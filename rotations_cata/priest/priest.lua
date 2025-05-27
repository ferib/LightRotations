local addon, light = ...

local function combat()
    if not target.exists or not target.enemy then
        return
    end

    --if player.channeling then
    --    return
    --end

    if not target.debuff(SB.ShadowWordPain).up then
        return cast(SB.ShadowWordPain, target)
    end

    --if castable(SB.Penance, target) then
    --    return cast(SB.Penance, target)
    --end
    if castable(SB.Mindblast, target) then
        return cast(SB.Mindblast, target)
    end
    if castable(SB.Smite) then
        return cast(SB.Smite, target)
        --print("SMITE!?")
    end
end

local function resting()
    -- -- resting
end

light.rotation.register({
    class = light.rotation.classes.priest,
    name = 'priest',
    label = 'Bundled Priest',
    combat = combat,
    resting = resting
})
