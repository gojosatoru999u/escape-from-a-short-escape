extends Control

@export var item_quantity: String
@export var item_name: String

func _ready() -> void:
	$TextureRect.texture = load(JsonData.item_data[item_name]["ItemTexture"])
	$Label.text = item_quantity
	
