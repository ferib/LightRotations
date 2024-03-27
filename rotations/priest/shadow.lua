local addon, light = ...

local lastHeal = 0

local function combat()
    -- never interupt channeling? waste of mana?
    if player.isChanneling then
        return
    end

    -- 90%
    if player.health.percent < 90 and not player.buff("Renew").up then
        return cast(SB.Renew, player)
    end

    local tick = GetTime()

    -- 50%?
    if player.health.percent < 50 and lastHeal+7 < tick then
        return cast(SB.LesserHeal, player)
    end

    -- 30% or lower?
    if player.health.percent < 30 and not player.debuff("Weakened Soul").up then
        return cast(SB.PowerWordShield, player)
    end

    -- Damage target
    if target.exists and target.enemy and target.alive then
        -- check 11 yards
        if not CheckInteractDistance("target", 2) then
            -- TOOD: in_range ?
            if castable(SB.MindFlay, target) and target.in_range("Mind Flay") 
            and not player.isChanneling then
                return cast(SB.MindFlay, target)
            end
        end
        
        if not target.debuff("Shadow Word: Pain").up and target.health.percent > 20 and castable(SB.ShadowWordPain, target) then
            return cast(SB.ShadowWordPain, target)
        end

        if castable(SB.MindBlast, target) and not player.isChanneling then
            return cast(SB.MindBlast, target)
        end

        if castable(SB.Smite, target) and not player.isChanneling then
            return cast(SB.Smite, target)
        end
       
    end
end

local function resting()
    -- opener xd
    if target.exists and target.enemy and target.alive then
        -- set a Renew b4 combat?
        if not player.buff("Renew").up and castable(SB.Renew, player) then
            return cast(SB.Renew, player)
        end
        if castable(SB.MindBlast, target) then
            return cast(SB.MindBlast, target)
        end
    end
    -- resting
    if player.alive then
        if not player.buff("Inner Fire").up then
            return cast(SB.InnerFire, player)
        end
        if not player.buff("Power Word: Fortitude").up then
            return cast(SB.PowerWordFortitude, player)
        end
    end
end

light.rotation.register({
    class = light.rotation.classes.priest,
    name = 'shadowp',
    label = 'Shadow Priest (leveling?)',
    combat = combat,
    resting = resting
})
