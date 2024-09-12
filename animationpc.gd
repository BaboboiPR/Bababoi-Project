
extends AnimationPlayer

@onready var timer = $Timer
@onready var timer2 = $Timer2
@onready var window1 = $Window1
@onready var window2 = $Window2

var is_dragging = false
var drag_offset = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
    play("new_animation_3")
    window1.visible = true
    window2.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_pressed("ui_e"):
        timer2.start()
        play("new_animation_2")

# Handle starting the drag for windows
func _on_window_title_bar_gui_input(event: InputEvent):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        is_dragging = true
        drag_offset = window1.rect_global_position - event.position
    elif event is InputEventMouseButton and not event.pressed:
        is_dragging = false

# Handle window dragging
func _on_window_gui_input(event: InputEvent):
    if is_dragging and event is InputEventMouseMotion:
        window1.rect_global_position = event.position + drag_offset


# Start the timer and play animation on button press
func _on_button_pressed():
    play("new_animation")
    $Web2.visible = true


func _on_text_edit_text_changed():
    var text_edit = $Web2/TextEdit # Or however you get the reference to your TextEdit node
    var user_input = text_edit.get_text()
    print("User wrote: ", user_input)
    
    if user_input == "qtube":
        $Qtube.visible = true
        
        if $Qtube.visible:
            play("web_show")
            $Web2.visible = false

# Close window 1 on button press
func _on_button_pressed2():
    window1.visible = false

# Close window 2 on button press
func _on_button_pressed3():
    window2.visible = false

# Start a new animation and timer on button press
func _on_button_pressed4():
    timer.start()
    play("new_animation_2")

# Scene change on timer timeout
func _on_timer_timeout():
    var error = get_tree().change_scene_to_file("res://scenes/menu.tscn")

# Scene change on second timer timeout
func _on_timer_2_timeout():
    var error = get_tree().change_scene_to_file("res://3d/world.tscn")
