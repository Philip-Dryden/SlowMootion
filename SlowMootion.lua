local unwanted_buffs = {
    ["Plainsrunning"] = true,
    ["Warchief's Blessing"] = true
}

local test_mode = true

print("SlowMootion loaded")


local function remove_buff(buff_name, auraInstanceID)
    if not UnitAffectingCombat("player") then
        C_UnitAuras.CancelAuraByInstanceID("player", auraInstanceID)
        if test_mode then
            print(buff_name, "remooved!")
        end
    end
end


local aura_frame = CreateFrame("Frame")
aura_frame:RegisterUnitEvent("UNIT_AURA", "player") -- Runs the following script every time there is a change in the player's auras
aura_frame:SetScript("OnEvent", function(_, _, _, updateInfo)

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
end)

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

local scan_buffs_frame = CreateFrame("Frame")
scan_buffs_frame:RegisterEvent("PLAYER_ENTERING_WORLD") -- Activated when the player logs in or /reload the UI
scan_buffs_frame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Since the API makes scans during active combat impossible, leaving combat causes a new scan
scan_buffs_frame:SetScript("OnEvent", function()
    scan_buffs()
end)




































