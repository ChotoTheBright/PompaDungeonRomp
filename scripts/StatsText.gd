extends Label

var health = 0

func _ready():
	health = 100
	update_display()

func update_health(amnt):
	health = clamp(health - amnt, 0, 100)
	update_display()

func update_display():
	text = "Health: " + str(health)
