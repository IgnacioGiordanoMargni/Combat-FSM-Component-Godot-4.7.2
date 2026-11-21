# Combat FSM Engineer

A self-contained Godot 4.7.2 portfolio component that demonstrates a clean combat finite-state machine, data-driven attacks, combo buffering, hit/hurt/stun handling, and a debug HUD.

This project is intentionally asset-free: fighters are primitive meshes with procedural feedback, so the code and architecture are the showcase.

## Run it

Open the folder in Godot 4.7.2 and press F6, or set `scenes/demo/combat_demo.tscn` as the main scene (already configured in `project.godot`).

```text
WASD       Move
J          Light attack
K          Heavy attack
L          Block (hold)
R          Reset both fighters
```

Light attacks chain `Light 1 > Light 2 > Light Finisher`. Heavy attacks chain `Heavy 1 > Heavy Finisher`. Press the next attack during the combo window shown by the `COMBO` label.

## What this demonstrates

- **Typed FSM core** — `CombatFSM` registers `CombatState` children, wires transition requests, and emits `state_changed`.
- **Data-driven attacks** — `AttackData` resources define timing, damage, stun, knockback, lunge, combo links, and pose tint. Designers can add attacks without editing state logic.
- **Explicit state ownership** — states own their timers and transition rules; the fighter owns shared systems (health, stun, hitbox/hurtbox, movement, visuals).
- **One-hit-per-attack** — `HitboxComponent` tracks target instance IDs during its active window so a single swing cannot multi-hit.
- **Reactable combat** — hits push into `Hurt`, high stun pushes into `Stunned`, blocking reduces damage/stun/knockback and avoids reactions, and zero health commits to `Death`.
- **Readable debug surface** — the HUD exposes state, health, stun, current attack, and buffered next attack for both fighters.
- **Drop-in input map** — `InputActions.ensure_actions()` registers the action names at runtime, so the component does not depend on hand-edited Project Settings.

## Structure

```text
scripts/
  core/
    combat_fsm.gd          # State registry and transition authority
    combat_state.gd        # Base state contract
    input_actions.gd       # Runtime input-action registration
  combat/
    attack_data.gd         # Attack definition Resource
    fighter.gd             # Entity façade and shared combat systems
    health_component.gd
    stun_component.gd
    hitbox_component.gd
    hurtbox_component.gd
    fighter_visuals.gd     # Procedural pose/color feedback
  states/
    idle_state.gd
    run_state.gd
    block_state.gd
    attack_state.gd        # Generic AttackData-driven swing state
    hurt_state.gd
    stunned_state.gd
    death_state.gd
  demo/
    combat_demo.gd         # Arena wiring, camera, reset
  ui/
    combat_hud.gd          # Runtime-built debug HUD

resources/attacks/         # Five AttackData .tres files
scenes/entities/fighter.tscn
scenes/demo/combat_demo.tscn
docs/COMPONENT_CONTRACT.md
```

## Portfolio talking points

1. **FSM as a component, not a giant match statement.** States are nodes with explicit enter/exit/update hooks and a single transition authority.
2. **Designer-tunable combat timing.** Active frames, combo windows, and stun are resource data, not magic numbers buried in code.
3. **Deterministic hit detection.** The hitbox activates only during the resource-defined window and ignores repeat contacts with the same target.
4. **Separation of simulation and presentation.** Combat logic emits signals; visual feedback reacts without owning gameplay state.
5. **Network-ready boundary.** The component has no global singletons and exposes state/health/combo signals that an authority layer could replicate later.
