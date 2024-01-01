local addon, light = ...

local function getBestHeal(hpMissing)
    local healSpells = {2050, 2052, 2053} -- lesser heal only?
    local maxHealing   = {  58,   91,  165}
    -- find the one with least mana wasted

    hpMissing = hpMissing * 1.05 -- add err tolerance?
    -- TODO: adjust multiplier if 'savemana' enabled?

    for i=#maxHealing, 1, -1 do
        if IsSpellKnown(healSpells[i]) and maxHealing[i] <= hpMissing then
            return healSpells[i]
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

local function combat()
    -- combat
    local cooldowns = toggle("cooldowns", false)
    local inParty = UnitInParty("player");
    local singleTarget = not toggle("multitarget", false)
    local savemana = toggle("savemana", false)

    -- priority on target
    if 
        target.exists and target.alive and not target.enemy 
    then
        -- pop a renew if needed?
        -- first, check if shielded/can be shielded?
        if target.health.percent < 98 then
            if 
                --target.health.percent < 80 and 
                castable(SB.Renew, target) 
                and not player.buff(SB.Renew).up 
            then
                return cast(SB.Renew, target)
            end
            
            if target.health.percent < 85 and castable(SB.Penance, target) then
                return cast(SB.Penance, target)
            end

            if
                not target.debuff("Weakened Soul").up and 
                castable(SB.PowerWordShield, target) 
                and not target.buff(SB.PowerWordShield).up
            then
                return cast(SB.PowerWordShield, target)
            end

            -- otherwise, cast some heals!
            print("Target healing missing", target.health.missing)
            local bestHeal = getBestHeal(target.health.missing)
            if bestHeal and castable(bestHeal, target) then
                return cast(bestHeal, target)
            end

            -- no match? check our best heal(s) instead?
            if castable(SB.Heal, player) then
                return cast(SB.Heal, target)
            end
            if castable(SB.LesserHeal, player) then
                return cast(SB.LesserHeal, target)
            end
        end
    end

    -- target OK, find party member instead?
    local lowUnit, hpMissing = getLowestHealthPlayer()
    if lowUnit ~= nil and hpMissing >= 47 then
        if hpMissing < 80 then
            return cast(SB.Renew, lowUnit)
        end
        
        print("healing " .. lowUnit.name .. ", missing " .. hpMissing)
        local bestHeal = getBestHeal(hpMissing)
        if bestHeal ~= nil and castable(bestHeal, lowUnit) then
            return cast(bestHeal, lowUnit)
        end
        -- no match? check our best heal(s) instead?
        if castable(SB.Heal, player) then
            return cast(SB.Heal, target)
        end
        if castable(SB.LesserHeal, player) then
            return cast(SB.LesserHeal, target)
        end
    end

end

local function resting()
    -- -- resting
end

light.rotation.register({
    class = light.rotation.classes.priest,
    name = 'holy',
    label = 'Bundled Priest',
    combat = combat,
    resting = resting
})
