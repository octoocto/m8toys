class_name RandomizerTree
extends Tree

var config: RandomizerConfigFile = RandomizerConfigFile.new()
var item_map: Dictionary[StringName, TreeItem] = {}

func _ready() -> void:
	_init_tree()

	self.item_edited.connect(func() -> void:
		var item := self.get_edited()
		var prop: StringName = item.get_metadata(0)
		match prop:
			"theme/generate_chance":
				item_map["theme/custom_chance"].set_range(1, 100 - item.get_range(1))
				config.set("theme/custom_chance", 100 - item.get_range(1))
			"theme/custom_chance":
				item_map["theme/generate_chance"].set_range(1, 100 - item.get_range(1))
				config.set("theme/generate_chance", 100 - item.get_range(1))
		
		match item.get_cell_mode(0):
			TreeItem.CELL_MODE_CHECK:
				config.set(prop, item.is_checked(0))

		match item.get_cell_mode(1):
			TreeItem.CELL_MODE_RANGE:
				print("range changed: %s = %s" % [prop, item.get_range(1)])
				if config.get(prop) is int:
					config.set(prop, int(item.get_range(1)))
				elif config.get(prop) is float:
					config.set(prop, item.get_range(1))
	)

	_set_collapsed_all(true)

func get_config() -> RandomizerConfigFile:
	return config

func set_config(config: RandomizerConfigFile) -> void:
	self.config = config
	_update_from_config()

func get_item(key: StringName) -> TreeItem:
	assert(key in self.item_map)
	return self.item_map[key]

func _set_collapsed_all(collapse: bool) -> void:
	var it := get_root().get_first_child()
	while it:
		it.set_collapsed_recursive(collapse)
		it = it.get_next()

func _init_tree() -> void:
	var root := self.create_item()

	_create_item_check(root, "theme/enabled", "Enable Theme")
	_create_item_check(root, "tempo/enabled", "Enable Tempo")
	_create_item_check(root, "scale/enabled", "Enable Scale")
	_create_item_check(root, "challenges/enabled", "Enable Challenges")
	_create_item_check(root, "pick_samples/enabled", "Enable Pick Samples")

	_create_item_rangei("tempo/enabled", "tempo/min",
		"Min tempo", 10, 999
	)
	_create_item_rangei("tempo/enabled", "tempo/max",
		"Max tempo", 10, 999
	)

	_create_item_rangei("pick_samples/enabled", "pick_samples/amount",
		"Number of samples to pick", 1, 20
	)

	_create_item_option("scale/enabled", "scale/mode",
		"Randomize", ["Key & Scale", "Key Only", "Scale Only"]
	)
	_create_item_check("scale/enabled", "scale/5_enabled", "Include 5 note scales")
	_create_item_check("scale/enabled", "scale/6_enabled", "Include 6 note scales")
	_create_item_check("scale/enabled", "scale/7_enabled", "Include 7 note scales")
	_create_item_check("scale/enabled", "scale/8_enabled", "Include 8 note scales")
	_create_item_check("scale/enabled", "scale/9_enabled", "Include 9-10 note scales")
	_create_item_check("scale/enabled", "scale/chromatic_enabled", "Include chromatic scale")

	_create_item_rangei("theme/enabled", "theme/custom_chance",
		"Custom theme chance (%)", 0, 100
	)
	_create_item_rangei("theme/enabled", "theme/generate_chance",
		"Generated theme chance (%)", 0, 100
	)

	_create_item_rangei("challenges/enabled", "challenges/amount",
		"Number of challenges", 1, 5
	)

	_create_item_check("challenges/enabled", "challenges/track_restrict", "Include track restrictions")
	_create_item_check("challenges/enabled", "challenges/instrument_type_restrict", "Include instrument type restrictions")
	_create_item_check("challenges/enabled", "challenges/instrument_amount_restrict", "Include instrument amount restrictions")
	_create_item_check("challenges/enabled", "challenges/fx_command_require", "Include FX command requirements")
	_create_item_check("challenges/enabled", "challenges/sample_kind_require", "Include sample kind requirements")
	_create_item_check("challenges/enabled", "challenges/synth_kind_require", "Include synth kind requirements")
	_create_item_check("challenges/enabled", "challenges/custom", "Include custom challenges")

func _update_from_config() -> void:
	for key: String in self.item_map.keys():
		var item := self.item_map[key]
		match item.get_cell_mode(0):
			TreeItem.CELL_MODE_CHECK:
				item.set_checked(0, config.get(key))

		match item.get_cell_mode(1):
			TreeItem.CELL_MODE_RANGE:
				if config.get(key) is int:
					item.set_range(1, config.get(key))
				elif config.get(key) is float:
					item.set_range(1, config.get(key))

func _create_item(parent: Variant, key: StringName) -> TreeItem:
	assert(key in config)
	var parent_item: TreeItem
	if parent is String:
		assert(parent in self.item_map)
		parent_item = self.item_map[parent]
	else:
		assert(parent is TreeItem)
		parent_item = parent

	var item := self.create_item(parent_item)
	item.set_metadata(0, key)
	self.item_map[key] = item
	return item

func _create_item_rangei(parent: Variant, key: String, text: String, range_min: int, range_max: int) -> TreeItem:
	var item := _create_item(parent, key)
	item.set_text(0, text)
	item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	item.set_range_config(1, range_min, range_max, 1, false)
	item.set_range(1, self.config.get(key))
	item.set_editable(1, true)
	return item

func _create_item_check(parent: Variant, key: String, text: String) -> TreeItem:
	var item := _create_item(parent, key)
	item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	item.set_text(0, text)
	item.set_checked(0, self.config.get(key))
	item.set_editable(0, true)
	return item

func _create_item_option(parent: Variant, key: String, text: String, item_options: PackedStringArray) -> TreeItem:
	var item := _create_item(parent, key)
	item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	item.set_text(0, text)
	item.set_text(1, ",".join(item_options))
	item.set_range(1, self.config.get(key))
	item.set_editable(1, true)
	return item
