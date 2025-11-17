extends CharacterBody2D

# Make the paddle move
func _input(event):
	self.position.x = get_global_mouse_position().x
