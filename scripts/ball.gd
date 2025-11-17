extends CharacterBody2D

var speed = 200
var initialVelocity # Initial velocity (speed and direction)
var launched = 0
var bricksDestroyed = 0
var bricksGroup
var lives = 3

# Set the initial velocity because the speed variable doesn't apply until the project starts
func _ready():
	initialVelocity = Vector2(speed, -200)
	bricksGroup = $"/root/Main/Bricks"

# Check if the player clicked, and launch the ball if they did, and if they didn't make the ball follow the paddle when the mouse moves
func _input(event):
	if event.is_action_pressed("click"):
		launched = 1
	if launched == 0:
		self.position.x = $"/root/Main/Paddle".position.x

# Makes the ball move and bounce
func _physics_process(delta):
	var collider = move_and_collide(initialVelocity * delta * launched)
	
	if collider:
		print(collider.get_collider().name)
		print(collider.get_collider().collision_layer)
		
		# Check if the ball has collided with anything that can make it bounce or a brick
		if collider.get_collider().collision_layer == 1 or collider.get_collider().collision_layer == 2:
			initialVelocity = initialVelocity.bounce(collider.get_normal())
			print(initialVelocity)
		
		# Break a brick if the ball has collided with one
		if collider.get_collider().collision_layer == 2:
			collider.get_collider().queue_free()
			bricksDestroyed += 1
			if bricksDestroyed == 20:
				print("All bricks destroyed!")
				add_sibling(bricksGroup)
			print(bricksDestroyed)
			
		
		# Lose a life and reset the ball if it goes under the paddle
		if collider.get_collider().collision_layer == 8:
			if lives > 1:
				lives -= 1
				launched = 0
				self.position.y = 430
				self.position.x = $"/root/Main/Paddle".position.x
			if lives == 2:
				$"/root/Main/LivesCounter/life2".texture = load("res://sprites/miniballoutline.png")
			if lives == 1:
				$"/root/Main/LivesCounter/life1".texture = load("res://sprites/miniballoutline.png")
			if lives == 0:
				self.queue_free()
			print("Lives: " + str(lives))
