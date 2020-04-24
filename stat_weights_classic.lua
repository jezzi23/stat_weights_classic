
local version =  "1.0.6";
-- TODO: add libstub here
--local icon_lib = LibStub("LibDBIcon-1.0");

local font = "GameFontHighlightSmall";

--TODO: Known spells that are incorrectly evaluated
        -- Holy Nova
        -- Curse of Agony dmg ramps up

local magic_school = {
     physical = 1,
     holy     = 2,
     fire     = 3,
     nature   = 4,
     frost    = 5,
     shadow   = 6,
     arcane   = 7
};

local stat = {
    str = 1,
    agi = 2,
    stam = 3,
    int = 4,
    spirit = 5
};

local spell_flags = {
    aoe = bit.lshift(1,1),
    snare = bit.lshift(1,2),
    heal = bit.lshift(1,3),
    absorb = bit.lshift(1,4),
    over_time_crit = bit.lshift(1,5)
};

local stat_ids_in_ui = {
    int = 1,
    spirit = 2,
    spell_crit = 3,
    spell_hit = 4,
    sp = 5,
    spell_damage = 6,
    healing_power = 7,
    holy_power = 8,
    fire_power = 9,
    nature_power = 10,
    frost_power = 11,
    shadow_power = 12,
    arcane_power = 13
};

local set_tiers = {
    pve_0 = 1,
    pve_0_5 = 2,
    pve_1 = 3,
    pve_2 = 4,
    pve_3 = 5,
    pvp_1 = 6,
    pvp_2 = 7,
    pve_2_5 = 8
};

local spell_name_to_id = {
    -- Mage
    ["Frostbolt"]               = 116,
    ["Frost Nova"]              = 122,
    ["Cone of Cold"]            = 120,
    ["Blizzard"]                = 10,
    ["Fireball"]                = 133,
    ["Fire Blast"]              = 2136,
    ["Scorch"]                  = 2948,
    ["Pyroblast"]               = 11366,
    ["Blast Wave"]              = 11113,
    ["Flamestrike"]             = 2120,
    ["Arcane Missiles"]         = 5143,
    ["Arcane Explosion"]        = 1449,
    -- Druid
    ["Healing Touch"]           = 5185,
    ["Rejuvenation"]            = 774,
    ["Tranquility"]             = 740,
    ["Regrowth"]                = 8936,
    ["Moonfire"]                = 8921,
    ["Wrath"]                   = 5176,
    ["Starfire"]                = 2912,
    ["Insect Swarm"]            = 5570,
    ["Hurricane"]               = 16914,
    ["Entangling Roots"]        = 339,
    -- Priest
    ["Lesser Heal"]             = 2050,
    ["Heal"]                    = 2054,
    ["Greater Heal"]            = 2060,
    ["Flash Heal"]              = 2061,
    ["Prayer of Healing"]       = 596,
    ["Renew"]                   = 139,
    ["Power Word: Shield"]      = 17,
    ["Holy Nova"]               = 15237,
    ["Smite"]                   = 585,
    ["Holy Fire"]               = 14914,
    ["Mind Blast"]              = 8092,
    ["Shadow Word: Pain"]       = 589,
    ["Mind Flay"]               = 15407,
    ["Devouring Plague"]        = 2944,
    -- Shaman
    ["Healing Stream Totem"]    = 5394,
    ["Lesser Healing"]          = 8004,
    ["Healing Wave"]            = 331,
    ["Chain Heal"]              = 1064,
    ["Lightning Bolt"]          = 403,
    ["Chain Lightning"]         = 421,
    ["Lightning Shield"]        = 324,
    ["Earth Shock"]             = 8042,
    ["Magma Totem"]             = 8190,
    ["Flame Shock"]             = 8050,
    ["Frost Shock"]             = 8056,
    ["Fire Nova Totem"]         = 1535,
    ["Searing Totem"]           = 3599,
    -- Paladin
    ["Flash of Light"]          = 19750,
    ["Holy Light"]              = 635,
    ["Holy Shock"]              = 20473,
    ["Hammer of Wrath"]         = 24275,
    ["Consecration"]            = 26573,
    ["Exorcism"]                = 879,
    ["Holy Wrath"]              = 2812,
    -- Warlock
    ["Curse of Agony"]          = 980,
    ["Siphon Life"]             = 18265,
    ["Death Coil"]              = 6789,
    ["Corruption"]              = 172,
    ["Drain Life"]              = 689,
    ["Drain Soul"]              = 1120,
    ["Shadow Bolt"]             = 686,
    ["Searing Pain"]            = 5676,
    ["Soul Fire"]               = 6353,
    ["Hellfire"]                = 1949,
    ["Rain of Fire"]            = 5740,
    ["Immolate"]                = 348,
    ["Conflagrate"]             = 17962,
    ["Shadowburn"]              = 17877
};


