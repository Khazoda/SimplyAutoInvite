saiDB = {
    inv = {inv = true, invite = true},
    confirm = true,
    keywordMatchMiddle = true,
    triggerOutgoingGInv = true,
    triggerOutgoingInv = false
}
keywordDB = {}
local versionNumber = GetAddOnMetadata("SimplyAutoInvite", "Version")
local saimsgPrefix = "|cFFFF6B68<|r|cFFFF4CA9SAI|r|cFFFF6B68>|r "
local saimsgCurio = "|cFFFF6B68›|r "

local clearAwaitingConfirmation = false
local GuildInvite = GuildInvite
local InviteUnit = C_PartyInfo.InviteUnit
local print = print
local GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local lower = lower
local trim = trim
local strlower = strlower
local tinsert = tinsert
local _M = {}
saiFunctions = _M

local sai = CreateFrame("Frame", "SimplyAutoInvite")

local function OnEvent(self, event, ...)
    local dispatch = self[event]

    if dispatch then dispatch(self, ...) end
end

sai:SetScript("OnEvent", OnEvent)
sai:RegisterEvent("ADDON_LOADED")
sai:RegisterEvent("CHAT_MSG_GUILD")

function sai:ADDON_LOADED(addonName)
    print("|cFFFF6B68<|r|cFFFF4CA9SimplyAutoInvite|r|cFFFF6B68>|r " ..
              "Addon Version " .. versionNumber ..
              " loaded. Type |cFF5EFF56'/sai help'|r for a list of commands.")

    if saiDB.inv == nil then saiDB.inv = {inv = true, invite = true} end
    if saiDB.confirm == nil then saiDB.confirm = true end
    if saiDB.keywordMatchMiddle == nil then saiDB.keywordMatchMiddle = true end
    if saiDB.triggerOutgoingGInv == nil then saiDB.triggerOutgoingGInv = true end
    if saiDB.triggerOutgoingInv == nil then saiDB.triggerOutgoingInv = false end

    self:UnregisterEvent("ADDON_LOADED")
end

function sai:CHAT_MSG_GUILD(msg, charname, _)
    _M.handleGuildMsg(msg, charname, true)
    return
end

-- Helper functions
function concatPrefix(s) return (s:gsub("%b[] ", "")) end

local function has_value(tab, val)
    for index, value in ipairs(tab) do if value == val then return true end end

    return false
end
_M.handleGuildMsg = function(msg, charname, outgoing)
    _M.process_msg(msg, charname, outgoing)
end

_M.process_msg = function(msg, charname, outgoing)
    msg = concatPrefix(msg)
    msg = msg:lower():trim()

    if saiDB.inv[msg] then
        InviteUnit(charname)
        return
    end

    if saiDB.keywordMatchMiddle then
        local found = false
        msg = ' ' .. msg .. ' '

        for phrase in pairs(saiDB.inv) do
            if (not outgoing) and
                msg:find('[^A-z]' .. phrase:lower():trim() .. '[^A-z]') then
                local dialog = StaticPopup_Show("saigroupinvPopup", charname)
                if (dialog) then
                    found = true
                    dialog.data = charname

                end
                break
            end
        end
        -- end
        if found then
            print(saimsgPrefix ..
                      "an invite keyword was found in the whisper you received. Type \"/sai toggleSmartMatch\" if you don't want long whispers to trigger an invite.")
            if (not saiDB.confirm) then
                print(saimsgPrefix ..
                          "The confirmation dialog cannot be disabled when Smart Match got triggered")
            end
        end
    end
end

