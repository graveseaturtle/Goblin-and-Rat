extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -200.0
const PICKUP_DISTANCE = 50

var holding_rat = false
var rat_node = null
var pickup_able = false
func _ready():
	rat_node = get_parent().get_node("Rat")
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("GoblinJump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("GoblinMoveLeft", "GoblinMoveRight")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
	#attempts at rat pickup script
	if rat_node and not holding_rat:
		var distance_to_rat = position.distance_to(rat_node.position)
		pickup_able = distance_to_rat <= PICKUP_DISTANCE
		if pickup_able and Input.is_action_pressed("GoblinAction"):
			holding_rat = true
			rat_node.visible = false
			print("rat aquired")
		elif holding_rat and Input.is_action_just_released("GoblinAction"):
			holding_rat = false
			rat_node.position = position + Vector2(20, 0)
			rat_node.visible = true
			print("rat lost :(")
		
	
 
