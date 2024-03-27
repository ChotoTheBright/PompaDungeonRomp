extends TextureButton

signal action
signal death
signal update_log

var hp = 5

onready var player = get_tree().get_nodes_in_group("player").front()
onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite
onready var status_bar = $status_bar

##statuses


var spotted : int = 0

var hype : int = 0

var dizzy : int = 0

var sleep : int = 0

var destabilized : int = 0

var webbed : int = 0

var bodyblocked : int = 0

var dead : bool = false

var charging : int = 0

var evasive : int = 0

export var dmg : float = 5 



var action: Dictionary = {"damage": dmg,
"status" : null ,
"target" : "player",
"animation" : "player_slash",
"description1" : "\n A knife flashes out of the shadows.",
"description2" : "\n Your armor absorbs most of the force"}



var interactions : Dictionary = {
	"disoriented" : {
		"cancels" : null,
		"description" : "\n It does nothing."},

	"webbed" : {
		"cancels" : null,
		"description" : "\n The webs are not match for a knife."},
	
	"sleep" : {
		"status" : sleep,},

	"spotted": {
		"status" : spotted},
	
	"hype" : {
		"status" : hype},
	
	"dizzy" : {
		"status" : dizzy}
	}


func _ready():
	connect("death", get_parent(), "on_enemy_death")
# warning-ignore:return_value_discarded
	connect("action", battle_scene, "queue_enemy_action")
# warning-ignore:return_value_discarded
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])
	connect("update_log", battle_scene, "update_log")


func damage(damage):

	sprite.play("damage_flash")

	if bodyblocked:
		damage = damage * .5

	hp -= damage

	if hp <= 0:
		yield(sprite, "animation_finished")
		hide()
		dead = true
		emit_signal("death")


func attack():

	var final_dict = action.duplicate()


	if spotted:
		final_dict["damage"] = dmg * 2

	emit_signal("action", final_dict)



func set_status(status : Dictionary):


	if status.has("disoriented") or status.has("webbed"):
		cancel_actions(status["status"])

	if status["duration"] > 0:
		
		set(status["status"], status["duration"])

#		print(get(status["status"]))
	call_deferred("update_status_bar")



func update_status_bar():

	for i in status_bar.get_children():
		var status = get(i.get_name())
		print(i.get_name())
		print(status)

		if status > 0:
			i.show()

		elif status <= 0:
			i.hide()



func cancel_actions(status):

	if interactions[status]["cancels"] != null:
		print(interactions[status]["cancels"])
		var canceled_action = interactions[status]["cancels"]
		canceled_action = false

	emit_signal("update_log", interactions[status]["description"])
	



func _on_animation_finished():
	sprite.play("idle")
	sprite.stop()
