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

var disoriented : int = 0

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

var statuses : Array = ["dizzy", "sleep", "destabilized", "webbed", "bodyblocked", "evasive", "disoriented"]

export var dmg : float = 10



var action: Dictionary = {"damage": dmg,
"status" : null ,
"target" : "player",
"animation" : "player_slash",
"description1" : "\n A knife flashes out of the shadows.",
"description2" : "\n Your armor absorbs most of the force"}



var interactions : Dictionary = {
	"destabilized" : {
		"cancels" : null,
		"description" : "\n It does nothing."},

	"webbed" : {
		"cancels" : null,
		"description" : "\n The webs are no match for a knife."},
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

	if bodyblocked and damage > 0:
		damage = damage * .5

	hp -= damage

	if hp <= 0:
		yield(sprite, "animation_finished")
		hide()
		dead = true
		emit_signal("death")

	if sleep > 0 and damage > 0 :
		wake_up()

	call_deferred("update_status_bar")


func wake_up():

	sleep = 0

	if dizzy > 0:
		dizzy = 0
		disoriented = 1



func attack():

	var final_dict = action.duplicate()

	if sleep > 0 or disoriented > 0:
		final_dict["damage"] = 0
		final_dict["animation"] = "wind"
		final_dict["description1"] = "\n They are in no condition to fight"
		final_dict["description2"] = "\n..."
	
	elif dizzy > 0:
		var coinflip = rand_range(0, 2)
		if coinflip > 1:
			final_dict["damage"] = 0
			final_dict["animation"] = "miss"
			final_dict["description1"] = "\n Their unbalanced strike is easy to dodge"
			final_dict["description2"] = "\n..."

		else:
			pass

	elif spotted:
		final_dict["damage"] = dmg * 2

	emit_signal("action", final_dict)



func set_status(status : Dictionary):


	if status.has("destabilized") or status.has("webbed"):
		print("cancel")
		
		if interactions[status["status"]]["cancels"] != null:
			set(interactions[status]["cancels"], 0)

	set(status["status"], status["duration"])
	if interactions.has(status["status"]):
		emit_signal("update_log", interactions.get(status["status"])["description"])

	call_deferred("update_status_bar")


func turn_end_status_maintenance():

	if sleep == 1:
		wake_up()

	for i in statuses:

		set(i, max(get(i) - 1, 0))


	call_deferred("update_status_bar")



func update_status_bar():

	for i in status_bar.get_children():
		var status = get(i.get_name())


		if status > 0:
			i.show()

		elif status <= 0:
			i.hide()





func _on_animation_finished():
	sprite.play("idle")
	sprite.stop()
