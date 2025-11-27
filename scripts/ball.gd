extends CharacterBody2D

@export var speed = 150
@onready var initialVelocity = Vector2(speed, speed)
var launched = 0
var bricksDestroyed = 0
@onready var bricksScene = preload("res://bricks.tscn")
@onready var gameOverScene = preload("res://gameover.tscn")
@onready var brickBreakEffectScene = preload("res://breakeffect.tscn")
var lives = 3
var score = 0
var highScore
@onready var paddle = $"/root/Main/Paddle"

# Check if the player clicked, and launch the ball if they did, and if they didn't make the ball follow the paddle when the mouse moves
func _input(event):
	if event.is_action_pressed("click") and !lives == 0:
		launched = 1
	if launched == 0 and not (paddle.position.x > 600 or paddle.position.x < 40):
		self.position.x = paddle.position.x

# Makes the ball move, bounce, and detect collision
func _physics_process(delta):
	var collider = move_and_collide(initialVelocity * delta * launched)
	
	if collider:
		var collidingObject = collider.get_collider()
		print(collidingObject.name)
		print(collidingObject.collision_layer)
		print(collidingObject.get_parent().name)
		
		# Check if the ball has collided with anything that can make it bounce or a brick
		if collidingObject.collision_layer == 1 or  collidingObject.collision_layer == 2 or collidingObject.collision_layer == 16:
			var bounce = collider.get_normal()
			initialVelocity = initialVelocity.bounce(bounce)
			if abs(initialVelocity.x)>abs(initialVelocity.y)*07 or abs(initialVelocity.y)>abs(initialVelocity.x)*07:
				initialVelocity = Vector2(speed*sign(initialVelocity.x), speed*sign(initialVelocity.y))
			$bounceSFX.play()
			print(bounce)
		
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
			$"breakSFX".play()
			
			# Add the effect for breaking the brick
			var brickBreakFX = brickBreakEffectScene.instantiate()
			brickBreakFX.position = collidingObject.global_position
			brickBreakFX.modulate = collidingObject.get_parent().modulate
			
			if bricksDestroyed == 20:
				collidingObject.get_parent().get_parent().queue_free()
				print("All bricks destroyed!")
				allBricksBroken()
			else:
				add_sibling(brickBreakFX)
			print(bricksDestroyed)
			
		# Lose a life and reset the ball if it goes under the paddle
		if collidingObject.collision_layer == 8:
			lives -= 1
			launched = 0
			removeLifeTexutre()
			if lives > 0:
				self.position.y = 430
				self.position.x = $"/root/Main/Paddle".position.x
				initialVelocity = Vector2(speed, speed)
			else:
				gameOver()
				self.visible = false
			screenShake(20, 250)
			$lifeLossSFX.play()
			
			print("Lives: " + str(lives))

# Sparkled effect for updating the sprite when you lose a life
func removeLifeTexutre():
	var lifeTexture = get_node("/root/Main/LivesCounter/life" + str(lives+1))
	
	for i in 3:
		lifeTexture.texture = load("res://sprites/miniball.png")
		await get_tree().create_timer(0.2).timeout
		lifeTexture.texture = load("res://sprites/miniballoutline.png")
		await get_tree().create_timer(0.2).timeout

# Really juicy screen shake effect, so much sparkle in there
func screenShake(shakeAmount, shakeLength):
	var camera = $"/root/Main/Camera"
	var random = RandomNumberGenerator.new()
	
	for i in shakeLength:
		camera.offset.x = round(random.randf_range(shakeAmount*-1, shakeAmount)/i*5)/4
		camera.offset.y = round(random.randf_range(shakeAmount*-1, shakeAmount)/i*5)/4
		
		await get_tree().create_timer(0.01).timeout
	
	camera.offset = Vector2(0, 0)

# Resummon the bricks once they're all destroyed, bring the ball back to the paddle, make it faster each time, and have a larger screen shake
func allBricksBroken():
	var loadBricks = bricksScene.instantiate()
	add_sibling(loadBricks)
	bricksDestroyed = 0
	
	launched = 0
	self.position.y = 430
	self.position.x = $"/root/Main/Paddle".position.x
	
	speed = speed * 1.1
	initialVelocity = Vector2(speed, speed)
	screenShake(10, 20)
	
	# Make the ball flash after the bricks respawn
	for i in 3:
		self.visible = true
		await get_tree().create_timer(0.1).timeout
		self.visible = false
		await get_tree().create_timer(0.1).timeout
	self.visible = true

# Save the user's high score and show the game over screen
func gameOver():
	var saveFile = FileAccess.open("user://savegame.save", FileAccess.READ_WRITE)
	var gameOverScreen = gameOverScene.instantiate()
	
	# Find the high score in the save files
	if FileAccess.file_exists("user://savegame.save"):
		var json_text = saveFile.get_as_text()
		var data = JSON.parse_string(json_text)
		print(data)
		
		if typeof(data) == 3:
			highScore = int(data)
		else:
			print("Invalid JSON structure. Structure is " + str(typeof(data)))
			highScore = 0
	else:
		print("Failed to open file.")
		highScore = 0
	
	# Update the high score if the score is bigger than the high score
	if score > highScore:
		highScore = score
		saveFile.store_line(JSON.stringify(highScore))
		highScoreFlash(gameOverScreen.get_node("Score"))
	
	
	gameOverScreen.get_node("Score").text = "Score: " + str(score)
	gameOverScreen.get_node("HighScore").text = "High Score: " + str(highScore)
	add_sibling(gameOverScreen)

# Add a small flashing effect for the score when you get a high score
func highScoreFlash(highScoreText):
	while true:
		highScoreText.modulate = Color(1.0, 0.7, 0.0, 1.0)
		await get_tree().create_timer(0.3).timeout
		highScoreText.modulate = Color(1.0, 1.0, 1.0, 1.0)
		await get_tree().create_timer(0.3).timeout
