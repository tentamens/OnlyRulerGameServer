extends Node


var network = NetworkedMultiplayerENet.new()

var ip = "127.0.0.1"

var port = 49142284372937

func _ready():
	ConnectToServer()

func ConnectToServer():
	print("connecting to Data Base")
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
	print_hello_world()


func _OnConnectionFailed():
	print("Failed to connect :/")

func _OnConnectionSucceeded():
	print("Succesfully connected to game server :D ")



func print_hello_world():
	print("Telling it to print")
	rpc_id(1, "Print_HelloWorld")
