local addon, light = ...

local function combat()
    -- combat
end

local function resting()
    -- -- resting
end

light.rotation.register({
    class = light.rotation.classes.druid,
    name = 'druid',
    label = 'Bundled Druid',
    combat = combat,
    resting = resting
})
