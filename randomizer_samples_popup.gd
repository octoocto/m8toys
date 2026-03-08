extends MarginContainer

@onready var button_cancel: Button = %ButtonCancel
@onready var button_clipboard: Button = %ButtonClipboard

func _ready() -> void:
	button_cancel.pressed.connect(func() -> void:
		self.hide()
	)
	# button_clipboard.pressed.connect(func() -> void:
	# 	assert(get_parent() is RandomizerMenu)
	# 	var menu := get_parent() as RandomizerMenu
	# 	menu.set_sample_paths(get_clipboard().split("\n"))
	# 	self.hide()
	# )

func get_clipboard() -> String:
	# return DisplayServer.clipboard_get()
	var clipboard: Variant = JavaScriptBridge.eval("prompt('Paste sample paths (one per line)', '')")
	if typeof(clipboard) == TYPE_STRING:
		return clipboard
	else:
		return ""
