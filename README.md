# BrotatoLike

A Brotato-inspired top-down survivor game built in **Godot 4** (GL Compatibility renderer).

Version 0.1.0. This is a learning project, built to understand how survivor-likes
hold together underneath the surface: the spawn loop, the auto-firing weapon
cycle, and the global state that ties a run together.

## Current state

An early vertical slice. The core loop runs, but there is no art pass,
no upgrade shop, and no win condition yet.

## Structure

```
scenes/
  game/     Game.tscn      main scene, spawn loop
  player/   Player.tscn    movement and health
  enemies/  Enemy.tscn     chase behaviour
  weapons/  Weapon.tscn    auto-firing weapon
            Bullet.tscn    projectile
scripts/
  GameState.gd             autoloaded singleton for run state
```

## Running it

1. Install [Godot 4.6](https://godotengine.org/download) or later.
2. Open the project folder in the Godot project manager.
3. Press F5, or run `scenes/game/Game.tscn` directly.

No build step and no external dependencies.

## Controls

| Input | Action |
|---|---|
| WASD / arrow keys | Move |
| (automatic) | Weapons fire on their own cooldown |

## Roadmap

- [ ] Wave progression and scaling difficulty
- [ ] Between-wave upgrade shop
- [ ] Additional weapon types
- [ ] Art and audio pass

## Licence

MIT. See [LICENSE](./LICENSE).
