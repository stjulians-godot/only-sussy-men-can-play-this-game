extends "res://addons/godot_tours/tour.gd"

const Gobot := preload("res://addons/godot_tours/bubble/gobot/gobot.gd")

const TEXTURE_BUBBLE_BACKGROUND := preload("res://addons/godot_tours/assets/icons/bubble-background.png")
const TEXTURE_GDQUEST_LOGO := preload("res://addons/godot_tours/assets/icons/bubble-background.png")
const TEXTURE_PARALLAX_EXAMPLE := preload("res://tours/03_parallax_layers/tour_assets/parallax_example.png")
const TEXTURE_PARALLAX_DEPTH := preload("res://tours/03_parallax_layers/tour_assets/parallax_depth_example.png")
const VIDEO_PARALLAX_EFFECT := preload("res://tours/03_parallax_layers/tour_assets/parallax_effect.ogv")

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

const checkpoint_res_path: String = "res://tours/03_parallax_layers/checkpoint.tres"

var scene_pre_made_path := "res://tours/03_parallax_layers/tour_assets/03_pre_scene.tscn"

# Parallax layer textures
var parallax_textures := [
	"res://tours/03_parallax_layers/tour_assets/parallax_images/forest_sky.png",
	"res://tours/03_parallax_layers/tour_assets/parallax_images/forest_mountain.png", 
	"res://tours/03_parallax_layers/tour_assets/parallax_images/forest_back.png",
	"res://tours/03_parallax_layers/tour_assets/parallax_images/forest_long.png",
	"res://tours/03_parallax_layers/tour_assets/parallax_images/forest_mid.png"
]

# "res://tours/03_parallax_layers/tour_assets/parallax_images/forest_short.png"

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
		ProjectSettings.set_setting('rendering/textures/canvas_textures/default_texture_filter', 'Nearest')
	)

	var steps_func : Array[Callable] = [
		steps_010_intro,
		steps_020_open_pre_scene,
		steps_030_add_parallax2d_node,
		steps_040_create_parallax_layers,
		steps_050_add_camera2d,
		steps_060_configure_motion_scale,
		steps_070_set_camera_limits,
		steps_080_test_movement,
		steps_090_wrap_up
	]

	var last_checkpoint : String = load_checkpoint(checkpoint_res_path)
	if last_checkpoint.is_empty():
		for step in steps_func:
			step.call()
	else:
		var starting_step_idx: int = steps_func.find(Callable(self, last_checkpoint))
		for i in range(steps_func.size() - starting_step_idx):
			steps_func[i+starting_step_idx].call()


func steps_010_intro() -> void:
	# 0010: introduction ----------------------------------------------------------------------
	context_set_2d()
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_set_title("Creating Parallax Backgrounds")
	bubble_add_texture(TEXTURE_PARALLAX_EXAMPLE)
	bubble_add_text(
		[gtr("In this lesson, you will learn how to create stunning parallax backgrounds using Godot's new Parallax2D node!"),
		gtr("Parallax scrolling creates the illusion of depth by moving background elements at different speeds."),
		gtr("Objects closer to the camera move faster, while distant objects move slower."),
		gtr("[center][b]Let's create some visual magic![/b][/center]"),]
	)
	queue_command(func avatar_wink(): bubble.avatar.do_wink())
	complete_step()

	# 0011: what is parallax effect ------------------------------------------------------------
	bubble_set_title(gtr("What is Parallax Scrolling? 🌄"))
	bubble_add_video(VIDEO_PARALLAX_EFFECT)
	bubble_add_text([
		gtr("Parallax scrolling is a visual technique where background images move slower than foreground images."),
		gtr("This creates an illusion of depth and makes your game world feel more dynamic and alive."),
		gtr("Think about looking out a car window - distant mountains move slowly while nearby trees blur past quickly!")
	])
	complete_step()

	# 0012: Godot 4.3 new feature ------------------------------------------------------------
	bubble_set_title(gtr("Meet Parallax2D! ✨"))
	bubble_add_text([
		gtr("In Godot 4.3, we got a fantastic new node called [b]Parallax2D[/b]!"),
		gtr("This node simplifies creating parallax effects compared to the old ParallaxBackground system."),
		gtr("Each background layer gets its own Parallax2D node, making organization much cleaner."),
		gtr("It's still experimental, but it's much easier to use and understand!")
	])
	complete_step()


