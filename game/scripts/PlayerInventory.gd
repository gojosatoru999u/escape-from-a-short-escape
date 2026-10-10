extends Node

@warning_ignore("unused_signal")
signal active_item_updated
@warning_ignore("unused_signal")
signal hotbar_updated

const INVENTORY_SLOTS = 24
const HOTBAR_SLOTS = 6
const InventorySlot = preload("res://scripts/InventorySlot.gd")
const ItemClass = preload("res://scripts/inventory_item.gd")

var inventory = {
}

var active_item_slot = 0
var inventory_layer: Node = null

func add_item(item_name, item_quantity):
	for item in inventory:
		if inventory[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - inventory[item][1]
			if able_to_add >= item_quantity:
				inventory[item][1] += item_quantity
				update_slot_visual(item, inventory[item])
				emit_signal("hotbar_updated")
				GameManager.update_objective_hud()
				return
			else:
				inventory[item][1] += able_to_add
				update_slot_visual(item, inventory[item])
				item_quantity = item_quantity - able_to_add
			
	for i in range(INVENTORY_SLOTS):
		if inventory.has(i) == false:
			inventory[i] = [item_name, item_quantity]
			update_slot_visual(i, inventory[i])
			emit_signal("hotbar_updated")
			GameManager.update_objective_hud()
			return
			
func update_slot_visual(slot_index, item_data):
	if inventory_layer == null:
		return
		
	var item_name: String = item_data[0]
	var item_quantity: int = item_data[1]
	var slot = null
	var slot_path = "Inventory/GridContainerHotbar/Panel" + str(slot_index + 1) \
	if slot_index < 6 else "Inventory/GridContainerInventory/Panel" + str(slot_index + 1)

	slot = inventory_layer.get_node(slot_path)
	
	if slot.item:
		slot.item.set_item(item_name, item_quantity, JsonData.item_data[item_name]["ItemTexture"])
	else:
		slot.initialize_item(item_name, item_quantity, JsonData.item_data[item_name]["ItemTexture"])

func remove_item(slot: InventorySlot):
	inventory.erase(slot.slot_index)
	GameManager.update_objective_hud()
	emit_signal("hotbar_updated")
			
func add_item_to_empty_slot(item: ItemClass, slot: InventorySlot):
	inventory[slot.slot_index] = [item.item_name, item.item_quantity]
	GameManager.update_objective_hud()
	emit_signal("hotbar_updated")
	
func add_item_quantity(slot: InventorySlot, quantity_to_add: int):
	inventory[slot.slot_index][1] += quantity_to_add
	GameManager.update_objective_hud()
	emit_signal("hotbar_updated")
	
func dec_item_quantity(slot: InventorySlot, quantity: int):
	inventory[slot.slot_index][1] -= quantity
	if inventory[slot.slot_index][1] <= 0:
		inventory.erase(slot.slot_index)
	GameManager.update_objective_hud()
	emit_signal("hotbar_updated")
	
func active_item_scroll_up():
	if active_item_slot == 0:
		active_item_slot = (HOTBAR_SLOTS - 1)
	else:
		active_item_slot -= 1
	emit_signal("active_item_updated")
	
func active_item_scroll_down():
	active_item_slot = (active_item_slot + 1) % HOTBAR_SLOTS
	emit_signal("active_item_updated")
	
func select_hotbar(num):
	active_item_slot = num
	emit_signal("active_item_updated")
