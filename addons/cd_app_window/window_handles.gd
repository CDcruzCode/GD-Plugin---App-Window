extends Control

var APP_MAIN:Control

@onready var right:Control = $right
@onready var left:Control = $left
@onready var top:Control = $top
@onready var bottom:Control = $bottom
@onready var top_right_corner:Control = $top_right_corner
@onready var bot_right_corner:Control = $bot_right_corner
@onready var top_left_corner:Control = $top_left_corner
@onready var bot_left_corner:Control = $bot_left_corner

var HANDLES:Array[Control]

var MIN_SIZE:Vector2i

func _ready()->void:
	APP_MAIN = self.owner.get_parent()
	MIN_SIZE = APP_MAIN.min_win_size
	HANDLES = [right, left, top, bottom, top_right_corner, bot_right_corner, top_left_corner, bot_left_corner]
	for control in HANDLES:
		if(!control.is_connected("gui_input", _gui_input_handler)):
			control.gui_input.connect(_gui_input_handler.bind(control))

var resizing:bool = false
var resize_node:Control
func _gui_input_handler(event: InputEvent, handle:Control) -> void:
	if(DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_MAXIMIZED, DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN] ):
		return
	
	var screen_mouse_pos:Vector2i = DisplayServer.mouse_get_position()
	
	if(event is InputEventMouseButton && event.button_index == 1):
		if(!resizing):
			resize_node = handle
		resizing = event.is_pressed()
	
	if event is InputEventMouseMotion and resizing:
		# Horizontal resizing:
		if resize_node in [right, top_right_corner, bot_right_corner]:
			var new_width = screen_mouse_pos.x - get_window().position.x
			get_window().size.x = max(new_width, MIN_SIZE.x)
		elif resize_node in [left, top_left_corner, bot_left_corner]:
			var resize_right = get_window().position.x + get_window().size.x
			var new_width = resize_right - screen_mouse_pos.x
			if new_width >= MIN_SIZE.x:
				get_window().position.x = screen_mouse_pos.x
				get_window().size.x = new_width
			else:
				get_window().position.x = resize_right - MIN_SIZE.x
				get_window().size.x = MIN_SIZE.x

		# Vertical resizing:
		if resize_node in [bottom, bot_left_corner, bot_right_corner]:
			var new_height = screen_mouse_pos.y - get_window().position.y
			get_window().size.y = max(new_height, MIN_SIZE.y)
		elif resize_node in [top, top_left_corner, top_right_corner]:
			var bottom_edge = get_window().position.y + get_window().size.y
			var new_height = bottom_edge - screen_mouse_pos.y
			if new_height >= MIN_SIZE.y:
				get_window().position.y = screen_mouse_pos.y
				get_window().size.y = new_height
			else:
				get_window().position.y = bottom_edge - MIN_SIZE.y
				get_window().size.y = MIN_SIZE.y
