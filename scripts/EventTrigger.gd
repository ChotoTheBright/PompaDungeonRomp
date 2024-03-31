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
				match encounter:
					0:
						PlayerStats.use_item("throwing_knife", 6)
						PlayerStats.use_item("potion_heal", 2)
					1:
						PlayerStats.use_item("bandage_heal", 6)
					2:
						PlayerStats.use_item("bandage_heal", 6)
					3:
						PlayerStats.use_item("web_ball", 4)
					4:
						PlayerStats.use_item("web_ball", 4)
					5:
						PlayerStats.use_item("fuzzy_dust", 6)
					6:
						PlayerStats.use_item("sphere", 6)
					7:
						PlayerStats.use_item("bandage_heal", 6)
						PlayerStats.use_item("throwing_knife", 6)
				emit_signal("eventitem")
				emit_signal("eventswitch")
				emit_signal("eventcutscene")
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









func openup():
	pass # Replace with function body.
