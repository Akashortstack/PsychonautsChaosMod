add_hook('startup', 'ChaosModSetup')
function ChaosModSetup()
	--Spawn the Script :)
	SpawnScript('ChaosController', 'ChaosController')
end

add_hook('prebeginlevel', 'ChaosModBeginLevel')
function ChaosModBeginLevel()
	--Load sound data from CA for Bears and Cougars
	LoadSoundData('CA')
	--Load sound data from MC for Knife Throwers and Demon Bunnies
	LoadSoundData('MC')
end

