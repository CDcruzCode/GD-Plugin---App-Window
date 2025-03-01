extends Control

const _2_ND_TEST:PackedScene = preload("res://2nd test.tscn")
@onready var button: Button = $Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("ASD")
	button.pressed.connect(func()->void: CDAppWindow.set_scene("res://2nd test.tscn") )
	CDAppWindow.get_app_window().titlebar_colour = Color.DARK_CYAN
	CDAppWindow.get_app_window().window_title = "CHANGED"
