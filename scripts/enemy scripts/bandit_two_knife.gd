extends TextureButton

signal action
signal death

onready var player = get_tree().get_nodes_in_group("player").front()
onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite

var hp = 10
export var dmg = 5 
var evasive : bool = true

var action : Dictionary = {
	"damage" : 10,
	"status" : null,
	"target" : "player",
	"animation" : "double_slash",
	"description" : "Bandit stabs twice idk"
}


##statuses

var spotted : bool = false

var hype : bool = false

var dizzy : bool = false

var sleep : bool = false

var disoriented : bool = false

var motivated : bool = false

var bodyblocked : bool = false

var dead : bool = false


func _ready():

	connect("death", get_parent(), "on_enemy_death")
	connect("action", battle_scene, "queue_enemy_action")
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])


func attack():

	var final_dict = action.duplicate()

	if spotted:
		final_dict["damage"] = dmg * 2



	emit_signal("action", final_dict)




func damage(damage):


	sprite.play("damage_flash")
	if evasive:
		evasive = false
		return

	else:
		if bodyblocked:
			damage = damage * .5

		hp -= damage

		if hp <= 0:

			hide()
			dead = true
			emit_signal("death")



func on_animation_finished():

	sprite.play("idle")
