class_name Player extends RigidBody2D

@export var top_speed: float = 50.0
@export var tilt_strength: float = 1000.0
@export var walk_strength: float = 500.0
@export var damp_strength: float = 500.0
@export var max_slope_angle: float = 45.0
@export var speed_curve: Curve

@onready var tilt_force_point: Node2D = $TiltForcePoint
@onready var floor_max_height: Node2D = $FloorCollisionMaxHeight
var contact_position := Vector2.ZERO
var contact_normal := Vector2.ZERO
var axis: float = 0.0

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	axis = Input.get_axis("move_left", "move_right")
	process_tilt_automove(_delta)

func process_tilt_automove(_delta: float) -> void:
	var tilt_force = axis * mass * tilt_strength
	apply_force(tilt_force * global_transform.x, tilt_force_point.position)

	if is_on_floor():
		# Sample the speed for this angle. Higher tilt is higher speed, depends on the curve.
		var angle90 = clamp(rotation_degrees - contact_normal.angle(), -90, 90)
		var speed_factor = speed_curve.sample(angle90)
		var force: float = 1.0 * mass * walk_strength * speed_factor * signf(angle90)

		# Apply walking velocity if not at top speed.
		if linear_velocity.length() > top_speed:
			force = 0
		apply_central_force(contact_normal.rotated(deg_to_rad(90)) * force)

		# Apply friction (damping).
		apply_central_force(-linear_velocity.normalized() * mass * damp_strength)

func process_feet_move(_delta: float) -> void:
	if is_on_floor():
		var force: float = 1.0 * mass * 500.0 * -axis
		apply_force(contact_normal.rotated(deg_to_rad(90)) * force, contact_position)

	queue_redraw()
	pass

func is_on_floor() -> bool:
	return not contact_position.is_zero_approx() and abs(rotation_degrees) < 60.0

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	contact_position = Vector2.ZERO
	for i in range(state.get_contact_count()):
		var body := state.get_contact_collider_object(i)
		var normal := state.get_contact_local_normal(i)
		var point := to_local(state.get_contact_local_position(i))

		if body is StaticBody2D and \
			normal.angle_to(Vector2.UP) < max_slope_angle \
			and point.y > floor_max_height.position.y:

			contact_position = point
			contact_normal = normal

func _draw() -> void:
	if is_on_floor():
		draw_circle(contact_position, 10.0, Color.RED, false)
