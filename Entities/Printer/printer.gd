extends Node3D
class_name Printer

@onready var audio: AudioStreamPlayer3D = %AudioStreamPlayer3D
@onready var interactable: Interactable = %Interactable

@onready var player: Player = GameManager.player_node

var original_parent

var drop_distance := Vector3(0, 0, -2)


func interact() -> void:	
	pick_up()


func get_interact_label_text() -> String:
	return "Press E to Pick up Printer"


func pick_up():
	player.holding_item = self
	interactable.toggle_collisions_off(true)
		# Reparent to socket
	original_parent = get_parent()
	original_parent.remove_child(self)
	player.hand_socket.add_child(self)

	# Reset local transform so it sits correctly in hand
	transform = Transform3D(Basis())
	interactable.global_transform = global_transform


func drop():
	player.holding_item = null
	interactable.toggle_collisions_off(false)
	
		# Reparent back to world
	player.hand_socket.remove_child(self)
	original_parent.add_child(self)

	# Put it a little in front of the player
	global_transform = player.cam.global_transform.translated_local(drop_distance)
	interactable.global_transform = global_transform


func throw(force: float):
	player.holding_item = null
	interactable.toggle_collisions_off(false)

	# Reparent back
	player.hand_socket.remove_child(self)
	original_parent.add_child(self)

	# Place at camera
	global_transform = player.cam.global_transform.translated_local(Vector3(0, 0, -1))

	# Apply throw impulse in camera forward direction
	var dir = -player.cam.global_transform.basis.z.normalized()
	interactable.apply_impulse(dir * force, Vector3.ZERO)
