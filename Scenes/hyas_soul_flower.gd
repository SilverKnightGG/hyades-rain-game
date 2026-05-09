extends Area2D

enum State {PLAYING, WON}
var state: State = State.PLAYING

const GOAL: float = 100.0
const DRAIN: float = 0.4
const GROWING_LENGTH: float = 5.0

var progress: float = 0.0

signal win


func _on_watered(amount: float):
    progress += amount
    if progress >= GOAL:
        _win()


func _process(delta: float) -> void:
    if state == State.WON:
        return
    progress = maxf(progress - delta * DRAIN, 0.0)
    var anim_time: float = (progress / GOAL) * GROWING_LENGTH
    prints("anim_time", str(anim_time))
    %FlowerAnimationPlayer.seek(anim_time, true, false)
    %FlowerAnimationPlayer.advance(0.001)



func _ready():
    %FlowerAnimationPlayer.play("growing")
    %FlowerAnimationPlayer.set_current_animation("growing")
    %FlowerAnimationPlayer.seek(0.0, true, false)
    #%FlowerAnimationPlayer.advance(0.001)


func _win():
    %FlowerAnimationPlayer.play("full")
    state = State.WON
    win.emit()
    prints("Won game")
