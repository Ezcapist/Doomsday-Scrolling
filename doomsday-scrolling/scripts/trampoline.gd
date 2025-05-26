extends Area2D

@export var extra_velocity = 500.0
@export var bounciness = 1.0

func _on_area_body_entered(body: Node2D):
	if body is RigidBody2D:
		body.linear_velocity.y = -body.linear_velocity.y * bounciness - extra_velocity
	pass
