extends Node2D

const RAINDROP: PackedScene = preload("uid://c501skqn12a77")
const TEARS_TIME_MIN: float = 0.5
const TEARS_TIME_MAX: float = 6.5

var crying: bool = true

@onready var cry_timers: Array[Timer] = [%Cry0, %Cry1, %Cry2, %Cry3, %Cry4, %Cry5, %Cry6, %Cry7]
@onready var tear_marks: Array[Marker2D] = [%Mark0, %Mark1, %Mark2, %Mark3, %Mark4, %Mark5, %Mark6, %Mark7]


func _ready():
    for timer: Timer in cry_timers:
        timer.timeout.connect(_make_raindrop.bind(timer.get_index()))
        timer.start(randf_range(TEARS_TIME_MIN, TEARS_TIME_MAX))


func _make_raindrop(timer_index: int):
    if not crying:
        return
    var marker: Marker2D = tear_marks[timer_index]
    var x_pos: float = marker.global_position.x
    var y_pos: float = marker.global_position.y
    var new_raindrop: Area2D = RAINDROP.instantiate()

    add_child(new_raindrop)

    new_raindrop.scale *= 0.6
    new_raindrop.set_global_position(Vector2(x_pos, y_pos))

    for timer: Timer in cry_timers:
        timer.start(randf_range(TEARS_TIME_MIN, TEARS_TIME_MAX))


func _on_stop_crying():
    crying = false
