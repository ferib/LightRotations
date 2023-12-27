local addon, light = ...

local builder = {}

local DiesalTools = LibStub("DiesalTools-1.0")
local DiesalStyle = LibStub("DiesalStyle-1.0")
local DiesalGUI = LibStub("DiesalGUI-1.0")
local DiesalMenu = LibStub("DiesalMenu-1.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local Colors = DiesalStyle.Colors
local HSL, ShadeColor, TintColor = DiesalTools.HSL, DiesalTools.ShadeColor, DiesalTools.TintColor

local buttonStyleSheet = {
    ['frame-color'] = {
        type = 'texture',
        layer = 'BACKGROUND',
        color = '2f353b',
        offset = 0
    },
    ['frame-highlight'] = {
        type = 'texture',
        layer = 'BORDER',
        gradient = 'VERTICAL',
        color = 'FFFFFF',
        alpha = 0,
        alphaEnd = .1,
        offset = -1
    },
    ['frame-outline'] = {
        type = 'outline',
        layer = 'BORDER',
        color = '000000',
        offset = 0
    },
    ['frame-inline'] = {
        type = 'outline',
        layer = 'BORDER',
        gradient = 'VERTICAL',
        color = 'ffffff',
        alpha = .02,
        alphaEnd = .09,
        offset = -1
    },
    ['frame-hover'] = {
        type = 'texture',
        layer = 'HIGHLIGHT',
        color = 'ffffff',
        alpha = .1,
        offset = 0
    },
    ['text-color'] = {
        type = 'Font',
        color = 'b8c2cc'
    }
}

local buttonStyleSheetGreen = {
    ['frame-color'] = {
        type = 'texture',
        layer = 'BACKGROUND',
        color = '336d38',
        offset = 0
    },
    ['frame-highlight'] = {
        type = 'texture',
        layer = 'BORDER',
        gradient = 'VERTICAL',
        color = 'FFFFFF',
        alpha = 0,
        alphaEnd = .1,
        offset = -1
    },
    ['frame-outline'] = {
        type = 'outline',
        layer = 'BORDER',
        color = '000000',
        offset = 0
    },
    ['frame-inline'] = {
        type = 'outline',
        layer = 'BORDER',
        gradient = 'VERTICAL',
        color = 'ffffff',
        alpha = .02,
        alphaEnd = .09,
        offset = -1
    },
    ['frame-hover'] = {
        type = 'texture',
        layer = 'HIGHLIGHT',
        color = 'ffffff',
        alpha = .1,
        offset = 0
    },
    ['text-color'] = {
        type = 'Font',
        color = 'c4ffc9'
    }
}

local buttonStyleSheetOrange = {
    ['frame-color'] = {
        type = 'texture',
        layer = 'BACKGROUND',
        color = 'b57c13',
        offset = 0
    },
    ['frame-highlight'] = {
        type = 'texture',
        layer = 'BORDER',
        gradient = 'VERTICAL',
        color = 'FFFFFF',
        alpha = 0,
        alphaEnd = .1,
        offset = -1
    },
    ['frame-outline'] = {
        type = 'outline',
        layer = 'BORDER',
        color = '000000',
        offset = 0
    },
    ['frame-inline'] = {
        type = 'outline',
        layer = 'BORDER',
        gradient = 'VERTICAL',
        color = 'ffffff',
        alpha = .02,
        alphaEnd = .09,
        offset = -1
    },
    ['frame-hover'] = {
        type = 'texture',
        layer = 'HIGHLIGHT',
        color = 'ffffff',
        alpha = .1,
        offset = 0
    },
    ['text-color'] = {
        type = 'Font',
        color = 'ffd6c6'
    }
}

local buttonStyleSheetRed = {
    ['frame-color'] = {
        type = 'texture',
        layer = 'BACKGROUND',
        color = '682f2f',
        offset = 0
    },
    ['frame-highlight'] = {
        type = 'texture',
        layer = 'BORDER',
        gradient = 'VERTICAL',
        color = 'FFFFFF',
        alpha = 0,
        alphaEnd = .1,
        offset = -1
    },
    ['frame-outline'] = {
        type = 'outline',
        layer = 'BORDER',
        color = '000000',
        offset = 0
    },
    ['frame-inline'] = {
        type = 'outline',
        layer = 'BORDER',
        gradient = 'VERTICAL',
        color = 'ffffff',
        alpha = .02,
        alphaEnd = .09,
        offset = -1
    },
    ['frame-hover'] = {
        type = 'texture',
        layer = 'HIGHLIGHT',
        color = 'ffffff',
        alpha = .1,
        offset = 0
    },
    ['text-color'] = {
        type = 'Font',
        color = 'ffbcbc'
    }
}

local spinnerStyleSheet = {
    ['frame-background'] = {
        type = 'texture',
        layer = 'BACKGROUND',
        color = '000000',
        alpha = .6
    },
    ['frame-inline'] = {
        type = 'outline',
        layer = 'BORDER',
        color = '000000',
        alpha = .6
    },
    ['frame-outline'] = {
        type = 'outline',
        layer = 'BORDER',
        color = 'FFFFFF',
        alpha = .02,
        position = 1
    },
    ['frame-hover'] = {
        type = 'outline',
        layer = 'HIGHLIGHT',
        color = 'FFFFFF',
        alpha = .25,
        position = -1
    },
    ['editBox-font'] = {
        type = 'Font',
        color = Colors.UI_TEXT
    },
    ['bar-background'] = {
        type = 'texture',
        layer = 'BACKGROUND',
        gradient = {'VERTICAL', Colors.UI_A100, ShadeColor(Colors.UI_A100, .1)}
    },
    ['bar-inline'] = {
        type = 'outline',
        layer = 'BORDER',
        gradient = {'VERTICAL', 'FFFFFF', 'FFFFFF'},
        alpha = {.07, .02}
    },
    ['bar-outline'] = {
        type = 'texture',
        layer = 'ARTWORK',
        color = '000000',
        alpha = .7,
        width = 1,
        position = {nil, 1, 0, 0}
    }
}

local createButtonStyle = {
    type = 'texture',
    layer = 'ARTWORK',
    image = {'DiesalGUIcons', {1, 6, 16, 256, 128}},
    alpha = .7,
    position = {-2, nil, -2, nil},
    width = 16,
    height = 16
}

local deleteButtonStyle = {
    type = 'texture',
    texFile = 'DiesalGUIcons',
    texCoord = {2, 6, 16, 256, 128},
    alpha = .7,
    offset = {-2, nil, -2, nil},
    width = 16,
    height = 16
}

local ButtonNormal = {
    type = 'texture',
    texColor = 'ffffff',
    alpha = .7
}

local ButtonOver = {
    type = 'texture',
    alpha = 1
}

local ButtonClicked = {
    type = 'texture',
    alpha = .3
}

local WindowStylesheet = {
    ['frame-outline'] = {
        type = 'outline',
        layer = 'BACKGROUND',
        color = '000000'
    },
    ['frame-shadow'] = {
        type = 'shadow'
    },
    ['titleBar-color'] = {
        type = 'texture',
        layer = 'BACKGROUND',
        color = '0b0c0f',
        alpha = .95
    },
    ['titletext-Font'] = {
        type = 'font',
        color = 'd8d8d8'
    },
    ['closeButton-icon'] = {
        type = 'texture',
        layer = 'ARTWORK',
        image = {'DiesalGUIcons', {9, 5, 16, 256, 128}},
        alpha = .3,
        position = {-2, nil, -1, nil},
        width = 16,
        height = 16
    },
    ['closeButton-iconHover'] = {
        type = 'texture',
        layer = 'HIGHLIGHT',
        image = {'DiesalGUIcons', {9, 5, 16, 256, 128}, '4da6ff'},
        alpha = 1,
        position = {-2, nil, -1, nil},
        width = 16,
        height = 16
    },
    ['header-background'] = {
        type = 'texture',
        layer = 'BACKGROUND',
        gradient = {'VERTICAL', '4da6ff', Colors.UI_400_GR[2]},
        alpha = .95,
        position = {0, 0, 0, -1}
    },
    ['header-inline'] = {
        type = 'outline',
        layer = 'BORDER',
        gradient = {'VERTICAL', 'ffffff', 'ffffff'},
        alpha = {.05, .02},
        position = {0, 0, 0, -1}
    },
    ['header-divider'] = {
        type = 'texture',
        layer = 'BORDER',
        color = '000000',
        alpha = 1,
        position = {0, 0, nil, 0},
        height = 1
    },
    ['content-background'] = {
        type = 'texture',
        layer = 'BACKGROUND',
        color = '1a1d23',
        alpha = .90
    },
    ['content-outline'] = {
        type = 'outline',
        layer = 'BORDER',
        color = 'FFFFFF',
        alpha = .01
    },
    ['footer-background'] = {
        type = 'texture',
        layer = 'BACKGROUND',
        gradient = {'VERTICAL', Colors.UI_400_GR[1], Colors.UI_400_GR[2]},
        alpha = .95,
        position = {0, 0, -1, 0}
    },
    ['footer-divider'] = {
        type = 'texture',
        layer = 'BACKGROUND',
        color = '000000',
        position = {0, 0, 0, nil},
        height = 1
    },
    ['footer-inline'] = {
        type = 'outline',
        layer = "BORDER",
        gradient = {'VERTICAL', 'ffffff', 'ffffff'},
        alpha = {.05, .02},
        position = {0, 0, -1, 0},
        debug = true
    }
}

local checkBoxStyle = {
    base = {
        type = 'texture',
        layer = 'ARTWORK',
        color = '00FF00',
        position = -3
    },
    disabled = {
        type = 'texture',
        color = '00FFFF'
    },
    enabled = {
        type = 'texture',
        color = Colors.UI_A400
    }
}

DiesalGUI:RegisterObjectConstructor("FontString", function()
    local self = DiesalGUI:CreateObjectBase(Type)
    local frame = CreateFrame('Frame', nil, UIParent)
    local fontString = frame:CreateFontString(nil, "OVERLAY", 'DiesalFontNormal')
    self.frame = frame
    self.fontString = fontString
    self.SetParent = function(self, parent)
        self.frame:SetParent(parent)
    end
    self.OnRelease = function(self)
        self.fontString:SetText('')
    end
    self.OnAcquire = function(self)
        self:Show()
    end
    self.type = "FontString"
    return self
end, 1)

DiesalGUI:RegisterObjectConstructor("Rule", function()
    local self = DiesalGUI:CreateObjectBase(Type)
    local frame = CreateFrame('Frame', nil, UIParent)
    self.frame = frame
    frame:SetHeight(1)
    frame.texture = frame:CreateTexture()
    frame.texture:SetColorTexture(0, 0, 0, 0.5)
    frame.texture:SetAllPoints(frame)
    self.SetParent = function(self, parent)
        self.frame:SetParent(parent)
    end
    self.OnRelease = function(self)
        self:Hide()
    end
    self.OnAcquire = function(self)
        self:Show()
    end
    self.type = "Rule"
    return self
end, 1)

local function buildElements(table, parent)
    local offset = -5
    for _, element in ipairs(table.template) do
        local push, pull = 0, 0
        if element.type == 'header' then
            local tmp = DiesalGUI:Create("FontString")
            tmp:SetParent(parent.content)
            parent:AddChild(tmp)
            tmp = tmp.fontString
            tmp:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset)
            tmp:SetText(element.text)
            if element.justify then
                tmp:SetJustifyH(element.justify)
            else
                tmp:SetJustifyH('LEFT')
            end
            tmp:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 13, "")
            tmp:SetWidth(parent.content:GetWidth() - 10)

            if element.align then
                tmp:SetJustifyH(strupper(element.align))
            end

            if element.key then
                table.window.elements[element.key] = tmp
            end

        elseif element.type == 'text' then

            local tmp = DiesalGUI:Create("FontString")
            tmp:SetParent(parent.content)
            parent:AddChild(tmp)
            tmp = tmp.fontString
            tmp:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset)
            tmp:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
            tmp:SetText(element.text)
            tmp:SetJustifyH('LEFT')
            tmp:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), element.size or 10, "")
            tmp:SetWidth(parent.content:GetWidth() - 10)

            if not element.offset then
                element.offset = tmp:GetStringHeight()
            end

            if element.align then
                tmp:SetJustifyH(strupper(element.align))
            end

            if element.key then
                table.window.elements[element.key] = tmp
            end

        elseif element.type == 'rule' then

            local tmp = DiesalGUI:Create('Rule')
            parent:AddChild(tmp)
            tmp:SetParent(parent.content)
            tmp.frame:SetPoint('TOPLEFT', parent.content, 'TOPLEFT', 5, offset - 3)
            tmp.frame:SetPoint('BOTTOMRIGHT', parent.content, 'BOTTOMRIGHT', -5, offset - 3)
            if element.key then
                table.window.elements[element.key] = tmp
            end

        elseif element.type == 'texture' then

            local tmp = CreateFrame('Frame')
            tmp:SetParent(parent.content)
            if element.center then
                tmp:SetPoint('CENTER', parent.content, 'CENTER', (element.x or 0), offset - (element.y or 0))
            else
                tmp:SetPoint('TOPLEFT', parent.content, 'TOPLEFT', 5 + (element.x or 0), offset - 3 + (element.y or 0))
            end

            tmp:SetWidth(parent:GetWidth() - 10)
            tmp:SetHeight(element.height)
            tmp:SetWidth(element.width)
            tmp.texture = tmp:CreateTexture()
            tmp.texture:SetTexture(element.texture)
            tmp.texture:SetAllPoints(tmp)

            if element.key then
                table.window.elements[element.key] = tmp
            end

        elseif element.type == 'checkbox' then

            local tmp = DiesalGUI:Create('Toggle')
            parent:AddChild(tmp)
            tmp:SetParent(parent.content)
            tmp:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset)

            tmp:SetEventListener('OnValueChanged', function(this, event, checked)
                light.settings.store(table.key .. '_' .. element.key, checked)
            end)

            tmp.checkBoxStyle = checkBoxStyle

            tmp:SetChecked(light.settings.fetch(table.key .. '_' .. element.key, element.default or false))
            tmp:SetText(element.text)

            if element.desc then
                local tmp_desc = DiesalGUI:Create("FontString")
                tmp_desc:SetParent(parent.content)
                parent:AddChild(tmp_desc)
                tmp_desc = tmp_desc.fontString
                tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset - 15)
                tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset - 15)
                tmp_desc:SetText(element.desc)
                tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9, "")
                tmp_desc:SetWidth(parent.content:GetWidth() - 10)
                tmp_desc:SetJustifyH('LEFT')
                push = tmp_desc:GetStringHeight() + 5
            end

            if element.key then
                table.window.elements[element.key .. 'Text'] = tmp_text
                table.window.elements[element.key] = tmp
            end

        elseif element.type == 'spinner' then

            local tmp_spin = DiesalGUI:Create('Spinner')
            parent:AddChild(tmp_spin)
            tmp_spin:SetParent(parent.content)
            tmp_spin:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
            tmp_spin:SetNumber(light.settings.fetch(table.key .. '_' .. element.key, element.default))

            if element.width then
                tmp_spin.settings.width = element.width
            end
            if element.min then
                tmp_spin.settings.min = element.min
            end
            if element.max then
                tmp_spin.settings.max = element.max
            end
            if element.step then
                tmp_spin.settings.step = element.step
            end
            if element.shiftStep then
                tmp_spin.settings.shiftStep = element.shiftStep
            end

            tmp_spin:ApplySettings()
            if tmp_spin.SetStylesheet then
                tmp_spin:SetStylesheet(spinnerStyleSheet)
            end

            tmp_spin:SetEventListener('OnValueChanged', function(this, event, userInput, number)
                if not userInput then
                    return
                end
                light.settings.store(table.key .. '_' .. element.key, tonumber(number))
            end)

            local tmp_text = DiesalGUI:Create("FontString")
            tmp_text:SetParent(parent.content)
            parent:AddChild(tmp_text)
            tmp_text = tmp_text.fontString
            tmp_text:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset - 4)
            tmp_text:SetText(element.text)
            tmp_text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 10, "")
            tmp_text:SetJustifyH('LEFT')
            tmp_text:SetWidth(parent.content:GetWidth() - 10)

            if element.desc then
                local tmp_desc = DiesalGUI:Create("FontString")
                tmp_desc:SetParent(parent.content)
                parent:AddChild(tmp_desc)
                tmp_desc = tmp_desc.fontString
                tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset - 18)
                tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset - 18)
                tmp_desc:SetText(element.desc)
                tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 10, "")
                tmp_desc:SetWidth(parent.content:GetWidth() - 10)
                tmp_desc:SetJustifyH('LEFT')
                push = tmp_desc:GetStringHeight() + 5
            end

            if element.key then
                table.window.elements[element.key .. 'Text'] = tmp_text
                table.window.elements[element.key] = tmp_spin
            end

        elseif element.type == 'checkspin' then

            local tmp_spin = DiesalGUI:Create('Spinner')
            parent:AddChild(tmp_spin)
            tmp_spin:SetParent(parent.content)
            tmp_spin:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)

            if element.width then
                tmp_spin.settings.width = element.width
            end
            if element.min then
                tmp_spin.settings.min = element.min
            end
            if element.max then
                tmp_spin.settings.max = element.max
            end
            if element.step then
                tmp_spin.settings.step = element.step
            end
            if element.shiftStep then
                tmp_spin.settings.shiftStep = element.shiftStep
            end

            tmp_spin:SetNumber(light.settings
                                   .fetch(table.key .. '_' .. element.key .. '.spin', element.default_spin or 0))
            if tmp_spin.SetStylesheet then
                tmp_spin:SetStylesheet(spinnerStyleSheet)
            end
            tmp_spin:ApplySettings()

            tmp_spin:SetEventListener('OnValueChanged', function(this, event, userInput, number)
                if not userInput then
                    return
                end
                light.settings.store(table.key .. '_' .. element.key .. '.spin', tonumber(number))
            end)

            local tmp_check = DiesalGUI:Create('Toggle')
            parent:AddChild(tmp_check)
            tmp_check:SetParent(parent.content)
            tmp_check:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset - 2)

            tmp_check.checkBoxStyle = checkBoxStyle

            tmp_check:SetEventListener('OnValueChanged', function(this, event, checked)
                light.settings.store(table.key .. '_' .. element.key .. '.check', checked)
            end)

            tmp_check:SetChecked(light.settings.fetch(table.key .. '_' .. element.key .. '.check',
                element.default_check or false))
            tmp_check:SetText(element.text)

            if element.desc then
                local tmp_desc = DiesalGUI:Create("FontString")
                tmp_desc:SetParent(parent.content)
                parent:AddChild(tmp_desc)
                tmp_desc = tmp_desc.fontString
                tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset - 18)
                tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset - 18)
                tmp_desc:SetText(element.desc)
                tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9, "")
                tmp_desc:SetWidth(parent.content:GetWidth() - 10)
                tmp_desc:SetJustifyH('LEFT')
                push = tmp_desc:GetStringHeight() + 5
            end

            if element.key then
                table.window.elements[element.key .. 'Text'] = tmp_text
                table.window.elements[element.key .. 'Check'] = tmp_check
                table.window.elements[element.key .. 'Spin'] = tmp_spin
            end

        elseif element.type == 'combo' or element.type == 'dropdown' then

            local tmp_list = DiesalGUI:Create('Dropdown')
            if element.width then
                tmp_list.settings.width = element.width
            end
            parent:AddChild(tmp_list)
            tmp_list:SetParent(parent.content)
            tmp_list:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
            local orderdKeys = {}
            local list = {}
            for i, value in pairs(element.list) do
                orderdKeys[i] = value.key
                list[value.key] = value.text
            end
            tmp_list:SetList(list, orderdKeys)

            tmp_list:SetEventListener('OnValueChanged', function(this, event, value)
                light.settings.store(table.key .. '_' .. element.key, value)
            end)

            tmp_list:SetValue(light.settings.fetch(table.key .. '_' .. element.key, element.default))

            local tmp_text = DiesalGUI:Create("FontString")
            tmp_text:SetParent(parent.content)
            parent:AddChild(tmp_text)
            tmp_text = tmp_text.fontString
            tmp_text:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset - 3)
            tmp_text:SetText(element.text)
            tmp_text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 10, "")
            tmp_text:SetJustifyH('LEFT')
            tmp_text:SetWidth(parent.content:GetWidth() - 10)

            if element.desc then
                local tmp_desc = DiesalGUI:Create("FontString")
                tmp_desc:SetParent(parent.content)
                parent:AddChild(tmp_desc)
                tmp_desc = tmp_desc.fontString
                tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset - 18)
                tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset - 18)
                tmp_desc:SetText(element.desc)
                tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9, "")
                tmp_desc:SetWidth(parent.content:GetWidth() - 10)
                tmp_desc:SetJustifyH('LEFT')
                push = tmp_desc:GetStringHeight() + 5
            end

            if element.key then
                table.window.elements[element.key .. 'Text'] = tmp_text
                table.window.elements[element.key] = tmp_list
            end

        elseif element.type == 'button' then

            local tmp = DiesalGUI:Create("Button")
            element.height = element.height or 20
            parent:AddChild(tmp)
            tmp:SetParent(parent.content)
            tmp:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5 + (element.offset_y and element.offset_y or 0), offset)
            tmp:SetText(element.text)
            tmp:SetWidth(element.width or parent:GetWidth() - 10)
            tmp:SetHeight(element.height or 20)
            tmp.buttonStyleSheetGreen = buttonStyleSheetGreen
            tmp.buttonStyleSheetRed = buttonStyleSheetRed
            tmp.buttonStyleSheetOrange = buttonStyleSheetOrange
            if tmp.SetStylesheet then
                tmp:SetStylesheet(buttonStyleSheet)
            end

            if element.call then
                element.callback(tmp, 'OnStyle')
            end
            tmp:SetEventListener("OnClick", element.callback)

            if element.desc then
                local tmp_desc = DiesalGUI:Create("FontString")
                tmp_desc:SetParent(parent.content)
                parent:AddChild(tmp_desc)
                tmp_desc = tmp_desc.fontString
                tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset - element.height - 3)
                tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset - element.height - 3)
                tmp_desc:SetText(element.desc)
                tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9, "")
                tmp_desc:SetWidth(parent.content:GetWidth() - 10)
                tmp_desc:SetJustifyH('LEFT')
                push = tmp_desc:GetStringHeight() + 5
            end

            if element.align then
                tmp:SetJustifyH(strupper(element.align))
            end

            if element.key then
                table.window.elements[element.key] = tmp
            end

        elseif element.type == "input" then

            local tmp_input = DiesalGUI:Create('Input')
            parent:AddChild(tmp_input)
            tmp_input:SetParent(parent.content)
            tmp_input:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)

            if element.width then
                tmp_input:SetWidth(element.width)
            end

            tmp_input:SetText(light.settings.fetch(table.key .. '_' .. element.key, element.default or ''))

            tmp_input:SetEventListener('OnEditFocusLost', function(this)
                light.settings.store(table.key .. '_' .. element.key, this:GetText())
            end)

            local tmp_text = DiesalGUI:Create("FontString")
            tmp_text:SetParent(parent.content)
            parent:AddChild(tmp_text)
            tmp_text = tmp_text.fontString
            tmp_text:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset - 3)
            tmp_text:SetText(element.text)
            tmp_text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 10, "")
            tmp_text:SetJustifyH('LEFT')

            if element.desc then
                local tmp_desc = DiesalGUI:Create("FontString")
                tmp_desc:SetParent(parent.content)
                parent:AddChild(tmp_desc)
                tmp_desc = tmp_desc.fontString
                tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset - 18)
                tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset - 18)
                tmp_desc:SetText(element.desc)
                tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9, "")
                tmp_desc:SetWidth(parent.content:GetWidth() - 10)
                tmp_desc:SetJustifyH('LEFT')
                push = tmp_desc:GetStringHeight() + 5
            end

            if element.key then
                table.window.elements[element.key .. 'Text'] = tmp_text
                table.window.elements[element.key] = tmp_input
            end

        elseif element.type == 'spacer' then
            -- NOTHING!
        end

        if element.type == 'rule' then
            offset = offset + -10
        elseif element.type == 'spinner' or element.type == 'checkspin' then
            offset = offset + -19
        elseif element.type == 'combo' or element.type == 'dropdown' then
            offset = offset + -20
        elseif element.type == 'texture' then
            offset = offset + -(element.offset or 0)
        elseif element.type == "text" then
            offset = offset + -(element.offset) - (element.size or 10)
        elseif element.type == 'button' then
            offset = offset + -20
        elseif element.type == 'spacer' then
            offset = offset + -(element.size or 10)
        else
            offset = offset + -16
        end

        if element.push then
            push = push + element.push
        end
        if element.pull then
            pull = pull + element.pull
        end

        offset = offset + -(push)
        offset = offset + pull

    end

