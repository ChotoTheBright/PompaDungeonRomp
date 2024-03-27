extends CanvasLayer



onready var diorama_container = $diorama_container
onready var hud = $HUD
onready var action_hud = $HUD/main_hud
onready var item_hud = $HUD/item_hud
onready var combat_log = $HUD/log/log_text
onready var battle_effects = $diorama_container/battle_effects
onready var back_button = $HUD/back

onready var _STAT = get_tree().get_nodes_in_group("STATLABEL")[0]
onready var player = get_tree().get_nodes_in_group("player")[0]


var player_turn : bool = true

var queued_player_actions : Array = []
var action_points : int = 2

var stored_dict : Dictionary

var player_actions : Dictionary = {
	"melee_attack": 
		{
		"damage": 10,
		"target" : null,
		"status" : null,
		"animation" : "player_slash",
		"description": "\n Jimbo lashes out."},
	
	"throwing_knife" : {
		"damage" : 5,
		"target" : null,
		"status" : null,
		"animation" : "player_slash",
		"description" : "\n A blur seeks bone."},

	"web_ball" : {
		"damage" : 0,
		"target" : null,
		"status" : "webbed",
		"animation" : "player_slash",
		"description" : "\n A sticky web covers every."},
	
	"sleep_gas" : {
		"damage" : 0,
		"target" : null,
		"status" : "sleep",
		"animation" : "player_slash",
		"description" : "\n The bomb explodes into a relaxing mist."},
	
	"sphere" : {
		"damage" : 0,
		"target" : null,
		"status" : "destabilized",
		"animation" : "player_slash",
		"description" : "\n The floor cracks on impact."},
	
	"fuzzy_dust" : {
		"damage" : 0,
		"target" : null,
		"status" : "dizzy",
		"animation" : "player_slash",
		"description" : "\n Touch fuzzy, get dizzy."},
	
	"bandage" : {
		"heal" : 20,
		"animation" : "player_slash",
		"description" : "\n It would stop the bleeding, had you time to."},
	
	"potion" : {
		"heal" : 80,
		"animation" : "player_slash",
		"description" : "\n Strangely savory."},
	
}

var statuses : Dictionary = {
	"sleep" : {
		"status" : "sleep",
		"duration": 4,},
	
	"dizzy" : {
		"status" : "dizzy",
		"duration" : 2,},

	"webbed" : {
		"status" : "webbed",
		"duration" :0,},
	
	"destabilized" : {
		"status" : "destabilized",
		"duration" : 0,}
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

	stored_action = action
	
	action_hud.hide()
	item_hud.hide()
	back_button.show()

	for i in enemies.get_children():
		if i.dead == false:
			i.mouse_filter = 0






func _on_item_pressed():

	action_hud.hide()
	item_hud.show()
	back_button.show()






func _on_back_pressed():

	action_hud.show()
	item_hud.hide()
	back_button.hide()

	for i in enemies.get_children():
		i.mouse_filter = 2




##turn functions

func start_combat():

	
	enemies = get_tree().get_nodes_in_group("encounter").front()

	start_player_turn()

#-------------
##turn order
#-------------

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

		
	
	activate_enemy_actions()









func queue_enemy_action(action: Dictionary):

	queued_enemy_actions.append(action)





func activate_enemy_actions():


	if queued_enemy_actions.size() > 0:
		call("enemy_attack", queued_enemy_actions.pop_front())

	else:
		start_player_turn()




func enemy_attack(attack_dict: Dictionary):

	stored_dict = attack_dict

	update_log(stored_dict.get("description1"))
	
	if stored_dict.get("target") is String:
		pain(stored_dict.get("damage"))

		if stored_dict.get("status") != null:
			PlayerStats.set_status(stored_dict.get("status"))

	else:
		get_node(stored_dict.get("target")).set_status(stored_dict.get("status"))


	battle_effects.play(stored_dict.get("animation"))






func queue_player_action(target : NodePath):
	
	back_button.hide()
	
	for i in enemies.get_children():
		i.mouse_filter = 2

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









func activate_player_actions():
	

	action_hud.hide()
	item_hud.hide()
	back_button.hide()

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
		get_node(attack_dictionary.get("target")).set_status(statuses.get(attack_dictionary["status"]))

	battle_effects.play(attack_dictionary.get("animation"))

	update_log(attack_dictionary.get("description"))



func _on_battle_effects_animation_finished():

	battle_effects.play("default")
	battle_effects.playing = false

	if player_turn == true:
		if enemies.get_children().size() == enemies.dead_dudes:
			end_combat()

		elif queued_player_actions.size() > 0:
			activate_player_actions()

		elif queued_player_actions.size() == 0:
			start_enemy_turn()

	elif player_turn == false:
		update_log(stored_dict.get("description2"))
		if queued_enemy_actions.size() != 0:
			activate_enemy_actions()

		else:
			start_player_turn()



func end_combat():

	clear_log()
	enemies.queue_free()

	action_hud.visible = false
	item_hud.visible = false
	visible = false
	player.inbattle = false





func death():
	print("penis wenis pro shenis")
	pass



func pain(_dam):
	PlayerStats.hurt(_dam)
	_STAT.update_health(_dam)#update_display()


func update_log(combat_text):

	combat_log.text = combat_log.text + combat_text

func clear_log():
	
	combat_log.text = ""



