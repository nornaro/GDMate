extends Node

var TCPserver = TCPServer.new()
var server = TCPServer.new()

func _ready():
	TCPserver.listen(8080)

func _process(delta):
	if TCPserver.is_connection_available():
		var client = TCPserver.take_connection()
		print("Client connected!")
