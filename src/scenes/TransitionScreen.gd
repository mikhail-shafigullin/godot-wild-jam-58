extends CanvasLayer

signal transitioned

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "toHide":
		emit_signal("transitioned")
		$AnimationPlayer.play("toShow")
		if anim_name == "toShow":
			print("sceen showing")
