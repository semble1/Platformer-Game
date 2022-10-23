extends KinematicBody2D
class_name Player

enum {
	MOVE,
	CLIMB
}

export(Resource) var moveData

var velocity = Vector2.ZERO
var state = MOVE

onready var aSprite = $AnimatedSprite
onready var ladderCheck = $LadderCheck

func _ready():
	aSprite.frames = load("res://PlayerDefault.tres")

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")

	match state:
		MOVE: move_state(input)
		CLIMB: climb_state(input)

func move_state(input):
	if is_on_ladder() and Input.is_action_pressed("ui_up"):
		state = CLIMB

	apply_gravity()

	if input.x == 0:
		apply_friction()
		aSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		aSprite.animation = "Run"
		if input.x > 0:
			aSprite.flip_h = false
			aSprite.offset.x = 0
		elif input.x < 0:
			aSprite.flip_h = true
			aSprite.offset.x = -1

	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = moveData.JUMP_FORCE
	else:
		aSprite.animation = "JumpUp"
		if Input.is_action_just_released("ui_up") and velocity.y < moveData.JUMP_RELEASE:
			velocity.y = moveData.JUMP_RELEASE

	if velocity.y > 0:
		if not is_on_floor():
			aSprite.animation = "JumpDown"
		velocity.y += moveData.ADDED_GRAVITY

	var was_in_air = not is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		aSprite.animation = "Idle"
		aSprite.frame = 0

func climb_state(input):
	if not is_on_ladder():
		state = MOVE

	if input.length() != 0:
		aSprite.animation = "Climb"

	velocity = input * 50
	velocity = move_and_slide(velocity, Vector2.UP)

func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true

func apply_gravity():
	velocity.y += moveData.GRAVITY
	velocity.y = min(velocity.y, 300)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION)

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)
