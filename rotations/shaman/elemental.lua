local addon, light = ...

--[[
    
    # Talents 25
    - Convection 5/5
    - Concussion 5/5
    - Elemental Focus 1/1
    - Call of Thunder 5/5

    # Runes
    - Overload (passive)
    - Lava Burst
    - Shamanistic Rage

    # Rotation
    ## How to Play Elemental Shaman DPS
    As a ranged DPS class you will want to be standing within range of enemies, 
    but away from their attacks or environmental damage while casting your damage 
    rotation or utility spells, according to necessity of the moment.

    ## Rotation
    Deploy your utility totems according to your group's needs:  Searing Totem,  
    Strength of Earth Totem, and  Healing Stream Totem are good options;

    Cast  Flame Shock and refresh it once it expires;
    Cast  Lava Burst if it will hit while Flame Shock is active on the target;
    Cast  Lightning Bolt otherwise, or exclusively if Mana is running out.

]]

local function isPlayerMoving()
    return GetUnitSpeed("player") ~= 0
end

local function opener()
	if not isPlayerMoving() and player.alive and target.exists and target.alive and target.enemy then
		--if target.in_range("Lightning Bolt") then
		--	return cast(SB.LightningBolt)
        --end
        if target.in_range("Flame Shock") then
            return cast(SB.FlameShock)
        end
	end
end
setfenv(opener, light.environment.env)

local function bestTotem()
    --[[
        !All totems 20y range!

        Healing Steam Totem (Water):
        - 1 min heal 6/2sec ()

        Poisen Cleansing Totem (Water):
        - rm poison every 5 sec (2min)

        Strength Of Earth Totem (Earth):
        - +strength (2min)

        Earth Bind Totem (Earth):
        - Slow (45 sec)

        Stonecal Totel (Earth):
        - taunt & tanks 171 dmg for 15 sec

        Forst Resistance Totem (Fire):
        - +30 forst resist (2 min)

        Searing Totem (Fire):
        - 10 fire dmg casts (30 sec)

        Fire Nova Totem (Fire):
        - ~110 10y AoE after 4 sec
    ]]
    -- 0) spam 'Stonecal Totel' if not in party?
    -- 1) WATER: Clear Poisen if needed, else heal if needed?
    -- 2) Spawn strength if needed (boss?), else check for tank HP and taunt if needed?
    -- 3) Searing totem single target else Fire Nova if 2 or more targets?
    -- 4) Fire nova of big fire dmg/cast inc?
end

local function stompStopTargetCast()
    local warstomp = 20549;
    if not castable(warstomp, target) then
        return false
    end
    
    --print(target.castingpercent)

    -- CheckInteractDistance, 3 - Duel, 9.9y range (warstom 8y)

    if target.castingpercent > 0 and CheckInteractDistance("target", 3) 
        --and castable(warstomp) 
    then --and target.in_range("Attack") then
        print(target.castingpercent, target.in_range("Attack"))
        return cast(warstomp)
        --return true
    end

end
setfenv(stompStopTargetCast, light.environment.env)

local _MoveForwardStart = _G.MoveForwardStart
local _MoveBackwardStart = _G.MoveBackwardStart
local _StrafeLeftStart = _G.StrafeLeftStart
local _StrafeRightStart = _G.StrafeRightStart


local function StopMove()
    _G.MoveForwardStart = function() end
    _G.MoveBackwardStart = function() end
    _G.StrafeLeftStart = function() end
    _G.StrafeRightStart = function() end
end
local function StartMove()
    
    Unlock(function() _G.MoveForwardStart = _MoveForwardStart end)

    _G.MoveBackwardStart = _MoveBackwardStart
    _G.StrafeLeftStart = _StrafeLeftStart
    _G.StrafeRightStart = _StrafeRightStart
end

_G.test = StopMove
_G.test2 = StartMove


local lastStopcast = GetTime() 

