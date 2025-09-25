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
		steps_010_intro,
		steps_020_player_script]

	var last_checkpoint : String = load_checkpoint(checkpoint_res_path)
	if last_checkpoint.is_empty():
		for step in steps_func:
			step.call()
	else:
		var starting_step_idx: int = steps_func.find(Callable(self, last_checkpoint))
		for i in range(steps_func.size() - starting_step_idx): # execute steps starting from the last checkpoint
			steps_func[i+starting_step_idx].call()
			  

func steps_010_intro() -> void:
	# 0010: introduction ----------------------------------------------------------------------
	context_set_2d()
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_set_title("Player Movement")
	bubble_add_texture(TEXTURE_BULLET_SHOOT_EXAMPLE)
	bubble_add_text(
		[gtr("In this lesson, you will learn how to create your player and make it move with your keyboard"),
		gtr("You will also learn gravity and"),
		gtr("[center][b]Let's get started![/b][/center]"),]
	)
	queue_command(func avatar_wink(): bubble.avatar.do_wink())
	complete_step()
	
	
	
	# 0011: Press add node button  ------------------------------------------------------------------
	highlight_controls([interface.scene_dock_button_add])
	mouse_move_by_callable(
		func(): return interface.canvas_item_editor.get_global_rect().get_center(),
		func(): return interface.scene_dock_button_add.get_global_rect().get_center()
	)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_title("Adding a node")
	bubble_add_text(
		[gtr("Add a Node"),
		gtr("Click on plus icon"),]
	)
	bubble_add_task_press_button(interface.scene_dock_button_add)
	complete_step()
	
	
	
	# 0012: Adding the Node2D  ----------------------------------------------------------------------
	highlight_controls([interface.node_create_panel])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_title("Adding a node")
	bubble_add_text(
		[gtr("Add a Node2D"),
		gtr("Click on plus icon"),]
	)
	bubble_add_task(
		gtr("Add an [b]Node2D[/b] node"), 1,
		func task_add_node(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			if root.is_class('Node2D'): return 1 else: return 0,
	)
	complete_step()
	
	
	
	# 0013: Adding CharacterBody2D-------------------------------------------------------------------
	highlight_controls([interface.scene_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_title("Adding a node")
	bubble_add_text(
		[gtr("Add a CharacterBody2D node"),
		gtr("C "),]
	)
	bubble_add_task(
		gtr("Add an [b]CharacterBody2D[/b] node"), 1,
		func task_add_node(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			var char_body_node = root.find_child('CharacterBody2D')
			if char_body_node.is_class('CharacterBody2D'): return 1 else: return 0,
	)
	complete_step()



	# 0014: focus on CharacterBody2D ----------------------------------------------------------------
	highlight_controls([interface.scene_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_title("Adding a node")
	bubble_add_text(
		[gtr("Focus on CharacterBody2D"),
		gtr("C "),]
	)
	bubble_add_task_focus_node('CharacterBody2D')
	complete_step()



	# 0015: Add a Sprite2D and a CollisionShape2D node ---------------------------------------------
	highlight_controls([interface.scene_dock_button_add])
	queue_command(func()->void: overlays.toggle_dimmers(false))
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_title("Adding a node")
	bubble_add_text(
		[gtr("Add a Sprite2D and a CollisionShape2D node"),
		gtr("C "),]
	)
	bubble_add_task(
		gtr("Add an [b]Sprite2D[/b] node"), 1,
		func task_add_node(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			var char_body_node = root.find_child('CharacterBody2D')
			var sprite_node = char_body_node.find_child('Sprite2D')
			if sprite_node.is_class('Sprite2D'): return 1 else: return 0,
	)
	bubble_add_task(
		gtr("Add an [b]CollisionShape2D[/b] node"), 1,
		func task_add_node(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			var char_body_node = root.find_child('CharacterBody2D')
			var sprite_node = char_body_node.find_child('CollisionShape2D')
			if sprite_node.is_class('CollisionShape2D'): return 1 else: return 0,
	)
	complete_step()
	
	
	
	# 0016: adding texture to sprite ----------------------------------------------------------------
	context_set_2d()
	queue_command(func()->void: overlays.toggle_dimmers(false))
	highlight_controls([interface.scene_dock, interface.inspector_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_title("Adding a texture to Sprite")
	bubble_add_text(
		[gtr("Adding a texture to your Sprite2D"),
		gtr(" (add a video) "),]
	)
	bubble_add_task_focus_node('Sprite2D')
	complete_step()
	
	
	
	# 0017: adding texture to sprite ----------------------------------------------------------------
	context_set_2d()
	queue_command(func()->void: overlays.toggle_dimmers(false))
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_title("Adding a texture to Sprite")
	bubble_add_text(
		[gtr("You can Strech sprite"),
		gtr(" (add a video) "),]
	)
	complete_step()



	# 0018: adding collision to CollisionShape2D ----------------------------------------------------------------
	context_set_2d()
	queue_command(func()->void: overlays.toggle_dimmers(false))
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_title("Adding a collision to CollisionShape2D")
	bubble_add_text(
		[gtr("Adding a collision shape. Like in your sprite, you can adjust its height and length"),
		gtr(" (add a video) "),]
	)
	bubble_add_task_focus_node('CollisionShape2D')
	complete_step()



	# 0019: rename CharacterBody2D to player --------------------------------------------------------
	context_set_2d()
	highlight_controls([interface.scene_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title("rename CharacterBody2D to player")
	bubble_add_text(
		[gtr("rename CharacterBody2D to player, double click on the node"),
		gtr(" (add a video) "),]
	)
	bubble_add_task(
		gtr("Rename [b]CharacterBody2D[/b] to [b]player[/b]"), 1,
		func task_rename_node(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			var char_body_node = root.find_child('player')
			if char_body_node.is_class('CharacterBody2D'): return 1 else: return 0,
	)
	complete_step()
	
	


func steps_020_player_script() -> void:
	queue_command(func()->void:
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_020_player_script"
		save_checkpoint(resource)
	)


	# 0020: attach script to the player --------------------------------------------------------
	highlight_controls([interface.scene_dock])
	mouse_move_by_callable(
		func(): return interface.canvas_item_editor.get_rect().get_center(),
		func(): return interface.scene_dock_button_add_script.get_global_rect().get_center()
	)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(bubble.AvatarAt.RIGHT)
	bubble_set_title("attach script to player")
	bubble_add_text(
		[gtr("attach script to player"),
		gtr(" (add a video) "),]
	)
	bubble_add_task_focus_node('player')
	bubble_add_task_press_button(interface.scene_dock_button_add_script, 'attatch new script')
	complete_step()



	# 0021: panel create script --------------------------------------------------------
	queue_command(func()->void: overlays.toggle_dimmers(false))
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_title("create a script attached to the player")
	bubble_add_text(
		[gtr("click on create, make sure it will be named player.gd"),
		gtr(" (add a video) "),]
	)
	# bubble_add_video()
	complete_step()



	# 0022: analising script code --------------------------------------------------------
	context_set_script()
	highlight_controls([interface.script_editor_code_panel])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER_RIGHT)
	bubble_set_title("understanding the code")
	bubble_add_text(
		[gtr("inspect code lines"),
		gtr(" (add a video) "),]
	)
	# bubble_add_video()
	complete_step()



	# 0023: rename main node to world -----------------------------------------------------
	highlight_controls([interface.scene_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_title("rename main node to world")
	bubble_add_text(
		[gtr("rename main node to world"),
		gtr(" (add a video) "),]
	)
	bubble_add_task(
		gtr("Rename [b]Node2D[/b] to [b]world[/b]"), 1,
		func task_rename_node(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			if root.name == 'world': return 1 else: return 0,
	)
	complete_step()
	

	# 0024: run the code to see what happens -----------------------------------------------------
	highlight_controls([interface.run_bar_play_button])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER_RIGHT)
	bubble_set_title("run the code to see what happens")
	bubble_add_text(
		[gtr("First you have to save the scene"),
		gtr(" (add a video) "),]
	)
	# bubble_add_video()
	bubble_add_task_press_button(interface.run_bar_play_button)
	complete_step()



	# 0024: needs a floor  --------------------------------------------------------
	highlight_controls([interface.scene_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_title("needs a floor")
	bubble_add_text(
		[gtr("Player falls indefinetly right? needs a privisory floor to test ur playa"),
		gtr(" "),]
	)
	bubble_add_task_focus_node('world')
	complete_step()



	# 0025: create a floor  --------------------------------------------------------
	highlight_controls([interface.scene_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_title("needs a floor")
	bubble_add_text(
		[gtr("Player falls indefinetly right? needs a privisory floor to test ur playa"),
		gtr(" "),]
	)
	bubble_add_task(
		gtr("Add an [b]StaticBody2D[/b] node"), 1,
		func task_add_node(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			var static_body_node = root.find_child('StaticBody2D')
			if static_body_node.is_class('StaticBody2D'): return 1 else: return 0,
	)
	complete_step()



	# 0026: run again the code to see what happens --------------------------------------------------------
	highlight_controls([interface.run_bar_play_button])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER_RIGHT)
	bubble_set_title("AGAIN run the code to see what happens")
	bubble_add_text(
		[gtr(" "),
		gtr(" (add a video) "),]
	)
	bubble_add_task_press_button(interface.run_bar_play_button)
	complete_step()



	# 0027: some little explaination --------------------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER_RIGHT)
	bubble_set_title("")
	bubble_add_text(
		[gtr("you can edit CONSTs velocity and jumpforce"),
		gtr(""),]
	)
	complete_step()
