extends AnimationPlayer

@onready var timer = $Timer
@onready var timer2 = $Timer2
# Called when the node enters the scene tree for the first time.
func _ready():
	play("new_animation_3" )
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui _E"):
		timer2.start()
		play("new_animation_2")

	
	
	
	
	# Start the timer
	
func _on_button_pressed():
		play("new_animation")
		$Web2.visible = true


func _on_text_edit_text_changed():
	var text_edit = $Web2/TextEdit # Or however you get the reference to your TextEdit node
	var user_input = text_edit.get_text()
	print("User wrote: ", user_input)
	# Do something with the input text, like saving it or using it in-game
	if user_input =="qtube":
		$Qtube.visible = true
		
		if $Qtube.visible == true:
			play("web_show")
			$Web2.visible = false
		


func _on_button_pressed2():
	$Qtube.visible = false


func _on_button_pressed3():
	$Web2.visible = false


func _on_button_pressed4():
	timer.start()
	play("new_animation_2")
	


func _on_timer_timeout():
	var error = get_tree().change_scene_to_file("res://scenes/menu.tscn")

	
	


func _on_timer_2_timeout():
	var error = get_tree().change_scene_to_file("res://3d/world.tscn")
