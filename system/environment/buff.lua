local addon, dank = ...

local UnitBuff = dank.environment.unit_buff

local buff = {}

function buff:exists()
    local buff, count, duration, expires, caster = UnitBuff(self.unitID, self.spell, 'any')
    if buff and (caster == 'player' or caster == 'pet') then
        return true
    end
    return false
end

function buff:down()
    return not self.exists
end

function buff:up()
    return self.exists
end

function buff:any()
    local buff, count, duration, expires, caster = UnitBuff(self.unitID, self.spell, 'any')
    if buff then
        return true
    end
    return false
end

function buff:count()
    local buff, count, duration, expires, caster = UnitBuff(self.unitID, self.spell, 'any')
    if buff and (caster == 'player' or caster == 'pet') then
        return count
    end
    return 0
end

function buff:remains()
    local buff, count, duration, expires, caster = UnitBuff(self.unitID, self.spell, 'any')
    if buff and (caster == 'player' or caster == 'pet') then
        return expires - GetTime()
    end
    return 0
end

function buff:duration()
    local buff, count, duration, expires, caster = UnitBuff(self.unitID, self.spell, 'any')
    if buff and (caster == 'player' or caster == 'pet') then
        return duration
    end
    return 0
end

function buff:stealable()
    local buff, count, duration, expires, caster, stealable = UnitBuff(self.unitID, self.spell, 'any')
    if stealable then
        return true
    end
    return false
end

function dank.environment.conditions.buff(unit)
    return setmetatable({
        unitID = unit.unitID
    }, {
        __index = function(self, func)
            local result = buff[func](self)
            dank.console.debug(4, 'buff', 'green', self.unitID .. '.buff(' .. tostring(self.spell) .. ').' .. func ..
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
            local result = buff['exists'](t)
            dank.console.debug(4, 'buff', 'green',
                t.unitID .. '.buff(' .. tostring(t.spell) .. ').exists = ' .. dank.format(result))
            return result
        end
    })
end
