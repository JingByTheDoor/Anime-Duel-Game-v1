class_name MiniGameRouter
extends Node

signal mini_game_completed(result: MiniGameResult)

@export var host_path: NodePath

var _host: Control
var _active_minigame: MiniGameBase
var _queued_fallback_result: MiniGameResult

func _ready() -> void:
	_host = get_node(host_path) as Control

func begin_minigame(mini_game_data: MiniGameData, context: Dictionary, start_interactive: bool = true) -> void:
	clear_active()
	if mini_game_data == null or mini_game_data.scene == null:
		var fallback := MiniGameResult.new()
		fallback.grade = DuelTypes.Grade.WEAK
		if start_interactive:
			call_deferred("_emit_fallback_result", fallback)
		else:
			_queued_fallback_result = fallback
		return

	_active_minigame = mini_game_data.scene.instantiate() as MiniGameBase
	_host.add_child(_active_minigame)
	_active_minigame.completed.connect(_on_minigame_completed)
	_active_minigame.begin(mini_game_data, context)
	_active_minigame.set_interaction_enabled(start_interactive)

func set_active_minigame_interaction(enabled: bool) -> void:
	if _active_minigame:
		_active_minigame.set_interaction_enabled(enabled)
	elif enabled and _queued_fallback_result != null:
		var fallback: MiniGameResult = _queued_fallback_result
		_queued_fallback_result = null
		call_deferred("_emit_fallback_result", fallback)

func clear_active() -> void:
	if _active_minigame:
		_active_minigame.queue_free()
		_active_minigame = null
	_queued_fallback_result = null

func _on_minigame_completed(result: MiniGameResult) -> void:
	mini_game_completed.emit(result)
	clear_active()

func _emit_fallback_result(result: MiniGameResult) -> void:
	mini_game_completed.emit(result)
