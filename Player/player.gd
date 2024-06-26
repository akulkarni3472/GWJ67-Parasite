extends CharacterBody3D


@export var speed = 20.0
@export var sprint_speed = 3
@export var jump_strength = 10
@export var sensitivity = 0.003

@export var min_view_angle = -50
@export var max_view_angle = 80

@export var bob_freq = 1.2
@export var bob_amp = 0.04
@export var t_bob = 0.0

@export var base_fov = 75.0
@export var fov_change = 1.5

@export var weapon: Node
@export var bullet: Node

@onready var head = $Head
@onready var camera = $Head/Camera
@onready var weapon_mount = $Head/WeaponMount
@onready var gun_base = $Head/WeaponMount/GunBase

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var bullet_emitter
var sprint_mult

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	bullet_emitter = get_node("Head/WeaponMount/GunBase/BulletEmitter")
	
func _unhandled_input(event):
	if event is InputEventMouseMotion: 
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(min_view_angle), deg_to_rad(max_view_angle))
		weapon_mount.rotate_x(-event.relative.y * sensitivity)
		weapon_mount.rotation.x = clamp(camera.rotation.x, deg_to_rad(min_view_angle), deg_to_rad(max_view_angle))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength
	
	if Input.is_action_just_pressed("sprint"):
		sprint_mult = sprint_speed
	else:
		sprint_mult = 1
		
	var input_dir = Input.get_vector("leftward", "rightward", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	fire(delta)
	
	move_and_slide()
	
func fire(delta):
	if Input.is_action_just_pressed("shoot"):
		print("Bang!")

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x - cos(time * bob_freq / 2) * bob_amp
	return pos
