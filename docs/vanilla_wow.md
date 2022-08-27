# Vanilla Wow

With the Burning Crusade expansion pack, we are no longer able to call `CastSpellByName`, however, this AddOn can be 'downgraded' to the Vanilla Wow APIs using [the below snippet](./vanilla_wow.lua).

Simply load them into the game one way or another _(or include them in [Light.xml](Light.xml))_
```lua
local light = _G['light_interface'] -- AddOn Global

-- Hook Lua Function
hooksecurefunc("_CastSpellByName", function(spell, target)
    local target = target or "target"
    if light.protected then
        dr_secured = false
        for i = 1, 420 do RunScript([[if not issecure() then return end CastSpellByName("]] .. spell .. [[", "]] .. target .. [[") dr_secured = true ]]) end
        dr_secured = nil
    end
end)
```
