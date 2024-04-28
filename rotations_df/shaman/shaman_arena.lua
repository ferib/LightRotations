local addon, light = ...

local bursting = false
local lastBurst = 0
local lastBurstStep = 1;

local function combat()
    if not (target.exists and target.enemy and  target.alive) then
        return
    end

    if IsMounted() then
        Unlock("RunMacroText", "/dismount")
        Unlock("CastSpellByName", "Swift Purple Gryphon")
    end

    local cooldowns = toggle("cooldowns", false)

    -- TODO: Wind Shear & Gounrding Totem on focus

    -- up Eearth Shield on big dmg taker
    -- use Flametongue & Lightning Shield on resting

    -- always do this for the GCD
    if not IsCurrentSpell(6603) and castable(SB.AutoAttack, target) then
        cast(SB.AutoAttack, target)
    end

    -- auto interrupt?
    --if Unit

    -- defences
    if player.health.percent < 95 and castable(SB.GiftOfTheNaruu, player) then
        cast(SB.GiftOfTheNaruu, player) -- instant no GCD ;D
    end
    if player.health.percent < 40 and castable(SB.GroundingTotem, player) then
        return cast(SB.GroundingTotem, player)
    end
    if not player.buff(SB.EarthShield).up and castable(SB.EarthShield, player) then
        return cast(SB.EarthShield, player)
    end
    if player.health.percent < 80 and castable(SB.AstralShift) then
        return cast(SB.AstralShift, player)
    end
    if player.health.percent < 80 and castable(SB.EarthElement) then
        return cast(SB.EarthElement)
    end

    -- include burst dmg
    if not bursting and player.buff(SB.MaelstormWeapon).count >= 9 then
        bursting = true
        lastBurst = GetTime()
        lastBurstStep = 1;
    end
    if bursting and cooldowns then
        print("burst", lastBurstStep)
        if lastBurstStep == 1 and castable(SB.FeralSpirit) then
            lastBurstStep = lastBurstStep + 1;
            return cast(SB.FeralSpirit)
        end

        -- skip CD
        if not castable(SB.FeralSpirit) then
            lastBurstStep = lastBurstStep + 1
        end

        if lastBurstStep == 2 and castable(SB.Stormstrike, target) then
            lastBurstStep = lastBurstStep + 1;
            return cast(SB.Stormstrike, target)
        end
        if lastBurstStep == 3 and castable(SB.PrimordialWave, target) then
            lastBurstStep = lastBurstStep + 1;
            return cast(SB.PrimordialWave, target)
        end
        if lastBurstStep == 4 and castable(SB.ElementalBlast, target) then
            lastBurstStep = lastBurstStep + 1;
            return cast(SB.ElementalBlast, target)
        end
        if lastBurstStep == 5 and castable(SB.LightningBolt, target) then -- instant?
            lastBurstStep = lastBurstStep + 1;
            return cast(SB.LightningBolt, target)
        end
        if lastBurstStep == 6 and castable(SB.LavaLash, target) then -- TODO: HotHand buff?
            lastBurstStep = lastBurstStep + 1;
            return cast(SB.LavaLash, target)
        end
        if lastBurstStep == 7 and castable(SB.Stormstrike, target) then
            lastBurstStep = lastBurstStep + 1;
            return cast(SB.Stormstrike, target)
        end
        if lastBurstStep == 8 and castable(SB.IceStrike, target) then
            lastBurstStep = lastBurstStep + 1;
            return cast(SB.IceStrike, target)
        end
        if lastBurstStep == 9 and castable(SB.FrostShock, target) then
            lastBurstStep = lastBurstStep + 1;
            return cast(SB.FrostShock, target)
        end

        if lastBurstStep >= 9 then
            bursting = false
        end

        -- do not waste?
        if castable(SB.ElementalBlast, target) then
            return cast(SB.ElementalBlast, target)
        end
        
        -- ALWAYS RETURN to keep burst sequence
        -- maybe not?
        return
    end

    --print("MaelstormWeapon: " .. tostring(player.buff(SB.MaelstormWeapon).count))

    -- pvp
    --if castable(SB.HealingStreamTotem) then
    -- GetTotemInfo(3)
    --end
    

    if castable(SB.FlameShock, target) then
        return cast(SB.FlameShock, target)
    end

    -- keep that up?
    if castable(SB.FrostShock, target) then
        return cast(SB.FrostShock, target)
    end

    if castable(SB.LavaLash, target) then
        return cast(SB.LavaLash, target)
    end
    if castable(SB.Stormstrike, target) then
        return cast(SB.Stormstrike, target)
    end

    if castable(SB.EarthgrabTotem) then
        cast(SB.EarthgrabTotem)
        ClickPosition(ObjectPosition("target"))
        return
    end

    
    -- quick totem check here
    if castable(SB.WindfuryTotem, target) and not GetTotemInfo(1) then -- wind totem
        return cast(SB.WindfuryTotem, target)
    end

    if castable(SB.Stormstrike, target) and player.buff(SB.Stormbringer).up then
        return cast(SB.Stormstrike, target)
    end
    if castable(SB.IceStrike, target) then -- and target.in_range("IceStrike") then
        cast(SB.IceStrike, target)
    end

    

    if not cooldowns and player.buff(SB.MaelstormWeapon).count >= 8 and castable(SB.ElementalBlast, target) then
        return cast(SB.ElementalBlast, target)
    end

    -- burst?
    --if player.buff(SB.HotHand).up and castable(SB.LavaLash, target) then
    --    return cast(SB.LavaLash, target)
    --end

    -- eeh? more dmg?
    if player.buff(SB.Hailstorm).up and castable(SB.FrostShock, target) then
        return cast(SB.FrostShock, target)
    end

end

local function resting()
    bursting = false;
    
    if target.exists and target.enemy and  target.alive then
        if not IsCurrentSpell(6603) and castable(SB.AutoAttack, target) then
            cast(SB.AutoAttack, target)
        end
        if castable(SB.FlameShock, target) then
            return cast(SB.FlameShock, target)
        end
    end

    --if castable(SB.FlametongueWeapon, player) and not player.buff(SB.Flametongue2).up then
    --    return cast(SB.FlametongueWeapon, player)
    --end
    if castable(SB.LightningShield, player) and not player.buff(SB.LightningShield).up then
        return cast(SB.LightningShield, player)
    end
    if castable(SB.EarthShield, player) and (not player.buff(SB.EarthShield).up or player.buff(SB.EarthShield).count < 9) then
        return cast(SB.EarthShield, player)
    end

-- /run Unlock(CastSpellByName, 420281)

end

light.rotation.register({
    class = light.rotation.classes.shaman,
    name = 'shaman',
    label = 'DF Shaman PvE',
    combat = combat,
    resting = resting
})
