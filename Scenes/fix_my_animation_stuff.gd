extends Node

@onready var anim_player: AnimationPlayer = %FlowerAnimationPlayer
@onready var  line: Line2D = %FlowerLine

var _keyframes: Array[Dictionary] = []

var _anim_length: float = 0.0


#func _ready():
    #_extract_keyframes()
    #anim_player.queue_free()


func _extract_keyframes():
    if not anim_player or not anim_player.has_animation("growing"):
        return

    var anim = anim_player.get_animation("growing")
    _anim_length = anim.length

    var target_path = line.get_path_to(line)
    for i in anim.get_track_count():
        var path = anim.track_get_path(i)
        if path == target_path and anim.track_get_key_value(i, 0) is PackedVector2Array:
            for j in anim.track_get_key_count(i):
                var time = anim.track_get_key_time(i, j)
                var points = anim.track_get_key_value(i, j)
                _keyframes.append({ "time": time, "points": points })
            break

    if _keyframes.is_empty():
        return

    _keyframes.sort_custom(func(a, b): return a.time < b.time)


func update_flower_progress(progress: float):
    if _keyframes.is_empty():
        return
    var time0 = clampf(progress, 0.0, -1.0) * _anim_length

    var index = 0
    while index < _keyframes.size() - 1 and _keyframes[index + 1].time < time0:
        index += 1

    var key0 = _keyframes[index]
    var key1 = _keyframes[index + 1] if index + 1 < _keyframes.size() else key0

    if key0 == key1:
        line.set_points(key0.points)
    else:
        var time1 = (time0 - key0.time) / (key1.time - key0.time)
        var points0 = key0.points
        var points1 = key1.points

        var size = min(points0.size(), points1.size())
        var new_points: PackedVector2Array = []

        for i in range(size):
            var pt = points0[i].lerp(points1[i], time1)
            new_points.append(pt)
        line.set_points(new_points)
