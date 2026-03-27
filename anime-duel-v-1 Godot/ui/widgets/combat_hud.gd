class_name CombatHUD
extends Control

func set_turn_timer(value: float) -> void:
	$TimerLabel.text = "%.1f" % value

func update_fighter_panels(player_state: FighterState, enemy_state: FighterState, balance_data: BalanceData) -> void:
	_update_panel($PlayerPanel, player_state, balance_data)
	_update_panel($EnemyPanel, enemy_state, balance_data)

func show_reveal_text(player_text: String, enemy_text: String) -> void:
	$CenterBox/RevealLabel.text = "%s  vs  %s" % [player_text, enemy_text]
	$CenterBox/RevealLabel.show()

func clear_reveal() -> void:
	$CenterBox/RevealLabel.hide()

func show_explanation(text: String) -> void:
	$BottomInfo/Explanation.text = text

func show_grade(grade_text: String, accent: Color) -> void:
	$CenterBox/GradeLabel.text = grade_text
	$CenterBox/GradeLabel.modulate = accent
	$CenterBox/GradeLabel.show()

func clear_grade() -> void:
	$CenterBox/GradeLabel.hide()

func set_tutorial_text(text: String) -> void:
	$BottomInfo/TutorialHint.text = text
	$BottomInfo/TutorialHint.visible = not text.is_empty()

func pulse_impact() -> void:
	$ImpactFlash.modulate.a = 0.45
	var tween := get_tree().create_tween().bind_node(self)
	tween.tween_property($ImpactFlash, "modulate:a", 0.0, 0.2)

func _update_panel(panel: PanelContainer, state: FighterState, balance_data: BalanceData) -> void:
	panel.get_node("VBox/Name").text = state.character.display_name
	panel.get_node("VBox/HPBar").max_value = balance_data.start_hp
	panel.get_node("VBox/GuardBar").max_value = balance_data.start_guard
	panel.get_node("VBox/MeterBar").max_value = balance_data.meter_cap
	panel.get_node("VBox/HPBar").value = state.hp
	panel.get_node("VBox/GuardBar").value = state.guard
	panel.get_node("VBox/MeterBar").value = state.meter
	panel.get_node("VBox/StateText").text = "Vulnerable" if state.is_vulnerable() else state.character.passive_name
