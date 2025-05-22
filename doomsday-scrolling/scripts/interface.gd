extends CanvasLayer

@export var player: Player
@onready var debug_label: Label = $DebugLabel

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	process_debug_label()

func process_debug_label():
	var text := ""
	text += "state=%s\n" % player.get_state_string()
	text += "coyote=%.1f\n" % player.coyote_timer
	text += "rotation=%.1f\n" % player.rotation_degrees
	text += "leg_counter_rotation=%.1f\n" % player.lower_body.rotation_degrees
	text += "is_on_floor=%s\n" % ("Yes" if player.is_on_floor else "No")

	debug_label.text = text
