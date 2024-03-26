extends TextureButton

signal action

onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite

var hp = 25

var action_rando : float
export var dmg = 5 
var charging : bool = false

var target_list

var target

##statuses

var dizzy : bool = false

var sleep : bool = false

var disoriented : bool = false

var motivated : bool = false

var bodyblocked : bool = false




func _ready():
	
	var target_list = get_parent().get_children()

	connect("action", battle_scene, "queue_enemy_action")
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])


func attack():

#	battle_scene.pain(dmg) #no attacks ^^
	set_target()

	action_rando = rand_range(0, 2)

	if action_rando >= 1:
		emit_signal("action", "spot", target)

	else:
		emit_signal("action", "hype", target)

	charging = true



func damage(damage):

	sprite.play("damage_flash")
	
	if bodyblocked:
		damage = damage * .5
	
	hp -= damage

	if hp <= 0:
		queue_free()




func on_animation_finished():

	sprite.play("idle")



func set_target():
	
	target_list.shuffle()
	
	target = target_list.front()
	
	if target == self:

		set_target()
