extends Spatial

var mouse_mov_x

var sway_threshold := 5
var sway_lerp := 5

export(NodePath) var camera_path
var camera : Camera

export var sway_left : Vector3
export var sway_right : Vector3

export var sway_normal : Vector3

const ADS_LERP := 15

export(Vector3) var default_position
export(Vector3) var ads_position

var default_fov := 70
var ads_fov = 45

var can_ads : = true

func _ready() -> void:
	camera = get_node(camera_path)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_mov_x = -event.relative.x

func _process(delta: float) -> void:
	if mouse_mov_x != null:
		if mouse_mov_x > sway_threshold:
			rotation = rotation.linear_interpolate(sway_left, sway_lerp * delta)
		elif mouse_mov_x < -sway_threshold:
			rotation = rotation.linear_interpolate(sway_right, sway_lerp * delta)
		else:
			rotation = rotation.linear_interpolate(sway_normal, sway_lerp * delta)
	
	if Input.is_action_pressed("aim"):
		if can_ads:
			transform.origin = transform.origin.linear_interpolate(ads_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, ads_fov, ADS_LERP * delta)
	else:
		transform.origin = transform.origin.linear_interpolate(default_position, ADS_LERP * delta)
		camera.fov = lerp(camera.fov, default_fov, ADS_LERP * delta)



