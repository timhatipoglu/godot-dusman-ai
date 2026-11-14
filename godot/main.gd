extends Node2D
## Arena: duvarlar, oyuncu (mavi kare), düşman (kırmızı kare, durum makinesi), HUD.

var player: CharacterBody2D
var enemy: CharacterBody2D
var hud: Label
var _lines: Array[String] = []


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.07, 0.09, 0.15))
	var floor_rect := ColorRect.new()
	floor_rect.color = Color(0.11, 0.14, 0.23)
	floor_rect.position = Vector2(60, 180)
	floor_rect.size = Vector2(960, 860)
	floor_rect.z_index = -10
	add_child(floor_rect)
	_wall(Vector2(60, 170), Vector2(960, 16))
	_wall(Vector2(60, 1030), Vector2(960, 16))
	_wall(Vector2(50, 170), Vector2(16, 876))
	_wall(Vector2(1014, 170), Vector2(16, 876))
	_wall(Vector2(330, 600), Vector2(560, 40))   # görüşü kesen iç duvar
	player = preload("res://player.gd").new()
	player.position = Vector2(560, 690)
	add_child(player)
	enemy = preload("res://enemy.gd").new()
	enemy.position = Vector2(560, 400)
	enemy.patrol_points = [Vector2(240, 400), Vector2(860, 400)]
	enemy.target = player
	add_child(enemy)
	enemy.state_changed.connect(_on_state)
	var ui := CanvasLayer.new()
	add_child(ui)
	hud = Label.new()
	hud.position = Vector2(40, 24)
	hud.add_theme_font_size_override("font_size", 28)
	hud.add_theme_color_override("font_color", Color(0.85, 0.9, 1))
	ui.add_child(hud)
	if "--auto" in OS.get_cmdline_user_args():
		add_child(preload("res://auto_input.gd").new())


func _wall(pos: Vector2, size: Vector2) -> void:
	var b := StaticBody2D.new()
	b.position = pos + size / 2.0
	var s := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = size
	s.shape = r
	b.add_child(s)
	var v := ColorRect.new()
	v.color = Color(0.36, 0.42, 0.62)
	v.size = size
	v.position = -size / 2.0
	b.add_child(v)
	add_child(b)


func _on_state(msg: String) -> void:
	_lines.append(msg)
	if _lines.size() > 4:
		_lines.pop_front()
	hud.text = "\n".join(_lines)
