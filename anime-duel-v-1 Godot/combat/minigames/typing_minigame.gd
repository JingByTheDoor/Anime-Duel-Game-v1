class_name TypingMiniGame
extends MiniGameBase

var _prompt := ""
var _typed := ""
var _elapsed := 0.0

func begin(mini_game_data: MiniGameData, run_context: Dictionary) -> void:
	super.begin(mini_game_data, run_context)
	_prompt = ""
	_typed = ""
	_elapsed = 0.0
	if DebugConfig.forced_grade >= 0:
		return

	var rng: RandomNumberGenerator = run_context.get("rng")
	if mini_game_data.typing_prompts.is_empty():
		_prompt = "parry"
	else:
		var index := randi_range(0, mini_game_data.typing_prompts.size() - 1)
		if rng:
			index = rng.randi_range(0, mini_game_data.typing_prompts.size() - 1)
		_prompt = mini_game_data.typing_prompts[index].to_lower()

	$Panel/VBox/Prompt.text = _prompt
	$Panel/VBox/InputEcho.text = ""
	set_process(true)

func _process(delta: float) -> void:
	_elapsed += delta
	$Panel/VBox/Timer.text = "Time %.2f / %.2f" % [_elapsed, config.typing_timeout]
	if _elapsed >= config.typing_timeout:
		set_process(false)
		_finish(DuelTypes.Grade.MISS, _count_errors(), true, 0.0, {"prompt": _prompt, "typed": _typed})

func _unhandled_input(event: InputEvent) -> void:
	if DebugConfig.forced_grade >= 0:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_BACKSPACE:
			if _typed.length() > 0:
				_typed = _typed.substr(0, _typed.length() - 1)
		elif event.keycode == KEY_SPACE:
			_typed += " "
		else:
			var text := OS.get_keycode_string(event.keycode).to_lower()
			if text.length() == 1 and text.unicode_at(0) >= 97 and text.unicode_at(0) <= 122:
				_typed += text
		$Panel/VBox/InputEcho.text = _typed
		if _typed.length() >= _prompt.length():
			set_process(false)
			var errors := _count_errors()
			var accuracy: float = 1.0 - (float(errors) / max(_prompt.length(), 1))
			var speed_factor: float = clamp(1.0 - (_elapsed / max(config.typing_timeout, 0.01)), 0.0, 1.0)
			var raw_score: float = (accuracy * 0.7) + (speed_factor * 0.3)
			var grade: int = DuelTypes.Grade.MISS
			if accuracy >= 1.0 and speed_factor >= 0.55:
				grade = DuelTypes.Grade.PERFECT
			elif accuracy >= 0.90:
				grade = DuelTypes.Grade.GOOD
			elif accuracy >= 0.70:
				grade = DuelTypes.Grade.WEAK
			_finish(grade, errors, false, raw_score, {"prompt": _prompt, "typed": _typed, "accuracy": accuracy})

func _count_errors() -> int:
	var errors := 0
	for index in _prompt.length():
		var prompt_char := _prompt[index]
		var typed_char := ""
		if index < _typed.length():
			typed_char = _typed[index]
		if typed_char != prompt_char:
			errors += 1
	return errors
