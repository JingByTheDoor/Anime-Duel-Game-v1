class_name CombatController
extends Node

signal duel_finished(result: Dictionary)
signal exchange_resolved(packet: ExchangeResultPacket)

const FIGHTER_PAWN_SCENE := preload("res://actors/fighter_pawn.tscn")
const ARENA_SCENE := preload("res://arena/shrine_arena.tscn")
const PATTERN_DATA: MiniGameData = preload("res://data/minigames/pattern_input.tres")
const TIMING_DATA: MiniGameData = preload("res://data/minigames/reaction_timing.tres")
const TYPING_DATA: MiniGameData = preload("res://data/minigames/typing.tres")

@onready var arena_holder: Node3D = $WorldRoot/ArenaHolder
@onready var player_holder: Node3D = $WorldRoot/Fighters/PlayerSpawn
@onready var enemy_holder: Node3D = $WorldRoot/Fighters/EnemySpawn
@onready var camera_rig: Node3D = $WorldRoot/CameraRig
@onready var camera: Camera3D = $WorldRoot/CameraRig/Camera3D
@onready var base_anchor: Node3D = $WorldRoot/CameraRig/BaseAnchor
@onready var player_anchor: Node3D = $WorldRoot/CameraRig/PlayerAnchor
@onready var enemy_anchor: Node3D = $WorldRoot/CameraRig/EnemyAnchor
@onready var finisher_anchor: Node3D = $WorldRoot/CameraRig/FinisherAnchor
@onready var combat_hud: CombatHUD = $UILayer/CombatHUD
@onready var action_picker: ActionPicker = $PickerLayer/ActionPicker
@onready var mini_game_router: MiniGameRouter = $MiniGameRouter
@onready var replay_overlay: ReplayOverlay = $ReplayLayer/ReplayOverlay
@onready var debug_overlay: DebugOverlay = $DebugLayer/DebugOverlay

var balance_data: BalanceData
var ai_config: AIConfig
var player_state := FighterState.new()
var enemy_state := FighterState.new()
var resolver := CombatResolver.new()
var ai_brain := AIBrain.new()
var replay_director := ReplayDirector.new()
var telemetry := TelemetryLogger.new()
var rng := RandomNumberGenerator.new()
var player_pawn: FighterPawn
var enemy_pawn: FighterPawn
var exchange_log: Array[ExchangeResultPacket] = []
var recent_visible_minigames: Array[int] = []
var current_state := DuelTypes.CombatState.INIT
var turn_index := 1
var turn_timer := 0.0
var player_choice := {}
var enemy_choice := {}
var player_confirmed := false
var player_timed_out := false
var tutorial_mode := false
var tutorial_step := 0

func _ready() -> void:
	camera.make_current()
	_spawn_world()
	replay_overlay.hide()

func start_duel(setup: Dictionary) -> void:
	if player_pawn == null or enemy_pawn == null:
		_spawn_world()
	balance_data = setup.balance_data
	ai_config = setup.ai_config
	tutorial_mode = bool(setup.get("tutorial_mode", false))
	turn_index = 1
	exchange_log.clear()
	recent_visible_minigames.clear()
	rng.seed = DebugConfig.deterministic_seed
	player_state.setup(setup.player_character, balance_data)
	enemy_state.setup(setup.enemy_character, balance_data)
	player_pawn.configure(setup.player_character)
	enemy_pawn.configure(setup.enemy_character)
	player_pawn.set_vulnerable(false)
	enemy_pawn.set_vulnerable(false)
	tutorial_step = 0
	_update_ui()
	call_deferred("_run_intro")

func _process(delta: float) -> void:
	if current_state == DuelTypes.CombatState.PLANNING:
		turn_timer = max(0.0, turn_timer - delta)
		combat_hud.set_turn_timer(turn_timer)
		if turn_timer <= 0.0:
			player_timed_out = true
			_finalize_player_choice_from_timeout()
			_end_planning()

func _unhandled_input(event: InputEvent) -> void:
	if _handle_debug_input(event):
		return

	if current_state == DuelTypes.CombatState.PLANNING:
		_handle_planning_input(event)
	elif current_state == DuelTypes.CombatState.REPLAY and event is InputEventKey and event.pressed and not event.echo:
		replay_overlay.skip()

