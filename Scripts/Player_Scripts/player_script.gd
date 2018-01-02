extends KinematicBody2D
var random_anim_sprite = [
	"yellow",
	"green",
	"blue",
	"pink"
]

var hurt_sprite = [
	preload("res://Resources/Sprites/Alien sprites/alienYellow_hurt.png"),
	preload("res://Resources/Sprites/Alien sprites/alienGreen_hurt.png"),
	preload("res://Resources/Sprites/Alien sprites/alienBlue_hurt.png"),
	preload("res://Resources/Sprites/Alien sprites/alienPink_hurt.png")
]
onready var start_button = get_node("./start_panel/start_button")
onready var gain5point = get_node("./+5point/gain5point")
onready var ui_score_label = get_node('./UI control').get_node("score_label")
onready var score_label = get_node("./score_label")
onready var window_width = Globals.get("display/width")
onready var window_height = Globals.get("display/height")
onready var anim_player= get_node('./player-animation')
export(float) var speed = 145
onready var hurt  = get_node('./hurt')
export(float) var create_enemies_interval = 0.4
var interval = 2
export(float) var max_acceleration = 300
var acceleration = 0
var elixirs = 0
export(int) var maximum_enemies = 4 + 9
export(int) var minimum_enemies = 9-4
export(float,0,1) var acceleration_proportion = 0.489
var real_acceleration = acceleration
var ui_score_text = "Score: %d"
onready var sprite  = get_node("./spite_swimming")
const up_direction = Vector2(0,-1)
const down_direction = Vector2(0,1)
const left_direction = Vector2(-1,0)
const right_direction = Vector2(1,0)
const idle_direction = Vector2(0,0)
const sprite_size = Vector2(70,87) * 0.9 #0.9 is the scale proportion of the spite
var heath 
const MAX_HEATH = 2
var score = 0
var INC_HEATH = 1
var DEC_HEATH = 1
var direction;
export(int,2,20) var create_mashmallow_interval = 17
var fish_enemy = preload("res://Scenes/Enemy/Fish.tscn")
var mash_mallow = preload("res://Scenes/Heath/Mashmallow.tscn")
var mlw_interval = 0

func _ready():
	heath = MAX_HEATH
	#randomize()
	self.maximum_enemies += 1
	score_label.set_text(str(self.heath))
	var random_sprite = int(randf()* 10) % 4;
	sprite.set_animation(self.random_anim_sprite[random_sprite])
	hurt.set_texture(hurt_sprite[random_sprite])
	self.direction = idle_direction;
	anim_player.get_animation("floating").set_loop(true)
	anim_player.play("floating")
	self.set_global_pos(Vector2(window_width / 2,window_height / 2))
	sprite.set_flip_h(false)
	sprite.set_flip_v(false)
	self.score = 0
	ui_score_label.set_text(ui_score_text % [0])
	
	#set_fixed_process(true)
	#set_process_input(true)
	
func _fixed_process(delta):
	interval += delta; mlw_interval += delta
	if interval >= self.create_enemies_interval:
		interval = 0.0
		var number_of_enemies = clamp(randi() % maximum_enemies, self.minimum_enemies, self.maximum_enemies)
		for iter in range(number_of_enemies):
			create_fish()
	if (interval - int(interval) == 0):
		gain_score()
	if mlw_interval >= create_mashmallow_interval:
		self.create_mashmallow()
		mlw_interval = 0
	var global_pos = self.get_global_pos()
	if Input.is_key_pressed(KEY_SPACE):
		self.acceleration = clamp(self.acceleration + 5 ,0,self.max_acceleration)
		if self.acceleration == self.max_acceleration : 
			self.real_acceleration = 0
		else:
			if self.acceleration >=  self.max_acceleration * self.acceleration_proportion:
				if real_acceleration != self.acceleration:
					self.elixirs -= 1
				self.real_acceleration = self.acceleration
	else:
		self.real_acceleration = 0
		self.acceleration = 0#clamp(self.acceleration -  2,0,self.max_acceleration)
	if self.direction == self.left_direction and global_pos.x < self.sprite_size.x /2 :
		#hit the left egde
		turn_right()
	elif self.direction == self.right_direction and global_pos.x > window_width - sprite_size.x /2:
		#hit the right egde
		turn_left()
	elif self.direction == self.up_direction and global_pos.y < sprite_size.y /2 :
		dive()
	elif self.direction == self.down_direction and global_pos.y > window_height - sprite_size.y /2:
		move_up()
	self.move(self.direction * (self.speed + real_acceleration)  * delta)
		
