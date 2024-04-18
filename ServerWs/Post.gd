@icon("res://icon.webp")
class_name Pre
extends Node
@export var downstream = {}

	
func collect_downstream():
	downstream = get_children()

func _enter_tree():
	collect_downstream()

#func _exit_tree():
	#children_list.clear()

