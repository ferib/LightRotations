local addon, light = ...

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
                return
            end
        end

    end
    SetFocus(old)
end
setfenv(autoTarget, light.environment.env)

local function combat()
    if not target.exists or not target.enemy or not target.alive then
        if toggle("multitarget", false) then
            autoTarget()
        end
        return
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
