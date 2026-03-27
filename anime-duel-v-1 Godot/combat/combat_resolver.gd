class_name CombatResolver
extends RefCounted

func build_exchange_context(player_choice: Dictionary, enemy_choice: Dictionary, player_state: FighterState, enemy_state: FighterState, balance_data: BalanceData, recent_minigames: Array[int]) -> Dictionary:
	var resolved_player: Dictionary = _effective_choice(player_choice, player_state, enemy_state, balance_data)
	var resolved_enemy: Dictionary = _effective_choice(enemy_choice, enemy_state, player_state, balance_data)
	var context: Dictionary = {
		"player_choice": resolved_player,
		"enemy_choice": resolved_enemy,
		"baseline_state": DuelTypes.BaselineState.NONE,
		"visible_mini_game_type": DuelTypes.MiniGameType.NONE,
		"enemy_mini_game_type": DuelTypes.MiniGameType.NONE,
		"favored_slot": -1,
		"attacker_slot": -1,
		"evader_slot": -1,
		"soft_whiff": false,
		"quick_meter": 0,
		"recent_minigames": recent_minigames.duplicate()
	}

	context.visible_mini_game_type = _enforce_repetition_rule(_choice_to_minigame(resolved_player, player_state.character), recent_minigames, resolved_player)
	context.enemy_mini_game_type = _choice_to_minigame(resolved_enemy, enemy_state.character)
	if DebugConfig.forced_minigame_type >= DuelTypes.MiniGameType.PATTERN:
		context.visible_mini_game_type = DebugConfig.forced_minigame_type

	var player_action: int = int(resolved_player.action)
	var enemy_action: int = int(resolved_enemy.action)

	if _is_quick_pair(player_action, enemy_action, resolved_player, resolved_enemy):
		context.baseline_state = DuelTypes.BaselineState.QUICK_RESOLVE
		context.quick_meter = balance_data.meter_gain_quick_evade if (player_action == DuelTypes.Action.EVADE or enemy_action == DuelTypes.Action.EVADE) else balance_data.meter_gain_quick_neutral
		return context

	if player_action == DuelTypes.Action.SPECIAL or enemy_action == DuelTypes.Action.SPECIAL:
		context.baseline_state = DuelTypes.BaselineState.SPECIAL_EVENT
		return context

	if player_action == DuelTypes.Action.ATTACK and enemy_action == DuelTypes.Action.ATTACK:
		if resolved_player.subtype == resolved_enemy.subtype:
			context.baseline_state = DuelTypes.BaselineState.CLASH
			return context
		context.baseline_state = DuelTypes.BaselineState.STRIKE
		context.favored_slot = _favored_slot_for_subtypes(resolved_player.subtype, resolved_enemy.subtype)
		return context

	if player_action == DuelTypes.Action.ATTACK and enemy_action == DuelTypes.Action.DEFEND:
		context.baseline_state = DuelTypes.BaselineState.GUARDED_STRIKE
		context.attacker_slot = DuelTypes.FighterSlot.PLAYER
		context.favored_slot = _guarded_favored_slot(resolved_player.subtype, DuelTypes.FighterSlot.PLAYER)
		return context

	if player_action == DuelTypes.Action.DEFEND and enemy_action == DuelTypes.Action.ATTACK:
		context.baseline_state = DuelTypes.BaselineState.GUARDED_STRIKE
		context.attacker_slot = DuelTypes.FighterSlot.ENEMY
		context.favored_slot = _guarded_favored_slot(resolved_enemy.subtype, DuelTypes.FighterSlot.ENEMY)
		return context

	if player_action == DuelTypes.Action.ATTACK and enemy_action == DuelTypes.Action.EVADE:
		context.evader_slot = DuelTypes.FighterSlot.ENEMY
		context.attacker_slot = DuelTypes.FighterSlot.PLAYER
		if resolved_player.subtype == DuelTypes.AttackSubtype.POWER:
			context.baseline_state = DuelTypes.BaselineState.WHIFF_PUNISH
			context.favored_slot = DuelTypes.FighterSlot.ENEMY
		elif resolved_player.subtype == DuelTypes.AttackSubtype.PRECISION:
			context.baseline_state = DuelTypes.BaselineState.STRIKE
			context.favored_slot = DuelTypes.FighterSlot.ENEMY
			context.soft_whiff = true
		else:
			context.baseline_state = DuelTypes.BaselineState.STRIKE
			context.favored_slot = DuelTypes.FighterSlot.PLAYER
			context.soft_whiff = true
		return context

	if player_action == DuelTypes.Action.EVADE and enemy_action == DuelTypes.Action.ATTACK:
		context.evader_slot = DuelTypes.FighterSlot.PLAYER
		context.attacker_slot = DuelTypes.FighterSlot.ENEMY
		if resolved_enemy.subtype == DuelTypes.AttackSubtype.POWER:
			context.baseline_state = DuelTypes.BaselineState.WHIFF_PUNISH
			context.favored_slot = DuelTypes.FighterSlot.PLAYER
		elif resolved_enemy.subtype == DuelTypes.AttackSubtype.PRECISION:
			context.baseline_state = DuelTypes.BaselineState.STRIKE
			context.favored_slot = DuelTypes.FighterSlot.PLAYER
			context.soft_whiff = true
		else:
			context.baseline_state = DuelTypes.BaselineState.STRIKE
			context.favored_slot = DuelTypes.FighterSlot.ENEMY
			context.soft_whiff = true
		return context

	context.baseline_state = DuelTypes.BaselineState.NEUTRAL_RESET
	return context

