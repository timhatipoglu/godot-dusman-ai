extends CharacterBody2D
## Oyuncu: yön tuşlarıyla hareket eden mavi kare.

const SPEED := 520.0


func _ready() -> void:
	var s := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(44, 44)
	s.shape = r
	add_child(s)
	var v := Polygon2D.new()
	v.polygon = PackedVector2Array([Vector2(-22, -22), Vector2(22, -22), Vector2(22, 22), Vector2(-22, 22)])
	v.color = Color(0.35, 0.65, 1.0)
	add_child(v)


func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * SPEED
	move_and_slide()
