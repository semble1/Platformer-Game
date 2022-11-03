extends KinematicBody2D

var direction = Vector2.RIGHT
var velocity = Vector2.ZERO

onready var edgeCheck = $EdgeCheck

func _physics_process(delta):
	var found_wall = is_on_wall()
	var found_edge = not edgeCheck.is_colliding()
	
	if found_wall or found_edge:
		direction *= -1
		scale.x = sign(-1)
	
	velocity = direction * 30
	move_and_slide(velocity, Vector2.UP)

func _on_Hurtbox_area_entered(area):
	queue_free()
