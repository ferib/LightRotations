local addon, dank = ...

local UnitDebuff = dank.environment.unit_debuff

local debuff = {}

function debuff:exists()
    local debuff, count, duration, expires, caster = UnitDebuff(self.unitID, self.spell, 'any')
    if debuff and (caster == 'player' or caster == 'pet') then
        return true
    end
    return false
end

function debuff:down()
    return not self.exists
end

function debuff:up()
    return self.exists
end

function debuff:any()
    local debuff, count, duration, expires, caster = UnitDebuff(self.unitID, self.spell, 'any')
    if debuff then
        return true
    end
    return false
end

function debuff:count()
    local debuff, count, duration, expires, caster = UnitDebuff(self.unitID, self.spell, 'any')
    if debuff and (caster == 'player' or caster == 'pet') then
        return count
    end
    return 0
end

function debuff:remains()
    local debuff, count, duration, expires, caster = UnitDebuff(self.unitID, self.spell, 'any')
    if debuff and (caster == 'player' or caster == 'pet') then
        return expires - GetTime()
    end
    return 0
end

function debuff:duration()
    local debuff, count, duration, expires, caster = UnitDebuff(self.unitID, self.spell, 'any')
    if debuff and (caster == 'player' or caster == 'pet') then
        return duration
    end
    return 0
end

function dank.environment.conditions.debuff(unit)
    return setmetatable({
        unitID = unit.unitID
    }, {
        __index = function(self, arg)
            local result = debuff[arg](self)
            dank.console.debug(4, 'debuff', 'teal', self.unitID .. '.debuff(' .. tostring(self.spell) .. ').' .. arg ..
                ' = ' .. dank.format(result))
            return result
        end,
        __call = function(self, arg)
            if type(arg) == 'table' then
                self.spell = arg.name
            elseif tonumber(arg) then
                self.spell = GetSpellInfo(arg)
            else
                self.spell = arg
            end
            return self
        end,
        __unm = function(t)
            local result = debuff['exists'](t)
            dank.console.debug(4, 'debuff', 'teal',
                t.unitID .. '.debuff(' .. tostring(t.spell) .. ').exists = ' .. dank.format(result))
            return debuff['exists'](t)
        end
    })
end
