local SoundService = game:GetService("SoundService")
local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local uiHandler = require(script.Parent:WaitForChild("ui"))


local settingsFrame 
local currentSettings = {
    Music = true,
    SFX = true,
}
local petsOn = false;
local settingsMod = {}

local statuses = {
    [false] = {
        step1Color = Color3.fromRGB(88, 206, 59),
        step2Color = Color3.fromRGB(142, 245, 109),
        uistroke = Color3.fromRGB(142, 245, 109),
    },
    [true] = {
        step1Color = Color3.fromRGB(146, 49, 49),
        step2Color = Color3.fromRGB(255, 81, 81),
        uistroke = Color3.fromRGB(142, 245, 109),
    }
}


function settingsMod.MuteSFX(button: TextButton)
	local size = button.Size
	local xScale = size.X.Scale * 1.05
	local yScale = size.Y.Scale * 1.05
    uiHandler.animateButton(button, { Size = UDim2.new(xScale, 0, yScale, 0) }, "ExplosiveButton")
	-- library.SoundService.SoundGroup.SFX.Volume = 0
end

function settingsMod.MuteMusic(button: TextButton)
	local size = button.Size
	local xScale = size.X.Scale * 1.2
	local yScale = size.Y.Scale * 1.2

    currentSettings.Music = not currentSettings.Music
	uiHandler.animateButton(button, { Size = UDim2.new(xScale, 0, yScale, 0) }, "ExplosiveButton")
    settingsMod.changeAeshethic(button, currentSettings.Music)
	library.SoundService.SoundGroup.Music.Volume = 0
    library.Events.PlayerSetting:FireServer("Music", false)
end


function settingsMod.changeAeshethic(button: TextButton, status : boolean)
    
    -- local offColor = Color3.fromRGB(126, 15, 11)
    local colorSequence = ColorSequence.new({
        ColorSequenceKeypoint.new(0, statuses[status].step1Color),
        ColorSequenceKeypoint.new(1, statuses[status].step2Color)
    })

    local uiGradient : UIGradient = button:FindFirstChild("UIGradient")
    if uiGradient then
        uiGradient.Color = colorSequence
    end
    
end

function settingsMod.SetupPlayerSettings(playerProfile)
    
    local profileSettings = playerProfile.Settings
    -- warn(profileSettings)
    warn(profileSettings)
    currentSettings = profileSettings
    if profileSettings.Music == false then 


        -- settingsMod.MuteMusic(library.PlayerGui.ScreenGui.Frames.Settings.MuteMusic)

        -- library.PlayerGui.ScreenGui.Frames.Settings.MuteMusic.Size = UDim2.new(1.2, 0, 1.2, 0)
    end

end


function settingsMod:Init()
	

    task.wait(2) -- Time to load the buttons in 
    SoundService.SoundGroup.Music:Play() --! play the music by default here
    local playerProfile = library.Events.GetProfile:InvokeServer()
    -- print(playerProfile)
    settingsMod.SetupPlayerSettings(playerProfile)

	settingsFrame = library.PlayerGui.ScreenGui.Frames.Settings
	-- local options

	for _, button in pairs(settingsFrame:GetDescendants()) do
		if button:IsA("TextButton") == false or button:IsA("ImageButton") then
			continue
		end
      
		if settingsMod[button.Name] == nil then
			warn("no setting mod for " .. button.Name)
			continue
		end
		local debounce = false
		button.Activated:Connect(function()
			if debounce then
				return
			end
			debounce = true
			warn("activated here, trying tsomething here")
			library.Events.PlayerSetting:FireServer(button.Name)
			settingsMod[button.Name](button)
			warn("changed the thing here")
			task.delay(0.2, function()
				debounce = false
			end)
		end)
		-- button.Activated:Connect(function()
		--     if button.Name == "MuteMusic" then
		--         settingsMod.MuteMusic()
		--     end
		-- end)
	end
end

return settingsMod
