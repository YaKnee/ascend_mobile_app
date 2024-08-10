extends StaticBody2D

#const POS_LEFT: float = 14.5
#const POS_RIGHT: float = 345.5
const RIGHT_OFFSET: float = 0.959722 #pos_right / screen width
const LEFT_OFFSET: float = 0.040277 #pos_left / screen width
const SCALE: float = 2.19

@onready var bottom_enemy: Node2D = get_parent().get_node("BottomEnemy")
@onready var sprite = $AnimatedSprite2D
var emerging: bool = false
var retreating: bool = false

func _process(_delta):
	if position.y > bottom_enemy.position.y + get_viewport_rect().size.y:
		queue_free()

func _on_detect_area_body_entered(body):
	if body is Player:
		sprite.play("emerge")
		await sprite.animation_finished
		sprite.play("idle")

func _on_detect_area_body_exited(body):
	if body is Player:
		await sprite.animation_finished
		sprite.play("retreat")
		await sprite.animation_finished
		sprite.play("fall")

func disable_collision():
	get_node("Killzone/CollisionShape2D").disabled = true
	
func _on_killzone_body_entered(body):
	if body is Player:
		call_deferred("disable_collision")
		sprite.play("crash")
		get_node("AudioStreamPlayer").play()
		await sprite.animation_finished
		sprite.play("mile_long_stare")
		
