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

func create_noise() -> FastNoiseLite:
	var new_noise := FastNoiseLite.new()
	
	new_noise.noise_type = noise_type
	new_noise.seed = seed
	new_noise.frequency = frequency
	new_noise.offset = offset
	
	new_noise.cellular_distance_function = cellular_distance_function
	new_noise.cellular_jitter = cellular_jitter
	new_noise.cellular_return_type = cellular_return_type
	
	new_noise.domain_warp_amplitude = domain_warp_amplitude
	new_noise.domain_warp_enabled = domain_warp_enabled
	new_noise.domain_warp_fractal_gain = domain_warp_fractal_gain
	new_noise.domain_warp_fractal_lacunarity = domain_warp_fractal_lacunarity
	new_noise.domain_warp_fractal_octaves = domain_warp_fractal_octaves
	new_noise.domain_warp_fractal_type = domain_warp_fractal_type
	new_noise.domain_warp_frequency =domain_warp_frequency
	new_noise.domain_warp_type = domain_warp_type
	
	new_noise.fractal_gain =fractal_gain
	new_noise.fractal_lacunarity = fractal_lacunarity
	new_noise.fractal_octaves = fractal_octaves
	new_noise.fractal_ping_pong_strength =fractal_ping_pong_strength
	new_noise.fractal_type = fractal_type
	new_noise.fractal_weighted_strength = fractal_weighted_strength
	
	return new_noise
