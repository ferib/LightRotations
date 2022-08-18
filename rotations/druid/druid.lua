local addon, dank = ...

local function combat()
    -- combat
end

local function resting()
    -- -- resting
end

dank.rotation.register({
  class = dank.rotation.classes.druid,
  name = 'druid',
  label = 'Bundled Druid',
  combat = combat,
  resting = resting
})
