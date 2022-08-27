local addon, light = ...
-- local disp = LibStub("LibDispellable-1.0")
local UnitReverseDebuff = light.environment.unit_reverse_debuff

local group = {}

local function group_count(func)
    local count = 0
    for unit in light.environment.iterator() do
        if func(unit) then
            count = count + 1
        end
    end
    return count
end

function group:count(func)
    return group_count
end

local function group_match(func)
    for unit in light.environment.iterator() do
        if func(unit) then
            return unit
        end
    end
    return false
end

function group:match(func)
    return group_match
end

local function group_buffable(spell)
    return group_match(function(unit)
        return unit.alive and unit.buff(spell).down
    end)
end

function group:buffable(spell)
    return group_buffable
end

local function check_removable(removable_type)
    return group_match(function(unit)
        local debuff, count, duration, expires, caster, found_debuff =
            UnitReverseDebuff(unit.unitID, light.data.removables[removable_type])
        return debuff and (count == 0 or count >= found_debuff.count) and unit.health.percent <= found_debuff.health
    end)
end

local function group_removable(...)
    for i = 1, select('#', ...) do
        local removable_type, _ = select(i, ...)
        if light.data.removables[removable_type] then
            local possible_unit = check_removable(removable_type)
            if possible_unit then
                return possible_unit
            end
        end
    end
    return false
end

function group:removable(...)
    return group_removable
end

-- local function group_dispellable(spell)
--   return group_match(function (unit)
--     return disp:CanDispelWith(unit.unitID, spell)
--   end)
-- end

function group:dispellable(spell)
    return group_dispellable
end

function group_under(...)
    local percent, distance, effective = ...
    return group_count(function(unit)
        return unit.alive and ((distance and unit.distance <= distance) or not distance) and
                   ((effective and unit.health.effective < percent) or (not effective and unit.health.percent < percent))
    end)
end

function group:under(...)
    return group_under
end

function light.environment.conditions.group()
    return setmetatable({}, {
        __index = function(t, k)
            return group[k](t)
        end
    })
end
