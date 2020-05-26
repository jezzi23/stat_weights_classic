
--MIT License
--
--Copyright (c) Stat Weights Classic
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

local sw_addon_name = "Stat Weights Classic";
local version =  "1.2.5";

local sw_addon_loaded = false;

local libstub_data_broker = LibStub("LibDataBroker-1.1", true)
local libstub_icon = libstub_data_broker and LibStub("LibDBIcon-1.0", true)

local font = "GameFontHighlightSmall";
local icon_overlay_font = "Interface\\AddOns\\stat_weights_classic\\fonts\\Oswald-Bold.ttf";

local action_bar_addon_name = nil;
local spell_book_addon_name = nil;

local _, class = UnitClass("player");
local _, race = UnitRace("player");
local faction, _ = UnitFactionGroup("player");

sw_snapshot_loadout_update_freq = 1;
sw_num_icon_overlay_fields_active = 0;

local function class_supported()
    return class == "MAGE" or class == "PRIEST" or class == "WARLOCK" or
       class == "SHAMAN" or class == "DRUID" or class == "PALADIN";
end

local class_is_supported = class_supported();

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

local buffs1 = {
    ony                         = { flag = bit.lshift(1,1),  id = 22888, name = "Ony/Nef"}, -- ok casters
    wcb                         = { flag = bit.lshift(1,2),  id = 16609, name = "WCB"}, 
    songflower                  = { flag = bit.lshift(1,3),  id = 15366, name = "Songflower"}, -- ok casters
    spirit_of_zandalar          = { flag = bit.lshift(1,4),  id = 24425, name = "Spirit of Zandalar"}, -- ok
    greater_arcane_elixir       = { flag = bit.lshift(1,5),  id = 17539, name = "Greater Arcane Elixir"}, --ok
    elixir_of_greater_firepower = { flag = bit.lshift(1,6),  id = 26276, name = "Elixir of Greater Firepower"}, --ok
    elixir_of_shadow_power      = { flag = bit.lshift(1,7),  id = 11474, name = "Elixir of Shadow power"}, --ok
    elixir_of_frost_power       = { flag = bit.lshift(1,8),  id = 21920, name = "Elixir of Frost Power"}, --ok
    runn_tum_tuber_surprise     = { flag = bit.lshift(1,9),  id = 22730, name = "10 Intellect Food"}, --ok
    power_infusion              = { flag = bit.lshift(1,10), id = 10060, name = "Power Infusion"},-- ok
    arcane_power                = { flag = bit.lshift(1,11), id = 12042, name = "Arcane Power"},-- ok
    int                         = { flag = bit.lshift(1,12), id = 10157, name = "Arcane Intellect"}, --ok
    int_aoe                     = { flag = bit.lshift(1,12), id = 23028, name = "Arcane Brilliance"}, --ok
    motw                        = { flag = bit.lshift(1,13), id = 24752, name = "Mark of the Wild"}, --ok
    motw_aoe                    = { flag = bit.lshift(1,13), id = 21850, name = "Gift of the Wild"}, --ok
    spirit                      = { flag = bit.lshift(1,14), id = 27841, name = "Divine Spirit"}, --ok
    spirit_aoe                  = { flag = bit.lshift(1,14), id = 27681, name = "Prayer Spirit"}, --ok
    mind_quickening_gem         = { flag = bit.lshift(1,15), id = 23723, name = "Mind Quickening Gem"},-- ok
    dmf_dmg                     = { flag = bit.lshift(1,16), id = 23768, name = "DMF Damage"},-- ok
    dmt_crit                    = { flag = bit.lshift(1,17), id = 22820, name = "DMT Spell Crit"},-- ok
    dmt_ap                      = { flag = bit.lshift(1,18), id = 22817, name = "DMT Attack Power"},
    dmt_hp                      = { flag = bit.lshift(1,19), id = 22818, name = "DMT HP"},
    hazzrahs_charm_of_magic     = { flag = bit.lshift(1,20), id = 24544, name = "Hazza'rah'Charm"},-- ok
    hazzrahs_charm_of_destr     = { flag = bit.lshift(1,21), id = 24544, name = "Hazza'rah'Charm"},-- ok
    amplify_curse               = { flag = bit.lshift(1,22), id = 18288, name = "Amplify Curse"},-- ok
    demonic_sacrifice           = { flag = bit.lshift(1,23), id = 18791, name = "Demonic Sacrifice (Succ)"},-- ok
    hazzrahs_charm_of_healing   = { flag = bit.lshift(1,24), id = 24546, name = "Hazza'rah'Charmof Healing"},-- ok
    shadow_form                 = { flag = bit.lshift(1,25), id = 15473, name = "Shadow Form"},-- ok
    wushoolays_charm_of_spirits = { flag = bit.lshift(1,26), id = 24499, name = "Wushoolay's Charm"},-- ok
    wushoolays_charm_of_nature  = { flag = bit.lshift(1,27), id = 24542, name = "Wushoolay's Charm"},-- ok
    -- TODO: spell ids for rogue/warr ambigious on wowhead, the following 2 are wrong
    berserking_rogue            = { flag = bit.lshift(1,28), id = 26297, name = "Berserking (Troll)"},
    berserking_warrior          = { flag = bit.lshift(1,29), id = 26296, name = "Berserking (Troll)"},
    berserking                  = { flag = bit.lshift(1,30), id = 26635, name = "Berserking (Troll)"}, -- ok casters
    toep                        = { flag = bit.lshift(1,31), id = 23271, name = "TOEP trinket"} -- ok casters
    --grileks_charm_of_valor      = { flag = bit.lshift(1,32), id = 24498, name = "Gri'lek's Charm of Valor"} -- ok casters
};

local buffs2 = {
    zandalarian_hero_charm      = { flag = bit.lshift(1,1),  id = 24658, name = "Zandalarian Hero Charm"}, --ok casters
    bok                         = { flag = bit.lshift(1,2),  id = 20217, name = "Blessing of Kings"}, --ok
    vengeance                   = { flag = bit.lshift(1,3),  id = 20059, name = "Vengeance"}, --ok
    natural_alignment_crystal   = { flag = bit.lshift(1,4),  id = 23734, name = "Natural Alignment Crystal"}, --ok
    blessed_prayer_beads        = { flag = bit.lshift(1,5),  id = 24354, name = "Blessed Prayer Beads"}, --ok
    troll_vs_beast              = { flag = bit.lshift(1,6),  id = 0,     name = "Beast Slaying (Trolls)"}, --ok
    flask_of_supreme_power      = { flag = bit.lshift(1,7),  id = 17628, name = "Flask of Supreme Power"}, --ok
    nightfin                    = { flag = bit.lshift(1,8),  id = 18233, name = "Nightfin Soup"}, --ok
    mage_armor                  = { flag = bit.lshift(1,9),  id = 22783, name = "Mage Armor"}, --ok
    flask_of_distilled_wisdom   = { flag = bit.lshift(1,10), id = 17627, name = "Flask of Distilled Wisdom"}, --ok
    bow                         = { flag = bit.lshift(1,11), id = 25290, name = "Blessing of Wisdom"} --ok
};

local target_buffs1 = {
    amplify_magic               = { flag = bit.lshift(1,1), id = 10170, name = "Amplify Magic"}, --ok
    dampen_magic                = { flag = bit.lshift(1,2), id = 10174, name = "Dampen Magic"}, --ok
    blessing_of_light           = { flag = bit.lshift(1,3), id = 19979, name = "Blessing of Light"}, --ok
    healing_way                 = { flag = bit.lshift(1,4), id = 29203, name = "Healing Way"} --ok
};

local target_debuffs1 = {
    curse_of_the_elements       = { flag = bit.lshift(1,1), id = 11722, name = "Curse of the Elements"}, -- ok casters
    wc                          = { flag = bit.lshift(1,2), id = 12579, name = "Winter's Chill"}, -- ok casters
    nightfall                   = { flag = bit.lshift(1,3), id = 23605, name = "Nightfall"}, -- ok casters
    improved_scorch             = { flag = bit.lshift(1,4), id = 22959, name = "Improved Scorch"}, -- ok casters
    improved_shadow_bolt        = { flag = bit.lshift(1,5), id = 17800, name = "Improved Shadow Bolt"}, -- ok casters
    shadow_weaving              = { flag = bit.lshift(1,6), id = 15258, name = "Shadow Weaving"}, -- ok casters
    stormstrike                 = { flag = bit.lshift(1,7), id = 17364, name = "Stormstrike"}, -- ok casters
    curse_of_shadow             = { flag = bit.lshift(1,8), id = 17937, name = "Curse of Shadow"}, -- ok casters
};

local stat_ids_in_ui = {
    int = 1,
    spirit = 2,
    mana = 3,
    mp5 = 4,
    sp = 5,
    spell_damage = 6,
    healing_power = 7,
    spell_crit = 8,
    spell_hit = 9
};

local icon_stat_display = {
    normal = bit.lshift(1,1),
    crit = bit.lshift(1,2),
    expected = bit.lshift(1,3),
    effect_per_sec = bit.lshift(1,4),
    effect_per_cost = bit.lshift(1,5),
    avg_cost = bit.lshift(1,6),
    avg_cast = bit.lshift(1,7),
    hit = bit.lshift(1,8),
    crit_chance = bit.lshift(1,9),
    casts_until_oom = bit.lshift(1,10),
    effect_until_oom = bit.lshift(1,11),
    time_until_oom = bit.lshift(1,12),

    show_heal_variant = bit.lshift(1,20)
};

local tooltip_stat_display = {
    normal = bit.lshift(1,1),
    crit = bit.lshift(1,2),
    ot = bit.lshift(1,3),
    ot_crit = bit.lshift(1,4),
    expected = bit.lshift(1,5),
    effect_per_sec = bit.lshift(1,6),
    effect_per_cost = bit.lshift(1,7),
    cost_per_sec = bit.lshift(1,8),
    stat_weights = bit.lshift(1,9),
    coef = bit.lshift(1,10),
    avg_cost = bit.lshift(1,11),
    avg_cast = bit.lshift(1,12),
    race_to_the_bottom = bit.lshift(1,13),
    cast_and_tap = bit.lshift(1,14)
};

local simulation_type = {
    spam_cast = 1,
    race_to_the_bottom = 2
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
    ["Amplify Magic"]           = 1008,
    ["Dampen Magic"]            = 604,
    ["Arcane Intellect"]        = 1459,
    ["Arcane Brilliance"]       = 23028,
    ["Mage Armor"]              = 22783,
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
    ["Mark of the Wild"]        = 1126,
    ["Gift of the Wild"]        = 21849,
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
    ["Divine Spirit"]           = 14752,
    ["Prayer of Spirit"]        = 27681,
    ["Starshards"]              = 10797,
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
    ["Blessing of Light"]       = 19977,
    ["Vengeance"]               = 20049,
    ["Blessing of Wisdom"]      = 19742,
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
    ["Shadowburn"]              = 17877,
    ["Curse of the Elements"]   = 1490,
    ["Curse of Shadow"]         = 17937
};

