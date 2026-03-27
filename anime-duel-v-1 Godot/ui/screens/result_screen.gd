class_name ResultScreen
extends Control

signal rematch_requested
signal switch_character_requested
signal switch_difficulty_requested
signal title_requested

func set_result(result: Dictionary) -> void:
	var outcome_text: String = str(result.get("outcome_text", "Duel complete."))
	var winner_text: String = str(result.get("winner_text", "Draw"))
	var replay_count: int = int(result.get("highlight_count", 0))
	$Margin/VBox/Outcome.text = outcome_text
	$Margin/VBox/Winner.text = winner_text
	$Margin/VBox/ReplayInfo.text = "Highlights captured: %d" % replay_count

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_R:
				rematch_requested.emit()
				get_viewport().set_input_as_handled()
			KEY_C:
				switch_character_requested.emit()
				get_viewport().set_input_as_handled()
			KEY_D:
				switch_difficulty_requested.emit()
				get_viewport().set_input_as_handled()
			KEY_T:
				title_requested.emit()
				get_viewport().set_input_as_handled()
