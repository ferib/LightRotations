local addon, light = ...

local bursting = false
local lastBurst = 0
local lastBurstStep = 1;

local function combat()
    -- interupt/css
    do
        local kickunits = { arena1, arena2, arena3 }
        for i=1, #kickunits do
            if kickunits[i] ~= nil and kickunits[i].exists and kickunits[i].alive then
                if kickunits[i].casting then
                    if castable(SB.WindShear, kickunits[i]) then
                        print("kick!!")
                        cast(SB.WindShear, kickunits[i])
                    end
                end
            end
        end
        
        if arena1.exists and arena1.alive then
            if arena1.casting then
                if castable(SB.WindShear, arena1) then
                    print("kick arena1")
                    cast(SB.WindShear, arena1)
                end
            end
        end
        if arena2.exists and arena2.alive then
            if arena2.casting then
                if castable(SB.WindShear, arena2) then
                    print("kick arena2")
                    cast(SB.WindShear, arena2)
                end
            end
        end
        if arena3.exists and arena3.alive then
            if arena3.casting then
                if castable(SB.WindShear, arena3) then
                    print("kick arena3")
                    cast(SB.WindShear, arena3)
                end
            end
        end
        
    end
    -- panic cd's
    do
        
        if ((player.health.percent < 40)
        or (party1.exists and party1.alive and party1.health.percent < 30)
        or (party2.exists and party2.alive and party2.health.percent < 30))
        and castable(SB.HealingTideTotem) then
            print("HealingTideTotem!")
            return cast(SB.HealingTideTotem)
        end

        --if not player.buff(SB.SpiritLinkTotem_Buff).up then
        if
        ((player.health.percent < 50)
        or (party1.exists and party1.alive and party1.health.percent < 40)
        or (party2.exists and party2.alive and party2.health.percent < 40))
        and castable(SB.SpiritLinkTotem) then
            print("SpiritLinkTotem!")
            cast(SB.SpiritLinkTotem)
            if (party1.exists and party1.alive and party1.health.percent < 40) then
                ClickPosition(ObjectPosition("party1"))
            elseif (party2.exists and party2.alive and party2.health.percent < 40) then
                ClickPosition(ObjectPosition("party2"))
            else
                ClickPosition(ObjectPosition("player"))
            end
            return
        end

        if not player.buff(SB.EarthWall).up and
        ((player.health.percent < 50)
        or (party1.exists and party1.alive and party1.health.percent < 40)
        or (party2.exists and party2.alive and party2.health.percent < 40))
        and castable(SB.Ascendance) then
            print("Ascendance!")
            return cast(SB.Ascendance)
        end

        if --not player.buff(SB.Ascendance).up and
        ((player.health.percent < 40)
        or (party1.exists and party1.alive and party1.health.percent < 30)
        or (party2.exists and party2.alive and party2.health.percent < 30))
        and castable(SB.EarthWallTotem) then
            print("EarthWallTotem!")
            cast(SB.EarthWallTotem)
            if (party1.exists and party1.alive and party1.health.percent < 30) then
                ClickPosition(ObjectPosition("party1"))
            elseif (party2.exists and party2.alive and party2.health.percent < 30) then
                ClickPosition(ObjectPosition("party2"))
            else
                ClickPosition(ObjectPosition("player"))
            end
            return
        end
    end

    -- panic?
    if player.health.percent < 60 and castable(SB.AstralShift, player) then
        print("AstralShift!")
        return cast(SB.AstralShift)
    end

    -- Healing stream totem uptime (passive heal)
    do
        -- check for healing stream need?
        -- 18 sec uptime, 24sec re-charge
        local water_up, _, _, _, _ = GetTotemInfo(1)
        if castable(SB.HealingStreamTotem) and not water_up then
            if player.health.percent < 90 then
                if party1.exists and party2.exists then
                    if party1.health.percent < 90 and party2.health.percent < 90 then
                        return cast(SB.HealingStreamTotem)
                    end
                elseif party1.exists and party1.health.percent < 90 then
                    return cast(SB.HealingStreamTotem)
                else
                    return cast(SB.HealingStreamTotem)
                end
            end
        end
    end

    -- instnat heals, UnleashLife & Riptide
    do
        local unleash_at = 70
        if player.health.percent < unleash_at and castable(SB.UnleashLife, player) then
            return cast(SB.UnleashLife, player)
        end
        if party1.exists and party1.alive then
            if party1.health.percent < unleash_at and castable(SB.UnleashLife, party1) then
                return cast(SB.UnleashLife, party1)
            end
        end
        if party2.exists and party2.alive then
            if party2.health.percent < unleash_at and castable(SB.UnleashLife, party2) then
                return cast(SB.UnleashLife, party2)
            end
        end

        local riptide_first = 90
        local riptide_second = 75
        
        -- first Riptide below 90? second below 80?
        if player.health.percent < riptide_first and castable(SB.Riptide, player) 
        and not player.buff(SB.Riptide).up then
            return cast(SB.Riptide, player)
        end

        if player.health.percent < riptide_second and castable(SB.Riptide, player) then
            return cast(SB.Riptide, player)
        end

        -- Riptide party 1/2 at 75
        if party1.exists and party1.alive then
            if party1.health.percent < riptide_second and castable(SB.Riptide, party1) then
                return cast(SB.Riptide, party1)
            end
        end
        if party2.exists and party2.alive then
            if party2.health.percent < riptide_second and castable(SB.Riptide, party2) then
                return cast(SB.Riptide, party2)
            end
        end
        -- Riptide party 1/2 at 90
        if party1.exists and party1.alive then
            if party1.health.percent < riptide_first and castable(SB.Riptide, party1) 
            and not party1.buff(SB.Riptide).up then
                return cast(SB.Riptide, party1)
            end
        end
        if party2.exists and party2.alive then
            if party2.health.percent < riptide_first and castable(SB.Riptide, party2) 
            and not party2.buff(SB.Riptide).up then
                return cast(SB.Riptide, party2)
            end
        end
    end

    -- casting heals
    do
        local healingsurge_at = 80
        if 
        --player.buff(SB.TidalWaves).up and player.buff(SB.TidalWaves).count >= 2
        --and 
        player.health.percent < healingsurge_at and castable(SB.HealingSurge, player) then
            return cast(SB.HealingSurge, player)
        end
        if party1.exists and party1.alive then
            if 
            --player.buff(SB.TidalWaves).up and player.buff(SB.TidalWaves).count >= 2
            --and 
            party1.health.percent < healingsurge_at and castable(SB.HealingWave, party1) then
                return cast(SB.HealingWave, party1)
            end
        end
        if party2.exists and party2.alive then
            if 
            --player.buff(SB.TidalWaves).up and player.buff(SB.TidalWaves).count >= 2
            --and 
            party2.health.percent < healingsurge_at and castable(SB.HealingWave, party2) then
                return cast(SB.HealingWave, party2)
            end
        end

        local primordial_at = 80
        if player.health.percent < primordial_at and castable(SB.PrimordialWave, player) then
            return cast(SB.PrimordialWave, player)
        end
    end

    -- Normal mode
    -- Riptide
    -- Healing Stream Totem
    -- Unleash Life ?
    -- pop Earthen Wall Totem of big dmg with stacked team?
    -- Healing Wave (1-2 stakcs Tidal Waves)
    -- Healing Surge on self if using Swelling Waves


    -- BIG HEAL - single target
    -- keep earthshield up on target
    -- pop healing stream totem for passive healing
    -- Unleash Life? (talent)
    -- Riptide (6sec, 2 charges)
    -- Primordial Wave (45s cd)
    -- big cd Earth Wall Totem and reset CD with Totemic Recall?

    -- BIG HEAL - multitarget
    -- keep earthshield up on biggest takers
    -- Earth Wall Totem & reset CD
    -- Healing Tide Totem
    -- Healing Stream Token (smoll passive healing)
    -- Unleash Life
    -- Riptide
    -- Primodial Wave
    -- Healing Wave for single target or check buffs for dual (if need dual?)
    -- Helaing Surge for quikc exra hp
    -- Ascendance - last resort CD
    -- Spirit Link Totem - last resort CD


    -- check shields, low priority
    do
        if not player.buff(SB.EarthShield).up and castable(SB.EarthShield, player) then
            return cast(SB.EarthShield, player)
        end

        if not player.buff(SB.WaterShield).up and castable(SB.WaterShield, player) then
            return cast(SB.WaterShield)
        end

        -- TODO: check party1/party2?
        if party1.exists and party1.alive then -- and party2.exists then
            if not party1.buff(SB.EarthShield).up and castable(SB.EarthShield, party1) then
                return cast(SB.EarthShield, party1)
            end
        end
    end

end

local function resting()
    if (not player.buff(SB.EarthShield).up or player.buff(SB.EarthShield).count < 9) and castable(SB.EarthShield, player) then
        return cast(SB.EarthShield, player)
    end

    -- TODO: check party1/party2?
    if party1.exists and party1.alive then -- and party2.exists then
        if (not party1.buff(SB.EarthShield).up or party1.buff(SB.EarthShield).count < 9) and castable(SB.EarthShield, party1) then
            return cast(SB.EarthShield, party1)
        end
    end

    if not player.buff(SB.WaterShield).up and castable(SB.WaterShield, player) then
        return cast(SB.WaterShield)
    end
    
end

light.rotation.register({
    class = light.rotation.classes.shaman,
    name = 'shaman3s',
    label = 'Shaman 3s',
    combat = combat,
    resting = resting
})
