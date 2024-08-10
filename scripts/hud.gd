extends CanvasLayer

const COUNTDOWN : int = 3
@onready var options = $Options
@onready var replay_menu = $ReplayMenu
@onready var score_container = $ReplayMenu/ScoreContainer
@onready var overlay = $Overlay
@onready var pause_menu = $PauseMenu
@onready var resume_timer = $PauseMenu/ResumeTimer
@onready var resume_countdown = $PauseMenu/ResumeCountdown
@onready var pause_options = $PauseMenu/VBoxContainer
@onready var bg_music = $BgMusic
@onready var music_fade = $BgMusic/MusicFade
@onready var death_handled: bool = false

func _ready():
	Global.load()
	pause_options.hide()
	if Global.settings.volume.master.muted:
		overlay.get_node("Mute").button_pressed = true
		
func _process(_delta):
	overlay.get_node("Score").text= "Score: " + str(Global.score)
	if Input.is_action_just_pressed("esc"):
		pause()
	if Global.player_died:
		if not death_handled:
			death_handled = true
			show_replay_menu()

#Shared Functions
func replay():
	AudioManager.play_select(self)
	get_tree().reload_current_scene()
func menu():
	AudioManager.play_select(self)
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")
func resume():
	get_tree().paused = false
	overlay.show()
	pause_menu.hide()
func pause():
	AudioManager.play_select(self)
	music_fade.play("fade_in")
	overlay.hide()
	pause_menu.get_node("Begin").hide()
	resume_countdown.hide()
	#pause_transition.play("blur")
	pause_menu.get_node("PausedLabel").show()
	pause_options.show()
	pause_menu.show()
	get_tree().paused = true
	
#Overlay Functions
func _on_pause_pressed():
	pause()
func _on_mute_pressed():
	AudioServer.set_bus_mute(0, !AudioServer.is_bus_mute(0))
	Global.settings.volume.master.muted = !Global.settings.volume.master.muted
	Global.save()

#PauseMenu Functions
func _on_resume_pressed():
	AudioManager.play_select(self)
	pause_options.hide()
	resume_countdown.text = str(COUNTDOWN)
	resume_countdown.show()
	resume_timer.start(1.0) 
	music_fade.play("fade_out")
func _on_resume_timer_timeout():
	var remaining_time := int(resume_countdown.text) - 1
	if remaining_time <= 0:
		resume_timer.stop()
		resume()
	AudioManager.play_select(self)
	resume_countdown.text = str(remaining_time)
func _on_options_pressed():
	AudioManager.play_select(self)
	pause_menu.hide()
	options.show()
	options.get_node("AnimationPlayer").play("blur")
func _on_restart_pressed():
	replay()
func _on_quit_pressed():
	menu()

#ReplayMenu Functions
func show_replay_menu():
	overlay.hide()
	score_container.get_node("Score").text = "Score: " +str(Global.score)
	replay_menu.show()
	replay_menu.get_node("BtnContainer/AnimationPlayer").play("fade")
	if Global.score > Global.settings.highscore.get(Global.settings.prev_played):
		score_container.get_node("HS").show()
		Global.settings.highscore[Global.settings.prev_played] = Global.score
		Global.save()
		score_container.get_node("HS/HS_Audio").play()
	else:
		music_fade.play("fade_in")
func _on_menu_pressed():
	menu()
func _on_replay_pressed():
	replay()
func _on_hs_audio_finished():
	music_fade.play("fade_in")