func _input(event):
	if event.is_action("swimming_down"):
		dive()
	elif event.is_action("swimming_up"):
		move_up()
	elif event.is_action("swimming_left"):
		turn_left()
	elif event.is_action("swimming_right"):
		turn_right()
	#self.direction = self.idle_direction


func turn_left():
	sprite.set_flip_v(false)
	sprite.set_flip_h(true)
	hurt.set_flip_h(true)
	hurt.set_flip_v(false)
	self.direction = self.left_direction;
func turn_right():
	sprite.set_flip_v(false)
	sprite.set_flip_h(false)
	hurt.set_flip_h(false)
	hurt.set_flip_v(false)
	self.direction = self.right_direction;
func move_up():
	self.direction = self.up_direction;
	sprite.set_flip_v(false)
	hurt.set_flip_v(false)
func dive():
	self.direction = self.down_direction;
	sprite.set_flip_v(true)
	hurt.set_flip_v(true)
	
func create_default_enemy_position():
	#0 is top
	#1 is right
	#2 is bottom
	#3 is left
	var side = randi() % 11 % 4
	var random_width = rand_range(0,window_width)
	var random_height = rand_range(0,window_height)
	if side == 0 :
		return Vector2(random_width,0)
	elif side == 1:
		return Vector2(window_width,random_height)
	elif side == 2:
		return Vector2(random_width,window_height)
	elif side == 3:
		return Vector2(0,random_height)
	
func create_mashmallow():
	var mlw = mash_mallow.instance()
	var random_left = window_width * randf()
	var random_top = window_height * randf()
	mlw.set_global_pos(Vector2(random_left,random_top))
	get_tree().get_root().add_child(mlw) 
	
func create_fish():
	var fish = fish_enemy.instance()
	fish.set_global_pos(create_default_enemy_position())
	get_tree().get_root().add_child(fish)
	fish.set_direction_and_look_at(self.get_global_pos())
	fish.set_player(self)

	

func hit_something( body ):
	if body.is_in_group('enemies'):
		hurt.show()
		sprite.hide()
		self.lose_score()
	elif body.is_in_group('heath'):
		self.heath = clamp(self.INC_HEATH + self.heath,0,self.MAX_HEATH)
		self.gain_score(5)
		gain5point.play("gain5point")
		body.queue_free()
		


func exit_enemy( body ):
	if body.is_in_group("enemies"):
		hurt.hide()
		sprite.show()
		
func gain_score(score_ = 1):
	#self.heath = clamp(self.INC_HEATH + self.heath,0,self.MAX_HEATH)
	self.score += score_
	ui_score_label.set_text(self.ui_score_text % [self.score])
	score_label.set_text(str(round(self.heath)))
	
func lose_score():
	self.heath -= self.DEC_HEATH 
	if self.heath < 0:
		set_fixed_process(false)
		set_process_input(false)
		for node in get_tree().get_nodes_in_group("enemies"):
			node.set_fixed_process(false)
		score_label.set_text("I'm a loser")
		start_button.show()
		return 
	score_label.set_text(str(self.heath))


func start_game():
	randomize()
	self.set_fixed_process(true)
	self.set_process_input(true)
	for node in get_tree().get_nodes_in_group("enemies"):
			node.queue_free()
	for node in get_tree().get_nodes_in_group("heath"):
			node.queue_free()
	self._ready()
	start_button.hide()