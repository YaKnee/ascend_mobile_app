extends Area2D

func _on_body_entered(body):
	if body is Player:
		call_deferred("kill_player", body)
		if get_parent() is FallingEnemy:
			get_parent().despawn_self(true) #true = collide sound


func _on_area_entered(_area): #collision between enemies
	if get_parent() is FallingEnemy and not get_parent().is_ray:
		get_parent().despawn_self()

func kill_player(body: Node2D):
	Engine.time_scale = 0.5
	body.die()
