class_name ReplayDirector
extends RefCounted

func build_highlights(exchange_log: Array[ExchangeResultPacket]) -> Array[ExchangeResultPacket]:
	if exchange_log.is_empty():
		return []

	var highlights: Array[ExchangeResultPacket] = []
	var sorted_log := exchange_log.duplicate()
	sorted_log.sort_custom(func(a: ExchangeResultPacket, b: ExchangeResultPacket) -> bool:
		return a.replay_importance_score > b.replay_importance_score
	)

	var final_packet: ExchangeResultPacket = exchange_log.back()
	highlights.append(final_packet)

	for packet in exchange_log:
		if packet.guard_break and not highlights.has(packet):
			highlights.append(packet)
		if packet.draw and not highlights.has(packet):
			highlights.append(packet)

	for packet in sorted_log:
		if highlights.size() >= 6:
			break
		if not highlights.has(packet):
			highlights.append(packet)

	if not highlights.has(exchange_log.front()):
		highlights.push_front(exchange_log.front())

	return highlights.slice(0, min(highlights.size(), 6))
