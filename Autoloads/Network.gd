extends Node
# Singleton that contains P2P logic

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 3

var server = null
var client = null

var ip_address: String

func _ready():
	# Get User IP address
	if OS.get_name()=="Windows": ip_address = IP.get_local_addresses()[3]
	elif OS.get_name()=="Android": ip_address = IP.get_local_addresses()[0]
	else: ip_address = IP.get_local_addresses()[3]
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168."):
			ip_address = ip
	
	# Connect signals
	if get_tree().connect("connected_to_server", self, "_connected_to_server")!=0:
		print("!!! Network singleton can't connect _connected_to_server !!!")
	if get_tree().connect("server_disconnected", self, "_server_disconnected"):
		print("!!! Network singleton can't connect _server_disconnected !!!")

func create_server():
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)

func join_server():
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)

func _connected_to_server(): print("Successfully connected to the server")

func _server_disconnected(): print("Disconnected from the server")

func kill_connection():
	yield(get_tree(),"idle_frame")
	if multiplayer.is_network_server(): server.close_connection()
	else: client.close_connection()
