class_name RandomizerConfigFile
extends ConfigFile

const SCALE_MODE_BOTH = 0
const SCALE_MODE_KEY_ONLY = 1
const SCALE_MODE_SCALE_ONLY = 2

func _init() -> void:
	set_value("theme", "enabled", false)
	set_value("theme", "generate_chance", 70)
	set_value("theme", "custom_chance", 30)

	set_value("tempo", "enabled", true)
	set_value("tempo", "min", 60)
	set_value("tempo", "max", 180)

	set_value("scale", "enabled", true)
	set_value("scale", "mode", SCALE_MODE_BOTH)
	set_value("scale", "5_enabled", false)
	set_value("scale", "6_enabled", false)
	set_value("scale", "7_enabled", true)
	set_value("scale", "8_enabled", false)
	set_value("scale", "9_enabled", false)
	set_value("scale", "chromatic_enabled", false)

	set_value("pick_samples", "enabled", false)
	set_value("pick_samples", "amount", 3)

	set_value("challenges", "enabled", true)
	set_value("challenges", "amount", 1)
	set_value("challenges", "track_restrict", true)
	set_value("challenges", "instrument_type_restrict", true)
	set_value("challenges", "instrument_amount_restrict", true)
	set_value("challenges", "fx_command_require", true)
	set_value("challenges", "sample_kind_require", true)
	set_value("challenges", "synth_kind_require", true)
	set_value("challenges", "custom", true)

func _set(key: StringName, value: Variant) -> bool:
	var parts := key.split("/")
	assert(parts.size() == 2)
	set_value(parts[0], parts[1], value)
	return true

func _get(key: StringName) -> Variant:
	var parts := key.split("/")
	assert(parts.size() == 2)
	return get_value(parts[0], parts[1])

# func has_key(key: StringName) -> bool:
# 	var parts := key.split("/")
# 	assert(parts.size() == 2)
# 	return has_section_key(parts[0], parts[1])
