# Slow Walkers (Godot 4.3)

First-person street walk built from the Dodge the Creeps cut-out assets.
Open the folder in the Godot 4 project manager (Import, select `project.godot`). Press F5.

## How it plays

Walk 300 m up a crowded street to the finish gate. Patience is the health bar.

- Patience drains while a walker is directly in front of you. It drains faster the closer they are.
- Patience drops 12 when you bump a walker.
- Patience refills slowly when the way ahead is clear.
- Sprint with Shift. Stamina runs out, then recovers.
- Lose all patience and you snap. Reach the finish line and your time is saved as a best time.

Controls: WASD or arrows to move, mouse to look, Shift to sprint, Space to start or restart,
Esc frees the mouse. Gamepad: left stick move, right stick look, left shoulder sprint, A start.

## Lanes and groups

The street is split into 5 lanes. Walkers spawn in formations that block lanes:

| Formation | What it is |
|---|---|
| single | One slow walker in a lane |
| pair | Two walkers side by side. Blocks a whole lane |
| stack | 3 to 5 walkers one behind another in one lane |
| row | Walkers abreast across 2 or 3 lanes |
| crowd | A loose group, 2 lanes wide and 2 or 3 deep |
| oncoming | 1 or 2 walkers coming toward you. They step around slow walkers |
| crossing | 1 or 2 walkers crossing the street sideways |

Group members share one pace and keep their formation. A formation only spawns if at least one lane
in that stretch of street stays open. Bumping a walker freezes it for a moment, and anyone following
it stops too.

## Walkers

Sprites are upright billboards. Frames come from `art/`.

| Motion | Sprites |
|---|---|
| Slow walkers ahead of you (same direction) | `e2_away`, `player_up_1/2` |
| Oncoming | `e1_walk_*`, `e2_toward`, `e3_walk`, `e4_walk` |
| Crossing | `player_left_*`, `player_right_*` |

Unused from the old set: the cough and barf frames (`e1_windup`, `e1_cough_splat`, `e1_cough`, `e4_barf`),
`player_down_*`, `player_idle`, `player_hit_*`, `player_victory`, `player_lookback`, `player_faceleft`.

`art/street.jpg` is the floor. `art/facade.png` (building walls) is new and generated, replace it freely.

## Files

- `main.gd`: rules, lanes, formations, spawning, patience, win and lose.
- `player.gd`: movement, sprint, bump check.
- `walker.gd`: the `KINDS` table (weights, speeds, frames) and walker behavior.
- `street.gd`: builds floor, walls, collision, finish gate, distance signs. Street size constants are at the top.
- `hud.gd`: HUD, built in code.

## Tuning

- Lane count, group sizes and mix: `LANE_COUNT`, `STACK_GAP` and the `FORMATIONS` table in `main.gd`.
- Difficulty: constants at the top of `main.gd` (drain, penalty, spawn interval, `MAX_WALKERS`).
- Walker mix and speeds: `KINDS` in `walker.gd`.
- Walker size: `PIXEL_SIZE` in `walker.gd`. Adults are about 1.75 m.
- Street length and width: `LEVEL_LENGTH`, `WIDTH` in `street.gd`.

Audio: `House In a Forest Loop.ogg`, `gameover.wav`, `bump.wav`, `finish.wav` are generated
stand-ins. Replace the files in place to use your own.
