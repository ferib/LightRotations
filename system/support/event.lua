local addon, dank = ...

dank.event = {
    events = {},
    callbacks = {}
}

local frame = CreateFrame('frame')

function dank.event.register(event, callback)
    if not dank.event.events[event] then
        frame:RegisterEvent(event)
        dank.event.events[event] = true
        dank.event.callbacks[event] = {}
    end
    table.insert(dank.event.callbacks[event], callback)
end

frame:SetScript('OnEvent', function(self, event, ...)
    if dank.event.callbacks[event] then
        for key, callback in ipairs(dank.event.callbacks[event]) do
            callback(...)
        end
    end
end)