end

function builder.buildGUI(template)
    local parent = DiesalGUI:Create('Window')
    parent:SetStylesheet(WindowStylesheet)
    parent:SetWidth(template.width or 200)
    parent:SetHeight(template.height or 300)

    if not template.key_orig then
        template.key_orig = template.key
    end

    if template.profiles == true and template.key_orig then
        parent.settings.footer = true

        local createButton = DiesalGUI:Create('Button')
        parent:AddChild(createButton)
        createButton:SetParent(parent.footer)
        createButton:SetPoint('TOPLEFT', 17, -1)
        createButton:SetSettings({
            width = 20,
            height = 20
        }, true)
        createButton:SetText('+')
        createButton:SetStylesheet(createButtonStyle)
        createButton:SetEventListener('OnClick', function()

            local newWindow = DiesalGUI:Create('Window')
            parent:AddChild(newWindow)
            newWindow:SetTitle("Create Profile")
            newWindow.settings.width = 200
            newWindow.settings.height = 75
            newWindow.settings.minWidth = newWindow.settings.width
            newWindow.settings.minHeight = newWindow.settings.height
            newWindow.settings.maxWidth = newWindow.settings.width
            newWindow.settings.maxHeight = newWindow.settings.height
            newWindow:ApplySettings()

            local profileInput = DiesalGUI:Create('Input')
            newWindow:AddChild(profileInput)
            profileInput:SetParent(newWindow.content)
            profileInput:SetPoint("TOPLEFT", newWindow.content, "TOPLEFT", 5, -5)
            profileInput:SetPoint("BOTTOMRIGHT", newWindow.content, "TOPRIGHT", -5, -25)
            profileInput:SetText("New Profile Name")

            local profileButton = DiesalGUI:Create('Button')
            newWindow:AddChild(profileButton)
            profileButton:SetParent(newWindow.content)
            profileButton:SetPoint("TOPLEFT", newWindow.content, "TOPLEFT", 5, -30)
            profileButton:SetPoint("BOTTOMRIGHT", newWindow.content, "TOPRIGHT", -5, -50)
            if profileButton.SetStylesheet then
                profileButton:SetStylesheet(buttonStyleSheet)
            end
            profileButton:SetText("Create New Profile")
            profileButton:SetEventListener('OnClick', function()

                local profiles = light.settings.fetch(template.key_orig .. '_' .. 'profiles', {{
                    key = 'default',
                    text = 'Default'
                }})
                local profileName = profileInput:GetText()
                local pkey = string.gsub(profileName, "%s+", "")
                if profileName ~= '' then
                    for _, p in ipairs(profiles) do
                        if p.key == pkey then
                            profileButton:SetText('|cffff3300Profile with that name exists!|r')
                            C_Timer.NewTicker(2, function()
                                profileButton:SetText("Create New Profile")
                            end, 1)
                            return false
                        end
                    end
                    table.insert(profiles, {
                        key = pkey,
                        text = profileName
                    })
                    light.settings.store(template.key_orig .. '_' .. 'profiles', profiles)
                    light.settings.store(template.key_orig .. '_' .. 'profile', pkey)
                    newWindow:Hide()
                    parent:Hide()
                    parent:Release()
                    builder.buildGUI(template)
                end

            end)
            profileInput:SetEventListener("OnEnterPressed", function()

                local profiles = light.settings.fetch(template.key_orig .. '_' .. 'profiles', {{
                    key = 'default',
                    text = 'Default'
                }})
                local profileName = profileInput:GetText()
                local pkey = string.gsub(profileName, "%s+", "")
                if profileName ~= '' then
                    for _, p in ipairs(profiles) do
                        if p.key == pkey then
                            profileButton:SetText('|cffff3300Profile with that name exists!|r')
                            C_Timer.NewTicker(2, function()
                                profileButton:SetText("Create New Profile")
                            end, 1)
                            return false
                        end
                    end
                    table.insert(profiles, {
                        key = pkey,
                        text = profileName
                    })
                    light.settings.store(template.key_orig .. '_' .. 'profiles', profiles)
                    light.settings.store(template.key_orig .. '_' .. 'profile', pkey)
                    newWindow:Hide()
                    parent:Hide()
                    parent:Release()
                    builder.buildGUI(template)
                end

            end)

        end)
        createButton:SetEventListener('OnEnter', function()
            createButton:SetStyle('frame', ButtonOver)
        end)
        createButton:SetEventListener('OnLeave', function()
            createButton:SetStyle('frame', ButtonNormal)
        end)
        createButton.frame:SetScript('OnMouseDown', function()
            createButton:SetStyle('frame', ButtonNormal)
        end)
        createButton.frame:SetScript('OnMouseUp', function()
            createButton:SetStyle('frame', ButtonOver)
        end)

        local deleteButton = DiesalGUI:Create('Button')
        parent:AddChild(deleteButton)
        deleteButton:SetParent(parent.footer)
        deleteButton:SetPoint('TOPLEFT', 0, -1)
        deleteButton:SetSettings({
            width = 20,
            height = 20
        }, true)
        deleteButton:SetText('-')
        deleteButton:SetStylesheet(deleteButtonStyle)
        deleteButton:SetEventListener('OnEnter', function()
            deleteButton:SetStyle('frame', ButtonOver)
        end)
        deleteButton:SetEventListener('OnLeave', function()
            deleteButton:SetStyle('frame', ButtonNormal)
        end)
        deleteButton.frame:SetScript('OnMouseDown', function()
            deleteButton:SetStyle('frame', ButtonNormal)
        end)
        deleteButton.frame:SetScript('OnMouseUp', function()
            deleteButton:SetStyle('frame', ButtonOver)
        end)
        deleteButton:SetEventListener('OnClick', function()
            local selectedProfile = light.settings.fetch(template.key_orig .. '_' .. 'profile', 'Default Profile')
            local profiles = light.settings.fetch(template.key_orig .. '_' .. 'profiles', {{
                key = 'default',
                text = 'Default'
            }})
            if selectedProfile ~= 'default' then
                for i, p in ipairs(profiles) do
                    if p.key == selectedProfile then
                        profiles[i] = nil
                        light.settings.store(template.key_orig .. '_' .. 'profiles', profiles)
                        light.settings.store(template.key_orig .. '_' .. 'profile', 'default')
                        parent:Hide()
                        parent:Release()
                        builder.buildGUI(template)
                    end
                end
            else
                engine.alert.Notify("WaterHack", "Cannot delete default profile!")
            end
        end)

        local profiles = light.settings.fetch(template.key_orig .. '_' .. 'profiles', {{
            key = 'default',
            text = 'Default'
        }})
        local selectedProfile = light.settings.fetch(template.key_orig .. '_' .. 'profile', 'default')
        local profile_dropdown = DiesalGUI:Create('Dropdown')
        parent:AddChild(profile_dropdown)
        profile_dropdown:SetParent(parent.footer)
        profile_dropdown:SetPoint("TOPRIGHT", parent.footer, "TOPRIGHT", 1, 0)
        profile_dropdown:SetPoint("BOTTOMLEFT", parent.footer, "BOTTOMLEFT", 37, -1)

        local orderdKeys = {}
        local list = {}

        for i, value in pairs(profiles) do
            orderdKeys[i] = value.key
            list[value.key] = value.text
        end

        profile_dropdown:SetList(list, orderdKeys)

        -- profile_dropdown:SetEventListener('OnValueChanged', function(this, event, value)
        --   if selectedProfile ~= value then
        --     light.settings.store(template.key_orig .. '_' .. 'profile', value)
        --     parent:Hide()
        --     parent:Release()
        --     builder.buildGUI(template)
        --   end
        -- end)

        profile_dropdown:SetValue(light.settings.fetch(template.key_orig .. '_' .. 'profile', 'Default Profile'))
        -- function whChangedProfile(thisprofile)
        --  profile_dropdown:SetValue(light.settings.fetch(template.key_orig . .. '_' .. '.' .. thisprofile))
        --  if string.lower(list[thisprofile]) ~= string.lower(thisprofile) then
        --    return engine.alert.Notify("WaterHack", "Profile does not exist!")
        --  end
        --    --light.settings.store(template.key_orig .. '_' .. 'profile', thisprofile)
        --  parent:Hide()
        --  parent:Release()
        --  builder.buildGUI(template)
        --  engine.alert.Notify("WaterHack", "Changed profile to: "..thisprofile.."!")
        -- end
        if selectedProfile then
            template.key = template.key_orig .. '.' .. selectedProfile
        end

    else
        light.settings.store(template.key_orig .. '_' .. 'profile', false)
    end

    if template.key_orig then
        parent:SetEventListener('OnDragStop', function(self, event, left, top)
            light.settings.store(template.key_orig .. '_' .. 'window', {left, top})
        end)
        local left, top = unpack(light.settings.fetch(template.key_orig .. '_' .. 'window', {false, false}))
        if left and top then
            parent.settings.left = left
            parent.settings.top = top
            parent:UpdatePosition()
        end
    end

    local window = DiesalGUI:Create('ScrollFrame')
    parent:AddChild(window)
    window:SetParent(parent.content)
    window:SetAllPoints(parent.content)
    window.parent = parent

    if not template.color then
        template.color = light.color
    end
    spinnerStyleSheet['bar-background']['gradient'] = {'VERTICAL', template.color, ShadeColor(template.color, .1)}
    checkBoxStyle['enabled']['color'] = template.color

    if template.title then
        parent:SetTitle("|cff" .. template.color .. template.title .. "|r", template.subtitle)
    end
    if template.width then
        parent:SetWidth(template.width)
    end
    if template.height then
        parent:SetHeight(template.height)
    end
    if template.minWidth then
        parent.settings.minWidth = template.minWidth
    end
    if template.minHeight then
        parent.settings.minHeight = template.minHeight
    end
    if template.maxWidth then
        parent.settings.maxWidth = template.maxWidth
    end
    if template.maxHeight then
        parent.settings.maxHeight = template.maxHeight
    end
    if template.resize == false then
        parent.settings.minHeight = template.height
        parent.settings.minWidth = template.width
        parent.settings.maxHeight = template.height
        parent.settings.maxWidth = template.width
    end

    parent:ApplySettings()

    template.window = window

    window.elements = {}

    buildElements(template, window)

    parent.frame:SetClampedToScreen(true)

    if template.show then
        parent.frame:Show()
    else
        parent.frame:Hide()
    end

    return window
