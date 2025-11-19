extends CharacterBody2D

var speed = 200
var initialVelocity
var launched = 0
var bricksDestroyed = 0
var bricksGroup
var lives = 3
var score = 0

# Set the initial velocity because the speed variable doesn't apply until the project starts
func _ready():
	initialVelocity = Vector2(100, speed)
	bricksGroup = $"/root/Main/Bricks"

# Check if the player clicked, and launch the ball if they did, and if they didn't make the ball follow the paddle when the mouse moves
func _input(event):
	if event.is_action_pressed("click") and !lives == 0:
		launched = 1
	if launched == 0:
		self.position.x = $"/root/Main/Paddle".position.x

# Makes the ball move and bounce
func _physics_process(delta):
	var collider = move_and_collide(initialVelocity * delta * launched)
	
	if collider:
		var collidingObject = collider.get_collider()
		print(collidingObject.name)
		print(collidingObject.collision_layer)
		print(collidingObject.get_parent().name)
		
		# Check if the ball has collided with anything that can make it bounce or a brick
		if collidingObject.collision_layer == 1 or  collidingObject.collision_layer == 2 or collidingObject.collision_layer == 16:
			initialVelocity = initialVelocity.bounce(collider.get_normal())
			print(initialVelocity)
		
		# Break a brick if the ball has collided with one, and add to the amount of bricks that has been broken
		if collidingObject.collision_layer == 2:
			collidingObject.queue_free()
			bricksDestroyed += 1
			
			# Detect how many points you get from destroying a brick
			if collidingObject.get_parent().name == "bottom":
				score += 3
				screenShake(3, 10)
			else: if collidingObject.get_parent().name == "midbottom":
				score += 5
				screenShake(5, 7)
			else: if collidingObject.get_parent().name == "midtop":
				score += 10
				screenShake(7, 5)
			else: if collidingObject.get_parent().name == "top":
				score += 15
				screenShake(9, 3)
			$"/root/Main/Points Text".text = str(score)
			
			if bricksDestroyed == 20:
				print("All bricks destroyed!")
				# Current priority is figuring out how to fix this (Why can't I just do what I usually do in Unity aaaaaaaaaaaaaa)
				add_sibling(bricksGroup)
			print(bricksDestroyed)
			
		# Lose a life and reset the ball if it goes under the paddle
		if collidingObject.collision_layer == 8:
			lives -= 1
			launched = 0
			if lives > 0:
				self.position.y = 430
				self.position.x = $"/root/Main/Paddle".position.x
				removeLifeTexutre()
			screenShake(20, 250)
			
			print("Lives: " + str(lives))

# Sparkled effect for updating the sprite when you lose a life
func removeLifeTexutre():
	var lifeTexture = get_node("/root/Main/LivesCounter/life" + str(lives))
	
	for i in 3:
		lifeTexture.texture = load("res://sprites/miniball.png")
		await get_tree().create_timer(0.1).timeout
		lifeTexture.texture = load("res://sprites/miniballoutline.png")
		await get_tree().create_timer(0.1).timeout

# Really juicy screen shake effect, so much sparkle in there
func screenShake(shakeAmount, shakeLength):
	var camera = $"/root/Main/Camera"
	var random = RandomNumberGenerator.new()
	
	for i in shakeLength:
		camera.offset.x = round(random.randf_range(shakeAmount*-1, shakeAmount)/i*5)/5
		camera.offset.y = round(random.randf_range(shakeAmount*-1, shakeAmount)/i*5)/5
		
		await get_tree().create_timer(0.01).timeout
	
	camera.offset = Vector2(0, 0)
