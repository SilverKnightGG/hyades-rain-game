extends Area2D

const ACCELERATION: float = 3.8
const TERMINAL_SPEED: float = 75.0

var down_speed: float = 0.0


func _process(delta: float) -> void:
    down_speed += delta * ACCELERATION
    position.y += min(down_speed, TERMINAL_SPEED)
