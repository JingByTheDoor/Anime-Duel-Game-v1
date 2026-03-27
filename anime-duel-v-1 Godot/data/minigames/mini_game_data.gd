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
	3: 1.8,
	4: 2.3,
	5: 2.8
}
@export var timing_duration := 1.8
@export var timing_heavy_duration := 2.1
@export var timing_miss_window := 0.24
@export var timing_weak_window := 0.11
@export var timing_good_window := 0.04
@export var typing_timeout := 6.0
@export var typing_target_times := {
	"short": 2.5,
	"medium": 3.8,
	"long": 5.0
}
@export var typing_prompts := PackedStringArray()
