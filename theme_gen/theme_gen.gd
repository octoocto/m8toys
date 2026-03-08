@tool
class_name ThemeGenerator
extends Container

const MODE_4_COLOR = 0
const MODE_13_COLOR = 1

@onready var palette_hbox: HBoxContainer = %PaletteHBox
@onready var button_generate: Button = %ButtonGenerate
@onready var option_mode: OptionButton = %OptionMode
@onready var text_edit_palette: TextEdit = %TextEditPalette

@onready var sample_00: ColorRect = %Sample00
@onready var sample_01: TextureRect = %Sample01
@onready var sample_02: TextureRect = %Sample02
@onready var sample_03: TextureRect = %Sample03
@onready var sample_04: TextureRect = %Sample04
@onready var sample_05: TextureRect = %Sample05
@onready var sample_06: TextureRect = %Sample06
@onready var sample_07: TextureRect = %Sample07
@onready var sample_08: TextureRect = %Sample08

func _ready() -> void:
	button_generate.pressed.connect(func() -> void:
		var colors := generate_palette(option_mode.selected)
		sample_00.color = colors[0]
		sample_01.modulate = colors[1]
		sample_02.modulate = colors[2]
		sample_03.modulate = colors[3]
		sample_04.modulate = colors[4]
		sample_05.modulate = colors[5]
		sample_06.modulate = colors[6]
		sample_07.modulate = colors[7]
		sample_08.modulate = colors[8]
		text_edit_palette.text = ""
		for c in colors:
			text_edit_palette.text += "%02X %02X %02X\n" % [c.r8, c.g8, c.b8]
	)

func _show_palette(colors: PackedColorArray) -> void:
	for c in palette_hbox.get_children():
		c.queue_free()

	for c: Color in colors:
		var color_rect := ColorRect.new()
		color_rect.custom_minimum_size = Vector2(0, 32)
		color_rect.color = c
		color_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		palette_hbox.add_child(color_rect)

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		for c: Control in get_children():
			fit_child_in_rect(c, Rect2(Vector2.ZERO, get_size()))

func generate_palette(mode: int = MODE_4_COLOR) -> PackedColorArray:
	match mode:
		MODE_4_COLOR:
			return generate_palette_4()
		MODE_13_COLOR:
			return generate_palette_13()
	assert(false, "invalid palette mode: %d" % mode)
	return []

func generate_palette_4() -> PackedColorArray:
	var bg_color := Color.from_ok_hsl(randf(), randf_range(0.0, 0.7), randf_range(0.0, 0.1))
	var fg_color := Color.from_ok_hsl(randf(), randf_range(0.0, 0.7), randf_range(0.7, 1.0))

	var colors := [bg_color, bg_color.lerp(fg_color, 0.1), bg_color.lerp(fg_color, 0.4), fg_color]

	_show_palette(colors)

	colors = [
		colors[0],
		colors[1],
		colors[2],
		colors[2],
		colors[3],
		colors[3],
		colors[2],
		colors[3],
		colors[2],
		colors[2],
		colors[1],
		colors[1],
		colors[1],
	]

	return colors

func generate_palette_13() -> PackedColorArray:
	var lightness_bg := randf_range(0.0, 0.1)
	var lightness_1 := randf_range(0.2, 0.3)
	var lightness_2 := randf_range(0.4, 0.5)
	var lightness_3 := randf_range(0.6, 0.7)

	var colors := [
		Color.from_ok_hsl(randf(), randf_range(0.0, 0.7), lightness_bg),
		Color.from_ok_hsl(randf(), randf_range(0.0, 0.7), lightness_1),
		Color.from_ok_hsl(randf(), randf_range(0.0, 0.7), lightness_2),
		Color.from_ok_hsl(randf(), randf_range(0.0, 0.7), lightness_3),
		Color.from_ok_hsl(randf(), randf_range(0.0, 0.7), randf_range(0.7, 0.95)),
		Color.from_ok_hsl(randf(), randf_range(0.5, 0.7), randf_range(0.7, 0.95)),
		Color.from_ok_hsl(randf(), randf_range(0.5, 0.7), randf_range(0.7, 0.95)),
		Color.from_ok_hsl(randf(), randf_range(0.5, 0.7), randf_range(0.7, 0.95)),
		Color.from_ok_hsl(randf(), randf_range(0.5, 0.7), randf_range(0.7, 0.95)),
		Color.from_ok_hsl(randf(), randf_range(0.5, 0.7), randf_range(0.7, 0.8)),
		Color.from_ok_hsl(randf(), randf_range(0.5, 0.7), randf_range(0.7, 0.95)),
		Color.from_ok_hsl(randf(), randf_range(0.5, 0.7), randf_range(0.7, 0.95)),
		Color.from_ok_hsl(randf(), randf_range(0.5, 0.7), randf_range(0.7, 0.95)),
	]

	_show_palette(colors)
	return colors

	# while colors.size() < 13: colors.append(colors[-1])
	#
	# colors.sort_custom(func(a: Color, b: Color) -> bool:
	# 	return a.get_luminance() < b.get_luminance()
	# )
	#
	# colors = _array_swap(colors, 7, 12)
	# colors = _array_swap(colors, 4, 11)
	# colors = _array_swap(colors, 5, 10)
	# colors = _array_swap(colors, 3, 9)
	# colors = _array_swap(colors, 2, 8)
	#
	# colors = _array_swap(colors, 8, 12)
	#
	# if abs(colors[1].h - colors[2].h) < abs(colors[1].h - colors[11].h) or colors[11].s > colors[2].s:
	# 	colors = _array_swap(colors, 2, 11)
	#
	# # adjust contrast
	#
	# if override_contrast:
	# 	var v_lo: float = lerp(colors[0].v, value_min, 0.9)
	# 	var v_hi: float = lerp(colors[12].v, value_max, 0.9)
	#
	# 	print("color value range: %.2f - %.2f" % [v_lo, v_hi])
	#
	# 	colors[0].v = v_lo
	# 	colors[1].v = lerp(v_lo, v_hi, 0.4)
	# 	colors[2].v = lerp(v_lo, v_hi, 0.4)
	# 	colors[3].v = lerp(v_lo, v_hi, 0.8)
	# 	colors[4].v = lerp(v_lo, v_hi, 0.8)
	# 	colors[5].v = lerp(v_lo, v_hi, 0.8)
	# 	colors[6].v = v_hi
	# 	colors[7].v = v_hi
	# 	colors[8].v = v_hi
	#
	# 	# scope/slider
	# 	colors[9].v = max(0.5, colors[9].v)
	#
	# 	# meter
	# 	colors[10].v = max(0.5, colors[10].v)
	# 	colors[11].v = max(0.6, colors[11].v)
	# 	colors[12].v = max(0.7, colors[12].v)
	#
	# # sort meter colors by hue
	# var meter_colors := colors.slice(10)
	# meter_colors.sort_custom(func(a: Color, b: Color) -> bool:
	# 	return a.h < b.h
	# )
	#
	# colors[10] = meter_colors[0]
	# colors[11] = meter_colors[1]
	# colors[12] = meter_colors[2]
