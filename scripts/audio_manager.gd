extends Node

const SELECT:= preload("res://assets/sounds/select.mp3")
const BUS_NAMES: Dictionary = {
	0: "master",
	1: "music",
	2: "sound",
	3: "ui",
}

func set_audio_from_file(slider: HSlider, check: CheckBox, bus: int,
volume: float, muted: bool):
	slider.value = volume
	AudioServer.set_bus_volume_db(bus, linear_to_db(volume))
	check.button_pressed = muted
	AudioServer.set_bus_mute(bus, muted)

func set_volume(bus: int, value: float):
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	var bus_name: String = BUS_NAMES[bus]
	Global.settings.volume[bus_name].value = value

func mute_bus(bus: int):
	AudioServer.set_bus_mute(bus, !AudioServer.is_bus_mute(bus))
	var bus_name: String = BUS_NAMES[bus]
	Global.settings.volume[bus_name].muted = !Global.settings.volume[bus_name].muted


func play_select(requester: Node):
	if is_node_visible(requester):
			var instance = AudioStreamPlayer.new()
			instance.stream = SELECT
			instance.bus = "UI"
			instance.volume_db = -10
			instance.finished.connect(remove_node.bind(instance))
			add_child(instance)
			instance.play()
			await instance.finished

func remove_node(instance: AudioStreamPlayer):
	instance.queue_free()

#Check if parent and ancestors are visible
func is_node_visible(node: Node):
	while node != null:
		if not node.visible:
			return false
		node = node.get_parent()
	return true
