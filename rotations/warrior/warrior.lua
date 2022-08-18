local addon, dank = ...

local function combat()
  if castable(SB.HeroicStrike, 'target') then return cast(SB.HeroicStrike, 'target') end
  -- combat
  if not IsCurrentSpell(6603) then
    return cast('Attack', 'target')
  end
end

local function resting()
  if UnitExists('target') then
    return cast('Attack', 'target')
  end
end

dank.rotation.register({
  class = dank.rotation.classes.warrior,
  name = 'warrior',
  label = 'Bundled Warrior',
  combat = combat,
  resting = resting
})
