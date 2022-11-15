extends Node

var expected_Tokens = []


onready var user_count = $Control/User_count

var user_num = 0
var instance_num = 0


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


func _player_disconnected(player_id):
	if has_node(str(player_id)):
		get_node(str(player_id)).queue_free()
	user_num =- 1
	instance_num -= 1
	print("Player: " + str(player_id) + " Disconnected")

remote func Fetch_Data(skill_name, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var reqestedData = ServerData.Game_data[skill_name]
	rpc_id(player_id, "ReturnData", reqestedData, requester)


func Get_server_id(player_id):
	print(player_id)


func _on_TokenExpiration_timeout():
	var current_time = OS.get_unix_time()
	var token_time
	if expected_Tokens == []:
		print("No tokens")
		pass
	else:
		for i in range(expected_Tokens.size() -1, -1, -1):
			token_time = int(expected_Tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_Tokens.remove(i)
	print("Expected Tokens:")
	print(expected_Tokens)

func FetchToken(player_id):
	print("sending out fetch token")
	rpc_id(player_id, "FetchToken")

remote func ReturnToken(token):
	var player_id = get_tree().get_rpc_sender_id()
	PlayerVerification.Verify(player_id, token)

func ReturnTokenVerificationResults(player_id, result):
		rpc_id(player_id, "ReturnTokenVerificationResults", result)

