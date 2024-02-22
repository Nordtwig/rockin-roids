extends Area2D

@export var bullet_scene: PackedScene
@export var speed: float = 150.0
@export var rotation_speed: float = 120.0
@export var health: int = 3
@export var bullet_spread: float = 0.2

var follow = PathFollow2D.new()
var target = null


func _ready() -> void:
    $GunCooldownTimer.timeout.connect(on_gun_cooldown_timer_timeout)
    $Sprite2D.frame = randi() % 3
    body_entered.connect(on_body_entered)
    var path = $EnemyPaths.get_children()[randi() % $EnemyPaths.get_child_count()]
    path.add_child(follow)
    follow.loop = false


func _physics_process(delta: float) -> void:
    rotation += deg_to_rad(rotation_speed) * delta
    follow.progress += speed * delta
    position = follow.global_position
    if follow.progress_ratio >= 1:
        queue_free()


func shoot() -> void:
    var dir = global_position.direction_to(target.global_position)
    dir = dir.rotated(randf_range(-bullet_spread, bullet_spread))
    var bullet_instance = bullet_scene.instantiate()
    get_tree().root.add_child(bullet_instance)
    bullet_instance.start(global_position, dir)


func shoot_pulse(n, delay) -> void:
    for i in n:
        shoot()
        $LaserAudioStreamPlayer.play()
        await get_tree().create_timer(delay).timeout


func take_damage(amount) -> void:
    health -= amount
    $AnimationPlayer.play("flash")
    if health <= 0:
        explode()


func explode() -> void:
    $ExplosionSound.play()
    speed = 0
    $GunCooldownTimer.stop()
    $CollisionShape2D.set_deferred("disabled", true)
    $Sprite2D.hide()
    $Explosion.show()
    $Explosion/AnimationPlayer.play("explosion")
    await $Explosion/AnimationPlayer.animation_finished
    queue_free()


func on_gun_cooldown_timer_timeout() -> void:
    shoot_pulse(3, 0.15)


func on_body_entered(body) -> void:
    if body.is_in_group("rocks"):
        return
    explode()
    body.shield -= 50

