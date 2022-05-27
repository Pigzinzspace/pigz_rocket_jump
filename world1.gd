extends Node2D
enum direction {UP=-1,DOWN=1}
enum sides {S=0,W=1,N=2,E=3}
onready var item = preload("res://item.tscn")
onready var mine = preload("res://infantry_mine.tscn")
var spawn_points = {}


var tile_map_top_left = Vector2(-150,-45)
#var tile_map_bot_right = Vector2(245,29)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var spawn_plane = {
	"databox" : 3,
	"mine": 25,
	"rocket": 2,
	"medpack": 2,
	"door" : 1
}
 
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	map_generation()
	
	pass # Replace with function body.


#func _input(event) :
#	if event.is_action_released("ui_select") :
#		map_generation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func map_generation() :
	spawn_points = {}
	
	clear_items_mines()
	$TileMap.clear()
	
# выбираем щаблон для дома
	var sectio_pattern = {
		0: [Vector2(0,0),Vector2(1,0),Vector2(1,0),Vector2(1,0),Vector2(1,0),Vector2(2,0)],
		1: [Vector2(0,1),Vector2(0,3),Vector2(1,3),Vector2(1,3),Vector2(2,3),Vector2(2,1)],
		2: [Vector2(0,1),Vector2(0,4),Vector2(1,4),Vector2(1,4),Vector2(2,4),Vector2(2,1)],
		3: [Vector2(0,1),Vector2(0,5),Vector2(1,5),Vector2(1,5),Vector2(2,5),Vector2(2,1)],
		4: [Vector2(0,2),Vector2(1,2),Vector2(1,2),Vector2(1,2),Vector2(1,2),Vector2(2,2)]
	}
	
##страшный цикл делает бордюрчик вокруг уровня
#	for l in [-50,40]:
#		for k in range(-150,150,6):
#			var test_offset = Vector2(k,l)
#			for i in sectio_pattern.size() :
#				for j in sectio_pattern[0].size() :
#					$TileMap.set_cellv(test_offset+Vector2(j,i),0,false,false,false,sectio_pattern[i][j])
#
#	for l in range(-50,45,5):
#		for k in [-155,150]:
#			var test_offset = Vector2(k,l)
#			for i in sectio_pattern.size() :
#				for j in sectio_pattern[0].size() :
#					$TileMap.set_cellv(test_offset+Vector2(j,i),0,false,false,false,sectio_pattern[i][j])
#	printt(sectio_pattern.size(),sectio_pattern[0].size())
# это рисует на карте респаун 
	$TileMap.set_cellv(Vector2(-141, 26),0,false,false,false,Vector2(0,6))
	$TileMap.set_cellv(Vector2(-140, 26),0,false,false,false,Vector2(1,6))
	$TileMap.set_cellv(Vector2(-139, 26),0,false,false,false,Vector2(2,6))
	$TileMap.set_cellv(Vector2(-141, 27),0,false,false,false,Vector2(0,7))
	$TileMap.set_cellv(Vector2(-140, 27),0,false,false,false,Vector2(1,7))
	$TileMap.set_cellv(Vector2(-139, 27),0,false,false,false,Vector2(2,7))
	$TileMap.set_cellv(Vector2(-141, 28),0,false,false,false,Vector2(0,8))
	$TileMap.set_cellv(Vector2(-140, 28),0,false,false,false,Vector2(1,8))
	$TileMap.set_cellv(Vector2(-139, 28),0,false,false,false,Vector2(2,8))
	
# создает дома
	for  i in 10 :
		set_bilding(tile_map_top_left.x+i*30,tile_map_top_left.y,direction.DOWN,sectio_pattern)
	for i in 9 :
		set_bilding(tile_map_top_left.x+i*30+15,tile_map_top_left.y+85,direction.UP,sectio_pattern)
#создвет все интерактивные объекты
	spawn_all() 
	
func set_bilding(offset_x,offset_y, direct,sectio_pattern):
	var columns = 2+randi()%3
	var rows = 5+randi()%3
	var start_offset_y = offset_y+randi()%4*direct*2  
	if direct == direction.UP :
		start_offset_y -= rows*sectio_pattern.size()
	
#нам нужны тайлы над верхним рядом, под нижним, перед первой колонкой и после последней если они не выходят за границы
# чтоб они все были строго положительными  и это все нормально работало значения точек увеличено на 500  
	var out_of_x = offset_x+columns*sectio_pattern[0].size()
	var out_of_y = start_offset_y + rows*sectio_pattern.size()
	for i in range(offset_x-1,out_of_x+1) :
		if start_offset_y-1 < 45 and start_offset_y-1 > -45 and i < 150 and i > -150 :
#мы записываем в значение ячейки сторону с которой находится пол, чтоб интерактивный объект понял где у него низ 
			spawn_points[(start_offset_y-1+500)*1000+i+500] = sides.S
	for i in range(offset_x-1,out_of_x+1) :
		if out_of_y < 45 and out_of_y > -45 and i < 150 and i > -150 :
			spawn_points[(out_of_y+500)*1000+i+500] = sides.N
	for i in range(start_offset_y,out_of_y) :
		if i < 45 and i > -45 and offset_x-1 < 150 and offset_x-1 > -150 :
			spawn_points[(i+500)*1000+offset_x-1+500] = sides.E
	for i in range(start_offset_y,out_of_y) :
		if i < 45 and i > -45 and out_of_x < 150 and out_of_x > -150 :
			spawn_points[(i+500)*1000+out_of_x+500] = sides.W
	
