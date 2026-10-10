extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Reserve space for the host's back-to-lobby button.
	position.x = 120
	var shop = TextureButton.new()
	shop.name = "ShopButton"
	shop.texture_normal = preload("res://assets/shop-icon.png")
	shop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	shop.ignore_texture_size = true
	shop.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	shop.size = Vector2(72, 72)
	shop.tooltip_text = "Бонус за 5 000 ESCAPE"
	shop.pressed.connect(func():
		if OS.has_feature("web"):
			JavaScriptBridge.eval("window.escapeOpenShop && window.escapeOpenShop()")
	)
	add_child(shop)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Follow the resource counter's actual width at every viewport size.
	$ShopButton.position = Vector2($GridContainer.position.x + $GridContainer.size.x * $GridContainer.scale.x + 20, 0)

func update_label():
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
	$GridContainer/ItemDisplay/Label.text = "%d/80" % woodAmount
	$GridContainer/ItemDisplay2/Label.text = "%d/12" % stoneAmount
	$GridContainer/ItemDisplay3/Label.text = "%d/24" % crystalAmount
