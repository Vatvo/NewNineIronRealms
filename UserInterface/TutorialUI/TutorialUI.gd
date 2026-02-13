extends Control

@onready var ExitBTN: Control = $MenuButtonUI/HBox/Button

@onready var Brake: Control =$Brake
@onready var BrakeBack: Button = $Brake/BrakeBack
@onready var BrakeForward: Button = $Brake/BrakeForward

@onready var Camera: Control =$Camera
@onready var CameraBack: Button = $Camera/CameraBack
@onready var CameraForward: Button = $Camera/CameraForward

@onready var Jump: Control =$Jump
@onready var JumpBack: Button = $Jump/JumpBack
@onready var JumpForward: Button = $Jump/JumpForward

@onready var Putt: Control =$Putt
@onready var PuttBack: Button = $Putt/PuttBack
@onready var PuttForward: Button = $Putt/PuttForward

@onready var Steer: Control =$Steer
@onready var SteerBack: Button = $Steer/SteerBack
@onready var SteerForward: Button = $Steer/SteerForward

func _ready() -> void:
	ExitBTN.pressed.connect(clear)
	
	BrakeBack.pressed.connect(brakeBack)
	BrakeForward.pressed.connect(brakeForward)
	
	CameraBack.pressed.connect(cameraBack)
	CameraForward.pressed.connect(cameraForward)
	
	JumpBack.pressed.connect(jumpBack)
	JumpForward.pressed.connect(jumpForward)
	
	PuttBack.pressed.connect(puttBack)
	PuttForward.pressed.connect(puttForward)
	
	SteerBack.pressed.connect(steerBack)
	SteerForward.pressed.connect(steerForward)

func clear() -> void:
	queue_free()

func brakeBack() -> void:
	Brake.hide()
	Jump.show()

func brakeForward() -> void:
	Brake.hide()
	Camera.show()

func cameraBack() -> void:
	Camera.hide()
	Brake.show()

func cameraForward() -> void:
	Camera.hide()
	Putt.show()

func jumpBack() -> void:
	Jump.hide()
	Steer.show()

func jumpForward() -> void:
	Jump.hide()
	Brake.show()
	
func puttBack() -> void:
	Putt.hide()
	Camera.show()

func puttForward() -> void:
	Putt.hide()
	Steer.show()
	
func steerBack() -> void:
	Steer.hide()
	Putt.show()

func steerForward() -> void:
	Steer.hide()
	Jump.show()
