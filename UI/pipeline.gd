extends Control

@export var filename = ""
const pipelines = "res://pipelines/"

# Called when the node enters the scene tree for the first time.
func _ready():
	print(pipelines+filename)
	var instance = load(pipelines+filename).instantiate()
	instance.name = filename.split(".")[0].replace("_"," ")
	add_child(instance)
