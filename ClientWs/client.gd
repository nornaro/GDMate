extends Node

@onready var _wsclient: WebSocketClient = $WebSocketClient
@onready var console = $Control/Console

var data = ""
var protocol = ""
var token = ""
var retry = 0

func read_or_write_template_json():
	if !FileAccess.file_exists("res://config.json"):
		var file = FileAccess.open("res://config.json", FileAccess.WRITE)
		file.store_string("""{
	"Token": "db513a3e323acbc90061db5b3c728b4f1c8b05ca",
	"Protocol": "WebSocket",
	"WebSocket": {
		"uid": "",
		"master": "ws://localhost:9988/test/",
		"retry": {
			"wait": 60,
			"times": 60
		}
	}
}""")
	data = JSON.parse_string( FileAccess.open("res://config.json", FileAccess.READ).get_as_text())
	if !data:
		push_error("Parsing config.json failed")
	protocol = data["Protocol"]
	token = data["Token"]
	data = data[protocol]

func get_environment(variable):
	return OS.get_environment(variable)

func set_environment(variable,value):
	OS.set_environment(variable,value)

func info(msg):
	var path = "res://"+Time.get_datetime_string_from_system().replace("-","").replace(":","").replace("T","")+".log"
	var mode = FileAccess.WRITE
	if FileAccess.file_exists(path):
		mode = FileAccess.READ_WRITE
	var file = FileAccess.open(path, mode)
	console.text += msg + "\n"
	file.seek_end()
	file.store_string(str(msg) + "\n")
	file.close()

func _on_web_socket_wsclient_connection_closed():
	var ws = _wsclient.get_socket()
	info("Client just disconnected with code: %s, res on: %s" % [ws.get_close_code(), ws.get_close_reason()])

func _on_web_socket_wsclient_connected_to_server():
	info("Client just connected with protocol: %s" % _wsclient.get_socket().get_selected_protocol())

func _on_web_socket_client_message_received(message):
	info("%s" % message)
	if message == "Authenticating...":
		_wsclient.send(token)
		return token
	var result = OS.execute(message, [])
	return result

func _ready():
	read_or_write_template_json()
	$Control/Console.text = ""
	info("Connecting to host: %s." % [data["master"]])
	var err = _wsclient.connect_to_url(data["master"])
	if err != OK:
		info("Error connecting to host: %s" % [data["master"]])
	if _wsclient.socket.get_ready_state() == 1:
		return
	if !data.has("retry"):
		return
	if retry < data["retry"]["times"]:
		retry+=1
		_ready()
