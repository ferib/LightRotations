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
		if target.in_range("Lightning Bolt") then
			return cast(SB.LightningBolt)
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

local function combat()
    if not target.alive or not target.exists or not target.enemy then return end

    -- check CD's
    if toggle("cooldowns", false) then
    end

    -- Throw 8y agro if not in group?
    if not GetTotemInfo(2) then -- Earth!
        -- Tank totem if not in party? (only 50% uptime tho)
        if not UnitInParty("player") then
            if castable(SB.StoneclawTotem) then
                return cast(SB.StoneclawTotem)
            end
        --else
        --    if castable(SB.StoneskinTotem) then
        --        return cast(SB.StoneskinTotem)
        --    end
        end
    elseif not GetTotemInfo(1) then -- fire! 
        -- always single target?
        if castable(SB.SearingTotem) then
            return cast(SB.SearingTotem)
        end
    end

    -- Cast  Flame Shock and refresh it once it expires;
    if 
        -- -player.power.mana > 30 and 
        not target.debuff(SB.FlameShock).up and 
        castable(SB.FlameShock, target) then
        return cast(SB.FlameShock, target)
    end

    -- Cast  Lava Burst if it will hit while Flame Shock is active on the target;
    --if castable(SB.LavaBurst, target) then
    --    return cast(SB.LavaBurst, target)
    --end

    -- Cast  Lightning Bolt otherwise, or exclusively if Mana is running out.
    if castable(SB.LightningBolt, target) then
        return cast(SB.LightningBolt, target)
    end

end

local function resting()
    if not player.buff("Lightning Shield") then
        return cast(SB.LightningShield)
    end
    if opener() then return end
    -- resting
end

light.rotation.register({
    class = light.rotation.classes.shaman,
    name = 'ele',
    label = 'Elemental Shaman',
    combat = combat,
    resting = resting
})
