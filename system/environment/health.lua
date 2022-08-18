local addon, dank = ...

local health = { }
local UnitHealth = dank.environment.UnitHealth

function health:percent()
  return UnitHealth(self.unitID) / UnitHealthMax(self.unitID) * 100
end

function health:actual()
  return UnitHealth(self.unitID)
end

function health:effective()
  return (UnitHealth(self.unitID) + (UnitGetIncomingHeals(self.unitID) or 0)) / UnitHealthMax(self.unitID) * 100
end

function health:missing()
  return UnitHealthMax(self.unitID) - UnitHealth(self.unitID)
end

function health:max()
  return UnitHealthMax(self.unitID)
end

function dank.environment.conditions.health(unit, called)
  return setmetatable({
    unitID = unit.unitID
  }, {
    __index = function(t, k)
      return health[k](t)
    end,
    __unm = function(t)
      return health['percent'](t)
    end
  })
end
