extends Node


onready var user_count = $Control/User_count

var user_num = 0
var instance_num


var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 2

var players = {}

func _ready():
	start_server()
	
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")
	network.connect("peer_connected", self, "_player_connected")
	network.connect("peer_disconnected", self, "_player_disconnected")
	
func _player_connected(player_id):
	PlayerVerification.start(player_id)
	user_num += 1
	instance_num += 1
	print("Player: " + str(player_id) + " Connected")
	user_count.text = str(user_num)
	get_node("Control/HBoxContainer2/InstanceCount").text = str(instance_num)


func _player_disconnected(player_id):
	get_node(str(player_id)).queue_free()
	user_num +- 1
	instance_num -= 1
	print("Player: " + str(player_id) + " Disconnected")
	user_count.text = str(user_num)
	get_node("Control/HBoxContainer2/InstanceCount").text = str(instance_num)

remote func Fetch_Data(skill_name, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var reqestedData = ServerData.Game_data[skill_name]
	rpc_id(player_id, "ReturnData", reqestedData, requester)


func Get_server_id(player_id):
	print(player_id)