local function create_spells()
    
    local _, class = UnitClass("player");
    if class == "MAGE" then
        return  {
            --frostbolts
            [116] = {
                base_min            = 20.0,
                base_max            = 22.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 4,
                mana                = 25,
                flags               = spell_flags.snare,
                school              = magic_school.frost
            },
            [205] = {
                base_min            = 33.0,
                base_max            = 38.0,
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.8,
                rank                = 2,
                lvl_req             = 8,
                mana                = 35,
                flags               = spell_flags.snare,
                school              = magic_school.frost
            },
            [837] = {
                base_min            = 54.0,
                base_max            = 61.0,
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 2.2,
                rank                = 3,
                lvl_req             = 14,
                mana                = 50,
                flags               = spell_flags.snare,
                school              = magic_school.frost
            },
            [7322] = {
                base_min            = 78.0,
                base_max            = 87.0,
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 2.6,
                rank                = 4,
                lvl_req             = 20,
                mana                = 65,
                flags               = spell_flags.snare,
                school              = magic_school.frost
            },
            [8406] = {
                base_min            = 132.0,
                base_max            = 144.0,
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3,
                rank                = 5,
                lvl_req             = 26,
                mana                = 100,
                flags               = spell_flags.snare,
                school              = magic_school.frost
            },
            [8407] = {
                base_min            = 180.0,
                base_max            = 197.0,
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3,
                rank                = 6,
                lvl_req             = 32,
                mana                = 130,
                flags               = spell_flags.snare,
                school              = magic_school.frost
            },
            [8408] = {
                base_min            = 235.0,
                base_max            = 255.0,
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3,
                rank                = 7,
                lvl_req             = 38,
                mana                = 160,
                flags               = spell_flags.snare,
                school              = magic_school.frost
            },
            [10179] = {
                base_min            = 301.0,
                base_max            = 326.0,
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3,
                rank                = 8,
                lvl_req             = 44,
                mana                = 195,
                flags               = spell_flags.snare,
                school              = magic_school.frost 
            },
            [10180] = {
                base_min            = 363.0,
                base_max            = 394.0,
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3,
                rank                = 9,
                lvl_req             = 50,
                mana                = 225,
                flags               = spell_flags.snare,
                school              = magic_school.frost
            },
            [10181] = {
                base_min            = 440.0,
                base_max            = 475.0,
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3,
                rank                = 10,
                lvl_req             = 56,
                mana                = 260,
                flags               = spell_flags.snare,
                school              = magic_school.frost
            },
            [25304] = {
                base_min            = 515.0,
                base_max            = 555.0,
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3,
                rank                = 11,
                lvl_req             = 60,
                mana                = 290,
                flags               = spell_flags.snare,
                school              = magic_school.frost
            },
            -- frost nova
            [122] = {
                base_min            = 21.0,
                base_max            = 24.0,
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 10,
                mana                = 55,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.frost
            },
            [865] = {
                base_min            = 35.0,
                base_max            = 40.0,
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 26,
                mana                = 85,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.frost
            },
            [6131] = {
                base_min            = 54.0,
                base_max            = 61.0,
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 40,
                mana                = 115,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.frost
            },
            [10230] = {
                base_min            = 73.0,
                base_max            = 82.0,
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 54,
                mana                = 145,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.frost
            },
            --cone of cold
            [120] = {
                base_min            = 102.0,
                base_max            = 112.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 26,
                mana                = 210,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.frost
            },
            [8492] = {
                base_min            = 151.0,
                base_max            = 165.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 34,
                mana                = 290,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.frost
            },
            [10159] = {
                base_min            = 209.0,
                base_max            = 229.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 42,
                mana                = 380,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.frost
            },
            [10160] = {
                base_min            = 270.0,
                base_max            = 297.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 50,
                mana                = 465,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.frost
            },
            [10161] = {
                base_min            = 338.0,
                base_max            = 368.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 58,
                mana                = 555,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.frost
            },
            -- blizzard
            [10] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 200,
                over_time_tick_freq = 1,
                over_time_duration  = 8,
                cast_time           = 8.0,
                rank                = 1,
                lvl_req             = 20,
                mana                = 320,
                flags               = spell_flags.aoe,
                school              = magic_school.frost
            },
            [6141] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 352,
                over_time_tick_freq = 1,
                over_time_duration  = 8,
                cast_time           = 8.0,
                rank                = 2,
                lvl_req             = 28,
                mana                = 520,
                flags               = spell_flags.aoe,
                school              = magic_school.frost
            },
            [8427] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 520,
                over_time_tick_freq = 1,
                over_time_duration  = 8,
                cast_time           = 8.0,
                rank                = 3,
                lvl_req             = 36,
                mana                = 720,
                flags               = spell_flags.aoe,
                school              = magic_school.frost
            },
            [10185] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 720,
                over_time_tick_freq = 1,
                over_time_duration  = 8,
                cast_time           = 8.0,
                rank                = 4,
                lvl_req             = 44,
                mana                = 935,
                flags               = spell_flags.aoe,
                school              = magic_school.frost
            },
            [10186] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 936,
                over_time_tick_freq = 1,
                over_time_duration  = 8,
                cast_time           = 8.0,
                rank                = 5,
                lvl_req             = 52,
                mana                = 1160,
                flags               = spell_flags.aoe,
                school              = magic_school.frost
            },
            [10187] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 1192,
                over_time_tick_freq = 1,
                over_time_duration  = 8,
                cast_time           = 8.0,
                rank                = 6,
                lvl_req             = 60,
                mana                = 1400,
                flags               = spell_flags.aoe,
                school              = magic_school.frost
            },
            -- fireball
            [133] = {
                base_min            = 16.0,
                base_max            = 25.0, 
                over_time           = 2,
                over_time_tick_freq = 2,
                over_time_duration  = 4,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 1,
                mana                = 30,
                flags               = 0,
                school              = magic_school.fire
            },
            [143] = {
                base_min            = 34.0,
                base_max            = 49.0, 
                over_time           = 3,
                over_time_tick_freq = 2,
                over_time_duration  = 6,
                cast_time           = 2.0,
                rank                = 2,
                lvl_req             = 6,
                mana                = 45,
                flags               = 0,
                school              = magic_school.fire
            },
            [145] = {
                base_min            = 57.0,
                base_max            = 77.0, 
                over_time           = 6,
                over_time_tick_freq = 2,
                over_time_duration  = 6,
                cast_time           = 2.5,
                rank                = 3,
                lvl_req             = 12,
                mana                = 65,
                flags               = 0,
                school              = magic_school.fire
            },
            [3140] = {
                base_min            = 89.0,
                base_max            = 122.0, 
                over_time           = 12,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.0,
                rank                = 4,
                lvl_req             = 18,
                mana                = 95,
                flags               = 0,
                school              = magic_school.fire
            },
            [8400] = {
                base_min            = 146.0,
                base_max            = 195.0, 
                over_time           = 20,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.5,
                rank                = 5,
                lvl_req             = 24,
                mana                = 140,
                flags               = 0,
                school              = magic_school.fire
            },
            [8401] = {
                base_min            = 207.0,
                base_max            = 274.0, 
                over_time           = 28,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.5,
                rank                = 6,
                lvl_req             = 30,
                mana                = 185,
                flags               = 0,
                school              = magic_school.fire
            },
            [8402] = {
                base_min            = 264.0,
                base_max            = 345.0, 
                over_time           = 32,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.5,
                rank                = 7,
                lvl_req             = 36,
                mana                = 220,
                flags               = 0,
                school              = magic_school.fire
            },
            [10148] = {
                base_min            = 328.0,
                base_max            = 425.0, 
                over_time           = 40,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.5,
                rank                = 8,
                lvl_req             = 42,
                mana                = 260,
                flags               = 0,
                school              = magic_school.fire
            },
            [10149] = {
                base_min            = 404.0,
                base_max            = 518.0, 
                over_time           = 52,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.5,
                rank                = 9,
                lvl_req             = 48,
                mana                = 305,
                flags               = 0,
                school              = magic_school.fire
            },
            [10150] = {
                base_min            = 488.0,
                base_max            = 623.0, 
                over_time           = 60,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.5,
                rank                = 10,
                lvl_req             = 54,
                mana                = 350,
                flags               = 0,
                school              = magic_school.fire
            },
            [10151] = {
                base_min            = 561.0,
                base_max            = 715.0, 
                over_time           = 72,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.5,
                rank                = 11,
                lvl_req             = 60,
                mana                = 395,
                flags               = 0,
                school              = magic_school.fire
            },
            [25306] = {
                base_min            = 596.0,
                base_max            = 760.0, 
                over_time           = 76,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.5,
                rank                = 12,
                lvl_req             = 60,
                mana                = 410,
                flags               = 0,
                school              = magic_school.fire
            },
            -- fire blast
            [2136] = {
                base_min            = 27.0,
                base_max            = 35.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 6,
                mana                = 40,
                flags               = 0,
                school              = magic_school.fire
            },
            [2137] = {
                base_min            = 62.0,
                base_max            = 76.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 14,
                mana                = 75,
                flags               = 0,
                school              = magic_school.fire
            },
            [2138] = {
                base_min            = 110.0,
                base_max            = 134.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 22,
                mana                = 115,
                flags               = 0,
                school              = magic_school.fire
            },
            [8412] = {
                base_min            = 177.0,
                base_max            = 211.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 30,
                mana                = 165,
                flags               = 0,
                school              = magic_school.fire
            },
            [8413] = {
                base_min            = 253.0,
                base_max            = 301.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 38,
                mana                = 220,
                flags               = 0,
                school              = magic_school.fire
            },
            [10197] = {
                base_min            = 345.0,
                base_max            = 407.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 46,
                mana                = 280,
                flags               = 0,
                school              = magic_school.fire
            },
            [10199] = {
                base_min            = 446.0,
                base_max            = 524.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 7,
                lvl_req             = 54,
                mana                = 340,
                flags               = 0,
                school              = magic_school.fire
            },
            -- scorch
            [2948] = {
                base_min            = 56.0,
                base_max            = 69.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 22, 
                mana                = 50,
                flags               = 0,
                school              = magic_school.fire
            },
            [8444] = {
                base_min            = 81.0,
                base_max            = 98.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 28,
                mana                = 65,
                flags               = 0,
                school              = magic_school.fire
            },
            [8445] = {
                base_min            = 105.0,
                base_max            = 126.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 34,
                mana                = 80,
                flags               = 0,
                school              = magic_school.fire
            },
            [8446] = {
                base_min            = 139.0,
                base_max            = 165.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 40,
                mana                = 100,
                flags               = 0,
                school              = magic_school.fire
            },
            [10205] = {
                base_min            = 168.0,
                base_max            = 199.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 46,
                mana                = 115,
                flags               = 0,
                school              = magic_school.fire
            },
            [10206] = {
                base_min            = 207.0,
                base_max            = 247.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 52,
                mana                = 135,
                flags               = 0,
                school              = magic_school.fire
            },
            [10207] = {
                base_min            = 237.0,
                base_max            = 280.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 7,
                lvl_req             = 58,
                mana                = 150,
                flags               = 0,
                school              = magic_school.fire
            },
            -- pyroblast
            [11366] = {
                base_min            = 148.0,
                base_max            = 195.0, 
                over_time           = 56,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 6.0,
                rank                = 1,
                lvl_req             = 20,
                mana                = 125,
                flags               = 0,
                school              = magic_school.fire
            },
            [12505] = {
                base_min            = 193.0,
                base_max            = 250.0, 
                over_time           = 72,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 6.0,
                rank                = 2,
                lvl_req             = 24,
                mana                = 150,
                flags               = 0,
                school              = magic_school.fire
            },
            [12522] = {
                base_min            = 270.0,
                base_max            = 343.0, 
                over_time           = 96,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 6.0,
                rank                = 3,
                lvl_req             = 30,
                mana                = 195,
                flags               = 0,
                school              = magic_school.fire
            },
            [12523] = {
                base_min            = 347.0,
                base_max            = 437.0, 
                over_time           = 124,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 6.0,
                rank                = 4,
                lvl_req             = 36,
                mana                = 240,
                flags               = 0,
                school              = magic_school.fire
            },
            [12524] = {
                base_min            = 427.0,
                base_max            = 536.0, 
                over_time           = 156,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 6.0,
                rank                = 5,
                lvl_req             = 42,
                mana                = 285,
                flags               = 0,
                school              = magic_school.fire
            },
            [12525] = {
                base_min            = 525.0,
                base_max            = 654.0, 
                over_time           = 188,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 6.0,
                rank                = 6,
                lvl_req             = 48,
                mana                = 335,
                flags               = 0,
                school              = magic_school.fire
            },
            [12526] = {
                base_min            = 625.0,
                base_max            = 776.0, 
                over_time           = 228,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 6.0,
                rank                = 7,
                lvl_req             = 54,
                mana                = 385,
                flags               = 0,
                school              = magic_school.fire
            },
            [18809] = {
                base_min            = 716.0,
                base_max            = 890.0, 
                over_time           = 268,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 6.0,
                rank                = 8,
                lvl_req             = 60,
                mana                = 440,
                flags               = 0,
                school              = magic_school.fire
            },
            -- blast wave
            [11113] = {
                base_min            = 160.0,
                base_max            = 192.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 60, 
                mana                = 215,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.fire
            },
            [13018] = {
                base_min            = 208.0,
                base_max            = 249.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 60,
                mana                = 270,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.fire
            },
            [13019] = {
                base_min            = 285.0,
                base_max            = 338.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 60,
                mana                = 355,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.fire
            },
            [13020] = {
                base_min            = 374.0,
                base_max            = 443.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 60,
                mana                = 450,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.fire
            },
            [13021] = {
                base_min            = 462.0,
                base_max            = 544.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 60,
                mana                = 545,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.fire
            },
            -- flamestrike
            [2120] = {
                base_min            = 55.0,
                base_max            = 71.0 ,
                over_time           = 48,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.0,
                rank                = 1,
                lvl_req             = 16, 
                mana                = 195,
                flags               = spell_flags.aoe,
                school              = magic_school.fire
            },
            [2121] = {
                base_min            = 100.0,
                base_max            = 126.0,
                over_time           = 88,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.0,
                rank                = 2,
                lvl_req             = 24, 
                mana                = 330,
                flags               = spell_flags.aoe,
                school              = magic_school.fire
            },
            [8422] = {
                base_min            = 159.0,
                base_max            = 197.0,
                over_time           = 140,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.0,
                rank                = 3,
                lvl_req             = 32, 
                mana                = 490,
                flags               = spell_flags.aoe,
                school              = magic_school.fire
            },
            [8423] = {
                base_min            = 226.0,
                base_max            = 279.0,
                over_time           = 196,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.0,
                rank                = 4,
                lvl_req             = 40, 
                mana                = 650,
                flags               = spell_flags.aoe,
                school              = magic_school.fire
            },
            [10215] = {
                base_min            = 298.0,
                base_max            = 367.0,
                over_time           = 264,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.0,
                rank                = 5,
                lvl_req             = 48, 
                mana                = 815,
                flags               = spell_flags.aoe,
                school              = magic_school.fire
            },
            [10216] = {
                base_min            = 381.0,
                base_max            = 466.0,
                over_time           = 340,
                over_time_tick_freq = 2,
                over_time_duration  = 8,
                cast_time           = 3.0,
                rank                = 6,
                lvl_req             = 56, 
                mana                = 990,
                flags               = spell_flags.aoe,
                school              = magic_school.fire
            },
            -- arcane missiles
            [5143] = {
                base_min            = 0.0,
                base_max            = 0.0 ,
                over_time           = 26 * 3,
                over_time_tick_freq = 1,
                over_time_duration  = 3,
                cast_time           = 3.0,
                rank                = 1,
                lvl_req             = 8, 
                mana                = 85,
                flags               = spell_flags.over_time_crit,
                school              = magic_school.arcane
            },
            [5144] = {
                base_min            = 0.0,
                base_max            = 0.0,
                over_time           = 38 * 4,
                over_time_tick_freq = 1,
                over_time_duration  = 4,
                cast_time           = 4.0,
                rank                = 2,
                lvl_req             = 16, 
                mana                = 140,
                flags               = spell_flags.over_time_crit,
                school              = magic_school.arcane
            },
            [5145] = {
                base_min            = 0.0,
                base_max            = 0.0 ,
                over_time           = 58 * 5,
                over_time_tick_freq = 1,
                over_time_duration  = 5,
                cast_time           = 5.0,
                rank                = 3,
                lvl_req             = 24, 
                mana                = 235,
                flags               = spell_flags.over_time_crit,
                school              = magic_school.arcane
            },
            [8416] = {
                base_min            = 0.0,
                base_max            = 0.0 ,
                over_time           = 86 * 5,
                over_time_tick_freq = 1,
                over_time_duration  = 5,
                cast_time           = 5.0,
                rank                = 4,
                lvl_req             = 32, 
                mana                = 320,
                flags               = spell_flags.over_time_crit,
                school              = magic_school.arcane
            },
            [8417] = {
                base_min            = 0.0,
                base_max            = 0.0 ,
                over_time           = 118 * 5,
                over_time_tick_freq = 1,
                over_time_duration  = 5,
                cast_time           = 5.0,
                rank                = 5,
                lvl_req             = 40, 
                mana                = 410,
                flags               = spell_flags.over_time_crit,
                school              = magic_school.arcane
            },
            [10211] = {
                base_min            = 0.0,
                base_max            = 0.0 ,
                over_time           = 155 * 5,
                over_time_tick_freq = 1,
                over_time_duration  = 5,
                cast_time           = 5.0,
                rank                = 6,
                lvl_req             = 48, 
                mana                = 500,
                flags               = spell_flags.over_time_crit,
                school              = magic_school.arcane
            },
            [10212] = {
                base_min            = 0.0,
                base_max            = 0.0 ,
                over_time           = 196 * 5,
                over_time_tick_freq = 1,
                over_time_duration  = 5,
                cast_time           = 5.0,
                rank                = 7,
                lvl_req             = 56, 
                mana                = 595,
                flags               = spell_flags.over_time_crit,
                school              = magic_school.arcane
            },
            [25345] = {
                base_min            = 0.0,
                base_max            = 0.0 ,
                over_time           = 230 * 5,
                over_time_tick_freq = 1,
                over_time_duration  = 5,
                cast_time           = 5.0,
                rank                = 8,
                lvl_req             = 56, 
                mana                = 635,
                flags               = spell_flags.over_time_crit,
                school              = magic_school.arcane
            },
            -- arcane explosion
            [1449] = {
                base_min            = 34.0,
                base_max            = 38.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 14, 
                mana                = 75,
                flags               = spell_flags.aoe,
                school              = magic_school.arcane
            },
            [8437] = {
                base_min            = 60.0,
                base_max            = 66.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 22,
                mana                = 120,
                flags               = spell_flags.aoe,
                school              = magic_school.arcane
            },
            [8438] = {
                base_min            = 101.0,
                base_max            = 110.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 30,
                mana                = 185,
                flags               = spell_flags.aoe,
                school              = magic_school.arcane
            },
            [8439] = {
                base_min            = 143.0,
                base_max            = 156.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 38,
                mana                = 250,
                flags               = spell_flags.aoe,
                school              = magic_school.arcane
            },
            [10201] = {
                base_min            = 191.0,
                base_max            = 208.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 46,
                mana                = 315,
                flags               = spell_flags.aoe,
                school              = magic_school.arcane
            },
            [10202] = {
                base_min            = 249.0,
                base_max            = 270.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 54,
                mana                = 390,
                flags               = spell_flags.aoe,
                school              = magic_school.arcane
            }
        };

    elseif class == "DRUID" then
        return {
            --  healing touch
            [5185] = {
                base_min            = 40.0,
                base_max            = 55.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 1,
                mana                = 25,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [5186] = {
                base_min            = 94.0,
                base_max            = 119.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 2.0,
                rank                = 2,
                lvl_req             = 8,
                mana                = 55,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [5187] = {
                base_min            = 204.0,
                base_max            = 253.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 2.5,
                rank                = 3,
                lvl_req             = 14,
                mana                = 110,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [5188] = {
                base_min            = 376.0,
                base_max            = 459.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3.0,
                rank                = 4,
                lvl_req             = 20,
                mana                = 185,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [5189] = {
                base_min            = 589.0,
                base_max            = 712.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3.5,
                rank                = 5,
                lvl_req             = 26,
                mana                = 270,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [6778] = {
                base_min            = 762.0,
                base_max            = 914.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3.5,
                rank                = 6,
                lvl_req             = 32,
                mana                = 335,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [8903] = {
                base_min            = 958.0,
                base_max            = 1143.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3.5,
                rank                = 7,
                lvl_req             = 38,
                mana                = 405,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [9758] = {
                base_min            = 1225.0,
                base_max            = 1453.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3.5,
                rank                = 8,
                lvl_req             = 44,
                mana                = 495,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [9888] = {
                base_min            = 1545.0,
                base_max            = 1826.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3.5,
                rank                = 9,
                lvl_req             = 50,
                mana                = 600,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [9889] = {
                base_min            = 1916.0,
                base_max            = 2257.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3.5,
                rank                = 10,
                lvl_req             = 56,
                mana                = 720,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [25297] = {
                base_min            = 2267.0,
                base_max            = 2677.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0,
                cast_time           = 3.5,
                rank                = 11,
                lvl_req             = 60,
                mana                = 800,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            -- rejuvenation
            [774] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 32,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 4,
                mana                = 25,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [1058] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 56,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 10,
                mana                = 40,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [1430] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 116,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 16,
                mana                = 75,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [2090] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 180,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 22,
                mana                = 105,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [2091] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 244,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 28,
                mana                = 135,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [3627] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 304,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 34,
                mana                = 160,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [8910] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 388,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 7,
                lvl_req             = 40,
                mana                = 195,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [9839] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 488,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 8,
                lvl_req             = 46,
                mana                = 235,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [9840] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 608,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 9,
                lvl_req             = 52,
                mana                = 280,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [9841] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 756,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 10,
                lvl_req             = 58,
                mana                = 335,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [25299] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 888,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 11,
                lvl_req             = 60,
                mana                = 360,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },

            -- tranquility
            [740] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 98 * 5,
                over_time_tick_freq = 2,
                over_time_duration  = 10,
                cast_time           = 10,
                rank                = 1,
                lvl_req             = 30,
                mana                = 375,
                flags               = bit.bor(spell_flags.heal, spell_flags.aoe),
                school              = magic_school.nature
            },
            [8918] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 143 * 5,
                over_time_tick_freq = 2,
                over_time_duration  = 10,
                cast_time           = 10,
                rank                = 2,
                lvl_req             = 40,
                mana                = 505,
                flags               = bit.bor(spell_flags.heal, spell_flags.aoe),
                school              = magic_school.nature
            },
            [9862] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 211 * 5,
                over_time_tick_freq = 2,
                over_time_duration  = 10,
                cast_time           = 10,
                rank                = 3,
                lvl_req             = 50,
                mana                = 695,
                flags               = bit.bor(spell_flags.heal, spell_flags.aoe),
                school              = magic_school.nature
            },
            [9863] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 294 * 5,
                over_time_tick_freq = 2,
                over_time_duration  = 10,
                cast_time           = 10,
                rank                = 4,
                lvl_req             = 30,
                mana                = 925,
                flags               = bit.bor(spell_flags.heal, spell_flags.aoe),
                school              = magic_school.nature
            },
            -- regrowth
            [8936] = {
                base_min            = 93.0,
                base_max            = 107.0, 
                over_time           = 98,
                over_time_tick_freq = 3,
                over_time_duration  = 21,
                cast_time           = 2.0,
                rank                = 1,
                lvl_req             = 12,
                mana                = 120,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [8938] = {
                base_min            = 176.0,
                base_max            = 201.0, 
                over_time           = 175,
                over_time_tick_freq = 3,
                over_time_duration  = 21,
                cast_time           = 2.0,
                rank                = 2,
                lvl_req             = 18,
                mana                = 205,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [8939] = {
                base_min            = 255.0,
                base_max            = 290.0, 
                over_time           = 259,
                over_time_tick_freq = 3,
                over_time_duration  = 21,
                cast_time           = 2.0,
                rank                = 3,
                lvl_req             = 24,
                mana                = 280,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [8940] = {
                base_min            = 336.0,
                base_max            = 378.0, 
                over_time           = 343,
                over_time_tick_freq = 3,
                over_time_duration  = 21,
                cast_time           = 2.0,
                rank                = 4,
                lvl_req             = 30,
                mana                = 350,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [8941] = {
                base_min            = 425.0,
                base_max            = 478.0, 
                over_time           = 427,
                over_time_tick_freq = 3,
                over_time_duration  = 21,
                cast_time           = 2.0,
                rank                = 5,
                lvl_req             = 36,
                mana                = 420,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [9750] = {
                base_min            = 534.0,
                base_max            = 599.0, 
                over_time           = 546,
                over_time_tick_freq = 3,
                over_time_duration  = 21,
                cast_time           = 2.0,
                rank                = 6,
                lvl_req             = 42,
                mana                = 510,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [9856] = {
                base_min            = 672.0,
                base_max            = 751.0, 
                over_time           = 686,
                over_time_tick_freq = 3,
                over_time_duration  = 21,
                cast_time           = 2.0,
                rank                = 7,
                lvl_req             = 48,
                mana                = 615,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [9857] = {
                base_min            = 839.0,
                base_max            = 935.0, 
                over_time           = 861,
                over_time_tick_freq = 3,
                over_time_duration  = 21,
                cast_time           = 2.0,
                rank                = 8,
                lvl_req             = 54,
                mana                = 740,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            [9858] = {
                base_min            = 1003.0,
                base_max            = 1119.0, 
                over_time           = 1064,
                over_time_tick_freq = 3,
                over_time_duration  = 21,
                cast_time           = 2.0,
                rank                = 9,
                lvl_req             = 60,
                mana                = 880,
                flags               = spell_flags.heal,
                school              = magic_school.nature
            },
            -- moonfire
            [8921] = {
                base_min            = 9.0,
                base_max            = 12.0, 
                over_time           = 12,
                over_time_tick_freq = 3,
                over_time_duration  = 9,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 4,
                mana                = 25,
                flags               = 0,
                school              = magic_school.arcane
            },
            [8924] = {
                base_min            = 17.0,
                base_max            = 21.0, 
                over_time           = 32,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 10,
                mana                = 50,
                flags               = 0,
                school              = magic_school.arcane
            },
            [8925] = {
                base_min            = 30.0,
                base_max            = 37.0, 
                over_time           = 52,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 16,
                mana                = 75,
                flags               = 0,
                school              = magic_school.arcane
            },
            [8926] = {
                base_min            = 47.0,
                base_max            = 55.0, 
                over_time           = 80,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 22,
                mana                = 105,
                flags               = 0,
                school              = magic_school.arcane
            },
            [8927] = {
                base_min            = 70.0,
                base_max            = 82.0, 
                over_time           = 124,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 28,
                mana                = 150,
                flags               = 0,
                school              = magic_school.arcane
            },
            [8928] = {
                base_min            = 91.0,
                base_max            = 108.0, 
                over_time           = 164,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 34,
                mana                = 190,
                flags               = 0,
                school              = magic_school.arcane
            },
            [8929] = {
                base_min            = 117.0,
                base_max            = 137.0, 
                over_time           = 212,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 7,
                lvl_req             = 40,
                mana                = 235,
                flags               = 0,
                school              = magic_school.arcane
            },
            [9833] = {
                base_min            = 143.0,
                base_max            = 168.0, 
                over_time           = 264,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 8,
                lvl_req             = 46,
                mana                = 280,
                flags               = 0,
                school              = magic_school.arcane
            },
            [9834] = {
                base_min            = 172.0,
                base_max            = 200.0, 
                over_time           = 320,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 9,
                lvl_req             = 52,
                mana                = 325,
                flags               = 0,
                school              = magic_school.arcane
            },
            [9835] = {
                base_min            = 195.0,
                base_max            = 228.0, 
                over_time           = 384,
                over_time_tick_freq = 3,
                over_time_duration  = 12,
                cast_time           = 1.5,
                rank                = 109,
                lvl_req             = 58,
                mana                = 375,
                flags               = 0,
                school              = magic_school.arcane
            },
            -- wrath
            [5176] = {
                base_min            = 13.0,
                base_max            = 16.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 1,
                mana                = 20,
                flags               = 0,
                school              = magic_school.nature
            },
            [5177] = {
                base_min            = 28.0,
                base_max            = 33.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 1.7,
                rank                = 2,
                lvl_req             = 6,
                mana                = 35,
                flags               = 0,
                school              = magic_school.nature
            },
            [5178] = {
                base_min            = 48.0,
                base_max            = 57.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 2.0,
                rank                = 3,
                lvl_req             = 14,
                mana                = 55,
                flags               = 0,
                school              = magic_school.nature
            },
            [5179] = {
                base_min            = 69.0,
                base_max            = 79.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 2.0,
                rank                = 4,
                lvl_req             = 22,
                mana                = 70,
                flags               = 0,
                school              = magic_school.nature
            },
            [5180] = {
                base_min            = 108.0,
                base_max            = 123.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 2.0,
                rank                = 5,
                lvl_req             = 30,
                mana                = 100,
                flags               = 0,
                school              = magic_school.nature
            },
            [6780] = {
                base_min            = 148.0,
                base_max            = 167.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 2.0,
                rank                = 6,
                lvl_req             = 38,
                mana                = 125,
                flags               = 0,
                school              = magic_school.nature
            },
            [8905] = {
                base_min            = 198.0,
                base_max            = 221.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 2.0,
                rank                = 7,
                lvl_req             = 46,
                mana                = 155,
                flags               = 0,
                school              = magic_school.nature
            },
            [9912] = {
                base_min            = 248.0,
                base_max            = 277.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 2.0,
                rank                = 8,
                lvl_req             = 54,
                mana                = 180,
                flags               = 0,
                school              = magic_school.nature
            },
            -- starfire
            [2912] = {
                base_min            = 95.0,
                base_max            = 115.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 3.5,
                rank                = 1,
                lvl_req             = 20,
                mana                = 95,
                flags               = 0,
                school              = magic_school.arcane
            },
            [8949] = {
                base_min            = 146.0,
                base_max            = 177.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 3.5,
                rank                = 2,
                lvl_req             = 26,
                mana                = 135,
                flags               = 0,
                school              = magic_school.arcane
            },
            [8950] = {
                base_min            = 212.0,
                base_max            = 253.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 3.5,
                rank                = 3,
                lvl_req             = 34,
                mana                = 180,
                flags               = 0,
                school              = magic_school.arcane
            },
            [8951] = {
                base_min            = 293.0,
                base_max            = 348.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 3.5,
                rank                = 4,
                lvl_req             = 42,
                mana                = 230,
                flags               = 0,
                school              = magic_school.arcane
            },
            [9875] = {
                base_min            = 378.0,
                base_max            = 445.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 3.5,
                rank                = 5,
                lvl_req             = 50,
                mana                = 275,
                flags               = 0,
                school              = magic_school.arcane
            },
            [9876] = {
                base_min            = 451.0,
                base_max            = 531.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 3.5,
                rank                = 6,
                lvl_req             = 58,
                mana                = 315,
                flags               = 0,
                school              = magic_school.arcane
            },
            [25298] = {
                base_min            = 496.0,
                base_max            = 584.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0.0,
                over_time_duration  = 0.0,
                cast_time           = 3.5,
                rank                = 7,
                lvl_req             = 60,
                mana                = 340,
                flags               = 0,
                school              = magic_school.arcane
            },
            -- insect swarm
            [5570] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 66.0,
                over_time_tick_freq = 2.0,
                over_time_duration  = 12.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 20,
                mana                = 45,
                flags               = spell_flags.snare,
                school              = magic_school.nature
            },
            [24974] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 138.0,
                over_time_tick_freq = 2.0,
                over_time_duration  = 12.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 30,
                mana                = 85,
                flags               = spell_flags.snare,
                school              = magic_school.nature
            },
            [24975] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 174.0,
                over_time_tick_freq = 2.0,
                over_time_duration  = 12.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 40,
                mana                = 100,
                flags               = spell_flags.snare,
                school              = magic_school.nature
            },
            [24976] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 264.0,
                over_time_tick_freq = 2.0,
                over_time_duration  = 12.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 50,
                mana                = 140,
                flags               = spell_flags.snare,
                school              = magic_school.nature
            },
            [24977] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 324.0,
                over_time_tick_freq = 2.0,
                over_time_duration  = 12.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 60,
                mana                = 160,
                flags               = spell_flags.snare,
                school              = magic_school.nature
            },
            -- hurricane
            [16914] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 72.0 * 10,
                over_time_tick_freq = 1.0,
                over_time_duration  = 10.0,
                cast_time           = 10,
                rank                = 1,
                lvl_req             = 40,
                mana                = 880,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.nature,
            },
            [17401] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 102.0 * 10,
                over_time_tick_freq = 1.0,
                over_time_duration  = 10.0,
                cast_time           = 10,
                rank                = 2,
                lvl_req             = 50,
                mana                = 1180,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.nature
            },
            [17402] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 134.0 * 10,
                over_time_tick_freq = 1.0,
                over_time_duration  = 10.0,
                cast_time           = 10,
                rank                = 3,
                lvl_req             = 60,
                mana                = 1495,
                flags               = bit.bor(spell_flags.snare, spell_flags.aoe),
                school              = magic_school.nature
            },
            -- entangling roots
            [339] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 20,
                over_time_tick_freq = 3.0,
                over_time_duration  = 12.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 8,
                mana                = 50,
                flags               = spell_flags.snare,
                school              = magic_school.nature
            },
            [1062] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 50,
                over_time_tick_freq = 3.0,
                over_time_duration  = 15.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 18,
                mana                = 65,
                flags               = spell_flags.snare,
                school              = magic_school.nature
            },
            [5195] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 90,
                over_time_tick_freq = 3.0,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 28,
                mana                = 80,
                flags               = spell_flags.snare,
                school              = magic_school.nature
            },
            [5196] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 140,
                over_time_tick_freq = 3.0,
                over_time_duration  = 21.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 38,
                mana                = 95,
                flags               = spell_flags.snare,
                school              = magic_school.nature
            },
            [9852] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 200,
                over_time_tick_freq = 3.0,
                over_time_duration  = 24.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 48,
                mana                = 110,
                flags               = spell_flags.snare,
                school              = magic_school.nature
            },
            [9853] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 270,
                over_time_tick_freq = 3.0,
                over_time_duration  = 27.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 58,
                mana                = 125,
                flags               = spell_flags.snare,
                school              = magic_school.nature
            }
        };

    elseif class == "PRIEST" then
        return {
            -- lesser heal
            [2050] = {
                base_min            = 47.0,
                base_max            = 58.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 1,
                mana                = 30,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [2052] = {
                base_min            = 76.0,
                base_max            = 91.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.0,
                rank                = 2,
                lvl_req             = 4,
                mana                = 45,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [2053] = {
                base_min            = 143.0,
                base_max            = 165.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 3,
                lvl_req             = 10,
                mana                = 75,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            -- heal
            [2054] = {
                base_min            = 307.0,
                base_max            = 353.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 1,
                lvl_req             = 16,
                mana                = 155,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [2055] = {
                base_min            = 445.0,
                base_max            = 507.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 2,
                lvl_req             = 22,
                mana                = 205,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [6063] = {
                base_min            = 586.0,
                base_max            = 662.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 3,
                lvl_req             = 28,
                mana                = 255,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [6064] = {
                base_min            = 737.0,
                base_max            = 827.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 4,
                lvl_req             = 34,
                mana                = 305,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            -- greater heal
            [2060] = {
                base_min            = 924.0,
                base_max            = 1039.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 1,
                lvl_req             = 40,
                mana                = 370,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [10963] = {
                base_min            = 1178.0,
                base_max            = 1318.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 2,
                lvl_req             = 46,
                mana                = 455,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [10964] = {
                base_min            = 1470.0,
                base_max            = 1642.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 3,
                lvl_req             = 52,
                mana                = 545,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [10965] = {
                base_min            = 1813.0,
                base_max            = 2021.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 4,
                lvl_req             = 58,
                mana                = 655,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [25314] = {
                base_min            = 1966.0,
                base_max            = 2194.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 5,
                lvl_req             = 60,
                mana                = 710,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            -- flash heal
            [2061] = {
                base_min            = 202.0,
                base_max            = 247.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 20,
                mana                = 125,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [9472] = {
                base_min            = 269.0,
                base_max            = 325.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 26,
                mana                = 155,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [9473] = {
                base_min            = 339.0,
                base_max            = 406.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 32,
                mana                = 185,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [9474] = {
                base_min            = 414.0,
                base_max            = 492.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 38,
                mana                = 215,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [10915] = {
                base_min            = 534.0,
                base_max            = 633.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 44,
                mana                = 265,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [10916] = {
                base_min            = 662.0,
                base_max            = 783.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 50,
                mana                = 315,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [10917] = {
                base_min            = 828.0,
                base_max            = 975.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 7,
                lvl_req             = 56,
                mana                = 380,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            -- prayer of healing
            [596] = {
                base_min            = 312.0,
                base_max            = 333.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 1,
                lvl_req             = 30,
                mana                = 410,
                flags               = bit.bor(spell_flags.heal, spell_flags.aoe),
                school              = magic_school.holy
            },
            [996] = {
                base_min            = 458.0,
                base_max            = 487.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 2,
                lvl_req             = 40,
                mana                = 560,
                flags               = bit.bor(spell_flags.heal, spell_flags.aoe),
                school              = magic_school.holy
            },
            [10960] = {
                base_min            = 675.0,
                base_max            = 713.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 3,
                lvl_req             = 50,
                mana                = 770,
                flags               = bit.bor(spell_flags.heal, spell_flags.aoe),
                school              = magic_school.holy
            },
            [10961] = {
                base_min            = 939.0,
                base_max            = 991.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 4,
                lvl_req             = 60,
                mana                = 1030,
                flags               = bit.bor(spell_flags.heal, spell_flags.aoe),
                school              = magic_school.holy
            },
            [25316] = {
                base_min            = 1041.0,
                base_max            = 1099.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 5,
                lvl_req             = 30,
                mana                = 1070,
                flags               = bit.bor(spell_flags.heal, spell_flags.aoe),
                school              = magic_school.holy
            },
            -- renew
            [139] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 45.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 8,
                mana                = 30,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [6074] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 100.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 14,
                mana                = 65,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [6075] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 175.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 20,
                mana                = 105,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [6076] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 245.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 26,
                mana                = 140,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [6077] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 315.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 32,
                mana                = 170,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [6078] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 400.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 38,
                mana                = 205,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [10927] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 510.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 1.5,
                rank                = 7,
                lvl_req             = 44,
                mana                = 250,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [10928] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 650.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 1.5,
                rank                = 8,
                lvl_req             = 50,
                mana                = 305,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [10929] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 810.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 1.5,
                rank                = 9,
                lvl_req             = 56,
                mana                = 365,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [25315] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 970.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 1.5,
                rank                = 10,
                lvl_req             = 60,
                mana                = 410,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            -- power word: shield
            [17] = {
                base_min            = 48.0,
                base_max            = 48.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 6,
                mana                = 45,
                flags               = spell_flags.absorb,
                school              = magic_school.holy
            },
            [592] = {
                base_min            = 94.0,
                base_max            = 94.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 12,
                mana                = 80,
                flags               = spell_flags.absorb,
                school              = magic_school.holy
            },
            [600] = {
                base_min            = 166.0,
                base_max            = 166.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 18,
                mana                = 130,
                flags               = spell_flags.absorb,
                school              = magic_school.holy
            },
            [3747] = {
                base_min            = 244.0,
                base_max            = 244.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 24,
                mana                = 175,
                flags               = spell_flags.absorb,
                school              = magic_school.holy
            },
            [6065] = {
                base_min            = 313.0,
                base_max            = 313.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 30,
                mana                = 210,
                flags               = spell_flags.absorb,
                school              = magic_school.holy
            },
            [6066] = {
                base_min            = 394.0,
                base_max            = 394.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 36,
                mana                = 250,
                flags               = spell_flags.absorb,
                school              = magic_school.holy
            },
            [10898] = {
                base_min            = 499.0,
                base_max            = 499.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 7,
                lvl_req             = 42,
                mana                = 300,
                flags               = spell_flags.absorb,
                school              = magic_school.holy
            },
            [10899] = {
                base_min            = 622.0,
                base_max            = 622.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 8,
                lvl_req             = 48,
                mana                = 355,
                flags               = spell_flags.absorb,
                school              = magic_school.holy
            },
            [10900] = {
                base_min            = 783.0,
                base_max            = 783.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 9,
                lvl_req             = 54,
                mana                = 425,
                flags               = spell_flags.absorb,
                school              = magic_school.holy
            },
            [10901] = {
                base_min            = 942.0,
                base_max            = 942.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 10,
                lvl_req             = 60,
                mana                = 500,
                flags               = spell_flags.absorb,
                school              = magic_school.holy
            },
            -- holy nova
            [15237] = {
                base_min            = 29.0,
                base_max            = 34.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 20,
                mana                = 185,
                flags               = spell_flags.aoe,
                school              = magic_school.holy,
                healing_version = {
                    base_min            = 54.0,
                    base_max            = 63.0, 
                    over_time           = 0.0,
                    over_time_tick_freq = 0,
                    over_time_duration  = 0.0,
                    cast_time           = 1.5,
                    rank                = 1,
                    lvl_req             = 20,
                    mana                = 185,
                    flags               = bit.bor(spell_flags.aoe, spell_flags.heal),
                    school              = magic_school.holy,
                }
            },
            [15430] = {
                base_min            = 52.0,
                base_max            = 61.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 28,
                mana                = 290,
                flags               = spell_flags.aoe,
                school              = magic_school.holy,
                healing_version = {
                    base_min            = 89.0,
                    base_max            = 101.0, 
                    over_time           = 0.0,
                    over_time_tick_freq = 0,
                    over_time_duration  = 0.0,
                    cast_time           = 1.5,
                    rank                = 2,
                    lvl_req             = 28,
                    mana                = 290,
                    flags               = bit.bor(spell_flags.aoe, spell_flags.heal),
                    school              = magic_school.holy,
                }
            },
            [15431] = {
                base_min            = 79.0,
                base_max            = 92.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 36,
                mana                = 400,
                flags               = spell_flags.aoe,
                school              = magic_school.holy,
                healing_version = {
                    base_min            = 124.0,
                    base_max            = 143.0, 
                    over_time           = 0.0,
                    over_time_tick_freq = 0,
                    over_time_duration  = 0.0,
                    cast_time           = 1.5,
                    rank                = 3,
                    lvl_req             = 36,
                    mana                = 400,
                    flags               = bit.bor(spell_flags.aoe, spell_flags.heal),
                    school              = magic_school.holy,
                }
            },
            [27799] = {
                base_min            = 110.0,
                base_max            = 127.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 44,
                mana                = 520,
                flags               = spell_flags.aoe,
                school              = magic_school.holy,
                healing_version = {
                    base_min            = 165.0,
                    base_max            = 192.0, 
                    over_time           = 0.0,
                    over_time_tick_freq = 0,
                    over_time_duration  = 0.0,
                    cast_time           = 1.5,
                    rank                = 4,
                    lvl_req             = 44,
                    mana                = 520,
                    flags               = bit.bor(spell_flags.aoe, spell_flags.heal),
                    school              = magic_school.holy,
                }
            },
            [27800] = {
                base_min            = 146.0,
                base_max            = 148.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 52,
                mana                = 635,
                flags               = spell_flags.aoe,
                school              = magic_school.holy,
                healing_version = {
                    base_min            = 239.0,
                    base_max            = 276.0, 
                    over_time           = 0.0,
                    over_time_tick_freq = 0,
                    over_time_duration  = 0.0,
                    cast_time           = 1.5,
                    rank                = 5,
                    lvl_req             = 52,
                    mana                = 635,
                    flags               = bit.bor(spell_flags.aoe, spell_flags.heal),
                    school              = magic_school.holy,
                }
            },
            [27801] = {
                base_min            = 181.0,
                base_max            = 209.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 60,
                mana                = 750,
                flags               = spell_flags.aoe,
                school              = magic_school.holy,
                healing_version = {
                    base_min            = 302.0,
                    base_max            = 350.0, 
                    over_time           = 0.0,
                    over_time_tick_freq = 0,
                    over_time_duration  = 0.0,
                    cast_time           = 1.5,
                    rank                = 6,
                    lvl_req             = 60,
                    mana                = 750,
                    flags               = bit.bor(spell_flags.aoe, spell_flags.heal),
                    school              = magic_school.holy,
                }
            },
            -- holy fire
            [14914] = {
                base_min            = 84.0,
                base_max            = 104.0, 
                over_time           = 30,
                over_time_tick_freq = 2,
                over_time_duration  = 10.0,
                cast_time           = 3.5,
                rank                = 1,
                lvl_req             = 20,
                mana                = 85,
                flags               = 0,
                school              = magic_school.holy,
            },
            [15262] = {
                base_min            = 106.0,
                base_max            = 131.0, 
                over_time           = 40,
                over_time_tick_freq = 2,
                over_time_duration  = 10.0,
                cast_time           = 3.5,
                rank                = 2,
                lvl_req             = 24,
                mana                = 95,
                flags               = 0,
                school              = magic_school.holy,
            },
            [15263] = {
                base_min            = 144.0,
                base_max            = 178.0, 
                over_time           = 55,
                over_time_tick_freq = 2,
                over_time_duration  = 10.0,
                cast_time           = 3.5,
                rank                = 3,
                lvl_req             = 30,
                mana                = 125,
                flags               = 0,
                school              = magic_school.holy,
            },
            [15264] = {
                base_min            = 178.0,
                base_max            = 223.0, 
                over_time           = 65,
                over_time_tick_freq = 2,
                over_time_duration  = 10.0,
                cast_time           = 3.5,
                rank                = 4,
                lvl_req             = 36,
                mana                = 145,
                flags               = 0,
                school              = magic_school.holy,
            },
            [15265] = {
                base_min            = 219.0,
                base_max            = 273.0, 
                over_time           = 85,
                over_time_tick_freq = 2,
                over_time_duration  = 10.0,
                cast_time           = 3.5,
                rank                = 5,
                lvl_req             = 42,
                mana                = 170,
                flags               = 0,
                school              = magic_school.holy,
            },
            [15266] = {
                base_min            = 271.0,
                base_max            = 340.0, 
                over_time           = 100,
                over_time_tick_freq = 2,
                over_time_duration  = 10.0,
                cast_time           = 3.5,
                rank                = 6,
                lvl_req             = 48,
                mana                = 200,
                flags               = 0,
                school              = magic_school.holy,
            },
            [15267] = {
                base_min            = 323.0,
                base_max            = 406.0, 
                over_time           = 125,
                over_time_tick_freq = 2,
                over_time_duration  = 10.0,
                cast_time           = 3.5,
                rank                = 7,
                lvl_req             = 7,
                mana                = 230,
                flags               = 0,
                school              = magic_school.holy,
            },
            [15261] = {
                base_min            = 355.0,
                base_max            = 449.0, 
                over_time           = 145,
                over_time_tick_freq = 2,
                over_time_duration  = 10.0,
                cast_time           = 3.5,
                rank                = 8,
                lvl_req             = 60,
                mana                = 255,
                flags               = 0,
                school              = magic_school.holy,
            },
            -- smite
            [585] = {
                base_min            = 15.0,
                base_max            = 20.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 1,
                mana                = 20,
                flags               = 0,
                school              = magic_school.holy,
            },
            [591] = {
                base_min            = 28.0,
                base_max            = 34.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.0,
                rank                = 2,
                lvl_req             = 6,
                mana                = 30,
                flags               = 0,
                school              = magic_school.holy,
            },
            [598] = {
                base_min            = 58.0,
                base_max            = 67.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 3,
                lvl_req             = 14,
                mana                = 60,
                flags               = 0,
                school              = magic_school.holy,
            },
            [984] = {
                base_min            = 97.0,
                base_max            = 112.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 4,
                lvl_req             = 22,
                mana                = 95,
                flags               = 0,
                school              = magic_school.holy,
            },
            [1004] = {
                base_min            = 158.0,
                base_max            = 178.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 5,
                lvl_req             = 30,
                mana                = 140,
                flags               = 0,
                school              = magic_school.holy,
            },
            [6060] = {
                base_min            = 222.0,
                base_max            = 250.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 6,
                lvl_req             = 38,
                mana                = 185,
                flags               = 0,
                school              = magic_school.holy,
            },
            [10933] = {
                base_min            = 298.0,
                base_max            = 335.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 7,
                lvl_req             = 46,
                mana                = 230,
                flags               = 0,
                school              = magic_school.holy,
            },
            [10934] = {
                base_min            = 384.0,
                base_max            = 429.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 8,
                lvl_req             = 54,
                mana                = 280,
                flags               = 0,
                school              = magic_school.holy,
            },
            -- shadow word: pain
            [589] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 30.0,
                over_time_tick_freq = 3,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 4,
                mana                = 25,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [594] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 30.0,
                over_time_tick_freq = 3,
                over_time_duration  = 66.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 10,
                mana                = 50,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [970] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 132.0,
                over_time_tick_freq = 3,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 18,
                mana                = 95,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [992] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 234.0,
                over_time_tick_freq = 3,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 26,
                mana                = 155,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [2767] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 366.0,
                over_time_tick_freq = 3,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 34,
                mana                = 230,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [10892] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 510.0,
                over_time_tick_freq = 3,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 42,
                mana                = 305,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [10893] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 672.0,
                over_time_tick_freq = 3,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 7,
                lvl_req             = 50,
                mana                = 385,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [10894] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 852.0,
                over_time_tick_freq = 3,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 8,
                lvl_req             = 58,
                mana                = 470,
                flags               = 0,
                school              = magic_school.shadow,
            },
            -- mind blast
            [8092] = {
                base_min            = 42.0,
                base_max            = 46.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 10,
                mana                = 50,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [8102] = {
                base_min            = 76.0,
                base_max            = 83.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 16,
                mana                = 80,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [8103] = {
                base_min            = 117.0,
                base_max            = 126.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 22,
                mana                = 110,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [8104] = {
                base_min            = 174.0,
                base_max            = 184.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 28,
                mana                = 150,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [8105] = {
                base_min            = 225.0,
                base_max            = 239.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 34,
                mana                = 185,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [8106] = {
                base_min            = 288.0,
                base_max            = 307.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 40,
                mana                = 225,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [10945] = {
                base_min            = 356.0,
                base_max            = 377.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 7,
                lvl_req             = 46,
                mana                = 265,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [10946] = {
                base_min            = 437.0,
                base_max            = 461.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 8,
                lvl_req             = 52,
                mana                = 310,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [10947] = {
                base_min            = 508.0,
                base_max            = 537.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 9,
                lvl_req             = 58,
                mana                = 350,
                flags               = 0,
                school              = magic_school.shadow,
            },
            -- mind flay
            [15407] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 75.0,
                over_time_tick_freq = 1,
                over_time_duration  = 3.0,
                cast_time           = 3.0,
                rank                = 1,
                lvl_req             = 20,
                mana                = 45,
                flags               = spell_flags.snare,
                school              = magic_school.shadow,
            },
            [17311] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 126.0,
                over_time_tick_freq = 1,
                over_time_duration  = 3.0,
                cast_time           = 3.0,
                rank                = 2,
                lvl_req             = 28,
                mana                = 70,
                flags               = spell_flags.snare,
                school              = magic_school.shadow,
            },
            [17312] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 186.0,
                over_time_tick_freq = 1,
                over_time_duration  = 3.0,
                cast_time           = 3.0,
                rank                = 3,
                lvl_req             = 36,
                mana                = 100,
                flags               = spell_flags.snare,
                school              = magic_school.shadow,
            },
            [17313] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 261.0,
                over_time_tick_freq = 1,
                over_time_duration  = 3.0,
                cast_time           = 3.0,
                rank                = 4,
                lvl_req             = 44,
                mana                = 135,
                flags               = spell_flags.snare,
                school              = magic_school.shadow,
            },
            [17314] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 330.0,
                over_time_tick_freq = 1,
                over_time_duration  = 3.0,
                cast_time           = 3.0,
                rank                = 5,
                lvl_req             = 52,
                mana                = 165,
                flags               = spell_flags.snare,
                school              = magic_school.shadow,
            },
            [18807] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 426.0,
                over_time_tick_freq = 1,
                over_time_duration  = 3.0,
                cast_time           = 3.0,
                rank                = 6,
                lvl_req             = 60,
                mana                = 205,
                flags               = spell_flags.snare,
                school              = magic_school.shadow,
            },
            -- devouring plague
            [2944] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 152.0,
                over_time_tick_freq = 3,
                over_time_duration  = 24.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 20,
                mana                = 215,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [19276] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 272.0,
                over_time_tick_freq = 3,
                over_time_duration  = 24.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 28,
                mana                = 350,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [19277] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 400.0,
                over_time_tick_freq = 3,
                over_time_duration  = 24.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 36,
                mana                = 495,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [19278] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 544.0,
                over_time_tick_freq = 3,
                over_time_duration  = 24.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 44,
                mana                = 645,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [19279] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 712.0,
                over_time_tick_freq = 3,
                over_time_duration  = 24.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 52,
                mana                = 810,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [19280] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 904.0,
                over_time_tick_freq = 3,
                over_time_duration  = 24.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 60,
                mana                = 985,
                flags               = 0,
                school              = magic_school.shadow,
            }
        }; 
    elseif class == "SHAMAN" then
        return {
            -- healing stream totem
            [5394] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 6.0 * 30,
                over_time_tick_freq = 2,
                over_time_duration  = 60.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 20,
                mana                = 40,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [6375] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 8.0 * 30,
                over_time_tick_freq = 2,
                over_time_duration  = 60.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 30,
                mana                = 50,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [6377] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 10.0 * 30,
                over_time_tick_freq = 2,
                over_time_duration  = 60.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 40,
                mana                = 60,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [10462] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 12.0 * 30,
                over_time_tick_freq = 2,
                over_time_duration  = 60.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 50,
                mana                = 70,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [10463] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 14.0 * 30,
                over_time_tick_freq = 2,
                over_time_duration  = 60.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 60,
                mana                = 80,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            -- lesser healing
            [8004] = {
                base_min            = 170.0,
                base_max            = 195.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 20,
                mana                = 105,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [8008] = {
                base_min            = 257.0,
                base_max            = 292.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 28,
                mana                = 145,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [8010] = {
                base_min            = 349.0,
                base_max            = 394.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 36,
                mana                = 185,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [10466] = {
                base_min            = 473.0,
                base_max            = 529.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 44,
                mana                = 235,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [10467] = {
                base_min            = 649.0,
                base_max            = 723.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 52,
                mana                = 305,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [10468] = {
                base_min            = 832.0,
                base_max            = 928.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 60,
                mana                = 380,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            -- healing wave
            [331] = {
                base_min            = 36.0,
                base_max            = 47.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 1,
                mana                = 25,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [332] = {
                base_min            = 69.0,
                base_max            = 83.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.0,
                rank                = 2,
                lvl_req             = 6,
                mana                = 45,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [547] = {
                base_min            = 136.0,
                base_max            = 163.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 3,
                lvl_req             = 12,
                mana                = 80,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [913] = {
                base_min            = 279.0,
                base_max            = 328.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 4,
                lvl_req             = 18,
                mana                = 155,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [939] = {
                base_min            = 389.0,
                base_max            = 454.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 5,
                lvl_req             = 24,
                mana                = 200,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [959] = {
                base_min            = 552.0,
                base_max            = 639.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 6,
                lvl_req             = 32,
                mana                = 265,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [8005] = {
                base_min            = 759.0,
                base_max            = 874.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 7,
                lvl_req             = 40,
                mana                = 340,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [10395] = {
                base_min            = 1040.0,
                base_max            = 1191.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 8,
                lvl_req             = 48,
                mana                = 440,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [10396] = {
                base_min            = 1389.0,
                base_max            = 1583.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 9,
                lvl_req             = 56,
                mana                = 560,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [25357] = {
                base_min            = 1620.0,
                base_max            = 1850.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 10,
                lvl_req             = 60,
                mana                = 620,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            -- chain heal
            [1064] = {
                base_min            = 332.0,
                base_max            = 381.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 1,
                lvl_req             = 40,
                mana                = 260,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [10622] = {
                base_min            = 419.0,
                base_max            = 479.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 2,
                lvl_req             = 46,
                mana                = 315,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            [10623] = {
                base_min            = 567.0,
                base_max            = 646.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 3,
                lvl_req             = 54,
                mana                = 405,
                flags               = spell_flags.heal,
                school              = magic_school.nature,
            },
            -- lightning bolt
            [403] = {
                base_min            = 15.0,
                base_max            = 17.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 1,
                mana                = 15,
                flags               = 0,
                school              = magic_school.nature,
            },
            [529] = {
                base_min            = 28.0,
                base_max            = 33.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.0,
                rank                = 2,
                lvl_req             = 8,
                mana                = 30,
                flags               = 0,
                school              = magic_school.nature,
            },
            [548] = {
                base_min            = 48.0,
                base_max            = 57.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 3,
                lvl_req             = 14,
                mana                = 45,
                flags               = 0,
                school              = magic_school.nature,
            },
            [915] = {
                base_min            = 88.0,
                base_max            = 100.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 4,
                lvl_req             = 20,
                mana                = 75,
                flags               = 0,
                school              = magic_school.nature,
            },
            [943] = {
                base_min            = 131.0,
                base_max            = 149.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 5,
                lvl_req             = 26,
                mana                = 105,
                flags               = 0,
                school              = magic_school.nature,
            },
            [6041] = {
                base_min            = 179.0,
                base_max            = 202.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 6,
                lvl_req             = 32,
                mana                = 135,
                flags               = 0,
                school              = magic_school.nature,
            },
            [10391] = {
                base_min            = 235.0,
                base_max            = 264.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 7,
                lvl_req             = 38,
                mana                = 165,
                flags               = 0,
                school              = magic_school.nature,
            },
            [10392] = {
                base_min            = 291.0,
                base_max            = 326.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 8,
                lvl_req             = 44,
                mana                = 195,
                flags               = 0,
                school              = magic_school.nature,
            },
            [15207] = {
                base_min            = 357.0,
                base_max            = 400.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 3,
                lvl_req             = 50,
                mana                = 230,
                flags               = 0,
                school              = magic_school.nature,
            },
            [15208] = {
                base_min            = 428.0,
                base_max            = 477.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 10,
                lvl_req             = 56,
                mana                = 265,
                flags               = 0,
                school              = magic_school.nature,
            },
            -- chain lightning
            [421] = {
                base_min            = 200.0,
                base_max            = 227.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 1,
                lvl_req             = 32,
                mana                = 280,
                flags               = 0,
                school              = magic_school.nature,
            },
            [930] = {
                base_min            = 288.0,
                base_max            = 323.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 40,
                lvl_req             = 2,
                mana                = 380,
                flags               = 0,
                school              = magic_school.nature,
            },
            [2860] = {
                base_min            = 391.0,
                base_max            = 438.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 3,
                lvl_req             = 48,
                mana                = 490,
                flags               = 0,
                school              = magic_school.nature,
            },
            [10605] = {
                base_min            = 505.0,
                base_max            = 564.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 4,
                lvl_req             = 56,
                mana                = 605,
                flags               = 0,
                school              = magic_school.nature,
            },
            -- lightning shield
            [324] = {
                base_min            = 13.0,
                base_max            = 13.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 8,
                mana                = 45,
                flags               = 0,
                school              = magic_school.nature,
            },
            [325] = {
                base_min            = 29.0,
                base_max            = 29.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 16,
                mana                = 80,
                flags               = 0,
                school              = magic_school.nature,
            },
            [905] = {
                base_min            = 51.0,
                base_max            = 51.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 24,
                mana                = 125,
                flags               = 0,
                school              = magic_school.nature,
            },
            [945] = {
                base_min            = 80.0,
                base_max            = 80.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 32,
                mana                = 180,
                flags               = 0,
                school              = magic_school.nature,
            },
            [8134] = {
                base_min            = 114.0,
                base_max            = 114.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 40,
                mana                = 240,
                flags               = 0,
                school              = magic_school.nature,
            },
            [10431] = {
                base_min            = 154.0,
                base_max            = 154.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 48,
                mana                = 305,
                flags               = 0,
                school              = magic_school.nature,
            },
            [10432] = {
                base_min            = 198.0,
                base_max            = 198.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 7,
                lvl_req             = 56,
                mana                = 370,
                flags               = 0,
                school              = magic_school.nature,
            },
            -- earth shock
            [8042] = {
                base_min            = 19.0,
                base_max            = 22.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 4,
                mana                = 30,
                flags               = 0,
                school              = magic_school.nature,
            },
            [8044] = {
                base_min            = 35.0,
                base_max            = 38.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 8,
                mana                = 50,
                flags               = 0,
                school              = magic_school.nature,
            },
            [8045] = {
                base_min            = 65.0,
                base_max            = 69.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 14,
                mana                = 85,
                flags               = 0,
                school              = magic_school.nature,
            },
            [8046] = {
                base_min            = 126.0,
                base_max            = 134.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 24,
                mana                = 145,
                flags               = 0,
                school              = magic_school.nature,
            },
            [10412] = {
                base_min            = 235.0,
                base_max            = 249.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 36,
                mana                = 240,
                flags               = 0,
                school              = magic_school.nature,
            },
            [10413] = {
                base_min            = 372.0,
                base_max            = 394.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 48,
                mana                = 345,
                flags               = 0,
                school              = magic_school.nature,
            },
            [10414] = {
                base_min            = 517.0,
                base_max            = 545.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 7,
                lvl_req             = 60,
                mana                = 450,
                flags               = 0,
                school              = magic_school.nature,
            },
            -- magma totem
            [8190] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 22 * 4,
                over_time_tick_freq = 2,
                over_time_duration  = 20.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 26,
                mana                = 230,
                flags               = spell_flags.aoe,
                school              = magic_school.fire,
            },
            [10585] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 37 * 4,
                over_time_tick_freq = 2,
                over_time_duration  = 20.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 36,
                mana                = 360,
                flags               = spell_flags.aoe,
                school              = magic_school.fire,
            },
            [10586] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 54 * 4,
                over_time_tick_freq = 2,
                over_time_duration  = 20.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 46,
                mana                = 500,
                flags               = spell_flags.aoe,
                school              = magic_school.fire,
            },
            [10587] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 75 * 4,
                over_time_tick_freq = 2,
                over_time_duration  = 20.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 56,
                mana                = 650,
                flags               = spell_flags.aoe,
                school              = magic_school.fire,
            },
            -- flame shock
            [8050] = {
                base_min            = 25.0,
                base_max            = 25.0, 
                over_time           = 25,
                over_time_tick_freq = 3,
                over_time_duration  = 12.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 10,
                mana                = 55,
                flags               = 0,
                school              = magic_school.fire,
            },
            [8052] = {
                base_min            = 51.0,
                base_max            = 51.0, 
                over_time           = 48,
                over_time_tick_freq = 3,
                over_time_duration  = 12.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 18,
                mana                = 95,
                flags               = 0,
                school              = magic_school.fire,
            },
            [8053] = {
                base_min            = 95.0,
                base_max            = 95.0, 
                over_time           = 96,
                over_time_tick_freq = 3,
                over_time_duration  = 12.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 28,
                mana                = 160,
                flags               = 0,
                school              = magic_school.fire,
            },
            [10447] = {
                base_min            = 164.0,
                base_max            = 164.0, 
                over_time           = 168,
                over_time_tick_freq = 3,
                over_time_duration  = 12.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 40,
                mana                = 250,
                flags               = 0,
                school              = magic_school.fire,
            },
            [10448] = {
                base_min            = 245.0,
                base_max            = 245.0, 
                over_time           = 256,
                over_time_tick_freq = 3,
                over_time_duration  = 12.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 52,
                mana                = 345,
                flags               = 0,
                school              = magic_school.fire,
            },
            [29228] = {
                base_min            = 292.0,
                base_max            = 320.0, 
                over_time           = 25,
                over_time_tick_freq = 3,
                over_time_duration  = 12.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 60,
                mana                = 410,
                flags               = 0,
                school              = magic_school.fire,
            },
            -- frost shock
            [8056] = {
                base_min            = 95.0,
                base_max            = 101.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 20,
                mana                = 115,
                flags               = spell_flags.snare,
                school              = magic_school.frost,
            },
            [8058] = {
                base_min            = 215.0,
                base_max            = 230.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 34,
                mana                = 225,
                flags               = spell_flags.snare,
                school              = magic_school.frost,
            },
            [10472] = {
                base_min            = 345.0,
                base_max            = 366.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 46,
                mana                = 325,
                flags               = spell_flags.snare,
                school              = magic_school.frost,
            },
            [10473] = {
                base_min            = 492.0,
                base_max            = 520.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 58,
                mana                = 430,
                flags               = spell_flags.snare,
                school              = magic_school.frost,
            },
            -- TODO: searing totem
            -- fire nova totem
            [1535] = {
                base_min            = 53.0,
                base_max            = 62.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 12,
                mana                = 95,
                flags               = spell_flags.aoe,
                school              = magic_school.fire,
            },
            [8498] = {
                base_min            = 110.0,
                base_max            = 124.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 22,
                mana                = 170,
                flags               = spell_flags.aoe,
                school              = magic_school.fire,
            },
            [8499] = {
                base_min            = 195.0,
                base_max            = 219.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 32,
                mana                = 280,
                flags               = spell_flags.aoe,
                school              = magic_school.fire,
            },
            [11314] = {
                base_min            = 295.0,
                base_max            = 331.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 42,
                mana                = 395,
                flags               = spell_flags.aoe,
                school              = magic_school.fire,
            },
            [11315] = {
                base_min            = 413.0,
                base_max            = 459.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 52,
                mana                = 520,
                flags               = spell_flags.aoe,
                school              = magic_school.fire,
            }
        };
    elseif class == "PALADIN" then
        return {
            -- flash of light
            [19750] = {
                base_min            = 67.0,
                base_max            = 77.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 20,
                mana                = 35,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [19939] = {
                base_min            = 102.0,
                base_max            = 117.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 26,
                mana                = 50,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [19940] = {
                base_min            = 153.0,
                base_max            = 171.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 34,
                mana                = 70,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [19941] = {
                base_min            = 206.0,
                base_max            = 231.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 42,
                mana                = 90,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [19942] = {
                base_min            = 278.0,
                base_max            = 310.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 50,
                mana                = 115,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [19943] = {
                base_min            = 348.0,
                base_max            = 389.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 58,
                mana                = 140,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            -- holy light
            [635] = {
                base_min            = 42.0,
                base_max            = 51.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 1,
                lvl_req             = 1,
                mana                = 35,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [639] = {
                base_min            = 81.0,
                base_max            = 96.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 2,
                lvl_req             = 6,
                mana                = 60,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [647] = {
                base_min            = 167.0,
                base_max            = 196.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 3,
                lvl_req             = 14,
                mana                = 110,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [1026] = {
                base_min            = 332.0,
                base_max            = 368.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 4,
                lvl_req             = 22,
                mana                = 190,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [1042] = {
                base_min            = 506.0,
                base_max            = 569.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 5,
                lvl_req             = 30,
                mana                = 275,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [3472] = {
                base_min            = 717.0,
                base_max            = 799.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 6,
                lvl_req             = 38,
                mana                = 365,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [10328] = {
                base_min            = 968.0,
                base_max            = 1067.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 7,
                lvl_req             = 46,
                mana                = 465,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [10329] = {
                base_min            = 1272.0,
                base_max            = 1414.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 8,
                lvl_req             = 54,
                mana                = 580,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [25292] = {
                base_min            = 1590.0,
                base_max            = 1770.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 9,
                lvl_req             = 60,
                mana                = 660,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            -- holy shock
            [20473] = {
                base_min            = 204.0,
                base_max            = 220.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 40,
                mana                = 225,
                flags               = 0,
                school              = magic_school.holy,
                healing_version = {
                    base_min            = 204.0,
                    base_max            = 220.0, 
                    over_time           = 0,
                    over_time_tick_freq = 0,
                    over_time_duration  = 0.0,
                    cast_time           = 1.5,
                    rank                = 1,
                    lvl_req             = 40,
                    mana                = 225,
                    flags               = spell_flags.heal,
                    school              = magic_school.holy,
                }
            },
            [20929] = {
                base_min            = 279.0,
                base_max            = 301.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 48,
                mana                = 275,
                flags               = 0,
                school              = magic_school.holy,
                healing_version = {
                    base_min            = 279.0,
                    base_max            = 301.0, 
                    over_time           = 0,
                    over_time_tick_freq = 0,
                    over_time_duration  = 0.0,
                    cast_time           = 1.5,
                    rank                = 1,
                    lvl_req             = 48,
                    mana                = 275,
                    flags               = spell_flags.heal,
                    school              = magic_school.holy,
                }
            },
            [20930] = {
                base_min            = 365.0,
                base_max            = 395.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 56,
                mana                = 325,
                flags               = 0,
                school              = magic_school.holy,
                healing_version = {
                    base_min            = 365.0,
                    base_max            = 395.0, 
                    over_time           = 0,
                    over_time_tick_freq = 0,
                    over_time_duration  = 0.0,
                    cast_time           = 1.5,
                    rank                = 3,
                    lvl_req             = 56,
                    mana                = 325,
                    flags               = spell_flags.heal,
                    school              = magic_school.holy,
                }
            }, 
            -- hammer of wrath
            [24275] = {
                base_min            = 316.0,
                base_max            = 348.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.0,
                rank                = 1,
                lvl_req             = 44,
                mana                = 295,
                flags               = 0,
                school              = magic_school.holy
            },
            [24274] = {
                base_min            = 412.0,
                base_max            = 455.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.0,
                rank                = 2,
                lvl_req             = 52,
                mana                = 360,
                flags               = 0,
                school              = magic_school.holy
            },
            [24239] = {
                base_min            = 504.0,
                base_max            = 556.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.0,
                rank                = 3,
                lvl_req             = 60,
                mana                = 425,
                flags               = 0,
                school              = magic_school.holy
            },
            -- consecration
            [26573] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 64,
                over_time_tick_freq = 1,
                over_time_duration  = 8.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 20,
                mana                = 135,
                flags               = spell_flags.aoe,
                school              = magic_school.holy
            },
            [20116] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 120,
                over_time_tick_freq = 1,
                over_time_duration  = 8.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 30,
                mana                = 235,
                flags               = spell_flags.aoe,
                school              = magic_school.holy
            },
            [20922] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 192,
                over_time_tick_freq = 1,
                over_time_duration  = 8.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 40,
                mana                = 320,
                flags               = spell_flags.aoe,
                school              = magic_school.holy
            },
            [20923] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 280,
                over_time_tick_freq = 1,
                over_time_duration  = 8.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 50,
                mana                = 435,
                flags               = spell_flags.aoe,
                school              = magic_school.holy
            },
            [20924] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 384,
                over_time_tick_freq = 1,
                over_time_duration  = 8.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 60,
                mana                = 565,
                flags               = spell_flags.aoe,
                school              = magic_school.holy
            },
            -- exorcism
            [879] = {
                base_min            = 90.0,
                base_max            = 102.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 20,
                mana                = 85,
                flags               = 0,
                school              = magic_school.holy
            },
            [5614] = {
                base_min            = 160.0,
                base_max            = 180.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 28,
                mana                = 135,
                flags               = 0,
                school              = magic_school.holy
            },
            [5615] = {
                base_min            = 227.0,
                base_max            = 255.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 36,
                mana                = 180,
                flags               = 0,
                school              = magic_school.holy
            },
            [10312] = {
                base_min            = 316.0,
                base_max            = 354.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 44,
                mana                = 235,
                flags               = 0,
                school              = magic_school.holy
            },
            [10313] = {
                base_min            = 407.0,
                base_max            = 453.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 52,
                mana                = 285,
                flags               = 0,
                school              = magic_school.holy
            },
            [10314] = {
                base_min            = 505.0,
                base_max            = 563.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 60,
                mana                = 345,
                flags               = 0,
                school              = magic_school.holy
            },
            -- holy wrath
            [2812] = {
                base_min            = 368.0,
                base_max            = 435.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.0,
                rank                = 1,
                lvl_req             = 50,
                mana                = 645,
                flags               = spell_flags.aoe,
                school              = magic_school.holy
            },
            [10318] = {
                base_min            = 490.0,
                base_max            = 576.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.0,
                rank                = 2,
                lvl_req             = 60,
                mana                = 805,
                flags               = spell_flags.aoe,
                school              = magic_school.holy
            }
        };

    elseif class == "WARLOCK" then
        return {
            -- curse of agony
            [980] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 84,
                over_time_tick_freq = 2,
                over_time_duration  = 24.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 8,
                mana                = 25,
                flags               = 0,
                school              = magic_school.shadow
            },
            [1014] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 180,
                over_time_tick_freq = 2,
                over_time_duration  = 24.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 18,
                mana                = 50,
                flags               = 0,
                school              = magic_school.shadow
            },
            [6217] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 324,
                over_time_tick_freq = 2,
                over_time_duration  = 24.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 28,
                mana                = 90,
                flags               = 0,
                school              = magic_school.shadow
            },
            [11711] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 504,
                over_time_tick_freq = 2,
                over_time_duration  = 24.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 38,
                mana                = 130,
                flags               = 0,
                school              = magic_school.shadow
            },
            [11712] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 780,
                over_time_tick_freq = 2,
                over_time_duration  = 24.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 48,
                mana                = 170,
                flags               = 0,
                school              = magic_school.shadow
            },
            [11713] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 1044,
                over_time_tick_freq = 2,
                over_time_duration  = 24.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 58,
                mana                = 215,
                flags               = 0,
                school              = magic_school.shadow
            },
            -- siphon life
            [18265] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 15,
                over_time_tick_freq = 3,
                over_time_duration  = 30.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 30,
                mana                = 150,
                flags               = 0,
                school              = magic_school.shadow
            },
            [18879] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 22,
                over_time_tick_freq = 3,
                over_time_duration  = 30.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 38,
                mana                = 205,
                flags               = 0,
                school              = magic_school.shadow
            },
            [18880] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 33,
                over_time_tick_freq = 3,
                over_time_duration  = 30.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 48,
                mana                = 285,
                flags               = 0,
                school              = magic_school.shadow
            },
            [18881] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 15,
                over_time_tick_freq = 3,
                over_time_duration  = 45.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 58,
                mana                = 365,
                flags               = 0,
                school              = magic_school.shadow
            },
            -- death coil
            [6789] = {
                base_min            = 301.0,
                base_max            = 301.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 42,
                mana                = 430,
                flags               = spell_flags.snare,
                school              = magic_school.shadow
            },
            [17925] = {
                base_min            = 391.0,
                base_max            = 391.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 50,
                mana                = 495,
                flags               = spell_flags.snare,
                school              = magic_school.shadow
            },
            [17926] = {
                base_min            = 476.0,
                base_max            = 476.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 58,
                mana                = 565,
                flags               = spell_flags.snare,
                school              = magic_school.shadow
            },
            -- corruption
            [172] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 40,
                over_time_tick_freq = 3,
                over_time_duration  = 12.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 4,
                mana                = 35,
                flags               = 0,
                school              = magic_school.shadow
            },
            [6222] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 90,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 14,
                mana                = 55,
                flags               = 0,
                school              = magic_school.shadow
            },
            [6223] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 222,
                over_time_tick_freq = 3,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 24,
                mana                = 100,
                flags               = 0,
                school              = magic_school.shadow
            },
            [7648] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 324,
                over_time_tick_freq = 3,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 34,
                mana                = 160,
                flags               = 0,
                school              = magic_school.shadow
            },
            [11671] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 486,
                over_time_tick_freq = 3,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 44,
                mana                = 225,
                flags               = 0,
                school              = magic_school.shadow
            },
            [11672] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 666,
                over_time_tick_freq = 3,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 54,
                mana                = 290,
                flags               = 0,
                school              = magic_school.shadow
            },
            [25311] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 822,
                over_time_tick_freq = 3,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 7,
                lvl_req             = 60,
                mana                = 340,
                flags               = 0,
                school              = magic_school.shadow
            },
            -- drain life
            [689] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 10 * 5,
                over_time_tick_freq = 1,
                over_time_duration  = 5.0,
                cast_time           = 5.0,
                rank                = 1,
                lvl_req             = 14,
                mana                = 55,
                flags               = 0,
                school              = magic_school.shadow
            },
            [699] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 17 * 5,
                over_time_tick_freq = 1,
                over_time_duration  = 5.0,
                cast_time           = 5.0,
                rank                = 2,
                lvl_req             = 22,
                mana                = 85,
                flags               = 0,
                school              = magic_school.shadow
            },
            [709] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 29 * 5,
                over_time_tick_freq = 1,
                over_time_duration  = 5.0,
                cast_time           = 5.0,
                rank                = 3,
                lvl_req             = 30,
                mana                = 135,
                flags               = 0,
                school              = magic_school.shadow
            },
            [7651] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 41 * 5,
                over_time_tick_freq = 1,
                over_time_duration  = 5.0,
                cast_time           = 5.0,
                rank                = 4,
                lvl_req             = 38,
                mana                = 185,
                flags               = 0,
                school              = magic_school.shadow
            },
            [11699] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 55 * 5,
                over_time_tick_freq = 1,
                over_time_duration  = 5.0,
                cast_time           = 5.0,
                rank                = 5,
                lvl_req             = 46,
                mana                = 240,
                flags               = 0,
                school              = magic_school.shadow
            },
            [11700] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 71 * 5,
                over_time_tick_freq = 1,
                over_time_duration  = 5.0,
                cast_time           = 5.0,
                rank                = 6,
                lvl_req             = 54,
                mana                = 300,
                flags               = 0,
                school              = magic_school.shadow
            },
            -- drain soul
            [1120] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 55,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 15.0,
                rank                = 1,
                lvl_req             = 10,
                mana                = 55,
                flags               = 0,
                school              = magic_school.shadow
            },
            [8288] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 155,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 15.0,
                rank                = 2,
                lvl_req             = 24,
                mana                = 125,
                flags               = 0,
                school              = magic_school.shadow
            },
            [8289] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 295,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 15.0,
                rank                = 3,
                lvl_req             = 38,
                mana                = 210,
                flags               = 0,
                school              = magic_school.shadow
            },
            [11675] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 455,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 15.0,
                rank                = 4,
                lvl_req             = 52,
                mana                = 290,
                flags               = 0,
                school              = magic_school.shadow
            },
            --shadow bolt
            [686] = {
                base_min            = 13.0,
                base_max            = 18.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.7,
                rank                = 1,
                lvl_req             = 1,
                mana                = 25,
                flags               = 0,
                school              = magic_school.shadow
            },
            [695] = {
                base_min            = 26.0,
                base_max            = 32.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.2,
                rank                = 2,
                lvl_req             = 6,
                mana                = 40,
                flags               = 0,
                school              = magic_school.shadow
            },
            [705] = {
                base_min            = 52.0,
                base_max            = 61.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.8,
                rank                = 3,
                lvl_req             = 12,
                mana                = 70,
                flags               = 0,
                school              = magic_school.shadow
            },
            [1088] = {
                base_min            = 92.0,
                base_max            = 104.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 4,
                lvl_req             = 20,
                mana                = 110,
                flags               = 0,
                school              = magic_school.shadow
            },
            [1106] = {
                base_min            = 150.0,
                base_max            = 170.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 5,
                lvl_req             = 28,
                mana                = 160,
                flags               = 0,
                school              = magic_school.shadow
            },
            [7641] = {
                base_min            = 213.0,
                base_max            = 240.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 6,
                lvl_req             = 36,
                mana                = 210,
                flags               = 0,
                school              = magic_school.shadow
            },
            [11659] = {
                base_min            = 292.0,
                base_max            = 327.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 7,
                lvl_req             = 44,
                mana                = 265,
                flags               = 0,
                school              = magic_school.shadow
            },
            [11660] = {
                base_min            = 373.0,
                base_max            = 415.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 8,
                lvl_req             = 52,
                mana                = 315,
                flags               = 0,
                school              = magic_school.shadow
            },
            [11661] = {
                base_min            = 455.0,
                base_max            = 507.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 9,
                lvl_req             = 60,
                mana                = 370,
                flags               = 0,
                school              = magic_school.shadow
            },
            [25307] = {
                base_min            = 482.0,
                base_max            = 538.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 3.0,
                rank                = 10,
                lvl_req             = 60,
                mana                = 380,
                flags               = 0,
                school              = magic_school.shadow
            },
            -- searing pain
            [5676] = {
                base_min            = 38.0,
                base_max            = 47.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 18,
                mana                = 45,
                flags               = 0,
                school              = magic_school.fire
            },
            [17919] = {
                base_min            = 65.0,
                base_max            = 77.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 26,
                mana                = 68,
                flags               = 0,
                school              = magic_school.fire
            },
            [17920] = {
                base_min            = 93.0,
                base_max            = 112.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 34,
                mana                = 91,
                flags               = 0,
                school              = magic_school.fire
            },
            [17921] = {
                base_min            = 131.0,
                base_max            = 155.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 42,
                mana                = 118,
                flags               = 0,
                school              = magic_school.fire
            },
            [17922] = {
                base_min            = 168.0,
                base_max            = 199.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 50,
                mana                = 141,
                flags               = 0,
                school              = magic_school.fire
            },
            [17923] = {
                base_min            = 208.0,
                base_max            = 244.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 58,
                mana                = 168,
                flags               = 0,
                school              = magic_school.fire
            },
            -- soul fire
            [6353] = {
                base_min            = 640.0,
                base_max            = 801.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 6.0,
                rank                = 1,
                lvl_req             = 48,
                mana                = 305,
                flags               = 0,
                school              = magic_school.fire
            },
            [17924] = {
                base_min            = 715.0,
                base_max            = 894.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 6.0,
                rank                = 2,
                lvl_req             = 56,
                mana                = 335,
                flags               = 0,
                school              = magic_school.fire
            },
            -- hellfire
            [1949] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 87.0*15,
                over_time_tick_freq = 1,
                over_time_duration  = 15.0,
                cast_time           = 15.0,
                rank                = 3,
                lvl_req             = 30,
                mana                = 645,
                flags               = spell_flags.aoe,
                school              = magic_school.fire
            },
            [11683] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 144.0*15,
                over_time_tick_freq = 1,
                over_time_duration  = 15.0,
                cast_time           = 15.0,
                rank                = 2,
                lvl_req             = 42,
                mana                = 975,
                flags               = spell_flags.aoe,
                school              = magic_school.fire
            },
            [11684] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 213.0*15,
                over_time_tick_freq = 1,
                over_time_duration  = 15.0,
                cast_time           = 15.0,
                rank                = 3,
                lvl_req             = 54,
                mana                = 1300,
                flags               = spell_flags.aoe,
                school              = magic_school.fire
            },
            -- rain of fire
            [5740] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 168.0,
                over_time_tick_freq = 2,
                over_time_duration  = 8.0,
                cast_time           = 8.0,
                rank                = 1,
                lvl_req             = 20,
                mana                = 295,
                flags               = spell_flags.aoe,
                school              = magic_school.fire
            },
            [6219] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 384.0,
                over_time_tick_freq = 2,
                over_time_duration  = 8.0,
                cast_time           = 8.0,
                rank                = 2,
                lvl_req             = 34,
                mana                = 605,
                flags               = spell_flags.aoe,
                school              = magic_school.fire
            },
            [11677] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 620.0,
                over_time_tick_freq = 2,
                over_time_duration  = 8.0,
                cast_time           = 8.0,
                rank                = 3,
                lvl_req             = 46,
                mana                = 885,
                flags               = spell_flags.aoe,
                school              = magic_school.fire
            },
            [11678] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 904.0,
                over_time_tick_freq = 2,
                over_time_duration  = 8.0,
                cast_time           = 8.0,
                rank                = 4,
                lvl_req             = 58,
                mana                = 1185,
                flags               = spell_flags.aoe,
                school              = magic_school.fire
            },
            -- immolate
            [348] = {
                base_min            = 11.0,
                base_max            = 11.0, 
                over_time           = 20.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 2.0,
                rank                = 1,
                lvl_req             = 1,
                mana                = 25,
                flags               = 0,
                school              = magic_school.fire
            },
            [707] = {
                base_min            = 24.0,
                base_max            = 24.0, 
                over_time           = 40.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 2.0,
                rank                = 2,
                lvl_req             = 10,
                mana                = 45,
                flags               = 0,
                school              = magic_school.fire
            },
            [1094] = {
                base_min            = 53.0,
                base_max            = 53.0, 
                over_time           = 90.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 2.0,
                rank                = 3,
                lvl_req             = 20,
                mana                = 90,
                flags               = 0,
                school              = magic_school.fire
            },
            [2941] = {
                base_min            = 101.0,
                base_max            = 101.0, 
                over_time           = 165.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 2.0,
                rank                = 4,
                lvl_req             = 30,
                mana                = 155,
                flags               = 0,
                school              = magic_school.fire
            },
            [11665] = {
                base_min            = 148.0,
                base_max            = 148.0, 
                over_time           = 255.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 2.0,
                rank                = 5,
                lvl_req             = 40,
                mana                = 220,
                flags               = 0,
                school              = magic_school.fire
            },
            [11667] = {
                base_min            = 208.0,
                base_max            = 208.0, 
                over_time           = 365.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 2.0,
                rank                = 6,
                lvl_req             = 50,
                mana                = 295,
                flags               = 0,
                school              = magic_school.fire
            },
            [11668] = {
                base_min            = 258.0,
                base_max            = 258.0, 
                over_time           = 485.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 2.0,
                rank                = 7,
                lvl_req             = 60,
                mana                = 370,
                flags               = 0,
                school              = magic_school.fire
            },
            [25309] = {
                base_min            = 279.0,
                base_max            = 279.0, 
                over_time           = 510.0,
                over_time_tick_freq = 3,
                over_time_duration  = 15.0,
                cast_time           = 2.0,
                rank                = 8,
                lvl_req             = 60,
                mana                = 380,
                flags               = 0,
                school              = magic_school.fire
            },
            -- shadowburn
            [17877] = {
                base_min            = 91.0,
                base_max            = 104.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 20,
                mana                = 105,
                flags               = 0,
                school              = magic_school.shadow
            },
            [18867] = {
                base_min            = 123.0,
                base_max            = 140.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 24,
                mana                = 103,
                flags               = 0,
                school              = magic_school.shadow
            },
            [18868] = {
                base_min            = 196.0,
                base_max            = 221.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 32,
                mana                = 190,
                flags               = 0,
                school              = magic_school.shadow
            },
            [18869] = {
                base_min            = 274.0,
                base_max            = 307.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 40,
                mana                = 245,
                flags               = 0,
                school              = magic_school.shadow
            },
            [18870] = {
                base_min            = 365.0,
                base_max            = 408.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 48,
                mana                = 305,
                flags               = 0,
                school              = magic_school.shadow
            },
            [18871] = {
                base_min            = 462.0,
                base_max            = 514.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 56,
                mana                = 365, 
                flags               = 0,
                school              = magic_school.shadow
            },
            -- conflagrate
            [17962] = {
                base_min            = 249.0,
                base_max            = 316.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 40,
                mana                = 165, 
                flags               = 0,
                school              = magic_school.fire
            },
            [18930] = {
                base_min            = 326.0,
                base_max            = 407.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 48,
                mana                = 200, 
                flags               = 0,
                school              = magic_school.fire
            },
            [18931] = {
                base_min            = 395.0,
                base_max            = 491.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 54,
                mana                = 230, 
                flags               = 0,
                school              = magic_school.fire
            },
            [18932] = {
                base_min            = 447.0,
                base_max            = 557.0, 
                over_time           = 0.0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 60,
                mana                = 255, 
                flags               = 0,
                school              = magic_school.fire
            }
        };
    end
    return {};
end


local spells = create_spells();

local function get_spell(spell_id)

    return spells[spell_id];
end

local function localized_spell_name(english_name)
    local name, _, _, _, _, _, _ = GetSpellInfo(spell_name_to_id[english_name]);
    return name;
end

local function empty_loadout()

    return  {
        name = "Empty loadout";
        lvl = 0,
        target_lvl = 63,
        int = 0,
        spirit = 0,

        spelldmg_by_school = {0, 0, 0, 0, 0, 0, 0},
        healingpower = 0,

        --spell_crit = 0,
        spell_crit_by_school = {0, 0, 0, 0, 0, 0, 0},
        healing_crit = 0,

        spelldmg_hit_by_school = {0, 0, 0, 0, 0, 0, 0},
        spell_dmg_mod_by_school = {0, 0, 0, 0, 0, 0, 0},
        spell_crit_mod_by_school = {0, 0, 0, 0, 0, 0, 0},

        spell_heal_mod_base = 0,
        spell_heal_mod = 0,

        haste_mod = 0,
        cost_mod = 0,

        stat_mod = {0, 0, 0, 0, 0},

        ignite = 0,
        spiritual_guidance = 0,
        illumination  = 0,
        master_of_elements  = 0,
        natures_grace = 0,
        improved_immolate = 0,
        improved_shadowbolt = 0,

        num_set_pieces = {0, 0, 0, 0, 0, 0, 0, 0},
        
        -- indexable by ability name
        ability_crit = {},
        ability_effect_mod= {},
        ability_cast_mod = {},
        ability_extra_ticks = {},
        ability_cost_mod = {},
        ability_crit_mod = {},
        ability_hit = {}
    };
end

local function negate_loadout(loadout)

    local negated = loadout;

    negated.int = -loadout.int;
    negated.spirit = -loadout.spirit;

    for i = 1, 7 do
        negated.spelldmg_by_school[i] = -loadout.spelldmg_by_school[i];
    end
    negated.healingpower = -loadout.healingpower;

    for i = 1, 7 do
        negated.spell_crit_by_school[i] = -loadout.spell_crit_by_school[i];
    end
    negated.healing_crit = -loadout.healing_crit;

    for i = 1, 7 do
        negated.spelldmg_hit_by_school[i] = -loadout.spelldmg_hit_by_school[i];
    end

    for i = 1, 7 do
        negated.spell_dmg_mod_by_school[i] = -loadout.spell_dmg_mod_by_school[i];
    end

    for i = 1, 7 do
        negated.spell_crit_mod_by_school[i] = -loadout.spell_crit_mod_by_school[i];
    end
    negated.spell_heal_mod_base = -negated.spell_heal_mod_base;
    negated.spell_heal_mod = -negated.spell_heal_mod;

    negated.haste_mod = -negated.haste_mod;
    negated.cost_mod = -negated.cost_mod;

    return negated;
end

-- deep copy to avoid reference entanglement
local function loadout_copy(loadout)

    local cpy = {};

    cpy.name =  loadout.name;
    cpy.lvl =  loadout.lvl;
    cpy.target_lvl =  loadout.target_lvl;
    cpy.int =  loadout.int;
    cpy.spirit = loadout.spirit;

    cpy.healingpower = loadout.healingpower;

    cpy.spelldmg_by_school = {};
    cpy.spell_crit_by_school = {};
    cpy.healing_crit = loadout.healing_crit;
    cpy.spelldmg_hit_by_school = {};
    cpy.spell_dmg_mod_by_school = {};
    cpy.spell_crit_mod_by_school = {};

    cpy.spell_heal_mod_base = loadout.spell_heal_mod_base;
    cpy.spell_heal_mod = loadout.spell_heal_mod;

    cpy.haste_mod = loadout.haste_mod;
    cpy.cost_mod = loadout.cost_mod;


    cpy.ignite = loadout.ignite;
    cpy.spiritual_guidance = loadout.spiritual_guidance;
    cpy.illumination = loadout.illumination;
    cpy.master_of_elements = loadout.master_of_elements;
    cpy.natures_grace = loadout.natures_grace;
    cpy.improved_immolate = loadout.improved_immolate;
    cpy.improved_shadowbolt = loadout.improved_shadowbolt;

    cpy.stat_mod = {};

    cpy.ability_crit = {};
    cpy.ability_effect_mod = {};
    cpy.ability_cast_mod = {};
    cpy.ability_extra_ticks = {};
    cpy.ability_cost_mod = {};
    cpy.ability_crit_mod = {};
    cpy.ability_hit = {};

    for i = 1, 7 do
        cpy.spelldmg_by_school[i] = loadout.spelldmg_by_school[i];
        cpy.spell_crit_by_school[i] = loadout.spell_crit_by_school[i];
        cpy.spelldmg_hit_by_school[i] = loadout.spelldmg_hit_by_school[i];
        cpy.spell_dmg_mod_by_school[i] = loadout.spell_dmg_mod_by_school[i];
        cpy.spell_crit_mod_by_school[i] = loadout.spell_crit_mod_by_school[i];
    end

    cpy.num_set_pieces = {};
    for i = set_tiers.pve_0, set_tiers.pve_2_5 do
        cpy.num_set_pieces[i] = loadout.num_set_pieces[i];
    end

    for i = 1, 5 do
        cpy.stat_mod[i] = loadout.stat_mod[i];
    end

    cpy.spell_heal_mod_base = loadout.spell_heal_mod_base;
    cpy.spell_heal_mod = loadout.spell_heal_mod;

    for k, v in pairs(loadout.ability_crit) do
        cpy.ability_crit[k] = v;
    end
    for k, v in pairs(loadout.ability_effect_mod) do
        cpy.ability_effect_mod[k] = v;
    end
    for k, v in pairs(loadout.ability_cast_mod) do
        cpy.ability_cast_mod[k] = v;
    end
    for k, v in pairs(loadout.ability_extra_ticks) do
        cpy.ability_extra_ticks[k] = v;
    end
    for k, v in pairs(loadout.ability_cost_mod) do
        cpy.ability_cost_mod[k] = v;
    end
    for k, v in pairs(loadout.ability_crit_mod) do
        cpy.ability_crit_mod[k] = v;
    end
    for k, v in pairs(loadout.ability_hit) do
        cpy.ability_hit[k] = v;
    end

    return cpy;
end

local function loadout_add(primary, diff)

    local added = loadout_copy(primary);

    added.int = primary.int + diff.int * (1 + primary.stat_mod[stat.int]);
    added.spirit = primary.spirit + diff.spirit * (1 + primary.stat_mod[stat.spirit]);

    local sp_gained_from_spirit = diff.spirit * (1 + primary.stat_mod[stat.spirit]) * primary.spiritual_guidance * 0.05;

    for i = 1, 7 do
        added.spelldmg_by_school[i] = primary.spelldmg_by_school[i] + diff.spelldmg_by_school[i] + sp_gained_from_spirit;
    end
    added.healingpower = primary.healingpower + diff.healingpower + sp_gained_from_spirit;

    -- introduce crit by intellect here
    crit_diff_normalized_to_primary = diff.int * ((1 + primary.stat_mod[stat.int])/60)/100; -- assume diff has no stat mod
    for i = 1, 7 do
        added.spell_crit_by_school[i] = primary.spell_crit_by_school[i] + diff.spell_crit_by_school[i] + 
            crit_diff_normalized_to_primary;
    end

    added.healing_crit = primary.healing_crit + diff.healing_crit + crit_diff_normalized_to_primary;

    for i = 1, 7 do
        added.spelldmg_hit_by_school[i] = primary.spelldmg_hit_by_school[i] + diff.spelldmg_hit_by_school[i];
    end

    for i = 1, 7 do
        added.spell_dmg_mod_by_school[i] = primary.spell_dmg_mod_by_school[i] + diff.spell_dmg_mod_by_school[i];
    end

    for i = 1, 7 do
        added.spell_crit_mod_by_school[i] = primary.spell_crit_mod_by_school[i] + diff.spell_crit_mod_by_school[i];
    end

    added.spell_heal_mod_base = primary.spell_heal_mod_base + diff.spell_heal_mod_base;
    added.spell_heal_mod = primary.spell_heal_mod + diff.spell_heal_mod;

    added.haste_mod = primary.haste_mod + diff.haste_mod;
    added.cost_mod = primary.cost_mod + diff.cost_mod;

    return added;
end

local function apply_talents(loadout)

    local new_loadout = loadout;
    
    local _, class = UnitClass("player");
    if class == "MAGE" then

        -- arcane focus
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 2);
        if pts ~= 0 then
            new_loadout.spelldmg_hit_by_school[magic_school.arcane] = 
                new_loadout.spelldmg_hit_by_school[magic_school.arcane] + pts * 0.02;
        end
        --  improved arcane explosion
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 8);
        if pts ~= 0 then
            local ae = localized_spell_name("Arcane Explosion");
            if not new_loadout.ability_crit[ae] then
                new_loadout.ability_crit[ae] = 0;
            end
            new_loadout.ability_crit[ae] = new_loadout.ability_crit[ae] + pts * 0.02;
        end
        -- arcane instability
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 15);
        if pts ~= 0 then
            for i = 1, 7 do
                new_loadout.spell_dmg_mod_by_school[i] = new_loadout.spell_dmg_mod_by_school[i] + pts * 0.01;
                new_loadout.spell_crit_by_school[i] = new_loadout.spell_crit_by_school[i] + pts * 0.01;
            end
        end
        -- improved fireball
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 1);
        if pts ~= 0 then
            local fb = localized_spell_name("Fireball");
            if not new_loadout.ability_cast_mod[fb] then
                new_loadout.ability_cast_mod[fb] = 0;
            end
            new_loadout.ability_cast_mod[fb] = new_loadout.ability_cast_mod[fb] + pts * 0.1;
        end
        -- ignite
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 3);
        if pts ~= 0 then
           new_loadout.ignite = pts; 
        end
        -- incinerate
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 6);
        if pts ~= 0 then
            local scorch = localized_spell_name("Scorch");
            local fb = localized_spell_name("Fire Blast");
            if not new_loadout.ability_crit[scorch] then
                new_loadout.ability_crit[scorch] = 0;
            end
            if not new_loadout.ability_crit[fb] then
                new_loadout.ability_crit[fb] = 0;
            end
            new_loadout.ability_crit[scorch] = new_loadout.ability_crit[scorch] + pts * 0.02;
            new_loadout.ability_crit[fb] = new_loadout.ability_crit[fb] + pts * 0.02;
        end
        -- improved flamestrike
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 7);
        if pts ~= 0 then
            local fs = localized_spell_name("Flamestrike");
            if not new_loadout.ability_crit[fs] then
                new_loadout.ability_crit[fs] = 0;
            end
            new_loadout.ability_crit[fs] = new_loadout.ability_crit[fs] + pts * 0.05;
        end
        -- master of elements
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 9);
        if pts ~= 0 then
            new_loadout.master_of_elements = pts;
        end
        -- critical mass
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 13);
        if pts ~= 0 then
            new_loadout.spell_crit_by_school[magic_school.fire] =
                new_loadout.spell_crit_by_school[magic_school.fire] + pts * 0.02;
        end
        -- fire power
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 15);
        if pts ~= 0 then
            new_loadout.spell_dmg_mod_by_school[magic_school.fire] =
                new_loadout.spell_dmg_mod_by_school[magic_school.fire] + pts * 0.02;
        end
        -- improved frostbolt
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 2);
        if pts ~= 0 then
            local fb = localized_spell_name("Frostbolt");
            if not new_loadout.ability_cast_mod[fb] then
                new_loadout.ability_cast_mod[fb] = 0;
            end
            new_loadout.ability_cast_mod[fb] = new_loadout.ability_cast_mod[fb] + pts * 0.1;
        end
        -- elemental precision
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 3);
        if pts ~= 0 then
            new_loadout.spelldmg_hit_by_school[magic_school.fire] = 
                new_loadout.spelldmg_hit_by_school[magic_school.fire] + pts * 0.02;
            new_loadout.spelldmg_hit_by_school[magic_school.frost] = 
                new_loadout.spelldmg_hit_by_school[magic_school.frost] + pts * 0.02;
        end
        -- ice shards
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 4);
        if pts ~= 0 then
            new_loadout.spell_crit_mod_by_school[magic_school.frost] = 
                1 + (new_loadout.spell_crit_mod_by_school[magic_school.frost] - 1) * (1 + pts * 0.2);
        end
        -- piercing ice
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 8);
        if pts ~= 0 then
            new_loadout.spell_dmg_mod_by_school[5] = new_loadout.spell_dmg_mod_by_school[5] + pts * 0.02;
        end
        -- frost channeling
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 12);
        if pts ~= 0 then

            local cold_spells = {"Frostbolt", "Blizzard", "Cone of Cold", "Frost Nova"};
            for k, v in pairs(cold_spells) do
                cold_spells[k] = localized_spell_name(v);
            end

            for k, v in pairs(cold_spells) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(cold_spells) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.05;
            end
        end
        -- improved cone of cold
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 15);
        if pts ~= 0 then
            local coc = localized_spell_name("Cone of Cold");
            if not new_loadout.ability_effect_mod[coc] then
                new_loadout.ability_effect_mod[coc] = 0;
            end
            new_loadout.ability_effect_mod[coc] = new_loadout.ability_effect_mod[coc] + pts * 0.15;
        end
    elseif class == "DRUID" then

        -- improved wrath
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 1);
        if pts ~= 0 then
            local wrath = localized_spell_name("Wrath");
            if not new_loadout.ability_cast_mod[wrath] then
                new_loadout.ability_cast_mod[wrath] = 0;
            end
            new_loadout.ability_cast_mod[wrath] = new_loadout.ability_cast_mod[wrath] + pts * 0.1;
        end

        -- improved moonfire
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 5);
        if pts ~= 0 then
            local mf = localized_spell_name("Moonfire");
            if not new_loadout.ability_effect_mod[mf] then
                new_loadout.ability_effect_mod[mf] = 0;
            end
            if not new_loadout.ability_crit[mf] then
                new_loadout.ability_crit[mf] = 0;
            end
            new_loadout.ability_effect_mod[mf] = new_loadout.ability_effect_mod[mf] + pts * 0.02;
            new_loadout.ability_crit[mf] = new_loadout.ability_crit[mf] + pts * 0.02;
        end

        -- vengeance
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 11);
        if pts ~= 0 then

            local mf = localized_spell_name("Moonfire");
            local sf = localized_spell_name("Starfire");
            local wrath = localized_spell_name("Wrath");
            if not new_loadout.ability_crit_mod[v] then
                new_loadout.ability_crit_mod[mf] = 0;
                new_loadout.ability_crit_mod[sf] = 0;
                new_loadout.ability_crit_mod[wrath] = 0;
            end
            -- TODO: uhh why do it like this?
            new_loadout.ability_crit_mod[mf] = 
                (new_loadout.spell_crit_mod_by_school[magic_school.arcane] - 1) * (pts * 0.2);
            new_loadout.ability_crit_mod[sf] = 
                (new_loadout.spell_crit_mod_by_school[magic_school.arcane] - 1) * (pts * 0.2);
            new_loadout.ability_crit_mod[wrath] = 
                (new_loadout.spell_crit_mod_by_school[magic_school.nature] - 1) * (pts * 0.2);
        end

        -- improved starfire
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 12);
        if pts ~= 0 then
            local sf = localized_spell_name("Starfire");
            if not new_loadout.ability_cast_mod[sf] then
                new_loadout.ability_cast_mod[sf] = 0;
            end
            new_loadout.ability_cast_mod[sf] = new_loadout.ability_cast_mod[sf] + pts * 0.1;
        end

        -- nature's grace
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 13);
        if pts ~= 0 then
            new_loadout.natures_grace = pts;
        end

        -- moonglow
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 14);
        if pts ~= 0 then
            local abilities = {"Moonfire", "Starfire", "Wrath", "Healing Touch", "Regrowth", "Rejuvenation"};

            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end
            for k, v in pairs(abilities) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.03;
            end
        end

        -- moonfury
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 15);
        if pts ~= 0 then
            local abilities = {"Starfire", "Moonfire", "Wrath"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end
            for k, v in pairs(abilities) do
                if not new_loadout.ability_effect_mod[v] then
                    new_loadout.ability_effect_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_effect_mod[v] = new_loadout.ability_effect_mod[v] + pts * 0.02;
            end
        end

        -- heart of the wild
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 15);
        if pts ~= 0 then
            new_loadout.stat_mod[stat.int] = new_loadout.stat_mod[stat.int] + pts * 0.04;
        end

        -- improved healing touch
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 3);
        if pts ~= 0 then
            local ht = localized_spell_name("Healing Touch");
            if not new_loadout.ability_cast_mod[ht] then
                new_loadout.ability_cast_mod[ht] = 0;
            end
            new_loadout.ability_cast_mod[ht] = new_loadout.ability_cast_mod[ht] + pts * 0.1;
        end

        -- tranquil spirit
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 9);
        if pts ~= 0 then
            local abilities = {"Healing Touch", "Tranquility"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end
            for k, v in pairs(abilities) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.02;
            end
        end

        -- improved rejuvenation
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 10);
        if pts ~= 0 then
            local rejuv = localized_spell_name("Rejuvenation");
            if not new_loadout.ability_effect_mod[rejuv] then
                new_loadout.ability_effect_mod[rejuv] = 0;
            end
            new_loadout.ability_effect_mod[rejuv] = new_loadout.ability_effect_mod[rejuv] + pts * 0.05;
        end

        -- gift of nature
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 12);
        if pts ~= 0 then
            new_loadout.spell_heal_mod_base = new_loadout.spell_heal_mod_base + pts * 0.02;
        end

        -- improved regrowth
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 14);
        if pts ~= 0 then
            local regrowth = localized_spell_name("Regrowth");
            if not new_loadout.ability_crit[regrowth] then
                new_loadout.ability_crit[regrowth] = 0;
            end
            new_loadout.ability_crit[regrowth] = new_loadout.ability_crit[regrowth] + pts * 0.10;
        end
    elseif class == "PRIEST" then

        -- improved power word: shield
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 5);
        if pts ~= 0 then
            local shield = localized_spell_name("Power Word: Shield");
            if not new_loadout.ability_effect_mod[shield] then
                new_loadout.ability_effect_mod[shield] = 0;
            end
            new_loadout.ability_effect_mod[shield] = 
                new_loadout.ability_effect_mod[shield] + pts * 0.05;
        end

        -- mental agility 
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 10);
        if pts ~= 0 then

            local instants = {"Power Word: Shield", "Renew", "Holy Nova"};
            for k, v in pairs(instants) do
                instants[k] = localized_spell_name(v);
            end
            for k, v in pairs(instants) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(instants) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.02;
            end
        end
        -- force of will
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 14);
        if pts ~= 0 then

            new_loadout.spell_crit_by_school[magic_school.holy] = 
                new_loadout.spell_crit_by_school[magic_school.holy] + 0.01 * pts;
            new_loadout.spell_crit_by_school[magic_school.shadow] = 
                new_loadout.spell_crit_by_school[magic_school.shadow] + 0.01 * pts;

            for i = 2, 7 do
                new_loadout.spell_dmg_mod_by_school[i] = 
                    new_loadout.spell_dmg_mod_by_school[i] + 0.01 * pts;
            end
        end

        -- improved renew
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 2);
        if pts ~= 0 then
            local renew = localized_spell_name("Renew");
            if not new_loadout.ability_effect_mod[renew] then
                new_loadout.ability_effect_mod[renew] = 0;
            end
            new_loadout.ability_effect_mod[renew] = new_loadout.ability_effect_mod[renew] + pts * 0.05;
        end
        -- holy specialization
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 3);
        if pts ~= 0 then

            new_loadout.healing_crit = new_loadout.healing_crit + pts * 0.01; -- all priest heals are holy...
            new_loadout.spell_crit_by_school[magic_school.holy] = 
                new_loadout.spell_crit_by_school[magic_school.holy] + pts * 0.01;
        end
        -- divine fury
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 5);
        if pts ~= 0 then

            local abilities = {"Smite", "Holy Fire", "Heal", "Greater Heal"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end
            for k, v in pairs(abilities) do
                if not new_loadout.ability_cast_mod[v] then
                    new_loadout.ability_cast_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_cast_mod[v] = new_loadout.ability_cast_mod[v] + pts * 0.1;
            end
        end
        -- improved healing
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 10);
        if pts ~= 0 then

            local abilities = {"Lesser Heal", "Heal", "Greater Heal"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end
            for k, v in pairs(abilities) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.05;
            end
        end
        -- searing light
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 11);
        if pts ~= 0 then

            local abilities = {"Smite", "Holy Fire"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end
            for k, v in pairs(abilities) do
                if not new_loadout.ability_effect_mod[v] then
                    new_loadout.ability_effect_mod[v] = 0;
                end
            end
            -- TODO: multiplicative or additive?
            for k, v in pairs(abilities) do
                new_loadout.ability_effect_mod[v] = new_loadout.ability_effect_mod[v] + pts * 0.05;
            end
        end
        -- improved prayer of healing
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 12);
        if pts ~= 0 then
            local poh = localized_spell_name("Prayer of Healing");
            if not new_loadout.ability_cost_mod[poh] then
                new_loadout.ability_cost_mod[poh] = 0;
            end
            new_loadout.ability_cost_mod[poh] = 
                new_loadout.ability_cost_mod[poh] + pts * 0.1;
        end
        -- spiritual guidance 
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 14);
        if pts ~= 0 then
           new_loadout.spiritual_guidance = pts; 
        end
        -- spiritual healing
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 15);
        if pts ~= 0 then
            new_loadout.spell_heal_mod_base = new_loadout.spell_heal_mod_base + pts * 0.02;
        end

        -- improved shadow word: pain
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 4);
        if pts ~= 0 then
            local swp = localized_spell_name("Shadow Word: Pain");                

            if not new_loadout.ability_extra_ticks[swp] then
                new_loadout.ability_extra_ticks[swp] = 0;
            end
            new_loadout.ability_extra_ticks[swp] = new_loadout.ability_extra_ticks[swp] + pts;
        end
        --shadow focus
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 5);
        if pts ~= 0 then
            new_loadout.spelldmg_hit_by_school[magic_school.shadow] = 
                new_loadout.spelldmg_hit_by_school[magic_school.shadow] + pts * 0.02;
        end
        --darkness
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 15);
        if pts ~= 0 then
            new_loadout.spell_dmg_mod_by_school[magic_school.shadow] = 
                new_loadout.spell_dmg_mod_by_school[magic_school.shadow] + pts * 0.02;
        end

    elseif class == "SHAMAN" then

        -- convection
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 1);
        if pts ~= 0 then
            local abilities = {"Earth Shock", "Frost Shock", "Flame Shock", "Lightning Bolt", "Chain Lightning"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end

            for k, v in pairs(abilities) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.02;
            end
        end

        -- concussion
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 2);
        if pts ~= 0 then
            local abilities = {"Earth Shock", "Frost Shock", "Flame Shock", "Lightning Bolt", "Chain Lightning"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end

            for k, v in pairs(abilities) do
                if not new_loadout.ability_effect_mod[v] then
                    new_loadout.ability_effect_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_effect_mod[v] = new_loadout.ability_effect_mod[v] + pts * 0.01;
            end
        end

        -- call of flame
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 5);
        if pts ~= 0 then
            local abilities = {"Magma Totem", "Searing Totem", "Fire Nova Totem"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end

            for k, v in pairs(abilities) do
                if not new_loadout.ability_effect_mod[v] then
                    new_loadout.ability_effect_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_effect_mod[v] = new_loadout.ability_effect_mod[v] + pts * 0.05;
            end
        end

        -- call of thunder
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 8);
        if pts ~= 0 then
            local abilities = {"Lightning Bolt", "Chain Lightning"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end

            for k, v in pairs(abilities) do
                if not new_loadout.ability_crit[v] then
                    new_loadout.ability_crit[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_crit[v] = new_loadout.ability_crit[v] + pts * 0.01;
            end
        end

        -- elemental fury
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 13);
        if pts ~= 0 then
            new_loadout.spell_crit_mod_by_school[magic_school.frost] = 
                1 + (new_loadout.spell_crit_mod_by_school[magic_school.frost] - 1) * (1 + pts * 0.2);
            new_loadout.spell_crit_mod_by_school[magic_school.fire] = 
                1 + (new_loadout.spell_crit_mod_by_school[magic_school.fire] - 1) * (1 + pts * 0.2);
            new_loadout.spell_crit_mod_by_school[magic_school.nature] = 
                1 + (new_loadout.spell_crit_mod_by_school[magic_school.nature] - 1) * (1 + pts * 0.2);
        end

        -- lightning mastery
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 14);
        if pts ~= 0 then

            local abilities = {"Lightning Bolt", "Chain Lightning"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end

            for k, v in pairs(abilities) do
                if not new_loadout.ability_cast_mod[v] then
                    new_loadout.ability_cast_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_cast_mod[v] = new_loadout.ability_cast_mod[v] + pts * 0.02;
            end
        end

        -- improved lightning shield
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 6);
        if pts ~= 0 then
            local ls = localized_spell_name("Lightning Shield");
            if not new_loadout.ability_effect_mod[ls] then
                new_loadout.ability_effect_mod[ls] = 0;
            end
            new_loadout.ability_effect_mod[ls] = new_loadout.ability_effect_mod[ls] + pts * 0.05;
        end

        -- improved healing wave
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 1);
        if pts ~= 0 then
            local hw = localized_spell_name("Healing Wave");
            if not new_loadout.ability_cast_mod[hw] then
                new_loadout.ability_cast_mod[hw] = 0;
            end
            new_loadout.ability_cast_mod[hw] = new_loadout.ability_cast_mod[hw] + pts * 0.1;
        end

        -- tidal focus
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 2);
        if pts ~= 0 then

            local abilities = {"Lesser Healing", "Healing Wave", "Chain Heal", "Healing Stream Totem"};

            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end
            for k, v in pairs(abilities) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.01;
            end
        end

        -- totemic focus
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 5);
        if pts ~= 0 then

            -- TODO: add dps totems
            local totems = {"Healing Stream Totem"};

            for k, v in pairs(totems) do
                totems[k] = localized_spell_name(v);
            end

            for k, v in pairs(totems) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(totems) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.05;
            end
        end

        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 10);
        if pts ~= 0 then

            local totems = {"Healing Stream Totem"};
            for k, v in pairs(totems) do
                totems[k] = localized_spell_name(v);
            end

            for k, v in pairs(totems) do
                if not new_loadout.ability_effect_mod[v] then
                    new_loadout.ability_effect_mod[v] = 0;
                end
            end
            for k, v in pairs(totems) do
                new_loadout.ability_effect_mod[v] = new_loadout.ability_effect_mod[v] + pts * 0.05;
            end
        end

        -- tidal mastery
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 11);
        if pts ~= 0 then

            new_loadout.healing_crit = new_loadout.healing_crit + pts * 0.01;

            local lightning_spells = {"Lightning Bolt", "Chain Lightning", "Lightning Shield"};

            for k, v in pairs(lightning_spells) do
                lightning_spells[k] = localized_spell_name(v);
            end

            for k, v in pairs(lightning_spells) do
                if not new_loadout.ability_crit[v] then
                    new_loadout.ability_crit[v] = 0;
                end
            end
            for k, v in pairs(lightning_spells) do
                new_loadout.ability_crit[v] = new_loadout.ability_crit[v] + pts * 0.01;
            end
        end

        -- purification
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 14);
        if pts ~= 0 then

            new_loadout.spell_heal_mod_base = new_loadout.spell_heal_mod_base + pts * 0.02;

        end

    elseif class == "PALADIN" then

        -- divine intellect
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 2);
        if pts ~= 0 then
            new_loadout.stat_mod[stat.int] = new_loadout.stat_mod[stat.int] + pts * 0.02;
        end

        -- healing light
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 5);
        if pts ~= 0 then

            local abilities = {"Holy Light", "Flash of Light"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end

            for k, v in pairs(abilities) do
                if not new_loadout.ability_effect_mod[v] then
                    new_loadout.ability_effect_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_effect_mod[v] = new_loadout.ability_effect_mod[v] + pts * 0.04;
            end
        end
        -- illumination
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 9);
        if pts ~= 0 then
            new_loadout.illumination = pts;
        end

        -- holy power
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 13);
        if pts ~= 0 then

            new_loadout.healing_crit = new_loadout.healing_crit + pts * 0.01; -- all priest heals are holy...
            new_loadout.spell_crit_by_school[magic_school.holy] = 
                new_loadout.spell_crit_by_school[magic_school.holy] + pts * 0.01;
        end

    elseif class == "WARLOCK" then
        local affl = {"Corruption", "Siphon Life", "Curse of Agony", "Death Coil", "Drain Life", "Drain Soul"};
        for k, v in pairs(affl) do
            affl[k] = localized_spell_name(v);
        end
        local destr = {"Shadow Bolt", "Searing Pain", "Soul Fire", "Hellfire", "Rain of Fire", "Immolate", "Shadowburn", "Conflagrate"};
        for k, v in pairs(destr) do
            destr[k] = localized_spell_name(v);
        end


        -- suppression
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 1);
        if pts ~= 0 then

            for k, v in pairs(affl) do
                if not new_loadout.ability_hit[v] then
                    new_loadout.ability_hit[v] = 0;
                end
            end
            for k, v in pairs(affl) do
                new_loadout.ability_hit[v] = 
                    new_loadout.ability_hit[v] + pts * 0.02;
            end
        end
        -- improved corruption
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 2);
        if pts ~= 0 then
            local corruption = localized_spell_name("Corruption");

            if not new_loadout.ability_cast_mod[corruption] then
                new_loadout.ability_cast_mod[corruption] = 0;
            end

            new_loadout.ability_cast_mod[corruption] = 
                new_loadout.ability_cast_mod[corruption] + pts * 0.4;
        end

        -- improved curse of agony
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 7);
        if pts ~= 0 then
            local coa = localized_spell_name("Curse of Agony");

            if not new_loadout.ability_effect_mod[coa] then
                new_loadout.ability_effect_mod[coa] = 0;
            end

            new_loadout.ability_effect_mod[coa] = 
                new_loadout.ability_effect_mod[coa] + pts * 0.02;
        end
        -- shadow mastery
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 16);
        if pts ~= 0 then

            new_loadout.spell_dmg_mod_by_school[magic_school.shadow] = 
                new_loadout.spell_dmg_mod_by_school[magic_school.shadow] + pts * 0.02;
        end

        -- improved shadow bolt
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 1);
        if pts ~= 0 then
           new_loadout.improved_shadowbolt = pts; 
        end

        -- cataclysm
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 2);
        if pts ~= 0 then

            for k, v in pairs(destr) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(destr) do
                new_loadout.ability_cost_mod[v] = 
                    new_loadout.ability_cost_mod[v] + pts * 0.01;
            end
        end
        -- bane
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 3);
        if pts ~= 0 then
            local imm = localized_spell_name("Immolate");
            local sb = localized_spell_name("Shadow Bolt");
            local sf = localized_spell_name("Soul Fire");

            if not new_loadout.ability_cast_mod[imm] then
                new_loadout.ability_cast_mod[imm] = 0;
            end
            if not new_loadout.ability_cast_mod[sb] then
                new_loadout.ability_cast_mod[sb] = 0;
            end
            if not new_loadout.ability_cast_mod[sf] then
                new_loadout.ability_cast_mod[sf] = 0;
            end

            new_loadout.ability_cast_mod[imm] = new_loadout.ability_cast_mod[imm] + pts * 0.1;
            new_loadout.ability_cast_mod[sb] = new_loadout.ability_cast_mod[sb] + pts * 0.1;
            new_loadout.ability_cast_mod[sf] = new_loadout.ability_cast_mod[sf] + pts * 0.4;
        end
        -- devastation
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 7);
        if pts ~= 0 then

            for k, v in pairs(destr) do
                if not new_loadout.ability_crit[v] then
                    new_loadout.ability_crit[v] = 0;
                end
            end
            for k, v in pairs(destr) do
                new_loadout.ability_crit[v] = 
                    new_loadout.ability_crit[v] + pts * 0.01;
            end
        end
        -- improved searing pain
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 11);
        if pts ~= 0 then
            local sp = localized_spell_name("Searing Pain");
            if not new_loadout.ability_crit[sp] then
                new_loadout.ability_crit[sp] = 0;
            end
            new_loadout.ability_crit[sp] = new_loadout.ability_crit[sp] + pts * 0.02;
        end

        -- improved immolate
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 13);
        new_loadout.improved_immolate = pts;

        -- ruin 
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 14);
        if pts ~= 0 then

            for k, v in pairs(destr) do
                if not new_loadout.ability_crit_mod[v] then
                    new_loadout.ability_crit_mod[v] = 0;
                end
            end
            for k, v in pairs(destr) do
                new_loadout.ability_crit_mod[v] = 
                    new_loadout.ability_crit_mod[v] + 0.5;
            end
        end
        --emberstorm
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 15);
        if pts ~= 0 then
            new_loadout.spell_dmg_mod_by_school[magic_school.fire] =
                new_loadout.spell_dmg_mod_by_school[magic_school.fire] + pts * 0.02;
        end
    end

    return new_loadout;
