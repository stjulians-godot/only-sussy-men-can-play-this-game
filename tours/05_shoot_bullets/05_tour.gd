extends "res://addons/godot_tours/tour.gd"

const Gobot := preload("res://addons/godot_tours/bubble/gobot/gobot.gd")

const TEXTURE_BUBBLE_BACKGROUND := preload("res://addons/godot_tours/assets/icons/bubble-background.png")
const TEXTURE_GDQUEST_LOGO := preload("res://addons/godot_tours/assets/icons/bubble-background.png")
const TEXTURE_BULLET_SHOOT_EXAMPLE := preload("res://tours/05_shoot_bullets/tour_assets/bullet_shoot_cover_example.png")
const TEXTURE_BULLET_FUNC_ERROR := preload("res://tours/05_shoot_bullets/tour_assets/bullet_func_error_texture.png")
const TEXTURE_BULLET_FUNC_ERROR_2 := preload("res://tours/05_shoot_bullets/tour_assets/bullet_func_error_texture_2.png")
const TEXTURE_BULLET_FUNC_ERROR_3 := preload("res://tours/05_shoot_bullets/tour_assets/bullet_func_error_texture_3.png")
const VIDEO_MAGIC_TRICK:= preload("res://tours/05_shoot_bullets/tour_assets/magic_trick.ogv")

const CREDITS_FOOTER_GDQUEST := "[center]GGuide+ · Made by [url=https://www.madfoxlabs.com/][b]GDQuest[/b][/url] ·[/center]"

const LEVEL_RECT := Rect2(Vector2.ZERO, Vector2(1920, 1080))
const LEVEL_CENTER_AT := Vector2(960, 540)


const ICONS_MAP = {
	node_position_unselected = "res://addons/godot_tours/assets/icons/icon_editor_position_unselected.svg",
	node_position_selected = "res://addons/godot_tours/assets/icons/icon_editor_position_selected.svg",
	script_signal_connected = "res://addons/godot_tours/assets/icons/icon_script_signal_connected.svg",
	script = "res://addons/godot_tours/assets/icons/icon_script.svg",
	script_indent = "res://addons/godot_tours/assets/icons/icon_script_indent.svg",
	zoom_in = "res://addons/godot_tours/assets/icons/icon_zoom_in.svg",
	zoom_out = "res://addons/godot_tours/assets/icons/icon_zoom_out.svg",
	open_in_editor = "res://addons/godot_tours/assets/icons/icon_open_in_editor.svg",
	node_signal_connected = "res://addons/godot_tours/assets/icons/icon_signal_scene_dock.svg",
}



const checkpoint_res_path: String = "res://tours/05_shoot_bullets/checkpoint.tres"

var scene_player_path := "res://player.tscn"

var template_bullet_script: String = get_text_from_json("res://tours/05_shoot_bullets/05_tour_scripts.json", "bullet_template")
var template_player_bullet_func : String = get_text_from_json("res://tours/05_shoot_bullets/05_tour_scripts.json", "player_bullet_func")

# variable that stores the path where the student wants to save the bullet scene
var student_bullet_path : String = ""


var fs_changed = false
func _on_filesystem_changed(): fs_changed = true



func _build() -> void:
	# Set editor state according to the tour's needs.
	queue_command(func reset_editor_state_for_tour():
		interface.canvas_item_editor_toolbar_grid_button.button_pressed = false
		interface.canvas_item_editor_toolbar_smart_snap_button.button_pressed = false
		interface.bottom_button_output.button_pressed = false
		
		var settings = EditorInterface.get_editor_settings()
		settings.set_setting('text_editor/behavior/files/auto_reload_scripts_on_external_change', true)
		settings.set_setting('run/output/always_clear_output_on_play', true)
		ProjectSettings.set_setting('display/window/size/always_on_top', true)
		ProjectSettings.set_setting('rendering/textures/canvas_textures/default_texture_filter' , 'Nearest')
	)


	var steps_func : Array[Callable] = [
		provisorio,
		steps_010_intro,
		steps_020_bullet_script,
		steps_030_edit_player_script,
		steps_040_add_marker2d,
		steps_050_assigning_shoot_input_key,
		steps_060_coding_final]

	var last_checkpoint : String = load_checkpoint(checkpoint_res_path)
	if last_checkpoint.is_empty():
		for step in steps_func:
			step.call()
	else:
		var starting_step_idx: int = steps_func.find(Callable(self, last_checkpoint))
		for i in range(steps_func.size() - starting_step_idx): # execute steps starting from the last checkpoint
			steps_func[i+starting_step_idx].call()
			  

	#steps_010_intro()
	#steps_020_bullet_script()
	#steps_030_edit_player_script()
	#provisorio()
	#steps_040_add_marker2d()
	#steps_050_assigning_shoot_input_key()
	#steps_060_coding_final()



