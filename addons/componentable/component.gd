@abstract class_name Component
extends Node

signal ProcessFinished
signal PhysicsProcessFinished

@export var active: bool = true:
	set(value):
		active = value
		set_process(value)
		set_physics_process(value)

@onready var parent = (func():
	parent = get_parent()
	while parent.name.to_lower().contains("component"):
		parent = parent.get_parent()
	parent.set_meta("component_count", parent.get_meta("component_count", 0) + 1)
	var holders = parent.get_meta("component_holders", []) as Array
	if not holders.has(get_parent()):
		holders.append(get_parent())
	parent.set_meta("component_holders", holders)
	set_meta("owner", parent)
	return parent
	).call()

func _exit_tree() -> void:
	parent.set_meta("component_count", parent.get_meta("component_count", 0) - 1)

func get_component(component: Script) -> Component:
	var holders = parent.get_meta("component_holders", [])
	assert(len(holders) > 0, "holders == 0, should be at least 1")
	for holder in holders:
		var children = holder.get_children()
		for child in children:
			if child.get_script() == component:
				return child
	return null

static func get_component_on_node(node: Node, component: Script) -> Component:
	if node is Component:
		return node.get_component(component)
	else:
		var holders = node.get_meta("component_holders")
		if not holders:
			return null
		for holder in holders:
			var children = holder.get_children()
			for child in children:
				if child.get_script() == component:
					return child
	return null

func _process(delta: float) -> void:
	process(delta)
	ProcessFinished.emit()

func _physics_process(delta: float) -> void:
	physics_process(delta)
	PhysicsProcessFinished.emit()

func process(_delta: float): pass
func physics_process(_delta: float): pass