extends Node2D

onready var tween = $Tween 
onready var damage_text = $Label


func damage_pop_up(damage: int, location: Vector2):
	show()
	var damage_string

	if damage < 0:
		damage_string = "+" + str(damage).right(1)

	else:
		damage_string = str(damage)

	tween.interpolate_property(self, "position", location, location + Vector2(10, -50), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)

	damage_text.text = damage_string
	tween.start()



func _on_Tween_tween_all_completed():
	hide()