func resolve_exchange(context: Dictionary, player_grade: int, enemy_grade: int, player_state: FighterState, enemy_state: FighterState, balance_data: BalanceData) -> ExchangeResultPacket:
	var packet: ExchangeResultPacket = ExchangeResultPacket.new()
	packet.turn_index = int(context.get("turn_index", 0))
	packet.p1_action = context.player_choice.action
	packet.p1_subtype = context.player_choice.subtype
	packet.p2_action = context.enemy_choice.action
	packet.p2_subtype = context.enemy_choice.subtype
	packet.baseline_state = context.baseline_state
	packet.mini_game_type = context.visible_mini_game_type
	packet.pre_snapshot = {
		"player": player_state.snapshot(),
		"enemy": enemy_state.snapshot()
	}
	packet.p1_grade = player_grade
	packet.p2_grade_abstract = enemy_grade
	packet.quick_resolve = context.baseline_state == DuelTypes.BaselineState.QUICK_RESOLVE

	if context.player_choice.valid_special:
		packet.special_fired = true
		packet.meter_delta_p1 -= balance_data.special_cost
	if context.enemy_choice.valid_special:
		packet.special_fired = true
		packet.meter_delta_p2 -= balance_data.special_cost

	match int(context.baseline_state):
		DuelTypes.BaselineState.QUICK_RESOLVE:
			_resolve_quick(context, packet, player_state, enemy_state, balance_data)
		DuelTypes.BaselineState.GUARDED_STRIKE:
			_resolve_guarded(context, packet, player_grade, enemy_grade, player_state, enemy_state, balance_data)
		DuelTypes.BaselineState.WHIFF_PUNISH:
			_resolve_whiff_punish(context, packet, player_grade, enemy_grade, player_state, enemy_state, balance_data, true)
		DuelTypes.BaselineState.SPECIAL_EVENT:
			_resolve_special(context, packet, player_grade, enemy_grade, player_state, enemy_state, balance_data)
		DuelTypes.BaselineState.CLASH:
			_resolve_clash(context, packet, player_grade, enemy_grade, player_state, enemy_state, balance_data)
		DuelTypes.BaselineState.STRIKE:
			if context.soft_whiff:
				_resolve_whiff_punish(context, packet, player_grade, enemy_grade, player_state, enemy_state, balance_data, false)
			else:
				_resolve_strike(context, packet, player_grade, enemy_grade, player_state, enemy_state, balance_data)
		_:
			packet.explanation_key = "quick_reset"

	_apply_hit_meter(packet, player_grade, enemy_grade, context, balance_data)
	_apply_recovery(packet, context, player_state, enemy_state, balance_data)
	_apply_vulnerable_state(packet, player_state, enemy_state, balance_data)
	_apply_debug_break(packet, context, player_state, enemy_state)
	_finalize_flags(packet, player_state, enemy_state, balance_data)
	return packet

func _effective_choice(choice: Dictionary, self_state: FighterState, opponent_state: FighterState, balance_data: BalanceData) -> Dictionary:
	var action: int = int(choice.get("action", DuelTypes.Action.DEFEND))
	var subtype: int = int(choice.get("subtype", DuelTypes.AttackSubtype.NONE))
	var resolved: Dictionary = choice.duplicate(true)
	resolved.action = action
	resolved.subtype = subtype
	resolved.valid_special = false
	resolved.special_invalid = false
	if action == DuelTypes.Action.SPECIAL:
		if self_state.character.is_special_available(self_state, opponent_state, balance_data, DebugConfig.force_special_available):
			resolved.valid_special = true
		else:
			resolved.action = DuelTypes.Action.DEFEND
			resolved.subtype = DuelTypes.AttackSubtype.NONE
			resolved.special_invalid = true
	return resolved

func _is_quick_pair(player_action: int, enemy_action: int, player_choice: Dictionary, enemy_choice: Dictionary) -> bool:
	if player_choice.special_invalid or enemy_choice.special_invalid:
		return player_action != DuelTypes.Action.ATTACK and enemy_action != DuelTypes.Action.ATTACK
	if player_action == DuelTypes.Action.DEFEND and enemy_action == DuelTypes.Action.DEFEND:
		return true
	if player_action == DuelTypes.Action.EVADE and enemy_action == DuelTypes.Action.EVADE:
		return true
	if player_action == DuelTypes.Action.DEFEND and enemy_action == DuelTypes.Action.EVADE:
		return true
	if player_action == DuelTypes.Action.EVADE and enemy_action == DuelTypes.Action.DEFEND:
		return true
	return false

