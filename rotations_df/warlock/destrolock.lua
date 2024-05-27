local addon, light = ...

local function combat()
    if not target.exists or not target.enemy or not target.alive then
        return
    end

    -- instant cast Incinerate
    if player.buff(SB.Backlash).up and castable(SB.Incinerate, target) then
        return cast(SB.Incinerate, target)
    end

    if castable(SB.Conflagrate, target) and not player.buff(SB.Backdraft).up then
        return cast(SB.Conflagrate, target)
    end

    if castable(SB.Immolate, target) and not target.debuff(SB.Immolate).up then
        return cast(SB.Immolate, target)
    end

    -- check for a Choas Bolt?

    if castable(SB.Incinerate, target) then
        return cast(SB.Incinerate, target)
    end

end

local function resting()
    --if UnitExists('target') then
    --    return cast('Attack', 'target')
    --end
end

light.rotation.register({
    class = light.rotation.classes.warlock,
    name = 'dlock',
    label = 'Destruction Warlock',
    combat = combat,
    resting = resting
})
