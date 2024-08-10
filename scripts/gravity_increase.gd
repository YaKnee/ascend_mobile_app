extends Area2D

const GRAV_MODIFIER: float = 1.8
const GRAVITY: float = 98.0

@onready var warning: AnimationPlayer = get_node("/root/SpaceScene/HUD/Overlay/Warning/AnimationPlayer")

func _on_body_entered(body):
	if body is Player:
		toggle_rocket_light(body, false)
		warning.play("flash")
		alter_gravity(body, true)

func _on_body_exited(body):
	if body is Player:
		toggle_rocket_light(body, true)
		warning.play("hide")
		alter_gravity(body, false)

func toggle_rocket_light(body: Node2D, state: bool):
	body.get_node_or_null("PointLight2D").enabled = state
	
func alter_gravity(body: Node2D, entering: bool):
	var gravity_mod = GRAV_MODIFIER if entering else 1 / GRAV_MODIFIER
	body.gravity *= gravity_mod

	var particles = body.get_node("Particles")
	var process_material = particles.process_material
	var mat_gravity = process_material.gravity
	mat_gravity.y = GRAVITY * (gravity_mod + 30) if entering else GRAVITY
	
	process_material.gravity = mat_gravity
