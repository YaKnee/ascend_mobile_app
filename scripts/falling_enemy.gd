class_name FallingEnemy extends Node2D

@onready var this = $"."
@onready var bottom_enemy: Node2D = get_parent().get_node("BottomEnemy")
@onready var screen_width: float = get_viewport_rect().size.x
@onready var x_translate: float = 300.0
@onready var rng = RandomNumberGenerator.new()
@onready var deleted: bool = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var reached_bottom_enemy: bool = false
var fall_speed: float = 100.0
var is_ray: bool = false
var can_sway: bool = false
var offscreen_offset: int = 50


func _ready():
	rng.randomize()
	if not is_ray:
		scale.x = -scale.x if rng.randf() > 0.5 else scale.x
func _process(delta):
	if Global.player_died:
		position.y += 0
		return
	if not reached_bottom_enemy:
		position.y += fall_speed * delta
		if is_ray: #space scene "death ray" physics
			#if goes offscreen, switch direction
			if position.x < -offscreen_offset or position.x > screen_width + offscreen_offset:
				x_translate = -x_translate  
				scale.x = -scale.x
			position.x += x_translate * delta
		if can_sway: #sway side to side randomly
			position.x = lerp(position.x, position.x + (2 if rng.randf() > 0.5 else -2), 0.5)
		if position.y >= bottom_enemy.position.y:
			reached_bottom_enemy = true
	else:
		position.y = bottom_enemy.position.y
		if not deleted:
			deleted = true
			despawn_self()
			

func disable_collision():
	find_child("CollisionShape2D").disabled = true

func despawn_self(play_sound: bool = false):
	call_deferred("disable_collision")
	if play_sound: get_node("Collision").play()
	this.play("crash")
	await this.animation_finished
	queue_free()

func _on_climb_area_body_exited(body): #Stalactite
	if body is Player:
		body.jump()

func _on_climb_area_body_entered(body): #Stalactite
	if body is Player:
		body.in_stalactite = true
