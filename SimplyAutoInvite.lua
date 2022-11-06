IOWDB= { -- the defaults
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
local IOWmsgPrefix = "<SimplyAutoInvite> "

local GuildInvite = GuildInvite
local InviteUnit = C_PartyInfo.InviteUnit
local print = print
local GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local lower = lower
local trim = trim
local strlower = strlower
local tinsert = tinsert
local _M = {}
IOWFunctions = _M

local IOW = CreateFrame("Frame", "SimplyAutoInvite")

local function OnEvent(self, event, ...)
	local dispatch = self[event]

	if dispatch then
		dispatch(self, ...)
	end
end

IOW:SetScript("OnEvent", OnEvent)
IOW:RegisterEvent("ADDON_LOADED")
-- IOW:RegisterEvent("CHAT_MSG_BN_WHISPER")
-- IOW:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
-- IOW:RegisterEvent("CHAT_MSG_WHISPER")
-- IOW:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
IOW:RegisterEvent("CHAT_MSG_GUILD")

function IOW:ADDON_LOADED(addonName)
    print("Loaded " .. nameAndVersion .. "; type '/iow info', for more info")
    
    if IOWDB.ginv == nil then
        IOWDB.ginv = {
            ginv = true,
            guildinv = true,
            ginvite = true
        }
    end
    if IOWDB.inv == nil then
        IOWDB.inv = {
            inv = true,
            invite = true
        }
    end
    if IOWDB.confirm == nil then
        IOWDB.confirm = true
    end
    if IOWDB.keywordMatchMiddle == nil then
        IOWDB.keywordMatchMiddle = true
    end
    if IOWDB.triggerOutgoingGInv == nil then
        IOWDB.triggerOutgoingGInv = true
    end
    if IOWDB.triggerOutgoingInv == nil then
        IOWDB.triggerOutgoingInv = false
    end
    
    StaticPopupDialogs["IOWguildinvPopup"] = {
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
    
    StaticPopupDialogs["IOWgroupinvPopup"] = {
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

function IOW:CHAT_MSG_BN_WHISPER(msg, _, _, _, _, _, _, _, _, _, _, _, bnetIDAccount, _)
    _M.handleBnetWhisper(msg, bnetIDAccount, false)
end

function IOW:CHAT_MSG_BN_WHISPER_INFORM(msg, _, _, _, _, _, _, _, _, _, _, _, bnetIDAccount, _)
    _M.handleBnetWhisper(msg, bnetIDAccount, true)
end

function IOW:CHAT_MSG_WHISPER(msg, charname, _)
    _M.handleWhisper(msg, charname, false)
end

function IOW:CHAT_MSG_WHISPER_INFORM(msg, charname, _)
    _M.handleWhisper(msg, charname, true)
end

function IOW:CHAT_MSG_GUILD(msg, charname, _)
    -- print(IOWmsgPrefix .. "im monkey")
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
    -- print(IOWmsgPrefix .. "Guild message handled")
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
    -- print(IOWmsgPrefix .. "message processed")
    msg = concatPrefix(msg)


    -- UNCOMMENT BELOW TO TEST FOR MATCHING
    -- print(IOWDB.inv[msg])

    msg = msg:lower():trim()

    if IOWDB.inv[msg] then
        -- print(IOWmsgPrefix .. "Trying to invite" ..charname .."")
        InviteUnit(charname)
        return
    end

    -- if IOWDB.ginv[msg] and (not outgoing or IOWDB.triggerOutgoingGInv) then
    --     local dialog = StaticPopup_Show("IOWguildinvPopup", charname)
    --     if (dialog) then
    --         dialog.data = charname
    --     end
    --     return
    -- if IOWDB.inv[msg] and (not outgoing or IOWDB.triggerOutgoingInv) then
    --     print("inv matched and no outgoing")
    --     if(IOWDB.confirm) then
    --         local dialog = StaticPopup_Show("IOWgroupinvPopup", charname)
    --         if (dialog) then
    --             dialog.data = charname
    --         end
    --     else
    --         print(IOWmsgPrefix .. "Trying to invite" ..charname .." to your party/raid")
    --         print(IOWmsgPrefix .. "Type '/iow toggleconfirm' to ask for confirmation before inviting")
    --         InviteUnit(charname)
    --     end
    --     return
    -- end
    if IOWDB.keywordMatchMiddle then
        local found = false
        msg = ' ' .. msg .. ' '
        -- wrapping msg around spaces, so that it starts and ends with a non alphabetical letter
        -- for phrase in pairs(IOWDB.ginv) do
        --     if (not outgoing) and msg:find('[^A-z]' .. phrase:lower():trim() .. '[^A-z]') then
        --         local dialog = StaticPopup_Show("IOWguildinvPopup", charname)
        --         if (dialog) then
        --             found = true
        --             dialog.data = charname
        --         end
        --         break
        --     end
        -- end
        -- if not found then
        for phrase in pairs(IOWDB.inv) do
            if (not outgoing) and msg:find('[^A-z]' .. phrase:lower():trim() .. '[^A-z]') then
                local dialog = StaticPopup_Show("IOWgroupinvPopup", charname)
                if (dialog) then
                    found = true
                    dialog.data = charname
                    
                end
                break
            end
        end
        -- end
        if found then
            print(IOWmsgPrefix .. "an invite keyword was found in the whisper you received. Type \"/iow toggleSmartMatch\" if you don't want long whispers to trigger an invite.")
            if(not IOWDB.confirm) then
                print(IOWmsgPrefix .. "The confirmation dialog cannot be disabled when Smart Match got triggered")
            end
        end
    end
end

_M.printInfo = function(subject)
    print(" ")
    print("|cffff0066Simply Auto Invite Instructions:|r")
    print("---------------------------------------------------------------------------")
    print("Create inviting keyword: |cFF5EFF56/iow add inv {keyword}|r")
    print("Delete inviting keyword: |cFFFF5956/iow remove inv {keyword}|r")
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
            print(IOWmsgPrefix .. "Incorrect usage. Correct usage is:")
            print("/iow add inv [*new keyword*]")
            print("Example: to invite someone when they type 'invpls' in /guild,")
            print("type '/iow add inv invpls'")
        else
            print(" ")
            print(IOWmsgPrefix .. "Incorrect usage. Correct usage is:")
            print("/iow remove inv [*keyword*]")
            print("Example: to remove the keyword 'invpls',")
            print("type '/iow remove inv invpls'")
        end
        return
    end
    -- IOWDB[invtype][keyword] = val
    IOWDB[invtype][keyword] = keyword

    if (add) then
        print(IOWmsgPrefix .. "added '" .. keyword .. "' to the list: " .. invtype)
    else
        print(IOWmsgPrefix .. "removed '" .. keyword .. "' from the list: " .. invtype)
    end
end


SLASH_IOW1="/iow"
SlashCmdList["IOW"] =
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
        elseif(a1 == "toggleconfirm") then
            IOWDB.confirm = (not IOWDB.confirm)
            if(IOWDB.confirm) then
                print(IOWmsgPrefix .. "confirmation for group invites is now turned ON")
            else
                print(IOWmsgPrefix .. "confirmation for group invites is now turned OFF")
            end
        elseif(a1 == "toggleoutgoingtrigger") then
            if a2 == 'ginv' then
                IOWDB.triggerOutgoingGInv = (not IOWDB.triggerOutgoingGInv)
                if(IOWDB.triggerOutgoingGInv) then
                    print(IOWmsgPrefix .. "triggering from outgoing whispers for guild invite is now turned ON")
                else
                    print(IOWmsgPrefix .. "triggering from outgoing whispers for guild invite is now turned OFF")
                end
            else
                IOWDB.triggerOutgoingInv = (not IOWDB.triggerOutgoingInv)
                if(IOWDB.triggerOutgoingInv) then
                    print(IOWmsgPrefix .. "triggering from outgoing whispers for group invite is now turned ON")
                else
                    print(IOWmsgPrefix .. "triggering from outgoing whispers for group invite is now turned OFF")
                end
            end
        elseif(a1 == "togglesmartmatch") then
            IOWDB.keywordMatchMiddle = (not IOWDB.keywordMatchMiddle)
            print(IOWmsgPrefix .. "smart match will search your received whispers for an invite keyword. the 'invite' keyword would then be triggered from \"Could you send me an invite please?\"")
            if(IOWDB.keywordMatchMiddle) then
                print(IOWmsgPrefix .. "smart match is now turned ON")
            else
                print(IOWmsgPrefix .. "smart match is now turned OFF")
            end
        end
    end   
