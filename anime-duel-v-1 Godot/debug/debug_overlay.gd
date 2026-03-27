class_name DebugOverlay
extends PanelContainer

func _ready() -> void:
	DebugConfig.changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	visible = DebugConfig.overlay_visible
	$VBox/Seed.text = "Seed %d" % DebugConfig.deterministic_seed
	$VBox/GuardBreak.text = "F5 Guard Break: %s" % ("ON" if DebugConfig.force_guard_break else "OFF")
	$VBox/Special.text = "F6 Special Ready: %s" % ("ON" if DebugConfig.force_special_available else "OFF")
	$VBox/MiniGame.text = "F7 Minigame: %s" % _minigame_label()
	$VBox/Grade.text = "F8 Grade: %s" % _grade_label()

func _minigame_label() -> String:
	match DebugConfig.forced_minigame_type:
		DuelTypes.MiniGameType.PATTERN:
			return "Pattern"
		DuelTypes.MiniGameType.TIMING:
			return "Timing"
		DuelTypes.MiniGameType.TYPING:
			return "Typing"
		_:
			return "Auto"

func _grade_label() -> String:
	match DebugConfig.forced_grade:
		DuelTypes.Grade.MISS:
			return "Miss"
		DuelTypes.Grade.WEAK:
			return "Weak"
		DuelTypes.Grade.GOOD:
			return "Good"
		DuelTypes.Grade.PERFECT:
			return "Perfect"
		_:
			return "Auto"
