# ☠ DankRotations

[DankRotations](https://github.com/ferib/DankRotations), yet another [DarkRotations](https://gitlab.com/dark_rotations) fork.

# ℹ How to install

[Download as .zip](https://github.com/ferib/DankRotations/archive/refs/heads/master.zip) and extract in `C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns\Dank`, make sure the folder no longer has the `-master` suffix in the name and that it is correctly renamed to `Dank`.

NOTE: your default installation folder might be located elsewhere!

-- OR --

Advanced installation for git users:

```bash
cd C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns\
git clone https://github.com/ferib/DankRotations
mv DankRotations Dank
```

## ⚠ Warning: AddOn Name Detection
It is public knowledge that AddOn names are uploaded to the game server for analysis! Both folder/toc names *(`Dank`, `Dank.toc`)* and Lua globals `_G.Dank` may be tracked.

TODO: add auto renaming script?

# ✍ Getting Started: Writing Combat Rotations

To get started creating combat routines, check out the [docs](docs/readme.md).
