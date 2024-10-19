extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var aim_line: Line2D = $AimLine  # Reference to Line2D in the Goblin node

const SPEED = 150.0
const JUMP_VELOCITY = -200.0
const PICKUP_DISTANCE = 30
const MaxThrowForce = 200
const ThrowChargeRate = 35

var holding_rat = false
var rat_node = null
var pickup_able = false
var throw_force = 0.0
var charging_throw = false

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
	elif holding_rat and Input.is_action_just_pressed("GoblinAction"):
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
			#print (throw_force)
			update_aim_line()
			animated_sprite_2d.play("charging")
		elif charging_throw and Input.is_action_just_released("Throw"):
			charging_throw = false
			holding_rat = false
			animated_sprite_2d.play("throwing")
			throw_rat()
			update_aim_line()
	if not holding_rat and not Input.is_action_just_pressed("Throw"):
		throw_force = max(0, throw_force - ThrowChargeRate * delta)
		update_aim_line()
		if throw_force > 0: # just used to see throw force number go buur
			pass
			#print(throw_force)
		if throw_force <= 0:
			aim_line.set_visible(false)
			throw_force = 0

#Attempt #2 at aim line using youtube tutorial
func update_aim_line():
	var aim_angle = -30.0
	var angle_radians = deg_to_rad(aim_angle)
	
	var initial_velocity = Vector2(
		throw_force * cos(angle_radians), # horizontal velocity
		throw_force * sin(angle_radians) # vertical velocity
	)
	
	#clears points
	aim_line.clear_points()
	var start_position = Vector2(0,0)
	
	var num_points = 50 #how many points it draws
	var time_step = 0.15
	
	for i in range(num_points):
		var t = i * time_step
		var position_x = start_position.x + initial_velocity.x * t
		var position_y = start_position.y + initial_velocity.y * t + (0.5 * 98.0 * t * t)
		
		aim_line.add_point(Vector2(position_x, position_y))
	
	

# Apply the throw to the rat
func throw_rat():
	rat_node.visible = true
	rat_node.enable_collision()
	rat_node.velocity = Vector2(throw_force, -throw_force * 0.5)  # Apply horizontal and vertical velocity
	animated_sprite_2d.play("default")
	aim_line.set_visible(false)
