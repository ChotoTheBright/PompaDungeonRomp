extends Control

func _ready():
	pass 

func retry():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MAIN.tscn")

func quit_game():
	get_tree().quit()
