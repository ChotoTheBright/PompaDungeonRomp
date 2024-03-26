extends CanvasLayer

signal player_action_finished
signal enemy_action_finished

onready var diorama_container = $diorama_container
onready var hud = $HUD
onready var action_hud = $HUD/main_hud
onready var item_hud = $HUD/item_hud
onready var _STAT = get_tree().get_nodes_in_group("STATLABEL")[0]
onready var player = get_tree().get_nodes_in_group("player")[0]


var stored_action : String


var queued_player_actions : Array = []
var action_points : int = 0

var player_actions : Dictionary = {
	"melee_attack": 
		{
	"damage": 10,
	"target" : null,
	"status" : null,
	"animation" : "player_slash",
	"description": "Jimbo lashes out"},
	
	"item_placeholder" : {
	"damage" : 0,
	"target" : null,
	"status" : "sleep",
	"animation" : "party",
	"description" : "Jimbo parties"}
}



var queued_enemy_actions : Array = []

var enemies 






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




func start_enemy_turn():

	for i in enemies.get_children():
		
		i.attack()
		print("attack")
		
	
	start_player_turn()




func pain(_dam):
	PlayerStats.hurt(_dam)
	_STAT.update_health(_dam)#update_display()
	print("hurtin ya?")
	

func queue_enemy_action(action: String, target):

	if target == "player":
		target = player
	queued_enemy_actions.append(action)
	
	activate_enemy_actions()




func queue_player_action(target : NodePath):


	if stored_action != "throwing_knife":

		action_points -= 1


	var queued_action = player_actions[stored_action].duplicate()
	print(queued_action)
	queued_action["target"] = target
	print(queued_action["target"])

	queued_player_actions.append(queued_action)

	if action_points == 0:
		activate_player_actions()

	else:
		action_hud.visible = true
		item_hud.visible = false


	for i in enemies.get_children():
		i.mouse_filter = false

	print(action_points)






func activate_enemy_actions():

	
	call("enemy_attack", queued_enemy_actions.pop_front())
	
	if queued_enemy_actions.size() != 0:
		activate_enemy_actions()
	
	else:
		start_player_turn()






func activate_player_actions():
	

	action_hud.visible = false
	item_hud.visible = false
	
	
	call("player_attack", queued_player_actions.pop_front())


	if queued_player_actions.size() > 0:
		activate_player_actions()

	elif queued_player_actions.size() == 0:
		call_deferred("end_player_turn")





func end_player_turn():

	if enemies.dead_dudes >= enemies.get_children().size():
		end_combat()
		enemies.queue_free()

	else:
		start_enemy_turn()






func end_combat():
	
	action_hud.visible = false
	item_hud.visible = false
	visible = false
	
	player.inbattle = false




##player actions

func death():
	print("penis wenis pro shenis")
	pass




func player_attack(attack_dictionary: Dictionary):

	print(attack_dictionary)
	
	if attack_dictionary.get("damage") > 0:

		get_node(attack_dictionary.get("target")).damage(attack_dictionary.get("damage"))
	
	if attack_dictionary.get("status") != null:
		var status = attack_dictionary.get("status")
		attack_dictionary.get("target").status = true
	
	#battle_effects.play(attack_dictionary.get("animation")
	
	$HUD/log.text += attack_dictionary.get("description")





func enemy_attack(attack_dictionary: Dictionary):

	pass




