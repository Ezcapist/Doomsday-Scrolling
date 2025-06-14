extends Area2D

#Spawning Missiles
func _ready():
	print('Missile Drop')
	var rng:= RandomNumberGenerator.new()
	
	var width = get_viewport().get_visible_rect().size[0]
	var camera = get_viewport().get_camera_2d().global_position.x
	var random_x = rng.randi_range(0, width)
	var random_y = rng.randi_range(-350,-750)
	position = Vector2(random_x  + camera, random_y) 
	print(position.x)

#Movement Missiles
func _process(delta):
		position += Vector2(0, 1.0) * 200 * delta
	
	
#Game Over
func _on_body_entered(body: Node2D) -> void:
	print('missile hit')
	print(body)
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
