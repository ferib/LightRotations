local addon, light = ...

local function combat()
    -- combat
end

local function resting()
    -- -- resting
end

light.rotation.register({
    class = light.rotation.classes.priest,
    name = 'holy',
    label = 'Bundled Priest',
    combat = combat,
    resting = resting
})
