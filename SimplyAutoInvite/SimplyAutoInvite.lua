saiDB = {
    inv = {inv = true, invite = true},
    confirm = true,
    keywordMatchMiddle = true,
    triggerOutgoingGInv = true,
    triggerOutgoingInv = false
}
local versionNumber = GetAddOnMetadata("SimplyAutoInvite", "Version")
local saimsgPrefix = "|cFFFF6B68<|r|cFFFF4CA9SAI|r|cFFFF6B68>|r "

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

function concatPrefix(s) return (s:gsub("%b[] ", "")) end

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
        print(
            "|cFFFF6B68›|r ------------------------------------------------------------------")
        print(
            "|cFFFF6B68›|r Create inviting keyword: |cFF5EFF56/sai add [keyword]|r")
        print(
            "|cFFFF6B68›|r Delete inviting keyword: |cFFFF5956/sai remove [keyword]|r")
        print("|cFFFF6B68›|r ")
        print("|cFFFF6B68›|r If anyone types your keyword in the guild chat,")
        print(
            "|cFFFF6B68›|r your client will automatically invite them to your group.")
        print(
            "|cFFFF6B68›|r ------------------------------------------------------------------")
    else
        print(saimsgPrefix .. "|cFFFF4343/sai " .. subject ..
                  " is not a valid command.|r")
        print(
            "|cFFFF6B68›|r |cFFFFCF56Please try '/sai help' for a list of commands.|r")
    end
end

-- Inviting function
_M.alterList = function(keyword, add)
    local error = false
    if (keyword == nil) then error = true end
    if (error) then
        if (add) then
            print(saimsgPrefix .. "|cFFFF4343Incorrect usage. Try:|r")
            print(
                "|cFFFF6B68›|r |cFFFFCF56'/sai add [new keyword]' (no brackets)|r")
        else
            print(saimsgPrefix .. "|cFFFF4343Incorrect usage. Try:|r")
            print(
                "|cFFFF6B68›|r |cFFFFCF56'/sai remove [keyword]' (no brackets)|r")
        end
        return

    else
        saiDB['inv'][keyword] = keyword
        if (add) then
            print(saimsgPrefix .. "|cFF5EFF56Added|r |cFFFFCF56'" .. keyword ..
                      "' |r|cFF5EFF56to your keywords|r")
        else
            print(
                saimsgPrefix .. "|cFFFF5956Removed|r |cFFFFCF56'" .. keyword ..
                    "' |r|cFFFF5956from your keywords|r")
        end
    end

end

SLASH_sai1 = "/sai"
SlashCmdList["sai"] = function(msg)
    local a1, a2 = strsplit(" ", strlower(msg), 2)
    if (a1 == "") then
        _M.printInfo("")
    elseif (a1 == "help") then
        _M.printInfo("")
    elseif (a1 == "add") then
        _M.alterList(a2, true)
    elseif (a1 == "remove") then
        _M.alterList(a2, false)
    else
        _M.printInfo(a1)
    end
end
