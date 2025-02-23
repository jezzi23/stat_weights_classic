-- THIS FILE IS GENERATED
local _, sc = ...;
sc.auto_attack_spell_id = 6603;
sc.player_buffs = {
	[6192] = {
			{"raw", "ap_flat", 55, nil, 2, 0},
	},
	[9576] = {
			{"raw", "phys_dmg_flat", 50, nil, 0, 0},
	},
	[13338] = {
			{"raw", "cast_haste", -0.5, nil, 0, 0},
	},
	[429868] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"by_school", "threat", 0.19999999, {1,2,3,4,5,6,7,}, 0, 1},
	},
	[22710] = {
			{"raw", "phys_dmg_flat", 6, nil, 0, 0},
			{"raw", "cast_haste", 1, nil, 0, 2},
	},
	[27721] = {
			{"by_school", "sp_dmg_flat", 23, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[28418] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[3045] = {
			{"raw", "ranged_haste", 0.39999998, nil, 33, 0},
			{"raw", "melee_haste", 0, nil, 33, 1},
	},
	[464743] = {
			{"raw", "ap_flat", -1110, nil, 2, 0},
			{"raw", "rap_flat", -1110, nil, 2, 1},
	},
	[29846] = {
			{"raw", "phys_crit", 0.03, nil, 32, 0},
			{"by_school", "crit", 0.03, {1,}, 2, 1},
	},
	[24318] = {
			{"raw", "phys_mod", 0.5, nil, 1, 0},
			{"raw", "melee_haste", 0.65, nil, 33, 1},
	},
	[413685] = {
			{"by_school", "dmg_mod", 0.049999997, {1,3,4,5,6,7,}, 1, 0},
			{"raw", "heal_mod", -0.5, nil, 1, 1},
	},
	[6864] = {
			{"raw", "phys_dmg_flat", 15, nil, 0, 0},
	},
	[2645] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 0},
	},
	[461297] = {
			{"raw", "ap_flat", 24, nil, 2, 0},
	},
	[1219485] = {
			{"creature", "dmg_mod", 0.01, {32,}, 1, 0},
	},
	[17402] = {
			{"raw", "melee_haste", -0.25, nil, 33, 1},
	},
	[5115] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[25176] = {
			{"raw", "phys_mod", 3, nil, 1, 0},
	},
	[12795] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
			{"raw", "melee_haste", 0.29999998, nil, 33, 1},
	},
	[29177] = {
			{"raw", "phys_crit", 0.06, nil, 32, 0},
	},
	[401984] = {
			{"raw", "phys_hit", 0.089999996, nil, 2, 0},
	},
	[467410] = {
			{"by_school", "sp_dmg_flat", 50, {7,}, 2, 0},
	},
	[25909] = {
			{"by_school", "threat", -0.19999999, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[473450] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[11443] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
			{"by_attr", "stat_mod", -0.5, {1,}, 0, 2},
	},
	[467667] = {
			{"raw", "phys_hit", 0.089999996, nil, 2, 0},
	},
	[26527] = {
			{"raw", "phys_dmg_flat", 250, nil, 0, 0},
			{"raw", "melee_haste", 0.75, nil, 33, 1},
	},
	[30165] = {
			{"raw", "phys_crit", 0.03, nil, 32, 0},
	},
	[19253] = {
			{"raw", "phys_dmg_flat", -15, nil, 0, 1},
	},
	[28780] = {
			{"raw", "healing_power_flat", 450, nil, 2, 0},
	},
	[20882] = {
			{"raw", "melee_haste", -0.42999998, nil, 33, 1},
			{"raw", "cast_haste", -0.29999998, nil, 0, 2},
	},
	[23271] = {
			{"by_school", "sp_dmg_flat", 175, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 175, nil, 2, 1},
	},
	[34074] = {
			{"by_school", "dmg_mod", -0.5, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", -0.5, nil, 1, 1},
	},
	[802] = {
			{"raw", "phys_mod", 18, nil, 1, 2},
	},
	[29338] = {
			{"raw", "phys_crit", 0.03, nil, 32, 0},
			{"by_school", "crit", 0.03, {1,}, 2, 1},
	},
	[18791] = {
			{"by_school", "dmg_mod", 0.14999999, {6,}, 1, 0},
	},
	[14202] = {
			{"raw", "phys_mod", 0.14999999, nil, 1, 0},
	},
	[24453] = {
			{"raw", "phys_mod", 0.5, nil, 1, 2},
	},
	[1214278] = {
			{"raw", "ap_flat", 328, nil, 2, 0},
			{"raw", "rap_flat", 328, nil, 2, 2},
	},
	[415423] = {
			{"by_school", "dmg_mod", -0.099999994, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", -0.099999994, nil, 1, 1},
	},
	[407791] = {
			{"raw", "phys_mod", 0.25, nil, 1, 0},
			{"raw", "melee_haste", 0.29999998, nil, 33, 1},
	},
	[28410] = {
			{"by_school", "dmg_mod", 2, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 2, nil, 1, 1},
	},
	[16277] = {
			{"raw", "melee_haste", 0.14999999, nil, 33, 0},
	},
	[28779] = {
			{"by_school", "sp_dmg_flat", 130, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 130, nil, 2, 1},
	},
	[355363] = {
			{"by_school", "crit", 0.099999994, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "ap_flat", 140, nil, 2, 1},
			{"raw", "phys_crit", 0.049999997, nil, 32, 2},
			{"raw", "rap_flat", 140, nil, 2, 3},
	},
	[17134] = {
			{"raw", "melee_haste", -0.32999998, nil, 33, 1},
	},
	[8255] = {
			{"raw", "melee_haste", -0.32999998, nil, 33, 1},
	},
	[407989] = {
			{"raw", "phys_mod", 0.29999998, nil, 1, 0},
	},
	[456347] = {
			{"creature", "dmg_mod", 0.03, {1,}, 1, 0},
	},
	[16257] = {
			{"raw", "melee_haste", 0.099999994, nil, 33, 0},
	},
	[434907] = {
			{"raw", "phys_mod", 0.25, nil, 1, 0},
			{"raw", "melee_haste", 0.29999998, nil, 33, 1},
	},
	[412326] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
	},
	[5213] = {
			{"raw", "melee_haste", -0.53999996, nil, 33, 2},
	},
	[7645] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
	},
	[20306] = {
			{"raw", "ap_flat", 145, nil, 2, 0},
	},
	[25916] = {
			{"raw", "ap_flat", 185, nil, 2, 0},
	},
	[5759] = {
			{"applies_aura", "shapeshift_passives", 0, {3025,}, 16, 0},
	},
	[18267] = {
			{"raw", "phys_dmg_flat", -1, nil, 0, 0},
	},
	[29331] = {
			{"raw", "phys_hit", 0.02, nil, 2, 0},
	},
	[10732] = {
			{"raw", "phys_dmg_flat", 50, nil, 0, 0},
			{"raw", "melee_haste", 0.25, nil, 33, 1},
	},
	[424574] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
	},
	[28791] = {
			{"raw", "ap_flat", 140, nil, 2, 0},
			{"raw", "rap_flat", 140, nil, 2, 1},
	},
	[30683] = {
			{"creature", "dmg_mod", 0.02, {32,}, 1, 0},
	},
	[3130] = {
			{"raw", "melee_haste", -1, nil, 33, 0},
	},
	[447892] = {
			{"by_school", "dmg_mod", 1, {1,2,3,4,5,6,7,}, 1, 2},
			{"raw", "phys_mod", 1, nil, 1, 2},
	},
	[1215885] = {
			{"raw", "melee_haste", 4, nil, 33, 0},
	},
	[18972] = {
			{"raw", "melee_haste", -0.53999996, nil, 33, 0},
	},
	[425121] = {
			{"raw", "cast_haste", 0.19999999, nil, 0, 0},
	},
	[11708] = {
			{"raw", "phys_dmg_flat", -31, nil, 0, 0},
	},
	[12051] = {
			{"raw", "regen_while_casting", 1, nil, 0, 1},
	},
	[1213356] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
	},
	[17539] = {
			{"by_school", "sp_dmg_flat", 35, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[7658] = {
			{"raw", "ap_flat", 45, nil, 2, 0},
	},
	[446687] = {
			{"by_school", "sp_dmg_flat", 40, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "phys_dmg_flat", 40, nil, 0, 0},
			{"raw", "healing_power_flat", 40, nil, 2, 1},
	},
	[467632] = {
			{"by_school", "dmg_mod", 0.25, {6,}, 1, 0},
	},
	[7357] = {
			{"raw", "melee_haste", -0.25, nil, 33, 0},
	},
	[19285] = {
			{"raw", "phys_dmg_flat", -20, nil, 0, 0},
	},
	[460455] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[425467] = {
			{"by_school", "sp_dmg_flat", 0, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 0, nil, 2, 1},
	},
	[402362] = {
			{"raw", "heal_mod", 0.099999994, nil, 1, 0},
	},
	[20716] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
	},
	[368615] = {
			{"raw", "cast_haste", 0.29999998, nil, 0, 2},
			{"raw", "melee_haste", 0.29999998, nil, 33, 3},
			{"raw", "ranged_haste", 0.29999998, nil, 33, 4},
	},
	[17105] = {
			{"raw", "phys_hit", -0.099999994, nil, 2, 0},
	},
	[20905] = {
			{"raw", "rap_flat", 75, nil, 2, 0},
			{"raw", "ap_flat", 75, nil, 2, 1},
			{"raw", "rap_flat", 150, nil, 2, 2},
	},
	[22247] = {
			{"raw", "melee_haste", -4, nil, 33, 1},
			{"raw", "cast_haste", -0.79999995, nil, 0, 2},
	},
	[369982] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[1214298] = {
			{"by_school", "dmg_mod", 0.099999994, {2,}, 1, 0},
	},
	[7102] = {
			{"raw", "melee_haste", -0.32999998, nil, 33, 0},
			{"raw", "cast_haste", -0.25, nil, 0, 1},
	},
	[420964] = {
			{"raw", "phys_dmg_flat", -20, nil, 0, 1},
	},
	[29332] = {
			{"raw", "phys_hit", 0.02, nil, 2, 0},
	},
	[468461] = {
			{"by_school", "crit", 0.099999994, {2,}, 2, 0},
	},
	[28155] = {
			{"raw", "healing_power_flat", 300, nil, 2, 0},
			{"by_school", "sp_dmg_flat", 120, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[13490] = {
			{"raw", "ap_flat", -30, nil, 2, 0},
			{"raw", "rap_flat", -30, nil, 2, 1},
	},
	[22820] = {
			{"by_school", "crit", 0.03, {4,}, 2, 0},
	},
	[4060] = {
			{"by_school", "sp_dmg_flat", -40, {1,2,3,4,5,6,7,}, 2, 2},
			{"raw", "phys_dmg_flat", -40, nil, 0, 2},
	},
	[15656] = {
			{"raw", "melee_haste", -0.25, nil, 33, 0},
	},
	[18173] = {
			{"by_school", "dmg_mod", 1, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 1, nil, 1, 0},
			{"raw", "cast_haste", 1000, nil, 0, 1},
	},
	[408309] = {
			{"by_school", "sp_dmg_flat", 0, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[21793] = {
			{"raw", "melee_haste", -3, nil, 33, 2},
	},
	[22817] = {
			{"raw", "ap_flat", 200, nil, 2, 0},
			{"raw", "rap_flat", 200, nil, 2, 1},
	},
	[24002] = {
			{"raw", "melee_haste", -1.5, nil, 33, 0},
	},
	[18371] = {
			{"raw", "regen_while_casting", 0.5, nil, 0, 1},
	},
	[25782] = {
			{"raw", "ap_flat", 155, nil, 2, 0},
	},
	[409365] = {
			{"raw", "melee_haste", 0, nil, 33, 0},
	},
	[473476] = {
			{"by_attr", "stat_mod", 0.14999999, {1,2,3,4,5,}, 0, 2},
	},
	[17038] = {
			{"raw", "ap_flat", 35, nil, 2, 0},
	},
	[19834] = {
			{"raw", "ap_flat", 35, nil, 2, 0},
	},
	[24603] = {
			{"raw", "phys_dmg_flat", 28, nil, 0, 0},
	},
	[16458] = {
			{"by_school", "sp_dmg_flat", -25, {1,2,3,4,5,6,7,}, 2, 1},
			{"raw", "phys_dmg_flat", -25, nil, 0, 1},
	},
	[10653] = {
			{"raw", "phys_dmg_flat", -8, nil, 0, 0},
			{"raw", "cast_haste", -0.19999999, nil, 0, 1},
	},
	[22290] = {
			{"raw", "melee_haste", -1, nil, 33, 0},
	},
	[1213904] = {
			{"raw", "phys_crit", 0.02, nil, 32, 1},
	},
	[3442] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
	},
	[469025] = {
			{"creature", "dmg_mod", 0.29999998, {2,}, 1, 0},
	},
	[8140] = {
			{"raw", "cast_haste", -0.5, nil, 0, 0},
	},
	[460750] = {
			{"by_school", "dmg_mod", 0.14999999, {6,}, 1, 0},
	},
	[9612] = {
			{"raw", "phys_hit", -0.5, nil, 2, 0},
	},
	[26615] = {
			{"raw", "melee_haste", 1.5, nil, 33, 0},
	},
	[19652] = {
			{"raw", "ap_flat", -23, nil, 2, 0},
	},
	[469209] = {
			{"by_school", "sp_dmg_flat", 16, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[457816] = {
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[11436] = {
			{"raw", "melee_haste", -0.53999996, nil, 33, 0},
	},
	[407627] = {
			{"by_school", "threat", 1.23, {2,}, 0, 0},
			{"by_school", "threat", 0.5, {1,3,4,5,6,7,}, 0, 1},
	},
	[27689] = {
			{"raw", "melee_haste", 1, nil, 33, 0},
	},
	[89] = {
			{"raw", "melee_haste", -0.45, nil, 33, 0},
			{"raw", "ranged_haste", -0.45, nil, 33, 1},
	},
	[1213367] = {
			{"raw", "ap_flat", 70, nil, 2, 0},
			{"raw", "rap_flat", 70, nil, 2, 1},
	},
	[16329] = {
			{"raw", "ap_flat", 40, nil, 2, 0},
			{"raw", "rap_flat", 40, nil, 2, 1},
	},
	[448828] = {
			{"raw", "melee_haste", 1, nil, 33, 1},
	},
	[15471] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
	},
	[467141] = {
			{"raw", "cast_haste", 0.32999998, nil, 0, 0},
	},
	[6268] = {
			{"raw", "phys_dmg_flat", 10, nil, 0, 1},
	},
	[468157] = {
			{"raw", "melee_haste", -0.19999999, nil, 33, 0},
	},
	[355366] = {
			{"raw", "melee_haste", 0.14999999, nil, 33, 1},
	},
	[370550] = {
			{"raw", "ap_flat", 200, nil, 2, 0},
			{"raw", "rap_flat", 200, nil, 2, 1},
	},
	[7844] = {
			{"by_school", "sp_dmg_flat", 10, {3,}, 2, 0},
	},
	[19283] = {
			{"raw", "phys_dmg_flat", -11, nil, 0, 0},
	},
	[25801] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 0},
			{"raw", "phys_mod", 0.19999999, nil, 1, 1},
	},
	[422397] = {
			{"raw", "phys_dmg_flat", -20, nil, 0, 1},
	},
	[346285] = {
			{"by_school", "dmg_mod", 0.5, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 0.5, nil, 1, 1},
	},
	[5271] = {
			{"raw", "melee_haste", -0.42999998, nil, 33, 0},
	},
	[3671] = {
			{"raw", "phys_dmg_flat", -15, nil, 0, 0},
	},
	[7992] = {
			{"raw", "melee_haste", -0.25, nil, 33, 0},
	},
	[15366] = {
			{"raw", "phys_crit", 0.049999997, nil, 32, 0},
			{"by_school", "crit", 0.049999997, {4,}, 2, 2},
	},
	[436739] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[439959] = {
			{"by_school", "sp_dmg_flat", 14, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[24662] = {
			{"raw", "phys_dmg_flat", 2, nil, 0, 0},
	},
	[461470] = {
			{"raw", "melee_haste", 0.03, nil, 33, 0},
	},
	[462832] = {
			{"by_school", "sp_dmg_flat", 0, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[24659] = {
			{"by_school", "sp_dmg_flat", 17, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 34, nil, 2, 1},
	},
	[467412] = {
			{"by_school", "sp_dmg_flat", 50, {5,}, 2, 0},
	},
	[12541] = {
			{"raw", "phys_hit", -0.099999994, nil, 2, 0},
	},
	[1219519] = {
			{"raw", "ap_flat", 280, nil, 2, 0},
			{"raw", "rap_flat", 280, nil, 2, 1},
	},
	[469239] = {
			{"by_school", "sp_dmg_flat", 100, {5,}, 2, 0},
	},
	[28747] = {
			{"raw", "phys_mod", 1, nil, 1, 0},
			{"raw", "melee_haste", 0.5, nil, 33, 1},
	},
	[16601] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[26166] = {
			{"by_school", "sp_dmg_flat", 50, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[457817] = {
			{"raw", "phys_crit", 0.099999994, nil, 32, 0},
	},
	[415144] = {
			{"raw", "ap_flat", 150, nil, 2, 0},
			{"by_school", "sp_dmg_flat", 30, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[24178] = {
			{"by_school", "dmg_mod", 2, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 2, nil, 1, 1},
			{"raw", "melee_haste", 1, nil, 33, 2},
	},
	[24498] = {
			{"by_school", "crit", 0.099999994, {2,}, 2, 0},
	},
	[5515] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 0},
	},
	[370444] = {
			{"by_school", "sp_dmg_flat", 10, {1,2,3,4,5,6,7,}, 2, 1},
			{"raw", "phys_dmg_flat", 10, nil, 0, 1},
	},
	[18810] = {
			{"raw", "melee_haste", 1, nil, 33, 0},
			{"raw", "phys_dmg_flat", 30, nil, 0, 1},
	},
	[13494] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[18803] = {
			{"raw", "cast_haste", 1000, nil, 0, 0},
	},
	[11415] = {
			{"creature", "dmg_mod", 0.03, {32,}, 1, 0},
	},
	[8733] = {
			{"by_school", "sp_dmg_flat", 15, {5,}, 2, 2},
	},
	[24438] = {
			{"raw", "phys_dmg_flat", 200, nil, 0, 0},
	},
	[446706] = {
			{"by_school", "sp_dmg_flat", 66, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[461680] = {
			{"by_school", "sp_dmg_flat", 184, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 184, nil, 2, 1},
	},
	[1219513] = {
			{"raw", "healing_power_flat", 450, nil, 2, 0},
	},
	[23577] = {
			{"raw", "ap_flat", 450, nil, 0, 0},
	},
	[23262] = {
			{"raw", "ap_flat", -10, nil, 2, 0},
	},
	[1214279] = {
			{"by_school", "sp_dmg_flat", 193, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[28762] = {
			{"by_school", "threat", -1, {2,3,4,5,6,7,}, 0, 0},
	},
	[459165] = {
			{"raw", "ap_flat", -1110, nil, 2, 0},
			{"raw", "rap_flat", -1110, nil, 2, 1},
	},
	[462872] = {
			{"raw", "melee_haste", 0.35, nil, 33, 0},
	},
	[19779] = {
			{"raw", "melee_haste", 1, nil, 33, 0},
			{"raw", "phys_mod", 0.25, nil, 1, 1},
			{"raw", "melee_haste", 2, nil, 33, 0},
			{"raw", "phys_mod", 1.5, nil, 1, 1},
			{"raw", "cast_haste", 0.25, nil, 0, 3},
	},
	[3603] = {
			{"raw", "cast_haste", -0.35, nil, 0, 0},
	},
	[14897] = {
			{"raw", "melee_haste", -0.25, nil, 33, 0},
	},
	[28862] = {
			{"by_school", "threat", -0.35, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[3443] = {
			{"raw", "melee_haste", 0.35, nil, 33, 0},
	},
	[446698] = {
			{"by_school", "sp_dmg_flat", 65, {1,2,3,4,5,6,7,}, 2, 1},
			{"by_attr", "stat_mod", 0.08, {1,2,3,4,5,}, 0, 2},
	},
	[18787] = {
			{"raw", "ap_flat", 100, nil, 2, 0},
			{"raw", "rap_flat", 100, nil, 2, 1},
	},
	[1221329] = {
			{"by_school", "dmg_mod", 0.25, {1,2,3,4,5,6,7,}, 1, 2},
			{"raw", "phys_mod", 0.25, nil, 1, 2},
	},
	[456401] = {
			{"by_school", "dmg_mod", 0.01, {1,2,3,4,5,6,7,}, 1, 0},
	},
	[24605] = {
			{"raw", "phys_dmg_flat", 18, nil, 0, 0},
	},
	[370552] = {
			{"by_attr", "stat_mod", 0.049999997, {1,2,3,4,5,}, 0, 0},
	},
	[11414] = {
			{"creature", "dmg_mod", 0.02, {32,}, 1, 0},
	},
	[412758] = {
			{"by_school", "dmg_mod", 0.39999998, {3,}, 1, 1},
	},
	[1218358] = {
			{"raw", "ap_flat", 14, nil, 2, 0},
	},
	[21062] = {
			{"by_attr", "stat_mod", -0.5, {2,}, 0, 0},
			{"by_attr", "stat_mod", -0.5, {5,}, 0, 1},
	},
	[67] = {
			{"by_attr", "stat_mod", -0.049999997, {1,}, 0, 0},
			{"by_attr", "stat_mod", -0.049999997, {2,}, 0, 1},
	},
	[23021] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
			{"raw", "phys_mod", -0.5, nil, 1, 2},
	},
	[439155] = {
			{"by_school", "sp_dmg_flat", 20, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "ap_flat", 20, nil, 2, 1},
			{"raw", "healing_power_flat", 20, nil, 2, 2},
			{"raw", "rap_flat", 20, nil, 2, 3},
	},
	[460939] = {
			{"raw", "melee_haste", 0.14999999, nil, 33, 1},
	},
	[1214102] = {
			{"by_school", "threat", -0.19999999, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[9634] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 0},
	},
	[467413] = {
			{"by_school", "sp_dmg_flat", 50, {4,}, 2, 0},
	},
	[7646] = {
			{"raw", "phys_dmg_flat", -15, nil, 0, 0},
	},
	[450084] = {
			{"raw", "melee_haste", 0.099999994, nil, 33, 0},
	},
	[1219553] = {
			{"raw", "healing_power_flat", 62, nil, 2, 0},
			{"by_school", "sp_dmg_flat", 19, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[24672] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[3490] = {
			{"raw", "melee_haste", 0.75, nil, 33, 0},
			{"raw", "phys_dmg_flat", -15, nil, 0, 1},
	},
	[12531] = {
			{"raw", "melee_haste", -0.42999998, nil, 33, 0},
	},
	[6814] = {
			{"raw", "melee_haste", -0.25, nil, 33, 2},
	},
	[1066] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 0},
	},
	[425284] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 1},
	},
	[17628] = {
			{"by_school", "sp_dmg_flat", 150, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[25806] = {
			{"by_school", "dmg_mod", 2, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 2, nil, 1, 1},
			{"raw", "melee_haste", 1, nil, 33, 2},
	},
	[456344] = {
			{"creature", "dmg_mod", 0.03, {32,}, 1, 0},
	},
	[26043] = {
			{"raw", "phys_dmg_flat", 200, nil, 0, 0},
	},
	[28204] = {
			{"by_school", "sp_dmg_flat", 40, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 75, nil, 2, 1},
	},
	[29166] = {
			{"raw", "regen_while_casting", 1, nil, 0, 0},
	},
	[430952] = {
			{"by_school", "crit", 0.01, {7,}, 2, 0},
	},
	[27648] = {
			{"raw", "melee_haste", -0.19999999, nil, 33, 0},
	},
	[28420] = {
			{"by_school", "dmg_mod", 0.29999998, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.29999998, nil, 1, 0},
	},
	[8552] = {
			{"raw", "phys_dmg_flat", -5, nil, 0, 0},
	},
	[8692] = {
			{"raw", "cast_haste", -0.5, nil, 0, 0},
	},
	[6673] = {
			{"raw", "ap_flat", 15, nil, 2, 0},
	},
	[12328] = {
			{"raw", "phys_mod", 0.19999999, nil, 1, 0},
	},
	[14320] = {
			{"raw", "rap_flat", 70, nil, 2, 0},
	},
	[435973] = {
			{"by_school", "sp_dmg_flat", 35, {1,2,3,4,5,6,7,}, 2, 2},
			{"raw", "ap_flat", 40, nil, 2, 3},
			{"raw", "rap_flat", 40, nil, 2, 6},
	},
	[446322] = {
			{"by_school", "threat", -0.29999998, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[1215756] = {
			{"by_school", "dmg_mod", 0.049999997, {4,}, 1, 0},
	},
	[1219503] = {
			{"by_school", "threat", -0.7, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[402811] = {
			{"raw", "ap_flat", -13, nil, 2, 0},
			{"raw", "rap_flat", -13, nil, 2, 1},
	},
	[24043] = {
			{"raw", "phys_dmg_flat", 40, nil, 0, 0},
	},
	[25101] = {
			{"raw", "ap_flat", 400, nil, 2, 0},
	},
	[5242] = {
			{"raw", "ap_flat", 35, nil, 2, 0},
	},
	[19254] = {
			{"raw", "phys_dmg_flat", -20, nil, 0, 1},
	},
	[16280] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[27578] = {
			{"raw", "ap_flat", 185, nil, 2, 0},
	},
	[7137] = {
			{"raw", "phys_dmg_flat", 10, nil, 0, 1},
	},
	[19282] = {
			{"raw", "phys_dmg_flat", -7, nil, 0, 0},
	},
	[25848] = {
			{"raw", "phys_crit", 0.099999994, nil, 32, 0},
	},
	[24402] = {
			{"by_school", "spell_hit", -0.099999994, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "phys_hit", -0.099999994, nil, 2, 1},
	},
	[19836] = {
			{"raw", "ap_flat", 85, nil, 2, 0},
	},
	[8272] = {
			{"raw", "cast_haste", -0.19999999, nil, 0, 0},
	},
	[12970] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[27499] = {
			{"by_school", "sp_dmg_flat", 95, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 95, nil, 2, 1},
	},
	[403619] = {
			{"by_school", "sp_dmg_flat", 1, {1,2,3,4,5,6,7,}, 2, 2},
			{"raw", "phys_dmg_flat", 1, nil, 0, 2},
			{"raw", "healing_power_flat", 1, nil, 2, 4},
	},
	[16449] = {
			{"raw", "ap_flat", -50, nil, 2, 0},
			{"raw", "rap_flat", -50, nil, 2, 1},
	},
	[446256] = {
			{"by_school", "sp_dmg_flat", 40, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[24689] = {
			{"raw", "melee_haste", 1.5, nil, 33, 0},
	},
	[21920] = {
			{"by_school", "sp_dmg_flat", 15, {5,}, 2, 0},
	},
	[417045] = {
			{"raw", "phys_mod", 0.14999999, nil, 1, 0},
	},
	[26051] = {
			{"raw", "melee_haste", 1.5, nil, 33, 0},
	},
	[15850] = {
			{"raw", "melee_haste", -0.25, nil, 33, 0},
	},
	[20006] = {
			{"raw", "phys_dmg_flat", -15, nil, 0, 0},
	},
	[20307] = {
			{"raw", "ap_flat", 221, nil, 2, 0},
	},
	[430420] = {
			{"by_attr", "stat_mod", 0.049999997, {4,}, 0, 0},
	},
	[436430] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 0},
			{"raw", "phys_dmg_flat", 25, nil, 0, 1},
	},
	[6742] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[6907] = {
			{"raw", "melee_haste", -0.53999996, nil, 33, 0},
	},
	[456400] = {
			{"by_school", "dmg_mod", 0.01, {1,2,3,4,5,6,7,}, 1, 0},
	},
	[20053] = {
			{"raw", "phys_mod", 0.089999996, nil, 1, 0},
			{"by_school", "dmg_mod", 0.089999996, {2,}, 1, 1},
	},
	[11960] = {
			{"raw", "ap_flat", -20, nil, 2, 0},
	},
	[26083] = {
			{"raw", "melee_haste", -99, nil, 33, 1},
	},
	[427726] = {
			{"by_school", "dmg_mod", 0.099999994, {3,}, 1, 2},
	},
	[436387] = {
			{"by_school", "dmg_mod", 0.08, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.08, nil, 1, 0},
	},
	[408699] = {
			{"raw", "melee_haste", -0.099999994, nil, 33, 0},
	},
	[17205] = {
			{"raw", "ap_flat", 70, nil, 2, 0},
	},
	[20308] = {
			{"raw", "ap_flat", 306, nil, 2, 0},
	},
	[27722] = {
			{"raw", "healing_power_flat", 44, nil, 2, 0},
	},
	[11980] = {
			{"raw", "phys_dmg_flat", -1, nil, 0, 0},
	},
	[22667] = {
			{"by_school", "dmg_mod", 3, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 3, nil, 1, 1},
	},
	[446228] = {
			{"raw", "ap_flat", 45, nil, 2, 0},
			{"raw", "rap_flat", 45, nil, 2, 1},
	},
	[28143] = {
			{"by_school", "sp_dmg_flat", 33, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 33, nil, 2, 1},
	},
	[426694] = {
			{"applies_aura", "shapeshift_passives", 0, {21178,}, 16, 0},
	},
	[446577] = {
			{"raw", "melee_haste", 0.049999997, nil, 33, 0},
			{"raw", "ap_flat", 50, nil, 2, 1},
	},
	[446712] = {
			{"raw", "healing_power_flat", 120, nil, 2, 0},
	},
	[3650] = {
			{"raw", "phys_hit", -0.5, nil, 2, 0},
	},
	[6774] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 1},
	},
	[6793] = {
			{"raw", "phys_dmg_flat", 20, nil, 0, 0},
	},
	[6205] = {
			{"raw", "phys_dmg_flat", -10, nil, 0, 0},
	},
	[23723] = {
			{"raw", "cast_haste", 0.32999998, nil, 0, 0},
	},
	[25291] = {
			{"raw", "ap_flat", 185, nil, 2, 0},
	},
	[1108] = {
			{"raw", "phys_dmg_flat", -6, nil, 0, 0},
	},
	[446327] = {
			{"raw", "phys_dmg_flat", 20, nil, 0, 0},
			{"raw", "melee_haste", 0.049999997, nil, 33, 1},
	},
	[473387] = {
			{"by_school", "crit", 0.099999994, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "ap_flat", 140, nil, 2, 1},
			{"raw", "phys_crit", 0.049999997, nil, 32, 2},
			{"raw", "rap_flat", 140, nil, 2, 3},
	},
	[27680] = {
			{"by_school", "dmg_mod", 5, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 5, nil, 1, 0},
	},
	[1213263] = {
			{"by_school", "dmg_mod", 0.14999999, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.14999999, nil, 1, 0},
			{"raw", "heal_mod", 0.14999999, nil, 1, 2},
	},
	[16528] = {
			{"raw", "melee_haste", -0.11, nil, 33, 1},
	},
	[420536] = {
			{"by_school", "spell_hit", -1, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[27723] = {
			{"raw", "phys_hit", 0.02, nil, 2, 0},
	},
	[459293] = {
			{"wpn_subclass", "spell_mod", 0.099999994, {8192}, 9, 1},
			{"wpn_subclass", "phys_mod", 0.099999994, {8192}, 9, 1},
	},
	[430421] = {
			{"by_attr", "stat_mod", 0.049999997, {3,}, 0, 0},
	},
	[5760] = {
			{"raw", "cast_haste", -0.39999998, nil, 0, 0},
	},
	[25797] = {
			{"by_school", "sp_dmg_flat", 10, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[5884] = {
			{"raw", "phys_hit", -0.099999994, nil, 2, 0},
	},
	[10855] = {
			{"raw", "melee_haste", -0.53999996, nil, 33, 0},
	},
	[415320] = {
			{"wpn_subclass", "spell_mod", 0.08, {173555}, 9, 2},
			{"wpn_subclass", "phys_mod", 0.08, {173555}, 9, 2},
	},
	[16460] = {
			{"raw", "phys_crit", -0.049999997, nil, 32, 0},
			{"by_school", "crit", -0.049999997, {1,}, 2, 1},
	},
	[10371] = {
			{"raw", "melee_haste", -0.25, nil, 33, 0},
	},
	[446305] = {
			{"by_school", "sp_dmg_flat", 8, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 16, nil, 2, 1},
	},
	[702] = {
			{"raw", "phys_dmg_flat", -3, nil, 0, 0},
	},
	[367987] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 0.099999994, nil, 1, 1},
			{"raw", "cast_haste", 1, nil, 0, 3},
	},
	[1220756] = {
			{"raw", "healing_power_flat", 300, nil, 2, 0},
			{"by_school", "sp_dmg_flat", 150, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[16587] = {
			{"by_school", "sp_dmg_flat", 35, {6,}, 2, 0},
	},
	[28701] = {
			{"raw", "melee_haste", 0.14999999, nil, 33, 0},
			{"raw", "ranged_haste", 0.14999999, nil, 33, 1},
	},
	[14204] = {
			{"raw", "phys_mod", 0.25, nil, 1, 0},
	},
	[24389] = {
			{"by_school", "sp_dmg_flat", 100, {3,}, 2, 1},
	},
	[1213897] = {
			{"raw", "ap_flat", 50, nil, 2, 0},
			{"raw", "rap_flat", 50, nil, 2, 1},
	},
	[16366] = {
			{"raw", "phys_dmg_flat", 6, nil, 0, 0},
	},
	[370835] = {
			{"by_school", "dmg_mod", 0.01, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.01, nil, 1, 0},
	},
	[1219552] = {
			{"by_school", "sp_dmg_flat", 33, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 33, nil, 2, 1},
	},
	[22418] = {
			{"by_school", "sp_dmg_flat", 1, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[3416] = {
			{"raw", "phys_dmg_flat", 45, nil, 0, 1},
			{"raw", "melee_haste", -0.5, nil, 33, 2},
	},
	[19953] = {
			{"raw", "phys_dmg_flat", 500, nil, 0, 0},
			{"raw", "melee_haste", 0.5, nil, 33, 1},
	},
	[5628] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[1719] = {
			{"raw", "phys_crit", 1, nil, 32, 0},
	},
	[24991] = {
			{"creature", "dmg_mod", 0.39999998, {8,}, 1, 0},
	},
	[428741] = {
			{"by_school", "crit", 0.049999997, {3,}, 2, 2},
	},
	[12686] = {
			{"raw", "ap_flat", 20, nil, 2, 0},
			{"raw", "melee_haste", 0.049999997, nil, 33, 1},
	},
	[14319] = {
			{"raw", "rap_flat", 50, nil, 2, 0},
	},
	[25891] = {
			{"raw", "ap_flat", 280, nil, 2, 0},
			{"raw", "rap_flat", 280, nil, 2, 2},
	},
	[20005] = {
			{"raw", "melee_haste", -0.25, nil, 33, 0},
	},
	[435978] = {
			{"by_school", "sp_dmg_flat", 40, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 40, nil, 2, 1},
	},
	[1213268] = {
			{"raw", "ap_flat", 110, nil, 0, 1},
	},
	[470367] = {
			{"raw", "healing_power_flat", 22, nil, 2, 0},
	},
	[27545] = {
			{"applies_aura", "shapeshift_passives", 0, {3025,}, 16, 0},
			{"raw", "melee_haste", 1, nil, 33, 1},
	},
	[432069] = {
			{"by_school", "dmg_mod", -0.5, {3,5,}, 1, 0},
	},
	[25296] = {
			{"raw", "rap_flat", 120, nil, 2, 0},
	},
	[15859] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
	},
	[1223048] = {
			{"raw", "heal_mod", 0.099999994, nil, 1, 0},
	},
	[21165] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 0},
	},
	[8602] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[17650] = {
			{"by_school", "dmg_mod", -0.19999999, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", -0.19999999, nil, 1, 0},
	},
	[468784] = {
			{"by_school", "sp_dmg_flat", 191, {6,7,}, 2, 0},
	},
	[468540] = {
			{"by_school", "crit", 0.099999994, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "phys_crit", 0.099999994, nil, 32, 1},
	},
	[5917] = {
			{"raw", "phys_hit", -0.25, nil, 2, 0},
	},
	[16843] = {
			{"raw", "extra_hits_flat", 3, nil, 0, 0},
	},
	[11707] = {
			{"raw", "phys_dmg_flat", -22, nil, 0, 0},
	},
	[461475] = {
			{"by_school", "crit", 0.049999997, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "ap_flat", 3, nil, 2, 1},
			{"raw", "phys_crit", 0.049999997, nil, 32, 2},
			{"raw", "rap_flat", 3, nil, 2, 3},
	},
	[11726] = {
			{"raw", "melee_haste", -0.39999998, nil, 33, 1},
			{"raw", "cast_haste", -0.29999998, nil, 0, 2},
	},
	[26635] = {
			{"raw", "melee_haste", 0.099999994, nil, 33, 0},
			{"raw", "ranged_haste", 0.049999997, nil, 33, 1},
			{"raw", "cast_haste", 0.049999997, nil, 0, 2},
	},
	[23060] = {
			{"raw", "melee_haste", 0.049999997, nil, 33, 0},
	},
	[474400] = {
			{"raw", "melee_haste", 0.5, nil, 33, 1},
	},
	[409507] = {
			{"raw", "ap_flat", 40, nil, 2, 0},
			{"raw", "rap_flat", 40, nil, 2, 1},
	},
	[23342] = {
			{"raw", "melee_haste", 1.5, nil, 33, 0},
			{"raw", "melee_haste", 1.5, nil, 33, 0},
	},
	[27035] = {
			{"raw", "extra_hits_flat", 1, nil, 0, 0},
	},
	[460772] = {
			{"by_school", "dmg_mod", 0.5, {1,2,3,4,5,6,7,}, 1, 2},
			{"raw", "phys_mod", 0.5, nil, 1, 2},
	},
	[10911] = {
			{"raw", "melee_haste", -0.25, nil, 33, 2},
	},
	[1219515] = {
			{"by_school", "sp_dmg_flat", 180, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 180, nil, 2, 1},
	},
	[16231] = {
			{"raw", "ap_flat", 45, nil, 2, 0},
	},
	[23734] = {
			{"by_school", "dmg_mod", 0.19999999, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "heal_mod", 0.19999999, nil, 1, 1},
	},
	[1213914] = {
			{"by_school", "sp_dmg_flat", 40, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[19835] = {
			{"raw", "ap_flat", 55, nil, 2, 0},
	},
	[19516] = {
			{"raw", "melee_haste", 0.089999996, nil, 33, 0},
	},
	[8277] = {
			{"raw", "phys_dmg_flat", -5, nil, 0, 0},
	},
	[14822] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[15271] = {
			{"by_attr", "stat_mod", 1, {5,}, 0, 0},
			{"raw", "regen_while_casting", 0.5, nil, 0, 1},
	},
	[446541] = {
			{"raw", "healing_power_flat", 50, nil, 2, 0},
	},
	[642] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
			{"by_school", "dmg_mod", -0.5, {1,2,3,4,5,6,7,}, 1, 3},
			{"raw", "phys_mod", -0.5, nil, 1, 3},
	},
	[4955] = {
			{"raw", "melee_haste", -0.53999996, nil, 33, 1},
			{"raw", "phys_dmg_flat", 100, nil, 0, 2},
	},
	[7103] = {
			{"raw", "melee_haste", -0.32999998, nil, 33, 0},
			{"raw", "cast_haste", -0.25, nil, 0, 1},
	},
	[430949] = {
			{"by_school", "spell_hit", 0.01, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[440667] = {
			{"raw", "ap_flat", -90, nil, 2, 0},
			{"raw", "rap_flat", -90, nil, 2, 1},
	},
	[26018] = {
			{"by_attr", "stat_mod", -0.14999999, {1,}, 0, 0},
			{"by_attr", "stat_mod", -0.14999999, {2,}, 0, 1},
	},
	[6530] = {
			{"raw", "phys_hit", -0.39999998, nil, 2, 0},
	},
	[368371] = {
			{"by_school", "dmg_mod", 1, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 1, nil, 1, 0},
	},
	[18309] = {
			{"applies_aura", "shapeshift_passives", 0, {21178,}, 16, 0},
	},
	[436365] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
			{"by_school", "spell_hit", 0.099999994, {1,2,3,4,5,6,7,}, 2, 2},
	},
	[1223458] = {
			{"raw", "phys_dmg_flat", 30, nil, 0, 0},
			{"raw", "melee_haste", 0.14999999, nil, 33, 1},
	},
	[446287] = {
			{"raw", "phys_crit", 1, nil, 32, 0},
	},
	[25799] = {
			{"by_school", "sp_dmg_flat", 30, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[1213892] = {
			{"by_school", "sp_dmg_flat", 180, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[7396] = {
			{"raw", "melee_haste", 0.099999994, nil, 33, 0},
	},
	[19284] = {
			{"raw", "phys_dmg_flat", -15, nil, 0, 0},
	},
	[1214088] = {
			{"by_school", "dmg_mod", 0.049999997, {3,}, 1, 0},
	},
	[426303] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[28347] = {
			{"raw", "rap_flat", 600, nil, 2, 0},
			{"raw", "ap_flat", 600, nil, 2, 1},
	},
	[14323] = {
			{"raw", "ap_flat", 45, nil, 0, 1},
	},
	[26400] = {
			{"by_school", "threat", -0.7, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[1218485] = {
			{"by_school", "dmg_mod", 0.02, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.02, nil, 1, 0},
			{"by_school", "crit_mod", 0.02, {1,2,3,4,5,6,7,}, 0, 1},
	},
	[1223975] = {
			{"raw", "melee_haste", 0.25, nil, 33, 0},
	},
	[16791] = {
			{"raw", "phys_dmg_flat", 15, nil, 0, 0},
			{"raw", "melee_haste", 0.04, nil, 33, 1},
	},
	[13877] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 0},
	},
	[20668] = {
			{"by_school", "sp_dmg_flat", 300, {1,2,3,4,5,6,7,}, 2, 1},
			{"raw", "phys_dmg_flat", 100, nil, 0, 2},
	},
	[26017] = {
			{"by_attr", "stat_mod", -0.099999994, {1,}, 0, 0},
			{"by_attr", "stat_mod", -0.099999994, {2,}, 0, 1},
	},
	[12480] = {
			{"raw", "phys_mod", 4, nil, 1, 1},
	},
	[461317] = {
			{"raw", "healing_power_flat", 220, nil, 2, 0},
	},
	[28470] = {
			{"by_school", "dmg_mod", 0.14999999, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 0.14999999, nil, 1, 1},
	},
	[1219557] = {
			{"raw", "cast_haste", 0.02, nil, 0, 0},
	},
	[5220] = {
			{"raw", "melee_haste", 0.5, nil, 33, 1},
	},
	[467411] = {
			{"by_school", "sp_dmg_flat", 50, {6,}, 2, 0},
	},
	[7657] = {
			{"raw", "phys_dmg_flat", 10, nil, 0, 0},
			{"by_school", "sp_dmg_flat", 20, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[446286] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
	},
	[24255] = {
			{"raw", "ap_flat", 300, nil, 2, 0},
			{"raw", "rap_flat", 300, nil, 2, 1},
	},
	[1213147] = {
			{"raw", "healing_power_flat", 360, nil, 2, 0},
	},
	[23620] = {
			{"by_school", "dmg_mod", 1, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 1, nil, 1, 0},
			{"raw", "cast_haste", 1000, nil, 0, 1},
	},
	[26121] = {
			{"by_school", "sp_dmg_flat", 50, {4,}, 2, 0},
	},
	[6150] = {
			{"raw", "ranged_haste", 0.29999998, nil, 33, 0},
	},
	[467742] = {
			{"raw", "ap_flat", 300, nil, 2, 0},
			{"raw", "rap_flat", 300, nil, 2, 1},
	},
	[426489] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[437585] = {
			{"by_school", "dmg_mod", 0.049999997, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.049999997, nil, 1, 0},
	},
	[462370] = {
			{"by_school", "dmg_mod", 0.049999997, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.049999997, nil, 1, 0},
	},
	[468183] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[22818] = {
			{"by_attr", "stat_mod", 0.14999999, {3,}, 0, 0},
	},
	[1139] = {
			{"raw", "melee_haste", -0.049999997, nil, 33, 0},
	},
	[1386] = {
			{"creature", "dmg_mod", 0.049999997, {36,}, 1, 0},
	},
	[25790] = {
			{"raw", "melee_haste", 1.5, nil, 33, 0},
			{"raw", "phys_mod", 1, nil, 1, 1},
	},
	[12969] = {
			{"raw", "melee_haste", 0.25, nil, 33, 0},
	},
	[473399] = {
			{"raw", "phys_crit", 0.049999997, nil, 32, 0},
			{"by_school", "crit", 0.049999997, {4,}, 2, 2},
	},
	[456352] = {
			{"creature", "dmg_mod", 0.03, {4,}, 1, 0},
	},
	[370767] = {
			{"raw", "cast_haste", 0.099999994, nil, 0, 2},
			{"raw", "melee_haste", 0.099999994, nil, 33, 3},
			{"raw", "ranged_haste", 0.099999994, nil, 33, 4},
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 6},
			{"raw", "phys_mod", 0.099999994, nil, 1, 6},
	},
	[469222] = {
			{"by_school", "dmg_mod", 0.14999999, {3,}, 1, 0},
	},
	[27775] = {
			{"by_school", "sp_dmg_flat", 95, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 95, nil, 2, 1},
	},
	[383895] = {
			{"by_school", "dmg_mod", 0, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0, nil, 1, 0},
	},
	[370066] = {
			{"raw", "cast_haste", 0.5, nil, 0, 2},
			{"raw", "melee_haste", 0.5, nil, 33, 3},
			{"raw", "ranged_haste", 0.5, nil, 33, 4},
	},
	[20812] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
			{"by_attr", "stat_mod", -0.5, {1,}, 0, 2},
	},
	[28142] = {
			{"by_school", "crit", 0.02, {7,}, 2, 0},
	},
	[26258] = {
			{"by_school", "dmg_mod", 2, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 2, nil, 1, 1},
			{"raw", "melee_haste", 1, nil, 33, 2},
	},
	[460402] = {
			{"by_school", "dmg_mod", -0.25, {1,2,3,4,5,6,7,}, 1, 2},
			{"raw", "phys_mod", -0.25, nil, 1, 2},
			{"raw", "heal_mod", -0.25, nil, 1, 3},
	},
	[4514] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 1},
	},
	[11390] = {
			{"by_school", "sp_dmg_flat", 20, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[11398] = {
			{"raw", "cast_haste", -0.59999996, nil, 0, 0},
	},
	[408680] = {
			{"by_school", "threat", 0.65, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[7965] = {
			{"raw", "phys_dmg_flat", 50, nil, 0, 1},
			{"raw", "melee_haste", -0.42999998, nil, 33, 2},
	},
	[14201] = {
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[459610] = {
			{"by_attr", "stat_mod", 0.14999999, {1,2,3,4,5,}, 0, 2},
	},
	[461347] = {
			{"raw", "phys_dmg_flat", 500, nil, 0, 0},
			{"raw", "melee_haste", 0.5, nil, 33, 1},
	},
	[25798] = {
			{"by_school", "sp_dmg_flat", 20, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[430947] = {
			{"by_school", "spell_hit", 0.03, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "ap_flat", 20, nil, 2, 1},
			{"raw", "phys_crit", 0.02, nil, 32, 2},
			{"raw", "rap_flat", 20, nil, 2, 3},
			{"by_school", "sp_dmg_flat", 25, {1,2,3,4,5,6,7,}, 2, 5},
	},
	[20217] = {
			{"by_attr", "stat_mod", 0.099999994, {1,2,3,4,5,}, 0, 0},
	},
	[413589] = {
			{"raw", "melee_haste", -0.099999994, nil, 33, 0},
	},
	[19251] = {
			{"raw", "phys_dmg_flat", -7, nil, 0, 1},
	},
	[1219291] = {
			{"creature", "dmg_mod", 0.01, {32,}, 1, 0},
	},
	[22833] = {
			{"raw", "phys_hit", -0.75, nil, 2, 0},
	},
	[469145] = {
			{"raw", "ap_flat", 0, nil, 2, 0},
			{"raw", "rap_flat", 0, nil, 2, 1},
	},
	[21840] = {
			{"raw", "ap_flat", -130, nil, 2, 0},
	},
	[16789] = {
			{"raw", "phys_dmg_flat", 50, nil, 0, 0},
			{"raw", "melee_haste", 0.5, nil, 33, 1},
	},
	[429836] = {
			{"by_attr", "stat_mod", 0.049999997, {5,}, 0, 0},
	},
	[24975] = {
			{"raw", "phys_hit", -0.02, nil, 2, 1},
	},
	[19393] = {
			{"raw", "phys_mod", -0.5, nil, 1, 2},
			{"raw", "phys_mod", -0.5, nil, 1, 2},
	},
	[605] = {
			{"raw", "melee_haste", -0.25, nil, 33, 2},
	},
	[8875] = {
			{"by_school", "dmg_mod", 0, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0, nil, 1, 0},
	},
	[19281] = {
			{"raw", "phys_dmg_flat", -4, nil, 0, 0},
	},
	[367873] = {
			{"raw", "phys_hit", -0.5, nil, 2, 1},
			{"by_school", "spell_hit", -0.5, {1,2,3,4,5,6,7,}, 2, 2},
	},
	[16889] = {
			{"by_school", "sp_dmg_flat", 35, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[16914] = {
			{"raw", "melee_haste", -0.25, nil, 33, 1},
	},
	[8215] = {
			{"raw", "cast_haste", 1, nil, 0, 0},
	},
	[459592] = {
			{"raw", "melee_haste", -99, nil, 33, 1},
	},
	[28801] = {
			{"by_attr", "stat_mod", -0.9, {1,2,3,4,5,}, 0, 0},
	},
	[1213241] = {
			{"by_school", "sp_dmg_flat", 20, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[13589] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 0},
	},
	[426159] = {
			{"by_school", "sp_dmg_flat", 0, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[436641] = {
			{"creature", "dmg_mod", 0, {0,}, 1, 0},
	},
	[18501] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
			{"raw", "melee_haste", 0.29999998, nil, 33, 1},
	},
	[28468] = {
			{"raw", "phys_mod", 1.5, nil, 1, 0},
	},
	[228] = {
			{"raw", "phys_mod", -0.65999997, nil, 1, 2},
	},
	[15642] = {
			{"raw", "extra_hits_flat", 3, nil, 0, 0},
			{"raw", "phys_crit", 0.099999994, nil, 32, 1},
	},
	[22782] = {
			{"raw", "regen_while_casting", 0.29999998, nil, 0, 1},
	},
	[428726] = {
			{"raw", "ranged_haste", 0.03, nil, 33, 0},
	},
	[18789] = {
			{"by_school", "dmg_mod", 0.14999999, {3,}, 1, 0},
	},
	[29604] = {
			{"raw", "ap_flat", 65, nil, 2, 0},
			{"raw", "rap_flat", 65, nil, 2, 1},
	},
	[1213422] = {
			{"raw", "regen_while_casting", 1, nil, 0, 0},
	},
	[1220545] = {
			{"raw", "ap_flat", 140, nil, 2, 0},
			{"raw", "rap_flat", 140, nil, 2, 1},
	},
	[1787] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 0},
	},
	[418508] = {
			{"raw", "phys_crit", 1, nil, 32, 0},
			{"raw", "phys_mod", 0.25, nil, 1, 1},
	},
	[434941] = {
			{"by_school", "dmg_mod", 0.25, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 0.25, nil, 1, 1},
	},
	[1214001] = {
			{"by_school", "sp_dmg_flat", 40, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "ap_flat", 40, nil, 2, 1},
			{"raw", "healing_power_flat", 40, nil, 2, 2},
			{"raw", "rap_flat", 40, nil, 2, 3},
	},
	[20052] = {
			{"raw", "phys_mod", 0.06, nil, 1, 0},
			{"by_school", "dmg_mod", 0.06, {2,}, 1, 1},
	},
	[13165] = {
			{"raw", "rap_flat", 20, nil, 2, 0},
	},
	[438536] = {
			{"by_school", "crit", 0.04, {1,}, 2, 0},
			{"by_school", "sp_dmg_flat", 42, {1,2,3,4,5,6,7,}, 2, 1},
			{"raw", "healing_power_flat", 42, nil, 2, 2},
			{"raw", "melee_haste", 0.099999994, nil, 33, 3},
			{"raw", "ranged_haste", 0.099999994, nil, 33, 4},
	},
	[8365] = {
			{"raw", "phys_dmg_flat", 3, nil, 0, 0},
	},
	[1130] = {
			{"raw", "ap_flat", 20, nil, 0, 1},
	},
	[23537] = {
			{"raw", "phys_dmg_flat", 219, nil, 0, 0},
			{"raw", "melee_haste", 0.5, nil, 33, 1},
	},
	[460940] = {
			{"raw", "melee_haste", 0.14999999, nil, 33, 1},
	},
	[4962] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
	},
	[29659] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[8699] = {
			{"raw", "melee_haste", 0.35, nil, 33, 0},
	},
	[768] = {
			{"applies_aura", "shapeshift_passives", 0, {3025,}, 16, 0},
	},
	[12880] = {
			{"raw", "phys_mod", 0.049999997, nil, 1, 0},
	},
	[20218] = {
			{"by_school", "dmg_mod", 0.099999994, {2,}, 1, 0},
	},
	[1217084] = {
			{"by_school", "dmg_mod", 0.03, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.03, nil, 1, 0},
			{"by_school", "crit_mod", 0.03, {1,2,3,4,5,6,7,}, 0, 1},
	},
	[17227] = {
			{"raw", "phys_dmg_flat", -1, nil, 0, 0},
	},
	[23684] = {
			{"raw", "regen_while_casting", 1, nil, 0, 0},
	},
	[425895] = {
			{"raw", "melee_haste", -0.25, nil, 33, 1},
	},
	[15061] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
			{"raw", "melee_haste", 0.29999998, nil, 33, 1},
	},
	[26129] = {
			{"by_school", "spell_hit", 0.049999997, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[29178] = {
			{"raw", "phys_crit", 0.089999996, nil, 32, 0},
	},
	[1714] = {
			{"raw", "cast_haste", -0.5, nil, 0, 0},
	},
	[6117] = {
			{"raw", "regen_while_casting", 0.29999998, nil, 0, 1},
	},
	[7659] = {
			{"raw", "ap_flat", 65, nil, 2, 0},
	},
	[26195] = {
			{"by_school", "dmg_mod", 2, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 2, nil, 1, 1},
			{"raw", "melee_haste", 1, nil, 33, 2},
	},
	[456349] = {
			{"creature", "dmg_mod", 0.03, {8,}, 1, 0},
	},
	[4063] = {
			{"raw", "phys_dmg_flat", 10, nil, 0, 1},
			{"raw", "melee_haste", 0.5, nil, 33, 2},
	},
	[407788] = {
			{"by_school", "dmg_mod", 0.19999999, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.19999999, nil, 1, 0},
			{"raw", "heal_mod", 0.19999999, nil, 1, 1},
	},
	[7483] = {
			{"raw", "phys_dmg_flat", 20, nil, 0, 0},
	},
	[439473] = {
			{"raw", "ap_flat", -205, nil, 2, 0},
	},
	[24932] = {
			{"raw", "phys_crit", 0.03, nil, 32, 0},
	},
	[23128] = {
			{"raw", "melee_haste", 1.5, nil, 33, 0},
	},
	[437327] = {
			{"by_school", "sp_dmg_flat", 50, {1,2,3,4,5,6,7,}, 2, 1},
			{"raw", "healing_power_flat", 50, nil, 2, 2},
	},
	[370836] = {
			{"by_school", "dmg_mod", 0.01, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.01, nil, 1, 0},
	},
	[437357] = {
			{"raw", "regen_while_casting", 1, nil, 0, 0},
			{"by_school", "sp_dmg_flat", 50, {1,2,3,4,5,6,7,}, 2, 1},
			{"raw", "healing_power_flat", 50, nil, 2, 2},
	},
	[446733] = {
			{"by_school", "sp_dmg_flat", 300, {1,2,3,4,5,6,7,}, 2, 1},
			{"raw", "phys_dmg_flat", 100, nil, 0, 2},
	},
	[17213] = {
			{"by_attr", "stat_mod", -0.25, {5,}, 0, 0},
	},
	[12968] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 0},
	},
	[26198] = {
			{"by_school", "dmg_mod", 2, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 2, nil, 1, 1},
			{"raw", "melee_haste", 1, nil, 33, 2},
	},
	[7484] = {
			{"raw", "phys_dmg_flat", 35, nil, 0, 0},
	},
	[22642] = {
			{"raw", "cast_haste", -0.5, nil, 0, 1},
			{"raw", "melee_haste", -0.32999998, nil, 33, 2},
	},
	[430352] = {
			{"by_school", "dmg_mod", 0.049999997, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.049999997, nil, 1, 0},
	},
	[368388] = {
			{"by_school", "dmg_mod", 9, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 9, nil, 1, 0},
			{"raw", "melee_haste", 1.5, nil, 33, 1},
	},
	[26276] = {
			{"by_school", "sp_dmg_flat", 40, {3,}, 2, 0},
	},
	[704] = {
			{"raw", "ap_flat", 20, nil, 2, 0},
	},
	[9740] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 0},
	},
	[437362] = {
			{"raw", "cast_haste", 0.19999999, nil, 0, 0},
	},
	[28342] = {
			{"raw", "ap_flat", -1000, nil, 2, 0},
			{"raw", "rap_flat", -1000, nil, 2, 1},
	},
	[5665] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
	},
	[440720] = {
			{"raw", "melee_haste", -1, nil, 33, 3},
	},
	[15716] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
			{"raw", "melee_haste", 0.29999998, nil, 33, 1},
	},
	[7656] = {
			{"raw", "phys_dmg_flat", -8, nil, 0, 0},
			{"by_school", "sp_dmg_flat", -13, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[13874] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
	},
	[437716] = {
			{"raw", "phys_crit", 1, nil, 32, 0},
	},
	[16278] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 0},
	},
	[26259] = {
			{"by_school", "dmg_mod", 2, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 2, nil, 1, 1},
			{"raw", "melee_haste", 1, nil, 33, 2},
	},
	[16050] = {
			{"raw", "melee_haste", -0.25, nil, 33, 0},
	},
	[9035] = {
			{"raw", "phys_dmg_flat", -2, nil, 0, 0},
	},
	[431111] = {
			{"by_school", "spell_hit", 0.03, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "ap_flat", 20, nil, 2, 1},
			{"raw", "phys_crit", 0.02, nil, 32, 2},
			{"raw", "rap_flat", 20, nil, 2, 3},
			{"by_school", "sp_dmg_flat", 25, {1,2,3,4,5,6,7,}, 2, 5},
	},
	[446336] = {
			{"raw", "rap_flat", 48, nil, 2, 0},
			{"raw", "ap_flat", 48, nil, 2, 1},
	},
	[474148] = {
			{"by_school", "sp_dmg_flat", 15, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[25898] = {
			{"by_attr", "stat_mod", 0.099999994, {1,2,3,4,5,}, 0, 0},
	},
	[28371] = {
			{"raw", "melee_haste", 1, nil, 33, 0},
			{"by_school", "dmg_mod", 0.5, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 0.5, nil, 1, 1},
	},
	[1784] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 0},
	},
	[11717] = {
			{"raw", "ap_flat", 90, nil, 2, 0},
	},
	[26068] = {
			{"raw", "melee_haste", 2, nil, 33, 0},
	},
	[446597] = {
			{"by_school", "sp_dmg_flat", 50, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[24974] = {
			{"raw", "phys_hit", -0.02, nil, 2, 1},
	},
	[422978] = {
			{"by_school", "dmg_mod", -0.19999999, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", -0.19999999, nil, 1, 1},
	},
	[4948] = {
			{"applies_aura", "shapeshift_passives", 0, {21178,}, 16, 0},
	},
	[409580] = {
			{"by_attr", "stat_mod", 0.099999994, {1,2,3,4,5,}, 0, 0},
	},
	[446231] = {
			{"raw", "ap_flat", 150, nil, 2, 0},
			{"raw", "rap_flat", 150, nil, 2, 1},
	},
	[23234] = {
			{"raw", "ap_flat", 0, nil, 2, 0},
	},
	[470361] = {
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[7481] = {
			{"raw", "phys_dmg_flat", 10, nil, 0, 0},
	},
	[28131] = {
			{"by_school", "dmg_mod", 0.25, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.25, nil, 1, 0},
			{"raw", "melee_haste", 0.39999998, nil, 33, 1},
	},
	[1220684] = {
			{"by_school", "sp_dmg_flat", 80, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[1038] = {
			{"by_school", "threat", -0.29999998, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[24597] = {
			{"raw", "phys_dmg_flat", 45, nil, 0, 0},
	},
	[457851] = {
			{"by_school", "dmg_mod", 0.19999999, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 0.19999999, nil, 1, 1},
	},
	[7072] = {
			{"raw", "phys_dmg_flat", 25, nil, 0, 0},
	},
	[22909] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
			{"raw", "cast_haste", -0.5, nil, 0, 2},
	},
	[460703] = {
			{"raw", "melee_haste", 2, nil, 33, 0},
	},
	[24858] = {
			{"applies_aura", "shapeshift_passives", 0, {443359,}, 16, 0},
			{"by_school", "threat", 0, {4,7,}, 0, 3},
	},
	[13533] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[438537] = {
			{"by_school", "crit", 0.04, {1,}, 2, 0},
			{"by_school", "sp_dmg_flat", 42, {1,2,3,4,5,6,7,}, 2, 1},
			{"raw", "healing_power_flat", 42, nil, 2, 2},
			{"raw", "melee_haste", 0.099999994, nil, 33, 3},
			{"raw", "ranged_haste", 0.099999994, nil, 33, 4},
	},
	[1220543] = {
			{"by_school", "sp_dmg_flat", 80, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 80, nil, 2, 1},
	},
	[449934] = {
			{"by_school", "sp_dmg_flat", 60, {4,}, 2, 0},
			{"raw", "healing_power_flat", 60, nil, 2, 1},
	},
	[12967] = {
			{"raw", "melee_haste", 0.14999999, nil, 33, 0},
	},
	[1098] = {
			{"raw", "melee_haste", -0.39999998, nil, 33, 1},
			{"raw", "cast_haste", -0.29999998, nil, 0, 2},
	},
	[29534] = {
			{"by_school", "dmg_mod", 0.049999997, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 0.049999997, nil, 1, 1},
	},
	[11474] = {
			{"by_school", "sp_dmg_flat", 40, {6,}, 2, 0},
	},
	[22640] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[25516] = {
			{"raw", "melee_haste", 0.099999994, nil, 33, 1},
			{"raw", "cast_haste", 0.11, nil, 0, 2},
	},
	[431060] = {
			{"raw", "cast_haste", 1000, nil, 0, 1},
	},
	[18546] = {
			{"raw", "melee_haste", 1, nil, 33, 1},
	},
	[19812] = {
			{"raw", "melee_haste", 1, nil, 33, 0},
	},
	[28144] = {
			{"raw", "healing_power_flat", 62, nil, 2, 0},
	},
	[473441] = {
			{"raw", "melee_haste", 0.14999999, nil, 33, 1},
	},
	[1214101] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[18163] = {
			{"raw", "phys_mod", 0.29999998, nil, 1, 0},
	},
	[1218587] = {
			{"creature", "dmg_mod", 0.01, {32,}, 1, 0},
	},
	[23153] = {
			{"raw", "cast_haste", -0.5, nil, 0, 1},
			{"raw", "cast_haste", -0.5, nil, 0, 1},
	},
	[15473] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 0},
			{"by_school", "dmg_mod", 0.14999999, {6,}, 1, 1},
	},
	[19451] = {
			{"raw", "melee_haste", 1.5, nil, 33, 0},
	},
	[408755] = {
			{"by_school", "dmg_mod", -0.5, {1,2,3,4,5,6,7,}, 1, 3},
			{"raw", "phys_mod", -0.5, nil, 1, 3},
	},
	[473482] = {
			{"by_school", "dmg_mod", -0.19999999, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", -0.19999999, nil, 1, 0},
	},
	[440483] = {
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[13004] = {
			{"raw", "ap_flat", 250, nil, 2, 0},
	},
	[412325] = {
			{"raw", "regen_while_casting", 0.099999994, nil, 0, 0},
	},
	[3385] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 1},
	},
	[25816] = {
			{"raw", "phys_dmg_flat", -20, nil, 0, 0},
	},
	[13168] = {
			{"raw", "phys_dmg_flat", 100, nil, 0, 0},
			{"raw", "melee_haste", 1, nil, 33, 1},
	},
	[24185] = {
			{"raw", "melee_haste", 0.75, nil, 33, 0},
	},
	[29334] = {
			{"raw", "healing_power_flat", 44, nil, 2, 0},
	},
	[25895] = {
			{"by_school", "threat", -0.29999998, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[24003] = {
			{"raw", "melee_haste", -1.5, nil, 33, 0},
	},
	[467522] = {
			{"raw", "cast_haste", 0.32999998, nil, 0, 0},
			{"raw", "melee_haste", 0.25, nil, 33, 1},
	},
	[22479] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
	},
	[24976] = {
			{"raw", "phys_hit", -0.02, nil, 2, 1},
	},
	[3229] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[23964] = {
			{"raw", "phys_crit", 0.099999994, nil, 32, 0},
			{"by_school", "crit", 0.099999994, {2,}, 2, 1},
	},
	[9128] = {
			{"raw", "ap_flat", 4, nil, 2, 0},
	},
	[24452] = {
			{"raw", "phys_mod", 0.35, nil, 1, 2},
	},
	[24378] = {
			{"by_school", "dmg_mod", 0.29999998, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.29999998, nil, 1, 0},
	},
	[474236] = {
			{"raw", "cast_haste", 1000, nil, 0, 0},
	},
	[473469] = {
			{"raw", "ap_flat", 35, nil, 2, 0},
	},
	[446709] = {
			{"raw", "ap_flat", 70, nil, 2, 0},
			{"raw", "rap_flat", 70, nil, 2, 1},
	},
	[17401] = {
			{"raw", "melee_haste", -0.25, nil, 33, 1},
	},
	[465414] = {
			{"raw", "phys_dmg_flat", 15, nil, 0, 0},
			{"raw", "melee_haste", 0.29999998, nil, 33, 1},
	},
	[370832] = {
			{"raw", "cast_haste", 0.14999999, nil, 0, 0},
			{"raw", "melee_haste", 0.14999999, nil, 33, 1},
			{"raw", "ranged_haste", 0.14999999, nil, 33, 2},
	},
	[3510] = {
			{"raw", "melee_haste", -0.66999996, nil, 33, 0},
	},
	[437349] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 0},
			{"raw", "ranged_haste", 0.19999999, nil, 33, 1},
	},
	[1020] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
			{"by_school", "dmg_mod", -0.5, {1,2,3,4,5,6,7,}, 1, 3},
			{"raw", "phys_mod", -0.5, nil, 1, 3},
	},
	[456339] = {
			{"by_school", "threat", 1, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[28793] = {
			{"by_school", "sp_dmg_flat", 80, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[25780] = {
			{"by_school", "threat", 0.59999996, {2,}, 0, 0},
	},
	[26064] = {
			{"raw", "melee_haste", -0.42999998, nil, 33, 1},
	},
	[14324] = {
			{"raw", "ap_flat", 75, nil, 0, 1},
	},
	[9736] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 0},
	},
	[23260] = {
			{"by_school", "dmg_mod", -3.25, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", -3.25, nil, 1, 0},
	},
	[437377] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 0},
	},
	[28134] = {
			{"raw", "melee_haste", 2, nil, 33, 0},
	},
	[25656] = {
			{"raw", "phys_hit", -0.75, nil, 2, 1},
	},
	[462238] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
	},
	[7321] = {
			{"raw", "melee_haste", -0.25, nil, 33, 1},
	},
	[23733] = {
			{"raw", "cast_haste", 0.32999998, nil, 0, 0},
			{"raw", "melee_haste", 0.25, nil, 33, 1},
	},
	[12888] = {
			{"raw", "melee_haste", 0.5, nil, 33, 1},
	},
	[20717] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
	},
	[1219370] = {
			{"creature", "dmg_mod", 0.01, {32,}, 1, 0},
	},
	[17331] = {
			{"raw", "cast_haste", -0.099999994, nil, 0, 0},
			{"raw", "melee_haste", -0.11, nil, 33, 1},
			{"raw", "ranged_haste", -0.11, nil, 33, 2},
	},
	[1219072] = {
			{"raw", "heal_mod", 0.099999994, nil, 1, 1},
	},
	[460060] = {
			{"by_school", "dmg_mod", 0, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 0, nil, 1, 1},
	},
	[3151] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[15288] = {
			{"by_school", "sp_dmg_flat", 25, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[5514] = {
			{"raw", "phys_hit", -0.25, nil, 2, 0},
	},
	[22783] = {
			{"raw", "regen_while_casting", 0.29999998, nil, 0, 1},
	},
	[443320] = {
			{"raw", "phys_mod", 0.049999997, nil, 1, 0},
			{"by_school", "threat", -0.29999998, {1,2,3,4,5,6,7,}, 0, 1},
			{"by_school", "dmg_mod", 0, {3,4,5,}, 1, 2},
	},
	[427714] = {
			{"raw", "cast_haste", 0.29999998, nil, 0, 0},
	},
	[15494] = {
			{"raw", "extra_hits_flat", 2, nil, 0, 1},
	},
	[446695] = {
			{"by_school", "sp_dmg_flat", 65, {1,2,3,4,5,6,7,}, 2, 1},
			{"by_attr", "stat_mod", 0.08, {1,2,3,4,5,}, 0, 2},
	},
	[29660] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[439472] = {
			{"raw", "melee_haste", -0.19999999, nil, 33, 0},
	},
	[19837] = {
			{"raw", "ap_flat", 115, nil, 2, 0},
	},
	[446618] = {
			{"raw", "ap_flat", 60, nil, 2, 0},
			{"raw", "rap_flat", 60, nil, 2, 1},
	},
	[30297] = {
			{"raw", "phys_crit", -0.049999997, nil, 32, 0},
	},
	[446630] = {
			{"raw", "ap_flat", 40, nil, 2, 0},
	},
	[454042] = {
			{"by_school", "sp_dmg_flat", 2, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[3019] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
	},
	[28498] = {
			{"by_school", "dmg_mod", 5, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 5, nil, 1, 0},
	},
	[418510] = {
			{"raw", "phys_dmg_flat", 5, nil, 0, 0},
			{"by_school", "sp_dmg_flat", 10, {1,2,3,4,5,6,7,}, 2, 1},
			{"raw", "healing_power_flat", 16, nil, 2, 2},
	},
	[425234] = {
			{"by_school", "dmg_mod", 0.14999999, {6,}, 1, 0},
	},
	[16279] = {
			{"raw", "melee_haste", 0.25, nil, 33, 0},
	},
	[775] = {
			{"applies_aura", "shapeshift_passives", 0, {439734,}, 16, 0},
	},
	[23205] = {
			{"raw", "rap_flat", -1500, nil, 2, 0},
	},
	[412735] = {
			{"by_school", "sp_dmg_flat", 0, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 0, nil, 2, 1},
	},
	[14744] = {
			{"by_school", "sp_dmg_flat", 30, {1,3,}, 2, 0},
	},
	[449932] = {
			{"raw", "ap_flat", 5, nil, 2, 0},
	},
	[20305] = {
			{"raw", "ap_flat", 94, nil, 2, 0},
	},
	[6136] = {
			{"raw", "melee_haste", -0.25, nil, 33, 1},
	},
	[3673] = {
			{"raw", "phys_dmg_flat", -40, nil, 0, 0},
	},
	[474126] = {
			{"by_school", "sp_dmg_flat", 40, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[7127] = {
			{"raw", "melee_haste", -0.25, nil, 33, 0},
			{"raw", "cast_haste", -0.19999999, nil, 0, 2},
	},
	[25462] = {
			{"raw", "phys_dmg_flat", 438, nil, 0, 0},
	},
	[425893] = {
			{"raw", "phys_crit", 0.5, nil, 32, 1},
	},
	[14203] = {
			{"raw", "phys_mod", 0.19999999, nil, 1, 0},
	},
	[24450] = {
			{"raw", "phys_mod", 0.19999999, nil, 1, 2},
	},
	[428728] = {
			{"raw", "melee_haste", 0.06, nil, 33, 0},
	},
	[19740] = {
			{"raw", "ap_flat", 20, nil, 2, 0},
	},
	[23505] = {
			{"by_school", "dmg_mod", 0.29999998, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.29999998, nil, 1, 0},
	},
	[355365] = {
			{"by_attr", "stat_mod", 0.14999999, {1,2,3,4,5,}, 0, 2},
	},
	[461270] = {
			{"raw", "melee_haste", 0.099999994, nil, 33, 0},
	},
	[28798] = {
			{"raw", "phys_mod", 1.5, nil, 1, 0},
			{"raw", "melee_haste", 0.75, nil, 33, 1},
	},
	[1213886] = {
			{"raw", "healing_power_flat", 80, nil, 2, 0},
			{"by_school", "sp_dmg_flat", 27, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[469144] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[30880] = {
			{"creature", "dmg_mod", 0.01, {32,}, 1, 0},
	},
	[9845] = {
			{"raw", "phys_dmg_flat", 30, nil, 0, 0},
	},
	[469210] = {
			{"raw", "healing_power_flat", 31, nil, 2, 0},
	},
	[783] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 0},
	},
	[10651] = {
			{"raw", "phys_dmg_flat", -8, nil, 0, 0},
			{"raw", "cast_haste", -0.19999999, nil, 0, 1},
	},
	[26099] = {
			{"raw", "phys_mod", 1, nil, 1, 0},
			{"raw", "melee_haste", 0.19999999, nil, 33, 1},
	},
	[463864] = {
			{"by_school", "sp_dmg_flat", 30, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "ap_flat", 30, nil, 2, 1},
			{"raw", "healing_power_flat", 30, nil, 2, 2},
			{"raw", "rap_flat", 30, nil, 2, 3},
	},
	[22888] = {
			{"by_school", "crit", 0.099999994, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "ap_flat", 140, nil, 2, 1},
			{"raw", "phys_crit", 0.049999997, nil, 32, 2},
			{"raw", "rap_flat", 140, nil, 2, 3},
	},
	[24907] = {
			{"by_school", "crit", 0.03, {4,}, 2, 0},
	},
	[14872] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
			{"raw", "phys_dmg_flat", 50, nil, 0, 1},
	},
	[452745] = {
			{"raw", "phys_hit", -0.02, nil, 2, 0},
	},
	[13010] = {
			{"raw", "ap_flat", -250, nil, 2, 0},
	},
	[17538] = {
			{"raw", "phys_crit", 0.02, nil, 32, 1},
	},
	[28826] = {
			{"raw", "ap_flat", 140, nil, 2, 0},
			{"raw", "rap_flat", 140, nil, 2, 1},
	},
	[461227] = {
			{"by_school", "sp_dmg_flat", 115, {4,}, 2, 0},
	},
	[1214166] = {
			{"by_school", "dmg_mod", 0.14999999, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.14999999, nil, 1, 0},
	},
	[3672] = {
			{"raw", "phys_dmg_flat", -26, nil, 0, 0},
	},
	[429125] = {
			{"raw", "cast_haste", 0.19999999, nil, 0, 0},
	},
	[447591] = {
			{"raw", "phys_mod", 1, nil, 1, 0},
	},
	[456399] = {
			{"by_school", "dmg_mod", 0.01, {1,2,3,4,5,6,7,}, 1, 0},
	},
	[19135] = {
			{"raw", "phys_mod", 0.5, nil, 1, 0},
	},
	[19030] = {
			{"applies_aura", "shapeshift_passives", 0, {21178,}, 16, 0},
	},
	[8260] = {
			{"raw", "phys_dmg_flat", 10, nil, 0, 1},
	},
	[16170] = {
			{"raw", "melee_haste", 0.59999996, nil, 33, 0},
	},
	[1218701] = {
			{"by_school", "dmg_mod", 0.049999997, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.049999997, nil, 1, 0},
	},
	[27650] = {
			{"raw", "phys_mod", 1, nil, 1, 0},
			{"by_school", "dmg_mod", 0.5, {1,2,3,4,5,6,7,}, 1, 2},
	},
	[408261] = {
			{"raw", "regen_while_casting", 0.5, nil, 0, 0},
	},
	[25907] = {
			{"by_school", "sp_dmg_flat", 132, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[365122] = {
			{"by_school", "dmg_mod", 5, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 5, nil, 1, 0},
			{"raw", "melee_haste", 1.5, nil, 33, 1},
	},
	[19479] = {
			{"raw", "ap_flat", -17, nil, 2, 0},
	},
	[469208] = {
			{"raw", "phys_crit", 0.01, nil, 32, 0},
			{"by_school", "crit", 0.01, {2,3,4,5,6,7,}, 2, 1},
	},
	[429688] = {
			{"raw", "melee_haste", -1, nil, 33, 1},
	},
	[11549] = {
			{"raw", "ap_flat", 85, nil, 2, 0},
	},
	[6922] = {
			{"raw", "phys_dmg_flat", -3, nil, 0, 1},
			{"by_school", "sp_dmg_flat", -10, {1,2,3,4,5,6,7,}, 2, 2},
	},
	[449923] = {
			{"raw", "healing_power_flat", 60, nil, 2, 0},
			{"by_school", "sp_dmg_flat", 60, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[10348] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
			{"raw", "cast_haste", 1, nil, 0, 1},
	},
	[19252] = {
			{"raw", "phys_dmg_flat", -11, nil, 0, 1},
	},
	[24425] = {
			{"by_attr", "stat_mod", 0.14999999, {1,2,3,4,5,}, 0, 2},
	},
	[1222564] = {
			{"raw", "melee_haste", 1, nil, 33, 0},
	},
	[11551] = {
			{"raw", "ap_flat", 185, nil, 2, 0},
	},
	[15007] = {
			{"by_school", "dmg_mod", -0.75, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", -0.75, nil, 1, 1},
	},
	[468466] = {
			{"raw", "regen_while_casting", 1, nil, 0, 1},
	},
	[20050] = {
			{"raw", "phys_mod", 0.03, nil, 1, 0},
			{"by_school", "dmg_mod", 0.03, {2,}, 1, 1},
	},
	[460171] = {
			{"raw", "ap_flat", 4, nil, 2, 0},
			{"raw", "rap_flat", 4, nil, 2, 1},
	},
	[2943] = {
			{"raw", "phys_dmg_flat", -2, nil, 0, 1},
	},
	[403816] = {
			{"by_school", "threat", 0.77, {1,2,3,4,5,6,7,}, 0, 2},
			{"by_school", "dmg_mod", -0.14999999, {1,2,3,4,5,6,7,}, 1, 4},
			{"raw", "phys_mod", -0.14999999, nil, 1, 4},
	},
	[460200] = {
			{"by_school", "sp_dmg_flat", 2, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[1214233] = {
			{"by_school", "sp_dmg_flat", 150, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[16629] = {
			{"by_school", "dmg_mod", -0.25, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", -0.25, nil, 1, 0},
	},
	[456361] = {
			{"creature", "dmg_mod", 0.03, {64,}, 1, 0},
	},
	[29520] = {
			{"creature", "dmg_mod", 0.049999997, {32,}, 1, 0},
	},
	[469261] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 0.099999994, nil, 1, 1},
			{"raw", "cast_haste", 1, nil, 0, 3},
	},
	[408024] = {
			{"raw", "heal_mod", 0.19999999, nil, 1, 0},
	},
	[16597] = {
			{"raw", "melee_haste", -0.25, nil, 33, 1},
	},
	[429867] = {
			{"raw", "melee_haste", 0.099999994, nil, 33, 0},
			{"raw", "ranged_haste", 0.099999994, nil, 33, 1},
			{"by_school", "threat", 0.19999999, {1,2,3,4,5,6,7,}, 0, 2},
	},
	[439733] = {
			{"applies_aura", "shapeshift_passives", 0, {439734,}, 16, 0},
	},
	[456348] = {
			{"creature", "dmg_mod", 0.03, {2,}, 1, 0},
	},
	[16609] = {
			{"raw", "melee_haste", 0.14999999, nil, 33, 1},
	},
	[18101] = {
			{"raw", "melee_haste", -1, nil, 33, 0},
	},
	[24327] = {
			{"raw", "melee_haste", 1, nil, 33, 1},
	},
	[1219558] = {
			{"by_school", "crit", 0.02, {7,}, 2, 0},
	},
	[13847] = {
			{"raw", "phys_crit", 1, nil, 32, 0},
	},
	[8599] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
			{"raw", "melee_haste", 0.29999998, nil, 33, 1},
	},
	[16592] = {
			{"by_school", "dmg_mod", 0.19999999, {6,}, 1, 1},
	},
	[425098] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[25164] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[26331] = {
			{"raw", "melee_haste", 1, nil, 33, 0},
	},
	[1219375] = {
			{"creature", "dmg_mod", 0.01, {32,}, 1, 0},
	},
	[467414] = {
			{"by_school", "sp_dmg_flat", 50, {3,}, 2, 0},
	},
	[12493] = {
			{"raw", "phys_dmg_flat", -1, nil, 0, 0},
	},
	[11719] = {
			{"raw", "cast_haste", -0.59999996, nil, 0, 0},
	},
	[1216566] = {
			{"by_school", "dmg_mod", 0.049999997, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 0.049999997, nil, 1, 1},
	},
	[8191] = {
			{"raw", "phys_dmg_flat", 10, nil, 0, 0},
	},
	[11550] = {
			{"raw", "ap_flat", 130, nil, 2, 0},
	},
	[23574] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[446572] = {
			{"by_school", "sp_dmg_flat", 30, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[5487] = {
			{"applies_aura", "shapeshift_passives", 0, {21178,}, 16, 0},
	},
	[22559] = {
			{"raw", "melee_haste", -1, nil, 33, 0},
	},
	[462230] = {
			{"raw", "ap_flat", 4, nil, 2, 0},
			{"raw", "rap_flat", 4, nil, 2, 1},
	},
	[14325] = {
			{"raw", "ap_flat", 110, nil, 0, 1},
	},
	[19506] = {
			{"raw", "rap_flat", 50, nil, 2, 0},
			{"raw", "ap_flat", 50, nil, 2, 1},
			{"raw", "rap_flat", 100, nil, 2, 2},
	},
	[10912] = {
			{"raw", "melee_haste", -0.25, nil, 33, 2},
	},
	[446240] = {
			{"by_school", "sp_dmg_flat", 30, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "ap_flat", 30, nil, 2, 1},
			{"raw", "healing_power_flat", 30, nil, 2, 2},
			{"raw", "rap_flat", 30, nil, 2, 3},
	},
	[13003] = {
			{"raw", "ap_flat", -250, nil, 2, 0},
	},
	[402368] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
	},
	[19615] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[468408] = {
			{"raw", "melee_haste", 0.75, nil, 33, 0},
	},
	[16461] = {
			{"by_attr", "stat_mod", -0.14999999, {3,}, 0, 0},
	},
	[5217] = {
			{"raw", "phys_dmg_flat", 10, nil, 0, 0},
	},
	[20054] = {
			{"raw", "phys_mod", 0.12, nil, 1, 0},
			{"by_school", "dmg_mod", 0.12, {2,}, 1, 1},
	},
	[22917] = {
			{"by_school", "dmg_mod", 0.39999998, {6,}, 1, 1},
	},
	[21082] = {
			{"raw", "ap_flat", 31, nil, 2, 0},
	},
	[408696] = {
			{"by_school", "threat", 0.45, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[1785] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 0},
	},
	[370520] = {
			{"by_school", "dmg_mod", 0, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0, nil, 1, 0},
	},
	[415233] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 0},
	},
	[28825] = {
			{"by_school", "sp_dmg_flat", 80, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[23951] = {
			{"raw", "melee_haste", 0.59999996, nil, 33, 0},
	},
	[15602] = {
			{"raw", "ap_flat", 50, nil, 2, 0},
			{"raw", "rap_flat", 50, nil, 2, 1},
	},
	[468164] = {
			{"by_school", "spell_hit", 0.099999994, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "phys_hit", 0.099999994, nil, 2, 1},
	},
	[23576] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[19249] = {
			{"raw", "phys_dmg_flat", -4, nil, 0, 1},
	},
	[448779] = {
			{"by_school", "sp_dmg_flat", 230, {1,2,3,4,5,6,7,}, 2, 1},
			{"raw", "phys_dmg_flat", 230, nil, 0, 1},
	},
	[456403] = {
			{"by_school", "sp_dmg_flat", 18, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "phys_dmg_flat", 18, nil, 0, 0},
			{"raw", "healing_power_flat", 18, nil, 2, 1},
	},
	[22742] = {
			{"raw", "ap_flat", -250, nil, 2, 0},
	},
	[467523] = {
			{"by_school", "dmg_mod", 0.19999999, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "heal_mod", 0.19999999, nil, 1, 1},
	},
	[17246] = {
			{"by_school", "dmg_mod", 1, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 1, nil, 1, 0},
	},
	[467049] = {
			{"by_school", "dmg_mod", 1, {1,2,3,4,5,6,7,}, 1, 2},
			{"raw", "phys_mod", 1, nil, 1, 2},
	},
	[5915] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 0},
	},
	[425124] = {
			{"raw", "regen_while_casting", 1, nil, 0, 2},
	},
	[5570] = {
			{"raw", "phys_hit", -0.02, nil, 2, 1},
	},
	[24109] = {
			{"raw", "phys_mod", 0.5, nil, 1, 0},
	},
	[26197] = {
			{"by_school", "dmg_mod", 2, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 2, nil, 1, 1},
			{"raw", "melee_haste", 1, nil, 33, 2},
	},
	[25773] = {
			{"by_school", "dmg_mod", 5, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 5, nil, 1, 0},
			{"raw", "melee_haste", 1, nil, 33, 1},
			{"raw", "cast_haste", 3, nil, 0, 2},
	},
	[9846] = {
			{"raw", "phys_dmg_flat", 40, nil, 0, 0},
	},
	[12731] = {
			{"raw", "phys_dmg_flat", 10, nil, 0, 0},
	},
	[17150] = {
			{"by_school", "sp_dmg_flat", 50, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[3547] = {
			{"raw", "melee_haste", 1, nil, 33, 0},
			{"raw", "phys_dmg_flat", -10, nil, 0, 2},
	},
	[20553] = {
			{"raw", "phys_dmg_flat", 500, nil, 0, 0},
			{"raw", "melee_haste", 0.5, nil, 33, 1},
			{"raw", "phys_dmg_flat", 500, nil, 0, 0},
			{"raw", "melee_haste", 0.5, nil, 33, 1},
	},
	[29333] = {
			{"by_school", "sp_dmg_flat", 23, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[448084] = {
			{"by_school", "sp_dmg_flat", 30, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 45, nil, 2, 2},
	},
	[17639] = {
			{"raw", "phys_hit", -0.099999994, nil, 2, 0},
	},
	[26079] = {
			{"raw", "melee_haste", 0.5, nil, 33, 1},
	},
	[1213939] = {
			{"by_school", "threat", 0.19999999, {}, 0, 1},
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 2},
			{"raw", "phys_mod", 0.099999994, nil, 1, 2},
	},
	[467530] = {
			{"by_school", "dmg_mod", 0.01, {2,}, 1, 0},
	},
	[409583] = {
			{"by_attr", "stat_mod", 0.099999994, {1,2,3,4,5,}, 0, 0},
			{"raw", "ap_flat", 40, nil, 2, 1},
			{"raw", "rap_flat", 40, nil, 2, 2},
	},
	[9459] = {
			{"raw", "phys_dmg_flat", -10, nil, 0, 0},
	},
	[24998] = {
			{"raw", "healing_power_flat", 350, nil, 2, 0},
	},
	[14321] = {
			{"raw", "rap_flat", 90, nil, 2, 0},
	},
	[19591] = {
			{"raw", "phys_crit", 0, nil, 32, 0},
			{"by_school", "crit", 0, {1,}, 2, 1},
	},
	[8269] = {
			{"raw", "phys_dmg_flat", 50, nil, 0, 0},
			{"raw", "melee_haste", 0.59999996, nil, 33, 1},
	},
	[1213334] = {
			{"by_school", "dmg_mod", 0.19999999, {6,}, 1, 1},
	},
	[8041] = {
			{"raw", "phys_dmg_flat", 25, nil, 0, 2},
	},
	[20162] = {
			{"raw", "ap_flat", 51, nil, 2, 0},
	},
	[27543] = {
			{"applies_aura", "shapeshift_passives", 0, {21178,}, 16, 0},
	},
	[28777] = {
			{"raw", "ap_flat", 260, nil, 2, 0},
			{"raw", "rap_flat", 260, nil, 2, 1},
	},
	[26041] = {
			{"raw", "melee_haste", 1.5, nil, 33, 0},
	},
	[28681] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[3258] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[469225] = {
			{"by_school", "dmg_mod", 0.14999999, {6,}, 1, 0},
	},
	[11725] = {
			{"raw", "melee_haste", -0.39999998, nil, 33, 1},
			{"raw", "cast_haste", -0.29999998, nil, 0, 2},
	},
	[14322] = {
			{"raw", "rap_flat", 110, nil, 2, 0},
	},
	[7090] = {
			{"applies_aura", "shapeshift_passives", 0, {21178,}, 16, 0},
	},
	[19838] = {
			{"raw", "ap_flat", 155, nil, 2, 0},
	},
	[21614] = {
			{"raw", "healing_power_flat", 14, nil, 2, 0},
	},
	[14318] = {
			{"raw", "rap_flat", 35, nil, 2, 0},
	},
	[16555] = {
			{"by_attr", "stat_mod", -0.14999999, {2,}, 0, 1},
	},
	[402794] = {
			{"raw", "cast_haste", -0.59999996, nil, 0, 0},
	},
	[24354] = {
			{"raw", "healing_power_flat", 190, nil, 2, 0},
	},
	[28732] = {
			{"raw", "cast_haste", -0.25, nil, 0, 0},
	},
	[446396] = {
			{"raw", "healing_power_flat", 45, nil, 2, 0},
	},
	[3631] = {
			{"raw", "melee_haste", 0.25, nil, 33, 0},
	},
	[402906] = {
			{"raw", "phys_mod", 0.25, nil, 1, 0},
	},
	[10060] = {
			{"raw", "heal_mod", 0.19999999, nil, 1, 0},
			{"by_school", "dmg_mod", 0.19999999, {1,2,3,4,5,6,7,}, 1, 1},
	},
	[21049] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[20055] = {
			{"raw", "phys_mod", 0.14999999, nil, 1, 0},
			{"by_school", "dmg_mod", 0.14999999, {2,}, 1, 1},
	},
	[1213408] = {
			{"by_attr", "stat_mod", 0.099999994, {1,2,3,4,5,}, 0, 0},
	},
	[24352] = {
			{"raw", "ap_flat", 150, nil, 2, 0},
			{"raw", "phys_hit", 0.02, nil, 2, 1},
			{"raw", "rap_flat", 150, nil, 2, 2},
	},
	[24865] = {
			{"raw", "phys_crit", 0.03, nil, 32, 0},
			{"by_school", "crit", 0.03, {2,}, 2, 1},
	},
	[17687] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[17494] = {
			{"raw", "ap_flat", -50, nil, 2, 0},
			{"raw", "rap_flat", -50, nil, 2, 2},
	},
	[456195] = {
			{"raw", "regen_while_casting", 1, nil, 0, 0},
	},
	[11413] = {
			{"creature", "dmg_mod", 0.01, {32,}, 1, 0},
	},
	[19653] = {
			{"raw", "ap_flat", -32, nil, 2, 0},
	},
	[426311] = {
			{"by_school", "dmg_mod", 0.099999994, {3,6,}, 1, 0},
	},
	[28866] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 0},
			{"raw", "ranged_haste", 0.19999999, nil, 33, 1},
	},
	[22371] = {
			{"by_school", "sp_dmg_flat", -1, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[3269] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[25289] = {
			{"raw", "ap_flat", 232, nil, 2, 0},
	},
	[408307] = {
			{"raw", "healing_power_flat", 0, nil, 2, 0},
	},
	[1786] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 0},
	},
	[5171] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 1},
	},
	[18381] = {
			{"raw", "ap_flat", -15, nil, 2, 0},
			{"raw", "rap_flat", -15, nil, 2, 1},
	},
	[446091] = {
			{"by_school", "dmg_mod", -0.98999995, {1,2,3,4,5,6,7,}, 1, 2},
			{"raw", "phys_mod", -0.98999995, nil, 1, 2},
			{"raw", "heal_mod", -0.98999995, nil, 1, 3},
	},
	[6921] = {
			{"raw", "phys_dmg_flat", 10, nil, 0, 1},
	},
	[428489] = {
			{"by_school", "dmg_mod", -0.29999998, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", -0.29999998, nil, 1, 1},
	},
	[10370] = {
			{"raw", "phys_dmg_flat", 5, nil, 0, 0},
	},
	[16927] = {
			{"raw", "melee_haste", -0.25, nil, 33, 0},
	},
	[6507] = {
			{"raw", "phys_dmg_flat", 5, nil, 0, 0},
	},
	[1215755] = {
			{"raw", "melee_haste", 1.5, nil, 33, 0},
	},
	[407805] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
			{"raw", "heal_mod", 0.099999994, nil, 1, 1},
	},
	[473403] = {
			{"raw", "ap_flat", 200, nil, 2, 0},
			{"raw", "rap_flat", 200, nil, 2, 1},
			{"by_attr", "stat_mod", 0.14999999, {3,}, 0, 2},
			{"by_school", "crit", 0.03, {4,}, 2, 3},
	},
	[24610] = {
			{"by_school", "spell_hit", 0.099999994, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[6434] = {
			{"raw", "melee_haste", 0.29999998, nil, 33, 0},
	},
	[24977] = {
			{"raw", "phys_hit", -0.02, nil, 2, 1},
	},
	[20906] = {
			{"raw", "rap_flat", 100, nil, 2, 0},
			{"raw", "ap_flat", 100, nil, 2, 1},
			{"raw", "rap_flat", 200, nil, 2, 2},
	},
	[22428] = {
			{"raw", "melee_haste", 1, nil, 33, 0},
	},
	[17633] = {
			{"raw", "cast_haste", 0.65999997, nil, 0, 0},
	},
	[27995] = {
			{"raw", "melee_haste", 1, nil, 33, 0},
	},
	[24604] = {
			{"raw", "phys_dmg_flat", 9, nil, 0, 0},
	},
	[25022] = {
			{"raw", "melee_haste", -0.25, nil, 33, 0},
	},
	[1220686] = {
			{"raw", "ap_flat", 140, nil, 2, 0},
			{"raw", "rap_flat", 140, nil, 2, 1},
	},
	[246] = {
			{"raw", "melee_haste", -0.35, nil, 33, 0},
	},
	[7069] = {
			{"raw", "phys_dmg_flat", 15, nil, 0, 0},
	},
	[371206] = {
			{"by_school", "dmg_mod", 2, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 2, nil, 1, 1},
			{"raw", "melee_haste", 1, nil, 33, 2},
			{"raw", "cast_haste", 1, nil, 0, 3},
			{"raw", "ranged_haste", 1, nil, 33, 4},
	},
	[403789] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 0},
	},
	[6468] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[3136] = {
			{"raw", "melee_haste", 0.32999998, nil, 33, 0},
	},
	[5337] = {
			{"raw", "melee_haste", -0.5, nil, 33, 0},
	},
	[468387] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "heal_mod", 0.099999994, nil, 1, 1},
			{"by_school", "crit", 0.099999994, {2,3,4,5,6,7,}, 2, 2},
	},
	[27675] = {
			{"by_school", "sp_dmg_flat", 100, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 190, nil, 2, 1},
	},
	[27530] = {
			{"raw", "melee_haste", -0.66999996, nil, 33, 1},
	},
	[16939] = {
			{"raw", "phys_crit", 0.04, nil, 32, 0},
	},
	[459611] = {
			{"by_attr", "stat_mod", 0.14999999, {1,2,3,4,5,}, 0, 2},
	},
	[19654] = {
			{"raw", "ap_flat", -40, nil, 2, 0},
	},
	[456360] = {
			{"creature", "dmg_mod", 0.03, {16,}, 1, 0},
	},
	[402808] = {
			{"raw", "melee_haste", -0.099999994, nil, 33, 0},
	},
	[26662] = {
			{"by_school", "dmg_mod", 5, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 5, nil, 1, 0},
			{"raw", "melee_haste", 1.5, nil, 33, 1},
	},
	[30682] = {
			{"creature", "dmg_mod", 0.03, {32,}, 1, 0},
	},
	[446219] = {
			{"by_school", "sp_dmg_flat", 10, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 10, nil, 2, 1},
			{"raw", "ap_flat", 10, nil, 2, 2},
	},
	[1218479] = {
			{"creature", "dmg_mod", 0.01, {32,}, 1, 0},
	},
	[16246] = {
			{"by_school", "dmg_mod", 0, {1,2,3,4,5,6,7,}, 1, 1},
	},
	[436074] = {
			{"raw", "melee_haste", 0.5, nil, 33, 1},
	},
	[28419] = {
			{"by_school", "dmg_mod", 0.19999999, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.19999999, nil, 1, 0},
	},
	[12966] = {
			{"raw", "melee_haste", 0.099999994, nil, 33, 0},
	},
	[23768] = {
			{"by_school", "dmg_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[10072] = {
			{"raw", "phys_dmg_flat", -60, nil, 0, 0},
	},
	[27827] = {
			{"applies_aura", "shapeshift_passives", 0, {}, 16, 2},
	},
	[1219500] = {
			{"raw", "melee_haste", 0.19999999, nil, 33, 0},
			{"raw", "ranged_haste", 0.19999999, nil, 33, 1},
	},
	[458878] = {
			{"raw", "heal_mod", 2.5, nil, 1, 5},
			{"by_school", "dmg_mod", 0.5, {1,2,3,4,5,6,7,}, 1, 7},
			{"raw", "phys_mod", 0.5, nil, 1, 7},
	},
	[22572] = {
			{"by_attr", "stat_mod", -0.35, {1,}, 0, 1},
			{"by_attr", "stat_mod", -0.35, {2,}, 0, 2},
	},
	[446528] = {
			{"raw", "cast_haste", 0.099999994, nil, 0, 0},
	},
	[459166] = {
			{"raw", "ap_flat", 1000, nil, 2, 0},
			{"raw", "rap_flat", 1000, nil, 2, 1},
	},
	[462636] = {
			{"by_school", "sp_dmg_flat", 128, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 236, nil, 2, 1},
	},
	[6146] = {
			{"raw", "melee_haste", -0.53999996, nil, 33, 0},
	},
	[458403] = {
			{"raw", "phys_hit", 0.01, nil, 2, 0},
			{"by_school", "spell_hit", 0.01, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[25810] = {
			{"raw", "cast_haste", -0.5, nil, 0, 0},
	},
	[785] = {
			{"by_school", "dmg_mod", 3, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "phys_mod", 3, nil, 1, 1},
	},
};
sc.hostile_buffs = {
	[9884] = {
			{"by_school", "target_res_flat", 240, {1,}, 0, 0},
	},
	[1490] = {
			{"by_school", "target_res_flat", -45, {3,5,}, 0, 0},
			{"by_school", "vuln_mod", 0.06, {3,5,}, 1, 1},
	},
	[17797] = {
			{"by_school", "vuln_mod", 0.12, {6,}, 1, 0},
	},
	[16857] = {
			{"by_school", "target_res_flat", -175, {1,}, 0, 0},
	},
	[20667] = {
			{"by_school", "target_res_flat", -160, {1,}, 0, 2},
	},
	[13744] = {
			{"by_school", "sp_dmg_flat", -25, {3,}, 0, 0},
	},
	[19713] = {
			{"by_school", "vuln_mod", 1, {1,2,3,4,5,6,7,}, 1, 0},
			{"by_school", "vuln_mod", 1, {1,2,3,4,5,6,7,}, 1, 0},
	},
	[8649] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[23154] = {
			{"by_school", "vuln_mod", 1, {3,}, 1, 0},
			{"by_school", "vuln_mod", 1, {3,}, 1, 0},
	},
	[438727] = {
			{"by_school", "vuln_mod", 0.5, {4,}, 1, 0},
	},
	[21670] = {
			{"by_school", "target_res_flat", -2000, {1,}, 0, 0},
	},
	[422996] = {
			{"by_school", "target_res_flat", -150, {1,}, 0, 1},
	},
	[22959] = {
			{"by_school", "vuln_mod", 0.03, {3,}, 1, 0},
	},
	[16168] = {
			{"by_school", "sp_dmg_flat", 180, {3,}, 0, 1},
	},
	[370544] = {
			{"by_school", "sp_dmg_flat", -5, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", -5, nil, 0, 0},
	},
	[445867] = {
			{"raw", "phys_dmg_flat", 5, nil, 0, 0},
	},
	[425235] = {
			{"by_school", "target_res_flat", 17000, {1,}, 0, 2},
	},
	[461343] = {
			{"by_school", "vuln_mod", 1, {1,2,3,4,5,6,7,}, 1, 0},
			{"by_school", "vuln_mod", 1, {1,2,3,4,5,6,7,}, 1, 0},
	},
	[17390] = {
			{"by_school", "target_res_flat", -285, {1,}, 0, 0},
	},
	[11198] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[17799] = {
			{"by_school", "vuln_mod", 0.16, {6,}, 1, 0},
	},
	[6950] = {
			{"by_school", "target_res_flat", -24, {1,}, 0, 0},
	},
	[402791] = {
			{"by_school", "target_res_flat", -75, {6,7,}, 0, 0},
			{"by_school", "vuln_mod", 0.099999994, {6,7,}, 1, 1},
	},
	[18151] = {
			{"by_school", "target_res_flat", -6, {4,}, 0, 0},
	},
	[10336] = {
			{"by_school", "sp_dmg_flat", 22, {2,}, 0, 1},
	},
	[7658] = {
			{"by_school", "target_res_flat", -290, {1,}, 0, 1},
	},
	[16536] = {
			{"by_school", "sp_dmg_flat", 30, {3,}, 0, 1},
	},
	[8091] = {
			{"by_school", "target_res_flat", 60, {1,}, 0, 0},
	},
	[6685] = {
			{"by_school", "target_res_flat", -580, {1,}, 0, 1},
	},
	[8643] = {
			{"by_school", "vuln_mod", 0, {1,2,3,4,5,6,7,}, 1, 2},
			{"raw", "vuln_phys", 0, nil, 1, 2},
	},
	[24673] = {
			{"raw", "phys_dmg_flat", 500, nil, 0, 0},
	},
	[17281] = {
			{"by_school", "sp_dmg_flat", 30, {2,}, 0, 1},
	},
	[3439] = {
			{"raw", "phys_dmg_flat", 5, nil, 0, 0},
	},
	[434841] = {
			{"by_school", "target_res_flat", -45, {3,5,}, 0, 0},
			{"by_school", "vuln_mod", 0.06, {3,5,}, 1, 1},
			{"by_school", "target_res_flat", -45, {6,7,}, 0, 2},
			{"by_school", "vuln_mod", 0.06, {6,7,}, 1, 3},
			{"by_school", "target_res_flat", -45, {2,4,}, 0, 4},
			{"by_school", "vuln_mod", 0.06, {2,4,}, 1, 5},
	},
	[25181] = {
			{"by_school", "vuln_mod", 1, {7,}, 1, 1},
	},
	[457612] = {
			{"by_school", "vuln_mod", 0.5, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "vuln_phys", 0.5, nil, 1, 1},
	},
	[412079] = {
			{"by_school", "vuln_mod", 0.14999999, {6,}, 1, 1},
	},
	[25794] = {
			{"by_school", "sp_dmg_flat", -5, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", -5, nil, 0, 0},
	},
	[14518] = {
			{"by_school", "sp_dmg_flat", 20, {2,}, 0, 1},
	},
	[25051] = {
			{"by_school", "target_res_flat", -1000, {1,}, 0, 0},
	},
	[28790] = {
			{"by_school", "target_res_flat", 700, {1,}, 0, 0},
	},
	[29306] = {
			{"raw", "phys_dmg_flat", 100, nil, 0, 0},
	},
	[17333] = {
			{"by_school", "target_res_flat", -100, {1,}, 0, 1},
	},
	[24339] = {
			{"raw", "phys_dmg_flat", 100, nil, 0, 1},
	},
	[12248] = {
			{"by_school", "vuln_mod", 0.5, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "vuln_phys", 0.5, nil, 1, 0},
	},
	[18946] = {
			{"by_school", "target_res_flat", 250, {1,}, 0, 0},
	},
	[8455] = {
			{"by_school", "sp_dmg_flat", 30, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[23120] = {
			{"by_school", "sp_dmg_flat", -100, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", -100, nil, 0, 0},
	},
	[25177] = {
			{"by_school", "vuln_mod", 1, {3,}, 1, 1},
	},
	[14120] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[8824] = {
			{"by_school", "sp_dmg_flat", 15, {2,}, 0, 1},
	},
	[17230] = {
			{"raw", "phys_dmg_flat", 6, nil, 0, 0},
	},
	[5232] = {
			{"by_school", "target_res_flat", 65, {1,}, 0, 0},
	},
	[15128] = {
			{"by_school", "sp_dmg_flat", 1000, {3,}, 0, 0},
	},
	[13880] = {
			{"by_school", "target_res_flat", -250, {1,}, 0, 2},
			{"by_school", "target_res_flat", -500, {1,}, 0, 2},
	},
	[7405] = {
			{"by_school", "target_res_flat", -180, {1,}, 0, 0},
	},
	[11971] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[12175] = {
			{"by_school", "target_res_flat", 240, {1,}, 0, 0},
	},
	[27857] = {
			{"raw", "phys_dmg_flat", 5, nil, 0, 0},
	},
	[24111] = {
			{"by_school", "target_res_flat", -5000, {1,}, 0, 1},
	},
	[13444] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[6873] = {
			{"by_school", "sp_dmg_flat", 50, {5,}, 0, 0},
	},
	[12245] = {
			{"raw", "phys_dmg_flat", 3, nil, 0, 0},
	},
	[408] = {
			{"by_school", "vuln_mod", 0, {1,2,3,4,5,6,7,}, 1, 2},
			{"raw", "vuln_phys", 0, nil, 1, 2},
	},
	[25796] = {
			{"by_school", "sp_dmg_flat", -25, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", -25, nil, 0, 0},
	},
	[15258] = {
			{"by_school", "vuln_mod", 0.03, {6,}, 1, 0},
	},
	[16429] = {
			{"by_school", "target_res_flat", -100, {6,}, 0, 0},
	},
	[402792] = {
			{"by_school", "target_res_flat", -75, {3,5,}, 0, 0},
			{"by_school", "vuln_mod", 0.099999994, {3,5,}, 1, 1},
	},
	[22426] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[27807] = {
			{"by_school", "target_res_flat", -25, {4,}, 0, 2},
	},
	[446586] = {
			{"by_school", "target_res_flat", 50, {2,3,4,5,6,7,}, 0, 3},
	},
	[25050] = {
			{"by_school", "sp_dmg_flat", 1000, {3,}, 0, 0},
	},
	[8094] = {
			{"by_school", "target_res_flat", 120, {1,}, 0, 0},
	},
	[18958] = {
			{"by_school", "target_res_flat", -20, {3,}, 0, 1},
	},
	[25668] = {
			{"by_school", "sp_dmg_flat", 40, {3,}, 0, 1},
	},
	[20301] = {
			{"by_school", "sp_dmg_flat", 80, {2,}, 0, 0},
	},
	[25178] = {
			{"by_school", "vuln_mod", 1, {5,}, 1, 1},
	},
	[461043] = {
			{"by_school", "target_res_flat", -250, {1,}, 0, 2},
	},
	[461113] = {
			{"by_school", "target_res_flat", 50, {3,}, 0, 0},
	},
	[1218358] = {
			{"by_school", "target_res_flat", -50, {1,}, 0, 1},
	},
	[426925] = {
			{"by_school", "vuln_mod", -0.75, {1,2,3,6,7,}, 1, 2},
	},
	[13424] = {
			{"by_school", "target_res_flat", -50, {1,}, 0, 0},
	},
	[7140] = {
			{"raw", "phys_dmg_flat", 5, nil, 0, 0},
	},
	[3427] = {
			{"raw", "phys_dmg_flat", 3, nil, 0, 0},
	},
	[16326] = {
			{"by_school", "target_res_flat", 15, {3,}, 0, 0},
	},
	[11374] = {
			{"raw", "phys_dmg_flat", 8, nil, 0, 0},
	},
	[26419] = {
			{"by_school", "sp_dmg_flat", 100, {4,}, 0, 1},
	},
	[9176] = {
			{"by_school", "target_res_flat", -50, {1,}, 0, 0},
	},
	[3263] = {
			{"by_school", "target_res_flat", -120, {1,}, 0, 1},
	},
	[16145] = {
			{"by_school", "target_res_flat", -24, {1,}, 0, 0},
	},
	[437891] = {
			{"by_school", "vuln_mod", 0.5, {2,}, 1, 1},
	},
	[3264] = {
			{"raw", "phys_dmg_flat", 5, nil, 0, 0},
	},
	[427143] = {
			{"by_school", "sp_dmg_flat", 2, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", 2, nil, 0, 0},
	},
	[18159] = {
			{"by_school", "vuln_mod", 0.14999999, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "vuln_phys", 0.14999999, nil, 1, 0},
	},
	[16871] = {
			{"by_school", "target_res_flat", -25, {2,3,4,5,6,7,}, 0, 0},
	},
	[29125] = {
			{"by_school", "vuln_mod", 50, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "vuln_phys", 50, nil, 1, 0},
	},
	[6756] = {
			{"by_school", "target_res_flat", 105, {1,}, 0, 0},
	},
	[10173] = {
			{"by_school", "sp_dmg_flat", -60, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[1220546] = {
			{"by_school", "target_res_flat", 700, {1,}, 0, 0},
	},
	[9885] = {
			{"by_school", "target_res_flat", 285, {1,}, 0, 0},
	},
	[436837] = {
			{"by_school", "vuln_mod", -0.5, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "vuln_phys", -0.5, nil, 1, 0},
	},
	[365663] = {
			{"by_school", "target_res_flat", -24, {1,}, 0, 1},
	},
	[25797] = {
			{"by_school", "sp_dmg_flat", -5, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", -5, nil, 0, 0},
	},
	[30081] = {
			{"raw", "phys_dmg_flat", 250, nil, 0, 0},
	},
	[425205] = {
			{"by_school", "vuln_mod", -0.25, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "vuln_phys", -0.25, nil, 1, 0},
	},
	[19631] = {
			{"by_school", "target_res_flat", -1000, {1,}, 0, 0},
	},
	[3436] = {
			{"raw", "phys_dmg_flat", 5, nil, 0, 0},
	},
	[17364] = {
			{"by_school", "vuln_mod", 0.19999999, {4,}, 1, 1},
	},
	[20542] = {
			{"by_school", "sp_dmg_flat", 100, {4,}, 0, 1},
	},
	[778] = {
			{"by_school", "target_res_flat", -285, {1,}, 0, 0},
	},
	[7386] = {
			{"by_school", "target_res_flat", -90, {1,}, 0, 0},
	},
	[412080] = {
			{"by_school", "vuln_mod", 0.19999999, {6,}, 1, 1},
	},
	[449920] = {
			{"by_school", "sp_dmg_flat", 50, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[28772] = {
			{"by_school", "sp_dmg_flat", 200, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[16359] = {
			{"by_school", "target_res_flat", -160, {1,}, 0, 2},
	},
	[412072] = {
			{"by_school", "vuln_mod", 0.099999994, {6,}, 1, 1},
	},
	[470280] = {
			{"by_school", "vuln_mod", 0.14999999, {6,}, 1, 1},
	},
	[19635] = {
			{"by_school", "target_res_flat", -50, {3,}, 0, 0},
	},
	[22433] = {
			{"by_school", "sp_dmg_flat", 1000, {3,}, 0, 1},
	},
	[17348] = {
			{"wpn_subclass", "phys_dmg_flat", 7, {173555}, 8, 2},
	},
	[450607] = {
			{"raw", "vuln_phys", 0.049999997, nil, 1, 0},
	},
	[474400] = {
			{"by_school", "vuln_mod", -0.9, {1,2,3,4,5,6,7,}, 1, 3},
			{"raw", "vuln_phys", -0.9, nil, 1, 3},
	},
	[15123] = {
			{"by_school", "target_res_flat", 2, {3,}, 0, 0},
	},
	[8137] = {
			{"raw", "vuln_phys", 0.099999994, nil, 1, 0},
	},
	[24752] = {
			{"by_school", "target_res_flat", 285, {1,}, 0, 0},
	},
	[17862] = {
			{"by_school", "target_res_flat", -60, {6,7,}, 0, 0},
			{"by_school", "vuln_mod", 0.08, {6,7,}, 1, 1},
	},
	[16231] = {
			{"by_school", "target_res_flat", -290, {1,}, 0, 1},
	},
	[16878] = {
			{"by_school", "target_res_flat", 384, {1,}, 0, 0},
	},
	[3247] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
	},
	[27891] = {
			{"by_school", "sp_dmg_flat", 80, {4,}, 0, 1},
	},
	[462286] = {
			{"by_school", "vuln_mod", 0.04, {3,4,5,6,7,}, 1, 0},
	},
	[25799] = {
			{"by_school", "sp_dmg_flat", -25, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", -25, nil, 0, 0},
	},
	[3387] = {
			{"raw", "phys_dmg_flat", 8, nil, 0, 0},
	},
	[448107] = {
			{"raw", "phys_dmg_flat", 5, nil, 0, 0},
	},
	[26977] = {
			{"by_school", "target_res_flat", -100, {3,}, 0, 0},
	},
	[8650] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[14539] = {
			{"by_school", "vuln_mod", 0.5, {4,}, 1, 0},
			{"by_school", "vuln_mod", 0.5, {6,}, 1, 1},
	},
	[10337] = {
			{"by_school", "sp_dmg_flat", 30, {2,}, 0, 1},
	},
	[364163] = {
			{"by_school", "target_res_flat", 240, {1,}, 0, 0},
	},
	[7120] = {
			{"by_school", "target_res_flat", 40, {1,}, 0, 0},
	},
	[25183] = {
			{"by_school", "vuln_mod", 1, {6,}, 1, 1},
	},
	[25651] = {
			{"by_school", "sp_dmg_flat", 40, {3,}, 0, 1},
	},
	[460402] = {
			{"by_school", "vuln_mod", 0.25, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "vuln_phys", 0.25, nil, 1, 1},
	},
	[21992] = {
			{"by_school", "target_res_flat", -25, {4,}, 0, 0},
	},
	[15042] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
	},
	[469548] = {
			{"by_school", "sp_dmg_flat", 380, {4,}, 0, 1},
	},
	[25798] = {
			{"by_school", "sp_dmg_flat", -15, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", -15, nil, 0, 0},
	},
	[17937] = {
			{"by_school", "target_res_flat", -75, {6,7,}, 0, 0},
			{"by_school", "vuln_mod", 0.099999994, {6,7,}, 1, 1},
	},
	[19397] = {
			{"by_school", "sp_dmg_flat", 25, {3,}, 0, 0},
	},
	[23397] = {
			{"by_school", "vuln_mod", 0.29999998, {1,2,3,4,5,6,7,}, 1, 2},
			{"raw", "vuln_phys", 0.29999998, nil, 1, 2},
	},
	[13526] = {
			{"by_school", "target_res_flat", -50, {1,}, 0, 1},
	},
	[17175] = {
			{"by_school", "target_res_flat", 2, {7,}, 0, 0},
	},
	[8451] = {
			{"by_school", "sp_dmg_flat", -40, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[8823] = {
			{"by_school", "sp_dmg_flat", 10, {2,}, 0, 1},
	},
	[25795] = {
			{"by_school", "sp_dmg_flat", -15, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", -15, nil, 0, 0},
	},
	[12279] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
	},
	[20188] = {
			{"by_school", "sp_dmg_flat", 30, {2,}, 0, 0},
	},
	[14533] = {
			{"by_school", "vuln_mod", 0.5, {3,}, 1, 0},
			{"by_school", "vuln_mod", 0.5, {5,}, 1, 1},
			{"by_school", "vuln_mod", 0.5, {7,}, 1, 2},
	},
	[1220683] = {
			{"by_school", "target_res_flat", 700, {1,}, 0, 0},
	},
	[17798] = {
			{"by_school", "vuln_mod", 0.08, {6,}, 1, 0},
	},
	[21055] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[8647] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[24317] = {
			{"by_school", "target_res_flat", -1000, {1,}, 0, 0},
	},
	[457191] = {
			{"by_school", "vuln_mod", 0.5, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "vuln_phys", 0.5, nil, 1, 1},
	},
	[17963] = {
			{"by_school", "target_res_flat", -24, {1,}, 0, 0},
	},
	[449869] = {
			{"by_school", "target_res_flat", -80, {1,}, 0, 2},
	},
	[7659] = {
			{"by_school", "target_res_flat", -465, {1,}, 0, 1},
	},
	[15235] = {
			{"by_school", "target_res_flat", -200, {1,}, 0, 0},
	},
	[1126] = {
			{"by_school", "target_res_flat", 25, {1,}, 0, 0},
	},
	[2537] = {
			{"by_school", "sp_dmg_flat", 6, {2,}, 0, 1},
	},
	[17392] = {
			{"by_school", "target_res_flat", -505, {1,}, 0, 0},
	},
	[17697] = {
			{"by_school", "target_res_flat", -100, {6,}, 0, 0},
	},
	[11721] = {
			{"by_school", "target_res_flat", -60, {3,5,}, 0, 0},
			{"by_school", "vuln_mod", 0.08, {3,5,}, 1, 1},
	},
	[5810] = {
			{"raw", "phys_dmg_flat", -15, nil, 0, 0},
	},
	[9806] = {
			{"by_school", "target_res_flat", -100, {1,}, 0, 0},
	},
	[17800] = {
			{"by_school", "vuln_mod", 0.19999999, {6,}, 1, 0},
	},
	[15595] = {
			{"raw", "phys_dmg_flat", -25, nil, 0, 0},
	},
	[11596] = {
			{"by_school", "target_res_flat", -360, {1,}, 0, 0},
	},
	[450640] = {
			{"raw", "vuln_phys", 0.049999997, nil, 1, 0},
	},
	[704] = {
			{"by_school", "target_res_flat", -140, {1,}, 0, 1},
	},
	[10170] = {
			{"by_school", "sp_dmg_flat", 75, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[1008] = {
			{"by_school", "sp_dmg_flat", 15, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[20911] = {
			{"by_school", "sp_dmg_flat", -10, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", -10, nil, 0, 0},
	},
	[15502] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[12579] = {
			{"by_school", "crit", 0.02, {5,}, 0, 0},
	},
	[16511] = {
			{"wpn_subclass", "phys_dmg_flat", 3, {173555}, 8, 2},
	},
	[8907] = {
			{"by_school", "target_res_flat", 195, {1,}, 0, 0},
	},
	[23769] = {
			{"by_school", "target_res_flat", 25, {2,3,4,5,6,7,}, 0, 0},
	},
	[8314] = {
			{"by_school", "target_res_flat", 15, {1,}, 0, 1},
	},
	[11717] = {
			{"by_school", "target_res_flat", -640, {1,}, 0, 1},
	},
	[20302] = {
			{"by_school", "sp_dmg_flat", 110, {2,}, 0, 0},
	},
	[434724] = {
			{"by_school", "vuln_mod", 0.5, {4,}, 1, 0},
	},
	[402818] = {
			{"by_school", "target_res_flat", -185, {1,}, 0, 0},
	},
	[25174] = {
			{"by_school", "target_res_flat", -240, {1,}, 0, 1},
	},
	[770] = {
			{"by_school", "target_res_flat", -175, {1,}, 0, 0},
	},
	[21183] = {
			{"by_school", "sp_dmg_flat", 20, {2,}, 0, 0},
	},
	[437132] = {
			{"by_school", "vuln_mod", 0.19999999, {4,}, 1, 0},
			{"by_school", "vuln_mod", 0.19999999, {7,}, 1, 1},
	},
	[5413] = {
			{"by_school", "target_res_flat", -3, {4,}, 0, 0},
	},
	[21081] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[18070] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[466272] = {
			{"by_school", "target_res_flat", -150, {4,}, 0, 0},
	},
	[23014] = {
			{"raw", "vuln_phys", 2, nil, 1, 0},
	},
	[14147] = {
			{"by_school", "target_res_flat", -760, {1,}, 0, 1},
	},
	[7139] = {
			{"raw", "phys_dmg_flat", 10, nil, 0, 2},
	},
	[446362] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
	},
	[469537] = {
			{"by_school", "target_res_flat", -25, {4,}, 0, 2},
	},
	[24378] = {
			{"by_school", "vuln_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "vuln_phys", 0.099999994, nil, 1, 1},
	},
	[10169] = {
			{"by_school", "sp_dmg_flat", 50, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[23174] = {
			{"by_school", "target_res_flat", 500, {1,2,3,4,5,6,7,}, 0, 2},
	},
	[3356] = {
			{"by_school", "target_res_flat", -10, {3,}, 0, 1},
	},
	[3252] = {
			{"by_school", "target_res_flat", -240, {1,}, 0, 0},
	},
	[11197] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[9482] = {
			{"by_school", "sp_dmg_flat", 100, {3,}, 0, 0},
	},
	[449927] = {
			{"by_school", "sp_dmg_flat", 7, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", 7, nil, 0, 0},
	},
	[17347] = {
			{"wpn_subclass", "phys_dmg_flat", 5, {173555}, 8, 2},
	},
	[20300] = {
			{"by_school", "sp_dmg_flat", 50, {2,}, 0, 0},
	},
	[25180] = {
			{"by_school", "vuln_mod", 1, {4,}, 1, 1},
	},
	[8282] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
	},
	[23341] = {
			{"by_school", "sp_dmg_flat", 150, {3,}, 0, 1},
			{"by_school", "sp_dmg_flat", 150, {3,}, 0, 1},
	},
	[426923] = {
			{"by_school", "vuln_mod", -0.75, {1,2,4,6,7,}, 1, 2},
	},
	[29175] = {
			{"by_school", "target_res_flat", 30, {3,}, 0, 0},
	},
	[12545] = {
			{"raw", "phys_dmg_flat", 15, nil, 0, 1},
	},
	[23505] = {
			{"by_school", "vuln_mod", 0.099999994, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "vuln_phys", 0.099999994, nil, 1, 1},
	},
	[15572] = {
			{"by_school", "target_res_flat", 0, {1,}, 0, 0},
	},
	[16128] = {
			{"raw", "phys_dmg_flat", 20, nil, 0, 1},
	},
	[9574] = {
			{"by_school", "sp_dmg_flat", 30, {3,}, 0, 1},
	},
	[17794] = {
			{"by_school", "vuln_mod", 0.04, {6,}, 1, 0},
	},
	[16325] = {
			{"by_school", "target_res_flat", 15, {5,}, 0, 0},
	},
	[28827] = {
			{"by_school", "target_res_flat", 700, {1,}, 0, 0},
	},
	[6922] = {
			{"raw", "phys_dmg_flat", 3, nil, 0, 0},
	},
	[27991] = {
			{"by_school", "target_res_flat", -48, {1,}, 0, 0},
	},
	[426917] = {
			{"by_school", "vuln_mod", -0.75, {1,2,5,6,7,}, 1, 2},
	},
	[25685] = {
			{"by_school", "sp_dmg_flat", -50, {1,2,3,4,5,6,7,}, 0, 2},
			{"raw", "phys_dmg_flat", -50, nil, 0, 2},
	},
	[17151] = {
			{"by_school", "sp_dmg_flat", -50, {6,}, 0, 0},
	},
	[16887] = {
			{"by_school", "target_res_flat", 400, {1,}, 0, 0},
	},
	[23314] = {
			{"by_school", "target_res_flat", -3938, {1,}, 0, 1},
			{"by_school", "target_res_flat", -5062, {1,}, 0, 1},
	},
	[20303] = {
			{"by_school", "sp_dmg_flat", 140, {2,}, 0, 0},
	},
	[22713] = {
			{"by_school", "sp_dmg_flat", 20, {3,}, 0, 1},
	},
	[15784] = {
			{"by_school", "target_res_flat", 12, {1,}, 0, 0},
	},
	[436741] = {
			{"by_school", "vuln_mod", 0.25, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "vuln_phys", 0.25, nil, 1, 0},
	},
	[447894] = {
			{"by_school", "target_res_flat", -60, {2,4,}, 0, 0},
			{"by_school", "vuln_mod", 0.08, {2,4,}, 1, 1},
	},
	[428482] = {
			{"by_school", "vuln_mod", 0.25, {6,}, 1, 1},
	},
	[434837] = {
			{"by_school", "target_res_flat", -160, {1,}, 0, 0},
	},
	[30080] = {
			{"raw", "phys_dmg_flat", 250, nil, 0, 0},
	},
	[402004] = {
			{"by_school", "vuln_mod", -0.39999998, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "vuln_phys", -0.39999998, nil, 1, 0},
	},
	[10452] = {
			{"by_school", "sp_dmg_flat", 20, {3,}, 0, 1},
	},
	[16928] = {
			{"by_school", "target_res_flat", -200, {1,}, 0, 0},
	},
	[8380] = {
			{"by_school", "target_res_flat", -270, {1,}, 0, 0},
	},
	[11791] = {
			{"by_school", "target_res_flat", -100, {1,}, 0, 0},
	},
	[20912] = {
			{"by_school", "sp_dmg_flat", -14, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", -14, nil, 0, 0},
	},
	[8450] = {
			{"by_school", "sp_dmg_flat", -20, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[16098] = {
			{"raw", "phys_dmg_flat", 2, nil, 0, 0},
	},
	[461773] = {
			{"by_school", "vuln_mod", 0.5, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "vuln_phys", 0.5, nil, 1, 1},
	},
	[14517] = {
			{"by_school", "sp_dmg_flat", 10, {2,}, 0, 1},
	},
	[20913] = {
			{"by_school", "sp_dmg_flat", -19, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", -19, nil, 0, 0},
	},
	[9749] = {
			{"by_school", "target_res_flat", -395, {1,}, 0, 0},
	},
	[17315] = {
			{"by_school", "target_res_flat", -200, {1,}, 0, 0},
	},
	[20656] = {
			{"by_school", "target_res_flat", -120, {1,}, 0, 0},
	},
	[426972] = {
			{"by_school", "vuln_mod", -0.03, {1,2,3,4,5,6,7,}, 1, 2},
			{"raw", "vuln_phys", -0.03, nil, 1, 2},
	},
	[11597] = {
			{"by_school", "target_res_flat", -450, {1,}, 0, 0},
	},
	[23605] = {
			{"by_school", "vuln_mod", 0.14999999, {1,2,3,4,5,6,7,}, 1, 0},
	},
	[428713] = {
			{"raw", "vuln_phys", -0.19999999, nil, 1, 1},
	},
	[20914] = {
			{"by_school", "sp_dmg_flat", -24, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", -24, nil, 0, 0},
	},
	[460338] = {
			{"by_school", "sp_dmg_flat", 30, {2,3,}, 0, 2},
	},
	[456496] = {
			{"by_school", "sp_dmg_flat", 140, {2,}, 0, 0},
	},
	[17391] = {
			{"by_school", "target_res_flat", -395, {1,}, 0, 0},
	},
	[5234] = {
			{"by_school", "target_res_flat", 150, {1,}, 0, 0},
	},
	[30113] = {
			{"by_school", "sp_dmg_flat", 120, {1,2,3,4,5,6,7,}, 0, 0},
			{"raw", "phys_dmg_flat", 120, nil, 0, 0},
	},
	[462161] = {
			{"by_school", "vuln_mod", 0.5, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "vuln_phys", 0.5, nil, 1, 1},
	},
	[15280] = {
			{"by_school", "target_res_flat", -300, {1,}, 0, 0},
	},
	[19366] = {
			{"by_school", "target_res_flat", -200, {3,}, 0, 0},
	},
	[468156] = {
			{"by_school", "target_res_flat", -25, {4,}, 0, 0},
	},
	[7367] = {
			{"raw", "phys_dmg_flat", 5, nil, 0, 1},
	},
	[15233] = {
			{"by_school", "target_res_flat", 200, {1,}, 0, 0},
	},
	[462400] = {
			{"by_school", "sp_dmg_flat", 25, {3,}, 0, 0},
	},
	[8095] = {
			{"by_school", "target_res_flat", 180, {1,}, 0, 0},
	},
	[10174] = {
			{"by_school", "sp_dmg_flat", -90, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[4932] = {
			{"raw", "phys_dmg_flat", -40, nil, 0, 2},
	},
	[9907] = {
			{"by_school", "target_res_flat", -505, {1,}, 0, 0},
	},
	[13752] = {
			{"by_school", "target_res_flat", -100, {1,}, 0, 0},
	},
	[428489] = {
			{"by_school", "vuln_mod", -0.29999998, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "vuln_phys", -0.29999998, nil, 1, 0},
	},
	[23313] = {
			{"by_school", "target_res_flat", -3938, {1,}, 0, 1},
			{"by_school", "target_res_flat", -5062, {1,}, 0, 1},
	},
	[604] = {
			{"by_school", "sp_dmg_flat", -10, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[16498] = {
			{"by_school", "target_res_flat", -24, {1,}, 0, 0},
	},
	[461615] = {
			{"by_school", "target_res_flat", -27, {3,5,}, 0, 0},
			{"by_school", "vuln_mod", 0.04, {3,5,}, 1, 1},
			{"by_school", "target_res_flat", -27, {6,7,}, 0, 2},
			{"by_school", "target_res_flat", -27, {4,}, 0, 3},
			{"by_school", "vuln_mod", 0.04, {6,7,}, 1, 4},
			{"by_school", "vuln_mod", 0.04, {4,}, 1, 5},
	},
	[371206] = {
			{"by_school", "sp_dmg_flat", 75, {1,2,3,4,5,6,7,}, 0, 6},
			{"raw", "phys_dmg_flat", 75, nil, 0, 6},
	},
	[9658] = {
			{"by_school", "sp_dmg_flat", 20, {3,}, 0, 1},
	},
	[20655] = {
			{"by_school", "target_res_flat", 3000, {1,}, 0, 0},
	},
	[3396] = {
			{"by_school", "target_res_flat", -60, {1,}, 0, 1},
	},
	[8245] = {
			{"by_school", "target_res_flat", -16, {1,}, 0, 0},
	},
	[439471] = {
			{"by_school", "target_res_flat", -1700, {1,}, 0, 0},
	},
	[11722] = {
			{"by_school", "target_res_flat", -75, {3,5,}, 0, 0},
			{"by_school", "vuln_mod", 0.099999994, {3,5,}, 1, 1},
	},
	[462223] = {
			{"by_school", "vuln_mod", 0.5, {1,2,3,4,5,6,7,}, 1, 1},
			{"raw", "vuln_phys", 0.5, nil, 1, 1},
	},
	[458878] = {
			{"by_school", "vuln_mod", -0.5, {1,2,3,4,5,6,7,}, 1, 3},
			{"raw", "vuln_phys", -0.5, nil, 1, 3},
	},
	[12738] = {
			{"by_school", "vuln_mod", 1, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "vuln_phys", 1, nil, 1, 0},
	},
};
sc.friendly_buffs = {
	[16856] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 1},
	},
	[459845] = {
			{"raw", "vuln_heal", -1, nil, 1, 2},
	},
	[28410] = {
			{"raw", "vuln_heal", 5, nil, 1, 2},
	},
	[7068] = {
			{"raw", "vuln_heal", -0.75, nil, 1, 0},
	},
	[21552] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 0},
	},
	[21553] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 0},
	},
	[460755] = {
			{"raw", "vuln_heal", -0.75, nil, 1, 0},
	},
	[19285] = {
			{"raw", "vuln_heal", -0.19999999, nil, 1, 1},
	},
	[13222] = {
			{"raw", "healing_power_flat", -75, nil, 0, 0},
	},
	[12294] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 0},
	},
	[1222207] = {
			{"raw", "vuln_heal", -0.25, nil, 1, 1},
	},
	[17820] = {
			{"raw", "vuln_heal", -0.75, nil, 1, 0},
	},
	[8455] = {
			{"raw", "healing_power_flat", 60, nil, 0, 1},
	},
	[26652] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 0},
	},
	[19283] = {
			{"raw", "vuln_heal", -0.19999999, nil, 1, 1},
	},
	[346285] = {
			{"raw", "vuln_heal", 0.5, nil, 1, 2},
	},
	[13583] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 0},
	},
	[23224] = {
			{"raw", "vuln_heal", -0.75, nil, 1, 0},
	},
	[13218] = {
			{"raw", "healing_power_flat", -55, nil, 0, 0},
	},
	[23169] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 1},
			{"raw", "vuln_heal", -0.5, nil, 1, 1},
	},
	[23230] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 0},
	},
	[19282] = {
			{"raw", "vuln_heal", -0.19999999, nil, 1, 1},
	},
	[13223] = {
			{"raw", "healing_power_flat", -105, nil, 0, 0},
	},
	[436387] = {
			{"raw", "vuln_heal", 0.08, nil, 1, 1},
	},
	[466211] = {
			{"raw", "vuln_heal", -0.25, nil, 1, 1},
	},
	[10173] = {
			{"raw", "healing_power_flat", -120, nil, 0, 1},
	},
	[370835] = {
			{"raw", "vuln_heal", 0.01, nil, 1, 1},
	},
	[19284] = {
			{"raw", "vuln_heal", -0.19999999, nil, 1, 1},
	},
	[13737] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 1},
	},
	[13224] = {
			{"raw", "healing_power_flat", -135, nil, 0, 0},
	},
	[19716] = {
			{"raw", "vuln_heal", -0.75, nil, 1, 0},
			{"raw", "vuln_heal", -1, nil, 1, 0},
			{"raw", "vuln_heal", -0.75, nil, 1, 0},
	},
	[437324] = {
			{"raw", "vuln_heal", -0.98999995, nil, 1, 3},
	},
	[19281] = {
			{"raw", "vuln_heal", -0.19999999, nil, 1, 1},
	},
	[8451] = {
			{"raw", "healing_power_flat", -80, nil, 0, 1},
	},
	[15708] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 1},
	},
	[459837] = {
			{"raw", "vuln_heal", -1, nil, 1, 2},
	},
	[24674] = {
			{"raw", "vuln_heal", -0.75, nil, 1, 0},
	},
	[461232] = {
			{"raw", "vuln_heal", -1, nil, 1, 0},
	},
	[22687] = {
			{"raw", "vuln_heal", -0.75, nil, 1, 0},
	},
	[370836] = {
			{"raw", "vuln_heal", 0.01, nil, 1, 1},
	},
	[430352] = {
			{"raw", "vuln_heal", 0.049999997, nil, 1, 1},
	},
	[10170] = {
			{"raw", "healing_power_flat", 150, nil, 0, 1},
	},
	[1008] = {
			{"raw", "healing_power_flat", 30, nil, 0, 1},
	},
	[27580] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 0},
	},
	[9035] = {
			{"raw", "vuln_heal", -0.19999999, nil, 1, 1},
	},
	[21551] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 0},
	},
	[28776] = {
			{"raw", "vuln_heal", -0.9, nil, 1, 0},
	},
	[25646] = {
			{"raw", "vuln_heal", -0.099999994, nil, 1, 0},
			{"raw", "vuln_heal", -0.099999994, nil, 1, 0},
	},
	[17547] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 1},
	},
	[23850] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 0},
	},
	[437847] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 1},
	},
	[10169] = {
			{"raw", "healing_power_flat", 100, nil, 0, 1},
	},
	[28467] = {
			{"raw", "vuln_heal", -0.099999994, nil, 1, 0},
	},
	[469010] = {
			{"raw", "vuln_heal", -1, nil, 1, 2},
	},
	[434869] = {
			{"raw", "vuln_heal", -1, nil, 1, 2},
	},
	[1225419] = {
			{"raw", "vuln_heal", -1, nil, 1, 0},
	},
	[444165] = {
			{"raw", "vuln_heal", -1, nil, 1, 0},
	},
	[24573] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 1},
			{"raw", "vuln_heal", -0.5, nil, 1, 1},
	},
	[28846] = {
			{"raw", "healing_power_flat", 160, nil, 0, 0},
	},
	[8450] = {
			{"raw", "healing_power_flat", -40, nil, 0, 1},
	},
	[28440] = {
			{"raw", "vuln_heal", -0.75, nil, 1, 0},
	},
	[19643] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 1},
	},
	[470535] = {
			{"raw", "vuln_heal", -0.25, nil, 1, 1},
	},
	[22859] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 1},
	},
	[10174] = {
			{"raw", "healing_power_flat", -180, nil, 0, 1},
	},
	[455350] = {
			{"raw", "vuln_heal", -0.29999998, nil, 1, 0},
	},
	[439745] = {
			{"raw", "vuln_heal", 0.099999994, nil, 1, 0},
	},
	[604] = {
			{"raw", "healing_power_flat", -20, nil, 0, 1},
	},
	[23848] = {
			{"raw", "vuln_heal", -0.5, nil, 1, 0},
	},
};
sc.set_items = {
	[20059] = 471,
	[228759] = 1781,
	[16984] = 489,
	[20158] = 483,
	[11731] = 1,
	[20154] = 483,
	[20057] = 467,
	[20042] = 468,
	[228350] = 1781,
	[226712] = 1666,
	[20150] = 483,
	[19689] = 442,
	[20050] = 469,
	[20041] = 467,
	[226709] = 1666,
	[20194] = 486,
	[213332] = 1585,
	[235893] = 1881,
	[227877] = 1791,
	[20190] = 486,
	[15046] = 490,
	[20058] = 468,
	[11728] = 1,
	[226710] = 1666,
	[20203] = 484,
	[20186] = 486,
	[215379] = 1584,
	[20195] = 484,
	[20055] = 469,
	[226708] = 1666,
	[235894] = 1881,
	[228349] = 1781,
	[227829] = 1792,
	[20048] = 467,
	[11729] = 1,
	[226714] = 1666,
	[215378] = 1584,
	[228360] = 1781,
	[20296] = 490,
	[15052] = 489,
	[20043] = 469,
	[20204] = 487,
	[15045] = 490,
	[226713] = 1666,
	[15050] = 489,
	[226711] = 1666,
	[20199] = 484,
	[11730] = 1,
	[226715] = 1666,
	[20212] = 487,
	[227853] = 1792,
	[213313] = 1585,
	[20208] = 487,
	[19688] = 442,
	[227878] = 1791,
	[20049] = 468,
	[11726] = 1,
	[227852] = 1792,
	[215377] = 1584,
	[15051] = 489,
	[20052] = 471,
	[227879] = 1791,
	[213341] = 1585,
	[20045] = 471,
	[227851] = 1792,
};
sc.set_bonuses = {
	[1881] = {{2,1219073},},
	[1792] = {{3,448324},},
	[1584] = {{2,436239},},
	[486] = {{3,7597},},
	[490] = {{3,21894},},
	[469] = {{3,7597},},
	[1781] = {{3,436239},},
	[1585] = {{2,436239},},
	[483] = {{3,7597},},
	[442] = {{2,7597},},
	[489] = {{3,7598},},
	[471] = {{3,7597},},
	[468] = {{3,7597},},
	[487] = {{3,7597},},
	[1666] = {{6,450608},},
	[467] = {{3,7597},},
	[1791] = {{3,21894},},
	[1] = {{5,7597},},
	[484] = {{3,7597},},
};
sc.items = {
};
sc.item_effects = {
	[440981] = {
			{"raw", "phys_dmg_flat", 3, nil, 0, 0},
	},
	[1223262] = {
			{"raw", "phys_crit", 0.03, nil, 32, 0},
			{"by_school", "crit", 0.03, {2,3,4,5,6,7,}, 2, 1},
	},
	[21079] = {
			{"raw", "melee_haste", 0.14999999, nil, 33, 1},
			{"raw", "phys_crit", 0.14999999, nil, 32, 2},
	},
	[468913] = {
			{"by_school", "dmg_mod", -0.75, {2,}, 1, 1},
	},
	[1220657] = {
			{"raw", "cast_haste", 0.04, nil, 0, 0},
	},
	[9405] = {
			{"raw", "phys_crit", 0.049999997, nil, 32, 0},
	},
	[448324] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[1219557] = {
			{"raw", "cast_haste", 0.02, nil, 0, 0},
	},
	[436239] = {
			{"raw", "phys_crit", 0.01, nil, 32, 0},
			{"by_school", "crit", 0.01, {2,3,4,5,6,7,}, 2, 1},
	},
	[17713] = {
			{"raw", "phys_crit", 0.099999994, nil, 32, 0},
	},
	[7598] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
	},
	[1222394] = {
			{"raw", "melee_haste", 0.03, nil, 33, 0},
			{"raw", "ranged_haste", 0.03, nil, 33, 1},
	},
	[22988] = {
			{"raw", "phys_hit", 0.19999999, nil, 2, 1},
			{"raw", "melee_haste", 0.29999998, nil, 33, 2},
	},
	[1220656] = {
			{"raw", "cast_haste", 0.03, nil, 0, 0},
	},
	[7597] = {
			{"raw", "phys_crit", 0.01, nil, 32, 0},
	},
	[1222393] = {
			{"raw", "melee_haste", 0.01, nil, 33, 0},
			{"raw", "ranged_haste", 0.01, nil, 33, 1},
	},
	[418510] = {
			{"raw", "phys_dmg_flat", 5, nil, 0, 0},
			{"by_school", "sp_dmg_flat", 10, {1,2,3,4,5,6,7,}, 2, 1},
			{"raw", "healing_power_flat", 16, nil, 2, 2},
	},
	[1220654] = {
			{"raw", "cast_haste", 0.01, nil, 0, 0},
	},
	[1220655] = {
			{"raw", "cast_haste", 0.02, nil, 0, 0},
	},
	[1214917] = {
			{"raw", "phys_dmg_flat", 2, nil, 0, 0},
	},
	[1213971] = {
			{"raw", "melee_haste", 0.02, nil, 33, 0},
			{"raw", "ranged_haste", 0.02, nil, 33, 1},
	},
	[23674] = {
			{"raw", "ranged_haste", 1.5, nil, 33, 0},
			{"raw", "phys_hit", -0.75, nil, 2, 1},
	},
	[9132] = {
			{"wpn_subclass", "phys_crit", 0.01, {327692}, 40, 0},
	},
	[25901] = {
			{"raw", "phys_dmg_flat", 4, nil, 0, 0},
	},
};
sc.set_effects = {
	[468436] = {
			{"wpn_subclass", "phys_crit", 0.049999997, {32768}, 40, 0},
	},
	[435975] = {
			{"by_school", "sp_dmg_flat", 11, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 11, nil, 2, 1},
	},
	[9329] = {
			{"raw", "ap_flat", 16, nil, 2, 0},
			{"raw", "rap_flat", 16, nil, 2, 1},
	},
	[30771] = {
			{"raw", "ap_flat", 40, nil, 2, 0},
			{"raw", "rap_flat", 40, nil, 2, 1},
	},
	[30780] = {
			{"by_school", "sp_dmg_flat", 23, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 23, nil, 2, 1},
	},
	[468395] = {
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 12, nil, 2, 1},
	},
	[15464] = {
			{"raw", "phys_hit", 0.01, nil, 2, 0},
	},
	[15465] = {
			{"raw", "phys_hit", 0.02, nil, 2, 0},
	},
	[432639] = {
			{"raw", "phys_hit", 0.01, nil, 2, 0},
			{"by_school", "spell_hit", 0.01, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[1219474] = {
			{"by_school", "spell_hit", 0.02, {1,2,3,4,5,6,7,}, 2, 2},
	},
	[461697] = {
			{"by_school", "sp_dmg_flat", 29, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[14027] = {
			{"raw", "ap_flat", 24, nil, 2, 0},
			{"raw", "rap_flat", 24, nil, 2, 1},
	},
	[17371] = {
			{"raw", "healing_power_flat", 44, nil, 2, 0},
	},
	[468397] = {
			{"by_school", "sp_dmg_flat", 14, {5,}, 2, 0},
	},
	[14056] = {
			{"raw", "ap_flat", 50, nil, 2, 0},
			{"raw", "rap_flat", 50, nil, 2, 1},
	},
	[455858] = {
			{"raw", "phys_hit", 0.03, nil, 2, 0},
			{"by_school", "spell_hit", 0.03, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[23727] = {
			{"by_school", "spell_hit", 0.01, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[468400] = {
			{"raw", "healing_power_flat", 12, nil, 2, 0},
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[9140] = {
			{"raw", "ap_flat", 10, nil, 2, 0},
			{"raw", "rap_flat", 10, nil, 2, 1},
	},
	[456546] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[9396] = {
			{"by_school", "sp_dmg_flat", 6, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 6, nil, 2, 1},
	},
	[18384] = {
			{"by_school", "crit", 0.01, {2,3,4,5,6,7,}, 2, 0},
	},
	[18382] = {
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 0},
	},
	[448324] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[428490] = {
			{"by_school", "threat", 0.5, {}, 0, 0},
	},
	[457323] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[18036] = {
			{"raw", "healing_power_flat", 55, nil, 2, 0},
	},
	[30779] = {
			{"by_school", "sp_dmg_flat", 23, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 23, nil, 2, 1},
	},
	[468398] = {
			{"raw", "healing_power_flat", 22, nil, 2, 0},
			{"by_school", "sp_dmg_flat", 7, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[429863] = {
			{"raw", "phys_hit", 0.01, nil, 2, 0},
	},
	[28118] = {
			{"raw", "phys_crit", 0.01, nil, 32, 0},
	},
	[9345] = {
			{"by_school", "sp_dmg_flat", 16, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 16, nil, 2, 1},
	},
	[14049] = {
			{"raw", "ap_flat", 40, nil, 2, 0},
			{"raw", "rap_flat", 40, nil, 2, 1},
	},
	[457549] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[23545] = {
			{"by_school", "threat", -0.14999999, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[436239] = {
			{"raw", "phys_crit", 0.01, nil, 32, 0},
			{"by_school", "crit", 0.01, {2,3,4,5,6,7,}, 2, 1},
	},
	[29068] = {
			{"creature", "dmg_mod", 0.02, {32,}, 1, 0},
	},
	[435976] = {
			{"raw", "ap_flat", 20, nil, 2, 0},
	},
	[468407] = {
			{"raw", "ap_flat", 20, nil, 2, 0},
			{"raw", "rap_flat", 20, nil, 2, 1},
	},
	[9141] = {
			{"raw", "ap_flat", 12, nil, 2, 0},
			{"raw", "rap_flat", 12, nil, 2, 1},
	},
	[7598] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
	},
	[7694] = {
			{"by_school", "sp_dmg_flat", 7, {4,}, 2, 0},
	},
	[21092] = {
			{"by_school", "crit", 0.02, {2,}, 2, 0},
	},
	[467647] = {
			{"raw", "healing_power_flat", 33, nil, 2, 0},
			{"by_school", "sp_dmg_flat", 11, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[9408] = {
			{"raw", "healing_power_flat", 22, nil, 2, 0},
	},
	[30777] = {
			{"by_school", "sp_dmg_flat", 23, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 23, nil, 2, 1},
	},
	[14799] = {
			{"by_school", "sp_dmg_flat", 20, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 20, nil, 2, 1},
	},
	[456489] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[450512] = {
			{"raw", "ap_flat", 40, nil, 2, 0},
			{"raw", "rap_flat", 40, nil, 2, 1},
			{"by_school", "sp_dmg_flat", 23, {1,2,3,4,5,6,7,}, 2, 2},
			{"raw", "healing_power_flat", 44, nil, 2, 3},
	},
	[9344] = {
			{"by_school", "sp_dmg_flat", 15, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 15, nil, 2, 1},
	},
	[23570] = {
			{"by_school", "crit", 0.03, {4,}, 2, 0},
	},
	[9142] = {
			{"raw", "ap_flat", 14, nil, 2, 0},
			{"raw", "rap_flat", 14, nil, 2, 1},
	},
	[7679] = {
			{"raw", "healing_power_flat", 11, nil, 2, 0},
	},
	[7597] = {
			{"raw", "phys_crit", 0.01, nil, 32, 0},
	},
	[9417] = {
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 12, nil, 2, 1},
	},
	[21894] = {
			{"raw", "regen_while_casting", 0.14999999, nil, 0, 0},
	},
	[9346] = {
			{"by_school", "sp_dmg_flat", 18, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 18, nil, 2, 1},
	},
	[450516] = {
			{"raw", "ap_flat", 40, nil, 2, 0},
			{"raw", "rap_flat", 40, nil, 2, 1},
			{"raw", "healing_power_flat", 32, nil, 2, 2},
	},
	[30778] = {
			{"by_school", "sp_dmg_flat", 23, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 23, nil, 2, 1},
	},
	[30770] = {
			{"raw", "ap_flat", 40, nil, 2, 0},
			{"raw", "rap_flat", 40, nil, 2, 1},
	},
	[9334] = {
			{"raw", "ap_flat", 26, nil, 2, 0},
			{"raw", "rap_flat", 26, nil, 2, 1},
	},
	[14127] = {
			{"by_school", "sp_dmg_flat", 28, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 28, nil, 2, 1},
	},
	[449926] = {
			{"raw", "phys_hit", 0.02, nil, 2, 0},
			{"by_school", "spell_hit", 0.02, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[9335] = {
			{"raw", "ap_flat", 28, nil, 2, 0},
			{"raw", "rap_flat", 28, nil, 2, 1},
	},
	[24196] = {
			{"by_school", "sp_dmg_flat", 47, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 47, nil, 2, 1},
	},
	[30775] = {
			{"raw", "ap_flat", 40, nil, 2, 0},
			{"raw", "rap_flat", 40, nil, 2, 1},
	},
	[450517] = {
			{"raw", "ap_flat", 40, nil, 2, 0},
			{"raw", "rap_flat", 40, nil, 2, 1},
			{"by_school", "sp_dmg_flat", 23, {1,2,3,4,5,6,7,}, 2, 2},
			{"raw", "healing_power_flat", 44, nil, 2, 3},
	},
	[467387] = {
			{"by_school", "threat", -0.19999999, {3,}, 0, 0},
	},
	[460230] = {
			{"raw", "phys_hit", 0.02, nil, 2, 0},
			{"by_school", "spell_hit", 0.02, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[9415] = {
			{"by_school", "sp_dmg_flat", 9, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 9, nil, 2, 1},
	},
	[450403] = {
			{"wpn_subclass", "phys_crit", 0.02, {327692}, 40, 0},
	},
	[467539] = {
			{"raw", "regen_while_casting", 0.14999999, nil, 0, 0},
	},
	[9336] = {
			{"raw", "ap_flat", 30, nil, 2, 0},
			{"raw", "rap_flat", 30, nil, 2, 1},
	},
	[23929] = {
			{"by_school", "sp_dmg_flat", 71, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 71, nil, 2, 1},
	},
	[457530] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[30772] = {
			{"raw", "ap_flat", 40, nil, 2, 0},
			{"raw", "rap_flat", 40, nil, 2, 1},
	},
	[468401] = {
			{"by_school", "sp_dmg_flat", 14, {2,}, 2, 0},
	},
	[468409] = {
			{"raw", "ap_flat", 20, nil, 2, 0},
			{"raw", "rap_flat", 20, nil, 2, 1},
	},
	[9318] = {
			{"raw", "healing_power_flat", 33, nil, 2, 0},
	},
	[467550] = {
			{"raw", "healing_power_flat", 44, nil, 2, 0},
			{"by_school", "sp_dmg_flat", 15, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[457322] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[9331] = {
			{"raw", "ap_flat", 20, nil, 2, 0},
			{"raw", "rap_flat", 20, nil, 2, 1},
	},
	[449933] = {
			{"by_school", "crit", 0.03, {2,}, 2, 0},
	},
	[457532] = {
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[14047] = {
			{"by_school", "sp_dmg_flat", 23, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 23, nil, 2, 1},
	},
};
sc.enchant_effects = {
	[23796] = {
			{"raw", "healing_power_flat", 24, nil, 2, 0},
	},
	[13601] = {
			{"by_school", "sp_dmg_flat", 16, {7,}, 2, 0},
	},
	[17884] = {
			{"by_school", "sp_dmg_flat", 50, {3,}, 2, 0},
	},
	[9138] = {
			{"raw", "ap_flat", 6, nil, 2, 0},
			{"raw", "rap_flat", 6, nil, 2, 1},
	},
	[21431] = {
			{"raw", "rap_flat", 14, nil, 2, 0},
	},
	[468352] = {
			{"raw", "phys_hit", 0.01, nil, 2, 1},
			{"by_school", "spell_hit", 0.01, {1,2,3,4,5,6,7,}, 2, 2},
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 3},
			{"raw", "healing_power_flat", 12, nil, 2, 4},
	},
	[468336] = {
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 2},
			{"raw", "healing_power_flat", 12, nil, 2, 3},
	},
	[9392] = {
			{"by_school", "sp_dmg_flat", 1, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 1, nil, 2, 1},
	},
	[21536] = {
			{"by_school", "sp_dmg_flat", 54, {2,}, 2, 0},
	},
	[468436] = {
			{"wpn_subclass", "phys_crit", 0.049999997, {32768}, 40, 0},
	},
	[17989] = {
			{"by_school", "sp_dmg_flat", 26, {4,}, 2, 0},
	},
	[15810] = {
			{"raw", "ap_flat", 44, nil, 2, 0},
			{"raw", "rap_flat", 44, nil, 2, 1},
	},
	[9324] = {
			{"by_school", "sp_dmg_flat", 16, {6,}, 2, 0},
	},
	[15696] = {
			{"raw", "healing_power_flat", 53, nil, 2, 0},
	},
	[18043] = {
			{"raw", "healing_power_flat", 70, nil, 2, 0},
	},
	[21457] = {
			{"raw", "rap_flat", 79, nil, 2, 0},
	},
	[17874] = {
			{"by_school", "sp_dmg_flat", 37, {3,}, 2, 0},
	},
	[25110] = {
			{"by_school", "sp_dmg_flat", 16, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 16, nil, 2, 1},
	},
	[21515] = {
			{"by_school", "sp_dmg_flat", 24, {2,}, 2, 0},
	},
	[21433] = {
			{"raw", "rap_flat", 19, nil, 2, 0},
	},
	[21527] = {
			{"by_school", "sp_dmg_flat", 41, {2,}, 2, 0},
	},
	[18021] = {
			{"by_school", "sp_dmg_flat", 44, {6,}, 2, 0},
	},
	[17747] = {
			{"by_school", "sp_dmg_flat", 23, {3,}, 2, 0},
	},
	[21532] = {
			{"by_school", "sp_dmg_flat", 49, {2,}, 2, 0},
	},
	[21458] = {
			{"raw", "rap_flat", 82, nil, 2, 0},
	},
	[17995] = {
			{"by_school", "sp_dmg_flat", 37, {4,}, 2, 0},
	},
	[21520] = {
			{"by_school", "sp_dmg_flat", 31, {2,}, 2, 0},
	},
	[17821] = {
			{"by_school", "sp_dmg_flat", 23, {7,}, 2, 0},
	},
	[21518] = {
			{"by_school", "sp_dmg_flat", 29, {2,}, 2, 0},
	},
	[21435] = {
			{"raw", "rap_flat", 24, nil, 2, 0},
	},
	[13595] = {
			{"by_school", "sp_dmg_flat", 9, {7,}, 2, 0},
	},
	[25116] = {
			{"raw", "healing_power_flat", 25, nil, 2, 1},
	},
	[17882] = {
			{"by_school", "sp_dmg_flat", 49, {3,}, 2, 0},
	},
	[17992] = {
			{"by_school", "sp_dmg_flat", 26, {4,}, 2, 0},
	},
	[15806] = {
			{"raw", "ap_flat", 34, nil, 2, 0},
			{"raw", "rap_flat", 34, nil, 2, 1},
	},
	[9407] = {
			{"raw", "healing_power_flat", 20, nil, 2, 0},
	},
	[9394] = {
			{"by_school", "sp_dmg_flat", 4, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 4, nil, 2, 1},
	},
	[22755] = {
			{"wpn_subclass", "phys_crit", 0.02, {42483}, 40, 0},
	},
	[18008] = {
			{"by_school", "sp_dmg_flat", 26, {6,}, 2, 0},
	},
	[9329] = {
			{"raw", "ap_flat", 16, nil, 2, 0},
			{"raw", "rap_flat", 16, nil, 2, 1},
	},
	[14052] = {
			{"raw", "ap_flat", 60, nil, 2, 0},
			{"raw", "rap_flat", 60, nil, 2, 1},
	},
	[7690] = {
			{"by_school", "sp_dmg_flat", 1, {4,}, 2, 0},
	},
	[7700] = {
			{"by_school", "sp_dmg_flat", 6, {5,}, 2, 0},
	},
	[9403] = {
			{"by_school", "sp_dmg_flat", 13, {5,}, 2, 0},
	},
	[442894] = {
			{"by_school", "spell_hit", 0.06, {3,}, 2, 0},
	},
	[21459] = {
			{"raw", "rap_flat", 84, nil, 2, 0},
	},
	[17891] = {
			{"by_school", "sp_dmg_flat", 26, {5,}, 2, 0},
	},
	[21529] = {
			{"by_school", "sp_dmg_flat", 44, {2,}, 2, 0},
	},
	[18009] = {
			{"by_school", "sp_dmg_flat", 27, {6,}, 2, 0},
	},
	[17868] = {
			{"by_school", "sp_dmg_flat", 27, {3,}, 2, 0},
	},
	[9357] = {
			{"by_school", "sp_dmg_flat", 16, {4,}, 2, 0},
	},
	[14794] = {
			{"by_school", "sp_dmg_flat", 24, {6,}, 2, 0},
	},
	[21510] = {
			{"by_school", "sp_dmg_flat", 17, {2,}, 2, 0},
	},
	[9397] = {
			{"by_school", "sp_dmg_flat", 7, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 7, nil, 2, 1},
	},
	[21507] = {
			{"by_school", "sp_dmg_flat", 13, {2,}, 2, 0},
	},
	[14793] = {
			{"by_school", "sp_dmg_flat", 23, {6,}, 2, 0},
	},
	[18026] = {
			{"by_school", "sp_dmg_flat", 51, {6,}, 2, 0},
	},
	[17890] = {
			{"by_school", "sp_dmg_flat", 24, {5,}, 2, 0},
	},
	[18035] = {
			{"raw", "healing_power_flat", 51, nil, 2, 0},
	},
	[14089] = {
			{"raw", "ap_flat", 36, nil, 2, 0},
			{"raw", "rap_flat", 36, nil, 2, 1},
	},
	[468316] = {
			{"by_school", "spell_hit", 0.01, {1,2,3,4,5,6,7,}, 2, 1},
			{"raw", "phys_hit", 0.01, nil, 2, 2},
			{"raw", "healing_power_flat", 12, nil, 2, 3},
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 4},
	},
	[18032] = {
			{"raw", "healing_power_flat", 42, nil, 2, 0},
	},
	[7687] = {
			{"by_school", "sp_dmg_flat", 7, {3,}, 2, 0},
	},
	[21534] = {
			{"by_school", "sp_dmg_flat", 51, {2,}, 2, 0},
	},
	[7699] = {
			{"by_school", "sp_dmg_flat", 4, {5,}, 2, 0},
	},
	[18016] = {
			{"by_school", "sp_dmg_flat", 37, {6,}, 2, 0},
	},
	[18034] = {
			{"raw", "healing_power_flat", 48, nil, 2, 0},
	},
	[17902] = {
			{"by_school", "sp_dmg_flat", 43, {5,}, 2, 0},
	},
	[21528] = {
			{"by_school", "sp_dmg_flat", 43, {2,}, 2, 0},
	},
	[13596] = {
			{"by_school", "sp_dmg_flat", 10, {7,}, 2, 0},
	},
	[21521] = {
			{"by_school", "sp_dmg_flat", 33, {2,}, 2, 0},
	},
	[446458] = {
			{"by_school", "sp_dmg_flat", 9, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 9, nil, 2, 1},
	},
	[14027] = {
			{"raw", "ap_flat", 24, nil, 2, 0},
			{"raw", "rap_flat", 24, nil, 2, 1},
	},
	[25066] = {
			{"by_school", "sp_dmg_flat", 20, {5,}, 2, 0},
	},
	[9413] = {
			{"by_school", "sp_dmg_flat", 13, {6,}, 2, 0},
	},
	[468758] = {
			{"raw", "healing_power_flat", 26, nil, 2, 0},
	},
	[17371] = {
			{"raw", "healing_power_flat", 44, nil, 2, 0},
	},
	[1213625] = {
			{"by_school", "sp_dmg_flat", 20, {7,}, 2, 0},
	},
	[17911] = {
			{"by_school", "sp_dmg_flat", 54, {5,}, 2, 0},
	},
	[17997] = {
			{"by_school", "sp_dmg_flat", 40, {4,}, 2, 0},
	},
	[442897] = {
			{"by_school", "spell_hit", 0.06, {6,}, 2, 0},
	},
	[21449] = {
			{"raw", "rap_flat", 58, nil, 2, 0},
	},
	[13593] = {
			{"by_school", "sp_dmg_flat", 6, {7,}, 2, 0},
	},
	[17896] = {
			{"by_school", "sp_dmg_flat", 34, {5,}, 2, 0},
	},
	[13831] = {
			{"by_school", "sp_dmg_flat", 29, {5,}, 2, 0},
	},
	[1220596] = {
			{"raw", "phys_crit", 0.01, nil, 32, 0},
			{"by_school", "crit", 0.01, {2,3,4,5,6,7,}, 2, 1},
	},
	[17988] = {
			{"by_school", "sp_dmg_flat", 24, {4,}, 2, 0},
	},
	[15820] = {
			{"raw", "ap_flat", 70, nil, 2, 0},
			{"raw", "rap_flat", 70, nil, 2, 1},
	},
	[9360] = {
			{"by_school", "sp_dmg_flat", 20, {4,}, 2, 0},
	},
	[21461] = {
			{"raw", "rap_flat", 89, nil, 2, 0},
	},
	[7689] = {
			{"by_school", "sp_dmg_flat", 10, {3,}, 2, 0},
	},
	[18031] = {
			{"raw", "healing_power_flat", 40, nil, 2, 0},
	},
	[15569] = {
			{"raw", "ap_flat", 129, nil, 2, 0},
	},
	[17898] = {
			{"by_school", "sp_dmg_flat", 37, {5,}, 2, 0},
	},
	[17870] = {
			{"by_school", "sp_dmg_flat", 31, {3,}, 2, 0},
	},
	[14254] = {
			{"by_school", "sp_dmg_flat", 19, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 19, nil, 2, 1},
	},
	[446450] = {
			{"raw", "ap_flat", 15, nil, 2, 0},
			{"raw", "rap_flat", 15, nil, 2, 1},
	},
	[21499] = {
			{"by_school", "sp_dmg_flat", 1, {2,}, 2, 0},
	},
	[17871] = {
			{"by_school", "sp_dmg_flat", 33, {3,}, 2, 0},
	},
	[468363] = {
			{"raw", "phys_hit", 0.01, nil, 2, 1},
			{"by_school", "spell_hit", 0.01, {1,2,3,4,5,6,7,}, 2, 2},
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 3},
			{"raw", "healing_power_flat", 12, nil, 2, 4},
	},
	[7676] = {
			{"raw", "healing_power_flat", 4, nil, 2, 0},
	},
	[21509] = {
			{"by_school", "sp_dmg_flat", 16, {2,}, 2, 0},
	},
	[17842] = {
			{"by_school", "sp_dmg_flat", 46, {7,}, 2, 0},
	},
	[7692] = {
			{"by_school", "sp_dmg_flat", 4, {4,}, 2, 0},
	},
	[9359] = {
			{"by_school", "sp_dmg_flat", 19, {4,}, 2, 0},
	},
	[425464] = {
			{"by_school", "dmg_mod", 0.099999994, {3,6,}, 1, 1},
	},
	[17879] = {
			{"by_school", "sp_dmg_flat", 44, {3,}, 2, 0},
	},
	[17897] = {
			{"by_school", "sp_dmg_flat", 36, {5,}, 2, 0},
	},
	[7685] = {
			{"by_school", "sp_dmg_flat", 4, {3,}, 2, 0},
	},
	[22748] = {
			{"raw", "healing_power_flat", 55, nil, 2, 0},
	},
	[21522] = {
			{"by_school", "sp_dmg_flat", 34, {2,}, 2, 0},
	},
	[17830] = {
			{"by_school", "sp_dmg_flat", 36, {7,}, 2, 0},
	},
	[446470] = {
			{"raw", "healing_power_flat", 18, nil, 2, 0},
	},
	[412286] = {
			{"by_school", "crit", 0.14999999, {3,}, 2, 0},
	},
	[9137] = {
			{"raw", "ap_flat", 4, nil, 2, 0},
			{"raw", "rap_flat", 4, nil, 2, 1},
	},
	[14056] = {
			{"raw", "ap_flat", 50, nil, 2, 0},
			{"raw", "rap_flat", 50, nil, 2, 1},
	},
	[24159] = {
			{"raw", "healing_power_flat", 24, nil, 2, 2},
	},
	[455858] = {
			{"raw", "phys_hit", 0.03, nil, 2, 0},
			{"by_school", "spell_hit", 0.03, {1,2,3,4,5,6,7,}, 2, 1},
	},
	[16638] = {
			{"by_school", "sp_dmg_flat", 34, {4,}, 2, 0},
	},
	[17881] = {
			{"by_school", "sp_dmg_flat", 47, {3,}, 2, 0},
	},
	[9414] = {
			{"by_school", "sp_dmg_flat", 14, {6,}, 2, 0},
	},
	[7217] = {
			{"raw", "melee_haste", 0.03, nil, 33, 0},
	},
	[29482] = {
			{"raw", "phys_crit", 0.01, nil, 32, 1},
			{"raw", "ap_flat", 26, nil, 2, 2},
			{"raw", "rap_flat", 26, nil, 2, 3},
	},
	[21508] = {
			{"by_school", "sp_dmg_flat", 14, {2,}, 2, 0},
	},
	[21455] = {
			{"raw", "rap_flat", 74, nil, 2, 0},
	},
	[18039] = {
			{"raw", "healing_power_flat", 62, nil, 2, 0},
	},
	[15826] = {
			{"raw", "ap_flat", 80, nil, 2, 0},
			{"raw", "rap_flat", 80, nil, 2, 1},
	},
	[15567] = {
			{"raw", "ap_flat", 58, nil, 2, 0},
	},
	[468327] = {
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 2},
			{"raw", "healing_power_flat", 12, nil, 2, 3},
	},
	[17908] = {
			{"by_school", "sp_dmg_flat", 50, {5,}, 2, 0},
	},
	[9140] = {
			{"raw", "ap_flat", 10, nil, 2, 0},
			{"raw", "rap_flat", 10, nil, 2, 1},
	},
	[18000] = {
			{"by_school", "sp_dmg_flat", 44, {4,}, 2, 0},
	},
	[17880] = {
			{"by_school", "sp_dmg_flat", 46, {3,}, 2, 0},
	},
	[21441] = {
			{"raw", "rap_flat", 38, nil, 2, 0},
	},
	[7695] = {
			{"by_school", "sp_dmg_flat", 9, {4,}, 2, 0},
	},
	[16313] = {
			{"raw", "ap_flat", 554, nil, 2, 0},
	},
	[18018] = {
			{"by_school", "sp_dmg_flat", 40, {6,}, 2, 0},
	},
	[13592] = {
			{"by_school", "sp_dmg_flat", 4, {7,}, 2, 0},
	},
	[468331] = {
			{"raw", "healing_power_flat", 22, nil, 2, 2},
	},
	[21456] = {
			{"raw", "rap_flat", 77, nil, 2, 0},
	},
	[15812] = {
			{"raw", "ap_flat", 52, nil, 2, 0},
			{"raw", "rap_flat", 52, nil, 2, 1},
	},
	[9306] = {
			{"by_school", "sp_dmg_flat", 19, {5,}, 2, 0},
	},
	[17999] = {
			{"by_school", "sp_dmg_flat", 43, {4,}, 2, 0},
	},
	[7691] = {
			{"by_school", "sp_dmg_flat", 3, {4,}, 2, 0},
	},
	[9361] = {
			{"by_school", "sp_dmg_flat", 21, {4,}, 2, 0},
	},
	[21514] = {
			{"by_school", "sp_dmg_flat", 23, {2,}, 2, 0},
	},
	[13830] = {
			{"by_school", "sp_dmg_flat", 29, {3,}, 2, 0},
	},
	[430391] = {
			{"wpn_subclass", "phys_hit", 0.02, {42483}, 8, 0},
	},
	[9405] = {
			{"raw", "phys_crit", 0.049999997, nil, 32, 0},
	},
	[9314] = {
			{"raw", "healing_power_flat", 24, nil, 2, 0},
	},
	[7704] = {
			{"by_school", "sp_dmg_flat", 1, {6,}, 2, 0},
	},
	[456546] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[409687] = {
			{"raw", "offhand_mod", 0.5, nil, 2, 0},
	},
	[18024] = {
			{"by_school", "sp_dmg_flat", 49, {6,}, 2, 0},
	},
	[409428] = {
			{"raw", "phys_crit", 0.049999997, nil, 32, 0},
	},
	[21446] = {
			{"raw", "rap_flat", 50, nil, 2, 0},
	},
	[21501] = {
			{"by_school", "sp_dmg_flat", 4, {2,}, 2, 0},
	},
	[17901] = {
			{"by_school", "sp_dmg_flat", 41, {5,}, 2, 0},
	},
	[9396] = {
			{"by_school", "sp_dmg_flat", 6, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 6, nil, 2, 1},
	},
	[9342] = {
			{"by_school", "sp_dmg_flat", 13, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 13, nil, 2, 1},
	},
	[18029] = {
			{"raw", "healing_power_flat", 35, nil, 2, 0},
	},
	[17826] = {
			{"by_school", "sp_dmg_flat", 30, {7,}, 2, 0},
	},
	[17876] = {
			{"by_school", "sp_dmg_flat", 41, {3,}, 2, 0},
	},
	[18007] = {
			{"by_school", "sp_dmg_flat", 54, {4,}, 2, 0},
	},
	[18046] = {
			{"raw", "healing_power_flat", 77, nil, 2, 0},
	},
	[17839] = {
			{"by_school", "sp_dmg_flat", 41, {7,}, 2, 0},
	},
	[25063] = {
			{"by_school", "threat", 0.02, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[9304] = {
			{"by_school", "sp_dmg_flat", 16, {5,}, 2, 0},
	},
	[22843] = {
			{"by_school", "sp_dmg_flat", 8, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 8, nil, 2, 1},
	},
	[9332] = {
			{"raw", "ap_flat", 22, nil, 2, 0},
			{"raw", "rap_flat", 22, nil, 2, 1},
	},
	[25070] = {
			{"by_school", "threat", -0.02, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[24153] = {
			{"raw", "ap_flat", 28, nil, 2, 0},
	},
	[18028] = {
			{"by_school", "sp_dmg_flat", 54, {6,}, 2, 0},
	},
	[21430] = {
			{"raw", "rap_flat", 12, nil, 2, 0},
	},
	[18038] = {
			{"raw", "healing_power_flat", 59, nil, 2, 0},
	},
	[13603] = {
			{"by_school", "sp_dmg_flat", 19, {7,}, 2, 0},
	},
	[457323] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[7702] = {
			{"by_school", "sp_dmg_flat", 9, {5,}, 2, 0},
	},
	[21440] = {
			{"raw", "rap_flat", 36, nil, 2, 0},
	},
	[17991] = {
			{"by_school", "sp_dmg_flat", 30, {4,}, 2, 0},
	},
	[18020] = {
			{"by_school", "sp_dmg_flat", 43, {6,}, 2, 0},
	},
	[468324] = {
			{"raw", "phys_hit", 0.01, nil, 2, 2},
			{"by_school", "spell_hit", 0.01, {1,2,3,4,5,6,7,}, 2, 3},
	},
	[17847] = {
			{"by_school", "sp_dmg_flat", 51, {7,}, 2, 0},
	},
	[22747] = {
			{"by_school", "sp_dmg_flat", 30, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 30, nil, 2, 1},
	},
	[17848] = {
			{"by_school", "sp_dmg_flat", 53, {7,}, 2, 0},
	},
	[429142] = {
			{"by_school", "crit", 0.17999999, {2,}, 2, 0},
	},
	[17893] = {
			{"by_school", "sp_dmg_flat", 30, {5,}, 2, 0},
	},
	[21434] = {
			{"raw", "rap_flat", 22, nil, 2, 0},
	},
	[18036] = {
			{"raw", "healing_power_flat", 55, nil, 2, 0},
	},
	[17895] = {
			{"by_school", "sp_dmg_flat", 33, {5,}, 2, 0},
	},
	[21442] = {
			{"raw", "rap_flat", 41, nil, 2, 0},
	},
	[18010] = {
			{"by_school", "sp_dmg_flat", 29, {6,}, 2, 0},
	},
	[468312] = {
			{"raw", "healing_power_flat", 22, nil, 2, 2},
	},
	[25064] = {
			{"by_school", "sp_dmg_flat", 20, {6,}, 2, 0},
	},
	[17846] = {
			{"by_school", "sp_dmg_flat", 50, {7,}, 2, 0},
	},
	[7693] = {
			{"by_school", "sp_dmg_flat", 6, {4,}, 2, 0},
	},
	[25065] = {
			{"by_school", "sp_dmg_flat", 20, {3,}, 2, 0},
	},
	[15827] = {
			{"raw", "ap_flat", 82, nil, 2, 0},
			{"raw", "rap_flat", 82, nil, 2, 1},
	},
	[9345] = {
			{"by_school", "sp_dmg_flat", 16, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 16, nil, 2, 1},
	},
	[7684] = {
			{"by_school", "sp_dmg_flat", 3, {3,}, 2, 0},
	},
	[9412] = {
			{"by_school", "sp_dmg_flat", 11, {6,}, 2, 0},
	},
	[468348] = {
			{"raw", "phys_hit", 0.01, nil, 2, 2},
			{"by_school", "spell_hit", 0.01, {1,2,3,4,5,6,7,}, 2, 3},
	},
	[14049] = {
			{"raw", "ap_flat", 40, nil, 2, 0},
			{"raw", "rap_flat", 40, nil, 2, 1},
	},
	[13928] = {
			{"raw", "melee_haste", 0.01, nil, 33, 0},
			{"raw", "ranged_haste", 0.01, nil, 33, 1},
	},
	[15821] = {
			{"raw", "ap_flat", 72, nil, 2, 0},
			{"raw", "rap_flat", 72, nil, 2, 1},
	},
	[21439] = {
			{"raw", "rap_flat", 34, nil, 2, 0},
	},
	[15809] = {
			{"raw", "ap_flat", 42, nil, 2, 0},
			{"raw", "rap_flat", 42, nil, 2, 1},
	},
	[7683] = {
			{"by_school", "sp_dmg_flat", 1, {3,}, 2, 0},
	},
	[457549] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[21451] = {
			{"raw", "rap_flat", 65, nil, 2, 0},
	},
	[7681] = {
			{"raw", "healing_power_flat", 15, nil, 2, 0},
	},
	[9343] = {
			{"by_school", "sp_dmg_flat", 14, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 14, nil, 2, 1},
	},
	[400014] = {
			{"by_school", "threat", 1.65, {1,2,3,4,5,6,7,}, 0, 1},
			{"by_school", "dmg_mod", -0.19999999, {1,2,3,4,5,6,7,}, 1, 9},
			{"raw", "phys_mod", -0.19999999, nil, 1, 9},
	},
	[21526] = {
			{"by_school", "sp_dmg_flat", 40, {2,}, 2, 0},
	},
	[430406] = {
			{"by_school", "spell_hit", 0.02, {1,2,3,4,5,6,7,}, 2, 0},
	},
	[21436] = {
			{"raw", "rap_flat", 26, nil, 2, 0},
	},
	[18023] = {
			{"by_school", "sp_dmg_flat", 47, {6,}, 2, 0},
	},
	[9411] = {
			{"by_school", "sp_dmg_flat", 14, {4,}, 2, 0},
	},
	[18042] = {
			{"raw", "healing_power_flat", 68, nil, 2, 0},
	},
	[9399] = {
			{"by_school", "sp_dmg_flat", 11, {3,}, 2, 0},
	},
	[9404] = {
			{"by_school", "sp_dmg_flat", 14, {5,}, 2, 0},
	},
	[21531] = {
			{"by_school", "sp_dmg_flat", 47, {2,}, 2, 0},
	},
	[18041] = {
			{"raw", "healing_power_flat", 66, nil, 2, 0},
	},
	[7708] = {
			{"by_school", "sp_dmg_flat", 7, {6,}, 2, 0},
	},
	[21513] = {
			{"by_school", "sp_dmg_flat", 21, {2,}, 2, 0},
	},
	[18030] = {
			{"raw", "healing_power_flat", 37, nil, 2, 0},
	},
	[17825] = {
			{"by_school", "sp_dmg_flat", 29, {7,}, 2, 0},
	},
	[13599] = {
			{"by_school", "sp_dmg_flat", 14, {7,}, 2, 0},
	},
	[16311] = {
			{"raw", "ap_flat", 211, nil, 2, 0},
	},
	[17320] = {
			{"raw", "healing_power_flat", 84, nil, 2, 0},
	},
	[9136] = {
			{"raw", "ap_flat", 2, nil, 2, 0},
			{"raw", "rap_flat", 2, nil, 2, 1},
	},
	[9402] = {
			{"by_school", "sp_dmg_flat", 11, {5,}, 2, 0},
	},
	[9141] = {
			{"raw", "ap_flat", 12, nil, 2, 0},
			{"raw", "rap_flat", 12, nil, 2, 1},
	},
	[17878] = {
			{"by_school", "sp_dmg_flat", 43, {3,}, 2, 0},
	},
	[13597] = {
			{"by_school", "sp_dmg_flat", 11, {7,}, 2, 0},
	},
	[9316] = {
			{"raw", "healing_power_flat", 29, nil, 2, 0},
	},
	[21517] = {
			{"by_school", "sp_dmg_flat", 27, {2,}, 2, 0},
	},
	[1220735] = {
			{"by_school", "sp_dmg_flat", 15, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 15, nil, 2, 1},
			{"by_school", "crit", 0.01, {2,3,4,5,6,7,}, 2, 2},
			{"raw", "phys_crit", 0.01, nil, 32, 3},
	},
	[7598] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
	},
	[7694] = {
			{"by_school", "sp_dmg_flat", 7, {4,}, 2, 0},
	},
	[15815] = {
			{"raw", "ap_flat", 58, nil, 2, 0},
			{"raw", "rap_flat", 58, nil, 2, 1},
	},
	[432137] = {
			{"raw", "melee_haste", 0.5, nil, 33, 0},
	},
	[15808] = {
			{"raw", "ap_flat", 38, nil, 2, 0},
			{"raw", "rap_flat", 38, nil, 2, 1},
	},
	[9393] = {
			{"by_school", "sp_dmg_flat", 2, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 2, nil, 2, 1},
	},
	[21453] = {
			{"raw", "rap_flat", 70, nil, 2, 0},
	},
	[7710] = {
			{"by_school", "sp_dmg_flat", 9, {6,}, 2, 0},
	},
	[24157] = {
			{"by_school", "sp_dmg_flat", 18, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 18, nil, 2, 1},
	},
	[7697] = {
			{"by_school", "sp_dmg_flat", 1, {5,}, 2, 0},
	},
	[16312] = {
			{"raw", "ap_flat", 393, nil, 2, 0},
	},
	[9358] = {
			{"by_school", "sp_dmg_flat", 17, {4,}, 2, 0},
	},
	[17886] = {
			{"by_school", "sp_dmg_flat", 53, {3,}, 2, 0},
	},
	[17990] = {
			{"by_school", "sp_dmg_flat", 27, {4,}, 2, 0},
	},
	[29474] = {
			{"raw", "healing_power_flat", 31, nil, 2, 1},
	},
	[18004] = {
			{"by_school", "sp_dmg_flat", 50, {4,}, 2, 0},
	},
	[21438] = {
			{"raw", "rap_flat", 31, nil, 2, 0},
	},
	[17829] = {
			{"by_school", "sp_dmg_flat", 34, {7,}, 2, 0},
	},
	[17867] = {
			{"by_school", "sp_dmg_flat", 26, {3,}, 2, 0},
	},
	[9408] = {
			{"raw", "healing_power_flat", 22, nil, 2, 0},
	},
	[442896] = {
			{"by_school", "spell_hit", 0.06, {4,}, 2, 0},
	},
	[7600] = {
			{"raw", "phys_crit", 0.04, nil, 32, 0},
	},
	[21429] = {
			{"raw", "rap_flat", 10, nil, 2, 0},
	},
	[17866] = {
			{"by_school", "sp_dmg_flat", 24, {3,}, 2, 0},
	},
	[17840] = {
			{"by_school", "sp_dmg_flat", 43, {7,}, 2, 0},
	},
	[21437] = {
			{"raw", "rap_flat", 29, nil, 2, 0},
	},
	[18037] = {
			{"raw", "healing_power_flat", 57, nil, 2, 0},
	},
	[13591] = {
			{"by_school", "sp_dmg_flat", 3, {7,}, 2, 0},
	},
	[9416] = {
			{"by_school", "sp_dmg_flat", 11, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 11, nil, 2, 1},
	},
	[15813] = {
			{"raw", "ap_flat", 54, nil, 2, 0},
			{"raw", "rap_flat", 54, nil, 2, 1},
	},
	[463873] = {
			{"by_school", "sp_dmg_flat", 30, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 55, nil, 2, 1},
	},
	[17906] = {
			{"by_school", "sp_dmg_flat", 47, {5,}, 2, 0},
	},
	[17837] = {
			{"by_school", "sp_dmg_flat", 39, {7,}, 2, 0},
	},
	[9344] = {
			{"by_school", "sp_dmg_flat", 15, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 15, nil, 2, 1},
	},
	[15831] = {
			{"raw", "ap_flat", 90, nil, 2, 0},
			{"raw", "rap_flat", 90, nil, 2, 1},
	},
	[9142] = {
			{"raw", "ap_flat", 14, nil, 2, 0},
			{"raw", "rap_flat", 14, nil, 2, 1},
	},
	[21516] = {
			{"by_school", "sp_dmg_flat", 26, {2,}, 2, 0},
	},
	[17887] = {
			{"by_school", "sp_dmg_flat", 54, {3,}, 2, 0},
	},
	[468350] = {
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 2},
			{"raw", "healing_power_flat", 12, nil, 2, 3},
	},
	[21525] = {
			{"by_school", "sp_dmg_flat", 39, {2,}, 2, 0},
	},
	[17905] = {
			{"by_school", "sp_dmg_flat", 46, {5,}, 2, 0},
	},
	[7679] = {
			{"raw", "healing_power_flat", 11, nil, 2, 0},
	},
	[17841] = {
			{"by_school", "sp_dmg_flat", 44, {7,}, 2, 0},
	},
	[21013] = {
			{"raw", "rap_flat", 60, nil, 2, 0},
	},
	[18006] = {
			{"by_school", "sp_dmg_flat", 53, {4,}, 2, 0},
	},
	[468367] = {
			{"raw", "phys_hit", 0.01, nil, 2, 1},
			{"by_school", "spell_hit", 0.01, {1,2,3,4,5,6,7,}, 2, 2},
	},
	[18017] = {
			{"by_school", "sp_dmg_flat", 39, {6,}, 2, 0},
	},
	[17903] = {
			{"by_school", "sp_dmg_flat", 44, {5,}, 2, 0},
	},
	[7597] = {
			{"raw", "phys_crit", 0.01, nil, 32, 0},
	},
	[21443] = {
			{"raw", "rap_flat", 43, nil, 2, 0},
	},
	[18044] = {
			{"raw", "healing_power_flat", 73, nil, 2, 0},
	},
	[25111] = {
			{"by_school", "sp_dmg_flat", 24, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 24, nil, 2, 1},
	},
	[21462] = {
			{"raw", "rap_flat", 91, nil, 2, 0},
	},
	[18012] = {
			{"by_school", "sp_dmg_flat", 31, {6,}, 2, 0},
	},
	[17875] = {
			{"by_school", "sp_dmg_flat", 40, {3,}, 2, 0},
	},
	[24154] = {
			{"raw", "rap_flat", 24, nil, 2, 0},
			{"raw", "phys_hit", 0.01, nil, 2, 1},
	},
	[7706] = {
			{"by_school", "sp_dmg_flat", 4, {6,}, 2, 0},
	},
	[7680] = {
			{"raw", "healing_power_flat", 13, nil, 2, 0},
	},
	[21524] = {
			{"by_school", "sp_dmg_flat", 37, {2,}, 2, 0},
	},
	[7686] = {
			{"by_school", "sp_dmg_flat", 6, {3,}, 2, 0},
	},
	[17822] = {
			{"by_school", "sp_dmg_flat", 17, {7,}, 2, 0},
	},
	[18001] = {
			{"by_school", "sp_dmg_flat", 46, {4,}, 2, 0},
	},
	[9417] = {
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 12, nil, 2, 1},
	},
	[468379] = {
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 2},
			{"raw", "healing_power_flat", 12, nil, 2, 3},
	},
	[25109] = {
			{"by_school", "sp_dmg_flat", 8, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 8, nil, 2, 1},
	},
	[1213830] = {
			{"by_school", "sp_dmg_flat", 10, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 10, nil, 2, 1},
	},
	[1213619] = {
			{"by_school", "sp_dmg_flat", 20, {2,}, 2, 0},
	},
	[18027] = {
			{"by_school", "sp_dmg_flat", 53, {6,}, 2, 0},
	},
	[1214006] = {
			{"by_school", "sp_dmg_flat", 45, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 45, nil, 2, 1},
			{"by_school", "crit", 0.01, {4,}, 2, 2},
	},
	[17998] = {
			{"by_school", "sp_dmg_flat", 41, {4,}, 2, 0},
	},
	[468343] = {
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 2},
			{"raw", "healing_power_flat", 12, nil, 2, 3},
	},
	[21930] = {
			{"by_school", "sp_dmg_flat", 7, {5,}, 2, 0},
	},
	[9297] = {
			{"by_school", "sp_dmg_flat", 20, {3,}, 2, 0},
	},
	[9410] = {
			{"by_school", "sp_dmg_flat", 9, {4,}, 2, 0},
	},
	[17819] = {
			{"by_school", "sp_dmg_flat", 29, {4,}, 2, 0},
	},
	[15830] = {
			{"raw", "ap_flat", 88, nil, 2, 0},
			{"raw", "rap_flat", 88, nil, 2, 1},
	},
	[9346] = {
			{"by_school", "sp_dmg_flat", 18, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 18, nil, 2, 1},
	},
	[9317] = {
			{"raw", "healing_power_flat", 31, nil, 2, 0},
	},
	[9406] = {
			{"raw", "healing_power_flat", 18, nil, 2, 0},
	},
	[21504] = {
			{"by_school", "sp_dmg_flat", 9, {2,}, 2, 0},
	},
	[21505] = {
			{"by_school", "sp_dmg_flat", 10, {2,}, 2, 0},
	},
	[17993] = {
			{"by_school", "sp_dmg_flat", 33, {4,}, 2, 0},
	},
	[21432] = {
			{"raw", "rap_flat", 17, nil, 2, 0},
	},
	[17996] = {
			{"by_school", "sp_dmg_flat", 39, {4,}, 2, 0},
	},
	[408496] = {
			{"raw", "offhand_mod", 0.5, nil, 2, 2},
	},
	[25113] = {
			{"by_school", "sp_dmg_flat", 36, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 36, nil, 2, 1},
			{"by_school", "crit", 0.01, {4,}, 2, 2},
	},
	[9315] = {
			{"raw", "healing_power_flat", 26, nil, 2, 0},
	},
	[13590] = {
			{"by_school", "sp_dmg_flat", 1, {7,}, 2, 0},
	},
	[7707] = {
			{"by_school", "sp_dmg_flat", 6, {6,}, 2, 0},
	},
	[471402] = {
			{"by_school", "sp_dmg_flat", 36, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 36, nil, 2, 1},
			{"by_school", "crit", 0.01, {4,}, 2, 2},
	},
	[17907] = {
			{"by_school", "sp_dmg_flat", 49, {5,}, 2, 0},
	},
	[9395] = {
			{"by_school", "sp_dmg_flat", 5, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 5, nil, 2, 1},
	},
	[21535] = {
			{"by_school", "sp_dmg_flat", 53, {2,}, 2, 0},
	},
	[21444] = {
			{"raw", "rap_flat", 46, nil, 2, 0},
	},
	[18011] = {
			{"by_school", "sp_dmg_flat", 30, {6,}, 2, 0},
	},
	[13594] = {
			{"by_school", "sp_dmg_flat", 7, {7,}, 2, 0},
	},
	[9334] = {
			{"raw", "ap_flat", 26, nil, 2, 0},
			{"raw", "rap_flat", 26, nil, 2, 1},
	},
	[7678] = {
			{"raw", "healing_power_flat", 9, nil, 2, 0},
	},
	[21519] = {
			{"by_school", "sp_dmg_flat", 30, {2,}, 2, 0},
	},
	[21503] = {
			{"by_school", "sp_dmg_flat", 7, {2,}, 2, 0},
	},
	[21426] = {
			{"raw", "rap_flat", 2, nil, 2, 0},
	},
	[7701] = {
			{"by_school", "sp_dmg_flat", 7, {5,}, 2, 0},
	},
	[415370] = {
			{"by_school", "dmg_mod", 0.29999998, {1,2,3,4,5,6,7,}, 1, 0},
			{"raw", "phys_mod", 0.29999998, nil, 1, 0},
	},
	[15832] = {
			{"raw", "ap_flat", 92, nil, 2, 0},
			{"raw", "rap_flat", 92, nil, 2, 1},
	},
	[17824] = {
			{"by_school", "sp_dmg_flat", 27, {7,}, 2, 0},
	},
	[442893] = {
			{"by_school", "spell_hit", 0.06, {7,}, 2, 0},
	},
	[9335] = {
			{"raw", "ap_flat", 28, nil, 2, 0},
			{"raw", "rap_flat", 28, nil, 2, 1},
	},
	[17894] = {
			{"by_school", "sp_dmg_flat", 31, {5,}, 2, 0},
	},
	[21428] = {
			{"raw", "rap_flat", 7, nil, 2, 0},
	},
	[17892] = {
			{"by_school", "sp_dmg_flat", 27, {5,}, 2, 0},
	},
	[9139] = {
			{"raw", "ap_flat", 8, nil, 2, 0},
			{"raw", "rap_flat", 8, nil, 2, 1},
	},
	[18019] = {
			{"by_school", "sp_dmg_flat", 41, {6,}, 2, 0},
	},
	[1220743] = {
			{"raw", "phys_crit", 0.01, nil, 32, 1},
			{"raw", "ap_flat", 26, nil, 2, 2},
			{"raw", "rap_flat", 26, nil, 2, 3},
			{"by_school", "crit", 0.01, {2,3,4,5,6,7,}, 2, 4},
	},
	[18013] = {
			{"by_school", "sp_dmg_flat", 33, {6,}, 2, 0},
	},
	[17899] = {
			{"by_school", "sp_dmg_flat", 39, {5,}, 2, 0},
	},
	[17838] = {
			{"by_school", "sp_dmg_flat", 40, {7,}, 2, 0},
	},
	[15568] = {
			{"raw", "ap_flat", 88, nil, 2, 0},
	},
	[17994] = {
			{"by_school", "sp_dmg_flat", 36, {4,}, 2, 0},
	},
	[17823] = {
			{"by_school", "sp_dmg_flat", 26, {7,}, 2, 0},
	},
	[7698] = {
			{"by_school", "sp_dmg_flat", 3, {5,}, 2, 0},
	},
	[9401] = {
			{"by_school", "sp_dmg_flat", 14, {3,}, 2, 0},
	},
	[17885] = {
			{"by_school", "sp_dmg_flat", 51, {3,}, 2, 0},
	},
	[468358] = {
			{"raw", "healing_power_flat", 22, nil, 2, 2},
	},
	[22780] = {
			{"wpn_subclass", "phys_hit", 0.03, {262156}, 8, 0},
	},
	[9327] = {
			{"by_school", "sp_dmg_flat", 20, {6,}, 2, 0},
	},
	[29468] = {
			{"by_school", "sp_dmg_flat", 15, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 15, nil, 2, 1},
			{"by_school", "crit", 0.01, {1,}, 2, 2},
	},
	[18005] = {
			{"by_school", "sp_dmg_flat", 51, {4,}, 2, 0},
	},
	[7703] = {
			{"by_school", "sp_dmg_flat", 10, {5,}, 2, 0},
	},
	[17910] = {
			{"by_school", "sp_dmg_flat", 56, {5,}, 2, 0},
	},
	[9398] = {
			{"by_school", "sp_dmg_flat", 8, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 8, nil, 2, 1},
	},
	[9307] = {
			{"by_school", "sp_dmg_flat", 20, {5,}, 2, 0},
	},
	[9333] = {
			{"raw", "ap_flat", 48, nil, 2, 0},
			{"raw", "rap_flat", 48, nil, 2, 1},
	},
	[442895] = {
			{"by_school", "spell_hit", 0.06, {5,}, 2, 0},
	},
	[467387] = {
			{"by_school", "threat", -0.19999999, {3,}, 0, 0},
	},
	[18033] = {
			{"raw", "healing_power_flat", 46, nil, 2, 0},
	},
	[10400] = {
			{"raw", "ap_flat", 29, nil, 2, 0},
	},
	[17900] = {
			{"by_school", "sp_dmg_flat", 40, {5,}, 2, 0},
	},
	[13605] = {
			{"by_school", "sp_dmg_flat", 21, {7,}, 2, 0},
	},
	[15819] = {
			{"raw", "ap_flat", 68, nil, 2, 0},
			{"raw", "rap_flat", 68, nil, 2, 1},
	},
	[9415] = {
			{"by_school", "sp_dmg_flat", 9, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 9, nil, 2, 1},
	},
	[21512] = {
			{"by_school", "sp_dmg_flat", 20, {2,}, 2, 0},
	},
	[7696] = {
			{"by_school", "sp_dmg_flat", 10, {4,}, 2, 0},
	},
	[467539] = {
			{"raw", "regen_while_casting", 0.14999999, nil, 0, 0},
	},
	[9294] = {
			{"by_school", "sp_dmg_flat", 16, {3,}, 2, 0},
	},
	[9336] = {
			{"raw", "ap_flat", 30, nil, 2, 0},
			{"raw", "rap_flat", 30, nil, 2, 1},
	},
	[21427] = {
			{"raw", "rap_flat", 5, nil, 2, 0},
	},
	[18002] = {
			{"by_school", "sp_dmg_flat", 47, {4,}, 2, 0},
	},
	[9296] = {
			{"by_school", "sp_dmg_flat", 19, {3,}, 2, 0},
	},
	[9328] = {
			{"by_school", "sp_dmg_flat", 21, {6,}, 2, 0},
	},
	[15816] = {
			{"raw", "ap_flat", 62, nil, 2, 0},
			{"raw", "rap_flat", 62, nil, 2, 1},
	},
	[9409] = {
			{"by_school", "sp_dmg_flat", 11, {4,}, 2, 0},
	},
	[24156] = {
			{"by_school", "sp_dmg_flat", 18, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 18, nil, 2, 1},
			{"by_school", "spell_hit", 0.01, {1,2,3,4,5,6,7,}, 2, 2},
	},
	[457530] = {
			{"raw", "phys_crit", 0.02, nil, 32, 0},
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[25067] = {
			{"raw", "healing_power_flat", 30, nil, 2, 0},
	},
	[17987] = {
			{"by_school", "sp_dmg_flat", 23, {4,}, 2, 0},
	},
	[17872] = {
			{"by_school", "sp_dmg_flat", 34, {3,}, 2, 0},
	},
	[15817] = {
			{"raw", "ap_flat", 64, nil, 2, 0},
			{"raw", "rap_flat", 64, nil, 2, 1},
	},
	[22841] = {
			{"raw", "melee_haste", 0.01, nil, 33, 0},
			{"raw", "ranged_haste", 0.01, nil, 33, 1},
	},
	[18045] = {
			{"raw", "healing_power_flat", 75, nil, 2, 0},
	},
	[17873] = {
			{"by_school", "sp_dmg_flat", 36, {3,}, 2, 0},
	},
	[17832] = {
			{"by_school", "sp_dmg_flat", 37, {7,}, 2, 0},
	},
	[468329] = {
			{"by_school", "sp_dmg_flat", 12, {1,2,3,4,5,6,7,}, 2, 2},
			{"raw", "healing_power_flat", 12, nil, 2, 3},
	},
	[9400] = {
			{"by_school", "sp_dmg_flat", 13, {3,}, 2, 0},
	},
	[18040] = {
			{"raw", "healing_power_flat", 64, nil, 2, 0},
	},
	[21445] = {
			{"raw", "rap_flat", 48, nil, 2, 0},
	},
	[17827] = {
			{"by_school", "sp_dmg_flat", 31, {7,}, 2, 0},
	},
	[9330] = {
			{"raw", "ap_flat", 18, nil, 2, 0},
			{"raw", "rap_flat", 18, nil, 2, 1},
	},
	[13604] = {
			{"by_school", "sp_dmg_flat", 20, {7,}, 2, 0},
	},
	[21447] = {
			{"raw", "rap_flat", 53, nil, 2, 0},
	},
	[15814] = {
			{"raw", "ap_flat", 56, nil, 2, 0},
			{"raw", "rap_flat", 56, nil, 2, 1},
	},
	[9318] = {
			{"raw", "healing_power_flat", 33, nil, 2, 0},
	},
	[15823] = {
			{"raw", "ap_flat", 74, nil, 2, 0},
			{"raw", "rap_flat", 74, nil, 2, 1},
	},
	[468341] = {
			{"raw", "healing_power_flat", 22, nil, 2, 2},
	},
	[15818] = {
			{"raw", "ap_flat", 66, nil, 2, 0},
			{"raw", "rap_flat", 66, nil, 2, 1},
	},
	[17828] = {
			{"by_school", "sp_dmg_flat", 33, {7,}, 2, 0},
	},
	[17849] = {
			{"by_school", "sp_dmg_flat", 58, {7,}, 2, 0},
	},
	[7688] = {
			{"by_school", "sp_dmg_flat", 9, {3,}, 2, 0},
	},
	[15824] = {
			{"raw", "ap_flat", 76, nil, 2, 0},
			{"raw", "rap_flat", 76, nil, 2, 1},
	},
	[21450] = {
			{"raw", "rap_flat", 62, nil, 2, 0},
	},
	[9295] = {
			{"by_school", "sp_dmg_flat", 17, {3,}, 2, 0},
	},
	[21614] = {
			{"raw", "healing_power_flat", 14, nil, 2, 0},
	},
	[15825] = {
			{"raw", "ap_flat", 78, nil, 2, 0},
			{"raw", "rap_flat", 78, nil, 2, 1},
	},
	[442898] = {
			{"by_school", "spell_hit", 0.06, {2,}, 2, 0},
	},
	[21454] = {
			{"raw", "rap_flat", 72, nil, 2, 0},
	},
	[17845] = {
			{"by_school", "sp_dmg_flat", 49, {7,}, 2, 0},
	},
	[21448] = {
			{"raw", "rap_flat", 55, nil, 2, 0},
	},
	[21530] = {
			{"by_school", "sp_dmg_flat", 46, {2,}, 2, 0},
	},
	[24151] = {
			{"raw", "healing_power_flat", 24, nil, 2, 2},
	},
	[9326] = {
			{"by_school", "sp_dmg_flat", 19, {6,}, 2, 0},
	},
	[18014] = {
			{"by_school", "sp_dmg_flat", 34, {6,}, 2, 0},
	},
	[17909] = {
			{"by_school", "sp_dmg_flat", 51, {5,}, 2, 0},
	},
	[15828] = {
			{"raw", "ap_flat", 84, nil, 2, 0},
			{"raw", "rap_flat", 84, nil, 2, 1},
	},
	[21452] = {
			{"raw", "rap_flat", 67, nil, 2, 0},
	},
	[21506] = {
			{"by_school", "sp_dmg_flat", 11, {2,}, 2, 0},
	},
	[13598] = {
			{"by_school", "sp_dmg_flat", 13, {7,}, 2, 0},
	},
	[24158] = {
			{"raw", "healing_power_flat", 24, nil, 2, 2},
	},
	[18003] = {
			{"by_school", "sp_dmg_flat", 49, {4,}, 2, 0},
	},
	[17869] = {
			{"by_school", "sp_dmg_flat", 30, {3,}, 2, 0},
	},
	[24155] = {
			{"by_school", "sp_dmg_flat", 13, {1,2,3,4,5,6,7,}, 2, 0},
			{"raw", "healing_power_flat", 13, nil, 2, 1},
	},
	[7709] = {
			{"by_school", "sp_dmg_flat", 10, {6,}, 2, 0},
	},
	[13602] = {
			{"by_school", "sp_dmg_flat", 17, {7,}, 2, 0},
	},
	[17844] = {
			{"by_school", "sp_dmg_flat", 47, {7,}, 2, 0},
	},
	[21502] = {
			{"by_school", "sp_dmg_flat", 6, {2,}, 2, 0},
	},
	[9308] = {
			{"by_school", "sp_dmg_flat", 21, {5,}, 2, 0},
	},
	[15811] = {
			{"raw", "ap_flat", 46, nil, 2, 0},
			{"raw", "rap_flat", 48, nil, 2, 1},
	},
	[7599] = {
			{"raw", "phys_crit", 0.03, nil, 32, 0},
	},
	[15829] = {
			{"raw", "ap_flat", 86, nil, 2, 0},
			{"raw", "rap_flat", 86, nil, 2, 1},
	},
	[21511] = {
			{"by_school", "sp_dmg_flat", 19, {2,}, 2, 0},
	},
	[21460] = {
			{"raw", "rap_flat", 86, nil, 2, 0},
	},
	[7705] = {
			{"by_school", "sp_dmg_flat", 3, {6,}, 2, 0},
	},
	[9331] = {
			{"raw", "ap_flat", 20, nil, 2, 0},
			{"raw", "rap_flat", 20, nil, 2, 1},
	},
	[18048] = {
			{"raw", "healing_power_flat", 81, nil, 2, 0},
	},
	[9325] = {
			{"by_school", "sp_dmg_flat", 17, {6,}, 2, 0},
	},
	[9305] = {
			{"by_school", "sp_dmg_flat", 17, {5,}, 2, 0},
	},
	[457532] = {
			{"by_school", "crit", 0.02, {2,3,4,5,6,7,}, 2, 1},
	},
	[17684] = {
			{"by_school", "sp_dmg_flat", 39, {3,}, 2, 0},
	},
	[18022] = {
			{"by_school", "sp_dmg_flat", 46, {6,}, 2, 0},
	},
	[18047] = {
			{"raw", "healing_power_flat", 79, nil, 2, 0},
	},
	[18015] = {
			{"by_school", "sp_dmg_flat", 36, {6,}, 2, 0},
	},
	[21500] = {
			{"by_school", "sp_dmg_flat", 3, {2,}, 2, 0},
	},
	[21523] = {
			{"by_school", "sp_dmg_flat", 36, {2,}, 2, 0},
	},
	[7675] = {
			{"raw", "healing_power_flat", 2, nil, 2, 0},
	},
	[15807] = {
			{"raw", "ap_flat", 32, nil, 2, 0},
			{"raw", "rap_flat", 32, nil, 2, 1},
	},
	[21533] = {
			{"by_school", "sp_dmg_flat", 50, {2,}, 2, 0},
	},
	[9298] = {
			{"by_school", "sp_dmg_flat", 21, {3,}, 2, 0},
	},
	[17889] = {
			{"by_school", "sp_dmg_flat", 23, {5,}, 2, 0},
	},
	[7677] = {
			{"raw", "healing_power_flat", 7, nil, 2, 0},
	},
	[18025] = {
			{"by_school", "sp_dmg_flat", 50, {6,}, 2, 0},
	},
};
sc.enchants = {
	[7791] = {457323,},
	[7266] = {440533,},
	[2113] = {17846,},
	[7000] = {415096,},
	[1601] = {14049,},
	[2237] = {7703,},
	[2277] = {9410,},
	[216] = {7686,},
	[7664] = {1220596,},
	[2162] = {9399,},
	[223] = {7693,},
	[7046] = {415327,},
	[7720] = {468028,},
	[1593] = {14027,},
	[7024] = {425198,},
	[7861] = {467208,},
	[2167] = {9296,},
	[7750] = {467586,},
	[7123] = {432137,},
	[7623] = {468343,},
	[7262] = {440113,},
	[7831] = {457520,},
	[7487] = {9343,},
	[7515] = {442894,},
	[2130] = {9327,},
	[2264] = {17907,},
	[6966] = {426157,},
	[7845] = {467221,},
	[7734] = {468417,},
	[7807] = {1213467,},
	[7671] = {468072,},
	[6742] = {402000,},
	[2293] = {17994,},
	[7708] = {457549,},
	[2082] = {13593,},
	[2153] = {18027,},
	[2085] = {13596,},
	[7765] = {456481,},
	[6977] = {414719,},
	[2091] = {13603,},
	[2330] = {15696,},
	[2227] = {21533,},
	[2225] = {21531,},
	[7643] = {440870,},
	[2301] = {18002,},
	[2198] = {21504,},
	[2434] = {21614,},
	[2303] = {18004,},
	[2134] = {18008,},
	[225] = {7695,},
	[2081] = {13592,},
	[7620] = {468331,},
	[1585] = {9139,},
	[1610] = {15815,},
	[436] = {9405,},
	[2112] = {17845,},
	[2117] = {7704,},
	[7326] = {446470,},
	[1592] = {9332,},
	[222] = {7692,},
	[2172] = {17867,},
	[2224] = {21530,},
	[2329] = {18035,},
	[2230] = {21536,},
	[2316] = {9408,},
	[2333] = {18038,},
	[7759] = {467624,},
	[2184] = {17878,},
	[2307] = {7675,},
	[7268] = {440569,},
	[219] = {7689,},
	[7628] = {468358,},
	[2205] = {21511,},
	[7731] = {467326,},
	[7758] = {467608,},
	[2155] = {7683,},
	[7049] = {458318,},
	[7788] = {1213410,},
	[7486] = {9345,},
	[7737] = {456389,},
	[211] = {7680,},
	[6878] = {408438,},
	[1603] = {15810,},
	[2587] = {24155,},
	[2141] = {18015,},
	[7707] = {457548,},
	[7724] = {1214095,},
	[7650] = {1214006,},
	[2197] = {21503,},
	[441] = {9407,},
	[7102] = {417145,},
	[2231] = {7697,},
	[2161] = {7689,},
	[2274] = {7695,},
	[7224] = {436364,},
	[2721] = {29468,},
	[2341] = {18046,},
	[7516] = {442895,},
	[2523] = {22780,},
	[6874] = {408496,},
	[7846] = {467227,},
	[7627] = {468352,},
	[7670] = {457820,},
	[7702] = {467746,},
	[2058] = {21444,},
	[7722] = {468061,},
	[1591] = {9331,},
	[2077] = {21462,},
	[6957] = {412798,},
	[6967] = {429142,},
	[2176] = {17870,},
	[2252] = {17894,},
	[7787] = {467536,},
	[7108] = {428717,},
	[446] = {9412,},
	[2289] = {17991,},
	[7124] = {17768,},
	[7638] = {468758,},
	[7746] = {456546,},
	[2139] = {18013,},
	[2182] = {17875,},
	[2617] = {25067,},
	[196] = {7598,},
	[6963] = {415059,},
	[2629] = {25116,},
	[7790] = {456488,},
	[2193] = {21499,},
	[6793] = {402877,},
	[2159] = {7687,},
	[7838] = {1213957,},
	[7053] = {426243,},
	[2147] = {18021,},
	[2322] = {18029,},
	[2098] = {17825,},
	[2086] = {13597,},
	[235] = {7705,},
	[1665] = {436519,},
	[2298] = {17999,},
	[6922] = {412324,},
	[2136] = {18010,},
	[2259] = {17901,},
	[7619] = {468329,},
	[2051] = {21437,},
	[2232] = {7698,},
	[2165] = {9294,},
	[2319] = {9316,},
	[2585] = {24153,},
	[7864] = {1213174,},
	[2108] = {17840,},
	[1664] = {16313,},
	[1589] = {9329,},
	[7820] = {467809,},
	[7045] = {425738,},
	[2279] = {9357,},
	[1615] = {15819,},
	[2324] = {18031,},
	[7690] = {457344,},
	[7696] = {468436,},
	[236] = {7706,},
	[7699] = {457349,},
	[2157] = {7685,},
	[7088] = {429142,},
	[7780] = {1213319,},
	[2297] = {17998,},
	[7815] = {1213937,},
	[7743] = {1213307,},
	[2160] = {7688,},
	[2308] = {7676,},
	[7634] = {468379,},
	[2043] = {21429,},
	[2288] = {17819,},
	[7721] = {468046,},
	[2294] = {17995,},
	[2234] = {7700,},
	[2544] = {22843,},
	[2311] = {7679,},
	[2235] = {7701,},
	[2323] = {18030,},
	[7762] = {1213708,},
	[2614] = {25064,},
	[210] = {7679,},
	[2064] = {21013,},
	[7488] = {9317,},
	[2169] = {9298,},
	[7050] = {426158,},
	[7686] = {468453,},
	[1594] = {9334,},
	[7776] = {467387,},
	[2052] = {21438,},
	[7489] = {14254,},
	[2284] = {17987,},
	[437] = {9402,},
	[7038] = {425464,},
	[7856] = {1213160,},
	[2238] = {9402,},
	[2327] = {18033,},
	[2217] = {21523,},
	[444] = {9410,},
	[2062] = {21448,},
	[683] = {16312,},
	[1597] = {15807,},
	[2616] = {25065,},
	[7625] = {468348,},
	[2120] = {7707,},
	[212] = {7681,},
	[1608] = {15813,},
	[2093] = {13605,},
	[2099] = {17826,},
	[6858] = {407977,},
	[7614] = {468316,},
	[2342] = {18047,},
	[447] = {9413,},
	[7857] = {455864,},
	[2211] = {21517,},
	[197] = {7599,},
	[7774] = {456398,},
	[208] = {7677,},
	[2135] = {18009,},
	[7034] = {462885,},
	[7132] = {432271,},
	[7802] = {467529,},
	[213] = {7683,},
	[2154] = {18028,},
	[1598] = {15806,},
	[434] = {9400,},
	[2174] = {13830,},
	[7602] = {25111,},
	[2270] = {7691,},
	[218] = {7688,},
	[2337] = {18042,},
	[7051] = {426065,},
	[7569] = {439431,},
	[7037] = {425412,},
	[7647] = {1213625,},
	[1605] = {9333,},
	[2269] = {7690,},
	[7773] = {456396,},
	[2173] = {17868,},
	[2073] = {21458,},
	[2076] = {21461,},
	[2318] = {9315,},
	[7128] = {432140,},
	[7704] = {467803,},
	[2152] = {18026,},
	[435] = {9401,},
	[6901] = {415370,},
	[2149] = {18023,},
	[2209] = {21515,},
	[2080] = {13591,},
	[214] = {7684,},
	[2069] = {21454,},
	[1611] = {14052,},
	[6800] = {403195,},
	[7560] = {400624,},
	[2302] = {18003,},
	[442] = {9408,},
	[2290] = {17992,},
	[7728] = {456379,},
	[2251] = {17893,},
	[7781] = {1213321,},
	[2609] = {9344,},
	[7622] = {468341,},
	[6987] = {415231,},
	[1620] = {15825,},
	[7824] = {457530,},
	[7835] = {467863,},
	[7768] = {467494,},
	[2178] = {17872,},
	[7716] = {468447,},
	[448] = {9414,},
	[6] = {15567,},
	[7817] = {457478,},
	[7106] = {408248,},
	[224] = {7694,},
	[2187] = {17881,},
	[2071] = {21456,},
	[2336] = {18041,},
	[1596] = {9336,},
	[7637] = {458393,},
	[2106] = {17838,},
	[2283] = {9361,},
	[1602] = {15809,},
	[1625] = {15830,},
	[2175] = {17869,},
	[7618] = {468327,},
	[2253] = {17895,},
	[2075] = {21460,},
	[2151] = {18025,},
	[7832] = {457524,},
	[6998] = {415352,},
	[7869] = {467084,},
	[2317] = {9314,},
	[1604] = {15811,},
	[2189] = {17884,},
	[7786] = {467532,},
	[2328] = {18034,},
	[7862] = {467211,},
	[1563] = {9136,},
	[2042] = {21428,},
	[2191] = {17886,},
	[6980] = {415100,},
	[2245] = {9308,},
	[2072] = {21457,},
	[426] = {9395,},
	[2215] = {21521,},
	[7013] = {417046,},
	[2114] = {17847,},
	[2118] = {7705,},
	[1666] = {436519,},
	[6811] = {403668,},
	[2194] = {21500,},
	[2344] = {17320,},
	[1627] = {15832,},
	[2320] = {9317,},
	[2243] = {9306,},
	[7630] = {468363,},
	[7727] = {457324,},
	[6950] = {412689,},
	[429] = {9398,},
	[2310] = {7678,},
	[2196] = {21502,},
	[2206] = {21512,},
	[2261] = {17903,},
	[2306] = {18007,},
	[2127] = {9324,},
	[2543] = {22841,},
	[7771] = {468425,},
	[7818] = {457494,},
	[2048] = {21434,},
	[2244] = {9307,},
	[7730] = {467312,},
	[217] = {7687,},
	[2092] = {13604,},
	[2613] = {25063,},
	[2343] = {18048,},
	[2061] = {21447,},
	[1609] = {15814,},
	[1626] = {15831,},
	[2079] = {13590,},
	[2276] = {9409,},
	[2626] = {25110,},
	[7827] = {467879,},
	[2129] = {9326,},
	[2305] = {18006,},
	[2070] = {21455,},
	[2335] = {18040,},
	[2621] = {25070,},
	[1663] = {16311,},
	[2204] = {21510,},
	[7482] = {9394,},
	[2612] = {9346,},
	[2138] = {18012,},
	[2223] = {21529,},
	[2313] = {7681,},
	[438] = {9403,},
	[2068] = {21453,},
	[2115] = {17848,},
	[2116] = {17849,},
	[2216] = {21522,},
	[7092] = {429133,},
	[2146] = {18020,},
	[6936] = {415739,},
	[2254] = {17896,},
	[2281] = {9359,},
	[2090] = {13602,},
	[1587] = {9141,},
	[2589] = {24157,},
	[7655] = {9417,},
	[7626] = {468350,},
	[7026] = {425266,},
	[2506] = {22755,},
	[7741] = {467333,},
	[7519] = {442898,},
	[7646] = {1213619,},
	[1621] = {15826,},
	[228] = {7698,},
	[2124] = {9412,},
	[6953] = {412732,},
	[7866] = {455858,},
	[2257] = {17899,},
	[7692] = {467737,},
	[2102] = {17829,},
	[1606] = {14056,},
	[2608] = {9342,},
	[7752] = {1213631,},
	[1617] = {15821,},
	[2089] = {13601,},
	[2212] = {21518,},
	[2304] = {18005,},
	[7850] = {456222,},
	[7105] = {417149,},
	[2133] = {14794,},
	[2100] = {17827,},
	[7884] = {1220743,},
	[2097] = {17824,},
	[7778] = {467399,},
	[2183] = {17876,},
	[6975] = {414677,},
	[2181] = {17684,},
	[2241] = {9304,},
	[7514] = {442893,},
	[7017] = {424925,},
	[7830] = {1213918,},
	[2233] = {7699,},
	[6994] = {415413,},
	[2096] = {17823,},
	[2041] = {21427,},
	[2087] = {13598,},
	[220] = {7690,},
	[6859] = {417051,},
	[6708] = {399965,433521,},
	[2262] = {17905,},
	[7271] = {440672,},
	[1614] = {15818,},
	[2220] = {21526,},
	[2132] = {14793,},
	[232] = {7702,},
	[2163] = {9400,},
	[7675] = {1214163,},
	[7621] = {468336,},
	[2201] = {21507,},
	[2260] = {17902,},
	[2046] = {21432,},
	[2063] = {21449,},
	[7825] = {457532,},
	[2185] = {17879,},
	[2267] = {17910,},
	[7844] = {467216,},
	[2105] = {17837,},
	[2240] = {9404,},
	[2504] = {22747,},
	[2222] = {21528,},
	[2103] = {17830,},
	[2179] = {17873,},
	[7701] = {457464,},
	[2591] = {24159,},
	[4] = {436519,},
	[2104] = {17832,},
	[7098] = {430391,},
	[2325] = {18032,},
	[7109] = {431622,},
	[2296] = {17997,},
	[2219] = {21525,},
	[2588] = {24156,},
	[2263] = {17906,},
	[2101] = {17828,},
	[7041] = {425589,},
	[2107] = {17839,},
	[195] = {7597,},
	[439] = {9404,},
	[2202] = {21508,},
	[7027] = {425280,},
	[2309] = {7677,},
	[2199] = {21505,},
	[7669] = {457697,},
	[2144] = {18018,},
	[7590] = {403511,},
	[7729] = {467235,},
	[2122] = {7710,},
	[7819] = {467804,},
	[428] = {9397,},
	[2250] = {13831,},
	[7617] = {468324,},
	[7795] = {467513,},
	[29] = {10400,},
	[445] = {9411,},
	[207] = {7676,},
	[1619] = {15824,},
	[7828] = {467882,},
	[7742] = {467334,},
	[2291] = {17993,},
	[198] = {7600,},
	[7693] = {467739,},
	[2049] = {21435,},
	[2047] = {21433,},
	[7518] = {442897,},
	[2226] = {21532,},
	[2312] = {7680,},
	[7715] = {468446,},
	[2040] = {21426,},
	[427] = {9396,},
	[2315] = {9407,},
	[7712] = {467988,},
	[2213] = {21519,},
	[2111] = {17844,},
	[7777] = {467388,},
	[230] = {7700,},
	[2140] = {18014,},
	[2334] = {18039,},
	[7812] = {467909,},
	[215] = {7685,},
	[7517] = {442896,},
	[1599] = {14089,},
	[7613] = {468312,},
	[2275] = {7696,},
	[7883] = {1220735,},
	[2229] = {21535,},
	[7748] = {467539,},
	[440] = {9406,},
	[2190] = {17885,},
	[1612] = {15816,},
	[2239] = {9403,},
	[2236] = {7702,},
	[2285] = {17988,},
	[2339] = {18044,},
	[2128] = {9325,},
	[7603] = {463873,},
	[7789] = {1213413,},
	[7328] = {446450,},
	[2590] = {24158,},
	[2221] = {21527,},
	[2249] = {17892,},
	[7099] = {430406,},
	[2050] = {21436,},
	[2207] = {21513,},
	[6982] = {415140,},
	[233] = {7703,},
	[1583] = {9137,},
	[2094] = {17821,},
	[7797] = {1213353,},
	[1] = {15568,},
	[2166] = {9295,},
	[7048] = {425858,},
	[2168] = {9297,},
	[1618] = {15823,},
	[2505] = {22748,},
	[2125] = {9413,},
	[2321] = {9318,},
	[7779] = {1213318,},
	[2623] = {25109,},
	[221] = {7691,},
	[2715] = {29474,},
	[2059] = {21445,},
	[2605] = {9346,},
	[2188] = {17882,},
	[2627] = {25111,},
	[2331] = {18036,},
	[2278] = {9411,},
	[3] = {436519,},
	[2268] = {17911,},
	[2266] = {17909,},
	[2606] = {9336,},
	[7134] = {432273,},
	[2340] = {18045,},
	[7863] = {1213171,},
	[1613] = {15817,},
	[7799] = {456533,},
	[7483] = {7677,},
	[2095] = {17822,},
	[2295] = {17996,},
	[2142] = {18016,},
	[2164] = {9401,},
	[7775] = {456402,},
	[209] = {7678,},
	[2214] = {21520,},
	[7133] = {432276,},
	[1584] = {9138,},
	[7859] = {455873,},
	[2248] = {17891,},
	[234] = {7704,},
	[6933] = {413251,},
	[6999] = {415358,},
	[7126] = {432056,},
	[7265] = {440520,},
	[2045] = {21431,},
	[2158] = {7686,},
	[7324] = {446450,},
	[443] = {9409,},
	[2074] = {21459,},
	[6889] = {409428,},
	[2083] = {13594,},
	[2088] = {13599,},
	[2121] = {7708,},
	[2628] = {25113,},
	[7726] = {456337,},
	[2055] = {21441,},
	[7754] = {468434,},
	[2292] = {16638,},
	[7668] = {457652,},
	[2604] = {9318,},
	[432] = {9417,},
	[503] = {15569,},
	[227] = {7697,},
	[7673] = {468236,},
	[424] = {9393,},
	[6726] = {412115,},
	[7798] = {456494,},
	[206] = {7675,},
	[240] = {7709,},
	[6815] = {403666,},
	[2566] = {23796,},
	[238] = {7708,},
	[2126] = {9414,},
	[2286] = {17989,},
	[7567] = {436519,},
	[2067] = {21452,},
	[7766] = {467401,},
	[7733] = {1213246,},
	[1590] = {9330,},
	[2242] = {9305,},
	[7784] = {456541,},
	[2044] = {21430,},
	[433] = {9399,},
	[7642] = {440892,},
	[7115] = {427713,},
	[425] = {9394,},
	[2110] = {17842,},
	[2282] = {9360,},
	[2109] = {17841,},
	[7849] = {456194,},
	[6879] = {408498,},
	[239] = {7710,},
	[2148] = {18022,},
	[7813] = {467916,},
	[2265] = {17908,},
	[6799] = {412507,},
	[1623] = {15828,},
	[5] = {436519,},
	[231] = {7701,},
	[2056] = {21442,},
	[2314] = {9406,},
	[2273] = {7694,},
	[283] = {439431,},
	[7270] = {462834,},
	[2228] = {21534,},
	[2332] = {18037,},
	[2287] = {17990,},
	[7644] = {471402,},
	[2065] = {21450,},
	[2200] = {21506,},
	[1669] = {439431,},
	[7738] = {456341,},
	[2119] = {7706,},
	[2123] = {7709,},
	[2053] = {21439,},
	[431] = {9416,},
	[7706] = {1213759,},
	[430] = {9415,},
	[1607] = {15812,},
	[2156] = {7684,},
	[2584] = {24151,},
	[1600] = {15808,},
	[2060] = {21446,},
	[7792] = {456492,},
	[7568] = {16313,},
	[2443] = {21930,},
	[2256] = {17898,},
	[2586] = {24154,},
	[7705] = {1213754,},
	[226] = {7696,},
	[7019] = {425096,},
	[2180] = {17874,},
	[7631] = {468367,},
	[6734] = {400615,},
	[2300] = {18001,},
	[7732] = {1213306,},
	[6710] = {400014,},
	[284] = {439431,},
	[2143] = {18017,},
	[2610] = {9343,},
	[2607] = {9417,},
	[7809] = {457541,},
	[6892] = {409687,},
	[2246] = {17889,},
	[2280] = {9358,},
	[931] = {13928,},
	[7648] = {1213830,},
	[7718] = {457572,},
	[2210] = {21516,},
	[2299] = {18000,},
	[525] = {439431,},
	[7325] = {446458,},
	[2338] = {18043,},
	[2326] = {17371,},
	[2131] = {9328,},
	[34] = {7217,},
	[1622] = {15827,},
	[2611] = {9346,},
	[2255] = {17897,},
	[2137] = {18011,},
	[2218] = {21524,},
	[2203] = {21509,},
	[7681] = {468069,},
	[2208] = {21514,},
	[6729] = {412286,},
	[2171] = {17866,},
	[7261] = {440484,},
	[2170] = {17747,},
	[1588] = {9142,},
	[2054] = {21440,},
	[1586] = {9140,},
	[1595] = {9335,},
	[1616] = {15820,},
	[2066] = {21451,},
	[2258] = {17900,},
	[2192] = {17887,},
	[2150] = {18024,},
	[2057] = {21443,},
	[2195] = {21501,},
	[2247] = {17890,},
	[2271] = {7692,},
	[7688] = {457329,},
	[2272] = {7693,},
	[523] = {436519,},
	[7767] = {467405,},
	[7562] = {458860,},
	[229] = {7699,},
	[2177] = {17871,},
	[237] = {7707,},
	[1624] = {15829,},
	[423] = {9392,},
	[2145] = {18019,},
	[2186] = {17880,},
	[2615] = {25066,},
	[2717] = {29482,},
	[2084] = {13595,},
};
sc.npc_armor_by_lvl = {20, 21, 46, 82, 126, 180, 245, 322, 412, 518, 545, 580, 615, 650, 685, 721, 756, 791, 826, 861, 897, 932, 967, 1002, 1037, 1072, 1108, 1142, 1172, 1212, 1247, 1283, 1317, 1353, 1387, 1494, 1607, 1724, 1849, 1980, 2117, 2262, 2414, 2574, 2742, 2798, 2853, 2907, 2963, 3018, 3072, 3128, 3183, 3237, 3292, 3348, 3402, 3457, 3512, 3566, 3622, 3677, 3731, };
sc.passives = {
	[6311] = {
			{"raw", "phys_dmg_flat", 1, nil, 0, 0},
	},
	[20591] = {
			{"by_attr", "stat_mod", 0.049999997, {4,}, 0, 0},
	},
	[1178] = {
			{"raw", "ap_flat", 30, nil, 2, 2},
	},
	[6315] = {
			{"raw", "phys_dmg_flat", 4, nil, 0, 0},
	},
	[6316] = {
			{"raw", "phys_dmg_flat", 6, nil, 0, 0},
	},
	[18739] = {
			{"raw", "mana_mod", 0, nil, 0, 0},
	},
	[17223] = {
			{"raw", "phys_mod", 0, nil, 1, 0},
	},
	[17212] = {
			{"raw", "phys_mod", 0, nil, 1, 0},
	},
	[18730] = {
			{"raw", "phys_mod", 0, nil, 1, 0},
	},
	[17215] = {
			{"raw", "phys_mod", 0, nil, 1, 0},
	},
	[19382] = {
			{"wpn_subclass", "phys_mod", 0.02, {173555}, 9, 0},
	},
	[18729] = {
			{"raw", "phys_mod", 0, nil, 1, 0},
	},
	[17208] = {
			{"raw", "phys_mod", -0.089999996, nil, 1, 0},
	},
	[20598] = {
			{"by_attr", "stat_mod", 0.049999997, {5,}, 0, 0},
	},
	[18727] = {
			{"raw", "phys_mod", 0, nil, 1, 0},
	},
	[17220] = {
			{"raw", "phys_mod", 0, nil, 1, 0},
	},
	[17221] = {
			{"raw", "phys_mod", -0.099999994, nil, 1, 0},
	},
	[17206] = {
			{"raw", "phys_mod", 0.07, nil, 1, 0},
	},
	[18741] = {
			{"raw", "mana_mod", 0, nil, 0, 0},
	},
	[9635] = {
			{"raw", "ap_flat", 120, nil, 2, 2},
	},
	[21184] = {
			{"by_school", "threat", -0.29, {1,2,3,4,5,6,7,}, 0, 0},
	},
	[19384] = {
			{"wpn_subclass", "phys_mod", 0.04, {173555}, 9, 0},
	},
	[18742] = {
			{"raw", "mana_mod", 0, nil, 0, 0},
	},
	[17219] = {
			{"raw", "phys_mod", 0.07, nil, 1, 0},
	},
	[6314] = {
			{"raw", "phys_dmg_flat", 2, nil, 0, 0},
	},
	[17222] = {
			{"raw", "phys_mod", 0.07, nil, 1, 0},
	},
	[17209] = {
			{"raw", "phys_mod", 0, nil, 1, 0},
	},
	[415429] = {
			{"raw", "ap_flat", 0, nil, 2, 1},
			{"by_school", "sp_dmg_flat", 0, {1,2,3,4,5,6,7,}, 2, 2},
			{"raw", "phys_hit", 0, nil, 2, 9},
			{"by_school", "spell_hit", 0, {1,2,3,4,5,6,7,}, 2, 10},
			{"raw", "melee_haste", 0, nil, 33, 11},
			{"raw", "cast_haste", 0, nil, 0, 12},
			{"raw", "phys_crit", 0, nil, 32, 13},
			{"by_school", "crit", 0, {1,}, 2, 14},
	},
	[416189] = {
			{"raw", "ap_flat", 0, nil, 2, 1},
			{"by_school", "sp_dmg_flat", 0, {1,2,3,4,5,6,7,}, 2, 2},
			{"raw", "phys_hit", 0, nil, 2, 9},
			{"by_school", "spell_hit", 0, {1,2,3,4,5,6,7,}, 2, 10},
			{"raw", "melee_haste", 0, nil, 33, 11},
			{"raw", "cast_haste", 0, nil, 0, 12},
			{"raw", "phys_crit", 0, nil, 32, 13},
			{"by_school", "crit", 0, {1,}, 2, 14},
	},
	[20557] = {
			{"creature", "dmg_mod", 0.049999997, {1,}, 1, 0},
	},
	[17210] = {
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[6317] = {
			{"raw", "phys_dmg_flat", 8, nil, 0, 0},
	},
	[17214] = {
			{"raw", "phys_mod", 0.02, nil, 1, 0},
	},
	[19385] = {
			{"wpn_subclass", "phys_mod", 0.049999997, {173555}, 9, 0},
	},
	[18728] = {
			{"raw", "phys_mod", 0, nil, 1, 0},
	},
	[17216] = {
			{"raw", "phys_mod", 0.07, nil, 1, 0},
	},
	[17217] = {
			{"raw", "phys_mod", 0.099999994, nil, 1, 0},
	},
	[18740] = {
			{"raw", "mana_mod", 0, nil, 0, 0},
	},
	[444831] = {
			{"raw", "phys_mod", 0.01, nil, 1, 0},
	},
	[17211] = {
			{"raw", "phys_mod", -0.049999997, nil, 1, 0},
	},
	[17218] = {
			{"raw", "phys_mod", -0.06, nil, 1, 0},
	},
	[19381] = {
			{"wpn_subclass", "phys_mod", 0.01, {173555}, 9, 0},
	},
	[7000] = {
			{"raw", "phys_mod", -0.099999994, nil, 1, 0},
	},
	[19383] = {
			{"wpn_subclass", "phys_mod", 0.03, {173555}, 9, 0},
	},
};
