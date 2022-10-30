extends KinematicBody2D
class_name Player

enum {
	MOVE,
	CLIMB
}

export(Resource) var moveData = preload("res://Player/DefaultPlayerMovement.tres") as PlayerMovement

var velocity = Vector2.ZERO
var state = MOVE
var double_jump = true
var buffered_jump = false
var coyote_jump = false
var on_door = false

onready var aSprite: = $AnimatedSprite
onready var ladderCheck: = $LadderCheck
onready var jumpBufferTimer: = $JumpBufferTimer
onready var coyoteJumpTimer: = $CoyoteJumpTimer
onready var remoteTransform2D: = $RemoteTransform2D

func _ready():
	aSprite.frames = load("res://Player/PlayerDefault.tres")

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")

	match state:
		MOVE: move_state(input, delta)
		CLIMB: climb_state(input)

func move_state(input, delta):
	if is_on_ladder() and Input.is_action_just_pressed("ui_up"):
		state = CLIMB

	apply_gravity(delta)

	horizontal_move(input, delta)

	if is_on_floor():
	#Change to double_jump = moveData.DOUBLE_JUMPS
		double_jump = true #Reset double jump
	else:
		aSprite.animation = "JumpUp"

	if can_jump():
		input_jump()
	else:
		input_jump_release()
		input_double_jump()
		buffer_jump()
		fast_fall(delta)

	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		aSprite.animation = "Idle"
		aSprite.frame = 0
	
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		coyoteJumpTimer.start()

func climb_state(input):
	if not is_on_ladder():
		state = MOVE

	if input.length() != 0:
		aSprite.animation = "Climb"

	velocity = input * moveData.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)

func player_die():
	SoundPlayer.play_sound(SoundPlayer.HURT)
	queue_free()
	Events.emit_signal("player_died")

func connect_camera(camera):
	var camera_path = camera.get_path()
	remoteTransform2D.remote_path = camera_path

func input_jump_release():
	if Input.is_action_just_released("ui_up") and velocity.y < moveData.JUMP_RELEASE:
		velocity.y = moveData.JUMP_RELEASE

func input_double_jump():
#for more than 1 double jump, change double_jump = true to double_jump = 1
#and double_jump == true to double_jump > 0 and double_jump = false tp double_jump -=1
	if Input.is_action_just_pressed("ui_up") and double_jump == true:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.JUMP_FORCE
		double_jump = false

func buffer_jump():
	if Input.is_action_just_pressed("ui_up"):
		buffered_jump = true
		jumpBufferTimer.start()

func fast_fall(delta):
	if velocity.y > 0:
		if not is_on_floor():
			aSprite.animation = "JumpDown"
			velocity.y += moveData.ADDED_GRAVITY * delta

func horizontal_move(input, delta):
	if input.x == 0:
		apply_friction(delta)
		aSprite.animation = "Idle"
	else:
		apply_acceleration(input.x, delta)
		aSprite.animation = "Run"
		if input.x > 0:
			aSprite.flip_h = false
			aSprite.offset.x = 0
		elif input.x < 0:
			aSprite.flip_h = true
			aSprite.offset.x = -1

func can_jump():
	return is_on_floor() or coyote_jump

func input_jump():
	if on_door:
		return
	if Input.is_action_just_pressed("ui_up") or buffered_jump:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.JUMP_FORCE
		buffered_jump = false

func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true

func apply_gravity(delta):
	velocity.y += moveData.GRAVITY * delta
	velocity.y = min(velocity.y, 300)

func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION * delta)

func apply_acceleration(amount, delta):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION * delta)

func _on_JumpBufferTimer_timeout():
	buffered_jump = false

func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false
