local addon, light = ...

local function combat()

	-- HoT healing
	if player.health.percent < 50 and castable(SB.Rejuvenation, player) and not player.buff(SB.Rejuvenation).up then
		return cast(SB.Rejuvenation, player)
	end

    -- Starsurge - RUNE
    if castable(SB.Starsurge, target) then
        return cast(SB.Starsurge, target)
    end

    if castable(SB.Moonfire, target) and not target.debuff(SB.Moonfire).up then
        return cast(SB.Moonfire, target)
    end
	
	if player.health.percent < 25 and castable(SB.Regrowth, player) then
		return cast(SB.Regrowth, player)
	end

    -- Sunfire during burst - RUNE
    if castable(SB.Sunfire, target) and not target.debuff(SB.Sunfire).up then
        return cast(SB.Sunfire, target)
    end

    -- Wrath spam
    if castable(SB.Wrath, target) then
        return cast(SB.Wrath, target)
    end
end

local function resting()
    -- -- resting
	if target.exists and target.alive and target.enemy then
		if castable(SB.Wrath, target) then
			return cast(SB.Wrath, target)
		end
	end
	
	-- always buff
	if not player.buff(SB.MarkOfTheWild).up and castable(SB.MarkOfTheWild, player) then
		return cast(SB.MarkOfTheWild, player)
	end
	if not player.buff(SB.Thorns).up and castable(SB.Thorns, player) then
		return cast(SB.Thorns, player)
	end
	
	-- SKIP, we eat lol?
	-- recovering
	if player.health.percent < 60 and castable(SB.HealingTouch, player) then
		return cast(SB.HealingTouch, player)
	end
end

light.rotation.register({
    class = light.rotation.classes.druid,
    name = 'druid',
    label = 'Bundled Druid',
    combat = combat,
    resting = resting
})