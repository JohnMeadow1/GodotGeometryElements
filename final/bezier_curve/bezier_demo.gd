tool
extends Node2D

var manual = false
var offset = 0
var steps = 100


func _process(_delta):
	if not manual:
		offset += 1
		offset = fmod(offset, steps)
		_update_curves_offset(offset)
		$ui/offset.value = offset


func _update_curves_offset(p_offset):
	offset = p_offset
	for curve in $curves.get_children():
		curve.offset = offset


func _on_offset_value_changed(value):
	if not manual:
		return
	_update_curves_offset(value)


func _on_mode_toggled(button_pressed):
	manual = button_pressed
	$ui/offset.editable = button_pressed

	if button_pressed:
		$ui/mode.text = tr("Manual")
	else:
		$ui/mode.text = tr("Auto")
