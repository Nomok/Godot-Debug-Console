extends VBoxContainer

# TODO: should probably put this in a singleton later so this can be in the main menu

@onready var debug_menu: Control = $".."
@onready var line_edit: LineEdit = $LineEdit
@onready var console_log_cotainer: VBoxContainer = $ConsoleLog/VBoxContainer

var console_menu_visible:bool = false
var command_history:PackedStringArray = []
var command_index : int = -1

func _ready() -> void:
	line_edit.text_submitted.connect(_console_command_entered)

## Prints a string to the debug console.
func cprint(text: String, text_color: Color = Color.WHITE) -> void:
	var new_text = RichTextLabel.new()
	console_log_cotainer.add_child(new_text)
	new_text.owner = console_log_cotainer
	new_text.fit_content = true
	new_text.add_text(text)
	new_text.modulate = text_color
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_console"):
		console_menu_visible =! console_menu_visible
		
		# This whole method is coded like shit but fuck it, should be readable enough for who reads it 
		# should also be performant unless some dumbass is inputing the console key inhumanely fast
		if console_menu_visible:
			# The await is here because without it inputs "`" when it first launches and I don't like it okay. 
			await get_tree().process_frame
			# Pass in your method for player control toggle if needed
			# Example:
			#GameState.player_ref.movement_enabled = false
			#GameState.player_ref.set_process_unhandled_input(false)
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			debug_menu.set_mouse_behavior_recursive(debug_menu.MOUSE_BEHAVIOR_ENABLED)
			line_edit.grab_focus(true)
			self.visible = true
		else:
			# Pass in your method for player control toggle if needed
			# Example:
			#GameState.player_ref.movement_enabled = true
			#GameState.player_ref.set_process_unhandled_input(true)
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			debug_menu.set_mouse_behavior_recursive(debug_menu.MOUSE_BEHAVIOR_DISABLED)
			line_edit.grab_focus(false)
			self.visible = false
			line_edit.clear()
			#resets the command selection index when closing the console
			command_index = -1
			
	if event.is_action_pressed("ui_focus_next") and !command_history.is_empty() and console_menu_visible:
			if command_index < command_history.size() - 1: command_index += 1
			else: command_index = 0
			line_edit.text = command_history[command_index]
			line_edit.caret_column = line_edit.text.length()
			
	elif event is InputEventKey and event.is_pressed() and line_edit.is_editing() and command_index != -1:
			command_index = -1
			
func _console_command_entered(command: String) -> void:
	#Sees if the command typed in the text input in the console matches a function name and its arguments found in scr_consolecommands
	var registered_command: String = command.get_slice(" ", 0)
	ConsoleCommands.called_command = Callable(ConsoleCommands, registered_command)
	
	#Adds the typed command whether incorrect or not into the command history 
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
