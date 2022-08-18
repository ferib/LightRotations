local addon, dank = ...

local function combat()
    -- combat
end

local function resting()
    -- -- resting
end

dank.rotation.register({
  class = dank.rotation.classes.priest,
  name = 'priest',
  label = 'Bundled Priest',
  combat = combat,
  resting = resting
})
