extends Control

@onready var fps_counter:Label = $Stats/PanelContainer/HBoxContainer/Label
@onready var memory_usage:Label = $Stats/PanelContainer2/HBoxContainer/Label
@onready var max_memory_usage:Label = $Stats/PanelContainer3/HBoxContainer/Label
@onready var video_mem:Label = $Stats/PanelContainer4/HBoxContainer/Label

# Check for if object is an autoloaded singleton
func is_autoload(node: Node) -> bool:
	var setting_path: String = "autoload/" + node.name
	if not ProjectSettings.has_setting(setting_path):
		return false
	var autoload_node: Node = get_node_or_null("/root/" + node.name)
	return autoload_node == node

# Gets rid of non-singleton instances of the object
func _ready() -> void:
	if not is_autoload(self):
		self.queue_free()

func _init() -> void:
	if !OS.is_debug_build():
		self.queue_free()
	
	#This function allows the viewmode_wireframe command to properly show wireframes at runtime
	RenderingServer.set_debug_generate_wireframes(true)

func _process(delta: float) -> void:
	
	fps_counter.text = "FPS: " + str(int(Performance.get_monitor(Performance.TIME_FPS)))
	
	#Lambda function that converts bytes into gigabytes
	var convert_bytes_to_gb: Callable = func(bytes: int) -> float:
		return float(snappedf(bytes / 1e+9, 0.01))
	
	memory_usage.text = "Static Memory Usage: " + str(convert_bytes_to_gb.call(Performance.get_monitor(Performance.MEMORY_STATIC))) + " GB"
	max_memory_usage.text = "Static Memory Peak Usage: " + str(convert_bytes_to_gb.call(Performance.get_monitor(Performance.MEMORY_STATIC_MAX))) + " GB"
	video_mem.text = "Video Memory Used: " + str(convert_bytes_to_gb.call(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))) + " GB"
