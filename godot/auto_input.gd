extends Node
## YALNIZ kayıt/test: zamanlı yön tuşu olayları (Input.parse_input_event). Düşman kodu habersizdir.
const PLAN := [  # [sn, tuş, basılı]
	[0.5, KEY_LEFT, true], [1.25, KEY_LEFT, false],
	[2.9, KEY_DOWN, true], [3.25, KEY_DOWN, false],
	[3.25, KEY_RIGHT, true], [4.6, KEY_RIGHT, false],
]
var _t := 0.0
var _i := 0

func _physics_process(delta: float) -> void:
	_t += delta
	while _i < PLAN.size() and _t >= PLAN[_i][0]:
		var ev := InputEventKey.new()
		ev.keycode = PLAN[_i][1]
		ev.physical_keycode = PLAN[_i][1]
		ev.pressed = PLAN[_i][2]
		Input.parse_input_event(ev)
		print("[auto] %.2f sn: %s %s" % [_t, OS.get_keycode_string(PLAN[_i][1]), "bas" if PLAN[_i][2] else "bırak"])
		_i += 1