func steps_020_open_pre_scene() -> void:
	queue_command(func()->void:
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_020_open_pre_scene"
		save_checkpoint(resource)
	)

	# 0020: Open the pre-made scene -----------------------------------------------------------
	queue_command(func()->void: overlays.toggle_dimmers(false))
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("The pre-made scene"))
	bubble_add_text(
		[gtr("I've prepared a scene for you with a basic player and ground setup."),]
	)
	scene_open(scene_pre_made_path)
	complete_step()

	# 0021: Explore the pre-made scene --------------------------------------------------------
	highlight_controls([interface.scene_tree], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_title(gtr("Explore the scene structure"))
	bubble_add_text(
		[gtr("Let's take a look at what we have:"),
		gtr("• [b]World[/b] - A Node2D that contains everything"),
		gtr("• [b]Player[/b] - A CharacterBody2D with movement capabilities"),
		gtr("• [b]Ground[/b] - A StaticBody2D for our character to walk on"),
		gtr("This gives us a foundation to add our parallax magic to!")]
	)
	complete_step()

func steps_030_add_parallax2d_node() -> void:
	queue_command(func()->void:
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_030_add_parallax2d_node"
		save_checkpoint(resource)
	)

	# 0030: Add first Parallax2D node ---------------------------------------------------------
	highlight_controls([interface.scene_dock_button_add], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Add your first Parallax2D node"))
	bubble_add_text(
		[gtr("Let's start by adding our first background layer."),
		gtr("Select the [b]World[/b] node, then click the [b]+[/b] icon to add a new node."),
		gtr("Search for [b]Parallax2D[/b] and add it.")]
	)
	bubble_add_task_press_button(interface.scene_dock_button_add)
	bubble_add_task(
		gtr("Add a [b]Parallax2D[/b] node"), 1,
		func task_add_node(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			if not root.find_children("*", "Parallax2D", false, true).is_empty(): return 1 else: return 0,
	)
	complete_step()

	# 0031: Add Sprite2D to first Parallax2D --------------------------------------------------
	highlight_controls([interface.scene_dock_button_add, interface.scene_tree], true)
	bubble_set_title(gtr("Add visual content to the layer"))
	bubble_add_text(
		[gtr("Each Parallax2D needs visual content to display."),
		gtr("With the Parallax2D node selected, add a [b]Sprite2D[/b] as its child."),
		gtr("This will hold our background image.")]
	)
	bubble_add_task(
		gtr("Add a [b]Sprite2D[/b] node to the Parallax2D"), 1,
		func task_add_sprite(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			var parallax2d = root.find_child("Parallax2D", true, true)
			if parallax2d and not parallax2d.find_children("*", "Sprite2D", false, true).is_empty():
				return 1
			else:
				return 0,
	)
	complete_step()

func steps_040_create_parallax_layers() -> void:
	queue_command(func()->void:
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_040_create_parallax_layers"
		save_checkpoint(resource)
	)

	# 0040: Assign sky texture ----------------------------------------------------------------
	highlight_controls([interface.inspector_dock], true)
	highlight_inspector_properties(['texture'])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_title(gtr("Assign the sky texture"))
	bubble_add_text(
		[gtr("Now let's give our first layer its background image."),
		gtr("Select the [b]Sprite2D[/b] node and look at the Inspector."),
		gtr("Drag [b]forest_sky.png[/b] from [b]res://tours/03_parallax_layers/tour_assets/parallax_images[/b] into the Texture property.")]
	)
	bubble_add_task_select_nodes_by_path(["World/Parallax2D/Sprite2D"])
	bubble_add_task(
		gtr("Drag the sky sprite to the Sprite2D's texture property"), 1,
		func task_drag_texture(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			var sprite_node = root.find_children("*", "Sprite2D", false, true)
			if not sprite_node.is_empty() and sprite_node.texture != null: 
				return 1 else: return 0,
	)
	complete_step()

	# 0041: Rename for organization -----------------------------------------------------------
	highlight_controls([interface.scene_tree], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_title(gtr("Organize with good names"))
	bubble_add_text(
		[gtr("Let's rename our nodes to keep things organized."),
		gtr("Right-click on the Parallax2D node and rename it to [b]sky_layer[/b].")]
	)
	bubble_add_task_rename_node("sky_layer", false)
	complete_step()

	# 0042: Create more parallax layers -------------------------------------------------------
	highlight_controls([interface.scene_tree], true)
	bubble_set_title(gtr("Create the remaining layers"))
	bubble_add_text(
		[gtr("A convincing parallax effect needs multiple layers at different depths."),
		gtr("Let's create 4 more Parallax2D nodes, each with its own Sprite2D child."),
		gtr("We'll use these textures in order: [b]clouds.png, mountains.png, hills.png, trees.png[/b]")]
	)
	bubble_add_task_focus_node("World", "Select the World node")
	bubble_add_task(
		gtr("Create 4 more [b]Parallax2D[/b] nodes, each with a [b]Sprite2D[/b] child"), 1,
		func task_create_all_layers(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			var parallax_nodes = root.find_children("*", "Parallax2D", false, true)
			if parallax_nodes.size() >= 5:
				# Check if each has a Sprite2D child
				for parallax in parallax_nodes:
					if parallax.find_children("*", "Sprite2D", false, true).is_empty():
						return 0
				return 1
			return 0,
	)
	complete_step()


	# 0043: Assign all textures ---------------------------------------------------------------
	queue_command(func()->void: overlays.toggle_dimmers(false))
	bubble_set_title(gtr("Assign all the textures"))
	bubble_add_text(
		[gtr("Now assign the remaining textures to each Sprite2D:"),
		gtr("• Second layer: [b]clouds.png[/b]"),
		gtr("• Third layer: [b]mountains.png[/b]"),
		gtr("• Fourth layer: [b]hills.png[/b]"),
		gtr("• Fifth layer: [b]trees.png[/b]"),
		gtr("Drag each PNG file from the FileSystem to the Texture property of its corresponding Sprite2D.")]
	)
	complete_step()

	# 0044: Rename all layers for organization ------------------------------------------------
	bubble_set_title(gtr("Name all your layers"))
	bubble_add_text(
		[gtr("Rename your Parallax2D nodes to match their content:"),
		gtr("• [b]SkyLayer[/b] (already done)"),
		gtr("• [b]CloudsLayer[/b]"),
		gtr("• [b]MountainsLayer[/b]"), 
		gtr("• [b]HillsLayer[/b]"),
		gtr("• [b]TreesLayer[/b]"),
		gtr("Good organization makes everything easier to work with!")]
	)
	complete_step()

func steps_050_add_camera2d() -> void:
	queue_command(func()->void:
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_050_add_camera2d"
		save_checkpoint(resource)
	)

	# 0050: Add Camera2D to player ------------------------------------------------------------
	highlight_controls([interface.scene_dock_button_add], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Add Camera2D to the player"))
	bubble_add_text(
		[gtr("For parallax to work, we need a camera that follows our player."),
		gtr("Select the [b]Player[/b] node and add a [b]Camera2D[/b] as its child."),
		gtr("This will make the camera follow the player automatically!")]
	)
	bubble_add_task_focus_node("Player", "Select the Player node")
	bubble_add_task(
		gtr("Add a [b]Camera2D[/b] node to the Player"), 1,
		func task_add_camera(task: Task) -> int:
			var root = EditorInterface.get_edited_scene_root()
			var player = root.find_child("Player", true, true)
			if player and not player.find_children("*", "Camera2D", false, true).is_empty():
				return 1
			else:
				return 0,
	)
	complete_step()

	# 0051: Enable Camera2D -------------------------------------------------------------------
	highlight_controls([interface.inspector_dock], true)
	highlight_inspector_properties(['enabled'])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_title(gtr("Enable the camera"))
	bubble_add_text(
		[gtr("Make sure the Camera2D is active by checking that [b]Enabled[/b] is turned on."),
		gtr("You should also see a blue camera icon in the 2D viewport when the Camera2D is selected."),
		gtr("This camera will automatically become the current camera for the scene.")]
	)
	bubble_add_task_focus_node("Camera2D", "Select the Camera2D node")
	complete_step()

func steps_060_configure_motion_scale() -> void:
	queue_command(func()->void:
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_060_configure_motion_scale"
		save_checkpoint(resource)
	)

	# 0060: Explain scroll_scale ---------------------------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_title(gtr("Understanding Scroll Scale"))
	bubble_add_texture(TEXTURE_PARALLAX_DEPTH)
	bubble_add_text(
		[gtr("Each Parallax2D has a [b]Scroll Scale[/b] property that controls how fast it scrolls."),
		gtr("• Values less than 1.0 = Slower than camera (distant objects)"),
		gtr("• Value of 1.0 = Same speed as camera"),
		gtr("• Values greater than 1.0 = Faster than camera (close objects)"),
		gtr("The key to good parallax is using different speeds for different depths!")]
	)
	complete_step()

	# 0061: Configure sky layer - slowest -----------------------------------------------------
	highlight_controls([interface.inspector_dock], true)
	highlight_inspector_properties(['scroll_scale'])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_title(gtr("Configure the sky layer - slowest"))
	bubble_add_text(
		[gtr("Let's start with the furthest layer (sky)."),
		gtr("Select your [b]SkyLayer[/b] and set its Scroll Scale X to [b]0.1[/b]."),
		gtr("This makes it move very slowly, like a distant sky should.")]
	)
	bubble_add_task_focus_node("SkyLayer", "Select the SkyLayer")
	bubble_add_task(
		gtr("Set Scroll Scale X to [b]0.1[/b]"), 1,
		func task_set_sky_scale(task: Task) -> int:
			var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
			if selected_nodes.size() > 0:
				var node = selected_nodes[0]
				if node.is_class("Parallax2D") and abs(node.scroll_scale.x - 0.1) < 0.01:
					return 1
			return 0,
	)
	complete_step()

	# 0062: Configure clouds layer ------------------------------------------------------------
	bubble_set_title(gtr("Configure the clouds layer"))
	bubble_add_text(
		[gtr("Now select your [b]CloudsLayer[/b]."),
		gtr("Set its Scroll Scale X to [b]0.2[/b]."),
		gtr("Clouds are still distant, but closer than the sky.")]
	)
	bubble_add_task_focus_node("CloudsLayer", "Select the CloudsLayer")
	bubble_add_task(
		gtr("Set Scroll Scale X to [b]0.2[/b]"), 1,
		func task_set_clouds_scale(task: Task) -> int:
			var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
			if selected_nodes.size() > 0:
				var node = selected_nodes[0]
				if node.is_class("Parallax2D") and abs(node.scroll_scale.x - 0.2) < 0.01:
					return 1
			return 0,
	)
	complete_step()

	# 0063: Configure mountains layer ---------------------------------------------------------
	bubble_set_title(gtr("Configure the mountains layer"))
	bubble_add_text(
		[gtr("Select your [b]MountainsLayer[/b]."),
		gtr("Set its Scroll Scale X to [b]0.3[/b]."),
		gtr("Mountains are in the middle distance.")]
	)
	bubble_add_task_focus_node("MountainsLayer", "Select the MountainsLayer")
	bubble_add_task(
		gtr("Set Scroll Scale X to [b]0.3[/b]"), 1,
		func task_set_mountains_scale(task: Task) -> int:
			var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
			if selected_nodes.size() > 0:
				var node = selected_nodes[0]
				if node.is_class("Parallax2D") and abs(node.scroll_scale.x - 0.3) < 0.01:
					return 1
			return 0,
	)
	complete_step()

	# 0064: Configure hills layer -------------------------------------------------------------
	bubble_set_title(gtr("Configure the hills layer"))
	bubble_add_text(
		[gtr("Select your [b]HillsLayer[/b]."),
		gtr("Set its Scroll Scale X to [b]0.5[/b]."),
		gtr("Hills are closer, so they move a bit faster.")]
	)
	bubble_add_task_focus_node("HillsLayer", "Select the HillsLayer")
	bubble_add_task(
		gtr("Set Scroll Scale X to [b]0.5[/b]"), 1,
		func task_set_hills_scale(task: Task) -> int:
			var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
			if selected_nodes.size() > 0:
				var node = selected_nodes[0]
				if node.is_class("Parallax2D") and abs(node.scroll_scale.x - 0.5) < 0.01:
					return 1
			return 0,
	)
	complete_step()

	# 0065: Configure trees layer - fastest ---------------------------------------------------
	bubble_set_title(gtr("Configure the trees layer - fastest"))
	bubble_add_text(
		[gtr("Finally, select your [b]TreesLayer[/b]."),
		gtr("Set its Scroll Scale X to [b]0.8[/b]."),
		gtr("Trees are closest to the camera, so they should move almost as fast as the player.")]
	)
	bubble_add_task_focus_node("TreesLayer", "Select the TreesLayer")
	bubble_add_task(
		gtr("Set Scroll Scale X to [b]0.8[/b]"), 1,
		func task_set_trees_scale(task: Task) -> int:
			var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
			if selected_nodes.size() > 0:
				var node = selected_nodes[0]
				if node.is_class("Parallax2D") and abs(node.scroll_scale.x - 0.8) < 0.01:
					return 1
			return 0,
	)
	complete_step()

func steps_070_set_camera_limits() -> void:
	queue_command(func()->void:
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_070_set_camera_limits"
		save_checkpoint(resource)
	)

	# 0070: Explain camera limits -------------------------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_title(gtr("Setting Camera Limits"))
	bubble_add_text(
		[gtr("We need to set limits on our camera so it doesn't show empty space beyond our backgrounds."),
		gtr("The [b]Limit[/b] properties prevent the camera from scrolling past certain boundaries."),
		gtr("This keeps our parallax backgrounds looking perfect at the edges!")]
	)
	complete_step()

	# 0071: Configure camera limits -----------------------------------------------------------
	highlight_controls([interface.inspector_dock], true)
	highlight_inspector_properties(['limit_top', 'limit_bottom'])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_title(gtr("Set the vertical limits"))
	bubble_add_text(
		[gtr("Select your [b]Camera2D[/b] node and look at the Limit properties."),
		gtr("Set [b]Limit Top[/b] to prevent the camera from going too high."),
		gtr("Set [b]Limit Bottom[/b] to prevent it from going too low."),
		gtr("Try values like [b]-200[/b] for top and [b]200[/b] for bottom to start with.")]
	)
	bubble_add_task_focus_node("Camera2D", "Select the Camera2D node")
	bubble_add_task(
		gtr("Set appropriate [b]Limit Top[/b] and [b]Limit Bottom[/b] values"), 1,
		func task_set_limits(task: Task) -> int:
			var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
			if selected_nodes.size() > 0:
				var camera = selected_nodes[0]
				if camera.is_class("Camera2D"):
					# Check if limits have been changed from default (0)
					if camera.limit_top != 0 or camera.limit_bottom != 0:
						return 1
			return 0,
	)
	complete_step()

	# 0072: Optional horizontal limits --------------------------------------------------------
	bubble_set_title(gtr("Optional: Horizontal limits"))
	bubble_add_text(
		[gtr("You can also set [b]Limit Left[/b] and [b]Limit Right[/b] if you want to constrain horizontal movement."),
		gtr("This is useful for levels with specific boundaries."),
		gtr("For now, let's leave these as default (0) for unlimited horizontal scrolling.")]
	)
	complete_step()

func steps_080_test_movement() -> void:
	queue_command(func()->void:
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_080_test_movement"
		save_checkpoint(resource)
	)

	# 0080: Test the parallax effect ----------------------------------------------------------
	highlight_controls([interface.run_bar_play_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_CENTER)
	bubble_set_title(gtr("Test your parallax effect! 🎮"))
	bubble_add_text(
		[gtr("Time to see your parallax background in action!"),
		gtr("Run your game and move your player left and right."),
		gtr("Watch how the background layers move at different speeds, creating depth!")]
	)
	bubble_add_task_press_button(interface.run_bar_play_button)
	complete_step()

	# 0081: Observe the effect ----------------------------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_title(gtr("What to observe 👀"))
	bubble_add_text(
		[gtr("As your player moves, notice how:"),
		gtr("• The [b]sky[/b] barely moves (0.1 scale)"),
		gtr("• The [b]clouds[/b] move slowly (0.2 scale)"),
		gtr("• The [b]mountains[/b] move a bit faster (0.3 scale)"),
		gtr("• The [b]hills[/b] move even faster (0.5 scale)"),
		gtr("• The [b]trees[/b] move almost as fast as the player (0.8 scale)"),
		gtr("This creates a convincing sense of depth and distance!")]
	)
	complete_step()

	# 0082: Fine-tuning tips ------------------------------------------------------------------
	bubble_set_title(gtr("Fine-tuning your effect 🔧"))
	bubble_add_text(
		[gtr("If the effect doesn't look quite right, you can adjust:"),
		gtr("• [b]Scroll Scale[/b] values to change layer speeds"),
		gtr("• [b]Repeat Size[/b] to make backgrounds tile seamlessly"),
		gtr("• [b]Scroll Offset[/b] to change starting positions"),
		gtr("• [b]Camera Limits[/b] to better frame your scene"),
		gtr("Experiment with different values until it feels perfect!")]
	)
	complete_step()

	# 0083: Troubleshooting common issues -----------------------------------------------------
	bubble_set_title(gtr("Troubleshooting tips 🔍"))
	bubble_add_text(
		[gtr("If your parallax isn't working as expected:"),
		gtr("• Make sure your Camera2D is [b]Enabled[/b] and is a child of the Player"),
		gtr("• Check that each Parallax2D has different Scroll Scale values"),
		gtr("• Verify that your Sprite2D nodes have textures assigned"),
		gtr("• Ensure Parallax2D nodes are children of World, not Player"),
		gtr("• Make sure your background images are positioned at (0,0)")]
	)
	complete_step()

func steps_090_wrap_up() -> void:
	queue_command(func()->void:
		var resource = get_checkpoint_res(checkpoint_res_path)
		resource.checkpoint_func_path = "steps_090_wrap_up"
		save_checkpoint(resource)
	)

	# 0090: Understanding repeat_size ---------------------------------------------------------
	highlight_inspector_properties(['repeat_size'])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_title(gtr("Bonus: Infinite Repeating Backgrounds"))
	bubble_add_text(
		[gtr("The [b]Repeat Size[/b] property makes your backgrounds repeat seamlessly!"),
		gtr("Set this to the width of your background image for horizontal tiling."),
		gtr("For example, if your image is 1024 pixels wide, set Repeat Size X to 1024."),
		gtr("This prevents your background from running out in longer levels!")]
	)
	complete_step()

	# 0091: Advanced techniques ---------------------------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_title(gtr("Advanced Techniques 🚀"))
	bubble_add_text(
		[gtr("Now that you know the basics, try these advanced ideas:"),
		gtr("• Add [b]vertical parallax[/b] for jumping/flying games (set Scroll Scale Y)"),
		gtr("• Use [b]AnimatedSprite2D[/b] for moving clouds or water"),
		gtr("• Create [b]multiple parallax groups[/b] for foreground and background"),
		gtr("• Combine with [b]particle effects[/b] for dynamic weather")]
	)
	complete_step()

	# 0092: Performance tips ------------------------------------------------------------------
	bubble_set_title(gtr("Performance Tips ⚡"))
	bubble_add_text(
		[gtr("To keep your parallax backgrounds running smoothly:"),
		gtr("• Use appropriate image sizes (don't make them unnecessarily huge)"),
		gtr("• Consider simpler textures for distant layers"),
		gtr("• Use Repeat Size instead of extremely wide images"),
		gtr("• Test on different devices to ensure good performance"),
		gtr("• Consider using CanvasLayers for UI elements that shouldn't parallax")]
	)
	complete_step()

	# 0093: Why Parallax2D is better ----------------------------------------------------------
	bubble_set_title(gtr("Why Parallax2D is Amazing! ✨"))
	bubble_add_text(
		[gtr("The new Parallax2D node has several advantages:"),
		gtr("• [b]Simpler setup[/b] - Each layer is independent"),
		gtr("• [b]Better organization[/b] - No complex nested structure"),
		gtr("• [b]Easier debugging[/b] - You can easily enable/disable individual layers"),
		gtr("• [b]More flexible[/b] - Each layer can have different repeat settings"),
		gtr("It's much easier than the old ParallaxBackground system!")]
	)
	complete_step()

	# 0094: Real-world applications -----------------------------------------------------------
	bubble_set_title(gtr("Real-World Applications 🌍"))
	bubble_add_text(
		[gtr("Parallax scrolling is used everywhere in game development:"),
		gtr("• [b]Platform games[/b] - Like Super Mario Bros and Sonic"),
		gtr("• [b]Side-scrolling shooters[/b] - Creating depth in space games"),
		gtr("• [b]Racing games[/b] - Making backgrounds feel distant"),
		gtr("• [b]Adventure games[/b] - Creating atmospheric environments"),
		gtr("You've just learned a professional game development technique!")]
	)
	complete_step()

	# 0095: Congratulations -------------------------------------------------------------------
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.RIGHT)
	bubble_set_title(gtr("Congratulations! 🎉"))
	bubble_add_text(
		[gtr("You've successfully created a beautiful parallax background system using Godot's new Parallax2D nodes!"),
		gtr("Your game now has professional-quality depth and visual appeal."),
		gtr("The illusion of depth you've created will make players feel more immersed in your game world."),
		gtr("You've mastered one of the most important visual techniques in 2D game development!")]
	)
	complete_step()

	# 0096: What's next -----------------------------------------------------------------------
	bubble_set_title(gtr("What's Next? 🚀"))
	bubble_add_text(
		[gtr("Ready to expand your game development skills further?"),
		gtr("• Learn about [b]advanced camera techniques[/b] like screen shake and smooth following"),
		gtr("• Explore [b]lighting and shadow effects[/b] to enhance your scenes"),
		gtr("• Master [b]particle systems[/b] for weather and special effects"),
		gtr("• Try [b]shader programming[/b] for custom visual effects"),
		gtr("Check out our other tutorials to keep building amazing games!")]
	)
	complete_step()

	# 0097: Final recap -----------------------------------------------------------------------
	bubble_set_title(gtr("Lesson Recap 📝"))
	bubble_add_text(
		[gtr("In this lesson, you learned:"),
		gtr("1. What parallax scrolling is and why it's important"),
		gtr("2. How to use Godot's new Parallax2D nodes"),
		gtr("3. Creating multiple background layers with different speeds"),
		gtr("4. Setting up a Camera2D with proper limits"),
		gtr("5. Fine-tuning scroll scales for realistic depth"),
		gtr("6. Troubleshooting common parallax issues"),
		gtr("You're now ready to create stunning backgrounds for any 2D game!")]
	)
	complete_step()
