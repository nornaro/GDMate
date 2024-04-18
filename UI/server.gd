extends Node

# The port we will listen to.
const PORT = 9080
var tcp_server := TCPServer.new()
var socket := WebSocketPeer.new()
var conn

func log_message(message):
	var time = "[color=#aaaaaa] %s [/color]" % Time.get_time_string_from_system()
	%TextServer.text += time + message + "\n"


func _ready():
	if tcp_server.listen(PORT) != OK:
		log_message("Unable to start server.")
		set_process(false)


func _process(_delta):
	while tcp_server.is_connection_available():
		var conn: StreamPeerTCP = tcp_server.take_connection()
		assert(conn != null)
		var node = socket.accept_stream(conn)
		print(node)

	socket.poll()

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			log_message(socket.get_packet().get_string_from_ascii())


func _exit_tree():
	socket.close()
	tcp_server.stop()


func _on_load_pressed():
	socket.send_text("Pong")