local function combat()
    if not target.alive or not target.exists or not target.enemy then return end

    -- always cast lightningb 
    if castable(SB.LightningBolt, target) then
            return cast(SB.LightningBolt)
    end

    -- check CD's
    local cooldowns = toggle("cooldowns", false)
    local interrupts = toggle("interrupts", false)
    
    if cooldowns then
        if 
            player.power.mana.percent < 75 and 
            castable(SB.ShamanisticRage, player) 
        then
            cast(SB.ShamanisticRage)
        end
    
        -- try warstomp if tauren?
        --if stompStopTargetCast() then
        --    return 
        --end
        --local warstomp = 20549;
        if interrupts and castable(SB.WarStomp, target) and
            target.castingpercent > 0 and  CheckInteractDistance("target", 3) 
        then
            print("WARSTOMP_1", target.castingpercent, target.in_range("Attack"))
            --return cast(WarStomp)
            if lastStopcast + 0.75 < GetTime() then
                Unlock(SpellStopCasting)
                lastStopcast = GetTime()
            end
            Unlock("RunMacroText", "/cast War Stomp")
            return cast(SB.WarStomp, target)
        end
    end

    local inParty = UnitInParty("player");
    local singleTarget = not toggle("multitarget", false)
    
    -- Totems and extra's if Mana high?
    
    local savemana = toggle("savemana", false)


    
    if not savemana then --and player.power.mana.percent > 0 then
        -- Cast  Flame Shock and refresh it once it expires;
        if 
            -- -player.power.mana > 30 and 
            not target.debuff(SB.FlameShock).up and 
            castable(SB.FlameShock, target) 
            -- and target.in_range(SB.FlameShock)
        then
            return cast(SB.FlameShock, target)
        end
        
        if target.health.actual < 130 and castable(SB.EarthShock, target) then
            return cast(SB.EarthShock)
        end

        -- Cast  Lava Burst if it will hit while Flame Shock is active on the target;
        if target.debuff(SB.FlameShock).up and castable(SB.LavaBurst, target) then
            -- pre-warstomp to get no kick?
            if cooldowns and castable(SB.WarStomp) and CheckInteractDistance("target", 3) then
                print("WARSTOMP_2", target.castingpercent, target.in_range("Attack"))
                --return cast(WarStomp)
                if lastStopcast + 0.75 < GetTime() then
                    Unlock(SpellStopCasting)
                    lastStopcast = GetTime()
                end
                Unlock("RunMacroText", "/cast War Stomp")
                return cast(SB.WarStomp, target)
            end
            return cast(SB.LavaBurst, target)
        end

        -- Throw 8y agro if not in group?
        if not GetTotemInfo(2) then -- Earth!
            -- Tank totem if not in party? (only 50% uptime tho)
            if not inParty and not singleTarget then
                if castable(SB.StoneclawTotem) then
                    return cast(SB.StoneclawTotem)
                end
            else
                if castable(SB.StoneskinTotem) then
                    return cast(SB.StoneskinTotem)
                end
            end
        elseif not GetTotemInfo(1) then -- fire! 
            -- always single target?
            if singleTarget then
                if castable(SB.SearingTotem) then
                    return cast(SB.SearingTotem)
                end
            else
                if castable(SB.FireNovaTotem) then
                    return cast(SB.FireNovaTotem)
                end
            end
        elseif not GetTotemInfo(3) then -- water!
            if (not inParty and player.health.percent < 95) 
            or (inParty and player.health.percent < 65) then
                if castable(SB.HealingStreamTotem) then
                    return cast(SB.HealingStreamTotem)
                end
            end
        end
    end

    -- heal? quicky?
    if player.health.percent < 30 and castable(SB.LesserHealingWave, player) then
        return cast(SB.LesserHealingWave, player)
    end
    -- TODO: Purge target?
    
    
    local skipLightning = toggle("nolightning", false)
    if not skipLightning then
        -- Cast  Lightning Bolt otherwise, or exclusively if Mana is running out.
        if castable(SB.LightningBolt, target) then
            return cast(SB.LightningBolt, target)
        end
    end

end

local function resting()
    
    --if not player.buff("Lightning Shield") then
    --    return cast(SB.LightningShield)
    --end

    if not isPlayerMoving() and 
        player.health.percent < 30 and 
        castable(SB.HealingWave, player) 
    then
        return cast(SB.HealingWave, player)
    end

    if opener() then return end
    -- resting
end

local function interface()
    light.interface.buttons.add_toggle(
        {
            name = "nolightning",
            label = "No lightning bolts",
            font = "dark_icon",
            on = {
                label = light.interface.icon("plug"),
                color = light.interface.color.red,
                color2 = light.interface.color.dark_red,
            },
            off = {
                label = light.interface.icon("plug"),
                color = light.color,
                color2 = light.color2
            }
        }
    )
    light.interface.buttons.add_toggle(
        {
            name = "savemana",
            label = "Save Mana",
            font = "dark_icon",
            on = {
                label = light.interface.icon("flask"),
                color = light.interface.color.blue,
                color2 = light.interface.color.dark_blue,
            },
            off = {
                label = light.interface.icon("flask"),
                color = light.color,
                color2 = light.color2
            }
        }
    )
end

light.rotation.register({
    class = light.rotation.classes.shaman,
    name = 'ele',
    label = 'Elemental Shaman',
    combat = combat,
    resting = resting,
    interface = interface
})
