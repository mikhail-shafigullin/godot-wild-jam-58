extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var garbageLevelExitY = -840;
var skyLevelBeginY = -1720;
var skyLevelEndY = -6580;
var cosmicLevelStartY = -8200;

var maxVolume = -10;
var minVolumeForTransaction = -30;
var minVolume = -80;

var currentY;

onready var channel1 = get_node("MusicChannel1");
onready var channel2 = get_node("MusicChannel2");
onready var channel3 = get_node("MusicChannel3");

# Called when the node enters the scene tree for the first time.
func _ready():
	State.soundManager = self;
	channel1.stop();
	channel2.stop();
	channel3.stop();

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func startLevel(playerLocationY):
	channel1.play();
	channel2.play();
	channel3.play();
	channel1.set_volume_db(minVolume)
	channel2.set_volume_db(minVolume)
	channel3.set_volume_db(minVolume)
	setMusicByYCoord(playerLocationY);

func setMusicByYCoord(y):
	if currentY != floor(y/100) :
		currentY = floor(y/100)
		if y > garbageLevelExitY :
			channel1.set_volume_db(maxVolume)
			channel2.set_volume_db(minVolume)
			channel3.set_volume_db(minVolume)
		elif y <= garbageLevelExitY && y > skyLevelBeginY :
			var proportion = (y - garbageLevelExitY) / (skyLevelBeginY - garbageLevelExitY);
			proportion = clamp(proportion, 0, 1);
			var garbageLevelVolume = lerp(minVolumeForTransaction, maxVolume, 1 - proportion);
			var skyLevelVolume = lerp(minVolumeForTransaction, maxVolume, proportion);
			channel1.set_volume_db(garbageLevelVolume);
			channel2.set_volume_db(skyLevelVolume);
		elif y <= skyLevelBeginY && y > skyLevelEndY :
			channel1.set_volume_db(minVolume)
			channel2.set_volume_db(maxVolume)
			channel3.set_volume_db(minVolume)
		elif y <= skyLevelEndY && y > cosmicLevelStartY :
			var proportion = (y - skyLevelEndY) / (cosmicLevelStartY - skyLevelEndY);
			proportion = clamp(proportion, 0, 1);
			var skyLevelVolume = lerp(minVolumeForTransaction, maxVolume, 1 - proportion);
			var cosmicLevelVolume = lerp(minVolumeForTransaction, maxVolume, proportion);
			channel2.set_volume_db(skyLevelVolume);
			channel3.set_volume_db(cosmicLevelVolume);
		elif y <= cosmicLevelStartY :
			channel1.set_volume_db(minVolume)
			channel2.set_volume_db(minVolume)
			channel3.set_volume_db(maxVolume)

func playSound():
	pass;
	
func playMusic():
	pass;
