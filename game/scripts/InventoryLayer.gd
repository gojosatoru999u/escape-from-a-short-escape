extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameManager.is_movement_disabled or not GameManager.player_is_alive:
		return
		
	if Input.is_action_just_pressed("inventory"):
		$Inventory.visible = !$Inventory.visible
		$Inventory/CraftingMenu.visible = false
		$Inventory.initialize_inventory()
		
	if Input.is_action_just_pressed("hotbar_1"):
		PlayerInventory.select_hotbar(0)
	if Input.is_action_just_pressed("hotbar_2"):
		PlayerInventory.select_hotbar(1)
	if Input.is_action_just_pressed("hotbar_3"):
		PlayerInventory.select_hotbar(2)
	if Input.is_action_just_pressed("hotbar_4"):
		PlayerInventory.select_hotbar(3)
	if Input.is_action_just_pressed("hotbar_5"):
		PlayerInventory.select_hotbar(4)
	if Input.is_action_just_pressed("hotbar_6"):
		PlayerInventory.select_hotbar(5)
		
	if Input.is_action_just_released("scroll_up"):
		PlayerInventory.active_item_scroll_up()
	elif Input.is_action_just_released("scroll_down"):
		PlayerInventory.active_item_scroll_down()
