extends Control

@onready var MASTER_AUDIO_BUS = AudioServer.get_bus_index("Master")
@onready var MUSIC_AUDIO_BUS = AudioServer.get_bus_index("Music")
@onready var SFX_AUDIO_BUS = AudioServer.get_bus_index("SFX")
@onready var UI_AUDIO_BUS = AudioServer.get_bus_index("UI")

@onready var animation_player = $AnimationPlayer
@onready var bg_blur = $Blur
@onready var popup = $Popup
@onready var popup_blur = $PopupBlur
@onready var master = $PanelContainer/MarginContainer/VBoxContainer/Volume/Sliders/MasterSlider
@onready var music = $PanelContainer/MarginContainer/VBoxContainer/Volume/Sliders/MusicSlider
@onready var sound = $PanelContainer/MarginContainer/VBoxContainer/Volume/Sliders/SoundSlider
@onready var ui = $PanelContainer/MarginContainer/VBoxContainer/Volume/Sliders/UI
@onready var master_check = $PanelContainer/MarginContainer/VBoxContainer/Volume/CheckBoxes/MasterCheck
@onready var music_check = $PanelContainer/MarginContainer/VBoxContainer/Volume/CheckBoxes/MusicCheck
@onready var sound_check = $PanelContainer/MarginContainer/VBoxContainer/Volume/CheckBoxes/SoundCheck
@onready var ui_check = $PanelContainer/MarginContainer/VBoxContainer/Volume/CheckBoxes/UICheck

func _ready():
	Global.load()
	AudioManager.set_audio_from_file(music, music_check, MUSIC_AUDIO_BUS,
		Global.settings.volume.music.value, Global.settings.volume.music.muted)
	AudioManager.set_audio_from_file(sound, sound_check, SFX_AUDIO_BUS,
		Global.settings.volume.sound.value, Global.settings.volume.sound.muted)
	AudioManager.set_audio_from_file(master, master_check, MASTER_AUDIO_BUS,
		Global.settings.volume.master.value, Global.settings.volume.master.muted)
	AudioManager.set_audio_from_file(ui, ui_check, UI_AUDIO_BUS,
		Global.settings.volume.ui.value, Global.settings.volume.ui.muted)
	popup.hide()
	popup_blur.hide()
	hide()
	get_tree().paused = false
	
func _on_close_pressed():
	AudioManager.play_select(self)
	Global.save()
	close_popup()
	if find_parent("MainMenu") == null:
		get_parent().get_node("PauseMenu").show()
	hide()

#Volume Sliders
func _on_master_value_changed(value: float):
	AudioManager.play_select(self)
	AudioManager.set_volume(MASTER_AUDIO_BUS, value)
func _on_music_value_changed(value: float):
	AudioManager.play_select(self)
	AudioManager.set_volume(MUSIC_AUDIO_BUS, value)
func _on_sound_value_changed(value: float):
	AudioManager.play_select(self)
	AudioManager.set_volume(SFX_AUDIO_BUS, value)
func _on_ui_value_changed(value):
	AudioManager.play_select(self)
	AudioManager.set_volume(UI_AUDIO_BUS, value)
	
#Volume Mute CheckMarks
func _on_master_check_pressed():
	AudioManager.mute_bus(MASTER_AUDIO_BUS)
	if find_parent("MainMenu") == null:
		#update mute button texture
		get_owner().find_child("Mute").button_pressed = AudioServer.is_bus_mute(MASTER_AUDIO_BUS)
	AudioManager.play_select(self)
func _on_music_check_pressed():
	AudioManager.mute_bus(MUSIC_AUDIO_BUS)
	AudioManager.play_select(self)
func _on_sound_check_pressed():
	AudioManager.mute_bus(SFX_AUDIO_BUS)
	AudioManager.play_select(self)
func _on_ui_check_pressed():
	AudioManager.mute_bus(UI_AUDIO_BUS)
	AudioManager.play_select(self)
	
#Reset Highscore (PopUp)
func _on_reset_pressed():
	AudioManager.play_select(self)
	popup_blur.show()
	popup.show()
	bg_blur.hide()
func close_popup():
	AudioManager.play_select(self)
	bg_blur.show()
	popup.hide()
	popup_blur.hide()
func _on_close_popup_pressed():
	close_popup()
func _on_cancel_pressed():
	close_popup()
func _on_reset_2_pressed():
	Global.save(true)
	Global.load()
	if find_parent("MainMenu") != null: #reset highscore text
		find_parent("MainMenu")._ready()
	close_popup()






