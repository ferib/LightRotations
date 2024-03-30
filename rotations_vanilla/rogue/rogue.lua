local addon, light = ...

local inCombat = false

local inOpener = false

local function opener()
	if player.alive and target.exists and target.alive and target.enemy then
		-- either throw or attack
		-- TODO: castable check?
		--[[
		if target.in_range("Throw") then
			cast("Throw")
			return cast("Attack")
		--elseif target.in_range("Attack") then
		else ]]--
		
		--if target.in_range("Sinister Strike") then -- melee range check
		--	return cast("Attack")
		--end

		--if target.in_range("Sinister Strike", target) and castable(SB.Ambush, target) then
		--	return cast(SB.Ambush, target)
		--end
		if target.in_range("Sinister Strike", target) and castable(SB.CheapShot, target) then
			inOpener = true
			return cast(SB.CheapShot, target)
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
	--if not target.in_range("Sinister Strike") and target.in_range("Throw") and castable("Throw") then
	--	cast("Throw")
	--end

	-- add Gouge to get 1 combo point and recove energy or interrupt in spell casting?

	-- slice and dice if not already 
	-- NOTE: Nopem never in PvP
	--[[
	if not player.buff("Slice and Dice").any and -player.power.combopoints >= 1 and -player.power.energy > 25 and castable(SB.SliceAndDice, target) and target.in_range("Slice and Dice") then
		return cast(SB.SliceAndDice, target)
	end
	]]--

	-- expose Armor
	--if not target.debuff("Expose Armor") and -player.power.energy > 25 and -player.power.combopoints >= 1 and castable(SB.ExposeArmor, target) then
	--	return cast(SB.ExposeArmor, target)
	--end

	-- KidneyShot if in opener?
	--print(inOpener)

	if toggle("snd", false) then
		if not player.buff(SB.SliceAndDice).up and -player.power.combopoints >= 1 
		and -player.power.energy >= 25 and castable(SB.SliceAndDice, target) then
			return cast(SB.SliceAndDice, target)
		end
	else
		if inOpener and not target.debuff("Cheap Shot").up 
		and -player.power.combopoints >= 1 and -player.power.energy >= 25 and castable(SB.KidneyShot, target) then
			inOpener = false
			print("Kidney Shot at " .. tostring( -player.power.combopoints) .. " seconds!")
			return cast(SB.KidneyShot, target)
		end
	end

	if inOpener and -player.power.energy < 50 then
		--print("reserver energy " .. tostring(-player.power.energy) .. " for after opener!")
		-- save some energy to ensure kidney ontime
		return --cast(SB.Attack, target)
	end

	-- fuck it just spam envenom 1cp+
	if toggle("envenom", false) then
		if not player.buff(SB.Envenom).up and -player.power.combopoints >= 4 
		and -player.power.energy >= 35 then

			if toggle("cooldowns", false) then
				cast(SB.ColdBlood)
			end

			cast(SB.Envenom, target)

			-- in case target immune?
			return cast(SB.Eviscerate, target)
		end
	else

		-- Eviscerate on 4+ while SliceAndDice already on
		-- OR 2+ combo points if target low health?
		if (-player.power.combopoints >= 4 or (target.health.actual < 300 and -player.power.combopoints >= 2))
			and -player.power.energy > 40 and castable(SB.Eviscerate, target) and target.in_range("Eviscerate") then
			inOpener = false

			if toggle("cooldowns", false) then
				cast(SB.ColdBlood)
			end

			return cast(SB.Eviscerate, target)
		end
	end
	
	-- Mutilate
	--if -player.power.energy >= 40 and castable(SB.Mutilate, target)
	if -player.power.energy >= 40 and castable(SB.SinisterStrike, target) then
		if inOpener then
			print("Mutilate at " .. tostring(-player.power.energy))
		end
		return cast(SB.Mutilate, target)
	end

	-- 424785
	--print(target.debuff(SB.SaberSlash).up )

	-- NOTE: only keep this up for PvE long fights?

	if -player.power.energy >= 40 and castable(SB.SaberSlash, target)
		and (not target.debuff(SB.SaberSlash).up 
			or target.debuff(SB.SaberSlash).count < 3
			or (target.debuff(SB.SaberSlash).count == 3 and target.debuff(SB.SaberSlash).remains <= 3.25))
	then
		return cast(SB.SaberSlash, target)
	end


	-- sinister strike, NEVER?
	--[[
	if -player.power.energy > 45 and castable(SB.SinisterStrike, target) and target.in_range("Sinister Strike") then
        return cast(SB.SinisterStrike, target)
    end
	]]--

end

local function resting()
    -- resting

	-- opener will attack target (if exists/alive/enemy)
	if opener() then return end
end


local function interface()
    light.interface.buttons.add_toggle(
        {
            name = "envenom",
            label = "Envenom",
            font = "dark_icon",
            on = {
                label = light.interface.icon("flask"),
                color = light.interface.color.green,
                color2 = light.interface.color.dark_green,
            },
            off = {
                label = light.interface.icon("flask"),
                color = light.color,
                color2 = light.color2
            }
        }
    )
	light.interface.buttons.add_toggle(
        {
            name = "snd",
            label = "Slice & Dice",
            font = "dark_icon",
            on = {
                label = light.interface.icon("utensils"),
                color = light.interface.color.yellow,
                color2 = light.interface.color.dark_yellow,
            },
            off = {
                label = light.interface.icon("utensils"),
                color = light.color,
                color2 = light.color2
            }
        }
    )
end

light.rotation.register({
    class = light.rotation.classes.rogue,
    name = 'rogue',
    label = 'Bundled Rogue',
    combat = combat,
	resting = resting,
    interface = interface
})


light.event.register("PLAYER_ENTER_COMBAT",
                          function(...) inCombat = true end)
light.event.register("PLAYER_LEAVE_COMBAT",
                          function(...) inCombat = false end)
