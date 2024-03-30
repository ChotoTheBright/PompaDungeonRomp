extends Control

onready var player = preload("res://scenes/player.tscn")
onready var env = preload("res://default_env.tres")
onready var viewport = $ViewportContainer/Viewport
onready var BAHUD = $BattleScreen
onready var MapHud = $Map
onready var MapSprite = $MapSprite
onready var maptop1 = $MapSprite2
onready var maptop2 = $MapSprite3
onready var penis = "this does nothing, but at least it's there 8]"
onready var cutscene = get_tree().get_nodes_in_group("cutscene")[0]
onready var exit_sign = $ViewportContainer/Viewport/MAIN/World/STUFF/EXITSIGN
onready var end_trigger = $ViewportContainer/Viewport/MAIN/World/INTERACTION/TriggerCutscene5

var scale_factor = 0.25
var bhud_time = Timer.new()
var hud_up = false
var hasmap = false
var title : bool = true


func _ready():
	MapHud.visible = false
	MapSprite.visible = false
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
	pass



func _root_viewport_size_changed():
	viewport.size = get_viewport().size * scale_factor

func scale_change(_factor):
	_factor = scale_factor
	viewport.size = get_viewport().size * scale_factor

func on_battlestart() -> void: #_on_DualCircles_pressed
	bhud_time.wait_time = 0.5
# warning-ignore:return_value_discarded
	bhud_time.connect("timeout", self, "show_bahud")
	bhud_time.one_shot = true
	add_child(bhud_time)
	bhud_time.start()


func check_map():
	if hasmap:
		if hud_up == true:
			MapHud.visible = false
			MapSprite.visible = false
			hud_up = false
			return
		if hud_up == false:
			MapHud.visible = true
			MapSprite.visible = true
			hud_up = true
			return

func endgamesetup():
	exit_sign.visible = true
	end_trigger.col.disabled = false
	pass

func print_test():
	print("congrats you beat ze game!")


func _unhandled_key_input(event):

	if title == true:
		$title.hide()

	if event.is_action_pressed("menu"):
		
		$pause_screen.on_pause()
