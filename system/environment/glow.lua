local addon, dank = ...

local glow = {}
dank.glow = glow

-- find spell in spellbar?

-- Show glow with ActionButton_ShowOverlayGlow(ActionButton2)
-- Hide glow with ActionButton_HideOverlayGlow(ActionButton2)

glow.spellIdActions = {}
glow.spellNameActions = {}
glow.durations = {}

function glow.trigger(spell)
	-- find spell by id/name
	local btnName = glow.spellIdActions[spell]
	if btnName == nil then
		btnName = glow.spellNameActions[spell]
	end

	-- not found?
	if btnName == nil then
		--print("btnName nil", spell)
		return
	end

	local btn = _G[btnName]
	if btn == nil then -- or btnName ~= type("string") then
		--print("btnName nil")
		return
	end

	--print("glow trigger on " .. btnName .. ", " , spell)

	local duration = glow.durations[btnName]
	ActionButton_ShowOverlayGlow(btn)
	C_Timer.After(duration, function(id)
		ActionButton_HideOverlayGlow(btn)
	end)
end

-- TODO: cleanup??

local actionBars = {'Action', 'MultiBarBottomLeft', 'MultiBarBottomRight', 'MultiBarRight', 'MultiBarLeft'}

function glow.updateActionsList()
	local gcdTime = 1500 --GetSpellCooldown(61304); -- GCD

    for _, barName in pairs(actionBars) do
        for i = 1, 12 do
            local button = _G[barName .. 'Button' .. i]
            local slot = ActionButton_GetPagedID(button) or ActionButton_CalculateAction(button) or
                             button:GetAttribute('action') or 0
            if HasAction(slot) then
                local actionName, _
				local actionRank
                local actionType, id = GetActionInfo(slot)
				local castTime = gcdTime
				if actionType == 'macro' then
                    _, _, id = GetMacroSpell(id)
                end
                if actionType == 'item' then
                    actionName = GetItemInfo(id)
                elseif actionType == 'spell' or (actionType == 'macro' and id) then
                    actionName, _, _, castTime = GetSpellInfo(id)
					actionRank = "(" .. GetSpellSubtext(id) .. ")"
					print(string.sub(actionRank, 1, 5))
					if actionRank == "()" or string.sub(actionRank, 1, 5) ~= "(Rank" then
						actionRank = nil
					end
                end
                if actionName then
                    -- print(button:GetName(), actionType, (GetSpellLink(id)), actionName)
                    glow.spellIdActions[id] = button:GetName()
					glow.spellNameActions[actionName .. (actionRank or "")] = button:GetName()
					if castTime < gcdTime then
						castTime = gcdTime
					end
					glow.durations[button:GetName()] = castTime / 1000
                end
            end
        end
    end
end

-- update cache on events
dank.event.register("ACTIONBAR_SLOT_CHANGED", function(...)
    glow.updateActionsList()
end)

-- init cache
glow.updateActionsList()
