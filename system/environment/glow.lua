local addon, light = ...

local glow = {}
light.glow = glow

-- find spell in spellbar?

-- Show glow with ActionButton_ShowOverlayGlow(ActionButton2)
-- Hide glow with ActionButton_HideOverlayGlow(ActionButton2)

glow.spellIdActions = {}
glow.spellNameActions = {}
glow.durations = {}

function glow.trigger(spell)
	--print("Glowing" .. spell)
	--[[
	-- check if Retail, then we can simplify things!
	if C_ActionBar ~= nil and C_ActionBar.FindSpellActionButtons ~= nil then
		local gcdTime = 1500 --GetSpellCooldown(61304); -- GCD
		
		local slots = C_ActionBar.FindSpellActionButtons(spell)
		print(slots)
		if slots ~= nil then
			actionName, _, _, castTime = GetSpellInfo(spell)
			ActionButton_ShowOverlayGlow(slots)
		else
			print("Glow?" .. spell)
		end
		return
	end]]

	-- find spell by id/name
	local btnName = glow.spellIdActions[spell]
	if btnName == nil then
		btnName = glow.spellNameActions[spell]
	end

	-- not found?
	if btnName == nil then
		local spellinfo = GetSpellInfo(spell)
		--print("btnName nil", spell)
		print("No keybind was found for ", spellinfo)
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
	CastSpellByName(spell)

	-- TODO: rm C_Timer and use clean queue?
	C_Timer.After(duration, function(id)
		ActionButton_HideOverlayGlow(btn)
	end)
end

-- TODO: cleanup??

local actionBars = {'Action', 'MultiBarBottomLeft', 'MultiBarBottomRight', 'MultiBarRight', 'MultiBarLeft'}

function glow.updateActionsList()
	local gcdTime = 1500 --GetSpellCooldown(61304); -- GCD


	if _G.CastingInfo == nil then -- hacky check to see if Retail, TODO add something better?
		-- TODO: This did not work?
		-- C_ActionBar.FindSpellActionButtons
		local actionBars =    {'Action', 'MultiBarBottomLeft', 'MultiBarBottomRight', 'MultiBarRight', 'MultiBarLeft', 'MultiBar5', 'MultiBar6', 'MultiBar7'}
		local actionNumbers = {1       , 61                  , 49                   , 76             , 37            , 145        , 157        , 169 }
		for k=1, #actionBars do
			barName = actionBars[k]
			local base = actionNumbers[k]
			for i = base, base+11 do
				local actionType, id, subtype = GetActionInfo(i)
				if actionType ~= nil then
					local actionName, _
					local actionRank

					local castTime = gcdTime
					if actionType == 'macro' then
						_, _, id = GetMacroSpell(id)
					end
					if actionType == 'item' then
						actionName = GetItemInfo(id)
					elseif actionType == 'spell' or (actionType == 'macro' and id) then
						actionName, _, _, castTime = GetSpellInfo(id)
					end

					local buttonName = barName .. "Button" .. (i-(base-1));
					local button = _G[buttonName];
					if actionName then
						--print(actionName, buttonName, button)
						--print(buttonName, button:GetName(), actionType, (GetSpellLink(id)), id, actionName)
						glow.spellIdActions[id] = buttonName
						glow.spellNameActions[actionName .. (actionRank or "")] = buttonName
						if castTime < gcdTime then
							castTime = gcdTime
						end
					glow.durations[buttonName] = castTime / 1000
					end
				end
			end
		end

	else
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
						local rank = GetSpellSubtext(id) or ""
						actionRank = "(" .. rank .. ")"
						--print(string.sub(actionRank, 1, 5))
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
end

-- update cache on events
light.event.register("ACTIONBAR_SLOT_CHANGED", function(...)
    glow.updateActionsList()
end)

-- init cache
glow.updateActionsList()
