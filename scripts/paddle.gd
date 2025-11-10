extends CharacterBody2D

func _process(delta):
	if not(get_global_mouse_position().x < 120 or get_global_mouse_position().x > 520):
		self.position.x = get_global_mouse_position().x
