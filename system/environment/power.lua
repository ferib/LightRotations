local addon, light = ...

local power = {}

function power:base()
    return light.environment.conditions.powerType(self.unit)
end

function power:mana()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.Mana, 'mana')
end

function power:rage()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.Rage, 'rage')
end

function power:focus()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.Focus, 'focus')
end

function power:energy()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.Energy, 'energy')
end

function power:combopoints()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.ComboPoints, 'combopoints')
end

function power:runes()
    return light.environment.conditions.runes(self.unit, 'runes')
end

function power:runicpower()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.RunicPower, 'runicpower')
end

function power:soulshards()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.SoulShards, 'soulshards')
end

function power:lunarpower()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.LunarPower, 'lunarpower')
end

function power:astral()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.LunarPower, 'astral')
end

function power:holypower()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.HolyPower, 'holypower')
end

function power:maelstrom()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.Maelstrom, 'maelstrom')
end

function power:chi()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.Chi, 'chi')
end

function power:insanity()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.Insanity, 'insanity')
end

function power:arcanecharges()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.ArcaneCharges, 'arcanecharges')
end

function power:fury()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.Fury, 'fury')
end

function power:pain()
    return light.environment.conditions.powerType(self.unit, Enum.PowerType.Pain, 'pain')
end

function light.environment.conditions.power(unit, called)
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
