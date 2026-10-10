extends Control

const InventorySlot = preload("res://scripts/InventorySlot.gd")


@onready var hotbar_slots = $GridContainerHotbar
@onready var inventory_slots = $GridContainerInventory
@onready var pickaxe_craft_button = $CraftingMenu/GridContainer/MarginContainer/PickaxeCraftButton
@onready var club_craft_button = $CraftingMenu/GridContainer/MarginContainer2/ClubCraftButton
@onready var sword_craft_button = $CraftingMenu/GridContainer/MarginContainer3/SwordCraftButton

var canCraftPickaxe = false
var canCraftClub = false
var canCraftSword = false

var ItemClass = preload("res://scenes/inventory/inventory_item.tscn")
var holding_item: Node = null

func _ready():
	var slots = hotbar_slots.get_children() + inventory_slots.get_children()
	for i in range(slots.size()):
		slots[i].mouse_filter = Control.MOUSE_FILTER_PASS
		slots[i].gui_input.connect(_on_slot_gui_input.bind(slots[i]))
		slots[i].slot_index = i
		slots[i].slot_type = InventorySlot.SlotType.INVENTORY
	initialize_inventory()
	$CraftingMenu.craft_pickaxe.connect(craft_pickaxe)
	$CraftingMenu.craft_club.connect(craft_club)
	$CraftingMenu.craft_sword.connect(craft_sword)

func initialize_inventory():
	var slots = hotbar_slots.get_children() + inventory_slots.get_children()
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(
				PlayerInventory.inventory[i][0],
				PlayerInventory.inventory[i][1], 
				JsonData.item_data[PlayerInventory.inventory[i][0]]["ItemTexture"]
				)


func reset_inventory_state():
	var slots = hotbar_slots.get_children() + inventory_slots.get_children()
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].removeFromSlot()
			PlayerInventory.remove_item(slots[i])

func _on_slot_gui_input(event: InputEvent, slot: InventorySlot):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if holding_item:
				if !slot.item:
					left_click_empty_slot(slot)
				else:
					if holding_item.item_name != slot.item.item_name:
						left_click_occupied_diff_item(slot, event)
					else:
						left_click_occupied_same_item(slot)
						
			else:
				if slot.item:
					PlayerInventory.remove_item(slot)
					holding_item = slot.item
					slot.pickFromSlot()
					holding_item.global_position = get_global_mouse_position()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if slot.item:
				if holding_item:
					if holding_item.item_name == slot.item.item_name:
						var stack_size = int(JsonData.item_data[holding_item.item_name]["StackSize"])
						if holding_item.item_quantity < stack_size and slot.item.item_quantity >= 1:
							holding_item.add_item_quantity(1)
							slot.item.dec_item_quantity(1)
							PlayerInventory.dec_item_quantity(slot, 1)
						if slot.item.item_quantity <= 0:
							PlayerInventory.remove_item(slot)
							slot.removeFromSlot()
				else:
					var item_name = slot.item.item_name
					var cur_quantity = slot.item.item_quantity
					if cur_quantity >= 1:
						var new_item = ItemClass.instantiate()
						new_item.set_item(item_name, 1, JsonData.item_data[item_name]["ItemTexture"])
						new_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
						add_child(new_item)
						new_item.global_position = get_global_mouse_position()
						holding_item = new_item
						
						slot.item.dec_item_quantity(1)
						PlayerInventory.dec_item_quantity(slot, 1)
						
						if slot.item.item_quantity <= 0:
							PlayerInventory.remove_item(slot)
							slot.removeFromSlot()

func left_click_empty_slot(slot: InventorySlot):
	PlayerInventory.add_item_to_empty_slot(holding_item, slot)
	slot.putToSlot(holding_item)
	holding_item = null
	
func left_click_occupied_diff_item(slot: InventorySlot, event: InputEventMouseButton):
	PlayerInventory.remove_item(slot)
	PlayerInventory.add_item_to_empty_slot(holding_item, slot)
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = event.global_position
	slot.putToSlot(holding_item)
	holding_item = temp_item
	
func left_click_occupied_same_item(slot: InventorySlot):
	var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
	var able_to_add = stack_size - slot.item.item_quantity
	if able_to_add >= holding_item.item_quantity:
		PlayerInventory.add_item_quantity(slot, holding_item.item_quantity)
		slot.item.add_item_quantity(holding_item.item_quantity)
		holding_item.queue_free()
		holding_item = null
	else:
		PlayerInventory.add_item_quantity(slot, able_to_add)
		slot.item.add_item_quantity(able_to_add)
		holding_item.dec_item_quantity(able_to_add)

func _process(_delta):
	if holding_item:
		holding_item.set_global_position(get_global_mouse_position())
		holding_item.release_focus()
		
	check_craftability()

func check_craftability():
	var isStickTaken = false
	var stoneAmount = 0
	var woodAmount = 0
	var crystalAmount = 0
	
	for item in PlayerInventory.inventory:
		if PlayerInventory.inventory[item][0] == "Stick":
			isStickTaken = true
		if PlayerInventory.inventory[item][0] == "Wood":
			woodAmount += PlayerInventory.inventory[item][1]
		if PlayerInventory.inventory[item][0] == "Stone":
			stoneAmount += PlayerInventory.inventory[item][1]
		if PlayerInventory.inventory[item][0] == "Crystal":
			crystalAmount += PlayerInventory.inventory[item][1]
	
	canCraftPickaxe = (stoneAmount >= 3) and (woodAmount >= 4)
	canCraftClub = isStickTaken and (woodAmount >= 8)
	canCraftSword = isStickTaken and (stoneAmount >= 2) and (crystalAmount >= 4)
	
	pickaxe_craft_button.disabled = !canCraftPickaxe
	club_craft_button.disabled = !canCraftClub
	sword_craft_button.disabled = !canCraftSword


func craft_item(item_name, required):
	var slots = hotbar_slots.get_children() + inventory_slots.get_children()

	for slot in slots:
		if slot.item == null:
			continue

		var item = slot.item
		var res_name = item.item_name
		if res_name in required and required[res_name] > 0:
			var to_remove = min(item.item_quantity, required[res_name])
			required[res_name] -= to_remove

			if item.item_quantity <= to_remove:
				slot.removeFromSlot()
				PlayerInventory.remove_item(slot)
			else:
				item.dec_item_quantity(to_remove)
				PlayerInventory.dec_item_quantity(slot, to_remove)

	var crafted = true
	for key in required:
		if required[key] > 0:
			crafted = false
			break

	if crafted:
		for i in range(slots.size()):
			if not PlayerInventory.inventory.has(i):
				PlayerInventory.add_item(item_name, 1)
				return
				

func _on_crafting_button_pressed() -> void:
	$CraftingMenu.visible = !$CraftingMenu.visible


func craft_pickaxe() -> void:
	var required = {"Stone": 3, "Wood": 4}
	craft_item("Pickaxe", required)


func craft_club() -> void:
	var required = {"Stick": 1, "Wood": 8}
	craft_item("Club", required)


func craft_sword() -> void:
	var required = {"Stick": 1, "Stone": 2, "Crystal": 4}
	craft_item("Sword", required)
