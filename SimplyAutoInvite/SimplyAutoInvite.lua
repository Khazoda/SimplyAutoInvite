KeywordDB = {}
local versionNumber = GetAddOnMetadata("SimplyAutoInvite", "Version")

local saimsgPrefixLong =
    "|cFFFF6B68<|r|cFFD47FAAS|r|cFFE28EA5i|r|cFFF9B280m|r|cFFFBCE80p|r|cFFFBE397l|r|cFFAFC58Cy|r|cFFFBE397A|r|cFFFBCE80u|r|cFFF9B280t|r|cFFE28EA5o|r|cFFD47FAAI|r|cFFE28EA5n|r|cFFF9B280v|r|cFFFBCE80i|r|cFFFBE397t|r|cFFAFC58Ce|r|r|cFFFF6B68>|r "
local saimsgPrefix = "|cFFFF6B68<|r|cFFFF4CA9SAI|r|cFFFF6B68>|r "
local saimsgCurio = "|cFFFF6B68›|r "

local clearAwaitingConfirmation = false
local InviteUnit = C_PartyInfo.InviteUnit
local strlower = strlower
local print = print

local _SAI = {}
saiFunctions = _SAI

local sai = CreateFrame("Frame", "SimplyAutoInvite")

local function OnEvent(self, event, ...)
    local dispatch = self[event]

    if dispatch then dispatch(self, ...) end
end

sai:SetScript("OnEvent", OnEvent)
sai:RegisterEvent("ADDON_LOADED")
sai:RegisterEvent("CHAT_MSG_GUILD")

function sai:ADDON_LOADED(addonName)
    print(saimsgPrefixLong .. "Addon Version " .. versionNumber ..
              " loaded. Type |cFF5EFF56'/sai help'|r for a list of commands.")

    self:UnregisterEvent("ADDON_LOADED")
end

function sai:CHAT_MSG_GUILD(msg, charname, _)
    _SAI.process_msg(msg, charname, true)
    return
end

-- Helper functions
function ConcatPrefix(s)
    -- Replace square brackets with an empty string
    local string = s:gsub("%b[] ", "")
    -- Replace parentheses with an empty string
    string = string:gsub("%b() ", "")
    -- Replace curly braces with an empty string
    string = string:gsub("%b{} ", "")

    return string
end

local function has_value(tab, val)
    for index, value in ipairs(tab) do if value == val then return true end end

    return false
end

_SAI.process_msg = function(msg, charname, outgoing)
    msg = ConcatPrefix(msg)
    msg = msg:lower():trim()

    if (has_value(KeywordDB, msg)) then
        InviteUnit(charname)
        return
    end

end

_SAI.printInfo = function(subject)
    if (subject == "") then
        print(
            "|cFFFF6B68<|r|cFFFF4CA9SimplyAutoInvite|r|cFFFF6B68>|r  Instructions:|r")
        print(saimsgCurio ..
                  "------------------------------------------------------------------")
        print(saimsgCurio .. "Create keyword: |cFF5EFF56/sai add [keyword]|r")
        print(saimsgCurio ..
                  "Delete keyword: |cFFFF5956/sai remove [keyword index]|r")
        print(saimsgCurio)
        print(saimsgCurio .. "If anyone types your keyword in the guild chat,")
        print(saimsgCurio ..
                  "your client will automatically invite them to your group.")
        print(saimsgCurio .. "")
        print(saimsgCurio ..
                  "To delete all your active keywords, type |cFF00CAFF/sai clear|r")
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
_SAI.alterList = function(keyword, add)
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
            if (has_value(KeywordDB, keyword)) then
                print(saimsgPrefix .. "|cFFFF4343Keyword '" .. keyword ..
                          "' is already active.|r")
            else
                table.insert(KeywordDB, keyword)
                print(
                    saimsgPrefix .. "|cFF5EFF56Added|r |cFFFFCF56'" .. keyword ..
                        "' |r|cFF5EFF56to your keywords|r")
            end
        else
            -- Removes keyword at given numerical index
            local index = tonumber(keyword)
            if (type(index) == "number" and index <= #KeywordDB) then
                local removed_keyword = KeywordDB[index]

                table.remove(KeywordDB, index)
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

_SAI.clearList = function()
    print(saimsgPrefix ..
              "|cFFFF5956WARNING:|r Are you sure you want to clear your list of keywords?")
    print(saimsgCurio .. "If you are, please type  |cFFFFCF56/sai confirm|r")
    clearAwaitingConfirmation = true
end

_SAI.confirmClear = function()
    if (clearAwaitingConfirmation) then
        KeywordDB = {}
        print(saimsgPrefix .. "|cFF009DFFYour keywords have been cleared.")
    end
end

_SAI.listList = function()
    print(saimsgPrefix .. "List of active keywords:")
    print(saimsgCurio .. "-----------------------------------")
    for index, data in ipairs(KeywordDB) do
        if (index % 2 == 0) then
            print(saimsgCurio .. "|cFFFF8BD2" .. index .. " - " .. data .. "|r")
        else
            print(saimsgCurio .. "|cFFFF8B68" .. index .. " - " .. data .. "|r")
        end
    end
end

_SAI.june = function()
    for i = 1, 10, 1 do
        print(saimsgPrefixLong .. saimsgPrefixLong .. saimsgPrefixLong ..
                  saimsgPrefixLong)
    end
    print("Take care of yourself and stay healthy <3")
    for i = 1, 10, 1 do
        print(saimsgPrefixLong .. saimsgPrefixLong .. saimsgPrefixLong ..
                  saimsgPrefixLong)
    end
end

SLASH_sai1 = "/sai"
SlashCmdList["sai"] = function(msg)
    local a1, a2 = strsplit(" ", strlower(msg), 2)
    if (a1 == "confirm") then
        _SAI.confirmClear()
    else
        clearAwaitingConfirmation = false
        if (a1 == "") then
            _SAI.printInfo("")
        elseif (a1 == "help") then
            _SAI.printInfo("")
        elseif (a1 == "add") then
            _SAI.alterList(a2, true)
        elseif (a1 == "remove") then
            _SAI.alterList(a2, false)
        elseif (a1 == "clear") then
            _SAI.clearList()
        elseif (a1 == "list") then
            _SAI.listList()
        elseif (a1 == "june") then
            _SAI.june()
        else
            _SAI.printInfo(a1)
        end
    end
end

