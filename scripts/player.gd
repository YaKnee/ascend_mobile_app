class_name Player extends CharacterBody2D

const WALL_SLIP: float = 0.3
const JUMP_VELOCITY_Y: float = -500.0
var JUMP_VELOCITY_X: float = 400.0

var jump_direction: int = -1
var jump_count: int = 0
var x_wall: float = -1.0
var allow_double_jump: bool = true
var in_stalactite: bool = false
var space_mode: bool = false
var city_mode: bool = false
var cave_mode: bool = false
var rng = RandomNumberGenerator.new()
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var jump_sound = $JumpSound
@onready var death_sound = $DeathSound
@onready var sprite = $AnimatedSprite2D
@onready var screen_size: Vector2 = get_node("Camera2D").get_viewport_rect().size

func _ready():
	rng.randomize()
	match Global.settings.prev_played:
		"city": city_mode = true
		"cave": cave_mode = true
		"space": 
			space_mode = true
			JUMP_VELOCITY_X = 300

func _physics_process(delta):
	if Global.player_died:
		return
	sprite.flip_h = jump_direction < 0

	if city_mode: city_movement()
	elif cave_mode: cave_movement(delta)
	elif space_mode: space_movement()
	
	if not in_stalactite:
		handle_in_air(delta) 
		handle_jump_input()
	
	move_and_slide()

func city_movement():
	if is_on_wall():
		update_wall_pos_and_jump_count()
		climb()
	if is_on_ceiling():
		#kick player off wall
		position.x += (5 if position.x < screen_size.x/2 else -5)

func cave_movement(delta: float):
	if in_stalactite: #triggered from stalactite
		climb()
	elif is_on_wall():
		update_wall_pos_and_jump_count()
		velocity.y += gravity * delta * WALL_SLIP
		sprite.play("wall_slide_down" if velocity.y > 0 else "wall_slide_up")

func space_movement():
	get_node("Particles").emitting = velocity.y < 0
	jump_count = 0
	if position.x > screen_size.x:
		position.x = -screen_size.x / 12
	elif position.x < -screen_size.x / 12:
		position.x = screen_size.x

func handle_in_air(delta: float):
	if not is_on_floor() and not is_on_wall():
		velocity.y += gravity * delta
		#detect passing midpoint
		if (x_wall < screen_size.x/2 and position.x >= screen_size.x/2) \
		or (x_wall > screen_size.x/2 and position.x <= screen_size.x/2):
			allow_double_jump = true

func update_wall_pos_and_jump_count():
	x_wall = position.x
	jump_count = 0
	allow_double_jump = true

func handle_jump_input():
	if Input.is_action_just_pressed("jump") and Engine.time_scale == 1:
		#subtle pitch shift, non-monotonous
		jump_sound.pitch_scale = rng.randf_range(0.9, 1.1) 
		if (allow_double_jump and jump_count < 2) or space_mode:
			jump_sound.play()
			jump_direction = -jump_direction
			velocity = Vector2(jump_direction * JUMP_VELOCITY_X, JUMP_VELOCITY_Y)
			if jump_count != 0:
				sprite.play("jump_turn")
				await sprite.animation_finished
			
			sprite.play("jump")
			
			if space_mode: await sprite.animation_finished
			allow_double_jump = false
			jump_count += 1

func die():
	if not Global.player_died:
		Global.player_died = true
		velocity = Vector2.ZERO
		death_sound.play()
		sprite.play("death")
		await sprite.animation_finished

func climb():
	velocity = Vector2(0, -100)
	sprite.play("climb")

func jump(): #called from falling enemy script
	if not Global.player_died:
		in_stalactite = false
		sprite.play("jump")
		velocity = Vector2(jump_direction * JUMP_VELOCITY_X, JUMP_VELOCITY_Y)
	
func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "jump" and space_mode:
		sprite.play("idle")
