local dank = _G['dark_interface']
-- local addon, dank = ...

dank.interface.buttons = {
    buttons = {}
}

local buttons = dank.interface.buttons.buttons
local button_size = 42
local button_padding = 2
local container_frame = CreateFrame('frame', 'dr_container_frame', UIParent)
local first_button
local last_button

fontObject = CreateFont("dank_regular")
fontObject:SetFont("Interface\\Addons\\dank\\media\\OpenSans-Regular.ttf", button_size / 4)

fontObject = CreateFont("dank_small")
fontObject:SetFont("Interface\\Addons\\dank\\media\\OpenSans-Regular.ttf", 12)

fontObject = CreateFont("dank_bold")
fontObject:SetFont("Interface\\Addons\\dank\\media\\OpenSans-Bold.ttf", button_size / 4)

fontObject = CreateFont("dank_icon")
fontObject:SetFont("Interface\\Addons\\dank\\media\\FontAwesomeProRegular.otf", button_size / 2)

container_frame.moving = false
container_frame:SetPoint('CENTER', UIParent)
container_frame:SetFrameStrata('MEDIUM')
container_frame:SetMovable(true)
container_frame:EnableMouse(true)
container_frame:RegisterForDrag('LeftButton')
container_frame:SetScript('OnDragStart', container_frame.StartMoving)
container_frame:SetScript('OnDragStop', container_frame.StopMovingOrSizing)

container_frame.text = container_frame:CreateFontString()
container_frame.text:SetAllPoints(true)
container_frame.text:SetFontObject("dank_bold")
container_frame.text:SetText('Drag Me!')
container_frame.text:Hide()

container_frame.background = container_frame:CreateTexture()
container_frame.background:SetColorTexture(0, 0, 0, 0.75)
container_frame.background:SetAllPoints(container_frame)
container_frame.background:SetDrawLayer('BACKGROUND')

local tooltip_frame = CreateFrame('frame', 'dr_tooltip_frame', container_frame)

tooltip_frame.text = tooltip_frame:CreateFontString()
tooltip_frame.text:SetFontObject("dank_small")
tooltip_frame:SetFrameStrata('HIGH')

tooltip_frame:SetWidth(100)
tooltip_frame:SetHeight(100)

tooltip_frame.background = tooltip_frame:CreateTexture()
tooltip_frame.background:SetColorTexture(0, 0, 0, 0.75)
tooltip_frame.background:SetAllPoints(tooltip_frame)
tooltip_frame.background:SetDrawLayer('BACKGROUND')

tooltip_frame.gradient = tooltip_frame:CreateTexture()
tooltip_frame.gradient:SetDrawLayer('ARTWORK')
do
    local minR, minG, minB = dank.interface.color.hexToRgb(dank.interface.color.grey)
    local maxR, maxG, maxB = dank.interface.color.hexToRgb(dank.interface.color.dark_grey)
    tooltip_frame.gradient:SetColorTexture(1, 1, 1, 0.75)
    tooltip_frame.gradient:SetGradient('VERTICAL', maxR, maxG, maxB, minR, minG, minB)
end
tooltip_frame.gradient:SetPoint("TOPLEFT", tooltip_frame, "TOPLEFT", button_padding, -button_padding)
tooltip_frame.gradient:SetPoint("BOTTOMRIGHT", tooltip_frame, "BOTTOMRIGHT", -button_padding, button_padding)

-- dank_bold
local info_frame = CreateFrame('frame', 'dr_info_frame', container_frame)
info_frame:SetPoint('BOTTOMLEFT', container_frame, 'TOPLEFT', 0, 2)
info_frame:SetPoint('BOTTOMRIGHT', container_frame, 'TOPRIGHT', 0, 2)
info_frame:SetFrameStrata('HIGH')
info_frame:SetMovable(true)
info_frame:EnableMouse(true)
info_frame:SetScript('OnDragStart', function()
    container_frame:StartMoving()
end)
info_frame:SetScript('OnDragStop', container_frame.StopMovingOrSizing)

info_frame:SetHeight(button_size / 1.5)
info_frame.background = info_frame:CreateTexture()
info_frame.background:SetColorTexture(0, 0, 0, 0.75)
info_frame.background:SetAllPoints(info_frame)
info_frame.background:SetDrawLayer('BACKGROUND')

info_frame.gradient = info_frame:CreateTexture()
info_frame.gradient:SetDrawLayer('ARTWORK')
do
    local minR, minG, minB = dank.interface.color.hexToRgb(dank.interface.color.grey)
    local maxR, maxG, maxB = dank.interface.color.hexToRgb(dank.interface.color.dark_grey)
    info_frame.gradient:SetColorTexture(1, 1, 1, 0.75)
    info_frame.gradient:SetGradient('VERTICAL', maxR, maxG, maxB, minR, minG, minB)