func _handle_debug_input(event: InputEvent) -> bool:
	if event.is_action_pressed("debug_toggle_overlay"):
		DebugConfig.toggle_overlay()
		return true
	if event.is_action_pressed("debug_force_guard_break"):
		DebugConfig.toggle_force_guard_break()
		return true
	if event.is_action_pressed("debug_force_special"):
		DebugConfig.toggle_force_special_available()
		return true
	if event.is_action_pressed("debug_cycle_minigame"):
		DebugConfig.cycle_minigame_type()
		return true
	if event.is_action_pressed("debug_cycle_grade"):
		DebugConfig.cycle_grade()
		return true
	return false

func _handle_planning_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	if event.is_action_pressed("duel_attack"):
		player_choice = {"action": DuelTypes.Action.ATTACK, "subtype": DuelTypes.AttackSubtype.NONE}
	elif event.is_action_pressed("duel_defend"):
		player_choice = {"action": DuelTypes.Action.DEFEND, "subtype": DuelTypes.AttackSubtype.NONE}
	elif event.is_action_pressed("duel_evade"):
		player_choice = {"action": DuelTypes.Action.EVADE, "subtype": DuelTypes.AttackSubtype.NONE}
	elif event.is_action_pressed("duel_special"):
		player_choice = {"action": DuelTypes.Action.SPECIAL, "subtype": DuelTypes.AttackSubtype.NONE}
		if not player_state.character.is_special_available(player_state, enemy_state, balance_data, DebugConfig.force_special_available):
			combat_hud.show_explanation(player_state.character.get_special_requirement_text())
	elif event.is_action_pressed("duel_fast") and int(player_choice.get("action", DuelTypes.Action.NONE)) == DuelTypes.Action.ATTACK:
		player_choice.subtype = DuelTypes.AttackSubtype.FAST
	elif event.is_action_pressed("duel_power") and int(player_choice.get("action", DuelTypes.Action.NONE)) == DuelTypes.Action.ATTACK:
		player_choice.subtype = DuelTypes.AttackSubtype.POWER
	elif event.is_action_pressed("duel_precision") and int(player_choice.get("action", DuelTypes.Action.NONE)) == DuelTypes.Action.ATTACK:
		player_choice.subtype = DuelTypes.AttackSubtype.PRECISION
	elif event.is_action_pressed("duel_back"):
		if int(player_choice.get("action", DuelTypes.Action.NONE)) == DuelTypes.Action.ATTACK and int(player_choice.get("subtype", DuelTypes.AttackSubtype.NONE)) != DuelTypes.AttackSubtype.NONE:
			player_choice.subtype = DuelTypes.AttackSubtype.NONE
		else:
			player_choice = {}
	elif event.is_action_pressed("duel_confirm") and _choice_is_complete(player_choice):
		player_confirmed = true
		_end_planning()

	_refresh_picker()

func _spawn_world() -> void:
	if arena_holder.get_child_count() == 0:
		arena_holder.add_child(ARENA_SCENE.instantiate())
	if player_pawn == null:
		player_pawn = FIGHTER_PAWN_SCENE.instantiate()
		player_holder.add_child(player_pawn)
	if enemy_pawn == null:
		enemy_pawn = FIGHTER_PAWN_SCENE.instantiate()
		enemy_holder.add_child(enemy_pawn)

func _run_intro() -> void:
	current_state = DuelTypes.CombatState.INTRO
	combat_hud.show_reveal_text(player_state.character.display_name, enemy_state.character.display_name)
	combat_hud.show_explanation("Intent decides the exchange.")
	_focus_camera(base_anchor, 0.1)
	await get_tree().create_timer(1.1).timeout
	combat_hud.clear_reveal()
	_begin_planning()

func _begin_planning() -> void:
	current_state = DuelTypes.CombatState.PLANNING
	if tutorial_mode and tutorial_step == 2:
		player_state.meter = balance_data.special_cost
		if player_state.character.special_condition_type == "hp_lte":
			player_state.hp = min(player_state.hp, player_state.character.special_condition_threshold)
		elif player_state.character.special_condition_type == "opponent_guard_lte":
			enemy_state.guard = min(enemy_state.guard, player_state.character.special_condition_threshold)
	turn_timer = balance_data.planning_time
	player_choice = {}
	player_confirmed = false
	player_timed_out = false
	enemy_choice = _build_enemy_choice()
	combat_hud.clear_grade()
	combat_hud.clear_reveal()
	combat_hud.show_explanation("Choose intent before time runs out.")
	if tutorial_mode:
		combat_hud.set_tutorial_text(_tutorial_text_for_turn())
	else:
		combat_hud.set_tutorial_text("")
	_refresh_picker()

