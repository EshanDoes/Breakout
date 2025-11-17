extends CharacterBody2D

# Make the paddle move (commented code caused a lot of lag, currently trying to figure out how to fix it)
func _process(delta):
	if not(get_global_mouse_position().x < 120 or get_global_mouse_position().x > 520):
		self.position.x = get_global_mouse_position().x
	#else: if get_global_mouse_position().x < 120:
	#	self.position.x = 120
	#else: if get_global_mouse_position().x > 520:
	#	self.position.x = 520
