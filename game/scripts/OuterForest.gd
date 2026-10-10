extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.entered_forest:
		$FirstDialogueTrigger.queue_free()
	$Player.position.y = GameManager.y_pos
	$Player.position.x = GameManager.x_pos
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_beach_scene_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.y_pos = body.position.y
		GameManager.x_pos = 224.0
		GameManager.last_dir = "w"
		call_deferred("change_scene_to_beach")

func _on_soil_scene_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.y_pos = body.position.y
		GameManager.x_pos = -160.0
		GameManager.last_dir = "e"
		call_deferred("change_scene_to_soil")
		
func change_scene_to_beach():
	get_tree().change_scene_to_file("res://scenes/Beach.tscn")
	
func change_scene_to_soil():
	get_tree().change_scene_to_file("res://scenes/StrangeSoil.tscn")


func _on_first_dialogue_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if GameManager.entered_forest:
			return
		GameManager.show_dialogue("enter_forest")
		GameManager.entered_forest = true
