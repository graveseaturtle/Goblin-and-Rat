extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var aim_line: Line2D = $AimLine  # Reference to Line2D in the Goblin node

const SPEED = 150.0
const JUMP_VELOCITY = -200.0
const PICKUP_DISTANCE = 30
const MaxThrowForce = 100
const ThrowChargeRate = 25

var holding_rat = false
var rat_node = null
var pickup_able = false
var throw_force = 0.0
var charging_throw = false

func _ready():
	rat_node = get_parent().get_node("Rat")  # Rat is still a sibling under the same parent

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("GoblinJump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
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
		if pickup_able and Input.is_action_just_pressed("GoblinAction"):
			holding_rat = true
			rat_node.visible = false
			rat_node.disable_collision()
			print("rat acquired")
			animated_sprite_2d.play("carrying")
	elif holding_rat and Input.is_action_just_released("GoblinAction"):
		holding_rat = false
		rat_node.position = position + Vector2(20, 0)
		rat_node.visible = true
		rat_node.enable_collision()
		print("rat lost :(")
		animated_sprite_2d.play("default")
		
	#throw and throw charge
	if holding_rat:
		if Input.is_action_pressed("Throw"):
			charging_throw = true
			aim_line.set_visible(true)
			throw_force = throw_force + ThrowChargeRate * delta
			if throw_force >= MaxThrowForce:
				throw_force = MaxThrowForce
			print (throw_force)
			update_aim_line()
			animated_sprite_2d.play("charging")
		elif charging_throw and Input.is_action_just_released("Throw"):
			charging_throw = false
			holding_rat = false
			throw_force = throw_force - ThrowChargeRate * delta
			if throw_force <= 0:
				aim_line.set_visible(false)
			animated_sprite_2d.play("throwing")
			update_aim_line()
			
#im kinda clueless on this shit, chatty g 'helped' write it and i think it calculates gravity then draws a line based on that gravity for the rat to follow
func update_aim_line():
	var points = []
	var initial_position = position
	var initial_velocity = Vector2(throw_force, -throw_force * 0.5)
	var gravity = 98.0
	var num_points = 20
	var time_step = 0.1
	aim_line.set_visible(true)
	for i in range(num_points):  # Calculates gravity and draws points along the trajectory
		var t = i * time_step
		var pos = initial_position + initial_velocity * t + Vector2(0, 0.5 * gravity * t * t)
		points.append(pos)
	aim_line.points = points  # Set points directly
	

# Apply the throw to the rat
func throw_rat():
	rat_node.visible = true
	rat_node.position = position
	rat_node.enable_collision()
	rat_node.velocity = Vector2(throw_force, -throw_force * 0.5)
	animated_sprite_2d.play("default")
