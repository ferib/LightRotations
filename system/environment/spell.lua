local addon, light = ...

local spell = {}

local IsUsableSpell = IsUsableSpell or C_Spell.IsSpellUsable
local GetSpellInfo = GetSpellInfo or C_Spell.GetSpellInfo
--local GetSpellCooldown = GetSpellCooldown or C_Spell.GetSpellCooldown

function spell:cooldown()
	local time, value

	if GetSpellCooldown ~= nil then
		time, value = GetSpellCooldown(self.spell)
	else
		local data = C_Spell.GetSpellCooldown(self.spell)
		time = data.startTime
		value = data.duration
	end
     
    if not time or time == 0 then
        return 0
    end
    local clip = light.settings.fetch('_engine_castclip', 0)
    local cd = (time + value - GetTime() - (select(4, GetNetStats()) / 1000)) - clip
    if cd > 0 then
        return cd
    else
        return 0
    end
end

function spell:exists()
    return IsPlayerSpell(self.spell)
end

function spell:castingtime()
    local name, _, _, castingTime = GetSpellInfo(self.spell)
    if name and castingTime then
        return castingTime / 1000
    end
    return 9999
end

function spell:charges()
    return GetSpellCharges(self.spell) or 0
end

local syncTime
local lastSync

function spell:fractionalcharges()
    local currentCharges, maxCharges, Start, Duration = GetSpellCharges(self.spell)
    local currentSync = GetTime() - Start
    if syncTime == nil then
        syncTime = currentSync
        lastSync = Start
    elseif Start ~= lastSync then
        syncTime = currentSync
        lastSync = Start
    end
    local syncedTime = GetTime() - syncTime
    local currentChargesFraction = (syncedTime - Start) / Duration
    local fractionalCharges = math.floor((currentCharges + currentChargesFraction) * 100) / 100
    if fractionalCharges > maxCharges then
        return maxCharges
    else
        return fractionalCharges
    end
end

function spell:recharge()
    local Charges, MaxCharges, CDTime, CDValue = GetSpellCharges(self.spell);
    if Charges == MaxCharges then
        return 0;
    end
    local CD = CDTime + CDValue - GetTime() - (select(4, GetNetStats()) / 1000)
    if CD > 0 then
        return CD;
    else
        return 0;
    end
end

function spell:lastcast()
    local lastcast = light.tmp.fetch('lastcast', false)
    return lastcast == self.spell
end

function spell:castable()
    --print(self.spell)
    local usable, noMana = IsUsableSpell(self.spell)
    if usable then
        if self.cooldown == 0 then
            return true
        else
            return false
        end
    end
    return false
end

function spell:current()
    local CastingInfo = _G.CastingInfo or _G.UnitCastingInfo
    local casting, _ = CastingInfo(self.unitID)
    local channel, _ = ChannelInfo(self.unitID)
    if casting then
        return self.base == casting
    end
    if channel then
        return self.spell == channel
    end
    return false
end

GetSpellName = light.environment.GetSpellName
function light.environment.conditions.spell(unit)
    return setmetatable({
        unitID = unit.unitID
    }, {
        __index = function(self, key)
            if self.unitID then
                local result = spell[key](self)
                light.console.debug(4, 'spell', 'indigo',
                    self.unitID .. '.spell(' .. self.spell .. ').' .. key .. ' = ' .. light.format(result))
                return result
            end
            return false
        end,
        __call = function(self, arg)
            --print(arg, "asd")
            if type(arg) == 'table' then
                self.spell = arg.namerank
            elseif tonumber(arg) then
                local spellinfo = GetSpellName(arg)
                if type(spellinfo) == "table" then
                    --print("TABLE set")
                    self.spell = spellinfo.name
                else
                    --print("NO TABLE set")
                    self.spell = spellinfo -- as is
                end
            else
                --print("TABLE set 2")
                self.spell = arg
            end
            --[[
            local par = string.find(self.spell, '%(')
            if par ~= nil then
                self.base = string.sub(self.spell, 1, par - 1)
            else
                self.base = self.spell
            end
            ]]
            return self
        end,
        __unm = function(t)
            local result = spell['cooldown'](t)
            light.console.debug(4, 'spell', 'indigo',
                t.unitID .. '.spell(' .. t.spell .. ').cooldown = ' .. light.format(result))
            return result
        end
    })
end
