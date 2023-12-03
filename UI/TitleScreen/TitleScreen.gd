extends Control

@export var new_game: Button
@export var continue_game: Button
@export var run: Button
@export var options: Button
@export var exit: Button


@export var save_exists: bool

@export var bg_texture: TextureRect
@export var possible_bgs: Array[CompressedTexture2D]

func _ready():
	
	new_game.pressed.connect(start_new_game)
	continue_game.pressed.connect(continue_save)
	run.pressed.connect(skip_to_run)
	options.pressed.connect(open_options)
	exit.pressed.connect(exit_game)
	
	bg_texture.texture = possible_bgs.pick_random()
	if save_exists == true:
		continue_game.show()
	else:
		continue_game.hide()
	new_game.grab_focus()

func start_new_game():
	pass

func continue_save():
	get_tree().change_scene_to_file("res://TestStuff/TestWorld.tscn")

func skip_to_run():
	get_tree().change_scene_to_file("res://TestStuff/TestWorld.tscn")

func open_options():
	pass
	
func exit_game():
	get_tree().quit()
