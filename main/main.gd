extends Node

@export var rock_scene: PackedScene

var screen_size: Vector2 = Vector2.ZERO


func _ready() -> void:
    screen_size = get_viewport().get_visible_rect().size
    for i in 3:
        spawn_rock(3)


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
