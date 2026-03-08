class_name Main
extends PanelContainer

@onready var header: HBoxContainer = %Header
@onready var label_title: Label = %LabelTitle
@onready var tab_main: Control = %TabMain
@onready var tab_randomizer: RandomizerMenu = %TabRandomizer

func _ready() -> void:
	get_window().content_scale_factor = DisplayServer.screen_get_scale(DisplayServer.SCREEN_OF_MAIN_WINDOW)

	if get_arg("p") == "randomizer":
		tab_randomizer.show()
		set_title("M8 Randomizer")
	else:
		tab_main.show()
		set_title("")

func set_title(new_title: String) -> void:
	label_title.text = new_title
	if new_title.is_empty():
		header.hide()
	else:
		header.show()

func get_arg(arg_name: String) -> Variant:
	return JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('%s')" % arg_name)
