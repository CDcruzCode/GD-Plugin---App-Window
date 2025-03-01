@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("CDUtils", "Node", preload("CDUtilsClass.gd"), preload("icon.svg"))
	pass


func _exit_tree() -> void:
	remove_custom_type("CDUtils")
	pass
