extends CharacterBody2D

var speed = 200
var initialVelocity # Initial velocity (speed and direction)
var launched = 0

func _ready():
	initialVelocity = Vector2(speed, -200)

func _input(event):
	if event.is_action_pressed("click"):
		launched = 1
	if launched == 0:
		self.position.x = $"/root/Main/Paddle".position.x - 320

func _physics_process(delta):
	# Move the object and detect collisions
	var collider = move_and_collide(initialVelocity * delta * launched)
	
	if collider:
		# Change direction based on collision
		print(collider.get_collider().name)
		initialVelocity = initialVelocity.bounce(collider.get_normal())
		print(initialVelocity)
		await get_tree().create_timer(0.01).timeout
