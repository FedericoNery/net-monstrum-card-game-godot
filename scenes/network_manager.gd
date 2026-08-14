extends Node
class_name NetworkManager

const PORT := 7777
const MAX_PLAYERS := 2

signal server_started
signal server_start_failed(error: Error)
signal player_joined(peer_id: int)
signal player_left(peer_id: int)
signal connected_to_host
signal connection_to_host_failed

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

func host_game() -> Error:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(PORT, MAX_PLAYERS)
	if err != OK:
		push_error("NetworkManager.host_game: no se pudo crear el server (%s)" % error_string(err))
		server_start_failed.emit(err)
		return err

	multiplayer.multiplayer_peer = peer
	server_started.emit()
	return OK

func join_game(ip: String) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip, PORT)
	if err != OK:
		push_error("NetworkManager.join_game: no se pudo conectar a '%s' (%s)" % [ip, error_string(err)])
		connection_to_host_failed.emit()
		return err

	multiplayer.multiplayer_peer = peer
	return OK

func disconnect_game() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

func is_host() -> bool:
	return multiplayer.multiplayer_peer != null and multiplayer.is_server()

func get_player_id() -> int:
	return multiplayer.get_unique_id()

func _on_peer_connected(peer_id: int) -> void:
	player_joined.emit(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	player_left.emit(peer_id)

func _on_connected_to_server() -> void:
	connected_to_host.emit()

func _on_connection_failed() -> void:
	connection_to_host_failed.emit()
