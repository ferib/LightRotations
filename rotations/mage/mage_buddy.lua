local addon, dank = ...

local function combat()
    -- combat
end

local function resting()
    -- resting
end

dank.rotation.register({
    class = dank.rotation.classes.mage,
    name = 'mage_buddy',
    label = 'Bundled Mage Buddy',
    combat = combat,
    resting = resting
})