func _choice_to_minigame(choice: Dictionary, character_data: CharacterData) -> int:
	match int(choice.action):
		DuelTypes.Action.ATTACK:
			match int(choice.subtype):
				DuelTypes.AttackSubtype.FAST:
					return DuelTypes.MiniGameType.PATTERN
				DuelTypes.AttackSubtype.POWER:
					return DuelTypes.MiniGameType.TIMING
				DuelTypes.AttackSubtype.PRECISION:
					return DuelTypes.MiniGameType.TYPING
		DuelTypes.Action.DEFEND:
			return DuelTypes.MiniGameType.TIMING
		DuelTypes.Action.EVADE:
			return DuelTypes.MiniGameType.PATTERN
		DuelTypes.Action.SPECIAL:
			return character_data.special_minigame_type
	return DuelTypes.MiniGameType.NONE

func _enforce_repetition_rule(next_type: int, recent_minigames: Array[int], choice: Dictionary) -> int:
	if int(choice.action) == DuelTypes.Action.SPECIAL or next_type == DuelTypes.MiniGameType.NONE:
		return next_type
	if recent_minigames.size() >= 2 and recent_minigames[0] == next_type and recent_minigames[1] == next_type:
		match next_type:
			DuelTypes.MiniGameType.PATTERN:
				return DuelTypes.MiniGameType.TIMING
			DuelTypes.MiniGameType.TIMING:
				return DuelTypes.MiniGameType.PATTERN
			DuelTypes.MiniGameType.TYPING:
				return DuelTypes.MiniGameType.PATTERN
	return next_type

func _favored_slot_for_subtypes(player_subtype: int, enemy_subtype: int) -> int:
	if player_subtype == DuelTypes.AttackSubtype.FAST and enemy_subtype in [DuelTypes.AttackSubtype.POWER, DuelTypes.AttackSubtype.PRECISION]:
		return DuelTypes.FighterSlot.PLAYER
	if enemy_subtype == DuelTypes.AttackSubtype.FAST and player_subtype in [DuelTypes.AttackSubtype.POWER, DuelTypes.AttackSubtype.PRECISION]:
		return DuelTypes.FighterSlot.ENEMY
	if player_subtype == DuelTypes.AttackSubtype.PRECISION and enemy_subtype == DuelTypes.AttackSubtype.POWER:
		return DuelTypes.FighterSlot.PLAYER
	if enemy_subtype == DuelTypes.AttackSubtype.PRECISION and player_subtype == DuelTypes.AttackSubtype.POWER:
		return DuelTypes.FighterSlot.ENEMY
	return -1

func _guarded_favored_slot(attacker_subtype: int, attacker_slot: int) -> int:
	if attacker_subtype == DuelTypes.AttackSubtype.POWER:
		return attacker_slot
	if attacker_subtype == DuelTypes.AttackSubtype.PRECISION:
		return DuelTypes.FighterSlot.ENEMY if attacker_slot == DuelTypes.FighterSlot.PLAYER else DuelTypes.FighterSlot.PLAYER
	return attacker_slot

func _resolve_quick(context: Dictionary, packet: ExchangeResultPacket, player_state: FighterState, enemy_state: FighterState, balance_data: BalanceData) -> void:
	packet.explanation_key = "quick_reset"
	packet.quick_resolve = true
	packet.meter_delta_p1 += context.quick_meter
	packet.meter_delta_p2 += context.quick_meter
	if context.player_choice.action == DuelTypes.Action.DEFEND and context.enemy_choice.action == DuelTypes.Action.DEFEND:
		packet.guard_delta_p1 += balance_data.defend_reset_guard_recovery
		packet.guard_delta_p2 += balance_data.defend_reset_guard_recovery
	elif context.player_choice.action == DuelTypes.Action.DEFEND and context.enemy_choice.action == DuelTypes.Action.EVADE:
		packet.guard_delta_p1 += balance_data.defend_vs_evade_defend_recovery
		packet.guard_delta_p2 += balance_data.defend_vs_evade_evade_recovery
	elif context.player_choice.action == DuelTypes.Action.EVADE and context.enemy_choice.action == DuelTypes.Action.DEFEND:
		packet.guard_delta_p1 += balance_data.defend_vs_evade_evade_recovery
		packet.guard_delta_p2 += balance_data.defend_vs_evade_defend_recovery
	else:
		packet.guard_delta_p1 += balance_data.passive_guard_recovery
		packet.guard_delta_p2 += balance_data.passive_guard_recovery

