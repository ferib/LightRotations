local addon, light = ...

light.cast = { }

function _CastSpellByName(spell, target)
    local target = target or "target"
	local spell = spell or ""

	--CastSpellByName(spell, target)
	light.glow.trigger(spell)

	light.console.debug(4, 'cast', 'red', spell .. ' on ' .. target)
	light.interface.status(spell)
end

function _CastGroundSpellByName(spell, target)
    local target = target or "target"

	--RunMacroText("/cast [@cursor] " .. spell)
	-- TODO: glow for macro?

	light.console.debug(4, 'cast', 'red', spell .. ' on ' .. target)
	light.interface.status(spell)
end

function _CastSpellByID(spell, target)
    if tonumber(spell) then
      spell, _ = GetSpellInfo(spell)
    end
    return _CastSpellByName(spell, target)
end

function _CastGroundSpellByID(spell, target)
    if tonumber(spell) then
      spell, _ = GetSpellInfo(spell)
    end
    return _CastGroundSpellByName(spell, target)
end

function _SpellStopCasting()
	--SpellStopCasting()
	-- TODO: glow for spell cancle?
	light.console.debug(4, '', 'red', 'Stopcasting')
	light.interface.status('Stopcasting')
end

function _RunMacroText(text)
	--RunMacroText(text)
	--TODO: glow for macro?

	light.console.debug(4, 'macro', 'red', text)
	light.interface.status('Macro')
end

light.tmp.store('lastcast', spell)

local function is_unlocked()
	-- https://wowpedia.fandom.com/wiki/Secure_Execution_and_Tainting
	-- Lua functions such as CastSpellByName are protected in TBC, this function
	-- will block the protected calls to prevent popup error messages
	-- Such functions will only work in Vanilla Wow
	--
	local _, _, _, tocversion = GetBuildInfo()
	return tocversion < 20000 -- TBC and above have ForecTaint_Strong protection!
end

local turbo = false

function light.environment.hooks.cast(spell, target)
    turbo = light.settings.fetch('_engine_turbo', false)
    local enablehcd = light.settings.fetch('_engine_healcd.check', true)
    if type(target) == 'table' then
		target = target.unitID
	end
	if type(spell) == 'table' then
		spell = spell.namerank
	end
	if type(spell) == 'number' then
		spell = GetSpellName(spell)
	end
	if target ~= nil and not UnitCanAttack('player', target) and enablehcd and UnitName(target) ~= nil then
		light.savedHealTarget = target
		if tonumber(spell) then
			spell, _ = GetSpellInfo(spell)
		end
		light.console.debug(1, 'engine', 'engine', string.format('casting spell %s on %s. UnitHealth %d', spell,
			UnitName(target), UnitHealth(target)))
	end
	if turbo or not CastingInfo('player') then
		if target == 'ground' then
			if tonumber(spell) then
				_CastGroundSpellByID(spell, target)
			else
				_CastGroundSpellByName(spell, target)
			end
		else
			if tonumber(spell) then
				_CastSpellByID(spell, target)
			else
				_CastSpellByName(spell, target)
			end
		end
	end
end

function light.environment.hooks.sequenceactive(sequence)
    if sequence.active then
        return true
    end
    return false
end

function light.environment.hooks.dosequence(sequence)
    if sequence.complete then
        return false
    end
    if #sequence.spells == 0 then
        return false
    end
    return true
end

function light.environment.hooks.sequence(sequence)
	if sequence.complete then
		return true
	end
	if not sequence.active then
		sequence.active = true
	end
	if not sequence.copy then
		sequence.copy = {}
		for _, value in ipairs(sequence.spells) do
			table.insert(sequence.copy, value)
		end
	end
	local lastcast = light.tmp.fetch('lastcast', false)
	local nextcast = sequence.copy[1]
	if tonumber(nextcast.spell) then
		nextcast.spell = GetSpellInfo(nextcast.spell)
	end
	if lastcast ~= nextcast.spell then
		_CastSpellByName(nextcast.spell, nextcast.target)
	else
		table.remove(sequence.copy, 1)
		if #sequence.copy == 0 then
			sequence.complete = true
		end
	end
end

function light.environment.hooks.resetsequence(sequence)
    if sequence.copy then
        sequence.copy = nil
        sequence.complete = false
        sequence.active = false
    end
end

function light.environment.hooks.auto_attack()
    --auto_attack()
end

function light.environment.hooks.auto_shot()
    --auto_shot()
end

function light.environment.hooks.auto_shoot()
    --auto_shoot()
end

function light.environment.hooks.stopcast()
    _SpellStopCasting()
end

function light.environment.hooks.macro(text)
    _RunMacroText(text)
end

local timer

light.cast.onUnlocked = function()
	light.log('Enhanced functionality enabled!')
	light.protected = true
	light.adv_protected = false
	timer:Cancel()
end

timer = C_Timer.NewTicker(1, function()
    -- NOTE: check is_unlocked
    if is_unlocked() then
		if light.cast.onUnlocked ~= nil then
        	light.cast.onUnlocked()
		end
    end
end)

light.event.register("UNIT_SPELLCAST_SUCCEEDED", function(...)
    local unitID, lineID, spellID = ...
    local spell = GetSpellInfo(spellID)
    if unitID == "player" then
        light.tmp.store('lastcast', spell)
    end
end)
