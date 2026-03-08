@tool
extends Button

@export_node_path("RichTextLabel") var target_label: NodePath

func _ready() -> void:
	self.pressed.connect(func() -> void:
		assert(target_label != null)
		var label := get_node(target_label) as RichTextLabel
		DisplayServer.clipboard_set(label.text)
		self.text = "Copied!"
		await get_tree().create_timer(1.0).timeout
		self.text = ""
	)