_M.printInfo = function(subject)
    if (subject == "") then
        print(
            "|cFFFF6B68<|r|cFFFF4CA9SimplyAutoInvite|r|cFFFF6B68>|r  Instructions:|r")
        print(saimsgCurio ..
                  "------------------------------------------------------------------")
        print(saimsgCurio ..
                  "Create inviting keyword: |cFF5EFF56/sai add [keyword]|r")
        print(saimsgCurio ..
                  "Delete inviting keyword: |cFFFF5956/sai remove [keyword index]|r")
        print(saimsgCurio)
        print(saimsgCurio .. "If anyone types your keyword in the guild chat,")
        print(saimsgCurio ..
                  "your client will automatically invite them to your group.")
        print(saimsgCurio .. "")
        print(saimsgCurio ..
                  "To see your active keywords, type |cFFFFCF56/sai list|r")
        print(saimsgCurio ..
                  "------------------------------------------------------------------")
    else
        print(saimsgPrefix .. "|cFFFF4343/sai " .. subject ..
                  " is not a valid command.|r")
        print(saimsgCurio ..
                  "Please try |cFFFFCF56'/sai help'|r for a list of commands.")
    end
end

-- Inviting function
_M.alterList = function(keyword, add)
    local error = false
    if (keyword == nil) then error = true end
    if (error) then
        if (add) then

            print(saimsgPrefix .. "|cFFFF4343Incorrect usage.|r Try:")
            print(saimsgCurio ..
                      "|cFFFFCF56'/sai add [new keyword]' (no brackets)|r")
        else
            print(saimsgPrefix .. "|cFFFF4343Incorrect usage.|r Try:")
            print(saimsgCurio ..
                      "|cFFFFCF56'/sai remove [keyword index]' (no brackets)|r")
        end
        return

    else
        if (add) then
            if (has_value(keywordDB, keyword)) then
                print(saimsgPrefix .. "|cFFFF4343Keyword '" .. keyword ..
                          "' is already active.|r")
            else
                table.insert(keywordDB, keyword)
                print(
                    saimsgPrefix .. "|cFF5EFF56Added|r |cFFFFCF56'" .. keyword ..
                        "' |r|cFF5EFF56to your keywords|r")
            end
        else
            -- Removes keyword at given numerical index
            local index = tonumber(keyword)
            if (type(index) == "number" and index <= #keywordDB) then
                local removed_keyword = keywordDB[index]

                table.remove(keywordDB, index)
                print(saimsgPrefix .. "|cFFFF5956Removed|r |cFFFFCF56'" ..
                          removed_keyword ..
                          "' |r|cFFFF5956from your keywords|r")
            else
                print(saimsgPrefix ..
                          '|cFFFF4343Please enter a valid index. Type |r|cFFFFCF56/sai list |cFFFF4343to see keyword indices|r')
            end

        end
    end

end

_M.clearList = function()
    print(saimsgPrefix ..
              "|cFFFF5956WARNING:|r Are you sure you want to clear your list of keywords?")
    print(saimsgCurio .. "If you are, please type  |cFFFFCF56/sai confirm|r")
    clearAwaitingConfirmation = true
end

_M.confirmClear = function()
    if (clearAwaitingConfirmation) then
        keywordDB = {}
        print(saimsgPrefix .. "|cFF009DFFYour keywords have been cleared.")
    end
end

_M.listList = function()
    print(saimsgPrefix .. "List of active keywords:")
    print(saimsgCurio .. "-----------------------------------")
    for index, data in ipairs(keywordDB) do
        if (index % 2 == 0) then
            print(saimsgCurio .. "|cFFFF8BD2" .. index .. " - " .. data .. "|r")
        else
            print(saimsgCurio .. "|cFFFF8B68" .. index .. " - " .. data .. "|r")
        end
    end
end

SLASH_sai1 = "/sai"
SlashCmdList["sai"] = function(msg)
    local a1, a2 = strsplit(" ", strlower(msg), 2)
    if (a1 == "confirm") then
        _M.confirmClear()
    else
        clearAwaitingConfirmation = false
        if (a1 == "") then
            _M.printInfo("")
        elseif (a1 == "help") then
            _M.printInfo("")
        elseif (a1 == "add") then
            _M.alterList(a2, true)
        elseif (a1 == "remove") then
            _M.alterList(a2, false)
        elseif (a1 == "clear") then
            _M.clearList()
        elseif (a1 == "list") then
            _M.listList()
        else
            _M.printInfo(a1)
        end
    end
end

