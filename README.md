# Componentable

A lightweight single class component system for godot based on classes

## Overview

`Component` is a `Node`. Attach subclasses to an entity; other components find each other without manual references.

## Behavior

- `active: bool` — if false, `process()`/`physics_process()` are skipped.
- On `_ready`, finds the owner by walking up past any `Component` parents. Stores `component_count` and `component_holders` meta on it.
- Override `process(delta)` / `physics_process(delta)` instead of the
  underscore versions. Each emits a signal (`ProcessFinished` /
  `PhysicsProcessFinished`) after running.

## API

| Member | Description |
|---|---|
| `active` | Enables/disables processing. |
| `parent` | Resolved owner node (not `get_parent()`). |
| `process(delta)` | Override for per-frame logic. |
| `physics_process(delta)` | Override for per-physics-tick logic. |
| `get_component(class_name)` | Find sibling component by script. |
| `get_component_on_node(node, class_name)` (static) | Find component from any node. |
| `has_component(script)` | True if a sibling matches. |
| `get_components(script)` | All matching siblings. |

## Usage

```gdscript
class_name HealthComponent
extends Component

func process(_delta): pass
```

```gdscript
var health = get_component(HealthComponent)
```

```gdscript
var health = Component.get_component_on_node(entity, HealthComponent)
```

## Notes
- Lookup matches exact script; first match wins.
