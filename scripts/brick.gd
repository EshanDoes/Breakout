extends StaticBody2D

func _physics_process(delta):
	var collider = move_and_collide(Vector2(0, 0))
	
	if collider:
		pass
