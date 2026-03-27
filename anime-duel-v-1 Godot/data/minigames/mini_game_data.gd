class_name MiniGameData
extends Resource

@export var id := ""
@export var display_name := ""
@export var mini_game_type := DuelTypes.MiniGameType.NONE
@export var scene: PackedScene
@export var repetition_cap := 2
@export var sequence_lengths: Array[int] = []
@export var sequence_keys := PackedStringArray(["A", "S", "D", "J", "K", "L"])
@export var pattern_time_limits := {
	3: 1.2,
	4: 1.6,
	5: 2.0
}
@export var timing_miss_window := 0.24
@export var timing_weak_window := 0.11
@export var timing_good_window := 0.04
@export var typing_timeout := 4.0
@export var typing_target_times := {
	"short": 1.8,
	"medium": 2.8,
	"long": 3.8
}
@export var typing_prompts := PackedStringArray()
