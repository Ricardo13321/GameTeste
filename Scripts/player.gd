extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var MaxGravity = -50
var GRAVITY = 20
var JUMP_FORCE = 20
var MaxSpeed = 14
var jumping = false
const ACC = 1
var dir
var Slide = -0.1
var MaxSlide = -4
@onready var WallDetector = $WallDetector as RayCast3D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_lefth", "move_right", "move_down", "move_up")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction.x:
		var SpeedX = round(direction.x)
		
		if velocity.x > MaxSpeed:
			velocity.x = MaxSpeed
			
		elif velocity.x < -MaxSpeed:
			velocity.x = -MaxSpeed
			
		velocity.x += SpeedX * ACC
		
		#Usado para verificar se está encontasndo em uma parede, aqui é onde setamos os valores
		WallDetector.rotation.z = 80*-SpeedX
		if WallDetector.rotation.z > 0:
			dir = -1
		else:
			dir = 1
		
	else:
		velocity.x = move_toward(velocity.x,0,ACC)
		
	# Handle Jump
	var jump = Input.is_action_just_pressed("jump")
	var jump_stop = Input.is_action_just_released("jump")
	
	# Add Gravity
	if velocity.y < MaxGravity:
		velocity.y = MaxGravity
		
	if is_on_floor():
		jumping = false
		
	#Veirifica se está colidindo com uma parede
	var Is_Colliding_In_Wall = WallDetector.is_colliding()
	
	if !Is_Colliding_In_Wall:
		if !is_on_floor() and !jump:
			velocity.y -= min(GRAVITY,1)
			
		elif jump and is_on_floor():
			velocity.y = JUMP_FORCE
			jumping = true
			
		if jumping and jump_stop and velocity.y > 0.5:
			velocity.y = 0.5
			jumping = false
	else:
		if velocity.y < MaxSlide:
			velocity.y = MaxSlide
		if !jumping and is_on_floor() and jump:
			jumping = true
			velocity.y = JUMP_FORCE+5
			
		if jumping and jump_stop and velocity.y > 0.5:
			velocity.y = 0.5
			jumping = false
		
		if !is_on_floor() and !jump:
			velocity.y -= min(GRAVITY,1)
			
		if velocity.y <= 0.5 and jumping:
			jumping = false
				
		if !jumping and !is_on_floor():
			if direction.x != 0:
				if jump:
					velocity.x = -10*direction.x
					velocity.y = JUMP_FORCE-5
			else:
				if jump:
					velocity.x = -20*dir
					velocity.y = JUMP_FORCE
					print(dir)
			
	move_and_slide()
