extends CanvasLayer
class_name MainUI

@onready var interact_tip_label: Label = %InteractTipLabel


func _ready() -> void:
	EventManager.display_interact_label.connect(_on_show_interact_tip)
	EventManager.hide_interact_label.connect(_on_hide_interact_label)


func _on_show_interact_tip(text: String) -> void:
	interact_tip_label.visible = true
	interact_tip_label.text = text


func _on_hide_interact_label() -> void:
	interact_tip_label.visible = false
