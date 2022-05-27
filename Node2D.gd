extends Node2D
onready var world1 = preload("res://world1.tscn").instance()
onready var player = preload("res://my_playet.tscn").instance()
onready var CL = preload("res://CanvasLayer.tscn").instance()
onready var border = $wallpaper
enum bomb_types {ROCKET,MINE,BAREL}
var tile_damage_radius = {bomb_types.ROCKET:100,bomb_types.MINE:200}

var damaged_tiles = {}
var world_1 = true
var rank = ""
var player_stats = {
				"hp" : 507,
				"rockets" : 23,	
				"score" : 0,
				"level" : 0,
				"difficulty": 0 
				}
var game_timer = 240.0
var game_canseled = false


func _ready():
	add_child(player)
	
	player.position = Vector2(-4490,850)
	player.hp = 507
	player.databoxes = 0
	player.rockets = 23
	add_child_below_node(border,world1)
	add_child(CL)
	CL.get_node("Label2").text = "Level : "+str(player_stats.level)
	CL.get_node("Timer").start()

func load_game(stage) :
	world_1 = true
	damaged_tiles = {}
	match stage :
		"new": 
			
			player_stats = {
				"hp" : 507,
				"rockets" : 23,	
				"score" : 0,
				"level" : 0,
				"difficulty": 0 
				}
			player.hp = 507
			player.rockets = 23
		"portal":
			player_stats.level += 1
			player_stats.score += player.databoxes*1500+player.hp+(player.rockets-23)*10+game_timer*10 + player_stats.level*100
			
			
			if player.hp < 507 :
				player_stats.hp = 507
				player.hp = 507
			else:
				player_stats.hp = player.hp
			if player.rockets < 23 :
				player_stats.rockets = 23
				player.rockets = 23
			else:
				player_stats.rockets = player.rockets
			CL.get_node("Label2").text = "Level : "+str(player_stats.level)
			CL.get_node("Timer").start()
	player.databoxes = 0  
	world1.map_generation()
	game_timer = 240.0
	player.position = Vector2(-4490,850)
	player.velocity = Vector2(0,0)
	player.rotation = 0
#		"next_level"
func _input(event):
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		game_pause()
		
#	if event.is_action_pressed("swap_worlds") and not event.is_echo():
#		if world_1 :
#			remove_child(world1)
#			add_child_below_node(border,world2)
#			world_1 = !world_1
#		else:
#			remove_child(world2)
#			add_child_below_node(border,world1)
#			world_1 = !world_1
func game_pause():
	if !game_canseled :
		game_canseled = true
		player.set_process_input(false)
		player.set_physics_process(false)
		$score_update.stop()
		CL.get_node("Label2").text = "PUSED\n"+ "ESC - continue"
	else :
		game_canseled = false
		player.set_process_input(true)
		player.set_physics_process(true)
		$score_update.start()
		CL.get_node("Label2").text = ""
		
func update_destructable(bomb_global_position,bomb_type) :
	
	var tile_map = world1.get_node("TileMap") 
	if !$explosion.playing :
		$explosion.play()
	for i in range(bomb_global_position.x-tile_damage_radius[bomb_type],
	bomb_global_position.x+tile_damage_radius[bomb_type],32) :
		for j in range(bomb_global_position.y+tile_damage_radius[bomb_type],
		bomb_global_position.y-tile_damage_radius[bomb_type],-32) :
			var cell = tile_map.world_to_map(Vector2(i,j))
			if cell in [Vector2(-141, 27),Vector2(-140, 27),Vector2(-139, 27),Vector2(-141, 26),Vector2(-140, 26),Vector2(-139, 26),Vector2(-141, 28),Vector2(-140, 28),Vector2(-139, 28)] :
				break
			if (bomb_global_position-Vector2(i,j)).length() < tile_damage_radius[bomb_type] and tile_map.get_cellv(cell)>=0:
				var index = 1000*(cell.y+1000)+cell.x
				if !damaged_tiles.has(index) :
					damaged_tiles[index] = 0
				damaged_tiles[index] += 1
				
				if damaged_tiles[index] >= 2 :
