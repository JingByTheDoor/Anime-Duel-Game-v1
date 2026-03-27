class_name ActionPicker
extends PanelContainer

func update_display(choice: Dictionary, character_data: CharacterData, balance_data: BalanceData, special_available: bool, selection_locked: bool, timeout_cap := false) -> void:
	var action := int(choice.get("action", DuelTypes.Action.NONE))
	var subtype := int(choice.get("subtype", DuelTypes.AttackSubtype.NONE))
	$VBox/Header.text = "COMMAND PICKER"
	$VBox/Actions.text = "1 Attack   2 Defend   3 Evade   4 Special"
	$VBox/Subtypes.text = "Q Fast   W Power   E Precision"
	$VBox/Current.text = "Current: %s %s" % [DuelTypes.action_to_text(action), DuelTypes.subtype_to_text(subtype)]
	$VBox/Special.text = "%s  |  %s" % [character_data.special_name, character_data.get_special_requirement_text()]
	$VBox/Special.modulate = Color(0.55, 0.55, 0.55, 1) if not special_available else character_data.accent_color
	$VBox/Preview.text = "Preview: %s" % ", ".join(balance_data.get_preview_tags(action, subtype, character_data.id))
	$VBox/Confirm.text = "Enter confirm early   Esc back"
	$VBox/Status.text = "Selection locked" if selection_locked else "Editing allowed"
	if timeout_cap:
		$VBox/Status.text += "  |  Timeout caps result at Weak"
