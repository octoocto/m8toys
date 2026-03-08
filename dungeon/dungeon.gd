@tool
class_name DungeonMain
extends Container

enum State {
	MAIN_MENU,
	ENTERING_ROOM,
	CURSE_CHECK,
	MUTATION_CHECK,
	COMPOSE,
	FINALIZE_ROOM,
	FINISH
}

var state: State = State.MAIN_MENU

var rooms: Array = []

var mutations: Array = []

func _ready() -> void:
	var mutations_lines := read_lines("res://dungeon/mutations.txt")
	var i := 0
	for line: String in mutations_lines:
		var parts := line.split(";")
		assert(parts.size() == 2 or parts.size() == 3, "Expected 2-3 parts for mutation, got %d in line '%s'" % [parts.size(), line])
		assert(parts[0].is_valid_int(), "Expected integer for mutation chance, got '%s'" % parts[0])
		var chance := int(parts[0])
		while i < chance:
			mutations.append(parts[1].strip_edges())
			i += 1
	print("%d mutations loaded" % mutations.size())
	pick_mutation()
	pick_mutation()
	pick_mutation()

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		for c: Control in get_children():
			fit_child_in_rect(c, Rect2(Vector2.ZERO, get_size()))

func roll_d100() -> int:
	var result := randi_range(0, 99)
	print("Rolled d100: %d" % (result + 1))
	return result

func pick_mutation() -> String:
	assert(mutations.size() == 100)
	var result: String = mutations[roll_d100()]
	print("Picked mutation: %s" % result)
	return result
	
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
