local addon, light = ...

light.console = {
    debugLevel = 0,
    file = '',
    line = '',
    logfile = nil
}

local fontObject = CreateFont("dank_console")
fontObject:SetFont("Interface\\AddOns\\Light\\media\\Consolas.ttf", 12)

local consoleFrame = CreateFrame('ScrollingMessageFrame', 'dank_console', UIParent)

consoleFrame:SetFontObject("dank_console")

-- position and setup
consoleFrame:SetPoint('CENTER', UIParent)
consoleFrame:SetMaxLines(1000)
consoleFrame:SetInsertMode('BOTTOM')
consoleFrame:SetWidth(500)
consoleFrame:SetHeight(145)
consoleFrame:SetJustifyH('LEFT')
consoleFrame:SetFading(false)
consoleFrame:SetClampedToScreen(true)
consoleFrame:Hide()

-- setup background
consoleFrame.background = consoleFrame:CreateTexture('background')
consoleFrame.background:SetPoint('TOPLEFT', consoleFrame, 'TOPLEFT', -5, 5)
consoleFrame.background:SetPoint('BOTTOMRIGHT', consoleFrame, 'BOTTOMRIGHT', 5, -5)
consoleFrame.background:SetColorTexture(0.74, 0.6, 0.36, 0.75)

consoleFrame.background2 = consoleFrame:CreateTexture('background')
consoleFrame.background2:SetPoint('TOPLEFT', consoleFrame, 'TOPLEFT', -7, 7)
consoleFrame.background2:SetPoint('BOTTOMRIGHT', consoleFrame, 'BOTTOMRIGHT', 7, -7)
consoleFrame.background2:SetColorTexture(20 / 255, 20 / 255, 20 / 255, 0.4)

-- make draggable
consoleFrame:SetMovable(true)
consoleFrame:EnableMouse(true)
consoleFrame:RegisterForDrag('LeftButton')
consoleFrame:SetScript('OnDragStart', consoleFrame.StartMoving)
consoleFrame:SetScript('OnDragStop', consoleFrame.StopMovingOrSizing)

-- scrolling
consoleFrame:SetScript('OnMouseWheel', function(self, delta)
    if delta > 0 then
        if IsShiftKeyDown() then
            self:ScrollToTop()
        else
            self:ScrollUp()
        end
    else
        if IsShiftKeyDown() then
            self:ScrollToBottom()
        else
            self:ScrollDown()
        end
    end
end)

-- display frame
function light.console.set_level(level)
    level = tonumber(level) or 0
    light.console.debugLevel = level
    light.settings.store('debug_level', level)
end

function light.console.toggle(show)
    if light.console.logfile ~= nil then
        return
    end
    show = show
    light.settings.store('debug_show', show)
    if show then
        consoleFrame:Show()
    else
        consoleFrame:Hide()
    end
end

local function join(...)
    local ret = ''
    for n = 1, select('#', ...) do
        ret = ret .. ' ' .. tostring(select(n, ...))
    end
    return ret:sub(2)
end

local colorize = function(color, msg)
    if light.console.logfile ~= nil then
        return msg
    else
        return light.interface.colorize(color, msg)
    end
end

local last = false
function light.console.log_time(str)
    local tm = GetTime()
    local sec = math.floor(tm)
    local milli = math.floor((tm - sec) * 1000)
    local min = math.floor(sec / 60)
    sec = sec - (min * 60)
    local hour = math.floor(min / 60)
    min = min - (hour * 60)
    local at = string.format('%d:%02d:%02d.%03d', hour, min, sec, milli)

    local joined = string.format('%s %s', at, str)
    if last ~= joined then
        light.console.log(joined)
        last = joined
    end
end

-- TODO: rm LB?
function light.console.log(msg)
    -- if light.adv_protected and light.console.logfile ~= nil then
    --  WriteFile(light.console.logfile, msg..'\r\n', true, true)
    -- elseif light.luabox and light.console.logfile ~= nil then
    --  __LB__.WriteFile(light.console.logfile, msg..'\n', true)
    -- else
    consoleFrame:AddMessage(msg)
    -- end
end

function light.console.notice(...)
    light.console.log(date('%H:%M:%S', time()) .. '|cff91FF00[notice]|r ' .. join(...))
end

function light.console.debug(level, section, color, ...)
    if light.console.debugLevel >= level then
        light.console.log_time(string.format('%s %s', colorize(color, '[' .. section .. ']'), join(...)))
    end
end

function light.log(string, ...)
    local formatted = string.format(string, ...)
    print('|cff' .. light.color .. '[' .. light.name .. ']|r ' .. formatted)
end

function light.error(...)
    print('|cff' .. light.color .. '[' .. light.name .. ']|r |cffc32425' .. join(...) .. '|r')
end

local function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function light.format(value)
    if tonumber(value) then
        return round(value, 2)
    else
        return tostring(value)
    end
end

light.on_ready(function()
    local debug_level = light.settings.fetch('debug_level', nil)
    light.console.set_level(debug_level)
    if light.settings.fetch('_engine_enablelogfile', false) then
        light.console.logfile = light.settings.fetch('_engine_logfilename', nil)
    end
    local toggle = light.settings.fetch('debug_show', false)
    light.console.toggle(toggle)
    light.console.log("Welcome!")
end)
