saiDB= { -- the defaults
	ginv = {
        ginv = true,
        guildinv = true,
        ginvite = true
    },
    inv = {
        inv = true,
        invite = true
    },
    confirm = true,
    keywordMatchMiddle = true,
    triggerOutgoingGInv = true,
    triggerOutgoingInv = false,
}
local nameAndVersion = "SimplyAutoInvite "..GetAddOnMetadata("SimplyAutoInvite", "Version")
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

	if dispatch then
		dispatch(self, ...)
	end
end

sai:SetScript("OnEvent", OnEvent)
sai:RegisterEvent("ADDON_LOADED")
-- sai:RegisterEvent("CHAT_MSG_BN_WHISPER")
-- sai:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
-- sai:RegisterEvent("CHAT_MSG_WHISPER")
-- sai:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
sai:RegisterEvent("CHAT_MSG_GUILD")

function sai:ADDON_LOADED(addonName)
    print("Loaded " .. nameAndVersion .. "; type '/sai info', for more info")
    
    if saiDB.ginv == nil then
        saiDB.ginv = {
            ginv = true,
            guildinv = true,
            ginvite = true
        }
    end
    if saiDB.inv == nil then
        saiDB.inv = {
            inv = true,
            invite = true
        }
    end
    if saiDB.confirm == nil then
        saiDB.confirm = true
    end
    if saiDB.keywordMatchMiddle == nil then
        saiDB.keywordMatchMiddle = true
    end
    if saiDB.triggerOutgoingGInv == nil then
        saiDB.triggerOutgoingGInv = true
    end
    if saiDB.triggerOutgoingInv == nil then
        saiDB.triggerOutgoingInv = false
    end
    
    StaticPopupDialogs["saiguildinvPopup"] = {
        text = "Do you want to invite %s to your guild?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function(self, data)
            GuildInvite(data)
        end,
        OnCancel = function()
            --do nuffin
            return
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3, 
    }
    
    StaticPopupDialogs["saigroupinvPopup"] = {
        text = "Do you want to invite %s to your party/raid?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function(self, data)
            InviteUnit(data)
        end,
        OnCancel = function()
            --do nuffin
            return
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3, 
    }
    
    self:UnregisterEvent("ADDON_LOADED")
end

function sai:CHAT_MSG_BN_WHISPER(msg, _, _, _, _, _, _, _, _, _, _, _, bnetIDAccount, _)
    _M.handleBnetWhisper(msg, bnetIDAccount, false)
end

function sai:CHAT_MSG_BN_WHISPER_INFORM(msg, _, _, _, _, _, _, _, _, _, _, _, bnetIDAccount, _)
    _M.handleBnetWhisper(msg, bnetIDAccount, true)
end

function sai:CHAT_MSG_WHISPER(msg, charname, _)
    _M.handleWhisper(msg, charname, false)
end

function sai:CHAT_MSG_WHISPER_INFORM(msg, charname, _)
    _M.handleWhisper(msg, charname, true)
end

function sai:CHAT_MSG_GUILD(msg, charname, _)
    -- print(saimsgPrefix .. "im monkey")
    _M.handleGuildMsg(msg, charname, true)
    return
end

function concatPrefix(s)
    return (s:gsub("%b[] ", ""))
end

_M.handleWhisper = function(msg, charname, outgoing)
    _M.process_msg(msg, charname, outgoing)
end

_M.handleGuildMsg = function(msg, charname, outgoing)
    -- print(saimsgPrefix .. "Guild message handled")
    _M.process_msg(msg, charname, outgoing)
end
_M.handleBnetWhisper = function(msg, bnetIDAccount, outgoing)
    local accountInfo = GetAccountInfoByID(bnetIDAccount)
    if(accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.characterName and accountInfo.gameAccountInfo.realmName) then
        local charname = accountInfo.gameAccountInfo.characterName .. '-' .. accountInfo.gameAccountInfo.realmName
        _M.process_msg(msg, charname, outgoing)
    end
end

