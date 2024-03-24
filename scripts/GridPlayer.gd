extends KinematicBody

onready var cam = $Camera
onready var button_duration = $Timer
onready var meh = $Mesh

onready var collision_node = get_node("/root/MAIN")
var speed = 5
var angle_speed = 10
var current_dir = Vector3()
var next_pos = Vector3()
var destination = Vector3()
var can_move = false
var GridUp = Vector3(0,0,-1) #-4 /// #Vector3.FORWARD
var GridDown = Vector3(0,0,1) #4 /// #Vector3.BACK
var GridLeft = Vector3(-1,0,0) #-4 /// #Vector3.LEFT
var GridRight = Vector3(1,0,0) #4/// #Vector3.RIGHT

func _ready():
	current_dir = "up"
	next_pos = Vector3.FORWARD
	destination = translation

func _physics_process(delta):
	translation = translation.move_toward(destination,speed * delta)
	$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(-next_pos.x, -next_pos.z), delta * angle_speed)
	
	#state
	
	if !translation + Vector3.FORWARD in collision_node.collision:
		if Input.is_action_pressed("walk_front") and button_duration.is_stopped():
			next_pos = Vector3.FORWARD
			current_dir = "up"
			can_move = true
			button_duration.start()
	if !translation + Vector3.BACK in collision_node.collision:
		if Input.is_action_pressed("walk_back") and button_duration.is_stopped():
			next_pos = Vector3.BACK
			current_dir = "down"
			can_move = true
			button_duration.start()
	if !translation + Vector3.LEFT in collision_node.collision:
		if Input.is_action_pressed("look_left") and button_duration.is_stopped():
			next_pos = Vector3.LEFT
			current_dir = "left"
			can_move = true
			button_duration.start()
	if !translation + Vector3.RIGHT in collision_node.collision:
		if Input.is_action_pressed("look_right") and button_duration.is_stopped():
			next_pos = Vector3.RIGHT
			current_dir = "right"
			can_move = true
			button_duration.start()
		
	if translation.distance_to(destination) <= 0.0000 and can_move:
		destination = translation + (next_pos)
		destination = translation + (next_pos)
		can_move = false


