local addon, light = ...

local ticker

ticker = C_Timer.NewTicker(0.1, function()
    if light.settings_ready then
        for _, callback in pairs(light.ready_callbacks) do
            callback()
        end
        ticker:Cancel()
    end
end)
