extends CanvasLayer

@onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("fade_in")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_link_button_pressed() -> void:
	GameManager.reset_game_state()
	queue_free()
	

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	$MarginContainer/HBoxContainer/VBoxContainer/LinkButton.disabled = false
