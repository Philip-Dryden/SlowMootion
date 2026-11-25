local unwanted_buffs = {
    ["Plainsrunning"] = true,
    ["Warchief's Blessing"] = false
}

local test_mode = true
local addon_enabled = false

print("SlowMootion loaded")


local function remove_buff(buff_name, auraInstanceID)
    if not UnitAffectingCombat("player") then
        C_UnitAuras.CancelAuraByInstanceID("player", auraInstanceID)
        if test_mode then
            print(buff_name, "remooved!")
        end
    end
end


local function scan_buffs() -- goes through the list of active buffs and compares them with the table of unwanted buffs
    local index = 1
    while true do
        local current_buff = C_UnitAuras.GetBuffDataByIndex("player", index)
        if current_buff == nil then
            break
        end
        if unwanted_buffs[current_buff.name] then
            remove_buff(current_buff.name, current_buff.auraInstanceID)
            break
        end
        index = index + 1
    end
end


local function scan_aura_updates(updateInfo) -- scans recently added auras for unwanted buffs
    if UnitAffectingCombat("player") then -- API blocks access to this information in combat and causes Lua errors.
        return -- Because of that, being in combat stops the aura scan. Leaving combat causes a different scan.
    end

    if updateInfo.addedAuras then -- if the aura change was caused by adding a new aura, it goes through the recently added auras and compares them with the table of unwanted buffs
         for _, aura in ipairs(updateInfo.addedAuras) do
                if unwanted_buffs[aura.name] then
                    remove_buff(aura.name, aura.auraInstanceID) -- removal requires the auraInstanceID
                end
        end
    end
end


local event_frame = CreateFrame("Frame")
event_frame:SetScript("OnEvent", function(_, event, _, updateInfo)
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
        scan_buffs()
    end
    if event == "UNIT_AURA" then
        scan_aura_updates(updateInfo)
    end
end)


local function enable_addon()
    event_frame:RegisterEvent("PLAYER_ENTERING_WORLD") -- Activated when the player logs in or /reload the UI
    event_frame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Since the API makes scans during active combat impossible, leaving combat causes a new scan
    event_frame:RegisterUnitEvent("UNIT_AURA", "player") -- Runs the following script every time there is a change in the player's auras
    if test_mode then
        print("SlowMootion activated!")
    end
    scan_buffs() -- one manual scan in case the unwanted buffs are already present when the addon gets activated
end


local function disable_addon()
    event_frame:UnregisterAllEvents()
        if test_mode then
        print("SlowMootion deactivated!")
    end
end


local function toggle_addon()
    addon_enabled = not addon_enabled
    if addon_enabled then
        enable_addon()
    else
        disable_addon()
    end
end


SLASH_SLOWMOO1 = "/slowmoo"
SlashCmdList["SLOWMOO"] = toggle_addon