func _resolve_guarded(context: Dictionary, packet: ExchangeResultPacket, player_grade: int, enemy_grade: int, player_state: FighterState, enemy_state: FighterState, balance_data: BalanceData) -> void:
	var attacker_slot: int = int(context.attacker_slot)
	var defender_slot: int = DuelTypes.FighterSlot.ENEMY if attacker_slot == DuelTypes.FighterSlot.PLAYER else DuelTypes.FighterSlot.PLAYER
	var attacker_choice: Dictionary = context.player_choice if attacker_slot == DuelTypes.FighterSlot.PLAYER else context.enemy_choice
	var attacker_subtype: int = int(attacker_choice.get("subtype", DuelTypes.AttackSubtype.NONE))
	var attacker_grade: int = player_grade if attacker_slot == DuelTypes.FighterSlot.PLAYER else enemy_grade
	var defender_grade: int = enemy_grade if attacker_slot == DuelTypes.FighterSlot.PLAYER else player_grade
	var attacker_state: FighterState = player_state if attacker_slot == DuelTypes.FighterSlot.PLAYER else enemy_state
	var defender_state: FighterState = enemy_state if attacker_slot == DuelTypes.FighterSlot.PLAYER else player_state
	if attacker_grade == DuelTypes.Grade.MISS:
		_apply_delta(packet, attacker_slot, 0, -_attack_self_risk(attacker_subtype, attacker_state.character, balance_data), 0)
		packet.explanation_key = "guard_stabilized"
		return

	var base_hp: int = balance_data.get_base_hp(attacker_subtype, attacker_grade)
	var base_guard: int = balance_data.get_base_guard(attacker_subtype, attacker_grade)
	var hp_scale: float = balance_data.guarded_hp_scale
	if attacker_subtype == DuelTypes.AttackSubtype.POWER:
		hp_scale = balance_data.guarded_hp_scale_power
	elif attacker_subtype == DuelTypes.AttackSubtype.PRECISION:
		hp_scale = balance_data.guarded_hp_scale_precision_good if attacker_grade >= DuelTypes.Grade.GOOD else balance_data.guarded_hp_scale_precision

	var damage_modifier: float = balance_data.guarded_attacker_modifier if context.favored_slot == attacker_slot else balance_data.guarded_defender_modifier
	if defender_grade == DuelTypes.Grade.GOOD:
		damage_modifier *= 0.8
	elif defender_grade == DuelTypes.Grade.PERFECT:
		damage_modifier *= 0.6
		hp_scale *= 0.5

	var hp_damage: int = int(round(base_hp * hp_scale))
	var guard_damage: int = int(round(base_guard * damage_modifier))
	_apply_attack_damage(packet, attacker_slot, defender_slot, hp_damage, guard_damage, 1.0, attacker_state, defender_state, false, false, balance_data)
	packet.explanation_key = "power_cracked_guard" if attacker_subtype == DuelTypes.AttackSubtype.POWER else "guard_stabilized"

func _resolve_whiff_punish(context: Dictionary, packet: ExchangeResultPacket, player_grade: int, enemy_grade: int, player_state: FighterState, enemy_state: FighterState, balance_data: BalanceData, hard_punish: bool) -> void:
	var evader_slot: int = int(context.evader_slot)
	var attacker_slot: int = int(context.attacker_slot)
	var evader_grade: int = player_grade if evader_slot == DuelTypes.FighterSlot.PLAYER else enemy_grade
	var attacker_grade: int = enemy_grade if evader_slot == DuelTypes.FighterSlot.PLAYER else player_grade
	var evader_state: FighterState = player_state if evader_slot == DuelTypes.FighterSlot.PLAYER else enemy_state
	var attacker_state: FighterState = enemy_state if evader_slot == DuelTypes.FighterSlot.PLAYER else player_state
	var attacker_choice: Dictionary = context.enemy_choice if evader_slot == DuelTypes.FighterSlot.PLAYER else context.player_choice
	var attacker_subtype: int = int(attacker_choice.get("subtype", DuelTypes.AttackSubtype.NONE))
	var punish_ready: bool = evader_grade >= DuelTypes.Grade.WEAK and hard_punish
	if not hard_punish:
		punish_ready = evader_grade >= DuelTypes.Grade.GOOD or attacker_grade == DuelTypes.Grade.MISS

	if punish_ready:
		var hp_damage: int = balance_data.get_evade_hp(evader_grade)
		var guard_damage: int = balance_data.get_evade_guard(evader_grade)
		var modifier: float = balance_data.hard_advantage_modifier if hard_punish else balance_data.soft_whiff_hp_scale
		_apply_attack_damage(packet, evader_slot, attacker_slot, hp_damage, guard_damage, modifier, evader_state, attacker_state, true, false, balance_data)
		packet.explanation_key = "evade_punished"
		return

	if attacker_grade == DuelTypes.Grade.MISS:
		_apply_delta(packet, attacker_slot, 0, -_attack_self_risk(attacker_subtype, attacker_state.character, balance_data), 0)
		packet.explanation_key = "miss_lost_exchange"
		return

	var hp_damage_attack: int = balance_data.get_base_hp(attacker_subtype, attacker_grade)
	var guard_damage_attack: int = balance_data.get_base_guard(attacker_subtype, attacker_grade)
	var modifier_attack: float = balance_data.soft_advantage_modifier if attacker_slot == context.favored_slot else balance_data.soft_disadvantage_modifier
	_apply_attack_damage(packet, attacker_slot, evader_slot, hp_damage_attack, guard_damage_attack, modifier_attack, attacker_state, evader_state, false, false, balance_data)
	packet.explanation_key = "miss_lost_exchange"