local function create_spells()
    
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
                cost                = 25,
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
                cost                = 35,
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
                cost                = 50,
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
                cost                = 65,
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
                cost                = 100,
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
                cost                = 130,
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
                cost                = 160,
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
                cost                = 195,
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
                cost                = 225,
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
                cost                = 260,
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
                cost                = 290,
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
                cost                = 55,
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
                cost                = 85,
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
                cost                = 115,
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
                cost                = 145,
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
                cost                = 210,
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
                cost                = 290,
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
                cost                = 380,
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
                cost                = 465,
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
                cost                = 555,
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
                cost                = 320,
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
                cost                = 520,
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
                cost                = 720,
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
                cost                = 935,
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
                cost                = 1160,
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
                cost                = 1400,
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
                cost                = 30,
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
                cost                = 45,
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
                cost                = 65,
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
                cost                = 95,
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
                cost                = 140,
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
                cost                = 185,
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
                cost                = 220,
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
                cost                = 260,
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
                cost                = 305,
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
                cost                = 350,
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
                cost                = 395,
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
                cost                = 410,
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
                cost                = 40,
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
                cost                = 75,
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
                cost                = 115,
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
                cost                = 165,
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
                cost                = 220,
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
                cost                = 280,
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
                cost                = 340,
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
                cost                = 50,
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
                cost                = 65,
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
                cost                = 80,
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
                cost                = 100,
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
                cost                = 115,
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
                cost                = 135,
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
                cost                = 150,
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
                cost                = 125,
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
                cost                = 150,
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
                cost                = 195,
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
                cost                = 240,
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
                cost                = 285,
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
                cost                = 335,
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
                cost                = 385,
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
                cost                = 440,
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
                cost                = 215,
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
                cost                = 270,
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
                cost                = 355,
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
                cost                = 450,
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
                cost                = 545,
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
                cost                = 195,
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
                cost                = 330,
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
                cost                = 490,
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
                cost                = 650,
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
                cost                = 815,
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
                cost                = 990,
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
                cost                = 85,
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
                cost                = 140,
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
                cost                = 235,
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
                cost                = 320,
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
                cost                = 410,
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
                cost                = 500,
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
                cost                = 595,
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
                cost                = 635,
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
                cost                = 75,
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
                cost                = 120,
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
                cost                = 185,
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
                cost                = 250,
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
                cost                = 315,
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
                cost                = 390,
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
                cost                = 25,
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
                cost                = 55,
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
                cost                = 110,
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
                cost                = 185,
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
                cost                = 270,
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
                cost                = 335,
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
                cost                = 405,
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
                cost                = 495,
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
                cost                = 600,
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
                cost                = 720,
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
                cost                = 800,
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
                cost                = 25,
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
                cost                = 40,
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
                cost                = 75,
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
                cost                = 105,
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
                cost                = 135,
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
                cost                = 160,
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
                cost                = 195,
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
                cost                = 235,
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
                cost                = 280,
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
                cost                = 335,
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
                cost                = 360,
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
                cost                = 375,
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
                cost                = 505,
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
                cost                = 695,
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
                cost                = 925,
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
                cost                = 120,
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
                cost                = 205,
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
                cost                = 280,
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
                cost                = 350,
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
                cost                = 420,
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
                cost                = 510,
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
                cost                = 615,
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
                cost                = 740,
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
                cost                = 880,
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
                cost                = 25,
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
                cost                = 50,
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
                cost                = 75,
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
                cost                = 105,
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
                cost                = 150,
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
                cost                = 190,
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
                cost                = 235,
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
                cost                = 280,
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
                cost                = 325,
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
                cost                = 375,
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
                cost                = 20,
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
                cost                = 35,
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
                cost                = 55,
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
                cost                = 70,
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
                cost                = 100,
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
                cost                = 125,
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
                cost                = 155,
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
                cost                = 180,
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
                cost                = 95,
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
                cost                = 135,
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
                cost                = 180,
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
                cost                = 230,
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
                cost                = 275,
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
                cost                = 315,
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
                cost                = 340,
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
                cost                = 45,
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
                cost                = 85,
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
                cost                = 100,
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
                cost                = 140,
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
                cost                = 160,
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
                cost                = 880,
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
                cost                = 1180,
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
                cost                = 1495,
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
                cost                = 50,
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
                cost                = 65,
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
                cost                = 80,
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
                cost                = 95,
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
                cost                = 110,
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
                cost                = 125,
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
                cost                = 30,
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
                cost                = 45,
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
                cost                = 75,
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
                cost                = 155,
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
                cost                = 205,
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
                cost                = 255,
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
                cost                = 305,
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
                cost                = 370,
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
                cost                = 455,
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
                cost                = 545,
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
                cost                = 655,
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
                cost                = 710,
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
                cost                = 125,
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
                cost                = 155,
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
                cost                = 185,
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
                cost                = 215,
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
                cost                = 265,
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
                cost                = 315,
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
                cost                = 380,
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
                cost                = 410,
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
                cost                = 560,
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
                cost                = 770,
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
                cost                = 1030,
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
                cost                = 1070,
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
                cost                = 30,
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
                cost                = 65,
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
                cost                = 105,
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
                cost                = 140,
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
                cost                = 170,
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
                cost                = 205,
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
                cost                = 250,
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
                cost                = 305,
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
                cost                = 365,
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
                cost                = 410,
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
                cost                = 45,
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
                cost                = 80,
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
                cost                = 130,
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
                cost                = 175,
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
                cost                = 210,
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
                cost                = 250,
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
                cost                = 300,
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
                cost                = 355,
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
                cost                = 425,
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
                cost                = 500,
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
                cost                = 185,
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
                    cost                = 185,
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
                cost                = 290,
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
                    cost                = 290,
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
                cost                = 400,
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
                    cost                = 400,
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
                cost                = 520,
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
                    cost                = 520,
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
                cost                = 635,
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
                    cost                = 635,
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
                cost                = 750,
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
                    cost                = 750,
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
                cost                = 85,
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
                cost                = 95,
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
                cost                = 125,
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
                cost                = 145,
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
                cost                = 170,
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
                cost                = 200,
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
                cost                = 230,
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
                cost                = 255,
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
                cost                = 20,
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
                cost                = 30,
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
                cost                = 60,
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
                cost                = 95,
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
                cost                = 140,
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
                cost                = 185,
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
                cost                = 230,
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
                cost                = 280,
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
                cost                = 25,
                flags               = 0,
                school              = magic_school.shadow,
            },
            [594] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 66.0,
                over_time_tick_freq = 3,
                over_time_duration  = 18.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 10,
                cost                = 50,
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
                cost                = 95,
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
                cost                = 155,
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
                cost                = 230,
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
                cost                = 305,
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
                cost                = 385,
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
                cost                = 470,
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
                cost                = 50,
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
                cost                = 80,
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
                cost                = 110,
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
                cost                = 150,
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
                cost                = 185,
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
                cost                = 225,
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
                cost                = 265,
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
                cost                = 310,
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
                cost                = 350,
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
                cost                = 45,
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
                cost                = 70,
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
                cost                = 100,
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
                cost                = 135,
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
                cost                = 165,
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
                cost                = 205,
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
                cost                = 215,
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
                cost                = 350,
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
                cost                = 495,
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
                cost                = 645,
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
                cost                = 810,
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
                cost                = 985,
                flags               = 0,
                school              = magic_school.shadow,
            },
            -- starshards
            [10797] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 84.0,
                over_time_tick_freq = 1,
                over_time_duration  = 6.0,
                cast_time           = 6.0,
                rank                = 1,
                lvl_req             = 10,
                cost                = 50,
                flags               = 0,
                school              = magic_school.arcane,
            },
            [19296] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 162.0,
                over_time_tick_freq = 1,
                over_time_duration  = 6.0,
                cast_time           = 6.0,
                rank                = 2,
                lvl_req             = 18,
                cost                = 85,
                flags               = 0,
                school              = magic_school.arcane,
            },
            [19299] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 288.0,
                over_time_tick_freq = 1,
                over_time_duration  = 6.0,
                cast_time           = 6.0,
                rank                = 3,
                lvl_req             = 26,
                cost                = 140,
                flags               = 0,
                school              = magic_school.arcane,
            },
            [19302] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 414.0,
                over_time_tick_freq = 1,
                over_time_duration  = 6.0,
                cast_time           = 6.0,
                rank                = 4,
                lvl_req             = 34,
                cost                = 190,
                flags               = 0,
                school              = magic_school.arcane,
            },
            [19303] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 570.0,
                over_time_tick_freq = 1,
                over_time_duration  = 6.0,
                cast_time           = 6.0,
                rank                = 5,
                lvl_req             = 42,
                cost                = 245,
                flags               = 0,
                school              = magic_school.arcane,
            },
            [19304] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 756.0,
                over_time_tick_freq = 1,
                over_time_duration  = 6.0,
                cast_time           = 6.0,
                rank                = 6,
                lvl_req             = 50,
                cost                = 300,
                flags               = 0,
                school              = magic_school.arcane,
            },
            [19305] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 936.0,
                over_time_tick_freq = 1,
                over_time_duration  = 6.0,
                cast_time           = 6.0,
                rank                = 7,
                lvl_req             = 58,
                cost                = 350,
                flags               = 0,
                school              = magic_school.arcane,
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
                cost                = 40,
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
                cost                = 50,
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
                cost                = 60,
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
                cost                = 70,
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
                cost                = 80,
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
                cost                = 105,
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
                cost                = 145,
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
                cost                = 185,
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
                cost                = 235,
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
                cost                = 305,
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
                cost                = 380,
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
                cost                = 25,
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
                cost                = 45,
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
                cost                = 80,
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
                cost                = 155,
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
                cost                = 200,
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
                cost                = 265,
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
                cost                = 340,
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
                cost                = 440,
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
                cost                = 560,
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
                cost                = 620,
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
                cost                = 260,
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
                cost                = 315,
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
                cost                = 405,
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
                cost                = 15,
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
                cost                = 30,
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
                cost                = 45,
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
                cost                = 75,
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
                cost                = 105,
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
                cost                = 135,
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
                cost                = 165,
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
                cost                = 195,
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
                cost                = 230,
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
                cost                = 265,
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
                cost                = 280,
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
                cost                = 380,
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
                cost                = 490,
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
                cost                = 605,
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
                cost                = 45,
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
                cost                = 80,
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
                cost                = 125,
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
                cost                = 180,
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
                cost                = 240,
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
                cost                = 305,
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
                cost                = 370,
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
                cost                = 30,
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
                cost                = 50,
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
                cost                = 85,
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
                cost                = 145,
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
                cost                = 240,
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
                cost                = 345,
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
                cost                = 450,
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
                cost                = 230,
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
                cost                = 360,
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
                cost                = 500,
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
                cost                = 650,
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
                cost                = 55,
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
                cost                = 95,
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
                cost                = 160,
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
                cost                = 250,
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
                cost                = 345,
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
                cost                = 410,
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
                cost                = 115,
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
                cost                = 225,
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
                cost                = 325,
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
                cost                = 430,
                flags               = spell_flags.snare,
                school              = magic_school.frost,
            },
            -- searing totem
            [3599] = {
                base_min            = 9.0,
                base_max            = 11.0,
                over_time           = 0,
                over_time_tick_freq = 2.5,
                over_time_duration  = 30,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 10, 
                cost                = 25,
                flags               = 0,
                school              = magic_school.fire
            },
            [6363] = {
                base_min            = 13.0,
                base_max            = 17.0,
                over_time           = 0,
                over_time_tick_freq = 2.5,
                over_time_duration  = 35,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 20, 
                cost                = 45,
                flags               = 0,
                school              = magic_school.fire
            },
            [6364] = {
                base_min            = 19.0,
                base_max            = 25.0,
                over_time           = 0,
                over_time_tick_freq = 2.5,
                over_time_duration  = 40,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 30, 
                cost                = 75,
                flags               = 0,
                school              = magic_school.fire
            },
            [6365] = {
                base_min            = 26.0,
                base_max            = 34.0,
                over_time           = 0,
                over_time_tick_freq = 2.5,
                over_time_duration  = 45,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 40, 
                cost                = 110,
                flags               = 0,
                school              = magic_school.fire
            },
            [10437] = {
                base_min            = 33.0,
                base_max            = 45.0,
                over_time           = 0,
                over_time_tick_freq = 2.5,
                over_time_duration  = 50,
                cast_time           = 1.5,
                rank                = 5,
                lvl_req             = 50, 
                cost                = 145,
                flags               = 0,
                school              = magic_school.fire
            },
            [10438] = {
                base_min            = 40.0,
                base_max            = 54.0,
                over_time           = 0,
                over_time_tick_freq = 2.5,
                over_time_duration  = 55,
                cast_time           = 1.5,
                rank                = 6,
                lvl_req             = 60, 
                cost                = 170,
                flags               = 0,
                school              = magic_school.fire
            },
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
                cost                = 95,
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
                cost                = 170,
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
                cost                = 280,
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
                cost                = 395,
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
                cost                = 520,
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
                cost                = 35,
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
                cost                = 50,
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
                cost                = 70,
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
                cost                = 90,
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
                cost                = 115,
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
                cost                = 140,
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
                cost                = 35,
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
                cost                = 60,
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
                cost                = 110,
                flags               = spell_flags.heal,
                school              = magic_school.holy
            },
            [1026] = {
                base_min            = 322.0,
                base_max            = 368.0, 
                over_time           = 0,
                over_time_tick_freq = 0,
                over_time_duration  = 0.0,
                cast_time           = 2.5,
                rank                = 4,
                lvl_req             = 22,
                cost                = 190,
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
                cost                = 275,
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
                cost                = 365,
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
                cost                = 465,
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
                cost                = 580,
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
                cost                = 660,
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
                cost                = 225,
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
                    cost                = 225,
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
                cost                = 275,
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
                    cost                = 275,
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
                cost                = 325,
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
                    cost                = 325,
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
                cost                = 295,
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
                cost                = 360,
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
                cost                = 425,
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
                cost                = 135,
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
                cost                = 235,
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
                cost                = 320,
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
                cost                = 435,
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
                cost                = 565,
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
                cost                = 85,
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
                cost                = 135,
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
                cost                = 180,
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
                cost                = 235,
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
                cost                = 285,
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
                cost                = 345,
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
                cost                = 645,
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
                cost                = 805,
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
                cost                = 25,
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
                cost                = 50,
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
                cost                = 90,
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
                cost                = 130,
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
                cost                = 170,
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
                cost                = 215,
                flags               = 0,
                school              = magic_school.shadow
            },
            -- siphon life
            [18265] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 150,
                over_time_tick_freq = 3,
                over_time_duration  = 30.0,
                cast_time           = 1.5,
                rank                = 1,
                lvl_req             = 30,
                cost                = 150,
                flags               = 0,
                school              = magic_school.shadow
            },
            [18879] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 220,
                over_time_tick_freq = 3,
                over_time_duration  = 30.0,
                cast_time           = 1.5,
                rank                = 2,
                lvl_req             = 38,
                cost                = 205,
                flags               = 0,
                school              = magic_school.shadow
            },
            [18880] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 330,
                over_time_tick_freq = 3,
                over_time_duration  = 30.0,
                cast_time           = 1.5,
                rank                = 3,
                lvl_req             = 48,
                cost                = 285,
                flags               = 0,
                school              = magic_school.shadow
            },
            [18881] = {
                base_min            = 0.0,
                base_max            = 0.0, 
                over_time           = 450,
                over_time_tick_freq = 3,
                over_time_duration  = 30.0,
                cast_time           = 1.5,
                rank                = 4,
                lvl_req             = 58,
                cost                = 365,
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
                cost                = 430,
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
                cost                = 495,
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
                cost                = 565,
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
                cost                = 35,
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
                cost                = 55,
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
                cost                = 100,
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
                cost                = 160,
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
                cost                = 225,
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
                cost                = 290,
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
                cost                = 340,
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
                cost                = 55,
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
                cost                = 85,
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
                cost                = 135,
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
                cost                = 185,
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
                cost                = 240,
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
                cost                = 300,
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
                cost                = 55,
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
                cost                = 125,
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
                cost                = 210,
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
                cost                = 290,
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
                cost                = 25,
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
                cost                = 40,
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
                cost                = 70,
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
                cost                = 110,
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
                cost                = 160,
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
                cost                = 210,
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
                cost                = 265,
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
                cost                = 315,
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
                cost                = 370,
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
                cost                = 380,
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
                cost                = 45,
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
                cost                = 68,
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
                cost                = 91,
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
                cost                = 118,
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
                cost                = 141,
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
                cost                = 168,
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
                cost                = 305,
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
                cost                = 335,
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
                cost                = 645,
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
                cost                = 975,
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
                cost                = 1300,
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
                cost                = 295,
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
                cost                = 605,
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
                cost                = 885,
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
                cost                = 1185,
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
                cost                = 25,
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
                cost                = 45,
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
                cost                = 90,
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
                cost                = 155,
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
                cost                = 220,
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
                cost                = 295,
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
                cost                = 370,
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
                cost                = 380,
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
                cost                = 105,
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
                cost                = 103,
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
                cost                = 190,
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
                cost                = 245,
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
                cost                = 305,
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
                cost                = 365, 
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
                cost                = 165, 
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
                cost                = 200, 
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
                cost                = 230, 
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
                cost                = 255, 
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

local function wowhead_talent_link(code)
    local lowercase_class = string.lower(class);
    return "https://classic.wowhead.com/talent-calc/"..lowercase_class.."/"..code;
end

local function wowhead_talent_code_from_url(link)

    local last_slash_index = 1;
    local i = 1;

    while link:sub(i, i) ~= "" do
        if link:sub(i, i) == "/" then
            last_slash_index = i;
        end
        i = i + 1;
    end
    return link:sub(last_slash_index + 1, i);
end

local function wowhead_talent_code()

    local sub_codes = {"", "", ""};
    for i = 1, 3 do

        local found_max = false;
        for j = 1, 20 do

            local _, _, _, _, pts, _, _, _ = GetTalentInfo(i, 20-j + 1);
            if pts and pts ~= 0 then
                found_max = true;
            end
            if found_max then
                sub_codes[i] = tostring(pts)..sub_codes[i];
            end
        end
    end
    if sub_codes[2] == "" and sub_codes[3] == "" then
        return sub_codes[1];
    elseif sub_codes[2] == "" then
        return sub_codes[1].."--"..sub_codes[3];
    elseif sub_codes[3] == "" then
        return sub_codes[1].."-"..sub_codes[2];
    else
        return sub_codes[1].."-"..sub_codes[2].."-"..sub_codes[3];
    end
end

local function talent_table(wowhead_code)

    local talents = {{}, {}, {}};

    local i = 1;
    local tree_index = 1;
    local talent_index = 1;

    while wowhead_code:sub(i, i) ~= "" do
        if wowhead_code:sub(i, i) == "-" then
            tree_index = tree_index + 1;
            talent_index = 1;
        elseif tonumber(wowhead_code:sub(i, i)) then
            talents[tree_index][talent_index] = tonumber(wowhead_code:sub(i, i));

            talent_index = talent_index + 1;
        end
        i = i + 1;
    end

    talents.pts = function(this, tree_index, talent_index)
        if this[tree_index][talent_index] then
            return this[tree_index][talent_index];
        else
            return 0;
        end
    end;
    return talents;
end

local function empty_loadout()

    return {
        name = "Empty";
        is_dynamic_loadout = true,
        talents_code = "",
        always_assume_buffs = true,
        lvl = 0,
        target_lvl = 0,
        use_dynamic_target_lvl = true,
        has_target = false; 

        stats = {0, 0, 0, 0, 0},
        mana = 0,
        extra_mana = 0,
        mp5 = 0,
        regen_while_casting = 0,
        mana_mod = 0,

        spell_dmg_by_school = {0, 0, 0, 0, 0, 0, 0},
        healing_power = 0,

        spell_crit_by_school = {0, 0, 0, 0, 0, 0, 0},
        healing_crit = 0,

        spell_dmg_hit_by_school = {0, 0, 0, 0, 0, 0, 0},
        spell_dmg_mod_by_school = {0, 0, 0, 0, 0, 0, 0},
        spell_crit_mod_by_school = {0, 0, 0, 0, 0, 0, 0},
        target_spell_dmg_taken = {0, 0, 0, 0, 0, 0, 0},

        spell_heal_mod_base = 0,
        spell_heal_mod = 0,

        dmg_mod = 0,
        target_mod_res_by_school = {0, 0, 0, 0, 0, 0, 0},

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
        ability_base_mod = {},
        ability_effect_mod = {},
        ability_cast_mod = {},
        ability_extra_ticks = {},
        ability_cost_mod = {},
        ability_crit_mod = {},
        ability_hit = {},
        ability_sp = {},
        ability_flat_add = {},

        target_friendly = false,
        target_type = "",

        buffs = {},
        target_buffs = {},
        target_debuffs = {},
        buffs1 = 0,
        buffs2 = 0,
        target_buffs1 = 0,
        target_debuffs1 = 0
    };
end

-- add things to loadout that a loadout is assumed to have but don't due to an older version of a loadout
local function satisfy_loadout(loadout)

    if not loadout.mp5 then
        loadout.mp5 = 0;
    end
    if not loadout.regen_while_casting then
        loadout.regen_while_casting = 0;
    end
    if not loadout.mana then
        loadout.mana = 0;
    end
    if not loadout.extra_mana then
        loadout.extra_mana = 0;
    end
    if not loadout.mana_mod then
        loadout.mana_mod = 0;
    end
    if not loadout.ability_flat_add then
        loadout.ability_flat_add = {};
    end
    if not loadout.talents_code then
        loadout.talents_code = wowhead_talent_code();
    end
end


local function negate_loadout(loadout)

    local negated = loadout;

    for i = 1, 5 do
        negated.stats[i] = -loadout.negated.stats[i];
    end
    negated.mp5 = -loadout.negated.mp5;
    negated.mana = -loadout.negated.mana;

    for i = 1, 7 do
        negated.spell_dmg_by_school[i] = -loadout.spell_dmg_by_school[i];
    end
    negated.healing_power = -loadout.healing_power;

    for i = 1, 7 do
        negated.spell_crit_by_school[i] = -loadout.spell_crit_by_school[i];
    end
    negated.healing_crit = -loadout.healing_crit;

    for i = 1, 7 do
        negated.spell_dmg_hit_by_school[i] = -loadout.spell_dmg_hit_by_school[i];
    end

    for i = 1, 7 do
        negated.spell_dmg_mod_by_school[i] = -loadout.spell_dmg_mod_by_school[i];
    end

    for i = 1, 7 do
        negated.spell_crit_mod_by_school[i] = -loadout.spell_crit_mod_by_school[i];
    end

    for i = 1, 7 do
        negated.target_spell_dmg_taken[i] = -loadout.target_spell_dmg_taken[i];
    end

    for i = 1, 7 do
        negated.target_mod_res_by_school[i] = -loadout.target_mod_res_by_school[i];
    end

    negated.spell_heal_mod_base = -negated.spell_heal_mod_base;
    negated.spell_heal_mod = -negated.spell_heal_mod;

    negated.dmg_mod = -negated.dmg_mod;

    negated.haste_mod = -negated.haste_mod;
    negated.cost_mod = -negated.cost_mod;

    return negated;
end

-- deep copy to avoid reference entanglement
local function loadout_copy(loadout)

    local cpy = empty_loadout();

    cpy.name = loadout.name;
    cpy.lvl = loadout.lvl;
    cpy.target_lvl = loadout.target_lvl;

    cpy.is_dynamic_loadout = loadout.is_dynamic_loadout;
    cpy.talents_code = loadout.talents_code;
    cpy.always_assume_buffs = loadout.always_assume_buffs;

    cpy.use_dynamic_target_lvl = loadout.use_dynamic_target_lvl;
    cpy.has_target = loadout.has_target;

    cpy.stats = {};
    for i = 1, 5 do
        cpy.stats[i] = loadout.stats[i];
    end

    cpy.mp5 = loadout.mp5;
    cpy.regen_while_casting = loadout.regen_while_casting;
    cpy.mana = loadout.mana;
    cpy.extra_mana = loadout.extra_mana;
    cpy.mana_mod = loadout.mana_mod;

    cpy.healing_power = loadout.healing_power;

    cpy.spell_dmg_by_school = {};
    cpy.spell_crit_by_school = {};
    cpy.healing_crit = loadout.healing_crit;
    cpy.spell_dmg_hit_by_school = {};
    cpy.spell_dmg_mod_by_school = {};
    cpy.spell_crit_mod_by_school = {};
    cpy.target_spell_dmg_taken = {};
    cpy.target_mod_res_by_school = {};

    cpy.spell_heal_mod_base = loadout.spell_heal_mod_base;
    cpy.spell_heal_mod = loadout.spell_heal_mod;

    cpy.dmg_mod = loadout.dmg_mod;

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
    cpy.ability_base_mod = {};
    cpy.ability_effect_mod = {};
    cpy.ability_cast_mod = {};
    cpy.ability_extra_ticks = {};
    cpy.ability_cost_mod = {};
    cpy.ability_crit_mod = {};
    cpy.ability_hit = {};
    cpy.ability_sp = {};
    cpy.ability_flat_add = {};

    cpy.buffs = {};
    cpy.target_buffs = {};
    cpy.target_debuffs = {};

    cpy.buffs1 = loadout.buffs1;
    cpy.buffs2 = loadout.buffs2;
    cpy.target_buffs1 = loadout.target_buffs1;
    cpy.target_debuffs1 = loadout.target_debuffs1;

    cpy.target_friendly = loadout.target_friendly;
    cpy.target_type = loadout.target_type;

    cpy.berserking_snapshot = loadout.berserking_snapshot;

    for i = 1, 7 do
        cpy.spell_dmg_by_school[i] = loadout.spell_dmg_by_school[i];
        cpy.spell_crit_by_school[i] = loadout.spell_crit_by_school[i];
        cpy.spell_dmg_hit_by_school[i] = loadout.spell_dmg_hit_by_school[i];
        cpy.spell_dmg_mod_by_school[i] = loadout.spell_dmg_mod_by_school[i];
        cpy.spell_crit_mod_by_school[i] = loadout.spell_crit_mod_by_school[i];
        cpy.target_spell_dmg_taken[i] = loadout.target_spell_dmg_taken[i];
        cpy.target_mod_res_by_school[i] = loadout.target_mod_res_by_school[i];
    end

    cpy.num_set_pieces = {};
    for i = set_tiers.pve_0, set_tiers.pve_2_5 do
        cpy.num_set_pieces[i] = loadout.num_set_pieces[i];
    end

    for i = 1, 5 do
        cpy.stat_mod[i] = loadout.stat_mod[i];
    end

    for k, v in pairs(loadout.ability_crit) do
        cpy.ability_crit[k] = v;
    end
    for k, v in pairs(loadout.ability_base_mod) do
        cpy.ability_base_mod[k] = v;
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
    for k, v in pairs(loadout.ability_sp) do
        cpy.ability_sp[k] = v;
    end
    for k, v in pairs(loadout.ability_flat_add) do
        cpy.ability_flat_add[k] = v;
    end

    for k, v in pairs(loadout.buffs) do
        cpy.buffs[k] = v;
    end
    for k, v in pairs(loadout.target_buffs) do
        cpy.target_buffs[k] = v;
    end
    for k, v in pairs(loadout.target_debuffs) do
        cpy.target_debuffs[k] = v;
    end

    return cpy;
end

local function loadout_add(primary, diff)

    local added = loadout_copy(primary);

    for i = 1, 5 do
        added.stats[i] = primary.stats[i] + diff.stats[i] * (1 + primary.stat_mod[i]);
    end

    added.mp5 = primary.mp5 + diff.mp5;
    added.mana = primary.mana + 
                 (diff.mana * (1 + primary.mana_mod)) + 
                 (15*diff.stats[stat.int]*(1 + primary.stat_mod[stat.int]*primary.mana_mod));

    local sp_gained_from_spirit = diff.stats[stat.spirit] * (1 + primary.stat_mod[stat.spirit]) * primary.spiritual_guidance * 0.05;
    for i = 1, 7 do
        added.spell_dmg_by_school[i] = primary.spell_dmg_by_school[i] + diff.spell_dmg_by_school[i] + sp_gained_from_spirit;
    end
    added.healing_power = primary.healing_power + diff.healing_power + sp_gained_from_spirit;

    -- introduce crit by intellect here
    crit_diff_normalized_to_primary = diff.stats[stat.int] * ((1 + primary.stat_mod[stat.int])/60)/100; -- assume diff has no stat mod
    for i = 1, 7 do
        added.spell_crit_by_school[i] = primary.spell_crit_by_school[i] + diff.spell_crit_by_school[i] + 
            crit_diff_normalized_to_primary;
    end

    added.healing_crit = primary.healing_crit + diff.healing_crit + crit_diff_normalized_to_primary;

    for i = 1, 7 do
        added.spell_dmg_hit_by_school[i] = primary.spell_dmg_hit_by_school[i] + diff.spell_dmg_hit_by_school[i];
    end

    for i = 1, 7 do
        added.spell_dmg_mod_by_school[i] = primary.spell_dmg_mod_by_school[i] + diff.spell_dmg_mod_by_school[i];
    end

    for i = 1, 7 do
        added.spell_crit_mod_by_school[i] = primary.spell_crit_mod_by_school[i] + diff.spell_crit_mod_by_school[i];
    end
    for i = 1, 7 do
        added.target_spell_dmg_taken[i] = primary.target_spell_dmg_taken[i] + diff.target_spell_dmg_taken[i];
    end
    for i = 1, 7 do
        added.target_mod_res_by_school[i] = primary.target_mod_res_by_school[i] + diff.target_mod_res_by_school[i];
    end

    added.spell_heal_mod_base = primary.spell_heal_mod_base + diff.spell_heal_mod_base;
    added.spell_heal_mod = primary.spell_heal_mod + diff.spell_heal_mod;

    added.dmg_mod = primary.dmg_mod + diff.dmg_mod;

    added.haste_mod = primary.haste_mod + diff.haste_mod;
    added.cost_mod = primary.cost_mod + diff.cost_mod;

    return added;
end

local active_loadout_base = nil;


local function remove_dynamic_stats_from_talents(loadout)

    local talents = talent_table(loadout.talents_code);

    if class == "PALADIN" then

        local pts = talents:pts(1, 13);
        if pts ~= 0 then
            loadout.healing_crit = loadout.healing_crit - pts * 0.01;
            for i = 2, 7 do
                loadout.spell_crit_by_school[i] = 
                    loadout.spell_crit_by_school[i] - pts * 0.01;
            end
        end
    end

    return loadout;
end

local function static_rescale_from_talents_diff(new_loadout, old_loadout)

    local old_int = old_loadout.stats[stat.int];
    local old_max_mana = old_loadout.mana;

    local int_mod = (1 + new_loadout.stat_mod[stat.int])/(1 + old_loadout.stat_mod[stat.int]);
    local mana_mod = (1 + new_loadout.mana_mod)/(1 + old_loadout.mana_mod);
    local new_int = int_mod * old_int
    local mana_gained_from_int =  (new_int - old_int)*15
    local crit_from_int_diff = (new_int - old_int)/6000;
    local new_max_mana = mana_mod * (old_max_mana + mana_gained_from_int);

    local loadout = active_loadout_base();
    loadout.mana = new_max_mana;
    loadout.stats[stat.int] = new_int;
    for i = 2, 7 do
        loadout.spell_crit_by_school[i] = loadout.spell_crit_by_school[i] + crit_from_int_diff;
    end
end

local function apply_talents(loadout)

    local new_loadout = loadout;

    local talents = talent_table(loadout.talents_code);
    
    if class == "MAGE" then

        -- arcane focus
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            new_loadout.spell_dmg_hit_by_school[magic_school.arcane] = 
                new_loadout.spell_dmg_hit_by_school[magic_school.arcane] + pts * 0.02;
        end
        --  improved arcane explosion
        local pts = talents:pts(1, 8);
        if pts ~= 0 then
            local ae = localized_spell_name("Arcane Explosion");
            if not new_loadout.ability_crit[ae] then
                new_loadout.ability_crit[ae] = 0;
            end
            new_loadout.ability_crit[ae] = new_loadout.ability_crit[ae] + pts * 0.02;
        end
        --  arcane mediation
        local pts = talents:pts(1, 12);
        if pts ~= 0 then
            new_loadout.regen_while_casting = new_loadout.regen_while_casting + pts * 0.05;
        end
        --  arcane mind
        local pts = talents:pts(1, 14);
        if pts ~= 0 then
            new_loadout.mana_mod = new_loadout.mana_mod + pts * 0.02;
        end
        -- arcane instability
        local pts = talents:pts(1, 15);
        if pts ~= 0 then
            for i = 1, 7 do
                new_loadout.spell_dmg_mod_by_school[i] = new_loadout.spell_dmg_mod_by_school[i] + pts * 0.01;
                new_loadout.spell_crit_by_school[i] = new_loadout.spell_crit_by_school[i] + pts * 0.01;
            end
        end
        -- improved fireball
        local pts = talents:pts(2, 1);
        if pts ~= 0 then
            local fb = localized_spell_name("Fireball");
            if not new_loadout.ability_cast_mod[fb] then
                new_loadout.ability_cast_mod[fb] = 0;
            end
            new_loadout.ability_cast_mod[fb] = new_loadout.ability_cast_mod[fb] + pts * 0.1;
        end
        -- ignite
        local pts = talents:pts(2, 3);
        if pts ~= 0 then
           new_loadout.ignite = pts; 
        end
        -- incinerate
        local pts = talents:pts(2, 6);
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
        local pts = talents:pts(2, 7);
        if pts ~= 0 then
            local fs = localized_spell_name("Flamestrike");
            if not new_loadout.ability_crit[fs] then
                new_loadout.ability_crit[fs] = 0;
            end
            new_loadout.ability_crit[fs] = new_loadout.ability_crit[fs] + pts * 0.05;
        end
        -- master of elements
        local pts = talents:pts(2, 9);
        if pts ~= 0 then
            new_loadout.master_of_elements = pts;
        end
        -- critical mass
        local pts = talents:pts(2, 13);
        if pts ~= 0 then
            new_loadout.spell_crit_by_school[magic_school.fire] =
                new_loadout.spell_crit_by_school[magic_school.fire] + pts * 0.02;
        end
        -- fire power
        local pts = talents:pts(2, 15);
        if pts ~= 0 then
            new_loadout.spell_dmg_mod_by_school[magic_school.fire] =
                new_loadout.spell_dmg_mod_by_school[magic_school.fire] + pts * 0.02;
        end
        -- improved frostbolt
        local pts = talents:pts(3, 2);
        if pts ~= 0 then
            local fb = localized_spell_name("Frostbolt");
            if not new_loadout.ability_cast_mod[fb] then
                new_loadout.ability_cast_mod[fb] = 0;
            end
            new_loadout.ability_cast_mod[fb] = new_loadout.ability_cast_mod[fb] + pts * 0.1;
        end
        -- elemental precision
        local pts = talents:pts(3, 3);
        if pts ~= 0 then
            new_loadout.spell_dmg_hit_by_school[magic_school.fire] = 
                new_loadout.spell_dmg_hit_by_school[magic_school.fire] + pts * 0.02;
            new_loadout.spell_dmg_hit_by_school[magic_school.frost] = 
                new_loadout.spell_dmg_hit_by_school[magic_school.frost] + pts * 0.02;
        end
        -- ice shards
        local pts = talents:pts(3, 4);
        if pts ~= 0 then
            new_loadout.spell_crit_mod_by_school[magic_school.frost] = 
                1 + (new_loadout.spell_crit_mod_by_school[magic_school.frost] - 1) * (1 + pts * 0.2);
        end
        -- piercing ice
        local pts = talents:pts(3, 8);
        if pts ~= 0 then
            new_loadout.spell_dmg_mod_by_school[5] = new_loadout.spell_dmg_mod_by_school[5] + pts * 0.02;
        end
        -- frost channeling
        local pts = talents:pts(3, 12);
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
        local pts = talents:pts(3, 15);
        if pts ~= 0 then
            local coc = localized_spell_name("Cone of Cold");
            if not new_loadout.ability_base_mod[coc] then
                new_loadout.ability_base_mod[coc] = 0;
            end
            new_loadout.ability_base_mod[coc] = new_loadout.ability_base_mod[coc] + pts * 0.15;
        end
    elseif class == "DRUID" then

        -- improved wrath
        local pts = talents:pts(1, 1);
        if pts ~= 0 then
            local wrath = localized_spell_name("Wrath");
            if not new_loadout.ability_cast_mod[wrath] then
                new_loadout.ability_cast_mod[wrath] = 0;
            end
            new_loadout.ability_cast_mod[wrath] = new_loadout.ability_cast_mod[wrath] + pts * 0.1;
        end

        -- improved moonfire
        local pts = talents:pts(1, 5);
        if pts ~= 0 then
            local mf = localized_spell_name("Moonfire");
            if not new_loadout.ability_base_mod[mf] then
                new_loadout.ability_base_mod[mf] = 0;
            end
            if not new_loadout.ability_crit[mf] then
                new_loadout.ability_crit[mf] = 0;
            end
            new_loadout.ability_base_mod[mf] = new_loadout.ability_base_mod[mf] + pts * 0.02;
            new_loadout.ability_crit[mf] = new_loadout.ability_crit[mf] + pts * 0.02;
        end

        -- vengeance
        local pts = talents:pts(1, 11);
        if pts ~= 0 then

            local mf = localized_spell_name("Moonfire");
            local sf = localized_spell_name("Starfire");
            local wrath = localized_spell_name("Wrath");
            if not new_loadout.ability_crit_mod[v] then
                new_loadout.ability_crit_mod[mf] = 0;
                new_loadout.ability_crit_mod[sf] = 0;
                new_loadout.ability_crit_mod[wrath] = 0;
            end
            new_loadout.ability_crit_mod[mf] = 
                (new_loadout.spell_crit_mod_by_school[magic_school.arcane] - 1) * (pts * 0.2);
            new_loadout.ability_crit_mod[sf] = 
                (new_loadout.spell_crit_mod_by_school[magic_school.arcane] - 1) * (pts * 0.2);
            new_loadout.ability_crit_mod[wrath] = 
                (new_loadout.spell_crit_mod_by_school[magic_school.nature] - 1) * (pts * 0.2);
        end

        -- improved starfire
        local pts = talents:pts(1, 12);
        if pts ~= 0 then
            local sf = localized_spell_name("Starfire");
            if not new_loadout.ability_cast_mod[sf] then
                new_loadout.ability_cast_mod[sf] = 0;
            end
            new_loadout.ability_cast_mod[sf] = new_loadout.ability_cast_mod[sf] + pts * 0.1;
        end

        -- nature's grace
        local pts = talents:pts(1, 13);
        if pts ~= 0 then
            new_loadout.natures_grace = pts;
        end

        -- moonglow
        local pts = talents:pts(1, 14);
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
        local pts = talents:pts(1, 15);
        if pts ~= 0 then
            local abilities = {"Starfire", "Moonfire", "Wrath"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end
            for k, v in pairs(abilities) do
                if not new_loadout.ability_base_mod[v] then
                    new_loadout.ability_base_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_base_mod[v] = new_loadout.ability_base_mod[v] + pts * 0.02;
            end
        end

        -- heart of the wild
        local pts = talents:pts(2, 15);
        if pts ~= 0 then
            new_loadout.stat_mod[stat.int] = new_loadout.stat_mod[stat.int] + pts * 0.04;
        end

        -- improved healing touch
        local pts = talents:pts(3, 3);
        if pts ~= 0 then
            local ht = localized_spell_name("Healing Touch");
            if not new_loadout.ability_cast_mod[ht] then
                new_loadout.ability_cast_mod[ht] = 0;
            end
            new_loadout.ability_cast_mod[ht] = new_loadout.ability_cast_mod[ht] + pts * 0.1;
        end
        -- reflection
        local pts = talents:pts(3, 6);
        if pts ~= 0 then
            new_loadout.regen_while_casting = new_loadout.regen_while_casting + pts * 0.05;
        end

        -- tranquil spirit
        local pts = talents:pts(3, 9);
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
        local pts = talents:pts(3, 10);
        if pts ~= 0 then
            local rejuv = localized_spell_name("Rejuvenation");
            if not new_loadout.ability_base_mod[rejuv] then
                new_loadout.ability_base_mod[rejuv] = 0;
            end
            new_loadout.ability_base_mod[rejuv] = new_loadout.ability_base_mod[rejuv] + pts * 0.05;
        end

        -- gift of nature
        local pts = talents:pts(3, 12);
        if pts ~= 0 then
            new_loadout.spell_heal_mod_base = new_loadout.spell_heal_mod_base + pts * 0.02;
        end

        -- improved regrowth
        local pts = talents:pts(3, 14);
        if pts ~= 0 then
            local regrowth = localized_spell_name("Regrowth");
            if not new_loadout.ability_crit[regrowth] then
                new_loadout.ability_crit[regrowth] = 0;
            end
            new_loadout.ability_crit[regrowth] = new_loadout.ability_crit[regrowth] + pts * 0.10;
        end
    elseif class == "PRIEST" then

        -- improved power word: shield
        local pts = talents:pts(1, 5);
        if pts ~= 0 then
            local shield = localized_spell_name("Power Word: Shield");
            if not new_loadout.ability_effect_mod[shield] then
                new_loadout.ability_effect_mod[shield] = 0;
            end
            new_loadout.ability_effect_mod[shield] = 
                new_loadout.ability_effect_mod[shield] + pts * 0.05;
        end

        -- mental agility 
        local pts = talents:pts(1, 10);
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
        -- meditation
        local pts = talents:pts(1, 8);
        if pts ~= 0 then
            new_loadout.regen_while_casting = new_loadout.regen_while_casting + pts * 0.05;
        end
        -- force of will
        local pts = talents:pts(1, 14);
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
        -- mental strength
        local pts = talents:pts(1, 12);
        if pts ~= 0 then
            new_loadout.mana_mod = new_loadout.mana_mod + pts * 0.02;
        end

        -- improved renew
        local pts = talents:pts(2, 2);
        if pts ~= 0 then
            local renew = localized_spell_name("Renew");
            if not new_loadout.ability_base_mod[renew] then
                new_loadout.ability_base_mod[renew] = 0;
            end
            new_loadout.ability_base_mod[renew] = new_loadout.ability_base_mod[renew] + pts * 0.05;
        end
        -- holy specialization
        local pts = talents:pts(2, 3);
        if pts ~= 0 then

            new_loadout.healing_crit = new_loadout.healing_crit + pts * 0.01; -- all priest heals are holy...
            new_loadout.spell_crit_by_school[magic_school.holy] = 
                new_loadout.spell_crit_by_school[magic_school.holy] + pts * 0.01;
        end
        -- divine fury
        local pts = talents:pts(2, 5);
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
        local pts = talents:pts(2, 10);
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
        local pts = talents:pts(2, 11);
        if pts ~= 0 then

            local abilities = {"Smite", "Holy Fire"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end
            for k, v in pairs(abilities) do
                if not new_loadout.ability_base_mod[v] then
                    new_loadout.ability_base_mod[v] = 0;
                end
            end
            -- TODO: multiplicative or additive?
            for k, v in pairs(abilities) do
                new_loadout.ability_base_mod[v] = new_loadout.ability_base_mod[v] + pts * 0.05;
            end
        end
        -- improved prayer of healing
        local pts = talents:pts(2, 12);
        if pts ~= 0 then
            local poh = localized_spell_name("Prayer of Healing");
            if not new_loadout.ability_cost_mod[poh] then
                new_loadout.ability_cost_mod[poh] = 0;
            end
            new_loadout.ability_cost_mod[poh] = 
                new_loadout.ability_cost_mod[poh] + pts * 0.1;
        end
        -- spiritual guidance 
        local pts = talents:pts(2, 14);
        if pts ~= 0 then
           new_loadout.spiritual_guidance = pts; 
        end
        -- spiritual healing
        local pts = talents:pts(2, 15);
        if pts ~= 0 then
            new_loadout.spell_heal_mod_base = new_loadout.spell_heal_mod_base + pts * 0.02;
        end

        -- improved shadow word: pain
        local pts = talents:pts(3, 4);
        if pts ~= 0 then
            local swp = localized_spell_name("Shadow Word: Pain");                

            if not new_loadout.ability_extra_ticks[swp] then
                new_loadout.ability_extra_ticks[swp] = 0;
            end
            new_loadout.ability_extra_ticks[swp] = new_loadout.ability_extra_ticks[swp] + pts;
        end
        -- shadow focus
        local pts = talents:pts(3, 5);
        if pts ~= 0 then
            new_loadout.spell_dmg_hit_by_school[magic_school.shadow] = 
                new_loadout.spell_dmg_hit_by_school[magic_school.shadow] + pts * 0.02;
        end
        -- darkness
        local pts = talents:pts(3, 15);
        if pts ~= 0 then
            
            local swp = localized_spell_name("Shadow Word: Pain");
            local dp = localized_spell_name("Devouring Plague");
            local mf = localized_spell_name("Mind Flay");
            local mb = localized_spell_name("Mind Blast");

            if not new_loadout.ability_effect_mod[swp] then
                new_loadout.ability_effect_mod[swp] = 0;
            end
            new_loadout.ability_effect_mod[swp] = new_loadout.ability_effect_mod[swp] + 0.02 * pts;

            if not new_loadout.ability_effect_mod[dp] then
                new_loadout.ability_effect_mod[dp] = 0;
            end
            new_loadout.ability_effect_mod[dp] = new_loadout.ability_effect_mod[dp] + 0.02 * pts;
            
            if not new_loadout.ability_effect_mod[mf] then
                new_loadout.ability_effect_mod[mf] = 0;
            end
            new_loadout.ability_effect_mod[mf] = new_loadout.ability_effect_mod[mf] + 0.02 * pts;

            if not new_loadout.ability_base_mod[mb] then
                new_loadout.ability_base_mod[mb] = 0;
            end
            new_loadout.ability_base_mod[mb] = new_loadout.ability_base_mod[mb] + 0.02 * pts;
        end

    elseif class == "SHAMAN" then

        -- convection
        local pts = talents:pts(1, 1);
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
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            local abilities = {"Earth Shock", "Frost Shock", "Flame Shock", "Lightning Bolt", "Chain Lightning"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end

            for k, v in pairs(abilities) do
                if not new_loadout.ability_base_mod[v] then
                    new_loadout.ability_base_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_base_mod[v] = new_loadout.ability_base_mod[v] + pts * 0.01;
            end
        end

        -- call of flame
        local pts = talents:pts(1, 5);
        if pts ~= 0 then
            local abilities = {"Magma Totem", "Searing Totem", "Fire Nova Totem"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end

            for k, v in pairs(abilities) do
                if not new_loadout.ability_base_mod[v] then
                    new_loadout.ability_base_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_base_mod[v] = new_loadout.ability_base_mod[v] + pts * 0.05;
            end
        end

        -- call of thunder
        local pts = talents:pts(1, 8);
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
                if pts == 5 then
                    new_loadout.ability_crit[v] = new_loadout.ability_crit[v] + 0.06;
                else
                    new_loadout.ability_crit[v] = new_loadout.ability_crit[v] + pts * 0.01;
                end
            end
        end

        -- elemental fury
        local pts = talents:pts(1, 13);
        if pts ~= 0 then
            new_loadout.spell_crit_mod_by_school[magic_school.frost] = 
                1 + (new_loadout.spell_crit_mod_by_school[magic_school.frost] - 1) * 2;
            new_loadout.spell_crit_mod_by_school[magic_school.fire] = 
                1 + (new_loadout.spell_crit_mod_by_school[magic_school.fire] - 1) * 2;
            new_loadout.spell_crit_mod_by_school[magic_school.nature] = 
                1 + (new_loadout.spell_crit_mod_by_school[magic_school.nature] - 1) * 2;
        end

        -- lightning mastery
        local pts = talents:pts(1, 14);
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
        local pts = talents:pts(2, 6);
        if pts ~= 0 then
            local ls = localized_spell_name("Lightning Shield");
            if not new_loadout.ability_base_mod[ls] then
                new_loadout.ability_base_mod[ls] = 0;
            end
            new_loadout.ability_base_mod[ls] = new_loadout.ability_base_mod[ls] + pts * 0.05;
        end

        -- improved healing wave
        local pts = talents:pts(3, 1);
        if pts ~= 0 then
            local hw = localized_spell_name("Healing Wave");
            if not new_loadout.ability_cast_mod[hw] then
                new_loadout.ability_cast_mod[hw] = 0;
            end
            new_loadout.ability_cast_mod[hw] = new_loadout.ability_cast_mod[hw] + pts * 0.1;
        end

        -- tidal focus
        local pts = talents:pts(3, 2);
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
        local pts = talents:pts(3, 5);
        if pts ~= 0 then

            local totems = {"Healing Stream Totem", "Magma Totem", "Searing Totem", "Fire Nova Totem"};

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

        local pts = talents:pts(3, 10);
        if pts ~= 0 then

            local totems = {"Healing Stream Totem"};
            for k, v in pairs(totems) do
                totems[k] = localized_spell_name(v);
            end

            for k, v in pairs(totems) do
                if not new_loadout.ability_base_mod[v] then
                    new_loadout.ability_base_mod[v] = 0;
                end
            end
            for k, v in pairs(totems) do
                new_loadout.ability_base_mod[v] = new_loadout.ability_base_mod[v] + pts * 0.05;
            end
        end

        -- tidal mastery
        local pts = talents:pts(3, 11);
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
        local pts = talents:pts(3, 14);
        if pts ~= 0 then

            new_loadout.spell_heal_mod_base = new_loadout.spell_heal_mod_base + pts * 0.02;

        end

    elseif class == "PALADIN" then

        -- divine intellect
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            new_loadout.stat_mod[stat.int] = new_loadout.stat_mod[stat.int] + pts * 0.02;
        end

        -- healing light
        local pts = talents:pts(1, 5);
        if pts ~= 0 then

            local abilities = {"Holy Light", "Flash of Light"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end

            for k, v in pairs(abilities) do
                if not new_loadout.ability_base_mod[v] then
                    new_loadout.ability_base_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_base_mod[v] = new_loadout.ability_base_mod[v] + pts * 0.04;
            end
        end
        -- illumination
        local pts = talents:pts(1, 9);
        if pts ~= 0 then
            new_loadout.illumination = pts;
        end

        -- holy power
        local pts = talents:pts(1, 13);
        if pts ~= 0 then

            new_loadout.healing_crit = new_loadout.healing_crit + pts * 0.01; -- all pally heals are holy...
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
        local pts = talents:pts(1, 1);
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
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            local corruption = localized_spell_name("Corruption");

            if not new_loadout.ability_cast_mod[corruption] then
                new_loadout.ability_cast_mod[corruption] = 0;
            end

            new_loadout.ability_cast_mod[corruption] = 
                new_loadout.ability_cast_mod[corruption] + pts * 0.4;
        end

        -- improved curse of agony
        local pts = talents:pts(1, 7);
        if pts ~= 0 then
            local coa = localized_spell_name("Curse of Agony");

            if not new_loadout.ability_base_mod[coa] then
                new_loadout.ability_base_mod[coa] = 0;
            end

            new_loadout.ability_base_mod[coa] = 
                new_loadout.ability_base_mod[coa] + pts * 0.02;
        end
        -- shadow mastery
        local pts = talents:pts(1, 16);
        if pts ~= 0 then

            new_loadout.spell_dmg_mod_by_school[magic_school.shadow] = 
                new_loadout.spell_dmg_mod_by_school[magic_school.shadow] + pts * 0.02;
        end

        -- improved shadow bolt
        local pts = talents:pts(3, 1);
        if pts ~= 0 then
           new_loadout.improved_shadowbolt = pts; 
        end

        -- cataclysm
        local pts = talents:pts(3, 2);
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
        local pts = talents:pts(3, 3);
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
        local pts = talents:pts(3, 7);
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
        local pts = talents:pts(3, 11);
        if pts ~= 0 then
            local sp = localized_spell_name("Searing Pain");
            if not new_loadout.ability_crit[sp] then
                new_loadout.ability_crit[sp] = 0;
            end
            new_loadout.ability_crit[sp] = new_loadout.ability_crit[sp] + pts * 0.02;
        end

        -- improved immolate
        local pts = talents:pts(3, 13);
        new_loadout.improved_immolate = pts;

        -- ruin 
        local pts = talents:pts(3, 14);
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
        local pts = talents:pts(3, 15);
        if pts ~= 0 then
            new_loadout.spell_dmg_mod_by_school[magic_school.fire] =
                new_loadout.spell_dmg_mod_by_school[magic_school.fire] + pts * 0.02;
        end
    end

    return new_loadout;
end


local function create_set_bonuses()

    local set_tier_ids = {};

    if class == "PRIEST" then
        -- of prophecy
        for i = 16811, 16819 do
            set_tier_ids[i] = set_tiers.pve_1;
        end
        for i = 16919, 16926 do
            set_tier_ids[i] = set_tiers.pve_2;
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

        -- t2
        set_tier_ids[16818] = set_tiers.pve_2;
        set_tier_ids[16912] = set_tiers.pve_2;
        set_tier_ids[16913] = set_tiers.pve_2;
        set_tier_ids[16914] = set_tiers.pve_2;
        set_tier_ids[16915] = set_tiers.pve_2;
        set_tier_ids[16916] = set_tiers.pve_2;
        set_tier_ids[16917] = set_tiers.pve_2;
        set_tier_ids[16918] = set_tiers.pve_2;

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
        local item_link = GetInventoryItemLink("player", item);
        if item_link then
            local item_stats = GetItemStats(item_link);
            if item_stats then
                if item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] then
                    new_loadout.mp5 = new_loadout.mp5 + item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] + 1;
                end
            end
        end
    end

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
        if new_loadout.num_set_pieces[set_tiers.pve_2] >= 3 then
            new_loadout.regen_while_casting = new_loadout.regen_while_casting + 0.15;
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
        
        if new_loadout.num_set_pieces[set_tiers.pve_2] >= 3 then

            new_loadout.regen_while_casting = new_loadout.regen_while_casting + 0.15;
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
        end

        if new_loadout.num_set_pieces[set_tiers.pve_2_5] >= 2 then

            new_loadout.mp5 = new_loadout.mp5 + 4;
            if new_loadout.num_set_pieces[set_tiers.pve_2_5] >= 5 then

                local sf = localized_spell_name("Starfire");
                if not new_loadout.ability_crit[sf] then
                    new_loadout.ability_crit[sf] = 0;
                end

                new_loadout.ability_crit[sf] = new_loadout.ability_crit[sf] + 0.03;
            end
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
                
                local probability_of_atleast_one_cost_proc = 1 - (1-0.25)*(1-0.25)*(1-0.25);
                new_loadout.ability_cost_mod[hw] = new_loadout.ability_cost_mod[hw] + probability_of_atleast_one_cost_proc * 0.35;
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

            if not new_loadout.ability_base_mod[corr] then
                new_loadout.ability_base_mod[corr] = 0;
            end
            new_loadout.ability_base_mod[corr] = new_loadout.ability_base_mod[corr] + 0.02;
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

local function detect_buffs(loadout)

    local new_loadout = loadout;

    new_loadout.buffs = {};
    for i = 1, 40  do
          local name, _, count, _, _, _, src, _, _, spell_id = UnitBuff("player", i);
          if not name then
              break;
          end
          new_loadout.buffs[spell_id] = {name = name, count = count, src = src};
          new_loadout.buffs[name] = {count = count, id = spell_id, src = src};
    end
    new_loadout.target_buffs = {};
    for i = 1, 40  do
          local name, _, count, _, _, _, src, _, _, spell_id = UnitBuff("target", i);
          if not name then
              break;
          end
          new_loadout.target_buffs[spell_id] = {name = name, count = count, src = src};
          new_loadout.target_buffs[name] = {count = count, id = spell_id, src = src};
    end
    new_loadout.target_debuffs = {};
    for i = 1, 40  do
          local name, _, count, _, _, _, src, _, _, spell_id = UnitDebuff("target", i);
          if not name then
              break;
          end
          new_loadout.target_debuffs[spell_id] = {name = name, count = count, src = src};
          new_loadout.target_debuffs[name] = {count = count, id = spell_id, src = src};
    end

    return new_loadout;
end

local function apply_general_buffs(loadout, raw_stats_diff)

    -- BUFFS
    if bit.band(buffs1.ony.flag, loadout.buffs1) ~= 0 and not loadout.buffs[buffs1.ony.id] and 
        loadout.always_assume_buffs then

        for i = 2, 7 do
            loadout.spell_crit_by_school[i] = loadout.spell_crit_by_school[i] + 0.1;
        end
        loadout.healing_crit = loadout.healing_crit + 0.1;

    elseif bit.band(buffs1.ony.flag, loadout.buffs1) == 0 and loadout.buffs[buffs1.ony.id] then

        for i = 2, 7 do
            loadout.spell_crit_by_school[i] = loadout.spell_crit_by_school[i] - 0.1;
        end
        loadout.healing_crit = loadout.healing_crit - 0.1;

    end
    if bit.band(buffs1.wcb.flag, loadout.buffs1) ~= 0 and 
        (loadout.buffs[buffs1.wcb.id] or loadout.always_assume_buffs) then

        loadout.mp5 = loadout.mp5 + 10;
    end
    -- zg buff
    if bit.band(buffs1.spirit_of_zandalar.flag, loadout.buffs1) ~= 0 then 

        if loadout.buffs[buffs1.spirit_of_zandalar.id] then
            for i = 1, 5 do
                loadout.stat_mod[i] = loadout.stat_mod[i] + 0.15;
            end
        elseif not loadout.buffs[buffs1.spirit_of_zandalar.id] and loadout.always_assume_buffs then
            for i = 1, 5 do
                raw_stats_diff.stats[i] = raw_stats_diff.stats[i] + loadout.stats[i] * 0.15;
            end
            for i = 1, 5 do
                loadout.stat_mod[i] = loadout.stat_mod[i] + 0.15;
            end
        end

    elseif bit.band(buffs1.spirit_of_zandalar.flag, loadout.buffs1) == 0 and 
            loadout.buffs[buffs1.spirit_of_zandalar.id] then

        for i = 1, 5 do
            raw_stats_diff.stats[i] = raw_stats_diff.stats[i] - loadout.stats[i] * 0.15;
        end
    end
    if bit.band(buffs1.songflower.flag, loadout.buffs1) ~= 0 and not loadout.buffs[buffs1.songflower.id] and
        loadout.always_assume_buffs then

        for i = 2, 7 do
            loadout.spell_crit_by_school[i] = loadout.spell_crit_by_school[i] + 0.05;
        end
        loadout.healing_crit = loadout.healing_crit + 0.05;
        for i = 1, 5 do
            raw_stats_diff.stats[i] = raw_stats_diff.stats[i] + 15;
        end
    elseif bit.band(buffs1.songflower.flag, loadout.buffs1) == 0 and loadout.buffs[buffs1.songflower.id] then

        for i = 2, 7 do
            loadout.spell_crit_by_school[i] = loadout.spell_crit_by_school[i] - 0.05;
        end
        loadout.healing_crit = loadout.healing_crit - 0.05;
        for i = 1, 5 do
            raw_stats_diff.stats[i] = raw_stats_diff.stats[i] - 15;
        end
    end

    if bit.band(buffs1.dmf_dmg.flag, loadout.buffs1) ~= 0 and 
        (loadout.always_assume_buffs or loadout.buffs[buffs1.dmf_dmg.id]) then
        loadout.dmg_mod = loadout.dmg_mod + 0.1;
    end
    -- TARGET BUFFS
    -- TARGET DEBUFFS
end

local function apply_horde_buffs(loadout, raw_stats_diff)
end

local function apply_ally_buffs(loadout, raw_stats_diff)

    if bit.band(buffs2.bok.flag, loadout.buffs2) ~= 0 then 

        if loadout.buffs[buffs2.bok.id] then
            for i = 1, 5 do
                loadout.stat_mod[i] = loadout.stat_mod[i] + 0.1;
            end
        elseif not loadout.buffs[buffs2.bok.id] and loadout.always_assume_buffs then
            -- buff wasnt actually on so increase stats
            for i = 1, 5 do
                raw_stats_diff.stats[i] = raw_stats_diff.stats[i] + loadout.stats[i] * 0.1;
            end
            for i = 1, 5 do
                loadout.stat_mod[i] = loadout.stat_mod[i] + 0.1;
            end
        end
    elseif bit.band(buffs2.bok.flag, loadout.buffs2) == 0 and loadout.buffs[buffs2.bok.id] then
        for i = 1, 5 do
            raw_stats_diff.stats[i] = raw_stats_diff.stats[i] - loadout.stats[i] * 0.1;
        end
    end
    if bit.band(buffs2.bow.flag, loadout.buffs2) ~= 0  and 
        (loadout.always_assume_buffs or loadout.buffs[localized_spell_name("Blessing of Wisdom")]) then 
        -- ehh just assume casters of bow have improved bow...
        local mp5 = 0;
        local talent_mod = 1.2;
        local bow = loadout.buffs[localized_spell_name("Blessing of Wisdom")];
        if bow then
            if bow.id == 19742 then
                mp5 = 10 * talent_mod;
            elseif bow.id == 19850 then
                mp5 = 15 * talent_mod;
            elseif bow.id == 19852 then
                mp5 = 20 * talent_mod;
            elseif bow.id == 19853 then
                mp5 = 25 * talent_mod;
            elseif bow.id == 19854 then
                mp5 = 30 * talent_mod;
            else 
                mp5 = 33 * talent_mod;
            end
        else
            mp5 = 33*talent_mod;
        end
        loadout.mp5 = loadout.mp5 + mp5;
    end
   
end
local function apply_caster_fire_buffs(loadout, raw_stats_diff)
    -- SELF BUFFS
    if bit.band(buffs1.elixir_of_greater_firepower.flag, loadout.buffs1) ~= 0 and
        loadout.always_assume_buffs and not loadout.buffs[buffs1.elixir_of_greater_firepower.id] then
        loadout.spell_dmg_by_school[magic_school.fire] = loadout.spell_dmg_by_school[magic_school.fire] + 40;
    elseif bit.band(buffs1.elixir_of_greater_firepower.flag, loadout.buffs1) == 0 and 
        loadout.buffs[buffs1.elixir_of_greater_firepower.id] then
        loadout.spell_dmg_by_school[magic_school.fire] = loadout.spell_dmg_by_school[magic_school.fire] - 40;
    end
    -- TARGET BUFFS
    -- TARGET DEBUFFS
    if bit.band(target_debuffs1.improved_scorch.flag, loadout.target_debuffs1) ~= 0 then

        local fire_dmg = 0;
        local fire_vuln = loadout.target_debuffs[target_debuffs1.improved_scorch.id];
        if fire_vuln then
            fire_dmg = fire_vuln.count * 0.03;
        elseif loadout.always_assume_buffs then
            -- assume 5 stacks
            fire_dmg = 0.03 * 5;
        end

        if (not loadout.target_friendly and loadout.has_target) or loadout.always_assume_buffs then
            loadout.target_spell_dmg_taken[magic_school.fire] = 
                loadout.target_spell_dmg_taken[magic_school.fire] + fire_dmg;
        end
    end
end
local function apply_caster_shadow_buffs(loadout, raw_stats_diff)
    -- SELF BUFFS
    if bit.band(buffs1.elixir_of_shadow_power.flag, loadout.buffs1) ~= 0 and
        loadout.always_assume_buffs and not loadout.buffs[buffs1.elixir_of_shadow_power.id] then
        loadout.spell_dmg_by_school[magic_school.shadow] = loadout.spell_dmg_by_school[magic_school.shadow] + 40;
    elseif bit.band(buffs1.elixir_of_shadow_power.flag, loadout.buffs1) == 0 and 
        loadout.buffs[buffs1.elixir_of_shadow_power.id] then
        loadout.spell_dmg_by_school[magic_school.shadow] = loadout.spell_dmg_by_school[magic_school.shadow] - 40;
    end
    -- TARGET BUFFS
    -- TARGET DEBUFFS
    if bit.band(target_debuffs1.improved_shadow_bolt.flag, loadout.target_debuffs1) ~= 0 and 
        ((not loadout.target_friendly and loadout.has_target and loadout.target_debuffs[target_debuffs1.improved_shadow_bolt.id]) or 
        loadout.always_assume_buffs) then

        loadout.target_spell_dmg_taken[magic_school.shadow] = 
            loadout.target_spell_dmg_taken[magic_school.shadow] + 0.2;
    end
    if bit.band(target_debuffs1.shadow_weaving.flag, loadout.target_debuffs1) ~= 0 then

        local shadow_dmg = 0;
        local shadow_vuln = loadout.target_debuffs[target_debuffs1.shadow_weaving.id];
        if shadow_vuln then
            shadow_dmg = shadow_vuln.count * 0.03;
        elseif loadout.always_assume_buffs then
            -- assume 5 stacks
            shadow_dmg = 0.03 * 5;
        end

        if (not loadout.target_friendly and loadout.has_target) or loadout.always_assume_buffs then
            loadout.target_spell_dmg_taken[magic_school.shadow] = 
                loadout.target_spell_dmg_taken[magic_school.shadow] + shadow_dmg;
        end
    end
end
local function apply_caster_frost_buffs(loadout, raw_stats_diff)
    -- SELF BUFFS
    if bit.band(buffs1.elixir_of_frost_power.flag, loadout.buffs1) ~= 0 and
        loadout.always_assume_buffs and not loadout.buffs[buffs1.elixir_of_frost_power.id] then
        loadout.spell_dmg_by_school[magic_school.frost] = loadout.spell_dmg_by_school[magic_school.frost] + 15;
    elseif bit.band(buffs1.elixir_of_frost_power.flag, loadout.buffs1) == 0 and 
        loadout.buffs[buffs1.elixir_of_frost_power.id] then
        loadout.spell_dmg_by_school[magic_school.frost] = loadout.spell_dmg_by_school[magic_school.frost] - 15;
    end

    -- TARGET BUFFS
    -- TARGET DEBUFFS
    if bit.band(target_debuffs1.wc.flag, loadout.target_debuffs1) ~= 0 then
        local frost_crit = 0;

        local winters_chill = loadout.target_debuffs[target_debuffs1.wc.id];
        if winters_chill then
            frost_crit = winters_chill.count * 0.02;
        elseif loadout.always_assume_buffs then
            -- assume 5 stacks
            frost_crit = 0.1;
        end

        if (not loadout.target_friendly and loadout.has_target) or loadout.always_assume_buffs then
            loadout.spell_crit_by_school[magic_school.frost] = loadout.spell_crit_by_school[magic_school.frost] + frost_crit;
        end
    end
end

local function apply_caster_nature_buffs(loadout, raw_stats_diff)

    if bit.band(target_debuffs1.stormstrike.flag, loadout.target_debuffs1) ~= 0 and 
        ((not loadout.target_friendly and loadout.has_target and loadout.target_debuffs[target_debuffs1.stormstrike.id]) or 
        loadout.always_assume_buffs) then

        loadout.target_spell_dmg_taken[magic_school.nature] = 
            loadout.target_spell_dmg_taken[magic_school.nature] + 0.2;
    end
end

local function apply_caster_buffs(loadout, raw_stats_diff)

    -- SELF BUFFS
    if bit.band(buffs1.power_infusion.flag, loadout.buffs1) ~= 0 and 
        (loadout.always_assume_buffs or loadout.buffs[buffs1.power_infusion.id]) then
    
        for j = 2, 7 do 
            loadout.spell_dmg_mod_by_school[j] = loadout.spell_dmg_mod_by_school[j] + 0.2;
        end
        loadout.spell_heal_mod = loadout.spell_heal_mod + 0.2;
    end
    
    if bit.band(buffs1.dmt_crit.flag, loadout.buffs1) ~= 0 and
        not loadout.buffs[buffs1.dmt_crit.id] and loadout.always_assume_buffs then

        for i = 2, 7 do
            loadout.spell_crit_by_school[i] = loadout.spell_crit_by_school[i] + 0.03;
        end
        loadout.healing_crit = loadout.healing_crit + 0.03;

    elseif bit.band(buffs1.dmt_crit.flag, loadout.buffs1) == 0 and
        loadout.buffs[buffs1.dmt_crit.id] then

        for i = 2, 7 do
            loadout.spell_crit_by_school[i] = loadout.spell_crit_by_school[i] - 0.03;
        end
        loadout.healing_crit = loadout.healing_crit - 0.03;
    end
    -- arcane intellect
    local int_buff = loadout.buffs[localized_spell_name("Arcane Intellect")];
    local int_buff_aoe = loadout.buffs[localized_spell_name("Arcane Brilliance")];
    if bit.band(buffs1.int.flag, loadout.buffs1) ~= 0 then

        if not int_buff and not int_buff_aoe and loadout.always_assume_buffs then
            raw_stats_diff.stats[stat.int] = raw_stats_diff.stats[stat.int] + 31;
        end
    elseif bit.band(buffs1.int.flag, loadout.buffs1) == 0 and (int_buff or int_buff_aoe) then
        raw_stats_diff.stats[stat.int] = raw_stats_diff.stats[stat.int] - 31;
    end
    -- motw
    local motw_buff = loadout.buffs[localized_spell_name("Mark of the Wild")];
    local motw_buff_aoe = loadout.buffs[localized_spell_name("Gift of the Wild")];
    if bit.band(buffs1.motw.flag, loadout.buffs1) ~= 0 then
        if not motw_buff and not motw_buff_aoe and loadout.always_assume_buffs then
            for i = 1, 5 do
                raw_stats_diff.stats[i] = raw_stats_diff.stats[i] + 16;
            end
        end
    elseif bit.band(buffs1.motw.flag, loadout.buffs1) == 0 and (motw_buff or motw_buff_aoe) then
        for i = 1, 5 do
            raw_stats_diff.stats[i] = raw_stats_diff.stats[i] - 16;
        end
    end
    -- spirit buff
    local spirit_buff = loadout.buffs[localized_spell_name("Divine Spirit")];
    local spirit_buff_aoe = loadout.buffs[localized_spell_name("Prayer of Spirit")];
    if bit.band(buffs1.spirit.flag, loadout.buffs1) ~= 0 then
        if not spirit_buff and not spirit_buff_aoe and loadout.always_assume_buffs then
            raw_stats_diff.stats[stat.spirit] = raw_stats_diff.stats[stat.spirit] + 40;
        end
    elseif bit.band(buffs1.spirit.flag, loadout.buffs1) == 0 and (spirit_buff or spirit_buff_aoe) then
        raw_stats_diff.stats[stat.spirit] = raw_stats_diff.stats[stat.spirit] - 40;
    end
    -- elixirs
    if bit.band(buffs1.greater_arcane_elixir.flag, loadout.buffs1) ~= 0 and
        loadout.always_assume_buffs and not loadout.buffs[buffs1.greater_arcane_elixir.id] then
        for i = 2, 7 do
            loadout.spell_dmg_by_school[i] = loadout.spell_dmg_by_school[i] + 35;
        end
    elseif bit.band(buffs1.greater_arcane_elixir.flag, loadout.buffs1) == 0 and 
        loadout.buffs[buffs1.greater_arcane_elixir.id] then

        for i = 2, 7 do
            loadout.spell_dmg_by_school[i] = loadout.spell_dmg_by_school[i] - 35;
        end
    end
    if bit.band(buffs1.runn_tum_tuber_surprise.flag, loadout.buffs1) ~= 0 and
        loadout.always_assume_buffs and not loadout.buffs[buffs1.runn_tum_tuber_surprise.id] then
        raw_stats_diff.stats[stat.int] = raw_stats_diff.stats[stat.int] + 10;
    elseif bit.band(buffs1.runn_tum_tuber_surprise.flag, loadout.buffs1) == 0 and 
        loadout.buffs[buffs1.runn_tum_tuber_surprise.id] then
        raw_stats_diff.stats[stat.int] = raw_stats_diff.stats[stat.int] - 10;
    end

    if bit.band(buffs1.toep.flag, loadout.buffs1) ~= 0 and not loadout.buffs[buffs1.toep.id] and 
        loadout.always_assume_buffs then

        for i = 2, 7 do
            loadout.spell_dmg_by_school[i] = loadout.spell_dmg_by_school[i] + 175;
        end
         loadout.healing_power = loadout.healing_power + 175;


    elseif bit.band(buffs1.toep.flag, loadout.buffs1) == 0 and loadout.buffs[buffs1.toep.id] then

        for i = 2, 7 do
            loadout.spell_dmg_by_school[i] = loadout.spell_dmg_by_school[i] - 175;
        end
         loadout.healing_power = loadout.healing_power - 175;
        
    end

    if bit.band(buffs2.zandalarian_hero_charm.flag, loadout.buffs2) ~= 0 and 
            not loadout.buffs[buffs2.zandalarian_hero_charm.id] and loadout.always_assume_buffs then

        for i = 2, 7 do
            loadout.spell_dmg_by_school[i] = loadout.spell_dmg_by_school[i] + 17*12 ;
        end
         loadout.healing_power = loadout.healing_power + 34*12;


    elseif bit.band(buffs2.zandalarian_hero_charm.flag, loadout.buffs2) == 0 and 
            loadout.buffs[buffs2.zandalarian_hero_charm.id] then

        local stacks = loadout.buffs[buffs2.zandalarian_hero_charm.id].count;

        for i = 2, 7 do
            loadout.spell_dmg_by_school[i] = loadout.spell_dmg_by_school[i] - 17*stacks;
        end
         loadout.healing_power = loadout.healing_power - 34*stacks;
    end

    if bit.band(buffs2.flask_of_supreme_power.flag, loadout.buffs2) ~= 0 and
        loadout.always_assume_buffs and not loadout.buffs[buffs2.flask_of_supreme_power.id] then
        for i = 2, 7 do
            loadout.spell_dmg_by_school[i] = loadout.spell_dmg_by_school[i] + 150;
        end
    elseif bit.band(buffs2.flask_of_supreme_power.flag, loadout.buffs2) == 0 and 
        loadout.buffs[buffs2.flask_of_supreme_power.id] then

        for i = 2, 7 do
            loadout.spell_dmg_by_school[i] = loadout.spell_dmg_by_school[i] - 150;
        end
    end

    if bit.band(buffs2.nightfin.flag, loadout.buffs2) ~= 0 and 
        (loadout.buffs[buffs2.nightfin.id] or loadout.always_assume_buffs) then

        loadout.mp5 = loadout.mp5 + 8;
    end
    if bit.band(buffs2.flask_of_distilled_wisdom.flag, loadout.buffs2) ~= 0 and
        (loadout.always_assume_buffs and not loadout.buffs[buffs2.flask_of_distilled_wisdom.id]) then

        loadout.mana = loadout.mana + 2000;

    elseif bit.band(buffs2.flask_of_distilled_wisdom.flag, loadout.buffs2) == 0 and 
        loadout.buffs[buffs2.flask_of_distilled_wisdom.id] then
        loadout.mana = max(0, loadout.mana - 2000);
    end

    -- TARGET BUFFS
    if bit.band(target_buffs1.amplify_magic.flag, loadout.target_buffs1) ~= 0 then
        local heal_effect = 0;

        local amp = loadout.target_buffs[localized_spell_name("Amplify Magic")];
        if amp then
            if amp.id == 1008 then
                heal_effect = 30;
            elseif amp.id == 8455 then
                heal_effect = 60;
            elseif amp.id == 10169 then
                heal_effect = 100;
            elseif amp.id == 10170 then
                heal_effect = 150;
            end
        elseif loadout.always_assume_buffs  then
            -- no amplify, assume max rank
            -- TODO: maybe check for talents for improved effect and by buff caster src
            heal_effect = 150;
        end

        if (not loadout.target_friendly and loadout.has_target) or loadout.always_assume_buffs then
            for j = 2, 7 do 
                loadout.spell_dmg_by_school[j] = loadout.spell_dmg_by_school[j] + heal_effect/2;
            end
        end
        if  (loadout.target_friendly and loadout.has_target) or loadout.always_assume_buffs then
            loadout.healing_power = loadout.healing_power + heal_effect;
        end
    end
    if bit.band(target_buffs1.dampen_magic.flag, loadout.target_buffs1) ~= 0 then
        local heal_effect = 0;

        local damp = loadout.target_buffs[localized_spell_name("Dampen Magic")];
        if damp then
            if damp.id == 604 then
                heal_effect = 20;
            elseif damp.id == 8450 then
                heal_effect = 40;
            elseif damp.id == 8451 then
                heal_effect = 80;
            elseif damp.id == 10173 then
                heal_effect = 120;
            elseif damp.id == 10174 then
                heal_effect = 180;
            end
        elseif loadout.always_assume_buffs then

            -- no dampen, assume max rank
            -- TODO: maybe check for talents for improved effect and by buff caster src
            heal_effect = 180;
        end

        if (not loadout.target_friendly and loadout.has_target) or loadout.always_assume_buffs then
            for j = 2, 7 do 
                loadout.spell_dmg_by_school[j] = loadout.spell_dmg_by_school[j] - heal_effect/2;
            end
        end
        if  (loadout.target_friendly and loadout.has_target) or loadout.always_assume_buffs then
            loadout.healing_power = loadout.healing_power - heal_effect;
        end
    end
    -- TARGET DEBUFFS
    if bit.band(target_debuffs1.curse_of_the_elements.flag, loadout.target_debuffs1) ~= 0 then
        local fire_frost_dmg_taken = 0;
        local resi = 0;

        local cote = loadout.target_debuffs[localized_spell_name("Curse of the Elements")];
        if cote then
            if cote.id == 1490 then
                fire_frost_dmg_taken = 0.06;
                resi = 45;
            elseif cote.id == 11721 then
                fire_frost_dmg_taken = 0.08;
                resi = 60;
            elseif cote.id == 11722 then
                fire_frost_dmg_taken = 0.1;
                resi = 75;
            end
        elseif loadout.always_assume_buffs then
                fire_frost_dmg_taken = 0.1;
                resi = 75;
        end

        if (not loadout.target_friendly and loadout.has_target) or loadout.always_assume_buffs then
            loadout.target_spell_dmg_taken[magic_school.frost] = 
                loadout.target_spell_dmg_taken[magic_school.frost] + fire_frost_dmg_taken;
            loadout.target_spell_dmg_taken[magic_school.fire] = 
                loadout.target_spell_dmg_taken[magic_school.fire] + fire_frost_dmg_taken;
        end
    end
    if bit.band(target_debuffs1.nightfall.flag, loadout.target_debuffs1) ~= 0 and 
        (loadout.always_assume_buffs or 
        (loadout.target_debuffs[target_debuffs1.nightfall.id] and not loadout.target_friendly and loadout.has_target)) then

        for j = 2, 7 do 
            loadout.target_spell_dmg_taken[j] = loadout.target_spell_dmg_taken[j] + 0.15;
        end
    end
    if bit.band(target_debuffs1.curse_of_shadow.flag, loadout.target_debuffs1) ~= 0 then
        local arcane_shadow_dmg_taken = 0;
        local resi = 0;

        local cos = loadout.target_debuffs[localized_spell_name("Curse of Shadow")];
        if cos then
            if cos.id == 17862 then
                arcane_shadow_dmg_taken = 0.08;
                resi = 60;
            elseif cos.id == 17937 then
                arcane_shadow_dmg_taken = 0.1;
                resi = 75;
            end
        elseif loadout.always_assume_buffs then
                arcane_shadow_dmg_taken = 0.1;
                resi = 75;
        end

        if (not loadout.target_friendly and loadout.has_target) or loadout.always_assume_buffs then
            loadout.target_spell_dmg_taken[magic_school.arcane] = 
                loadout.target_spell_dmg_taken[magic_school.arcane] + arcane_shadow_dmg_taken;
            loadout.target_spell_dmg_taken[magic_school.shadow] = 
                loadout.target_spell_dmg_taken[magic_school.shadow] + arcane_shadow_dmg_taken;
        end
    end
end

local function apply_mage_buffs(loadout, raw_stats_diff)

    if bit.band(buffs1.arcane_power.flag, loadout.buffs1) ~= 0 and
        (loadout.always_assume_buffs or loadout.buffs[buffs1.arcane_power.id]) then
    
        for j = 2, 7 do 
            loadout.spell_dmg_mod_by_school[j] = loadout.spell_dmg_mod_by_school[j] + 0.3;
        end
        loadout.cost_mod = loadout.cost_mod - 0.3;
    end
    if bit.band(buffs1.mind_quickening_gem.flag, loadout.buffs1) ~= 0 and
        (loadout.always_assume_buffs or loadout.buffs[buffs1.mind_quickening_gem.id]) then

        loadout.haste_mod = loadout.haste_mod + 0.33;
    end
    if bit.band(buffs1.hazzrahs_charm_of_magic.flag, loadout.buffs1) ~= 0 and
        (loadout.always_assume_buffs or loadout.buffs[buffs1.hazzrahs_charm_of_magic.id]) then
        loadout.spell_crit_mod_by_school[magic_school.arcane] =
            loadout.spell_crit_mod_by_school[magic_school.arcane] + 0.5;
    end
    if bit.band(buffs2.mage_armor.flag, loadout.buffs2) ~= 0 and 
        (loadout.buffs[localized_spell_name("Mage Armor")] or loadout.always_assume_buffs) then

        loadout.regen_while_casting = loadout.regen_while_casting + 0.3; 
    end


end

local function apply_warlock_buffs(loadout, raw_stats_diff)
    -- hazza'rah's charm of destruction
    if bit.band(buffs1.hazzrahs_charm_of_destr.flag, loadout.buffs1) ~= 0  and 
        (loadout.always_assume_buffs or loadout.buffs[buffs1.hazzrahs_charm_of_destr.id]) then

        local destr = {"Shadow Bolt", "Searing Pain", "Soul Fire", "Hellfire", "Rain of Fire", "Immolate", "Shadowburn", "Conflagrate"};
        for k, v in pairs(destr) do
            destr[k] = localized_spell_name(v);
        end
    
        for k, v in pairs(destr) do
            if not loadout.ability_crit[v] then
                loadout.ability_crit[v] = 0;
            end
        end
        for k, v in pairs(destr) do
            loadout.ability_crit[v] = 
                loadout.ability_crit[v] + 0.1;
        end
    end
    -- amplify curse
    if bit.band(buffs1.amplify_curse.flag, loadout.buffs1) ~= 0 and
        (loadout.always_assume_buffs or loadout.buffs[buffs1.amplify_curse.id]) then

        local coa = localized_spell_name("Curse of Agony");
    
        if not loadout.ability_base_mod[coa] then
            loadout.ability_base_mod[coa] = 0;
        end
    
        loadout.ability_base_mod[coa] = 
            loadout.ability_base_mod[coa] + 0.5;
    
    end
    -- demonic sacrifice - succubus i.e. touch of shadow
    if bit.band(buffs1.demonic_sacrifice.flag, loadout.buffs1) ~= 0 and
       (loadout.always_assume_buffs or loadout.buffs[buffs1.demonic_sacrifice.id]) 
        then
        loadout.spell_dmg_mod_by_school[magic_school.shadow] = 
            loadout.spell_dmg_mod_by_school[magic_school.shadow] + 0.15;
    end
end

local function apply_paladin_buffs(loadout, raw_stats_diff)
    -- BUFFS

    if bit.band(buffs2.vengeance.flag, loadout.buffs2) ~= 0 and
        (loadout.always_assume_buffs or loadout.buffs[localized_spell_name("Vengeance")]) then

        local veng = loadout.buffs[localized_spell_name("Vengeance")];
        if veng then
            local amount = 0;
            if veng.id == 20049 then
                amount = 0.03;
            elseif veng.id == 20056 then
                amount = 0.06;
            elseif veng.id == 20057 then
                amount = 0.09;
            elseif veng.id == 20058 then
                amount = 0.12;
            elseif veng.id == 20059 then
                amount = 0.15;
            end
        else
            amount = 0.15;
        end
    
        loadout.spell_dmg_mod_by_school[magic_school.holy] = loadout.spell_dmg_mod_by_school[magic_school.holy] + amount;
    end
    -- grileks charm of valor

    -- TARGET BUFFS
    if class == "PALADIN" then
        if bit.band(target_buffs1.blessing_of_light.flag, loadout.target_buffs1) ~= 0 then

            local hl_effect = 0;
            local fh_effect = 0;

            local bol = loadout.target_buffs[localized_spell_name("Blessing of Light")];
            if bol then
                if bol.id == 19977 then
                    hl_effect = 210;
                    fh_effect = 60;
                elseif bol.id == 19978 then
                    hl_effect = 300;
                    fh_effect = 85;
                elseif bol.id == 19979 then
                    hl_effect = 400;
                    fh_effect = 115;
                end
            elseif loadout.always_assume_buffs then
                hl_effect = 400;
                fh_effect = 115;
            end

            if loadout.always_assume_buffs or (loadout.target_friendly and loadout.has_target) then
                if not loadout.ability_flat_add[localized_spell_name("Holy Light")] then
                    loadout.ability_flat_add[localized_spell_name("Holy Light")] = 0;
                end
                if not loadout.ability_flat_add[localized_spell_name("Flash of Light")] then
                    loadout.ability_flat_add[localized_spell_name("Flash of Light")] = 0;
                end
                loadout.ability_flat_add[localized_spell_name("Holy Light")] = 
                    loadout.ability_flat_add[localized_spell_name("Holy Light")] + hl_effect;
                loadout.ability_flat_add[localized_spell_name("Flash of Light")] = 
                    loadout.ability_flat_add[localized_spell_name("Flash of Light")] + fh_effect;
            end
        end
    end

    -- TARGET DEBUFFS
end

local function apply_priest_buffs(loadout, raw_stats_diff)
    -- shadow form
    if bit.band(buffs1.shadow_form.flag, loadout.buffs1) ~= 0 then
        loadout.spell_dmg_mod_by_school[magic_school.shadow] = 
            loadout.spell_dmg_mod_by_school[magic_school.shadow] + 0.15;
    end
    -- ST priest trinket
    if bit.band(buffs2.blessed_prayer_beads.flag, loadout.buffs2) ~= 0 and not loadout.buffs[buffs2.blessed_prayer_beads.id] and 
        loadout.always_assume_buffs then

         loadout.healing_power = loadout.healing_power + 190;

    elseif bit.band(buffs2.blessed_prayer_beads.flag, loadout.buffs2) == 0 and loadout.buffs[buffs2.blessed_prayer_beads.id] then

         loadout.healing_power = loadout.healing_power - 190;
    end
end

local function apply_shaman_buffs(loadout, raw_stats_diff)
    -- wushoolay's charm of spirits
    if bit.band(buffs1.wushoolays_charm_of_spirits.flag, loadout.buffs1) ~= 0 and 
       (loadout.always_assume_buffs or loadout.buffs[buffs1.wushoolays_charm_of_spirits.id]) then

        local ls = localized_spell_name("Lightning Shield");
        if not loadout.ability_base_mod[ls] then
            loadout.ability_base_mod[ls] = 0;
        end
        loadout.ability_base_mod[ls] = loadout.ability_base_mod[ls] + 1;
    end
    -- natural alignment crystal
    if bit.band(buffs2.natural_alignment_crystal.flag, loadout.buffs2) ~= 0 and
        (loadout.always_assume_buffs or loadout.buffs[buffs2.natural_alignment_crystal.id]) then
    
        for j = 2, 7 do 
            loadout.spell_dmg_mod_by_school[j] = loadout.spell_dmg_mod_by_school[j] + 0.2;
        end
        loadout.spell_heal_mod = loadout.spell_heal_mod + 0.2;
        loadout.cost_mod = loadout.cost_mod - 0.2;
    end
    -- target buffs
    if bit.band(target_buffs1.healing_way.flag, loadout.target_buffs1) ~= 0 then
        --(loadout.always_assume_buffs or loadout.buffs[target_buffs1.healing_way.id]) 

        local effect = 0;
        local healing_way = loadout.target_buffs[target_buffs1.healing_way.id];
        if healing_way then
            effect = healing_way.count * 0.06;
        elseif loadout.always_assume_buffs then
            effect = 3 * 0.06;
        end

        if loadout.always_assume_buffs or (loadout.target_friendly and loadout.has_target) then
            local hw = localized_spell_name("Healing Wave");
            if not loadout.ability_effect_mod[hw] then
                loadout.ability_effect_mod[hw] = 0;
            end
            loadout.ability_effect_mod[hw] = loadout.ability_effect_mod[hw] + effect;
        end
    end
end

local function apply_druid_buffs(loadout, raw_stats_diff)
    -- wushoolay's charm of nature
    if bit.band(buffs1.wushoolays_charm_of_nature.flag, loadout.buffs1) ~= 0 and
       (loadout.always_assume_buffs or loadout.buffs[buffs1.wushoolays_charm_of_nature.id]) then

        loadout.ability_cast_mod[localized_spell_name("Healing Touch")] =
            loadout.ability_cast_mod[localized_spell_name("Healing Touch")] + 0.4;
        
        local healing_abilities = {"Healing Touch", "Rejuvenation", "Regrowth", "Tranquility"};
    
        for k, v in pairs(healing_abilities) do
            healing_abilities[k] = localized_spell_name(v);
        end
    
        for k, v in pairs(healing_abilities) do
            if not loadout.ability_cost_mod[v] then
                loadout.ability_cost_mod[v] = 0;
            end
        end
        for k, v in pairs(healing_abilities) do
            loadout.ability_cost_mod[v] = loadout.ability_cost_mod[v] + 0.05;
        end
    end
end

local function apply_troll_buffs(loadout, raw_stats_diff)

    if bit.band(buffs1.berserking.flag, loadout.buffs1) ~= 0 then
        if loadout.buffs[buffs1.berserking.id] then
    
            if not loadout.berserking_snapshot then
    
                local max_hp = UnitHealthMax("player");
                local hp = UnitHealth("player");
                local hp_perc = 0;
                if max_hp ~= 0 then
                    hp_perc = hp/max_hp;
                end
    
                -- at 100% hp: 10 % haste
                -- at less or equal than 40% hp: 30 % haste
                -- interpolate between 10% and 30% haste at 40% - 100% hp
                local haste_mod = 0.1 + 0.2 * (1 -((math.max(0.4, hp_perc) - 0.4)*(5/3)));

                loadout.berserking_snapshot = haste_mod;
                sw_berserking_snapshot = haste_mod;
            end
            loadout.haste_mod = loadout.haste_mod + loadout.berserking_snapshot;
        
        elseif loadout.always_assume_buffs then
            -- apply 10%
            if loadout.berserking_snapshot then
                loadout.haste_mod = loadout.haste_mod + loadout.berserking_snapshot;
            else
                loadout.haste_mod = loadout.haste_mod + 0.1;
            end
        else
            loadout.berserking_snapshot = nil;
            sw_berserking_snapshot = nil;
        end
    end
    
    if bit.band(buffs2.troll_vs_beast.flag, loadout.buffs2) ~= 0 and 
        ((not loadout.target_friendly and loadout.has_target and loadout.target_type == "Beast") or loadout.always_assume_buffs) then

        loadout.dmg_mod = loadout.dmg_mod + 0.05;
    end
end

local function apply_buffs(loadout)

    local stats_diff_loadout = empty_loadout();

    if class == "MAGE" then
        apply_mage_buffs(loadout, stats_diff_loadout);
    elseif class == "PRIEST" then
        apply_priest_buffs(loadout, stats_diff_loadout);
    elseif class == "WARLOCK" then
        apply_warlock_buffs(loadout, stats_diff_loadout);
    elseif class == "SHAMAN" then
        apply_shaman_buffs(loadout, stats_diff_loadout);
    elseif class == "DRUID" then
        apply_druid_buffs(loadout, stats_diff_loadout);
    elseif class == "PALADIN" then
        apply_paladin_buffs(loadout, stats_diff_loadout);
    end

    if class == "MAGE" or class == "PRIEST" or class == "WARLOCK" or
       class == "SHAMAN" or class == "DRUID" or class == "PALADIN" then

        apply_caster_buffs(loadout, stats_diff_loadout);    

        if class == "PRIEST" or class == "WARLOCK" then
            apply_caster_shadow_buffs(loadout, stats_diff_loadout);    
        end
        if class == "MAGE" or class == "WARLOCK" or class == "SHAMAN" then
            apply_caster_fire_buffs(loadout, stats_diff_loadout);    
        end
        if class == "MAGE" or class == "SHAMAN" then
            apply_caster_frost_buffs(loadout, stats_diff_loadout);    
        end
        if class == "DRUID" or class == "SHAMAN" then
            apply_caster_nature_buffs(loadout, stats_diff_loadout);    
        end
    end

    apply_general_buffs(loadout, stats_diff_loadout);
    if faction == "Horde" then
        apply_horde_buffs(loadout, stats_diff_loadout);
    else
        apply_ally_buffs(loadout, stats_diff_loadout);
    end
    if race == "Troll" then
        apply_troll_buffs(loadout, stats_diff_loadout);
    end

    loadout = loadout_add(loadout, stats_diff_loadout);

    return loadout;
end

local function default_loadout()

   local loadout = empty_loadout();

   loadout.name = "Default";

   loadout.lvl = UnitLevel("player");
   loadout.target_lvl = loadout.lvl + 3;
   loadout.is_dynamic_loadout = true;
   loadout.talents_code = wowhead_talent_code();
   loadout.always_assume_buffs = false;
   loadout.use_dynamic_target_lvl = true;
   loadout.has_target = false;

   loadout.stats = {};
   for i = 1, 5 do
       local _, stat, _, _ = UnitStat("player", i);

       loadout.stats[i] =  stat;
   end
   loadout.mana = 0;
   loadout.extra_mana = 0;

   for i = 1, 7 do
       loadout.spell_dmg_by_school[i] = GetSpellBonusDamage(i);
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
       loadout.spell_dmg_hit_by_school[i] = spell_hit;
   end

   loadout.healing_power = GetSpellBonusHealing();
   loadout.healing_crit = min_crit;

   loadout.spell_crit_mod_by_school = {1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5};

   loadout.buffs1 = bit.bnot(0);
   loadout.buffs2 = bit.bnot(0);
   loadout.target_buffs1 = bit.bnot(0);
   loadout.target_debuffs1 = bit.bnot(0);

   --loadout = apply_talents(loadout);

   --loadout = apply_set_bonuses(loadout);

   --loadout = detect_buffs(loadout);

   return loadout;
end

local function dynamic_loadout(base_loadout)

   base_loadout.talents_code  = wowhead_talent_code();

   local loadout = loadout_copy(base_loadout);

   loadout.lvl = UnitLevel("player");

   loadout.stats = {};
   for i = 1, 5 do
       local _, stat, _, _ = UnitStat("player", i);

       loadout.stats[i] =  stat;
   end

   loadout.mana = UnitPower("player", 0);

   for i = 1, 7 do
       loadout.spell_dmg_by_school[i] = GetSpellBonusDamage(i);
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
       loadout.spell_dmg_hit_by_school[i] = spell_hit;
   end

   loadout.healing_power = GetSpellBonusHealing();
   loadout.healing_crit = min_crit;

   loadout.berserking_snapshot = sw_berserking_snapshot;

   loadout.spell_crit_mod_by_school = {1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5};

   if UnitExists("target") then
       loadout.has_target = true; 

       loadout.target_friendly = UnitIsFriend("player", "target");
       -- TODO: returns localized name.. so won't work for non-english clients....
       loadout.target_type = UnitCreatureType("target");

       if loadout.use_dynamic_target_lvl and not loadout.target_friendly then
           local target_lvl = UnitLevel("target");
           if target_lvl == -1 then
               loadout.target_lvl = loadout.lvl + 3;
           else
               loadout.target_lvl = target_lvl;
           end
       end
   else
       loadout.has_target = false; 
   end

   -- talents may not be applied here as they are parameterized
   --loadout = apply_talents(loadout);

   loadout = remove_dynamic_stats_from_talents(loadout);

   loadout = apply_set_bonuses(loadout);

   loadout = detect_buffs(loadout);

   return loadout;
end

local function static_loadout_from_dynamic(base_loadout)
    
   local loadout = loadout_copy(base_loadout);

   loadout.lvl = UnitLevel("player");

   loadout.stats = {};
   for i = 1, 5 do
       local _, stat, _, _ = UnitStat("player", i);

       loadout.stats[i] =  stat;
   end

   loadout.mana = UnitPowerMax("player", 0);
   loadout.talents_code = wowhead_talent_code();
   loadout.extra_mana = base_loadout.extra_mana;

   for i = 1, 7 do
       loadout.spell_dmg_by_school[i] = GetSpellBonusDamage(i);
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
       loadout.spell_dmg_hit_by_school[i] = spell_hit;
   end

   loadout.healing_power = GetSpellBonusHealing();
   loadout.healing_crit = min_crit;

   loadout.berserking_snapshot = sw_berserking_snapshot;

   loadout.spell_crit_mod_by_school = {1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5};

   if UnitExists("target") then
       loadout.has_target = true; 

       loadout.target_friendly = UnitIsFriend("player", "target");
       -- TODO: returns localized name.. so won't work for non-english clients....
       loadout.target_type = UnitCreatureType("target");

       if loadout.use_dynamic_target_lvl and not loadout.target_friendly then
           local target_lvl = UnitLevel("target");
           if target_lvl == -1 then
               loadout.target_lvl = loadout.lvl + 3;
           else
               loadout.target_lvl = target_lvl;
           end
       end
   else
       loadout.has_target = false; 
   end

   -- talents may not be applied here as they are parameterized
   --loadout = apply_talents(loadout);
   loadout = remove_dynamic_stats_from_talents(loadout);

   loadout = apply_set_bonuses(loadout);

   loadout = detect_buffs(loadout);

   return loadout;
end

local function empty_loadout_with_buffs(loadout_with_buffs)

    -- snapshot loadout
    local loadout = empty_loadout();

    loadout.name = loadout_with_buffs.name;
    loadout.lvl = loadout_with_buffs.lvl;
    loadout.target_lvl = loadout_with_buffs.target_lvl;

    -- setting mana as max mana, is this fine?

    loadout.always_assume_buffs = loadout_with_buffs.always_assume_buffs;
    loadout.is_dynamic_loadout = loadout_with_buffs.is_dynamic_loadout;
    loadout.use_dynamic_target_lvl = loadout_with_buffs.use_dynamic_target_lvl;
    loadout.has_target = loadout_with_buffs.has_target;

    for k, v in pairs(loadout_with_buffs.buffs) do
        loadout.buffs[k] = v;
    end
    for k, v in pairs(loadout_with_buffs.target_buffs) do
        loadout.target_buffs[k] = v;
    end
    for k, v in pairs(loadout_with_buffs.target_debuffs) do
        loadout.target_debuffs[k] = v;
    end

    loadout.buffs1 = loadout_with_buffs.buffs1;
    loadout.buffs2 = loadout_with_buffs.buffs2;
    loadout.target_buffs1 = loadout_with_buffs.target_buffs1;
    loadout.target_debuffs1 = loadout_with_buffs.target_debuffs1;

    loadout.target_friendly = loadout_with_buffs.target_friendly;
    loadout.target_type = loadout_with_buffs.target_type;

    loadout.berserking_snapshot = loadout_with_buffs.berserking_snapshot;

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
    print("Loadout: "..loadout.name);
    print(string.format("level:%d, target_level: %d", loadout.lvl, loadout.target_lvl));
    print("dynamic: ", loadout.is_dynamic_loadout);
    print("always_apply_buffs: ", loadout.always_assume_buffs);
    print("talents: ", wowhead_talent_link(loadout.talents_code));
    print("buffs1 flags: ", loadout.buffs1);
    print("buffs2 flags: ", loadout.buffs2);
    print("target buffs flags: ", loadout.target_buffs1);
    print("target debuffs flags: ", loadout.target_debuffs1);

    print(string.format("str: %d, agi: %d, stam: %d, int: %d, spirit: %d",
          loadout.stats[1],
          loadout.stats[2],
          loadout.stats[3],
          loadout.stats[4],
          loadout.stats[5]));
    print("mana", loadout.mana);
    print("extra mana gained from consumes (pots, runes)", loadout.extra_mana);
    print("mana regen while casting ratio:", loadout.regen_while_casting);
    print("mp5 from gear/buffs", loadout.mp5);
    print("heal: "..loadout.healing_power..", heal_crit: ".. string.format("%.3f", loadout.healing_crit));
    print(string.format("spell power schools: holy %d, fire %d, nature %d, frost %d, shadow %d, arcane %d",
          loadout.spell_dmg_by_school[2],
          loadout.spell_dmg_by_school[3],
          loadout.spell_dmg_by_school[4],
          loadout.spell_dmg_by_school[5],
          loadout.spell_dmg_by_school[6],
          loadout.spell_dmg_by_school[7]));
    print("spell heal mod base: ", loadout.spell_heal_mod_base);
    print("spell heal mod: ", loadout.spell_heal_mod);
    print(string.format("spell crit schools: holy %.3f, fire %.3f, nature %.3f, frost %.3f,shadow  %.3f, arcane %.3f", 
                        loadout.spell_crit_by_school[2],
                        loadout.spell_crit_by_school[3],
                        loadout.spell_crit_by_school[4],
                        loadout.spell_crit_by_school[5],
                        loadout.spell_crit_by_school[6],
                        loadout.spell_crit_by_school[7]));
    print(string.format("spell crit dmg mod schools: holy %.3f, fire %.3f, nature %.3f, frost %.3f, shadow %.3f arcane %.3f", 
                        loadout.spell_crit_mod_by_school[2],
                        loadout.spell_crit_mod_by_school[3],
                        loadout.spell_crit_mod_by_school[4],
                        loadout.spell_crit_mod_by_school[5],
                        loadout.spell_crit_mod_by_school[6],
                        loadout.spell_crit_mod_by_school[7]));
    print(string.format("spell hit schools: holy %.3f, fire %.3f, nature %.3f, frost %.3f, shadow %.3f, arcane %.3f", 
                        loadout.spell_dmg_hit_by_school[2],
                        loadout.spell_dmg_hit_by_school[3],
                        loadout.spell_dmg_hit_by_school[4],
                        loadout.spell_dmg_hit_by_school[5],
                        loadout.spell_dmg_hit_by_school[6],
                        loadout.spell_dmg_hit_by_school[7]));
    print(string.format("spell mod schools: holy %.3f, fire %.3f, nature %.3f, frost %.3f, shadow %.3f, arcane %.3f", 
                        loadout.spell_dmg_mod_by_school[2],
                        loadout.spell_dmg_mod_by_school[3],
                        loadout.spell_dmg_mod_by_school[4],
                        loadout.spell_dmg_mod_by_school[5],
                        loadout.spell_dmg_mod_by_school[6],
                        loadout.spell_dmg_mod_by_school[7]));

    print(string.format("target spell dmg taken mod schools: holy %.3f, fire %.3f, nature %.3f, frost %.3f, shadow %.3f, arcane %.3f", 
                        loadout.target_spell_dmg_taken[2],
                        loadout.target_spell_dmg_taken[3],
                        loadout.target_spell_dmg_taken[4],
                        loadout.target_spell_dmg_taken[5],
                        loadout.target_spell_dmg_taken[6],
                        loadout.target_spell_dmg_taken[7]));

    print(string.format("spell haste mod: %.3f", loadout.haste_mod));
    print(string.format("spell cost mod: %.3f", loadout.cost_mod));
    print(string.format("spell dmg mod : %.3f", loadout.dmg_mod));
    print(string.format("stat mods : %.3f, %.3f, %.3f, %.3f, %.3f",
                        loadout.stat_mod[1],
                        loadout.stat_mod[2],
                        loadout.stat_mod[3],
                        loadout.stat_mod[4],
                        loadout.stat_mod[5]));
    print(string.format("max mana mod : %.3f", loadout.mana_mod));


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

    for k, v in pairs(loadout.ability_base_mod) do
        print("base mod: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_effect_mod) do
        print("effect mod: ", k, string.format("%.3f", v));
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
    for k, v in pairs(loadout.ability_sp) do
        print("ability extra sp: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_flat_add) do
        print("ability flat extra effect: ", k, string.format("%.3f", v));
    end
end

local function level_scaling(lvl)
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
    elseif spell_name == localized_spell_name("Searing Totem") then
        direct_coef = 0.08;
        ot_coef = 0.0;
    elseif spell_name == localized_spell_name("Insect Swarm") then
        -- insect swarm seems to have 15/15 scaling isntead of 12/15
        direct_coef = 0.0;
        ot_coef = 1.0;
    elseif spell_name == localized_spell_name("Entangling Roots") then
        -- scales of cast time, not ot duration
        direct_coef = 0.0;
        ot_coef = math.min(1.0, math.max(1.5/3.5, spell_info.cast_time/3.5));
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
        direct_coef = direct_coef * 0.7;
    elseif spell_name == localized_spell_name("Mind Flay") then
        ot_coef = 0.45;
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

    direct_coef = direct_coef * level_scaling(spell_info.lvl_req);
    ot_coef = ot_coef * level_scaling(spell_info.lvl_req);
    
    return direct_coef, ot_coef;
end

local function spell_info(base_min, base_max,
                          base_ot, ot_freq, ot_dur, ot_extra_ticks,
                          cast_time, sp, flat_direct_addition,
                          crit, ot_crit, crit_mod, hit,
                          target_vuln_mod, global_mod, mod, base_mod,
                          direct_coef, ot_coef,
                          cost, school,
                          spell_name, loadout)


    -- improved immolate only works on direct damage -,-
    local base_mod_before_improved_immolate = base_mod;
    if spell_name == localized_spell_name("Immolate") then
        base_mod = base_mod + loadout.improved_immolate * 0.05;
    end

    local min_noncrit_if_hit = 
        (base_min * base_mod + sp * direct_coef + flat_direct_addition) * mod * target_vuln_mod * global_mod;
    local max_noncrit_if_hit = 
        (base_max * base_mod + sp * direct_coef + flat_direct_addition) * mod * target_vuln_mod * global_mod;

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

        ot = (base_ot_tick + ot_coef_per_tick * sp) * ot_ticks * mod * target_vuln_mod * global_mod;

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
       spell_name == localized_spell_name("Mind Flay") or 
       spell_name == localized_spell_name("Starshards") then 

        local channel_ratio_time_lost_to_miss = 1 - (ot_dur - 1.5)/ot_dur;
        expected_ot = expectation_ot_if_hit - (1 - hit) * channel_ratio_time_lost_to_miss * expectation_ot_if_hit;
    end

    local expectation_direct = (min + max) / 2;
    if spell_name == localized_spell_name("Searing Totem") then
        expectation_direct = expectation_direct * ot_dur/ot_freq;
    end
      
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

    if class == "MAGE" and base_min > 0 and loadout.num_set_pieces[set_tiers.pve_2] >= 8 then
        cast_time = cast_time - math.max(0, (cast_time - 1.5)) * 0.1;
    end

    if loadout.improved_shadowbolt ~= 0 and spell_name == localized_spell_name("Shadow Bolt") then
        -- a reasonably good, generous estimate, 
        -- assumes all other warlocks in raid/party have same crit chance/improved shadowbolt talent
        -- and just spam shadow bolt allt fight, other abilities like shadowburn/mind blast will skew this estimate
        local sb_dmg_bonus = loadout.improved_shadowbolt * 0.04;
        local improved_sb_uptime = 1 - math.pow(1-crit, 4);
        local sb_dmg_taken_mod = sb_dmg_bonus * improved_sb_uptime;
        local new_vuln_mod = (target_vuln_mod + sb_dmg_taken_mod)/target_vuln_mod;

        expectation = expectation * new_vuln_mod;
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

    -- improved shadow bolt invuln mod has been ignored before for shadow bolt only
    -- and inserted now if relevant to show accurate dmg numbers
    -- expected dmg, dps, and stat weights still assume uptime based on crit instead of 100% uptime
    if bit.band(target_debuffs1.improved_shadow_bolt.flag, loadout.target_debuffs1) ~= 0 and 
        (loadout.always_assume_buffs or 
        (loadout.target_debuffs[target_debuffs1.improved_shadow_bolt.id] and not loadout.target_friendly and loadout.has_target)) and 
        spell_name == localized_spell_name("Shadow Bolt") then

        local shadowbolt_vuln_mod = (target_vuln_mod + 0.2)/target_vuln_mod;

        min_noncrit_if_hit = min_noncrit_if_hit * shadowbolt_vuln_mod;
        max_noncrit_if_hit = max_noncrit_if_hit * shadowbolt_vuln_mod;

        min_crit_if_hit = min_crit_if_hit * shadowbolt_vuln_mod;
        max_crit_if_hit = max_crit_if_hit * shadowbolt_vuln_mod;
    end

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

        effect_per_cost = expectation/cost,
        cost_per_sec = cost / cast_time,

        cast_time = cast_time,

        cost = cost
    };
end

local function loadout_stats_for_spell(spell_data, spell_name, loadout)

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
    elseif bit.band(spell_data.flags, spell_flags.over_time_crit) ~= 0 then
        ot_crit = crit;
        ot_crit_delta_1 = crit_delta_1;
    elseif spell_data.base_min == 0 then
        crit = 0;
        crit_delta_1 = 0;
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

    if spell_name == localized_spell_name("Flash Heal") or spell_name == localized_spell_name("Regrowth") or 
        spell_name == localized_spell_name("Immolate") then
        -- from set bonuses, flash heal and regrowth, immolate seem to be the only exceptions to ignore 1.5 gcd on all spells

        -- TODO: make sure that this branch isn't taken for these spells without the set bonuses, e.g. with 30% berserk
        cast_speed = math.max(cast_speed, 1.3);
    else
        cast_speed = math.max(cast_speed, 1.5);
    end

    local target_vuln_mod = 1;
    local global_mod = 1; 
    local spell_mod = 1;
    local spell_mod_base = 1;
    local flat_addition = 0;

    if not loadout.ability_base_mod[spell_name] then
        loadout.ability_base_mod[spell_name] = 0;
    end
    if not loadout.ability_effect_mod[spell_name] then
        loadout.ability_effect_mod[spell_name] = 0;
    end

    -- regarding blessing of light effect
    if loadout.ability_flat_add[spell_name] and class == "PALADIN" then

        local scaling_coef_by_lvl = 1;
        if spell_data.lvl_req == 1 then -- rank 1 holy light
            scaling_coef_by_lvl = 0.2;
        elseif spell_data.lvl_req == 6 then -- rank 2 holy light
            scaling_coef_by_lvl = 0.4;
        elseif spell_data.lvl_req == 14 then -- rank 3 holy light
            scaling_coef_by_lvl = 0.7;
        end
        
        flat_addition = 
            flat_addition + loadout.ability_flat_add[spell_name] * scaling_coef_by_lvl;
    end

    if spell_name == localized_spell_name("Shadow Bolt") and 
        bit.band(target_debuffs1.improved_shadow_bolt.flag, loadout.target_debuffs1) ~= 0 and 
        ((not loadout.target_friendly and loadout.has_target and loadout.target_debuffs[target_debuffs1.improved_shadow_bolt.id]) or 
        loadout.always_assume_buffs) then


        -- undo for shadow bolt in order to get real average stat weights for crit, which increases buff uptime
        loadout.target_spell_dmg_taken[magic_school.shadow] = 
            loadout.target_spell_dmg_taken[magic_school.shadow] - 0.2;
    end

    if bit.band(spell_data.flags, spell_flags.heal) ~= 0 then
        spell_mod = 1 + loadout.spell_heal_mod;

        --if spell_name ~= localized_spell_name("Holy Nova") then
            -- holy nova actually doesnt get bonus healing on base, maybe because its both dmg and heal
        spell_mod_base = 1 + loadout.spell_heal_mod_base;
        --end
        spell_mod_base = spell_mod_base + loadout.ability_base_mod[spell_name];
        spell_mod = spell_mod + loadout.ability_effect_mod[spell_name];
    else
        target_vuln_mod = target_vuln_mod + loadout.target_spell_dmg_taken[spell_data.school];
        global_mod = global_mod + loadout.dmg_mod;
        spell_mod_base = spell_mod_base + loadout.ability_base_mod[spell_name];
        spell_mod = spell_mod * (1 + loadout.spell_dmg_mod_by_school[spell_data.school]);
        spell_mod = spell_mod * (1 + loadout.ability_effect_mod[spell_name]);
    end


    local extra_hit = 0;
    if loadout.ability_hit[spell_name] then
        extra_hit = loadout.spell_dmg_hit_by_school[spell_data.school] + loadout.ability_hit[spell_name];
    else
        extra_hit = loadout.spell_dmg_hit_by_school[spell_data.school];
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
        spell_power = loadout.healing_power;
    else
        spell_power = loadout.spell_dmg_by_school[spell_data.school];
    end

    if loadout.ability_sp[spell_name] then
        spell_power = spell_power + loadout.ability_sp[spell_name];
    end

    local cost = spell_data.cost;
    local cost_mod = 1 - loadout.cost_mod;

    if loadout.ability_cost_mod[spell_name] then
        cost_mod = cost_mod - loadout.ability_cost_mod[spell_name]
    end
    if loadout.illumination ~= 0  and bit.band(spell_data.flags, spell_flags.heal) ~= 0 then
        cost_mod = cost_mod - loadout.healing_crit * (loadout.illumination * 0.2);
    end

    if loadout.master_of_elements ~= 0 and 
       (spell_data.school == magic_school.fire or spell_data.school == magic_school.frost) ~= 0 then
        cost_mod = cost_mod - loadout.spell_crit_by_school[spell_data.school] * (loadout.master_of_elements * 0.1);
    end

    cost = cost * cost_mod;

    -- the game seems to round cost up/down to the nearest
    cost = tonumber(string.format("%.0f", cost));

    local direct_coef, over_time_coef = spell_coef(spell_data, spell_name);

    return {
        extra_ticks = extra_ticks,
        cast_speed = cast_speed,
        spell_power = spell_power,
        flat_direct_addition = flat_addition,
        crit = crit,
        crit_delta_1 = crit_delta_1,
        ot_crit = ot_crit,
        ot_crit_delta_1 = ot_crit_delta_1,
        spell_crit_mod = spell_crit_mod,
        hit = hit,
        hit_delta_1 = hit_delta_1,
        target_vuln_mod = target_vuln_mod,
        global_mod = global_mod,
        spell_mod = spell_mod,
        spell_mod_base = spell_mod_base,
        direct_coef = direct_coef,
        over_time_coef = over_time_coef,
        cost = cost
    };
end

local function spell_info_from_loadout_stats(spell_data, spell_name, loadout)

    local stats = loadout_stats_for_spell(spell_data, spell_name, loadout);

    return spell_info(
       spell_data.base_min, spell_data.base_max, 
       spell_data.over_time, spell_data.over_time_tick_freq, spell_data.over_time_duration, stats.extra_ticks,
       stats.cast_speed,
       stats.spell_power,
       stats.flat_direct_addition,
       max(0, min(1, stats.crit)),
       max(0, min(1, stats.ot_crit)),
       stats.spell_crit_mod,
       stats.hit,
       stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_mod_base,
       stats.direct_coef, stats.over_time_coef,
       stats.cost, spell_data.school,
       spell_name, loadout
    );
end

local function evaluate_spell(stats, spell_data, spell_name, loadout)

    local spell_effect = spell_info(
       spell_data.base_min, spell_data.base_max, 
       spell_data.over_time, spell_data.over_time_tick_freq, spell_data.over_time_duration, stats.extra_ticks,
       stats.cast_speed,
       stats.spell_power,
       stats.flat_direct_addition,
       max(0, min(1, stats.crit)),
       max(0, min(1, stats.ot_crit)),
       stats.spell_crit_mod,
       stats.hit,
       stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_mod_base,
       stats.direct_coef, stats.over_time_coef,
       stats.cost, spell_data.school,
       spell_name, loadout
    );

    local dmg_1_extra_sp = spell_info(
        spell_data.base_min, spell_data.base_max, 
        spell_data.over_time, spell_data.over_time_tick_freq, spell_data.over_time_duration, stats.extra_ticks,
        stats.cast_speed,
        stats.spell_power + 1,
        stats.flat_direct_addition,
        max(0, min(1, stats.crit)),
        max(0, min(1, stats.ot_crit)),
        stats.spell_crit_mod,
        stats.hit,
        stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_mod_base,
        stats.direct_coef, stats.over_time_coef,
        stats.cost, spell_data.school,
        spell_name, loadout
    );
    local spell_effect_extra_1crit = spell_info(
        spell_data.base_min, spell_data.base_max, 
        spell_data.over_time, spell_data.over_time_tick_freq, spell_data.over_time_duration, stats.extra_ticks,
        stats.cast_speed,
        stats.spell_power,
        stats.flat_direct_addition,
        max(0, min(1, stats.crit_delta_1)),
        max(0, min(1, stats.ot_crit_delta_1)),
        stats.spell_crit_mod,
        stats.hit,
        stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_mod_base,
        stats.direct_coef, stats.over_time_coef,
        stats.cost, spell_data.school,
        spell_name, loadout
    );
    local spell_effect_extra_1hit = spell_info(
        spell_data.base_min, spell_data.base_max, 
        spell_data.over_time, spell_data.over_time_tick_freq, spell_data.over_time_duration, stats.extra_ticks,
        stats.cast_speed,
        stats.spell_power,
        stats.flat_direct_addition,
        max(0, min(1, stats.crit)),
        max(0, min(1, stats.ot_crit)),
        stats.spell_crit_mod,
        stats.hit_delta_1,
        stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_mod_base,
        stats.direct_coef, stats.over_time_coef,
        stats.cost, spell_data.school,
        spell_name, loadout
    );

    local spell_effect_1sp_delta = dmg_1_extra_sp.expectation - spell_effect.expectation;
    local spell_effect_1crit_delta = spell_effect_extra_1crit.expectation - spell_effect.expectation;
    local spell_effect_1hit_delta  = spell_effect_extra_1hit.expectation - spell_effect.expectation;

    local sp_per_crit = spell_effect_1crit_delta/(spell_effect_1sp_delta);
    local sp_per_hit = spell_effect_1hit_delta/(spell_effect_1sp_delta);

    return {
        effect_per_sp = spell_effect_1sp_delta,
        sp_per_crit = sp_per_crit,
        sp_per_hit = sp_per_hit,

        spell_data = spell_effect,
        spell_data_1_sp = dmg_1_extra_sp,
        spell_data_1_crit = spell_effect_extra_1crit,
        spell_data_1_hit = spell_effect_extra_1hit
    };
end

local function race_to_the_bottom_sim(spell_effect, mp5, spirit, mana, loadout)

    local num_casts = 0;
    local effect = 0;

    local mp2 = 0; 
    if class == "PRIEST" or class == "MAGE" then
        mp2 = (13 + spirit/4) * loadout.regen_while_casting + (mp5/5)*2;
    elseif class == "DRUID" or class == "SHAMAN" or class == "PALADIN" then
        mp2 = (15 + spirit/5) * loadout.regen_while_casting + (mp5/5)*2;
    elseif class == "WARLOCK" then
        mp2 = (8 + spirit/4) * loadout.regen_while_casting + (mp5/5)*2;
    end

    local mp1 = mp2/2;

    local resource_loss_per_sec = spell_effect.cost/spell_effect.cast_time - mp1;

    if resource_loss_per_sec <= 0 then
        -- divide by 0 party!
        return {
            num_casts = 1/0,
            effect = 1/0,
            time_until_oom = 1/0,
            mp2 = mp2

        };
    end

    local time_until_oom = mana/resource_loss_per_sec; 
    local num_casts = time_until_oom/spell_effect.cast_time;
    local effect_until_oom = num_casts * spell_effect.expectation;
    
    return {
        num_casts = num_casts,
        effect = effect_until_oom,
        time_until_oom = time_until_oom,
        mp2 = mp2
    };
end

local function race_to_the_bottom_sim_default(spell_effect, loadout)

    return race_to_the_bottom_sim(
        spell_effect, loadout.mp5, loadout.stats[stat.spirit], 
        loadout.mana + loadout.extra_mana, loadout
    );
end

local function race_to_the_bottom_stat_weights(
        stats, spell_data, spell_name, spell_effect_normal, spell_effect_1_sp, spell_effect_1_crit, spell_effect_1_hit, loadout)

    local until_oom_normal = 
        race_to_the_bottom_sim(spell_effect_normal, loadout.mp5, loadout.stats[stat.spirit], loadout.mana + loadout.extra_mana, loadout);
    local until_oom_1_sp = 
        race_to_the_bottom_sim(spell_effect_1_sp, loadout.mp5, loadout.stats[stat.spirit], loadout.mana + loadout.extra_mana, loadout);
    local until_oom_1_crit = 
        race_to_the_bottom_sim(spell_effect_1_crit, loadout.mp5, loadout.stats[stat.spirit], loadout.mana + loadout.extra_mana, loadout);
    local until_oom_1_hit = 
        race_to_the_bottom_sim(spell_effect_1_hit, loadout.mp5, loadout.stats[stat.spirit], loadout.mana + loadout.extra_mana, loadout);
    local until_oom_1_mp5 = 
        race_to_the_bottom_sim(spell_effect_normal, loadout.mp5 + 1, loadout.stats[stat.spirit], loadout.mana + loadout.extra_mana, loadout);

    local loadout_1_spirit = empty_loadout();
    loadout_1_spirit.stats[stat.spirit] = 1;
    local loadout_added_1_spirit = loadout_add(loadout, loadout_1_spirit);
    local stats_1_spirit_added = loadout_stats_for_spell(spell_data, spell_name, loadout_added_1_spirit);
    local added_1_spirit_effect = spell_info(
       spell_data.base_min, spell_data.base_max, 
       spell_data.over_time, spell_data.over_time_tick_freq, spell_data.over_time_duration, stats.extra_ticks,
       stats_1_spirit_added.cast_speed,
       stats_1_spirit_added.spell_power,
       stats_1_spirit_added.flat_direct_addition,
       max(0, min(1, stats_1_spirit_added.crit)),
       max(0, min(1, stats_1_spirit_added.ot_crit)),
       stats_1_spirit_added.spell_crit_mod,
       stats_1_spirit_added.hit,
       stats_1_spirit_added.target_vuln_mod, 
       stats_1_spirit_added.global_mod, 
       stats_1_spirit_added.spell_mod, 
       stats_1_spirit_added.spell_mod_base,
       stats_1_spirit_added.direct_coef, 
       stats_1_spirit_added.over_time_coef,
       stats_1_spirit_added.cost, spell_data.school,
       spell_name, loadout_added_1_spirit
    );

    local until_oom_1_spirit = race_to_the_bottom_sim(
        added_1_spirit_effect, 
        loadout_added_1_spirit.mp5, 
        loadout_added_1_spirit.stats[stat.spirit], 
        loadout_added_1_spirit.mana + loadout.extra_mana, 
        loadout_added_1_spirit);

    local loadout_1_int = empty_loadout();
    loadout_1_int.stats[stat.int] = 1;

    local loadout_added_1_int = loadout_add(loadout, loadout_1_int);
    local stats_1_int_added = loadout_stats_for_spell(spell_data, spell_name, loadout_added_1_int);
    local added_1_int_effect = spell_info(
       spell_data.base_min, spell_data.base_max, 
       spell_data.over_time, spell_data.over_time_tick_freq, spell_data.over_time_duration, stats.extra_ticks,
       stats_1_int_added.cast_speed,
       stats_1_int_added.spell_power,
       stats_1_int_added.flat_direct_addition,
       max(0, min(1, stats_1_int_added.crit)),
       max(0, min(1, stats_1_int_added.ot_crit)),
       stats_1_int_added.spell_crit_mod,
       stats_1_int_added.hit,
       stats_1_int_added.target_vuln_mod, 
       stats_1_int_added.global_mod, 
       stats_1_int_added.spell_mod, 
       stats_1_int_added.spell_mod_base,
       stats_1_int_added.direct_coef, 
       stats_1_int_added.over_time_coef,
       stats_1_int_added.cost, spell_data.school,
       spell_name, loadout_added_1_int
    );

    local until_oom_1_int = race_to_the_bottom_sim(
        added_1_int_effect, 
        loadout_added_1_int.mp5, 
        loadout_added_1_int.stats[stat.spirit], 
        loadout_added_1_int.mana + loadout.extra_mana,
        loadout_added_1_int);

    
    local diff_1_sp = until_oom_1_sp.effect - until_oom_normal.effect;
    local diff_1_crit = until_oom_1_crit.effect - until_oom_normal.effect;
    local diff_1_hit = until_oom_1_hit.effect - until_oom_normal.effect;
    local diff_1_mp5 = until_oom_1_mp5.effect - until_oom_normal.effect;
    local diff_1_spirit = until_oom_1_spirit.effect - until_oom_normal.effect;
    local diff_1_int = until_oom_1_int.effect - until_oom_normal.effect;

    local sp_per_crit = diff_1_crit/diff_1_sp;
    local sp_per_hit = diff_1_hit/diff_1_sp;
    local sp_per_mp5 = diff_1_mp5/diff_1_sp;
    local sp_per_spirit = diff_1_spirit/diff_1_sp;
    local sp_per_int = diff_1_int/diff_1_sp;

    return {
        effect_per_1_sp = diff_1_sp,

        sp_per_crit = sp_per_crit,
        sp_per_hit = sp_per_hit,
        sp_per_mp5 = sp_per_mp5,
        sp_per_spirit = sp_per_spirit,
        sp_per_int = sp_per_int,

        normal = until_oom_normal,
    };
end

local function tooltip_spell_info(tooltip, spell, spell_name, loadout)

    if spell then

        if sw_frame.settings_frame.tooltip_num_checked == 0 or 
            (sw_frame.settings_frame.show_tooltip_only_when_shift and not IsShiftKeyDown()) then
            return;
        end

        local stats = loadout_stats_for_spell(spell, spell_name, loadout); 
        local eval = evaluate_spell(stats, spell, spell_name, loadout);

        local race_to_bottom = race_to_the_bottom_stat_weights(
          stats, spell, spell_name, eval.spell_data, eval.spell_data_1_sp, eval.spell_data_1_crit, eval.spell_data_1_hit, loadout
        );
        
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

        tooltip:AddLine("Stat Weights Classic", 1, 1, 1);
        local loadout_type = "";
        if loadout.is_dynamic_loadout then
            loadout_type = "dynamic";
        else
            loadout_type = "static";
        end
        if bit.band(spell.flags, spell_flags.heal) ~= 0 or bit.band(spell.flags, spell_flags.absorb) ~= 0 then
            tooltip:AddLine(string.format("Active Loadout (%s): %s", loadout_type, loadout.name), 1, 1,1);
        else
            tooltip:AddLine(string.format("Active Loadout (%s): %s - Target lvl %d", loadout_type, loadout.name, loadout.target_lvl), 1, 1, 1);
        end
        if eval.spell_data.min_noncrit ~= 0 then
            if sw_frame.settings_frame.tooltip_normal_effect:GetChecked() then
                if eval.spell_data.min_noncrit ~= eval.spell_data.max_noncrit then
                    -- dmg spells with real direct range
                    if stats.hit ~= 1 then
                        if spell_name == localized_spell_name("Searing Totem") then
                            local num_ticks = spell.over_time_duration/spell.over_time_tick_freq;
                            tooltip:AddLine(
                                string.format("Normal %s (%.1f%% hit): %d over %d sec (%d-%d per tick for %d ticks)", 
                                              effect, 
                                              stats.hit*100,
                                              (eval.spell_data.min_noncrit + eval.spell_data.max_noncrit)*num_ticks/2,
                                              spell.over_time_duration,
                                              math.floor(eval.spell_data.min_noncrit), 
                                              math.ceil(eval.spell_data.max_noncrit),
                                              num_ticks),
                                232.0/255, 225.0/255, 32.0/255);
                        else
                            tooltip:AddLine(string.format("Normal %s (%.1f%% hit): %d-%d", 
                                                           effect, 
                                                           stats.hit*100,
                                                           math.floor(eval.spell_data.min_noncrit), 
                                                           math.ceil(eval.spell_data.max_noncrit)),
                                             232.0/255, 225.0/255, 32.0/255);
                        end
                    -- heal spells with real direct range
                    else
                        tooltip:AddLine(string.format("Normal %s: %d-%d", 
                                                      effect, 
                                                      math.floor(eval.spell_data.min_noncrit), 
                                                      math.ceil(eval.spell_data.max_noncrit)),
                                        232.0/255, 225.0/255, 32.0/255);
                    end
                else
                    if stats.hit ~= 1 then
                        tooltip:AddLine(string.format("Normal %s (%.1f%% hit): %d", 
                                                      effect,
                                                      stats.hit*100,
                                                      math.floor(eval.spell_data.min_noncrit)),
                                                      --string.format("%.0f", eval.spell_data.min_noncrit)),
                                        232.0/255, 225.0/255, 32.0/255);
                    else
                        tooltip:AddLine(string.format("Normal %s: %d", 
                                                      effect,
                                                      stats.hit*100,
                                                      math.floor(eval.spell_data.min_noncrit)),
                                                      --string.format("%.0f", eval.spell_data.min_noncrit)),
                                        232.0/255, 225.0/255, 32.0/255);
                    end

                end
            end
            if sw_frame.settings_frame.tooltip_crit_effect:GetChecked() then
                if stats.crit ~= 0 then
                    if loadout.ignite ~= 0 and eval.spell_data.ignite_min > 0 then
                        tooltip:AddLine(string.format("Critical %s (%.2f%% crit): %d-%d (ignites for %d-%d)", 
                                                      effect, 
                                                      stats.crit*100, 
                                                      math.floor(eval.spell_data.min_crit), 
                                                      math.ceil(eval.spell_data.max_crit),
                                                      math.floor(eval.spell_data.ignite_min), 
                                                      math.ceil(eval.spell_data.ignite_max)),
                                       252.0/255, 69.0/255, 3.0/255);

                    elseif spell_name == localized_spell_name("Searing Totem") then
                        local num_ticks = spell.over_time_duration/spell.over_time_tick_freq;
                        tooltip:AddLine(
                            string.format("Critical %s (%.2f%% crit): %d over %d sec (%d-%d per tick for %d ticks)", 
                                          effect, 
                                          stats.crit*100, 
                                          (eval.spell_data.min_crit + eval.spell_data.max_crit)*num_ticks/2,
                                          spell.over_time_duration,
                                          math.floor(eval.spell_data.min_crit), 
                                          math.ceil(eval.spell_data.max_crit),
                                          num_ticks),
                            252.0/255, 69.0/255, 3.0/255);
                    else
                        tooltip:AddLine(string.format("Critical %s (%.2f%% crit): %d-%d", 
                                                      effect, 
                                                      stats.crit*100, 
                                                      math.floor(eval.spell_data.min_crit), 
                                                      math.ceil(eval.spell_data.max_crit)),
                                       252.0/255, 69.0/255, 3.0/255);
                    end

                end
            end
        end


        if eval.spell_data.ot_if_hit ~= 0 and sw_frame.settings_frame.tooltip_normal_ot:GetChecked() then

            -- round over time num for niceyness
            local ot = tonumber(string.format("%.0f", eval.spell_data.ot_if_hit));

            if stats.hit ~= 1 then
                if spell_name == localized_spell_name("Curse of Agony") then
                    tooltip:AddLine(string.format("%s (%.1f%% hit): %d over %d sec (%.0f-%.0f-%.0f per tick for %d ticks)",
                                                  effect,
                                                  stats.hit * 100,
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
                                                  stats.hit * 100,
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

            if bit.band(spell_flags.over_time_crit, spell.flags) ~= 0 and 
               sw_frame.settings_frame.tooltip_crit_ot:GetChecked() then
                -- over time can crit (e.g. arcane missiles)
                tooltip:AddLine(string.format("Critical %s (%.2f%% crit): %d over %d sec (%d-%d per tick for %d ticks)",
                                              effect,
                                              stats.crit*100, 
                                              eval.spell_data.ot_crit_if_hit, 
                                              eval.spell_data.ot_duration, 
                                              math.floor(eval.spell_data.ot_crit_if_hit/eval.spell_data.ot_num_ticks),
                                              math.ceil(eval.spell_data.ot_crit_if_hit/eval.spell_data.ot_num_ticks),
                                              eval.spell_data.ot_num_ticks), 
                           252.0/255, 69.0/255, 3.0/255);
                    
            end
        end

        
      if sw_frame.settings_frame.tooltip_expected_effect:GetChecked() then
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
                                             100*(1 - math.pow(1-stats.crit, 4)));
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


        tooltip:AddLine("Expected "..effect..string.format(": %.1f ",eval.spell_data.expectation)..effect_extra_str,
                        255.0/256, 128.0/256, 0);

        if eval.spell_data.base_min ~= 0.0 and eval.spell_data.expectation ~=  eval.spell_data.expectation_st then

          tooltip:AddLine("Expected "..effect..string.format(": %.1f",eval.spell_data.expectation_st).." (incl: single effect)",
                          255.0/256, 128.0/256, 0);
        end
      end

      tooltip:AddLine("Infinite Spam Cast Scenario", 1, 1, 1);
      if sw_frame.settings_frame.tooltip_effect_per_sec:GetChecked() then
        tooltip:AddLine(string.format("%s: %.1f", 
                                      effect_per_sec,
                                      eval.spell_data.effect_per_sec),
                        255.0/256, 128.0/256, 0);
      end
      if sw_frame.settings_frame.tooltip_effect_per_cost:GetChecked() then
        tooltip:AddLine(effect_per_cost..": "..string.format("%.1f",eval.spell_data.effect_per_cost), 0.0, 1.0, 1.0);
      end
      if sw_frame.settings_frame.tooltip_cost_per_sec:GetChecked() then
        tooltip:AddLine(cost_per_sec.." burn: "..string.format("%.1f",eval.spell_data.cost_per_sec), 0.0, 1.0, 1.0);
        tooltip:AddLine(cost_per_sec.." gain: "..string.format("%.1f",race_to_bottom.normal.mp2/2), 0.0, 1.0, 1.0);
      end

      if sw_frame.settings_frame.tooltip_stat_weights:GetChecked() then
        tooltip:AddLine(effect_per_sp..": "..string.format("%.3f",eval.effect_per_sp), 0.0, 1.0, 0.0);
        tooltip:AddLine(sp_name.." per 1% Crit: "..string.format("%.3f",eval.sp_per_crit), 0.0, 1.0, 0.0);

        if (bit.band(spell.flags, spell_flags.heal) == 0 and bit.band(spell.flags, spell_flags.absorb) == 0) then
            tooltip:AddLine(sp_name.." per 1%  Hit: "..string.format("%.3f",eval.sp_per_hit), 0.0, 1.0, 0.0);
        end
      end

      if sw_frame.settings_frame.tooltip_race_to_the_bottom:GetChecked() then
        tooltip:AddLine("Race to the Bottom Scenario", 1, 1, 1);


        tooltip:AddLine("Time until OOM "..string.format("%.1f sec",race_to_bottom.normal.time_until_oom));
        tooltip:AddLine(effect.." until OOM: "..string.format("%.1f",race_to_bottom.normal.effect));
        tooltip:AddLine("Casts until OOM: "..string.format("%.1f",race_to_bottom.normal.num_casts));
        --tooltip:AddLine("Effect per 1 sp: "..string.format("%.3f",race_to_bottom.effect_per_1_sp), 0.0, 1.0, 0.0);
        --tooltip:AddLine("Spell power per 1% crit: "..string.format("%.2f",race_to_bottom.sp_per_crit), 0.0, 1.0, 0.0);
        --if race_to_bottom.sp_per_hit ~= 0 then
        --    tooltip:AddLine("Spell power per 1% hit: "..string.format("%.2f",race_to_bottom.sp_per_hit), 0.0, 1.0, 0.0);
        --end
        tooltip:AddLine(sp_name.." per MP5: "..string.format("%.3f",race_to_bottom.sp_per_mp5), 0.0, 1.0, 0.0);
        tooltip:AddLine(sp_name.." per Spirit: "..string.format("%.3f",race_to_bottom.sp_per_spirit), 0.0, 1.0, 0.0);
        tooltip:AddLine(sp_name.." per Intellect: "..string.format("%.3f",race_to_bottom.sp_per_int), 0.0, 1.0, 0.0);
        tooltip:AddLine(sp_name.." per 1% Crit: "..string.format("%.3f",race_to_bottom.sp_per_crit), 0.0, 1.0, 0.0);
        if (bit.band(spell.flags, spell_flags.heal) == 0 and bit.band(spell.flags, spell_flags.absorb) == 0) then
            tooltip:AddLine(sp_name.." per 1%  Hit: "..string.format("%.3f",race_to_bottom.sp_per_hit), 0.0, 1.0, 0.0);
        end
      end

      if sw_frame.settings_frame.tooltip_coef:GetChecked() then
          tooltip:AddLine(string.format("Coefficient direct: %.3f", direct_coef), 232.0/255, 225.0/255, 32.0/255);
          tooltip:AddLine(string.format("Coefficient over time: %.3f", ot_coef), 232.0/255, 225.0/255, 32.0/255);
      end
      if sw_frame.settings_frame.tooltip_avg_cast:GetChecked() then

          tooltip:AddLine(string.format("Average cast time: %.3f sec", eval.spell_data.cast_time), 232.0/255, 225.0/255, 32.0/255);
      end
      if sw_frame.settings_frame.tooltip_avg_cost:GetChecked() then
          tooltip:AddLine("Average cost: "..eval.spell_data.cost, 232.0/255, 225.0/255, 32.0/255);
      end

      -- debug tooltip stuff
      if __sw__debug__ then
          tooltip:AddLine("Base "..effect..": "..spell.base_min.."-"..spell.base_max);
          tooltip:AddLine(
            string.format("Stats: sp %d, crit %.2f, crit_mod %.2f, hit %.2f, vuln_mod %.2f, gmod %.2f, mod %.2f, bmod %.2f, flat add %.2f, cost %f, cast %f",
                          stats.spell_power,
                          stats.crit,
                          stats.spell_crit_mod,
                          stats.hit,
                          stats.target_vuln_mod,
                          stats.global_mod,
                          stats.spell_mod,
                          stats.spell_mod_base,
                          stats.flat_direct_addition,
                          stats.cost,
                          stats.cast_speed
            
          ));
      end


      end_tooltip_section(tooltip);

      if spell.healing_version then
          -- used for holy nova
          tooltip_spell_info(tooltip, spell.healing_version, spell_name, loadout);
      end
    end
end

local function print_spell(spell, spell_name, loadout)

    if spell then

        local stats = loadout_stats_for_spell(spell, spell_name, loadout); 
        local eval = evaluate_spell(stats, spell, spell_name, loadout);
        
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
                            spell.cost
                            ));

        print(string.format("Spell noncrit: min %d, max %d", eval.spell_data.min_noncrit, eval.spell_data.max_noncrit));
        print(string.format("Spell crit: min %d, max %d", eval.spell_data.min_crit, eval.spell_data.max_crit));
                            

        print("Spell evaluation");
        print(string.format("ot if hit: %.3f", eval.spell_data.ot_if_hit));
        print(string.format("including hit/miss - expectation: %.3f, effect_per_sec: %.3f, effect per cost:%.3f, effect_per_sp : %.3f, sp_per_crit: %.3f, sp_per_hit: %.3f", 
                            eval.spell_data.expectation, 
                            eval.spell_data.effect_per_sec, 
                            eval.spell_data.effect_per_cost, 
                            eval.effect_per_sp, 
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

    loadout.stats[stat.int] = stats[stat_ids_in_ui.int].editbox_val;
    loadout.stats[stat.spirit] = stats[stat_ids_in_ui.spirit].editbox_val;
    loadout.mana = stats[stat_ids_in_ui.mana].editbox_val;
    loadout.mp5 = stats[stat_ids_in_ui.mp5].editbox_val;

    local loadout_crit = stats[stat_ids_in_ui.spell_crit].editbox_val;
    for i = 1, 7 do
        loadout.spell_crit_by_school[i] = loadout_crit/100;
    end
    loadout.healing_crit = loadout_crit/100;

    local loadout_hit = stats[stat_ids_in_ui.spell_hit].editbox_val;
    for i = 1, 7 do
        loadout.spell_dmg_hit_by_school[i] = loadout_hit/100;
    end

    local loadout_sp = stats[stat_ids_in_ui.sp].editbox_val;
    for i = 1, 7 do
        loadout.spell_dmg_by_school[i] = loadout.spell_dmg_by_school[i] + loadout_sp;
    end

    loadout.healing_power = loadout.healing_power + loadout_sp;

    local loadout_spell_dmg = stats[stat_ids_in_ui.spell_damage].editbox_val;
    for i = 1, 7 do
        loadout.spell_dmg_by_school[i] = loadout.spell_dmg_by_school[i] + loadout_spell_dmg;
    end

    loadout.healing_power = loadout.healing_power + stats[stat_ids_in_ui.healing_power].editbox_val;

    --for i = 2, 7 do

    --    local loadout_school_sp = stats[stat_ids_in_ui.holy_power - 2 + i].editbox_val;

    --    loadout.spell_dmg_by_school[i] = loadout.spell_dmg_by_school[i] + loadout_school_sp;
    --end

    frame.is_valid = true;

    return loadout;
end

local function spell_diff(spell_data, spell_name, loadout, diff, sim_type)

    local loadout_diffed = loadout_add(loadout, diff);

    local expectation_loadout = spell_info_from_loadout_stats(spell_data, spell_name, loadout);
    local expectation_loadout_diffed = spell_info_from_loadout_stats(spell_data, spell_name, loadout_diffed);

    if sim_type == simulation_type.spam_cast then
        return {
            diff_ratio = 100 * 
                (expectation_loadout_diffed.expectation/expectation_loadout.expectation - 1),
            expectation = expectation_loadout_diffed.expectation - 
                expectation_loadout.expectation,
            effect_per_sec = expectation_loadout_diffed.effect_per_sec - 
                expectation_loadout.effect_per_sec
        };
    elseif sim_type == simulation_type.race_to_the_bottom then
        
        local race_for_loadout = race_to_the_bottom_sim_default(expectation_loadout, loadout);
        local race_for_loadout_diffed = race_to_the_bottom_sim_default(expectation_loadout_diffed, loadout_diffed);
        -- Misleading! effect_per_sec used here to use previous code but doesnt mean efect_per_sec here
        return {
            diff_ratio = 100 * 
                (race_for_loadout_diffed.effect/race_for_loadout.effect - 1),
            expectation = race_for_loadout_diffed.effect - 
                race_for_loadout.effect,
            effect_per_sec = race_for_loadout_diffed.time_until_oom - 
                race_for_loadout.time_until_oom
        };
    end
end

function active_loadout_base()
    if sw_frame.loadouts_frame.lhs_list.loadouts and sw_frame.loadouts_frame.lhs_list.active_loadout then
        return sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout;
    else
        return default_loadout();
    end
end

local function active_loadout_copy()

    local loadout = active_loadout_base();

    if loadout.is_dynamic_loadout then
        loadout_modified = dynamic_loadout(loadout);
    else
        loadout_modified = loadout_copy(loadout);
    end

    return loadout_modified;
end

local function active_loadout_buffed_talented_copy()

    return apply_buffs(apply_talents(active_loadout_copy()));
end

local update_and_display_spell_diffs = nil;

local function display_spell_diff(spell_id, spell_data, spell_diff_line, loadout, loadout_diff, frame, is_duality_spell, sim_type)

    local diff = spell_diff(spell_data, spell_diff_line.name, loadout, loadout_diff, sim_type);

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
    
        elseif diff.expectation > 0 then
    
            v.change:SetText(string.format("+%.2f", diff.diff_ratio).."%");
            v.change:SetTextColor(33/255, 185/255, 21/255);
    
            v.expectation:SetText(string.format("+%.2f", diff.expectation));
            v.expectation:SetTextColor(33/255, 185/255, 21/255);
    
        else
    
            v.change:SetText("0 %");
            v.change:SetTextColor(1, 1, 1);
    
            v.expectation:SetText("0");
            v.expectation:SetTextColor(1, 1, 1);
        end

        if diff.effect_per_sec < 0 then
            v.effect_per_sec:SetText(string.format("%.2f", diff.effect_per_sec));
            v.effect_per_sec:SetTextColor(195/255, 44/255, 11/255);
        elseif diff.effect_per_sec > 0 then
            v.effect_per_sec:SetText(string.format("+%.2f", diff.effect_per_sec));
            v.effect_per_sec:SetTextColor(33/255, 185/255, 21/255);
        else
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

function update_and_display_spell_diffs(frame)

    frame.line_y_offset = frame.line_y_offset_before_dynamic_spells;

    local loadout = active_loadout_buffed_talented_copy();

    local loadout_diff = create_loadout_from_ui_diff(frame);

    for k, v in pairs(frame.spells) do
        display_spell_diff(k, spells[k], v, loadout, loadout_diff, frame, false, sw_frame.stat_comparison_frame.sim_type);

        -- for spells with both heal and dmg
        if spells[k].healing_version then
            display_spell_diff(k, spells[k].healing_version, v, loadout, loadout_diff, frame, true, sw_frame.stat_comparison_frame.sim_type);
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
    frame.footer:SetText("Add abilities by holding SHIFT and HOVERING over them!");
end

local function loadout_name_already_exists(name)

    local already_exists = false;    
    for i = 1, sw_frame.loadouts_frame.lhs_list.num_loadouts do
    
        if name == sw_frame.loadouts_frame.lhs_list.loadouts[i].loadout.name then
            already_exists = true;
        end
    end
    return already_exists;
end

local function update_loadouts_rhs()

    local loadout = active_loadout_base();

    if sw_frame.loadouts_frame.lhs_list.num_loadouts == 1 then

        sw_frame.loadouts_frame.rhs_list.delete_button:Hide();
    else
        sw_frame.loadouts_frame.rhs_list.delete_button:Show();
    end

    sw_frame.stat_comparison_frame.loadout_name_label:SetText(
        loadout.name
    );

    sw_frame.loadouts_frame.rhs_list.name_editbox:SetText(
        loadout.name
    );

    sw_frame.loadouts_frame.rhs_list.level_editbox:SetText(
        loadout.target_lvl
    );

    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetText(
        loadout.extra_mana
    );

    if loadout.use_dynamic_target_lvl then
        sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton:SetChecked(true);
    else
        sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton:SetChecked(false);
    end
    if loadout.is_dynamic_loadout then

        sw_frame.loadouts_frame.rhs_list.talent_editbox:SetText(
            wowhead_talent_link(wowhead_talent_code())
        );

        sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(true);
        sw_frame.loadouts_frame.rhs_list.static_button:SetChecked(false);

    else

        sw_frame.loadouts_frame.rhs_list.talent_editbox:SetText(
            wowhead_talent_link(loadout.talents_code)
        );

        sw_frame.loadouts_frame.rhs_list.static_button:SetChecked(true);
        sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(false);
    end

    if loadout.always_assume_buffs then

        sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetChecked(true);
        sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetChecked(false);
    else
        sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetChecked(true);
        sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetChecked(false);
    end

    local num_checked_buffs = 0;
    local num_checked_target_buffs = 0;
    for k, v in pairs(sw_frame.loadouts_frame.rhs_list.buffs) do

        if v.checkbutton.buff_type == "self1" then
            if bit.band(v.checkbutton.buff_info.flag, loadout.buffs1) ~= 0 then
                v.checkbutton:SetChecked(true);
                num_checked_buffs = num_checked_buffs + 1;
            else
                v.checkbutton:SetChecked(false);
            end
        elseif v.checkbutton.buff_type == "self2" then
            if bit.band(v.checkbutton.buff_info.flag, loadout.buffs2) ~= 0 then
                v.checkbutton:SetChecked(true);
                num_checked_buffs = num_checked_buffs + 1;
            else
                v.checkbutton:SetChecked(false);
            end
        end
    end
    for k, v in pairs(sw_frame.loadouts_frame.rhs_list.target_buffs) do
        if bit.band(v.checkbutton.buff_info.flag, loadout.target_buffs1) ~= 0 then
            v.checkbutton:SetChecked(true);
            num_checked_target_buffs = num_checked_target_buffs + 1;
        else
            v.checkbutton:SetChecked(false);
        end
    end
    for k, v in pairs(sw_frame.loadouts_frame.rhs_list.target_debuffs) do
        if bit.band(v.checkbutton.buff_info.flag, loadout.target_debuffs1) ~= 0 then
            v.checkbutton:SetChecked(true);
            num_checked_target_buffs = num_checked_target_buffs + 1;
        else
            v.checkbutton:SetChecked(false);
        end
    end

    sw_frame.loadouts_frame.rhs_list.num_checked_buffs = num_checked_buffs;
    sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs = num_checked_target_buffs;

    if sw_frame.loadouts_frame.rhs_list.num_checked_buffs == 0 then
        sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(false);
    else
        sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(true);
    end

    if sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs == 0 then

        sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(false);
    else
        sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(true);
    end
end

local loadout_checkbutton_id_counter = 1;

-- TOOD localize
function update_loadouts_lhs()

    local y_offset = -13;

    for k, v in pairs(sw_frame.loadouts_frame.lhs_list.loadouts) do

        local checkbutton_name = "sw_frame_loadouts_lhs_list"..k;
        v.check_button = getglobal(checkbutton_name);

        if not v.check_button then


            v.check_button = 
                CreateFrame("CheckButton", checkbutton_name, sw_frame.loadouts_frame.lhs_list, "ChatConfigCheckButtonTemplate");

            v.check_button.target_index = k;

            v.check_button:SetScript("OnClick", function(self)
                
                for i = 1, sw_frame.loadouts_frame.lhs_list.num_loadouts  do

                    sw_frame.loadouts_frame.lhs_list.loadouts[i].check_button:SetChecked(false);
                    
                end
                self:SetChecked(true);

                sw_frame.loadouts_frame.lhs_list.active_loadout = self.target_index;

                update_loadouts_rhs();
            end);

        end
        if k == sw_frame.loadouts_frame.lhs_list.active_loadout then
            v.check_button:SetChecked(true);
        else
            v.check_button:SetChecked(false);
        end
        v.check_button.target_index = k;

        v.check_button:Show();
        v.check_button:SetPoint("TOPLEFT", 10, y_offset);

        getglobal(v.check_button:GetName() .. 'Text'):SetText(v.loadout.name);

       y_offset = y_offset - 20;
    end

    update_loadouts_rhs();
end

local function create_new_loadout_as_copy(loadout, name)

    local cpy = loadout_copy(loadout);

    sw_frame.loadouts_frame.lhs_list.loadouts[
        sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(false);

    sw_frame.loadouts_frame.lhs_list.num_loadouts = sw_frame.loadouts_frame.lhs_list.num_loadouts + 1;
    sw_frame.loadouts_frame.lhs_list.active_loadout = sw_frame.loadouts_frame.lhs_list.num_loadouts;

    sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.num_loadouts] = {};
    sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.num_loadouts].loadout = cpy;

    sw_frame.loadouts_frame.lhs_list.loadouts[
        sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.name = name.." (Copy)";

    update_loadouts_lhs();

    sw_frame.loadouts_frame.lhs_list.loadouts[
        sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(true);
end

local function sw_activate_tab(tab_index)

    sw_frame.active_tab = tab_index;

    sw_frame:Show();

    sw_frame.settings_frame:Hide();
    sw_frame.loadouts_frame:Hide();
    sw_frame.stat_comparison_frame:Hide();

    sw_frame.tab1:UnlockHighlight();
    sw_frame.tab1:SetButtonState("NORMAL");
    sw_frame.tab2:UnlockHighlight();
    sw_frame.tab2:SetButtonState("NORMAL");
    sw_frame.tab3:UnlockHighlight();
    sw_frame.tab3:SetButtonState("NORMAL");

    if tab_index == 1 then
        sw_frame.settings_frame:Show();
        sw_frame.tab1:LockHighlight();
        sw_frame.tab1:SetButtonState("PUSHED");
    elseif tab_index == 2 then
        sw_frame.loadouts_frame:Show();
        sw_frame.tab2:LockHighlight();
        sw_frame.tab2:SetButtonState("PUSHED");
    elseif tab_index == 3 then

        update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
        sw_frame.stat_comparison_frame:Show();
        sw_frame.tab3:LockHighlight();
        sw_frame.tab3:SetButtonState("PUSHED");
    end
end

local function default_sw_settings()
    local settings = {};
    settings.ability_icon_overlay = 
        bit.bor(icon_stat_display.normal, 
                icon_stat_display.crit, 
                icon_stat_display.effect_per_sec,
                icon_stat_display.show_heal_variant);

    settings.ability_tooltip = 
        bit.bor(tooltip_stat_display.normal, 
                tooltip_stat_display.crit, 
                tooltip_stat_display.ot,
                tooltip_stat_display.ot_crit,
                tooltip_stat_display.expected,
                tooltip_stat_display.effect_per_sec,
                tooltip_stat_display.effect_per_cost,
                tooltip_stat_display.cost_per_sec,
                tooltip_stat_display.stat_weights,
                tooltip_stat_display.race_to_the_bottom);

    settings.icon_overlay_update_freq = 10;
    settings.icon_overlay_font_size = 8;
    settings.show_tooltip_only_when_shift = false;
    settings.libstub_minimap_icon = { hide = false };

    return settings;
end

local function save_sw_settings()

    local icon_overlay_settings = 0;
    local tooltip_settings = 0;

    if sw_frame.settings_frame.icon_normal_effect:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.normal);
    end
    if sw_frame.settings_frame.icon_crit_effect:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.crit);
    end
    if sw_frame.settings_frame.icon_expected_effect:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.expected);
    end
    if sw_frame.settings_frame.icon_effect_per_sec:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.effect_per_sec);
    end
    if sw_frame.settings_frame.icon_effect_per_cost:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.effect_per_cost);
    end
    if sw_frame.settings_frame.icon_avg_cost:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.avg_cost);
    end
    if sw_frame.settings_frame.icon_avg_cast:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.avg_cast);
    end
    if sw_frame.settings_frame.icon_hit:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.hit);
    end
    if sw_frame.settings_frame.icon_crit:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.crit_chance);
    end
    if sw_frame.settings_frame.icon_casts_until_oom:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.casts_until_oom);
    end
    if sw_frame.settings_frame.icon_effect_until_oom:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.effect_until_oom);
    end
    if sw_frame.settings_frame.icon_time_until_oom:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.time_until_oom);
    end
    if sw_frame.settings_frame.icon_heal_variant:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.show_heal_variant);
    end

    if sw_frame.settings_frame.tooltip_normal_effect:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.normal);
    end
    if sw_frame.settings_frame.tooltip_crit_effect:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.crit);
    end
    if sw_frame.settings_frame.tooltip_normal_ot:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.ot);
    end
    if sw_frame.settings_frame.tooltip_crit_ot:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.ot_crit);
    end
    if sw_frame.settings_frame.tooltip_expected_effect:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.expected);
    end
    if sw_frame.settings_frame.tooltip_effect_per_sec:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.effect_per_sec);
    end
    if sw_frame.settings_frame.tooltip_effect_per_cost:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.effect_per_cost);
    end
    if sw_frame.settings_frame.tooltip_cost_per_sec:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.cost_per_sec);
    end
    if sw_frame.settings_frame.tooltip_stat_weights:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.stat_weights);
    end
    if sw_frame.settings_frame.tooltip_coef:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.coef);
    end
    if sw_frame.settings_frame.tooltip_avg_cost:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.avg_cost);
    end
    if sw_frame.settings_frame.tooltip_avg_cast:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.avg_cast);
    end
    if sw_frame.settings_frame.tooltip_race_to_the_bottom:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.race_to_the_bottom);
    end
    --if class == "WARLOCK" then
    --    if sw_frame.settings_frame.tooltip_cast_and_tap:GetChecked() then
    --        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.cast_and_tap);
    --    end
    --end

    __sw__persistent_data_per_char.settings.ability_icon_overlay = icon_overlay_settings;
    __sw__persistent_data_per_char.settings.ability_tooltip = tooltip_settings;
    __sw__persistent_data_per_char.settings.show_tooltip_only_when_shift = sw_frame.settings_frame.show_tooltip_only_when_shift;
    __sw__persistent_data_per_char.settings.icon_overlay_update_freq = sw_snapshot_loadout_update_freq;
    __sw__persistent_data_per_char.settings.icon_overlay_font_size = sw_frame.settings_frame.icon_overlay_font_size;
