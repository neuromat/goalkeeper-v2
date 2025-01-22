class_name HSliderWithLabel
extends VBoxContainer

func _ready() -> void:
	var value = $HSlider.value
	$Label.text = String("%.2f" % value)

func _on_h_slider_value_changed(value: float) -> void:
	$Label.text = String("%.2f" % value)
