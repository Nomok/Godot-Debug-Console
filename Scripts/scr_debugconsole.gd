extends Node

@onready var line_edit: LineEdit = $LineEdit ## Text box used for command input.
@onready var console_log: VBoxContainer = $ConsoleLog/VBoxContainer ## Vertical container that stores console logs as RichTextLabels.
@onready var console_log_container: ScrollContainer = $ConsoleLog ## Scroll box used for holding the console logs.

var max_scroll_length: float = 0.0 ## Variable used to keep track of the console_log_container scroll length.

var console_visible: bool = false
var command_history: PackedStringArray = [] ## Array that stores the command history.
var command_index : int = -1 ## Index for looking through command_history.

func _ready() -> void:
	self.visible = console_visible
	line_edit.text_submitted.connect(_console_command_entered)

	max_scroll_length = console_log_container.get_v_scroll_bar().max_value
	console_log.sort_children.connect(_auto_scroll)

## Prints a string to the debug console.
func cprint(text_input: String, text_color: Color = Color.WHITE) -> void:
	var new_text: RichTextLabel = RichTextLabel.new()
	console_log.add_child(new_text)
	new_text.owner = console_log
	new_text.fit_content = true
	new_text.add_text(text_input)
	new_text.modulate = text_color

# Toggle for visiblity, input acceptance, and command history
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_console"):
		console_visible =! console_visible
		if console_visible:
			# The await is here because without it inputs "`" when it first launches and I don't like it okay. 
			await get_tree().process_frame
			DebugMenu.set_mouse_behavior_recursive(DebugMenu.MOUSE_BEHAVIOR_ENABLED)
			line_edit.grab_focus(true)
			self.visible = true
		else:
			DebugMenu.set_mouse_behavior_recursive(DebugMenu.MOUSE_BEHAVIOR_DISABLED)
			line_edit.grab_focus(false)
			self.visible = false
			line_edit.clear()
			command_index = -1 # resets the command selection index when closing the console
	
	if event.is_action_pressed("ui_focus_next") and console_visible:
		if !command_history.is_empty():
			if command_index < command_history.size() - 1: command_index += 1
			else: command_index = 0
			line_edit.text = command_history[command_index]
			line_edit.caret_column = line_edit.text.length()

	if event is InputEventKey and event.is_pressed() and line_edit.is_editing() and command_index != -1:
		command_index = -1
			
func _console_command_entered(command: String) -> void:
	# Sees if the command typed in the text input in the console matches a function name and its arguments found in scr_consolecommands
	var registered_command: String = command.get_slice(" ", 0)
	var called_command: Callable = Callable(ConsoleCommands, registered_command)
	
	# Adds the typed command whether incorrect or not into the command history 
	if !command_history.has(command): command_history.push_back(command)
	
	cprint(">" + command, Color.GRAY)
	
	# Store the command arguments in a PackedStringArray seperated by spaces in the pushed command
	var command_arguments : PackedStringArray = command.split(" ", false, 0)
	command_arguments.remove_at(0)
	
	if called_command.is_valid():
		if called_command.get_argument_count() == command_arguments.size():
			called_command.callv(command_arguments)
			
		elif called_command.get_argument_count() > command_arguments.size():
			cprint(registered_command + " Has missing params", Color.RED)
		
		elif called_command.get_argument_count() < command_arguments.size():
			cprint(registered_command + " Has too many params", Color.RED)
	
	elif !called_command.is_valid():
		cprint("The command you have typed could not be found", Color.RED)
	
	line_edit.clear()

## Automatically scrolls the console_log_container to the bottom when a new child object is added to the container
func _auto_scroll() -> void:
	if max_scroll_length != console_log_container.get_v_scroll_bar().max_value:
		console_log_container.get_v_scroll_bar().value = console_log_container.get_v_scroll_bar().max_value
		max_scroll_length = console_log_container.get_v_scroll_bar().max_value