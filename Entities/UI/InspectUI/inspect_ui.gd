extends Control
class_name InspectUI

@onready var cam: Camera3D = %Camera3D
@export var zoom_speed := 0.5
@export var zoom_min := 1.0
@export var zoom_max := 10.0

var rotating := false
var rot_x := 0.0
var rot_y := 0.0
@export var rotate_speed := 0.01
@onready var inspect_model := %InspectModel

func _ready() -> void:
	GameManager.register_inspect_ui(self)


func enter_inspect_mode(item_to_fix) -> void:
	show()
	EventManager.hide_interact_label.emit()
	GameManager.player_node.toggle_player_camera(false)
	GameManager.player_node.toggle_player_controls(false)
	
	cam.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	inspect_model.add_child(item_to_fix.get_mesh().duplicate())


func exit_inspect_mode():
	hide()
	cam.current = false
	GameManager.player_node.toggle_player_controls(true)
	GameManager.player_node.toggle_player_camera(true)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_viewport().set_input_as_handled()  # prevents bleed-through events
	


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		exit_inspect_mode()


	#camera Controls
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		cam.translate(Vector3(0, 0, -zoom_speed))
		cam.position.z = max(zoom_min, cam.position.z)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		cam.translate(Vector3(0, 0, zoom_speed))
		cam.position.z = min(zoom_max, cam.position.z)


	#rotation Controls
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		rotating = event.pressed

	if event is InputEventMouseMotion and rotating:
		rot_x += event.relative.x * rotate_speed
		rot_y += event.relative.y * rotate_speed
		rot_y = clamp(rot_y, deg_to_rad(-80), deg_to_rad(80)) # prevent flipping

		# rebuild rotation from scratch each time
		var basis = Basis()
		basis = basis.rotated(Vector3.UP, -rot_x)
		basis = basis.rotated(Vector3.RIGHT, -rot_y)
		inspect_model.rotation = basis.get_euler()
