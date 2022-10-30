extends CanvasLayer

onready var animationPlayer: = $AnimationPlayer

signal transition_complete

func exit_level_transition():
	animationPlayer.play("ExitLevel")

func enter_level_transition():
	animationPlayer.play("EnterLevel")

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("transition_complete")
