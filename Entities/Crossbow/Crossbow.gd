extends Node3D

@export_category("Cameras")
@export var firstCam: PhantomCamera3D
@export var firstCamDelay: float = 1
@export var secondCam: PhantomCamera3D
@export var secondCamDelay: float = 1

@export_category("Parameters")
@export var aimPoint: Node3D
@export var shotForce: float

@onready var crossbowBody: Node3D = $CrossbowBody
@onready var ballMount: MeshInstance3D = $CrossbowBody/Armature/Skeleton3D/Crossbow/BallMount
@onready var mainAnimationPlayer: AnimationPlayer = $CrossbowBody/AnimationPlayer
@onready var mountMover: AnimationPlayer = $CrossbowBody/Armature/Skeleton3D/Crossbow/MountMover

var isPlayerAttached: bool = false
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isPlayerAttached:
		player.global_position = ballMount.global_position

func activate_crossbow() -> void:
	#disable player input
	Player.canShoot = false
	Player.canBrake = false
	Player.canSteer = false
	Player.canMoveCamera = false
	Player.canReset = false
	
	#attach ball to mount point
	isPlayerAttached = true
	player.gravity_scale = 0
	player.linear_velocity = Vector3.ZERO
	player.angular_velocity = Vector3.ZERO
	
	#transition to firstCam
	if firstCam:
		print("Cam1")
		firstCam.priority = 300
		
	#start crossbow animation
	mainAnimationPlayer.play("CrossbowShoot")
	mountMover.play("CrossbowShoot")
	
	#start aiming
	var startingLook: Vector3 = crossbowBody.global_position + (-crossbowBody.global_basis.z * 10)
	
	var test := MeshInstance3D.new()
	test.mesh = SphereMesh.new()
	get_tree().root.add_child(test)
	test.position = startingLook
	
	var tween = get_tree().create_tween()
	tween.tween_method(
		crossbowBody.look_at,
		startingLook,
		aimPoint.position,
		1
	)
	
	#await finished animation
	await mainAnimationPlayer.animation_finished
	
	#detatch ball from mount point
	isPlayerAttached = false
	player.gravity_scale = 1
	player.linear_velocity = Vector3.ZERO
	player.angular_velocity = Vector3.ZERO
	
	#shoot
	await get_tree().physics_frame
	player.apply_central_force(-crossbowBody.global_basis.z * shotForce)
	
	#await firstCamDelay
	await get_tree().create_timer(firstCamDelay).timeout
	firstCam.priority = 0
	
	#transition to secondCam
	if secondCam:
		secondCam.priority = 300
		
		#await seconCamDelay
		await get_tree().create_timer(secondCamDelay).timeout
		secondCam.priority = 0
		
	#enable player input
	Player.canShoot = true
	Player.canBrake = true
	Player.canSteer = true
	Player.canMoveCamera = true
	Player.canReset = true
	
func _on_collision_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body
		activate_crossbow()
