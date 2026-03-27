class_name DifficultySelectScreen
extends Control

signal difficulty_selected(difficulty_id: String)
signal back_requested

var player_character_name := ""

func set_player_character(name: String) -> void:
	player_character_name = name
	if is_node_ready():
		_refresh()

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	$Margin/VBox/Subtitle.text = "Player: %s" % player_character_name
	$Margin/VBox/Easy.text = "1  Easy  |  readable habits, more mistakes"
	$Margin/VBox/Normal.text = "2  Normal  |  balanced reads and adaptation"
	$Margin/VBox/Hard.text = "3  Hard  |  sharper punish, stronger memory"
	$Margin/VBox/BackHint.text = "ESC  Back"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				difficulty_selected.emit("easy")
				get_viewport().set_input_as_handled()
			KEY_2:
				difficulty_selected.emit("normal")
				get_viewport().set_input_as_handled()
			KEY_3:
				difficulty_selected.emit("hard")
				get_viewport().set_input_as_handled()
			KEY_ESCAPE, KEY_BACKSPACE:
				back_requested.emit()
				get_viewport().set_input_as_handled()
