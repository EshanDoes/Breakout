extends CharacterBody2D

var speed = 200
var initialVelocity = Vector2(speed, 200) # Initial velocity (speed and direction)

func _physics_process(delta):
	# Move the object and detect collisions
	var collision = move_and_collide(initialVelocity * delta)
	
	if collision:
		# Change direction based on collision
		print(collision.get_collider().name)
		
		if collision.get_collider().name == "Wall":
			initialVelocity = initialVelocity.bounce(collision.get_normal())
		else: if collision.get_collider().name == "Paddle":
			#initialVelocity = self.position.angle_to_point(collision.get_collider().position)
			print(self.position)