end

local function create_sw_checkbox(name, parent, line_pos_index, y_offset, text, check_func)

    local checkbox_frame = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate"); 

    local x_spacing = 180;
    local x_pad = 10;
    checkbox_frame:SetPoint("TOPLEFT", x_pad + (line_pos_index - 1) * x_spacing, y_offset);
    getglobal(checkbox_frame:GetName() .. 'Text'):SetText(text);
    checkbox_frame:SetScript("OnClick", check_func);

    return checkbox_frame;
end

local function create_sw_gui_settings_frame()

    sw_frame.settings_frame:SetWidth(370);
    sw_frame.settings_frame:SetHeight(600);
    sw_frame.settings_frame:SetPoint("TOP", sw_frame, 0, -20);

    if not __sw__persistent_data_per_char then
        __sw__persistent_data_per_char = {};
    end

    if not __sw__persistent_data_per_char.settings then
        __sw__persistent_data_per_char.settings = default_sw_settings();
    end

    -- content frame for settings
    sw_frame.settings_frame.y_offset = -35;

    sw_frame.settings_frame.icon_settings_label = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.icon_settings_label:SetFontObject(font);
    sw_frame.settings_frame.icon_settings_label:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_settings_label:SetText("Ability Icon Overlay Display Options (max 3)");
    sw_frame.settings_frame.icon_settings_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    -- TODO: this needs to be checked based on saved vars
    sw_frame.settings_frame.icons_num_checked = 0;

    local icon_checkbox_func = function(self)
        if self:GetChecked() then
            if sw_frame.settings_frame.icons_num_checked >= 3 then
                self:SetChecked(false);
            else
                sw_frame.settings_frame.icons_num_checked = sw_frame.settings_frame.icons_num_checked + 1;
            end
        else
            sw_frame.settings_frame.icons_num_checked = sw_frame.settings_frame.icons_num_checked - 1;
        end
        update_icon_overlay_settings();
    end;

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_normal_effect = 
        create_sw_checkbox("sw_icon_normal_effect", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Normal effect", icon_checkbox_func);
    sw_frame.settings_frame.icon_crit_effect = 
        create_sw_checkbox("sw_icon_crit_effect", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Critical effect", icon_checkbox_func); 
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_expected_effect = 
        create_sw_checkbox("sw_icon_expected_effect", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Expected effect", icon_checkbox_func);  
    getglobal(sw_frame.settings_frame.icon_expected_effect:GetName()).tooltip = 
        "Expected effect is the DMG or Heal dealt on average for a single cast considering miss chance, crit chance, spell power etc. This equates to your DPS or HPS number multiplied with the ability's cast time"

    sw_frame.settings_frame.icon_effect_per_sec = 
        create_sw_checkbox("sw_icon_effect_per_sec", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Effect per sec", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_effect_per_cost = 
        create_sw_checkbox("sw_icon_effect_per_costs", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Effect per cost", icon_checkbox_func);  
    sw_frame.settings_frame.icon_avg_cost = 
        create_sw_checkbox("sw_icon_avg_cost", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Average cost", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_avg_cast = 
        create_sw_checkbox("sw_icon_avg_cast", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Average cast time", icon_checkbox_func);
    sw_frame.settings_frame.icon_hit = 
        create_sw_checkbox("sw_icon_hit", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Hit Chance", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_crit = 
        create_sw_checkbox("sw_icon_crit_chance", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Critical Chance", icon_checkbox_func);  
    sw_frame.settings_frame.icon_casts_until_oom = 
        create_sw_checkbox("sw_icon_casts_until_oom", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Casts until OOM", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    sw_frame.settings_frame.icon_effect_until_oom = 
        create_sw_checkbox("sw_icon_effect_until_oom", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Effect until OOM", icon_checkbox_func);  
    sw_frame.settings_frame.icon_time_until_oom = 
        create_sw_checkbox("sw_icon_time_until_oom", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Time until OOM", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 30;

    sw_frame.settings_frame.icon_settings_label = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.icon_settings_label:SetFontObject(font);
    sw_frame.settings_frame.icon_settings_label:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_settings_label:SetText("Ability Icon Overlay Configuration");
    sw_frame.settings_frame.icon_settings_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_heal_variant = 
        CreateFrame("CheckButton", "sw_icon_heal_variant", sw_frame.settings_frame, "ChatConfigCheckButtonTemplate"); 
    sw_frame.settings_frame.icon_heal_variant:SetPoint("TOPLEFT", 10, sw_frame.settings_frame.y_offset);   
    getglobal(sw_frame.settings_frame.icon_heal_variant:GetName() .. 'Text'):SetText("Show healing for hybrid spells");
    --sw_frame.settings_frame.icon_heal_variant:SetScript("OnClick", function(self)
    --end);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 30;
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetFontObject(font);
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetText("Update frequency");

    sw_frame.settings_frame.icon_settings_update_freq_label_lhs = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetFontObject(font);
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetPoint("TOPLEFT", 170, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetText("Hz (less means better performance");

    sw_frame.settings_frame.icon_settings_update_freq_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.settings_frame, "InputBoxTemplate");
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetPoint("TOPLEFT", 120, sw_frame.settings_frame.y_offset + 3);
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetText("");
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetSize(40, 15);
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetAutoFocus(false);

    local hz_editbox = function(self)

        
        local txt = self:GetText();
        
        local hz = tonumber(txt);
        if hz and hz >= 0.01 and hz <= 300 then

            sw_snapshot_loadout_update_freq = tonumber(hz);
            
        else
            self:SetText("10"); 
            sw_snapshot_loadout_update_freq = 10;
        end

    	self:ClearFocus();
    end

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 30;

    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetScript("OnEnterPressed", hz_editbox);
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetScript("OnEscapePressed", hz_editbox);

    sw_frame.settings_frame.icon_overlay_font_size_slider =
        CreateFrame("Slider", "icon_overlay_font_size", sw_frame.settings_frame, "OptionsSliderTemplate");
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetMinMaxValues(2, 24)
    getglobal(sw_frame.settings_frame.icon_overlay_font_size_slider:GetName()..'Text'):SetText("Icon overlay font size");
    getglobal(sw_frame.settings_frame.icon_overlay_font_size_slider:GetName()..'Low'):SetText("");
    getglobal(sw_frame.settings_frame.icon_overlay_font_size_slider:GetName()..'High'):SetText("");
    sw_frame.settings_frame.icon_overlay_font_size = __sw__persistent_data_per_char.settings.icon_overlay_font_size;
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetValue(sw_frame.settings_frame.icon_overlay_font_size);
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetValueStep(1)
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetScript("OnValueChanged", function(self, val)
        sw_frame.settings_frame.icon_overlay_font_size = val;
    end);


    local num_icon_overlay_checks = 0;
    -- set checkboxes for _icon options as  according to persistent data per char
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.normal) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_normal_effect:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.crit) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_crit_effect:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.expected) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_expected_effect:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.effect_per_sec) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_effect_per_sec:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.effect_per_cost) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_effect_per_cost:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.avg_cost) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_avg_cost:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.avg_cast) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_avg_cast:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.hit) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_hit:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.crit_chance) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_crit:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.casts_until_oom) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_casts_until_oom:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.effect_until_oom) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_effect_until_oom:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.time_until_oom) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_time_until_oom:SetChecked(true);
        end
    end
    sw_frame.settings_frame.icons_num_checked = num_icon_overlay_checks;
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.show_heal_variant) ~= 0 then
        sw_frame.settings_frame.icon_heal_variant:SetChecked(true);
    end

    sw_snapshot_loadout_update_freq = __sw__persistent_data_per_char.settings.icon_overlay_update_freq;
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetText(""..sw_snapshot_loadout_update_freq);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 30;

    sw_frame.settings_frame.tooltip_settings_label = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.tooltip_settings_label:SetFontObject(font);
    sw_frame.settings_frame.tooltip_settings_label:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.tooltip_settings_label:SetText("Ability Tooltip Display Options");
    sw_frame.settings_frame.tooltip_settings_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    -- tooltip options
    sw_frame.settings_frame.tooltip_num_checked = 0;
    local tooltip_checkbox_func = function(self)
        if self:GetChecked() then
            sw_frame.settings_frame.tooltip_num_checked = sw_frame.settings_frame.tooltip_num_checked + 1;
        else
            sw_frame.settings_frame.tooltip_num_checked = sw_frame.settings_frame.tooltip_num_checked - 1;
        end
    end;

    sw_frame.settings_frame.tooltip_normal_effect = 
        create_sw_checkbox("sw_tooltip_normal_effect", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Normal effect", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_crit_effect = 
        create_sw_checkbox("sw_tooltip_crit_effect", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Critical effect", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_normal_ot = 
        create_sw_checkbox("sw_tooltip_normal_ot", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Normal over time effect", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_crit_ot = 
        create_sw_checkbox("sw_tooltip_crit_ot", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Critical over time effect", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_expected_effect = 
        create_sw_checkbox("sw_tooltip_expected_effect", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Expected effect", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_effect_per_sec = 
        create_sw_checkbox("sw_tooltip_effect_per_sec", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Effect per sec", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_effect_per_cost = 
        create_sw_checkbox("sw_tooltip_effect_per_cost", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Effect per cost", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_cost_per_sec = 
        create_sw_checkbox("sw_tooltip_cost_per_sec", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Cost per sec", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_stat_weights = 
        create_sw_checkbox("sw_tooltip_stat_weights", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Stat Weights", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_coef = 
        create_sw_checkbox("sw_tooltip_coef", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Ability coefficient", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_avg_cost = 
        create_sw_checkbox("sw_tooltip_avg_cost", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Average cost", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_avg_cast = 
        create_sw_checkbox("sw_tooltip_avg_cast", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Average cast time", tooltip_checkbox_func);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_race_to_the_bottom = 
        create_sw_checkbox("sw_tooltip_race_to_the_bottom", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Race to the Bottom", tooltip_checkbox_func);
    getglobal(sw_frame.settings_frame.tooltip_race_to_the_bottom:GetName()).tooltip = 
        "Assumes you cast a particular ability until you are OOM with no cooldowns.";
    --if class == "WARLOCK" then    
    --    sw_frame.settings_frame.tooltip_cast_and_tap = 
    --        create_sw_checkbox("sw_tooltip_cast_and_tap", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
    --                            "Cast and Lifetap", tooltip_checkbox_func);
    --end

    -- set tooltip options as according to saved persistent data
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.normal) ~= 0 then
        sw_frame.settings_frame.tooltip_normal_effect:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.crit) ~= 0 then
        sw_frame.settings_frame.tooltip_crit_effect:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.ot) ~= 0 then
        sw_frame.settings_frame.tooltip_normal_ot:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.ot_crit) ~= 0 then
        sw_frame.settings_frame.tooltip_crit_ot:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.expected) ~= 0 then
        sw_frame.settings_frame.tooltip_expected_effect:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.effect_per_sec) ~= 0 then
        sw_frame.settings_frame.tooltip_effect_per_sec:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.effect_per_cost) ~= 0 then
        sw_frame.settings_frame.tooltip_effect_per_cost:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.cost_per_sec) ~= 0 then
        sw_frame.settings_frame.tooltip_cost_per_sec:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.stat_weights) ~= 0 then
        sw_frame.settings_frame.tooltip_stat_weights:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.coef) ~= 0 then
        sw_frame.settings_frame.tooltip_coef:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.avg_cost) ~= 0 then
        sw_frame.settings_frame.tooltip_avg_cost:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.avg_cast) ~= 0 then
        sw_frame.settings_frame.tooltip_avg_cast:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.race_to_the_bottom) ~= 0 then
        sw_frame.settings_frame.tooltip_race_to_the_bottom:SetChecked(true);
    end
    --if class == "WARLOCK" then
        --if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.cast_and_tap) ~= 0 then
        --    sw_frame.settings_frame.tooltip_cast_and_tap:SetChecked(true);
        --end
    --end

    for i = 1, 32 do
        if bit.band(bit.lshift(1, i), __sw__persistent_data_per_char.settings.ability_tooltip) ~= 0 then
            sw_frame.settings_frame.tooltip_num_checked = sw_frame.settings_frame.tooltip_num_checked + 1;
        end
    end;
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 30;
    
    sw_frame.settings_frame.tooltip_settings_label_misc = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.tooltip_settings_label_misc:SetFontObject(font);
    sw_frame.settings_frame.tooltip_settings_label_misc:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.tooltip_settings_label_misc:SetText("Miscellaneous Settings");
    sw_frame.settings_frame.tooltip_settings_label_misc:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.libstub_icon_checkbox = 
        create_sw_checkbox("sw_settings_show_minimap_button", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Minimap Icon", function(self) 

        __sw__persistent_data_per_char.settings.libstub_minimap_icon.hide = not self:GetChecked();
        if __sw__persistent_data_per_char.settings.libstub_minimap_icon.hide then
            libstub_icon:Hide(sw_addon_name);

        else
            libstub_icon:Show(sw_addon_name);
        end
    end);

    sw_frame.settings_frame.show_tooltip_only_when_shift_button = 
        create_sw_checkbox("sw_settings_show_tooltip_only_when_shift_button", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "SHIFT to show tooltip", function(self)
        sw_frame.settings_frame.show_tooltip_only_when_shift = self:GetChecked();
    end);
    sw_frame.settings_frame.show_tooltip_only_when_shift = 
        __sw__persistent_data_per_char.settings.show_tooltip_only_when_shift;
    sw_frame.settings_frame.show_tooltip_only_when_shift_button:SetChecked(
        sw_frame.settings_frame.show_tooltip_only_when_shift
    );
