extends Control

@onready var _server: WebSocketServer = $WebSocketServer
@onready var _listen_port = 9988
@onready var log_out = $Out
@onready var command = $Command

var peers = {}
var salt = "ragna"
var passwd = "ragna"
var token = ""
var crypto = Crypto.new()
var tokens := {}
var	token_key = CryptoKey.new()
var	server_key = CryptoKey.new()
var	server_cert = X509Certificate.new()


func info(msg):
	log_out.add_text(str(msg) + "\n")

func _on_web_socket_server_client_connected(peer_id):
	var peer: WebSocketPeer = _server.peers[peer_id]
	info("Remote client connected: %d. Protocol: %s" % [peer_id, peer.get_selected_protocol()])
	_server.send(-peer_id, "[%d] connected" % peer_id)
	var auth_response = peer.send("Authenticating...".to_utf8_buffer(),WebSocketPeer.WRITE_MODE_TEXT)
	tokens[peer_id] = null
	peers[peer_id] = peer
	

func cmd(peer_id,text):
	if peers.is_empty():
		return
	print(peers[peer_id].send(text.to_utf8_buffer(),WebSocketPeer.WRITE_MODE_TEXT))

func _on_web_socket_server_client_disconnected(peer_id):
	var peer: WebSocketPeer = _server.peers[peer_id]
	info("Remote client disconnected: %d. Code: %d, Reason: %s" % [peer_id, peer.get_close_code(), peer.get_close_reason()])
	_server.send(-peer_id, "[%d] disconnected" % peer_id)

func _on_web_socket_server_message_received(peer_id, message):
	info("Server received data from peer %d: %s" % [peer_id, message])
	if !tokens[message].has(peer_id):
		return auth(peer_id, message)

func _input(ev):
	if !Input.is_key_pressed(KEY_ENTER):
		return
	if command.text == "":
		return
	cmd(peers.keys().front(),command.text)
	info(command.text)
	command.text = ""

func auth(peer_id, message):
	print("Received token from client ", peer_id, ": ", message)
	if tokens.has(message):
		print("Token validated for client ", peer_id)
		peers[peer_id].send("Authentication successful".to_utf8_buffer(),WebSocketPeer.WRITE_MODE_TEXT)
		tokens[message].append(peer_id)
		return
	print("Invalid token from client ", peer_id)
	peers[peer_id].send("Authentication failed".to_utf8_buffer(),WebSocketPeer.WRITE_MODE_TEXT)
	
func _ready():
	tokens = JSON.parse_string( FileAccess.open("res://tokens", FileAccess.READ).get_as_text())
	var port = int(_listen_port)
	var err = _server.listen(port)
	if err != OK:
		info("Error listing on port %s" % port)
		return
	info("Listing on port %s, supported protocols: %s" % [port, _server.supported_protocols])

func _on_token_pressed():
	token = Marshalls.utf8_to_base64(passwd.sha1_text()).sha1_text()
	tokens[token] = []
	FileAccess.open("res://tokens",FileAccess.WRITE).store_string(JSON.stringify(tokens))
