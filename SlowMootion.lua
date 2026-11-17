local unwanted_buff = "Plainsrunning"

print("SlowMootion loaded")


local function remove_buff(buff_name, auraInstanceID)
    if not UnitAffectingCombat("player") then
        C_UnitAuras.CancelAuraByInstanceID("player", auraInstanceID)
        print(buff_name, "remooved!") -- test code
    end
end


local aura_frame = CreateFrame("Frame")
aura_frame:RegisterUnitEvent("UNIT_AURA", "player")
aura_frame:SetScript("OnEvent", function(_, _, _, updateInfo)
    if UnitAffectingCombat("player") then
        return
    end

    if updateInfo.addedAuras then
         for _, aura in ipairs(updateInfo.addedAuras) do
            if aura.name == unwanted_buff then
                remove_buff(aura.name, aura.auraInstanceID)
            end
        end
    end
end)

local function scan_buffs(target_buff)
    local index = 1
    while true do
        local current_buff = C_UnitAuras.GetBuffDataByIndex("player", index)
        if current_buff == nil then
            break
        end
        if current_buff.name == target_buff then
            remove_buff(current_buff.name, current_buff.auraInstanceID)
            break
        end
        index = index + 1
    end
end

local scan_buffs_frame = CreateFrame("Frame")
scan_buffs_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
scan_buffs_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
scan_buffs_frame:SetScript("OnEvent", function()
    scan_buffs(unwanted_buff)
end)




































