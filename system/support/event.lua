local addon, light = ...

light.event = {
    events = {},
    callbacks = {}
}

local frame = CreateFrame('frame')

function light.event.register(event, callback)
    if not light.event.events[event] then
        frame:RegisterEvent(event)
        light.event.events[event] = true
        light.event.callbacks[event] = {}
    end
    table.insert(light.event.callbacks[event], callback)
end

frame:SetScript('OnEvent', function(self, event, ...)
    if light.event.callbacks[event] then
        for key, callback in ipairs(light.event.callbacks[event]) do
            callback(...)
        end
    end
end)
