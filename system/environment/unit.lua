local addon, dank = ...
-- local rc = LibStub("LibRangeCheck-2.0")
-- local disp = LibStub("LibDispellable-1.0")
local UnitReverseDebuff = dank.environment.unit_reverse_debuff

local unit = {}
local calledUnit

function unit:buff()
    return dank.environment.conditions.buff(self)
end

function unit:debuff()
    return dank.environment.conditions.debuff(self)
end

function unit:health()
    return dank.environment.conditions.health(self)
end

function unit:spell()
    return dank.environment.conditions.spell(self)
end

function unit:power()
    return dank.environment.conditions.power(self)
end

function unit:enemies()
    return dank.environment.conditions.enemies(self)
end

function unit:alive()
    return not UnitIsDeadOrGhost(self.unitID)
end

function unit:level()
    return UnitLevel(self.unitID)
end

function unit:dead()
    return UnitIsDeadOrGhost(self.unitID)
end

function unit:enemy()
    return UnitCanAttack('player', self.unitID)
end

function unit:friend()
    return not UnitCanAttack('player', self.unitID)
end

function unit:name()
    return UnitName(self.unitID)
end

function unit:exists()
    return UnitExists(self.unitID)
end

function unit:guid()
    return UnitGUID(self.unitID)
end

function unit:canloot()
    if dank.adv_protected then
        local obj = GetObjectWithGUID(UnitGUID(self.unitID))
        if obj ~= nil and UnitCanBeLooted(obj) then
            return true
        end
    end
    return false
end

function unit:canskin()
    if dank.adv_protected then
        local obj = GetObjectWithGUID(UnitGUID(self.unitID))
        if obj ~= nil and UnitCanBeSkinned(obj) then
            return true
        end
    end
    return false
end

-- TODO: remove?
function unit:distance()
    --[[if dank.luaboxdev then
    if UnitExists(self.unitID) then
      local px, py, pz = __LB__.ObjectPosition('player')
      local tx, ty, tz = __LB__.ObjectPosition(self.unitID)
      if px and py and pz and tx and ty and tz then
        local dist = math.sqrt((px-tx)^2+(py-ty)^2+(pz-tz)^2)
        dist = dist * 100; dist = math.floor(dist); dist = dist / 100
        return dist
      else
        return 100
      end
    else
      return 100
    end
  else]] --
    if dank.adv_protected then
        -- if ObjectExists(self.unitID) then
        --  local dist = GetDistanceBetweenObjects('player', self.unitID)
        --  if dist then
        --    dist = dist * 100; dist = math.floor(dist); dist = dist / 100
        --    return dist
        --  else
        --    return 100
        --  end
        -- else
        return 100
        -- end
    else
        local minRange, maxRange = rc:GetRange(self.unitID)
        if not minRange then
            return 100
        elseif not maxRange then
            return 100
        else
            return maxRange
        end
    end
end

local function channeling(spell)
    local channeling_spell = ChannelInfo(calledUnit.unitID)
    if channeling_spell then
        if spell then
            if tonumber(spell) then
                spell = GetSpellInfo(spell)
            end
            if channeling_spell == spell then
                return true
            else
                return false
            end
        else
            return true
        end
    else
        return false
    end
end

function unit:channeling(spell)
    return channeling
end

function unit:isChanneling()
    return UnitChannelInfo(self.unitID) ~= nil
end

function unit:castingpercent()
    local castingname, _, _, startTime, endTime, notInterruptible = CastingInfo("player")
    if castingname then
        local castLength = (endTime - startTime) / 1000
        local secondsLeft = endTime / 1000 - GetTime()
        return ((secondsLeft / castLength) * 100)
    end
    return 0
end

function unit:casting()
    -- if UnitCastID then
    --   local cast_id, spell_id, _ = UnitCastID(self.unitID)
    --   print(cast_id, spell_id)
    --   if cast_id ~= '0' or spell_id ~= '0' then return true else return false end
    -- end
    if not self.unitID == 'player' then
        return false
    end
    local castingname, _ = CastingInfo("player")
    if castingname then
        return true
    end
    return false
