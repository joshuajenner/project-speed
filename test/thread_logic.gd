extends Control

var thread: Thread
var semaphore: Semaphore

var nearby_chunks: int = 0

var chunks_to_solve: int = 0
var chunks_to_place: int = 0
var placed_chunks: int = 0

var is_thread_active: bool = true

func _ready():
	thread = Thread.new()
	semaphore = Semaphore.new()
	thread.start(handle_chunk_generation)


func handle_chunk_generation():
	get_chunks_to_solve()
	while is_thread_active:
		solve_chunk()


func _physics_process(delta):
	place_solved_chunks()


func get_chunks_to_solve():
	for c in 5:
		chunks_to_solve += 1
		print("Added Chunk To Solve: " + str(chunks_to_solve))

func solve_chunk():
	if chunks_to_solve > 0:
		chunks_to_solve -= 1
		chunks_to_place += 1
		print("Added Chunk To Place: " + str(chunks_to_place))

func place_solved_chunks():
	if chunks_to_place > 0:
		chunks_to_place -= 1
		print("Placed a Chunk")

func _exit_tree():
	is_thread_active = false
	semaphore.post()
	thread.wait_to_finish()
