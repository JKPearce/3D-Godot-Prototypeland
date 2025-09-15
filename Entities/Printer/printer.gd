extends Carryable
class_name Printer


func _ready() -> void:
	tooltip_text = "Press E to pickup Printer"

func use() -> void:
	print("you have used the printer")
