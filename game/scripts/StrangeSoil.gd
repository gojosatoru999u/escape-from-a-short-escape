extends Node2D

var enemy = preload("res://scenes/BambooEnemy.tscn")
@onready var timer = $EnemySpawnTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for drops in GameManager.dropped_items:
		var drop = GameManager.dropped_items[drops]
		if drop["scene"] == self.name:
			var item_scene = load("res://scenes/items/" + drop["item_name"] + ".tscn")
			var item_instance = item_scene.instantiate()
			item_instance.item_id = drop["item_id"]
			item_instance.position = drop["position"]
			item_instance.max_take = GameManager.takenID[drop["item_id"]]
			$Items.add_child(item_instance)
	randomize()
	timer.set_wait_time(randi_range(5, 12))
	timer.start()
	
	$Player.position.y = GameManager.y_pos
	$Player.position.x = GameManager.x_pos
	
func is_valid_spawn_position(pos: Vector2, radius: float = 8.0) -> bool:
	var space_state = get_world_2d().direct_space_state
	var shape = CircleShape2D.new()
	shape.radius = radius

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0, pos)
	params.collide_with_areas = true
	params.collide_with_bodies = true

	var result = space_state.intersect_shape(params, 1)
	return result.is_empty()


	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_forest_scene_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.y_pos = body.position.y
		GameManager.x_pos = 616.0
		GameManager.last_dir = "w"
		call_deferred("change_scene_to_forest")

func change_scene_to_forest():
	get_tree().change_scene_to_file("res://scenes/OuterForest.tscn")


func _on_enemy_spawn_timer_timeout() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	$Player/Path2D/PathFollow2D.progress = rng.randf_range(0.0, 1639.0)
	var spawn_pos = $Player/Path2D/PathFollow2D/Marker2D.global_position
	
	if is_valid_spawn_position(spawn_pos):
		timer.set_wait_time(rng.randi_range(5, 12))
		var enemy_instance = enemy.instantiate()
		enemy_instance.global_position = spawn_pos
		$EnemyLayer.add_child(enemy_instance)
	else:
		timer.set_wait_time(0.1)
	
	timer.start()
