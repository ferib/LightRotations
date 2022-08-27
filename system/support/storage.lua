local addon, light = ...

local frame = CreateFrame('frame')
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function(self, event, arg1)
    if event == 'ADDON_LOADED' and arg1 == addon then
        light.log('Build ' .. light.version)
        if light_storage == nil then
            light_storage = {}
            light.log('Creating new settings profile!')
        else
            light.log('Settings loaded, welcome back!')
        end
        light.settings_ready = true
    end
end)

light.settings = {}

function light.settings.store(key, value)
    light_storage[key] = value
    return true
end

function light.settings.fetch(key, default)
    local value = light_storage[key]
    return value == nil and default or value
end

function light.settings.store_toggle(key, value)
    local active_rotation = light.settings.fetch('active_rotation', false)
    if not active_rotation then
        return
    end
    local full_key
    if light.rotation.active_rotation then
        full_key = active_rotation .. '_toggle_' .. key
    else
        full_key = 'toggle_' .. key
    end
    light_storage[full_key] = value
    light.console.debug(5, 'settings', 'purple', string.format('%s <= %s', full_key, tostring(value)))
    return true
end

function light.settings.fetch_toggle(key, default)
    local active_rotation = light.settings.fetch('active_rotation', false)
    if not active_rotation then
        return
    end
    local full_key
    if light.rotation.active_rotation then
        full_key = active_rotation .. '_toggle_' .. key
    else
        full_key = 'toggle_' .. key
    end
    if not string.find(full_key, 'master_toggle') then
        light.console.debug(5, 'settings', 'purple', string.format('%s => %s', full_key, tostring(default)))
    end
    return light_storage[full_key] or default
end

light.tmp = {
    cache = {}
}

function light.tmp.store(key, value)
    light.tmp.cache[key] = value
    return true
end

function light.tmp.fetch(key, default)
    return light.tmp.cache[key] or default
end

light.on_ready(function()
    light.environment.hooks.toggle = function(key, default)
        return light.settings.fetch_toggle(key, default)
    end
    light.environment.hooks.storage = function(key, default)
        return light.settings.fetch(key, default)
    end
end)
