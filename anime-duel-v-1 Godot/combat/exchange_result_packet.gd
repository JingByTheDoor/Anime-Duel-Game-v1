class_name ExchangeResultPacket
extends RefCounted

var turn_index := 0
var p1_action := DuelTypes.Action.NONE
var p1_subtype := DuelTypes.AttackSubtype.NONE
var p2_action := DuelTypes.Action.NONE
var p2_subtype := DuelTypes.AttackSubtype.NONE
var baseline_state := DuelTypes.BaselineState.NONE
var mini_game_type := DuelTypes.MiniGameType.NONE
var mini_game_owner := DuelTypes.FighterSlot.PLAYER
var p1_grade := DuelTypes.Grade.MISS
var p2_grade_abstract := DuelTypes.Grade.MISS
var hp_delta_p1 := 0
var hp_delta_p2 := 0
var guard_delta_p1 := 0
var guard_delta_p2 := 0
var meter_delta_p1 := 0
var meter_delta_p2 := 0
var vulnerability_applied := false
var guard_break := false
var special_fired := false
var camera_tags: PackedStringArray = []
var explanation_key := ""
var finisher := false
var draw := false
var quick_resolve := false
var pre_snapshot: Dictionary = {}
var post_snapshot: Dictionary = {}
var replay_importance_score := 0
var visible_text := ""

func to_dictionary() -> Dictionary:
	return {
		"turn_index": turn_index,
		"p1_action": p1_action,
		"p1_subtype": p1_subtype,
		"p2_action": p2_action,
		"p2_subtype": p2_subtype,
		"baseline_state": baseline_state,
		"mini_game_type": mini_game_type,
		"mini_game_owner": mini_game_owner,
		"p1_grade": p1_grade,
		"p2_grade_abstract": p2_grade_abstract,
		"hp_delta_p1": hp_delta_p1,
		"hp_delta_p2": hp_delta_p2,
		"guard_delta_p1": guard_delta_p1,
		"guard_delta_p2": guard_delta_p2,
		"meter_delta_p1": meter_delta_p1,
		"meter_delta_p2": meter_delta_p2,
		"vulnerability_applied": vulnerability_applied,
		"guard_break": guard_break,
		"special_fired": special_fired,
		"camera_tags": camera_tags,
		"explanation_key": explanation_key,
		"finisher": finisher,
		"draw": draw,
		"quick_resolve": quick_resolve,
		"pre_snapshot": pre_snapshot.duplicate(true),
		"post_snapshot": post_snapshot.duplicate(true),
		"replay_importance_score": replay_importance_score,
		"visible_text": visible_text
	}
