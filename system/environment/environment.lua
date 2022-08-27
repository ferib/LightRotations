local addon, light = ...

light.environment = {
  conditions = { },
  hooks = { },
  unit_cache = { },
  group_cache = nil,
  hook_cache = { }
}

local env = { }

local function UnitHealth(unit)
  -- if the unit is on cooldown then its health hasn't been updated yet so..
  -- lowest shouldn't be selecting it. and. the health checking in a CR
  -- shouldn't see the stale health value. so report MaxHealth instead.
  if light.healthCooldown[unit] ~= nil then
    if light.healthCooldown[unit] > GetTime() then
      light.console.debug(1, 'engine', 'engine', string.format('unit %s (health/max %s/%s) is on cooldown', UnitName(unit), _G.UnitHealth(unit), UnitHealthMax(unit)))
      return UnitHealthMax(unit)
    end
  end
  return _G.UnitHealth(unit)
end
light.environment.UnitHealth = UnitHealth

local GetSpellName = function(spellid)
  local rank = GetSpellSubtext(spellid)
  local spellname = GetSpellInfo(spellid)
  if spellname ~= nil and rank ~= nil and rank ~= '' then
    spellname = spellname..'('..rank..')'
  end
  return spellname
end
light.environment.GetSpellName = GetSpellName

light.environment.env = setmetatable(env, {
  __index = function(_env, called)
    local ds = debugstack(2, 1, 0)
    local file, line = string.match(ds, '^.-\(%a-%.lua):(%d+):.+$')
    light.console.file = file
    light.console.line = line
    if light.environment.logical.validate(called) then
      if not light.environment.unit_cache[called] then
        light.environment.unit_cache[called] = light.environment.conditions.unit(called)
      end
      return light.environment.unit_cache[called]
    elseif light.environment.virtual.validate(called) then
      local resolved, virtual_type = light.environment.virtual.resolve(called)
      if virtual_type == 'unit' then
        if not light.environment.unit_cache[resolved] then
          light.environment.unit_cache[resolved] = light.environment.conditions.unit(resolved)
        end
        return light.environment.unit_cache[resolved]
      elseif virtual_type == 'group' then
        if not light.environment.group_cache then
          light.environment.group_cache = light.environment.conditions.group()
        end
        return light.environment.group_cache
      end
    elseif light.environment.hooks[called] then
      if not light.environment.hook_cache[called] then
        light.environment.hook_cache[called] = light.environment.hooks[called]
      end
      return light.environment.hook_cache[called]
    end
    return _G[called]
  end
})

function light.environment.hook(func)
  setfenv(func, light.environment.env)
end

function light.environment.iterator(raw)
  local members = GetNumGroupMembers()
  local group_type = IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
  local index = 0
  local returned_solo = false
  return function()
    local called
    if group_type == 'solo' and not returned_solo then
      returned_solo = true
      called = 'player'
    elseif group_type ~= 'solo' then
      if index <= members then
        index = index + 1
        if group_type == 'party' and index == members then
          called = 'player'
        else
          called = group_type .. index
        end
      end
    end
    if called then
      if raw then
        return called
      end
      if not light.environment.unit_cache[called] then
        light.environment.unit_cache[called] = light.environment.conditions.unit(called)
      end
      return light.environment.unit_cache[called]
    end
  end
end

light.environment.hooks.each_member = light.environment.iterator

light.environment.unit_buff = function(target, spell, owner)
  local buff, count, caster, expires, spellID
  local i = 0; local go = true
  while i <= 40 and go do
    i = i + 1
    buff, _, count, _, duration, expires, caster, stealable, _, spellID = _G['UnitBuff'](target, i)
    if not owner then
      if ((tonumber(spell) and spellID == tonumber(spell)) or buff == spell) and caster == "player" then go = false end
    elseif owner == "any" then
      if ((tonumber(spell) and spellID == tonumber(spell)) or buff == spell) then go = false end
    end
  end
  return buff, count, duration, expires, caster, stealable
end

light.environment.unit_debuff = function(target, spell, owner)
  local debuff, count, caster, expires, spellID
  local i = 0; local go = true
  while i <= 40 and go do
    i = i + 1
    debuff, _, count, _, duration, expires, caster, _, _, spellID = _G['UnitDebuff'](target, i)
    if not owner then
      if ((tonumber(spell) and spellID == tonumber(spell)) or debuff == spell) and caster == "player" then go = false end
    elseif owner == "any" then
      if ((tonumber(spell) and spellID == tonumber(spell)) or debuff == spell) then go = false end
    end
  end
  return debuff, count, duration, expires, caster
end

light.environment.unit_reverse_debuff = function(target, candidates)
  local debuff, count, caster, expires, spellID
  local i = 0; local go = true
  while i <= 40 and go do
    i = i + 1
    debuff, _, count, _, duration, expires, caster, _, _, spellID = _G['UnitDebuff'](target, i)
    if candidates[spellID] then go = false end
  end
  return debuff, count, duration, expires, caster, candidates[spellID]
end
