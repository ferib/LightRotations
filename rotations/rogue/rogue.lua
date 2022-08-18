local addon, dank = ...

local function combat()
    -- combat
end

local function resting()
    -- resting
end

dank.rotation.register({
    class = dank.rotation.classes.rogue,
    name = 'rogue',
    label = 'Bundled Rogue',
    combat = combat,
    resting = resting
})
