extends Polygon2D




func _on_body_entered(body:Node2D):
	if body.is_in_group("player"):
		get_parent().get_node("AcceptDialog").popup_centered()
