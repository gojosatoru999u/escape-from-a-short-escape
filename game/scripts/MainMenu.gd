extends CanvasLayer

@onready var anim = $AnimationPlayer
var reference_width = 1920.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.game_started:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_link_button_pressed() -> void:
	anim.play("fade_out")
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	GameManager.game_start()
	if anim_name == "fade_out":
		queue_free()
	
