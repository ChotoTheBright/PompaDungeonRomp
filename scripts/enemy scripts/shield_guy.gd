extends AnimatedSprite

signal action
signal bodyblock

onready var player = get_tree().get_nodes_in_group("player").front()
onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite

var hp = 35

var charging : bool = false





##statuses

var dizzy : bool = false

var sleep : bool = false

var disoriented : bool = false

var motivated : bool = false

var bodyblocked : bool = false




func _ready():

	connect("action", battle_scene, "queue_enemy_action")
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])



func guard():

	emit_signal("action", "bodyblock")



func attack():


	emit_signal("action", "shield_slam")
	charging = true

	if not bodyblocked:
		guard()





func damage(damage):

	sprite.play("damage_flash")

	if bodyblocked:
		damage = damage * .25

	hp -= damage

	if hp <= 0:
		queue_free()



func on_animation_finished():

	sprite.play("idle")
