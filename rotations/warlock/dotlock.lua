local addon, light = ...

-- immume enemy buffs
local aura_immume = {
    45438, -- Ice Block
    33786, -- Cyclone
    1020, -- Divine Shield
    710, -- Banish
	-- Cloack of Shadow?
}

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
local DeadlockFound = false

local LifeTapAmount = 899

local objects = { }

local objects = { }
local players = { }
local localPlayer = { }
local distRange = 60


local CalcDistance = function(x1, y1, z1, x2, y2, z2)
	if x1 and x2 then
		return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2) + math.pow(z2 - z1, 2));
	end
end


local function buffs()
    local demonarmor = light.settings.fetch("warlock_demonskin", true)

    if demonarmor and (player.buff("Demon Armor").down and player.buff("Fel Armor").down) then
        cast(SB.DemonArmor)
        return true
    end

    if player.buff("Soul Link").down and pet.exists and pet.alive then
        cast(SB.SoulLink)
    end
end
setfenv(buffs, light.environment.env)

local function opener()
    -- TODO: add check to prevent double cast!
    if castable(SB.UnstableAffliction) and target.exists and target.alive and target.in_range("Unstable Affliction") and
    (GetTime() > OpenerCD) then
        OpenerCD = GetTime() + SpellCD
        cast(SB.UnstableAffliction)
        --cast(SB.Torment) -- pet attack taunt
        return true
    end
    return false
end
setfenv(opener, light.environment.env)

local function GetFacing(px, py, tx, ty)
	local px2, py2 -- point north of player
	px2 = px + 36
	py2 = py

	if px == nil or tx == nil then
		return -1
	end

	local a = mover.utils.GetDistanceBetweenPositions(px2, py2, 0, tx, ty, 0)
	local b = mover.utils.GetDistanceBetweenPositions(px, py, 0, tx, ty, 0)
	local c = mover.utils.GetDistanceBetweenPositions(px, py, 0, px2, py2, 0)
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

