extends Node

var delivered_shop_tools: Dictionary = {}
var bonus_run = 0

func reset_shop_delivery() -> void:
	delivered_shop_tools.clear()
	bonus_run += 1
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.escapeShopOwned = []")

# Host lifecycle and a cosmetic single-player holder bonus; no financial rewards.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if not OS.has_feature("web"):
		return
	get_tree().paused = not bool(JavaScriptBridge.eval("window.escapeGameActive === true"))
	# Host checks the connected wallet's on-chain balance before selecting one tool.
	if GameManager.game_started:
		var owned = JSON.parse_string(str(JavaScriptBridge.eval("JSON.stringify(window.escapeShopOwned || [])")))
		if owned is Array:
			for item in owned:
				if item in ["Pickaxe", "Club", "Sword"] and not delivered_shop_tools.has(item):
					if PlayerInventory.inventory.size() < PlayerInventory.INVENTORY_SLOTS:
						PlayerInventory.add_item(item, 1)
						delivered_shop_tools[item] = true
	var state = {
		"playing": not get_tree().paused,
		"health": GameManager.player_health,
		"started": GameManager.game_started,
		"run": bonus_run,
		"freeSlots": PlayerInventory.INVENTORY_SLOTS - PlayerInventory.inventory.size(),
		"scene": get_tree().current_scene.name if get_tree().current_scene else "",
	}
	JavaScriptBridge.eval("window.escapeGameState = " + JSON.stringify(state))
