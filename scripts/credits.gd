extends Control

@onready var scroll_container = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer
@onready var credits_container = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/CreditsContainer
@onready var reset_timer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/CreditsContainer/ResetTimer
@onready var auto_scroll_timer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/CreditsContainer/AutoScrollTimer

const MAX_SCROLL_HEIGHT: int = 1415
const AUTO_SCROLL_SPEED: int = 60  # Pixels per second

var is_autoscroll: bool = false  # Flag for auto-scrolling

func _ready():
	# Ensure the scroll starts at the top of the credits
	scroll_container.scroll_vertical = 0
	set_process(false)  # Stop processing until visible

func _process(delta):
	if is_autoscroll:
		# Auto-scroll logic
		scroll_container.scroll_vertical += AUTO_SCROLL_SPEED * delta
		
		# Check if scroll container has reached the bottom
		if scroll_container.scroll_vertical >= MAX_SCROLL_HEIGHT:
			reset_timer.start(3.0)
			is_autoscroll = false

func _on_visibility_changed():
	# Start auto-scroll 2 seconds after becoming visible
	if visible:
		scroll_container.scroll_vertical = 0  # Reset scroll to top
		auto_scroll_timer.start(2.0)
		set_process(true)  # Enable processing
	else:
		set_process(false)  # Disable processing when not visible
	
func _on_close_pressed():
	visible = false
	
func _on_scroll_container_gui_input(event):
# Detect user scrolling and pause auto-scroll
	if event is InputEventMouseMotion or event is InputEventPanGesture or event is InputEventScreenDrag:
		if reset_timer.is_stopped():  # Don't pause if reset is already happening
			is_autoscroll = false
			auto_scroll_timer.start(2.0)  # Pause for 2 seconds before resuming auto-scroll

func _on_reset_timer_timeout():
# Reset to the top and allow auto-scroll to resume
	scroll_container.scroll_vertical = 0
	is_autoscroll = false  # Stop auto-scrolling temporarily
	auto_scroll_timer.start(2.0)  # Wait 2 seconds before resuming
	reset_timer.stop()  # Ensure the timer stops cleanly

func _on_auto_scroll_timer_timeout():
	# Auto-scroll resumes automatically when timer ends
	is_autoscroll = true
	auto_scroll_timer.stop()
	
func _on_yaknee_meta_clicked(_meta):
	OS.shell_open("https://yaknee.github.io")
	
func _on_zegley_meta_clicked(_meta):
	OS.shell_open("https://zegley.itch.io/2d-platformermetroidvania-asset-pack")

func _on_lava_meta_clicked(_meta):
	OS.shell_open("https://dribbble.com/shots/2303888-Lava-Animation")

func _on_cat_meta_clicked(_meta):
	OS.shell_open("https://pop-shop-packs.itch.io/")

func _on_raph_meta_clicked(_meta):
	OS.shell_open("https://ragnapixel.itch.io/particle-fx")

func _on_main_meta_clicked(_meta):
	OS.shell_open("https://www.fesliyanstudios.com/royalty-free-music/download/funny-bit/2399")

func _on_option_meta_clicked(_meta):
	OS.shell_open("https://pixabay.com/music/video-games-waiting-time-175800/")

func _on_city_meta_clicked(_meta):
	OS.shell_open("https://pixabay.com/sound-effects/026491-pixel-song-8-72675/")

func _on_cave_meta_clicked(_meta):
	OS.shell_open("https://rustedstudio.itch.io/free-music-10-spooky-8bit-tracks")

func _on_space_meta_clicked(_meta):
	OS.shell_open("https://www.pond5.com/royalty-free-music/item/154774154-space-8-bit-classic-video-game")

func _on_highscore_meta_clicked(_meta):
	OS.shell_open("https://pixabay.com/sound-effects/winsquare-6993/")

func _on_climber_meta_clicked(_meta):
	OS.shell_open("https://pixabay.com/sound-effects/male-death-sound-128357/")

func _on_cat_meow_meta_clicked(_meta):
	OS.shell_open("https://pixabay.com/sound-effects/mjau3-82957/")

func _on_cat_slash_meta_clicked(_meta):
	OS.shell_open("https://pixabay.com/sound-effects/slashkut-108175/")





