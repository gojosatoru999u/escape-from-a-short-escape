extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.boat_menu_open = true
	check_craftability()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func check_craftability():
	var stoneAmount = 0
	var woodAmount = 0
	var crystalAmount = 0
	
	for item in PlayerInventory.inventory:
		if PlayerInventory.inventory[item][0] == "Wood":
			woodAmount += PlayerInventory.inventory[item][1]
		if PlayerInventory.inventory[item][0] == "Stone":
			stoneAmount += PlayerInventory.inventory[item][1]
		if PlayerInventory.inventory[item][0] == "Crystal":
			crystalAmount += PlayerInventory.inventory[item][1]
	var canEscape = (woodAmount >= 80 and stoneAmount >= 12 and crystalAmount >= 24)
	$TextureRect/MarginContainer/VBoxContainer/HBoxContainer/EscapeButton.disabled = not canEscape


func _on_close_button_pressed() -> void:
	GameManager.boat_menu_open = false
	queue_free()


func _on_escape_button_pressed() -> void:
	GameManager.player_win()
	queue_free()
