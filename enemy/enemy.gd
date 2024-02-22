extends Area2D



func _ready() -> void:
    $GunCooldownTimer.timeout.connect(on_gun_cooldown_timer_timeout)


func on_gun_cooldown_timer_timeout() -> void:
    pass