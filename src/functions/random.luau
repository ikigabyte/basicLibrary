return function(min, max, rounded, seed)
	local generator
	
	if seed then generator = Random.new(seed) end
	if not seed then generator = Random.new() end
	
	--Return generated number---------------------------
	if rounded then
		return generator:NextInteger(min, max)
	end
	
	return generator:NextNumber(min, max)
end