#	for i in spawn_points.keys() :
#		$TileMap.set_cellv(Vector2(int(i)%1000-500,int(i)/1000-500),0,false,false,false,sectio_pattern[1][1])
	
	
	
	for i in columns:
		for j in rows: 
			var start_tile = Vector2(offset_x+i*sectio_pattern[0].size(),start_offset_y+j*sectio_pattern.size())
			set_section(direct,sectio_pattern,start_tile)  
#			printt(start_tile,i,)
	
	
		
		
#она рисует секцию дома которую задает словарь sectio_pattern 
func set_section(direct,sectio_pattern,start_tile) :
#	if direct == direction.UP : 
#		start_tile+=Vector2(0,-sectio_pattern.size())
	for i in sectio_pattern.size() :
		for j in sectio_pattern[0].size() :
			$TileMap.set_cellv(start_tile+Vector2(j,i),0,false,false,false,sectio_pattern[i][j])
			
func spawn_all() :	
	
#	print(spawn_plane["mine"])
# я так устал по этому делаю все тупо 500 которое отнимается из координат тайла 
# это та 500  которая прибавлялась когд мы сохраняли индексы.
	for i in spawn_plane["mine"] :
		var mine_instance = mine.instance()
		var spawn_key = spawn_points.keys()[randi()%spawn_points.size()]
		mine_instance.position = Vector2((int(spawn_key)%1000-500)*32+16,(int(spawn_key)/1000-500)*32+16)  
		mine_instance.rotation = spawn_points[spawn_key]*PI/2
		get_parent().call_deferred("add_child", mine_instance)
		
		spawn_points.erase(spawn_key)
#		printt(mine_instance.position)
	
	for i in spawn_plane["databox"] :
		var item_instance = item.instance()
		var spawn_key = spawn_points.keys()[randi()%spawn_points.size()]
		item_instance.position = Vector2((int(spawn_key)%1000-500)*32+16,(int(spawn_key)/1000-500)*32+16)  
		item_instance.rotation = spawn_points[spawn_key]*PI/2
		item_instance.item = item_instance.items.DATABOX 
		
		get_parent().call_deferred("add_child", item_instance)
		spawn_points.erase(spawn_key)
	
	for i in spawn_plane["rocket"] :
		var item_instance = item.instance()
		var spawn_key = spawn_points.keys()[randi()%spawn_points.size()]
		item_instance.position = Vector2((int(spawn_key)%1000-500)*32+16,(int(spawn_key)/1000-500)*32+16)  
		item_instance.rotation = spawn_points[spawn_key]*PI/2
		item_instance.item = item_instance.items.ROCKETS 
		get_parent().call_deferred("add_child", item_instance)
		spawn_points.erase(spawn_key)
	 
	for i in spawn_plane["medpack"] :
		var item_instance = item.instance()
		var spawn_key = spawn_points.keys()[randi()%spawn_points.size()]
		item_instance.position = Vector2((int(spawn_key)%1000-500)*32+16,(int(spawn_key)/1000-500)*32+16)  
		item_instance.rotation = spawn_points[spawn_key]*PI/2
		item_instance.item = item_instance.items.MEDPACK 
		get_parent().call_deferred("add_child", item_instance)
		
		spawn_points.erase(spawn_key)
	
	for i in spawn_plane["door"] :
		var item_instance = item.instance()
		var spawn_key = spawn_points.keys()[randi()%spawn_points.size()]
		item_instance.position = Vector2((int(spawn_key)%1000-500)*32+16,(int(spawn_key)/1000-500)*32+16)  
		item_instance.rotation = spawn_points[spawn_key]*PI/2
		item_instance.item = item_instance.items.DOOR
		get_parent().call_deferred("add_child", item_instance)
		
		spawn_points.erase(spawn_key)
	
func clear_items_mines():
	var parent_nodes = get_parent().get_children()
	for i in parent_nodes:
		if i.is_in_group("mine") or i.is_in_group("item") :
			i.queue_free()
#	for i in parent_nodes:
#		if i.is_in_group("player") :
#			i.position = Vector2(-4600,1250) 
#
#генерация
#размер 300x80 тайлов
#пол рисуется по периметру из одинаковых блоков толщина пола 1 секция не меняется
#так что можно забить его прям сразу, 1 слой клеток рядом с полом добавляются в свободные
#при запоминании клеток мы должны запоминать  с какой стороны пол чтоб правильно разместить предмет 

#пол я убрал с ним получалось не так весело как без него, тез него можно прыгать
# со всех сторон от дома  а не тольео внутри между домами

#задача простроить 2 рядка домиков сверху и снизу, их делать высотой  6 этажей + 0,1,2
#толщина домиков 2 секции + 0,1,2,3, 
#если домик не влезает по ширине до края он не ставится
#если бомик не влезает в высоту то он ставится но нужно вычеркнуть 2 или 1 слой клеток
#которые он закрыл из списка  
#секции генерятся по шаблону (забиты в словарь), выбираются случайно для домика
#когда домик ставим мы запоминаем в массив все клетки на которые будут вокруг них на 2 тайла, 
#если они не вылезают за границу и не попадают в пол
#
#мы должны поставить, 1 дверь, мины, аптечки, ракеты, датабоксы количеcтво которых зависит
# от уровня игры и уровня сложности,  мы ставим их в свободные квадраты случайно 
#чтоб можно было легко проверить в  списке клетки, мы делаем им код в словаре Yx1000+X 
#
#свинья всегда респится на квадратном домике в левом нижнем углу 
	
