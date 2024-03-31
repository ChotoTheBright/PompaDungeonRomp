extends Control
onready var player = get_tree().get_nodes_in_group("player")[0]
onready var control = get_tree().get_nodes_in_group("control")[0]
onready var _anim = $AnimationPlayer
onready var _label = $Label
onready var _timer = $RemoveTextTimer
onready var _timer2 = $Timer2
onready var _scene = 0

func _ready():
	
	pass

func set_scene(_event):
	_scene = _event
	match _scene:
		0:
			control.hasmap = true
			_anim.play("fade")
			_label.text = "You have found the map! You can open and close it at any time by pressing the M key." #+ str(health)
			_timer.start()
		1:
			_anim.play_backwards("fade")
			_label.text = " "
			_timer.stop()
		2:
			control.maptop1.visible = true
			pass
		3:
			control.maptop2.visible = true
			pass
		4:
			_anim.play("fade")
			_label.text = "You have found the map! You can open and close it at any time by pressing the M key." #+ str(health)
			_timer.start()
		5:
			_anim.play("fade")
			_label.text = "You have found 3 Knives and 2 Potions! Remember, items are consumed with use" #+ str(health)
			_timer.start()
		6:
			_anim.play("fade")
			_label.text = "You have found 6 Bandages!"
			_timer.start()
		7:
			_anim.play("fade")
			_label.text = "You have found 4 Web Balls!"
			_timer.start()
		8:
			_anim.play("fade")
			_label.text = "You have found 6 Fuzzy Dust!"
			_timer.start()
		9:
			_anim.play("fade")
			_label.text = "You have found 3 Spheres!"
			_timer.start()
		10:
			_anim.play("fade")
			_label.text = "You have found 4 Bandages and 8 Throwing Knives!"
			_timer.start()

func fade_out():
	_anim.play_backwards("fade")
	_label.text = " "
	_timer.stop()
#
