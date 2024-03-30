local addon, light = ...

local function combat()
    -- combat
end

local function resting()
    -- resting
end

light.rotation.register({
    class = light.rotation.classes.mage,
    name = 'mage_buddy',
    label = 'Bundled Mage Buddy',
    combat = combat,
    resting = resting
})
