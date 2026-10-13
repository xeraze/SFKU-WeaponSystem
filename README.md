# SFKU — Weapon System

Weapon system for the Roblox project **SFKU** (client — Delk). Lua/Luau, server + client modules, installable into Studio via Command Bar batches.

## Features

- Pickup from the map (ProximityPrompt), carrying multiple weapons at once
- Hitscan shooting with distance damage falloff and 2× headshots
- Semi-auto / full-auto by weapon type, bolt-action snipers
- Reload with timer, magazine hide animation hook, reserve ammo
- ADS (right mouse, first-person only) with reduced spread
- Fully data-driven stats in `WeaponConfig` (damage, fire rate, mag size, spread, range)
- Auto-resolve stats for models with arbitrary names (fallback config)

## Structure

```
ReplicatedStorage/Modules/          — Config, DataStore, Weapon (Config / Parser / Validator)
ServerScriptService/Server/         — MainServer + gameplay systems (roles, doors, KPZ, weapon, ...)
StarterPlayerScripts/               — client: weapon HUD, interactions, menu
StarterGui/MainMenu/                — loading screen and role selection menu
cmd_1.lua ... cmd_6.lua             — Studio Command Bar install batches
generate_batches.ps1                — regenerates cmd_*.lua from sources
```

## Installation (Roblox Studio)

1. Open the place, enable **Game Settings → Security → Studio Access to API Services** (built-in DataStore is used).
2. In **Edit mode**, paste `cmd_1.lua` … `cmd_6.lua` into the Command Bar in order (each batch is under the 100k symbol limit).
3. Play. Weapons are picked up from the ground with **E**.

## Known limitations

- No animations or gunshot sounds yet (animator's scope).
- Model geometry, scale and grip points belong to the asset pack; weapon attachments (suppressors, optics) are not feasible without proper attachment points in the models.

## License

Non-commercial use only. Authorship: **SFKU / SFKU.inc project**.
See [LICENSE](LICENSE) (based on [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)).

The repository also contains supporting project infrastructure (roles, doors, cameras, KPZ, virology, case management) as part of the SFKU project codebase.
