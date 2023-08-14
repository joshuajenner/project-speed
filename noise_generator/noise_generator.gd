extends Control

@onready var file_input: LineEdit = %FileInput
@onready var message_output: LineEdit = %MessageOutput

@onready var noise_type_input: OptionButton = %NoiseTypeInput
@onready var seed_input: SpinBox = %SeedInput
@onready var frequency_input: SpinBox = %FrequencyInput
@onready var offset_x_input: SpinBox = %OffsetXInput
@onready var offset_y_input: SpinBox = %OffsetYInput
@onready var offset_z_input: SpinBox = %OffsetZInput

@onready var cellular_distance_function_input: OptionButton = %CDFInput
@onready var cellular_jitter_input: SpinBox = %CellularJitterInput
@onready var cellular_return_type_input: OptionButton = %CRTInput

@onready var domain_warp_amplitude_input: SpinBox = %DomainWarpAmplitudeInput
@onready var domain_warp_enabled_input: CheckBox = %DomainWarpEnabledInput
@onready var domain_warp_fractal_gain_input: SpinBox = %DomainWarpFractalGainInput
@onready var domain_warp_fractal_lacunarity_input: SpinBox = %DomainWarpFractalLacunarityInput
@onready var domain_warp_fractal_octaves_input: SpinBox = %DomainWarpFractalOctavesInput
@onready var domain_warp_fractal_type_input: OptionButton = %DomainWarpFractalTypeInput
@onready var domain_warp_frequency_input: SpinBox = %DomainWarpFrequencyInput
@onready var domain_warp_type_input: OptionButton = %DomainWarpTypeInput

@onready var fractal_gain_input: SpinBox = %FractalGainInput
@onready var fractal_lacunarity_input: SpinBox = %FractalLacunarityInput
@onready var fractal_octaves_input: SpinBox = %FractalOctavesInput
@onready var fractal_ping_pong_strength_input: SpinBox = %FractalPingPongStrengthInput
@onready var fractal_type_input: OptionButton = %FractalTypeInput
@onready var fractal_weighted_strength_input: SpinBox = %FractalWeightedStrengthInput


const noise_types: Array = [
	["Cellular", FastNoiseLite.TYPE_CELLULAR],
	["Perlin", FastNoiseLite.TYPE_PERLIN],
	["Simplex", FastNoiseLite.TYPE_SIMPLEX],
	["Simplex Smooth", FastNoiseLite.TYPE_SIMPLEX_SMOOTH],
	["Value", FastNoiseLite.TYPE_VALUE],
	["Value Cubic", FastNoiseLite.TYPE_VALUE_CUBIC]
]
const fractal_types: Array = [
	["None", FastNoiseLite.FRACTAL_NONE],
	["FBM", FastNoiseLite.FRACTAL_FBM],
	["Ridged", FastNoiseLite.FRACTAL_RIDGED],
	["Ping Pong", FastNoiseLite.FRACTAL_PING_PONG],
]
const cellular_distance_functions: Array = [
	["Euclidean", FastNoiseLite.DISTANCE_EUCLIDEAN],
	["Euclidean Squared", FastNoiseLite.DISTANCE_EUCLIDEAN_SQUARED],
	["Manhattan", FastNoiseLite.DISTANCE_MANHATTAN],
	["Hybrid", FastNoiseLite.DISTANCE_HYBRID],
]
const cellular_return_types: Array = [
	["Cell Value", FastNoiseLite.RETURN_CELL_VALUE],
	["Distance", FastNoiseLite.RETURN_DISTANCE],
	["Distance 2", FastNoiseLite.RETURN_DISTANCE2],
	["Distance 2 Add", FastNoiseLite.RETURN_DISTANCE2_ADD],
	["Distance 2 Sub", FastNoiseLite.RETURN_DISTANCE2_SUB],
	["Distance 2 Mul", FastNoiseLite.RETURN_DISTANCE2_MUL],
	["Distance 2 Div", FastNoiseLite.RETURN_DISTANCE2_DIV]
]
const domain_warp_types: Array = [
	["Simplex", FastNoiseLite.DOMAIN_WARP_SIMPLEX],
	["Reduced", FastNoiseLite.DOMAIN_WARP_SIMPLEX_REDUCED],
	["Basic Grid", FastNoiseLite.DOMAIN_WARP_BASIC_GRID],
]
const domain_warp_fractal_types: Array = [
	["None", FastNoiseLite.DOMAIN_WARP_FRACTAL_NONE],
	["Progressive", FastNoiseLite.DOMAIN_WARP_FRACTAL_PROGRESSIVE],
	["Independent", FastNoiseLite.DOMAIN_WARP_FRACTAL_INDEPENDENT],
]

var noise: Object
var noise_resource: NoiseResource

func _ready():
	init_ui()
	
	noise_resource = NoiseResource.new()
	noise = FastNoiseLite.new()
	
	load_values_from_resource()


func load_values_from_resource() -> void:
	noise_type_input.select(noise_resource.noise_type)
	seed_input.value = noise_resource.seed
	frequency_input.value = noise_resource.frequency
	offset_x_input.value = noise_resource.offset.x
	offset_y_input.value = noise_resource.offset.y
	offset_z_input.value = noise_resource.offset.z
	
	cellular_distance_function_input.select(noise_resource.cellular_distance_function)
	cellular_jitter_input.value = noise_resource.cellular_jitter
	cellular_return_type_input.select(noise_resource.cellular_return_type)
	
	domain_warp_amplitude_input.value = noise_resource.domain_warp_amplitude
	domain_warp_enabled_input.button_pressed = noise_resource.domain_warp_enabled
	domain_warp_fractal_gain_input.value = noise_resource.domain_warp_fractal_gain
	domain_warp_fractal_lacunarity_input.value = noise_resource.domain_warp_fractal_lacunarity
	domain_warp_fractal_octaves_input.value = noise_resource.domain_warp_fractal_octaves
	domain_warp_fractal_type_input.select(noise_resource.domain_warp_fractal_type)
	domain_warp_frequency_input.value = noise_resource.domain_warp_frequency
	domain_warp_type_input.select(noise_resource.domain_warp_type)
	
	fractal_gain_input.value = noise_resource.fractal_gain
	fractal_lacunarity_input.value = noise_resource.fractal_lacunarity
	fractal_octaves_input.value = noise_resource.fractal_octaves
	fractal_ping_pong_strength_input.value = noise_resource.fractal_ping_pong_strength
	fractal_type_input.select(noise_resource.fractal_type)
	fractal_weighted_strength_input.value = noise_resource.fractal_weighted_strength

func init_ui() -> void:
	add_options_to_input(noise_types, noise_type_input)
	add_options_to_input(cellular_distance_functions, cellular_distance_function_input)
	add_options_to_input(cellular_return_types, cellular_return_type_input)
	add_options_to_input(domain_warp_fractal_types, domain_warp_fractal_type_input)
	add_options_to_input(domain_warp_types, domain_warp_type_input)
	add_options_to_input(fractal_types, fractal_type_input)

func add_options_to_input(options: Array, input: OptionButton) -> void:
	for option in options:
		input.add_item(option[0], option[1])
