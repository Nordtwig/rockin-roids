extends CanvasLayer

signal start_game

@onready var lives_counter: Array[Node] = $MarginContainer/HBoxContainer/LivesCounter.get_children()
@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var start_button: TextureButton = $VBoxContainer/StartButton


func _ready() -> void:
    $Timer.timeout.connect(on_timer_timeout)
    start_button.pressed.connect(on_start_button_pressed)


func show_message(text: String) -> void:
    message_label.text = text
    message_label.show()
    $Timer.start()


func update_score(value: int) -> void:
    score_label.text = str(value)


func update_lives_counter(value: int) -> void:
    for item in 3:
        lives_counter[item].visible = value > item


func game_over() -> void:
    show_message("Game Over")
    await $Timer.timeout
    start_button.show()


func on_timer_timeout() -> void:
    message_label.hide()
    message_label.text = ""


func on_start_button_pressed() -> void:
    start_button.hide()
    start_game.emit()