extends Node

const PATH: String = "user://settings.json"
var score: int = 0
#var player_pos: Vector2 = Vector2.ZERO
#var bottom_enemy_pos: Vector2 = Vector2.ZERO
var player_died: bool = false
var settings: Dictionary = {
	"highscore" = {
		"cave" = 0,
		"city" = 0,
		"space" = 0,
	},
	"prev_played" = "city",
	"volume" = {
		"master" = {
			"value" = 1,
			"muted" = false
		},
		"music" = {
			"value" = 1,
			"muted" = false
		},
		"sound" = {
			"value" = 1,
			"muted" = false
		},
		"ui" = {
			"value" = 1,
			"muted" = false
		}
	}
}

func save(reset: bool = false):
	if reset:
		settings.highscore.city = 0
		settings.highscore.cave = 0
		settings.highscore.space = 0
	var file = FileAccess.open(PATH,FileAccess.WRITE)
	file.store_string(JSON.stringify(settings))
	file.close()

func load():
	if not FileAccess.file_exists(PATH):
		save()
	var file = FileAccess.open(PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	#settings = data
	settings.highscore = data.highscore
	settings.prev_played = data.prev_played
	settings.volume = data.volume
	file.close()