end

light.interface.builder = builder

light.on_ready(function()
    local engine = {
        key = "_engine",
        title = 'DarkEngine',
        subtitle = 'Build ' .. light.version,
        color = '1F8FB5',
        profiles = false,
        width = 250,
        height = 350,
        resize = true,
        show = true,
        template = {{
            type = 'header',
            text = 'Performance'
        }, {
            type = 'rule'
        }, {
            key = 'tickrate',
            type = 'spinner',
            text = 'Tick Rate',
            desc = 'The core ticket rate, in seconds.  Default is 0.1',
            min = 0.01,
            max = 1.00,
            step = 0.05,
            default = 0.1
        }, {
            key = 'gcd',
            type = 'checkbox',
            text = 'GCD Check',
            desc = 'Attempt to pause the rotation during the GCD.',
            default = true
        }, {
            type = 'spacer'
        }, {
            type = 'spacer'
        }, {
            type = 'header',
            text = 'Turbo'
        }, {
            type = 'rule'
        }, {
            key = 'turbo',
            type = 'checkbox',
            text = 'Enable Turbo',
            desc = 'Enables higher performance.',
            default = false
        }, {
            key = 'castclip',
            type = 'spinner',
            text = 'Clip Amount',
            desc = 'The amount of time, in seconds, before attempting the next cast during the GCD.  Default is 0.15',
            min = 0.00,
            max = 1.00,
            step = 0.01,
            default = 0.15
        }, {
            type = 'rule'
        }, {
            key = 'healcd',
            type = 'checkspin',
            text = 'Healing Cooldown (s)',
            default_check = true,
            default_spin = 0.8,
            min = 0.00,
            max = 3.00,
            step = 0.1
        }, {
            key = 'enablelogfile',
            type = 'checkbox',
            text = 'Enable log to file',
            default = false
        }, {
            key = 'logfilename',
            type = 'input',
            text = 'Logfile Name',
            width = 170.0
        }, {
            key = 'secdebug',
            type = 'checkbox',
            text = 'Debug Authentication',
            default = false
        } -- { key = 'enablemagellan', type = 'checkbox', text = 'Enable Magellan', default = true },
        }
    }
    configWindow = builder.buildGUI(engine)
    configWindow.parent:Hide()
    light.econf = configWindow
end)
