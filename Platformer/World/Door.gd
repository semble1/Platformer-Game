extends Area2D

export(String, FILE, "*.tscn") var next_level = ""

var player = false

func go_next_level():
	Transition.exit_level_transition()
	get_tree().paused = true
	yield(Transition, "transition_complete")
	Transition.enter_level_transition()
	get_tree().paused = false
	get_tree().change_scene(next_level)

func _process(delta):
	if not player:
		return
	if not player.is_on_floor():
		return
	if Input.is_action_just_pressed("ui_up"):
		if next_level.empty():
			return
		go_next_level()

func _on_Door_body_entered(body):
	if not body is Player:
		return
	body.on_door = true
	player = body

func _on_Door_body_exited(body):
	if not body is Player:
		return
	body.on_door = false
	player = null
