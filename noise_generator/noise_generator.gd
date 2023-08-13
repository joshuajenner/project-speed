extends Control


@onready var cellular_distance_function_input: OptionButton = %CDFInput
@onready var cellular_return_type_input: OptionButton = %CRTInput
@onready var domain_warp_fractal_type_input = %DomainWarpFractalTypeInput
@onready var noise_type_input: OptionButton = %NoiseTypeInput
@onready var fractal_type_input: OptionButton = %FractalTypeInput


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


func init_ui() -> void:
	init_noise_options()


func init_noise_options() -> void:
	for noise in noise_types:
		noise_type_input.add_item(noise[0], noise[1])
