local addon, light = ...

local function combat()
    if not target.exists or not target.enemy or not target.alive then
        return
    end

    --print(player.channeling, player.channeling)
    if player.isChanneling then
        return
    end

    -- open with mindspike

    -- shadowfriend
    -- pain
    if 
        not target.debuff(SB.ShadowWordPain).up and 
        castable(SB.ShadowWordPain, target) 
    then
        return cast(SB.ShadowWordPain, target)
    end

    -- Mindflay max 3x or until 1 Shadow Orb and 5x Envagelism
    if 
        not player.buff(SB.EmpoweringShadow).up and -- 15 sec after consume orb
        player.buff(SB.ShadowOrb).count < 1 and 
        -- player.buff(SB.Envagelism).count < 5 and  -- NOTE check talent!
        castable(SB.MindFlay, target)
    then
        return cast(SB.MindFlay, target)
    end

    -- mindblast if buff
    if
        castable(SB.Mindblast, target) and
        player.buff(SB.ShadowOrb).count >= 1
    then
        return cast(SB.Mindblast, target)
    end

    -- Vamperic touch
    if
        castable(SB.VampericTouch, target) and
        not target.debuff(SB.VampericTouch).up
    then
        return cast(SB.VampericTouch, target)
    end

    -- plague
    if
        castable(SB.DevouringPlague, target) and
        not target.debuff(SB.DevouringPlague).up
    then
        return cast(SB.DevouringPlague, target)
    end


    -- filler mindflay?
    if castable(SB.MindFlay, target) then
        return cast(SB.MindFlay, target)
    end

end

local function resting()
    -- -- resting
    -- buff: Fortitude, Inner Fire, Vamperic Embrace, Shadow Form
end

light.rotation.register({
    class = light.rotation.classes.priest,
    name = 'shadow',
    label = 'Bundled Priest',
    combat = combat,
    resting = resting
})
