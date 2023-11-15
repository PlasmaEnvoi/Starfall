extends Button

@export var item_cost: Label
@export var item_icon: TextureRect
@export var sold_text: Label
var item_name: String
var item_description: String
var item_info: StoreItem
var cost
var bought = false

@export var speed_icon: CompressedTexture2D
@export var endurance_icon: CompressedTexture2D
@export var strength_icon: CompressedTexture2D
@export var move_icon: CompressedTexture2D

signal item_pressed
signal focus 

func initialize(new_info, speed_stat, strength_stat, endurance_stat):
	sold_text.hide()
	item_info = new_info
#	action_data.action_type.keys()[action.action_data.animation]
	if item_info.possible_types.keys()[item_info.item_type] == "SPEED":
		item_icon.texture = speed_icon
		match speed_stat:
			1:
				item_description = "Speed increases."
			2:
				item_description = "Speed Increases. You gain a dash."
			3:
				item_description = "Speed Increases. You gain an additional air action."
			4:
				item_description = "Speed Cap. You gain an additional double jump."

	elif item_info.possible_types.keys()[item_info.item_type] == "STRENGTH":
		item_icon.texture = strength_icon
		match strength_stat:
			1:
				item_description = "Damage and knockback increases."
			2:
				item_description = "Damage and knockback increases."
			3:
				item_description = "Damage and knockback increases."
			4:
				"Strength Cap. Damage and knockback increase."
	elif item_info.possible_types.keys()[item_info.item_type] == "ENDURANCE":
		item_icon.texture = endurance_icon
		match endurance_stat:
			1:
				item_description = "Maximum Health increases."
			2:
				item_description = "Maximum Health increases."
			3:
				item_description = "Maximum Health increases."
			4:
				item_description = "Endurance Cap. Maximum health increases."
				
	else:
		item_description = item_info.move_desc
		item_icon.texture = null
	cost = (randi_range(item_info.cost_range.x,item_info.cost_range.y))
	if randf() < .2:
		cost /= 2
		item_cost.text = str(cost) + "!!"
	else:
		item_cost.text = str(cost)

func sold():
	bought = true
	item_icon.modulate = Color(1,1,1,.3)
	sold_text.show()

func _on_pressed():
	item_pressed.emit(self)
	
func on_focused():
	focus.emit(self)
