extends KinematicBody

export(float) var speed := 9.5
export(float) var gravity := 14.5
export(float) var jump_height := 6.7

const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
onready var accel = ACCEL_DEFAULT

var cam_accel = 40
var mouse_sensitivity :float = 0.1
var snap = 0

var direction = Vector3.ZERO
var velocity = Vector3.ZERO
var gravity_vec = Vector3.ZERO
var movement = Vector3.ZERO

var mouse_visible :bool = false

onready var rotation_pivot := $RotationPivot
onready var camera := $RotationPivot/Camera
onready var aimcast := $RotationPivot/Camera/Aimcast

func _ready() -> void:
	var screen_size = OS.get_screen_size(0)
	var window_size = OS.get_window_size()
	
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		rotation_pivot.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		rotation_pivot.rotation.x = clamp(rotation_pivot.rotation.x, deg2rad(-89), deg2rad(89))

func _process(delta: float) -> void:
	if mouse_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif !mouse_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(rotation_pivot.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = rotation_pivot.rotation.x
	else:
		camera.set_as_toplevel(false)
		camera.global_transform = rotation_pivot.global_transform

func _physics_process(delta: float) -> void:
	direction = Vector3.ZERO
	
	if Input.is_action_just_pressed("ui_cancel"):
		mouse_visible = !mouse_visible

	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	var h_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump_height
	
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	
	move_and_slide_with_snap(movement, snap, Vector3.UP)




