extends Control

# Ease the game over screen into the screen, and ease out the UI and paddle
func _ready():
	for i in 21:
		var animationProgress = ease(i/20.0, 0.4)
		self.position.y = 10 - (animationProgress * 10)
		self.modulate.a = animationProgress
		$"/root/Main/Points Text".modulate.a = 1 - animationProgress
		$"/root/Main/LivesCounter".modulate.a = 1 - animationProgress
		$"/root/Main/Paddle".modulate.a = 1 - animationProgress
		await get_tree().create_timer(0.01).timeout
		print(animationProgress)

# Detect when the button is presssed and restart the main scene
func _button_pressed():
	get_tree().reload_current_scene()
