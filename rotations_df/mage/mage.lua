local addon, light = ...

local function combat()
    -- combat
end

local function resting()
    -- resting
end

light.rotation.register({
    class = light.rotation.classes.mage,
    name = 'mage',
    label = 'Bundled Mage',
    combat = combat,
    resting = resting
})
