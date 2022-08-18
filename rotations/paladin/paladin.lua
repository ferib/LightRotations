local addon, dank = ...

local function combat()
    -- combat
end

local function resting()
    -- -- resting
end

dank.rotation.register({
  class = dank.rotation.classes.paladin,
  name = 'paladin',
  label = 'Bundled Paladin',
  combat = combat,
  resting = resting
})
