tool
extends Area2D
enum items {DATABOX,MEDPACK,ROCKETS,DOOR}
export (items) var item = items.ROCKETS setget set_item
var alpha = 0.0
var pix_rotate = true

func set_item(value):
	match value:
		items.ROCKETS: 
			$AnimatedSprite.stop()
			$AnimatedSprite.animation = "default"
			$AnimatedSprite.frame = 2
			pix_rotate = true
		items.DATABOX:
			$AnimatedSprite.stop()
			$AnimatedSprite.animation = "default"
			$AnimatedSprite.frame = 1
			pix_rotate = true
		items.MEDPACK:
			$AnimatedSprite.stop()
			$AnimatedSprite.animation = "default"
			$AnimatedSprite.frame = 0
			pix_rotate = true
		items.DOOR:
			$AnimatedSprite.animation = "door"
			$AnimatedSprite.frame = 0
			$AnimatedSprite.play()
			pix_rotate = false
#	if !pix_rotate :
	$AnimatedSprite.scale.x = 1
	item = value
#func _physics_process(delta):
#	if pix_rotate :
#		alpha+=delta
#		$AnimatedSprite.scale.x = sin(alpha)
	


func _on_Area2D_body_entered(body):
	if body.is_in_group("player") :
		match item:
			items.ROCKETS: 
				body.rockets += 10
			items.DATABOX:
				body.databoxes += 1
			items.MEDPACK:
				body.hp += 150
			items.DOOR:
				get_parent().load_game("portal")
		var sound = get_parent().get_node("pick_up")
		if !sound.playing :
			sound.play()
		queue_free()
		
		
	# Replace with function body.
