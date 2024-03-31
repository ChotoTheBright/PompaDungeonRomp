extends CanvasLayer
#if you search anywhere in the script for #SWAP#, you can 
#find the changes I made to start the game outside of combat.
#simple switch-a-roos, some things get commented out, 
#other stuff gets uncommented. 

onready var diorama_container = $diorama_container
onready var hud = $HUD
onready var action_hud = $HUD/main_hud
onready var item_hud = $HUD/item_hud
onready var combat_log = $HUD/log/log_text
onready var battle_effects = $diorama_container/battle_effects
onready var back_button = $HUD/back
onready var action_point = $HUD/TextureRect/action_points
onready var inventory = $HUD/inventory.get_children()
onready var item_description = $HUD/item_hud/item_description
onready var audio = $AudioStreamPlayer
onready var timer = $Timer
var click_sound = preload("res://assets/Audio/switch31.ogg")

var slash_sound = preload("res://assets/Audio/woosh2.ogg")
var enemy_slash = preload("res://assets/Audio/woosh6.ogg")
var click = preload("res://assets/Audio/switch31.ogg")
var hit_sound = preload("res://assets/Audio/hit_sound.wav")
var shield_hit = preload("res://assets/Audio/shield_hit_sound.wav")
var knife_sound = preload("res://assets/Audio/woosh8.ogg")
var healsound = preload("res://assets/Audio/sinkWater1.ogg")
var sleep_sound = preload("res://assets/Audio/explosion4.ogg")
var web_sound = preload("res://assets/Audio/explosion1.ogg")


onready var encounter1 = preload("res://scenes/combat/encounter_1.tscn").instance()
onready var encounter2 = preload("res://scenes/combat/encounter_2.tscn").instance()
onready var encounter3 = preload("res://scenes/combat/encounter_3.tscn").instance()
onready var encounter4 = preload("res://scenes/combat/encounter_4.tscn").instance()
onready var encounter5 = preload("res://scenes/combat/encounter_5.tscn").instance()
onready var encounter6 = preload("res://scenes/combat/encounter_6.tscn").instance()
onready var encounter7 = preload("res://scenes/combat/encounter_7.tscn").instance()

#Comment OUT the line below# #SWAP#
#onready var encounter = preload("res://scenes/combat/encounter_4.tscn").instance()

onready var _STAT = get_tree().get_nodes_in_group("STATLABEL")[0]
onready var player = get_tree().get_nodes_in_group("player")[0]

var defending : bool = false

var player_turn : bool = true
var end_combat_timer : Timer
var queued_player_actions : Array = []
var action_points : int = 2

var stored_dict : Dictionary

var player_actions : Dictionary = {
	"melee_attack": 
		{
		"damage": 20, #10
		"type" : "attack",
		"target" : null,
		"status" : null,
		"sound" : slash_sound,
		"animation" : "player_slash",
		"description": "\n Jimbo lashes out."},
	
	"throwing_knife" : {
		"damage" : 5,
		"type" : "item",
		"target" : null,
		"status" : null,
		"sound" : knife_sound,
		"animation" : "throwing_knife",
		"description" : "\n A blur seeks bone.",
		"description2" : "Throwing Knife \n \n Deals a small amount of damage without consuming an action."},

	"web_ball" : {
		"type" : "item",
		"damage" : 0,
		"target" : null,
		"status" : "webbed",
		"sound" : web_sound,
		"animation" : "player_slash",
		"description" : "\n A sticky web covers every.",
		"description2" : "Web Ball \n \n Constricts movement, canceling certain actions and buffs."},

	"sleep_gas" : {
		"type" : "item",
		"damage" : 0,
		"target" : null,
		"status" : "sleep",
		"animation" : "sleep_bomb",
		"sounds" : sleep_sound,
		"description" : "\n The bomb explodes into a relaxing mist.",
		"description2" : "Sleep Gas \n \n Puts an enemy to sleep for 4 turns. Enemies effected by Fuzzy Dust will have bad dreams, and wake up disoriented."},


	"sphere" : {
		"type" : "item",
		"damage" : 0,
		"target" : null,
		"status" : "destabilized",
		"animation" : "sphere",
		"sound" : sleep_sound,
		"description" : "\n The floor cracks on impact.",
		"description2" : "Impossibly Dense Sphere \n \n The small metal orb hits the earth with enough force to break stone, canceling certain actions and buffs."},

	"fuzzy_dust" : {
		"type" : "item",
		"damage" : 0,
		"target" : null,
		"status" : "dizzy",
		"sound" : knife_sound,
		"animation" : "fuzzy_dust",
		"description" : "\n Touch fuzzy, get dizzy.",
		"description2" : "Fuzzy Dust \n \n Makes its victim Dizzy, causing them to miss some attacks."},

	"bandage_heal" : {
		"type" : "item",
		"damage" : -20,
		"target" : "player",
		"animation" : "heal",
		"sound" : healsound,
		"description" : "\n It would stop the bleeding, had you time to.",
		"description2" : "Bandage \n \n Heals 20 hp."},

	"potion_heal" : {
		"type" : "item",
		"damage" : -80,
		"target" : "player",
		"animation" : "heal",
		"sound" : healsound,
		"description" : "\n Strangely savory.",
		"description2" : "Bandage \n \n Heals 80 hp."},
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
		"duration" : 0,},
	
	"spotted" : {
		"status" : "spotted",
		"duration" : 1
	},
	
	"hype" : {
		"status" : "hype",
		"duration" : 1
	}
}



