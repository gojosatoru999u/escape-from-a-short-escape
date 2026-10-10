extends Control

const InventorySlot = preload("res://scripts/InventorySlot.gd")

@onready var hotbar = $HotbarSlots
@onready var slots = hotbar.get_children()
@onready var active_item_label = $ActiveItemLabel

func _ready():
	PlayerInventory.hotbar_updated.connect(sync_hotbar)
	PlayerInventory.active_item_updated.connect(self.update_active_item_label)
	for i in range(slots.size()):
		PlayerInventory.active_item_updated.connect(slots[i].refresh_style)
		slots[i].slot_index = i
		slots[i].slot_type = InventorySlot.SlotType.HOTBAR
	initialize_hotbar()
	update_active_item_label()
	
func initialize_hotbar():
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(
				PlayerInventory.inventory[i][0],
				PlayerInventory.inventory[i][1],
				JsonData.item_data[PlayerInventory.inventory[i][0]]["ItemTexture"]
			)
		slots[i].refresh_style()
				
func update_active_item_label():
	if slots[PlayerInventory.active_item_slot].item != null:
		active_item_label.text = slots[PlayerInventory.active_item_slot].item.item_name
	else:
		active_item_label.text = ""
		
				
func sync_hotbar():
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			if slots[i].item:
				slots[i].removeFromSlotNoRefresh()
			slots[i].initialize_item(
				PlayerInventory.inventory[i][0],
				PlayerInventory.inventory[i][1],
				JsonData.item_data[PlayerInventory.inventory[i][0]]["ItemTexture"]
				)
		else:
			if slots[i].item:
				slots[i].removeFromSlot()
	update_active_item_label()
			
