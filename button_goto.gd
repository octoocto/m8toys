class_name GotoButton
extends Button

@export var target_node: NodePath
@export var hide_if_target_visible: bool = false
@export var title_text: String = ""

func _ready() -> void:
	self.pressed.connect(func() -> void:
		if not target_node.is_empty():
			(get_node(target_node) as Control).show()
			if get_tree().current_scene is Main:
				(get_tree().current_scene as Main).set_title(title_text)
	)

func _physics_process(_delta: float) -> void:
	if hide_if_target_visible and not target_node.is_empty():
		visible = not (get_node(target_node) as Control).is_visible()
