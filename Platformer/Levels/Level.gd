extends Node2D

const PlayerScene = preload("res://Player/Player.tscn")

var player_spawn_location = Vector2.ZERO

onready var camera: = $Camera2D
onready var player: = $Player
onready var timer: = $Timer

func _ready():
	VisualServer.set_default_clear_color(Color.lightblue)
	player.connect_camera(camera)
	player_spawn_location = player.global_position
	Events.connect("player_died", self, "_on_player_died")
	Events.connect("enemy_died", self, "_on_enemy_died")
	Events.connect("pass_checkpoint", self, "_on_pass_checkpoint")

func _on_enemy_died():
	pass

func _on_player_died():
	timer.start(1.0)
	yield(timer, "timeout")
	var player = PlayerScene.instance()
	player.position = player_spawn_location
	add_child(player)
	player.connect_camera(camera)

func _on_pass_checkpoint(checkpoint_position):
	player_spawn_location = checkpoint_position
