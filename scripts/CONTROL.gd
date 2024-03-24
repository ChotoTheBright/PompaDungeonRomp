extends Control

onready var player = preload("res://scenes/player.tscn")
onready var env = preload("res://default_env.tres")
onready var viewport = $ViewportContainer/Viewport
onready var HUD = $HUD
onready var penis = "this does nothing, but at least it's there 8]"
var scale_factor = 0.25

func _ready():
#	HUD.visible = false
	env.set_fog_enabled(true)
	#----#This is to set the initial scale of the game
	viewport.size = get_viewport().size * scale_factor
	# warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_root_viewport_size_changed")
	_root_viewport_size_changed()
	#----#End of scaling section



func _process(_delta):
	pass

func show_hud():
	HUD.visible = true
	pass


func _root_viewport_size_changed():
	viewport.size = get_viewport().size * scale_factor

func scale_change(_factor):
	_factor = scale_factor
	viewport.size = get_viewport().size * scale_factor
