extends Area2D

var bullet_speed := 2000.0
var direction := 1
 
func _process(delta):
	position.x += bullet_speed * direction * delta
	
	
# changes bullet direction. It gets the direction from the player's script.
func set_direction(dir):
	direction = dir
	
	# if the bullet is going left
	if dir < 0:
		# changes the bullet sprite 
		$anim.scale.x = -abs($anim.scale.x)
	else:
		$anim.scale.x = abs($anim.scale.x)
