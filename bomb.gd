extends Area2D

var direction = Vector2(0,0)
enum bomb_types {ROCKET,MINE,BAREL}
var bomb_type = bomb_types.ROCKET
# Declare member variables here. Examples:
# var a = 2
# $Sprite.rotation b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$rocket_start.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += direction
	$Sprite.rotation += 2*PI*delta*1.5
	
#	pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # Replace with function body.


#
#func do_damage(target,bomb,bomb_type):
#	if target.is_in_group("player") :
#		var target_direction = target.position - position
#		var distance = target_direction.length()
#		var damage = 3000/(1+distance)
#		var boom_speed = target_direction.rotated(-target.rotation).normalized()*damage*25
#		var boom_damage = damage
#		target.velocity += boom_speed 
#		target.shock_wave = true
#		target.hp -= boom_damage
#	var explosion = load("res://explosion.tscn").instance()
#	get_parent().add_child(explosion)
#	explosion.position = position 
#	explosion.play()
	
	
#	printt(damage," damage ",boom_damage,"speed ", boom_speed.length())

func _on_bomb_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	get_parent().update_destructable(global_position,bomb_type)
	get_parent().do_damage(get_parent().player,self,bomb_type)
	
	queue_free()
	pass # Replace with function body.


func _on_bomb_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.is_in_group("mine") :
		area.queue_free()
		get_parent().update_destructable(global_position,bomb_type)
		get_parent().do_damage(get_parent().player,self,bomb_type)
		queue_free()
	pass # Replace with function body.
