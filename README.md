# Roblox Weapon System

Weapon system for the Roblox project **SFKU** (owner — [@Delk](https://discord.com/users/1016374260811440258)). Lua/Luau, server + client modules.

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
```

## Installation (Roblox Studio)

1. Open the place, enable **Game Settings → Security → Studio Access to API Services** (built-in DataStore is used).
2. Copy the folder tree into the matching services (`ReplicatedStorage`, `ServerScriptService`, `StarterPlayerScripts`, `StarterGui`).
3. Play. Weapons are picked up from the ground with **E**.

## Known limitations

- No animations or gunshot sounds yet (animator's scope).
- Model geometry, scale and grip points belong to the asset pack; weapon attachments (suppressors, optics) are not feasible without proper attachment points in the models.

## License

Proprietary. Copyright (c) 2026 SFKU project. All rights reserved.
Publicly available for viewing only (portfolio). See [LICENSE](LICENSE).

The repository also contains supporting project infrastructure (roles, doors, cameras, KPZ, virology, case management) as part of the SFKU project codebase.