extends Node2D

const HYAS_FLOWER_SCENE: PackedScene = preload("uid://bwthjoy1pdvsn")
@onready var flower_marker: Marker2D = %FlowerMarker


func _ready():
    Game.main = self
    Game.animator = %GameAnimation

    # TEST
    %GameAnimation.play("Intro")


func _on_playing():
    await get_tree().process_frame

    var hyas_flower: Area2D = HYAS_FLOWER_SCENE.instantiate()
    %AsphodelMeadow.add_child(hyas_flower)
    hyas_flower.global_position = flower_marker.global_position

    Game.start_play(hyas_flower)

func _on_play_playing_animation():
    %GameAnimation.play("playing")
