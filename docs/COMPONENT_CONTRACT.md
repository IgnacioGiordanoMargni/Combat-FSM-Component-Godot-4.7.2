## Combat FSM component boundary

### Responsibility

Owns entity state transitions, attack sequencing, combo buffering, and combat reactions. It does **not** own networking, menus, Steam, inventory, or tournament flow.

### Public surface

| Type | Purpose |
|---|---|
| `CombatFSM` | Registers `CombatState` children and performs `change_state()`. |
| `CombatState` | Base class for `enter()`, `exit()`, `physics_update()`, and transition requests. |
| `AttackData` | Resource describing one attack: timing, damage, stun, knockback, and combo links. |
| `Fighter` | Entity façade: movement, health, stun, hitbox/hurtbox coordination, visual feedback. |
| `HealthComponent` | Current/max health with `health_changed` and `depleted`. |
| `StunComponent` | Accumulating stun with decay and `stun_changed`. |
| `HitboxComponent` | Active-window Area3D that reports one hit per target per attack. |
| `HurtboxComponent` | Area3D that identifies the receiving fighter. |

### Required inputs from a host project

- A `CharacterBody3D` fighter scene with the component nodes composed as children.
- Input actions: `move_left`, `move_right`, `move_forward`, `move_back`, `light_attack`, `heavy_attack`, `block`, `restart`.
- Optional: a target fighter assigned to `Fighter.look_target`.

### Emitted events

- `CombatFSM.state_changed(previous, current)`
- `Fighter.health_changed(current, maximum)`
- `Fighter.stun_changed(current, maximum)`
- `Fighter.combo_changed(attack_name, buffered_name)`
- `Fighter.hit_confirmed(target, damage)`
- `Fighter.hit_received(damage, from)`
- `Fighter.attack_blocked(from)`
- `Fighter.died(fighter)`

### Deliberately excluded

- Animation clips and rigs: visual feedback is procedural so the demo stays asset-free.
- Multiplayer authority and RPCs.
- Camera behavior beyond the demo's fixed camera.
- Tournament, shop, NPC, and menu systems.
