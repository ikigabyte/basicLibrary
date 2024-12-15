local abbreviations = {"", "K","M","B","T","Qd","Qn","Sx","Sp","O","N", "D", "U", "INF"}

--Formats a number (100000 -> 100K)---------------------------
return function(number)
	if not number or not (typeof(number) == "number") then return number end
	local newNumber = math.abs(number)
	local index = 1
	while number >= 1000 and index < #abbreviations do
		number = number / 1000
		index = index + 1
	end

	local formattedNumber = string.format("%.1f", number)
	if formattedNumber:sub(-2) == ".0" then
		formattedNumber = formattedNumber:sub(1, -3)
	end

	--Add a minus sign if the original number was negative---------------------------
	if number < 0 then formattedNumber = "-" .. formattedNumber end
	return formattedNumber .. abbreviations[index]
end