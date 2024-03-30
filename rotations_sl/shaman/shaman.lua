local addon, light = ...

local function combat()
    -- combat
end

local function resting()
    if target.exists and target.enemy and  target.alive then
        local LightningBolt = 188196 -- TODO: Update spellbooks!
        if castable(LightningBolt, target) then
            return cast(LightningBolt)
        end
    end
end

light.rotation.register({
    class = light.rotation.classes.shaman,
    name = 'shaman',
    label = 'Bundled Shaman',
    combat = combat,
    resting = resting
})
