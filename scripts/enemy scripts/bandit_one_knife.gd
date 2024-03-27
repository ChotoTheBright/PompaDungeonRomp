extends TextureButton

signal action
signal death

onready var player = get_tree().get_nodes_in_group("player").front()
onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite

##statuses


var spotted : bool = false

var hype : bool = false

var dizzy : bool = false

var sleep : bool = false

var disoriented : bool = false

var motivated : bool = false

var bodyblocked : bool = false

var dead : bool = false

export var dmg : float = 5 



var hp = 5

var attack : Dictionary = {"damage": dmg,
"status" : "bleed",
"target" : "player",
"animation" : "single_slash",
"description" : "\n Bandits knife flashes out of the shadows."}






func _ready():
	connect("death", get_parent(), "on_enemy_death")
# warning-ignore:return_value_discarded
	connect("action", battle_scene, "queue_enemy_action")
# warning-ignore:return_value_discarded
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])



func damage(damage):

	sprite.play("damage_flash")

	if bodyblocked:
		damage = damage * .5
	
	hp -= damage

	print(hp)

	if hp <= 0:
		hide()
		dead = true
		emit_signal("death")




func attack():


	var final_damage = dmg

	if spotted:
		final_damage = dmg * 2


	emit_signal("action", attack)





func on_animation_finished():
	sprite.play("idle")


func _on_bandit_one_knife_pressed():
	print("click")
