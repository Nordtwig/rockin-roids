extends RigidBody2D

signal exploded

var screen_size: Vector2 = Vector2.ZERO
var size: float
var radius: float
var scale_factor: float = 0.2


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
    var x_form = state.transform
    x_form.origin.x = wrapf(x_form.origin.x, 0 - radius, screen_size.x + radius)
    x_form.origin.y = wrapf(x_form.origin.y, 0 - radius, screen_size.y + radius)
    state.transform = x_form


func start(_position: Vector2, _velocity: Vector2, _size:) -> void:
    position = _position
    size = _size
    mass = 1.5 * size
    $Sprite2D.scale = Vector2.ONE * scale_factor * size
    radius = int($Sprite2D.texture.get_size().x / 2 * $Sprite2D.scale.x)
    var shape = CircleShape2D.new()
    shape.radius = radius
    $CollisionShape2D.shape = shape
    linear_velocity = _velocity
    angular_velocity = randf_range(-PI, PI)
    $Explosion.scale = Vector2.ONE * 0.75 * size


func explode() -> void:
    $CollisionShape2D.set_deferred("disabled", true)
    $Sprite2D.hide()
    $Explosion/AnimationPlayer.play("explosion")
    $Explosion.show()
    exploded.emit(size, radius, position, linear_velocity)
    linear_velocity = Vector2.ZERO
    angular_velocity = 0
    await $Explosion/AnimationPlayer.animation_finished
    queue_free()