extends CanvasLayer

onready var inventory = $inventory.get_children()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.

func on_pause():
	show()
	get_tree().paused = true
	$GridContainer/Button.grab_focus()
	update_inventory()

func update_inventory():

	for i in inventory:
		if PlayerStats.get(i.name) >0 :
			i.get_child(0).text = str(PlayerStats.get(i.name))
			i.show()


func _on_continue_pressed():
	hide()
	get_tree().paused = false



func _on_quit_pressed():
	get_tree().quit()
