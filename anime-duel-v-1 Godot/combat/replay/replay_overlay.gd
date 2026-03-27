class_name ReplayOverlay
extends Control

signal finished

var _skip_requested := false

func play_highlights(highlights: Array[ExchangeResultPacket]) -> void:
	_skip_requested = false
	show()
	if highlights.is_empty():
		hide()
		finished.emit()
		return

	$Panel/VBox/Title.text = "HIGHLIGHT REPLAY"
	for packet in highlights:
		if _skip_requested:
			break
		$Panel/VBox/Body.text = "Turn %d\n%s" % [packet.turn_index, packet.visible_text]
		$Panel/VBox/Footer.text = packet.explanation_key
		for _tick in 14:
			if _skip_requested:
				break
			await get_tree().create_timer(0.1).timeout
	hide()
	finished.emit()

func skip() -> void:
	_skip_requested = true
