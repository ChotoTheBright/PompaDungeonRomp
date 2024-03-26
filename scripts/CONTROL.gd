extends Control

onready var player = preload("res://scenes/player.tscn")
onready var env = preload("res://default_env.tres")
onready var viewport = $ViewportContainer/Viewport
onready var BAHUD = $BattleScreen
onready var penis = "this does nothing, but at least it's there 8]"
var scale_factor = 0.25
var bhud_time = Timer.new()

func _ready():
	#BAHUD.visible = false
	env.set_fog_enabled(true)
	#----#This is to set the initial scale of the game
	viewport.size = get_viewport().size * scale_factor
	# warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_root_viewport_size_changed")
	_root_viewport_size_changed()
	#----#End of scaling section



func _process(_delta):
	pass


func show_bahud():
	BAHUD.visible = true
#	HUD.visible = false
	pass



func _root_viewport_size_changed():
	viewport.size = get_viewport().size * scale_factor

func scale_change(_factor):
	_factor = scale_factor
	viewport.size = get_viewport().size * scale_factor

func on_battlestart() -> void: #_on_DualCircles_pressed
	Transitions.dual_circles(2, Color.black) #self, self, 2, Color.black
	bhud_time.wait_time = 0.5
# warning-ignore:return_value_discarded
	bhud_time.connect("timeout", self, "show_bahud")
	bhud_time.one_shot = true
	add_child(bhud_time)
	bhud_time.start()
