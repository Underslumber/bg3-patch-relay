<img src="docs/cover.png" alt="Patch Relay" width="220" align="right">

# 🛡️ BG3 Underslumber — Patch Relay

**English** · [Русский](README.md)

A private patch layer on top of third-party Baldur's Gate 3 mods. It normally overrides individual stat entries and adds narrowly scoped Script Extender handlers; custom item variants only exist as explicitly documented continuations of the original entries.

Mod page: [BG3 Underslumber — Patch Relay on mod.io](https://mod.io/g/baldursgate3/m/bg3-underslumber-patch-relay).

A GitHub Release is published to mod.io by [a separate workflow driven by the official BG3 Toolkit](docs/modio-publishing.md); the source is always this repository as a whole, including `Mods/` and `Public/`.

In BG3 stats the last loaded entry wins, so this mod must sit **below** every patched mod in the load order.

***

## 📋 Patches

The table is a table of contents: one row per patch, the details live in a separate file. A full description states the third-party mod version the patch was made against, the overridden fields, the original content (the "Базис" section) and the reason for the change — after an upstream update that is what tells whether the patch still holds or needs rewriting. The per-patch files are written in Russian.

| Patch | Mod | What it does |
|:---|:---|:---|
| 🗡️ [`BLADESONG` AC ladder](docs/patches/dnd55e-bladesong.md) | 📦 [DnD 5.5e All-in-One BEYOND](#-affected-mods) | 💡 Extends the Bladesong bonus past its +7 cap up to +10 at 30 Intelligence and collapses seven terms into a single tooltip line |
| ⚔️ [Pact weapon outside the slot](docs/patches/dnd55e-pact-weapon.md) | 📦 [DnD 5.5e All-in-One BEYOND](#-affected-mods) | 💡 The pact bond survives moving the weapon into the inventory: a Lua handler restores the removed `PACT_BLADE*` statuses |
| 🎲 [Void capsules: reward and extended pools](docs/patches/ancient-mega-pack-void-capsule.md) | 📦 [Ancient Mega Pack](#-affected-mods) | 💡 Fixes the empty reward and automatically tops up the stock pools with gear from active mods by rarity, slot and theme |
| 🎩 [Eternal Echo on the very rare hat](docs/patches/ancient-mega-pack-eternal-echo.md) | 📦 [Ancient Mega Pack](#-affected-mods) | 💡 Raises the actual bonus damage from ×1 to the advertised ×1.5 Intelligence modifier |
| 🔨 [Ancient Mega Pack effect fixes](docs/patches/ancient-mega-pack-mace-stun.md) | 📦 [Ancient Mega Pack](#-affected-mods) | 💡 Aligns status durations and displayed weapon and cloak effects with their actual behavior |
| 💠 [Two versions of the Arcane Augmentation Pendant](docs/patches/xfed-arcane-augmentation-pendant.md) | 📦 [Fade's Equipment Distribution AIO](#-affected-mods) | 💡 Clarifies the displayed properties of the very rare version and adds a separate legendary capstone to xFED world loot and legendary capsules |
| ⚙️ [xFED mechanic fixes](docs/patches/xfed-missing-item-mechanics.md) | 📦 [Fade's Equipment Distribution AIO](#-affected-mods) | 💡 Aligns item properties with their described behavior and removes broken status references |
| 📝 [xFED item descriptions](docs/patches/xfed-russian-localization.md) | 📦 [Fade's Equipment Distribution AIO](#-affected-mods) | 💡 Fixes missing and inaccurate descriptions of effects, conditions and numerical values |
| 🏺 [Ancient Mega Pack descriptions](docs/patches/ancient-mega-pack-russian-localization.md) | 📦 [Ancient Mega Pack](#-affected-mods) | 💡 Aligns the Disintegrator, pendant and weapon descriptions with their actual behavior |

### 🗑️ Removed

Once upstream fixes the issue itself, the patch is dropped from the mod and its row moves here. None so far.

***

## 🎮 Affected mods

| Mod | What it is | Resources |
|:---|:---|:---|
| 🎲 [DnD 5.5e All-in-One BEYOND](https://mod.io/g/baldursgate3/m/bg3dnd) | 📖 BG3 converted to the D&D 2024 (5.5e) rules: classes, subclasses, feats, spells, backgrounds and core rules | 🔗 [card](docs/patched-mods.md#dnd-55e-all-in-one-beyond) · 📂 [sources](https://github.com/Yoonmoonsik/bg3dnd) · 🍴 [fork](https://github.com/Underslumber/bg3dnd) |
| 🏺 [Ancient Mega Pack](https://mod.io/g/baldursgate3/m/ancient-mega-pack-rel) | 🎁 A large pack of items, random loot and void capsules | 🔗 [card](docs/patched-mods.md#ancient-mega-pack) · 📦 [page and build](https://mod.io/g/baldursgate3/m/ancient-mega-pack-rel) · 📂 unpacked local copy |
| 💠 [Fade's Equipment Distribution AIO](https://mod.io/g/baldursgate3/m/fades-equipment-distribution-aio) | 🧰 World distribution of class equipment sets | 🔗 [card](docs/patched-mods.md#fades-equipment-distribution-aio) · 📦 [page and build](https://mod.io/g/baldursgate3/m/fades-equipment-distribution-aio) · 📂 unpacked local copy |