end

local function create_sw_gui_stat_comparison_frame()

    sw_frame.stat_comparison_frame:SetWidth(370);
    sw_frame.stat_comparison_frame:SetHeight(600);
    sw_frame.stat_comparison_frame:SetPoint("TOP", sw_frame, 0, -20);

    sw_frame.stat_comparison_frame.line_y_offset = -15;

    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.instructions_label = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.instructions_label:SetFontObject(font);
    sw_frame.stat_comparison_frame.instructions_label:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.instructions_label:SetText("See project page for an example use case of this tool:");


    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.instructions_label1 = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.instructions_label1:SetFontObject(font);
    sw_frame.stat_comparison_frame.instructions_label1:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.instructions_label1:SetText("https://www.curseforge.com/wow/addons/stat-weights-classic");

    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

    sw_frame.stat_comparison_frame.loadout_label = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.loadout_label:SetFontObject(font);
    sw_frame.stat_comparison_frame.loadout_label:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.loadout_label:SetText("Active Loadout: ");
    sw_frame.stat_comparison_frame.loadout_label:SetTextColor(222/255, 192/255, 40/255);

    sw_frame.stat_comparison_frame.loadout_name_label = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.loadout_name_label:SetFontObject(font);
    sw_frame.stat_comparison_frame.loadout_name_label:SetPoint("TOPLEFT", 110, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.loadout_name_label:SetText("Missing loadout!");
    sw_frame.stat_comparison_frame.loadout_name_label:SetTextColor(222/255, 192/255, 40/255);


    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

    sw_frame.stat_comparison_frame.stat_diff_header_left = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.stat_diff_header_left:SetFontObject(font);
    sw_frame.stat_comparison_frame.stat_diff_header_left:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.stat_diff_header_left:SetText("Stat");

    sw_frame.stat_comparison_frame.stat_diff_header_center = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.stat_diff_header_center:SetFontObject(font);
    sw_frame.stat_comparison_frame.stat_diff_header_center:SetPoint("TOPRIGHT", -80, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.stat_diff_header_center:SetText("Difference");

    local num_stats = 9;

    sw_frame.stat_comparison_frame.clear_button = CreateFrame("Button", "button", sw_frame.stat_comparison_frame, "UIPanelButtonTemplate"); 
    sw_frame.stat_comparison_frame.clear_button:SetScript("OnClick", function()

        for i = 1, num_stats do

            sw_frame.stat_comparison_frame.stats[i].editbox:SetText("");
        end

        update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
    end);

    sw_frame.stat_comparison_frame.clear_button:SetPoint("TOPRIGHT", -30, sw_frame.stat_comparison_frame.line_y_offset + 3);
    sw_frame.stat_comparison_frame.clear_button:SetHeight(15);
    sw_frame.stat_comparison_frame.clear_button:SetWidth(50);
    sw_frame.stat_comparison_frame.clear_button:SetText("Clear");

    --sw_frame.stat_comparison_frame.line_y_offset = sw_frame.stat_comparison_frame.line_y_offset - 10;


    sw_frame.stat_comparison_frame.stats = {
        [1] = {
            label_str = "Intellect"
        },
        [2] = {
            label_str = "Spirit"
        },
        [3] = {
            label_str = "Mana"
        },
        [4] = {
            label_str = "MP5"
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
            label_str = "Spell Crit"
        },
        [9] = {
            label_str = "Spell Hit"
        }
        --,
        --[8] = {
        --    label_str = "Holy spell power"
        --},
        --[9] = {
        --    label_str = "Fire spell power"
        --},
        --[10] = {
        --    label_str = "Nature spell power"
        --},
        --[11] = {
        --    label_str = "Frost spell power"
        --},
        --[12] = {
        --    label_str = "Shadow spell power"
        --},
        --[13] = {
        --    label_str = "Arcane spell power"
        --}
    };

    for i = 1 , num_stats do

        v = sw_frame.stat_comparison_frame.stats[i];

        sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

        v.label = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");

        v.label:SetFontObject(font);
        v.label:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
        v.label:SetText(v.label_str);
        v.label:SetTextColor(222/255, 192/255, 40/255);


        v.editbox = CreateFrame("EditBox", v.label_str.."editbox"..i, sw_frame.stat_comparison_frame, "InputBoxTemplate");
        v.editbox:SetPoint("TOPRIGHT", -30, sw_frame.stat_comparison_frame.line_y_offset);
        v.editbox:SetText("");
        v.editbox:SetAutoFocus(false);
        v.editbox:SetSize(100, 10);
        v.editbox:SetScript("OnTextChanged", function(self)

            if string.match(self:GetText(), "[^-+0123456789. ()]") ~= nil then
                self:ClearFocus();
                self:SetText("");
                self:SetFocus();
            else 
                update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
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
            sw_frame.stat_comparison_frame.stats[next_index].editbox:SetFocus();
        end);
    end

    sw_frame.stat_comparison_frame.stats[stat_ids_in_ui.sp].editbox:SetText("1");

    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

    -- sim type button
    sw_frame.stat_comparison_frame.sim_type_button = 
        CreateFrame("Button", "sw_sim_type_button", sw_frame.stat_comparison_frame, "UIDropDownMenuTemplate"); 
    sw_frame.stat_comparison_frame.sim_type_button:SetPoint("TOPLEFT", -5, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.sim_type_button.init_func = function()
        UIDropDownMenu_Initialize(sw_frame.stat_comparison_frame.sim_type_button, function()
            
            if sw_frame.stat_comparison_frame.sim_type == simulation_type.spam_cast then 
                UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Infinite Spam Cast");
            elseif sw_frame.stat_comparison_frame.sim_type == simulation_type.race_to_the_bottom then 
                UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Race to the Bottom");
            end
            UIDropDownMenu_SetWidth(sw_frame.stat_comparison_frame.sim_type_button, 130);

            UIDropDownMenu_AddButton(
                {
                    text = "Infinite Spam Cast",
                    func = function()

                        sw_frame.stat_comparison_frame.sim_type = simulation_type.spam_cast;
                        UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Infinite Spam Cast");
                        sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Show();
                        sw_frame.stat_comparison_frame.spell_diff_header_right_race_to_the_bottom:Hide();
                        update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
                    end
                }
            );
            UIDropDownMenu_AddButton(
                {
                    text = "Race to the Bottom",
                    func = function()

                        sw_frame.stat_comparison_frame.sim_type = simulation_type.race_to_the_bottom;
                        UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Race to the Bottom");
                        sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Hide();
                        sw_frame.stat_comparison_frame.spell_diff_header_right_race_to_the_bottom:Show();
                        update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
                    end
                }
            );
        end);
    end;

    sw_frame.stat_comparison_frame.sim_type_button:SetText("Simulation type");

    -- header for spells
    sw_frame.stat_comparison_frame.export_button = CreateFrame("Button", "button", sw_frame.stat_comparison_frame, "UIPanelButtonTemplate"); 
    sw_frame.stat_comparison_frame.export_button:SetScript("OnClick", function()

        local loadout = active_loadout_copy();

        local loadout_diff = create_loadout_from_ui_diff(sw_frame.stat_comparison_frame);

        local new_loadout = loadout_add(loadout, loadout_diff);

        new_loadout.is_dynamic_loadout = false;

        create_new_loadout_as_copy(new_loadout, active_loadout_base().name.." (modified)");

        sw_activate_tab(2);
    end);


    sw_frame.stat_comparison_frame.export_button:SetPoint("TOPRIGHT", -25, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.export_button:SetHeight(20);
    sw_frame.stat_comparison_frame.export_button:SetWidth(110);
    sw_frame.stat_comparison_frame.export_button:SetText("New Loadout");

    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

    sw_frame.stat_comparison_frame.line_y_offset_before_dynamic_spells = sw_frame.stat_comparison_frame.line_y_offset;

    sw_frame.stat_comparison_frame.spell_diff_header_spell = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_spell:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_spell:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_spell:SetText("Spell");

    sw_frame.stat_comparison_frame.spell_diff_header_left = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_left:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_left:SetPoint("TOPRIGHT", -180, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_left:SetText("Change");

    sw_frame.stat_comparison_frame.spell_diff_header_center = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_center:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_center:SetPoint("TOPRIGHT", -105, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_center:SetText("DMG/HEAL");

    sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:SetPoint("TOPRIGHT", -45, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:SetText("DPS/HPS");

    sw_frame.stat_comparison_frame.spell_diff_header_right_race_to_the_bottom = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_right_race_to_the_bottom:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_right_race_to_the_bottom:SetPoint("TOPRIGHT", -20, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_right_race_to_the_bottom:SetText("DURATION (s)");

    -- always have at least one
    sw_frame.stat_comparison_frame.spells = {};
    sw_frame.stat_comparison_frame.sim_type = simulation_type.spam_cast;

    if UnitLevel("player") == 60 then

        if class == "MAGE" then
            sw_frame.stat_comparison_frame.spells[10181] = {-- pre AQ
                name = localized_spell_name("Frostbolt")
            };
            sw_frame.stat_comparison_frame.spells[10151] = {-- pre AQ
                name = localized_spell_name("Fireball")
            };
        elseif class == "DRUID" then

            sw_frame.stat_comparison_frame.spells[9889] = {-- pre AQ
                name = localized_spell_name("Healing Touch")
            };
            sw_frame.stat_comparison_frame.spells[9876] = {-- pre AQ
                name = localized_spell_name("Starfire")
            };

        elseif class == "PALADIN" then

            sw_frame.stat_comparison_frame.spells[19943] = {
                name = localized_spell_name("Flash of Light")
            };
            sw_frame.stat_comparison_frame.spells[10329] = {-- pre AQ
                name = localized_spell_name("Holy Light")
            };
        elseif class == "SHAMAN" then

            sw_frame.stat_comparison_frame.spells[10396] = {--pre AQ
                name = localized_spell_name("Healing Wave")
            };
            sw_frame.stat_comparison_frame.spells[15208] = {
                name = localized_spell_name("Lightning Bolt")
            };
        elseif class == "PRIEST" then

            sw_frame.stat_comparison_frame.spells[10965] = { -- pre AQ
                name = localized_spell_name("Greater Heal")
            };
            sw_frame.stat_comparison_frame.spells[10929] = { -- pre AQ
                name = localized_spell_name("Renew")
            };
        elseif class == "WARLOCK" then

            sw_frame.stat_comparison_frame.spells[11661] = {-- pre AQ
                name = localized_spell_name("Shadow Bolt")
            };
            sw_frame.stat_comparison_frame.spells[11672] = {-- pre AQ
                name = localized_spell_name("Corruption")
            };
            sw_frame.stat_comparison_frame.spells[11713] = {
                name = localized_spell_name("Curse of Agony")
            };
        end
    end

end

local sw_frame_loadout_buff_index = 1;

local function create_loadout_buff_checkbutton(buffs_table, buff_info, buff_type, parent_frame, y_offset, func)

    buffs_table[sw_frame_loadout_buff_index] = {};
    buffs_table[sw_frame_loadout_buff_index].checkbutton = CreateFrame("CheckButton", "loadout_apply_buffs_"..buff_info.id, parent_frame, "ChatConfigCheckButtonTemplate");
    buffs_table[sw_frame_loadout_buff_index].checkbutton:SetPoint("TOP", 10, y_offset);
    buffs_table[sw_frame_loadout_buff_index].checkbutton.buff_info = buff_info;
    buffs_table[sw_frame_loadout_buff_index].checkbutton.buff_type = buff_type;
    getglobal(buffs_table[sw_frame_loadout_buff_index].checkbutton:GetName() .. 'Text'):SetText(buff_info.name);

    buffs_table[sw_frame_loadout_buff_index].checkbutton:SetScript("OnClick", func);

    sw_frame_loadout_buff_index = sw_frame_loadout_buff_index + 1;

    return buffs_table[sw_frame_loadout_buff_index - 1].checkbutton;
end

local function create_sw_gui_loadout_frame()

    sw_frame.loadouts_frame:SetWidth(370);
    sw_frame.loadouts_frame:SetHeight(600);
    sw_frame.loadouts_frame:SetPoint("TOP", sw_frame, 0, -20);

    sw_frame.loadouts_frame.lhs_list = CreateFrame("ScrollFrame", "sw_loadout_frame_lhs", sw_frame.loadouts_frame);
    sw_frame.loadouts_frame.lhs_list:SetWidth(150);
    sw_frame.loadouts_frame.lhs_list:SetHeight(600-30-200-10-25-10-20);
    sw_frame.loadouts_frame.lhs_list:SetPoint("TOPLEFT", sw_frame, 0, -50);

    sw_frame.loadouts_frame.rhs_list = CreateFrame("ScrollFrame", "sw_loadout_frame_rhs", sw_frame.loadouts_frame);
    sw_frame.loadouts_frame.rhs_list:SetWidth(150);
    sw_frame.loadouts_frame.rhs_list:SetHeight(600-30);
    sw_frame.loadouts_frame.rhs_list:SetPoint("TOP", sw_frame, 0, -20);

    sw_frame.loadouts_frame.loadouts_select_label = sw_frame.loadouts_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.loadouts_select_label:SetFontObject(font);
    sw_frame.loadouts_frame.loadouts_select_label:SetPoint("TOPLEFT", sw_frame.loadouts_frame, 15, -32);
    sw_frame.loadouts_frame.loadouts_select_label:SetText("Select Active Loadout");
    sw_frame.loadouts_frame.loadouts_select_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.loadouts_frame.rhs_list.self_buffs_frame = 
        CreateFrame("ScrollFrame", "sw_loadout_frame_rhs_self_buffs", sw_frame.loadouts_frame.rhs_list);
    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetWidth(150);
    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetHeight(500);
    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetPoint("TOPLEFT", sw_frame.loadouts_frame.rhs_list, 0, 0);

    sw_frame.loadouts_frame.rhs_list.target_buffs_frame = 
        CreateFrame("ScrollFrame", "sw_loadout_frame_rhs_target_buffs", sw_frame.loadouts_frame.rhs_list);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetWidth(150);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetHeight(500);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetPoint("TOPLEFT", sw_frame.loadouts_frame.rhs_list, 0, 0);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:Hide();

    sw_frame.loadouts_frame.rhs_list.num_buffs_checked = 0;
    sw_frame.loadouts_frame.rhs_list.num_target_buffs_checked = 0;

    local y_offset_lhs = 0;
    
    sw_frame.loadouts_frame.rhs_list.delete_button =
        CreateFrame("Button", "sw_loadouts_delete_button", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.delete_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.delete_button:SetText("Delete Loadout");
    sw_frame.loadouts_frame.rhs_list.delete_button:SetSize(170, 25);
    sw_frame.loadouts_frame.rhs_list.delete_button:SetScript("OnClick", function(self)
        
        if sw_frame.loadouts_frame.lhs_list.num_loadouts == 1 then
            return;
        end

        sw_frame.loadouts_frame.lhs_list.loadouts[
            sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(false);
        
        for i = sw_frame.loadouts_frame.lhs_list.num_loadouts - 1, sw_frame.loadouts_frame.lhs_list.active_loadout, -1  do
            sw_frame.loadouts_frame.lhs_list.loadouts[i].loadout = sw_frame.loadouts_frame.lhs_list.loadouts[i+1].loadout;
        end

        sw_frame.loadouts_frame.lhs_list.loadouts[
            sw_frame.loadouts_frame.lhs_list.num_loadouts].check_button:Hide();

        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.num_loadouts] = nil;

        sw_frame.loadouts_frame.lhs_list.num_loadouts = sw_frame.loadouts_frame.lhs_list.num_loadouts - 1;

        sw_frame.loadouts_frame.lhs_list.active_loadout = sw_frame.loadouts_frame.lhs_list.num_loadouts;

        update_loadouts_lhs();
    end);

    y_offset_lhs = y_offset_lhs - 30;

    sw_frame.loadouts_frame.rhs_list.export_button =
        CreateFrame("Button", "sw_loadouts_export_button", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.export_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.export_button:SetText("Create Loadout as a Copy");
    sw_frame.loadouts_frame.rhs_list.export_button:SetSize(170, 25);
    sw_frame.loadouts_frame.rhs_list.export_button:SetScript("OnClick", function(self)

        local loadout = active_loadout_base();
        create_new_loadout_as_copy(loadout, loadout.name);
    end);

    y_offset_lhs = y_offset_lhs - 20;


--
    sw_frame.loadouts_frame.rhs_list.loadout_talent_label = sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_talent_label:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_talent_label:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_talent_label:SetText("Talents");

    sw_frame.loadouts_frame.rhs_list.talent_editbox = 
        CreateFrame("EditBox", "sw_loadout_talent_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 65, y_offset_lhs - 2);
    --sw_frame.loadouts_frame.rhs_list.talent_editbox:SetText("");
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetSize(110, 15);
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetAutoFocus(false);
    local talent_editbox = function(self)

        local txt = self:GetText();
        local loadout = sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout;

        if txt == wowhead_talent_link(loadout.talents_code) then
            return;
        end

        local loadout_before = active_loadout_buffed_talented_copy();


        sw_frame.loadouts_frame.lhs_list.loadouts[
            sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.is_dynamic_loadout = false;

        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout = 
            static_loadout_from_dynamic(active_loadout_base());

        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.talents_code =
            wowhead_talent_code_from_url(txt);

        local loadout_after = active_loadout_buffed_talented_copy();

        sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(false);

        static_rescale_from_talents_diff(loadout_after, loadout_before);

        update_loadouts_lhs();
    end

    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetScript("OnEnterPressed", function(self) 
        talent_editbox(self);
        self:ClearFocus();
    end);
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetScript("OnEscapePressed", function(self) 
        talent_editbox(self);
        self:ClearFocus();
    end);

    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetScript("OnTextChanged", talent_editbox);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.loadout_rename_label = 
        sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_rename_label:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_rename_label:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_rename_label:SetText("Rename");

    sw_frame.loadouts_frame.rhs_list.name_editbox = 
        CreateFrame("EditBox", "sw_loadout_name_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 65, y_offset_lhs - 2);
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetText("");
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetSize(110, 15);
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetAutoFocus(false);
    local editbox_save = function(self)

        local txt = self:GetText();
        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.name = txt;

        update_loadouts_lhs();
    end

    sw_frame.loadouts_frame.rhs_list.name_editbox:SetScript("OnEnterPressed", function(self) 
        editbox_save(self);
        self:ClearFocus();
    end);
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetScript("OnEscapePressed", function(self) 
        editbox_save(self);
        self:ClearFocus();
    end);
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetScript("OnTextChanged", editbox_save);

    y_offset_lhs = y_offset_lhs - 20;


    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana = 
        sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana:SetText("Extra mana (pots)");

    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 120, y_offset_lhs - 2);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetSize(50, 15);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetAutoFocus(false);

    local mana_editbox = function(self)

        local txt = self:GetText();
        
        local mana = tonumber(txt);
        if mana then
            active_loadout_base().extra_mana = mana;
            
        else
            self:SetText("0");
            active_loadout_base().extra_mana = 0;
        end

    	self:ClearFocus();
    end

    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetScript("OnEnterPressed", mana_editbox);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetScript("OnEscapePressed", mana_editbox);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.loadout_level_label = 
        sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_level_label:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_level_label:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_level_label:SetText("Default target level");

    sw_frame.loadouts_frame.rhs_list.level_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 130, y_offset_lhs - 2);
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetText("");
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetSize(40, 15);
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetAutoFocus(false);

    local editbox_lvl = function(self)

        local txt = self:GetText();
        
        local lvl = tonumber(txt);
        if lvl and lvl == math.floor(lvl) and lvl >= 1 and lvl <= 63 then

            active_loadout_base().target_lvl = lvl;
            
        else
            self:SetText(""..active_loadout_base().target_lvl); 
        end

    	self:ClearFocus();
    end

    sw_frame.loadouts_frame.rhs_list.level_editbox:SetScript("OnEnterPressed", editbox_lvl);
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetScript("OnEscapePressed", editbox_lvl);

    y_offset_lhs = y_offset_lhs - 25;

    sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_dynamic_target_level", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton:GetName()..'Text'):SetText("Use target's level");
    getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton:GetName()).tooltip = 
        "Only works with dynamic loadouts. If level is unknown '?' 3 levels above yourself is assumed";

    sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton :SetScript("OnClick", function(self)
        active_loadout_base().use_dynamic_target_lvl = self:GetChecked();
    end)

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.dynamic_button = 
        CreateFrame("CheckButton", "sw_loadout_dynamic_check", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.dynamic_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_button:GetName()..'Text'):SetText("Dynamic loadout");
    getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_button:GetName()).tooltip = 
        "Dynamic loadouts use your current equipment, set bonuses, talents. In addition, self buffs and target's buffs/debuffs may be applied if so chosen";

    sw_frame.loadouts_frame.rhs_list.dynamic_button:SetScript("OnClick", function(self)
        
        if self:GetChecked() then

            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.is_dynamic_loadout = true;

            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout = empty_loadout_with_buffs(active_loadout_base());

            
            sw_frame.loadouts_frame.rhs_list.static_button:SetChecked(false);
        else

            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.is_dynamic_loadout = false;

            sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout = 
                static_loadout_from_dynamic(active_loadout_base());

            sw_frame.loadouts_frame.rhs_list.static_button:SetChecked(true);
        end
        update_loadouts_rhs();
    end);

    y_offset_lhs = y_offset_lhs - 20;
    sw_frame.loadouts_frame.rhs_list.static_button = 
        CreateFrame("CheckButton", "sw_loadout_static_check_button", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.static_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    getglobal(sw_frame.loadouts_frame.rhs_list.static_button:GetName()..'Text'):SetText("Static loadout");
    getglobal(sw_frame.loadouts_frame.rhs_list.static_button:GetName()).tooltip =
        "Static loadouts never change and can be used to create custom setups. When checked, a static loadout is a snapshot of a dynamic loadout or can be created with modified stats through the stat comparison tool"
    sw_frame.loadouts_frame.rhs_list.static_button:SetScript("OnClick", function(self)

        if self:GetChecked() then
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.is_dynamic_loadout = false;

            sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout = 
                static_loadout_from_dynamic(active_loadout_base());

            sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(false);
        else
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.is_dynamic_loadout = true;

            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout = empty_loadout_with_buffs(active_loadout_base());

            sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(true);
        end
        update_loadouts_rhs();
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button = 
        CreateFrame("CheckButton", "sw_loadout_always_apply_buffs_button", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.apply_buffs_button = 
        CreateFrame("CheckButton", "sw_loadout_apply_buffs_button", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    getglobal(sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:GetName() .. 'Text'):SetText("Apply buffs ALWAYS");
    getglobal(sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:GetName()).tooltip = 
        "The selected buffs always be applied, but only if not already active";
    sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetScript("OnClick", function(self)

        if self:GetChecked() then
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.always_assume_buffs = true;
            sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetChecked(false);
        else
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.always_assume_buffs = false;
            sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetChecked(true);
        end
            
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    getglobal(sw_frame.loadouts_frame.rhs_list.apply_buffs_button:GetName() .. 'Text'):SetText("Apply buffs IF ACTIVE");
    getglobal(sw_frame.loadouts_frame.rhs_list.apply_buffs_button:GetName()).tooltip =
        "The selected buffs will be applied only if already active";
    sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetScript("OnClick", function(self)

        if self:GetChecked() then
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.always_assume_buffs = false;
            sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetChecked(false);
        else
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.always_assume_buffs = true;
            sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetChecked(true);
        end
            
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.loadout_dump =
        CreateFrame("Button", "sw_loadouts_loadout_dump", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.loadout_dump:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_dump:SetText("Print Loadout (Ugly!)");
    sw_frame.loadouts_frame.rhs_list.loadout_dump:SetSize(170, 20);
    sw_frame.loadouts_frame.rhs_list.loadout_dump:SetScript("OnClick", function(self)

        print_loadout(active_loadout_buffed_talented_copy());
    end);

    local y_offset_rhs = -30;


    sw_frame.loadouts_frame.rhs_list.buffs_button =
        CreateFrame("Button", "sw_frame_buffs_button", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetScript("OnClick", function(self)

        sw_frame.loadouts_frame.rhs_list.self_buffs_frame:Show();

        sw_frame.loadouts_frame.rhs_list.buffs_button:LockHighlight();
        sw_frame.loadouts_frame.rhs_list.buffs_button:SetButtonState("PUSHED");

        sw_frame.loadouts_frame.rhs_list.target_buffs_frame:Hide();

        sw_frame.loadouts_frame.rhs_list.target_buffs_button:UnlockHighlight();
        sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetButtonState("NORMAL");

    end);
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetPoint("TOP", 40, y_offset_rhs);
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetText("Self Buffs");
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetWidth(90);
    sw_frame.loadouts_frame.rhs_list.buffs_button:LockHighlight();
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetButtonState("PUSHED");


    sw_frame.loadouts_frame.rhs_list.target_buffs_button =
        CreateFrame("Button", "sw_frame_target_buffs_button", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetScript("OnClick", function(self)

        sw_frame.loadouts_frame.rhs_list.target_buffs_frame:Show();

        sw_frame.loadouts_frame.rhs_list.target_buffs_button:LockHighlight();
        sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetButtonState("PUSHED");

        sw_frame.loadouts_frame.rhs_list.self_buffs_frame:Hide();

        sw_frame.loadouts_frame.rhs_list.buffs_button:UnlockHighlight();
        sw_frame.loadouts_frame.rhs_list.buffs_button:SetButtonState("NORMAL");

    end);
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetPoint("TOP", 130, y_offset_rhs);
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetText("Target Buffs");
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetWidth(90);

    y_offset_rhs = y_offset_rhs - 20;

    sw_frame.loadouts_frame.rhs_list.buffs = {};
    sw_frame.loadouts_frame.rhs_list.target_buffs = {};
    sw_frame.loadouts_frame.rhs_list.target_debuffs = {};

    local check_button_buff_func = function(self)

        if self:GetChecked() then
            if self.buff_type == "self1" then
                sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.buffs1 =
                    bit.bor(
                        self.buff_info.flag,
                        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.buffs1
                    );
                sw_frame.loadouts_frame.rhs_list.num_checked_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_buffs + 1;
            elseif self.buff_type == "self2" then
                sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.buffs2 =
                    bit.bor(
                        self.buff_info.flag,
                        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_buffs1
                    );
                sw_frame.loadouts_frame.rhs_list.num_checked_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_buffs + 1;
            elseif self.buff_type == "target_buffs1" then
                sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_buffs1 =
                    bit.bor(
                        self.buff_info.flag,
                        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_buffs1
                    );
                sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs + 1;
            elseif self.buff_type == "target_debuffs1" then
                sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_debuffs1 =
                    bit.bor(
                        self.buff_info.flag,
                        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_debuffs1
                    );
                sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs + 1;
            end

        else    
            if self.buff_type == "self1" then
                sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.buffs1 =
                    bit.band(
                        bit.bnot(self.buff_info.flag),
                        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.buffs1
                    );
                sw_frame.loadouts_frame.rhs_list.num_checked_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_buffs - 1;
            elseif self.buff_type == "self2" then
                sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.buffs2 =
                    bit.band(
                        bit.bnot(self.buff_info.flag),
                        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_buffs1
                    );
                sw_frame.loadouts_frame.rhs_list.num_checked_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_buffs - 1;
            elseif self.buff_type == "target_buffs1" then
                sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_buffs1 =
                    bit.band(
                        bit.bnot(self.buff_info.flag),
                        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_buffs1
                    );
                sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs - 1;
            elseif self.buff_type == "target_debuffs1" then
                sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_debuffs1 =
                    bit.band(
                        bit.bnot(self.buff_info.flag),
                        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_debuffs1
                    );
                sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs - 1;
            end
        end

        if sw_frame.loadouts_frame.rhs_list.num_checked_buffs == 0 then
            sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(true);
        end

        if sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs == 0 then
            sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(true);
        end

    end

    local y_offset_rhs_buffs = y_offset_rhs - 3;
    local y_offset_rhs_target_buffs = y_offset_rhs - 3;

    -- add select all optoin for both buffs and debuffs

    sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_select_all_buffs", sw_frame.loadouts_frame.rhs_list.self_buffs_frame, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetPoint("TOP", 10, y_offset_rhs_buffs);
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:GetName() .. 'Text'):SetText("SELECT ALL/NONE");
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:GetName() .. 'Text'):SetTextColor(1, 0, 0);

    sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetScript("OnClick", function(self) 
        if self:GetChecked() then
            active_loadout_base().buffs1 = bit.bnot(0);
            active_loadout_base().buffs2 = bit.bnot(0);
        else
            active_loadout_base().buffs1 = 0;
            active_loadout_base().buffs2 = 0;
        end

        update_loadouts_rhs();
    end);

    sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_select_all_target_buffs", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetPoint("TOP", 10, y_offset_rhs_buffs);
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:GetName() .. 'Text'):SetText("SELECT ALL/NONE");
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:GetName() .. 'Text'):SetTextColor(1, 0, 0);
    sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetScript("OnClick", function(self)
        if self:GetChecked() then
            active_loadout_base().target_buffs1 = bit.bnot(0);
            active_loadout_base().target_debuffs1 = bit.bnot(0);
        else
            active_loadout_base().target_buffs1 = 0;
            active_loadout_base().target_debuffs1 = 0;
        end
        update_loadouts_rhs();
    end);

    y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
    y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;

    -- general buff
    create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.ony, "self1", 
                                    sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                    check_button_buff_func);
    y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
    create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.wcb, "self1", 
                                    sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                    check_button_buff_func);
    y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
    create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.songflower, "self1", 
                                    sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                    check_button_buff_func);
    y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
    create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.spirit_of_zandalar, "self1", 
                                    sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                    check_button_buff_func);
    y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
    create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.dmf_dmg, "self1", 
                                    sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                    check_button_buff_func);
    y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
    -- general target buff
    create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_buffs, target_buffs1.amplify_magic, "target_buffs1", 
                                    sw_frame.loadouts_frame.rhs_list.target_buffs_frame, y_offset_rhs_target_buffs, 
                                    check_button_buff_func);
    y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;
    create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_buffs, target_buffs1.dampen_magic, "target_buffs1", 
                                    sw_frame.loadouts_frame.rhs_list.target_buffs_frame, y_offset_rhs_target_buffs, 
                                    check_button_buff_func);
    y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;

    -- general target debuff

    if faction == "Horde" then
        -- general horde buffs
        
    else
        -- general ally buffs
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs2.bok, "self2", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs2.bow, "self2", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
    end



    -- caster buff/debuffs
    if class == "MAGE" or class == "PRIEST" or class == "WARLOCK" or
       class == "SHAMAN" or class == "DRUID" or class == "PALADIN" then

        -- self buffs
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.runn_tum_tuber_surprise, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.power_infusion, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.int, "self1",
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.motw, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.spirit, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.dmt_crit, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.toep, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.greater_arcane_elixir, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        -- self buffs 2
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs2.zandalarian_hero_charm, "self2", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs2.flask_of_supreme_power, "self2", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs2.flask_of_distilled_wisdom, "self2", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs2.nightfin, "self2", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;

        -- target buffs
        -- target debuffs
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_debuffs, target_debuffs1.nightfall, 
                                         "target_debuffs1", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, 
                                         y_offset_rhs_target_buffs, check_button_buff_func);
        y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;

        -- shadow dmg classes
        if class == "PRIEST" or class == "WARLOCK" then

            create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.elixir_of_shadow_power, "self1", 
                                            sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                            check_button_buff_func);
            y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
            create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_debuffs, target_debuffs1.improved_shadow_bolt,
                                             "target_debuffs1", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, 
                                             y_offset_rhs_target_buffs, check_button_buff_func);
            y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;
            create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_debuffs, target_debuffs1.shadow_weaving,
                                             "target_debuffs1", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, 
                                             y_offset_rhs_target_buffs, check_button_buff_func);
            y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;
        end

        -- fire dmg classes
        if class == "MAGE" or class == "WARLOCK" or class == "SHAMAN" then
            create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.elixir_of_greater_firepower, "self1", 
                                            sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                            check_button_buff_func);
            y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
            create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_debuffs, target_debuffs1.improved_scorch,
                                             "target_debuffs1", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, 
                                             y_offset_rhs_target_buffs, check_button_buff_func);
            y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;

        end
        -- frost dmg classes
        if class == "MAGE" or class == "SHAMAN" then
            create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.elixir_of_frost_power, "self1", 
                                            sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                            check_button_buff_func);
            y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
            create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_debuffs, target_debuffs1.wc, 
                                             "target_debuffs1", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, 
                                             y_offset_rhs_target_buffs, check_button_buff_func);
            y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;
        end
        -- nature dmg classes
        if class == "DRUID" or class == "SHAMAN" then
            create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_debuffs, target_debuffs1.stormstrike,
                                             "target_debuffs1", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, 
                                             y_offset_rhs_target_buffs, check_button_buff_func);
            y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;
        end

       
    end
    -- mage buff/debuffs
    if class == "MAGE" then
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.arcane_power, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.mind_quickening_gem, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.hazzrahs_charm_of_magic, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs2.mage_armor, "self2", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_debuffs, target_debuffs1.curse_of_the_elements,
                                         "target_debuffs1", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, 
                                         y_offset_rhs_target_buffs, check_button_buff_func);
        y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_debuffs, target_debuffs1.curse_of_shadow,
                                         "target_debuffs1", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, 
                                         y_offset_rhs_target_buffs, check_button_buff_func);
        y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;

    -- warlock buff/debuffs
    elseif class == "WARLOCK" then
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.hazzrahs_charm_of_destr, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.amplify_curse, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.demonic_sacrifice, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_debuffs, target_debuffs1.curse_of_the_elements,
                                         "target_debuffs1", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, 
                                         y_offset_rhs_target_buffs, check_button_buff_func);
        y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_debuffs, target_debuffs1.curse_of_shadow,
                                         "target_debuffs1", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, 
                                         y_offset_rhs_target_buffs, check_button_buff_func);
        y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;
    -- shaman buff/debuffs
    elseif class == "SHAMAN" then
        -- self buffs1
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.wushoolays_charm_of_spirits, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        -- self buffs2
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs2.natural_alignment_crystal, "self2", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        -- target buffs
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_buffs, target_buffs1.healing_way, "target_buffs1", 
                                        sw_frame.loadouts_frame.rhs_list.target_buffs_frame, y_offset_rhs_target_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_debuffs, target_debuffs1.curse_of_the_elements,
                                         "target_debuffs1", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, 
                                         y_offset_rhs_target_buffs, check_button_buff_func);
        y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;
    -- paladin buff/debuffs
    elseif class == "PALADIN" then
        -- self buffs
        --create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.grileks_charm_of_valor, "self1", 
        --                                sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs,
        --                                check_button_buff_func);
        --y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs2.vengeance, "self2", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs- 20;
        -- target buffs
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_buffs, target_buffs1.blessing_of_light, "target_buffs1", 
                                        sw_frame.loadouts_frame.rhs_list.target_buffs_frame, y_offset_rhs_target_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;
    -- druid buff/debuffs
    elseif class == "DRUID" then
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.wushoolays_charm_of_nature, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_debuffs, target_debuffs1.curse_of_shadow,
                                         "target_debuffs1", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, 
                                         y_offset_rhs_target_buffs, check_button_buff_func);
        y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;
    elseif class == "PRIEST" then
    -- priest buff/debuffs
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.shadow_form, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.hazzrahs_charm_of_healing, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs2.blessed_prayer_beads, "self2", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.target_debuffs, target_debuffs1.curse_of_shadow,
                                         "target_debuffs1", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, 
                                         y_offset_rhs_target_buffs, check_button_buff_func);
        y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;
    end
   
    if race == "Troll" then
        local berserking_checkbutton = 
        create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs1.berserking, "self1", 
                                        sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                        check_button_buff_func);
        getglobal(berserking_checkbutton:GetName()).tooltip = 
            "If berserk is active, 10-30% haste is applied depending on your HP when used. Otherwise 10% is default";
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
            create_loadout_buff_checkbutton(sw_frame.loadouts_frame.rhs_list.buffs, buffs2.troll_vs_beast, "self2", 
                                            sw_frame.loadouts_frame.rhs_list.self_buffs_frame, y_offset_rhs_buffs, 
                                            check_button_buff_func);
        y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
    end
