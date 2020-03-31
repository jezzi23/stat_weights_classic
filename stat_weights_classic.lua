
local version =  "1.0.0";
-- TODO: add libstub here
--local icon_lib = LibStub("LibDBIcon-1.0");

local font = "GameFontHighlightSmall"

--TODO: Known spells that are incorrectly evaluated
        -- Holy Nova
        -- Regrowth

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
    pyro_dot = bit.lshift(1,4), -- pyro is an exception to scaling rules
    flat_dot = bit.lshift(1,5), -- 0 scaling on dots
    absorb = bit.lshift(1,6),
    over_time_crit = bit.lshift(1,7),
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
                flags               = spell_flags.flat_dot,
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
                flags               = spell_flags.flat_dot,
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
                flags               = spell_flags.flat_dot,
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
                flags               = spell_flags.flat_dot,
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
                flags               = spell_flags.flat_dot,
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
                flags               = spell_flags.flat_dot,
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
                flags               = spell_flags.flat_dot,
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
                flags               = spell_flags.flat_dot,
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
                flags               = spell_flags.flat_dot,
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
                flags               = spell_flags.flat_dot,
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
                flags               = spell_flags.flat_dot,
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
                flags               = spell_flags.flat_dot,
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
            -- arcane missile
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
                lvl_req              = 40,
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
            }
        }; 
    elseif class == "SHAMAN" then
        return {
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
            }
            -- lightning bolt
            --[403] = {
            --    base_min            = 15.0,
            --    base_max            = 17.0, 
            --    over_time           = 0,
            --    over_time_tick_freq = 0,
            --    over_time_duration  = 0.0,
            --    cast_time           = 1.5,
            --    rank                = 1,
            --    lvl_req             = 1,
            --    mana                = 15,
            --    flags               = 0,
            --    school              = magic_school.nature,
            --},
            --[529] = {
            --    base_min            = 28.0,
            --    base_max            = 33.0, 
            --    over_time           = 0,
            --    over_time_tick_freq = 0,
            --    over_time_duration  = 0.0,
            --    cast_time           = 2.0,
            --    rank                = 2,
            --    lvl_req             = 8,
            --    mana                = 30,
            --    flags               = 0,
            --    school              = magic_school.nature,
            --},
            --[548] = {
            --    base_min            = 48.0,
            --    base_max            = 57.0, 
            --    over_time           = 0,
            --    over_time_tick_freq = 0,
            --    over_time_duration  = 0.0,
            --    cast_time           = 2.5,
            --    rank                = 3,
            --    lvl_req             = 14,
            --    mana                = 45,
            --    flags               = 0,
            --    school              = magic_school.nature,
            --},
            --[915] = {
            --    base_min            = 88.0,
            --    base_max            = 100.0, 
            --    over_time           = 0,
            --    over_time_tick_freq = 0,
            --    over_time_duration  = 0.0,
            --    cast_time           = 3.0,
            --    rank                = 4,
            --    lvl_req             = 20,
            --    mana                = 75,
            --    flags               = 0,
            --    school              = magic_school.nature,
            --},
            --[943] = {
            --    base_min            = 131.0,
            --    base_max            = 149.0, 
            --    over_time           = 0,
            --    over_time_tick_freq = 0,
            --    over_time_duration  = 0.0,
            --    cast_time           = 3.0,
            --    rank                = 5,
            --    lvl_req             = 26,
            --    mana                = 105,
            --    flags               = 0,
            --    school              = magic_school.nature,
            --},
            --[6041] = {
            --    base_min            = 179.0,
            --    base_max            = 202.0, 
            --    over_time           = 0,
            --    over_time_tick_freq = 0,
            --    over_time_duration  = 0.0,
            --    cast_time           = 3.0,
            --    rank                = 6,
            --    lvl_req             = 32,
            --    mana                = 135,
            --    flags               = 0,
            --    school              = magic_school.nature,
            --},
            --[548] = {
            --    base_min            = 48.0,
            --    base_max            = 57.0, 
            --    over_time           = 0,
            --    over_time_tick_freq = 0,
            --    over_time_duration  = 0.0,
            --    cast_time           = 2.5,
            --    rank                = 3,
            --    lvl_req             = 14,
            --    mana                = 45,
            --    flags               = 0,
            --    school              = magic_school.nature,
            --},
            --[548] = {
            --    base_min            = 48.0,
            --    base_max            = 57.0, 
            --    over_time           = 0,
            --    over_time_tick_freq = 0,
            --    over_time_duration  = 0.0,
            --    cast_time           = 2.5,
            --    rank                = 3,
            --    lvl_req             = 14,
            --    mana                = 45,
            --    flags               = 0,
            --    school              = magic_school.nature,
            --},
            --[548] = {
            --    base_min            = 48.0,
            --    base_max            = 57.0, 
            --    over_time           = 0,
            --    over_time_tick_freq = 0,
            --    over_time_duration  = 0.0,
            --    cast_time           = 2.5,
            --    rank                = 3,
            --    lvl_req             = 14,
            --    mana                = 45,
            --    flags               = 0,
            --    school              = magic_school.nature,
            --},
            --[548] = {
            --    base_min            = 48.0,
            --    base_max            = 57.0, 
            --    over_time           = 0,
            --    over_time_tick_freq = 0,
            --    over_time_duration  = 0.0,
            --    cast_time           = 2.5,
            --    rank                = 3,
            --    lvl_req             = 14,
            --    mana                = 45,
            --    flags               = 0,
            --    school              = magic_school.nature,
            --},
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
            }
        };
    end
    return {};
