class_name MiniGameResult
extends RefCounted

var grade := DuelTypes.Grade.MISS
var elapsed := 0.0
var errors := 0
var timed_out := false
var raw_score := 0.0
var metadata: Dictionary = {}

func to_dictionary() -> Dictionary:
	return {
		"grade": grade,
		"elapsed": elapsed,
		"errors": errors,
		"timed_out": timed_out,
		"raw_score": raw_score,
		"metadata": metadata.duplicate(true)
	}
