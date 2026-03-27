class_name BalanceData
extends Resource

@export var start_hp := 100
@export var start_guard := 100
@export var start_meter := 0
@export var meter_cap := 100
@export var special_cost := 50
@export var planning_time := 7.0
@export var reveal_pause := 0.45
@export var recovery_pause := 0.6
@export var max_exchange_damage := 32
@export var pattern_threshold_scale_attacker := 0.95
@export var pattern_threshold_scale_vulnerable := 1.10
@export var timing_threshold_scale_attacker := 1.05
@export var timing_threshold_scale_vulnerable := 0.90
@export var typing_threshold_scale_attacker := 0.95
@export var typing_threshold_scale_vulnerable := 1.10
@export var clash_guard_chip := 4
@export var invalid_special_guard_penalty := 8
@export var vulnerable_attack_hp_bonus := 0.10
@export var vulnerable_attack_guard_bonus := 0.15
@export var vulnerable_defense_guard_penalty := 4
@export var passive_guard_recovery := 4
@export var success_guard_recovery := 12
@export var defend_reset_guard_recovery := 10
@export var defend_vs_evade_defend_recovery := 8
@export var defend_vs_evade_evade_recovery := 10
@export var meter_gain_hit := 8
@export var meter_gain_be_hit := 5
@export var meter_gain_successful_defend := 6
@export var meter_gain_successful_evade := 8
@export var meter_gain_perfect_bonus := 5
@export var meter_gain_guard_break := 8
@export var meter_gain_quick_neutral := 3
@export var meter_gain_quick_evade := 4
@export var soft_advantage_modifier := 1.10
@export var soft_disadvantage_modifier := 0.90
@export var hard_advantage_modifier := 1.25
@export var hard_disadvantage_modifier := 0.75
@export var guarded_defender_modifier := 0.90
@export var guarded_attacker_modifier := 1.10
@export var guarded_hp_scale := 0.35
@export var guarded_hp_scale_power := 0.55
@export var guarded_hp_scale_precision := 0.20
@export var guarded_hp_scale_precision_good := 0.45
@export var soft_whiff_hp_scale := 0.75
@export var soft_whiff_guard_scale := 0.75
@export var evade_punish_hp := {
	1: 8,
	2: 14,
	3: 20
}
@export var evade_punish_guard := {
	1: 8,
	2: 12,
	3: 16
}
@export var base_hp_damage := {
	1: {1: 6, 2: 10, 3: 14},
	2: {1: 10, 2: 16, 3: 24},
	3: {1: 8, 2: 14, 3: 28}
}
@export var base_guard_damage := {
	1: {1: 8, 2: 12, 3: 16},
	2: {1: 14, 2: 22, 3: 30},
	3: {1: 6, 2: 12, 3: 18}
}
@export var preview_tags := {
	"attack_fast": PackedStringArray(["Strong", "Good vs Power"]),
	"attack_power": PackedStringArray(["Break Guard", "Risky"]),
	"attack_precision": PackedStringArray(["Risky", "Finisher"]),
	"defend": PackedStringArray(["Strong", "Comeback"]),
	"evade": PackedStringArray(["Risky", "Unsafe if Missed"]),
	"special_martial": PackedStringArray(["Comeback", "Strong"]),
	"special_samurai": PackedStringArray(["Finisher", "Good vs Low Guard"])
}
@export var explanation_keys := {
	"fast_interrupts_power": "Fast Good interrupted Power.",
	"power_cracked_guard": "Power pressure cracked Guard.",
	"precision_salvaged": "Precision execution salvaged the read.",
	"evade_punished": "Evade punished a heavy read.",
	"guard_stabilized": "Defend stabilized the exchange.",
	"quick_reset": "Both fighters reset their rhythm.",
	"special_declared": "Special intent broke the tempo.",
	"miss_lost_exchange": "A miss gave up the exchange.",
	"clash_neutralized": "Matching intent collided head-on.",
	"guard_break": "Guard Break opened Vulnerable.",
	"final_blow": "The duel ended on a decisive beat."
}

func get_base_hp(subtype: int, grade: int) -> int:
	if grade <= DuelTypes.Grade.MISS:
		return 0
	return int(base_hp_damage.get(subtype, {}).get(grade, 0))

func get_base_guard(subtype: int, grade: int) -> int:
	if grade <= DuelTypes.Grade.MISS:
		return 0
	return int(base_guard_damage.get(subtype, {}).get(grade, 0))

func get_evade_hp(grade: int) -> int:
	return int(evade_punish_hp.get(grade, 0))

func get_evade_guard(grade: int) -> int:
	return int(evade_punish_guard.get(grade, 0))

func get_preview_tags(action: int, subtype: int, character_id: String) -> PackedStringArray:
	if action == DuelTypes.Action.ATTACK:
		match subtype:
			DuelTypes.AttackSubtype.FAST:
				return preview_tags.get("attack_fast", PackedStringArray())
			DuelTypes.AttackSubtype.POWER:
				return preview_tags.get("attack_power", PackedStringArray())
			DuelTypes.AttackSubtype.PRECISION:
				return preview_tags.get("attack_precision", PackedStringArray())
	elif action == DuelTypes.Action.DEFEND:
		return preview_tags.get("defend", PackedStringArray())
	elif action == DuelTypes.Action.EVADE:
		return preview_tags.get("evade", PackedStringArray())
	elif action == DuelTypes.Action.SPECIAL:
		if character_id == "martial_artist":
			return preview_tags.get("special_martial", PackedStringArray())
		return preview_tags.get("special_samurai", PackedStringArray())
	return PackedStringArray()

func get_explanation(key: String) -> String:
	return explanation_keys.get(key, "")
