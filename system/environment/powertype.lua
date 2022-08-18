local addon, dank = ...

local powerType = { }

function powerType:actual()
  local actual = UnitPower(self.unitID, self.type)
  return actual or 0
end

function powerType:max()
  local max = UnitPowerMax(self.unitID, self.type)
  return max or 0
end

function powerType:deficit()
  local deficit = self.max - self.actual
  return deficit or 0
end

function powerType:deficitpercent()
  local deficitpercent = (self.deficit / self.max) * 100
  return deficitpercent or 0
end

function powerType:percent()
  local percent = (self.actual / self.max) * 100
  return percent or 0
end

function powerType:regen()
  local regen = select(2, GetPowerRegen())
  return regen or 0
end

function powerType:predict()
  local ina, act = GetPowerRegen()
  local predict = (self.actual + (act))
  return predict or 0
end

function powerType:predictpercent()
  local ina, act = GetPowerRegen()
  local predictpercent = ((self.actual + (act)) / self.max) * 100
  return predictpercent or 0
end

function powerType:regenpercent()
  local regenpercent = (self.regen / self.max) * 100
  return regenpercent or 0
end

function powerType:tomax()
  local tomax = self.deficit / GetPowerRegen()
  return tomax or 0
end

function dank.environment.conditions.powerType(unit, power_type, power_type_name)
  return setmetatable({
    unitID = unit.unitID,
    type = power_type,
    type_name = power_type_name
  }, {
    __index = function(t, k)
      if powerType[k] then
        local result = powerType[k](t)
        dank.console.debug(4, 'power', 'blue', t.unitID .. '.power.' .. t.type .. '.' .. k .. ' = ' .. dank.format(result))
        return result
      end
    end,
    __unm = function(t)
        local result = powerType['actual'](t)
        dank.console.debug(4, 'power', 'blue', t.unitID .. '.power.' .. t.type_name .. '.actual' .. ' = ' .. dank.format(result))
        return result
    end
  })
end
