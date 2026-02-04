extends CollisionObject3D

class_name Goal

func enable_flag():
	%meshActive.visible = true
	%meshDisabled.visible = false
	
func disable_flag():
	%meshActive.visible = false
	%meshDisabled.visible = true
