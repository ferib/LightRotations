local addon, dank = ...

local power = { }

function power:base()
  return dank.environment.conditions.powerType(self.unit)
end

function power:mana()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.Mana, 'mana')
end

function power:rage()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.Rage, 'rage')
end

function power:focus()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.Focus, 'focus')
end

function power:energy()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.Energy, 'energy')
end

function power:combopoints()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.ComboPoints, 'combopoints')
end

function power:runes()
  return dank.environment.conditions.runes(self.unit, 'runes')
end

function power:runicpower()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.RunicPower, 'runicpower')
end

function power:soulshards()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.SoulShards, 'soulshards')
end

function power:lunarpower()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.LunarPower, 'lunarpower')
end

function power:astral()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.LunarPower, 'astral')
end

function power:holypower()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.HolyPower, 'holypower')
end

function power:maelstrom()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.Maelstrom, 'maelstrom')
end

function power:chi()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.Chi, 'chi')
end

function power:insanity()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.Insanity, 'insanity')
end

function power:arcanecharges()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.ArcaneCharges, 'arcanecharges')
end

function power:fury()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.Fury, 'fury')
end

function power:pain()
  return dank.environment.conditions.powerType(self.unit, Enum.PowerType.Pain, 'pain')
end

function dank.environment.conditions.power(unit, called)
  return setmetatable({
    unit = unit,
    unitID = unit.unitID
  }, {
    __index = function(t, k)
      return power[k](t)
    end,
    __unm = function(t)
      return power['base'](t)
    end
  })
end
