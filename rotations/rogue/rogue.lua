local addon, light = ...

local inCombat = false

local function opener()
	if player.alive and target.exists and target.alive and target.enemy then
		-- either throw or attack
		-- TODO: castable check?
		if target.in_range("Throw") then
			cast("Throw")
			return cast("Attack")
		--elseif target.in_range("Attack") then
		elseif target.in_range("Sinister Strike") then -- melee range check
			return cast("Attack")
		end
	end
end
setfenv(opener, light.environment.env)

local function combat()
    -- combat
	if not target.alive or not target.exists or not target.enemy then return end

    if not inCombat
	--and target.in_range("Attack")
	then cast("Attack") end

	if toggle("interrupts", false) then
		--if target.casting
		-- 	
		-- "Shadow Crash"
		-- "Shadowy Chains"
		if target.casting then
			print(target.cast)
			if castable(SB.Kick, target) then
				return cast(SB.Kick, target)
			end
		end
	end

	-- check for evasion CD
	if toggle("cooldowns", false) then
		if -player.health.percent < 33 and castable(SB.Evasion) then
			return cast(SB.Evasion)
		end
	end


	-- check if not in range
	if not target.in_range("Sinister Strike") and target.in_range("Throw") and castable("Throw") then
		cast("Throw")
	end

	-- add Gouge to get 1 combo point and recove energy or interrupt in spell casting?

	-- slice and dice if not already
	if not player.buff("Slice and Dice").any and -player.power.combopoints >= 1 and -player.power.energy > 25 and castable(SB.SliceAndDice, target) and target.in_range("Slice and Dice") then
		return cast(SB.SliceAndDice, target)
	end

	-- expose Armor
	--if not target.debuff("Expose Armor") and -player.power.energy > 25 and -player.power.combopoints >= 1 and castable(SB.ExposeArmor, target) then
	--	return cast(SB.ExposeArmor, target)
	--end

	-- Eviscerate on 4+ while SliceAndDice already on
	if -player.power.combopoints >= 4 and -player.power.energy > 40 and castable(SB.Eviscerate, target) and target.in_range("Eviscerate") then
		return cast(SB.Eviscerate, target)
	end
	
	-- 424785
	--print(target.debuff(SB.SaberSlash).up )
	if -player.power.energy > 40 and castable(SB.SinisterStrike, target)
		and (not target.debuff(SB.SaberSlash).up 
			or target.debuff(SB.SaberSlash).count < 3
			or (target.debuff(SB.SaberSlash).count == 3 and target.debuff(SB.SaberSlash).remains <= 3.25))
	then
		return cast(SB.SaberSlash, target)
	end

	-- sinister strike
	if -player.power.energy > 45 and castable(SB.SinisterStrike, target) and target.in_range("Sinister Strike") then
        return cast(SB.SinisterStrike, target)
    end

end

local function resting()
    -- resting

	-- opener will attack target (if exists/alive/enemy)
	if opener() then return end
end

light.rotation.register({
    class = light.rotation.classes.rogue,
    name = 'rogue',
    label = 'Bundled Rogue',
    combat = combat,
	resting = resting
})


light.event.register("PLAYER_ENTER_COMBAT",
                          function(...) inCombat = true end)
light.event.register("PLAYER_LEAVE_COMBAT",
                          function(...) inCombat = false end)
