extends Area2D
enum bomb_types {ROCKET,MINE,BAREL}
var bomb_type = bomb_types.MINE 
var hp = 10


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		var explosion = load("res://explosion.tscn").instance()
		get_parent().add_child(explosion)
		explosion.position = position 
		explosion.play()
		var my_root = get_parent()
		my_root.update_destructable(get_global_position(),bomb_type)
		my_root.do_damage(my_root.player,self,bomb_type)
		queue_free()
