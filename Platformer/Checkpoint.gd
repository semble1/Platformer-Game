extends Area2D

onready var aSprite: = $AnimatedSprite

var active = true

func _on_Checkpoint_body_entered(body):
	if not body is Player: 
		return
	if not active:
		return
	active = false
	aSprite.play("Checked")
	Events.emit_signal("pass_checkpoint", position)
