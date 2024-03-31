extends Node

export var plyr_audio_dir : String = "res://assets/"
onready var feet1: AudioStreamPlayer = $Steps
onready var feet2: AudioStreamPlayer = $Steps2
onready var feet3: AudioStreamPlayer = $Steps3
var foot_steps = []
var feet_arr = []
var r = RandomNumberGenerator.new()

func _ready():
	r.randomize()
	var dir = Directory.new()
	if dir.open(plyr_audio_dir) == OK:
		dir.list_dir_begin()
		var file = dir.get_next()
		while(file != ""):
			if file.begins_with("Step") and file.ends_with("ogg"):
				foot_steps.append(load(plyr_audio_dir + file))
			elif file.begins_with("Step") and file.ends_with("ogg"):
				feet_arr.append(load(plyr_audio_dir + file))
#			elif file.begins_with("land_concrete") and file.ends_with("ogg"):
#				land_dirt.append(load(plyr_audio_dir + file))
			file = dir.get_next()
	ground_type()


func _process(_delta):
	pass

func footsteps():
	feet1.stream = random_footstep()
	feet1.play()

func random_footstep():
	var length : int
	var i : int
	
	length = feet_arr.size()
	i = r.randi() % length
	if feet_arr[i] == feet1.stream:
		if i > 0 and i < length-1:
			i += (r.randi() & 2) - 1
		elif i == 0:
			i = r.randi_range(1, length-1)
		elif i == length-1:
			i = r.randi_range(0, length-2)
	
	return feet_arr[i]

func ground_type():
	feet_arr = foot_steps
