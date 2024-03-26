extends CanvasLayer

onready var main_hud = $HUD/main_hud
onready var item_hud = $HUD/item_hud
onready var _STAT = get_tree().get_nodes_in_group("STATLABEL")[0]


var stored_action : String =""
var stored_target

var queued_player_actions : Array = []
var queued_knife_targets : Array = []
var player_action_targets : Array = []
var player_actions : int = 0
var action_index : int = 0
var queued_knives : float = 0
var _dam #damage

var queued_enemy_actions : Array = []
var enemy_action_targets : Array = []

var enemies 



func _ready():
	PlayerStats.init()
# warning-ignore:return_value_discarded
	PlayerStats.connect("dead", self, "death")
#	PlayerStats.connect("hurt", self, "pain")
#	PlayerStats.connect("dead", self, "death")
	
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


func start_combat():

	enemies = get_tree().get_nodes_in_group("encounter").front()
	
	start_player_turn()

func start_player_turn():

	player_actions = 2
	main_hud.visible = true


func start_enemy_turn():

	for i in enemies.get_children():

		i.attack()

	start_player_turn()


func death():
	print("penis wenis pro shenis")
	pass


func pain(__dam):
	PlayerStats.hurt(_dam)
	_STAT.update_display()
	

func queue_enemy_action(action: String, target : NodePath):

	queued_enemy_actions.append(action)
	enemy_action_targets.append(target)





func queue_player_action(target : NodePath):



	if stored_action == "throwing_knife":
		queued_knives += 1
		queued_knife_targets.append(target)

	elif stored_action != "throwing_knife":
		player_actions -= 1
		queued_player_actions.append(stored_action)
		player_action_targets.append(target)

	if player_actions == 0:
		activate_player_actions()

	elif player_actions > 0:
		main_hud.visible = true
		item_hud.visible = false

	for i in enemies.get_children():
		i.mouse_filter = false

	print(player_actions)



func activate_player_actions():
	
	if queued_player_actions.size() == 0:
		start_enemy_turn()
	
	else:
		main_hud.visible = false
		item_hud.visible = false
	
		if queued_knives > 0:
			throwing_knife(queued_knives)
	
		call(queued_player_actions.pop_front(), player_action_targets.pop_front())

	
	if queued_player_actions.size() > 0:
		activate_player_actions()



##player actions


func attack(target):

	get_node(target).damage(10)



func sleep_gas(target):

	print("sleep_gas")

func throwing_knife(knives):
	queued_knives = 0
	print("knife")

func sphere():

	print("sphere")

func fuzzy_dust():

	print("fuzzy_dust")

func defend():

	print("defend")


func bandage():

	print("bandage")

func potion():

	print("potion")



##enemy_actions



func bleed_hit():
#	playerstats
	print("bleed hit")


func double_hit():

	print("double hit")


func spot():

	print("spot")


func hype():

	print("hype")


func shield_bash():

	print("shield_bash")


func rally():

	print("rally")






