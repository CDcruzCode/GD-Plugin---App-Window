@tool
extends EditorPlugin

var undo_redo:EditorUndoRedoManager

func _enter_tree() -> void:
	add_custom_type("CDAppWindow", "Control", preload("init.gd"), preload("icon.svg"))
	pass


func _exit_tree() -> void:
	remove_custom_type("CDAppWindow")
	self.queue_free()
