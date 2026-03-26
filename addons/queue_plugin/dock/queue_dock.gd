@tool
extends VBoxContainer

enum RequestType { NONE, RAISE, LOWER, POSITION, QUEUE_LIST }

var student_name: String = ""
var server_url: String = ""
var in_queue: bool = false
var current_request: RequestType = RequestType.NONE

@onready var name_input: LineEdit = $NameInput
@onready var server_input: LineEdit = $ServerInput
@onready var save_btn: Button = $SaveSettingsBtn
@onready var raise_btn: Button = $ButtonsContainer/RaiseHandBtn
@onready var lower_btn: Button = $ButtonsContainer/LowerHandBtn
@onready var status_label: Label = $StatusLabel
@onready var queue_list: ItemList = $QueueList
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var poll_timer: Timer = $PollTimer


func _ready():
	_load_settings()
	name_input.text = student_name
	server_input.text = server_url

	save_btn.pressed.connect(_on_save_settings)
	raise_btn.pressed.connect(_on_raise_hand)
	lower_btn.pressed.connect(_on_lower_hand)
	http_request.request_completed.connect(_on_request_completed)
	poll_timer.timeout.connect(_on_poll_timeout)

	_update_buttons()


func _load_settings():
	var config = ConfigFile.new()
	if config.load("user://queue_plugin_settings.cfg") == OK:
		student_name = config.get_value("settings", "student_name", "")
		server_url = config.get_value("settings", "server_url", "")


func _save_settings():
	var config = ConfigFile.new()
	config.set_value("settings", "student_name", student_name)
	config.set_value("settings", "server_url", server_url)
	config.save("user://queue_plugin_settings.cfg")


func _on_save_settings():
	student_name = name_input.text.strip_edges()
	server_url = server_input.text.strip_edges().rstrip("/")
	_save_settings()
	status_label.text = "Settings saved"
	_update_buttons()


func _update_buttons():
	var has_settings = student_name != "" and server_url != ""
	raise_btn.disabled = !has_settings or in_queue
	lower_btn.disabled = !has_settings or !in_queue


func _is_request_in_flight() -> bool:
	return current_request != RequestType.NONE


func _on_raise_hand():
	if _is_request_in_flight():
		return
	var url = server_url + "/raise"
	var body = JSON.stringify({"student_name": student_name})
	var headers = PackedStringArray(["Content-Type: application/json"])
	current_request = RequestType.RAISE
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)


func _on_lower_hand():
	if _is_request_in_flight():
		return
	var url = server_url + "/lower"
	var body = JSON.stringify({"student_name": student_name})
	var headers = PackedStringArray(["Content-Type: application/json"])
	current_request = RequestType.LOWER
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)


func _poll_queue():
	if _is_request_in_flight():
		return
	var url = server_url + "/queue"
	current_request = RequestType.QUEUE_LIST
	http_request.request(url)


func _on_poll_timeout():
	if in_queue:
		_poll_queue()


func _start_polling():
	poll_timer.start()


func _stop_polling():
	poll_timer.stop()


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var req_type = current_request
	current_request = RequestType.NONE

	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		status_label.text = "Error: connection failed"
		return

	var json = JSON.new()
	var err = json.parse(body.get_string_from_utf8())
	if err != OK:
		status_label.text = "Error: invalid response"
		return

	var data = json.get_data()

	match req_type:
		RequestType.RAISE:
			var position = data.get("position", 0)
			status_label.text = "Position: #%d" % position
			in_queue = true
			_update_buttons()
			_start_polling()
			_poll_queue()
		RequestType.LOWER:
			status_label.text = "Not in queue"
			in_queue = false
			_update_buttons()
			_stop_polling()
		RequestType.QUEUE_LIST:
			var q = data.get("queue", [])
			queue_list.clear()
			var found = false
			for entry in q:
				queue_list.add_item("#%d  %s" % [entry["position"], entry["name"]])
				if entry["name"] == student_name:
					status_label.text = "Position: #%d" % entry["position"]
					found = true
			if not found and in_queue:
				status_label.text = "Not in queue"
				in_queue = false
				_update_buttons()
				_stop_polling()
