extends CanvasLayer

signal try_again(chaos_mode: bool)

@onready var try_again_button: Button = %TryAgainButton
@onready var chaos_mode_button: Button = %ChaosModeButton
@onready var time_taken_label: Label = %TimeTakenLabel
@onready var tower_height_label: Label = %TowerHeightLabel
@onready var player_height_label: Label = %PlayerHeightLabel
@onready var jump_label: Label = %JumpLabel
@onready var blocks_placed_label: Label = %BlocksPlacedLabel
@onready var chances_taken_label: Label = %ChancesTakenLabel

var start_time: int = 0
var elapsed_time: int = 0
var tower_height: int = 0
var player_height := 0.0
var player_jumps := 0
var blocks_placed := 0
var chances_taken := 0

var game_over = false

var time_string := ""

func _ready() -> void:
    try_again_button.pressed.connect(_on_try_again_button_pressed)
    chaos_mode_button.pressed.connect(_on_chaos_mode_button_pressed)
    GameEvents.game_started.connect(_on_game_started)
    GameEvents.game_over.connect(_on_game_over)

func _process(delta: float) -> void:
    if(game_over):
        time_taken_label.text = time_string
        tower_height_label.text = "Tower height: " + str(tower_height)
        player_height_label.text = "Player height: " + str(round(player_height * 100)/100)
        jump_label.text = "Jumps made: " + str(player_jumps)
        blocks_placed_label.text = "Blocks placed: " + str(blocks_placed)
        chances_taken_label.text = "Chances taken: " + str(chances_taken)

func allow_chaos_mode() -> void:
    chaos_mode_button.visible = true

func _on_try_again_button_pressed() -> void:
    try_again.emit(false)

func _on_chaos_mode_button_pressed() -> void:
    try_again.emit(true)

func _on_game_started() -> void:
    game_over = false
    start_time = Time.get_ticks_usec()
    
func _on_game_over() -> void:
    game_over = true
    elapsed_time = Time.get_ticks_usec() - start_time
    time_string = "Time taken: " + format_time(elapsed_time)
    
func give_tower_height_reached(tower_h: int):
    tower_height = tower_h
    
func give_player_height_reached(player_h: float):
    player_height = player_h
    
func give_player_jumps(jump_c: int):
    player_jumps = jump_c

func give_blocks_placed(blocks: int):
    blocks_placed = blocks

func give_chances_taken(chances: int):
    chances_taken = chances

func format_time(usec: int) -> String:
    var total_seconds = usec / 1000000
    var minutes = int(total_seconds / 60)
    var seconds = int(total_seconds % 60)
    var milliseconds = int((usec % 1000000) / 1000)

    return str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)
