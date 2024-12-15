local ProximityPromptService = game:GetService("ProximityPromptService")
local shared = {}
shared.Gamepasses = {

    ["VIP"] = 123123,
    ["x2Chance"] = 123123,
    ["Something here"] = 123123,
    ["Something else here"] = 123123,
}

shared.DevProducts = {
    ["SmallCash"] = 2673547554,
    ["MediumCash"] = 2673547554,
    ["BigCash"] = 2673547554,
    ["BiggerCash"] = 2673547554,
    ["Boost"] = 2673547554,
    ["DoublePower"] = 2673578525,
}


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