func _build_enemy_choice() -> Dictionary:
	var snapshot := CombatSnapshot.new()
	snapshot.setup(turn_index, player_state, enemy_state, recent_visible_minigames)
	if tutorial_mode:
		match tutorial_step:
			0:
				return {"action": DuelTypes.Action.DEFEND, "subtype": DuelTypes.AttackSubtype.NONE, "timed_out": false}
			1:
				return {"action": DuelTypes.Action.DEFEND, "subtype": DuelTypes.AttackSubtype.NONE, "timed_out": false}
			2:
				return {"action": DuelTypes.Action.DEFEND, "subtype": DuelTypes.AttackSubtype.NONE, "timed_out": false}
	return ai_brain.pick_intent(snapshot, enemy_state, player_state, ai_config, balance_data, rng)

func _tutorial_text_for_turn() -> String:
	match tutorial_step:
		0:
			return "Start with Attack -> Fast to feel the duel rhythm."
		1:
			return "Push Guard pressure. A clean exchange can crack composure."
		2:
			return "Special is available now. Commit to the anime payoff."
		_:
			return ""

func _refresh_picker() -> void:
	action_picker.update_display(player_choice, player_state.character, balance_data, player_state.character.is_special_available(player_state, enemy_state, balance_data, DebugConfig.force_special_available), player_confirmed, player_timed_out)
	combat_hud.update_fighter_panels(player_state, enemy_state, balance_data)

func _choice_is_complete(choice: Dictionary) -> bool:
	var action := int(choice.get("action", DuelTypes.Action.NONE))
	if action == DuelTypes.Action.NONE:
		return false
	if action == DuelTypes.Action.ATTACK:
		return int(choice.get("subtype", DuelTypes.AttackSubtype.NONE)) != DuelTypes.AttackSubtype.NONE
	return true

func _finalize_player_choice_from_timeout() -> void:
	if _choice_is_complete(player_choice):
		player_choice.timed_out = true
		return
	player_choice = {"action": DuelTypes.Action.DEFEND, "subtype": DuelTypes.AttackSubtype.NONE, "timed_out": true, "auto_defend": true}
	_refresh_picker()

func _end_planning() -> void:
	if current_state != DuelTypes.CombatState.PLANNING:
		return
	current_state = DuelTypes.CombatState.CONFIRM
	if not _choice_is_complete(player_choice):
		_finalize_player_choice_from_timeout()
	call_deferred("_run_exchange")

func _run_exchange() -> void:
	current_state = DuelTypes.CombatState.REVEAL
	combat_hud.show_reveal_text(_choice_text(player_choice), _choice_text(enemy_choice))
	await get_tree().create_timer(balance_data.reveal_pause).timeout
	combat_hud.clear_reveal()

	var context := resolver.build_exchange_context(player_choice, enemy_choice, player_state, enemy_state, balance_data, recent_visible_minigames)
	context.turn_index = turn_index
	var player_grade := DuelTypes.Grade.WEAK
	var enemy_grade := ai_brain.roll_grade(int(context.enemy_mini_game_type), ai_config, rng)
	if context.baseline_state != DuelTypes.BaselineState.QUICK_RESOLVE:
		current_state = DuelTypes.CombatState.SPAWN_MINI_GAME
		var player_result: MiniGameResult = await _play_player_minigame(int(context.visible_mini_game_type))
		player_grade = player_result.grade
		if player_timed_out and player_grade > DuelTypes.Grade.WEAK:
			player_grade = DuelTypes.Grade.WEAK
	else:
		player_grade = DuelTypes.Grade.WEAK
		enemy_grade = DuelTypes.Grade.WEAK

	var packet := resolver.resolve_exchange(context, player_grade, enemy_grade, player_state, enemy_state, balance_data)
	_apply_character_passives(packet, player_grade, enemy_grade)
	apply_packet(packet)
	await _playback_packet(packet)
	if player_state.hp <= 0 or enemy_state.hp <= 0:
		await _finish_duel()
	else:
		turn_index += 1
		tutorial_step += 1
		_begin_planning()

