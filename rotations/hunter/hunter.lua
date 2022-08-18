local addon, dank = ...

local function combat()
    -- combat
end

local function resting()
    -- -- resting
end

dank.rotation.register({
    class = dank.rotation.classes.hunter,
    name = 'hunter',
    label = 'Bundled Hunter',
    combat = combat,
    resting = resting
})
