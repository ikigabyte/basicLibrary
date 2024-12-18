local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

local sfxMod = {}

local function getSound(soundName, parent)
	local sfx = library.SoundService.SoundGroup:FindFirstChild(soundName) or nil
	--Find sound in sounds folder---------------------------
	-- local newSound
	-- for i, sound in ipairs(sounds) do
	-- 	if not (tostring(sound) == soundName) then continue end
		
	-- 	newSound = sound:Clone()
	-- 	newSound.Parent = Library.SoundService.SoundsPlaying
		
	-- 	break
	-- end
	
	return sfx
end



function sfxMod.Play(soundName, volume, cooldown, plays, position)
	local sound = getSound(soundName)
	local soundPart
	if not sound then return false, "Sound does not exist" end
	

	--Default values---------------------------
	plays = plays or 1
	cooldown = cooldown or sound.TimeLength
	volume = volume or 0.5
	sound.Volume = volume
	sound.TimePosition = 0
	-- if position then soundPart = createSoundPart(position); sound.Parent = soundPart end
	
	--Handle playing the module---------------------------
	task.spawn(function()
		for i = 1, plays, 1 do
			-- print("playing the sound here")
			sound:Play()
			task.wait(cooldown)
		end
		-- library.Debris:AddItem(sound, cooldown)
		-- if soundPart then library.Debris:AddItem(soundPart, cooldown) end
	end)
end


return sfxMod