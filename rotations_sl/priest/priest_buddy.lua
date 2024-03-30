local addon, light = ...

local function combat()
    -- combat
end

local function resting()
    -- -- resting
end

light.rotation.register({
    class = light.rotation.classes.priest,
    name = 'priest_buddy',
    label = 'Bundled Priest Buddy',
    combat = combat,
    resting = resting
})
