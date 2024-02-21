extends RigidBody2D

signal lives_changed
signal dead

enum PlayerState {INIT, ALIVE, INVULNERABLE, DEAD}

@export_group("Movement")
@export var engine_power: float = 500.0
@export var rotation_power: float = 8000.0

@export_group("Combat")
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.25

var current_state = PlayerState.INIT
var thrust: Vector2 = Vector2.ZERO
var rotation_direction: float = 0
var screen_size: Vector2 = Vector2.ZERO
var can_shoot: bool = true
var reset_position = false
var lives = 0: set = set_lives


func _ready() -> void:
    screen_size = get_viewport_rect().size
    $GunCooldownTimer.timeout.connect(_on_gun_cooldown_timer_timeout)
    $GunCooldownTimer.wait_time = fire_rate
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
    if reset_position:
        physics_state.transform.origin = screen_size / 2
        reset_position = false


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

    if Input.is_action_pressed("shoot") && can_shoot:
        _shoot()


func _shoot() -> void:
    if current_state == PlayerState.INVULNERABLE:
        return
    can_shoot = false
    $GunCooldownTimer.start()
    var bullet_instance = bullet_scene.instantiate()
    get_tree().root.add_child(bullet_instance)
    bullet_instance.start($MuzzleMarker.global_transform)


func set_lives(value) -> void:
    lives = value
    lives_changed.emit(lives)
    if lives <= 0:
        _change_state(PlayerState.DEAD)
    else:
        _change_state(PlayerState.INVULNERABLE)


func reset() -> void:
    reset_position = true
    $Sprite2D.show()
    lives = 3
    _change_state(PlayerState.ALIVE)


func _on_gun_cooldown_timer_timeout() -> void:
    can_shoot = true
