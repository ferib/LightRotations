local addon, light = ...

local function getDistanceBetweenPositions(x, y, z, xx, yy, zz)
    if not xx or not x then return end 
    return sqrt((x - xx) ^ 2 + (y - yy) ^ 2 + (z - zz) ^ 2)
end
local function getFacing(px, py, tx, ty)
	local px2, py2 -- point north of player
	px2 = px + 15
	py2 = py

	if px == nil or tx == nil then
		return -1
	end

	local a = getDistanceBetweenPositions(px2, py2, 0, tx, ty, 0)
	local b = getDistanceBetweenPositions(px, py, 0, tx, ty, 0)
	local c = getDistanceBetweenPositions(px, py, 0, px2, py2, 0)
	local numerator = (b ^ 2) + (c ^ 2) - (a ^ 2)

	if a == nil or b == nil or c == nil then
		return -1
	end

	local denominator = 2 * b * c
	if denominator == 0 then
		return 
	end
	local angle = math.acos(numerator / denominator)
	if ty < py then
		angle = 2 * math.pi - angle
	end
	return angle
end

local lastUpdate = GetTime()

local function updateFacingTarget()
    local tick = GetTime()
    if lastUpdate + 0.5 > tick then
        return
    end
    local px, py, _ = ObjectPosition("player")
    local tx, ty, _ = ObjectPosition("target")
    if px ~= nil and tx ~= nil then
        lastUpdate = tick
        local f = getFacing(px, py, tx, ty)
        SetPlayerFacing(f)
    end
end

local function autoTarget()
    if not Objects or not GetFocus then return end
    local os = Objects()
    local old = GetFocus()
    for i=1, #os do
        local o = os[i]
        if ObjectType(o) == 5 then
            SetFocus(o)
            if focus.alive and focus.enemy and focus.exists and CheckInteractDistance("focus", 1)  then
                Unlock(TargetUnit, "focus")
                --print('setting focus', focus.name)
                SetFocus(old)
                updateFacingTarget()
                return
            end
        end

    end
    SetFocus(old)
end
setfenv(autoTarget, light.environment.env)

-- Auto Queue Dungeon



local function combat()
    if not target.exists or not target.enemy or not target.alive then
        if toggle("multitarget", false) then
            autoTarget()
        end
        return
    end

    updateFacingTarget()

    if toggle("multitarget", false) then
        -- check if target still in range, otherwise close
        if not CheckInteractDistance("target", 1) then
            Unlock(ClearTarget)
        end
    end

    -- instant cast Incinerate
    if player.buff(SB.Backlash).up and castable(SB.Incinerate, target) then
        return cast(SB.Incinerate, target)
    end

    if castable(SB.Conflagrate, target) and not player.buff(SB.Backdraft).up then
        return cast(SB.Conflagrate, target)
    end

    if castable(SB.Immolate, target) and not target.debuff(SB.Immolate).up then
        return cast(SB.Immolate, target)
    end

    -- check for a Choas Bolt?

    if castable(SB.Incinerate, target) then
        return cast(SB.Incinerate, target)
    end

end

local function resting()
    if not target.exists or not target.enemy or not target.alive then
        if toggle("multitarget", false) then
            autoTarget()
        end
        return
    end

    if toggle("multitarget", false) then
        -- check if target still in range, otherwise close
        if not CheckInteractDistance("target", 1) then
            Unlock(ClearTarget)
        end
    end

    if castable(SB.Immolate, target) and not target.debuff(SB.Immolate).up then
        return cast(SB.Immolate, target)
    elseif castable(SB.Incinerate, target) then
        return cast(SB.Incinerate, target)
    end
end

light.rotation.register({
    class = light.rotation.classes.warlock,
    name = 'dlock',
    label = 'Destruction Warlock',
    combat = combat,
    resting = resting
})
