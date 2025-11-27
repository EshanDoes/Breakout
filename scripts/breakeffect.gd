extends Node

# Activate the brick breaking effect, including an easing effect for the movement and fading out
func _ready():
	for i in 21:
		var animationProgress = ease(i/20.0, 0.4)
		$bottomright.position = Vector2(animationProgress*50, animationProgress*20)
		$bottomleft.position = Vector2(animationProgress*-50, animationProgress*20)
		$topright.position = Vector2(animationProgress*50, animationProgress*-20)
		$topleft.position = Vector2(animationProgress*-50, animationProgress*-20)
		self.modulate.a = 1-ease(i/20.0, 3.5)
		await get_tree().create_timer(0.01).timeout
	self.queue_free()
