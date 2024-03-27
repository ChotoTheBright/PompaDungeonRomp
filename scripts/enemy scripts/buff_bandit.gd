extends TextureButton

signal action
signal death


onready var battle_scene = get_tree().get_nodes_in_group("battle_screen").front()
onready var sprite = $AnimatedSprite
onready var status_bar = $status_bar


export var dmg = 0

var hp = 25

var action : Dictionary = {
	"spot" : {
	
	"damage" : dmg,
	"status" : "spotted",
	"target" : null,
	"animation" : "spot",
	"description1" : "\n Buff Bandit spots his ally",
	"description2" : "\n Their muscles get huge. "},
	"hype" : {
	"damage" : dmg,
	"status" : "hyped",
	"target" : null,
	"animation" : "hype",
	"description1" : "\n Buff Bandit hypes up his ally",
	"description2" : " \n They're real ready to scrap now."}
	}


var action_rando : float




var target_list

var target

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
	
	target_list = get_parent().get_children()
	connect("death", get_parent(), "on_enemy_death")
	connect("action", battle_scene, "queue_enemy_action")
	connect("pressed", battle_scene, "queue_player_action", [battle_scene.get_path_to(self)])


func attack():

	if charging == 1:

		var final_dict : Dictionary 
		var status : String


##chooses action
		action_rando = rand_range(0, 2)
		if action_rando >= 1:
			status = "spot"
		else:
			status = "hype"

		final_dict = action[status].duplicate()


#sets target


		target_list.shuffle()
	
		for i in target_list:
			if i != self and i.dead == false:
				
				final_dict["target"] = battle_scene.get_path_to(i)
				
				emit_signal("action", final_dict)
				break
		charging = 0

	else:
		charging = 1
		battle_scene.update_log("\n Buff Bandit charges up")





func damage(damage):

	sprite.play("damage_flash")
	
	if bodyblocked:
		damage = damage * .5
	
	hp -= damage

	if hp <= 0:
		hide()
		dead = true
		emit_signal("death")







func set_status(status : String):

	var changed_status = get(status)
	changed_status = true



func _on_animation_finished():

	sprite.play("idle")
	sprite.stop()
