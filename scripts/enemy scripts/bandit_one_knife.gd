extends TextureButton

signal action

onready var player = get_tree().get_nodes_in_group("player").front()
onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite

var hp = 5




##statuses

var dizzy : bool = false

var sleep : bool = false

var disoriented : bool = false

var motivated : bool = false

var bodyblocked : bool = false




func _ready():

	connect("action", battle_scene, "queue_enemy_action")
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])



func damage(damage):

	sprite.play("damage_flash")

	if bodyblocked:
		damage = damage * .5
	
	hp -= damage

	print(hp)

	if hp <= 0:
		queue_free()


func attack():
	
	emit_signal("action", "bleed_hit")





func on_animation_finished():
	sprite.play("idle")


func _on_bandit_one_knife_pressed():
	print("click")
