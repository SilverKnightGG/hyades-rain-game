extends Area2D

const SOUL_SCENE: PackedScene = preload("uid://v3ta2jli3mva")

enum State {PLAYING, WON}
var state: State = State.PLAYING

const GOAL: float = 100.0
const DRAIN: float = 0.4
const GROWING_LENGTH: float = 5.0

var progress: float = 0.0

signal win


func _on_watered(amount: float):
    if state == State.WON:
        return
    progress += amount
    if progress >= GOAL:
        Game.win()


func _process(delta: float) -> void:
    if state == State.WON:
        return
    progress = maxf(progress - delta * DRAIN, 0.0)
    var anim_time: float = (progress / GOAL) * GROWING_LENGTH
    %FlowerAnimationPlayer.seek(anim_time, true, false)
    %FlowerAnimationPlayer.advance(0.001)



func _ready():
    await get_tree().process_frame
    %FlowerAnimationPlayer.play("growing")
    %FlowerAnimationPlayer.set_current_animation("growing")
    %FlowerAnimationPlayer.seek(0.0, true, false)


func _win():
    %FlowerAnimationPlayer.play("full")
    state = State.WON
    %Vase.move_state = %Vase.MoveState.IMMOVEABLE
    Game.win()


func _exit_tree():
    prints("flower deleted:", Time.get_ticks_msec())
    print_stack()
