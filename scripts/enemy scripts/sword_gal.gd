extends TextureButton

signal action
signal bodyblock

onready var player = get_tree().get_nodes_in_group("player").front()
onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite

var hp = 35
export var dmg = 5 #

##statuses

var dizzy : bool = false

var sleep : bool = false

var disoriented : bool = false

var motivated : bool = true

var bodyblocked : bool = false




func _ready():

	connect("action", battle_scene, "queue_enemy_action")
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])


func attack():

	battle_scene.pain(dmg)
	emit_signal("action", "rally")

	if not motivated:
		motivated = true



func damage(damage):

	sprite.play("damage_flash")
	hp -= damage
	
	if bodyblocked:
		damage = damage * .5

	if hp <= 0:
		queue_free()



func on_animation_finished():

	sprite.play("idle")


