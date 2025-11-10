extends CharacterBody2D

func _process(delta):
	self.position.x = get_global_mouse_position().x
