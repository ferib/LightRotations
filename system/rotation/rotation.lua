local addon, light = ...

light.rotation = {
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

function light.rotation.register(config)
    if config.gcd then
        setfenv(config.gcd, light.environment.env)
    end
    if config.combat then
        setfenv(config.combat, light.environment.env)
    end
    if config.resting then
        setfenv(config.resting, light.environment.env)
    end
    if config.combat_movement then
        setfenv(config.combat_movement, light.environment.env)
    end
    light.rotation.rotation_store[config.name] = config
end

function light.rotation.load(name)
    local rotation
    for _, rot in pairs(light.rotation.rotation_store) do
        if rot.name == name then
            rotation = rot
        end
    end

    if rotation then
        light.settings.store('active_rotation', name)
        light.rotation.active_rotation = rotation
        light.interface.buttons.reset()
        if rotation.interface then
            rotation.interface(rotation)
        end
        if light.settings.fetch("netload_rotation_release", nil) then
            light.log('Loaded rotation: ' .. name .. ' (network)')
        else
            light.log('Loaded rotation: ' .. name)
        end
        light.interface.status('Ready...')
    else
        light.error('Unable to load rotation: ' .. name)
    end
end

function light.environment.selectrank(ranks, p)
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

GetSpellName = light.environment.GetSpellName
light.environment.hooks['SB'] = setmetatable({}, {
    __index = function(self, key)
        local _, _, class = UnitClass('player') -- TODO: Use a global...
        local value = light.rotation.spellbook_map[class][key]
        if value then
            local spell_id = nil
            if type(value) == 'table' then
                local rank = light.environment.selectrank(value)
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
        if light.rotation.spellbook_map[class] then
            local value = light.rotation.spellbook_map[class][key]
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

light.environment.hooks['Spell'] = light.environment.hooks['SB']
light.environment.hooks['Spells'] = light.environment.hooks['SB']

local loading_wait = false

local timer
local function init()
    if not loading_wait then
        timer = C_Timer.NewTicker(0.3, function()
            if light.protected then
                light.rotation.spellbook_map = {
                    [1] = light.rotation.spellbooks.warrior,
                    [2] = light.rotation.spellbooks.paladin,
                    [3] = light.rotation.spellbooks.hunter,
                    [4] = light.rotation.spellbooks.rogue,
                    [5] = light.rotation.spellbooks.priest,
                    [7] = light.rotation.spellbooks.shaman,
                    [8] = light.rotation.spellbooks.mage,
                    [9] = light.rotation.spellbooks.warlock,
                    [11] = light.rotation.spellbooks.druid
                }
                local active_rotation = light.settings.fetch('active_rotation', false)
                local netload_rotation_release = light.settings.fetch('netload_rotation_release', false)
                if active_rotation and netload_rotation_release then
                    RotationLoader:LoadRotation(active_rotation, netload_rotation_release)
                elseif active_rotation then
                    light.rotation.load(active_rotation)
                    light.interface.status('Ready...')
                else
                    light.interface.status('Load a rotation...')
                end
                loading_wait = false
                timer:Cancel()
            end
        end)
    end
end

light.on_ready(function()
    init()
    loading_wait = true
end)