func _resolve_special(context: Dictionary, packet: ExchangeResultPacket, player_grade: int, enemy_grade: int, player_state: FighterState, enemy_state: FighterState, balance_data: BalanceData) -> void:
	var player_special: bool = bool(context.player_choice.valid_special)
	var enemy_special: bool = bool(context.enemy_choice.valid_special)
	if player_special and enemy_special:
		var player_score: int = _grade_points(player_grade) + 1
		var enemy_score: int = _grade_points(enemy_grade) + 1
		if player_score == enemy_score:
			packet.guard_delta_p1 -= 8
			packet.guard_delta_p2 -= 8
			packet.explanation_key = "special_declared"
			return
		var winner_slot: int = DuelTypes.FighterSlot.PLAYER if player_score > enemy_score else DuelTypes.FighterSlot.ENEMY
		var loser_slot: int = DuelTypes.FighterSlot.ENEMY if winner_slot == DuelTypes.FighterSlot.PLAYER else DuelTypes.FighterSlot.PLAYER
		var winner_state: FighterState = player_state if winner_slot == DuelTypes.FighterSlot.PLAYER else enemy_state
		var loser_state: FighterState = enemy_state if winner_slot == DuelTypes.FighterSlot.PLAYER else player_state
		var grade: int = player_grade if winner_slot == DuelTypes.FighterSlot.PLAYER else enemy_grade
		_apply_special_damage(packet, winner_slot, loser_slot, grade, winner_state, loser_state, balance_data)
		packet.explanation_key = "special_declared"
		return

	var special_slot: int = DuelTypes.FighterSlot.PLAYER if player_special else DuelTypes.FighterSlot.ENEMY
	var defender_slot: int = DuelTypes.FighterSlot.ENEMY if special_slot == DuelTypes.FighterSlot.PLAYER else DuelTypes.FighterSlot.PLAYER
	var special_grade: int = player_grade if special_slot == DuelTypes.FighterSlot.PLAYER else enemy_grade
	var defender_grade: int = enemy_grade if special_slot == DuelTypes.FighterSlot.PLAYER else player_grade
	var special_state: FighterState = player_state if special_slot == DuelTypes.FighterSlot.PLAYER else enemy_state
	var defender_state: FighterState = enemy_state if special_slot == DuelTypes.FighterSlot.PLAYER else player_state
	var defender_choice: Dictionary = context.enemy_choice if special_slot == DuelTypes.FighterSlot.PLAYER else context.player_choice
	var defender_action: int = int(defender_choice.get("action", DuelTypes.Action.NONE))
	var defender_subtype: int = int(defender_choice.get("subtype", DuelTypes.AttackSubtype.NONE))

	if special_grade == DuelTypes.Grade.MISS:
		_apply_delta(packet, special_slot, 0, special_state.character.special_self_guard_penalty, 0)
		packet.explanation_key = "miss_lost_exchange"
		return

	var special_score: int = _grade_points(special_grade) + 1
	var defend_score: int = _grade_points(defender_grade)
	if defender_action == DuelTypes.Action.EVADE and defend_score >= special_score:
		var hp_damage: int = balance_data.get_evade_hp(max(defender_grade, DuelTypes.Grade.WEAK))
		var guard_damage: int = balance_data.get_evade_guard(max(defender_grade, DuelTypes.Grade.WEAK))
		_apply_attack_damage(packet, defender_slot, special_slot, hp_damage, guard_damage, 1.0, defender_state, special_state, true, false, balance_data)
		packet.explanation_key = "evade_punished"
		return
	if defender_action == DuelTypes.Action.ATTACK and defend_score > special_score:
		_apply_attack_damage(packet, defender_slot, special_slot, balance_data.get_base_hp(defender_subtype, defender_grade), balance_data.get_base_guard(defender_subtype, defender_grade), 1.05, defender_state, special_state, false, false, balance_data)
		packet.explanation_key = "special_declared"
		return
	if defender_action == DuelTypes.Action.DEFEND and defend_score >= special_score:
		var reduced_hp: int = int(round(float(special_state.character.special_hp_results.get(special_grade, 0)) * 0.35))
		var reduced_guard: int = int(round(float(special_state.character.special_guard_results.get(special_grade, 0)) * 0.65))
		_apply_attack_damage(packet, special_slot, defender_slot, max(0, reduced_hp), max(0, reduced_guard), 1.0, special_state, defender_state, false, true, balance_data)
		packet.explanation_key = "guard_stabilized"
		return

	_apply_special_damage(packet, special_slot, defender_slot, special_grade, special_state, defender_state, balance_data)
	packet.explanation_key = "special_declared"

func _resolve_clash(context: Dictionary, packet: ExchangeResultPacket, player_grade: int, enemy_grade: int, player_state: FighterState, enemy_state: FighterState, balance_data: BalanceData) -> void:
	if player_grade == enemy_grade:
		if player_grade == DuelTypes.Grade.MISS:
			packet.guard_delta_p1 -= 2
			packet.guard_delta_p2 -= 2
			packet.explanation_key = "miss_lost_exchange"
		else:
			packet.guard_delta_p1 -= balance_data.clash_guard_chip
			packet.guard_delta_p2 -= balance_data.clash_guard_chip
			packet.explanation_key = "clash_neutralized"
		return

	var winner_slot: int = DuelTypes.FighterSlot.PLAYER if player_grade > enemy_grade else DuelTypes.FighterSlot.ENEMY
	var loser_slot: int = DuelTypes.FighterSlot.ENEMY if winner_slot == DuelTypes.FighterSlot.PLAYER else DuelTypes.FighterSlot.PLAYER
	var winner_choice: Dictionary = context.player_choice if winner_slot == DuelTypes.FighterSlot.PLAYER else context.enemy_choice
	var winner_subtype: int = int(winner_choice.get("subtype", DuelTypes.AttackSubtype.NONE))
	var grade: int = player_grade if winner_slot == DuelTypes.FighterSlot.PLAYER else enemy_grade
	var attacker_state: FighterState = player_state if winner_slot == DuelTypes.FighterSlot.PLAYER else enemy_state
	var defender_state: FighterState = enemy_state if winner_slot == DuelTypes.FighterSlot.PLAYER else player_state
	_apply_attack_damage(packet, winner_slot, loser_slot, balance_data.get_base_hp(winner_subtype, grade), balance_data.get_base_guard(winner_subtype, grade), 0.9, attacker_state, defender_state, false, false, balance_data)
	packet.explanation_key = "clash_neutralized"

