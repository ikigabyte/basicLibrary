local shared = {}

shared.RewardTypes = {
	ENUM_CASH = "Cash",
	ENUM_PET = "",
	ENUM_SPIN = "",
}

shared.Gamepasses = {
	["VIP"] = 1003212013,
	["extra"] = 1007573112,
	["Something here"] = 123123,
	["Something else here"] = 123123,
}

shared.MaxClicks = 25
shared.Defaults = {
	WalkSpeed = 22,
	JumpPower = 16,
}

shared.DevProduct = {
	["SmallCash"] = 2673547554,
	["BuySpins"] = 2673547554,
	["MediumCash"] = 2673547554,
	["BigCash"] = 2673547554,
	["BiggerCash"] = 2673547554,
	["Boost"] = 2673547554,
	["DoublePower"] = 2673578525,
}

shared.TimeUntilOPPet = 3 * 60 --! 3 minutes for testing

shared.DailyRewards = {

	[1] = {
		RewardType = "Cash",
		Reward = 100,
		ImageType = "rbxassetid://18814815380",
		DisplayName = "testing here",
	},
	[2] = {
		RewardType = "Cash",
		Reward = 200,
		DisplayName = "testing something here",
	},
	[3] = {
		RewardType = "Cash",
		Reward = 300,
		DisplayName = "something else",
	},
	[4] = {
		RewardType = "Cash",
		Reward = 400,
		DisplayName = "",
	},
	[5] = {
		RewardType = "Cash",
		Reward = 500,
		DisplayName = "",
	},
	[6] = {
		RewardType = "Cash",
		Reward = 600,
		DisplayName = "",
	},
	[7] = {
		RewardType = "Cash",
		Reward = 700,
		DisplayName = "",
	},
}

shared.SpinWheelRewards = {
	[1] = {
		RewardType = "Cash",
		Reward = 700,
	},
	[2] = {
		RewardType = "Wins",
		Reward = 5,
	},
	[3] = {
		RewardType = "Wins",
		Reward = 5,
	},
	[4] = {
		RewardType = "Power",
		Reward = 100,
	},
	


}

shared.Balls = {
	["Spike Ball"] = {
		Price = 100,
		Boost = 5,
	},
	["Lava Ball"] = {
		Price = 200,
		Boost = 3,
	},
	["Test Ball"] = {
		Price = "Gamepass",
		Boost = 10,
		Id = 1003212013,
	},
}


shared.TimeGifts = {
	[1] = {
		Minutes = 0.1,
		RewardType = "Cash",
		Reward = 100,
	},
	[2] = {
		Minutes = 0.3,
		RewardType = "Cash",
		Reward = 100,
	},
	[3] = {
		Minutes = 1,
		RewardType = "Cash",
		Reward = 100,
	},
	[4] = {
		Minutes = 10,
		RewardType = "Cash",
		Reward = 100,
	},
}

return shared
