class_name Component
extends Node

signal ProcessFinished(delta: float)
signal PhysicsProcessFinished(delta: float)

@export var active: bool = true:
	set(value):
		active = value
		set_process(value)
		set_physics_process(value)

@onready var parent = (func():
	parent = get_parent()
	while parent is Component:
		parent = parent.get_parent()
	parent.set_meta("component_count", parent.get_meta("component_count", 0) + 1)
	var holders = parent.get_meta("component_holders", []) as Array
	if not holders.has(get_parent()):
		holders.append(get_parent())
	parent.set_meta("component_holders", holders)
	set_meta("owner", parent)
	for signal_name in ["component_added", "component_removed"]:
		if not parent.has_user_signal(signal_name):
			parent.add_user_signal(signal_name, [{"name": "component", "type": TYPE_OBJECT}])
	parent.emit_signal("component_added", self)
	return parent
	).call()

func _exit_tree() -> void:
	parent.set_meta("component_count", parent.get_meta("component_count", 0) - 1)
	var holder = get_parent()
	if not holder.get_children().any(func(c): return c != self and c is Component):
		parent.get_meta("component_holders", []).erase(holder)
	parent.emit_signal("component_removed", self)

func get_component(component: Script) -> Component:
	return get_component_on_node(self, component)

func has_component(component: Script) -> bool:
	return not get_components(component).is_empty()

func require_component(component: Script) -> Component:
	var found = get_component_on_node(self, component)
	assert(found, "%s requires a component of type %s" % [name, component.resource_path])
	return found

func get_components(component: Script) -> Array[Component]:
	return get_components_on_node(self, component)

static func get_components_on_node(node: Node, component: Script) -> Array[Component]:
	var result: Array[Component] = []
	if node is Component:
		node = node.parent
	for holder in node.get_meta("component_holders", []):
		if not is_instance_valid(holder):
			continue
		for child in holder.get_children():
			if is_instance_of(child, component):
				result.append(child)
	return result

static func get_component_on_node(node: Node, component: Script) -> Component:
	var found = get_components_on_node(node, component)
	if found.is_empty():
		push_warning("%s has no component of type %s" % [node.name, component.resource_path])
		return null
	return found[0]

func _process(delta: float) -> void:
	process(delta)
	ProcessFinished.emit(delta)

func _physics_process(delta: float) -> void:
	physics_process(delta)
	PhysicsProcessFinished.emit(delta)

func process(_delta: float): pass
func physics_process(_delta: float): pass
