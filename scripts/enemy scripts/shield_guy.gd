extends TextureButton

signal action
signal bodyblock
signal death
signal update_log


onready var player = get_tree().get_nodes_in_group("player").front()
onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite
onready var status_bar = $status_bar


var party
var hp = 35
export var dmg = 15


var action : Dictionary = {
	"damage" : dmg,
	"status" : "dizzy",
	"target" : "player",
	"animation" : "player_slash",
	"description1" : "\n The shield jerks out towards your face.", 
	"description2" : "\n Stars fill your vision."
}

var interactions : Dictionary = {
	"disoriented" : {
		"cancels" : [charging, bodyblocked],
		"description" : "\n His footing falters."},

	"webbed" : {
		"cancels" : [charging, bodyblocked],
		"description" : "\n The webs get between every plate of armor."},
	}


##statuses


var disoriented : int = 0

var spotted : int = 0

var hype : int = 0

var dizzy : int = 0

var sleep : int = 0

var destabilized : int = 0

var webbed : int = 0

var bodyblocked : int = 99

var dead : bool = false

var charging : int = 0

var evasive : int = 0

var statuses : Array = [spotted, hype, dizzy, sleep, destabilized, webbed, bodyblocked, charging, evasive]





func _ready():



	party = get_parent().get_children()
	
	connect("update_log", battle_scene, "update_log")
	connect("death", get_parent(), "on_enemy_death")
	connect("action", battle_scene, "queue_enemy_action")
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])

	guard()

func guard():

	for i in party:
		if i.dead == false:
			i.set_status({"status" : "bodyblocked", "duration": 99})
			emit_signal("update_log", "\n The gargantuan knight readies his shield.")



func attack():
	
	if charging == 1:
		var final_dict = action.duplicate()

		if spotted:
			final_dict["damage"] = dmg * 2

		if dizzy > 0 or sleep > 0 or disoriented > 0:
			final_dict["damage"] = 0
			final_dict["animation"] = "wind"
			final_dict["description"] = "They are in no condition to fight"

		emit_signal("action", final_dict)
		charging = 0


	elif charging == 0 and sleep <= 0 and disoriented <= 0:
		charging = 1
		emit_signal("update_log", "\n The knight gathers his strength.")


	if bodyblocked <= 0:
		guard()

	update_status_bar()



func damage(damage):

	sprite.play("damage_flash")

	if bodyblocked:
		damage = damage * .25

	hp -= damage
	print(hp)

	if hp <= 0:
		print("dead")
		hide()
		dead = true
		emit_signal("death")




func set_status(status : Dictionary):


	if status.has("destabilized") or status.has("webbed"):
		print("cancel")
		
		if interactions[status["status"]]["cancels"] != null:
			
			for i in interactions[status]["cancels"]:
				set(i, 0)

	set(status["status"], status["duration"])
	if interactions.has(status["status"]):
		emit_signal("update_log", interactions.get(status["status"])["description"])

	call_deferred("update_status_bar")




func turn_end_status_maintenance():

	for i in statuses:
		i = max(i - 1, 0)


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
	sprite.playing = false

