extends Area2D

export(String, FILE, "*.tscn") var next_level = ""

func _on_Door_body_entered(body):
	if not body is Player:
		return
	if next_level.empty():
		return
	get_tree().change_scene(next_level)