end
info_frame.gradient:SetPoint("TOPLEFT", info_frame, "TOPLEFT", button_padding, -button_padding)
info_frame.gradient:SetPoint("BOTTOMRIGHT", info_frame, "BOTTOMRIGHT", -button_padding, button_padding)

info_frame.text = info_frame:CreateFontString()
info_frame.text:SetPoint("TOPLEFT", info_frame, "TOPLEFT", 5, 0)
info_frame.text:SetPoint("BOTTOMRIGHT", info_frame, "BOTTOMRIGHT", 5, 0)

info_frame.text:SetJustifyH('LEFT')
info_frame.text:SetFontObject("dank_regular")
info_frame.text:SetText('')

info_frame.text_right = info_frame:CreateFontString()
info_frame.text_right:SetPoint("TOPLEFT", info_frame, "TOPLEFT", -5, 0)
info_frame.text_right:SetPoint("BOTTOMRIGHT", info_frame, "BOTTOMRIGHT", -5, 0)

info_frame.text_right:SetJustifyH('RIGHT')
info_frame.text_right:SetFontObject("dank_regular")
info_frame.text_right:SetText('')

dank.interface.status_text_override = false
function dank.interface.status_override(text, duration, colorA, colorB)
    dank.interface.status_text_override = true
    info_frame.text:SetText(text)
    if not colorA or not colorB then
        colorA = dank.interface.color.teal
        colorB = dank.interface.color.dark_teal
    end
    do
        local minR, minG, minB = dank.interface.color.hexToRgb(colorA)
        local maxR, maxG, maxB = dank.interface.color.hexToRgb(colorB)
        info_frame.gradient:SetColorTexture(1, 1, 1, 0.75)
        info_frame.gradient:SetGradient('VERTICAL', maxR, maxG, maxB, minR, minG, minB)
    end
    C_Timer.After(duration, function()
        do
            local minR, minG, minB = dank.interface.color.hexToRgb(dank.interface.color.grey)
            local maxR, maxG, maxB = dank.interface.color.hexToRgb(dank.interface.color.dark_grey)
            info_frame.gradient:SetColorTexture(1, 1, 1, 0.75)
            info_frame.gradient:SetGradient('VERTICAL', maxR, maxG, maxB, minR, minG, minB)
        end
        dank.interface.status_text_override = false
        info_frame.text:SetText(dank.interface.status_text)
    end)
end

dank.interface.status = function(text)
    dank.interface.status_text = text
    if not dank.interface.status_text_override then
        info_frame.text:SetText(text)
    end
end

dank.interface.status_extra = function(text)
    info_frame.text_right:SetText(text)
end

local buttons_frame = CreateFrame('frame', 'dr_buttons_frame', container_frame)
buttons_frame:SetAllPoints(container_frame)

