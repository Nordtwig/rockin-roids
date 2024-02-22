extends CanvasLayer

signal start_game

@onready var lives_counter: Array[Node] = $MarginContainer/HBoxContainer/LivesCounter.get_children()
@onready var shield_bar: TextureProgressBar = $MarginContainer/HBoxContainer/ShieldBar
@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var start_button: TextureButton = $VBoxContainer/StartButton

var bar_textures: Dictionary = {
    "green": preload("res://assets/bar_green_200.png"),
    "yellow": preload("res://assets/bar_yellow_200.png"),
    "red": preload("res://assets/bar_red_200.png"),
}

func _ready() -> void:
    $Timer.timeout.connect(on_timer_timeout)
    start_button.pressed.connect(on_start_button_pressed)
    get_parent().player_lives_changed.connect(on_main_player_lives_changed)
    get_parent().player_dead.connect(on_main_player_dead)
    get_parent().player_shield_changed.connect(on_main_player_shield_changed)


func show_message(text: String) -> void:
    message_label.text = text
    message_label.show()
    $Timer.start()


func update_score(value: int) -> void:
    score_label.text = str(value)


func update_lives_counter(value: int) -> void:
    for item in 3:
        lives_counter[item].visible = value > item


func update_shield(value: float) -> void:
    shield_bar.texture_progress = bar_textures["green"]
    if value < 0.4:
        shield_bar.texture_progress = bar_textures["red"]
    elif value < 0.7:
        shield_bar.texture_progress = bar_textures["yellow"]
    shield_bar.value = value

    

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


func on_main_player_lives_changed(value) -> void:
    update_lives_counter(value)


func on_main_player_dead() -> void:
    game_over()


func on_main_player_shield_changed(value: float) -> void:
    update_shield(value)
