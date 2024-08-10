extends CanvasLayer

const CITY_PREVIEW := preload("res://assets/video/city.ogv")
const CAVE_PREVIEW := preload("res://assets/video/cave.ogv")
const SPACE_PREVIEW := preload("res://assets/video/space.ogv")

@onready var MASTER_AUDIO_BUS = AudioServer.get_bus_index("Master")
@onready var MUSIC_AUDIO_BUS = AudioServer.get_bus_index("Music")
@onready var SFX_AUDIO_BUS = AudioServer.get_bus_index("SFX")
@onready var options = $Options
@onready var menu = $Menu
@onready var highscore_text = $Menu/VBoxContainer/HS
@onready var preview = $CanvasLayer/Preview
@onready var city = $Menu/City
@onready var cave = $Menu/Cave
@onready var space = $Menu/Space
@onready var scene: String = Global.settings.prev_played

var loading: bool = true

func _ready():
	Global.load()
	update_scene_info(scene)
	loading = false

		
func _on_play_pressed():
	AudioManager.play_select(self)
	Global.settings.prev_played = scene
	Global.save()
	get_tree().change_scene_to_file("res://scenes/levels/%s_scene.tscn" % scene)
	
func _on_options_pressed():
	AudioManager.play_select(self)
	options.show()
	options.get_node("AnimationPlayer").play("blur")

func _on_city_toggled(toggled_on):
	scene_toggled(toggled_on, "city", CITY_PREVIEW)

func _on_cave_toggled(toggled_on):
	scene_toggled(toggled_on, "cave", CAVE_PREVIEW)

func _on_space_toggled(toggled_on):
	scene_toggled(toggled_on, "space", SPACE_PREVIEW)

func scene_toggled(toggled_on, new_scene, video):
	preview.stream = video
	preview.play()
	if toggled_on and not loading:
		AudioManager.play_select(self)
		scene = new_scene
		update_scene_info(new_scene)

func update_scene_info(new_scene):
	highscore_text.text = str(Global.settings.highscore[new_scene])
	var button = get_node("Menu/" + new_scene.capitalize())
	button.button_pressed = true
