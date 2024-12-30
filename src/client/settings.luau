

--[[
	This module handles the settings for the client, including muting music and sound effects,
	redeeming codes, and setting up player-specific settings. It interacts with the SoundService
	and various UI elements to provide a seamless user experience.


]]


local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local uiHandler = require(script.Parent:WaitForChild("ui"))
local sfxMod = require(script.Parent:WaitForChild("sfx"))


local settingsFrame = library.PlayerGui.ScreenGui.Frames.Settings
local scrollingFrame = settingsFrame.ScrollingFrame
local currentSettings = {
    Music = true,
    SFX = true,
}
local petsOn = false
local settingsMod = {}
local debounce = false
local codeTextBox :TextBox = scrollingFrame.RedeemCode.Frame.TextBox



local OnColor : Color3 = Color3.fromRGB(77, 255, 40)
local OffColor : Color3 = Color3.fromRGB(299, 128, 102)
local OnColorStroke : Color3 = Color3.fromRGB(0, 81, 0)
local OffColorStroke : Color3 = Color3.fromRGB(126, 15, 11)


function settingsMod.SetupPlayerSettings(playerProfile)
    local profileSettings = playerProfile.Settings
    -- print(profileSettings)
	local musicStatus = profileSettings.Music
	local sfxStatus = profileSettings.Sound
	local petsStatus = profileSettings.Pets

	--Updates all the settings based on the profile settings

	if musicStatus == true then
		library.SoundService.SoundGroup.Music:Play()
	end
	local muteMusicButton = scrollingFrame.MuteMusic.Button
	local muteSFXButton = scrollingFrame.MuteSFX.Button
	local hidePetsButton = scrollingFrame.HidePets.Button

	muteMusicButton:SetAttribute("status", musicStatus)
	muteSFXButton:SetAttribute("status", sfxStatus)
	hidePetsButton:SetAttribute("status", petsStatus)

	settingsMod.MuteMusic(muteMusicButton, musicStatus, false)
	settingsMod.MuteSFX(muteSFXButton, sfxStatus, false)
	settingsMod.HidePets(hidePetsButton, petsStatus, false)

end




function settingsMod.RedeemCode(button: TextButton)
	local code = codeTextBox.Text
	if code == "" then
			codeTextBox.PlaceholderText = "Redeem Code"
		return
	end

	codeTextBox.PlaceholderText = "Redeem Code"
	-- print("clicked here")
	library.Events.RedeemCode:FireServer(code)
	-- code.placeh
	codeTextBox.Text = ""
end

function settingsMod.HidePets(button: TextButton, status : boolean, clickedOn)
	settingsMod.changeAeshethic(button, status)
	-- print("hiding the pets here now")
	if clickedOn then
		library.Events.PlayerSetting:FireServer("Pets", status)
	end
end

function settingsMod.MuteSFX(button: TextButton, status : boolean, clickedOn)
	settingsMod.changeAeshethic(button, status)
	for _, sound in pairs(library.SoundService.SoundGroup:GetChildren()) do
		-- print(sound.Name)
		if not sound:IsA("Sound")  then continue end
		if sound.Name == "Music" then
			continue
		end

		if status then
			sound.Volume = .5
		else
			sound.Volume = 0
		end
	end
	if clickedOn then 
		library.Events.PlayerSetting:FireServer("SFX", status)
	end
end

function settingsMod.MuteMusic(button: TextButton, status, clickedOn)
	local volume 
	if status then
		volume = 0.5
		library.SoundService.SoundGroup.Music:Play()
		
	else
		volume = 0
	end
	library.SoundService.SoundGroup.Music.Volume = volume
	
	settingsMod.changeAeshethic(button, status)
	if clickedOn then
		library.Events.PlayerSetting:FireServer("Music", status)
	end
end

function settingsMod.changeAeshethic(button: TextButton, status)
	local color
	local strokeColor
	local text = 'ON'
	if status == false then
		color = OffColor
		text = 'OFF'
		strokeColor = OffColorStroke
	else
		text = 'ON'
		color = OnColor
		strokeColor = OnColorStroke
	end
	button.TextLabel.Text = text
	button.UIStroke.Color = strokeColor
	button.BackgroundColor3 = color
	button.TextLabel.UIStroke.Color = strokeColor
end

function settingsMod.OnButtonActivation(button: TextButton, settingsName: string)
	local size = button.Size
	local xScale = size.X.Scale * 1.05
	local yScale = size.Y.Scale * 1.05

	local settingsName = button.Parent.Name
	if settingsMod[settingsName] == nil then
		warn("no setting mod for " .. settingsName)
		return
	end

	button.Activated:Connect(function()
		if debounce then
			return
		end
		debounce = true
		task.delay(0.2, function()
			debounce = false
		end)
		sfxMod.Play("Click", 0.5)
		uiHandler.animateButton(button, { Size = UDim2.new(xScale, 0, yScale, 0) }, "ExplosiveButton")
		if settingsName == "RedeemCode" then
			-- settingsMod.RedeemCode(button)
			settingsMod.RedeemCode()
			-- debounce = false
			return
			--! this one is depending on the code you put
		else
			-- print("doing something here")
			local status = button:GetAttribute("status")
			local newStatus = not status
			-- print(newStatus)
			button:SetAttribute("status", newStatus)
			settingsMod[settingsName](button, newStatus, true)
		end
	end)
end


function settingsMod.OnClose()
	codeTextBox.Text = ""

	print("this text box has been closed")

end


function settingsMod:Init()
	-- task.wait(2) -- Time to load the buttons in
	-- SoundService.SoundGroup.Music:Play() --! play the music by default here
	local playerProfile = library.Events.GetProfile:InvokeServer()
	 settingsMod.SetupPlayerSettings(playerProfile)
	for _, button in pairs(settingsFrame:GetDescendants()) do
		if button:IsA("TextButton") == false or button:IsA("ImageButton") then
			continue
		end
		settingsMod.OnButtonActivation(button)
	end
	settingsFrame.AttributeChanged:Connect(function(attribute)
		if attribute == "Visible" then
			if settingsFrame.Visible == false then
				settingsMod.OnClose()
			end
		end
	end)
	
	settingsFrame.ScrollingFrame.RedeemCode.Frame.TextBox.FocusLost:Connect(function()
		print("the focus has been lost")
		settingsMod.RedeemCode()
		-- settingsMod.RedeemCode()
	end)
end

return settingsMod
