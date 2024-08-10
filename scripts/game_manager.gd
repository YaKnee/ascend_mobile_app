extends Node2D

const START_SPEED: float = 3.0
#const MAX_SPEED: float = 10.0
const ENEMY_START_POS:= Vector2(180, 640)
const WALL_START_POS:= Vector2(0, -640)
var PLAYER_START_POS:= Vector2(34, 0)

#Falling Enemy Variables and Resources
var first_interval: float = 1.0
var second_interval: float = 2.4
var falling_enemies: Array
var fall_speed: float = 50.0
var plant: PackedScene = preload("res://scenes/falling_objects/plant_pot.tscn")
var stalactite: PackedScene= preload("res://scenes/falling_objects/stalactite.tscn")
var fire_enemy: PackedScene = preload("res://scenes/falling_objects/fire.tscn")
var asteroid: PackedScene= preload("res://scenes/falling_objects/asteroid.tscn")
var death_ray: PackedScene = preload("res://scenes/falling_objects/death_ray.tscn")

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var game_running: bool = false
var speed: float 
var hs_audio_played: bool = false
var death_handled: bool = false
#var speed_updated: bool = false 

@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var hud = $HUD
@onready var enemy = $BottomEnemy
@onready var walls = $Walls
@onready var bg_music = $BackgroundMusic
@onready var screen_size: Vector2 = camera.get_viewport_rect().size

func _ready():
	match Global.settings.prev_played:
		"city": 
			falling_enemies = [plant, plant]
			fall_speed = 100.0
			first_interval = 1.5
			second_interval = 3.2
			var window_timer = Timer.new()
			add_child(window_timer)
			window_timer.timeout.connect(spawn_window)
			window_timer.start(3)
		"cave": 
			falling_enemies = [fire_enemy, stalactite]
			fall_speed = 70.0
			second_interval = 0.9
		"space": 
			falling_enemies = [asteroid, death_ray]
			fall_speed = 50.0
			PLAYER_START_POS = Vector2(168, 0) #centre the player
			first_interval = 0.5
	set_up_game()

func _process(delta: float):
	if game_running:
		update_game(delta)
	else:
		start_game()
	if Global.player_died and not death_handled:
		handle_death()
		death_handled = true

func set_up_game():
	Global.player_died = false
	Global.score = 0
	speed = START_SPEED
	player.position = PLAYER_START_POS
	enemy.position = ENEMY_START_POS
	walls.position = WALL_START_POS
	Engine.time_scale = 0
	
	var first_timer = Timer.new()
	add_child(first_timer)
	first_timer.timeout.connect(spawn_falling_object.bind(falling_enemies[0], fall_speed * 2))
	first_timer.start(first_interval)
	
	var second_timer = Timer.new()
	add_child(second_timer)
	second_timer.timeout.connect(spawn_falling_object.bind(falling_enemies[1], fall_speed))
	second_timer.start(second_interval)
	
func spawn_falling_object(falling_enemy: PackedScene, falling_speed: float):
	var falling_object = falling_enemy.instantiate()
	falling_object.fall_speed = falling_speed
	falling_object.is_ray = true if falling_object.name == "DeathRay" else false
	if falling_object.name in ["Asteroid", "Fire"]: falling_object.can_sway = true
	add_child(falling_object)
	var wall_dist_calc: float = 0.0 if Global.settings.prev_played == "space" else screen_size.x / 12
	var x_position = rng.randf_range(wall_dist_calc, screen_size.x - wall_dist_calc)
	falling_object.position = Vector2(x_position,
		player.position.y-(screen_size.y*0.6))

func spawn_window():
	var window_scene = preload("res://scenes/falling_objects/open_window.tscn")
	var window = window_scene.instantiate()
	add_child(window)
	var is_left_side: bool = rng.randf() > 0.5
	window.position.x = screen_size.x * (window.LEFT_OFFSET if is_left_side else window.RIGHT_OFFSET)
	window.position.y = player.position.y - (screen_size.y * 0.8)
	window.scale.x = window.SCALE if is_left_side else -window.SCALE
	window.z_index = 100

func update_game(delta: float):
	enemy.position.y -= speed
	Global.score = max(abs(player.position.y / 10), 0)
	#Move Wall Up 
	if abs(walls.position.y - player.position.y) < screen_size.y * 0.6:
			walls.position.y -= screen_size.y * 0.6
	#Limit Distance of Player to Bottom Enemy
	if abs(player.position.y) - abs(enemy.position.y) > screen_size.y * 0.9:
			#use interpolation for smooth 2d audio
			enemy.position.y = lerp(enemy.position.y, 
									player.position.y + (screen_size.y * 0.8), 
									delta)
	##Update speed of enemy the further you travel up
	#if speed < MAX_SPEED and Global.score > 0 and Global.score % 100 == 0 and !speed_updated:
	#	speed += 0.1
	#	speed_updated = true
	## Reset the speed_updated flag when Global.score is not a multiple of 10
	#if Global.score % 100 != 0:
	#	speed_updated = false

func start_game():
	if Input.is_action_just_pressed("jump"):
		hud.get_node("PauseMenu").hide()
		hud.get_node("Overlay").show()
		Engine.time_scale = 1
		game_running = true

func handle_death():
	bg_music.playing = false
	enemy.find_child("AudioStreamPlayer2D").playing = false
	for object in get_children():
		if object is FallingEnemy:
			object.despawn_self()
		if object is Timer:
			object.stop()
	speed = 0
