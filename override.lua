-- Overrides on generator data shared for all clients go here if any
-- Most are client specific, under e.g ./vanilla/overrides.lua
local _, sc = ...;

local lookups = sc.lookups;

lookups.bol_ids = { 19977, 19978, 19979, 25890 };
lookups.bol_rank_to_hl_coef_subtract = {
    [1] = 1.0 - (1 - (20 - 1) * 0.0375) * 2.5 / 3.5, -- lvl 1 hl coef used
    [2] = 1.0 - 0.4,
    [3] = 1.0 - 0.7,
};
lookups.isb_ids = { 177944, 177988, 177972, 177996, 17800 };
lookups.lightning_shield = 324;
lookups.rejuvenation = 774;
lookups.regrowth = 8936;

lookups.priest_t3 = 525;
