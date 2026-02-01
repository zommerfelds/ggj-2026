extends Area3D

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var mat: StandardMaterial3D = mesh.get_surface_override_material(0) as StandardMaterial3D

func _ready():
	mat = mesh.get_surface_override_material(0).duplicate() as StandardMaterial3D
	mesh.set_surface_override_material(0, mat)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		SignalBus.can_rotate.emit(true)
		mat.emission_energy = 1.5

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		SignalBus.can_rotate.emit(false)
		mat.emission_energy = 0.0
