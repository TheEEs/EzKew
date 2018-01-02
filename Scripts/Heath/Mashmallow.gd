extends KinematicBody2D

var falling_vector = Vector2(0,1)
var speed = 14
onready var anim = get_node("anim")
var time_to_live = clamp(randi() % 11,3,10)
var time = 0
func _ready():
	set_fixed_process(true)
	anim.play("appearance")

func _fixed_process(delta):
	time += delta
	if time >= self.time_to_live:
		anim.play("appearance")
		self.queue_free()
	self.move(self.falling_vector * delta * speed)
