extends TextureButton

signal action
signal death
signal update_log

onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite
onready var status_bar = $status_bar
onready var damage_text = $damage_text

export var dmg = 0

var hp = 25

var action : Dictionary = {
	"spot" : {
	
	"damage" : dmg,
	"status" : "spotted",
	"target" : null,
	"animation" : "spot",
	"description1" : "\n Buff Bandit spots his ally",
	"description2" : "\n The flexual tension is real. "}, #Their muscles get huge. 
	"hype" : {
	"damage" : dmg,
	"status" : "hype",
	"target" : null,
	"animation" : "hype",
	"description1" : "\n Buff Bandit hypes up his ally",
	"description2" : " \n They're real ready to scrap now."}
	}
	
var interactions : Dictionary = {
	"destabilized" : {
		"cancels" : ["charging"],
		"description" : "\n The well built gentleman loses his balance"},

	"webbed" : {
		"cancels" : ["charging"],
		"description" : "\n His muscles strain under the webs grip."},
	}


var action_rando : float




var target_list

var target

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



func _ready():
	
	target_list = get_parent().get_children()
# warning-ignore:return_value_discarded
	connect("death", get_parent(), "on_enemy_death")
# warning-ignore:return_value_discarded
	connect("action", battle_scene, "queue_enemy_action")
# warning-ignore:return_value_discarded
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])
# warning-ignore:return_value_discarded
	connect("update_log", battle_scene, "update_log")

func attack():

	var final_dict : Dictionary 
	var status : String

	if charging == 1 and sleep <= 0 and disoriented <= 0:

##chooses action
		action_rando = rand_range(0, 2)

		if action_rando >= 1:
			status = "spot"

		else:
			status = "hype"

		final_dict = action[status].duplicate()


#sets target
		target_list.shuffle()

		for i in target_list:
			if i != self and i.dead == false:
				final_dict["target"] = battle_scene.get_path_to(i)
				emit_signal("action", final_dict)
				break

		charging = 0

	elif charging == 0 and sleep <= 0 and dizzy <= 0 and disoriented <= 0:
		charging = 1
		emit_signal("update_log", "\n Buff Bandit charges up")

	else:
		final_dict["description1"] = "\n They are in no condition to fight"
		final_dict["description2"] = "\n..."

	update_status_bar()



func damage(damage):


	if bodyblocked:
		damage = damage * .5
	
	hp -= damage
	
	if damage != 0:
		damage_text.damage_pop_up(damage, Vector2(0,0))
	
	sprite.play("damage_flash")
	yield(sprite, "animation_finished")

	if hp <= 0:
		hide()
		dead = true
		emit_signal("death")

	elif sleep > 0 and damage >0 :
		wake_up()

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
