extends Node2D

enum {
	HOVER,
	FALL,
	LAND,
	RISE
}

var state = HOVER

onready var init_position = global_position
onready var timer: = $Timer
onready var raycast: = $RayCast2D
onready var aSprite: = $AnimatedSprite
onready var particles: = $Particles2D

func _physics_process(delta):
	match state:
		HOVER: hover_state()
		FALL: fall_state(delta)
		LAND: land_state()
		RISE: rise_state(delta)

func hover_state():
	state = FALL

func fall_state(delta):
	aSprite.play("Falling")
	position.y += 60 * delta
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		position.y = collision_point.y
		state = LAND
		timer.start(1.0)
		particles.emitting = true

func land_state():
	aSprite.play("Rising")
	if timer.time_left == 0:
		state = RISE

func rise_state(delta):
	aSprite.play("Falling")
	position.y = move_toward(position.y, init_position.y, 30 * delta)
	if position.y == init_position.y:
		state = HOVER