end

function unit:moving()
    return GetUnitSpeed(self.unitID) ~= 0
end

function unit:has_stealable()
    local has_stealable = false
    for i = 1, 40 do
        buff, _, count, _, duration, expires, caster, stealable, _, spellID = _G['UnitBuff'](self.unitID, i)
        if stealable then
            has_stealable = true
        end
    end
    return has_stealable
end

function unit:combat()
    return UnitAffectingCombat(self.unitID)
end

local function unit_interrupt(percent, spell)
    local percent = tonumber(percent) or 100
    local spell = GetSpellInfo(spell) or false
    local name, startTime, endTime, notInterruptible
    name, _, _, startTime, endTime, _, _, notInterruptible, _ = UnitCastingInfo(calledUnit.unitID)
    if not name then
        name, _, _, startTime, endTime, _, _, notInterruptible, _ = UnitChannelInfo(calledUnit.unitID)
    end
    if name and startTime and endTime and ((spell and name == spell) or (not spell and not notInterruptible)) then
        local castTimeRemaining = endTime / 1000 - GetTime()
        local castTimeTotal = (endTime - startTime) / 1000
        if castTimeTotal > 0 and castTimeRemaining / castTimeTotal * 100 <= percent then
            return true
        end
    end
    return false
end

function unit:interrupt()
    return unit_interrupt
end

local function unit_in_range(spell)
    if tonumber(spell) then
        name = GetSpellInfo(spell)
    end
    return IsSpellInRange(spell, calledUnit.unitID) == 1
end

function unit:in_range()
    return unit_in_range
end

local function totem_cooldown(name)
    if tonumber(name) then
        name = GetSpellInfo(name)
    end
    local haveTotem, totemName, startTime, duration
    for i = 1, 4 do
        haveTotem, totemName, startTime, duration = GetTotemInfo(i)
        if totemName == name then
            return duration - (GetTime() - startTime)
        end
    end
    return 0
end

function unit:totem()
    return totem_cooldown
end

local function unit_talent(a, b)
    local tier, column
    if type(a) == 'table' then
        tier = a[1]
        column = a[2]
    else
        tier = a
        column = b
    end
    local talentID, name, texture, selected, available, spellID, unknown, row, column, unknown, known = GetTalentInfo(
        tier, column, GetActiveSpecGroup())
    return available
end

function unit:talent()
    return unit_talent
end

local death_tracker = {}
function unit:time_to_die()
    if death_tracker[self.unitID] and death_tracker[self.unitID].guid == UnitGUID(self.unitID) then
        local health_change = death_tracker[self.unitID].health - UnitHealth(self.unitID)
        local time_change = GetTime() - death_tracker[self.unitID].time
        local health_per_time = health_change / time_change
        local time_to_die = UnitHealth(self.unitID) / health_per_time
        return math.min(math.max(time_to_die, 0), 9999) -- give it the clamps
    end
    if not death_tracker[self.unitID] then
        death_tracker[self.unitID] = {}
    end
    death_tracker[self.unitID].guid = UnitGUID(self.unitID)
    death_tracker[self.unitID].time = GetTime()
    death_tracker[self.unitID].health = UnitHealth(self.unitID)
    return 9999
end

local function spell_cooldown(spell)
    local time, value = GetSpellCooldown(spell)
    if not time or time == 0 then
        return 0
    end
    local cd = time + value - GetTime() - (select(4, GetNetStats()) / 1000)
    if cd > 0 then
        return cd
    else
        return 0
    end
end

local function spell_castable(spell)
    if type(spell) == 'table' then
        spell = spell.namerank
    end
    spell = GetSpellInfo(spell)
    local usable, noMana = IsUsableSpell(spell)
    local inRange = IsSpellInRange(spell, calledUnit.unitID)
    local onCooldown = false
    if dank.healthCooldown[calledUnit.unitID] ~= nil and dank.healthCooldown[calledUnit.unitID] > GetTime() then
        onCooldown = true
    end
    dank.console.debug(1, 'engine', 'engine', string.format('in unit:castable unit %s onCooldown %s',
        UnitName(calledUnit.unitID), tostring(onCooldown)))
    if usable and inRange == 1 and not onCooldown then
        if spell_cooldown(spell) == 0 then
            return true
        else
            return false
        end
    end
    return false
