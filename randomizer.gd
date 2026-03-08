@tool
class_name RandomizerMenu
extends Container

const KEYS = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

const INSTRUMENT_TYPES = [
	"wavsynth",
	"macrosyn",
	"sampler",
	"fmsynth",
	"hyprsyn"
]

const FX_COMMANDS = [
	"ARP",
	"DEL",
	"GRV",
	"INS",
	"HOP",
	"NXT",
	"PVB",
	"PVX",
	"CHA",
	"RAN",
	"RNL",
	"ERR",
	"NTH",
	"RET",
	"REP",
	"RTO",
	"RMX",
	"PSL",
	"PBN",
	"SNG",
	"SED",
	"TBL",
	"THO",
	"TIC",
	"TBX",
	"TPO",
]


@onready var tree: RandomizerTree = %Tree
@onready var header: HBoxContainer = %Header
@onready var button_generate: Button = %ButtonGenerate
@onready var label_output: RichTextLabel = %LabelOutput
@onready var stylebox_output: StyleBoxFlat  = (%PanelOutput as PanelContainer).get_theme_stylebox("panel")
@onready var samples_popup: MarginContainer = %SamplesPopup
@onready var line_edit_seed: LineEditSeed = %LineEditSeed
@onready var button_copy_seed: Button = %ButtonCopySeed
@onready var button_load_config: Button = %ButtonLoadConfig

@onready var button_show_sample_popup: Button = %ButtonShowSamplePopup
@onready var code_edit_sample_pool: CodeEdit = %CodeEditSamplePool
@onready var code_edit_challenge_pool: CodeEdit = %CodeEditChallengePool
@onready var code_edit_theme_pool: CodeEdit = %CodeEditThemePool
@onready var text_edit_config: TextEdit = %TextEditConfig

var sample_pool: Array
var scales_5_pool: Array = read_lines("res://scales_5.txt")
var scales_6_pool: Array = read_lines("res://scales_6.txt")
var scales_7_pool: Array = read_lines("res://scales_7.txt")
var scales_8_pool: Array = read_lines("res://scales_8.txt")
var scales_9_pool: Array = read_lines("res://scales_9.txt")
var custom_challenge_pool: Array
var custom_theme_pool: Array
var sample_challenge_pool: Array = read_lines("res://challenges_samples.txt")
var sound_design_challenge_pool: Array = read_lines("res://challenges_sound_design.txt")

var data_theme_words: Array = read_lines("res://theme_words.txt")
var data_theme_words_left: Array = read_lines("res://theme_words_left.txt")
var data_theme_words_right: Array = read_lines("res://theme_words_right.txt")

func read_sample_pool_from_textbox() -> void:
	var text := self.code_edit_sample_pool.text.strip_edges()
	var paths := Array(text.split("\n")).filter(is_valid_sample_path)
	self.sample_pool = paths
	self.tree.get_item("pick_samples/enabled").set_text(1, "%d in pool" % self.sample_pool.size())

func read_challenge_pool_from_textbox() -> void:
	var text := self.code_edit_challenge_pool.text.strip_edges()
	var challenges := Array(text.split("\n")).filter(func(line: String) -> bool:
		return !line.is_empty() or line.begins_with("#")
	)
	self.custom_challenge_pool = challenges

func read_theme_pool_from_textbox() -> void:
	var text := self.code_edit_theme_pool.text.strip_edges()
	var themes := Array(text.split("\n")).filter(func(line: String) -> bool:
		return !line.is_empty() or line.begins_with("#")
	)
	self.custom_theme_pool = themes

func is_valid_sample_path(path: String) -> bool:
	path = path.replace("\\", "/").simplify_path()
	if path.is_empty():
		return false
	if path.begins_with("#"):
		return false
	for part in path.split("/"):
		if part.begins_with("."):
			return false
	return true

