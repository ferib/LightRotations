local addon, light = ...

local function combat()
    -- combat
end

local function resting()
    -- -- resting
end

light.rotation.register({
    class = light.rotation.classes.hunter,
    name = 'hunter',
    label = 'Bundled Hunter',
    combat = combat,
    resting = resting
})