func _play_player_minigame(minigame_type: int) -> MiniGameResult:
	current_state = DuelTypes.CombatState.MINI_GAME_ACTIVE
	var data := _get_minigame_data(minigame_type)
	mini_game_router.begin_minigame(data, {"rng": rng, "heavy": int(player_choice.get("subtype", DuelTypes.AttackSubtype.NONE)) == DuelTypes.AttackSubtype.POWER})
	var result: MiniGameResult = await mini_game_router.mini_game_completed
	return result

func _get_minigame_data(minigame_type: int) -> MiniGameData:
	match minigame_type:
		DuelTypes.MiniGameType.PATTERN:
			return PATTERN_DATA
		DuelTypes.MiniGameType.TIMING:
			return TIMING_DATA
		DuelTypes.MiniGameType.TYPING:
			return TYPING_DATA
		_:
			return TIMING_DATA

func _choice_text(choice: Dictionary) -> String:
	var action_text := DuelTypes.action_to_text(int(choice.get("action", DuelTypes.Action.NONE)))
	if int(choice.get("action", DuelTypes.Action.NONE)) == DuelTypes.Action.ATTACK:
		return "%s %s" % [action_text, DuelTypes.subtype_to_text(int(choice.get("subtype", DuelTypes.AttackSubtype.NONE)))]
	return action_text

func _apply_character_passives(packet: ExchangeResultPacket, player_grade: int, enemy_grade: int) -> void:
	if player_state.character.id == "martial_artist" and int(player_choice.get("subtype", DuelTypes.AttackSubtype.NONE)) == DuelTypes.AttackSubtype.FAST and player_grade >= DuelTypes.Grade.GOOD:
		packet.meter_delta_p1 += player_state.character.fast_bonus_meter
	if enemy_state.character.id == "martial_artist" and int(enemy_choice.get("subtype", DuelTypes.AttackSubtype.NONE)) == DuelTypes.AttackSubtype.FAST and enemy_grade >= DuelTypes.Grade.GOOD:
		packet.meter_delta_p2 += enemy_state.character.fast_bonus_meter
	if player_state.character.evade_bonus_guard > 0 and int(player_choice.get("action", DuelTypes.Action.NONE)) == DuelTypes.Action.EVADE and packet.hp_delta_p1 == 0:
		packet.guard_delta_p1 += player_state.character.evade_bonus_guard
	if enemy_state.character.evade_bonus_guard > 0 and int(enemy_choice.get("action", DuelTypes.Action.NONE)) == DuelTypes.Action.EVADE and packet.hp_delta_p2 == 0:
		packet.guard_delta_p2 += enemy_state.character.evade_bonus_guard

func apply_packet(packet: ExchangeResultPacket) -> void:
	var player_was_vulnerable := player_state.is_vulnerable()
	var enemy_was_vulnerable := enemy_state.is_vulnerable()
	player_state.push_history(int(player_choice.get("action", DuelTypes.Action.NONE)), int(player_choice.get("subtype", DuelTypes.AttackSubtype.NONE)))
	enemy_state.push_history(int(enemy_choice.get("action", DuelTypes.Action.NONE)), int(enemy_choice.get("subtype", DuelTypes.AttackSubtype.NONE)))
	player_state.hp = clamp(player_state.hp + packet.hp_delta_p1, 0, balance_data.start_hp)
	enemy_state.hp = clamp(enemy_state.hp + packet.hp_delta_p2, 0, balance_data.start_hp)
	player_state.guard = clamp(player_state.guard + packet.guard_delta_p1, 0, balance_data.start_guard)
	enemy_state.guard = clamp(enemy_state.guard + packet.guard_delta_p2, 0, balance_data.start_guard)
	player_state.meter = clamp(player_state.meter + packet.meter_delta_p1, 0, balance_data.meter_cap)
	enemy_state.meter = clamp(enemy_state.meter + packet.meter_delta_p2, 0, balance_data.meter_cap)

	if player_was_vulnerable:
		player_state.vulnerable_turns = 0
		player_state.guard_reset_pending = false
	if enemy_was_vulnerable:
		enemy_state.vulnerable_turns = 0
		enemy_state.guard_reset_pending = false
	if packet.guard_break:
		if enemy_state.guard == 0 and packet.guard_delta_p2 < 0:
			enemy_state.vulnerable_turns = 1
			enemy_state.guard_reset_pending = true
		if player_state.guard == 0 and packet.guard_delta_p1 < 0:
			player_state.vulnerable_turns = 1
			player_state.guard_reset_pending = true

	player_pawn.set_vulnerable(player_state.is_vulnerable())
	enemy_pawn.set_vulnerable(enemy_state.is_vulnerable())
	packet.post_snapshot = {"player": player_state.snapshot(), "enemy": enemy_state.snapshot()}
	exchange_log.append(packet)
	if not packet.quick_resolve and packet.mini_game_type != DuelTypes.MiniGameType.NONE:
		recent_visible_minigames.push_front(packet.mini_game_type)
		if recent_visible_minigames.size() > 3:
			recent_visible_minigames.resize(3)
	exchange_resolved.emit(packet)
	telemetry.log_exchange(packet)
	_update_ui()

