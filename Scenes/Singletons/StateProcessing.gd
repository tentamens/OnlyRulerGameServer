extends Node


var world_state



func _physics_process(delta):
	if not Server.player_state_collection.empty():
		world_state = Server.player_state_collection.duplicate(true)
		world_state["T"] = OS.get_system_time_msecs()
		Server.SendWorldState(world_state)
