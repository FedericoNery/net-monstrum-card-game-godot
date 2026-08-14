class_name DeckRepository extends RefCounted

const DECKS_DIR := "user://decks/"

static func _ensure_decks_dir() -> void:
	DirAccess.make_dir_recursive_absolute(DECKS_DIR)

static func _path_for(file_name: String) -> String:
	var normalized := file_name
	if not normalized.ends_with(".json"):
		normalized += ".json"
	return DECKS_DIR + normalized

static func save_deck(deck: Deck, file_name: String = "") -> Error:
	_ensure_decks_dir()
	var target_name := file_name if not file_name.is_empty() else deck.deck_name
	if target_name.is_empty():
		push_error("DeckRepository.save_deck: se necesita un nombre de archivo o deck.deck_name")
		return ERR_INVALID_PARAMETER

	var data := {
		"name": deck.deck_name,
		"card_ids": deck.card_ids,
	}
	var file := FileAccess.open(_path_for(target_name), FileAccess.WRITE)
	if file == null:
		push_error("DeckRepository.save_deck: no se pudo abrir '%s' (%s)" % [target_name, error_string(FileAccess.get_open_error())])
		return FileAccess.get_open_error()

	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return OK

static func load_deck(file_name: String) -> Deck:
	var path := _path_for(file_name)
	if not FileAccess.file_exists(path):
		push_error("DeckRepository.load_deck: no existe '%s'" % path)
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("DeckRepository.load_deck: no se pudo abrir '%s' (%s)" % [path, error_string(FileAccess.get_open_error())])
		return null

	var text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		push_error("DeckRepository.load_deck: JSON inválido en '%s'" % path)
		return null

	var raw_ids: Array = parsed.get("card_ids", [])
	return Deck.new(parsed.get("name", ""), raw_ids)

static func list_decks() -> Array[String]:
	_ensure_decks_dir()
	var result: Array[String] = []
	var dir := DirAccess.open(DECKS_DIR)
	if dir == null:
		return result

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if not dir.current_is_dir() and entry.ends_with(".json"):
			result.append(entry)
		entry = dir.get_next()
	dir.list_dir_end()
	return result

static func delete_deck(file_name: String) -> Error:
	var path := _path_for(file_name)
	if not FileAccess.file_exists(path):
		return ERR_FILE_NOT_FOUND
	return DirAccess.remove_absolute(path)