func _ready() -> void:

	self.button_generate.pressed.connect(generate)

	self.code_edit_sample_pool.focus_exited.connect(read_sample_pool_from_textbox)
	read_sample_pool_from_textbox()

	self.code_edit_challenge_pool.text = read_text("res://challenges.txt")
	self.code_edit_challenge_pool.focus_exited.connect(read_challenge_pool_from_textbox)
	read_challenge_pool_from_textbox()

	self.code_edit_theme_pool.text = read_text("res://custom_themes.txt")
	self.code_edit_theme_pool.focus_exited.connect(read_theme_pool_from_textbox)
	read_theme_pool_from_textbox()

	self.button_show_sample_popup.pressed.connect(func() -> void:
		self.samples_popup.show()
	)

	self.button_copy_seed.pressed.connect(func() -> void:
		line_edit_seed.copy_to_clipboard()
	)

	self.text_edit_config.visibility_changed.connect(func() -> void:
		if self.text_edit_config.visible:
			self.text_edit_config.text = self.tree.get_config().encode_to_text()
	)
	self.button_load_config.pressed.connect(func() -> void:
		if self.text_edit_config.visible:
			var config_text := self.text_edit_config.text
			var new_config := RandomizerConfigFile.new()
			var err := new_config.parse(config_text)
			if err == OK:
				self.tree.set_config(new_config)
				self.button_load_config.text = "Config loaded!"
			else:
				print("Failed to parse config: %s" % err)
				self.button_load_config.text = "Invalid config!"
			await get_tree().create_timer(1.0).timeout
			self.button_load_config.text = "Load from Textbox"
	)

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		for c: Control in get_children():
			fit_child_in_rect(c, Rect2(Vector2.ZERO, get_size()))

func generate() -> void:

	seed(self.line_edit_seed.generate_seed())

	var tween := get_tree().create_tween()
	
	var bg_color := Color.from_ok_hsl(randf(), randf_range(0.0, 0.7), randf_range(0.0, 0.3))
	var fg_color := Color.from_ok_hsl(randf(), randf_range(0.0, 0.7), randf_range(0.7, 1.0))

	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(true)
	tween.tween_property(stylebox_output, "bg_color", bg_color, 0.5)
	tween.tween_property(label_output, "theme_override_colors/default_color", fg_color, 0.5)

	var rando_options := self.tree.get_config()

	label_output.clear()

	if rando_options.get("theme/enabled"):
		var theme: String
		# print("generate chance: %d" % rando_options.get("theme/generate_chance"))
		# print("theme pool size: %d" % self.custom_theme_pool.size())
		if randi_range(0, 99) < rando_options.get("theme/generate_chance") or self.custom_theme_pool.size() == 0:
			theme = generate_theme()
		else:
			theme = self.custom_theme_pool.pick_random()
		label_output.append_text("[b]Theme:[/b] %s\n" % theme.to_upper())

	if rando_options.get("tempo/enabled"):
		label_output.append_text("[b]Tempo:[/b] %s bpm\n" % pick_tempo(rando_options))

	if rando_options.get("scale/enabled"):
		label_output.append_text("[b]Scale:[/b] %s\n" % pick_scale(rando_options))

	if rando_options.get("pick_samples/enabled") and self.sample_pool.size() > 0:
		var num_samples_to_pick := int(rando_options.get("pick_samples/amount"))
		label_output.append_text("[b]Samples:[/b]\n")
		for i in num_samples_to_pick:
			label_output.append_text("- %s\n" % self.sample_pool.pick_random())

	if rando_options.get("challenges/enabled") and (rando_options.get("challenges/track_restrict") or rando_options.get("challenges/instrument_type_restrict") or rando_options.get("challenges/instrument_amount_restrict") or rando_options.get("challenges/fx_command_require") or rando_options.get("challenges/sample_kind_require") or rando_options.get("challenges/synth_kind_require") or (rando_options.get("challenges/custom") and self.custom_challenge_pool.size() > 0)):
		label_output.append_text("[b]Challenges:[/b]\n")
		for i in int(rando_options.get("challenges/amount")):
			label_output.append_text("- %s\n" % pick_challenge(rando_options))

func pick_tempo(rando_options: RandomizerConfigFile) -> int:
	return randi_range(rando_options.get("tempo/min"), rando_options.get("tempo/max"))

