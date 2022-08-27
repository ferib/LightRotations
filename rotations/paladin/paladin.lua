local addon, light = ...

local function combat()
    -- combat
end

local function resting()
    -- -- resting
end

light.rotation.register({
    class = light.rotation.classes.paladin,
    name = 'paladin',
    label = 'Bundled Paladin',
    combat = combat,
    resting = resting
})
