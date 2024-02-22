extends Area2D

@export var speed: float = 1000

var velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
    body_entered.connect(_on_body_entered)
    area_entered.connect(on_area_entered)
    $VisibleOnScreenNotifier2D.screen_exited.connect(_on_vos_enabler_screen_exited)


func _process(delta) -> void:
    position += velocity * delta


func start(_transform: Transform2D) -> void:
    transform = _transform
    velocity = transform.x * speed


func _on_body_entered(body) -> void:
    if body.is_in_group("rocks"):
        body.explode()
        queue_free()


func on_area_entered(area) -> void:
    if area.is_in_group("enemies"):
        area.take_damage(1)


func _on_vos_enabler_screen_exited() -> void:
    queue_free()
