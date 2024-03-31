extends AnimatedSprite3D

func _ready():
	set_animation("Shut")

func openup():
	set_animation("Open")
	playing = true




