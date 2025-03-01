##A custom node designed to provide enhanced control over your application's window. For optimal functionality, ensure that the 'borderless' option is set to true in ProjectSettings.
@tool
class_name CDAppWindow
extends Control

# General settings
@export_group("General")
##The name of your app that appears in the titlebar.
@export var window_title: String = "App Window":
	set(value):
		window_title = value
		if(_window_inst):
			_window_inst.set_window_title(value)
##The current scene that is loaded
@export var active_scene: PackedScene:
	set(value):
		active_scene = value
		if(_window_inst):
			_window_inst.set_scene(value)
# Design settings
@export_group("Design")
##The icon that will appear in the titlebar.
@export_file("*.png","*jpg","*jpeg","*.svg") var app_icon:String = "res://addons/cd_app_window/icon.svg":
		set(value):
			app_icon = value
			if(_window_inst):
				_window_inst.set_app_icon(value)
##The titlebar colour.
@export var titlebar_colour: Color = Color("#202020"):
	set(value):
		titlebar_colour = value
		if(_window_inst):
			_window_inst.set_bar_colour(value)
##The size of the windows rounded corners. In pixels.
@export_range(0.0, 10.0, 1.0, "hide_slider") var border_radius:int = 0:
	set(value):
			border_radius = value
			if(_window_inst):
				_window_inst.set_border_radius(value)
##The minimum size that the app window can be resized to.
@export var min_win_size:Vector2i = Vector2i(670, 500)
#Behaviour settings
@export_group("Behaviour")
##When true, allows the app window to be resizable.
@export var resizable: bool = true
##The duration for window animations like maximizing the window.
@export_range(0.1, 5.0, 0.01, "hide_slider") var animation_duration: float = 0.25


const _CD_APP_WINDOW:PackedScene = preload("res://addons/cd_app_window/cd_app_window.tscn")
var _window_inst:Control

func _enter_tree() -> void:
	if(!Engine.is_editor_hint()):
		_window_inst = self.get_node("window_main")
		return
	
	_window_inst = self.get_node_or_null("window_main")
	#Make sure Project Settings are set to the right settings for making the window look correct.
	ProjectSettings.set_setting("display/window/size/transparent", true)
	ProjectSettings.set_setting("display/window/per_pixel_transparency/allowed", true)
	ProjectSettings.set_setting("rendering/viewport/transparent_background", true)
	get_tree().get_root().set_transparent_background(true)
	
	if(_window_inst != null):
		return
	
	self.set_anchors_preset(PRESET_FULL_RECT)
	self.anchor_left = 0
	self.anchor_top = 0
	self.anchor_right = 1
	self.anchor_bottom = 1
	self.offset_left = 0
	self.offset_top = 0
	self.offset_right = 0
	self.offset_bottom = 0
	
	_window_inst = _CD_APP_WINDOW.instantiate()
	self.add_child(_window_inst, false, Node.INTERNAL_MODE_FRONT)
	_window_inst.owner = get_tree().edited_scene_root
	self.set_editable_instance(_window_inst, false)
	
	_window_inst.title = window_title
	if(active_scene!=null):
		_window_inst.get_node("%window_content").add_child(active_scene.instantiate())
		_window_inst.ready_scene = active_scene

func _ready() -> void:
	if(Engine.is_editor_hint()):
		return
	
	#Make sure Project Settings are set to the right settings for making the window look correct.
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	ProjectSettings.set_setting("display/window/size/transparent", true)
	ProjectSettings.set_setting("display/window/per_pixel_transparency/allowed", true)
	ProjectSettings.set_setting("rendering/viewport/transparent_background", true)
	get_tree().get_root().set_transparent_background(true)
	
	_window_inst.owner = get_tree().edited_scene_root


#----ACESSIBLE FUNCTIONS----#
##Cleanly switch the window's content
static func set_scene(scene_path: String) -> void:
	if not CDUtils.file_exists(scene_path):
		printerr("[CDAppWindow] set_scene: Scene file does not exist at path: %s" % scene_path)
		return
	
	var app_window:CDAppWindow = get_app_window()
	if(app_window == null):
		printerr("[CDAppWindow] set_scene: could not access CDAppWindow")
		return
	
	if(app_window._window_inst == null):
		return
	
	var scene_resource = ResourceLoader.load(scene_path)
	if scene_resource is PackedScene:
		var scene_instance:Node = scene_resource.instantiate()
		app_window._window_inst.set_to_scene(scene_instance)
		print("[CDAppWindow] set_scene: Scene loaded successfully from path: %s" % scene_path)
	else:
		printerr("[CDAppWindow] set_scene: Failed to load scene from path: %s" % scene_path)


##Returns the main CD App Window. This should be located as the first node of the entire tree (After the root node).
static func get_app_window() -> CDAppWindow:
	var tree = Engine.get_main_loop() as SceneTree
	if(tree.get_root().get_child(0) is CDAppWindow):
		return tree.get_root().get_child(0)
	printerr("[CDAppWindow] get_app_window: No window found.")
	return null
