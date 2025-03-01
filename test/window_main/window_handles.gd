extends Control

@onready var right:Control = $right
@onready var left:Control = $left
@onready var top:Control = $top
@onready var bottom:Control = $bottom
@onready var top_right_corner:Control = $top_right_corner
@onready var bottom_right_corner:Control = $bottom_right_corner
@onready var top_left_corner:Control = $top_left_corner
@onready var bottom_left_corner:Control = $bottom_left_corner

const DEFAULT_SIZE:Vector2i = Vector2i(670, 500)

func _ready()->void:
	right.gui_input.connect(_on_right_gui)
	left.gui_input.connect(_on_left_gui)
	top.gui_input.connect(_on_top_gui)
	bottom.gui_input.connect(_on_bottom_gui)
	top_right_corner.gui_input.connect(_on_top_right)
	top_left_corner.gui_input.connect(_on_top_left)
	bottom_right_corner.gui_input.connect(_on_bottom_right)
	bottom_left_corner.gui_input.connect(_on_bottom_left)

func _on_right_gui(event:InputEvent)->void:
	_gui_input_handling(event, right)

func _on_left_gui(event:InputEvent)->void:
	_gui_input_handling(event, left)

func _on_top_gui(event:InputEvent)->void:
	_gui_input_handling(event, top)

func _on_bottom_gui(event:InputEvent)->void:
	_gui_input_handling(event, bottom)

func _on_top_right(event:InputEvent)->void:
	_gui_input_handling(event, top_right_corner)

func _on_bottom_right(event:InputEvent)->void:
	_gui_input_handling(event, bottom_right_corner)

func _on_top_left(event:InputEvent)->void:
	_gui_input_handling(event, top_left_corner)

func _on_bottom_left(event:InputEvent)->void:
	_gui_input_handling(event, bottom_left_corner)


var resizing:bool = false
var resize_node:Control
func _gui_input_handling(event:InputEvent, node:Control)->void:
	if(DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_MAXIMIZED, DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN] ):
		self.hide()
		return
	
	if(event is InputEventMouseButton && event.button_index == 1):
		if(!resizing):
			resize_node = node
		resizing = event.is_pressed()
	
	if(event is InputEventMouseMotion && resizing):
		#var scene = get_tree().current_scene
		if(resize_node in [top, top_right_corner, top_left_corner]):
			get_window().size.y -= event.relative.y
			if(get_window().size.y > DEFAULT_SIZE.y):
				#await get_tree().process_frame
				get_window().position.y += roundi(event.relative.y)
		if(resize_node in [bottom, bottom_right_corner, bottom_left_corner]):
			get_window().size.y += event.relative.y
		if(resize_node in [right, bottom_right_corner, top_right_corner]):
			get_window().size.x += event.relative.x
		if(resize_node in [left, bottom_left_corner, top_left_corner]):
			get_window().size.x -= event.relative.x
			if(get_window().size.x > DEFAULT_SIZE.x):
				#await get_tree().process_frame
				get_window().position.x += roundi(event.relative.x)
