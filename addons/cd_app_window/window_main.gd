@tool
extends Control

@onready var window_topbar: PanelContainer = %window_topbar
@onready var window_title: Label = %window_title
@onready var border_overlay: PanelContainer = %border_overlay
@onready var window_content: PanelContainer = %window_content
@onready var window_icon: TextureRect = %window_icon
@onready var window_handles: Control = %window_handles

var is_ready:bool = false
func _ready() -> void:
	is_ready = true
	set_scene(self.owner.active_scene)
	set_window_title(self.owner.window_title)
	set_min_size(self.owner.min_win_size)
	set_bar_colour(self.owner.titlebar_colour)
	set_animation_speed(self.owner.animation_duration)
	set_border_radius(self.owner.border_radius)
	set_resizable(self.owner.resizable)
	set_app_icon(self.owner.app_icon)

func set_to_scene(new_scene:Node)->void:
	for node:Node in window_content.get_children():
		node.queue_free()
	
	window_content.add_child(new_scene)


func set_scene(value:PackedScene)->void:
	if(is_ready || Engine.is_editor_hint()) && value != null:
		var scene:Node = value.instantiate()
		window_content.add_child(scene)
		scene.owner = window_content

func set_window_title(value:String)->void:
	if(is_ready || Engine.is_editor_hint()):
		window_title.text = value

func set_app_icon(value:String)->void:
	if(!value.is_empty() && CDUtils.file_exists(value)):
		window_icon.texture = load(value)

func set_bar_colour(background:Color)->void:
	if(is_ready || Engine.is_editor_hint()):
		window_topbar.self_modulate = background
		window_title.add_theme_color_override("font_color", CDUtils.contrast_text(background))
		window_content.self_modulate = background
		border_overlay.self_modulate = background

func set_border_radius(value:float)->void:
	var con_stylebox:StyleBoxFlat = window_content.get_theme_stylebox("panel")
	con_stylebox.corner_radius_bottom_left = value
	con_stylebox.corner_radius_bottom_right = value
	var overlay_stylebox:StyleBoxFlat = border_overlay.get_theme_stylebox("panel")
	overlay_stylebox.corner_radius_bottom_left = value
	overlay_stylebox.corner_radius_bottom_right = value
	overlay_stylebox.corner_radius_top_left = value
	overlay_stylebox.corner_radius_top_right = value
	var bar_stylebox:StyleBoxFlat = window_topbar.get_theme_stylebox("panel")
	bar_stylebox.corner_radius_top_left = value
	bar_stylebox.corner_radius_top_right = value

func set_min_size(value:Vector2i = Vector2i(670, 500))->void:
	if(is_ready || Engine.is_editor_hint() && value > Vector2i(0,0)):
		get_window().min_size = value

func set_resizable(value:bool = true)->void:
	if(value):
		window_handles.show()
	else:
		window_handles.hide()

func set_animation_speed(value:float = 0.25)->void:
	if(is_ready || Engine.is_editor_hint()):
		window_topbar.MAXIMIZE_SPEED = value
