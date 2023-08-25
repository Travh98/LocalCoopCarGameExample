class_name InteractRayCast
extends RayCast3D


func get_interactable() -> InteractableComponent:
	if is_colliding():
		# Try casting collision to Interact Component
		var collider: InteractableComponent = get_collider() as InteractableComponent
		return collider
	else:
		return null
