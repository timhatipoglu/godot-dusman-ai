extends CharacterBody2D
## Düşman yapay zekâsı = durum makinesi: DEVRİYE → KOVALA → SALDIR → GERİ DÖN.
## Görme iki adım: Area2D (menzil çemberi) + RayCast2D (arada duvar var mı).

signal state_changed(msg: String)

enum State { PATROL, CHASE, ATTACK, RETURN }
const NAMES := ["DEVRİYE", "KOVALA", "SALDIR", "GERİ DÖN"]
const PATROL_SPEED := 180.0
const CHASE_SPEED := 230.0
const SIGHT_RADIUS := 300.0
const ATTACK_RANGE := 70.0
const ATTACK_COOLDOWN := 0.5
const LOSE_AFTER := 0.5      # sn: görüş kesildikten sonra kovalamayı bırakma süresi

var patrol_points: Array = []
var target: Node2D
var state := State.PATROL
var _pi := 0
var _t := 0.0
var _in_area := false
var _last_seen := 0.0
var _last_seen_pos := Vector2.ZERO
var _cooldown := 0.0
var _hits := 0
var ray: RayCast2D
var label: Label
var body_vis: Polygon2D


func _ready() -> void:
	var s := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(48, 48)
	s.shape = r
	add_child(s)
	body_vis = Polygon2D.new()
	body_vis.polygon = PackedVector2Array([Vector2(-24, -24), Vector2(24, -24), Vector2(24, 24), Vector2(-24, 24)])
	body_vis.color = Color(1, 0.3, 0.3)
	add_child(body_vis)
	var area := Area2D.new()
	var cs := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = SIGHT_RADIUS
	cs.shape = circle
	area.add_child(cs)
	add_child(area)
	area.body_entered.connect(func(b): if b == target: _in_area = true)
	area.body_exited.connect(func(b): if b == target: _in_area = false)
	ray = RayCast2D.new()
	ray.add_exception(self)
	add_child(ray)
	label = Label.new()
	label.position = Vector2(-90, -78)
	label.size = Vector2(180, 30)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 26)
	add_child(label)
	_set_state(State.PATROL, "başlangıç")


func _set_state(s: State, why: String) -> void:
	state = s
	label.text = NAMES[s]
	var msg := "%.2f sn: %s (%s)" % [_t, NAMES[s], why]
	if target: print("[enemy]   konum düşman (%d, %d) · oyuncu (%d, %d)" % [global_position.x, global_position.y, target.global_position.x, target.global_position.y])
	print("[enemy] " + msg)
	state_changed.emit(msg)


func can_see() -> bool:
	if not _in_area:
		return false
	ray.target_position = target.global_position - global_position
	ray.force_raycast_update()
	return ray.is_colliding() and ray.get_collider() == target


func _physics_process(delta: float) -> void:
	_t += delta
	_cooldown = maxf(_cooldown - delta, 0.0)
	var sees := can_see()
	if sees:
		_last_seen = _t
		_last_seen_pos = target.global_position
	var dist := global_position.distance_to(target.global_position)
	match state:
		State.PATROL:
			var goal: Vector2 = patrol_points[_pi]
			velocity = global_position.direction_to(goal) * PATROL_SPEED
			if global_position.distance_to(goal) < 8:
				_pi = (_pi + 1) % patrol_points.size()
			if sees:
				_set_state(State.CHASE, "gördü, mesafe %d px" % dist)
		State.CHASE:
			velocity = global_position.direction_to(_last_seen_pos) * CHASE_SPEED
			if global_position.distance_to(_last_seen_pos) < 6:
				velocity = Vector2.ZERO
			if sees and dist <= ATTACK_RANGE:
				_set_state(State.ATTACK, "menzilde, %d px" % dist)
			elif _t - _last_seen > LOSE_AFTER:
				_set_state(State.RETURN, "%.1f sn görmedi" % LOSE_AFTER)
		State.ATTACK:
			velocity = Vector2.ZERO
			if _cooldown <= 0.0:
				_hits += 1
				_cooldown = ATTACK_COOLDOWN
				print("[enemy] %.2f sn: vuruş %d" % [_t, _hits])
			if dist > ATTACK_RANGE * 1.3:
				_set_state(State.CHASE, "hedef kaçtı, %d px" % dist)
		State.RETURN:
			var home: Vector2 = patrol_points[0]
			velocity = global_position.direction_to(home) * CHASE_SPEED
			if sees:
				_set_state(State.CHASE, "yine gördü")
			elif global_position.distance_to(home) < 8:
				_pi = 1
				_set_state(State.PATROL, "noktaya döndü")
	move_and_slide()
	var cols := [Color(0.31, 0.89, 0.69), Color(1, 0.63, 0.2), Color(1, 0.3, 0.3), Color(0.54, 0.7, 1)]
	label.add_theme_color_override("font_color", cols[state])
	body_vis.color = Color(1, 1, 1) if (state == State.ATTACK and _cooldown > 0.38) else Color(1, 0.3, 0.3)
	queue_redraw()


func _draw() -> void:
	draw_arc(Vector2.ZERO, SIGHT_RADIUS, 0, TAU, 96, Color(1, 1, 1, 0.18), 3)
	if _in_area:
		var col := Color(0.31, 0.89, 0.69) if can_see() else Color(1, 0.3, 0.3, 0.8)
		draw_line(Vector2.ZERO, target.global_position - global_position, col, 4)
