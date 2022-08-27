local addon, dank = ...

local inCombat = false

local function opener()
	if target.exists and target.alive and target.enemy then
		-- either throw or attack
		-- TODO: castable check?
		if target.in_range("Throw") then
			cast("Throw")
		--elseif target.in_range("Attack") then
		else
			cast("Attack")
		end
	end
end
setfenv(opener, dank.environment.env)

local function combat()
    -- combat
	if not target.alive or not target.exists or not target.enemy then return end

    if not inCombat
	--and target.in_range("Attack")
	then cast("Attack") end

	-- add Gouge to get 1 combo point and recove energy or interrupt in spell casting?

	-- slice and dice if not already
	if not player.buff("Slice and Dice").any and -player.power.combopoints >= 1 and -player.power.energy > 25 and castable(SB.SliceAndDice) and target.in_range("Slice and Dice") then
		return cast(SB.SliceAndDice, target)
	end

	-- Eviscerate on 3+ while SliceAndDice already on
	if -player.power.combopoints >= 3 and -player.power.energy > 35 and castable(SB.Eviscerate) and target.in_range("Eviscerate") then
		return cast(SB.Eviscerate, target)
	end

	-- sinister strike
	if -player.power.energy > 45 and castable(SB.SinisterStrike) and target.in_range("Sinister Strike") then
        return cast(SB.SinisterStrike, target)
    end

end

local function resting()
    -- resting

	-- opener will attack target (if exists/alive/enemy)
	if opener() then return end
end

dank.rotation.register({
    class = dank.rotation.classes.rogue,
    name = 'rogue',
    label = 'Bundled Rogue',
    combat = combat,
	resting = resting
})


dank.event.register("PLAYER_ENTER_COMBAT",
                          function(...) inCombat = true end)
dank.event.register("PLAYER_LEAVE_COMBAT",
                          function(...) inCombat = false end)
