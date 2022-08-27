local light = _G['light_interface']

hooksecurefunc("_CastSpellByName", function(spell, target)
    local target = target or "target"
    if light.adv_protected then
        Nn.Unlock("CastSpellByName", spell, target)
    elseif light.protected then
        dr_secured = false
        for i = 1, 420 do RunScript([[if not issecure() then return end CastSpellByName("]] .. spell .. [[", "]] .. target .. [[") dr_secured = true ]]) end
        dr_secured = nil
    end
end)

hooksecurefunc("_CastGroundSpellByName", function(spell, target)
    local target = target or "target"
    if light.adv_protected then
        Nn.Unlock("RunMacroText", "/cast [@cursor] " .. spell)
    elseif light.protected then
        dr_secured = false
        for i = 1, 420 do RunScript([[if not issecure() then return end RunMacroText("/cast [@cursor] ]] .. spell .. [[") dr_secured = true ]]) end
        dr_secured = nil
    end
end)

hooksecurefunc("_SpellStopCasting", function()
    if light.adv_protected then
        Nn.Unlock("SpellStopCasting")
    elseif light.protected then
        dr_secured = false
        for i = 1, 420 do RunScript([[if not issecure() then return end SpellStopCasting() dr_secured = true]]) end
        dr_secured = nil
    end
end)

hooksecurefunc("_RunMacroText", function(text)
    if light.adv_protected then
        Nn.Unlock("RunMacroText", text)
	elseif light.protected then
		dr_secured = false
		for i = 1, 420 do RunScript([[if not issecure() then return end RunMacroText("]] .. text .. [[") dr_secured = true]]) end
		dr_secured = nil
	end
end)

-- check for unlocked?
local timer
timer = C_Timer.NewTicker(0.5, function()
	if Nn ~= nil then
		light.log('NoName Detected! Enhanced functionality enabled!')
		light.adv_protected = true
		light.protected = true
		--Unlock = true
		timer:Cancel()
	elseif is_unlocked() then
		light.log('Enhanced functionality enabled!')
		light.protected = true
		light.adv_protected = false
		timer:Cancel()
	end
end)
