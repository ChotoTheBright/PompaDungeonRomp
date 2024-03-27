extends CanvasLayer

signal player_action_finished
signal enemy_action_finished

onready var diorama_container = $diorama_container
onready var hud = $HUD
onready var action_hud = $HUD/main_hud
onready var item_hud = $HUD/item_hud
onready var combat_log = $HUD/log/log_text
onready var battle_effects = $diorama_container/battle_effects


onready var _STAT = get_tree().get_nodes_in_group("STATLABEL")[0]
onready var player = get_tree().get_nodes_in_group("player")[0]


var player_turn : bool = true

var queued_player_actions : Array = []
var action_points : int = 2

var player_actions : Dictionary = {
	"melee_attack": 
		{
	"damage": 10,
	"target" : null,
	"status" : null,
	"animation" : "player_slash",
	"description": "\n Jimbo lashes out"},
	
	"item_placeholder" : {
	"damage" : 0,
	"target" : null,
	"status" : "sleep",
	"animation" : "party",
	"description" : "\n Jimbo parties"}
}


var queued_enemy_actions : Array = []

var enemies 

var stored_action : String






func _ready():
	
	player.inbattle = true
	
	PlayerStats.init()
# warning-ignore:return_value_discarded
	PlayerStats.connect("dead", self, "death")
# warning-ignore:return_value_discarded
#	PlayerStats.connect("hurt", self, "pain")
#	PlayerStats.connect("dead", self, "death")
	
	start_combat()
	pass



##HUD functions



func _on_action_button_pressed(action):
	print("click")
	stored_action = action
	
	action_hud.visible = false
	item_hud.visible = false
	
	for i in enemies.get_children():
		i.mouse_filter = 0




func _on_item_pressed():

	action_hud.visible = false
	item_hud.visible = true






##turn functions

func start_combat():

	
	enemies = get_tree().get_nodes_in_group("encounter").front()

	start_player_turn()




func start_player_turn():

	if PlayerStats.defending == true:
		PlayerStats.defending = false

	action_points = 2
	action_hud.visible = true
	player_turn = true



func start_enemy_turn():
	player_turn = false
	for i in enemies.get_children():
		if i.dead == false:
			i.attack()
			print("attack")
		
	
	activate_enemy_actions()





func pain(_dam):
	PlayerStats.hurt(_dam)
	_STAT.update_health(_dam)#update_display()
	print("hurtin ya?")
	

func queue_enemy_action(action: Dictionary):

	queued_enemy_actions.append(action)
	
	








func activate_enemy_actions():


	if queued_enemy_actions.size() > 0:
		call("enemy_attack", queued_enemy_actions.pop_front())



func enemy_attack(attack_dictionary: Dictionary):

	if attack_dictionary.get("target") is String:
		pain(attack_dictionary.get("damage"))

		if attack_dictionary.get("status") != null:
			PlayerStats.set_status(attack_dictionary.get("status"))

	else:

		get_node(attack_dictionary.get("target")).set_status(attack_dictionary.get("status"))


	battle_effects.play(attack_dictionary.get("animation"))

	update_log(attack_dictionary.get("description"))




func queue_player_action(target : NodePath):
	
	for i in enemies.get_children():
		i.mouse_filter = false

	if stored_action != "throwing_knife":

		action_points -= 1


	var queued_action = player_actions[stored_action].duplicate()

	queued_action["target"] = target


	queued_player_actions.append(queued_action)

	if action_points == 0:
		activate_player_actions()

	else:
		action_hud.visible = true
		item_hud.visible = false




	print(action_points)





func activate_player_actions():
	

	action_hud.visible = false
	item_hud.visible = false
	
	
	call("player_attack", queued_player_actions.pop_front())








func player_attack(attack_dictionary: Dictionary):


	if get_node(attack_dictionary.get("target")).dead == true:

		var new_target
		for i in enemies.get_children():
			
			if i.dead == false:
				
				new_target = self.get_path_to(i)
				break
		attack_dictionary["target"] = new_target


	battle_effects.position = get_node(attack_dictionary["target"]).rect_position
	battle_effects.play(attack_dictionary.get("animation"))
	
	yield(battle_effects, "animation_finished")


	if attack_dictionary.get("damage") > 0:

		get_node(attack_dictionary.get("target")).damage(attack_dictionary.get("damage"))
	
	if attack_dictionary.get("status") != null:
<<<<<<< HEAD

		attack_dictionary.get("target").set_status(attack_dictionary.get("status"))
=======
# warning-ignore:unused_variable
		var status = attack_dictionary.get("status")
		attack_dictionary.get("target").status = true
	
	#battle_effects.play(attack_dictionary.get("animation")
>>>>>>> 3065c1b60b3b46380873cfebcfbd5b39114c0b80
	

	update_log(attack_dictionary.get("description"))













func end_combat():

	enemies.queue_free()

	action_hud.visible = false
	item_hud.visible = false
	visible = false
	player.inbattle = false




##player actions

func death():
	print("penis wenis pro shenis")
	pass



func update_log(combat_text):

	combat_log.text = combat_log.text + combat_text




func _on_battle_effects_animation_finished():

	battle_effects.play("default")
	battle_effects.playing = false

	print(enemies.dead_dudes)

	if player_turn == true:
		if enemies.get_children().size() == enemies.dead_dudes:
			end_combat()

		elif queued_player_actions.size() > 0:
			activate_player_actions()

		elif queued_player_actions.size() == 0:
			start_enemy_turn()

	elif player_turn == false:
		if queued_enemy_actions.size() != 0:
			activate_enemy_actions()

		else:
			start_player_turn()

