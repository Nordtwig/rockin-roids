extends Node

signal player_lives_changed(value)
signal player_dead()
signal player_shield_changed

@export var rock_scene: PackedScene
@export var enemy_scene: PackedScene

var screen_size: Vector2 = Vector2.ZERO
var level: int = 0
var score: int = 0
var playing: bool = false


func _ready() -> void:
    screen_size = get_viewport().get_visible_rect().size
    $HUD.start_game.connect(on_hud_start_game)
    $Player.lives_changed.connect(on_player_lives_changed)
    $Player.dead.connect(on_player_dead)
    $Player.shield_changed.connect(on_player_shield_changed)
    $EnemyTimer.timeout.connect(on_enemy_timer_timeout)
    

func _process(_delta) -> void:
    if not playing:
        return
    if get_tree().get_nodes_in_group("rocks").size() == 0:
        new_level()


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        if not playing:
            return
        get_tree().paused = not get_tree().paused
        var message = $HUD/VBoxContainer/MessageLabel
        if get_tree().paused:
            message.text = "Paused"
            message.show()
        else:
            message.text = ""
            message.hide()


func spawn_rock(size: float, position = null, velocity = null) -> void:
    if position == null:
        $RockPath/RockSpawn.progress = randi()
        position = $RockPath/RockSpawn.position
    if velocity == null:
        velocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
    var rock_instance = rock_scene.instantiate()
    rock_instance.start(position, velocity, size)
    rock_instance.screen_size = screen_size
    call_deferred("add_child", rock_instance)
    rock_instance.exploded.connect(self._on_rock_exploded)


func new_game() -> void:
    $Music.play()
    # remove any rocks from previous game
    get_tree().call_group("rocks", "queue_free")
    level = 0
    score = 0
    $HUD.update_score(score)
    $HUD.show_message("Get Ready!")
    $Player.reset()
    await $HUD/Timer.timeout
    playing = true


func new_level() -> void:
    $LevelupSound.play()
    level += 1
    $HUD.show_message("Wave %s" % level)
    for i in level:
        spawn_rock(3)
    $EnemyTimer.start(randf_range(5, 10))
    

func on_hud_start_game() -> void:
    new_game()


func on_player_lives_changed(value) -> void:
    player_lives_changed.emit(value)


func on_player_dead() -> void:
    $Music.stop()
    player_dead.emit()


func on_player_shield_changed(value: float) -> void:
    player_shield_changed.emit(value)


func _on_rock_exploded(size, radius, pos, vel) -> void:
    $ExplosionSound.play()
    if size <= 1:
        return
    for offset in [-1, 1]:
        var dir =  $Player.position.direction_to(pos).orthogonal() * offset
        var new_pos = pos + dir * radius
        var new_vel = dir * vel.length() * 1.1
        spawn_rock(size - 1, new_pos, new_vel)
    

func on_enemy_timer_timeout() -> void:
    var enemy_instance = enemy_scene.instantiate()
    add_child(enemy_instance)
    enemy_instance.target = $Player
    $EnemyTimer.start(randf_range(20, 40))

