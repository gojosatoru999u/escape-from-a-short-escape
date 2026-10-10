extends Node

var item_data: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_data = load_data("res://scenes/inventory/data/ItemData.json")

func load_data(file_path: String):
	var file_data = FileAccess.get_file_as_string(file_path)
	var json_data = JSON.parse_string(file_data)
	return json_data

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
