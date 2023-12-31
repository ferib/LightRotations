local addon, light = ...

local function getBestHealingWave(hpMissing)
    local healingWaves = {331, 332, 547, 913, 939, 959, 8005, 10395, 10396, 25357}
    local maxHealing   = { 47,  83, 163, 328, 443,   0,    0,     0,     0,     0}
    -- find the one with least mana wasted

    hpMissing = hpMissing * 1.05 -- add err tolerance?
    -- TODO: adjust multiplier if 'savemana' enabled?

    for i=#maxHealing, 1, -1 do
        if IsSpellKnown(healingWaves[i]) and maxHealing[i] <= hpMissing then
            return healingWaves[i]
        end
    end
    return nil
end

local function getLowestHealthPlayer()
    -- eeh??
    local partyUnits = {player, party1, party2, party3, party4 }
    local raidUnits = {raid1, raid2, raid3, raid4, raid5, raid6, raid7, raid8, raid9, raid10}
    local units = {player}
    
    if UnitInParty("player") then
        units = partyUnits
    elseif UnitInRaid("player") then
        units = raidUnits
    end

    local lastLost = 0
    local lastUnit = nil

    for i=1, #units do
        local unit = units[i]
        --if unit.exists then
        --    print(#units, unit.name, unit.health.missing)
        --end
        if unit.exists and unit.alive and not unit.enemy and unit.health.missing > lastLost then
            lastUnit = unit
            lastLost = unit.health.missing
        end
    end

    return lastUnit, lastLost
end
setfenv(getLowestHealthPlayer, light.environment.env)

local function couldNeedSomeRain(belowXPercent)
    local partyUnits = {player, party1, party2, party3, party4 }
    local raidUnits = {raid1, raid2, raid3, raid4, raid5, raid6, raid7, raid8, raid9, raid10}
    local units = {player}
    
    if UnitInParty("player") then
        units = partyUnits
    elseif UnitInRaid("player") then
        units = raidUnits
    end

    local playersBelowCount = 0;
    local f = belowXPercent or 80

    for i=1, #units do
        local unit = units[i]
        --print(unit.name, unit.exists,CheckInteractDistance(unit, 2), unit.alive, not unit.enemy )
        if unit.exists and unit.alive and not unit.enemy then
            if unit.health.percent < f then
                playersBelowCount = playersBelowCount + 1
            end
        end
    end
    --print("rain", playersBelowCount, #units)
    return playersBelowCount >= 2
end
setfenv(couldNeedSomeRain, light.environment.env)

local function combat()
    -- combat
    local cooldowns = toggle("cooldowns", false)
    local inParty = UnitInParty("player");
    local singleTarget = not toggle("multitarget", false)
    local savemana = toggle("savemana", false)

    if cooldowns then
        if player.power.mana.percent < 85 and castable(SB.ShamanisticRage, player) 
        then
            cast(SB.ShamanisticRage)
        end
    end

    -- Keep Healing Stream Totem up 100%
    -- TODO: also check for healing buff and replace old?
    if --couldNeedSomeRain(99) and 
        (not GetTotemInfo(3) or not player.buff("Healing Stream").up) then -- water!
        if castable(SB.HealingStreamTotem) then
            return cast(SB.HealingStreamTotem)
        end
    end

    -- DMG TOTEMS
    if not GetTotemInfo(1) then -- fire! 
        -- always single target?
        if singleTarget then
            if castable(SB.SearingTotem) then
                return cast(SB.SearingTotem)
            end
        else
            if castable(SB.FireNovaTotem) then
                return cast(SB.FireNovaTotem)
            end
        end
    end

    -- Silence target?
    if target.exists and target.enemy and target.alive then
        if target.castingpercent > 0 and castable(SB.EarthShock, target) then
            print("EarthShock!")
            return cast(SB.EarthShock, target)
        end
    end

    -- AoE heal?
    if castable(SB.HealingRain, player) and couldNeedSomeRain(88) then
        return cast(SB.HealingRain, player)
    end

    -- best healing for party?
    --print(player.health.missing)

    -- target first
    if target.exists and target.alive and not target.enemy and target.health.missing >= 100 then
        print("Target healing missing", target.health.missing)
        local bestHeal = getBestHealingWave(target.health.missing)
        --print(player.health.missing, bestHeal)
        if bestHeal and castable(bestHeal, target) then
            return cast(bestHeal, target)
        end
        if castable(SB.HealingWave, player) then
            return cast(SB.healingWaves, target)
        end
    end

    -- find target?
    local lowUnit, hpMissing = getLowestHealthPlayer()
    if lowUnit ~= nil and hpMissing >= 47 then
        print("healing " .. lowUnit.name .. ", missing " .. hpMissing)
        local bestHeal = getBestHealingWave(hpMissing)
        if bestHeal ~= nil and castable(bestHeal, lowUnit) then
            return cast(bestHeal, lowUnit)
        end
        if castable(SB.HealingWave, lowUnit) then
            return cast(SB.healingWaves, lowUnit)
        end
    end
    

    -- near death?
    if player.health.actual < 200 then
        if castable(SB.HealingWave, player) then
            return cast(SB.HealingWave, player)
        end

    end

    if not player.buff(SB.WaterShield).up and castable(SB.WaterShield) then
        return cast(SB.WaterShield)
    end

end

local function resting()
    --print("x", player.name, party1.name, party2.name, party3.name, party4.name)
    --print("x", raid1.name, raid2.name, raid3.name, raid4.name, raid5.name, raid6.name, raid7.name, raid8.name, raid9.name, raid10.name)
    --print("a", raid1.name, raid1.health.missing, raid6.name, raid5.health.missing)

    if target.exists and target.enemy and target.alive then
        if castable(SB.FlameShock, target) then
            return cast(SB.FlameShock, target)
        end
    end

    -- resting
    if not player.buff(SB.WaterShield).up and castable(SB.WaterShield) then
        return cast(SB.WaterShield)
    end
end

local function interface()
    light.interface.buttons.add_toggle(
        {
            name = "savemana",
            label = "Save Mana",
            font = "dark_icon",
            on = {
                label = light.interface.icon("flask"),
                color = light.interface.color.blue,
                color2 = light.interface.color.dark_blue,
            },
            off = {
                label = light.interface.icon("flask"),
                color = light.color,
                color2 = light.color2
            }
        }
    )
end

light.rotation.register({
    class = light.rotation.classes.shaman,
    name = 'resto',
    label = 'Bundled Shaman',
    combat = combat,
    resting = resting,
    interface = interface
})
