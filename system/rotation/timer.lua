local addon, light = ...

light.rotation.timer = {
    lag = 0
}

local gcd_spell, gcd_spell_name

local function find_gcd_spell()
    local _, _, offset, numSpells = GetSpellTabInfo(2)
    for i = offset + 1, offset + numSpells do
        local slotType, slotID = GetSpellBookItemInfo(i, 'spell')
        if slotType == 'SPELL' then
            local slotName = GetSpellBookItemName(i, 'spell')
            local spellName, _, _, _, _, _, spellID = GetSpellInfo(slotName)
            local spellCD = GetSpellBaseCooldown(spellID or 0) -- spellID can be nil during loading
            local spellCharges = GetSpellCharges(spellID)
            if spellCD == 0 and spellCharges == nil then
                gcd_spell = spellID
                gcd_spell_name = spellName
                break
            end
        end
    end

    C_Timer.After(0.5, function()
        if not gcd_spell then
            light.console.debug(4, 'engine', 'engine', 'No GCD candidate found!')
        else
            light.console.debug(4, 'engine', 'engine',
                string.format('GCD candidate found, using %s (%s)', gcd_spell, gcd_spell_name))
        end
    end)
end

light.event.register('SPELLS_CHANGED', find_gcd_spell)

local last_loading = GetTime()
local loading_wait = math.random(120, 300)
local last_duration = false
local lastLag = 0
local castclip = 0
local turbo = false

function light.rotation.tick(ticker)
    turbo = light.settings.fetch('_engine_turbo', false)
    castclip = light.settings.fetch('_engine_castclip', 0.15)
    ticker._duration = light.settings.fetch('_engine_tickrate', 0.1)
    if ticker._duration ~= last_duration then
        last_duration = ticker._duration
        light.console.debug(4, 'engine', 'engine', string.format('Ticket Rate: %sms', last_duration * 1000))
    end
    local toggled = light.settings.fetch_toggle('master_toggle', false)
    if not toggled then
        light.interface.status('Ready...')
        return
    end

    local do_gcd = light.settings.fetch('_engine_gcd', true)
    local gcd_wait, start, duration = false
    if gcd_spell and do_gcd then
        start, duration = GetSpellCooldown(gcd_spell)
        gcd_wait = start > 0 and (duration - (GetTime() - start)) or 0
    end

    if light.rotation.active_rotation then
        if IsMounted() then
            return
        end

        local _, _, lagHome, lagWorld = GetNetStats()
        local lag = (((lagHome + lagWorld) / 2) / 1000) * 2
        if lag ~= lastLag then
            light.console.debug(4, 'engine', 'engine', string.format('Lag: %sms', lag * 1000))
            lastLag = lag
            light.rotation.timer.lag = lag
        end

        if not turbo and (gcd_wait and gcd_wait > (lag + castclip)) then
            if light.rotation.active_rotation.gcd then
                return light.rotation.active_rotation.gcd()
            else
                return
            end
        end

        local iscasting, _ = CastingInfo("player")
        local hcd = light.settings.fetch('_engine_healcd.spin', 0.8)
        if light.savedHealTarget ~= nil and not iscasting then
            light.healthCooldown[light.savedHealTarget] = GetTime() + hcd
            light.console.debug(1, 'engine', 'engine',
                string.format('finished casting spell on %s. Health %d start cooldown of %1.1f seconds',
                    UnitName(light.savedHealTarget), UnitHealth(light.savedHealTarget), hcd))
            light.savedHealTarget = nil
        end
        local unit, cdtime
        for unit, cdtime in pairs(light.healthCooldown) do
            if GetTime() > cdtime then
                if UnitName(unit) ~= nil and UnitHealth(unit) ~= nil then
                    light.console.debug(1, 'engine', 'engine', string.format('cooldown finished for unit %s health %d',
                        UnitName(unit), UnitHealth(unit)))
                end
                light.healthCooldown[unit] = nil
            end
        end

        local rv
        if UnitAffectingCombat('player') then
            rv = light.rotation.active_rotation.combat()
        else
            rv = light.rotation.active_rotation.resting()
            if GetTime() - last_loading > loading_wait then
                light.interface.status_override(light.interface.loading_messages[math.random(#light.interface
                                                                                               .loading_messages)], 10)
                last_loading = GetTime()
                loading_wait = math.random(120, 300)
            else
                light.interface.status('Resting...')
            end
        end
        if rv then
            return
        end

        -- light.questing:questing()
    end
end

light.on_ready(function()
    light.rotation.timer.ticker = C_Timer.NewAdvancedTicker(0.1, light.rotation.tick)
end)
