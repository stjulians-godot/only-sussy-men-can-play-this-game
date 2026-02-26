extends Area2D

var speed: float = 600.0
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta):
	# Move the bullet
	position += direction * speed * delta

func _on_body_entered(body):
	# Hit something! Destroy the bullet
	queue_free()
	
	# If we hit an enemy, damage it
	if body.has_method("take_damage"):
		body.take_damage(1)
