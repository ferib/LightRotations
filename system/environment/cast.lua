local addon, dank = ...

-- TODO: ! cleanup

function _CastSpellByName(spell, target)
    local target = target or "target"
    if dank.adv_protected then
        -- if Unlock then
        Nn.Unlock("CastSpellByName", spell, target)
        dank.console.debug(4, 'cast', 'red', spell .. ' on ' .. target)
        dank.interface.status(spell)
    elseif dank.protected then
        dr_secured = false
        for i = 1, 420 do
            RunScript([[
        if not issecure() then
          return
        end
        CastSpellByName("]] .. spell .. [[", "]] .. target .. [[")
        dr_secured = true
      ]])
            if dr_secured then
                dank.console.debug(4, 'cast', 'red', spell .. ' on ' .. target)
                dank.interface.status(spell)
            end
        end
        dr_secured = nil
    end
end

-- test?
function _CastGroundSpellByName(spell, target)
    local target = target or "target"
    if dank.adv_protected then
        Nn.Unlock("RunMacroText", "/cast [@cursor] " .. spell)
        dank.console.debug(4, 'cast', 'red', spell .. ' on ' .. target)
        dank.interface.status(spell)
    elseif dank.protected then
        dr_secured = false
        for i = 1, 420 do
            RunScript([[
				if not issecure() then
				return
				end
				RunMacroText("/cast [@cursor] ]] .. spell .. [[")
				dr_secured = true
			]])
            if dr_secured then
                dank.console.debug(4, 'cast', 'red', spell .. ' on ' .. target)
                dank.interface.status(spell)
            end
        end
        dr_secured = nil
    end
end

function _CastSpellByID(spell, target)
    -- if tonumber(spell) then
    --  spell, _ = GetSpellInfo(spell)
    -- end
    -- return _CastSpellByName(spell, target)
    return false -- TODO
end

function _CastGroundSpellByID(spell, target)
    -- if tonumber(spell) then
    --  spell, _ = GetSpellInfo(spell)
    -- end
    -- return _CastGroundSpellByName(spell, target)
    return false -- TODO
end

function _SpellStopCasting()
    if dank.adv_protected then
        Nn.Unlock("SpellStopCasting")
        dank.console.debug(4, '', 'red', 'Stopcasting')
        dank.interface.status('Stopcasting')
    elseif dank.protected then
        dr_secured = false
        for i = 1, 420 do
            RunScript([[
				if not issecure() then
				return
				end
				SpellStopCasting()
				dr_secured = true
			]])
            if dr_secured then
                dank.console.debug(4, '', 'red', 'Stopcasting')
                dank.interface.status('Stopcasting')
            end
        end
        dr_secured = nil
    end
end

-- TODO: fix?
local function auto_attack()
    if not IsCurrentSpell(6603) then
        if dank.adv_protected then
            CastSpellByID(6603)
        else
            secured = false
            while not secured do
                RunScript([[
					for index = 1, 500 do
						if not issecure() then
						return
						end
					end
					CastSpellByID(6603)
					secured = true
				]])
            end
        end
    end
end

local function auto_shot()
    if not IsCurrentSpell(75) then
        if dank.adv_protected then
            CastSpellByID(75)
        else
            secured = false
            while not secured do
                RunScript([[
					for index = 1, 500 do
						if not issecure() then
						return
						end
					end
					CastSpellByID(75)
					secured = true
				]])
            end
        end

    end
end

local function auto_shoot()
    if not IsCurrentSpell(5019) then
        if dank.adv_protected then
            CastSpellByID(5019)
        else
            secured = false
            while not secured do
                RunScript([[
					for index = 1, 500 do
						if not issecure() then
							return
						end
					end
					CastSpellByID(5019)
					secured = true
				]])
            end
        end

    end
end

function _RunMacroText(text)
    if dank.adv_protected then
        RunMacroText(text)
        dank.console.debug(4, 'macro', 'red', text)
        dank.interface.status('Macro')
    else
        if dank.luabox then
            __LB__.Unlock(RunMacroText, text)
            dank.console.debug(4, 'macro', 'red', text)
            dank.interface.status('LB Macro')
        else
            secured = false
            while not secured do
                RunScript([[
					for index = 1, 500 do
					if not issecure() then
						return
					end
					end
					RunMacroText("]] .. text .. [[")
					secured = true
				]])
                if secured then
                    dank.console.debug(4, 'macro', 'red', text)
                    dank.interface.status('Macro')
                end
            end
        end
    end
end

dank.tmp.store('lastcast', spell)

local function is_unlocked()
    local unlocked = false
    for x = 1, 50 do
        RunScript([[
			if not issecure() then
				return
			end
			unlocked = true
		]])
    end
    return unlocked
end

local turbo = false

function dank.environment.hooks.cast(spell, target)
    turbo = dank.settings.fetch('_engine_turbo', false)
    local enablehcd = dank.settings.fetch('_engine_healcd.check', true)
    if not dank.protected then
        return
    end
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
        dank.savedHealTarget = target
        if tonumber(spell) then
            spell, _ = GetSpellInfo(spell)
        end
        dank.console.debug(1, 'engine', 'engine', string.format('casting spell %s on %s. UnitHealth %d', spell,
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
	dank.glow.trigger(spell)
end

function dank.environment.hooks.sequenceactive(sequence)
    if sequence.active then
        return true
    end
    return false
end

function dank.environment.hooks.dosequence(sequence)
    if sequence.complete then
        return false
    end
    if #sequence.spells == 0 then
        return false
    end
    return true
end

function dank.environment.hooks.sequence(sequence)
    if not dank.protected then
        return
    end
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
    local lastcast = dank.tmp.fetch('lastcast', false)
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

function dank.environment.hooks.resetsequence(sequence)
    if sequence.copy then
        sequence.copy = nil
        sequence.complete = false
        sequence.active = false
    end
end

function dank.environment.hooks.auto_attack()
    auto_attack()
end

function dank.environment.hooks.auto_shot()
    auto_shot()
end

function dank.environment.hooks.auto_shoot()
    auto_shoot()
end

function dank.environment.hooks.stopcast()
    _SpellStopCasting()
end

function dank.environment.hooks.macro(text)
    _RunMacroText(text)
end

local timer
timer = C_Timer.NewTicker(0.5, function()
    -- NOTE: _G.Nn is loaded for devs
    if Nn ~= nil then
        dank.log('NoName Detected! Enhanced functionality enabled!')
        dank.adv_protected = true
        dank.protected = true
        Unlock = true
        timer:Cancel()
    elseif is_unlocked() then
        dank.log('Enhanced functionality enabled!')
        dank.protected = true
        dank.adv_protected = false
        timer:Cancel()
    end
end)

dank.event.register("UNIT_SPELLCAST_SUCCEEDED", function(...)
    local unitID, lineID, spellID = ...
    local spell = GetSpellInfo(spellID)
    if unitID == "player" then
        dank.tmp.store('lastcast', spell)
    end
end)