end

local spells = create_spells();

local function get_spell(spell_id)

    return spells[spell_id];
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

        spell_heal_mod = 0,

        stat_mod = {0, 0, 0, 0, 0},

        ignite = 0,
        spiritual_guidance = 0,
        illumination  = 0,
        master_of_elements  = 0,
        natures_grace = 0,
        
        -- indexable by ability name
        ability_crit = {},
        ability_effect_mod= {},
        ability_cast_mod = {},
        ability_extra_ticks = {},
        ability_cost_mod = {},
        ability_crit_mod = {}
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
    negated.spell_heal_mod = -negated.spell_heal_mod;

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

    cpy.spell_heal_mod = loadout.spell_heal_mod;


    cpy.ignite = loadout.ignite;
    cpy.spiritual_guidance = loadout.spiritual_guidance;
    cpy.illumination = loadout.illumination;
    cpy.master_of_elements = loadout.master_of_elements;
    cpy.natures_grace = loadout.natures_grace;

    cpy.stat_mod = {};

    cpy.ability_crit = {};
    cpy.ability_effect_mod = {};
    cpy.ability_cast_mod = {};
    cpy.ability_extra_ticks = {};
    cpy.ability_cost_mod = {};
    cpy.ability_crit_mod = {};

    for i = 1, 7 do
        cpy.spelldmg_by_school[i] = loadout.spelldmg_by_school[i];
        cpy.spell_crit_by_school[i] = loadout.spell_crit_by_school[i];
        cpy.spelldmg_hit_by_school[i] = loadout.spelldmg_hit_by_school[i];
        cpy.spell_dmg_mod_by_school[i] = loadout.spell_dmg_mod_by_school[i];
        cpy.spell_crit_mod_by_school[i] = loadout.spell_crit_mod_by_school[i];
    end

    for i = 1, 5 do
        cpy.stat_mod[i] = loadout.stat_mod[i];
    end

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

    added.spell_heal_mod = primary.spell_heal_mod + diff.spell_heal_mod;

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
            if not new_loadout.ability_crit["Arcane Explosion"] then
                new_loadout.ability_crit["Arcane Explosion"] = 0;
            end
            new_loadout.ability_crit["Arcane Explosion"] = new_loadout.ability_crit["Arcane Explosion"] + pts * 0.02;
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
            if not new_loadout.ability_cast_mod["Fireball"] then
                new_loadout.ability_cast_mod["Fireball"] = 0;
            end
            new_loadout.ability_cast_mod["Fireball"] = new_loadout.ability_cast_mod["Fireball"] + pts * 0.1;
        end
        -- ignite
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 3);
        if pts ~= 0 then
           new_loadout.ignite = pts; 
        end
        -- incinerate
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 6);
        if pts ~= 0 then
            if not new_loadout.ability_crit["Scorch"] then
                new_loadout.ability_crit["Scorch"] = 0;
            end
            if not new_loadout.ability_crit["Fire Blast"] then
                new_loadout.ability_crit["Fire Blast"] = 0;
            end
            new_loadout.ability_crit["Scorch"] = new_loadout.ability_crit["Scorch"] + pts * 0.02;
            new_loadout.ability_crit["Fire Blast"] = new_loadout.ability_crit["Fire Blast"] + pts * 0.02;
        end
        -- improved flamestrike
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 7);
        if pts ~= 0 then
            if not new_loadout.ability_crit["Flamestrike"] then
                new_loadout.ability_crit["Flamestrike"] = 0;
            end
            new_loadout.ability_crit["Flamestrike"] = new_loadout.ability_crit["Flamestrike"] + pts * 0.05;
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
            if not new_loadout.ability_cast_mod["Frostbolt"] then
                new_loadout.ability_cast_mod["Frostbolt"] = 0;
            end
            new_loadout.ability_cast_mod["Frostbolt"] = new_loadout.ability_cast_mod["Frostbolt"] + pts * 0.1;
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
            new_loadout.spell_crit_mod_by_school[5] = 1 + (new_loadout.spell_crit_mod_by_school[5] - 1) * (1 + pts * 0.2);
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
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(cold_spells) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.05;
            end
        end
        -- imrpoved cone of cold
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 15);
        if pts ~= 0 then
            if not new_loadout.ability_effect_mod["Cone of Cold"] then
                new_loadout.ability_effect_mod["Cone of Cold"] = 0;
            end
            new_loadout.ability_effect_mod["Cone of Cold"] = new_loadout.ability_effect_mod["Cone of Cold"] + pts * 0.15;
        end
    elseif class == "DRUID" then

        -- improved wrath
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 1);
        if pts ~= 0 then
            if not new_loadout.ability_cast_mod["Wrath"] then
                new_loadout.ability_cast_mod["Wrath"] = 0;
            end
            new_loadout.ability_cast_mod["Wrath"] = new_loadout.ability_cast_mod["Wrath"] + pts * 0.1;
        end

        -- improved moonfire
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 5);
        if pts ~= 0 then
            if not new_loadout.ability_effect_mod["Moonfire"] then
                new_loadout.ability_effect_mod["Moonfire"] = 0;
            end
            if not new_loadout.ability_crit["Moonfire"] then
                new_loadout.ability_crit["Moonfire"] = 0;
            end
            new_loadout.ability_effect_mod["Moonfire"] = new_loadout.ability_effect_mod["Moonfire"] + pts * 0.02;
            new_loadout.ability_crit["Moonfire"] = new_loadout.ability_crit["Moonfire"] + pts * 0.02;
        end

        -- vengeance
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 11);
        if pts ~= 0 then

            if not new_loadout.ability_crit_mod[v] then
                new_loadout.ability_crit_mod["Moonfire"] = 0;
                new_loadout.ability_crit_mod["Starfire"] = 0;
                new_loadout.ability_crit_mod["Wrath"] = 0;
            end
            new_loadout.ability_crit_mod["Moonfire"] = 
                (new_loadout.spell_crit_mod_by_school[magic_school.arcane] - 1) * (pts * 0.2);
            new_loadout.ability_crit_mod["Starfire"] = 
                (new_loadout.spell_crit_mod_by_school[magic_school.arcane] - 1) * (pts * 0.2);
            new_loadout.ability_crit_mod["Wrath"] = 
                (new_loadout.spell_crit_mod_by_school[magic_school.nature] - 1) * (pts * 0.2);
        end

        -- improved starfire
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 12);
        if pts ~= 0 then
            if not new_loadout.ability_cast_mod["Starfire"] then
                new_loadout.ability_cast_mod["Starfire"] = 0;
            end
            new_loadout.ability_cast_mod["Starfire"] = new_loadout.ability_cast_mod["Starfire"] + pts * 0.1;
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
            if not new_loadout.ability_cast_mod["Healing Touch"] then
                new_loadout.ability_cast_mod["Healing Touch"] = 0;
            end
            new_loadout.ability_cast_mod["Healing Touch"] = new_loadout.ability_cast_mod["Healing Touch"] + pts * 0.1;
        end

        -- tranquil spirit
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 9);
        if pts ~= 0 then
            local abilities = {"Healing Touch", "Tranquility"};
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
            if not new_loadout.ability_effect_mod["Rejuvenation"] then
                new_loadout.ability_effect_mod["Rejuvenation"] = 0;
            end
            new_loadout.ability_effect_mod["Rejuvenation"] = new_loadout.ability_effect_mod["Rejuvenation"] + pts * 0.05;
        end

        -- gift of nature
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 12);
        if pts ~= 0 then
            new_loadout.spell_heal_mod = new_loadout.spell_heal_mod + pts * 0.02;
        end

        -- improved regrowth
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 14);
        if pts ~= 0 then
            if not new_loadout.ability_crit["Regrowth"] then
                new_loadout.ability_crit["Regrowth"] = 0;
            end
            new_loadout.ability_crit["Regrowth"] = new_loadout.ability_crit["Regrowth"] + pts * 0.10;
        end
    elseif class == "PRIEST" then

        -- improved power word: shield
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 5);
        if pts ~= 0 then
            if not new_loadout.ability_effect_mod["Power Word: Shield"] then
                new_loadout.ability_effect_mod["Power Word: Shield"] = 0;
            end
            new_loadout.ability_effect_mod["Power Word: Shield"] = 
                new_loadout.ability_effect_mod["Power Word: Shield"] + pts * 0.05;
        end

        -- mental agility 
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 10);
        if pts ~= 0 then

            local instants = {"Power Word: Shield", "Renew", "Holy Nova"};
            for k, v in pairs(instants) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(instants) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.02;
            end
        end
        -- TODO: force of will
        -- improved renew
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 2);
        if pts ~= 0 then

            if not new_loadout.ability_effect_mod["Renew"] then
                new_loadout.ability_effect_mod["Renew"] = 0;
            end
            new_loadout.ability_effect_mod["Renew"] = new_loadout.ability_effect_mod["Renew"] + pts * 0.05;
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

            if not new_loadout.ability_cost_mod["Prayer of Healing"] then
                new_loadout.ability_cost_mod["Prayer of Healing"] = 0;
            end
            new_loadout.ability_cost_mod["Prayer of Healing"] = 
                new_loadout.ability_cost_mod["Prayer of Healing"] + pts * 0.1;
        end
        -- spiritual guidance 
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 14);
        if pts ~= 0 then
           new_loadout.spiritual_guidance = pts; 
        end
        -- spiritual healing
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(2, 15);
        if pts ~= 0 then
            new_loadout.spell_heal_mod = new_loadout.spell_heal_mod + pts * 0.02;
        end
        --TODO: shadow talents

    elseif class == "SHAMAN" then

        -- improved healing wave
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 1);
        if pts ~= 0 then
            if not new_loadout.ability_cast_mod["Healing Wave"] then
                new_loadout.ability_cast_mod["Healing Wave"] = 0;
            end
            new_loadout.ability_cast_mod["Healing Wave"] = new_loadout.ability_cast_mod["Healing Wave"] + pts * 0.1;
        end

        -- tidal focus
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 2);
        if pts ~= 0 then

            local abilities = {"Lesser Heal", "Healing Wave", "Chain Heal", "Healing Stream Totem"};
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
                if not new_loadout.ability_effect_mod[v] then
                    new_loadout.ability_effect_mod[v] = 0;
                end
            end
            for k, v in pairs(totems) do
                new_loadout.ability_effect_mod[v] = new_loadout.ability_effect_mod[v] + pts * 0.05;
            end
        end

        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 11);
        if pts ~= 0 then

            new_loadout.healing_crit = new_loadout.healing_crit + pts * 0.01;

            -- TODO: lightning shield? any more lightning spells??
            local lightning_spells = {"Lightning Bolt", "Chain Lightning"};

            for k, v in pairs(lightning_spells) do
                if not new_loadout.ability_crit[v] then
                    new_loadout.ability_crit[v] = 0;
                end
            end
            for k, v in pairs(lightning_spells) do
                new_loadout.ability_crit[v] = new_loadout.ability_crit[v] + pts * 0.01;
            end
        end

        local _, _, _, _, pts, _, _, _ = GetTalentInfo(3, 14);
        if pts ~= 0 then

            new_loadout.spell_heal_mod = new_loadout.spell_heal_mod + pts * 0.02;

        end


    elseif class == "PALADIN" then

        -- divine intellect
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 2);
        if pts ~= 0 then
            new_loadout.stat_mod = new_loadout.stat_mod[stat.int] + pts * 0.02;
        end

        -- healing light
        local _, _, _, _, pts, _, _, _ = GetTalentInfo(1, 5);
        if pts ~= 0 then

            local abilities = {"Holy Light", "Flash of Light"};

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

   loadout_with_talents = apply_talents(loadout);

   return loadout_with_talents;
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

    for k, v in pairs(loadout.ability_effect_mod) do
        print("mod: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_crit) do
        print("crit: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_cast_mod) do
        print("cast: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_extra_ticks) do
        print("extra ticks: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_cost_mod) do
        print("cost: ", k, string.format("%.3f", v));
    end

    for k, v in pairs(loadout.ability_crit_mod) do
        print("crit mod: ", k, string.format("%.3f", v));
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
        if spell_name == "Arcane Missiles" then
            -- for arcane missiles max scaling is at 5 secs channel at 1.2 coef
            ot_coef = 1.2 * spell_info.over_time_duration/5;
        elseif spell_info.cast_time == spell_info.over_time_duration then
            ot_coef = math.min(1.0, math.max(1.5/3.5, spell_info.cast_time/3.5));
        else
            ot_coef = spell_info.over_time_duration/15.0;
        end
    end

    -- special coefs
    if spell_name == "Power Word: Shield" then
        direct_coef = 0.1;
        ot_coef = 0;
    elseif spell_name == "Healing Stream Totem" then
        direct_coef = 0.0;
        ot_coef = 0.65;
    elseif spell_name == "Insect Swarm" then
        -- insect swarm seems to have 15/15 scaling isntead of 12/15
        direct_coef = 0.0;
        ot_coef = 1.0;
    elseif spell_name == "Entangling Roots" then
        -- scales of cast time, not ot duration
        ot_coef = 0.0;
        direct_coef = math.min(1.0, math.max(1.5/3.5, spell_info.cast_time/3.5));
    end
    -- distribute direct and ot coefs if both
    if spell_info.base_min > 0 and spell_info.over_time > 0 then
        -- pyroblast and fireball dots are special...
        if spell_name == "Pyroblast" then
            direct_coef = 1.0;
            ot_coef = 0.65;
        elseif spell_name == "Fireball" then
            direct_coef = 1.0;
            ot_coef = 0;
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

    if spell_name == "Holy Nova" then
        direct_coef = direct_coef/2;
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

    local min_noncrit_if_hit = (base_min * base_mod + sp * direct_coef) * mod;
    local max_noncrit_if_hit = (base_max * base_mod + sp * direct_coef) * mod;

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
    if spell_name == "Fireball" then
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

    local expected_ot = hit * ot;

    local expectation_ot_if_hit = (1 - ot_crit) * ot + ot_crit * ot_if_crit;

    local expected_ot = hit * expectation_ot_if_hit;

    local expectation_direct = (min + max) / 2;
    local expectation = expectation_direct + expected_ot + hit * crit * (ignite_min + ignite_max)/2;

    if loadout.natures_grace and loadout.natures_grace ~= 0  and cast_time >= 2 and 
        spell_name ~= "Tranquility" and spell_name == "Hurricane" then

        cast_time = cast_time - 0.5 * crit;
    end

    local expectation_st = expectation;
    if spell_name == "Chain Heal" then
        expectation = 1.75 * expectation_st;
    elseif spell_name == "Prayer of Healing" then
        expectation = 5 * expectation_st;
    elseif spell_name == "Tranquility" then
        expectation = 5 * expectation_st;
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
    cast_speed = math.max(cast_speed, 1.5);

    local spell_mod = 1;
    local spell_mod_base = 1;
    if not loadout.ability_effect_mod[spell_name] then
        loadout.ability_effect_mod[spell_name] = 0;
    end

    if bit.band(spell_data.flags, spell_flags.heal) ~= 0 then
        spell_mod = 1;
        spell_mod_base = 1 + loadout.spell_heal_mod;
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

    local hit = spell_hit(loadout.lvl, loadout.target_lvl, loadout.spelldmg_hit_by_school[spell_data.school]);
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
        cost = cost * (1 - loadout.ability_cost_mod[spell_name]);
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
            tooltip:AddLine(string.format("Loadout: %s", loadout.name));
        else
            tooltip:AddLine(string.format("Loadout: %s - target lvl %d", loadout.name, loadout.target_lvl));
        end
        if eval.spell_data.min_noncrit ~= 0 then
            if eval.spell_data.min_noncrit ~= eval.spell_data.max_noncrit then
                if eval.spell_hit ~= 1 then
                    tooltip:AddLine(string.format("  Normal %s (%.1f%% hit): %d-%d", 
                                                  effect, 
                                                  eval.spell_hit*100,
                                                  math.ceil(eval.spell_data.min_noncrit), 
                                                  math.floor(eval.spell_data.max_noncrit)),
                                    232.0/255, 225.0/255, 32.0/255);
                else
                    tooltip:AddLine(string.format("  Normal %s: %d-%d", 
                                                  effect, 
                                                  math.ceil(eval.spell_data.min_noncrit), 
                                                  math.floor(eval.spell_data.max_noncrit)),
                                    232.0/255, 225.0/255, 32.0/255);
                end
            else

                tooltip:AddLine(string.format("  Normal %s (%.1f%% hit): %d", 
                                              effect,
                                              eval.spell_hit*100,
                                              math.floor(eval.spell_data.min_noncrit)),
                                              --string.format("%.0f", eval.spell_data.min_noncrit)),
                                232.0/255, 225.0/255, 32.0/255);
            end
            if eval.spell_crit ~= 0 then
                if loadout.ignite ~= 0 and eval.spell_data.ignite_min > 0 then
                    tooltip:AddLine(string.format("  Critical %s (%.1f%% crit): %d-%d (ignites for %d-%d)", 
                                                  effect, 
                                                  eval.spell_crit*100, 
                                                  math.ceil(eval.spell_data.min_crit), 
                                                  math.floor(eval.spell_data.max_crit),
                                                   math.ceil(eval.spell_data.ignite_min), 
                                                  math.floor(eval.spell_data.ignite_max)),
                                   194.0/255, 52.0/255, 23.0/255);
                else
                    tooltip:AddLine(string.format("  Critical %s (%.1f%% crit): %d-%d", 
                                                  effect, 
                                                  eval.spell_crit*100, 
                                                  math.ceil(eval.spell_data.min_crit), 
                                                  math.floor(eval.spell_data.max_crit)),
                                   194.0/255, 52.0/255, 23.0/255);
                end
            end
        end


        if eval.spell_data.ot_if_hit ~= 0 then

            -- round over time num for niceyness
            local ot = tonumber(string.format("%.0f", eval.spell_data.ot_if_hit));

            if eval.spell_hit ~= 1 then
                tooltip:AddLine(string.format("  %s (%.1f%% hit): %d over %d sec (%d-%d per tick for %d ticks)",
                                              effect,
                                              eval.spell_hit * 100,
                                              eval.spell_data.ot_if_hit, 
                                              eval.spell_data.ot_duration, 
                                              math.floor(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks),
                                              math.ceil(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks),
                                              eval.spell_data.ot_num_ticks), 
                                232.0/255, 225.0/255, 32.0/255);

            else
                tooltip:AddLine(string.format("  %s: %d over %d sec (%d-%d per tick for %d ticks)",
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
                tooltip:AddLine(string.format("  Critical %s (%.1f%% crit): %d over %d sec (%d-%d per tick for %d ticks)",
                                              effect,
                                              eval.spell_crit*100, 
                                              eval.spell_data.ot_crit_if_hit, 
                                              eval.spell_data.ot_duration, 
                                              math.floor(eval.spell_data.ot_crit_if_hit/eval.spell_data.ot_num_ticks),
                                              math.ceil(eval.spell_data.ot_crit_if_hit/eval.spell_data.ot_num_ticks),
                                              eval.spell_data.ot_num_ticks), 
                           194.0/255, 52.0/255, 23.0/255);
                    
            end
        end

        
      local effect_extra_str = "";
      if loadout.ignite ~= 0 then
          if spell_name == "Fireball" then
              effect_extra_str = " (incl: ignite - excl: fireball dot)";
          elseif spell_name == "Pyroblast" then
              effect_extra_str = " (incl: ignite & pyro dot)";
          else
              effect_extra_str = " (incl: ignite )";
          end
      else
          if spell_name == "Fireball" then
              effect_extra_str = " (excl: fireball dot)";
          elseif spell_name == "Pyroblast" then
              effect_extra_str = " (incl: pyro dot)";
          elseif spell.over_time > 0 and eval.spell_data.expectation ~= eval.spell_data.ot then
              effect_extra_str = "(incl: over time)";
          end
      end
      if loadout.natures_grace and loadout.natures_grace ~= 0 and eval.spell_data.cast_time > 1.5 then
          effect_extra_str = " (incl: nature's grace)";
      end

      if spell_name == "Prayer of Healing" or spell_name == "Chain Heal" or spell_name == "Tranquility" then
          effect_extra_str = " (incl: full aoe effect)";
      elseif bit.band(spell.flags, spell_flags.aoe) ~= 0 and 
              eval.spell_data.expectation == eval.spell_data.expectation_st then

          effect_extra_str = "(incl: single target)";
      end


      tooltip:AddLine("  Expected "..effect..string.format(": %.1f ",eval.spell_data.expectation)..effect_extra_str);

      if eval.spell_data.base_min ~= 0.0 and eval.spell_data.expectation ~=  eval.spell_data.expectation_st then

        tooltip:AddLine("  Expected "..effect..string.format(": %.1f",eval.spell_data.expectation_st).." (incl: single target)");
      end

      tooltip:AddLine(string.format("  %s: %.1f", 
                                    effect_per_sec,
                                    eval.spell_data.effect_per_sec));
      tooltip:AddLine("  "..effect_per_cost..": "..string.format("%.1f",eval.spell_data.effect_per_cost), 0.0, 1.0, 1.0);
      tooltip:AddLine("  "..cost_per_sec..": "..string.format("%.1f",eval.spell_data.cost_per_sec), 0.0, 1.0, 1.0);
      tooltip:AddLine("  "..effect_per_sp..": "..string.format("%.1f",eval.dmg_per_sp), 0.0, 1.0, 0.0);
      tooltip:AddLine("  "..sp_name.." per 1% crit: "..string.format("%.1f",eval.sp_per_crit), 0.0, 1.0, 0.0);

      if (bit.band(spell.flags, spell_flags.heal) == 0 and bit.band(spell.flags, spell_flags.absorb) == 0) then
          tooltip:AddLine("  "..sp_name.." per 1%  hit: "..string.format("%.1f",eval.sp_per_hit), 0.0, 1.0, 0.0);
      end

      -- debug tooltip stuff
      if __sw__debug__ then
          tooltip:AddLine("  ".."Base "..effect..": "..spell.base_min.."-"..spell.base_max,
                          1.0, 1.0, 1.0);
          tooltip:AddLine("  ".."Cost: "..eval.spell_data.mana, 1.0, 1.0, 1.0);
          tooltip:AddLine(string.format("  Coef: %.3f, %.3f", direct_coef, ot_coef), 1.0, 1.0, 1.0);
      end

      end_tooltip_section(tooltip);

      if spell.healing_version then
          -- used for holy nova
          tooltip_spell_info(tooltip, spell.healing_version, spell_name, loadout);
      end
    end
end

function spell_diff(spell_id, spell_name, loadout, diff)

    local spell_data = get_spell(spell_id);

    local loadout_diffed = loadout_add(loadout, diff);

    local expectation_loadout = evaluate_spell(spell_data, spell_name, loadout);
    local expectation_loadout_diffed = evaluate_spell(spell_data, spell_name, loadout_diffed);
    
    return {
        expectation = expectation_loadout_diffed.spell_data.expectation - 
            expectation_loadout.spell_data.expectation,
        effect_per_sec = expectation_loadout_diffed.spell_data.effect_per_sec - 
            expectation_loadout.spell_data.effect_per_sec,
    };
end

local function loadout_by_item_tooltip()

    local loadout = empty_loadout();
    loadout.name = "Single item loadout - Primary";

    for i = 1, GameTooltip:NumLines() do

        repeat 
            line = getfenv()["GameTooltipTextLeft"..i]:GetText();

            local stat_val = string.match(line, "%d+");
            -- attribute like int and + spell dmg from green items

            local attribute_basic = string.match(line, "[+-]%d+ .*");
            local attribute_sp = string.match(line, "Equip: .* by .*");

            local val = tonumber(stat_val);

            if stat_val then
                if string.sub(stat_val, 1, 1) == "-" then
                    val = -val;
                end
            else
                do break end; -- scuffed continue
            end

            if attribute_basic then
                -- check for negative stats
                
                if string.match(attribute_basic, "Intellect") then
                    loadout.int = loadout.int + val;
                elseif string.match(attribute_basic, "Spirit") then
                    loadout.spirit = loadout.spirit + val;
                elseif string.match(attribute_basic, "Holy Spell Damage") then
                    loadout.spelldmg_by_school[2] = loadout.spelldmg_by_school[2] + val;
                elseif string.match(attribute_basic, "Fire Spell Damage") then
                    loadout.spelldmg_by_school[3] = loadout.spelldmg_by_school[3] + val;
                elseif string.match(attribute_basic, "Nature Spell Damage") then
                    loadout.spelldmg_by_school[4] = loadout.spelldmg_by_school[4] + val;
                elseif string.match(attribute_basic, "Frost Spell Damage") then
                    loadout.spelldmg_by_school[5] = loadout.spelldmg_by_school[5] + val;
                elseif string.match(attribute_basic, "Shadow Spell Damage") then
                    loadout.spelldmg_by_school[6] = loadout.spelldmg_by_school[6] + val;
                elseif string.match(attribute_basic, "Arcane Spell Damage") then
                    loadout.spelldmg_by_school[7] = loadout.spelldmg_by_school[7] + val;
                end
                do break end; -- scuffed continue
            end

            if attribute_sp then
                if string.match(attribute_sp, "damage and healing done by magical spells and") then
                    for i = 1, 7 do
                        loadout.spelldmg_by_school[i] = loadout.spelldmg_by_school[i] + val;
                    end
                    loadout.healingpower = loadout.healingpower + val;
                elseif string.match(attribute_sp, "Increases healing done by spells and") then
                    loadout.healingpower = loadout.healingpower + val;
                elseif string.match(attribute_sp, "Increases damage done by Holy spells and") then
                    loadout.spelldmg_by_school[2] = loadout.spelldmg_by_school[2] + val;
                elseif string.match(attribute_sp, "Increases damage done by Fire spells and") then
                    loadout.spelldmg_by_school[3] = loadout.spelldmg_by_school[3] + val;
                elseif string.match(attribute_sp, "Increases damage done by Nature spells and") then
                    loadout.spelldmg_by_school[4] = loadout.spelldmg_by_school[4] + val;
                elseif string.match(attribute_sp, "Increases damage done by Frost spells and") then
                    loadout.spelldmg_by_school[5] = loadout.spelldmg_by_school[5] + val;
                elseif string.match(attribute_sp, "Increases damage done by Shadow spells and") then
                    loadout.spelldmg_by_school[6] = loadout.spelldmg_by_school[6] + val;
                elseif string.match(attribute_sp, "Increases damage done by Arcane spells and") then
                    loadout.spelldmg_by_school[7] = loadout.spelldmg_by_school[7] + val;
                elseif string.match(attribute_sp, "Improves your chance to hit with spells by") then
                    for i = 1, 7 do
                        loadout.spelldmg_hit_by_school[i] = loadout.spelldmg_hit_by_school[i] + val * 0.01;
                    end
                elseif string.match(attribute_sp, "Improves your chance to get a critical strike with spells by") then
                    for i = 1, 7 do
                        loadout.spell_crit_by_school[i] = loadout.spell_crit_by_school[i] + val * 0.01;
                        loadout.healing_crit = loadout.healing_crit + val * 0.01;
                    end
                end
                do break end; -- scuffed continue
            end

        until true

    end

    return loadout;
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

local function update_and_display_spell_diffs(frame)

    frame.line_y_offset = frame.line_y_offset_before_dynamic_spells;

    local loadout = current_loadout();

    local loadout_diff = create_loadout_from_ui_diff(frame);

    for k, v in pairs(frame.spells) do

        local diff = spell_diff(k, v.name, loadout, loadout_diff);

        frame.line_y_offset = ui_y_offset_incr(frame.line_y_offset);

        if not v.name_str then
            v.name_str = frame:CreateFontString(nil, "OVERLAY");
            v.name_str:SetFontObject(font);

            v.expectation = frame:CreateFontString(nil, "OVERLAY");
            v.expectation:SetFontObject(font);

            v.effect_per_sec = frame:CreateFontString(nil, "OVERLAY");
            v.effect_per_sec:SetFontObject(font);

            v.cancel_button = CreateFrame("Button", "button", frame, "UIPanelButtonTemplate"); 
        end

        v.name_str:SetPoint("TOPLEFT", 15, frame.line_y_offset);
        v.name_str:SetText(v.name.." (Rank "..spells[k].rank..")");
        v.name_str:SetTextColor(222/255, 192/255, 40/255);

        if not frame.is_valid then

            v.expectation:SetPoint("TOPRIGHT", -115, frame.line_y_offset);
            v.expectation:SetText("NAN");

            v.effect_per_sec:SetPoint("TOPRIGHT", -45, frame.line_y_offset);
            v.effect_per_sec:SetText("NAN");
            
        else

            local expectation_diff = tonumber(diff.expectation);

            v.expectation:SetPoint("TOPRIGHT", -115, frame.line_y_offset);
            v.effect_per_sec:SetPoint("TOPRIGHT", -45, frame.line_y_offset);

            if expectation_diff < 0 then
                v.expectation:SetText(string.format("%.2f", expectation_diff));
                v.expectation:SetTextColor(195/255, 44/255, 11/255);

                v.effect_per_sec:SetText(string.format("%.2f", tostring(diff.effect_per_sec)));
                v.effect_per_sec:SetTextColor(195/255, 44/255, 11/255);

            elseif expectation_diff > 0 then
                v.expectation:SetText(string.format("+%.2f", expectation_diff));
                v.expectation:SetTextColor(33/255, 185/255, 21/255);

                v.effect_per_sec:SetText(string.format("+%.2f", tostring(diff.effect_per_sec)));
                v.effect_per_sec:SetTextColor(33/255, 185/255, 21/255);

            else
                v.expectation:SetText("0");
                v.expectation:SetTextColor(1, 1, 1);

                v.effect_per_sec:SetText("0");
                v.effect_per_sec:SetTextColor(1, 1, 1);

            end
                
            v.cancel_button:SetScript("OnClick", function()

                v.name_str:Hide();
                v.expectation:Hide();
                v.effect_per_sec:Hide();
                v.cancel_button:Hide();

                frame.spells[k] = nil; -- remove this spell
                update_and_display_spell_diffs(frame);

            end);

            v.cancel_button:SetPoint("TOPRIGHT", -10, frame.line_y_offset + 3);
            v.cancel_button:SetHeight(20);
            v.cancel_button:SetWidth(25);
            v.cancel_button:SetText("X");
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

    sw_frame:SetWidth(320);
    sw_frame:SetHeight(500);
    sw_frame:SetPoint("RIGHT", SpellBookFrame, "RIGHT", 340, 20);

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

    sw_frame.line_y_offset = -35;

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
        v.editbox:SetScript("OnTextChanged", function()

            update_and_display_spell_diffs(sw_frame);
        end);

        v.editbox:SetScript("OnEnterPressed", function(self)

        	self:ClearFocus()
        end)
        
        v.editbox:SetScript("OnEscapePressed", function(self)
        	self:ClearFocus()
        end)

        v.editbox:SetScript("OnTabPressed", function(self)
            local next_index = 1 + (i %num_stats);
        	self:ClearFocus()
            sw_frame.stats[next_index].editbox:SetFocus();
        end)
    end

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
    sw_frame.spell_diff_header_center:SetPoint("TOPRIGHT", -115, sw_frame.line_y_offset);
    sw_frame.spell_diff_header_center:SetText("Expected");

    sw_frame.spell_diff_header_left = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.spell_diff_header_left:SetFontObject(font);
    sw_frame.spell_diff_header_left:SetPoint("TOPRIGHT", -45, sw_frame.line_y_offset);
    sw_frame.spell_diff_header_left:SetText("Per sec");

    -- always have at least one
    sw_frame.spells = {};

    if UnitLevel("player") == 60 then
        local _, class = UnitClass("player");

        if class == "MAGE" then
            sw_frame.spells[10181] = {
                name = "Frostbolt";
            };
        elseif class == "DRUID" then

            sw_frame.spells[25297] = {
                name = "Healing Touch";
            };
            sw_frame.spells[9876] = {
                name = "Starfire";
            };

        elseif class == "PALADIN" then

            sw_frame.spells[19943] = {
                name = "Flash of Light";
            };
        elseif class == "SHAMAN" then

            sw_frame.spells[10396] = {
                name = "Healing Wave";
            };
            sw_frame.spells[15208] = {
                name = "Lightning Bolt";
            };
        elseif class == "PRIEST" then

            sw_frame.spells[25314] = {
                name = "Greater Heal";
            };
            sw_frame.spells[25315] = {
                name = "Renew";
            };
        end
    end

    sw_frame:Hide();
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

ItemRefTooltip:HookScript("OnTooltipSetItem", function(tooltip, ...)
  --local name, link = tooltip:GetItem();
  --print("Itemref: Hovering Item", name, link);
end)

GameTooltip:HookScript("OnTooltipSetItem", function(tooltip, ...)
    
    --local name, link = tooltip:GetItem();
    --print("Gametooltip : Hovering Item");

    --item_loadout = loadout_by_item_tooltip();

    ----print_loadout(item_loadout);
    ---- add tooltip loadout to current loadout
    --before = current_loadout();
    --after = loadout_add(before, item_loadout);

    --diff = diff_spell(10181, before, after);

    --print("--------------------------------------");
    --print("diff on item using frostbolt10");
    --print("delta - expectation:" ,  diff.expectation, "effect_per_sec:", diff.effect_per_sec);
end)

GameTooltip:HookScript("OnTooltipSetSpell", function(tooltip, ...)

    local spell_name, spell_id = tooltip:GetSpell();

    local spell = get_spell(spell_id);

    local loadout = current_loadout();

    --local spell_name, _ = GetSpellInfo(spell_id);

    --print_spell(spell, spell_name, loadout);
    tooltip_spell_info(GameTooltip, spell, spell_name, loadout);

    if spell and IsShiftKeyDown() and sw_frame:IsShown() and not sw_frame.spells[spell_id]then
        sw_frame.spells[spell_id] = {
            name = spell_name,
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

