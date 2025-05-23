extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print('bunker entered')
	print(body)
	get_tree().change_scene_to_file("res://scenes/Level Complete.tscn")