end

local function action_id_of_button(button)

    if action_bar_addon_name == "Default" then
        return button.action;
    else
        -- Dominos seems to set GetAttribute function for the 1-6 default blizz bars
        return button:GetAttribute("action");
    end
end

local function gather_spell_icons()

    local action_bar_frame_names = {};
    local spell_book_frames = {};

    local index = 1;
    -- gather spell book icons
    if false then -- check for some common addons if they overrite spellbook frames

    else -- default spellbook frames
        for i = 1, 16 do

            spell_book_frames[i] = { 
                frame = getfenv()["SpellButton"..i];
            };
        end
    end
    for i = 1, 16 do

        spell_book_frames[i].overlay_frames = {nil, nil, nil};
    end

    -- danni er faggi

    -- gather action bar icons
    index = 1;
    if IsAddOnLoaded("Bartender4") then -- check for some common addons if they overrite spellbook frames

        for i = 1, 120 do
            action_bar_frame_names[i] = "BT4Button"..i;
        end
        action_bar_addon_name = "Bartender4";

    elseif IsAddOnLoaded("ElvUI") then -- check for some common addons if they overrite spellbook frames

        local elvi_bar_order_to_match_action_ids = {1, 6, 5, 4, 2, 3, 7, 8, 9, 10};
        for i = 1, 10 do
            for j = 1, 12 do
                action_bar_frame_names[index] = 
                    "ElvUI_Bar"..elvi_bar_order_to_match_action_ids[i].."Button"..j;

                index = index + 1;
            end
        end
        action_bar_addon_name = "ElvUI";

    elseif IsAddOnLoaded("Dominos") then -- check for some common addons if they overrite spellbook frames

        local bars = {
            "ActionButton", "DominosActionButton", "MultiBarRightButton",
            "MultiBarLeftButton", "MultiBarBottomRightButton", "MultiBarBottomLeftButton"
        };
        index = 1;
        for k, v in pairs(bars) do
            for j = 1, 12 do
                action_bar_frame_names[index] = v..j;

                index = index + 1;
            end
        end

        local dominos_button_index = 13;
        for i = index, 120 do
            action_bar_frame_names[i] = "DominosActionButton"..dominos_button_index;

            dominos_button_index = dominos_button_index + 1;
        end
        action_bar_addon_name = "Dominos";

    else -- default action bars
        
        local bars = {
            "ActionButton", "BonusActionButton", "MultiBarRightButton",
            "MultiBarLeftButton", "MultiBarBottomRightButton", "MultiBarBottomLeftButton"
        };
        index = 1;
        for k, v in pairs(bars) do
            for j = 1, 12 do
                action_bar_frame_names[index] = v..j;

                index = index + 1;
            end
        end
        action_bar_addon_name = "Default";
    end

    local action_bar_frames_of_interest = {};

    for k, v in pairs(action_bar_frame_names) do

        local frame = getfenv()[v];
        if frame then

            local action_id = action_id_of_button(frame);
                
            local spell_id = 0;
            local action_type, id, _ = GetActionInfo(action_id);
            if action_type == "macro" then
                 spell_id, _ = GetMacroSpell(id);
            elseif action_type == "spell" then
                 spell_id = id;
            else
                spell_id = 0;
            end
            if not spells[spell_id] then
                spell_id = 0;
            end

            if spell_id ~= 0 then

                action_bar_frames_of_interest[action_id] = {};
                action_bar_frames_of_interest[action_id].spell_id = spell_id;
                action_bar_frames_of_interest[action_id].frame = frame; 
                action_bar_frames_of_interest[action_id].overlay_frames = {nil, nil, nil}
            end
        end
    end
    

    return {
        bar_names = action_bar_frame_names,
        bars = action_bar_frames_of_interest,
        book = spell_book_frames
    };
