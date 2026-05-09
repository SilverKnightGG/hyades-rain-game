extends RayCast2D


func _ready():
    await get_tree().process_frame

    add_exception(%GroundSplashArea)
    add_exception(%CatchArea)

    set_enabled(true)
