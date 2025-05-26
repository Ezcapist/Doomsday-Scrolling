class_name Player extends RigidBody2D

@export var top_speed: float = 50.0
@export var tilt_strength: float = 1000.0
@export var walk_strength: float = 500.0
@export var fly_strength: float = 100.0
@export var damp_strength: float = 500.0
@export var max_bend_angle: float = 70.0
@export var upright_recover_angle: float = 50.0
@export var upright_kick_strength: float = 1000.0
@export var max_up_velocity: float = 500.0
@export var speed_curve: Curve

@onready var lower_body: Node2D = %Onderlichaam
@onready var anim: AnimationPlayer = %Anim

var contact_normal := Vector2.UP
var is_on_floor := false
var is_lying_down := false
var axis: float = 0.0

const COYOTE_TIME: float = 0.2
var coyote_timer: float = 0.0

enum State {
	Walking,
	Flying,
	LyingDown,
}
var state := State.Walking

func _ready() -> void:
	pass

func _integrate_forces(directstate: PhysicsDirectBodyState2D):
	is_on_floor = false

	for i in range(directstate.get_contact_count()):
		var body := directstate.get_contact_collider_object(i)
		var normal := directstate.get_contact_local_normal(i)

		if body is StaticBody2D and normal.dot(Vector2.UP) > 0:
			is_on_floor = true
			contact_normal = normal

func _physics_process(delta: float):
	is_lying_down = is_on_floor and abs(rotation_degrees) > max_bend_angle
	axis = Input.get_axis("move_left", "move_right")

	if state == State.Walking:
		process_tilt(delta)
		process_walking(delta)
		process_friction(delta)
		lower_body.rotation_degrees = clamp(-rotation_degrees, -max_bend_angle, max_bend_angle)

		# Zorg dat de speler extra tijd heeft om te lopen/springen nadat hij ergens
		# vanaf valt.
		if is_on_floor:
			coyote_timer = COYOTE_TIME
		if not is_on_floor:
			coyote_timer -= delta
		if coyote_timer <= 0:
			state = State.Flying
		
		if is_lying_down:
			state = State.LyingDown
		
		anim.speed_scale = 1.0
		anim.play("Walking")

	elif state == State.Flying:
		process_tilt(delta)
		if is_on_floor:
			state = State.Walking
		if linear_velocity.y < -max_up_velocity:
			linear_velocity.y = -max_up_velocity
		apply_central_force(Vector2.RIGHT * fly_strength * mass * signf(rotation_degrees))
		anim.speed_scale = 0.3
	
	elif state == State.LyingDown:
		process_friction(delta)
		reset_lowerbody_rotation(delta)

		# Play crying animation.
		anim.speed_scale = 1.0
		if anim.current_animation == "Walking":
			anim.play("Crying")
		elif not anim.is_playing():
			anim.play("Crying")
		
		# Play kick animation when spamming movement buttons.
		if Input.is_action_just_pressed("move_left"):
			push_upright(-1.0)
			anim.stop()
			anim.play("RageKick")
		if Input.is_action_just_pressed("move_right"):
			push_upright(1.0)
			anim.stop()
			anim.play("RageKick")
		
		# Recover the baby when we are sufficiently upright.
		# Not the same as "max_bend_angle" !
		if abs(rotation_degrees) < upright_recover_angle:
			state = State.Walking

func process_tilt(delta: float):
	var tilt_force = axis * mass * tilt_strength
	apply_torque(tilt_force * 200.0)

func process_friction(delta: float):
	# Apply friction (damping).
	apply_central_force(-linear_velocity.normalized() * mass * damp_strength)

func process_walking(delta: float) -> void:
	# Sample the speed for this angle. Higher tilt is higher speed, depends on the curve.
	var angle90 = clamp(rotation_degrees, -90, 90)
	var speed_factor = speed_curve.sample(angle90)
	var force: float = (mass * (walk_strength * speed_factor + damp_strength)) * signf(angle90)

	# Apply walking velocity if not at top speed.
	if linear_velocity.length() > top_speed:
		force = 0
	anim.speed_scale = linear_velocity.length() / top_speed
	apply_central_force(Vector2.RIGHT * force)

func reset_lowerbody_rotation(delta):
	lower_body.rotation = lerp_angle(lower_body.rotation, 0.0, delta*10.0)

func push_upright(direction: float):
	apply_torque_impulse(direction * 100 * upright_kick_strength * mass)


func get_state_string() -> String:
	match state:
		State.Walking: return "Walking"
		State.Flying: return "Flying"
		State.LyingDown: return "LyingDown"
	return "Unknown"
