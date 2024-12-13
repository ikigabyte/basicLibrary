return function(seconds, format)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local remainingSeconds = seconds % 60
	
	if format == "seconds" then 
		return string.format("%02d:%02d:%02d", hours, minutes, remainingSeconds)
	elseif format == "minutes" then
		return string.format("%02d:%02d", minutes, remainingSeconds)
	end
	
end