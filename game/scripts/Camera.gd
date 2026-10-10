extends Camera2D

var shake_strength: float = 0.0
var shake_fade: float = 0.0
var is_shaking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_shaking:
		if shake_strength > 0.1:
			shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
			offset = _get_random_offset()
		else:
			is_shaking = false
			shake_fade = 0.0
			shake_strength = 0.0
			offset = Vector2.ZERO

func shake(random_strength, fade_intensity):
	shake_strength = random_strength
	shake_fade = fade_intensity
	is_shaking = true
	
func _get_random_offset():
	var rng = RandomNumberGenerator.new()
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
	
