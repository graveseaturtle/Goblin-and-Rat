extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -200.0
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _physics_process(delta: float) -> void:
	if not visible:
		return # If the rat is not visible, skip movement

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("RatJump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("RatMoveLeft", "RatMoveRight")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
func disable_collision():
	collision_shape_2d.disabled = true
func enable_collision():
	collision_shape_2d.disabled = false
	
