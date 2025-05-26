extends Area2D

@export var extra_velocity = 500.0
@export var bounciness = 1.0

func _on_area_body_entered(body: Node2D):
	if body is RigidBody2D:
		var dir = -global_transform.y
		body.linear_velocity = body.linear_velocity.bounce(dir) * bounciness + extra_velocity * dir
	pass
