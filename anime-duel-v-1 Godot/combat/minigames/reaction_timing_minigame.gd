class_name ReactionTimingMiniGame
extends MiniGameBase

var _elapsed := 0.0
var _duration := 1.8
var _resolved := false

func begin(mini_game_data: MiniGameData, run_context: Dictionary) -> void:
	super.begin(mini_game_data, run_context)
	_elapsed = 0.0
	_duration = mini_game_data.timing_duration
	_resolved = false
	if DebugConfig.forced_grade >= 0:
		return
	if run_context.get("heavy", false):
		_duration = mini_game_data.timing_heavy_duration
	$Panel/VBox/Status.text = "Press ENTER when the marker is centered."
	set_process(true)

func _process(delta: float) -> void:
	if not is_interaction_enabled():
		return
	if _resolved:
		return
	_elapsed += delta
	var ratio: float = clamp(_elapsed / _duration, 0.0, 1.0)
	$Panel/VBox/Bar/Marker.position.x = lerp(18.0, 414.0, ratio)
	if _elapsed >= _duration:
		_resolved = true
		set_process(false)
		_finish(DuelTypes.Grade.MISS, 0, true, 0.0)

func _unhandled_input(event: InputEvent) -> void:
	if DebugConfig.forced_grade >= 0 or _resolved or not is_interaction_enabled():
		return
	if event.is_action_pressed("duel_confirm"):
		_resolved = true
		set_process(false)
		var offset: float = abs((_elapsed / _duration) - 0.5)
		var grade: int = DuelTypes.Grade.MISS
		if offset <= config.timing_good_window:
			grade = DuelTypes.Grade.PERFECT
		elif offset <= config.timing_weak_window:
			grade = DuelTypes.Grade.GOOD
		elif offset <= config.timing_miss_window:
			grade = DuelTypes.Grade.WEAK
		_finish(grade, 0, false, 1.0 - (offset * 2.0), {"offset": offset})
