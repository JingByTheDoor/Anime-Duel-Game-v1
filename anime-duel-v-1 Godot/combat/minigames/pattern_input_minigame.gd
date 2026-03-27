class_name PatternInputMiniGame
extends MiniGameBase

var _sequence: PackedStringArray = []
var _input_index := 0
var _errors := 0
var _time_limit := 2.3
var _elapsed := 0.0

func begin(mini_game_data: MiniGameData, run_context: Dictionary) -> void:
	super.begin(mini_game_data, run_context)
	_sequence.clear()
	_input_index = 0
	_errors = 0
	_time_limit = 2.3
	_elapsed = 0.0
	if DebugConfig.forced_grade >= 0:
		return
	var rng: RandomNumberGenerator = run_context.get("rng")
	var length := int(mini_game_data.sequence_lengths.pick_random())
	if rng:
		length = mini_game_data.sequence_lengths[rng.randi_range(0, mini_game_data.sequence_lengths.size() - 1)]

	for index in length:
		var key_index := randi_range(0, mini_game_data.sequence_keys.size() - 1)
		if rng:
			key_index = rng.randi_range(0, mini_game_data.sequence_keys.size() - 1)
		_sequence.append(mini_game_data.sequence_keys[key_index])

	_time_limit = float(mini_game_data.pattern_time_limits.get(length, 2.3))
	$Panel/VBox/Sequence.text = " ".join(_sequence)
	$Panel/VBox/Status.text = "Input the sequence"
	_update_progress()
	set_process(true)

func _process(delta: float) -> void:
	if not is_interaction_enabled():
		return
	_elapsed += delta
	_update_progress()
	if _elapsed >= _time_limit:
		set_process(false)
		_finish(DuelTypes.Grade.MISS, _errors, true, 0.0, {"sequence": _sequence})

func _update_progress() -> void:
	$Panel/VBox/Timer.text = "Time %.2f / %.2f" % [_elapsed, _time_limit]
	$Panel/VBox/Progress.text = "Progress %d / %d" % [_input_index, _sequence.size()]

func _unhandled_input(event: InputEvent) -> void:
	if DebugConfig.forced_grade >= 0 or not is_interaction_enabled():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_text := OS.get_keycode_string(event.keycode).to_upper()
		if _input_index >= _sequence.size():
			return
		if key_text == _sequence[_input_index]:
			_input_index += 1
			if _input_index >= _sequence.size():
				set_process(false)
				var ratio: float = _elapsed / max(_time_limit, 0.01)
				var grade: int = DuelTypes.Grade.GOOD
				if _errors > 0:
					grade = DuelTypes.Grade.WEAK
				elif ratio <= 0.55:
					grade = DuelTypes.Grade.PERFECT
				_finish(grade, _errors, false, 1.0 - ratio, {"sequence": _sequence})
			else:
				$Panel/VBox/Status.text = "Keep the rhythm"
		else:
			_errors += 1
			if _errors > 1:
				set_process(false)
				_finish(DuelTypes.Grade.MISS, _errors, false, 0.0, {"sequence": _sequence, "failed_key": key_text})
			else:
				$Panel/VBox/Status.text = "Correction used"
