extends Node


var world_state
var reset = false


func _physics_process(delta):
	if not Server.player_state_collection.empty():
		if reset == true:
			reset = false
			return 
		
		world_state = Server.player_state_collection.duplicate(true)
		
		var dead_IDENS = Server.dead_IDENS
		
		
		world_state["T"] = OS.get_system_time_msecs()
		Server.SendWorldState(world_state)


func _on_Button_pressed() -> void:
	world_state.clear()
