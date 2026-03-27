class_name FighterState
extends RefCounted

var character: CharacterData
var hp := 100
var guard := 100
var meter := 0
var vulnerable_turns := 0
var guard_reset_pending := false
var broken_last_exchange := false
var exposed := false
var last_action := DuelTypes.Action.NONE
var last_subtype := DuelTypes.AttackSubtype.NONE
var action_history: Array[Dictionary] = []

func setup(character_data: CharacterData, balance_data: BalanceData) -> void:
	character = character_data
	hp = balance_data.start_hp
	guard = balance_data.start_guard
	meter = balance_data.start_meter
	vulnerable_turns = 0
	guard_reset_pending = false
	broken_last_exchange = false
	exposed = false
	last_action = DuelTypes.Action.NONE
	last_subtype = DuelTypes.AttackSubtype.NONE
	action_history.clear()

func push_history(action: int, subtype: int) -> void:
	last_action = action
	last_subtype = subtype
	action_history.push_front({
		"action": action,
		"subtype": subtype
	})
	if action_history.size() > 5:
		action_history.resize(5)

func has_meter_for_special(balance_data: BalanceData) -> bool:
	return meter >= balance_data.special_cost

func is_vulnerable() -> bool:
	return vulnerable_turns > 0

func snapshot() -> Dictionary:
	return {
		"character_id": character.id,
		"hp": hp,
		"guard": guard,
		"meter": meter,
		"vulnerable_turns": vulnerable_turns,
		"guard_reset_pending": guard_reset_pending,
		"broken_last_exchange": broken_last_exchange,
		"exposed": exposed,
		"last_action": last_action,
		"last_subtype": last_subtype,
		"history": action_history.duplicate(true)
	}
