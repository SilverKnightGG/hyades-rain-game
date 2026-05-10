extends Node2D

const SPLASH_PARTICLES: PackedScene = preload("uid://drxexh5psobso")
const RAINDROP: PackedScene = preload("uid://c501skqn12a77")
const MIN_INTERVAL: float = 0.02
const MAX_INTERVAL: float = 1.1
const OFFSET_Y: float = 119.0 # px

var playing: bool = false


func _on_ground_splash_area_area_entered(area: Area2D) -> void:
    if area == %CatchArea:
        return
    prints("area removing:", str(area), area.name)
    _splash(area.global_position)
    area.queue_free()


func _splash(pos_to_splash: Vector2):
    var new_splash: CPUParticles2D = SPLASH_PARTICLES.instantiate()
    add_child(new_splash)
    new_splash.global_position = pos_to_splash
    new_splash.finished.connect((func(particles): particles.queue_free()).bind(new_splash))
    new_splash.set_emitting(true)


func _make_raindrop():
    if not playing:
        return
    var x_pos: float = randf_range(%RainRect.global_position.x, %RainRect.global_position.x + %RainRect.size.x)
    var y_pos: float = randf_range(%RainRect.global_position.y, %RainRect.global_position.y + %RainRect.size.y)
    var new_raindrop: Area2D = RAINDROP.instantiate()
    add_child(new_raindrop)

    new_raindrop.set_global_position(Vector2(x_pos, y_pos))


func _ready():
    position.y += OFFSET_Y
    %RainTimer.start(MIN_INTERVAL)


func _on_rain_timer_timeout() -> void:
    %RainTimer.start(randf_range(MIN_INTERVAL, MAX_INTERVAL))
    _make_raindrop()


func _on_play():
    playing = true

    %Vase.linear_velocity = Vector2.ZERO
    %Vase.angular_velocity = 0.0
    %Vase.sleeping = true
    %Vase.global_position = %VaseTransformRemote.global_position
    %Vase.rotation = %VaseTransformRemote.rotation
    await get_tree().physics_frame
    %Vase.sleeping = false
