class_name AIConfig
extends Resource

@export var id := ""
@export var display_name := ""
@export var memory_turns := 1
@export var bluff_rate := 0.10
@export var randomness := 0.25
@export var miss_rate := 0.10
@export var weak_rate := 0.25
@export var good_rate := 0.50
@export var perfect_rate := 0.15
@export var typing_miss_bonus := 0.04
@export var typing_perfect_penalty := 0.04
@export var power_miss_penalty := -0.02
@export var power_good_bonus := 0.02
@export var aggression_bias := 1.0
@export var defend_bias := 1.0
@export var evade_bias := 1.0
@export var special_bias := 1.0
@export var adaptiveness := 1.0