func _resolve_strike(context: Dictionary, packet: ExchangeResultPacket, player_grade: int, enemy_grade: int, player_state: FighterState, enemy_state: FighterState, balance_data: BalanceData) -> void:
	var favored_slot: int = int(context.favored_slot)
	var player_score: int = _grade_points(player_grade) + (1 if favored_slot == DuelTypes.FighterSlot.PLAYER else 0)
	var enemy_score: int = _grade_points(enemy_grade) + (1 if favored_slot == DuelTypes.FighterSlot.ENEMY else 0)
	if player_grade == DuelTypes.Grade.MISS and enemy_grade == DuelTypes.Grade.MISS:
		packet.guard_delta_p1 -= _attack_self_risk(int(context.player_choice.subtype), player_state.character, balance_data)
		packet.guard_delta_p2 -= _attack_self_risk(int(context.enemy_choice.subtype), enemy_state.character, balance_data)
		packet.explanation_key = "miss_lost_exchange"
		return

	if player_score == enemy_score and player_grade == enemy_grade:
		packet.guard_delta_p1 -= balance_data.clash_guard_chip
		packet.guard_delta_p2 -= balance_data.clash_guard_chip
		packet.explanation_key = "clash_neutralized"
		return

	var winner_slot: int = DuelTypes.FighterSlot.PLAYER if player_score > enemy_score else DuelTypes.FighterSlot.ENEMY
	var loser_slot: int = DuelTypes.FighterSlot.ENEMY if winner_slot == DuelTypes.FighterSlot.PLAYER else DuelTypes.FighterSlot.PLAYER
	var winner_choice: Dictionary = context.player_choice if winner_slot == DuelTypes.FighterSlot.PLAYER else context.enemy_choice
	var winner_subtype: int = int(winner_choice.get("subtype", DuelTypes.AttackSubtype.NONE))
	var winner_grade: int = player_grade if winner_slot == DuelTypes.FighterSlot.PLAYER else enemy_grade
	var attacker_state: FighterState = player_state if winner_slot == DuelTypes.FighterSlot.PLAYER else enemy_state
	var defender_state: FighterState = enemy_state if winner_slot == DuelTypes.FighterSlot.PLAYER else player_state
	var hp_damage: int = balance_data.get_base_hp(winner_subtype, winner_grade)
	var guard_damage: int = balance_data.get_base_guard(winner_subtype, winner_grade)
	var modifier: float = 1.0
	if favored_slot == winner_slot:
		modifier = balance_data.soft_advantage_modifier
	_apply_attack_damage(packet, winner_slot, loser_slot, hp_damage, guard_damage, modifier, attacker_state, defender_state, false, false, balance_data)
	packet.explanation_key = "fast_interrupts_power" if winner_subtype == DuelTypes.AttackSubtype.FAST else "precision_salvaged"

func _apply_hit_meter(packet: ExchangeResultPacket, player_grade: int, enemy_grade: int, context: Dictionary, balance_data: BalanceData) -> void:
	if packet.hp_delta_p2 < 0 or packet.guard_delta_p2 < 0:
		packet.meter_delta_p1 += balance_data.meter_gain_hit
		packet.meter_delta_p2 += balance_data.meter_gain_be_hit
	if packet.hp_delta_p1 < 0 or packet.guard_delta_p1 < 0:
		packet.meter_delta_p2 += balance_data.meter_gain_hit
		packet.meter_delta_p1 += balance_data.meter_gain_be_hit
	if player_grade == DuelTypes.Grade.PERFECT:
		packet.meter_delta_p1 += balance_data.meter_gain_perfect_bonus
	if enemy_grade == DuelTypes.Grade.PERFECT:
		packet.meter_delta_p2 += balance_data.meter_gain_perfect_bonus
	if context.player_choice.action == DuelTypes.Action.DEFEND and packet.hp_delta_p1 == 0 and player_grade >= DuelTypes.Grade.WEAK:
		packet.meter_delta_p1 += balance_data.meter_gain_successful_defend
	if context.enemy_choice.action == DuelTypes.Action.DEFEND and packet.hp_delta_p2 == 0 and enemy_grade >= DuelTypes.Grade.WEAK:
		packet.meter_delta_p2 += balance_data.meter_gain_successful_defend
	if context.player_choice.action == DuelTypes.Action.EVADE and packet.hp_delta_p1 == 0 and player_grade >= DuelTypes.Grade.WEAK:
		packet.meter_delta_p1 += balance_data.meter_gain_successful_evade
	if context.enemy_choice.action == DuelTypes.Action.EVADE and packet.hp_delta_p2 == 0 and enemy_grade >= DuelTypes.Grade.WEAK:
		packet.meter_delta_p2 += balance_data.meter_gain_successful_evade

