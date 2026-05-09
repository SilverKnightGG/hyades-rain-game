extends RigidBody2D

# Instant spill (high angle)
const SPILL_ANGLE_MIN = 20.0
const SPILL_ANGLE_MAX = 50.0
const INSTANT_BASE_RATE = 4.0      # water per second when just above threshold
const INSTANT_RATE_SCALE = 1.0     # additional water/sec per degree above threshold

# Sustained spill (slow leak)
const SUSTAIN_ANGLE_FULL = 8.0
const SUSTAIN_ANGLE_EMPTY = 90.0
const SUSTAIN_SPILL_RATE = 2.0      # water per second

# Motion boost (optional)
const MOTION_BOOST_FACTOR = 0.005    # adds faux degrees per unit velocity

const ACCELERATION_POUR_THRESHOLD: float = 0.3
const MAX_POUR_ANGLE_RAD: float = PI / 5.5

const FORCED_SPILL_EXPLOSIVENESS: float = 0.65
const GRADUAL_SPILL_EXPLOSIVENESS: float = 0.2
const IMPULSE_POWER: float = 16.0
const DROPLET_MIN: float = 5.0
const DROPLET_MAX: float = 10.0
const VASE_FULL: float = 100.0
const INERTIA_DAMPENED: float = 0.6
const ANGLE_LOW_THRESHOLD: float = 12.0
const ANGLE_MULT: float = 2.0
const GRADUAL_SPILL_PARTICLE_RATIO: float = 360.0
const FORCED_SPILL_PARTICLE_RATIO: float = 26.0
const SPILL_VELOCITY_MULT_MIN: float = 0.025
const SPILL_VELOCITY_MULT_MAX: float = 0.05
const FILL_GLOW_MAX: float = 0.7
const FILL_GLOW_FLOOR: float = 0.25
const SPILL_INERTIA: float = 0.25
const SPILL_CURVE: float = 1.0
const SPILL_WATER_THRESHOLD: float = 66.2
const MAX_SPILL_ACCELERATION_X: float = 60.0
const VASE_MASS: float = 0.5
const WATER_MASS_FACTOR: float = 0.4
const MAX_VELOCITY_X: float = 320.0
const CENTER_OF_MASS_BASE: float = 42.0
const CENTER_OF_MASS_TRAVEL: float = 7.0

enum MoveState {MOVEABLE, IMMOVEABLE}
var move_state: MoveState = MoveState.MOVEABLE

var water: float = 0.0: set = set_water_amount
var fill_glow: float = 0.0
var previous_x_velocity: float = 0.0
var previous_acceleration_x: float = 0.0

@onready var fill_glow_reset: float = FILL_GLOW_MAX * 100.0

signal pouring_on_flower(amount: float)


func set_water_amount(amount: float):
    water = amount
    %VaseSprite.material.set_shader_parameter("progress", water / VASE_FULL)


func _check_spill(delta: float):
    var water_ratio = water / VASE_FULL
    var current_angle = abs(rotation_degrees)
    var motion_boost = abs(linear_velocity.x) * MOTION_BOOST_FACTOR
    var effective_angle = current_angle + motion_boost

    # --- Instant spill (high angle) ---
    var instant_threshold = lerp(SPILL_ANGLE_MAX, SPILL_ANGLE_MIN, water_ratio)
    if effective_angle > instant_threshold:
        var excess = effective_angle - instant_threshold
        # Spill rate per second (base + excess scaling)
        var rate = INSTANT_BASE_RATE + excess * INSTANT_RATE_SCALE
        var spill_amount = rate * delta
        spill_amount = min(spill_amount, water)
        if spill_amount > 0:
            _spill_amount(spill_amount, true)
            return

    # --- Sustained low‑angle spill ---
    var sustain_threshold = lerp(SUSTAIN_ANGLE_EMPTY, SUSTAIN_ANGLE_FULL, water_ratio)
    if current_angle > sustain_threshold:
        var spill_amount = SUSTAIN_SPILL_RATE * delta
        spill_amount = min(spill_amount, water)
        if spill_amount > 0:
            _spill_amount(spill_amount, false)
            return

    _spill_amount(0.0, false)



#func _check_spill(rate: float):
    #var half_full: float = VASE_FULL / 2.0
    #var spill_resistance: float = (half_full + VASE_FULL) / water
    #var motion = rate * INERTIA_DAMPENED
