extends Control

onready var Target_XZ = get_tree().get_nodes_in_group("player")[0]
onready var Target_Y = get_tree().get_nodes_in_group("worldspace")[0]
onready var cam = $ViewportContainer/Viewport/Camera


# warning-ignore:unused_argument
func _physics_process(delta):
	cam.translation.x = Target_XZ.get_global_transform().origin.x
	cam.translation.z = Target_XZ.get_global_transform().origin.z
	cam.translation.y = Target_Y.get_global_transform().origin.y + 40.0
