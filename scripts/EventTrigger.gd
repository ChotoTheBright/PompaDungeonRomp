extends Area

enum EVENTS {BATTLE, CUTSCENE, DOOR, ITEM, SWITCH}
export(EVENTS) var event_type

#Triggers must have a collis.shape with this name
onready var col = $Col 

signal eventbattle
signal eventcutscene
signal eventdoor
signal eventitem
signal eventswitch

func _ready():
	pass

func on_body_entered(body, encounter):
	if body.is_in_group("player"):
		match event_type:
			EVENTS.BATTLE:
				Transitions.dual_circles(encounter,1,Color.black)
				emit_signal("eventbattle")
			EVENTS.ITEM:
				emit_signal("eventitem")
		col.disabled = true
		return

func body_entered2(body):
	if body.is_in_group("player"):
		match event_type:
			EVENTS.CUTSCENE: #extra idea
				emit_signal("eventcutscene")
				emit_signal("eventdoor")
				emit_signal("eventswitch")
			EVENTS.DOOR: #extra idea
				emit_signal("eventdoor")
			EVENTS.SWITCH: #extra idea
				emit_signal("eventswitch")
		self.visible = false
		col.disabled = true
		return







