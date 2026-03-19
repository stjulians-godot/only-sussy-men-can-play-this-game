extends Area2D

var speed: float = 600.0
var direction: Vector2 = Vector2.RIGHT
var direction_left: Vector2 = Vector2.LEFT
@onready var anim: AnimatedSprite2D = $anim
@onready var bullet: Area2D = $"."


func _ready():
	if direction == Vector2.LEFT:
		anim.flip_h = true

func _physics_process(delta):
	# Move the bullet
	position += direction * speed * delta
	####
	
	


func _on_body_entered(body):
	# Hit something! Destroy the bullet
	queue_free()
	
	# If we hit an enemy, damage it
	#if body.has_method("take_damage"):
		#body.take_damage(1)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
