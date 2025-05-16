extends Area2D

#Spawning Missiles
func _ready():
	print('Missile Drop')
	var rng:= RandomNumberGenerator.new()
	
	var width = get_viewport().get_visible_rect().size[0]
	var random_x = rng.randi_range(0, width)
	var random_y = rng.randi_range(-350,-750)
	position = Vector2(random_x, random_y) 

#Movement Missiles
func _process(delta):
	#var rng:= RandomNumberGenerator.new()
	#var MissileSpeed = rng.randi_range(10,400)
	position += Vector2(0, 1.0) * 100 * delta
	
	
#####var explosion_scene: PackedScene = load("res://scenes/explosion.tscn")

#Game Over
func _on_body_entered(body: Node2D) -> void:
	print('body entered')
	print(body)
	###var explosion = explosion_scene.instantiate()
	####add_child(explosion)
	$Explosion.play()
	$BabyDeath.play()
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	

	
