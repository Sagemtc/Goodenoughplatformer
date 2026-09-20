extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -900
const DASH_SPEED = 1400

var dashing = false
var can_dash = true
var air_dash_available = false
var dash_direction = 1

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	
	#reset dash when landing on the ground
	if is_on_floor():
		air_dash_available = true
	
	# Handle dash input
	if Input.is_action_just_pressed("dash") and can_dash and (air_dash_available or is_on_floor()):
		dashing = true
		air_dash_available = false
		can_dash = false
		velocity.y = 0

		# Get dash direction
		dash_direction = Input.get_axis("left", "right")

		# If no direction is pressed, use the direction the player is facing
		if dash_direction == 0:
			dash_direction = -1 if animated_sprite.flip_h else 1

		$dash_timer.start()
		$dash_cooldown.start()

	# Dashing
	if dashing:
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0

	# Normal movement
	else:
		# Add gravity
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump
		if is_on_floor():
			air_dash_available = true
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_VELOCITY

		elif velocity.y < 0.0:
			if Input.is_action_just_released("jump"):
				velocity.y *= 0.5

		# Handle movement
		var direction := Input.get_axis("left", "right")

		if direction:
			velocity.x = direction * SPEED
			animated_sprite.play("walk")
			animated_sprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animated_sprite.play("idle")

	move_and_slide()


func _on_dash_cooldown_timeout() -> void:
	can_dash = true


func _on_dash_timer_timeout() -> void:
	dashing = false