local function getPlayers()
    -- Obtain all players
    local oldmouseover = Nn.GetMouseover()
    players = { }
    objects = Nn.GetObjects()
    for i=1, #objects do
        local o = objects[i]
        local type = Nn.GetObjectType(o)
        if type == 6 then -- player
            local player = { }
            Nn.SetMouseover(o)
            player.id = o
            player.immume = false
            player.enemy = UnitIsEnemy("player", "mouseover")
            local x, y, z = Nn.GetObjectPosition(o)
            player.x = x
            player.y = y
            player.z = z
            local ded = UnitIsDeadOrGhost("mouseover")
            player.alive = not ded
            player.hp = UnitHealth("mouseover")
            player.hpMax = UnitHealthMax("mouseover")
            player.name = UnitName("mouseover")
            local spell, _, _, _, startTime, endTime, isTradeSkill, _, interrupt = UnitCastingInfo("mouseover")
            if not isTradeSkill then
                player.castSpell = spell
                player.castStartTime = startTime
                player.castEndTime = endTime
                player.castInterrupt = interrupt
            end
            local _, _, classId = UnitClass("mouseover")
            player.classId = classId
            player.hasAgony = false
            player.hasTongue = false
            player.hasWeakness = false
            player.hasSiphon = false
            player.hasCorruption = false
            for i=1, 40 do
                local dd, a, b, c, d, e, f, unitCaster, _, _, spellId = UnitDebuff("mouseover", i)
                if aura_immume[spellId] then
                    print("Immume", player.name)
                    player.immume = true
                end
                local d = UnitDebuff("mouseover", i)

                --print(d)
                if d == "Curse of Agony" then
                    --print(dd .. " " .. a .. " " .. b .. " " .. c .. " " .. d .. " " .. e .. " " .. f)
                end

                if d == "Corruption" and f == "player" then player.hasCorruption = true
                elseif d == "Siphon Life" and f == "player" then player.hasSiphon = true
                elseif d == "Curse of Tongues" then player.hasTongue = true -- shared
                elseif d == "Curse of Weakness" then player.hasWeakness = true -- shared
                elseif d == "Curse of Agony" and f == "player" then player.hasAgony = true
                end

            end
            players[#players+1] = player
        elseif type == 7 then -- local player
            localPlayer.id = o
            local x, y, z = Nn.GetObjectPosition(o)
            localPlayer.x = x
            localPlayer.y = y
            localPlayer.z = z
        end
    end
    Nn.SetMouseover(oldmouseover)
    return players
end

local function inLoS(player)
    --print(localPlayer.x, localPlayer.y, localPlayer.z+1.3, player.x, player.y, player.z+1.3, 0x100010)
	--return true
	local x, y, z = Nn.TraceLine(localPlayer.x, localPlayer.y, localPlayer.z+1.3, player.x, player.y, player.z+1.3, 0x100010)
	--print("LoS check: " .. tostring(x))
    return x == 0 or x == nil or x == false
end

local function combat()
    if not player.alive then return end
    --if not target.alive or not target.exists then return end

    if not InCombat then cast("Attack") end

    -- some healing
    --if player.health.percent < 15 and pet.alive then
    --    --return cast(SB.DeathCoil)
    --    Nn.Unlock("CastSpellByName", "Sacrifice(Rank 7)")
    --end

    --if modi

    -- lifetap on full hp when needed
    if player.health.percent >= 85 and player.power.mana.percent < 95 or
		player.power.mana.percent < 5 then -- tap until we feint
        return cast(SB.LifeTap)
    end

    -- chech dots on main target
    if target.exists and target.alive and target.enemy then
        -- check for Fear
        if target.health.percent < 3 and castable(SB.DrainSoul) then
            return cast(SB.DrainSoul)
        end

        -- check for user input
        if modifier.alt then
            return cast(SB.Fear)
        end
        if modifier.shift then
            return cast(SB.DrainLife)
        end

        -- In case no low HP target was found for 100% shadowbolt
        if target.exists and target.alive and target.enemy
        and not DeadlockFound and player.buff(SB.ShadowTrance).up then -- and target.in_range("Shadow Bolt") then
            return cast(SB.ShadowBolt)
        end

		-- handle Haunt & Unstable Affliction
		if target.debuff(SB.UnstableAffliction).down and castable(SB.UnstableAffliction) then
			return cast(SB.UnstableAffliction)
		elseif target.debuff(SB.Haunt).down and castable(SB.Haunt) then
			return cast(SB.Haunt)
		end

        -- single target dots
        if toggle("dagony") and target.debuff(SB.CurseOfAgony).down then
            return cast(SB.CurseOfAgony)
        elseif toggle("dcorruption") and target.debuff(SB.Corruption).down then
            return cast(SB.Corruption)
        elseif toggle("interrupts") and target.debuff(SB.SiphonLife).down then
            return cast(SB.SiphonLife)
        end
    end

    --if multi
    if toggle('multitarget', false) then
        local players = getPlayers()
		--print("players: " .. #players)
        local lowFound = false
        -- movement
        if toggle('coodlowns', false) then

        end
        -- spell casting
        for i=1, #players do
            local atar = players[i]
            if atar.enemy and not atar.immume then
                local dist = CalcDistance(localPlayer.x, localPlayer.y, localPlayer.z, atar.x, atar.y, atar.z)
                -- TODO: check spells
                --print("Check: " .. atar.name .. " - " .. dist)
                if dist ~= nil and dist < 36 and inLoS(atar) then
                    -- check for rogue
                    if false then -- player.debuff(SB.Cheapshot) then

                    else
                    -- do as normal
                        if atar.hp < 20 and atar.alive then
                            --print(atar.name .. " " .. atar.hp .. " - " .. atar.hpMax)
                            lowFound = true
                            if player.buff(SB.ShadowTrance).up then
                                -- cast SB
                                local old = Nn.GetMouseover()
                                Nn.SetMouseover(atar.id)
                                --cast(SB.ShadowBolt)
                                Nn.Unlock("CastSpellByName", "Shadow Bolt(Rank 12)", "mouseover")
                                Nn.SetMouseover(old)
                                print("Auto-Shadowbolted: " .. atar.name .. " (" .. atar.hp .. ")")
                                return
                            end
                        end
                        --print("Check: " .. atar.name)
                        -- check dot
                        castName = nil
                        if not atar.hasAgony and toggle("dagony", false) then
                            castName = "Curse of Agony(Rank 8)"
                        elseif not atar.hasCorruption and toggle("dcorruption", false) then
                            castName = "Corruption(Rank 10)"
                        --elseif not atar.hasSiphon and toggle("interrupts", false) then
                        --    castName = "Siphon Life(Rank 6)"
                        end

                        if castName ~= nil then
                            if debugdot then
                                print("dotting "..atar.name .. " - " .. atar)
                            end
                            local old = Nn.GetMouseover()
                            Nn.SetMouseover(atar.id)
                            Nn.Unlock("CastSpellByName", castName, "mouseover")
                            Nn.SetMouseover(old)
                            -- should we?
                            --DeadlockFound = lowFound
                            -- TODO: use CD instead?
                            --return
                        end
                    end
                end
            end
        end
        DeadlockFound = lowFound
    end

    if toggle("cooldowns", false) then
        --print(string.format("isChanneling: %s, channeling: %s", tostring(player.isChanneling), tostring(player.channeling()) ))
        -- drainlife spam while we wait for new targets
		if not player.channeling() and target.in_range("Drain Life") then
		--if not player.isChanneling and target.in_range("Drain Life") then
		--if target.in_range("Searing Pain") then
			return cast(SB.DrainLife)
			--return cast(SB.SearingPain)
		end
    end

    if buffs() then return end
end

local function UnitHasBuff(type, buffname)

end

local function hasDebuff(p, debuff, fp)
    local fromPlayer = fp or true
    local old = Nn.GetMouseover()
    for i=1,40 do
        local d, _, _, _, _, _, _, unitCaster = UnitDebuff("mouseover", i)
        print(unitCaster)
        if d == debuff and (not fromPlayer or unitCaster == "player") then
            Nn.SetMouseover(old)
            return true
        end
    end
    Nn.SetMouseover(old)
    return false
end

local function resting()
    if not player.alive then return end
    if buffs() then return end

    -- TODO: rain of fire on stealth

    -- TODO: auto flag cap
    -- TODO: display Enemy player count near flag/objectives
    --combat()

    if opener() then return end
end

local function interface()
    local warlock = {
        key = "dotlock",
        title = "Warlock Curse'n'Dot",
        width = 250,
        height = 400,
        resize = true,
        show = false,
        template = {
            {
                type = "header",
                text = "Affliction dotting",
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
                key = "dotdebug",
                type = "checkbox",
                text = "Debug Dots",
                default = false
            }
        }
    }

    ConfigWindow = light.interface.builder.buildGUI(warlock)

    light.interface.buttons.add_toggle(
        {
            name = "dagony",
            label = "Auto Curse of Agony",
            font = "dark_icon",
            on = {
                label = light.interface.icon("circle"),
                color = light.interface.color.orange,
                color2 = light.interface.color.dark_orange,
            },
            off = {
                label = light.interface.icon("circle"),
                color = light.color,
                color2 = light.color2
            }
        }
    )
    light.interface.buttons.add_toggle(
        {
            name = "dcorruption",
            label = "Auto Corruption",
            font = "dark_icon",
            on = {
                label = light.interface.icon("circle"),
                color = light.interface.color.red,
                color2 = light.interface.color.dark_red,
            },
            off = {
                label = light.interface.icon("circle"),
                color = light.color,
                color2 = light.color2
            }
        }
    )
    --[[
    light.interface.buttons.add_toggle(
        {
            name = "settings",
            label = "Rotation Settings",
            font = "dark_icon",
            on = {
                label = light.interface.icon("cog"),
                color = light.interface.color.purple,
                color2 = light.interface.color.dark_purple
            },
            off = {
                label = light.interface.icon("cog"),
                color = light.interface.color.grey,
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
        ]]--
        -- auto AoE on enemy rogue
end

light.rotation.register({
    class = light.rotation.classes.warlock,
    name = "dotlock",
    label = "Warlock Curse'n'dots",
    combat = combat,
    resting = resting,
    interface = interface
})

light.event.register("PLAYER_ENTER_COMBAT",
                          function(...) InCombat = true end)
light.event.register("PLAYER_LEAVE_COMBAT",
                          function(...) InCombat = false end)
