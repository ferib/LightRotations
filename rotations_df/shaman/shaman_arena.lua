local addon, light = ...

local function combat()
    if not (target.exists and target.enemy and  target.alive) then
        return
    end

    if castable(SB.PrimordialWave, target) then
        return cast(SB.PrimordialWave, target)
    end
    if castable(SB.FeralSpirit, target) then
        return cast(SB.FeralSpirit, target)
    end
    if castable(SB.FlameShock, target) and not target.debuff(SB.FlameShock).up then
        return cast(SB.FlameShock, target)
    end
    if player.buff(SB.HotHand).up and castable(SB.LavaLash, target) then
        return cast(SB.LavaLash, target)
    end
    if --[[ no WindfuryTotem.up and ]] castable(SB.WindfuryTotem, target) then
        return cast(SB.WindfuryTotem, target)
    end
    if --[[ MaelstormWeapon 5+ and 2 charges and ]] castable(SB.ElementalBlast, target) then
        return cast(SB.ElementalBlast, target)
    end
    if target.debuff(SB.PrimordialWave).up and --[[ MaelstormWeapon 8+ ]] castable(SB.LightningBolt, target) then
        return cast(SB.LightningBolt, target)
    end
    if --[[ MaelstormWeapon 8+ and ]] player.buff(SB.FeralSpirit).up and castable(SB.ElementalBlast, target) then
        return cast(SB.ElementalBlast, target)
    end
    if --[[ MaelstormWeapon 10  and ]] castable(SB.LightningBolt, target) then
        return cast(SB.LightningBolt, target)
    end
    if castable(SB.IceStrike, target) then
        return cast(SB.IceStrike, target)
    end
    if player.buff(SB.Hailstorm).up and castable(SB.FrostShock, target) then
        return cast(SB.FrostShock, target)
    end
    if castable(SB.LavaLash, target) then
        return cast(SB.LavaLash, target)
    end
    if castable(SB.Stormstrike, target) then
        return cast(SB.Stormstrike, target)
    end
    if --[[ MaelstormWeapon 5+ and ]] castable(SB.LightningBolt, target) then
        return cast(SB.LightningBolt, target)
    end
    if castable(SB.FrostShock, target) then
        return cast(SB.FrostShock, target)
    end
    -- refresh Flame Shock?
    if castable(SB.FlameShock, target) then
        return cast(SB.FlameShock, target)
    end
    -- refresh Windfury Totem?
    if castable(SB.WindfuryTotem, target) then
        return cast(SB.WindfuryTotem, target)
    end
end

local function resting()
    if target.exists and target.enemy and  target.alive then
        if castable(SB.FlameShock, target) then
            return cast(SB.FlameShock, target)
        end
    end
end

light.rotation.register({
    class = light.rotation.classes.shaman,
    name = 'shaman',
    label = 'DF Shaman PvE',
    combat = combat,
    resting = resting
})
