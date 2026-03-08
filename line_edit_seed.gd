class_name LineEditSeed
extends LineEdit

var regex := RegEx.new()

func _ready() -> void:
	regex.compile("^[0-9a-fA-F]{16}$")
	self.text_submitted.connect(func(new_text: String) -> void:
		if new_text.is_empty():
			self.text = ""
			return

		while new_text.length() < 16:
			new_text = new_text + "0"
		if regex.search(new_text):
			var parts := PackedStringArray()
			for i in 8:
				parts.append(new_text.substr(i * 2, 2))
			text = " ".join(parts)
		else:
			self.text = ""
	)

func text_to_seed() -> int:
	var clean_text := self.text.replace(" ", "")
	assert(regex.search(clean_text))
	return clean_text.hex_decode().decode_s64(0)

func copy_to_clipboard() -> void:
	DisplayServer.clipboard_set(self.placeholder_text.replace(" ", ""))

func generate_seed() -> int:
	var rand_seed: int
	if self.text.is_empty():
		rand_seed = randi() << 32 | randi()
		print("Generated seed: %s" % [_int64_to_bytes(rand_seed)])
	else:
		rand_seed = text_to_seed()
		print("Using seed: %s" % [_int64_to_bytes(rand_seed)])

	var seed_text: String = " ".join(_int64_to_bytes(rand_seed).map(func(byte: int) -> String:
		return "%02X" % byte
	))
	self.placeholder_text = seed_text

	return rand_seed

func _int64_to_bytes(value: int) -> Array:
	var bytes := Array()
	for i in 8:
		bytes.append(int((value >> (i * 8)) & 0xFF))
	return bytes
