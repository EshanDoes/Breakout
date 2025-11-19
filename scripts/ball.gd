extends CharacterBody2D

var speed = 200
var initialVelocity # Initial velocity (speed and direction)
var launched = 0
var bricksDestroyed = 0
var bricksGroup
var lives = 3

# Set the initial velocity because the speed variable doesn't apply until the project starts
func _ready():
	initialVelocity = Vector2(100, speed)
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
		var collidingObject = collider.get_collider()
		
		# Check if the ball has collided with anything that can make it bounce or a brick
		if collidingObject.collision_layer == 1 or  collidingObject.collision_layer == 2 or collidingObject.collision_layer == 16:
			initialVelocity = initialVelocity.bounce(collider.get_normal())
			print(initialVelocity)
		
		# Break a brick if the ball has collided with one, and add to the amount of bricks that has been broken
		if collidingObject.collision_layer == 2:
			collidingObject.queue_free()
			bricksDestroyed += 1
			if bricksDestroyed == 20:
				print("All bricks destroyed!")
				# Current priority is figuring out how to fix this (Why can't I just do what I usually do in Unity aaaaaaaaaaaaaa)
				add_sibling(bricksGroup)
			print(bricksDestroyed)
			
		if collidingObject.collision_layer == 16:
			var angleFromPaddle = (rad_to_deg(collidingObject.position.angle_to_point(self.position))+90)*2
			print("Angle: " + str(angleFromPaddle))
			initialVelocity = Vector2(angleFromPaddle, initialVelocity.y)
			
		# Lose a life and reset the ball if it goes under the paddle
		if collidingObject.collision_layer == 8:
			if lives > 0:
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