end

local function on_special_action_bar_changed()

    for i = 1, 12 do
    
        local frame = getfenv()[__sw__icon_frames.bar_names[i]];
        if frame then
    
            local action_id = action_id_of_button(frame);
                
            local spell_id = 0;
            local action_type, id, _ = GetActionInfo(action_id);
            if action_type == "macro" then
                 spell_id, _ = GetMacroSpell(id);
            elseif action_type == "spell" then
                 spell_id = id;
            else
                spell_id = 0;
            end
            if not spells[spell_id] then
                spell_id = 0;
            end
    
            if spell_id ~= 0 then
    
                if __sw__icon_frames.bars[i] then
                    for j = 1, 3 do
                        if __sw__icon_frames.bars[i].overlay_frames[j] then
                            __sw__icon_frames.bars[i].overlay_frames[j]:SetText("");
                            __sw__icon_frames.bars[i].overlay_frames[j]:Hide();
                        end
                    end
                end
    
                __sw__icon_frames.bars[i] = {};
                __sw__icon_frames.bars[i].spell_id = spell_id;
                __sw__icon_frames.bars[i].frame = frame; 
                __sw__icon_frames.bars[i].overlay_frames = {nil, nil, nil}
            else
                if __sw__icon_frames.bars[i] then
                    for j = 1, 3 do
                        if __sw__icon_frames.bars[i].overlay_frames[j] then
                            __sw__icon_frames.bars[i].overlay_frames[j]:SetText("");
                            __sw__icon_frames.bars[i].overlay_frames[j]:Hide();
                        end
                    end
                end
                __sw__icon_frames.bars[i] = nil; 
            end
        end
    end
