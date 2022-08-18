local addon, dank = ...

local function hide_block(...)
    StaticPopup1:Hide()
end

function StaticPopup_OnShow(self)
    if self.which ~= 'MACRO_ACTION_FORBIDDEN' and self.which ~= 'ADDON_ACTION_FORBIDDEN' and self.which ~=
        'ADDON_ACTION_BLOCKED' then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
    end

    local dialog = StaticPopupDialogs[self.which];
    local OnShow = dialog.OnShow;

    if (OnShow) then
        OnShow(self, self.data);
    end
    if (dialog.hasMoneyInputFrame) then
        _G[self:GetName() .. "MoneyInputFrameGold"]:SetFocus();
    end
    if (dialog.enterClicksFirstButton) then
        self:SetScript("OnKeyDown", StaticPopup_OnKeyDown);
    end
end

function StaticPopup_OnHide(self)
    if self.which ~= 'MACRO_ACTION_FORBIDDEN' and self.which ~= 'ADDON_ACTION_FORBIDDEN' and self.which ~=
        'ADDON_ACTION_BLOCKED' then
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
    end

    StaticPopup_CollapseTable();

    local dialog = StaticPopupDialogs[self.which];
    local OnHide = dialog.OnHide;
    if (OnHide) then
        OnHide(self, self.data);
    end
    self.extraFrame:Hide();
    if (dialog.enterClicksFirstButton) then
        self:SetScript("OnKeyDown", nil);
    end
    if (self.insertedFrame) then
        self.insertedFrame:Hide();
        self.insertedFrame:SetParent(nil);
        local text = _G[self:GetName() .. "Text"];
        _G[self:GetName() .. "MoneyFrame"]:SetPoint("TOP", text, "BOTTOM", 0, -5);
        _G[self:GetName() .. "MoneyInputFrame"]:SetPoint("TOP", text, "BOTTOM", 0, -5);
    end
end

function C_Timer.NewAdvancedTicker(duration, callback, iterations)
    local ticker = setmetatable({}, TickerMetatable);
    ticker._duration = duration;
    ticker._remainingIterations = iterations;
    ticker._callback = function()
        if (not ticker._cancelled) then
            callback(ticker);

            -- Make sure we weren't cancelled during the callback
            if (not ticker._cancelled) then
                if (ticker._remainingIterations) then
                    ticker._remainingIterations = ticker._remainingIterations - 1;
                end
                if (not ticker._remainingIterations or ticker._remainingIterations > 0) then
                    C_Timer.After(ticker._duration, ticker._callback);
                end
            end
        end
    end;

    C_Timer.After(ticker._duration, ticker._callback);
    return ticker;
end

-- remove taint popup, might happen during the 'unlocking loop' for basic unlockers
--
dank.event.register("MACRO_ACTION_FORBIDDEN", hide_block)
dank.event.register("ADDON_ACTION_FORBIDDEN", hide_block)
dank.event.register("ADDON_ACTION_BLOCKED", hide_block)
