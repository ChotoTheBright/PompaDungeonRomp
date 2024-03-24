extends KinematicBody

#signal wall_signal
signal battle_signal

onready var GridUp = Vector3(0,0,-2) #FORWARD #*see bottom for ref.
onready var GridDown = Vector3(0,0,2) #BACK
onready var GridLeft = Vector3(-2,0,0) #LEFT
onready var GridRight = Vector3(2,0,0) #RIGHT
onready var mesh = $Mesh
onready var ray_b = $Mesh/Camera/RayBattle
onready var ray_w = $Mesh/Camera/RayWall
var speed = 5
var angle_speed = 10
var current_dir = Vector3()
var next_pos = Vector3()
var destination = Vector3()
var can_move = false
var btn_time : Timer
var inbattle : bool = false

func _ready():
	btn_time = Timer.new()
	btn_time.wait_time = 0.5
# warning-ignore:return_value_discarded
	btn_time.connect("timeout", self, "time_end")
	btn_time.one_shot = true
	add_child(btn_time)
	current_dir = "up"
	next_pos = GridUp
	destination = translation

func _physics_process(delta):
	battle_signal()
	translation = translation.move_toward(destination,speed * delta)
	self.rotation.y = lerp_angle(self.rotation.y, atan2(-next_pos.x, -next_pos.z), delta * angle_speed)
	
	if Input.is_action_pressed("walk_front") and btn_time.is_stopped():
		next_pos = next_pos
		current_dir = current_dir
		if ray_w.is_colliding(): #Wall
			can_move = false
		else:
			can_move = true
		btn_time.start()
	if Input.is_action_pressed("look_left") and btn_time.is_stopped():
		match next_pos:
			GridRight:
				next_pos = GridUp
				current_dir = "up"
				btn_time.start()
				pass
			GridLeft:
				next_pos = GridDown
				current_dir = "down"
				btn_time.start()
				pass
			GridUp:
				next_pos = GridLeft
				current_dir = "left"
				btn_time.start()
				pass
			GridDown:
				next_pos = GridRight
				current_dir = "right"
				btn_time.start()
				pass
#----------------------------------------------------------------------------#
	if Input.is_action_pressed("look_right") and btn_time.is_stopped():
		match next_pos:
			GridRight:
				next_pos = GridDown
				current_dir = "down"
				btn_time.start()
				pass
			GridLeft:
				next_pos = GridUp
				current_dir = "up"
				btn_time.start()
				pass
			GridUp:
				next_pos = GridRight
				current_dir = "right"
				btn_time.start()
				pass
			GridDown:
				next_pos = GridLeft
				current_dir = "left"
				btn_time.start()
				pass

	if translation.distance_to(destination) <= 0.0000 and can_move:
		destination = translation + (next_pos)
		can_move = false

func time_end():
	return

func battle_signal():
	if ray_b.is_colliding(): #Battle
		emit_signal("battle_signal")
		can_move = false
		return

#INFO: Vector3(x,y,z)--FORWARD:0,0,-1,//BACK:0,0,1//RIGHT:1,0,0//LEFT:-1,0,0
func blastinwenis():
	print("peepeepoopoocaca - cathy")