func _apply_recovery(packet: ExchangeResultPacket, context: Dictionary, player_state: FighterState, enemy_state: FighterState, balance_data: BalanceData) -> void:
	if player_state.is_vulnerable():
		packet.guard_delta_p1 = min(packet.guard_delta_p1, 0)
	if enemy_state.is_vulnerable():
		packet.guard_delta_p2 = min(packet.guard_delta_p2, 0)
	if context.baseline_state == DuelTypes.BaselineState.QUICK_RESOLVE:
		return
	var player_success_defense: bool = context.player_choice.action in [DuelTypes.Action.DEFEND, DuelTypes.Action.EVADE] and packet.hp_delta_p1 == 0 and packet.guard_delta_p1 >= 0
	var enemy_success_defense: bool = context.enemy_choice.action in [DuelTypes.Action.DEFEND, DuelTypes.Action.EVADE] and packet.hp_delta_p2 == 0 and packet.guard_delta_p2 >= 0
	if context.player_choice.action == DuelTypes.Action.DEFEND and player_success_defense and not player_state.is_vulnerable():
		packet.guard_delta_p1 += balance_data.success_guard_recovery
	elif context.player_choice.action == DuelTypes.Action.EVADE and player_success_defense and not player_state.is_vulnerable():
		packet.guard_delta_p1 += balance_data.success_guard_recovery
	elif packet.hp_delta_p1 == 0 and packet.guard_delta_p1 >= 0 and not player_state.is_vulnerable():
		packet.guard_delta_p1 += balance_data.passive_guard_recovery
	if context.enemy_choice.action == DuelTypes.Action.DEFEND and enemy_success_defense and not enemy_state.is_vulnerable():
		packet.guard_delta_p2 += balance_data.success_guard_recovery
	elif context.enemy_choice.action == DuelTypes.Action.EVADE and enemy_success_defense and not enemy_state.is_vulnerable():
		packet.guard_delta_p2 += balance_data.success_guard_recovery
	elif packet.hp_delta_p2 == 0 and packet.guard_delta_p2 >= 0 and not enemy_state.is_vulnerable():
		packet.guard_delta_p2 += balance_data.passive_guard_recovery

func _apply_vulnerable_state(packet: ExchangeResultPacket, player_state: FighterState, enemy_state: FighterState, balance_data: BalanceData) -> void:
	if player_state.is_vulnerable():
		var projected_guard: int = player_state.guard + packet.guard_delta_p1
		packet.guard_delta_p1 += 35 - projected_guard
	if enemy_state.is_vulnerable():
		var projected_enemy_guard: int = enemy_state.guard + packet.guard_delta_p2
		packet.guard_delta_p2 += 35 - projected_enemy_guard

	var new_player_guard: int = player_state.guard + packet.guard_delta_p1
	var new_enemy_guard: int = enemy_state.guard + packet.guard_delta_p2
	if new_player_guard <= 0 and not player_state.is_vulnerable():
		packet.guard_break = true
		packet.vulnerability_applied = true
		packet.guard_delta_p1 = -player_state.guard
		packet.meter_delta_p2 += balance_data.meter_gain_guard_break
		packet.explanation_key = "guard_break"
	if new_enemy_guard <= 0 and not enemy_state.is_vulnerable():
		packet.guard_break = true
		packet.vulnerability_applied = true
		packet.guard_delta_p2 = -enemy_state.guard
		packet.meter_delta_p1 += balance_data.meter_gain_guard_break
		packet.explanation_key = "guard_break"

func _apply_debug_break(packet: ExchangeResultPacket, context: Dictionary, player_state: FighterState, enemy_state: FighterState) -> void:
	if not DebugConfig.force_guard_break or packet.guard_break:
		return
	if context.favored_slot == DuelTypes.FighterSlot.PLAYER:
		packet.guard_delta_p2 = -enemy_state.guard
	else:
		packet.guard_delta_p1 = -player_state.guard
	packet.guard_break = true
	packet.vulnerability_applied = true

