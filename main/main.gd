extends Node

signal player_lives_changed(value)
signal player_dead()

@export var rock_scene: PackedScene

var screen_size: Vector2 = Vector2.ZERO
var level: int = 0
var score: int = 0
var playing: bool = false


func _ready() -> void:
    screen_size = get_viewport().get_visible_rect().size
    $HUD.start_game.connect(on_hud_start_game)
    $Player.lives_changed.connect(on_player_lives_changed)
    $Player.dead.connect(on_player_dead)
    

func _process(_delta) -> void:
    if not playing:
        return
    if get_tree().get_nodes_in_group("rocks").size() == 0:
        new_level()


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


func _on_rock_exploded(size, radius, pos, vel) -> void:
    if size <= 1:
        return
    for offset in [-1, 1]:
        var dir =  $Player.position.direction_to(pos).orthogonal() * offset
        var new_pos = pos + dir * radius
        var new_vel = dir * vel.length() * 1.1
        spawn_rock(size - 1, new_pos, new_vel)


func new_game() -> void:
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
    level += 1
    $HUD.show_message("Wave %s" % level)
    for i in level:
        spawn_rock(3)
    

func on_hud_start_game() -> void:
    new_game()


func on_player_lives_changed(value) -> void:
    player_lives_changed.emit(value)


func on_player_dead() -> void:
    player_dead.emit()
