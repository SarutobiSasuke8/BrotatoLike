# BrotatoLike

A Brotato-inspired top-down survivor, version 0.1.0, made with Godot 4.6
(GL Compatibility renderer).

## Concept

You start in the middle of a 1152 by 648 window and live through waves of
enemies. Each wave lasts 60 seconds. Enemies walk in from just outside the
edges of the screen and chase you. The only weapon aims at the nearest enemy
and fires on its own. There is no separate fire button.

Defeated enemies award experience and gold. Experience raises your level.
The first level needs 10 XP, and each later threshold is the previous one
multiplied by 1.4. Levelling does not open a choice on its own. When the
wave timer reaches zero, every enemy is removed, the wave number increases,
and a shop offers three upgrades drawn at random. You can buy any you can
afford, then continue. There is no win condition. Later waves spawn faster
and scale enemy health and damage.

If your health reaches zero the run ends. The death screen shows the wave,
your level, and your gold. Play Again reloads the scene, which resets the
run through `GameState.reset()`.

### Enemies

The spawn interval starts at 2.0 seconds and drops by 0.1 seconds per wave,
with a floor of 0.3 seconds. The first spawn of a wave waits 1.5 seconds.
Each spawn rolls a type:

| Type | Chance | Speed | Base health | Base damage | XP | Gold |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Speeder | 25% | 160 | 15 | 8 | 3 | 1 |
| Tank | 15% | 45 | 80 | 20 | 15 | 5 |
| Normal | the rest | 80 | 30 | 10 | 5 | 2 |

Health is multiplied by `1 + wave * 0.15` and damage by `1 + wave * 0.10`.
Contact damage is applied at most twice a second.

### Player and shop

Starting stats live on the `GameState` autoload: 100 max health, speed 200,
damage 15, fire rate 1.0, bullet speed 400, armour 0, and XP and gold
multipliers of 1.0. Incoming damage is reduced by armour, but at least 1
damage always gets through. Position is clamped 18 pixels in from each edge
of the window.

The shop draws three entries from this pool. The labels are the ones shown
on the buttons.

| Label | Stat | Change | Cost |
| --- | --- | ---: | ---: |
| +25 Max HP | `max_health` | +25, and current health rises by 25 up to the new maximum | 8 |
| +5 Damage | `damage` | +5 | 10 |
| +0.3 Fire Rate | `fire_rate` | +0.3 | 12 |
| +30 Speed | `speed` | +30 | 6 |
| +2 Armor | `armor` | +2 | 8 |
| +80 Bullet Speed | `bullet_speed` | +80 | 7 |
| +20% XP | `xp_mult` | +0.2 | 5 |
| +20% Gold | `gold_mult` | +0.2 | 5 |

A button is disabled when you cannot afford it. A bought upgrade cannot be
bought again in that shop.

Circles are drawn in code. There are no sprite or audio files.

## Controls

Movement is read in `scenes/player/Player.gd` with
`Input.get_axis("ui_left", "ui_right")` and
`Input.get_axis("ui_up", "ui_down")`. This project does not define an input
map, so the engine defaults for those actions apply. On Godot 4.6.3 they are
the arrow keys, the gamepad D-pad, and the left stick. WASD is not bound.

| Input | What it does |
| --- | --- |
| Arrow keys | Move |
| Gamepad D-pad or left stick | Move, through the built-in `ui_left`, `ui_right`, `ui_up`, and `ui_down` actions |
| (none) | The weapon fires by itself at the nearest enemy, and only while an enemy exists |
| Mouse click | Shop upgrades, Continue to Wave, and Play Again |

Shop and death buttons are ordinary `Button` nodes. The scripts do not call
`grab_focus()`, so keyboard or gamepad UI focus is not set up for them.

## Accessibility notes

**Input options.** Movement uses `ui_left`, `ui_right`, `ui_up`, and `ui_down` (Godot's built-in actions). Arrow keys and gamepad D-pad/left stick are bound by default. WASD is not bound. The weapon fires automatically; there is no fire button to press. Shop and death-screen buttons require a mouse click: `grab_focus()` is not called anywhere, so keyboard and gamepad navigation of those buttons is not available.

**Colour reliance.** The HP counter in the HUD changes colour as health falls: white above 60%, orange between 30% and 60%, and red below 30% (`scenes/game/Game.gd`). The numeric HP value is always shown alongside the colour change, so the information is not conveyed by colour alone. Enemy types and the player are distinguished by circle size and fill colour; there is no text label or shape variation for enemy type in-game.

**Flashing.** When the player takes damage, the player circle flashes red for 0.15 seconds (`scenes/player/Player.gd`). The flash is brief and confined to the player circle. Players sensitive to flashing effects should be aware of this.

**Text size.** Rendered font sizes: HUD labels 18 px, shop title 26 px, shop upgrade buttons 17 px, death screen title 56 px, death info 21 px. Sizes are set in code and do not scale with operating-system accessibility settings. The engine default font is used throughout.

**Audio.** There is no audio. No sounds or music play at any point.

## Run

1. Install Godot 4.6. `project.godot` declares the 4.6 feature tag. The
   check in this repository uses Godot 4.6.3 stable, the latest 4.6
   maintenance release.
2. Open this folder in the Godot project manager (`project.godot`).
3. Press F5, or run `scenes/game/Game.tscn`. That scene is the main scene.

There are no extra packages and no assets to import by hand.

## Build

There is no `export_presets.cfg`, so this repository does not export a
binary. The build check is a headless import, which scans the project and
loads scripts, followed by a two-frame boot of the main scene.

With Godot 4.6.3 on your `PATH`:

```bash
godot --headless --path . --import --quit
godot --headless --path . --quit-after 2
```

Godot can print a script error and still exit 0. Treat any `SCRIPT ERROR`,
`Parse Error`, `Compile Error`, or `Failed to load script` line as a failed
build. A headless editor import may also print `ERROR: Malformed message!`
from the debug adapter. That line is not a script failure.

GitHub Actions runs the same two commands on pull requests and on pushes to
`master`. See [`.github/workflows/build.yml`](.github/workflows/build.yml).

## Layout

```
project.godot              Godot 4.6 project, main scene, GameState autoload
scenes/game/               Wave loop, shop, death screen, HUD
scenes/player/             Movement, health, armour
scenes/enemies/            Chase behaviour and the three enemy types
scenes/weapons/            Auto-fired weapon and bullets
scripts/GameState.gd       Run stats, XP, gold, and the upgrade pool
```

## Licence

MIT. See [MIT Licence](LICENSE).