#
    #var tilt_effect = abs(motion / rotation_degrees if (rotation_degrees < 0.0 and motion < 0.0) or (rotation_degrees < 0.0 and motion < 0.0) else motion * rotation_degrees)
    #var spill_threshold = ANGLE_LOW_THRESHOLD + (VASE_FULL - water) / ANGLE_MULT
#
    #if tilt_effect > spill_threshold * spill_resistance:
        #_spill_amount(min(tilt_effect - spill_threshold, water))


func _on_catch_rain(area: Area2D):
    area.queue_free()
    water += randf_range(DROPLET_MIN, DROPLET_MAX)


func _spill_amount(amount: float = 0.0, force_spill: bool = false):
    if not force_spill and amount < SPILL_WATER_THRESHOLD:
        %SpillParticles.set_emitting(false)
        return

    %SpillParticles.initial_velocity_min = previous_acceleration_x * SPILL_VELOCITY_MULT_MIN
    %SpillParticles.initial_velocity_max = previous_acceleration_x * SPILL_VELOCITY_MULT_MAX
    %SpillParticles.set_direction(Vector2(linear_velocity.x, -1.0)) # Basically, more relative 'up' if it's a spill at a higher tilt from being fuller.

    if amount and not %SpillParticles.emitting:

        if force_spill:
            %SpillParticles.set_amount(int(amount * GRADUAL_SPILL_PARTICLE_RATIO))
            %SpillParticles.explosiveness = FORCED_SPILL_EXPLOSIVENESS
            %SpillParticles.one_shot = true
        else:
            %SpillParticles.set_amount(int(amount * GRADUAL_SPILL_PARTICLE_RATIO))
            %SpillParticles.explosiveness = GRADUAL_SPILL_EXPLOSIVENESS
            %SpillParticles.one_shot = false

        %SpillParticles.set_emitting(true)

    var last_amount: float = water
    water = clampf(water - amount, 0.0, VASE_FULL)

    if %PourCast.is_colliding():
        var pouring_amount: float = last_amount - water
        if pouring_amount:
            pouring_on_flower.emit(pouring_amount)



func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
    mass = VASE_MASS + (water / VASE_FULL) * WATER_MASS_FACTOR
    center_of_mass.y = CENTER_OF_MASS_BASE - (water / VASE_FULL) * CENTER_OF_MASS_TRAVEL


func _physics_process(delta: float) -> void:
    if not move_state == MoveState.MOVEABLE:
        return

    var current_velocity = linear_velocity.x
    var acceleration_x = clampf((current_velocity - previous_x_velocity) / delta, -MAX_SPILL_ACCELERATION_X, MAX_SPILL_ACCELERATION_X)
    acceleration_x = lerpf(acceleration_x, previous_acceleration_x, 0.6)

    var impulse: Vector2 = Vector2(Input.get_axis("ui_left", "ui_right") * IMPULSE_POWER, 0.0)

    linear_velocity.x = clampf(linear_velocity.x, -MAX_VELOCITY_X, MAX_VELOCITY_X)

    apply_central_impulse(impulse)
    _check_spill(delta)
    _modulate_fill_glow(delta)
    _alter_pour_cast_angle()

    previous_x_velocity = linear_velocity.x
    previous_acceleration_x = acceleration_x


func _modulate_fill_glow(delta: float):
    if not water:
        return

    fill_glow += delta
    if fill_glow > fill_glow_reset:
        fill_glow -= fill_glow_reset

    %VaseSprite.material.set_shader_parameter("glow_amount", pingpong(fill_glow, FILL_GLOW_MAX) + FILL_GLOW_FLOOR)


func _alter_pour_cast_angle():
    var clamped_accel = clamp(previous_acceleration_x, -MAX_SPILL_ACCELERATION_X, MAX_SPILL_ACCELERATION_X)
    var accel_ratio: float = clamped_accel / MAX_SPILL_ACCELERATION_X
    var pour_down: float = Vector2.RIGHT.angle()

    %PourCast.global_rotation = (global_rotation + accel_ratio * MAX_POUR_ANGLE_RAD) if abs(accel_ratio) > ACCELERATION_POUR_THRESHOLD else pour_down