func pick_scale(rando_options: RandomizerConfigFile) -> String:
	var scales_pool: Array
	if rando_options.get("scale/5_enabled"):
		scales_pool.append_array(self.scales_5_pool)
	if rando_options.get("scale/6_enabled"):
		scales_pool.append_array(self.scales_6_pool)
	if rando_options.get("scale/7_enabled"):
		scales_pool.append_array(self.scales_7_pool)
	if rando_options.get("scale/8_enabled"):
		scales_pool.append_array(self.scales_8_pool)
	if rando_options.get("scale/9_enabled"):
		scales_pool.append_array(self.scales_9_pool)
	if rando_options.get("scale/chromatic_enabled"):
		scales_pool.append("CHROMATIC")

	var mode: int = rando_options.get("scale/mode")
	if scales_pool.size() == 0:
		mode = 1

	var rand_key: String = KEYS.pick_random()
	var scale: String = ""
	match mode:
		0:
			scale = "%s, %s" % [rand_key, scales_pool.pick_random()]
		1:
			scale = "Any scale in %s" % rand_key
		2:
			scale = "%s in any key" % scales_pool.pick_random()

	assert(scale != "")
	return scale

func generate_theme() -> String:
	var left_words := self.data_theme_words_left.duplicate()
	left_words.append_array(self.data_theme_words.duplicate())
	var right_words := self.data_theme_words_right.duplicate()
	right_words.append_array(self.data_theme_words.duplicate())

	var word_a: String = left_words.pick_random()
	var word_b: String = right_words.pick_random()
	while word_a == word_b or word_a.ends_with("s") or word_a.length() + word_b.length() > 12:
		word_a = left_words.pick_random()
		word_b = right_words.pick_random()

	return "%s%s" % [word_a, word_b]

func pick_challenge(rando_options: RandomizerConfigFile) -> String:
	match randi_range(0, 6):
		0:  # track restriction
			if not rando_options.get("challenges/track_restrict"):
				return pick_challenge(rando_options)
			return "can only use at most %d track(s)" % randi_range(1, 4)

		1:  # instrument type restriction
			if not rando_options.get("challenges/instrument_type_restrict"):
				return pick_challenge(rando_options)
			var num_types := randi_range(1, INSTRUMENT_TYPES.size() - 1)
			if randf() < 0.25:
				return "can only use %d instrument type(s) of your choice" % num_types
			var types := INSTRUMENT_TYPES.duplicate()
			types.shuffle()
			while types.size() > num_types:
				types.pop_back()
			return "can only use these instrument type(s): %s" % ", ".join(types)

		2:  # instrument amount restriction
			if not rando_options.get("challenges/instrument_amount_restrict"):
				return pick_challenge(rando_options)
			return "can only use at most %d instrument(s)" % randi_range(1, 16)

		3:  # FX command requirement
			if not rando_options.get("challenges/fx_command_require"):
				return pick_challenge(rando_options)
			var num_types := randi_range(1, 4)
			var types := FX_COMMANDS.duplicate()
			types.shuffle()
			while types.size() > num_types:
				types.pop_back()
			return "must use these FX command(s): %s" % ", ".join(types)

		4:  # sample kind requirement
			if not rando_options.get("challenges/sample_kind_require"):
				return pick_challenge(rando_options)
			return "must use/record a sample of: %s" % self.sample_challenge_pool.pick_random()

		5:  # synth kind requirement
			if not rando_options.get("challenges/synth_kind_require"):
				return pick_challenge(rando_options)
			return "must use/create a synth that sounds like: %s" % self.sound_design_challenge_pool.pick_random()

		_:  # custom challenge
			if not rando_options.get("challenges/custom") or self.custom_challenge_pool.size() == 0:
				return pick_challenge(rando_options)
			return "%s" % self.custom_challenge_pool.pick_random()

static func read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		file.close()
		return content
	return ""

static func read_lines(path: String) -> Array:
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		file.close()
		var array := Array(content.split("\n")).filter(func(line: String) -> bool:
			return line.strip_edges() != "" and not line.begins_with("#")
		)
		return array
	return []
