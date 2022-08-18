local addon, dank = ...

local runes = {}

function runes:count()
    local runes_ready = 0.0
    for i = 1, 6 do
        local start, duration, runeReady = GetRuneCooldown(i)
        local percent = start == 0 and 1.0 or (1 - (((start + duration) - GetTime()) / duration) * 1)
        runes_ready = runes_ready + percent
    end
    return runes_ready
end

function dank.environment.conditions.runes(unit)
    return setmetatable({
        unitID = unit.unitID
    }, {
        __index = function(t, k)
            if runes[k] then
                return runes[k](t)
            end
        end
    })
end
