extends TextureRect

var dead_dudes : int = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.

func on_enemy_death():

	dead_dudes += 1
