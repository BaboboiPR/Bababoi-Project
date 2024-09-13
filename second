extends AnimationPlayer

@onready var timer = $Timer
@onready var timer2 = $Timer2
@onready var window1 = $Window1
@onready var window2 = $Window2
@onready var web_view = $WebView  # Assuming WebView node is added

var is_dragging = false
var drag_offset = Vector2()
var input_cooldown = 0.5  # Half a second cooldown between inputs
var last_input_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
    # Setup initial states
    play("new_animation_3")
    window1.visible = true
    window2.visible = true
    web_view.visible = false  # Hide web view initially
    
    Engine.target_fps = 60  # Set to 60 FPS, can be adjusted dynamically

    # Connect signals to buttons and other UI elements
    timer.connect("timeout", self, "_on_timer_timeout")
    timer2.connect("timeout", self, "_on_timer_2_timeout")

    # Start the timer
    timer.start(1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var current_time = OS.get_ticks_msec() / 1000.0
    if Input.is_action_pressed("ui_e") and current_time - last_input_time > input_cooldown:
        last_input_time = current_time
        timer2.start()
        play("new_animation_2")

# Handle starting the drag for window1
func _on_window_title_bar_gui_input(event: InputEvent):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        is_dragging = true
        drag_offset = window1.rect_global_position - event.position
    elif event is InputEventMouseButton and not event.pressed:
        is_dragging = false

# Handle window dragging for window1
func _on_window_gui_input(event: InputEvent):
    if is_dragging and event is InputEventMouseMotion:
        window1.rect_global_position = event.position + drag_offset

# Handle WebView interactions (Wikipedia/Google)
func _on_text_edit_text_changed():
    var text_edit = $Web2/TextEdit  # Assuming TextEdit node inside Web2
    var user_input = text_edit.get_text()
    print("User wrote: ", user_input)
    
    if user_input == "qtube":
        $Qtube.visible = true
        play("web_show")
        $Web2.visible = false

# Handle button press to close window1
func _on_button_pressed2():
    window1.visible = false

# Handle button press to close window2
func _on_button_pressed3():
    window2.visible = false

# Start timer and animation on button press
func _on_button_pressed4():
    timer.start()
    play("new_animation_2")

# Scene change on timer timeout
func _on_timer_timeout():
    var error = get_tree().change_scene_to_file("res://scenes/menu.tscn")
    _handle_scene_change_error(error)

# Scene change on second timer timeout
func _on_timer_2_timeout():
    var error = get_tree().change_scene_to_file("res://3d/world.tscn")
    _handle_scene_change_error(error)

# Handle scene change errors gracefully
func _handle_scene_change_error(error):
    if error != OK:
        print("Failed to change scene: ", error)
        var retry_error = get_tree().reload_current_scene()
        if retry_error != OK:
            print("Failed to reload scene: ", retry_error)
