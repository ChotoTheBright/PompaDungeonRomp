extends Label

var health = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_health(amnt):
	health = amnt
	update_display()

func update_display():
	text = "Health: " + str(health)
