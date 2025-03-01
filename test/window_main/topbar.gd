extends PanelContainer

@onready var window_handles:Control = %window_handles
@onready var window_minimize_button:Button = $hbox/window_minimize_button
@onready var window_maximize_button:Button = $hbox/window_maximize_button
@onready var window_close_button:Button = $hbox/window_close_button
@onready var top_spacer:ColorRect = $"../../window_layout/top_spacer"
@onready var window_title:Label = %window_title

signal close_window_request

func _ready():
	get_window().min_size = Vector2i(670,500)
	DisplayServer.window_set_size(Vector2i(1250, 700))
	center_window()
	self.gui_input.connect(_moving_window)
	window_minimize_button.pressed.connect(func()->void: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED))
	window_maximize_button.pressed.connect(_maximize_window)
	window_close_button.pressed.connect(_close_window)
	set_bar_colour(Color("#202020"))
	await get_tree().process_frame
	toggle_topbar()
	
	#DisplayServer.window_set_drop_files_callback(_window_event, 0)

func _window_event()->void:
	print("EVENT")

func toggle_topbar()->void:
	if(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN):
		self.hide()
		top_spacer.hide()
	else:
		self.show()
		top_spacer.show()

var moving:bool = false
var mouse_start:Vector2i
var mouse_offset:Vector2i = Vector2i(0,0)
func _moving_window(event:InputEvent)->void:
	if(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):
		if !moving:
			mouse_start = DisplayServer.mouse_get_position()
			mouse_offset = get_viewport().get_mouse_position()
		moving = event.is_pressed()
	
	#Double click top bar to maximize/ window
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		_maximize_window()
		moving = false
		return
	
	#Maximize windowed window when window is held at the top of the screen and let go
	if(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_released() && get_window().mode == Window.MODE_WINDOWED && DisplayServer.mouse_get_position().y <= 0):
		_maximize_window()
		moving = false
		return
	
	if(event is InputEventMouseMotion):
		if(moving):
			if(get_window().mode == Window.MODE_MAXIMIZED || get_window().mode == Window.MODE_FULLSCREEN):
				if(event.relative.x >= 5 || event.relative.y >= 5):
					mouse_offset.x = globals.scale_num_to_range(int(get_viewport().get_mouse_position().x), 0, get_window().size.x, 0, windowed_size.x)
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
					get_window().size = windowed_size
					window_handles.show()
					mouse_start = Vector2i( DisplayServer.mouse_get_position().x - mouse_offset.x, DisplayServer.mouse_get_position().y - mouse_offset.y )
					
			get_window().position = ( Vector2i( DisplayServer.mouse_get_position().x - mouse_offset.x , DisplayServer.mouse_get_position().y - mouse_offset.y ) )


#func _minimize_window(event:InputEvent)->void:
	#if(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed):
		#print("Minimize Window")
		##get_window().gui_release_focus()
		##window_minimize.release_focus()
		##await get_tree().process_frame
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

var windowed_size:Vector2i = Vector2i(670,500)
var windowed_position:Vector2i = Vector2i(0,0)
func _maximize_window()->void:
	match get_window().mode:
		Window.MODE_WINDOWED:
			windowed_position = get_window().position
			windowed_size = get_window().size
			window_handles.hide()
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		Window.MODE_MAXIMIZED, Window.MODE_FULLSCREEN:
			window_handles.show()
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			get_window().size = windowed_size
			get_window().position = windowed_position

func center_window():
	var actual_size:Vector2i = get_window().size
	var screen_size:Vector2i = DisplayServer.screen_get_size()
	var centered:Vector2i = Vector2i(screen_size.x / 2 - actual_size.x / 2, screen_size.y / 2 - actual_size.y / 2)
	get_window().position = centered

var can_close:bool = true
func _close_window()->void:
	print("Close Window Attempt")
	close_window_request.emit()
	if(can_close):
		get_tree().quit()


func set_bar_colour(background:Color)->void:
	self.self_modulate = background
	window_title.add_theme_color_override("font_color", globals.contrast_text(background))
