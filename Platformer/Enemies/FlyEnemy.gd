tool
extends Path2D

enum ANIMATION_TYPE {
	LOOP,
	BOUNCE
}

export(ANIMATION_TYPE) var animation_type setget set_animation_type
export(int) var speed = 1 setget set_speed

onready var animationPlayer: = $AnimationPlayer

func set_animation_type(type):
	animation_type = type
	var animPlayer = find_node("AnimationPlayer")
	if animPlayer:
		play_animation(animPlayer)

func set_speed(value):
	speed = value
	var animPlayer = find_node("AnimationPlayer")
	if animPlayer:
		animPlayer.playback_speed = speed

func _ready():
	play_animation(animationPlayer)

func play_animation(animPlayer):
	match animation_type:
		ANIMATION_TYPE.LOOP: animPlayer.play("MoveAlongPathLoop")
		ANIMATION_TYPE.BOUNCE: animPlayer.play("MoveAlongPathBounce")
