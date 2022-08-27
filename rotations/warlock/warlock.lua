local addon, light = ...

local ConfigWindow
local InCombat = false
local SpellCD = 0.5
local ImpCD = 1
local SummonVoidwalkerCD = 1

local SummonImpCD = 0
local SummonVoidwalkerCD = 0
local ImmolateCD = 0
local CorruptionCD = 0
local CurseOfAgonyCD = 0
local LifeTapCD = 0
local OpenerCD = 0

local LifeTapAmount = 699

local function should_use_darkpact()
    if not pet.exists then
        return false
    end

    if not castable(SB.DarkPact) then
        return false
    end

    --[[
    local name, _, _, _, _, _, spellid = UnitChannelInfo("player")
    if name ~= nil then
        return false -- channeling, no interrupt!
    end
    ]]--

    --if GetTime() < LifeTapCD  then
    --    return false
    --end

    -- TODO: get player Mana and pet Mana!
    if player.power.mana.percent < 70 and pet.power.mana.percent > 25 then
        return true
    end

    return false
end
setfenv(should_use_darkpact, light.environment.env)

local function should_use_lifetap()
    local lifetap = light.settings.fetch("warlock_lifetap", true)
    local lifetapminhealth = light.settings.fetch(
                                 "warlock_lifetapminhealth", 50)
    local lifetapstayhealthy = light.settings.fetch(
                                   "warlock_lifetapstayhealthy", true)
    local lifetapdebug = light.settings
                             .fetch("warlock_lifetapdebug", false)

    if not castable(SB.LifeTap) then
        return false
    end

    local name, _, _, _, _, _, spellid = UnitChannelInfo("player")
    if name ~= nil then
        return false -- channeling, no interrupt!
    end

    if not lifetap then
        if lifetapdebug then print('should_use_lifetap(): not enabled') end
        return false
    end
    if GetTime() < LifeTapCD then
        if lifetapdebug then
            print('should_use_lifetap(): still on cooldown')
        end
        return false
    end

    -- prior darkpact on full monion
    if pet.exists and pet.power.mana.percent >= 95 and player.health.percent < 95 and player.power.mana.percent < 95 then
        return false
    end

    local maxh = player.health.max
    local curh = player.health.actual
    if (((curh - LifeTapAmount) / maxh) * 100) < 15 then -- lifetapminhealth then
        if lifetapdebug then
            print(
                'should_use_lifetap(): Don\'t cast because health would be to low')
        end
        return false
    end
    if player.health.percent <= player.power.mana.percent then
        if lifetapdebug then
            print('should_use_lifetap(): health% lower than mana%')
        end
        return false
    end
    if lifetapstayhealthy then
        local maxm = player.power.mana.max
        local curm = player.power.mana.actual
        local future_mana_pct = (curm + LifeTapAmount) / maxm
        local future_health_pct = (curh - LifeTapAmount) / maxh
        if future_health_pct < future_mana_pct then
            if lifetapdebug then
                print(
                    'should_use_lifetap(): would cause health to drop below mana')
            end
            return false
        end
    end
    if lifetapdebug then print('should_use_lifetap(): do it!') end
    return true
end
setfenv(should_use_lifetap, light.environment.env)

local function buffs()
    local demonarmor = light.settings.fetch("warlock_demonskin", true)

    if demonarmor and (player.buff("Demon Armor").down and player.buff("Fel Armor").down) then

        cast(SB.DemonArmor)
        return true
    end

    if should_use_lifetap() then
        LifeTapCD = GetTime() + 1
        return cast(SB.LifeTap)
    --elseif should_use_darkpact() then
    --    LifeTapCD = GetTime() + 1
    --    return cast(SB.DarkPact)
    end
end
setfenv(buffs, light.environment.env)

local function opener()
    -- TODO: add check to prevent double cast!
    --if castable(SB.UnstableAffliction) and target.exists and target.alive and target.in_range("Unstable Affliction") and
    if castable(SB.Immolate) and target.exists and target.alive and target.in_range("Immolate") and
    (GetTime() > OpenerCD) then
        OpenerCD = GetTime() + SpellCD
        cast(SB.Immolate)
        --cast(SB.Torment) -- pet attack taunt
        return true
    end
    return false
end
setfenv(opener, light.environment.env)

