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
export var dmg = 5 


var action : Dictionary = {
	"damage" : 20,
	"status" : "dizzy",
	"target" : "player",
	"animation" : "player_slash",
	"description1" : "\n The shield jerks out towards your face.", 
	"description2" : "\n Stars fill your vision."
}


##statuses

var spotted : int = 0

var hype : int = 0

var dizzy : int = 0

var sleep : int = 0

var destabilized : int = 0

var webbed : int = 0

var bodyblocked : int = 0

var charging : int = 0

var evasive : int = 0

var dead : bool = false




func _ready():
	
	party = get_parent().get_children()
	
	connect("update_log", battle_scene, "update_log", ["\n The gargantuan knight readies his shield."])
	connect("death", get_parent(), "on_enemy_death")
	connect("action", battle_scene, "queue_enemy_action")
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])



func guard():

	for i in party:
		if i.dead == false:
			i.set_status("bodyblocked")



func attack():
	
	if charging == 1:

		emit_signal("action", action)
		charging = 0

	elif charging == 0:
		charging = 1
		emit_signal("update_log")

	if not bodyblocked:
		guard()





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



func set_status(status : String):

	var changed_status = get(status)
	changed_status = true


func _on_animation_finished():

	sprite.play("idle")
	sprite.playing = false