_M.process_msg = function(msg, charname, outgoing)
    -- print(saimsgPrefix .. "message processed")
    msg = concatPrefix(msg)


    -- UNCOMMENT BELOW TO TEST FOR MATCHING
    -- print(saiDB.inv[msg])

    msg = msg:lower():trim()

    if saiDB.inv[msg] then
        -- print(saimsgPrefix .. "Trying to invite" ..charname .."")
        InviteUnit(charname)
        return
    end

    -- if saiDB.ginv[msg] and (not outgoing or saiDB.triggerOutgoingGInv) then
    --     local dialog = StaticPopup_Show("saiguildinvPopup", charname)
    --     if (dialog) then
    --         dialog.data = charname
    --     end
    --     return
    -- if saiDB.inv[msg] and (not outgoing or saiDB.triggerOutgoingInv) then
    --     print("inv matched and no outgoing")
    --     if(saiDB.confirm) then
    --         local dialog = StaticPopup_Show("saigroupinvPopup", charname)
    --         if (dialog) then
    --             dialog.data = charname
    --         end
    --     else
    --         print(saimsgPrefix .. "Trying to invite" ..charname .." to your party/raid")
    --         print(saimsgPrefix .. "Type '/sai toggleconfirm' to ask for confirmation before inviting")
    --         InviteUnit(charname)
    --     end
    --     return
    -- end
    if saiDB.keywordMatchMiddle then
        local found = false
        msg = ' ' .. msg .. ' '
        -- wrapping msg around spaces, so that it starts and ends with a non alphabetical letter
        -- for phrase in pairs(saiDB.ginv) do
        --     if (not outgoing) and msg:find('[^A-z]' .. phrase:lower():trim() .. '[^A-z]') then
        --         local dialog = StaticPopup_Show("saiguildinvPopup", charname)
        --         if (dialog) then
        --             found = true
        --             dialog.data = charname
        --         end
        --         break
        --     end
        -- end
        -- if not found then
        for phrase in pairs(saiDB.inv) do
            if (not outgoing) and msg:find('[^A-z]' .. phrase:lower():trim() .. '[^A-z]') then
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
            print(saimsgPrefix .. "an invite keyword was found in the whisper you received. Type \"/sai toggleSmartMatch\" if you don't want long whispers to trigger an invite.")
            if(not saiDB.confirm) then
                print(saimsgPrefix .. "The confirmation dialog cannot be disabled when Smart Match got triggered")
            end
        end
    end
end

_M.printInfo = function(subject)
    print(" ")
    print("|cffff0066Simply Auto Invite Instructions:|r")
    print("---------------------------------------------------------------------------")
    print("Create inviting keyword: |cFF5EFF56/sai add inv {keyword}|r")
    print("Delete inviting keyword: |cFFFF5956/sai remove inv {keyword}|r")
    print("---------------------------------------------------------------------------")
    print("After creating a keyword, if anyone types that keyword in your guild chat, you will automatically send them a group invite.")
end

-- Inviting function
_M.alterList = function(invtype, keyword, add)
    local syntaxerror = false
    if(invtype == nil) or (keyword == nil) then
        syntaxerror = true
    end
    if(invtype ~= "ginv" and invtype ~= "inv") then
        syntaxerror = true
    end
    if (syntaxerror) then
        if (add) then
            print(" ")
            print(saimsgPrefix .. "Incorrect usage. Correct usage is:")
            print("/sai add inv [*new keyword*]")
            print("Example: to invite someone when they type 'invpls' in /guild,")
            print("type '/sai add inv invpls'")
        else
            print(" ")
            print(saimsgPrefix .. "Incorrect usage. Correct usage is:")
            print("/sai remove inv [*keyword*]")
            print("Example: to remove the keyword 'invpls',")
            print("type '/sai remove inv invpls'")
        end
        return
    end
    -- saiDB[invtype][keyword] = val
    saiDB[invtype][keyword] = keyword

    if (add) then
        print(saimsgPrefix .. "added '" .. keyword .. "' to the list: " .. invtype)
    else
        print(saimsgPrefix .. "removed '" .. keyword .. "' from the list: " .. invtype)
    end
end


SLASH_sai1="/sai"
SlashCmdList["sai"] =
	function(msg)
		local a1, a2, a3 = strsplit(" ", strlower(msg), 3)
        if (a1 == "") then 
            _M.printInfo()
        elseif (a1 == "info")  then 
            _M.printInfo(a2)
        elseif(a1 == "add") then
            _M.alterList(a2, a3, true)
        elseif(a1 == "remove") then
            _M.alterList(a2, a3, false)
        end
    end   
