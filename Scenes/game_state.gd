extends Node

const MEADOW_SCENE: PackedScene = preload("uid://dgx12se6gk3f3")

var meadow: Node2D
var main: Node2D
var animator: AnimationPlayer
var hyas_flower: Area2D


func start_play(new_hyas_flower: Area2D):
    hyas_flower = new_hyas_flower



func win():
    print("win")
    animator.play("Outro")
    meadow.playing = false
    pass


func menu():
    pass


func credits():
    pass
