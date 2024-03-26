extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerStats.init()
# warning-ignore:return_value_discarded
	PlayerStats.connect("dead", self, "death")
	pass

func death():
	print("penis wenis pro shenis")
	pass