end

local function create_sw_base_gui()

    sw_frame = CreateFrame("Frame", "sw_frame", UIParent, "BasicFrameTemplate, BasicFrameTemplateWithInset");

    sw_frame:SetMovable(true)
    sw_frame:EnableMouse(true)
    sw_frame:RegisterForDrag("LeftButton")
    sw_frame:SetScript("OnDragStart", sw_frame.StartMoving)
    sw_frame:SetScript("OnDragStop", sw_frame.StopMovingOrSizing)

    sw_frame.settings_frame = CreateFrame("ScrollFrame", "sw_settings_frame", sw_frame);
    sw_frame.loadouts_frame = CreateFrame("ScrollFrame", "sw_loadout_frame ", sw_frame);
    sw_frame.stat_comparison_frame = CreateFrame("ScrollFrame", "sw_stat_comparison_frame", sw_frame);

    sw_frame:RegisterEvent("ADDON_LOADED");
    sw_frame:RegisterEvent("PLAYER_LOGIN");
    sw_frame:RegisterEvent("PLAYER_LOGOUT");
    sw_frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
    --sw_frame:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
    --sw_frame:RegisterEvent("ACTIONBAR_UPDATE_STATE");
    sw_frame:RegisterEvent("UPDATE_STEALTH");
    sw_frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM");

    sw_frame:SetWidth(370);
    sw_frame:SetHeight(600);
    sw_frame:SetPoint("TOPLEFT", 400, -30);

    sw_frame.title = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.title:SetFontObject(font)
    sw_frame.title:SetText("Stat Weights Classic");
    sw_frame.title:SetPoint("CENTER", sw_frame.TitleBg, "CENTER", 11, 0);

    sw_frame:SetScript("OnEvent", function(self, event, msg)

        if event == "ADDON_LOADED" and msg == "stat_weights_classic" then

            if not class_is_supported then
                return;
            end
            create_sw_gui_stat_comparison_frame();

            if not __sw__persistent_data_per_char then
                __sw__persistent_data_per_char = {};
            end
            if __sw__use_defaults__ then
                __sw__persistent_data_per_char.settings = nil;
                __sw__persistent_data_per_char.loadouts = nil;
            end

            if not __sw__persistent_data_per_char.settings then
                __sw__persistent_data_per_char.settings = default_sw_settings();
            end

            create_sw_gui_settings_frame();

            if libstub_data_broker then
                local sw_launcher = libstub_data_broker:NewDataObject(sw_addon_name, {
                    type = "launcher",
                    icon = "Interface\\Icons\\spell_fire_elementaldevastation",
                    OnClick = function(self, button)
                        if button == "LeftButton" or button == "RightButton" then 
                            if sw_frame:IsShown() then 
                                 sw_frame:Hide() 
                            else 
                                 sw_frame:Show() 
                            end
                        end
                    end,
                    OnTooltipShow = function(tooltip)
                        tooltip:AddLine(sw_addon_name..": Version "..version);
                        tooltip:AddLine("Left/Right click: Toggle addon frame");
                        tooltip:AddLine("This icon can be removed in the addon's settings tab");
                    end,
                });
                if libstub_icon then
                    libstub_icon:Register(sw_addon_name, sw_launcher, __sw__persistent_data_per_char.settings.libstub_minimap_icon);
                end
            end

            if __sw__persistent_data_per_char.settings.libstub_minimap_icon.hide then
                libstub_icon:Hide(sw_addon_name);
            else
                libstub_icon:Show(sw_addon_name);
                sw_frame.settings_frame.libstub_icon_checkbox:SetChecked(true);
            end

            create_sw_gui_loadout_frame();

            if not __sw__persistent_data_per_char.sim_type or __sw__use_defaults__ then
                sw_frame.stat_comparison_frame.sim_type = simulation_type.spam_cast;
            else
                sw_frame.stat_comparison_frame.sim_type = __sw__persistent_data_per_char.sim_type;
            end
            if sw_frame.stat_comparison_frame.sim_type  == simulation_type.spam_cast then
                sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Show();
                sw_frame.stat_comparison_frame.spell_diff_header_right_race_to_the_bottom:Hide();
            elseif sw_frame.stat_comparison_frame.sim_type  == simulation_type.race_to_the_bottom then
                sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Hide();
                sw_frame.stat_comparison_frame.spell_diff_header_right_race_to_the_bottom:Show();
            end
            sw_frame.stat_comparison_frame.sim_type_button.init_func();

            if __sw__persistent_data_per_char.stat_comparison_spells and not __sw__use_defaults__ then

                sw_frame.stat_comparison_frame.spells = __sw__persistent_data_per_char.stat_comparison_spells;

                update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
            end

            if not __sw__persistent_data_per_char.loadouts then
                -- load defaults
                __sw__persistent_data_per_char.loadouts = {};
                __sw__persistent_data_per_char.loadouts.loadouts_list = {};
                __sw__persistent_data_per_char.loadouts.loadouts_list[1] = default_loadout();
                __sw__persistent_data_per_char.loadouts.active_loadout = 1;
                __sw__persistent_data_per_char.loadouts.num_loadouts = 1;
            end

            sw_frame.loadouts_frame.lhs_list.loadouts = {};
            for k, v in pairs(__sw__persistent_data_per_char.loadouts.loadouts_list) do
                sw_frame.loadouts_frame.lhs_list.loadouts[k] = {};
                sw_frame.loadouts_frame.lhs_list.loadouts[k].loadout = v;
                satisfy_loadout(sw_frame.loadouts_frame.lhs_list.loadouts[k].loadout);
                
            end

            sw_frame.loadouts_frame.lhs_list.active_loadout = __sw__persistent_data_per_char.loadouts.active_loadout;
            sw_frame.loadouts_frame.lhs_list.num_loadouts = __sw__persistent_data_per_char.loadouts.num_loadouts;

            update_loadouts_lhs();

            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(true);

            sw_activate_tab(3);
            sw_frame:Hide();

        elseif event ==  "PLAYER_LOGOUT"  then

            if not class_is_supported then
                return;
            end

            -- clear previous ui elements from spells table
            __sw__persistent_data_per_char.stat_comparison_spells = {};
            for k, v in pairs(self.stat_comparison_frame.spells) do
                __sw__persistent_data_per_char.stat_comparison_spells[k] = {};
                __sw__persistent_data_per_char.stat_comparison_spells[k].name = v.name;
            end
            __sw__persistent_data_per_char.sim_type = self.stat_comparison_frame.sim_type;

            __sw__persistent_data_per_char.loadouts = {};
            __sw__persistent_data_per_char.loadouts.loadouts_list = {};
            for k, v in pairs(self.loadouts_frame.lhs_list.loadouts) do
                __sw__persistent_data_per_char.loadouts.loadouts_list[k] = v.loadout;
            end
            __sw__persistent_data_per_char.loadouts.active_loadout = self.loadouts_frame.lhs_list.active_loadout;
            __sw__persistent_data_per_char.loadouts.num_loadouts = self.loadouts_frame.lhs_list.num_loadouts;

            -- save settings from ui
            save_sw_settings();

        elseif event ==  "PLAYER_LOGIN"  then
            if not class_is_supported then
                return;
            end
            __sw__icon_frames = gather_spell_icons();
            update_icon_overlay_settings();

            sw_addon_loaded = true;

        elseif event ==  "ACTIONBAR_SLOT_CHANGED"  then

            if not sw_addon_loaded then
                return;
            end

            local action_id = msg;

            local spell_id = 0;
            local action_type, id, _ = GetActionInfo(action_id);
            if action_type == "macro" then
                spell_id, _ = GetMacroSpell(id);
            elseif action_type == "spell" then
                 spell_id = id;
            else
                spell_id = 0;
            end
            if not spells[spell_id] then
                spell_id = 0;
            end

            if spell_id ~= 0 then
                __sw__icon_frames.bars[action_id] = {};
                __sw__icon_frames.bars[action_id].spell_id = spell_id;
                __sw__icon_frames.bars[action_id].frame = getfenv()[__sw__icon_frames.bar_names[action_id]]; 
                __sw__icon_frames.bars[action_id].overlay_frames = {nil, nil, nil}
            else
                if __sw__icon_frames.bars[action_id] then
                    for i = 1, 3 do
                        if __sw__icon_frames.bars[action_id].overlay_frames[i] then
                            __sw__icon_frames.bars[action_id].overlay_frames[i]:SetText("");
                            __sw__icon_frames.bars[action_id].overlay_frames[i]:Hide();
                        end
                        __sw__icon_frames.bars[action_id].overlay_frames[i] = nil;
                    end
                end
                __sw__icon_frames.bars[action_id] = nil; 
            end

            if IsStealthed() or GetShapeshiftForm() ~= 0 then
                on_special_action_bar_changed();
            end

        elseif event ==  "UPDATE_STEALTH" or event == "UPDATE_SHAPESHIFT_FORM" then

            if not sw_addon_loaded then
                return;
            end
            on_special_action_bar_changed();
        end
    end
    );

    
    sw_frame.tab1 = CreateFrame("Button", "__sw_settings_button", sw_frame, "UIPanelButtonTemplate"); 

    sw_frame.tab1:SetPoint("TOPLEFT", 10, -25);
    sw_frame.tab1:SetWidth(116);
    sw_frame.tab1:SetHeight(25);
    sw_frame.tab1:SetText("Settings");
    sw_frame.tab1:SetScript("OnClick", function()
        sw_activate_tab(1);
    end);


    sw_frame.tab2 = CreateFrame("Button", "__sw_loadouts_button", sw_frame, "UIPanelButtonTemplate"); 
    sw_frame.tab2:SetPoint("TOPLEFT", 124, -25);
    sw_frame.tab2:SetWidth(116);
    sw_frame.tab2:SetHeight(25);
    sw_frame.tab2:SetText("Loadouts");

    sw_frame.tab2:SetScript("OnClick", function()
        sw_activate_tab(2);
    end);

    sw_frame.tab3 = CreateFrame("Button", "__sw_stat_comparison_button", sw_frame, "UIPanelButtonTemplate"); 
    sw_frame.tab3:SetPoint("TOPLEFT", 238, -25);
    sw_frame.tab3:SetWidth(120);
    sw_frame.tab3:SetHeight(25);
    sw_frame.tab3:SetText("Stat Comparison");
    sw_frame.tab3:SetScript("OnClick", function()
        sw_activate_tab(3);
    end);
