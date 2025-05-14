class_name Player extends RigidBody2D

@export var top_speed: float = 50.0
@export var speed_curve: Curve

var contact_position := Vector2.ZERO
var contact_normal := Vector2.ZERO

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	process_tilt_automove(_delta)

func process_tilt_automove(_delta: float) -> void:
	#var axis := -Input.get_axis("test_left", "test_right")
	#apply_torque(-axis * 3000000.0)
	
	var angle90 = min(90, abs(rotation_degrees))
	var speed_factor = speed_curve.sample(angle90)

	if is_on_floor():
		var force: float = 1.0 * mass * 500.0 * speed_factor * signf(rotation_degrees)
		apply_central_force(contact_normal.rotated(deg_to_rad(90)) * force)
		pass

func process_feet_move(_delta: float) -> void:
	var axis := -Input.get_axis("test_left", "test_right")
	if is_on_floor():
		var force: float = 1.0 * mass * 500.0 * axis
		apply_force(contact_normal.rotated(deg_to_rad(90)) * force, contact_position)

	queue_redraw()
	pass

func is_on_floor() -> bool:
	return not contact_position.is_zero_approx() and abs(rotation_degrees) < 60.0

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	contact_position = Vector2.ZERO
	for i in range(state.get_contact_count()):
		var body := state.get_contact_collider_object(i)
		if body is StaticBody2D:
			contact_position = to_local(state.get_contact_collider_position(i))
			contact_normal = state.get_contact_local_normal(i)

func _draw() -> void:
	if is_on_floor():
		draw_circle(contact_position, 10.0, Color.RED, false)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		apply_torque_impulse(event.relative.x * 2000.0)
	if event.is_action_pressed("capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_VISIBLE
