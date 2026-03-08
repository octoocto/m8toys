extends RichTextLabel

func _ready() -> void:
	self.meta_clicked.connect(func(meta: Variant) -> void:
		OS.shell_open(str(meta))
	)
