local addon, dank = ...

local function combat()
    -- combat
end

local function resting()
    -- -- resting
end

dank.rotation.register({
    class = dank.rotation.classes.shaman,
    name = 'shaman',
    label = 'Bundled Shaman',
    combat = combat,
    resting = resting
})
