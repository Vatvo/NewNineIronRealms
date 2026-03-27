extends State


func enter() -> void:
	await get_tree().create_timer(1).timeout
	Player.canShoot = true
	Player.canReset = true
	Player.canMoveCamera = true
