local addon, dank = ...

local function combat()
    -- combat
end

local function resting()
    -- -- resting
end

dank.rotation.register({
  class = dank.rotation.classes.priest,
  name = 'priest_buddy',
  label = 'Bundled Priest Buddy',
  combat = combat,
  resting = resting
})
