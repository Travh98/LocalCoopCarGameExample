extends Area3D

@export var damage: float = 1

func _ready():
	body_entered.connect(on_body_entered)


func on_body_entered(body: Node3D):
	if body is ChMob:
		var mob = body as ChMob
		var health = mob.health_component as HealthComponent
		health.take_damage(damage)
	if body is RbMob:
		var mob = body as RbMob
		var health = mob.health_component as HealthComponent
		health.take_damage(damage)
