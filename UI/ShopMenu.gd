extends Control

@export var stock: Array[StoreItem]
@export var active: bool
@export var current_player_cash: int
@export var player: CharacterBody3D
@export var cash_display: Label
@export var item_desc: Label
@export var shop_button: PackedScene
@export var shop_grid: GridContainer

signal sell
signal exit_store


func stock_store(new_stock: Array[StoreItem]):
	stock = new_stock.duplicate()
	for item in shop_grid.get_children():
		item.queue_free()
		
	for item in stock:
		var new_item = shop_button.instantiate()
		new_item.initialize(item, player.strength, player.agility, player.endurance)
		shop_grid.add_child(new_item)
		new_item.item_pressed.connect(sell_item)
		new_item.focus.connect(item_focused)
	
func _open_shop(player_cash):
	current_player_cash = player_cash
	cash_display.text = str(current_player_cash)
	active = true
	show()
	print(shop_grid.get_children()[0])
	await get_tree().process_frame
	shop_grid.get_children()[0].grab_focus()
	
func _hide_shop():
	active = false
	exit_store.emit(current_player_cash)
	for item in shop_grid.get_children():
		release_focus()
	hide()
	
func sell_item(item):
	if active != false:
		if item.cost <= current_player_cash && item.bought == false:
			current_player_cash -= item.cost
			sell.emit(item)
			cash_display.text = str(current_player_cash)
			item.sold()
		else:
			print("Too much!!")

func item_focused(item):
	item_desc.text = item.item_description
