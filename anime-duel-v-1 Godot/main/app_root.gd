extends Control

const TITLE_SCREEN := preload("res://ui/screens/title_screen.tscn")
const CHARACTER_SELECT_SCREEN := preload("res://ui/screens/character_select_screen.tscn")
const DIFFICULTY_SELECT_SCREEN := preload("res://ui/screens/difficulty_select_screen.tscn")
const RESULT_SCREEN := preload("res://ui/screens/result_screen.tscn")
const COMBAT_SCENE_PATH := "res://combat/combat_scene.tscn"
const TUTORIAL_SCENE_PATH := "res://tutorial/tutorial_scene.tscn"

var balance_data: BalanceData = preload("res://data/balance/default_balance.tres")
var character_map := {
	"martial_artist": preload("res://data/characters/martial_artist.tres"),
	"samurai": preload("res://data/characters/samurai.tres")
}
var ai_map := {
	"easy": preload("res://data/ai/easy_ai.tres"),
	"normal": preload("res://data/ai/normal_ai.tres"),
	"hard": preload("res://data/ai/hard_ai.tres")
}

var current_screen: Node
var selected_character_id := "martial_artist"
var selected_difficulty_id := "normal"
var last_result: Dictionary = {}

func _ready() -> void:
	DuelInput.ensure_actions()
	DebugConfig.reset_session()
	_show_title()

func _replace_content(node: Node) -> void:
	if current_screen:
		current_screen.queue_free()
	current_screen = node
	add_child(current_screen)

func _show_title() -> void:
	var screen: TitleScreen = TITLE_SCREEN.instantiate()
	screen.start_requested.connect(_show_character_select)
	screen.tutorial_requested.connect(_start_tutorial)
	screen.quit_requested.connect(_quit_game)
	_replace_content(screen)

func _show_character_select() -> void:
	var screen: CharacterSelectScreen = CHARACTER_SELECT_SCREEN.instantiate()
	screen.character_selected.connect(_on_character_selected)
	screen.back_requested.connect(_show_title)
	_replace_content(screen)

func _show_difficulty_select() -> void:
	var screen: DifficultySelectScreen = DIFFICULTY_SELECT_SCREEN.instantiate()
	screen.set_player_character(character_map[selected_character_id].display_name)
	screen.difficulty_selected.connect(_on_difficulty_selected)
	screen.back_requested.connect(_show_character_select)
	_replace_content(screen)

func _show_result(result: Dictionary) -> void:
	last_result = result
	var screen: ResultScreen = RESULT_SCREEN.instantiate()
	screen.set_result(result)
	screen.rematch_requested.connect(_start_duel)
	screen.switch_character_requested.connect(_show_character_select)
	screen.switch_difficulty_requested.connect(_show_difficulty_select)
	screen.title_requested.connect(_show_title)
	_replace_content(screen)

func _on_character_selected(character_id: String) -> void:
	selected_character_id = character_id
	_show_difficulty_select()

func _on_difficulty_selected(difficulty_id: String) -> void:
	selected_difficulty_id = difficulty_id
	_start_duel()

func _build_duel_setup(tutorial_mode := false) -> Dictionary:
	var player_character: CharacterData = character_map[selected_character_id]
	var enemy_character: CharacterData = character_map["samurai"]
	if selected_character_id == "samurai":
		enemy_character = character_map["martial_artist"]

	return {
		"balance_data": balance_data,
		"player_character": player_character,
		"enemy_character": enemy_character,
		"ai_config": ai_map[selected_difficulty_id],
		"tutorial_mode": tutorial_mode
	}

func _start_duel() -> void:
	var combat_scene: PackedScene = load(COMBAT_SCENE_PATH)
	var combat_controller: Node = combat_scene.instantiate()
	combat_controller.duel_finished.connect(_on_duel_finished)
	_replace_content(combat_controller)
	combat_controller.start_duel(_build_duel_setup(false))

func _start_tutorial() -> void:
	var tutorial_scene: PackedScene = load(TUTORIAL_SCENE_PATH)
	if tutorial_scene == null:
		_start_duel()
		return
	var tutorial_root: Node = tutorial_scene.instantiate()
	tutorial_root.tutorial_finished.connect(_on_duel_finished)
	_replace_content(tutorial_root)
	tutorial_root.start_tutorial(_build_duel_setup(true))

func _on_duel_finished(result: Dictionary) -> void:
	_show_result(result)

func _quit_game() -> void:
	get_tree().quit()