func _playback_packet(packet: ExchangeResultPacket) -> void:
	current_state = DuelTypes.CombatState.PLAYBACK
	if packet.quick_resolve:
		combat_hud.show_grade("Quick Resolve", player_state.character.accent_color)
	else:
		combat_hud.show_grade(DuelTypes.grade_to_text(packet.p1_grade), player_state.character.accent_color)
	var explanation := balance_data.get_explanation(packet.explanation_key)
	if explanation.is_empty():
		explanation = packet.explanation_key
	combat_hud.show_explanation(explanation)
	_focus_camera(_anchor_for_packet(packet), 0.16)
	_animate_choice(player_pawn, player_choice)
	_animate_choice(enemy_pawn, enemy_choice)
	if packet.hp_delta_p1 < 0:
		player_pawn.play_hit(abs(packet.hp_delta_p1) >= 18)
		combat_hud.pulse_impact()
	if packet.hp_delta_p2 < 0:
		enemy_pawn.play_hit(abs(packet.hp_delta_p2) >= 18)
		combat_hud.pulse_impact()
	if packet.guard_break:
		if enemy_state.is_vulnerable():
			enemy_pawn.play_guard_break()
		if player_state.is_vulnerable():
			player_pawn.play_guard_break()
	await get_tree().create_timer(balance_data.recovery_pause).timeout
	combat_hud.clear_grade()

func _anchor_for_packet(packet: ExchangeResultPacket) -> Node3D:
	if packet.finisher or packet.special_fired:
		return finisher_anchor
	if packet.guard_break or packet.p1_grade == DuelTypes.Grade.PERFECT:
		return player_anchor
	if packet.p2_grade_abstract == DuelTypes.Grade.PERFECT:
		return enemy_anchor
	return base_anchor

func _animate_choice(pawn: FighterPawn, choice: Dictionary) -> void:
	match int(choice.get("action", DuelTypes.Action.NONE)):
		DuelTypes.Action.ATTACK:
			pawn.play_attack(int(choice.get("subtype", DuelTypes.AttackSubtype.NONE)))
		DuelTypes.Action.DEFEND:
			pawn.play_defend()
		DuelTypes.Action.EVADE:
			pawn.play_evade()
		DuelTypes.Action.SPECIAL:
			pawn.pulse_special()
			pawn.play_attack(DuelTypes.AttackSubtype.POWER, true)
		_:
			pawn.play_idle()

func _focus_camera(anchor: Node3D, duration: float) -> void:
	var tween := get_tree().create_tween().bind_node(camera_rig)
	tween.tween_property(camera, "global_transform", anchor.global_transform, duration)

func _finish_duel() -> void:
	current_state = DuelTypes.CombatState.REPLAY
	var highlights := replay_director.build_highlights(exchange_log)
	combat_hud.show_explanation("Highlight replay")
	replay_overlay.play_highlights(highlights)
	await replay_overlay.finished
	var result := {
		"winner_text": _winner_text(),
		"outcome_text": _outcome_text(),
		"highlight_count": highlights.size()
	}
	duel_finished.emit(result)

func _winner_text() -> String:
	if player_state.hp <= 0 and enemy_state.hp <= 0:
		return "Draw"
	if enemy_state.hp <= 0:
		return "%s wins" % player_state.character.display_name
	return "%s wins" % enemy_state.character.display_name

func _outcome_text() -> String:
	if player_state.hp <= 0 and enemy_state.hp <= 0:
		return "Double KO."
	if enemy_state.hp <= 0:
		return "You won the duel."
	return "The AI won the duel."

func _update_ui() -> void:
	combat_hud.update_fighter_panels(player_state, enemy_state, balance_data)
	combat_hud.set_turn_timer(turn_timer)
	_refresh_picker()
