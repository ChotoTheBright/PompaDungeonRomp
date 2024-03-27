extends TextureButton

signal action
signal death
signal update_log

onready var player = get_tree().get_nodes_in_group("player").front()
onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite

var hp = 10
export var dmg = 5 


var action : Dictionary = {
	"damage" : 10,
	"status" : null,
	"target" : "player",
	"animation" : "player_slash",
	"description" : "Bandit stabs twice idk"
}


##statuses

var evasive : bool = true

var spotted : bool = false

var hype : bool = false

var dizzy : bool = false

var sleep : bool = false

var disoriented : bool = false

var destabilized : bool = false

var webbed : bool = false

var motivated : bool = false

var bodyblocked : bool = false

var dead : bool = false


func _ready():

	connect("death", get_parent(), "on_enemy_death")
	connect("action", battle_scene, "queue_enemy_action")
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])
	connect("update_log", battle_scene, "update_log", ["The bandit dances around your blade."])


func attack():

	var final_dict = action.duplicate()

	if spotted:
		final_dict["damage"] = dmg * 2


	emit_signal("action", final_dict)




func damage(damage):

	if evasive == false:
		if bodyblocked:
			damage = damage * .5

		hp -= damage
		sprite.play("damage_flash")
		if hp <= 0:

			hide()
			dead = true
			emit_signal("death")

	if evasive == true:
		evasive = false
		emit_signal("update_log")


func on_animation_finished():

	sprite.play("idle")
