extends TextureButton

signal action
signal bodyblock
signal death

onready var player = get_tree().get_nodes_in_group("player").front()
onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite

var hp = 35
export var dmg = 20 #

var action : Dictionary = {
	"damage" : 15,
	"heal" : 5,
	"status" : null,
	"target" : "player",
	"animation" : "player_slash",
	"description" : "The knights passion rallies her allies."
}
##statuses

var spot : bool = false

var hype : bool = true

var dizzy : bool = false

var sleep : bool = false

var destabilized : bool = false

var webbed : bool = false

var disoriented : bool = false

var bodyblocked : bool = false

var dead : bool = false




func _ready():
	connect("death", get_parent(), "on_enemy_death")
	connect("action", battle_scene, "queue_enemy_action")
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])


func attack():

	battle_scene.pain(dmg)
	emit_signal("action", action)





func damage(damage):

	sprite.play("damage_flash")
	hp -= damage
	
	if bodyblocked:
		damage = damage * .5

	if hp <= 0:
		hide()
		dead = true
		emit_signal("death")



func on_animation_finished():

	sprite.play("idle")


func set_status(status : String):

	var changed_status = get(status)

	changed_status = true