func _finalize_flags(packet: ExchangeResultPacket, player_state: FighterState, enemy_state: FighterState, balance_data: BalanceData) -> void:
	var final_player_hp: int = int(clamp(player_state.hp + packet.hp_delta_p1, 0, balance_data.start_hp))
	var final_enemy_hp: int = int(clamp(enemy_state.hp + packet.hp_delta_p2, 0, balance_data.start_hp))
	packet.draw = final_player_hp <= 0 and final_enemy_hp <= 0
	packet.finisher = final_player_hp <= 0 or final_enemy_hp <= 0
	if packet.finisher:
		packet.explanation_key = "final_blow"
	packet.camera_tags = PackedStringArray([DuelTypes.baseline_to_text(packet.baseline_state)])
	if packet.special_fired:
		packet.camera_tags.append("special")
	if packet.guard_break:
		packet.camera_tags.append("guard_break")
	if packet.p1_grade == DuelTypes.Grade.PERFECT or packet.p2_grade_abstract == DuelTypes.Grade.PERFECT:
		packet.camera_tags.append("perfect")
	packet.replay_importance_score = 0
	if packet.p1_grade == DuelTypes.Grade.PERFECT or packet.p2_grade_abstract == DuelTypes.Grade.PERFECT:
		packet.replay_importance_score += 3
	if packet.guard_break:
		packet.replay_importance_score += 4
	if packet.special_fired:
		packet.replay_importance_score += 4
	if abs(packet.hp_delta_p1) >= 20 or abs(packet.hp_delta_p2) >= 20:
		packet.replay_importance_score += 3
	if packet.vulnerability_applied:
		packet.replay_importance_score += 2
	if packet.finisher:
		packet.replay_importance_score += 5
	if packet.draw:
		packet.replay_importance_score += 5
	packet.visible_text = "%s %s (%s) vs %s %s (%s)" % [
		DuelTypes.action_to_text(packet.p1_action),
		DuelTypes.subtype_to_text(packet.p1_subtype),
		DuelTypes.grade_to_text(packet.p1_grade),
		DuelTypes.action_to_text(packet.p2_action),
		DuelTypes.subtype_to_text(packet.p2_subtype),
		DuelTypes.grade_to_text(packet.p2_grade_abstract)
	]

func _grade_points(grade: int) -> int:
	match grade:
		DuelTypes.Grade.WEAK:
			return 1
		DuelTypes.Grade.GOOD:
			return 2
		DuelTypes.Grade.PERFECT:
			return 3
		_:
			return 0

func _apply_delta(packet: ExchangeResultPacket, slot: int, hp_delta: int, guard_delta: int, meter_delta: int) -> void:
	if slot == DuelTypes.FighterSlot.PLAYER:
		packet.hp_delta_p1 += hp_delta
		packet.guard_delta_p1 += guard_delta
		packet.meter_delta_p1 += meter_delta
	else:
		packet.hp_delta_p2 += hp_delta
		packet.guard_delta_p2 += guard_delta
		packet.meter_delta_p2 += meter_delta

func _apply_attack_damage(packet: ExchangeResultPacket, source_slot: int, target_slot: int, hp_damage: int, guard_damage: int, modifier: float, attacker_state: FighterState, defender_state: FighterState, evade_punish := false, guarded_special := false, balance_data: BalanceData = null) -> void:
	var adjusted_hp: int = int(round(float(hp_damage) * modifier))
	var adjusted_guard: int = int(round(float(guard_damage) * modifier))
	if defender_state.is_vulnerable():
		adjusted_hp = int(round(float(adjusted_hp) * (1.0 + balance_data.vulnerable_attack_hp_bonus)))
		adjusted_guard = int(round(float(adjusted_guard) * (1.0 + balance_data.vulnerable_attack_guard_bonus)))
	if evade_punish:
		adjusted_guard = max(adjusted_guard, 1)
	if guarded_special:
		adjusted_hp = max(adjusted_hp, 0)
	if source_slot == DuelTypes.FighterSlot.PLAYER:
		packet.hp_delta_p2 -= adjusted_hp
		packet.guard_delta_p2 -= adjusted_guard
	else:
		packet.hp_delta_p1 -= adjusted_hp
		packet.guard_delta_p1 -= adjusted_guard

func _apply_special_damage(packet: ExchangeResultPacket, source_slot: int, target_slot: int, grade: int, attacker_state: FighterState, defender_state: FighterState, balance_data: BalanceData) -> void:
	var hp_damage: int = int(attacker_state.character.special_hp_results.get(grade, 0))
	var guard_damage: int = int(attacker_state.character.special_guard_results.get(grade, 0))
	if hp_damage > 0 or guard_damage > 0:
		if defender_state.is_vulnerable():
			hp_damage += attacker_state.character.special_vulnerable_hp_bonus
			guard_damage += attacker_state.character.special_vulnerable_guard_bonus
		_apply_attack_damage(packet, source_slot, target_slot, hp_damage, guard_damage, 1.0, attacker_state, defender_state, false, false, balance_data)
	if grade == DuelTypes.Grade.PERFECT and attacker_state.character.special_restore_guard_on_perfect > 0:
		_apply_delta(packet, source_slot, 0, attacker_state.character.special_restore_guard_on_perfect, 0)

func _attack_self_risk(subtype: int, character_data: CharacterData, balance_data: BalanceData) -> int:
	var risk: int = int(round(balance_data.get_base_guard(subtype, DuelTypes.Grade.WEAK) * 0.5))
	if subtype == DuelTypes.AttackSubtype.FAST:
		risk = int(round(float(risk) * character_data.fast_self_risk_scale))
	elif subtype in [DuelTypes.AttackSubtype.POWER, DuelTypes.AttackSubtype.PRECISION]:
		risk = int(round(float(risk) * character_data.power_precision_miss_self_risk_scale))
	return max(risk, 2)