var queued_enemy_actions : Array = []

var enemies 

var stored_action : String






func _ready():

#	start_combat(4)

	end_combat_timer = Timer.new()
	end_combat_timer.wait_time = 0.5
# warning-ignore:return_value_discarded
	end_combat_timer.connect("timeout", self, "end_combat_trans")
	end_combat_timer.one_shot = true
	add_child(end_combat_timer)




	#Uncomment the line below# #SWAP#
#	player.inbattle = true

	PlayerStats.init()
# warning-ignore:return_value_discarded
	PlayerStats.connect("dead", self, "death")


	#Uncomment the 3 lines below# #SWAP#
#	var encounter = preload("res://scenes/combat/encounter_3.tscn").instance() #SWAP#
#	start_combat(encounter) #SWAP#


	pass



##HUD functions



func _on_action_button_pressed(action):

	stored_action = action

	if action.get_slice("_", 1) == "heal":
		print("heal")
		action_hud.show()
		item_hud.hide()
		back_button.hide()
		queue_player_action("player")



	for i in enemies.get_children():
		if i.dead == false:
			
			i.mouse_filter = 0
			
	var items = item_hud.get_child(0).get_children()

	for i in items:
		i.hide()
	item_hud.hide()
	action_hud.hide()
	back_button.show()


func _on_item_pressed():
 

	action_hud.hide()
	back_button.show()
	var items = item_hud.get_child(0).get_children()

	for i in items:
		if PlayerStats.get(i.name) > 0:
			i.show()
	item_hud.show()


func _on_back_pressed():
	action_hud.show()
	item_hud.hide()
	back_button.hide()

	for i in enemies.get_children():
		i.mouse_filter = 2





##turn functions

func start_combat(encounter):
	hud.show()
	self.show()
	#---#
	player.inbattle = true
	match encounter:
		1:
			diorama_container.add_child(encounter1)
			pass
		2:
			diorama_container.add_child(encounter2)
			pass
		3:
			diorama_container.add_child(encounter3)
			pass
		4:
			diorama_container.add_child(encounter4)
			pass
		5:
			diorama_container.add_child(encounter5)
			pass
		6:
			diorama_container.add_child(encounter6)
			pass
		7:
			diorama_container.add_child(encounter7)#SWAP#
			pass
		8:
			pass


	enemies = get_tree().get_nodes_in_group("encounter").front()


	update_inventory()

	start_player_turn()



func _on_defend_pressed():
	action_points -= 1
	update_action_points()
	defending = true
	
	$HUD/main_hud/Button3.disabled = true

	print("defend")
	if action_points <= 0:
		call_deferred("activate_player_actions")

#-------------
##turn order
#-------------



func start_player_turn():
	
	if defending == true:
		$HUD/main_hud/Button3.disabled = false
		defending = false

	action_points = 2
	update_action_points()
	action_hud.visible = true
	player_turn = true



func start_enemy_turn():
	print("enemy_turn")
	player_turn = false
	for i in enemies.get_children():
		if i.dead == false:
			i.attack()

	activate_enemy_actions()




func queue_enemy_action(action: Dictionary):

	queued_enemy_actions.append(action)





func activate_enemy_actions():

	if queued_enemy_actions.size() > 0:
		call_deferred("enemy_attack", queued_enemy_actions.pop_front())

	else:
		start_player_turn()




