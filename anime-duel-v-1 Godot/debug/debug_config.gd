extends Node

signal changed

var overlay_visible := false
var force_guard_break := false
var force_special_available := false
var forced_minigame_type: int = -1
var forced_grade: int = -1
var deterministic_seed: int = 1337

func reset_session() -> void:
	force_guard_break = false
	force_special_available = false
	forced_minigame_type = -1
	forced_grade = -1
	changed.emit()

func toggle_overlay() -> void:
	overlay_visible = not overlay_visible
	changed.emit()

func toggle_force_guard_break() -> void:
	force_guard_break = not force_guard_break
	changed.emit()

func toggle_force_special_available() -> void:
	force_special_available = not force_special_available
	changed.emit()

func cycle_minigame_type() -> void:
	forced_minigame_type += 1
	if forced_minigame_type > 3:
		forced_minigame_type = -1
	changed.emit()

func cycle_grade() -> void:
	forced_grade += 1
	if forced_grade > 3:
		forced_grade = -1
	changed.emit()
