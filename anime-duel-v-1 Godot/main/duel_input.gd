class_name DuelInput
extends RefCounted

const ACTIONS := {
	"duel_attack": [KEY_1],
	"duel_defend": [KEY_2],
	"duel_evade": [KEY_3],
	"duel_special": [KEY_4],
	"duel_fast": [KEY_Q],
	"duel_power": [KEY_W],
	"duel_precision": [KEY_E],
	"duel_confirm": [KEY_ENTER, KEY_KP_ENTER],
	"duel_back": [KEY_ESCAPE, KEY_BACKSPACE],
	"debug_toggle_overlay": [KEY_F1],
	"debug_force_guard_break": [KEY_F5],
	"debug_force_special": [KEY_F6],
	"debug_cycle_minigame": [KEY_F7],
	"debug_cycle_grade": [KEY_F8]
}

static func ensure_actions() -> void:
	for action_name in ACTIONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		var existing_events := InputMap.action_get_events(action_name)
		if existing_events.size() > 0:
			continue

		for keycode in ACTIONS[action_name]:
			var event := InputEventKey.new()
			event.keycode = keycode
			InputMap.action_add_event(action_name, event)
