class_name TelemetryLogger
extends RefCounted

const FILE_PATH := "user://telemetry.jsonl"

var enabled := true

func log_exchange(packet: ExchangeResultPacket) -> void:
	if not enabled:
		return
	var file := FileAccess.open(FILE_PATH, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
		if file == null:
			return
	file.seek_end()
	file.store_line(JSON.stringify(packet.to_dictionary()))
