# ☠ LightRotations

[LightRotations](https://github.com/ferib/LightRotations), yet another [DarkRotations](https://gitlab.com/dark_rotations) fork.


## ⚔️ Combat Rotations

NOTE: The current state of the project includes none of my rotations as they are private,

| Name | Class | Type | Dev | Status |
|------|-------|------|-----|--------|
| Druid | Druid | | | 🔴 TODO |
| Hunter | Hunter | | | 🔴 TODO |
| Mage | Mage | | | 🔴 TODO |
| Paladin | Paladin | | | 🔴 TODO |
| Priest | Priest | | | 🔴 TODO |
| Rogue | Rogue | | | 🔴 TODO |
| Shaman | Shaman | | | 🔴 TODO |
| [Dotlock](#) | Warlock _(affliction)_ | Advanced | [ferib](https://github.com/ferib) |  🟠 WIP _(private)_ |
| Warrior | Warrior | | | 🔴 TODO |


# ℹ How to install

[Download as .zip](https://github.com/ferib/LightRotations/archive/refs/heads/master.zip) and extract in `C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns\Light`, make sure the folder no longer has the `-master` suffix in the name and that it is correctly renamed to `Light`.

NOTE: your default installation folder might be located elsewhere!

-- OR --

Advanced installation for git users:

```bash
cd C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns\
git clone https://github.com/ferib/LightRotations
mv LightRotations Light
```

## ⚠ Warning: AddOn Name Detection
It is public knowledge that AddOn names are uploaded to the game server for analysis! Both folder/toc names *(`Light`, `Light.toc`)* and Lua globals `_G.Light` may be tracked.

TODO: add auto renaming script?

# ✍ Getting Started: Writing Combat Rotations

To get started creating combat routines, check out the [docs](docs/readme.md).