end


local function create_set_bonuses()

    local _, class = UnitClass("player");

    local set_tier_ids = {};

    if class == "PRIEST" then
        -- of prophecy
        for i = 16811, 16819 do
            set_tier_ids[i] = set_tiers.pve_1;
        end

    elseif class == "DRUID" then
        -- stormrage
        for i = 16897, 16904 do
            set_tier_ids[i] = set_tiers.pve_2;
        end

        -- zg
        set_tier_ids[19955] = set_tiers.pve_2_5;
        set_tier_ids[19613] = set_tiers.pve_2_5;
        set_tier_ids[19840] = set_tiers.pve_2_5;
        set_tier_ids[19839] = set_tiers.pve_2_5;
        set_tier_ids[19838] = set_tiers.pve_2_5;

    elseif class == "SHAMAN" then
        -- earthfury
        for i = 16837, 16844 do
            set_tier_ids[i] = set_tiers.pve_1;
        end
        -- ten storms
        for i = 16943, 16950 do
            set_tier_ids[i] = set_tiers.pve_2;
        end
        -- pvp set has non linear ids
        set_tier_ids[22857] = set_tiers.pvp_1;
        set_tier_ids[22867] = set_tiers.pvp_1;
        set_tier_ids[22876] = set_tiers.pvp_1;
        set_tier_ids[22887] = set_tiers.pvp_1;
        set_tier_ids[23259] = set_tiers.pvp_1;
        set_tier_ids[23260] = set_tiers.pvp_1;

        set_tier_ids[16577] = set_tiers.pvp_2;
        set_tier_ids[16578] = set_tiers.pvp_2;
        set_tier_ids[16580] = set_tiers.pvp_2;
        set_tier_ids[16573] = set_tiers.pvp_2;
        set_tier_ids[16574] = set_tiers.pvp_2;
        set_tier_ids[16579] = set_tiers.pvp_2;

    elseif class == "WARLOCK" then
        for i = 16803, 16810 do
            set_tier_ids[i] = set_tiers.pve_1;
        end

        -- ally
        set_tier_ids[23296] = set_tiers.pvp_1;
        set_tier_ids[23297] = set_tiers.pvp_1;
        set_tier_ids[23283] = set_tiers.pvp_1;
        set_tier_ids[23311] = set_tiers.pvp_1;
        set_tier_ids[23282] = set_tiers.pvp_1;
        set_tier_ids[23310] = set_tiers.pvp_1;

        set_tier_ids[17581] = set_tiers.pvp_2;
        set_tier_ids[17580] = set_tiers.pvp_2;
        set_tier_ids[17583] = set_tiers.pvp_2;
        set_tier_ids[17584] = set_tiers.pvp_2;
        set_tier_ids[17579] = set_tiers.pvp_2;
        set_tier_ids[17578] = set_tiers.pvp_2;
        -- horde
        set_tier_ids[22865] = set_tiers.pvp_1;
        set_tier_ids[22855] = set_tiers.pvp_1;
        set_tier_ids[23255] = set_tiers.pvp_1;
        set_tier_ids[23256] = set_tiers.pvp_1;
        set_tier_ids[22881] = set_tiers.pvp_1;
        set_tier_ids[22884] = set_tiers.pvp_1;

        set_tier_ids[17586] = set_tiers.pvp_2;
        set_tier_ids[17588] = set_tiers.pvp_2;
        set_tier_ids[17593] = set_tiers.pvp_2;
        set_tier_ids[17591] = set_tiers.pvp_2;
        set_tier_ids[17590] = set_tiers.pvp_2;
        set_tier_ids[17592] = set_tiers.pvp_2;

        -- zg
        set_tier_ids[19957] = set_tiers.pve_2_5;
        set_tier_ids[19605] = set_tiers.pve_2_5;
        set_tier_ids[19848] = set_tiers.pve_2_5;
        set_tier_ids[19849] = set_tiers.pve_2_5;
        set_tier_ids[20033] = set_tiers.pve_2_5;

    elseif class == "MAGE" then

        -- zg
        set_tier_ids[19601] = set_tiers.pve_2_5;
        set_tier_ids[19959] = set_tiers.pve_2_5;
        set_tier_ids[19846] = set_tiers.pve_2_5;
        set_tier_ids[20034] = set_tiers.pve_2_5;
        set_tier_ids[19845] = set_tiers.pve_2_5;

    elseif class == "PALADIN" then

        -- zg
        set_tier_ids[19588] = set_tiers.pve_2_5;
        set_tier_ids[19952] = set_tiers.pve_2_5;
        set_tier_ids[19827] = set_tiers.pve_2_5;
        set_tier_ids[19826] = set_tiers.pve_2_5;
        set_tier_ids[19825] = set_tiers.pve_2_5;
    end

    return set_tier_ids;
