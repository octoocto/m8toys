extends VBoxContainer

@onready var range_desired_tempo: Range = %RangeDesiredTempo
@onready var range_desired_tick_res: Range = %RangeDesiredTickRes
@onready var range_desired_swing: Range = %RangeDesiredSwing
@onready var label_project_tempo: Label = %LabelProjectTempo
@onready var label_project_groove: Label = %LabelProjectGroove
@onready var label_project_swing: Label = %LabelProjectSwing
@onready var label_project_ms_per_tick: Label = %LabelProjectMSPerTick
@onready var label_project_ms_per_8_tick: Label = %LabelProjectMSPer8Tick

func _ready() -> void:
	# set up tempo/swing calculation
	self.range_desired_tempo.value_changed.connect(func(_value: float) -> void: _calculate_tempo())
	self.range_desired_tick_res.value_changed.connect(func(_value: float) -> void: _calculate_tempo())
	self.range_desired_swing.value_changed.connect(func(_value: float) -> void: _calculate_tempo())
	_calculate_tempo()

func _calculate_tempo() -> void:
	var desired_tempo: float = self.range_desired_tempo.value
	var desired_ticks: int = int(self.range_desired_tick_res.value)
	var desired_swing: float = self.range_desired_swing.value / 100.0

	var project_tempo: float = desired_ticks / 6.0 * desired_tempo

	var project_tick_1: int = floor(float(desired_ticks * 2) * desired_swing)
	var project_tick_2: int = (desired_ticks * 2) - project_tick_1
	var project_groove: String = "%02X, %02X" % [project_tick_1, project_tick_2]
	var project_swing: float = project_tick_1 / float(project_tick_1 + project_tick_2)
	var project_ms_per_tick: float = (1.0 / desired_tempo) * 60.0 / 4.0 / float(desired_ticks) * 1000.0

	self.label_project_tempo.text = "%.2f bpm" % project_tempo
	self.label_project_groove.text = project_groove
	if fmod(project_swing, 1.0) == 0.0:
		self.label_project_swing.text = "%d %%" % (project_swing * 100)
	else:
		self.label_project_swing.text = "%.2f %%" % (project_swing * 100)
	self.label_project_ms_per_tick.text = "%.2f ms" % project_ms_per_tick
	self.label_project_ms_per_8_tick.text = "%.2f ms" % (project_ms_per_tick / 8.0)
