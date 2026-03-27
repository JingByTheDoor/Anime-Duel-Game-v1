class_name FighterPawn
extends Node3D

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var aura_mesh: MeshInstance3D = $AuraMesh

var character_data: CharacterData
var _base_position := Vector3.ZERO
var _base_rotation := Vector3.ZERO

func _ready() -> void:
	_base_position = position
	_base_rotation = rotation

func configure(data: CharacterData) -> void:
	character_data = data
	var body_material := body_mesh.get_active_material(0)
	if body_material is StandardMaterial3D:
		body_material.albedo_color = data.accent_color
	var aura_material := aura_mesh.get_active_material(0)
	if aura_material is StandardMaterial3D:
		aura_material.albedo_color = data.accent_color.lightened(0.25)

func play_idle() -> void:
	_reset_transform()

func play_attack(subtype: int, is_special := false) -> void:
	var push := -0.45
	var lift := 0.06
	if subtype == DuelTypes.AttackSubtype.POWER or is_special:
		push = -0.6
		lift = 0.12
	var tween := get_tree().create_tween().bind_node(self)
	tween.tween_property(self, "position", _base_position + Vector3(0.0, lift, push), 0.12)
	tween.tween_property(self, "position", _base_position, 0.20)

func play_defend() -> void:
	var tween := get_tree().create_tween().bind_node(self)
	tween.tween_property(self, "rotation", _base_rotation + Vector3(0.0, 0.0, 0.12), 0.10)
	tween.tween_property(self, "rotation", _base_rotation, 0.16)

func play_evade() -> void:
	var tween := get_tree().create_tween().bind_node(self)
	tween.tween_property(self, "position", _base_position + Vector3(0.35, 0.08, 0.25), 0.12)
	tween.tween_property(self, "position", _base_position, 0.18)

func play_hit(heavy := false) -> void:
	var distance := 0.22
	if heavy:
		distance = 0.35
	var tween := get_tree().create_tween().bind_node(self)
	tween.tween_property(self, "position", _base_position + Vector3(0.0, 0.0, distance), 0.08)
	tween.parallel().tween_property(self, "scale", Vector3.ONE * 1.05, 0.08)
	tween.tween_property(self, "position", _base_position, 0.16)
	tween.parallel().tween_property(self, "scale", Vector3.ONE, 0.14)

func play_guard_break() -> void:
	var tween := get_tree().create_tween().bind_node(self)
	tween.tween_property(self, "rotation", _base_rotation + Vector3(0.0, 0.0, 0.35), 0.14)
	tween.parallel().tween_property(aura_mesh, "scale", Vector3.ONE * 1.6, 0.14)
	tween.tween_property(self, "rotation", _base_rotation, 0.22)
	tween.parallel().tween_property(aura_mesh, "scale", Vector3.ONE, 0.18)

func pulse_special() -> void:
	var tween := get_tree().create_tween().bind_node(self)
	tween.tween_property(aura_mesh, "scale", Vector3.ONE * 1.7, 0.18)
	tween.parallel().tween_property(aura_mesh, "visible", true, 0.0)
	tween.tween_property(aura_mesh, "scale", Vector3.ONE, 0.22)

func set_vulnerable(active: bool) -> void:
	aura_mesh.visible = active

func _reset_transform() -> void:
	position = _base_position
	rotation = _base_rotation
	scale = Vector3.ONE
