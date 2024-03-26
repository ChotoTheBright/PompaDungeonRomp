extends CanvasLayer

onready var diorama_container = $diorama_container
onready var main_hud = $HUD/main_hud
onready var item_hud = $HUD/item_hud
onready var player = get_tree().get_nodes_in_group("player").front()

var stored_action : String =""
var stored_target

var queued_player_actions : Array = []
var queued_knife_targets : Array = []
var player_action_targets : Array = []
var player_actions : int = 0
var action_index : int = 0
var queued_knives : float = 0


var queued_enemy_actions : Array = []
var enemy_action_targets : Array = []

var enemies 

var encounter


var defending : bool = false

func _ready():
	
	player.inbattle = true
	
	PlayerStats.init()
# warning-ignore:return_value_discarded
	PlayerStats.connect("dead", self, "death")
	
	start_combat()
	pass



##HUD functions



func _on_action_button_pressed(action):

	print("click")
	stored_action = action
	
	main_hud.visible = false
	item_hud.visible = false
	
	for i in enemies.get_children():
		i.mouse_filter = 0


func _on_item_pressed():
	main_hud.visible = false
	item_hud.visible = true






##turn functions

func start_combat():
	
	
	enemies = get_tree().get_nodes_in_group("encounter").front()
	
	start_player_turn()





func start_player_turn():

	if defending == true:
		defending = false

	player_actions = 2
	main_hud.visible = true




func start_enemy_turn():

	for i in enemies.get_children():

		i.attack()
		print("attack")
		
	start_player_turn()





func queue_enemy_action(action: String):

	queued_enemy_actions.append(action)






func queue_player_action(target : NodePath):



	if stored_action == "throwing_knife":
		queued_knives += 1
		queued_knife_targets.append(target)

	else:

		player_actions -= 1
		queued_player_actions.append(stored_action)
		
		if stored_action != "defend":
			player_action_targets.append(target)



	if player_actions == 0:
		activate_player_actions()

	else:
		main_hud.visible = true
		item_hud.visible = false


	for i in enemies.get_children():
		i.mouse_filter = false

	print(player_actions)








func activate_player_actions():
	

	main_hud.visible = false
	item_hud.visible = false
	
	if queued_knives > 0:
		throwing_knife(queued_knives)
	
	call(queued_player_actions.pop_front(), player_action_targets.pop_front())



	
	if queued_player_actions.size() > 0:
		activate_player_actions()

	elif queued_player_actions.size() == 0:
		call_deferred("end_player_turn")


func end_player_turn():



	print(enemies.get_children().size())
	
	if enemies.get_children().size() == 0:
		end_combat()

	else:
		start_enemy_turn()


func end_combat():

	main_hud.visible = false
	item_hud.visible = false
	self.visible = false
	
	player.inbattle = false


##player actions

func death():
	print("penis wenis pro shenis")
	pass


func attack(target):

	get_node(target).damage(10)


func sleep_gas(target):

	get_node(target).sleep = true


func throwing_knife(knives):
	queued_knives = 0
	print(knives)


func sphere(target):

	target.sphere()


func fuzzy_dust(target):

	target.dizzy = true


func defend(target):

	defending = true


func bandage(target):

	pass


func potion(target):

	print("potion")



##enemy_actions



func bleed_hit():

	print("bleed hit")


func double_hit():

	print("double hit")


func spot(target):

	print("spot")


func hype(target):

	print("hype")


func shield_bash():

	print("shield_bash")


func rally():

	print("rally")


func bodyblock():
	
	print("bodyblock")