#					printt(">=2",index,cell)
					tile_map.set_cellv(cell,-1)
					damaged_tiles.erase(index)
					
				else :
					var v_index = tile_map.get_cell_autotile_coord(cell.x,cell.y)
					
					
					tile_map.set_cellv(cell,0,false,false,false,v_index+Vector2(0,9))
					

func do_damage(target,bomb,bomb_type):
	if target.is_in_group("player") :
		var target_direction = target.global_position - bomb.global_position
		var distance = target_direction.length()
		var damage = 3000/(1+distance)
		if distance > 300 :
			damage = 0
		var boom_speed = target_direction.rotated(-target.rotation).normalized()*damage*25
		var boom_damage = damage
		target.velocity += boom_speed 
		target.shock_wave = true
		target.hp -= boom_damage
#		printt(damage," damage ",boom_damage,"speed ", boom_speed.length())
	var explosion = load("res://explosion.tscn").instance()
	add_child(explosion)
	explosion.global_position = bomb.global_position 
	explosion.play()
					
					
#func end_level(reason) :
#	pass
#	print("gg")
#	player.get_node("sprite/Sprite").visible = 0 
#	player.get_node("sprite/Sprite/ass").visible = 0
#	player.set_process_input(false)
#	player.set_physics_process(false)
	


func _on_Timer_timeout():
	game_timer -= $score_update.wait_time
	var check = player_stats.score/(player_stats.level+5)
	rank = "absolute zero"
	if check > -19999 :
		rank = "hard loser"
	if check > -4999 :
		rank = "crooked-handed"	
	if check > -1999 :
		rank = "unskillful"
	if check > -999 :
		rank = "outsider"
	if check > -499 :
		rank = "amateur"
	if check >= 0 :
		rank = "on the border"
	if check >= 1000 :
		rank = "recruit"
	if check >= 2000 :
		rank = "novice"
	if check >= 3000 :
		rank = "copper"
	if check >= 4000 :
		rank = "bronze"
	if check >= 5000 :
		rank = "iron"
	if check >= 6000 :
		rank = "steel"
	if check >= 7000 :
		rank = "titanium"
	if check >= 8000 :
		rank = "date boxes singer"
	if check >= 10000 :
		rank = "rainbow rocket rider"
	if check >= 20000 :
		rank = "sorceress girl"

		
	var text = "A,D - move\n"
	text +=	"Space,W - jump\n"
	text +=	"L Mouse - rocket\n"
	text += "ESC - pause/unpause\n"
	text += "\n"
	text += "Rockets : "+str(player.rockets)+"\n"
	text += "HP : "+str(int(player.hp))+"\n"
	text += "Data boxes : "+str(player.databoxes)+"\n"
	text += "Time left: "+str(int(game_timer))+"\n"
	text += "Level : "+str(player_stats.level)+"\n"
	text += "SCORE : "+str(int(player_stats.score))+"\n"
	text += "Rank : " + rank+ "\n"
	text += "\n"
	text += "Main goal : Find 3 data boxes\n"
	text += "Evacuation : For exit find a cyan portal"
	CL.get_node("Label").text = text
	

#	проверим на границы  
	if player.position.x < - 6000 or player.position.x > 6000 or player.position.y < - 2500 or player.position.y > 2500 :
		player.position = Vector2(-4490,850)
		player.rotation = 0
		player.velocity = Vector2(0,0)
	


func _on_maby_player_timeout():
	if $looser.playing or $AFK.playing or $main_theme.playing or $impact.playing :
		return
	if player.databoxes == 3 and randi()%6 == 0 :
		$impact.play()
	elif game_timer <= 30 and game_timer > 0 :
		$AFK.play()
	elif  player.hp <= 100  or (player_stats.score<= 0 and randi()%5==0) or player.rockets <= 1 :
		$looser.play()
	elif randi()%3  == 0 :
		$main_theme.play()
		
		
		 