function dank.interface.buttons.add(button)
    local frame = CreateFrame('frame', 'dr_button_' .. table.size(buttons), buttons_frame)
    local index = table.size(buttons)
    local offset = (index * button_size) + (index * button_padding)

    frame.button = button
    frame.index = index
    frame:SetPoint('CENTER', container_frame)
    frame:SetPoint('LEFT', container_frame, 'LEFT', offset + 2, 0)
    frame:SetWidth(button_size)
    frame:SetHeight(button_size)
    frame:EnableMouse(true)
    frame:SetFrameStrata('MEDIUM')

    frame.background = frame:CreateTexture()
    frame.background:SetDrawLayer('BACKGROUND', 1)
    frame.background:SetAllPoints(frame)

    function frame.background:setColor(color)
        local r, g, b = dank.interface.color.hexToRgb(color)
        self:SetColorTexture(r, g, b, 1)
    end

    function frame.background:setGradient(colorA, colorB)
        local minR, minG, minB = dank.interface.color.hexToRgb(colorA)
        local maxR, maxG, maxB = dank.interface.color.hexToRgb(colorB)
        self:SetColorTexture(1, 1, 1, 0.85)
        self:SetGradient('VERTICAL', maxR, maxG, maxB, minR, minG, minB)
    end

    if button.color2 then
        frame.background:setColor('#ffffff')
        frame.background:setGradient(button.color, button.color2)
    else
        frame.background:setColor(button.color)
    end

    -- frame.outline = frame:CreateTexture('background')
    -- frame.outline:SetColorTexture(r, g, b, 0.5)
    -- frame.outline:SetDrawLayer('BACKGROUND', -1)
    -- frame.outline:SetPoint('TOPLEFT', frame, 'TOPLEFT', -1, 1)
    -- frame.outline:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 1, -1)

    frame.text = frame:CreateFontString()
    frame.text:SetAllPoints(true)
    frame.text:SetFontObject("dank_bold")
    frame.text:SetText(button.label)

    button.frame = frame

    frame:SetScript('OnMouseDown', function()
        button:callback()
    end)

    frame:SetScript('OnEnter', function(self)
        if button.state then
            button:set_color_on(0.75)
        else
            button:set_color_off(0.75)
        end
        local x, y = GetCursorPosition()
        tooltip_frame:Show()
        tooltip_frame.text:SetText(button.button.label)
        tooltip_frame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -2, -3)
        tooltip_frame.text:SetPoint("TOPLEFT", tooltip_frame, "TOPLEFT", 5, -5)
        tooltip_frame:SetWidth(tooltip_frame.text:GetStringWidth() + 11)
        tooltip_frame:SetHeight(tooltip_frame.text:GetHeight() + 9)

        -- tooltip_frame.text:SetWidth(tooltip_frame:GetRight() - tooltip_frame:GetLeft() - 10)
        -- tooltip_frame:SetHeight(tooltip_frame.text:GetHeight() + 15)
    end)

    frame:SetScript('OnLeave', function()
        if button.state then
            button:set_color_on(1)
        else
            button:set_color_off(1)
        end
        tooltip_frame:Hide()
    end)

    button:init()

    buttons[button.name] = button
    container_frame:SetWidth((table.size(buttons) * button_size) + (table.size(buttons) * button_padding) + 2)
    container_frame:SetHeight(button_size + button_padding + 2)

    return frame
end

function dank.interface.buttons.add_toggle(button)
    dank.interface.buttons.add({
        button = button,
        name = button.name,
        label = button.label or false,
        core = button.core or false,
        label = button.on.text,
        color = button.on.color,
        state = false,
        set_color_on = function(self, ratio)
            if button.on.color2 then
                self.frame.background:setColor('#ffffff')
                self.frame.background:setGradient(dank.interface.color.ratio(button.on.color, ratio),
                    dank.interface.color.ratio(button.on.color2, ratio))
            else
                self.frame.background:setColor(dank.interface.color.ratio(button.on.color, ratio))
            end
        end,
        toggle_on = function(self)
            self.frame.text:SetText(button.on.label)
            self:set_color_on(1)
            if button.label then
                dank.interface.status_override(button.label .. ' enabled', 1)
            end
        end,
        set_color_off = function(self, ratio)
            if button.off.color2 then
                self.frame.background:setColor('#ffffff')
                self.frame.background:setGradient(dank.interface.color.ratio(button.off.color, ratio),
                    dank.interface.color.ratio(button.off.color2, ratio))
            else
                self.frame.background:setColor(dank.interface.color.ratio(button.off.color, ratio))
            end
        end,
        toggle_off = function(self)
            self.frame.text:SetText(button.off.label)
            self:set_color_off(1)
            if button.label then
                dank.interface.status_override(button.label .. ' disabled', 1)
            end
        end,
        callback = function(self)
            self.state = not self.state
            if button.callback then
                button.callback(self)
            end
            if self.state then
                self:toggle_on()
            else
                self:toggle_off()
            end
            dank.settings.store_toggle(button.name, self.state)
        end,
        init = function(self)
            local state = dank.settings.fetch_toggle(button.name, false)
            self.state = state
            if state then
                self.frame.text:SetText(button.on.label)
                if button.on.color2 then
                    self.frame.background:setColor('#ffffff')
                    self.frame.background:setGradient(button.on.color, button.on.color2)
                else
                    self.frame.background:setColor(button.on.color)
                end
            else
                self.frame.text:SetText(button.off.label)
                if button.off.color2 then
                    self.frame.background:setColor('#ffffff')
                    self.frame.background:setGradient(button.off.color, button.off.color2)
                else
                    self.frame.background:setColor(button.off.color)
                end
            end
            if button.font then
                self.frame.text:SetFontObject(button.font)
            end
        end
    })
end

_G['button'] = buttons

function dank.interface.buttons.reset()
    for key, button in pairs(buttons) do
        if not button.core then
            button.frame:Hide()
            buttons[button.name] = nil
        else
            local state = dank.settings.fetch_toggle(button.name, button.default, button.core)
            button.state = state
            if state then
                button:toggle_on()
            else
                button:toggle_off()
            end
        end
    end
    container_frame:SetWidth((table.size(buttons) * button_size) + (table.size(buttons) * button_padding) + 2)
    container_frame:SetHeight(button_size + button_padding + 2)
