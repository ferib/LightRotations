local addon, dank = ...

local frame = CreateFrame('frame')
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function(self, event, arg1)
    if event == 'ADDON_LOADED' and arg1 == addon then
        dank.log('Build ' .. dank.version)
        if dank_storage == nil then
            dank_storage = {}
            dank.log('Creating new settings profile!')
        else
            dank.log('Settings loaded, welcome back!')
        end
        dank.settings_ready = true
    end
end)

dank.settings = {}

function dank.settings.store(key, value)
    dank_storage[key] = value
    return true
end

function dank.settings.fetch(key, default)
    local value = dank_storage[key]
    return value == nil and default or value
end

function dank.settings.store_toggle(key, value)
    local active_rotation = dank.settings.fetch('active_rotation', false)
    if not active_rotation then
        return
    end
    local full_key
    if dank.rotation.active_rotation then
        full_key = active_rotation .. '_toggle_' .. key
    else
        full_key = 'toggle_' .. key
    end
    dank_storage[full_key] = value
    dank.console.debug(5, 'settings', 'purple', string.format('%s <= %s', full_key, tostring(value)))
    return true
end

function dank.settings.fetch_toggle(key, default)
    local active_rotation = dank.settings.fetch('active_rotation', false)
    if not active_rotation then
        return
    end
    local full_key
    if dank.rotation.active_rotation then
        full_key = active_rotation .. '_toggle_' .. key
    else
        full_key = 'toggle_' .. key
    end
    if not string.find(full_key, 'master_toggle') then
        dank.console.debug(5, 'settings', 'purple', string.format('%s => %s', full_key, tostring(default)))
    end
    return dank_storage[full_key] or default
end

dank.tmp = {
    cache = {}
}

function dank.tmp.store(key, value)
    dank.tmp.cache[key] = value
    return true
end

function dank.tmp.fetch(key, default)
    return dank.tmp.cache[key] or default
end

dank.on_ready(function()
    dank.environment.hooks.toggle = function(key, default)
        return dank.settings.fetch_toggle(key, default)
    end
    dank.environment.hooks.storage = function(key, default)
        return dank.settings.fetch(key, default)
    end
end)
