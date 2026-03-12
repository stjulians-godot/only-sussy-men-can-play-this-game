extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -500.0
# Load the bullet scene
var bullet_scene = preload("res://prefabs/bullet.tscn")
@onready var sniper: Sprite2D = $sniper
@onready var spawn_point: Marker2D = $spawn_point




func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):#and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("LMB"):
		shoot()

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if direction < 0 and not sniper.flip_h:
			sniper.flip_h = true
			sniper.position.x *= -1
			spawn_point.position.x *= -1
			
		elif direction > 0 and sniper.flip_h:
			sniper.flip_h = false
			sniper.position.x *= -1
			spawn_point.position.x *= -1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func shoot():
	# Create a bullet
	var bullet = bullet_scene.instantiate()
	
	# Position it at the spawn point
	bullet.position = spawn_point.global_position	
	
	# Set direction based on facing
	"""
	if facing_right:
		bullet.direction = Vector2.RIGHT
	else:
		bullet.direction = Vector2.LEFT
	"""
	
		
	# Add bullet to the scene
	get_tree().root.add_child(bullet)
