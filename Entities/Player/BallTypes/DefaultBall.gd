extends BallType
	
func power_shot() -> void:
	print("DefaultPowerShot")
	var impulse: Vector3 = parent.aimDirection * parent.shotPower * parent.pullLength / parent.maxPullLength
	parent.apply_central_impulse(impulse)
		
	var spin: Vector3 = impulse * parent.spinPower
	parent.apply_torque_impulse(spin.rotated(Vector3.UP, PI/2))
	
func ability() -> void:
	pass
	
#func collect_money(value: int) -> void:
#	pass
