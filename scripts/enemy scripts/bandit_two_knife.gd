extends TextureButton

signal action
signal death
signal update_log

onready var player = get_tree().get_nodes_in_group("player").front()
onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite
onready var status_bar = $status_bar
onready var damage_text = $damage_text
onready var audio = $AudioStreamPlayer

var hit_sound = preload("res://assets/Audio/hit_sound.wav")
var miss_sound = preload("res://assets/Audio/woosh1.ogg")


var hp = 25
export var dmg = 15


var action : Dictionary = {
	"damage" : dmg,
	"status" : null,
	"target" : "player",
	"animation" : "double_slash",
	"description1" : "\n Bandit stabs twice idk",
	"description2" : "\n Stuff"
}

var interactions : Dictionary = {
	"destabilized" : {
		"cancels" : null,
		"description" : "\n The bandit leaps over the force"},

	"webbed" : {
		"cancels" : ["evasive"],
		"description" : "\n The blanket of webs pins the bandit to the ground."},
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

var statuses : Array = ["dizzy", "sleep", "destabilized", "webbed", "bodyblocked", "evasive", "disoriented"]



func _ready():

	update_status_bar()
# warning-ignore:return_value_discarded
	connect("death", get_parent(), "on_enemy_death")
# warning-ignore:return_value_discarded
	connect("action", battle_scene, "queue_enemy_action")
# warning-ignore:return_value_discarded
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])
# warning-ignore:return_value_discarded
	connect("update_log", battle_scene, "update_log")


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




func damage(damage):

	if damage < 0:
		hp -= damage

	elif evasive <= 0 or sleep > 0:
		if bodyblocked and damage > 0:
			damage = damage * .5

		if sleep > 0 and damage > 0 :
			wake_up()

		hp -= damage

		if damage != 0:
			damage_text.damage_pop_up(damage, Vector2(0,0))

		audio.stream = hit_sound
		audio.play(0)

		sprite.play("damage_flash")
		yield(sprite, "animation_finished")

		if hp <= 0:

			hide()
			dead = true
			emit_signal("death")

		elif sleep > 0 and damage > 0 :
			wake_up()

	elif evasive > 0:
		evasive = 0
		emit_signal("update_log", "\n The bandit dances around your blade.")
		audio.stream = miss_sound
		audio.play(0)

	call_deferred("update_status_bar")


func wake_up():

	sleep = 0

	if dizzy > 0:
		dizzy = 0
		disoriented = 1


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

	if sleep == 1:
		wake_up()

	evasive = 99
	emit_signal("update_log", "\n The bandit bounces on his feet")
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

