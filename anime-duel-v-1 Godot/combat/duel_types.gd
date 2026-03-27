class_name DuelTypes
extends RefCounted

enum FighterSlot {
	PLAYER,
	ENEMY
}

enum Action {
	NONE,
	ATTACK,
	DEFEND,
	EVADE,
	SPECIAL
}

enum AttackSubtype {
	NONE,
	FAST,
	POWER,
	PRECISION
}

enum BaselineState {
	NONE,
	STRIKE,
	GUARDED_STRIKE,
	WHIFF_PUNISH,
	CLASH,
	NEUTRAL_RESET,
	SPECIAL_EVENT,
	QUICK_RESOLVE
}

enum MiniGameType {
	NONE,
	PATTERN,
	TIMING,
	TYPING
}

enum Grade {
	MISS,
	WEAK,
	GOOD,
	PERFECT
}

enum CombatState {
	INIT,
	INTRO,
	PLANNING,
	CONFIRM,
	REVEAL,
	RESOLVE_BASELINE,
	SPAWN_MINI_GAME,
	MINI_GAME_ACTIVE,
	RESOLVE_OUTCOME,
	PLAYBACK,
	RECOVERY,
	CHECK_END,
	REPLAY,
	RESULT
}

static func action_to_text(action: int) -> String:
	match action:
		Action.ATTACK:
			return "Attack"
		Action.DEFEND:
			return "Defend"
		Action.EVADE:
			return "Evade"
		Action.SPECIAL:
			return "Special"
		_:
			return "None"

static func subtype_to_text(subtype: int) -> String:
	match subtype:
		AttackSubtype.FAST:
			return "Fast"
		AttackSubtype.POWER:
			return "Power"
		AttackSubtype.PRECISION:
			return "Precision"
		_:
			return "None"

static func grade_to_text(grade: int) -> String:
	match grade:
		Grade.MISS:
			return "Miss"
		Grade.WEAK:
			return "Weak"
		Grade.GOOD:
			return "Good"
		Grade.PERFECT:
			return "Perfect"
		_:
			return "Quick Resolve"

static func minigame_to_text(minigame_type: int) -> String:
	match minigame_type:
		MiniGameType.PATTERN:
			return "Pattern Input"
		MiniGameType.TIMING:
			return "Reaction Timing"
		MiniGameType.TYPING:
			return "Typing"
		_:
			return "None"

static func baseline_to_text(baseline_state: int) -> String:
	match baseline_state:
		BaselineState.STRIKE:
			return "Strike"
		BaselineState.GUARDED_STRIKE:
			return "Guarded Strike"
		BaselineState.WHIFF_PUNISH:
			return "Whiff Punish"
		BaselineState.CLASH:
			return "Clash"
		BaselineState.NEUTRAL_RESET:
			return "Neutral Reset"
		BaselineState.SPECIAL_EVENT:
			return "Special Event"
		BaselineState.QUICK_RESOLVE:
			return "Quick Resolve"
		_:
			return "None"
