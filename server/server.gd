extends Node


var unit_NUM = 0
var reset = false


var player_ID1 = null
var player_ID2 = null


var expected_Tokens = []
var player_state_collection = {}
var dead_IDENS = {}


onready var user_count = $Control/User_count

var user_num = 0
var instance_num = 0


var network = NetworkedMultiplayerENet.new()
var port = 12030
var max_players = 10

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
	player_state_collection.erase(player_id)
	print("Player: " + str(player_id) + " Disconnected")

remote func Fetch_Data(skill_name, requester):
	print("Fetching data")
	var player_id = get_tree().get_rpc_sender_id()
	var reqestedData = ServerData.Game_data[skill_name]
	rpc_id(player_id, "ReturnData", reqestedData, requester)


remote func ReceivePlayerState(player_state, IDEN):
	var player_id = get_tree().get_rpc_sender_id()
	
	check_IDS(player_id)
	
	
	if dead_IDENS.has(IDEN):
		return
	
	
	elif player_state["HP"] <= 0:
		Kill_Unit(IDEN, player_state["CI"], player_id)
		dead_IDENS = [IDEN]
		player_state_collection.erase(IDEN)
	
	
	elif player_state_collection.has(IDEN):
		if player_state_collection[IDEN]["T"] < player_state["T"]:
			player_state["IDEN"] = player_state_collection[IDEN]["IDEN"]
			player_state_collection[IDEN] = player_state
			unit_NUM += 1
	
	else:
		player_state_collection[IDEN] = player_state
		unit_NUM += 1


func check_IDS(player_ID):
	if player_ID2:	return
	
	if player_ID1 == null:
		player_ID1 = player_ID
	elif player_ID2 == null or player_ID != player_ID1:
		player_ID2 = player_ID


func SendWorldState(world_state):
	if reset == true:
		reset = false
		return
	unit_NUM += 1
	rpc("ReceiveWorldState", world_state, unit_NUM, player_state_collection)

remote func UpdatePlayerState(player_state):
	player_state_collection = player_state



func Get_server_id(player_id):
	print(player_id)


func _on_TokenExpiration_timeout():
	var current_time = OS.get_unix_time()
	var token_time
	if expected_Tokens == []:
		pass
	else:
		for i in range(expected_Tokens.size() -1, -1, -1):
			token_time = int(expected_Tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_Tokens.remove(i)

func FetchToken(player_id):
	print("sending out fetch token")
	rpc_id(player_id, "FetchToken")

remote func ReturnToken(token):
	var player_id = get_tree().get_rpc_sender_id()
	PlayerVerification.Verify(player_id, token)

func ReturnTokenVerificationResults(player_id, result):
		rpc_id(player_id, "ReturnTokenVerificationResults", result)



remote func SpawnTent():
	rpc_id(0, "SpawnNewTent", get_tree().get_rpc_sender_id(), Vector2(0,0))


remote func DetermineLatency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnLatency", client_time)





remote func SpawnUnit(UnitID, IDEN):
	var UnitCreatorID = get_tree().get_rpc_sender_id()
	# ID 1 = Knight ID 2 = Catapult ID 3 = archer
	
	rpc_id(UnitCreatorID, "PlayerSpawnUnit", UnitID, IDEN)



remote func FetchServerTime(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)

remote func Receive_Hit_Data(player_id, player_IDE, damage_taken):
	rpc_id(player_id, "Return_Hit_Data", player_IDE, damage_taken)


remote func Erase_Unit(IDEN):
	print("erase")
	if player_state_collection.has(IDEN):
		print("unit")
		reset = true
		player_state_collection.erase(IDEN)


func Kill_Unit(IDEN, player_id, killer_ID):
	if player_id == player_ID1:
		rpc_id(player_id, "Kill_Unit", IDEN)
		rpc_id(player_ID2, "Kill_Unit",IDEN)
		print(player_ID2, "   " , player_id)
	else:
		print(player_ID1, "   " , player_id)
		rpc_id(player_id, "Kill_Unit", IDEN)
		rpc_id(player_ID1, "Kill_Unit",IDEN)

func Erase_Connections():
	for player in get_children():
		self.remove_child(player)
		player.queue_free()
		
	user_num =- 1
	instance_num -= 1
	player_state_collection.clear()
