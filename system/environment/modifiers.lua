local addon, light = ...

local modifiers = {}

function modifiers:shift()
    return IsShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end

function modifiers:control()
    return IsControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end

function modifiers:alt()
    return IsAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end

function modifiers:lshift()
    return IsLeftShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end

function modifiers:lcontrol()
    return IsLeftControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end

function modifiers:lalt()
    return IsLeftAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end

function modifiers:rshift()
    return IsRightShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end

function modifiers:rcontrol()
    return IsRightControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end

function modifiers:ralt()
    return IsRightAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end

light.environment.hooks.modifier = setmetatable({}, {
    __index = function(t, k)
        return modifiers[k](t)
    end
})
