class_name CombatSnapshot
extends RefCounted

var turn_index := 0
var player: Dictionary = {}
var enemy: Dictionary = {}
var last_visible_minigames: Array[int] = []

func setup(current_turn: int, player_state: FighterState, enemy_state: FighterState, recent_minigames: Array[int]) -> void:
	turn_index = current_turn
	player = player_state.snapshot()
	enemy = enemy_state.snapshot()
	last_visible_minigames = recent_minigames.duplicate()

func to_dictionary() -> Dictionary:
	return {
		"turn_index": turn_index,
		"player": player.duplicate(true),
		"enemy": enemy.duplicate(true),
		"last_visible_minigames": last_visible_minigames.duplicate()
	}
