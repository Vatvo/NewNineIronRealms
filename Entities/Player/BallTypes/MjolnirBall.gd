extends BallType

func begin() -> void:
	resetCount = INF
	
func power_shot() -> void:
	var impulse: Vector3 = parent.aimDirection * parent.shotPower * parent.pullLength / parent.maxPullLength
	parent.apply_central_impulse(impulse * 2)
		
	var spin: Vector3 = impulse * parent.spinPower
	parent.apply_torque_impulse(spin.rotated(Vector3.UP, PI/2))
	
func ability() -> void:
	pass
	
#func collect_money(value: int) -> void:
#	pass
