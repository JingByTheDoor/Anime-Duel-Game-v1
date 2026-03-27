class_name CharacterSelectScreen
extends Control

signal character_selected(character_id: String)
signal back_requested

func _ready() -> void:
	$Margin/VBox/Hint.text = "Choose your duelist"
	$Margin/VBox/OptionOne.text = "1  Martial Artist  |  Flow, tempo, smoother recovery"
	$Margin/VBox/OptionTwo.text = "2  Samurai  |  Heavier commitment, lethal payoff"
	$Margin/VBox/BackHint.text = "ESC  Back"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				character_selected.emit("martial_artist")
				get_viewport().set_input_as_handled()
			KEY_2:
				character_selected.emit("samurai")
				get_viewport().set_input_as_handled()
			KEY_ESCAPE, KEY_BACKSPACE:
				back_requested.emit()
				get_viewport().set_input_as_handled()
