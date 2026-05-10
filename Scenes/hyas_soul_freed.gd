extends CharacterBody2D




func _process(delta: float) -> void:
    %CPUParticles2D.set_color(modulate)
    %CPUParticles2D2.set_color(modulate)
    %PointLight2D.set_color(modulate)


func _on_start():
    %CPUParticles2D.emitting = true
    %CPUParticles2D2.emitting = true