func steps_010_intro() -> void:

	# 0010: introduction ----------------------------------------------------------------------
	context_set_2d()
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_set_title("Shooting Bullets (2D platform style)")
	bubble_add_texture(TEXTURE_BULLET_SHOOT_EXAMPLE)
	bubble_add_text(
		[gtr("In this lesson, you will learn how to make your player shoot bullets."),
		gtr("Be aware that this tutorial is meant to shoot bullets only [b]Sideways[/b]."),
		gtr("For other types of shooting (e.g 360º mouse shooter), you may check other tutorial."),
		gtr("[center][b]Let's get started![/b][/center]"),]
	)
	queue_command(func avatar_wink(): bubble.avatar.do_wink())
	complete_step()


	# 0011: scenes that must be opened ------------------------------------------------------------
	bubble_set_title(gtr("Disclaimer! ⚠️⚠️⚠️⚠️⚠️"))
	bubble_add_text([bbcode_wrap_font_size(gtr("For this lesson, you must have already created your player character and have its scene [b]currently open![/b]"), 20)])
	complete_step()


	# 0020: Create a new scene -------------------------------------------------------------------
	highlight_controls([interface.add_a_new_scene_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Create a new scene!"))
	bubble_add_text(
		[gtr("Let's create our bullet, to do it so, you need to create a new scene."),
		gtr("Click the [b]+[/b] icon in the scene's tab bar")]
	)
	queue_command(func() -> void:
		for path in EditorInterface.get_open_scenes():
			if path == "res://player.tscn":
				scene_player_path = path
	)
	scene_open(scene_player_path)
	bubble_add_task_press_button(interface.add_a_new_scene_button)
	complete_step()



	# 0030: Add new node warning ------------------------------------------------------------------
	highlight_controls([interface.scene_dock], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_title(gtr("DON'T CLICK BEFORE YOU READ"))
	bubble_add_text(
		[gtr("This time there's [b]no[/b] need to start with a 2D node, so do not run into autopilot mode by clicking on the 1st node icon you see!"),]
	)
	bubble_set_background(TEXTURE_BUBBLE_BACKGROUND)
	complete_step()
	
	
	
	# 0040: Add Area2D node----------------------------------------------------------------------
	highlight_controls([interface.scene_dock_button_add, interface.node_create_panel], true)
	bubble_add_task_press_button(interface.scene_dock_button_add)	 
	bubble_set_title(gtr("Add an Area2D node"))
	bubble_add_text(
		[gtr("On the top left corner you should see a [b]+[/b] icon to add a new node."),
		gtr("Then type [b]Area2D[/b] to find the node")]
	)
	bubble_add_task(
		gtr("Add an [b]Area2D[/b] node"), 1,
		func task_add_node(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			if root.is_class('Area2D'): return 1 else: return 0,
	)
	complete_step()
	
	
	
	# 0060: Add Sprite2D and CollisionShape2D nodes ----------------------------------------------------
	highlight_controls([interface.scene_dock_button_add, interface.scene_tree], true) 
	bubble_set_title(gtr("Add sprite and collision"))
	bubble_add_text(
		[gtr("Make sure you add a [b]sprite[/b] and a [b]collision[/b] node as children of your Area2D."),
		gtr("To do this, select the Area2D node first, and then add the sprite and collision nodes to it."),]
	)
	bubble_add_task(
		gtr("Add a [b]Sprite2D[/b] and a [b]CollisionShape2D[/b] node"), 1,
		func task_add_node(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			if not root.find_children("*", "Sprite2D", false, true).is_empty() and not root.find_children("*", "CollisionShape2D", false, true).is_empty(): return 1 else: return 0,
	)
	bubble_add_task_focus_node("Area2D", "Select the Area2D node that you just added")
	complete_step()



func steps_020_bullet_script() -> void:
	queue_command(func()->void: # SAVING CHECKPOINT
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_020_bullet_script"
		save_checkpoint(resource))
	
	# 0070: configure the sprite and collision nodes. Also rename area2d to bullet
	highlight_controls([interface.scene_dock_button_add, interface.scene_tree], true)
	queue_command(func()->void: overlays.toggle_dimmers(false))
	bubble_set_avatar_at(Bubble.AvatarAt.RIGHT)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT) 
	bubble_set_title(gtr("Configuring the nodes"))
	bubble_add_text(
		[gtr("Great! Now you should configure the sprite and collision nodes as you did in previous lessons. Also, you should rename your [b]Area2D[/b] node to [b]bullet[/b] or something similar."),]
	)
	complete_step()


	# 0080: Adding a script -----------------------------------------------------------------------
	highlight_controls([interface.scene_dock_button_add_script], true)
	bubble_set_title(gtr("Adding a script to the bullet"))
	bubble_add_task_press_button(interface.scene_dock_button_add_script)
	bubble_add_text(
		[gtr("Let's attach a script to your bullet!"),
		gtr("In order to do it so, you'll need to select your [b]Area2D[/b] node and click on the add script icon ")]
	)
	complete_step()


func provisorio():
	# 0080: pasting the bullet area2d script---------------------------------------------------------
	highlight_controls([interface.script_editor_code_panel])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)	
	bubble_set_title(gtr("Writting the script"))
	bubble_add_text(
		[gtr("Now we can write the script that this area2D node needs. I will give you a little push to start..."),]
	)
	queue_command(func()->void:
		var settings = EditorInterface.get_editor_settings()
		settings.set_setting('text_editor/behavior/files/auto_reload_scripts_on_external_change', true)
	)
	complete_step()



	## 0100: I will add the template code -----------------------------------------------------------------------
	highlight_controls([interface.script_editor_code_panel], true)
	bubble_set_title(gtr("Wanna see a magic trick? 🤣")) 
	bubble_add_text(
		[gtr("Just minimize Godot by clicking on its icon at the bottom as you can see on this video and click it again to open it. I'll do a trick 😶‍🌫️"),]
	)
	bubble_add_video(VIDEO_MAGIC_TRICK)
	queue_command(func write_script():
		var bullet_script: Script = EditorInterface.get_script_editor().get_current_script()
		var bullet_script_path = bullet_script.resource_path

		# write the template into the script
		var file = FileAccess.open(bullet_script_path, FileAccess.WRITE)
		file.store_string(template_bullet_script)
		file.close()
	)
	complete_step()
	
	
	
	## 0110: Explaining the script ---------------------------------------------------------------------
	highlight_code(6, 7, 0, false, true)
	bubble_set_title(gtr("What happened? 😲"))
	bubble_add_text(
		[gtr("Your script seems a little different huh?"),
		gtr("Let's see what I added..."),]
	)
	var lines: Array[String] = ["Code Line 1", "Code Line 2", "Code Line 3"]
	bubble_add_code(lines)
	complete_step()



	## 0120: Explainning steps ----------------------------------------------------------
	highlight_code(10, 19, 0, false, true) 
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER_RIGHT)
	bubble_set_title(gtr("Call the teacher"))
	bubble_add_text(
		[gtr("Ruben was feeling too lazy to code that part,"),
		gtr("So he's requesting you to call him while he doesn't finish this yet..."),]
	)
	#bubble_add_text([gtr("At the bottom-left, you can see the [b]FileSystem Dock[/b]. It lists all the files used in your project (all the scenes, images, scripts...).")])
	#EditorInterface.edit_script(area2d_script, 1, 7, true)
	complete_step()

	## 0130 adding visible on screen enable ------------------------------------------------
	#bubble_move_and_anchor(interface.main_screen)
	#bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("What happens "))
	bubble_add_text(
		[gtr("What happens to the bullets that you shot and miss the target? Do they continue forever in your game?"),
		gtr("It's not in the good practices book to leave elements that are no longer relevant to our game"),
		gtr("So, I will teach you a quick way to delete the bullets once they leave the screen"),]
	)
	bubble_add_texture(TEXTURE_GDQUEST_LOGO)
	complete_step()
	
	
	## 0140 adding visible on screen enable node ---------------------------------------------
	highlight_controls([interface.scene_dock_button_add], true)
	bubble_set_title(gtr("VisibleOnScreenEnabler2D Node"))
	bubble_add_text(
		[gtr("Let's begin by adding a [b]VisibleOnScreenEnabler2D[/b] into your bullet Area2D node "),]
	)
	bubble_add_task_press_button(interface.scene_dock_button_add)
	complete_step()
	

	## 0150 adding visible on screen enable node ---------------------------------------------
	highlight_tabs_index(interface.inspector_tabs, 1 , true)
	highlight_controls([interface.node_dock_signals_button, interface.node_dock_signals_editor], true)
	bubble_set_title(gtr("Connecting a signal - part 1"))
	bubble_add_text(
		[gtr("Let's connect screen_exited() signal "),]
	)
	bubble_add_task_focus_node("VisibleOnScreenEnabler2D")
	bubble_add_task_press_button(interface.node_dock_signals_button)
	complete_step()
	

	## 0160 adding visible on screen enable signal ---------------------------------------------
	highlight_tabs_index(interface.inspector_tabs, 1 , true)
	highlight_controls([interface.node_dock_signals_button, interface.signals_dialog], true)
	highlight_signals(['screen_exited'], true)
	bubble_set_title(gtr("Connecting a signal - part 2"))
	bubble_add_text(
		[gtr("Let's double click on that signal"),]
	)
	bubble_add_task(
		gtr("[b]Double-click[/b] the signal called [b]scree_exited()[/b] in the node dock."),
		1,
		func task_open_signal_connection_dialog(task: Task) -> int:
			if interface.signals_dialog_window.visible:
				return 1
			else:
				return 0,
	)
	
	complete_step()
	
	
	
	## 0160 adding visible on screen enable signal ---------------------------------------------
	highlight_tabs_index(interface.inspector_tabs, 1 , true)
	highlight_controls([interface.node_dock_signals_button], true)
	highlight_signals(['screen_exited'], true)
	bubble_set_title(gtr("Connecting a signal - part 3"))
	bubble_add_text(
		[gtr("Make sure you select your main bullet node (area2D type)"),]
	)
	queue_command(func() -> void:
		var first_node_in_tree = interface.signals_dialog_tree.get_selected().get_text(0)
		overlays.highlight_signal_nodes_by_path([first_node_in_tree])
	)
	complete_step()
	
	## 0170 adding visible on screen enable signal ---------------------------------------------
	highlight_tabs_index(interface.inspector_tabs, 1 , true)
	highlight_controls([interface.node_dock_signals_button], true)
	highlight_signals(['screen_exited'], true)
	highlight_controls([interface.signals_dialog_ok_button])
	bubble_set_title(gtr("Connecting a signal - part 4"))
	bubble_add_text(
		[gtr("If the correct node is selected you can click on [b]connect[/b]"),]
	)
	bubble_add_task_press_button(interface.signals_dialog_ok_button, "Press connect")
	complete_step()


	## 0180 writting the code signal code ---------------------------------------------
	highlight_code(21, 22)
	bubble_set_title(gtr("Writting the behavior"))
	bubble_add_text(
		[gtr("Great! Now we can set what happens when the bullet leaves the screenview of your game!"),
		gtr("You may already guessed it's deleting that bullet, right?"),]
	)
	complete_step()


	## 0190 writting the code signal code ---------------------------------------------
	highlight_code(21, 22)
	bubble_set_title(gtr("Programming the deletion"))
	bubble_add_code(["pass # Replace with function body."])
	bubble_add_text(
		[gtr("To do it so, let's erase the 'pass' line under the function and replace it with a godot method that deletes nodes."),
		gtr("It's called [b]queue_free()[/b]. So go ahead, delete that line and write that method"),
		gtr("Don't forget that under functions, their code lines have to be spaced at least by one TAB (look at your keyboard)"),]
	)
	bubble_add_code(["queue_free()"])
	bubble_add_task(
		gtr("Write [b]queue_free()[/b] under the function"), 1,
		func task_write_code(task: Task) -> int:
			var bullet_script: String = EditorInterface.get_script_editor().get_current_script().source_code
			
			if bullet_script.contains("	queue_free()"): return 1
			else: return 0,
	)
	complete_step()



	## 0190 writting the code signal code ---------------------------------------------
	bubble_set_title(gtr("Saving the bullet scene"))
	bubble_add_text(
		[gtr("Great! Now you should save this scene!"),
		gtr("The shortcut to save files on every software usually is [b]CTRL[/b] + [b]S[/b], you should give it a try"),
		gtr("Alternatively, on the top left you can just Scene -> Save Scene"),
		gtr("I would recomend you to save on [b]res//prefabs[/b] and name it [b]bullet.tscn[/b]"),]
	)
	
	bubble_add_task(
		gtr("Save this scene"), 1,
		func task_save_scene(task: Task) -> int:
			
			var fs = EditorInterface.get_resource_filesystem()
			fs.connect("filesystem_changed", Callable(self, "_on_filesystem_changed"))
			
			if fs_changed: # fs_changed has to be set resetted to false only on the next step
				return 1 else: return 0,
	)
	complete_step()



func steps_030_edit_player_script() -> void:
	
	queue_command(func()->void:
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_030_edit_player_script"
		save_checkpoint(resource)
	)

	## get saved bullet scene path---------------------------------------------------------------
	queue_command(func()->void: student_bullet_path = EditorInterface.get_edited_scene_root().scene_file_path)
	queue_command(func reset_fs_changed()->void: fs_changed = false) # because of the previous step
	
	## 0190 adding bullet function to players code ---------------------------------------------
	bubble_set_title(gtr("Editing player's script"))
	bubble_add_text(
		[gtr("Now that we have set the basic of our bullet we still need to make our player character to spawn a bullet when he shoots."),
		gtr("When you're playing and press the shoot key/button"),]
	)
	highlight_tabs_title(interface.main_screen_tabs, "player")
	bubble_add_task_set_tab_to_title(interface.main_screen_tabs, "player")
	complete_step()


	## 0200 adding bullet function to players code ---------------------------------------------
	context_set_script() # just to make sure the students is still on script view 
	queue_command(func():
		interface.bottom_button_output.button_pressed = false
	)
	highlight_controls([interface.script_editor_code_panel])
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER_RIGHT)
	bubble_set_title(gtr("Adding shoot function to player"))
	bubble_add_text(
		[gtr("Now we should add a function to our player to be called everytime he wants to shoot."),
		gtr("You can select and copy the following code to your player's script"),]
	)
	bubble_add_code([template_player_bullet_func])
	bubble_set_footer("⚠️ Warning! The editor is going to highlight in red that it has some errors.
	  It's fine, we will correct it in the next step.")
	complete_step()


	## 0210 adding bullet function to players code ---------------------------------------------
	highlight_controls([interface.script_editor_code_panel])
	bubble_set_title(gtr("Something is missing... 🤔"))
	bubble_add_texture(TEXTURE_BULLET_FUNC_ERROR)
	bubble_add_text(
		[gtr("Getting some errors huh? 🤨"),
		gtr("That's because we haven't declared our bullet scene in the player's script yet!"),
		gtr("As you can see in the function's 1st line, BULLET_SCENE.instantiate() wants to create a variable that instantiates/spawns the bullet you just created moments ago. However, your bullet scene hasn't been yet declared on your player's script..."),]
	)
	complete_step()


	## 0220 declaring bullet scene on player's script --------------------------------------------
	highlight_controls([interface.script_editor_code_panel])
	bubble_set_title(gtr("Declare your bullet scene!"))
	bubble_add_text(
		[gtr("Let's reach the top of your player's script and declare your bullet's scene"),
		gtr("The following line should be added somewhere in the beggining of the player's script:"),]
	)
	bubble_add_code(['const BULLET_SCENE = preload("res://prefabs/bullet.tscn")'])
	var video: VideoStream = load("res://test_video.ogv")
	bubble_add_video(video)
	bubble_set_footer('Warning: you may have to change the path "res://prefabs/bullet.tscn"\nto the path where you store the bullet scene.')
	complete_step()



func steps_040_add_marker2d():
	queue_command(func()->void:
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_040_add_marker2d"
		save_checkpoint(resource)
	)
	
	## 0230 still lacks a Marker2D --------------------------------------------
	highlight_controls([interface.script_editor_code_panel])
	bubble_set_title(gtr("Still, something is missing..."))
	bubble_add_text(
		[gtr("One error it's solved but some still persist... 😒"),
		gtr("The [b]bullet_position[/b] variable is meant to define the starting position of the bullet in your game."),
		gtr("This is usually the end of the player's gun barrel, right?"),]
	)
	complete_step()


	## 0240 adding the Marker2D node -------------------------------------------------------
	bubble_set_title(gtr("The Marker2D node"))
	bubble_add_text(
		[gtr("Hey, there's a really cool node that makes this super easy to do!"),
		gtr("It's called [b]Marker2D[/b]. Basically, like the name says, it's just a marker, a point you can place anywhere in your game."),
		gtr("You can make it move, follow other things, or just keep it in one spot – it all depends on how you set it up."),]
	)
	complete_step()


	## 0240 adding the Marker2D node -------------------------------------------------------
	highlight_controls([interface.scene_dock_button_add, interface.scene_tree])
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Adding a Marker2D"))
	bubble_add_text(
		[gtr("So, let's select your player node and adding him a [b]Marker2D[/b]"),
		gtr("Make sure the tree node is correctly organized when adding it"),]
	)
	bubble_add_task(
		gtr("Add a [b]Marker2D[/b] node to your player node"), 1,
		func task_add_node(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			if root.find_children("*", "Marker2D", false, true ).is_empty(): return 0 else: return 1,
	)
	complete_step()


	## 0250 placing the Marker2D - selecting 2D view ----------------------------------------------
	highlight_controls([interface.context_switcher_2d_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_CENTER)
	bubble_set_title(gtr("Placing the Marker2D - part 1"))
	bubble_add_text(
		[gtr("So, let's place your [b]Marker2D[/b] where you want your bullets to be spawn."),
		gtr("First, switch to 2D View."),]
	)
	bubble_add_task_press_button(interface.context_switcher_2d_button)
	complete_step()


	## 0250 dragging mode to move Marker2D -------------------------------------------------------
	highlight_controls([interface.context_switcher_2d_button, interface.canvas_item_editor_toolbar_move_button], true)
	mouse_move_by_position(get_control_global_center(interface.context_switcher_2d_button), get_control_global_center(interface.canvas_item_editor_toolbar_move_button))
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_CENTER)
	bubble_set_title(gtr("Placing the Marker2D - part 2"))
	bubble_add_text(
		[gtr("To drag your Marker2D, you need to have the move tool active."),
		gtr("Click on the [b]move tool[/b] icon in the toolbar to select it and enable moving the node."),]
	)
	bubble_add_task_press_button(interface.canvas_item_editor_toolbar_move_button)
	complete_step()


	## 0260 making sure student selects the Marker2D node -------------------------------------------------------
	highlight_scene_nodes_by_name(["Marker2D"])
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_title(gtr("Placing the Marker2D - part 3"))
	bubble_add_text(
		[gtr("Don't forget to select the correct node."),]
	)
	bubble_add_task_focus_node("Marker2D", "Make sure you have the [b]Marker2D[/b] node selected")
	complete_step()

	
	## 0270 placing the Marker2D -------------------------------------------------------
	bubble_move_and_anchor(interface.inspector_dock, bubble.At.BOTTOM_RIGHT)
	queue_command(func()->void: overlays.toggle_dimmers(false))
	bubble_set_title(gtr("Placing the Marker2D - part 4"))
	bubble_add_text(
		[gtr("In the 2D Viewport, you can now drag the [b]Marker2D[/b] node to the position where you want the bullets to start."),]
	)
	var video: VideoStream = load("res://test_video.ogv")
	bubble_add_video(video)
	bubble_add_task(
		gtr("Drag the [b]Marker2D[/b] node to where you wish the bullets to be spawned"), 1,
		func task_drag_node(task: Task) -> int:
			var marker2d_node: Node = EditorInterface.get_edited_scene_root().find_child("Marker2D", false, true)
			if marker2d_node.position != Vector2.ZERO: return 1 else: return 0,
	)	
	complete_step()
	


	## 0280 placing the Marker2D -------------------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	highlight_controls([interface.scene_tree])
	bubble_set_title(gtr("Renaming the Marker2D node"))
	bubble_add_text(
		[gtr("Fantastic! With the Marker2D in place, can you recall what we're using it for?"),
		gtr("We should rename it to make its purpose clear as we go forward."),]
	)
	bubble_add_task_rename_node('bullet_position', false)
	complete_step()



	## 0300 check the player's code -------------------------------------------------------
	context_set_script()
	#queue_command(func()->void: EditorInterface.open_scene_from_path(student_bullet_path))
	#queue_command(func()->void:
		#var player_scene_path = EditorInterface.get_edited_scene_root().scene_file_path
		#EditorInterface.open_scene_from_path(player_scene_path)
		#)
	highlight_scene_nodes_by_name([EditorInterface.get_edited_scene_root().name])
	bubble_set_title(gtr("Check player's script"))
	bubble_add_text(
		[gtr("Take a look inside the player's script again."),]
	)
	bubble_add_task(
		gtr("Open the script attached to the [b]player[/b] node."), 1,
		func(task: Task) -> int:
			if not interface.is_in_scripting_context(): return 0
			var script_player = EditorInterface.get_edited_scene_root().get_script().resource_path	
			var open_script: String = EditorInterface.get_script_editor().get_current_script().resource_path
			return 1 if open_script == script_player else 0,
	)
	complete_step()



	## 0310 inspect player's code -------------------------------------------------------
	bubble_move_and_anchor(interface.inspector_dock, bubble.At.CENTER_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Declaring the Mark2D node"))
	bubble_add_text(
		[gtr("Okay, so the error message is a little different now. See how the first two errors are highlighting the lines where we've used [b]bullet_position[/b]")]
	)
	bubble_add_code(["if sign(bullet_position.position.x) == 1:", "bullet_instance.global_position = bullet_position.global_position"])
	bubble_add_text(
		[gtr("The reason for this is that the script has no idea what we're talking about when we say bullet_position. We need to tell it what that is by declaring it!")]
	)
	queue_command(func ()->void: # highlighting the error message
		var current_script_editor = EditorInterface.get_script_editor().get_current_editor()
		var script_error_box = Utils.find_child_by_type(current_script_editor, 'HBoxContainer')
		overlays.highlight_controls([script_error_box])
	)
	bubble_add_texture(TEXTURE_BULLET_FUNC_ERROR_2)
	scroll_script(900, 2)
	complete_step()



	## 0310 declaring the node on the player's script -------------------------------------------
	bubble_move_and_anchor(interface.inspector_dock, bubble.At.CENTER_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	highlight_controls([interface.scene_tree, interface.script_editor_code_panel])
	bubble_set_title(gtr("Declaring the Mark2D node on player's script"))
	bubble_add_text(
		[gtr("Let's go to the top of your player's script and declare the node variable"),
		gtr("You could just copy & paste the following code:")]
	)
	var bullet_position_declaring_code = "@onready var bullet_position = $bullet_position"
	bubble_add_code([bullet_position_declaring_code])
	bubble_add_text(
		[gtr("[b]However[/b] a quick way to achieve this is to [b]hold down CTRL[/b] and drag the node directly from the scene tree into your script."),]
	)
	mouse_click_drag_by_position(get_control_global_center(interface.scene_tree),  interface.script_editor_code_panel.get_global_rect().position + Vector2(200, 30))
	var video_2: VideoStream = load("res://test_video.ogv")
	bubble_add_video(video_2)
	scroll_script(5, 1)
	complete_step()



	## 0320 check the player's code -------------------------------------------------------
	bubble_move_and_anchor(interface.inspector_dock, bubble.At.CENTER_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	highlight_controls([interface.script_editor_code_panel])
	bubble_set_title(gtr("Declared Marked2D"))
	bubble_add_text(
		[gtr("Now that we've fixed everything related to your bullet_position marker."),
		gtr("You should see that we're very close to being set up."),]
	)
	scroll_script(900, 1)
	bubble_add_texture(TEXTURE_BULLET_FUNC_ERROR_3)
	complete_step()



	## 0330 checking last script error -------------------------------------------------------
	bubble_move_and_anchor(interface.inspector_dock, bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("What's left?"))
	bubble_add_text(
		[gtr("We still have that final warning."),
		gtr("What does it say?"),]
	)
	queue_command(func ()->void: # highlighting the error message
		var current_script_editor = EditorInterface.get_script_editor().get_current_editor()
		var script_error_box = Utils.find_child_by_type(current_script_editor, 'HBoxContainer')
		overlays.highlight_controls([script_error_box])
	)
	complete_step()



	## 0340 check the player's code -------------------------------------------------------
	bubble_move_and_anchor(interface.inspector_dock, bubble.At.CENTER_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("What's left?"))
	bubble_add_text(
		[gtr("What's the issue? It seems [b]shoot_cooldown[/b] hasn't been declared."),
		gtr("The reason for this is that a shoot cooldown doesn't exist yet! Let's create one."),]
	)
	queue_command(func ()->void: # highlighting the error message and the code panel separately
		var current_script_editor = EditorInterface.get_script_editor().get_current_editor()
		var script_error_box = Utils.find_child_by_type(current_script_editor, 'HBoxContainer')
		overlays.highlight_controls([script_error_box])
		overlays.highlight_controls([current_script_editor.get_base_editor()])
	)
	complete_step()
	
	
	## 0350 intro to the timer node -------------------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.CENTER)
	bubble_set_title(gtr("The timer node"))
	bubble_add_text(
		[gtr("Meet the [b]Timer[/b] node!"),
		gtr("It's a simple node that can countdown in loop or not"),]
	)
	complete_step()
	
	
		
	## 0360 make sure it's still on player scene--------------------------------------------------
	highlight_tabs_title(interface.main_screen_tabs, 'player')
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.CENTER)
	bubble_set_title(gtr("The timer node"))
	bubble_add_text(
		[gtr("Make sure you are still on your player scene")]
	)
	bubble_add_task_set_tab_to_title(interface.main_screen_tabs, "player")
	complete_step()
	
	
	## 0370 make sure it's still on player scene--------------------------------------------------
	highlight_controls([interface.scene_dock_button_add])
	highlight_scene_nodes_by_name([EditorInterface.get_edited_scene_root().name])
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("The timer node - part 1"))
	bubble_add_task_focus_node(EditorInterface.get_edited_scene_root().name)
	bubble_add_task(
		gtr("Add a [b]Timer[/b] node to your player node"), 1,
		func task_add_node(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			if root.find_children("*", "Timer", false, true ).is_empty(): return 0 else: return 1,
	)
	complete_step()



	## 0380 select the timer node and toggle one_shot -------------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("The timer node - part 2"))
	bubble_add_text(
		[gtr("The one_shot property, when enabled, will stop the the timer after reaching the end. Otherwise, the timer will automatically restart."),
		gtr("Since this is timer that sets the bullet's fire rate, it makes sense that we want it to activate when the fire key is pressed and deactivate once the cooldown is over, right? 😉")]
	)
	highlight_scene_nodes_by_name(['Timer'])
	highlight_inspector_properties(['one_shot'])
	bubble_add_task_focus_node('Timer')
	bubble_add_task_toggle_property('one_shot')
	complete_step()
	
	
	## 0381 select the timer node and set Wait Time property ---------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("The timer node - part 2.1"))
	bubble_add_text(
		[gtr("[Optional] You can also adjust the [b]Wait Time[/b] of your timer."),
		gtr("This controls how long you have to wait before being able to shoot again. Think of it as setting your bullets-per-second, or your fire rate")]
	)
	highlight_scene_nodes_by_name(['Timer'])
	highlight_inspector_properties(['wait_time'])



	## 0390 rename timer node to shoot_cooldown --------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("The timer node - part 3"))
	bubble_add_text(
		[gtr("Great! So, we should rename our timer node to make it obvious what this timer is timing, don't you think? 🧐")]
	)
	highlight_scene_nodes_by_path([EditorInterface.get_edited_scene_root().name + "/Timer"])
	bubble_add_task_rename_node('shoot_cooldown', false)
	complete_step()


	
	## 0400 check the last error in player's script disapeared --------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Checking our player's script"))
	bubble_add_text(
		[gtr("Great! Let's go back to our player's code")]
	)
	bubble_add_task(
		gtr("Open the script %s attached  to the [b]player[/b] node." % bbcode_generate_icon_image_string(ICONS_MAP.script)), 1,
		func task_open_script(task: Task) -> int:
			if not interface.is_in_scripting_context(): return 0
			var script_player = EditorInterface.get_edited_scene_root().get_script().resource_path	
			var open_script: String = EditorInterface.get_script_editor().get_current_script().resource_path
			return 1 if open_script == script_player else 0,
	)
	highlight_scene_nodes_by_name([EditorInterface.get_edited_scene_root().name])
	complete_step()



	## 0410  the shoot_cooldown is yet to be declared on player's script---------------------------
	bubble_move_and_anchor(interface.inspector_dock, bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Almost set"))
	bubble_add_text(
		[gtr("Take a look at the error message..."),
		gtr("As we did with our Marker2D node, we still have to declare the [b]shoot_cooldown[/b] Timer node in the script!")]
	)
	queue_command(func ()->void: # highlighting the error message
		var current_script_editor = EditorInterface.get_script_editor().get_current_editor()
		var script_error_box = Utils.find_child_by_type(current_script_editor, 'HBoxContainer')
		overlays.highlight_controls([script_error_box])
	)
	complete_step()



	## 0420 declaring the shoot_cooldown on player's script ------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Declaring the shoot_cooldown"))
	bubble_add_text(
		[gtr("Take a look at the error message..."),
		gtr("As we did with our Marker2D node, we still have to declare the [b]shoot_cooldown[/b] Timer node in the script!"),
		gtr("You can [b]hold down CTRL[/b] and drag the node directly from the scene tree into your script [b]or[/b] just copy & paste the following code:")]
	)
	bubble_add_code(['@onready var shoot_cooldown = $shoot_cooldown'])
	mouse_click_drag_by_position(get_control_global_center(interface.scene_tree),  interface.script_editor_code_panel.get_global_rect().position + Vector2(200, 30))
	scroll_script(5, 1.5)
	highlight_controls([interface.script_editor_code_panel, interface.scene_dock])
	complete_step()



	## 0430 check the last error in player's script disapeared --------------------------------------------
	bubble_move_and_anchor(interface.inspector_dock, bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("No more errors? 😃"))
	bubble_add_text(
		[gtr("Now the function shoot_bullet()  is all set up"),]
	)
	scroll_script(900, 1)
	highlight_controls([interface.script_editor_code_panel])
	complete_step()



func steps_050_assigning_shoot_input_key()->void:
	queue_command(func()->void:
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_050_assigning_shoot_input_key"
		save_checkpoint(resource)
	)
	
	
	## 0440 open project settings --------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Defining shooting key/button"))
	bubble_add_text(
		[gtr("Now we need to establish what key or mouse button is assigned to shoot, right?"),
		gtr("To do that let's add a new input action"),]
	)
	queue_command(func(): # set project settings dialog window to not lock everything outside it
		var project_window = interface.proj_settings_dialog
		project_window.always_on_top = false
		project_window.exclusive = false
	)
	bubble_add_task(
		gtr("Open [b]Project[/b]->[b]Project Settings[/b]"), 1,
		func task_open_proj_settings(task: Task) -> int:
			var project_window = interface.proj_settings_dialog
			if project_window.visible: return 1 else: return 0,
	)
	highlight_controls([interface.menu_bar])
	complete_step()



	## 0450  Go to Input tab--------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Adding a new input action - part 1"))
	bubble_add_text(
		[gtr("Switch to the [b]Input Map[/b] tab"),]
	)
	bubble_add_task_set_tab_to_title(interface.proj_settings_tabs.find_children("*", "TabBar", false, false )[0], 'Input Map')
	highlight_tabs_index(interface.proj_settings_tabs, 1)
	queue_command(func(): 
		var project_editor_window = interface.proj_settings_dialog
		var screen_size = DisplayServer.window_get_size()
		project_editor_window.size = screen_size / 2
		project_editor_window.position = screen_size / 3
	)
	complete_step()



	## 0460 Add the action 'shoot' --------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Adding a new input action - part 2"))
	bubble_add_text(
		[gtr("Let's write the name of our new action."),
		gtr("We should name it [b]shoot[/b]"),]
	)
	queue_command(func()->void: 
		var input_map_LineEdit = interface.input_map_window.find_children("*", "LineEdit", true, false)
		overlays.highlight_controls([input_map_LineEdit[2]])
	)
	bubble_add_task(
		gtr("Type [b]shoot[/b] on the add new action bar"), 1,
		func task_type_lineEdit(task: Task) -> int:
			var input_map_LineEdit = interface.input_map_window.find_children("*", "LineEdit", true, false)
			var lineedit : LineEdit = input_map_LineEdit[2]
			if lineedit.text == "shoot" : return 1 else: return 0,
	)
	complete_step()



	## 0470 clicking on the add action button --------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Adding a new input action - part 3"))
	queue_command(func()->void:
		var input_map_LineEdit = interface.input_map_window.find_children("*", "LineEdit", true, false)
		var buttons = input_map_LineEdit[2].get_parent().find_children("*", "Button", true, false)
		var add_button = buttons[0]
		overlays.highlight_controls([add_button], true)
	)
	# this is the same add_button as the previous queue_command function. Due to time restraints I haven't figured out why bubble_add_task_press_button isn't working inside queue_command
	bubble_add_task_press_button(interface.input_map_window.find_children("*", "LineEdit", true, false)[2].get_parent().find_children("*", "Button", true, false)[0])
	complete_step()



	## 0480 clicking on the add action button --------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Adding a new input action - part 4"))
	bubble_add_text(
		[gtr("Search for it in the filter bar above where you just typed your new action."),
		gtr("Then, click the [b]+[/b] icon to assign the input you want"),
		gtr("This can be any key on your keyboard, or even a mouse button. Many people use the [b]F[/b] key or the [b]Left Mouse Button[/b]."),]
	)
	bubble_add_video(load('res://test_video.ogv'))
	complete_step()



	## 0490 closing project settings -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Action Input added 🥳"))
	bubble_add_text(
		[gtr("Great! now we can configure in your player's script what to do when this new action is activated"),
		gtr("[b]You can close the project settings.[/b]"),])
	bubble_add_video(load('res://test_video.ogv'))
	bubble_add_task(
		gtr("You can close the [b]project settings[/b]."), 1,
		func task_close_window(task: Task) -> int:
			var window = interface.proj_settings_dialog
			if window.visible : return 0 else: return 1,
	)
	context_display_a_script(scene_player_path)
	complete_step()



func steps_060_coding_final():
	queue_command(func()->void:
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_060_coding_final"
		save_checkpoint(resource)
	)
	
	
	## 0500 locating _process_physics in player's script -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Coding the shoot input"))
	bubble_add_text(
		[gtr("We need to return to the player's script and add code within the [b]_physics_process[/b] function."),
		gtr("Do you still remember what does the [b]_physics_process[/b] function do?\nIt runs automatically every physics step, so it's where we put code related to things like movement and interactions with the physics engine."),])
	context_set_script()
	queue_command(func ()->void:  
		var script: String = EditorInterface.get_edited_scene_root().get_script().source_code
		overlays.highlight_code_from_lines(script, 'func _physics_process', 'func')
	)
	complete_step()



	## 0510 Explaining what we about to code regarding input shoot ------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Coding the shoot input"))
	bubble_add_text(
		[gtr("We want to add what happens everytime that you order to a bullet to be shot. 🔫"),
		gtr("Imagine telling someone: 'If you press the shoot button, then shoot!' That's the idea.😃"),
		gtr("In our computer language, GDScript, we have special words for this:\nWe use the word [b]if[/b], and we check if you're pressing the shoot button using something called [b]Input[/b] and [b]is_action_pressed()[/b]."),
		gtr("You might already know some of these things, but we'll take another look to refresh your memory."),])
	queue_command(func ()->void:  
		var script: String = EditorInterface.get_edited_scene_root().get_script().source_code
		overlays.highlight_code_from_lines(script, 'func _physics_process', 'func')
	)
	complete_step()



	## 0520 writting input shoot code in player's script -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Coding the shoot input - part 1"))
	bubble_add_text(
		[gtr("Firstly we want to say if 'shoot' is triggered."),
		gtr("[b]Input[/b] - This is how Godot knows what the player is pressing"),
		gtr("[b].is_action_pressed()[/b] - This checks if a button is being held down (not just tapped)."),
		gtr("[b]'shoot'[/b] – This is the name of the action you created in the Input Map (in Project Settings)"),])
	bubble_add_code(["if Input.is_action_pressed('shoot'):"])
	complete_step()



	## 0530 writting input shoot code in player's script -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Coding the shoot input - part 2"))
	bubble_add_text(
		[gtr("We also want to use our timer, remember? We've already declared it in this script with the name [b]shoot_cooldown[/b]"),
		gtr("So, we want to trigger the shooting only if we press the shoot key/button [b]and[/b] if the shoot_cooldown has already finished its cooldown."),
		gtr("To check if the timer has finished counting down the time we specified, we can use a built-in method called [b].is_stopped().[/b]"),])
	bubble_add_code(["if Input.is_action_pressed('shoot') and shoot_cooldown.is_stopped():"])
	bubble_set_footer(".                                                                                                                                     .")
	complete_step()



	## 0530 writting input shoot code in player's script -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Coding the shoot input - part 3"))
	bubble_add_text(
		[gtr("Now we are ready to invoke our shoot function that we previously defined! 🤩"),
		gtr("As you can see, the function created is named [b]shoot_bullet[/b] "),])
	scroll_script_to_string('func shoot_bullet')
	queue_command(func()->void:
		var script: String = EditorInterface.get_edited_scene_root().get_script().source_code
		overlays.highlight_code_from_lines(script, 'func shoot_bullet', 'shoot_cooldown', 0, false)
	)
	complete_step()



	## 0530 writting input shoot code in player's script -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Coding the shoot input - part 4"))
	bubble_add_text(
		[gtr("To call a function we just need to type its name following by ()"),
		gtr("The function created is named [b]shoot_bullet[/b]"),])
	bubble_add_code(["if Input.is_action_pressed('shoot') and shoot_cooldown.is_stopped():
		shoot_bullet()"])
	scroll_script_to_string('func _physics_process')
	queue_command(func ()->void:  
		var script: String = EditorInterface.get_edited_scene_root().get_script().source_code
		overlays.highlight_code_from_lines(script, 'func _physics_process', 'func', 0, false)
	)
	scroll_script_to_string('func _physics_process', 2)
	bubble_add_task(
		gtr("Add the code inside your [b]_process_physics()[/b] function"), 1,
		func task_write_code(task: Task) -> int:
			var script: String = EditorInterface.get_edited_scene_root().get_script().source_code
			if script.contains("if Input.is_action_pressed('shoot') and shoot_cooldown.is_stopped():
		shoot_bullet()"): return 1
			else: return 0,
	)
	bubble_set_footer(".                                                                                                                                     .")
	complete_step()



	## 0530 writting input shoot code in player's script -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Shoot direction coding - part 1"))
	bubble_add_text(
		[gtr("Then, we would also like to confirm the direction where we should shoot at."),
		gtr("For that we have the [b]sign()[/b] function. It's like a math shortcut that tells you if a number is:"),
		gtr("-1 → Negative (left side of screen)"),
		gtr("0 → Zero (middle)"),
		gtr("1 → Positive (right side)"),])
	bubble_add_code(["	if Input.is_action_pressed('ui_left'):
		if sign(bullet_position.position.x) == 1:"]
	)
	complete_step()



	## 0540 writting input shoot code in player's script -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Shoot direction coding- part 3"))
	bubble_add_text(
		[gtr("This line flips the bullet’s position from one side to the other, like a mirror!"),])
	bubble_add_code(["bullet_position.position.x *= -1"])
	bubble_add_text(
		[gtr("[b]bullet_position.position.x[/b] That’s the bullet’s position on the X-axis (left or right side of the screen)."),
		gtr("[b]*= -1[/b] This means: Take the number and multiply it by -1, then save the result back."),])
	complete_step()



	## 0550 writting input shoot code in player's script -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Shoot direction coding - part 4"))
	bubble_add_text(
		[gtr("All in all, it should look like this:"),])
	bubble_add_code(["	if Input.is_action_pressed('ui_left'):
		if sign(bullet_position.position.x) == 1:
			bullet_position.position.x *= -1"]
	)
	bubble_add_task(
		gtr("Add the code inside your [b]_process_physics()[/b] function"), 1,
		func task_write_code(task: Task) -> int:
			var script: String = EditorInterface.get_edited_scene_root().get_script().source_code
			if script.contains("	if Input.is_action_pressed('ui_left'):
		if sign(bullet_position.position.x) == 1:
			bullet_position.position.x *= -1"): return 1
			else: return 0,
	)
	queue_command(func ()->void:  
		var script: String = EditorInterface.get_edited_scene_root().get_script().source_code
		overlays.highlight_code_from_lines(script, 'func _physics_process', 'func')
	)
	bubble_set_footer("⚠️It has at least to be added before move_and_slide()")
	complete_step()



	## 0560 the inverse code has to be written too -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Shoot direction coding - part 5"))
	bubble_add_text(
		[gtr("Excellent!😊 We've handled the left direction. Now, we also need to add the opposite logic for the ui_right action, which corresponds to moving right."),])
	bubble_add_code(["	if Input.is_action_pressed('ui_right'):
		if sign(bullet_position.position.x) == -1:
			bullet_position.position.x *= -1"]
	)
	bubble_add_text(
		[gtr("⚠️Remember that apart from the [b]ui_right[/b] action change, the second line also has a difference. It's checking if the bullet's direction is [b]-1[/b], which corresponds to moving left.⚠️"),])
	bubble_add_task(
		gtr("Add the code inside your [b]_process_physics()[/b] function"), 1,
		func task_write_code(task: Task) -> int:
			var script: String = EditorInterface.get_edited_scene_root().get_script().source_code
			if script.contains("	if Input.is_action_pressed('ui_right'):
		if sign(bullet_position.position.x) == -1:
			bullet_position.position.x *= -1"): return 1
			else: return 0,
	)
	queue_command(func ()->void:  
		var script: String = EditorInterface.get_edited_scene_root().get_script().source_code
		overlays.highlight_code_from_lines(script, 'func _physics_process', 'func')
	)
	bubble_set_footer("⚠️It has at least to be added before move_and_slide()")
	complete_step()



	## 0570 overall explaination of the input code -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Shoot direction coding - recap"))
	bubble_add_text(
		[gtr("This code makes sure the bullet is always on the same side the player is facing."),
		gtr("If the player presses [b]right[/b] and the bullet is on the left, it flips it to the [b]right[/b]."),
		gtr("If the player presses [b]left[/b] and the bullet is on the right, it flips it to the [b]left[/b]."),
		gtr("It keeps the bullet’s position in sync with the player’s direction."),])
	complete_step()



	## 0580 overall explaination of the input code -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Test your game! 🥳"))
	bubble_add_text(
		[gtr("Congrats! you are all set to test your game!"),
		gtr("Click the play icon in the top right of the editor to run the Godot project."),
		gtr("Test if your player can now shoot in both directions"),])
	highlight_controls([interface.run_bar_play_button], true)
	bubble_add_task_press_button(interface.run_bar_play_button)
	complete_step()
	
	
	## 0590 overall explaination of the input code -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.CENTER)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Overall recap"))
	bubble_add_text(
		[gtr("In short, you created a bullet scene with all the parts it needs: a way to detect hits (Area2D), a visual (Sprite2D), a collision shape (CollisionShape2D), and a screen checker (VisibleOnScreenEnabler2D)."),
		gtr("Then, you added a script to the bullet to manage its speed and make it face the right way."),
		gtr("AftNext, you prepared your player by adding a place for bullets to come out (Marker2D) and a way to limit shooting speed (Timer)."),
		gtr("Finally, you wrote code in the player to make new bullets when you press the fire button and to tell each bullet which direction to shoot based on the player's direction."),])
	complete_step()



	## 0590 overall explaination of the input code -------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, bubble.At.CENTER)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("What now?"))
	bubble_add_text(
		[gtr("You did it! Now the fun continues! Think about how you can make your shooting even more exciting – maybe replacing the Sprite2D for an AnimationSprite2D, effect sounds, or explosions!"),
		gtr("Want to keep learning and creating? Explore our other tutorials!"),])
	complete_step()
	
