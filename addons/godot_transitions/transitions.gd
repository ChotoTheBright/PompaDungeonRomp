extends Node2D

const ViewPortTemplate = preload("res://addons/godot_transitions/scenes/ViewPortScene.tscn")
const ZigZagOverlay = preload("res://addons/godot_transitions/scenes/ZigZagOverlay.tscn")
const StripesHorizontal = preload("res://addons/godot_transitions/scenes/StripesHorizontal.tscn")
const Sector = preload("res://addons/godot_transitions/scenes/Sector.tscn")
const Donut = preload("res://addons/godot_transitions/scenes/Donut.tscn")
onready var bat_scr = get_tree().get_nodes_in_group("battle_screen")[0]
onready var _audio = get_tree().get_nodes_in_group("audio")[0]

var SCREEN: Dictionary = {
	"width" :ProjectSettings.get("display/window/size/width"),
	"height": ProjectSettings.get("display/window/size/height"),
	"center": Vector2()
}

func _ready() -> void:
	SCREEN.center = Vector2(SCREEN.width/2, SCREEN.height/2)

func dual_circles(encounter: int, duration: float, color: Color): #from, to, 
	var controlRoot = CanvasLayer.new()
	var overlay_top = Sector.instance()
	var overlay_bottom = Sector.instance()
	var tween = Tween.new()
	controlRoot.set_pause_mode(PAUSE_MODE_PROCESS)
	
	get_tree().get_root().add_child(controlRoot)
	controlRoot.add_child(overlay_top)
	overlay_top.color = color
	overlay_top.global_position = SCREEN.center
	overlay_top.center = Vector2.ZERO
	overlay_top.angle_from = 90
	overlay_top.angle_to = 90
	overlay_top.radius = SCREEN.center.distance_to(Vector2(SCREEN.width, 0))
	
	controlRoot.add_child(overlay_bottom)
	overlay_bottom.color = color
	overlay_bottom.global_position = SCREEN.center
	overlay_bottom.center = Vector2.ZERO
	overlay_bottom.angle_from = -90
	overlay_bottom.angle_to = -90
	overlay_bottom.radius = SCREEN.center.distance_to(Vector2(SCREEN.width, 0))
	
	controlRoot.add_child(tween)
#	get_tree().set_pause(true)
	
	tween.interpolate_property(overlay_top, "angle_to", 90, -90, duration/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(overlay_bottom, "angle_to", -90, -270, duration/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	
	
	yield(tween, "tween_all_completed")
	if encounter == 0:
		bat_scr.end_combat()
		_audio.get_node("Muzak").set_volume_db(0)
		_audio.get_node("Muzak2").set_volume_db(-100)
	elif encounter != 0:
		bat_scr.start_combat(encounter)
		_audio.get_node("Muzak").set_volume_db(-100)
		_audio.get_node("Muzak2").set_volume_db(0)
	
#	var new_scene = load(to).instance()
#	get_tree().get_root().add_child(new_scene)
#	from.queue_free()
	
	yield(get_tree().create_timer(0.2), "timeout")

	tween.interpolate_property(overlay_top, "angle_to", -90, 90, duration/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(overlay_bottom, "angle_to", -270, -90, duration/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

	yield(tween, "tween_all_completed")

#	get_tree().set_current_scene(new_scene)
	controlRoot.queue_free()
#	get_tree().set_pause(false)

func donut_eye(from, to, duration: float, color: Color):
	var controlRoot = CanvasLayer.new()
	var donut = Donut.instance()
	var tween = Tween.new()
	controlRoot.set_pause_mode(PAUSE_MODE_PROCESS)
	
	var r = SCREEN.center.distance_to(Vector2(SCREEN.width, 0)) # Screen Diagonal / 2
	
	get_tree().get_root().add_child(controlRoot)
	controlRoot.add_child(donut)
	donut.color = color
	donut.global_position = SCREEN.center
	donut.center = Vector2.ZERO
	donut.inner_radius =  r
	donut.outer_radius =  r + 10
	
	controlRoot.add_child(tween)
	get_tree().set_pause(true)
	
	tween.interpolate_property(donut, "inner_radius", r, 0, duration/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	
	yield(tween, "tween_all_completed")

	#start_combat()
	var new_scene = load(to).instance()
	get_tree().get_root().add_child(new_scene)
	from.queue_free()

	yield(get_tree().create_timer(0.2), "timeout")

	tween.interpolate_property(donut, "inner_radius", 0, r, duration/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

	yield(tween, "tween_all_completed")
	
	get_tree().set_current_scene(new_scene)
	controlRoot.queue_free()
	get_tree().set_pause(false)
