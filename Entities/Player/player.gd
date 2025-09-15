extends CharacterBody3D
class_name Player


#raycast
@onready var ray: RayCast3D = %RayCast3D
var last_hit: Node = null #To track the last hit node with the ray - used to stop constantly emitting signals when there was no changes to emit and also track for input

#camera
@onready var cam: Camera3D = %Camera
@export var camera_sens := 0.2
var pitch := 0.0

#movement
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOVE_LERP := 10.0  # higher = snappier, lower = floatier
var target_vel: Vector3

var controls_enabled := true

var holding_item: Carryable = null
@onready var hand_socket: Node3D = %HandSocket

var throw_charge := 0.0
var throw_charge_max := 1.5  # seconds to reach full power
var throw_force := 15.0
var charging := false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameManager.register_player(self)
	cam.current = true


func _input(event: InputEvent) -> void:
	if !controls_enabled:
		return

	#throw item
	if event.is_action_pressed("right_click") and holding_item:
		throw_charge = 0.0
		charging = true

	#throw item
	if event.is_action_released("right_click") and holding_item:
		var power = throw_charge / throw_charge_max
		holding_item.throw(power * throw_force)
		charging = false

	#interact with item
	if event.is_action_pressed("interact"):
		if holding_item:
			holding_item.interact()
		elif last_hit and last_hit.has_method("interact"):
			last_hit.interact()
	
	#use item
	if event.is_action_pressed("left_click") and holding_item:
		holding_item.use()


	#handle mouse release and capture
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


	#handle character camera movement
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * camera_sens * 0.01
		pitch = clamp(pitch - event.relative.y * camera_sens * 0.01, deg_to_rad(-80), deg_to_rad(80))
		cam.rotation.x = pitch

	#continue _input
	


func _physics_process(delta: float) -> void:
	if !controls_enabled:
		return

	if charging:
		throw_charge = clamp(throw_charge + delta, 0, throw_charge_max)

	handle_movement(delta)

	if ray.is_colliding():
		var hit = ray.get_collider().owner
		if hit != last_hit: #only fire if something new is being looked at
			last_hit = hit
			if hit.has_method("interact"):
				EventManager.display_interact_label.emit(hit.tooltip_text) #get the string for interactable to display and tell UI to display it
	else:
		if last_hit != null: #only fire when we actually stop looking at something
			last_hit = null
			EventManager.hide_interact_label.emit() #get the string for interactable to display and tell UI to display it
	
	#continue physics func
	



func _notification(what: int) -> void:
	if !controls_enabled:
		return

	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Calculate desired direction
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if dir:
		target_vel.x = dir.x * SPEED
		target_vel.z = dir.z * SPEED
	else:
		target_vel.x = 0
		target_vel.z = 0

	# Lerp current horizontal velocity toward target
	velocity.x = lerp(velocity.x, target_vel.x, MOVE_LERP * delta)
	velocity.z = lerp(velocity.z, target_vel.z, MOVE_LERP * delta)

	move_and_slide()

#used to turn the controls on and off in the player controls
func toggle_player_controls(toggle: bool) -> void:
	controls_enabled = toggle

#used to toggle the camera in the player node
func toggle_player_camera(toggle: bool) -> void:
	cam.current = toggle
