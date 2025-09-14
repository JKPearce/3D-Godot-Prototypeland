extends RigidBody3D
class_name Interactable

@onready var parent: Node3D = get_parent()

@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D



func interact() -> void:
	if parent.has_method("interact"):
		parent.interact()
	else:
		printerr("Parent node of an interactable Static Object does not have a configured Interact method", self)


func get_interact_label_text() -> String:
	var label: String = "Press E to interact" #default override 
	if parent.has_method("get_interact_label_text"):
		label = parent.get_interact_label_text()
	else:
		printerr("Parent node of an interactable Static Object does not have a configured Interact method", self)
	
	return label


func toggle_collisions_off(value: bool) -> void:
	self.freeze = value
	collision_shape_3d.disabled = value
