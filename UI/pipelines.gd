extends VBoxContainer

const pipelines = "res://pipelines/"

# Called when the node enters the scene tree for the first time.
func _ready():
	list_directory_contents(pipelines)

func _on_load_button_up():
	list_directory_contents(pipelines)

func list_directory_contents(path):
	var dir = DirAccess.get_files_at(path)
	for filename in dir:
		var instance = load("res://pipeline.tscn").instantiate()
		instance.name = filename.split(".")[0].replace("_"," ")
		instance.filename = filename
		add_child(instance)
