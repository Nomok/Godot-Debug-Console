extends VBoxContainer

# TODO: should probably put this in a singleton later so this can be in the main menu

@onready var line_edit: LineEdit = $LineEdit
@onready var console_log_container: VBoxContainer = $ConsoleLog/VBoxContainer

var console_visible: bool = false
var command_history: PackedStringArray = []
var command_index : int = -1 #

func _ready() -> void:
	self.visible = console_visible
	line_edit.text_submitted.connect(_console_command_entered)

## Prints a string to the debug console.
func cprint(text_input: String, text_color: Color = Color.WHITE) -> void:
	var new_text: RichTextLabel = RichTextLabel.new()
	console_log_container.add_child(new_text)
	new_text.owner = console_log_container
	new_text.fit_content = true
	new_text.add_text(text_input)
	new_text.modulate = text_color

# Toggle for visible and input acceptance
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
	
	# This is broken and needs to be refactored at some point
	if event.is_action_pressed("ui_focus_next") and console_visible:
		get_viewport().set_input_as_handled() # Mark the input as handled so the Text node ignores it
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
	ConsoleCommands.called_command = Callable(ConsoleCommands, registered_command)
	
	# Adds the typed command whether incorrect or not into the command history 
	if !command_history.has(command): command_history.push_back(command)
	
	cprint(">" + command, Color.GRAY)
	
	#This clears all previous parameters in the packedstringarray that may have been leftover in a previously typed in command 
	#and registers the new command parameters in the packedstringarray while also seperating each of the parameters
	ConsoleCommands.arguments.clear()
	ConsoleCommands.arguments = command.split(" ", false, 0)
	ConsoleCommands.arguments.remove_at(0)
	
	if ConsoleCommands.called_command.is_valid():
		if ConsoleCommands.called_command.get_argument_count() == ConsoleCommands.arguments.size():
			ConsoleCommands.called_command.callv(ConsoleCommands.arguments)
			cprint(ConsoleCommands.output_console_text, Color.WHITE)
			
		elif ConsoleCommands.called_command.get_argument_count() > ConsoleCommands.arguments.size():
			cprint(registered_command + " Has missing params", Color.RED)
		
		elif ConsoleCommands.called_command.get_argument_count() < ConsoleCommands.arguments.size():
			cprint(registered_command + " Has too many params", Color.RED)
	
	elif !ConsoleCommands.called_command.is_valid():
		cprint("The command you have typed could not be found", Color.RED)
	
	line_edit.clear()
