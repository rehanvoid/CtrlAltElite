extends Area3D

@onready var win_label = $CanvasLayer/WinLabel

func _ready():
	print("goal ready")

func _on_body_entered(body: Node3D):
	print("touched: ", body.name)
	if body.name == "Player":
		win_label.visible = true
