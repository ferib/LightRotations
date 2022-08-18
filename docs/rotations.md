
# How to write a Combat Rotation


Class rotation files are located at `/rotations/class_name/`, the directory usually contains `spellbook.lua` for a mapping of spell names to spell id's _(and ranks)_.

## Template

Example template for a class rotations:
```lua
local addon, dank = ...

local function combat()
    -- combat routine
end

local function resting()
    -- resting routine
end

dank.rotation.register({
  class = dank.rotation.classes.class_name, -- TODO set class
  name = 'class_name',
  label = 'Demo Class',

  -- register our funcs in DR
  combat = combat,
  resting = resting
})
```

## Writing logic

- Casting Spells
- Unit Info


### Casting Spells



### Unit Info

Unit names:
- `player`
- `target`
- `focus`
- ...

unit:
- `buff`
- `debuff`
- `health`
- `spell`
- `power`
- `enemies`
- `alive`
- `level`
- `dead`
- `enemy`
- `friend`
- `name`
- `exists`
- `guid`
- ~`canloot`~
- ~`canskin`~
- ~`distance`~
- `channeling`
- `castingpercent`
- `casting`
- `moving`
- `combat`
- `interrupt`
- `in_range`
- `totem`
- `talent`
- `castable`
- `removable`
- `dispellable`
- ~`position`~
- ~`distance_to_pos`~
- ~`move_to`~
- `stop`
- ~`face`~
- ~`interact`~
- ~`target`~


unit.heath:
- `percent`
- `actual`
- `effective`
- `missing`
- `max`

unit.debuff:
- `exists`
- `down`
- `up`
- `down`
- `any`
- `count`
- `remains`
- `duration`

unit.spell:
- `cooldown`
- `exists`
- `castingtime`
- `charges`
- `fractionalcharges`
- `recharge`
- `lastcast`
- `castable`
- `current`

unit.power:
- `base`
- `mana`
- `rage`
- `focus`
- `energy`
- `combopoints`
- `runes`
- `runicpower`
- `soulshards`
- `lunarpower`
- `astral`
- `holypower`
- `maelstorm`
- `chi`
- `insanity`
- `arcanecharges`
- `fury`
- `pain` 

unit.runes:
- `count`


-- misc?

group:
- `count`
- `match`
- `buffable`
- `removable`
- `dispellable`
- `under`

#### Examples
Obtain player health `player.health.max`
Obtain mana left of focus `focus.power.mana`