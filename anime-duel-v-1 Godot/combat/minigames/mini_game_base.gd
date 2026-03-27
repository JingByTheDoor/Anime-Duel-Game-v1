class_name MiniGameBase
extends Control

signal completed(result: MiniGameResult)

var config: MiniGameData
var context: Dictionary = {}
var started_at_msec := 0

func begin(mini_game_data: MiniGameData, run_context: Dictionary) -> void:
	config = mini_game_data
	context = run_context.duplicate(true)
	started_at_msec = Time.get_ticks_msec()
	show()
	grab_focus()
	apply_debug_override()

func apply_debug_override() -> void:
	if DebugConfig.forced_grade >= 0:
		await get_tree().create_timer(0.2).timeout
		_finish(DebugConfig.forced_grade, 0, false, 1.0, {"debug_forced": true})

func _finish(grade: int, errors: int, timed_out: bool, raw_score: float, metadata: Dictionary = {}) -> void:
	var result := MiniGameResult.new()
	result.grade = grade
	result.elapsed = float(Time.get_ticks_msec() - started_at_msec) / 1000.0
	result.errors = errors
	result.timed_out = timed_out
	result.raw_score = raw_score
	result.metadata = metadata
	completed.emit(result)
