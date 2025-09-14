extends Node

var player_node: Player
var inspect_node: InspectUI

func register_player(player: Player) -> void:
	player_node = player


func register_inspect_ui(node: InspectUI) -> void:
	inspect_node = node
