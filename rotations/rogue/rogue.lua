local addon, dank = ...

local function combat()
    -- combat

	if not player.alive then return end
    if not target.alive or not target.exists then return end

    if not InCombat then cast("Attack") end

    if player.power.energy() > 45 and castable(SB.SinisterStrike) and target.in_range("Sinister Strike") then
        cast(SB.SinisterStrike, target)
        return cast(SB.SinisterStrike) -- pet attack taunt
    end

end

local function resting()
    -- resting
end

dank.rotation.register({
    class = dank.rotation.classes.rogue,
    name = 'rogue',
    label = 'Bundled Rogue',
    combat = combat,
    resting = resting
})
