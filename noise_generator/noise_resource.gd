class_name NoiseResource
extends Resource


@export var cellular_distance_function: FastNoiseLite.CellularDistanceFunction = 0
@export var cellular_jitter: float = 0.45
@export var cellular_return_type: FastNoiseLite.CellularReturnType = 1
@export var domain_warp_amplitude: float = 30.0
@export var domain_warp_enabled: bool = false
@export var domain_warp_fractal_gain: float = 0.5
@export var domain_warp_fractal_lacunarity: float = 6.0
@export var domain_warp_fractal_octaves: int = 5
@export var domain_warp_fractal_type: FastNoiseLite.DomainWarpFractalType = 1
@export var domain_warp_frequency: float = 0.05
@export var domain_warp_type: FastNoiseLite.DomainWarpType = 0
@export var fractal_gain: float = 0.5
@export var fractal_lacunarity: float = 2.0
@export var fractal_octaves: float = 5
@export var fractal_ping_pong_strength: float = 2.0
@export var fractal_type: FastNoiseLite.FractalType = 1
@export var fractal_weighted_strength: float = 0.0
@export var frequency: float = 0.01
@export var noise_type: FastNoiseLite.NoiseType = 1
@export var offset: Vector3 = Vector3.ZERO
@export var seed: int = 0


#enum Value {
#	CELLULAR_DISTANCE_FUNCTION,
#
#}
#
#
#func set_value(index: int, new_value) -> void:
#	match index:
#		Value.CELLULAR_DISTANCE_FUNCTION:
#			cellular_distance_function = new_value
