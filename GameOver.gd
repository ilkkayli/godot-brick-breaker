extends Control

signal restart_game
signal watch_ad

var final_score: int = 0
var high_score: int = 0

func _ready() -> void:
	$VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)
	$VBoxContainer/RewardedAdButton.pressed.connect(_on_rewarded_ad_pressed)

func setup(score: int, best: int) -> void:
	final_score = score
	high_score = best
	$VBoxContainer/ScoreLabel.text = "Score: " + str(final_score)
	$VBoxContainer/HighScoreLabel.text = "Best: " + str(high_score)

func _on_restart_pressed() -> void:
	restart_game.emit()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_rewarded_ad_pressed() -> void:
	watch_ad.emit()
	# Tähän tulee myöhemmin oikea ad-kutsu
	print("Rewarded ad katsottu → +1 elämä")
