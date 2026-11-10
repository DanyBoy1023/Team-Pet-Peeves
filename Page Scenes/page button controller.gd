extends Control



func _on_back_page_button_pressed() -> void:
	PageController.go_back_a_page()


func _on_forward_page_button_pressed() -> void:
	PageController.go_forward_a_page()
