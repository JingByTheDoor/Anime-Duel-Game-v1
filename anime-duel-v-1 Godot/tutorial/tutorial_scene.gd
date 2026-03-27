extends Node

signal tutorial_finished(result: Dictionary)

const COMBAT_SCENE := preload("res://combat/combat_scene.tscn")

var combat_controller: CombatController

func start_tutorial(setup: Dictionary) -> void:
	combat_controller = COMBAT_SCENE.instantiate()
	add_child(combat_controller)
	combat_controller.duel_finished.connect(_on_duel_finished)
	combat_controller.start_duel(setup)

func _on_duel_finished(result: Dictionary) -> void:
	tutorial_finished.emit(result)
