extends Node2D

var boat_in_range = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.takenID.has(4):
		if GameManager.takenID[4] == 0:
			$DialogueGate.queue_free()
	$Player.position.y = GameManager.y_pos
	$Player.position.x = GameManager.x_pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not GameManager.is_movement_disabled:
		if Input.is_action_just_pressed("interact") and boat_in_range:
			if not GameManager.boat_dialogue_visited:
				GameManager.show_dialogue("broken_boat")
				GameManager.boat_visited = true
			else:
				GameManager.open_boat_crafting_menu()
	

func _on_next_scene_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.y_pos = body.position.y
		GameManager.x_pos = -160.0
		GameManager.last_dir = "e"
		call_deferred("change_scene")

		
func change_scene():
	get_tree().change_scene_to_file("res://scenes/OuterForest.tscn")


func _on_is_stick_taken_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if GameManager.takenID[4] != 0:
			GameManager.show_dialogue("no_weapon_beach")
		else:
			$DialogueGate/StaticBody2D.queue_free()


func _on_escape_ship_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		boat_in_range = true


func _on_escape_ship_trigger_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		boat_in_range = false
