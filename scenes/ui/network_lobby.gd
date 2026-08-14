extends Control
class_name NetworkLobby

signal game_started

@onready var ip_input: LineEdit = $VBox/IpRow/IpInput
@onready var status_label: Label = $VBox/StatusLabel

func _ready() -> void:
	NetworkManager.server_started.connect(_on_server_started)
	NetworkManager.server_start_failed.connect(_on_server_start_failed)
	NetworkManager.player_joined.connect(_on_player_joined)
	NetworkManager.player_left.connect(_on_player_left)
	NetworkManager.connected_to_host.connect(_on_connected_to_host)
	NetworkManager.connection_to_host_failed.connect(_on_connection_failed)
	_set_status("Sin conectar.")

func _on_host_pressed() -> void:
	var err := NetworkManager.host_game()
	if err == OK:
		_set_status("Hosteando en el puerto %d. Esperando al otro jugador..." % NetworkManager.PORT)

func _on_connect_pressed() -> void:
	var ip := ip_input.text.strip_edges()
	if ip.is_empty():
		ip = "127.0.0.1"
	_set_status("Conectando a %s..." % ip)
	NetworkManager.join_game(ip)

func _on_server_started() -> void:
	_set_status("Servidor iniciado. Esperando jugador...")

func _on_server_start_failed(_error: int) -> void:
	_set_status("No se pudo iniciar el servidor.")

func _on_player_joined(peer_id: int) -> void:
	_set_status("Jugador %d conectado. ¡Listo para jugar!" % peer_id)
	game_started.emit()

func _on_player_left(peer_id: int) -> void:
	_set_status("Jugador %d se desconectó." % peer_id)

func _on_connected_to_host() -> void:
	_set_status("Conectado al host. ¡Listo para jugar!")
	game_started.emit()

func _on_connection_failed() -> void:
	_set_status("Falló la conexión al host.")

func _set_status(text: String) -> void:
	status_label.text = text
