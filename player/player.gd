extends RigidBody2D

enum PlayerState {INIT, ALIVE, INVULNERABLE, DEAD}

@export var engine_power: float = 500.0
@export var rotation_power: float = 8000.0

var current_state = PlayerState.INIT
var thrust: Vector2 = Vector2.ZERO
var rotation_direction: float = 0
var screen_size: Vector2 = Vector2.ZERO


func _ready() -> void:
    screen_size = get_viewport_rect().size
    _change_state(PlayerState.ALIVE)


func _process(_delta) -> void:
    _get_input()


func _physics_process(_delta) -> void:
    constant_force = thrust
    constant_torque = rotation_direction * rotation_power


func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
    var x_form = physics_state.transform
    x_form.origin.x = wrapf(x_form.origin.x, 0, screen_size.x)
    x_form.origin.y = wrapf(x_form.origin.y, 0, screen_size.y)
    physics_state.transform = x_form


func _change_state(new_state) -> void:
    match new_state:
        PlayerState.INIT:
            $CollisionShape2D.set_deferred("disabled", true)
        PlayerState.ALIVE:
            $CollisionShape2D.set_deferred("disabled", false)
        PlayerState.INVULNERABLE:
            $CollisionShape2D.set_deferred("disabled", true)
        PlayerState.DEAD:
            $CollisionShape2D.set_deferred("disabled", true)
    current_state = new_state


func _get_input() -> void:
    thrust = Vector2.ZERO
    if current_state in [PlayerState.DEAD, PlayerState.INIT]:
        return
    if Input.is_action_pressed("thrust"):
        thrust = transform.x * engine_power
    rotation_direction = Input.get_axis("rotate_left", "rotate_right")

