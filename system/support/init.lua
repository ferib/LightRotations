local addon, dank = ...

_G['dark_interface'] = dank
dank.name = 'DankRotations Classic'
dank.version = 'r300'
dank.color = 'ebdec2'
dank.color2 = 'ebdec2'
dank.color3 = 'ebdec2'
dank.ready = false
dank.settings_ready = false
dank.ready_callbacks = {}
dank.protected = false
dank.adv_protected = false
-- dank.libcc = LibStub("LibClassicCasterino")
dank.savedHealTarget = nil
dank.healthCooldown = {}

function dank.on_ready(callback)
    dank.ready_callbacks[callback] = callback
end

local libccstub = function(event, ...)
    return
end
-- dank.libcc.RegisterCallback(dank.name,"UNIT_SPELLCAST_START", libccstub)
-- UnitCastingInfo = function(unit) return dank.libcc:UnitCastingInfo(unit) end
-- UnitChannelInfo = function(unit) return dank.libcc:UnitChannelInfo(unit) end
