local addon, light = ...

local function combat()
    if not target.exists or not target.enemy or not target.alive then
        return
    end

    if 
        castable(SB.ShadowWordDeath, target) and
        target.health.percent <= 25
    then
        return cast(SB.ShadowWordDeath, target)
    end

    --print(player.channeling, player.channeling)
    if player.isChanneling then
        --print('channel')
        return
    end

    -- check?
    local mindflay = IsAltKeyDown()
    if mindflay and castable(SB.MindFlay, target) then
        return cast(SB.MindFlay, target)
    end

    
    -- check Archangle for mini burst
    --print('pre arch')
    if player.buff(SB.DarkEvangelism).count >= 5 then
        --print('5')
        --return cast(SB.Archangle)
    end

    -- TODO: check buff?
    --print("arch?", player.buff(SB.DarkArchangle))
    if 
        player.buff(SB.DarkArchangle).up and 
        castable(SB.MindSpike, target)
    then
        if castbale(SB.Mindblast, target) then
            print("mb")
            return cast(SB.Mindblast, target)
        end
        print("MindSpike")
        return cast(SB.MindSpike, target)
    end
    --print("no archangle")
 
    -- shadowfriend
    -- pain
    if toggle("multitarget", false) then
        if 
            not target.debuff(SB.ShadowWordPain).up and 
            castable(SB.ShadowWordPain, target) 
        then
            return cast(SB.ShadowWordPain, target)
        end
    end

    -- Mindflay max 3x or until 1 Shadow Orb and 5x Envagelism
    --[[
    if 
        not player.buff(SB.EmpoweringShadow).up and -- 15 sec after consume orb
        player.buff(SB.ShadowOrb).count < 1 and 
        -- player.buff(SB.Envagelism).count < 5 and  -- NOTE check talent!
        castable(SB.MindFlay, target)
    then
        return cast(SB.MindFlay, target)
    end]]

    if toggle("cooldowns", false) then
        -- plague (instant cast)
        if
            castable(SB.DevouringPlague, target) and
            not target.debuff(SB.DevouringPlague).up
        then
            return cast(SB.DevouringPlague, target)
        end
        -- Vamperic touch
        if
            castable(SB.VampericTouch, target) and
            not target.debuff(SB.VampericTouch).up
        then
            return cast(SB.VampericTouch, target)
        end
    end

    -- mindblast off CD
    if
        castable(SB.Mindblast, target) --and
        --player.buff(SB.ShadowOrb).count >= 1
    then
        return cast(SB.Mindblast, target)
    end


    -- check self heals before doing filler?
    --if 
    --    player.health.percent < 70 and
    --    castable(SB.Renew, player)
    --then
    --    return cast(SB.Renew, player)
    --end

    -- filler mindflay? -- filler
    if castable(SB.MindSpike, target) then
        return cast(SB.MindSpike, target)
    end

end

local function resting()
    -- -- resting
    -- buff: Fortitude, Inner Fire, Vamperic Embrace, Shadow Form
end

light.rotation.register({
    class = light.rotation.classes.priest,
    name = 'shadowpvp',
    label = 'Shadow pvp Priest 85',
    combat = combat,
    resting = resting
})
