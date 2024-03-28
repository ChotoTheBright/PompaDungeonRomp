extends TextureButton

signal action
signal death
signal update_log

onready var player = get_tree().get_nodes_in_group("player").front()
onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite
onready var status_bar = $status_bar


var hp = 25
export var dmg = 10 


var action : Dictionary = {
	"damage" : dmg,
	"status" : null,
	"target" : "player",
	"animation" : "player_slash",
	"description1" : "\n Bandit stabs twice idk",
	"description2" : "\n Stuff"
}

var interactions : Dictionary = {
	"destabilized" : {
		"cancels" : null,
		"description" : "\n The bandit leaps over the forced"},

	"webbed" : {
		"cancels" : ["evasive"],
		"description" : "\n Dodge this."},
	}

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

var evasive : int = 99

var statuses : Array = [spotted, hype, dizzy, sleep, destabilized, webbed, bodyblocked, charging, evasive]



func _ready():

	update_status_bar()
	connect("death", get_parent(), "on_enemy_death")
	connect("action", battle_scene, "queue_enemy_action")
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])
	connect("update_log", battle_scene, "update_log")


func attack():

	var final_dict = action.duplicate()

	if spotted:
		final_dict["damage"] = dmg * 2

	if dizzy > 0 or sleep > 0 or disoriented > 0:
		final_dict["damage"] = 0
		final_dict["animation"] = "wind"
		final_dict["description1"] = "\n They are in no condition to fight"
		final_dict["description2"] = "\n..."

	emit_signal("action", final_dict)




func damage(damage):

	if evasive <= 0 or sleep > 0:
		if bodyblocked:
			damage = damage * .5

		hp -= damage
		sprite.play("damage_flash")
		if hp <= 0:

			hide()
			dead = true
			emit_signal("death")

	elif evasive > 0:
		evasive = 0
		emit_signal("update_log", "\n The bandit dances around your blade.")

	if sleep > 0:
		sleep = 0
		if dizzy > 0:
			disoriented = 1
			dizzy = 0

	call_deferred("update_status_bar")





func set_status(status : Dictionary):

	if status["status"] == "destabilized" or status["status"] == "webbed":
		print("cancel")

		if interactions.get(status["status"])["cancels"] != null:
			print(interactions.get(status["status"])["cancels"])
			for i in interactions.get(status["status"])["cancels"]:
				print(i)
				set(i, 0)

	set(status["status"], status["duration"])

	if interactions.has(status["status"]):
		emit_signal("update_log", interactions.get(status["status"])["description"])

	call_deferred("update_status_bar")




func turn_end_status_maintenance():

	evasive = 99
	emit_signal("update_log", "\n The bandit bounces on his feet")
	for i in statuses:
		i = max(i - 1, 0)

		if i > 0:
			update_status_bar()



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