end

function dank.interface.buttons.resize()
    local fontObject
    button_size = dank.settings.fetch('button_size', 32)

    fontObject = CreateFont("dank_regular")
    fontObject:SetFont("Interface\\Addons\\dank\\media\\OpenSans-Regular.ttf", button_size / 4)

    fontObject = CreateFont("dank_bold")
    fontObject:SetFont("Interface\\Addons\\dank\\media\\OpenSans-Bold.ttf", button_size / 4)

    fontObject = CreateFont("dank_icon")
    fontObject:SetFont("Interface\\Addons\\dank\\media\\FontAwesomeProRegular.otf", button_size / 2)

    for key, button in pairs(buttons) do
        local offset = (button.frame.index * button_size) + (button.frame.index * button_padding)
        button.frame:SetPoint('LEFT', container_frame, 'LEFT', offset + 2, 0)
        button.frame:SetWidth(button_size)
        button.frame:SetHeight(button_size)
    end
    container_frame:SetWidth((table.size(buttons) * button_size) + (table.size(buttons) * button_padding) + 2)
    container_frame:SetHeight(button_size + button_padding + 2)
end

dank.on_ready(function()
    button_size = dank.settings.fetch('button_size', button_size)

    fontObject = CreateFont("dank_regular")
    fontObject:SetFont("Interface\\Addons\\dank\\media\\OpenSans-Regular.ttf", button_size / 4)

    fontObject = CreateFont("dank_bold")
    fontObject:SetFont("Interface\\Addons\\dank\\media\\OpenSans-Bold.ttf", button_size / 4)

    fontObject = CreateFont("dank_icon")
    fontObject:SetFont("Interface\\Addons\\dank\\media\\FontAwesomeProRegular.otf", button_size / 2)

    dank.commands.register({
        command = 'move',
        arguments = {},
        text = 'Locks and unlocks the button frame for moving',
        callback = function(rotation_name)
            if container_frame.moving then
                container_frame.moving = false
                buttons_frame:Show()
                container_frame.text:Hide()
            else
                container_frame.moving = true
                buttons_frame:Hide()
                container_frame.text:Show()
            end
            return true
        end
    })

    dank.commands.register({
        command = {'size', 'resize'},
        arguments = {'button_size'},
        text = 'Adjusts the size of the on-screen buttons',
        callback = function(button_size)
            local size = tonumber(button_size)
            print(size, button_size)
            if size then
                dank.settings.store('button_size', size)
                dank.interface.buttons.resize()
                return true
            else
                return false
            end
        end
    })

    dank.interface.buttons.add_toggle({
        core = true,
        name = 'master_toggle',
        label = 'Rotation',
        font = 'dank_icon',
        on = {
            label = dank.interface.icon('toggle-on'),
            color = dank.interface.color.green,
            color2 = dank.interface.color.dark_green
        },
        off = {
            label = dank.interface.icon('toggle-off'),
            color = dank.interface.color.grey,
            color2 = dank.interface.color.dark_grey
        }
    })

    dank.interface.buttons.add_toggle({
        core = true,
        name = 'cooldowns',
        label = 'Cooldowns',
        font = 'dank_icon',
        on = {
            label = dank.interface.icon('clock'),
            color = dank.interface.color.teal,
            color2 = dank.interface.color.dark_teal
        },
        off = {
            label = dank.interface.icon('clock'),
            color = dank.interface.color.grey,
            color2 = dank.interface.color.dark_grey
        }
    })

    dank.interface.buttons.add_toggle({
        core = true,
        name = 'interrupts',
        label = 'Interrupts',
        font = 'dank_icon',
        on = {
            label = dank.interface.icon('hand-paper'),
            color = dank.interface.color.teal,
            color2 = dank.interface.color.dark_teal
        },
        off = {
            label = dank.interface.icon('hand-paper'),
            color = dank.interface.color.grey,
            color2 = dank.interface.color.dark_grey
        }
    })

    dank.interface.buttons.add_toggle({
        core = true,
        name = 'multitarget',
        label = 'Multi-target',
        font = 'dank_icon',
        on = {
            label = dank.interface.icon('users'),
            color = dank.interface.color.teal,
            color2 = dank.interface.color.dark_teal
        },
        off = {
            label = dank.interface.icon('user'),
            color = dank.interface.color.grey,
            color2 = dank.interface.color.dark_grey
        }
    })

    C_Timer.After(2, function()
        dank.interface.status_override('/dr help to get started', 5)
    end)

end)
