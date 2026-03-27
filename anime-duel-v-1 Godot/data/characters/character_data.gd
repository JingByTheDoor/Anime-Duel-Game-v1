class_name CharacterData
extends Resource

@export var id := ""
@export var display_name := ""
@export var tagline := ""
@export var accent_color := Color.WHITE
@export var passive_name := ""
@export var fast_bonus_meter := 0
@export var evade_bonus_guard := 0
@export var fast_self_risk_scale := 1.0
@export var power_precision_miss_self_risk_scale := 1.0
@export var power_perfect_bonus_guard := 0
@export var precision_perfect_bonus_hp := 0
@export var special_name := ""
@export var special_condition_type := ""
@export var special_condition_threshold := 0
@export var special_minigame_type := DuelTypes.MiniGameType.NONE
@export var special_hp_results := {
	0: 0,
	1: 0,
	2: 0,
	3: 0
}
@export var special_guard_results := {
	0: 0,
	1: 0,
	2: 0,
	3: 0
}
@export var special_self_guard_penalty := 0
@export var special_restore_guard_on_perfect := 0
@export var special_vulnerable_hp_bonus := 0
@export var special_vulnerable_guard_bonus := 0
@export var ai_attack_bias := 1.0
@export var ai_defend_bias := 1.0
@export var ai_evade_bias := 1.0
@export var ai_special_bias := 1.0
@export var ai_fast_bias := 1.0
@export var ai_power_bias := 1.0
@export var ai_precision_bias := 1.0

func is_special_available(self_state: FighterState, opponent_state: FighterState, balance_data: BalanceData, debug_force := false) -> bool:
	if debug_force:
		return true
	if not self_state.has_meter_for_special(balance_data):
		return false

	match special_condition_type:
		"hp_lte":
			return self_state.hp <= special_condition_threshold
		"opponent_guard_lte":
			return opponent_state.guard <= special_condition_threshold
		_:
			return false

func get_special_requirement_text() -> String:
	match special_condition_type:
		"hp_lte":
			return "Own HP 50 or less"
		"opponent_guard_lte":
			return "Enemy Guard 35 or less"
		_:
			return "Requirement unknown"
