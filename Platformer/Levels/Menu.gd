extends Control

func _ready():
	$VBoxContainer/Start.grab_focus()

func _on_Start_pressed():
	Transition.exit_level_transition()
	get_tree().paused = true
	yield(Transition, "transition_complete")
	Transition.enter_level_transition()
	get_tree().paused = false
	get_tree().change_scene("res://Levels/Level1.tscn")

func _on_Quit_pressed():
	get_tree().quit()
