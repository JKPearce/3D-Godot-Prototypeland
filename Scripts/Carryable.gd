extends Node3D
class_name Carryable

#main interface for all carryable objects in the game

@onready var player: Player = GameManager.player_node
@export var rigid_body: RigidBody3D
@export var collision_shape: CollisionShape3D

var original_parent: Node3D
var drop_distance := Vector3(0, -0.5, -1.5)

var is_held := false
var tooltip_text: String = "Press E to Pickup Item" #default, should be set in every objects _ready()


func toggle_collisions_off(value: bool) -> void:
	rigid_body.freeze = value
	collision_shape.disabled = value
	is_held = value #Freeze and disable will be true when player is holding so i can just piggyback here and toggle the is_held in same call


func interact() -> void:
	if is_held:
		drop()
	else:
		pick_up()


func pick_up():
	player.holding_item = self
	toggle_collisions_off(true)
	
		# Reparent to socket
	original_parent = get_parent()
	original_parent.remove_child(self)
	player.hand_socket.add_child(self)

	# Reset local transform so it sits correctly in hand
	transform = Transform3D(Basis(), drop_distance)
	rigid_body.global_transform = global_transform


func drop():
	player.holding_item = null
	toggle_collisions_off(false)
	
		# Reparent back to world
	player.hand_socket.remove_child(self)
	original_parent.add_child(self)

	# Put it a little in front of the player
	global_transform = player.cam.global_transform.translated_local(drop_distance)
	rigid_body.global_transform = global_transform


func throw(force: float) -> void:
	drop()
		# Apply throw impulse in camera forward direction
	var dir = -player.cam.global_transform.basis.z.normalized()
	rigid_body.apply_impulse(dir * force, Vector3.ZERO)


func use() -> void:
	push_warning("Tried to use %s, but no use() function is implemented!" % [self.name])
