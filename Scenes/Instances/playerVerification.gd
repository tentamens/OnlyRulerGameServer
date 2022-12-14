extends Node

onready var player_container_scene = preload("res://Scenes/Instances/PlayerContainer.tscn")
onready var main_interface = Server


var awaiting_varifitcation = {}

func start(player_id):
	awaiting_varifitcation[player_id] = {"Timestamp": OS.get_unix_time()}
	main_interface.FetchToken(player_id)


func CreatePlayerContainer(player_id):
	var new_player_container = player_container_scene.instance()
	new_player_container.name = str(player_id)
	get_parent().add_child(new_player_container, true)
	var player_container = get_node("../" + str(player_id))
	FillPlayerContainer(player_container)
	

func FillPlayerContainer(player_container):
	player_container.player_stats = ServerData.test_data.Stats

func Verify(player_id, token):
	var token_verification = false
	while OS.get_unix_time() - int(token.right(64)) <= 30:
		if main_interface.expected_Tokens.has(token):
			token_verification = true
			CreatePlayerContainer(player_id)
			awaiting_varifitcation.erase(player_id)
			main_interface.expected_Tokens.erase(token)
			break
		else:
			yield(get_tree().create_timer(2), "timeout")
	main_interface.ReturnTokenVerificationResults(player_id, token_verification)
	if token_verification == false:
		awaiting_varifitcation.erase(player_id)
		main_interface.network.disconnect_peer(player_id)
	
	
	


func _on_VerificationExpiration_timeout():
	var current_time = OS.get_unix_time()
	var start_time
	if awaiting_varifitcation == {}:
		pass
	else: 
		for key in awaiting_varifitcation.keys():
			start_time = awaiting_varifitcation[key].Timestamp
			if current_time - start_time >= 30:
				awaiting_varifitcation.erase(key)
				var connected_peers = Array(get_tree().get_network_connected_peers())
				if connected_peers.has(key):
					main_interface.ReturnTokenVerificationResults(key, false)
					main_interface.network.disconnect_peer(key)
	
	


func _on_Button_pressed() -> void:
	awaiting_varifitcation.clear()
	Server.Erase_Connections()
