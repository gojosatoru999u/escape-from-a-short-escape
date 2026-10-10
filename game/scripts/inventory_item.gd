extends Control

var item_name
var item_quantity

func _ready() -> void:
	pass

func set_item(nm, qt, text):
	item_name = nm
	item_quantity = qt
	self.texture = load(text)
	
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	if stack_size == 1:
		$Label.visible = false
	else:
		$Label.visible = true
		$Label.text = str(item_quantity)

func add_item_quantity(amount_to_add):
	item_quantity += amount_to_add
	$Label.text = str(item_quantity)
	
func dec_item_quantity(amount_to_add):
	item_quantity -= amount_to_add
	$Label.text = str(item_quantity)
