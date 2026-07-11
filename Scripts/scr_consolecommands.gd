extends Node

@onready var console_menu: BoxContainer = DebugMenu.get_node("ConsoleMenu") ## Root of the console menu.
@onready var stats: VBoxContainer = DebugMenu.get_node("Stats") ## Vertical container for all the stats.
@onready var console_log: VBoxContainer = console_menu.get_node("ConsoleLog").get_node("VBoxContainer") ## Vertical container that stores console logs as RichTextLabels.

func clear() -> void:
	for i in console_log.get_children():
		console_log.remove_child(i)
		console_log.queue_free()

func test() -> void:
	console_menu.cprint("Hello, World!")
	
func show_fps() -> void:
	stats.get_child(0).visible =! stats.get_child(0).visible
	
func set_max_fps(maxfps) -> void:
	Engine.max_fps = maxfps.to_int()
	console_menu.cprint(str("FPS is now ", maxfps, "!"), Color.WHITE)
	
func show_memory_info() -> void:
	for i:int in stats.get_child_count():
		if i > 0: stats.get_child(i).visible =! stats.get_child(i).visible

func viewmode(mode) -> void:
	mode = mode.to_int()
	match mode:
		0:
			#Shaded
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
			console_menu.cprint("Rendering is now shaded!", Color.WHITE)
		1:
			# Unlit
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_UNSHADED
			console_menu.cprint("Rendering is now unlit!", Color.WHITE)
		2:
			# Wireframe
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
			console_menu.cprint("Rendering is now in wireframe mode!", Color.WHITE)
	
func change_map(levelname) -> void:
	#Set this to what folder your maps are stored or change the function to how your loading system works. 
	var level = "res://maps/" + str(levelname) + ".tscn"
	if ResourceLoader.exists(level): get_tree().change_scene_to_file(level)
	else: console_menu.cprint("The map labled as: " + levelname + " does not exist!", Color.RED)