local function combat()
    if not player.alive then return end
    if not target.alive or not target.exists then return end

    if not InCombat then cast("Attack") end

    if castable(SB.CurseOfAgony) and target.in_range("Curse Of Agony") and target.debuff("Curse of Agony").down and
        (GetTime() > CurseOfAgonyCD) then
        CurseOfAgonyCD = GetTime() + SpellCD
        cast(SB.CurseOfAgony, target)
        return cast(SB.Torment) -- pet attack taunt
    end

    -- some healing
    if player.health.percent < 35 and castable(SB.DeathCoil) and target.in_range("Death Coil") then
        return cast(SB.DeathCoil)
    end

    -- NOTE: only for short burst in rotation
    --[[
    if castable(SB.Immolate) and target.castable(SB.Immolate) and not target.debuff("Immolate").up and
        (GetTime() > ImmolateCD) then
        ImmolateCD = GetTime() + SpellCD
        return cast(SB.Immolate, target)
    end
    ]]--

    if castable(SB.Corruption) and target.castable(SB.Corruption) and target.in_range("Corruption") and
        target.debuff("Corruption").down and (GetTime() > CorruptionCD) then
        CorruptionCD = GetTime() + SpellCD
        return cast(SB.Corruption, target)
    end

    if castable(SB.UnstableAffliction) and target.castable(SB.UnstableAffliction) and target.in_range("Unstable Affliction")
        and target.health.percent > 35 and target.debuff("Unstable Affliction").down and (GetTime() > OpenerCD) then
        OpenerCD = GetTime() + SpellCD
        return cast(SB.UnstableAffliction, target)
    end

    if castable(SB.SiphonLife) and target.castable(SB.SiphonLife) and target.health.percent > 35 and
        target.debuff("Siphon Life").down then
        return cast(SB.SiphonLife, target)
    end

    --if castable(SB.ShadowBolt) and target.castable(SB.ShadowBolt) then
    --    return cast(SB.ShadowBolt, target)
    --end

    -- check if almost dead

    local name, _, _, _, _, _, spellid = UnitChannelInfo("player")
    if target.health.percent <= 9 and target.in_range("Drain Soul") and spellid ~= SB.DrainSoul
        and (target.debuff("Curse of Agony") or target.debuff("Corruption") or target.debuff("Immolate")) then
        return cast(SB.DrainSoul)
    end

    if castable(SB.DrainLife) and target.castable(SB.DrainLife) and name == nil then -- player.castable(SB.DrainLife) then
        -- check if we need a lifetap first!
        if should_use_lifetap() then
            LifeTapCD = GetTime() + 1
            return cast(SB.LifeTap)
        --elseif should_use_darkpact() then
        --    LifeTapCD = GetTime() + 1
        --    return cast(SB.DarkPact)
        end
        -- otherwise continue with drain life
        return cast(SB.DrainLife, target)
    end

    if buffs() then return end
end

local function resting()
    if target.exists then
        --local loc = string.format("%.2f, %.2f, %.2f", unpack(target.position))
        --light.interface.status_extra(loc)
    end
    if not player.alive then return end

    if buffs() then return end

    --if not pet.exists and
    ---- light.settings.fetch("warlock_pet", "Imp") =="Imp" and
    --castable(SB.SummonVoidwalker) and (GetTime() > SummonVoidwalkerCD) then
    --    SummonVoidwalkerCD = GetTime() + SummonVoidwalkerCD -- TODO check soulshard!
    --    return cast(SB.SummonVoidwalkerCD)
    --end

    if opener() then return end
end

local function interface()
    local warlock = {
        key = "Ferib's Warlock",
        title = "Warlock - level 58-70",
        width = 250,
        height = 400,
        resize = true,
        show = false,
        template = {
            {
                type = "header",
                text = "Classic Warlock Settings",
                align = "center"
            }, {
                key = "opener",
                type = "dropdown",
                text = "Opener",
                default = "Shadow Bolt",
                list = {
                    {key = "None", text = "None"},
                    {key = "Shadow Bolt", text = "Shadow Bolt"},
                    {key = "Immolate", text = "Immolate"},
                    {key = "Corruption", text = "Corruption"}
                }
            }, {type = "rule"},
            {type = "header", text = "Affliction", align = "center"}, {
                key = "curse",
                type = "dropdown",
                text = "Curse",
                default = "None",
                list = {
                    {key = "None", text = "None"},
                    {key = "Weakness", text = "Weakness"}
                }
            }, {type = "rule"},
            {type = "header", text = "Demonology", align = "center"},
            {
                key = "demonskin",
                type = "checkbox",
                text = "Use Demonskin",
                default = true
            }, {
                key = "pet",
                type = "dropdown",
                text = "Pet",
                default = "None",
                list = {
                    {key = "None", text = "None"}, {key = "Imp", text = "Imp"}
                }
            }, {type = "rule"},
            {type = "header", text = "LifeTap", align = "center"},
            {
                key = "lifetap",
                type = "checkbox",
                text = "Enable LifeTap",
                default = true
            }, {
                key = "lifetapminhealth",
                type = "spinner",
                text = "Min Health",
                default = 50,
                min = 10,
                max = 100,
                step = 5,
                desc = "Stop using LifeTap when health drops below this number."
            }, {
                key = "lifetapstayhealthy",
                type = "checkbox",
                text = "Don't allow health to drop below mana",
                default = true
            }, {
                key = "lifetapdebug",
                type = "checkbox",
                text = "Debug LifeTap",
                default = false
            }
        }
    }

    ConfigWindow = light.interface.builder.buildGUI(warlock)

    light.interface.buttons.add_toggle(
        {
            name = "settings",
            label = "Rotation Settings",
            font = "dank_icon",
            on = {
                label = light.interface.icon("cog"),
                color = light.interface.color.purple,
                color2 = light.interface.color.dark_purple
            },
            off = {
                label = light.interface.icon("cog"),
                color = light.color,
                color2 = light.interface.color.dark_grey
            },
            callback = function(self)
                if light.interface.buttons.buttons["settings"].state then
                    ConfigWindow.parent:Show()
                else
                    ConfigWindow.parent:Hide()
                end
            end
        })
end

light.rotation.register({
    class = light.rotation.classes.warlock,
    name = "warlock",
    label = "Warlock - Lvl 58-70",
    combat = combat,
    resting = resting,
    interface = interface
})

light.event.register("PLAYER_ENTER_COMBAT",
                          function(...) InCombat = true end)
light.event.register("PLAYER_LEAVE_COMBAT",
                          function(...) InCombat = false end)
