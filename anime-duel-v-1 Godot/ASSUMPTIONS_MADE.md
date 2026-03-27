# Assumptions Made

- The vertical slice uses Godot 4.5 with GDScript and a lightweight 3D presentation stack.
- The visible single-player mini-game always reflects the player's selected action; the AI's matching execution is simulated in the background.
- Soft `Attack vs Evade` cases are resolved as strike-lean exchanges that flip into evade punish on strong evade execution.
- The baseline matchup modifier table is implemented with soft `1.1 / 0.9` and hard `1.25 / 0.75` bands because the GDD defines relationships qualitatively, not numerically.
- Invalid Special at reveal downgrades to defend-equivalent behavior with no meter spend and a guard penalty.
- Replay is a condensed highlight montage driven by logged exchange packets, not deterministic reconstruction.
- Tutorial is a guided first duel built on the main combat scene with forced enemy choices and temporary state setup to expose required beats.
