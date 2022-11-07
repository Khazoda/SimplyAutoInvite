saiDB = {
    inv = {inv = true, invite = true},
    confirm = true,
    keywordMatchMiddle = true,
    triggerOutgoingGInv = true,
    triggerOutgoingInv = false
}
local nameAndVersion = "SimplyAutoInvite " ..
                           GetAddOnMetadata("SimplyAutoInvite", "Version")
local saimsgPrefix = "<SimplyAutoInvite> "

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
    print("Loaded " .. nameAndVersion .. "; type '/sai info', for more info")

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
    print(" ")
    print("|cffff0066Simply Auto Invite Instructions:|r")
    print("----------------------------------------------------------------")
    print("Create inviting keyword: |cFF5EFF56/sai add [keyword]|r")
    print("Delete inviting keyword: |cFFFF5956/sai remove [keyword]|r")
    print("----------------------------------------------------------------")
    print("If anyone types your keyword in the guild chat,")
    print("your client will automatically invite them to your group.")

end

-- Inviting function
_M.alterList = function(keyword, add)
    local error = false
    if (keyword == nil) then error = true end
    if (error) then
        if (add) then
            print(" ")
            print(saimsgPrefix .. "Incorrect usage. Try:")
            print("|cFF5EFF56/sai add [*new keyword*]|r")
        else
            print(" ")
            print(saimsgPrefix .. "Incorrect usage. Try:")
            print("|cFFFF5956/sai remove [*keyword*]|r")
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
        _M.printInfo()
    elseif (a1 == "info") then
        _M.printInfo(a2)
    elseif (a1 == "add") then
        _M.alterList(a2, true)
    elseif (a1 == "remove") then
        _M.alterList(a2, false)
    end
end
