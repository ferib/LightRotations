local addon, dank = ...

dank.rotation = {
    classes = {
        druid = 11,
        hunter = 3,
        mage = 8,
        paladin = 2,
        priest = 5,
        rogue = 4,
        shaman = 7,
        warlock = 9,
        warrior = 1
    },
    rotation_store = {},
    spellbooks = {},
    talentbooks = {},
    dispellbooks = {},
    healingspells = {},
    active_rotation = false
}

function dank.rotation.register(config)
    if config.gcd then
        setfenv(config.gcd, dank.environment.env)
    end
    if config.combat then
        setfenv(config.combat, dank.environment.env)
    end
    if config.resting then
        setfenv(config.resting, dank.environment.env)
    end
    if config.combat_movement then
        setfenv(config.combat_movement, dank.environment.env)
    end
    dank.rotation.rotation_store[config.name] = config
end

function dank.rotation.load(name)
    local rotation
    for _, rot in pairs(dank.rotation.rotation_store) do
        if rot.name == name then
            rotation = rot
        end
    end

    if rotation then
        dank.settings.store('active_rotation', name)
        dank.rotation.active_rotation = rotation
        dank.interface.buttons.reset()
        if rotation.interface then
            rotation.interface(rotation)
        end
        if dank.settings.fetch("netload_rotation_release", nil) then
            dank.log('Loaded rotation: ' .. name .. ' (network)')
        else
            dank.log('Loaded rotation: ' .. name)
        end
        dank.interface.status('Ready...')
    else
        dank.error('Unable to load rotation: ' .. name)
    end
end

function dank.environment.selectrank(ranks, p)
    local ispet = p or false
    if #ranks == 0 then
        return
    end
    for i = #ranks, 1, -1 do
        if IsSpellKnown(ranks[i], false) then
            return ranks[i]
        end
    end
end

local rank_cache = {}

GetSpellName = dank.environment.GetSpellName
dank.environment.hooks['SB'] = setmetatable({}, {
    __index = function(self, key)
        local _, _, class = UnitClass('player') -- TODO: Use a global...
        local value = dank.rotation.spellbook_map[class][key]
        if value then
            local spell_id = nil
            if type(value) == 'table' then
                local rank = dank.environment.selectrank(value)
                if rank then
                    spell_namerank = GetSpellName(rank)
                    spell_name = GetSpellInfo(rank)
                    spell_id = rank
                else
                    spell_namerank = GetSpellName(value[1])
                    spell_name = GetSpellInfo(value[1])
                    spell_id = value[1]
                end
            else
                spell_namerank = GetSpellName(value)
                spell_name = GetSpellInfo(value)
                spell_id = value
            end
            if not rank_cache[spell_id] then
                rank_cache[spell_id] = setmetatable({
                    namerank = spell_namerank,
                    name = spell_name,
                    id = spell_id,
                    ranks = value
                }, {
                    __index = function(self, key)
                        if type(self.ranks) == 'table' and tonumber(key) then
                            return self.ranks[key]
                        end
                        return self.id
                    end,
                    __call = function(self, key)
                        if type(self.ranks) == 'table' and tonumber(key) then
                            return self.ranks[key]
                        end
                        return self.id
                    end,
                    __tostring = function(self)
                        return self.namerank
                    end,
                    __concat = function(l, r)
                        if l.namerank then
                            return l.namerank .. r
                        end
                        if r.namerank then
                            return l .. r.namerank
                        end
                    end
                })
            end
            return rank_cache[spell_id]
        end
        return nil
    end,
    __call = function(self, key, rank)
        local _, _, class = UnitClass('player')
        if dank.rotation.spellbook_map[class] then
            local value = dank.rotation.spellbook_map[class][key]
            if type(value) == 'table' then
                local id = value[rank]
                if not id then
                    return value[1]
                end
                return id
            else
                return value
            end
        end
        return nil
    end
})

dank.environment.hooks['Spell'] = dank.environment.hooks['SB']
dank.environment.hooks['Spells'] = dank.environment.hooks['SB']

local loading_wait = false

local timer
local function init()
    if not loading_wait then
        timer = C_Timer.NewTicker(0.3, function()
            if dank.protected then
                dank.rotation.spellbook_map = {
                    [1] = dank.rotation.spellbooks.warrior,
                    [2] = dank.rotation.spellbooks.paladin,
                    [3] = dank.rotation.spellbooks.hunter,
                    [4] = dank.rotation.spellbooks.rogue,
                    [5] = dank.rotation.spellbooks.priest,
                    [7] = dank.rotation.spellbooks.shaman,
                    [8] = dank.rotation.spellbooks.mage,
                    [9] = dank.rotation.spellbooks.warlock,
                    [11] = dank.rotation.spellbooks.druid
                }
                local active_rotation = dank.settings.fetch('active_rotation', false)
                local netload_rotation_release = dank.settings.fetch('netload_rotation_release', false)
                if active_rotation and netload_rotation_release then
                    RotationLoader:LoadRotation(active_rotation, netload_rotation_release)
                elseif active_rotation then
                    dank.rotation.load(active_rotation)
                    dank.interface.status('Ready...')
                else
                    dank.interface.status('Load a rotation...')
                end
                loading_wait = false
                timer:Cancel()
            end
        end)
    end
end

dank.on_ready(function()
    init()
    loading_wait = true
end)
