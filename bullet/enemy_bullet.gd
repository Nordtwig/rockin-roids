extends Area2D

@export var speed: float = 1000


func _ready() -> void:
    body_entered.connect(on_body_entered)
    $VisibleOnScreenNotifier2D.screen_exited.connect(on_vos_notifier_screen_exited)


func _process(delta) -> void:
    position += transform.x * speed * delta


func start(_position, _direction) -> void:
    position = _position
    rotation = _direction.angle()


func on_body_entered(body) -> void:
    queue_free()


func on_vos_notifier_screen_exited() -> void:
    queue_free()