end

local set_bonuses = create_set_bonuses();

local function apply_set_bonuses(loadout)

    local new_loadout = loadout;

    -- go through equipment to find set pieces

    for item = 1, 18 do
        local id = GetInventoryItemID("player", item);
        if set_bonuses[id] then
            -- incr counter
            new_loadout.num_set_pieces[set_bonuses[id]] = new_loadout.num_set_pieces[set_bonuses[id]] + 1;
        end
    end


    local _, class = UnitClass("player");
    if class == "PRIEST" then
        if new_loadout.num_set_pieces[set_tiers.pve_1] >= 3 then

            local flash = localized_spell_name("Flash Heal");
            if not new_loadout.ability_cast_mod[flash] then
                new_loadout.ability_cast_mod[flash] = 0;
            end
            new_loadout.ability_cast_mod[flash] = new_loadout.ability_cast_mod[flash] + 0.1;

            
            if new_loadout.num_set_pieces[set_tiers.pve_1] >= 5 then

                -- NOTE: the tooltip specifies 2% holy crit chance but internally
                --       seems to increase all spell crits by 2%, according to GetSpellCritChance API...
                --new_loadout.healing_crit = new_loadout.healing_crit + 0.02;
                   
                if new_loadout.num_set_pieces[set_tiers.pve_1] >= 8 then
            
                    local poh = localized_spell_name("Prayer of Healing");
                    if not new_loadout.ability_crit[poh] then
                        new_loadout.ability_crit[poh] = 0;
                    end
                    new_loadout.ability_crit[poh] = new_loadout.ability_crit[poh] + 0.25;
                end
            end
        end

    elseif class == "DRUID" then

        -- check for special items giving special things...
        for item = 1, 18 do
            local id = GetInventoryItemID("player", item);
            if id == 19613 then -- pristine enchanted south seas kelp
                if not new_loadout.ability_crit[localized_spell_name("Starfire")] then
                    new_loadout.ability_crit[localized_spell_name("Starfire")] = 0;
                end
                if not new_loadout.ability_crit[localized_spell_name("Wrath")] then
                    new_loadout.ability_crit[localized_spell_name("Wrath")] = 0;
                end
                new_loadout.ability_crit[localized_spell_name("Starfire")] = 
                    new_loadout.ability_crit[localized_spell_name("Starfire")] + 0.02;
                new_loadout.ability_crit[localized_spell_name("Wrath")] = 
                    new_loadout.ability_crit[localized_spell_name("Wrath")] + 0.02;
            end
        end

        if new_loadout.num_set_pieces[set_tiers.pve_2] >= 5 then

            local regrowth = localized_spell_name("Regrowth");
            if not new_loadout.ability_cast_mod[regrowth] then
                new_loadout.ability_cast_mod[regrowth] = 0;
            end
               
            if new_loadout.num_set_pieces[set_tiers.pve_2] >= 8 then
        
                local rejuv = localized_spell_name("Rejuvenation");
                if not new_loadout.ability_extra_ticks[rejuv] then
                    new_loadout.ability_extra_ticks[rejuv] = 0;
                end
                new_loadout.ability_extra_ticks[rejuv] = new_loadout.ability_extra_ticks[rejuv] + 1;
            end
        end

        if new_loadout.num_set_pieces[set_tiers.pve_2_5] >= 5 then

            local sf = localized_spell_name("Starfire");
            if not new_loadout.ability_crit[sf] then
                new_loadout.ability_crit[sf] = 0;
            end

            new_loadout.ability_crit[sf] = new_loadout.ability_crit[sf] + 0.03;
        end

    elseif class == "SHAMAN" then

        if new_loadout.num_set_pieces[set_tiers.pve_1] >= 5 then

            local lh = localized_spell_name("Lesser Healing");
            local hw = localized_spell_name("Healing Wave");

            if not new_loadout.ability_cost_mod[lh] then
                new_loadout.ability_cost_mod[lh] = 0;
            end
            if not new_loadout.ability_cost_mod[hw] then
                new_loadout.ability_cost_mod[hw] = 0;
            end

            if new_loadout.num_set_pieces[set_tiers.pve_1] >= 8 then
                
                local probability_of_atleast_one_mana_proc = 1 - (1-0.25)*(1-0.25)*(1-0.25);
                new_loadout.ability_cost_mod[hw] = new_loadout.ability_cost_mod[hw] + probability_of_atleast_one_mana_proc * 0.35;
            else
                new_loadout.ability_cost_mod[hw] = new_loadout.ability_cost_mod[hw] + 0.25 * 0.35;
            end
            new_loadout.ability_cost_mod[lh] = new_loadout.ability_cost_mod[lh] + 0.25 * 0.35;
            -- 8 set bonus for healing wave bounce is done within spell_info function
        end

        -- 3 set bonus for chain healing is done within spell_info function
        if new_loadout.num_set_pieces[set_tiers.pve_2] >= 5 then

            -- NOTE: the tooltip specifies 3% nature crit chance but internally
            --       seems to increase all spell crits by 3%, according to GetSpellCritChance API...
            --new_loadout.healing_crit = new_loadout.healing_crit + 0.03;
        end

        if new_loadout.num_set_pieces[set_tiers.pvp_1] >= 5 or 
           new_loadout.num_set_pieces[set_tiers.pvp_2] >= 5 then

            local abilities = {"Flame Shock", "Earth Shock", "Frost Shock"};

            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end
            for k, v in pairs(abilities) do
                if not new_loadout.ability_crit[v] then
                    new_loadout.ability_crit[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_crit[v] = new_loadout.ability_crit[v] + 0.02;
            end
        end

    elseif class == "WARLOCK" then

        if new_loadout.num_set_pieces[set_tiers.pve_1] >= 8 then

            local shadow = {
                "Curse of Agony", "Corruption", "Drain Soul", "Siphon Life", 
                "Death Coil", "Drain Life", "Shadow Bolt", "Shadowburn"
            };

            for k, v in pairs(shadow) do
                shadow[k] = localized_spell_name(v);
            end
            for k, v in pairs(shadow) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(shadow) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + 0.15;
            end

        end
        if new_loadout.num_set_pieces[set_tiers.pvp_1] >= 4 or new_loadout.num_set_pieces[set_tiers.pvp_2] >= 3 then

            local imm = localized_spell_name("Immolate");
            if not new_loadout.ability_cast_mod[imm] then
                new_loadout.ability_cast_mod[imm] = 0;
            end
            new_loadout.ability_cast_mod[imm] = new_loadout.ability_cast_mod[imm] + 0.2;
        end

        if new_loadout.num_set_pieces[set_tiers.pve_2_5] >= 3 then

            -- unsure if this 2% bonus works on base spell or on spell power bonus
            -- ...assume base for now as with other similar talents
            local corr = localized_spell_name("Corruption");

            if not new_loadout.ability_effect_mod[corr] then
                new_loadout.ability_effect_mod[corr] = 0;
            end
            new_loadout.ability_effect_mod[corr] = new_loadout.ability_effect_mod[corr] + 0.02;
        end

    elseif class == "MAGE" then

        if new_loadout.num_set_pieces[set_tiers.pve_2_5] >= 5 then

            local fs = localized_spell_name("Flamestrike");
            if not new_loadout.ability_cast_mod[fs] then
                new_loadout.ability_cast_mod[fs] = 0;
            end
            new_loadout.ability_cast_mod[fs] = new_loadout.ability_cast_mod[fs] + 0.5;

        end

    elseif class == "PALADIN" then

        if new_loadout.num_set_pieces[set_tiers.pve_2_5] >= 5 then

            local hl = localized_spell_name("Holy Light");
            if not new_loadout.ability_cast_mod[hl] then
                new_loadout.ability_cast_mod[hl] = 0;
            end
            new_loadout.ability_cast_mod[hl] = new_loadout.ability_cast_mod[hl] + 0.1;

        end
    end

    return new_loadout;
end

local function apply_buffs(loadout)

    local new_loadout = loadout;

    local _, class = UnitClass("player");

    if class == "MAGE" then
      for i = 1, 40  do
            local name, _, _, _, _, _, _, _, _, spell_id = UnitBuff("player", i);
            if not name then
                break;
            end
            -- arcane power
            if spell_id == 12042 then
                for j = 2, 7 do 
                    new_loadout.spell_dmg_mod_by_school[j] = new_loadout.spell_dmg_mod_by_school[j] + 0.3;
                end
                new_loadout.cost_mod = new_loadout.cost_mod - 0.3;
            -- mind quickening gem bfuff
            elseif spell_id == 23723 then
                new_loadout.haste_mod = new_loadout.haste_mod + 0.33;
            -- hazza'rah's charm of magic
            elseif spell_id == 24544 then
                -- 5% arcane crit should already be given by GetCritChance API...
                new_loadout.spell_crit_mod_by_school[magic_school.arcane] =
                    new_loadout.spell_crit_mod_by_school[magic_school.arcane] + 0.5;
            end
        end
    elseif class == "PRIEST" then
        for i = 1, 40  do
            local name, _, _, _, _, _, _, _, _, spell_id = UnitBuff("player", i);
            if not name then
                break;
            end
            -- shadow form
            if spell_id == 15473 then
                new_loadout.spell_dmg_mod_by_school[magic_school.shadow] = 
                    new_loadout.spell_dmg_mod_by_school[magic_school.shadow] + 0.15;
            end
        end
    elseif class == "WARLOCK" then
        for i = 1, 40  do
            local name, _, _, _, _, _, _, _, _, spell_id = UnitBuff("player", i);
            if not name then
                break;
            end
            -- hazza'rah's charm of destruction
            if spell_id == 24543 then
                local destr = {"Shadow Bolt", "Searing Pain", "Soul Fire", "Hellfire", "Rain of Fire", "Immolate", "Shadowburn", "Conflagrate"};
                for k, v in pairs(destr) do
                    destr[k] = localized_spell_name(v);
                end

                for k, v in pairs(destr) do
                    if not new_loadout.ability_crit[v] then
                        new_loadout.ability_crit[v] = 0;
                    end
                end
                for k, v in pairs(destr) do
                    new_loadout.ability_crit[v] = 
                        new_loadout.ability_crit[v] + 0.1;
                end
            -- amplify curse
            elseif spell_id == 18288 then
                local coa = localized_spell_name("Curse of Agony");
    
                if not new_loadout.ability_effect_mod[coa] then
                    new_loadout.ability_effect_mod[coa] = 0;
                end
    
                new_loadout.ability_effect_mod[coa] = 
                    new_loadout.ability_effect_mod[coa] + 0.5;
    
            end
        end
    elseif class == "SHAMAN" then
        for i = 1, 40  do
            local name, _, _, _, _, _, _, _, _, spell_id = UnitBuff("player", i);
            if not name then
                break;
            end
            -- wushoolay's charm of spirits
            if spell_id == 24499 then
                local ls = localized_spell_name("Lightning Shield");
                if not new_loadout.ability_effect_mod[ls] then
                    new_loadout.ability_effect_mod[ls] = 0;
                end
                new_loadout.ability_effect_mod[ls] = new_loadout.ability_effect_mod[ls] + 1;
            end
        end
    elseif class == "DRUID" then
        for i = 1, 40  do
            local name, _, _, _, _, _, _, _, _, spell_id = UnitBuff("player", i);
            if not name then
                break;
            end
            -- nimble healing touch
            if spell_id == 24542 then
                new_loadout.ability_cast_mod[localized_spell_name("Healing Touch")] =
                    new_loadout.ability_cast_mod[localized_spell_name("Healing Touch")] + 0.4;
                
                local healing_abilities = {"Healing Touch", "Rejuvenation", "Regrowth", "Tranquility"};

                for k, v in pairs(healing_abilities) do
                    healing_abilities[k] = localized_spell_name(v);
                end

                for k, v in pairs(healing_abilities) do
                    if not new_loadout.ability_cost_mod[v] then
                        new_loadout.ability_cost_mod[v] = 0;
                    end
                end
                for k, v in pairs(healing_abilities) do
                    new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + 0.05;
                end
            end
        end
    elseif class == "PALADIN" then
        for i = 1, 40  do
            local name, _, _, _, _, _, _, _, _, spell_id = UnitBuff("player", i);
            if not name then
                break;
            end
            -- hazza'rah's charm of healing
            if spell_id == 24546 then
                new_loadout.ability_cast_mod[localized_spell_name("Holy Light")] =
                    new_loadout.ability_cast_mod[localized_spell_name("Holy Light")] + 0.4;
                
                local healing_abilities = {"Holy Light", "Flash of Light", "Holy Shock"};


                for k, v in pairs(healing_abilities) do
                    healing_abilities[k] = localized_spell_name(v);
                end

                for k, v in pairs(healing_abilities) do
                    if not new_loadout.ability_cost_mod[v] then
                        new_loadout.ability_cost_mod[v] = 0;
                    end
                end
                for k, v in pairs(healing_abilities) do
                    new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + 0.05;
                end
            end
        end
    end

    local _, race = UnitRace("player");
    if race == "Troll" then
        for i = 1, 40  do
            local name, _, _, _, _, _, _, _, _, spell_id = UnitBuff("player", i);
            if not name then
                break;
            end
            -- berserking
            if spell_id == 26297 or spell_id == 20554 or spell_id == 26635 then

                local max_hp = UnitHealthMax("player");
                local hp = UnitHealth("player");
                local hp_perc = 0;
                if max_hp ~= 0 then
                    hp_perc = hp/max_hp;
                end

                -- at 100% hp: 10 % haste
                -- at less or equal than 40% hp: 30 % haste
                -- interpolate between 10% and 30% haste at 40% - 100% hp
                local haste_mod = 0.1 + 0.2 * (1 -((math.max(0.4, hp_perc) - 0.4)*(5/3)))
                new_loadout.haste_mod = new_loadout.haste_mod + haste_mod;
            end
        end
    end

    for i = 1, 40  do
        local name, _, _, _, _, _, _, _, _, spell_id = UnitBuff("player", i);
        if not name then
            break;
        end
        -- power infusion
        if spell_id == 10060 then

            for j = 2, 7 do 
                new_loadout.spell_dmg_mod_by_school[j] = new_loadout.spell_dmg_mod_by_school[j] + 0.2;
            end
            new_loadout.spell_heal_mod = new_loadout.spell_heal_mod + 0.2;
        -- zg buff
        elseif spell_id == 24425 then
            for j = 1, 5 do
                new_loadout.stat_mod[j] = new_loadout.stat_mod[j] + 0.15;

            end
        elseif spell_id == 23768 then
        -- darkmoon faire dmg buff
        -- look into if it should be additive or multiplicative to other school dmg mods
            for i = 1, 7 do
                new_loadout.spell_dmg_mod_by_school[i] = new_loadout.spell_dmg_mod_by_school[i] + 0.1;
            end
            
        end
        -- TODO: holy dmg aura from palas
    end

    return new_loadout;
    
end

local function current_loadout()

   local loadout = empty_loadout();

   local _, int, _, _ = UnitStat("player", 4);
   local _, spirit, _, _ = UnitStat("player", 5);

   loadout.name = "Current loadout";

   loadout.lvl = UnitLevel("player");
   loadout.target_lvl = loadout.lvl + 3;
   
   loadout.int = int;
   loadout.spirit = spirit;

   for i = 1, 7 do
       loadout.spelldmg_by_school[i] = GetSpellBonusDamage(i);
   end
   for i = 1, 7 do
       loadout.spell_crit_by_school[i] = GetSpellCritChance(i)*0.01;
   end

   local min_crit = 1;
   for i = 2, 7 do
       if min_crit > loadout.spell_crit_by_school[i] then
           min_crit = loadout.spell_crit_by_school[i];
       end
   end

   -- right after load GetSpellHitModifier seems to sometimes returns a nil.... so check first I guess
   local spell_hit = 0;
   local real_hit = GetSpellHitModifier();
   if real_hit then
       spell_hit = real_hit/100;
   end
   for i = 1, 7 do
       loadout.spelldmg_hit_by_school[i] = spell_hit;
   end

   loadout.healingpower = GetSpellBonusHealing();
   loadout.healing_crit = min_crit;

   loadout.spell_crit_mod_by_school = {1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5};

   loadout = apply_talents(loadout);

   loadout = apply_set_bonuses(loadout);

   loadout = apply_buffs(loadout);

   return loadout;
end

local function begin_tooltip_section(tooltip)
    tooltip:AddLine(" ");
    --tooltip:AddLine("Stat Weights", 1.0, 153.0/255, 102.0/255);
end
local function end_tooltip_section(tooltip)
    tooltip:Show();
end


local function print_loadout(loadout)

    print("Stat Weights Classic - Version: "..version);
    print(loadout.name);
    print("int: "..loadout.int..", spirit: "..loadout.spirit);
    print("heal: "..loadout.healingpower..", heal_crit: ".. string.format("%.3f", loadout.healing_crit));
    print("spell schools: ",
          loadout.spelldmg_by_school[1],
          loadout.spelldmg_by_school[2],
          loadout.spelldmg_by_school[3],
          loadout.spelldmg_by_school[4],
          loadout.spelldmg_by_school[5],
          loadout.spelldmg_by_school[6],
          loadout.spelldmg_by_school[7]);
    print("spell heal: ", loadout.healingpower);
    print("spell heal mod base: ", loadout.spell_heal_mod_base);
    print("spell heal mod: ", loadout.spell_heal_mod);
    print(string.format("spell crit schools: %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f", 
                        loadout.spell_crit_by_school[1],
                        loadout.spell_crit_by_school[2],
                        loadout.spell_crit_by_school[3],
                        loadout.spell_crit_by_school[4],
                        loadout.spell_crit_by_school[5],
                        loadout.spell_crit_by_school[6],
                        loadout.spell_crit_by_school[7]));
    print(string.format("spell crit dmg mod schools: %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f", 
                        loadout.spell_crit_mod_by_school[1],
                        loadout.spell_crit_mod_by_school[2],
                        loadout.spell_crit_mod_by_school[3],
                        loadout.spell_crit_mod_by_school[4],
                        loadout.spell_crit_mod_by_school[5],
                        loadout.spell_crit_mod_by_school[6],
                        loadout.spell_crit_mod_by_school[7]));
    print(string.format("spell hit schools: %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f", 
                        loadout.spelldmg_hit_by_school[1],
                        loadout.spelldmg_hit_by_school[2],
                        loadout.spelldmg_hit_by_school[3],
                        loadout.spelldmg_hit_by_school[4],
                        loadout.spelldmg_hit_by_school[5],
                        loadout.spelldmg_hit_by_school[6],
                        loadout.spelldmg_hit_by_school[7]));
    print(string.format("spell mod schools: %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f", 
                        loadout.spell_dmg_mod_by_school[1],
                        loadout.spell_dmg_mod_by_school[2],
                        loadout.spell_dmg_mod_by_school[3],
                        loadout.spell_dmg_mod_by_school[4],
                        loadout.spell_dmg_mod_by_school[5],
                        loadout.spell_dmg_mod_by_school[6],
                        loadout.spell_dmg_mod_by_school[7]));

    print(string.format("spell haste mod: %.3f", loadout.haste_mod));
    print(string.format("spell cost mod: %.3f", loadout.cost_mod));
    print(string.format("stat mods : %.3f, %.3f, %.3f, %.3f, %.3f",
                        loadout.stat_mod[1],
                        loadout.stat_mod[2],
                        loadout.stat_mod[3],
                        loadout.stat_mod[4],
                        loadout.stat_mod[5]));


    print("num set pieces: {", 
          loadout.num_set_pieces[1],
          loadout.num_set_pieces[2],
          loadout.num_set_pieces[3],
          loadout.num_set_pieces[4],
          loadout.num_set_pieces[5],
          loadout.num_set_pieces[6],
          loadout.num_set_pieces[7],
          loadout.num_set_pieces[8],
          "}");

    for k, v in pairs(loadout.ability_effect_mod) do
        print("mod: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_crit) do
        print("crit: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_cast_mod) do
        print("cast mod: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_extra_ticks) do
        print("extra ticks: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_cost_mod) do
        print("cost mod: ", k, string.format("%.3f", v));
    end

    for k, v in pairs(loadout.ability_crit_mod) do
        print("crit mod: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_hit) do
        print("hit: ", k, string.format("%.3f", v));
    end
end

local function spell_scaling(lvl)
    return math.min(1, 1 - (20 - lvl)* 0.0375);
end

local function spell_hit(lvl, lvl_target, hit)

    base_hit = 0;

    if lvl_target - lvl > 2 then
        base_hit =  0.94 - 0.11 * (lvl_target - lvl - 2);
    else
        base_hit = 0.96 - 0.01 * (lvl_target - lvl);
    end
    
    return math.max(0.01, math.min(0.99, base_hit + hit));
end

local function spell_coef(spell_info, spell_name)

    local direct_coef = 1;
    local ot_coef = 1;
    
    direct_coef = math.min(1.0, math.max(1.5/3.5, spell_info.cast_time/3.5));

    if spell_info.base_min <= 0 then
        direct_coef = 0;
    end
    
    if spell_info.over_time_duration < 15 then
        if spell_name == localized_spell_name("Arcane Missiles") then
            -- for arcane missiles max scaling is at 5 secs channel at 1.2 coef
            ot_coef = 1.2 * spell_info.over_time_duration/5;
        elseif spell_info.cast_time == spell_info.over_time_duration then
            ot_coef = math.min(1.0, math.max(1.5/3.5, spell_info.cast_time/3.5));
        else
            ot_coef = spell_info.over_time_duration/15.0;
        end
    end

    -- special coefs
    if spell_name == localized_spell_name("Power Word: Shield") then
        direct_coef = 0.1;
        ot_coef = 0;
    elseif spell_name == localized_spell_name("Lightning Shield") then
        direct_coef = 1/3;
        ot_coef = 0;
    elseif spell_name == localized_spell_name("Healing Stream Totem") then
        direct_coef = 0.0;
        ot_coef = 0.65;
    elseif spell_name == localized_spell_name("Insect Swarm") then
        -- insect swarm seems to have 15/15 scaling isntead of 12/15
        direct_coef = 0.0;
        ot_coef = 1.0;
    elseif spell_name == localized_spell_name("Entangling Roots") then
        -- scales of cast time, not ot duration
        ot_coef = 0.0;
        direct_coef = math.min(1.0, math.max(1.5/3.5, spell_info.cast_time/3.5));
    end
    -- distribute direct and ot coefs if both
    if spell_info.base_min > 0 and spell_info.over_time > 0 then
        -- pyroblast and fireball dots are special...
        if spell_name == localized_spell_name("Pyroblast") then
            direct_coef = 1.0;
            ot_coef = 0.65;
        elseif spell_name == localized_spell_name("Fireball") then
            direct_coef = 1.0;
            ot_coef = 0;
        elseif spell_name == localized_spell_name("Regrowth") then
            direct_coef = 0.5 * (2/3.5);
            ot_coef = 0.5;
        else
            local tmp_direct_coef = direct_coef;
            local tmp_ot_coef = ot_coef;

            direct_coef = tmp_direct_coef*tmp_direct_coef / (tmp_direct_coef + tmp_ot_coef);
            ot_coef = tmp_ot_coef*tmp_ot_coef / (tmp_direct_coef + tmp_ot_coef);
        end
    end

    if bit.band(spell_info.flags, spell_flags.aoe) ~= 0 then
        direct_coef = direct_coef/3;
        ot_coef = ot_coef/3;
    end
    if bit.band(spell_info.flags, spell_flags.snare) ~= 0 then
        direct_coef = direct_coef * 0.95;
        ot_coef = ot_coef * 0.95;
    end

    if spell_name == localized_spell_name("Holy Nova") then
        direct_coef = direct_coef/1.5;
    elseif spell_name == localized_spell_name("Devouring Plague") then
        ot_coef = ot_coef/2;
    elseif spell_name == localized_spell_name("Siphon Life") then
        ot_coef = ot_coef/2;
    elseif spell_name == localized_spell_name("Death Coil") then
        direct_coef = direct_coef/2;
    elseif spell_name == localized_spell_name("Drain Life") then
        ot_coef = ot_coef/2;
    elseif spell_name == localized_spell_name("Drain Soul") then
        ot_coef = ot_coef/2;
    end

    direct_coef = direct_coef * spell_scaling(spell_info.lvl_req);
    ot_coef = ot_coef * spell_scaling(spell_info.lvl_req);
    
    return direct_coef, ot_coef;
end

local function spell_info(base_min, base_max,
                          base_ot, ot_freq, ot_dur, ot_extra_ticks,
                          cast_time, sp, 
                          crit, ot_crit, crit_mod, hit,
                          mod, base_mod,
                          direct_coef, ot_coef,
                          mana, school,
                          spell_name, loadout)

    -- tmp
    if __sw__debug__ then
        print(sp, crit, crit_mod, hit, mod, base_mod, mana, cast_time);
    end 

    -- improved immolate only works on direct damage -,-
    local base_mod_before_improved_immolate = base_mod;
    if spell_name == localized_spell_name("Immolate") then
        base_mod = base_mod + loadout.improved_immolate * 0.05;
    end

    local min_noncrit_if_hit = (base_min * base_mod + sp * direct_coef) * mod;
    local max_noncrit_if_hit = (base_max * base_mod + sp * direct_coef) * mod;

    local base_mod = base_mod_before_improved_immolate;

    local min_crit_if_hit = min_noncrit_if_hit * crit_mod;
    local max_crit_if_hit = max_noncrit_if_hit * crit_mod;

    -- TODO: Looks like min is ceiled and max is floored
    --       do this until we know any better!

    --min_noncrit_if_hit = math.ceil(min_noncrit_if_hit);
    --max_noncrit_if_hit = math.ceil(max_noncrit_if_hit);

    --min_crit_if_hit = math.ceil(min_crit_if_hit);
    --max_crit_if_hit = math.ceil(max_crit_if_hit);

    local min = hit * ((1 - crit) * min_noncrit_if_hit + (crit * min_crit_if_hit));
    local max = hit * ((1 - crit) * max_noncrit_if_hit + (crit * max_crit_if_hit));

    local ot = 0;
    local ot_if_crit = 0;
    local ot_ticks = 0;
    local ignite_min = 0;
    local ignite_max = 0;

    --if loadout.ignite ~= 0 and 
    if spell_name == localized_spell_name("Fireball") then
        -- dont include dot for calcs
        base_ot = 0.0;
        base_dur = 0.0;
    end

    if loadout.ignite and loadout.ignite ~= 0 and school == magic_school.fire then
        -- dont include dot for calcs
         ignite_min = loadout.ignite * 0.08 * min_crit_if_hit;
         ignite_max = loadout.ignite * 0.08 * max_crit_if_hit;
    end

    if base_ot > 0 then

        local base_ot_num_ticks = (ot_dur / ot_freq);
        local ot_coef_per_tick = ot_coef / base_ot_num_ticks;
        local base_ot_tick = base_ot * base_mod / base_ot_num_ticks;

        ot_ticks = base_ot_num_ticks + ot_extra_ticks;

        ot = (base_ot_tick + ot_coef_per_tick * sp) * ot_ticks * mod;

        if ot_crit > 0 then
            ot_if_crit = ot * crit_mod;
        else
            ot_if_crit = 0;
        end
    end

    local expectation_ot_if_hit = (1 - ot_crit) * ot + ot_crit * ot_if_crit;
    local expected_ot = hit * expectation_ot_if_hit;
    -- soul drain, life drain, mind flay are all directed casts that can only miss on the channel itself
    -- 1.5 sec gcd is always implied which is the only penalty for misses
    if spell_name == localized_spell_name("Drain Soul") or 
       spell_name == localized_spell_name("Drain Life") or
       spell_name == localized_spell_name("Mind Flay") then

        local channel_ratio_time_lost_to_miss = 1 - (ot_dur - 1.5)/ot_dur;
        expected_ot = expectation_ot_if_hit - (1 - hit) * channel_ratio_time_lost_to_miss * expectation_ot_if_hit;
    end

    local expectation_direct = (min + max) / 2;
    local expectation = expectation_direct + expected_ot + hit * crit * (ignite_min + ignite_max)/2;

    if loadout.natures_grace and loadout.natures_grace ~= 0  and cast_time > 1.5 and 
        spell_name ~= localized_spell_name("Tranquility") and spell_name ~= localized_spell_name("Hurricane") then
        local cast_reduction = 0.5;
        if cast_time - 1.5 < 0.5 then
            --cast_time is between ]1.5:2]
            -- partially account for natures grace as the cast is lower than 2 and natures grace doesnt ignore gcd
            cast_reduction = cast_time - 1.5; -- i.e. between [0:0.5]
        end
        cast_time = cast_time - cast_reduction * crit;
    end

    if loadout.improved_shadowbolt ~= 0 and spell_name == localized_spell_name("Shadow Bolt") then
        -- a reasonably good, generous estimate, 
        -- assumes all other warlocks in raid/party have same crit chance/improved shadowbolt talent
        -- and just spam shadow bolt allt fight, other abilities like shadowburn/mind blast will skew this estimate
        local sb_dmg_bonus = loadout.improved_shadowbolt * 0.04;
        local improved_sb_uptime = 1 - math.pow(1-crit, 4);

        expectation = expectation * (1 + sb_dmg_bonus * improved_sb_uptime);
    end

    local expectation_st = expectation;

    if spell_name == localized_spell_name("Chain Heal") then
        if loadout.num_set_pieces[set_tiers.pve_2] >= 3 then
            expectation = (1 + 1.3*0.5 + 1.3*1.3*0.5*0.5) * expectation_st;
        else
            expectation = (1 + 0.5 + 0.5*0.5) * expectation_st;
        end
    elseif spell_name == localized_spell_name("Healing Wave") and loadout.num_set_pieces[set_tiers.pve_1] >= 8 then
        expectation = (1 + 0.2 + 0.2*0.2) * expectation_st;
    elseif spell_name == localized_spell_name("Lightning Shield") then
        expectation = 3 * expectation_st;
    elseif spell_name == localized_spell_name("Prayer of Healing") then
        expectation = 5 * expectation_st;
    elseif spell_name == localized_spell_name("Tranquility") then
        expectation = 5 * expectation_st;
    elseif spell_name == localized_spell_name("Chain Lightning") then
        expectation = (1 + 0.7 + 0.7 * 0.7) * expectation_st;
    end

    local effect_per_sec = expectation/cast_time;

    return {
        min_noncrit = min_noncrit_if_hit,
        max_noncrit = max_noncrit_if_hit,

        min_crit = min_crit_if_hit,
        max_crit = max_crit_if_hit,

        ignite_min = ignite_min,
        ignite_max = ignite_max,

        --including crit/hit
        expectation_direct = expectation_direct,

        ot_num_ticks = ot_ticks,
        ot_duration = ot_dur + ot_extra_ticks * ot_freq,
        ot_if_hit = ot,
        ot_crit_if_hit = ot_if_crit,
        ot = expected_ot,

        expectation = expectation,
        expectation_st = expectation_st,
        effect_per_sec = effect_per_sec,

        effect_per_cost = expectation/mana,
        cost_per_sec = mana / cast_time,

        cast_time = cast_time,

        mana = mana
    };
end

local function evaluate_spell(spell_data, spell_name, loadout)

    local crit = 0;
    local ot_crit = 0;
    local crit_delta_1 = 0;
    local ot_crit_delta_1 = 0;
    if bit.band(spell_data.flags, spell_flags.heal) ~= 0 then
        crit = loadout.healing_crit;
    else 
        crit = loadout.spell_crit_by_school[spell_data.school];
    end
    if not loadout.ability_crit[spell_name] then
        loadout.ability_crit[spell_name] = 0;
    end
    crit = crit + loadout.ability_crit[spell_name];
    crit_delta_1 = math.min(crit + 0.01, 1.0);

    if bit.band(spell_data.flags, spell_flags.absorb) ~= 0 then
        crit = 0.0;
        crit_delta_1 = 0.0;
    end
    if bit.band(spell_data.flags, spell_flags.over_time_crit) ~= 0 then
        ot_crit = crit;
        ot_crit_delta_1 = crit_delta_1;
    end

    local spell_crit_mod = loadout.spell_crit_mod_by_school[spell_data.school];
    if not loadout.ability_crit_mod[spell_name] then
        loadout.ability_crit_mod[spell_name] = 0;
    end
    spell_crit_mod = spell_crit_mod + loadout.ability_crit_mod[spell_name];

    local cast_speed = spell_data.cast_time;
    if not loadout.ability_cast_mod[spell_name] then
        loadout.ability_cast_mod[spell_name] = 0;
    end
    cast_speed = cast_speed - loadout.ability_cast_mod[spell_name];

    -- apply global haste
    cast_speed = cast_speed * (1 - loadout.haste_mod);

    if spell_name == localized_spell_name("Flash Heal") or spell_name == localized_spell_name("Regrowth") then
        -- from set bonuses, flash heal and regrowth seem to be the only exceptions to ignore 1.5 gcd on all spells
        cast_speed = math.max(cast_speed, 1.3);
    else
        cast_speed = math.max(cast_speed, 1.5);
    end
    

    local spell_mod = 1;
    local spell_mod_base = 1;
    if not loadout.ability_effect_mod[spell_name] then
        loadout.ability_effect_mod[spell_name] = 0;
    end

    if bit.band(spell_data.flags, spell_flags.heal) ~= 0 then
        spell_mod = 1 + loadout.spell_heal_mod;
        spell_mod_base = 1 + loadout.spell_heal_mod_base;
        spell_mod_base = spell_mod_base + loadout.ability_effect_mod[spell_name];

    elseif bit.band(spell_data.flags, spell_flags.absorb) ~= 0 then
        spell_mod = 1;
        spell_mod_base = 1;
        spell_mod = spell_mod + loadout.ability_effect_mod[spell_name];
    else
        -- TODO: see if frostbolts should be done like the heal before
        spell_mod = spell_mod + loadout.spell_dmg_mod_by_school[spell_data.school];
        spell_mod_base = spell_mod_base + loadout.ability_effect_mod[spell_name];
    end

    local extra_hit = 0;
    if loadout.ability_hit[spell_name] then
        extra_hit = loadout.spelldmg_hit_by_school[spell_data.school] + loadout.ability_hit[spell_name];
    else
        extra_hit = loadout.spelldmg_hit_by_school[spell_data.school];
    end

    local hit = spell_hit(loadout.lvl, loadout.target_lvl, extra_hit);
    local hit_delta_1 = hit + 0.01;
    if bit.band(spell_data.flags, spell_flags.heal) ~= 0 or bit.band(spell_data.flags, spell_flags.absorb) ~= 0 then
        hit = 1.0;
        hit_delta_1 = 1.0;
    else
        hit = math.min(0.99, hit);
        hit_delta_1 = math.min(0.99, hit + 0.01);
    end

    -- 
    local extra_ticks = loadout.ability_extra_ticks[spell_name];
    if not extra_ticks then
        extra_ticks = 0;
    end

    local spell_power = 0;
    if bit.band(spell_data.flags, spell_flags.heal) ~= 0 or bit.band(spell_data.flags, spell_flags.absorb) ~= 0 then
        spell_power = loadout.healingpower;
    else
        spell_power = loadout.spelldmg_by_school[spell_data.school];
    end

    local cost = spell_data.mana;
    if loadout.ability_cost_mod[spell_name] then
        cost = cost * (1 - loadout.ability_cost_mod[spell_name] - loadout.cost_mod);
    end
    if loadout.illumination ~= 0  and bit.band(spell_data.flags, spell_flags.heal) ~= 0 then
        cost = cost * (1 - loadout.healing_crit * (loadout.illumination * 0.2));
    end

    if loadout.master_of_elements ~= 0 and 
       (spell_data.school == magic_school.fire or spell_data.school == magic_school.frost) ~= 0 then
        cost = cost * (1 - loadout.spell_crit_by_school[spell_data.school] * (loadout.master_of_elements * 0.1));
    end

    -- the game seems to round mana up/down to the nearest
    cost = tonumber(string.format("%.0f", cost));

    local direct_coef, over_time_coef = spell_coef(spell_data, spell_name);


    if __sw__debug__ then
        print("--------------------");
        print(spell_name, spell_data.rank);
    end

    local normal_dmg = spell_info(
        spell_data.base_min, spell_data.base_max, 
        spell_data.over_time, spell_data.over_time_tick_freq, spell_data.over_time_duration, extra_ticks,
        cast_speed,
        max(0, spell_power),
        min(1, crit),
        min(1, ot_crit),
        spell_crit_mod,
        hit,
        spell_mod, spell_mod_base,
        direct_coef, over_time_coef,
        cost, spell_data.school,
        spell_name, loadout
    );

    local dmg_1_extra_sp = spell_info(
        spell_data.base_min, spell_data.base_max, 
        spell_data.over_time, spell_data.over_time_tick_freq, spell_data.over_time_duration, extra_ticks,
        cast_speed,
        max(0, spell_power + 1) ,
        min(1, crit),
        min(1, ot_crit),
        spell_crit_mod,
        hit,
        spell_mod, spell_mod_base,
        direct_coef, over_time_coef,
        cost, spell_data.school,
        spell_name, loadout
    );
    local dmg_1_extra_crit = spell_info(
        spell_data.base_min, spell_data.base_max, 
        spell_data.over_time, spell_data.over_time_tick_freq, spell_data.over_time_duration, extra_ticks,
        cast_speed,
        max(0, spell_power),
        min(1, crit_delta_1),
        min(1, ot_crit_delta_1),
        spell_crit_mod,
        hit,
        spell_mod, spell_mod_base,
        direct_coef, over_time_coef,
        cost, spell_data.school,
        spell_name, loadout
    );
    local dmg_1_extra_hit = spell_info(
        spell_data.base_min, spell_data.base_max, 
        spell_data.over_time, spell_data.over_time_tick_freq, spell_data.over_time_duration, extra_ticks,
        cast_speed,
        max(0, spell_power),
        min(1, crit),
        min(1, ot_crit),
        spell_crit_mod,
        hit_delta_1,
        spell_mod, spell_mod_base,
        direct_coef, over_time_coef,
        cost, spell_data.school,
        spell_name, loadout
    );


    local dmg_1_sp_delta = dmg_1_extra_sp.expectation - normal_dmg.expectation;
    local dmg_1_crit_delta = dmg_1_extra_crit.expectation - normal_dmg.expectation;
    local dmg_1_hit_delta  = dmg_1_extra_hit.expectation - normal_dmg.expectation;

    local sp_per_crit = dmg_1_crit_delta/(dmg_1_sp_delta);
    local sp_per_hit = dmg_1_hit_delta/(dmg_1_sp_delta);

    return {
        dmg_per_sp = dmg_1_sp_delta,
        sp_per_crit = sp_per_crit,
        sp_per_hit = sp_per_hit,

        spell_data = normal_dmg,
        spell_crit = crit,
        spell_hit = hit
    };
end

local function tooltip_spell_info(tooltip, spell, spell_name, loadout)

    if spell then

        local eval = evaluate_spell(spell, spell_name, loadout);
        
        local direct_coef, ot_coef = spell_coef(spell, spell_name);

        local effect = "";
        local effect_per_sec = "";
        local effect_per_cost = "";
        local effect_per_sp = "";
        local sp_name = "";

        if bit.band(spell.flags, spell_flags.heal) ~= 0 or bit.band(spell.flags, spell_flags.absorb) ~= 0 then
            effect = "Heal";
            effect_per_sec = "HPS";
            effect_per_cost = "Heal per Mana";
            cost_per_sec = "Mana per sec";
            effect_per_sp = "Heal per healing power";
            sp_name = "Healing power";
        else
            effect = "Damage";
            effect_per_sec = "DPS";
            effect_per_cost = "Damage per Mana";
            cost_per_sec = "Mana per sec";
            effect_per_sp = "Damage per spell power";
            sp_name = "Spell power";
        end

        begin_tooltip_section(tooltip);

        if bit.band(spell.flags, spell_flags.heal) ~= 0 or bit.band(spell.flags, spell_flags.absorb) ~= 0 then
            tooltip:AddLine(string.format("Stat Weights Classic: %s", loadout.name), 1, 1,1);
        else
            tooltip:AddLine(string.format("Stat Weights Classic: %s - target lvl %d", loadout.name, loadout.target_lvl), 1, 1, 1);
        end
        if eval.spell_data.min_noncrit ~= 0 then
            if eval.spell_data.min_noncrit ~= eval.spell_data.max_noncrit then
                -- dmg spells with real direct range
                if eval.spell_hit ~= 1 then
                    tooltip:AddLine(string.format("Normal %s (%.1f%% hit): %d-%d", 
                                                  effect, 
                                                  eval.spell_hit*100,
                                                  math.floor(eval.spell_data.min_noncrit), 
                                                  math.ceil(eval.spell_data.max_noncrit)),
                                    232.0/255, 225.0/255, 32.0/255);
                -- heal spells with real direct range
                else
                    tooltip:AddLine(string.format("Normal %s: %d-%d", 
                                                  effect, 
                                                  math.floor(eval.spell_data.min_noncrit), 
                                                  math.ceil(eval.spell_data.max_noncrit)),
                                    232.0/255, 225.0/255, 32.0/255);
                end
            else

                -- TODO: priest absorb is showing this...
                tooltip:AddLine(string.format("Normal %s (%.1f%% hit): %d", 
                                              effect,
                                              eval.spell_hit*100,
                                              math.floor(eval.spell_data.min_noncrit)),
                                              --string.format("%.0f", eval.spell_data.min_noncrit)),
                                232.0/255, 225.0/255, 32.0/255);
            end
            if eval.spell_crit ~= 0 then
                if loadout.ignite ~= 0 and eval.spell_data.ignite_min > 0 then
                    tooltip:AddLine(string.format("Critical %s (%.1f%% crit): %d-%d (ignites for %d-%d)", 
                                                  effect, 
                                                  eval.spell_crit*100, 
                                                  math.floor(eval.spell_data.min_crit), 
                                                  math.ceil(eval.spell_data.max_crit),
                                                  math.floor(eval.spell_data.ignite_min), 
                                                  math.ceil(eval.spell_data.ignite_max)),
                                   252.0/255, 69.0/255, 3.0/255);
                else
                    tooltip:AddLine(string.format("Critical %s (%.1f%% crit): %d-%d", 
                                                  effect, 
                                                  eval.spell_crit*100, 
                                                  math.floor(eval.spell_data.min_crit), 
                                                  math.ceil(eval.spell_data.max_crit)),
                                   252.0/255, 69.0/255, 3.0/255);
                end
            end
        end


        if eval.spell_data.ot_if_hit ~= 0 then

            -- round over time num for niceyness
            local ot = tonumber(string.format("%.0f", eval.spell_data.ot_if_hit));

            if eval.spell_hit ~= 1 then
                if spell_name == localized_spell_name("Curse of Agony") then
                    tooltip:AddLine(string.format("%s (%.1f%% hit): %d over %d sec (%.0f-%.0f-%.0f per tick for %d ticks)",
                                                  effect,
                                                  eval.spell_hit * 100,
                                                  eval.spell_data.ot_if_hit, 
                                                  eval.spell_data.ot_duration, 
                                                  eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks * 0.6,
                                                  eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks,
                                                  eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks * 1.4,
                                                  eval.spell_data.ot_num_ticks), 
                                    232.0/255, 225.0/255, 32.0/255);
                else
                    tooltip:AddLine(string.format("%s (%.1f%% hit): %d over %d sec (%d-%d per tick for %d ticks)",
                                                  effect,
                                                  eval.spell_hit * 100,
                                                  eval.spell_data.ot_if_hit, 
                                                  eval.spell_data.ot_duration, 
                                                  math.floor(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks),
                                                  math.ceil(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks),
                                                  eval.spell_data.ot_num_ticks), 
                                    232.0/255, 225.0/255, 32.0/255);
                end
                

            else
                tooltip:AddLine(string.format("%s: %d over %d sec (%d-%d per tick for %d ticks)",
                                              effect,
                                              eval.spell_data.ot_if_hit, 
                                              eval.spell_data.ot_duration, 
                                              math.floor(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks),
                                              math.ceil(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks),
                                              eval.spell_data.ot_num_ticks), 
                                232.0/255, 225.0/255, 32.0/255);
            end

            if bit.band(spell_flags.over_time_crit, spell.flags) ~= 0 then
                -- over time can crit (e.g. arcane missiles)
                tooltip:AddLine(string.format("Critical %s (%.1f%% crit): %d over %d sec (%d-%d per tick for %d ticks)",
                                              effect,
                                              eval.spell_crit*100, 
                                              eval.spell_data.ot_crit_if_hit, 
                                              eval.spell_data.ot_duration, 
                                              math.floor(eval.spell_data.ot_crit_if_hit/eval.spell_data.ot_num_ticks),
                                              math.ceil(eval.spell_data.ot_crit_if_hit/eval.spell_data.ot_num_ticks),
                                              eval.spell_data.ot_num_ticks), 
                           252.0/255, 69.0/255, 3.0/255);
                    
            end
        end

        
      local effect_extra_str = "";
      if loadout.ignite ~= 0 then
          if spell_name == localized_spell_name("Fireball") then
              effect_extra_str = " (incl: ignite - excl: fireball dot)";
          elseif spell_name == localized_spell_name("Pyroblast") then
              effect_extra_str = " (incl: ignite & pyro dot)";
          else
              effect_extra_str = " (incl: ignite )";
          end
      else
          if spell_name == localized_spell_name("Fireball") then
              effect_extra_str = " (excl: fireball dot)";
          elseif spell_name == localized_spell_name("Pyroblast") then
              effect_extra_str = " (incl: pyro dot)";
          elseif spell.over_time > 0 and eval.spell_data.expectation ~= eval.spell_data.ot then
              effect_extra_str = "(incl: over time)";
          end
      end
      if loadout.improved_shadowbolt ~= 0 and spell_name == localized_spell_name("Shadow Bolt") then
          effect_extra_str = string.format(" (incl: %.1f%% improved shadow bolt uptime)", 
                                           100*(1 - math.pow(1-eval.spell_crit, 4)));
      end
      if loadout.natures_grace and loadout.natures_grace ~= 0 and eval.spell_data.cast_time > 1.5 then
          effect_extra_str = " (incl: nature's grace)";
      end

      if spell_name == localized_spell_name("Prayer of Healing") or 
         spell_name == localized_spell_name("Chain Heal") or 
         spell_name == localized_spell_name("Chain Heal") or 
         spell_name == localized_spell_name("Tranquility") then

          effect_extra_str = " (incl: full effect)";
      elseif bit.band(spell.flags, spell_flags.aoe) ~= 0 and 
              eval.spell_data.expectation == eval.spell_data.expectation_st then
          effect_extra_str = "(incl: single effect)";
      end


      tooltip:AddLine("Expected "..effect..string.format(": %.1f ",eval.spell_data.expectation)..effect_extra_str);

      if eval.spell_data.base_min ~= 0.0 and eval.spell_data.expectation ~=  eval.spell_data.expectation_st then

        tooltip:AddLine("Expected "..effect..string.format(": %.1f",eval.spell_data.expectation_st).." (incl: single effect)");
      end

      tooltip:AddLine(string.format("%s: %.1f", 
                                    effect_per_sec,
                                    eval.spell_data.effect_per_sec));
      tooltip:AddLine(effect_per_cost..": "..string.format("%.1f",eval.spell_data.effect_per_cost), 0.0, 1.0, 1.0);
      tooltip:AddLine(cost_per_sec..": "..string.format("%.1f",eval.spell_data.cost_per_sec), 0.0, 1.0, 1.0);
      tooltip:AddLine(effect_per_sp..": "..string.format("%.1f",eval.dmg_per_sp), 0.0, 1.0, 0.0);
      tooltip:AddLine(sp_name.." per 1% crit: "..string.format("%.1f",eval.sp_per_crit), 0.0, 1.0, 0.0);

      if (bit.band(spell.flags, spell_flags.heal) == 0 and bit.band(spell.flags, spell_flags.absorb) == 0) then
          tooltip:AddLine(sp_name.." per 1%  hit: "..string.format("%.1f",eval.sp_per_hit), 0.0, 1.0, 0.0);
      end

      -- debug tooltip stuff
      if __sw__debug__ then
          tooltip:AddLine("Base "..effect..": "..spell.base_min.."-"..spell.base_max,
                          1.0, 1.0, 1.0);
          tooltip:AddLine("Average cost: "..eval.spell_data.mana, 1.0, 1.0, 1.0);
          tooltip:AddLine(string.format("Coef: %.3f, %.3f", direct_coef, ot_coef), 1.0, 1.0, 1.0);
          tooltip:AddLine("Average cast: "..eval.spell_data.cast_time, 1.0, 1.0, 1.0);
      end

      end_tooltip_section(tooltip);

      if spell.healing_version then
          -- used for holy nova
          tooltip_spell_info(tooltip, spell.healing_version, spell_name, loadout);
      end
    end
end

function spell_diff(spell_data, spell_name, loadout, diff)

    local loadout_diffed = loadout_add(loadout, diff);

    local expectation_loadout = evaluate_spell(spell_data, spell_name, loadout);
    local expectation_loadout_diffed = evaluate_spell(spell_data, spell_name, loadout_diffed);
    
    return {
        diff_ratio = 100 * 
            (expectation_loadout_diffed.spell_data.expectation/expectation_loadout.spell_data.expectation - 1),
        expectation = expectation_loadout_diffed.spell_data.expectation - 
            expectation_loadout.spell_data.expectation,
        effect_per_sec = expectation_loadout_diffed.spell_data.effect_per_sec - 
            expectation_loadout.spell_data.effect_per_sec
    };
end

local function print_spell(spell, spell_name, loadout)

    if spell then

        local eval = evaluate_spell(spell, spell_name, loadout);
        
        local direct_coef, ot_oef = spell_coef(spell, spell_name);

        print(string.format("Base spell: min %d, max %d, ot %d, ot_freq %d, ot_dur %d, cast %.3f, rank %d, lvl_req %d, flags %d, school %d, direct coef %.3f, ot coef %.3f, cost: %d", 
                            spell.base_min,
                            spell.base_max,
                            spell.over_time,
                            spell.over_time_tick_freq,
                            spell.over_time_duration,
                            spell.cast_time,
                            spell.rank,
                            spell.lvl_req,
                            spell.flags,
                            spell.school,
                            direct_coef,
                            ot_oef,
                            spell.mana
                            ));

        print(string.format("Spell noncrit: min %d, max %d", eval.spell_data.min_noncrit, eval.spell_data.max_noncrit));
        print(string.format("Spell crit: min %d, max %d", eval.spell_data.min_crit, eval.spell_data.max_crit));
                            

        print("Spell evaluation");
        print(string.format("ot if hit: %.3f", eval.spell_data.ot_if_hit));
        print(string.format("including hit/miss - expectation: %.3f, effect_per_sec: %.3f, dmg per mana:%.3f, dmg_per_sp : %.3f, sp_per_crit: %.3f, sp_per_hit: %.3f", 
                            eval.spell_data.expectation, 
                            eval.spell_data.effect_per_sec, 
                            eval.spell_data.effect_per_cost, 
                            eval.dmg_per_sp, 
                            eval.sp_per_crit, 
                            eval.sp_per_hit
                            ));
        print("---------------------------------------------------");
    end
end

--local function diff_spell(spell_data, spell_name, loadout1, loadout2)
--

--    lhs = evaluate_spell(spell_data, spell_name, loadout1);
--    rhs = evaluate_spell(spell_data, spell_name, loadout2);
--    return {
--        expectation = rhs.spell_data.expectation - lhs.spell_data.expectation,
--        effect_per_sec = rhs.spell_data.effect_per_sec - lhs.spell_data.effect_per_sec
--    };
--end


local function ui_y_offset_incr(y) 
    return y - 17;
end

local sw_frame = {};

local function create_loadout_from_ui_diff(frame) 

    local stats = frame.stats;

    -- verify validity and run input expr 
    for k, v in pairs(stats) do


        local expr_str = v.editbox:GetText();
        
        local is_whitespace_expr = expr_str and string.match(expr_str, "%S") == nil;
        --local is_whitespace_expr = string.format(expr_str, "[^ \t\n]") == nil;
        local is_valid_expr = string.match(expr_str, "[^-+0123456789. ()]") == nil

        local expr = nil;
        if is_valid_expr then
            expr = loadstring("return "..expr_str..";");
            if expr then
                v.editbox_val = expr();
                frame.is_valid = true;
            end
        end
        if is_whitespace_expr or not is_valid_expr or not expr then

            v.editbox_val = 0;
            if not is_whitespace_expr then
                frame.is_valid = false;
                return empty_loadout();
            end
        end
    end

    local loadout = empty_loadout();

    loadout.int = stats[stat_ids_in_ui.int].editbox_val;
    loadout.spirit = stats[stat_ids_in_ui.spirit].editbox_val;

    local loadout_crit = stats[stat_ids_in_ui.spell_crit].editbox_val;
    for i = 1, 7 do
        loadout.spell_crit_by_school[i] = loadout_crit/100;
    end
    loadout.healing_crit = loadout_crit/100;

    local loadout_hit = stats[stat_ids_in_ui.spell_hit].editbox_val;
    for i = 1, 7 do
        loadout.spelldmg_hit_by_school[i] = loadout_hit/100;
    end

    local loadout_sp = stats[stat_ids_in_ui.sp].editbox_val;
    for i = 1, 7 do
        loadout.spelldmg_by_school[i] = loadout.spelldmg_by_school[i] + loadout_sp;
    end

    loadout.healingpower = loadout.healingpower + loadout_sp;

    local loadout_spell_dmg = stats[stat_ids_in_ui.spell_damage].editbox_val;
    for i = 1, 7 do
        loadout.spelldmg_by_school[i] = loadout.spelldmg_by_school[i] + loadout_spell_dmg;
    end

    loadout.healingpower = loadout.healingpower + stats[stat_ids_in_ui.healing_power].editbox_val;

    for i = 2, 7 do

        local loadout_school_sp = stats[stat_ids_in_ui.holy_power - 2 + i].editbox_val;

        loadout.spelldmg_by_school[i] = loadout.spelldmg_by_school[i] + loadout_school_sp;
    end

    frame.is_valid = true;

    return loadout;
end


local display_spell_diff = nil;

local function update_and_display_spell_diffs(frame)

    frame.line_y_offset = frame.line_y_offset_before_dynamic_spells;

    local loadout = current_loadout();

    local loadout_diff = create_loadout_from_ui_diff(frame);

    for k, v in pairs(frame.spells) do
        display_spell_diff(k, spells[k], v, loadout, loadout_diff, frame, false);

        -- for spells with both heal and dmg
        if spells[k].healing_version then
            display_spell_diff(k, spells[k].healing_version, v, loadout, loadout_diff, frame, true);
        end
    end

    -- footer
    frame.line_y_offset = ui_y_offset_incr(frame.line_y_offset);
    frame.line_y_offset = ui_y_offset_incr(frame.line_y_offset);

    if not frame.footer then
        frame.footer = frame:CreateFontString(nil, "OVERLAY");
    end
    frame.footer:SetFontObject(font);
    frame.footer:SetPoint("TOPLEFT", 15, frame.line_y_offset);
    frame.footer:SetText("Add abilities by holding shift and hovering over them!");
end


display_spell_diff = function(spell_id, spell_data, spell_diff_line, loadout, loadout_diff, frame, is_duality_spell)

    local diff = spell_diff(spell_data, spell_diff_line.name, loadout, loadout_diff);

    local v = nil;
    if is_duality_spell then
        if not spell_diff_line.duality then
            spell_diff_line.duality = {};
        end
        spell_diff_line.duality.name = spell_diff_line.name;
        v = spell_diff_line.duality;
    else
        v = spell_diff_line;
    end
    
    frame.line_y_offset = ui_y_offset_incr(frame.line_y_offset);
    
    if not v.name_str then
        v.name_str = frame:CreateFontString(nil, "OVERLAY");
        v.name_str:SetFontObject(font);
    
        v.change = frame:CreateFontString(nil, "OVERLAY");
        v.change:SetFontObject(font);
    
        v.expectation = frame:CreateFontString(nil, "OVERLAY");
        v.expectation:SetFontObject(font);
    
        v.effect_per_sec = frame:CreateFontString(nil, "OVERLAY");
        v.effect_per_sec:SetFontObject(font);
    

        if not spell_data.healing_version then
            v.cancel_button = CreateFrame("Button", "button", frame, "UIPanelButtonTemplate"); 
        end
    end
    
    v.name_str:SetPoint("TOPLEFT", 15, frame.line_y_offset);
    if is_duality_spell and 
        bit.band(spell_data.flags, spell_flags.heal) ~= 0 then

        v.name_str:SetText(v.name.." H (Rank "..spell_data.rank..")");
    elseif v.name == localized_spell_name("Holy Nova") or v.name == localized_spell_name("Holy Shock") then

        v.name_str:SetText(v.name.." D (Rank "..spell_data.rank..")");
    else
        v.name_str:SetText(v.name.." (Rank "..spell_data.rank..")");
    end

    v.name_str:SetTextColor(222/255, 192/255, 40/255);
    
    if not frame.is_valid then
    
        v.change:SetPoint("TOPRIGHT", -180, frame.line_y_offset);
        v.change:SetText("NAN");
    
        v.expectation:SetPoint("TOPRIGHT", -115, frame.line_y_offset);
        v.expectation:SetText("NAN");
    
        v.effect_per_sec:SetPoint("TOPRIGHT", -45, frame.line_y_offset);
        v.effect_per_sec:SetText("NAN");
        
    else
    
        v.change:SetPoint("TOPRIGHT", -180, frame.line_y_offset);
        v.expectation:SetPoint("TOPRIGHT", -115, frame.line_y_offset);
        v.effect_per_sec:SetPoint("TOPRIGHT", -45, frame.line_y_offset);
    
        if diff.expectation < 0 then
    
            v.change:SetText(string.format("%.2f", diff.diff_ratio).."%");
            v.change:SetTextColor(195/255, 44/255, 11/255);
    
            v.expectation:SetText(string.format("%.2f", diff.expectation));
            v.expectation:SetTextColor(195/255, 44/255, 11/255);
    
            v.effect_per_sec:SetText(string.format("%.2f", diff.effect_per_sec));
            v.effect_per_sec:SetTextColor(195/255, 44/255, 11/255);
    
        elseif diff.expectation > 0 then
    
            v.change:SetText(string.format("+%.2f", diff.diff_ratio).."%");
            v.change:SetTextColor(33/255, 185/255, 21/255);
    
            v.expectation:SetText(string.format("+%.2f", diff.expectation));
            v.expectation:SetTextColor(33/255, 185/255, 21/255);
    
            v.effect_per_sec:SetText(string.format("+%.2f", diff.effect_per_sec));
            v.effect_per_sec:SetTextColor(33/255, 185/255, 21/255);
    
        else
    
            v.change:SetText("0 %");
            v.change:SetTextColor(1, 1, 1);
    
            v.expectation:SetText("0");
            v.expectation:SetTextColor(1, 1, 1);
    
            v.effect_per_sec:SetText("0");
            v.effect_per_sec:SetTextColor(1, 1, 1);
    
        end
            

        if not spell_data.healing_version then
            v.cancel_button:SetScript("OnClick", function()
    
                v.change:Hide();
                v.name_str:Hide();
                v.expectation:Hide();
                v.effect_per_sec:Hide();
                v.cancel_button:Hide();

                -- in case this was the duality spell, i.e. healing counterpart 
                frame.spells[spell_id].change:Hide();
                frame.spells[spell_id].name_str:Hide();
                frame.spells[spell_id].expectation:Hide();
                frame.spells[spell_id].effect_per_sec:Hide();

                frame.spells[spell_id] = nil;
                update_and_display_spell_diffs(frame);
    
            end);
    
            v.cancel_button:SetPoint("TOPRIGHT", -10, frame.line_y_offset + 3);
            v.cancel_button:SetHeight(20);
            v.cancel_button:SetWidth(25);
            v.cancel_button:SetText("X");
        end
    end
end

function create_base_gui()

    local frame_name = "sw_frame";
    sw_frame = CreateFrame("Frame", frame_name, SpellBookFrame, "BasicFrameTemplate, BasicFrameTemplateWithInset");

    sw_frame:RegisterEvent("ADDON_LOADED");
    sw_frame:RegisterEvent("PLAYER_LOGOUT");
    sw_frame:SetScript("OnEvent", function(self, event)

        if event == "ADDON_LOADED" then
            if __sw__persistent_spells_diff then

                self.spells = __sw__persistent_spells_diff;

                update_and_display_spell_diffs(self);
            end
        elseif event ==  "PLAYER_LOGOUT"  then

            -- clear previous ui elements from spells table
            __sw__persistent_spells_diff = {};
            for k,v in pairs(self.spells) do
                __sw__persistent_spells_diff[k] = {};
                __sw__persistent_spells_diff[k].name = v.name;
            end
        end
    end
    );

    sw_frame:SetWidth(370);
    sw_frame:SetHeight(600);
    sw_frame:SetPoint("RIGHT", SpellBookFrame, "RIGHT", 380, 10);

    local sw_toggle_button = CreateFrame("Button", "button", SpellBookFrame, "UIPanelButtonTemplate"); 

    sw_toggle_button:SetPoint("TOPRIGHT", -40, -34);
    sw_toggle_button:SetWidth(160);
    sw_toggle_button:SetHeight(25);
    sw_toggle_button:SetText("Stat Weights Classic -->");

    sw_toggle_button:SetScript("OnClick", function()

        if sw_frame:IsShown() then
            sw_frame:Hide();
        else
            sw_frame:Show();
        end
    end);

    sw_frame.title = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.title:SetFontObject(font)
    sw_frame.title:SetText("Stat Weights Classic");
    sw_frame.title:SetPoint("CENTER", sw_frame.TitleBg, "CENTER", 11, 0);

    sw_frame.line_y_offset = -15;


    sw_frame.line_y_offset = ui_y_offset_incr(sw_frame.line_y_offset);
    sw_frame.instructions_label = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.instructions_label:SetFontObject(font);
    sw_frame.instructions_label:SetPoint("TOPLEFT", 15, sw_frame.line_y_offset);
    sw_frame.instructions_label:SetText("Type into the fields below to compare stats against your current");

    sw_frame.line_y_offset = ui_y_offset_incr(sw_frame.line_y_offset);

    sw_frame.instructions_label = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.instructions_label:SetFontObject(font);
    sw_frame.instructions_label:SetPoint("TOPLEFT", 15, sw_frame.line_y_offset);
    sw_frame.instructions_label:SetText("loadout (it can do simple addition/subtraction math). The");

    sw_frame.line_y_offset = ui_y_offset_incr(sw_frame.line_y_offset);

    sw_frame.instructions_label = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.instructions_label:SetFontObject(font);
    sw_frame.instructions_label:SetPoint("TOPLEFT", 15, sw_frame.line_y_offset);
    sw_frame.instructions_label:SetText("change in spell effectiveness is displayed in terms of \"Expected\""); 

    sw_frame.line_y_offset = ui_y_offset_incr(sw_frame.line_y_offset);

    sw_frame.instructions_label = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.instructions_label:SetFontObject(font);
    sw_frame.instructions_label:SetPoint("TOPLEFT", 15, sw_frame.line_y_offset);
    sw_frame.instructions_label:SetText("as shown in the spell's tooltip which considers all your stats");

    sw_frame.line_y_offset = ui_y_offset_incr(sw_frame.line_y_offset);

    sw_frame.instructions_label = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.instructions_label:SetFontObject(font);
    sw_frame.instructions_label:SetPoint("TOPLEFT", 15, sw_frame.line_y_offset);
    sw_frame.instructions_label:SetText("to give you the average spell outcome.");

    sw_frame.line_y_offset = ui_y_offset_incr(sw_frame.line_y_offset);

    sw_frame.line_y_offset = sw_frame.line_y_offset - 10;

    sw_frame.stat_diff_header_left = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_diff_header_left:SetFontObject(font);
    sw_frame.stat_diff_header_left:SetPoint("TOPLEFT", 15, sw_frame.line_y_offset);
    sw_frame.stat_diff_header_left:SetText("Stat");

    sw_frame.stat_diff_header_center = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_diff_header_center:SetFontObject(font);
    sw_frame.stat_diff_header_center:SetPoint("TOPRIGHT", -80, sw_frame.line_y_offset);
    sw_frame.stat_diff_header_center:SetText("Difference");


    local num_stats = 13;

    sw_frame.clear_button = CreateFrame("Button", "button", sw_frame, "UIPanelButtonTemplate"); 
    sw_frame.clear_button:SetScript("OnClick", function()

        for i = 1, num_stats do

            sw_frame.stats[i].editbox:SetText("");
        end

        update_and_display_spell_diffs(sw_frame);
    end);

    sw_frame.clear_button:SetPoint("TOPRIGHT", -30, sw_frame.line_y_offset + 3);
    sw_frame.clear_button:SetHeight(15);
    sw_frame.clear_button:SetWidth(50);
    sw_frame.clear_button:SetText("Clear");

    --sw_frame.line_y_offset = sw_frame.line_y_offset - 10;


    sw_frame.stats = {
        [1] = {
            label_str = "Intellect"
        },
        [2] = {
            label_str = "Spirit"
        },
        [3] = {
            label_str = "Spell crit %"
        },
        [4] = {
            label_str = "Spell hit %"
        },
        [5] = {
            label_str = "Spell power"
        },
        [6] = {
            label_str = "Spell damage"
        },
        [7] = {
            label_str = "Healing power"
        },
        [8] = {
            label_str = "Holy spell power"
        },
        [9] = {
            label_str = "Fire spell power"
        },
        [10] = {
            label_str = "Nature spell power"
        },
        [11] = {
            label_str = "Frost spell power"
        },
        [12] = {
            label_str = "Shadow spell power"
        },
        [13] = {
            label_str = "Arcane spell power"
        }
    };

    for i = 1 , num_stats do

        v = sw_frame.stats[i];

        sw_frame.line_y_offset = ui_y_offset_incr(sw_frame.line_y_offset);

        v.label = sw_frame:CreateFontString(nil, "OVERLAY");

        v.label:SetFontObject(font);
        v.label:SetPoint("TOPLEFT", 15, sw_frame.line_y_offset);
        v.label:SetText(v.label_str);
        v.label:SetTextColor(222/255, 192/255, 40/255);


        v.editbox = CreateFrame("EditBox", v.label_str.."editbox"..i, sw_frame, "InputBoxTemplate");
        v.editbox:SetPoint("TOPRIGHT", -30, sw_frame.line_y_offset);
        v.editbox:SetText("");
        v.editbox:SetAutoFocus(false);
        v.editbox:SetSize(100, 10);
        v.editbox:SetScript("OnTextChanged", function(self)

            if string.match(self:GetText(), "[^-+0123456789. ()]") ~= nil then
                self:ClearFocus();
                self:SetText("");
                self:SetFocus();
            else 
                update_and_display_spell_diffs(sw_frame);
            end
        end);

        v.editbox:SetScript("OnEnterPressed", function(self)

        	self:ClearFocus()
        end);
        
        v.editbox:SetScript("OnEscapePressed", function(self)
        	self:ClearFocus()
        end);

        v.editbox:SetScript("OnTabPressed", function(self)

            local next_index = 0;
            if IsShiftKeyDown() then
                next_index = 1 + ((i-2) %num_stats);
            else
                next_index = 1 + (i %num_stats);

            end
        	self:ClearFocus()
            sw_frame.stats[next_index].editbox:SetFocus();
        end);
    end

    sw_frame.stats[stat_ids_in_ui.sp].editbox:SetText("1");

    --sw_frame:SetScript("OnLeave", function(self)
    --    
    --    if sw_frame:IsShown() and SpellBookFrame:IsShown() and not MouseIsOver(sw_frame, 0, 0, 0, 0) then

    --        for key, val in pairs(sw_frame.stats) do
    --            val.editbox:ClearFocus();
    --        end
    --    end
    --end)

    -- header for spells

    sw_frame.line_y_offset = ui_y_offset_incr(sw_frame.line_y_offset);
    sw_frame.line_y_offset = ui_y_offset_incr(sw_frame.line_y_offset);

    sw_frame.line_y_offset_before_dynamic_spells = sw_frame.line_y_offset;

    sw_frame.spell_diff_header_left = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.spell_diff_header_left:SetFontObject(font);
    sw_frame.spell_diff_header_left:SetPoint("TOPLEFT", 15, sw_frame.line_y_offset);
    sw_frame.spell_diff_header_left:SetText("Spell");

    sw_frame.spell_diff_header_center = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.spell_diff_header_center:SetFontObject(font);
    sw_frame.spell_diff_header_center:SetPoint("TOPRIGHT", -180, sw_frame.line_y_offset);
    sw_frame.spell_diff_header_center:SetText("Change");

    sw_frame.spell_diff_header_center = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.spell_diff_header_center:SetFontObject(font);
    sw_frame.spell_diff_header_center:SetPoint("TOPRIGHT", -105, sw_frame.line_y_offset);
    sw_frame.spell_diff_header_center:SetText("DMG/HEAL");

    sw_frame.spell_diff_header_left = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.spell_diff_header_left:SetFontObject(font);
    sw_frame.spell_diff_header_left:SetPoint("TOPRIGHT", -45, sw_frame.line_y_offset);
    sw_frame.spell_diff_header_left:SetText("DPS/HPS");

    -- always have at least one
    sw_frame.spells = {};

    if UnitLevel("player") == 60 then
        local _, class = UnitClass("player");

        if class == "MAGE" then
            sw_frame.spells[10181] = {-- pre AQ
                name = localized_spell_name("Frostbolt")
            };
            sw_frame.spells[10151] = {-- pre AQ
                name = localized_spell_name("Fireball")
            };
        elseif class == "DRUID" then

            sw_frame.spells[9889] = {-- pre AQ
                name = localized_spell_name("Healing Touch")
            };
            sw_frame.spells[9876] = {-- pre AQ
                name = localized_spell_name("Starfire")
            };

        elseif class == "PALADIN" then

            sw_frame.spells[19943] = {
                name = localized_spell_name("Flash of Light")
            };
            sw_frame.spells[10329] = {-- pre AQ
                name = localized_spell_name("Holy Light")
            };
        elseif class == "SHAMAN" then

            sw_frame.spells[10396] = {--pre AQ
                name = localized_spell_name("Healing Wave")
            };
            sw_frame.spells[15208] = {
                name = localized_spell_name("Lightning Bolt")
            };
        elseif class == "PRIEST" then

            sw_frame.spells[10965] = { -- pre AQ
                name = localized_spell_name("Greater Heal")
            };
            sw_frame.spells[10929] = { -- pre AQ
                name = localized_spell_name("Renew")
            };
        elseif class == "WARLOCK" then

            sw_frame.spells[11661] = {-- pre AQ
                name = localized_spell_name("Shadow Bolt")
            };
            sw_frame.spells[11672] = {-- pre AQ
                name = localized_spell_name("Corruption")
            };
            sw_frame.spells[11713] = {
                name = localized_spell_name("Curse of Agony")
            };
        end
    end

    sw_frame:Hide()
end

local function command(msg, editbox)
    if msg == "loadout" then
        print_loadout(current_loadout());
    else
        if SpellBookFrame:IsShown() then

        else
            ToggleFrame(SpellBookFrame);
        end

        sw_frame:Show();
    end
end

GameTooltip:HookScript("OnTooltipSetSpell", function(tooltip, ...)

    local spell_name, spell_id = tooltip:GetSpell();

    local spell = get_spell(spell_id);

    local loadout = current_loadout();

    --local spell_name, _ = GetSpellInfo(spell_id);

    --print_spell(spell, spell_name, loadout);
    tooltip_spell_info(GameTooltip, spell, spell_name, loadout);

    if spell and IsShiftKeyDown() and sw_frame:IsShown() and not sw_frame.spells[spell_id]then
        sw_frame.spells[spell_id] = {
            name = spell_name
        }

        update_and_display_spell_diffs(sw_frame);
    end

end)

SLASH_STAT_WEIGHTS1 = "/sw"
SLASH_STAT_WEIGHTS2 = "/stat-weights"
SLASH_STAT_WEIGHTS3 = "/stat-weights-classic"
SLASH_STAT_WEIGHTS4 = "/swc"
SlashCmdList["STAT_WEIGHTS"] = command

create_base_gui();

--__sw__debug__ = 1;