end

function unit:castable()
    return spell_castable
end

local function check_removable(removable_type)
    local debuff, count, duration, expires, caster, found_debuff =
        UnitReverseDebuff(calledUnit.unitID, dank.data.removables[removable_type])
    if debuff and (count == 0 or count >= found_debuff.count) and calledUnit.health.percent <= found_debuff.health then
        return unit
    end
    return false
end

local function unit_removable(...)
    for i = 1, select('#', ...) do
        local removable_type, _ = select(i, ...)
        if dank.data.removables[removable_type] then
            local possible_unit = check_removable(removable_type)
            if possible_unit then
                return possible_unit
            end
        end
    end
    return false
end

function unit:removable(...)
    return unit_removable
end

local function unit_dispellable(spell)
    return disp:CanDispelWith(calledUnit.unitID, spell)
end

function unit:dispellable(spell)
    return unit_dispellable
end

function unit_position()
    return unlocker.position(UnitGUID(calledUnit.unitID))
end

function unit:position()
    return unit_position()
end

function unit_distance_to_pos(x, y, z)
    local guid = UnitGUID(calledUnit.unitID)
    local pos = unlocker.position(guid)
    local px, py, pz = unpack(pos)
    return math.sqrt((px - x) * (px - x) + (py - y) * (py - y) + (pz - z) * (pz - z))
end

function unit:distance_to_pos(...)
    return unit_distance_to_pos
end

function unit_move_to(x, y, z)
    -- if calledUnit.unitID ~= 'player' then
    --  return
    -- end
    -- if type(x) == "table" then
    --  x, y, z = x.position
    -- if x == nil or y == nil or z == nil then
    --    return
    --  end
    -- end
    -- unlocker.goto(x, y, z)
end

function unit:move_to(...)
    return unit_move_to
end

function unit_stop()
    if calledUnit.unitID ~= 'player' then
        return
    end
    unlocker.stop()
end

function unit:stop(...)
    return unit_stop
end

function unit_face(unit)
    if calledUnit.unitID ~= 'player' then
        return
    end
    if type(unit) == "table" then
        unlocker.face(unit.guid)
    else
        unlocker.face(unit)
    end
end

function unit:face(...)
    return unit_face
end

function unit_interact(unit)
    if calledUnit.unitID ~= 'player' then
        return
    end
    if type(unit) == "table" then
        unlocker.interact(unit.guid)
    else
        unlocker.interact(unit)
    end
end

function unit:interact(...)
    return unit_interact
end

function unit_target(unit)
    if calledUnit.unitID ~= 'player' then
        return
    end
    if type(unit) == "table" then
        unlocker.target(unit.guid)
    else
        unlocker.target(unit)
    end
end

function unit:target(...)
    return unit_target
end

function dank.environment.conditions.unit(unitID)
    return setmetatable({
        unitID = unitID
    }, {
        __index = function(t, k, k2)
            if t and k then
                calledUnit = t
                if unit[k] == nil then
                    dank.error("unit:", k, " doesn't exist")
                end
                return unit[k](t, k2)
            end
        end
    })
end

local player_hook = dank.environment.conditions.unit('player')
local player_spell_hook = player_hook['spell']
dank.environment.hooks.spell = player_spell_hook
dank.environment.hooks.buff = player_hook['buff']
dank.environment.hooks.debuff = player_hook['debuff']
dank.environment.hooks.power = player_hook['power']
dank.environment.hooks.health = player_hook['health']
dank.environment.hooks.talent = player_hook['talent']
dank.environment.hooks.totem = player_hook['totem']
dank.environment.hooks.enemies = player_hook['enemies']

dank.environment.hooks.castable = function(spell)
    return player_spell_hook(spell)['castable']
end

dank.environment.hooks.lastcast = function(spell)
    return player_spell_hook(spell)['lastcast']
end
