extends Node

@onready var console_menu = DebugMenu.get_node("ConsoleMenu")
@onready var stats = DebugMenu.get_node("Stats")
@onready var console_output = console_menu.get_node("ConsoleLog")

var called_command : Callable
var arguments : PackedStringArray
var output_console_text : String

func clear():
	for i in console_output.get_children():
		console_output.remove_child(i)
		console_output.queue_free()
		
func toggle_noclip():
	# Pass in your method for noclip
	# Example:
	#if GameState.player_ref.current_player_movement != GameState.player_ref.player_movement_type.NOCLIP:
	#	console_menu.print_text_to_console_log("Noclip enabled!", Color.WHITE)
	#	GameState.player_ref.current_player_movement = GameState.player_ref.player_movement_type.NOCLIP
	#else:
	#	console_menu.print_text_to_console_log("Noclip disabled!", Color.WHITE)
	#	GameState.player_ref.current_player_movement = GameState.player_ref.player_movement_type.WALKING
	pass
	
func show_fps():
	stats.get_child(0).visible =! stats.get_child(0).visible
	
func set_max_fps(maxfps):
	Engine.max_fps = maxfps.to_int()
	console_menu.print_text_to_console_log(str("FPS is now ", maxfps, "!"), Color.WHITE)
	
func show_memory_info():
	for i:int in stats.get_child_count():
		if i > 0: stats.get_child(i).visible =! stats.get_child(i).visible
	
func viewmode_unlit():
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_UNSHADED
	console_menu.print_text_to_console_log("Rendering is now unlit!", Color.WHITE)

func viewmode_wireframe():
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	console_menu.print_text_to_console_log("Rendering is now in wireframe mode!", Color.WHITE)

func viewmode_shaded():
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
	console_menu.print_text_to_console_log("Rendering is now shaded!", Color.WHITE)
	
func change_map(levelname):
	#Set this to what folder your maps are stored or change the function to how your loading system works. 
	var level = "res://maps/" + str(levelname) + ".tscn"
	if ResourceLoader.exists(level): get_tree().change_scene_to_file(level)
	else: console_menu.print_text_to_console_log("The map labled as: " + levelname + " does not exist!", Color.RED)
