extends KinematicBody2D
var bomb = preload("res://bomb.tscn")
export (int) var speed = 10
export (int) var jump_speed = -350
export (int) var gravity = 400

var snap = Vector2(0,0)
var velocity = Vector2(0,0) setget set_velocity 
var is_jumping = false
var shock_wave = false

var databoxes = 0 
var hp = 507.0 setget set_hp
var rockets = 23

func set_velocity(value):
	if value == Vector2(0,0) :
		$footstep.stop()
	elif is_on_floor() and !$footstep.playing :
		$footstep.play()
	velocity = value
	
func set_hp(value) :
	hp = value
	if value < 0 :
		var my_paren = get_parent()
		my_paren.game_pause()
		my_paren.CL.get_node("Label2").text = "GOOD GAME!\n"
		var text = "A,D - move\n"
		text +=	"Space,W - jump\n"
		text +=	"L Mouse - rocket\n"
		text += "ESC - pause\n"
		text += "\n"
		text += "Rockets : "+str(rockets)+"\n"
		text += "HP : "+str(int(hp))+"\n"
		text += "Data boxes : "+str(databoxes)+"\n"
		text += "Time left: "+str(int(my_paren.game_timer))+"\n"
		text += "Level : "+str(my_paren.player_stats.level)+"\n"
		text += "SCORE : "+str(int(my_paren.player_stats.score))+"\n"
		text += "Rank : " + my_paren.rank+ "\n"
		text += "\n"
		text += "Main goal : Find 3 data boxes\n"
		text += "Evacuation : For exit find a cyan portal"
		my_paren.CL.get_node("Label").text = text
			
		my_paren.load_game("new")
		pass
	
		


func get_input():
	var dir = 0
	
	if Input.is_action_pressed("right"):
		dir = 1
		$sprite.scale.x = 1
		if velocity.x<300 :
			self.velocity.x += speed*dir
	elif Input.is_action_pressed("left"):
		dir = -1
		$sprite.scale.x = -1
		if velocity.x>-300 :
			self.velocity.x += speed*dir
# когда стоит на поверхности он  не должен по ней ехать  или двигаться если 
# не нажаты кнопки 
# но если shock_wave = true, значит его долбануло ударной волной от взрыва и 
# 1 фрейм он может поменять свою скорость
	if dir == 0 and  is_on_floor() and !shock_wave:
#	if dir == 0 and velocity.length() <100 and is_on_floor():
		self.velocity = Vector2(0,0)
		
	else :
		shock_wave = false 
#		velocity.x += speed*dir
	var local_mouse_position = $sprite/Sprite.get_local_mouse_position()
	$sprite/Sprite/ass.rotation = local_mouse_position.angle()
	if Input.is_action_just_released("ui_accept"):
		if rockets > 0 : 
			rockets -= 1
			var bomb_instance = bomb.instance()
			var direction = get_global_mouse_position() - $sprite/Sprite/ass.global_position
			 
			bomb_instance.direction = direction.normalized()*10
			bomb_instance.position = position
			get_parent().add_child(bomb_instance)

func _physics_process(delta):
	get_input()
#	velocity.y += gravity * delta
	
#	velocity = velocity.rotated(-rotation)
##
#	if transform.get_rotation() < 0: 
#		transform.rotated(360)
	if Input.is_action_just_released("ui_jump") and is_on_floor() :
			is_jumping = true
			$footstep.stop()
			self.velocity.y += jump_speed
			var sound_jump = get_parent().get_node("jump")
			if !sound_jump.playing :
				sound_jump.play()
				
	if is_on_floor() :
		rotation = get_floor_normal().angle() + PI/2
		is_jumping = false
	else : 
		self.velocity.y += gravity * delta
#		
#	else:
	
	
	snap = transform.y.normalized()*4 #if !is_jumping else Vector2.ZERO
	velocity = move_and_slide_with_snap(velocity.rotated(rotation), snap, -transform.y, false, 2, PI, false)
	self.velocity = velocity.rotated(-rotation)
	
	
