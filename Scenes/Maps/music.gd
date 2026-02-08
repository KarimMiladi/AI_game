extends Node2D

@onready var player = $MusicPlayer

var current_track = ""

func play_music(path):
	if current_track == path:
		return
		
	current_track = path
	player.stream = load(path)
	player.play()

func _process(delta):
	if GameManager.task == 5:
		play_music("res://1-061. Bs Glade.mp3")
