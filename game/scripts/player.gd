extends CharacterBody2D

@export var speed = 100
@onready var anim = $AnimatedSprite2D
@onready var attack_anim = $AttackSweep
@onready var walk_audio = $AudioStreamPlayer2D

var player_state
var is_attacking = false
var last_dir = "e"

var health: int
var player_alive = true
var items_in_range: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = GameManager.player_health
	last_dir = GameManager.last_dir


func _physics_process(_delta: float) -> void:
	if not GameManager.is_first_dialogue_shown:
		return
	elif GameManager.is_movement_disabled and GameManager.is_first_dialogue_shown:
		player_state = "idle"
		play_anim(last_dir)
		return
	elif not player_alive:
		anim.play("faint")
		return
		
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction.x == 0 and direction.y == 0:
		player_state = "idle"
		walk_audio.stop()
	elif direction.x != 0 or direction.y != 0:
		player_state = "walking"
		if not walk_audio.playing:
			walk_audio.play()
		
	velocity = direction * speed
	if not is_attacking:
		play_anim(direction)
	move_and_slide()
	
	
func _process(_delta: float) -> void:
	if not GameManager.game_started or GameManager.is_movement_disabled or not player_alive:
		return
		
	if not is_attacking and Input.is_action_just_pressed("attack"):
		start_attack()
		
	if health <= 0:
		player_alive = false
		
	if Input.is_action_just_pressed("interact") and items_in_range.size() > 0:
		var closest_item = null
		var closest_dist = INF
		for item in items_in_range:
			if not item.tool_held:
				continue
			var dist = position.distance_to(item.position)
			if dist < closest_dist:
				closest_dist = dist
				closest_item = item
		
		if closest_item:
			closest_item.take_item()


func play_anim(direction):
	if player_state == "idle":
		anim.play("idle_"+last_dir)
	elif player_state == "walking":
		if direction.y == -1:
			anim.play("walk_n")
			last_dir = "n"
		elif direction.y == 1:
			anim.play("walk_s")
			last_dir = "s"
		elif direction.x == -1:
			if not is_attacking:
				anim.play("walk_w")
				attack_anim.flip_h = true
			last_dir = "w"
		elif direction.x == 1:
			if not is_attacking:
				anim.play("walk_e")
				attack_anim.flip_h = false
			last_dir = "e"

	
func start_attack():
	is_attacking = true
	GameManager.player_current_attack = true
	if PlayerInventory.inventory.has(PlayerInventory.active_item_slot):
		var item_held = PlayerInventory.inventory[PlayerInventory.active_item_slot][0]
		if JsonData.item_data[item_held]["ItemCategory"] == "Weapon":
			var anim_speed = JsonData.item_data[item_held]["ItemSpeed"]
			anim.speed_scale = anim_speed
			attack_anim.speed_scale = anim_speed
		else:
			anim.speed_scale = 1.0
			attack_anim.speed_scale = 1.0
	else:
		anim.speed_scale = 1.0
		attack_anim.speed_scale = 1.0
	anim.play("attack_" + last_dir)
	attack_anim.play("sword_sweep")
	GameManager.audio_attack()


func enemy_attack():
	if player_alive:
		GameManager.screen_flash()
		GameManager.player_hit()
		
		var camera = get_node_or_null("Camera2D")
		if camera != null:
			camera.shake(4.0, 8.0)
		anim.material.set_shader_parameter("flash_strength", 0.5)
		await get_tree().create_timer(0.1).timeout
		anim.material.set_shader_parameter("flash_strength", 0.0)
		
		health -= 20
		GameManager.player_health -= 20
		GameManager.emit_signal("health_changed")
	

func register_item(item: Node2D) -> void:
	items_in_range.append(item)
	

func unregister_item(item: Node2D) -> void:
	items_in_range.erase(item)


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation.begins_with("attack_"):
		GameManager.player_current_attack = false
		GameManager.player_attack_cooldown = false
		is_attacking = false
