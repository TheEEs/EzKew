extends KinematicBody2D
onready var sprite = get_node("./anim-sprite")
var random_sprite = [
	"pinkfish",
	"greenfish"
]
var X_axis_vector = Vector2(1,0)
var viewport_width = Globals.get("display/width")
export(Vector2) var swim_direction = Vector2(1,1)
export(int) var speed = 142
var player

var sprite_size = Vector2(57,44)
onready var viewport_rectangle = Rect2( - sprite_size.x, -sprite_size.y,
	Globals.get("display/width") + sprite_size.x * 2,
	Globals.get("display/height") + sprite_size.y * 2)


func _ready():
	randomize()
	swim_direction = swim_direction.normalized()
	sprite.set_animation(self.random_sprite[
		int(randf() * 10) % 2
	])
	
func _fixed_process(delta):
	var position = get_global_pos()
	if not viewport_rectangle.has_point(position):
		#player.gain_score()
		queue_free()
	self.move(self.swim_direction * self.speed * delta)
	
func set_direction_and_look_at(player_location):
	var my_pos = self.get_global_pos();
	var swimming_direction = (player_location - my_pos).normalized()
	self.swim_direction = swimming_direction
	var radian_between_me_and_player = my_pos.angle_to_point(player_location)
	if(swimming_direction.x > 0):
		sprite.set_flip_h(true)
		sprite.set_rot(radian_between_me_and_player + deg2rad(90))
	else:
		sprite.set_rot(radian_between_me_and_player - deg2rad(90))
	set_fixed_process(true)
		
func set_player(player):
	self.player = player