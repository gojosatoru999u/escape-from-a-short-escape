extends CharacterBody2D

@export var item_dropped: String
@export var speed = 50
@export var entity_id: int

@onready var anim = $AnimatedSprite2D
@onready var attack_anim = $AttackAnim
@onready var attack_audio = $AudioStreamPlayerAttack

var red_flash: ShaderMaterial

var health = 100
var last_dir = "s"

var player_chase = false
var player = null
var player_in_attack_zone = false

var is_attacking = false

func _enter_tree() -> void:
	if entity_id:
		if GameManager.entityID.has(entity_id):
			queue_free()
	else:
		entity_id = GameManager.get_runtime_id()
	visible = true

func _ready() -> void:
	red_flash = ShaderMaterial.new()
	red_flash.shader = preload("res://scripts/RedFlash.gdshader")
	anim.material = red_flash
	

func _physics_process(_delta: float) -> void:
	if player_chase and player and not is_attacking:
		if global_position.distance_to(player.global_position) > 12.3:
			var direction = (player.global_position - global_position).normalized()
			global_position += direction * speed * _delta

			play_walk_anim(direction)
		
	move_and_slide()
	
	
func _process(_delta: float) -> void:
	if player_in_attack_zone and GameManager.player_current_attack and !GameManager.player_attack_cooldown:
		deal_with_damage()
		
	if player_in_attack_zone and not is_attacking:
		start_attack()


func play_walk_anim(direction: Vector2) -> void:
	if abs(direction.y) > abs(direction.x):
		if direction.y < 0:
			anim.play("walk_n")
			last_dir = "n"
		else:
			anim.play("walk_s")
			last_dir = "s"
	else:
		if direction.x < 0:
			anim.play("walk_w")
			last_dir = "w"
		else:
			anim.play("walk_e")
			last_dir = "e"


func start_attack():
	is_attacking = true
	anim.play("attack_windup")
	$AttackWindupTimer.start()


func _on_attack_windup_timer_timeout() -> void:
	anim.play("idle")
	attack_anim.play("attack")
	attack_audio.play()
	
	if player_in_attack_zone and player:
		player.enemy_attack()
	
		
func _on_attack_anim_animation_finished() -> void:
	is_attacking = false


func deal_with_damage():
	GameManager.player_attack_cooldown = true
	
	anim.material.set_shader_parameter("flash_strength", 0.5)
	await get_tree().create_timer(0.1).timeout
	anim.material.set_shader_parameter("flash_strength", 0.0)
	
	
	var damage = 15
	if PlayerInventory.inventory.has(PlayerInventory.active_item_slot):
		var item_held = PlayerInventory.inventory[PlayerInventory.active_item_slot][0]
		if JsonData.item_data[item_held]["ItemCategory"] == "Weapon":
			damage = JsonData.item_data[item_held]["ItemAttack"]
	
	GameManager.enemy_hit()
	
	health -= damage
	if health <= 0:
		var drop_count = randi_range(1, 3)
		for i in range(drop_count):
			var item_dropped_scene = load("res://scenes/items/"+item_dropped+".tscn")
			var object_offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
			var item_dropped_node = item_dropped_scene.instantiate()
			item_dropped_node.position = self.global_position + object_offset
			item_dropped_node.max_take = 3
			item_dropped_node.item_id = GameManager.get_runtime_id()
			get_parent().get_parent().get_node("Items").add_child(item_dropped_node)
			GameManager.dropped_items[item_dropped_node.item_id] = {
				"item_id": item_dropped_node.item_id,
				"scene": get_parent().name,
				"item_name": item_dropped,
				"position": item_dropped_node.position,
				"max_take": item_dropped_node.max_take,
			}
		GameManager.entityID[entity_id] = 1
		self.queue_free()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		player_chase = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player = null
		player_chase = false
		
	anim.play("idle")


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attack_zone = true


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attack_zone = false


func _on_player_first_encounter_detect_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if not GameManager.first_enemy_encounter:
			GameManager.show_dialogue("first_enemy_encounter")
			GameManager.first_enemy_encounter = true
