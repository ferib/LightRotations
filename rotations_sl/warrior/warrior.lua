local addon, light = ...

local function combat()
    if castable(SB.HeroicStrike, 'target') then
        return cast(SB.HeroicStrike, 'target')
    end
    -- combat
    if not IsCurrentSpell(6603) then
        return cast('Attack', 'target')
    end
end

local function resting()
    if UnitExists('target') then
        return cast('Attack', 'target')
    end
end

light.rotation.register({
    class = light.rotation.classes.warrior,
    name = 'warrior',
    label = 'Bundled Warrior',
    combat = combat,
    resting = resting
})