end

local function command(msg, editbox)
    if class_is_supported then
        if msg == "print" then
            print_loadout(active_loadout_buffed_talented_copy());
        elseif msg == "loadout" or msg == "loadouts" then
            sw_activate_tab(2);
        elseif msg == "settings" or msg == "opt" or msg == "options" or msg == "conf" or msg == "configure" then
            sw_activate_tab(1);
        elseif msg == "compare" or msg == "sc" or msg == "stat compare"  or msg == "stat" then
            sw_activate_tab(3);
        else
            sw_activate_tab(3);
        end
    end
end

if class_is_supported then
    GameTooltip:HookScript("OnTooltipSetSpell", function(tooltip, ...)
    
        local spell_name, spell_id = tooltip:GetSpell();
    
        local spell = get_spell(spell_id);

        local loadout = active_loadout_buffed_talented_copy();
    
        tooltip_spell_info(GameTooltip, spell, spell_name, loadout);
    
        if spell and IsShiftKeyDown() and sw_frame.stat_comparison_frame:IsShown() and 
                not sw_frame.stat_comparison_frame.spells[spell_id]then
            sw_frame.stat_comparison_frame.spells[spell_id] = {
                name = spell_name
            };
    
            update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
        end
    end)
end


function update_icon_overlay_settings()

    sw_frame.settings_frame.icon_overlay = {};
    
    local index = 1; 

    if sw_frame.settings_frame.icon_normal_effect:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.normal,
            color = {232.0/255, 225.0/255, 32.0/255}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_crit_effect:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.crit,
            color = {252.0/255, 69.0/255, 3.0/255}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_expected_effect:GetChecked() then 
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.expected,
            color = {255.0/256, 128/256, 0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_effect_per_sec:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.effect_per_sec,
            color = {255.0/256, 128/256, 0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_effect_per_cost:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.effect_per_cost,
            color = {0.0, 1.0, 1.0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_avg_cost:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.avg_cost,
            color = {0.0, 1.0, 1.0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_avg_cast:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.avg_cast,
            color = {0.0, 1.0, 0.0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_hit:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.hit,
            color = {232.0/255, 225.0/255, 32.0/255}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_crit:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.crit_chance,
            color = {252.0/255, 69.0/255, 3.0/255}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_effect_until_oom:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.effect_until_oom,
            color = {255.0/256, 128/256, 0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_casts_until_oom:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.casts_until_oom,
            color = {0.0, 1.0, 0.0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_time_until_oom:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.time_until_oom,
            color = {0.0, 1.0, 0.0}
        };
        index = index + 1;
    end

    -- if 1, do bottom
    if not sw_frame.settings_frame.icon_overlay[2] then
        sw_frame.settings_frame.icon_overlay[3] = sw_frame.settings_frame.icon_overlay[1];
        sw_frame.settings_frame.icon_overlay[1] = nil;
    -- if 2, do top and bottom
    elseif not sw_frame.settings_frame.icon_overlay[3] then
        sw_frame.settings_frame.icon_overlay[3] = sw_frame.settings_frame.icon_overlay[2];
        sw_frame.settings_frame.icon_overlay[2] = nil;
    end

    sw_num_icon_overlay_fields_active = index - 1;

    -- hide existing overlay frames that should no longer exist
    for i = 1, 3 do

        if not sw_frame.settings_frame.icon_overlay[i] then
            for k, v in pairs(__sw__icon_frames.book) do
                if v.overlay_frames[i] then
                    v.overlay_frames[i]:Hide();
                end
            end
            for k, v in pairs(__sw__icon_frames.bars) do
                if v.overlay_frames[i] then
                    v.overlay_frames[i]:Hide();
                end
            end
        end

    end
end

local function update_spell_icon_frame(frame_info, spell_data, spell_name, loadout)

    local stats = loadout_stats_for_spell(spell_data, spell_name, loadout); 

    local spell_effect = spell_info(
       spell_data.base_min, spell_data.base_max, 
       spell_data.over_time, spell_data.over_time_tick_freq, spell_data.over_time_duration, stats.extra_ticks,
       stats.cast_speed,
       stats.spell_power,
       stats.flat_direct_addition,
       max(0, min(1, stats.crit)),
       max(0, min(1, stats.ot_crit)),
       stats.spell_crit_mod,
       stats.hit,
       stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_mod_base,
       stats.direct_coef, stats.over_time_coef,
       stats.cost, spell_data.school,
       spell_name, loadout
    );

    local race_to_the_bottom = race_to_the_bottom_sim(
        spell_effect, loadout.mp5, loadout.stats[stat.spirit], loadout.mana + loadout.extra_mana, loadout
    );

    for i = 1, 3 do
        
        if sw_frame.settings_frame.icon_overlay[i] then
            if not frame_info.overlay_frames[i] then
                frame_info.overlay_frames[i] = frame_info.frame:CreateFontString(nil, "OVERLAY");
            end
            frame_info.overlay_frames[i]:SetFont(
                icon_overlay_font, sw_frame.settings_frame.icon_overlay_font_size, "THICKOUTLINE");

            if i == 1 then
                frame_info.overlay_frames[i]:SetPoint("TOP", 1, -3);
            elseif i == 2 then
                frame_info.overlay_frames[i]:SetPoint("CENTER", 1, -1.5);
            elseif i == 3 then 
                frame_info.overlay_frames[i]:SetPoint("BOTTOM", 1, 0);
            end
            if sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.normal then
                frame_info.overlay_frames[i]:SetText(string.format("%d",
                    (spell_effect.min_noncrit + spell_effect.max_noncrit)/2 + spell_effect.ot_if_hit));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.crit  then
                if spell_effect.ot_crit_if_hit > 0  then
                    frame_info.overlay_frames[i]:SetText(string.format("%d",
                        (spell_effect.min_crit + spell_effect.max_crit)/2 + spell_effect.ot_crit_if_hit));
                elseif spell_effect.min_crit ~= 0.0 then
                    frame_info.overlay_frames[i]:SetText(string.format("%d", 
                        (spell_effect.min_crit + spell_effect.max_crit)/2 + spell_effect.ot_if_hit));
                else
                    frame_info.overlay_frames[i]:SetText("");
                end
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.expected then
                frame_info.overlay_frames[i]:SetText(string.format("%d", spell_effect.expectation));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.effect_per_sec then
                frame_info.overlay_frames[i]:SetText(string.format("%d", spell_effect.effect_per_sec));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.effect_per_cost then
                frame_info.overlay_frames[i]:SetText(string.format("%.2f", spell_effect.effect_per_cost));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.avg_cost then
                frame_info.overlay_frames[i]:SetText(string.format("%d", spell_effect.cost));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.avg_cast then
                frame_info.overlay_frames[i]:SetText(string.format("%.1f", spell_effect.cast_time));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.hit and 
                    stats.hit < 1 then

                frame_info.overlay_frames[i]:SetText(string.format("%d%%", 100*stats.hit));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.crit_chance and
                    stats.crit ~= 0 then

                frame_info.overlay_frames[i]:SetText(string.format("%.1f%%", 100*max(0, min(1, stats.crit))));
                ---
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.casts_until_oom then
                frame_info.overlay_frames[i]:SetText(string.format("%.1f", race_to_the_bottom.num_casts));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.effect_until_oom then
                frame_info.overlay_frames[i]:SetText(string.format("%.0f", race_to_the_bottom.effect));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.time_until_oom then
                frame_info.overlay_frames[i]:SetText(string.format("%.1fs", race_to_the_bottom.time_until_oom));
            end
            frame_info.overlay_frames[i]:SetTextColor(sw_frame.settings_frame.icon_overlay[i].color[1], 
                                                      sw_frame.settings_frame.icon_overlay[i].color[2], 
                                                      sw_frame.settings_frame.icon_overlay[i].color[3]);

            frame_info.overlay_frames[i]:Show();
        end
    end
end

__sw__icon_frames = {};

local function update_spell_icons(loadout)

    -- update spell book icons
    if SpellBookFrame:IsShown() then
        for k, v in pairs(__sw__icon_frames.book) do
            if v.frame then
                spell_name = v.frame.SpellName:GetText();
                spell_rank_name = v.frame.SpellSubName:GetText();

                local _, _, _, _, _, _, id = GetSpellInfo(spell_name, spell_rank_name);
                if v.frame and v.frame:IsShown() then
                    if spells[id] then
                        local spell_name = GetSpellInfo(id);
                        -- TODO: icon overlay not working for healing version checkbox
                        if spells[id].healing_version and sw_frame.settings_frame.icon_heal_variant:GetChecked() then
                            update_spell_icon_frame(v, spells[id].healing_version, spell_name, loadout);
                        else
                            update_spell_icon_frame(v, spells[id], spell_name, loadout);
                        end
                    else
                        for i = 1, 3 do
                            if v.overlay_frames[i] then
                                v.overlay_frames[i]:Hide();
                            end
                        end
                    end
                elseif v.frame and not v.frame:IsShown() then
                    for i = 1, 3 do
                        if v.overlay_frames[i] then
                            v.overlay_frames[i]:Hide();
                        end
                    end
                end
            end
        end
    end

    -- update action bar icons
    for k, v in pairs(__sw__icon_frames.bars) do

        if v.frame and v.frame:IsShown() then

            local id = v.spell_id;
            local spell_name = GetSpellInfo(id);

            if spells[id].healing_version and sw_frame.settings_frame.icon_heal_variant:GetChecked() then
                update_spell_icon_frame(v, spells[id].healing_version, spell_name, loadout);
            else
                update_spell_icon_frame(v, spells[id], spell_name, loadout);
            end

        else
            for i = 1, 3 do
                if v.overlay_frames[i] then
                    v.overlay_frames[i]:Hide();
                end
            end
        end
    end
end

local snapshot_time_since_last_update = 0;

if class_is_supported then
    create_sw_base_gui();
else
    print("Stat Weights Classic currently does not support your class :(");
end

if class_is_supported then
    UIParent:HookScript("OnUpdate", function(self, elapsed)
    
        snapshot_time_since_last_update = snapshot_time_since_last_update + elapsed;
        
        if snapshot_time_since_last_update > 1/sw_snapshot_loadout_update_freq and 
                sw_num_icon_overlay_fields_active > 0 then

            update_spell_icons(active_loadout_buffed_talented_copy());

            snapshot_time_since_last_update = 0;
        end

    end)
end

-- add addon to Addons list under Interface

if InterfaceOptions_AddCategory then

    local addon_interface_panel = CreateFrame("FRAME");
    addon_interface_panel.name = "Stat Weights Classic";
    InterfaceOptions_AddCategory(addon_interface_panel);


    local y_offset = -20;
    local x_offset = 20;

    local str = "";
    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Stats Weights Classic - Version"..version);

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Project Page: https://www.curseforge.com/wow/addons/stat-weights-classic");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Author: jezzi23");

    y_offset = y_offset - 30;

    addon_interface_panel.open_sw_frame_button = 
        CreateFrame("Button", "sw_addon_interface_open_frame_button", addon_interface_panel, "UIPanelButtonTemplate"); 

    addon_interface_panel.open_sw_frame_button:SetPoint("TOPLEFT", x_offset, y_offset);
    addon_interface_panel.open_sw_frame_button:SetWidth(150);
    addon_interface_panel.open_sw_frame_button:SetHeight(25);
    addon_interface_panel.open_sw_frame_button:SetText("Open Addon Frame");
    addon_interface_panel.open_sw_frame_button:SetScript("OnClick", function()
        sw_activate_tab(1);
    end);

    y_offset = y_offset - 30;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Or type any of the following:");

    y_offset = y_offset - 15;
    x_offset = x_offset + 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sw");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sw conf");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sw loadouts");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sw stat");
    
end

SLASH_STAT_WEIGHTS1 = "/sw"
SLASH_STAT_WEIGHTS2 = "/stat-weights"
SLASH_STAT_WEIGHTS3 = "/stat-weights-classic"
SLASH_STAT_WEIGHTS4 = "/swc"
SlashCmdList["STAT_WEIGHTS"] = command

--__sw__debug__ = 1;
--__sw__use_defaults__ = 1;
