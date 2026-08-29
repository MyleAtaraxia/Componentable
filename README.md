# Componentable

A lightweight single class component system for godot based on classes

## Overview

`Component` is an abstract `Node`. Attach subclasses as children of an
entity; other components can then look each other up without manual
references.

## Behavior

- `active: bool` — if false, `process()`/`physics_process()` are skipped.
- On `_ready`, walks up parents (skipping any named `*component*`) to find
  the owning entity node. Stores on that owner:
  - `component_count` meta (incremented/decremented on enter/exit tree)
  - `component_holders` meta (list of direct parent nodes of components)
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
- Holder nodes must not have "component" in their name, or they get skipped.
- Lookup matches exact script; first match wins.
- Requires Godot 4.3+ for `@abstract`.
