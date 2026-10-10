extends TextureRect

@warning_ignore("unused_signal")
signal craft_pickaxe
@warning_ignore("unused_signal")
signal craft_club
@warning_ignore("unused_signal")
signal craft_sword

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_pickaxe_craft_button_pressed() -> void:
	emit_signal("craft_pickaxe")


func _on_club_craft_button_pressed() -> void:
	emit_signal("craft_club")


func _on_sword_craft_button_pressed() -> void:
	emit_signal("craft_sword")
