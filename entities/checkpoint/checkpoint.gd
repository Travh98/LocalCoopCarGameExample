class_name Checkpoint
extends Node3D

signal checkpoint_entered(checkpoint: Node3D, body: Node3D)

@onready var checkpoint_particles : GPUParticles3D = $CheckpointParticles
@onready var checkpoint_area: Area3D = $CheckpointArea
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready():
	checkpoint_area.body_entered.connect(on_body_entered)
	mesh_instance.visible = false
	

func on_body_entered(body: Node3D):
	if body is VehicleBody3D:
		var vehicle = body as VehicleBody3D
		if vehicle.has_node("PlayerCarController"):
			var controller = vehicle.get_node("PlayerCarController")
			if controller.last_checkpoint != self:
				controller.last_checkpoint = self
				checkpoint_particles.emitting = true
				checkpoint_entered.emit(self, body)
		
