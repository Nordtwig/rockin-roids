extends RigidBody2D

signal lives_changed
signal dead
signal shield_changed

enum PlayerState {INIT, ALIVE, INVULNERABLE, DEAD}

@export_group("Movement")
@export var engine_power: float = 500.0
@export var rotation_power: float = 8000.0

@export_group("Combat")
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.25

@export_group("Defence")
@export var max_shield: float = 100.0
@export var shield_regen: float = 5.0

var current_state = PlayerState.INIT
var thrust: Vector2 = Vector2.ZERO
var rotation_direction: float = 0
var screen_size: Vector2 = Vector2.ZERO
var can_shoot: bool = true
var reset_position = false
var lives = 0: set = set_lives
var shield = 0: set = set_shield


func _ready() -> void:
    screen_size = get_viewport_rect().size
    body_entered.connect(on_body_entered)
    $GunCooldownTimer.timeout.connect(_on_gun_cooldown_timer_timeout)
    $GunCooldownTimer.wait_time = fire_rate
    $InvulnerabilityTimer.timeout.connect(on_invul_timer_timeout)
    _change_state(PlayerState.ALIVE)


func _process(delta) -> void:
    _get_input()
    shield += shield_regen * delta


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
            $Sprite2D.modulate.a = 0.5
        PlayerState.ALIVE:
            $CollisionShape2D.set_deferred("disabled", false)
            $Sprite2D.modulate.a = 1.0
        PlayerState.INVULNERABLE:
            $CollisionShape2D.set_deferred("disabled", true)
            $Sprite2D.modulate.a = 0.5
            $InvulnerabilityTimer.start()
        PlayerState.DEAD:
            $CollisionShape2D.set_deferred("disabled", true)
            $Sprite2D.hide()
            linear_velocity = Vector2.ZERO
            $EngineAudioStreamPlayer.stop()
            dead.emit()
    current_state = new_state


func _get_input() -> void:
    thrust = Vector2.ZERO
    if current_state in [PlayerState.DEAD, PlayerState.INIT]:
        return
    if Input.is_action_pressed("thrust"):
        thrust = transform.x * engine_power
        if not $EngineAudioStreamPlayer.playing:
            $EngineAudioStreamPlayer.play()
            $Exhaust.emitting = true
    else:
        $EngineAudioStreamPlayer.stop()
        $Exhaust.emitting = false
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
    $LaserAudioStreamPlayer.play()


func explode() -> void:
    $Explosion.show()
    $Explosion/AnimationPlayer.play("explosion")
    await $Explosion/AnimationPlayer.animation_finished
    $Explosion.hide()


func set_lives(value) -> void:
    lives = value
    lives_changed.emit(lives)
    if lives <= 0:
        _change_state(PlayerState.DEAD)
    else:
        _change_state(PlayerState.INVULNERABLE)
        shield = max_shield


func set_shield(value) -> void:
    value = min(value, max_shield)
    shield = value
    shield_changed.emit(shield / max_shield)
    if shield <= 0:
        lives -= 1
        explode()
        

func reset() -> void:
    reset_position = true
    $Sprite2D.show()
    lives = 3
    _change_state(PlayerState.ALIVE)


func on_body_entered(body) -> void:
    if body.is_in_group("rocks"):
        shield -= body.size * 25
        body.explode()


func _on_gun_cooldown_timer_timeout() -> void:
    can_shoot = true


func on_invul_timer_timeout() -> void:
    _change_state(PlayerState.ALIVE)