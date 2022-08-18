local addon, dank = ...

dank.environment.virtual = {
  targets = {},
  resolvers = {},
  resolved = {},
}
local UnitHealth = dank.environment.UnitHealth

local function GroupType()
  return IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
end

function dank.environment.virtual.validate(virtualID)
  if dank.environment.virtual.targets[virtualID] or virtualID == 'group' then
    return true
  end
  return false
end

function dank.environment.virtual.resolve(virtualID)
  if virtualID == 'group' then
    return 'group', 'group'
  else
    return dank.environment.virtual.resolved[virtualID], 'unit'
  end
end

function dank.environment.virtual.targets.lowest()
  local members = GetNumGroupMembers()
  local group_type = GroupType()
  if dank.environment.virtual.resolvers[group_type] then
    return dank.environment.virtual.resolvers[group_type](members)
  end
end

function dank.environment.virtual.resolvers.unit(unitA, unitB)
  local healthA = UnitHealth(unitA) / UnitHealthMax(unitA) * 100
  local healthB = UnitHealth(unitB) / UnitHealthMax(unitB) * 100
  if healthA < healthB then
    return unitA, healthA
  else
    return unitB, healthB
  end
end

function dank.environment.virtual.resolvers.party(members)
  local lowest = 'player'
  local lowest_health
  for i = 1, (members - 1) do
    local unit = 'party' .. i
    if not UnitCanAttack('player', unit) and UnitInRange(unit) and not UnitIsDeadOrGhost(unit) then
      if not lowest then
        lowest, lowest_health = dank.environment.virtual.resolvers.unit(unit, 'player')
      else
        lowest, lowest_health = dank.environment.virtual.resolvers.unit(unit, lowest)
      end
    end
  end
  return lowest
end

function dank.environment.virtual.resolvers.raid(members)
  local lowest = 'player'
  local lowest_health
  for i = 1, members do
    local unit = 'raid' .. i
    if not UnitCanAttack('player', unit) and UnitInRange(unit) and not UnitIsDeadOrGhost(unit) then
      if not lowest then
        lowest, lowest_health = unit, UnitHealth(unit)
      else
        lowest, lowest_health = dank.environment.virtual.resolvers.unit(unit, lowest)
      end
    end
  end
  return lowest
end

function dank.environment.virtual.resolvers.solo()
  return 'player'
end

function dank.environment.virtual.targets.tank()
  local members = GetNumGroupMembers()
  local group_type = GroupType()
  if dank.environment.virtual.resolvers[group_type..'_tank'] then
    return dank.environment.virtual.resolvers[group_type..'_tank'](members)
  end
end

function dank.environment.virtual.resolvers.party_tank(members)
  local tank = 'player'
  for i = 1, (members - 1) do
    local unit = 'party' .. i
    if UnitHealthMax(unit) > UnitHealthMax(tank) then
      tank = unit
    end
  end
  return tank
end

function dank.environment.virtual.resolvers.raid_tank(members)
  local tank = 'player'
  for i = 1, (members - 1) do
    local unit = 'raid' .. i
    if UnitHealthMax(unit) > UnitHealthMax(tank) then
      tank = unit
    end
  end
  return tank
end

function dank.environment.virtual.resolvers.solo_tank()
  return 'player'
end

dank.on_ready(function()
  C_Timer.NewTicker(0.1, function()
    for target, callback in pairs(dank.environment.virtual.targets) do
      dank.environment.virtual.resolved[target] = callback()
    end
  end)
end)
