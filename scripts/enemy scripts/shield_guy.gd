extends TextureButton

signal action
# warning-ignore:unused_signal
signal bodyblock
signal death
signal update_log


onready var player = get_tree().get_nodes_in_group("player").front()
onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite
onready var status_bar = $status_bar
onready var damage_text = $damage_text
onready var audio = $AudioStreamPlayer

var hit_sound = preload("res://assets/Audio/hit_sound.wav")
var charge_sound = preload("res://assets/Audio/rumble3.ogg")


var party
var hp = 35
export var dmg = 15


var action : Dictionary = {
	"damage" : dmg,
	"status" : "dizzy",
	"target" : "player",
	"animation" : "shield_bash",
	"description1" : "\n The shield jerks out towards your face.", 
	"description2" : "\n Stars fill your vision."
}

var interactions : Dictionary = {
	"destabilized" : {
		"cancels" : ["charging", "bodyblocked"],
		"description" : "\n His footing falters."},

	"webbed" : {
		"cancels" : ["charging", "bodyblocked"],
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

var statuses : Array = ["dizzy", "sleep", "destabilized", "webbed", "bodyblocked", "evasive", "disoriented"]





func _ready():

	party = get_parent().get_children()
	
# warning-ignore:return_value_discarded
	connect("update_log", battle_scene, "update_log")
# warning-ignore:return_value_discarded
	connect("death", get_parent(), "on_enemy_death")
# warning-ignore:return_value_discarded
	connect("action", battle_scene, "queue_enemy_action")
# warning-ignore:return_value_discarded
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])

	guard()




func guard():

	for i in party:
		if i.dead == false:
			i.set_status({"status" : "bodyblocked", "duration": 99})
			emit_signal("update_log", "\n The gargantuan knight readies his shield.")

func unguard():

	for i in party:
		if i.dead == false and i.name != "shield_guy":
			i.set_status({"status" : "bodyblocked", "duration": 0})
			emit_signal("update_log", "\n The enemy party is exposed.")


func attack():
	
	if charging == 1:
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

		elif spotted:
			final_dict["damage"] = dmg * 2
			
		
		else:
			charging = 0

			if bodyblocked <= 0 and sleep <= 0:
				guard()
				
		emit_signal("action", final_dict)


	elif charging <= 0 and sleep <= 0 and disoriented <= 0:
		charging = 1
		emit_signal("update_log", "\n The knight gathers his strength.")
		sprite.play("charge")
		audio.stream = charge_sound
		audio.play(0)
		yield(sprite, "animation_finished")
		
	
	update_status_bar()



func damage(damage):

	sprite.play("damage_flash")
	audio.stream = hit_sound
	audio.play(0)
	
	if bodyblocked and damage > 0:
		damage = damage * .25

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

	if bodyblocked == 0:
		unguard()



func _on_animation_finished():

	sprite.play("idle")
	sprite.playing = false

