-- $Id: Toggle.lua 60 2018-09-22 08:28:01Z DarkRotations $

local DiesalGUI = LibStub("DiesalGUI-1.0")
-- ~~| Libraries |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local DiesalTools = LibStub("DiesalTools-1.0")
local DiesalStyle = LibStub("DiesalStyle-1.0")
-- ~~| Diesal Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local Colors = DiesalStyle.Colors
local HSL, ShadeColor, TintColor = DiesalTools.HSL, DiesalTools.ShadeColor, DiesalTools.TintColor
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local type, tonumber, select                      = type, tonumber, select
local pairs, ipairs, next                       = pairs, ipairs, next
local min, max                                = math.min, math.max
-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local CreateFrame, UIParent, GetCursorPosition          = CreateFrame, UIParent, GetCursorPosition
local GetScreenWidth, GetScreenHeight               = GetScreenWidth, GetScreenHeight
local GetSpellInfo, GetBonusBarOffset, GetDodgeChance     = GetSpellInfo, GetBonusBarOffset, GetDodgeChance
local GetPrimaryTalentTree, GetCombatRatingBonus        = GetPrimaryTalentTree, GetCombatRatingBonus
-- ~~| Button |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local TYPE    = "Toggle"
local VERSION   = 1
-- ~~| Button Stylesheets |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local Stylesheet = {
  ['frame-background'] = {
    type      = 'texture',
    layer     = 'BACKGROUND',
    color     = '333333',
    alpha     = .95,
    position  = -2
  },
  ['frame-inline'] = {
    type = 'outline',
    layer = 'BORDER',
    color = '000000',
    alpha = .6,
    position  = -2
  },
  ['frame-outline'] = {
    type      = 'outline',
    layer     = 'BORDER',
    color     = 'FFFFFF',
    alpha     = .1,
    position  = -1,
  },
}
local checkBoxStyle = {
  base = {
    type      = 'texture',
    layer     = 'ARTWORK',
    color     = '00FF00',
    position  = -3,
  },
  disabled = {
    type      = 'texture',
    color     = '00FFFF',
  },
  enabled = {
    type      = 'texture',
    color     = Colors.UI_A400,
  },
}

local wireFrame = {
  ['frame-white'] = {
    type      = 'outline',
    layer     = 'OVERLAY',
    color     = 'ffffff',
  },
}
-- ~~| Button Methods |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local methods = {
  ['OnAcquire'] = function(self)
    self:ApplySettings()
    self:SetStylesheet(Stylesheet)
    self:Enable()
    -- self:SetStylesheet(wireFrameSheet)
    self.fontString:SetFontObject("DiesalFontNormal")
    self.fontString:SetText()
    self:Show()
  end,
  ['OnRelease'] = function(self)  end,
  ['ApplySettings'] = function(self)
    local settings  = self.settings
    local frame     = self.frame

    self:SetWidth(settings.width)
    self:SetHeight(settings.height)
  end,
  ["SetChecked"] = function(self,value)
    self.settings.checked = value
    self.frame:SetChecked(value)

    self[self.settings.disabled and "Disable" or "Enable"](self)
  end,
  ["GetChecked"] = function(self)
    return self.settings.checked
  end,
  ["Disable"] = function(self)
    self.settings.disabled = true
    DiesalStyle:StyleTexture(self.check,self.checkBoxStyle and self.checkBoxStyle.disabled or checkBoxStyle.disabled)
    self.frame:Disable()
  end,
  ["Enable"] = function(self)
    self.settings.disabled = false
    DiesalStyle:StyleTexture(self.check,self.checkBoxStyle and self.checkBoxStyle.enabled or checkBoxStyle.enabled)
    self.frame:Enable()
  end,
  ["RegisterForClicks"] = function(self,...)
    self.frame:RegisterForClicks(...)
  end,
  ["SetText"] = function(self, text)
    self.fontString:SetText(text)
    self.frame:SetHitRectInsets(0,-self.fontString:GetWidth(),0,0)
  end,
}
-- ~~| Button Constructor |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local function Constructor()
  local self    = DiesalGUI:CreateObjectBase(TYPE)
  local frame   = CreateFrame('CheckButton', nil, UIParent)
  local fontString = frame:CreateFontString()
  self.frame    = frame
  self.fontString  = fontString

  local c,a = 0.5,0.5
  local tex = frame:CreateTexture(nil, "BACKGROUND")
  tex:SetAllPoints()
  tex:SetColorTexture(0, 0, 0, 0)

  -- ~~ Default Settings ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  self.defaults = {
    height    = 11,
    width     = 11,
  }
  -- ~~ Events ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- OnAcquire, OnRelease, OnHeightSet, OnWidthSet
  -- OnValueChanged, OnEnter, OnLeave, OnDisable, OnEnable
  -- ~~ Construct ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  local check = self:CreateRegion("Texture", 'check', frame)
  self.check = check

  DiesalStyle:StyleTexture(check,self.checkBoxStyle and self.checkBoxStyle.base or checkBoxStyle.base)
  frame:SetCheckedTexture(check)
  frame:SetScript('OnClick', function(this,button,...)
    DiesalGUI:OnMouse(this,button)

    if not self.settings.disabled then
      self:SetChecked(not self.settings.checked)

      if self.settings.checked then
        ----PlaySound("igMainMenuOptionCheckBoxOn")
      else
        ----PlaySound("igMainMenuOptionCheckBoxOff")
      end

      self:FireEvent("OnValueChanged", self.settings.checked)
    end
  end)
  frame:SetScript('OnEnter', function(this)
    self:FireEvent("OnEnter")
    tex:SetColorTexture(c, c, c, a)
    -- SetCursor([[Interface\Cursor\Cast]])
  end)
  frame:SetScript('OnLeave', function(this)
    self:FireEvent("OnLeave")
    tex:SetColorTexture(0, 0, 0, 0)
    -- SetCursor(nil)
  end)
  frame:SetScript("OnDisable", function(this)
    self:FireEvent("OnDisable")
  end)
  frame:SetScript("OnEnable", function(this)
    self:FireEvent("OnEnable")
  end)

  fontString:SetPoint("TOPLEFT", check, "TOPRIGHT", 5, 2)

  -- ~~ Methods ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  for method, func in pairs(methods) do self[method] = func end
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return self
end

DiesalGUI:RegisterObjectConstructor(TYPE,Constructor,VERSION)