func enemy_attack(attack_dict: Dictionary):
  
	stored_dict = attack_dict

	update_log(stored_dict.get("description1"))
	battle_effects.global_position = Vector2(800, 500)
	battle_effects.call_deferred("play", stored_dict.get("animation"))

	yield(battle_effects, "animation_finished")

	if stored_dict.get("target") is String:
		pain(stored_dict.get("damage"))

		if stored_dict.get("status") != null:
			PlayerStats.set_status(stored_dict.get("status"))

	else:
		get_node(stored_dict.get("target")).set_status(statuses[stored_dict.get("status")])

	update_log(stored_dict.get("description2"))

	if stored_dict.get("damage") > 20:
		audio.stream = shield_hit
		audio.play(0)




func queue_player_action(target):



	if player_actions[stored_action]["type"] == "item":
			PlayerStats.use_item(stored_action, -1)
			call_deferred("update_inventory")

	back_button.hide()
	
	for i in enemies.get_children():
		i.mouse_filter = 2

	if stored_action != "throwing_knife":
		action_points -= 1
		update_action_points()

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

	if attack_dictionary.get("target") != "player":
		if get_node(attack_dictionary.get("target")).dead == true:

			var new_target
			for i in enemies.get_children():
				
				if i.dead == false:
					
					new_target = self.get_path_to(i)
					attack_dictionary["target"] = new_target


		battle_effects.position = get_node(attack_dictionary["target"]).rect_position + Vector2(-20,20)
		battle_effects.play(attack_dictionary.get("animation"))
		yield(battle_effects, "animation_finished")

	if attack_dictionary.get("damage") >= 0:
		update_log(attack_dictionary.get("description"))
		get_node(attack_dictionary.get("target")).damage(attack_dictionary.get("damage"))

		if attack_dictionary.get("status") != null:
			get_node(attack_dictionary.get("target")).set_status(statuses.get(attack_dictionary["status"]))
			print(statuses.get(attack_dictionary["status"]))

	elif attack_dictionary.get("damage") < 0:

		battle_effects.global_position = Vector2(800, 650)
		battle_effects.play(attack_dictionary.get("animation"))
		yield(battle_effects, "animation_finished")
		pain(attack_dictionary.get("damage"))

	audio.stream = attack_dictionary.get("sound")
	audio.play(0)


func _on_battle_effects_animation_finished():

	battle_effects.play("default")
	battle_effects.playing = false
	timer.start(1)
	yield(timer, "timeout")

	if player_turn == true:
		print(enemies.dead_dudes)
		if enemies.get_children().size() == enemies.dead_dudes:
			call_deferred("end_combat_trans")#end_combat

		elif queued_player_actions.size() == 0:
			call_deferred("start_enemy_turn")

		elif queued_player_actions.size() > 0:
			call_deferred("activate_player_actions")

	elif player_turn == false:
		if enemies.get_children().size() == enemies.dead_dudes:
			call_deferred("end_combat_trans")#end_combat

		if queued_enemy_actions.size() != 0:
			call_deferred("activate_enemy_actions")

		else:
			for i in enemies.get_children():
				i.turn_end_status_maintenance()
			
			call_deferred("start_player_turn")



func end_combat_trans():
	Transitions.dual_circles(0,1,Color.black)
	queued_player_actions.clear()
#	end_combat_timer.start()
	pass

func end_combat():
	call_deferred("clear_log")
	enemies.queue_free()
	hud.hide()
	action_hud.visible = false
	item_hud.visible = false
	visible = false
	player.inbattle = false






func death():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/GameOver.tscn")
	print("penis wenis pro shenis")
	pass



func pain(_dam):
	if defending == true and _dam > 0:
		_dam = int(_dam * .25)
	PlayerStats.hurt(_dam)
	_STAT.update_health(_dam)#update_display()

	if _dam == -20:
		update_log(player_actions.get("bandage_heal")["description"])
		audio.stream = healsound
		audio.play(0)

	if _dam == -80:
		update_log(player_actions.get("potion_heal")["description"])
		audio.stream = healsound
		audio.play(0)
	else:
		audio.stream = hit_sound
		audio.play(0)
		

func update_action_points():

	action_point.play(str(action_points))


func update_log(combat_text):

	combat_log.text = combat_log.text + combat_text


func clear_log():

	combat_log.text = ""


func update_inventory():

	for i in inventory:
		if PlayerStats.get(i.name) >0 :
			i.get_child(0).text = str(PlayerStats.get(i.name))
			i.show()


func _on_item_mouse_entered(item : String):
	item_description.text = player_actions[item]["description2"]
	

