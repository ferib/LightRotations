local addon, light = ...

_G['light_interface'] = light
light.name = 'Light'
light.version = 'r300'
light.color = 'f5deb3'
light.color2 = 'ebbd68'
light.color3 = 'ebdec2'
light.fontColor = '424242' -- light.interface.color.grey
light.fontFamily = 'ComicSans'
light.ready = false
light.settings_ready = false
light.ready_callbacks = {}
light.protected = false
light.adv_protected = false
-- light.libcc = LibStub("LibClassicCasterino")
light.savedHealTarget = nil
light.healthCooldown = {}

function light.on_ready(callback)
    light.ready_callbacks[callback] = callback
end

local libccstub = function(event, ...)
    return
end
-- light.libcc.RegisterCallback(light.name,"UNIT_SPELLCAST_START", libccstub)
-- UnitCastingInfo = function(unit) return light.libcc:UnitCastingInfo(unit) end
-- UnitChannelInfo = function(unit) return light.libcc:UnitChannelInfo(unit) end
