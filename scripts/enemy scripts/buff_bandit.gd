extends TextureButton

signal action
signal death


onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite
onready var status_bar = $status_bar


export var dmg = 0

var hp = 25

var action : Dictionary = {
	"spot" : {
	
	"damage" : dmg,
	"status" : "spotted",
	"target" : null,
	"animation" : "spot",
	"description1" : "\n Buff Bandit spots his ally",
	"description2" : "\n Their muscles get huge. "},
	"hype" : {
	"damage" : dmg,
	"status" : "hyped",
	"target" : null,
	"animation" : "hype",
	"description1" : "\n Buff Bandit hypes up his ally",
	"description2" : " \n They're real ready to scrap now."}
	}
	
var interactions : Dictionary = {
	"disoriented" : {
		"cancels" : charging,
		"description" : "\n The well built gentleman loses his balance"},

	"webbed" : {
		"cancels" : charging,
		"description" : "\n His muscles strain under the webs grip."},
	}


var action_rando : float




var target_list

var target

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

var statuses : Array = [spotted, hype, dizzy, sleep, destabilized, webbed, bodyblocked, charging, evasive]



func _ready():
	
	target_list = get_parent().get_children()
	connect("death", get_parent(), "on_enemy_death")
	connect("action", battle_scene, "queue_enemy_action")
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])


func attack():

	if charging == 1:

		var final_dict : Dictionary 
		var status : String


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

	else:
		charging = 1
		battle_scene.update_log("\n Buff Bandit charges up")

	update_status_bar()



func damage(damage):

	sprite.play("damage_flash")
	
	if bodyblocked:
		damage = damage * .5
	
	hp -= damage

	if hp <= 0:
		hide()
		dead = true
		emit_signal("death")




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
