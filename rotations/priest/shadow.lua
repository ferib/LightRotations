local addon, light = ...

local lastHeal = 0
local mustPenance = false
local lastPenanceReq = 0

local function combat()
    -- never interupt channeling? waste of mana?
    if player.isChanneling then
        return
    end

    -- hibernating if low mana
    -- Just wand and Penance self? NOTE: Flakey AF
    if player.power.mana.percent < 15 then
        if player.health.percent < 80 and castable(SB.Penance, player) then
            if not mustPenance then
                mustPenance = true
                lastPenanceReq = GetTime()
                --print("stop shoot")
                return cast("Shoot") -- disable shooting?
                --Unlock(RunMacroText, "/stopattack")
            elseif lastPenanceReq+1.5 < GetTime() then -- make sure to check GCD
                mustPenance = false
                -- TODO: pre-shield to not get knocked?
                --print("start PENANCE")
                return cast(SB.Penance, player)
            end
        elseif mustPenance == false then
            --print("start shoot")
            Unlock(RunMacroText, "/castsequence !Shoot")
            return
        end
    end

    -- ???
    if mustPenance then
        if castable(SB.Penance, player) then
            mustPenance = false
            return cast(SB.Penance, player)
        end
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
        if not CheckInteractDistance("target", 2) or target.debuff("Blackout").up then
            -- TOOD: in_range ?
            if castable(SB.MindFlay, target) and target.in_range("Mind Flay") 
            and not player.isChanneling then
                return cast(SB.MindFlay, target)
            end
        end
        
        --if castable(SB.HolyFire, target) and target.health.actual > 90 then
        --    return cast(SB.HolyFire, target)
        --end

        if not target.debuff("Shadow Word: Pain").up and target.health.percent > 20 and castable(SB.ShadowWordPain, target) then
            return cast(SB.ShadowWordPain, target)
        end

        if castable(SB.Penance, target) then
            return cast(SB.Penance, target)
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

        -- 3.5sec cast, better have it out of combat (if learned)
        if castable(SB.HolyFire, target) then
            return cast(SB.HolyFire, target)
        end

        if castable(SB.MindBlast, target) then
            return cast(SB.MindBlast, target)
        end
    end
    -- resting
    if player.alive and not player.buff("Drink").up and not player.buff("Food").up then
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
