extends State


@onready var intro_camera: PhantomCamera3D = $IntroCamera

func enter() -> void:
	intro_camera.priority = 1000
	Player.canShoot = false
	Player.canReset = false
	Player.canMoveCamera = false
	
	Dialogic.start("Intro")
	Dialogic.timeline_ended.connect(dialogue_finished)

func dialogue_finished() -> void:
	transitioned.emit("Play")

func exit() -> void:
	intro_camera.priority = 0
