local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))



local sfxMod = {}


function sfxMod.PlaySound(soundName, volume, pitch)
	local sound = library.SoundService.SoundGroup:FindFirstChild(soundName)
	if sound then
		sound:Play()
		sound.Volume = volume
		sound.Pitch = pitch
	else
		warn("Sound not found")
	end
end

return sfxMod