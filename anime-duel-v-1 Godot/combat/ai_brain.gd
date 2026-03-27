class_name AIBrain
extends RefCounted

func pick_intent(snapshot: CombatSnapshot, self_state: FighterState, opponent_state: FighterState, config: AIConfig, balance_data: BalanceData, rng: RandomNumberGenerator) -> Dictionary:
	var action_weights: Dictionary = {
		DuelTypes.Action.ATTACK: 1.0 * config.aggression_bias * self_state.character.ai_attack_bias,
		DuelTypes.Action.DEFEND: 0.8 * config.defend_bias * self_state.character.ai_defend_bias,
		DuelTypes.Action.EVADE: 0.55 * config.evade_bias * self_state.character.ai_evade_bias,
		DuelTypes.Action.SPECIAL: 0.2 * config.special_bias * self_state.character.ai_special_bias
	}

	if self_state.guard <= 35 or self_state.is_vulnerable():
		action_weights[DuelTypes.Action.DEFEND] += 0.6 * config.adaptiveness
		action_weights[DuelTypes.Action.EVADE] += 0.2

	if self_state.hp <= 35:
		action_weights[DuelTypes.Action.DEFEND] += 0.4

	if opponent_state.guard <= 40:
		action_weights[DuelTypes.Action.ATTACK] += 0.4

	if self_state.character.is_special_available(self_state, opponent_state, balance_data, DebugConfig.force_special_available):
		action_weights[DuelTypes.Action.SPECIAL] += 0.55 * config.special_bias

	var recent_patterns: Dictionary = _count_recent_actions(opponent_state.action_history, config.memory_turns)
	if recent_patterns.get(DuelTypes.Action.ATTACK, 0) >= 2:
		action_weights[DuelTypes.Action.DEFEND] += 0.15 * config.adaptiveness
	if recent_patterns.get(DuelTypes.AttackSubtype.POWER, 0) >= 1:
		action_weights[DuelTypes.Action.EVADE] += 0.35 * config.adaptiveness
	if recent_patterns.get(DuelTypes.AttackSubtype.FAST, 0) >= 2:
		action_weights[DuelTypes.Action.DEFEND] += 0.15 * config.adaptiveness

	if rng.randf() < config.bluff_rate:
		action_weights[DuelTypes.Action.EVADE] += 0.2

	_apply_randomness(action_weights, config.randomness, rng)
	var action: int = _weighted_pick(action_weights, rng)
	var subtype: int = DuelTypes.AttackSubtype.NONE
	if action == DuelTypes.Action.ATTACK:
		subtype = _pick_subtype(opponent_state, self_state, config, rng)

	return {
		"action": action,
		"subtype": subtype,
		"timed_out": false,
		"confirmed": true,
		"auto_defend": false
	}

func roll_grade(minigame_type: int, config: AIConfig, rng: RandomNumberGenerator) -> int:
	if DebugConfig.forced_grade >= 0:
		return DebugConfig.forced_grade

	var miss_rate: float = config.miss_rate
	var weak_rate: float = config.weak_rate
	var good_rate: float = config.good_rate
	var perfect_rate: float = config.perfect_rate

	if minigame_type == DuelTypes.MiniGameType.TYPING:
		miss_rate += config.typing_miss_bonus
		perfect_rate = max(0.0, perfect_rate - config.typing_perfect_penalty)
	elif minigame_type == DuelTypes.MiniGameType.TIMING:
		miss_rate = max(0.0, miss_rate + config.power_miss_penalty)
		good_rate += config.power_good_bonus

	var total: float = miss_rate + weak_rate + good_rate + perfect_rate
	miss_rate /= total
	weak_rate /= total
	good_rate /= total

	var roll: float = rng.randf()
	if roll < miss_rate:
		return DuelTypes.Grade.MISS
	if roll < miss_rate + weak_rate:
		return DuelTypes.Grade.WEAK
	if roll < miss_rate + weak_rate + good_rate:
		return DuelTypes.Grade.GOOD
	return DuelTypes.Grade.PERFECT

func _pick_subtype(opponent_state: FighterState, self_state: FighterState, config: AIConfig, rng: RandomNumberGenerator) -> int:
	var subtype_weights: Dictionary = {
		DuelTypes.AttackSubtype.FAST: 1.0 * self_state.character.ai_fast_bias,
		DuelTypes.AttackSubtype.POWER: 1.0 * self_state.character.ai_power_bias,
		DuelTypes.AttackSubtype.PRECISION: 0.85 * self_state.character.ai_precision_bias
	}

	if opponent_state.guard <= 40:
		subtype_weights[DuelTypes.AttackSubtype.POWER] += 0.45 * config.adaptiveness
	if opponent_state.hp <= 35:
		subtype_weights[DuelTypes.AttackSubtype.PRECISION] += 0.35 * config.adaptiveness
	if opponent_state.last_subtype == DuelTypes.AttackSubtype.POWER:
		subtype_weights[DuelTypes.AttackSubtype.FAST] += 0.2

	_apply_randomness(subtype_weights, config.randomness, rng)
	return _weighted_pick(subtype_weights, rng)

func _count_recent_actions(history: Array[Dictionary], turns: int) -> Dictionary:
	var counts: Dictionary = {}
	var max_turns: int = min(turns, history.size())
	for index in max_turns:
		var action: int = int(history[index].get("action", DuelTypes.Action.NONE))
		var subtype: int = int(history[index].get("subtype", DuelTypes.AttackSubtype.NONE))
		counts[action] = int(counts.get(action, 0)) + 1
		counts[subtype] = int(counts.get(subtype, 0)) + 1
	return counts

func _apply_randomness(weights: Dictionary, randomness: float, rng: RandomNumberGenerator) -> void:
	for key in weights.keys():
		weights[key] = max(0.05, float(weights[key]) + rng.randf_range(-randomness, randomness))

func _weighted_pick(weights: Dictionary, rng: RandomNumberGenerator) -> int:
	var total: float = 0.0
	for value in weights.values():
		total += float(value)
	var roll: float = rng.randf_range(0.0, total)
	var current: float = 0.0
	for key in weights.keys():
		current += float(weights[key])
		if roll <= current:
			return int(key)
	return int(weights.keys().front())
