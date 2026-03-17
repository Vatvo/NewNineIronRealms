extends Node3D

class_name AsgardDoor

@export var animation_player: AnimationPlayer

@onready var closed: CollisionShape3D = $DoorCollision/Closed
@onready var open2: CollisionShape3D = $DoorCollision/Open2
@onready var open1: CollisionShape3D = $DoorCollision/Open1

@export_category("Audio")
@onready var GateSound: AudioStreamPlayer2D = $GateSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	closed.disabled = false
	open1.disabled = true
	open2.disabled = true

func open() -> void:
	GateSound.play()
	animation_player.play("DoorOpen")
	closed.disabled = true
	open1.disabled = false
	open2.disabled = false
