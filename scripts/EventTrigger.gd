extends Area

enum EVENTS {BATTLE, CUTSCENE, DOOR, ITEM, SWITCH}
export(EVENTS) var event_type

onready var col = $Col #Triggers must have a collis.shape with this name

signal eventbattle
signal eventcutscene
signal eventdoor
signal eventitem
signal eventswitch

func _ready():
	pass

func on_body_entered(body):
	if body.is_in_group("player"):
		match event_type:
			EVENTS.BATTLE:
				emit_signal("eventbattle")
			EVENTS.CUTSCENE:
				emit_signal("eventcutscene")
			EVENTS.DOOR:
				emit_signal("eventdoor")
			EVENTS.ITEM:
				emit_signal("eventitem")
			EVENTS.SWITCH:
				emit_signal("eventswitch")
		col.disabled = true
		return










#
#extends Area
#class_name Pickup
#enum PICKUP_TYPES {PISTOLS, SHOTGUN, AUTOMATIC, HURACAN, ROCKET_L, BOW, XBOW,
#	AUTOMATIC_AMMO, PISTOL_AMMO, SHOTGUN_AMMO, HURACAN_AMMO, ROCKET_L_AMMO, BOW_AMMO, 
#	XBOW_AMMO, HEALTH, FOOD}
#
#export(PICKUP_TYPES) var pickup_type
#export var ammo = 20
#export var rotating = false
#export var is_food = false
#
#onready var anim_player = $AnimationPlayer
#
#func _ready():
#	if rotating == true:
#		anim_player.play("rotate")
