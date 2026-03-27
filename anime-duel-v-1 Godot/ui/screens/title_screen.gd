class_name TitleScreen
extends Control

signal start_requested
signal tutorial_requested
signal quit_requested

func _ready() -> void:
	$Margin/VBox/PrimaryHint.text = "ENTER  Start Duel"
	$Margin/VBox/TutorialHint.text = "T  Tutorial"
	$Margin/VBox/QuitHint.text = "ESC  Quit"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ENTER, KEY_KP_ENTER:
				start_requested.emit()
				get_viewport().set_input_as_handled()
			KEY_T:
				tutorial_requested.emit()
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				quit_requested.emit()
				get_viewport().set_input_as_handled()
