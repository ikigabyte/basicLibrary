local shared = {}



shared.Gamepasses = {
    ["VIP"] = 1003212013,
    ["extra"] = 1007573112,
    ["Something here"] = 123123,
    ["Something else here"] = 123123,
}

shared.DevProduct = {
    ["SmallCash"] = 2673547554,
    ["MediumCash"] = 2673547554,
    ["BigCash"] = 2673547554,
    ["BiggerCash"] = 2673547554,
    ["Boost"] = 2673547554,
    ["DoublePower"] = 2673578525,
}

shared.TimeUntilOPPet = 3 * 60 --! 3 minutes for testing


shared.Tools = {
    ["spikeball1"] = {
        Price = 100,
        Damage = 10,

    },
    ["spikeball2"] = {
        Price = 200,
    },
    ["spikeball3"] = {
        Price = "Gamepass",
        Id = 123123123
    }
}

shared.TimeGifts = {
    [1] = {
        Minutes = .1 ,
        RewardType = "Cash",
        Reward = 100,
    }, 
    [2] = {
        Minutes = .3,
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