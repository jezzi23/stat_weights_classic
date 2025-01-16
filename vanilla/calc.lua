local _, swc = ...;

local spells            = swc.abilities.spells;
local spids             = swc.abilities.spids;
local magic_school      = swc.abilities.magic_school;
local spell_flags       = swc.abilities.spell_flags;
local best_rank_by_lvl  = swc.abilities.best_rank_by_lvl;

local schools           = swc.schools;
local comp_flags        = swc.comp_flags;

local rune_ids          = swc.talents.rune_ids;

local config            = swc.config;

local stat              = swc.utils.stat;
local class             = swc.utils.class;
local deep_table_copy   = swc.utils.deep_table_copy;

local effects_zero_diff = swc.loadout.effects_zero_diff;
local effects_diff      = swc.loadout.effects_diff;
local loadout_flags     = swc.loadout.loadout_flags;

local set_tiers         = swc.equipment.set_tiers;

local is_buff_up        = swc.buffs.is_buff_up;

--------------------------------------------------------------------------------
local calc              = {};

local simulation_type   = {
    spam_cast      = 1,
    cast_until_oom = 2
};

local evaluation_flags  = {
    assume_single_effect = bit.lshift(1, 1),
    isolate_periodic     = bit.lshift(1, 2),
    isolate_direct       = bit.lshift(1, 3),
    offhand              = bit.lshift(1, 4),
};

local function get_combat_rating_effect(rating_id, level)
    -- for vanilla, treat rating as same as percentage
    return 1;
end

local function spell_hit(lvl, lvl_target, hit, pvp)
    local base_hit = 0;
    local each_lvl_miss = 0.11;
    if pvp then
        each_lvl_miss = 0.07;
    end

    if lvl_target - lvl > 2 then
        base_hit = 0.94 - each_lvl_miss * (lvl_target - lvl - 2);
    else
        base_hit = 0.96 - 0.01 * (lvl_target - lvl);
    end

    return math.max(0.01, math.min(0.99, base_hit + hit));
end

local function npc_lvl_resi_base(self_lvl, target_lvl)
    -- higher lvl npcs always have impenetrable base resistance for non binary spells
    return math.floor(self_lvl * math.max(0, target_lvl - self_lvl) * 2 / 15);
end

local function target_avg_magical_res_binary(self_lvl, target_res)
    return math.min(0.75, 0.75 * (target_res / (math.max(self_lvl * 5, 100))))
end

local function target_avg_magical_mitigation_non_binary(self_lvl, target_res)
    -- adjusted according to @src: https://royalgiraffe.github.io/resist-guide
    local resi_to_cap_ratio = target_res / (math.max(self_lvl * 5, 100));
    local beyond_half_resist_falloff = (3 / 16) * math.max(0, resi_to_cap_ratio - 2 / 3);
    return math.min(0.75, 0.75 * resi_to_cap_ratio - beyond_half_resist_falloff)
end

local function hit_calc(extra_hit, avg_resi, loadout, spell)
    local final_hit = 0;
    local final_avg_resi = avg_resi;

    local target_is_pvp = bit.band(loadout.flags, loadout_flags.target_pvp) ~= 0;
    final_hit = spell_hit(loadout.lvl, loadout.target_lvl, extra_hit, target_is_pvp);
    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
        final_hit = 1.0;
    elseif bit.band(spell.flags, spell_flags.binary) ~= 0 then
        -- @src: https://royalgiraffe.github.io/resist-guide
        -- binary spells will have lower hit chance against higher resistances
        -- rather than partial resists
        local base_hit = spell_hit(loadout.lvl, loadout.target_lvl, 0.0, target_is_pvp);
        final_hit = math.min(0.99, base_hit * (1.0 - avg_resi) + extra_hit);
        avg_resi = 0.0;
    else
        final_hit = math.min(0.99, final_hit);
    end

    return final_hit, final_avg_resi;
end

local base_mana_by_lvl = (function()
    if class == "PALADIN" then
        return { 60, 78, 98, 104, 111, 134, 143, 153, 179, 192, 205, 219, 249, 265, 282, 315, 334, 354, 390, 412, 435, 459, 499, 525, 552, 579, 621, 648, 675, 702, 729, 756, 798, 825, 852, 879, 906, 933, 960, 987, 1014, 1041, 1068, 1110, 1137, 1164, 1176, 1203, 1230, 1257, 1284, 1311, 1338, 1365, 1392, 1419, 1446, 1458, 1485, 1512, 1656, 1800, 1944, 2088, 2232, 2377, 2521, 2665, 2809, 2953, 3097, 3241, 3385, 3529, 3673, 3817, 3962, 4106, 4250, 4394, }
    elseif class == "HUNTER" then
        return { 65, 70, 76, 98, 106, 130, 140, 166, 193, 206, 235, 250, 266, 298, 316, 350, 370, 391, 428, 451, 475, 515, 541, 568, 611, 640, 670, 715, 745, 775, 805, 850, 880, 910, 940, 970, 1015, 1045, 1075, 1105, 1135, 1180, 1210, 1240, 1270, 1300, 1330, 1360, 1390, 1420, 1450, 1480, 1510, 1540, 1570, 1600, 1630, 1660, 1690, 1720, 1886, 2053, 2219, 2385, 2552, 2718, 2884, 3050, 3217, 3383, 3549, 3716, 3882, 4048, 4215, 4381, 4547, 4713, 4880, 5046, }
    elseif class == "PRIEST" then
        return { 73, 76, 95, 114, 133, 152, 171, 190, 209, 212, 215, 234, 254, 260, 282, 305, 329, 339, 365, 377, 405, 434, 449, 480, 497, 530, 549, 584, 605, 627, 665, 689, 728, 752, 776, 800, 839, 863, 887, 911, 950, 974, 998, 1022, 1046, 1070, 1094, 1118, 1142, 1166, 1190, 1214, 1238, 1262, 1271, 1295, 1319, 1343, 1352, 1376, 1500, 1625, 1749, 1873, 1998, 2122, 2247, 2371, 2495, 2620, 2744, 2868, 2993, 3117, 3242, 3366, 3490, 3615, 3739, 3863, }
    elseif class == "SHAMAN" then
        return { 85, 91, 98, 106, 115, 125, 136, 148, 161, 175, 190, 206, 223, 241, 260, 280, 301, 323, 346, 370, 395, 421, 448, 476, 505, 535, 566, 598, 631, 665, 699, 733, 767, 786, 820, 854, 888, 922, 941, 975, 1009, 1028, 1062, 1096, 1115, 1149, 1183, 1202, 1236, 1255, 1289, 1323, 1342, 1376, 1395, 1414, 1448, 1467, 1501, 1520, 1664, 1808, 1951, 2095, 2239, 2383, 2527, 2670, 2814, 2958, 3102, 3246, 3389, 3533, 3677, 3821, 3965, 4108, 4252, 4396, }
    elseif class == "MAGE" then
        return { 100, 110, 106, 118, 131, 130, 145, 146, 163, 196, 215, 220, 241, 263, 271, 295, 305, 331, 343, 371, 385, 415, 431, 463, 481, 515, 535, 556, 592, 613, 634, 670, 691, 712, 733, 754, 790, 811, 832, 853, 874, 895, 916, 937, 958, 979, 1000, 1021, 1042, 1048, 1069, 1090, 1111, 1117, 1138, 1159, 1165, 1186, 1192, 1213, 1316, 1419, 1521, 1624, 1727, 1830, 1932, 2035, 2138, 2241, 2343, 2446, 2549, 2652, 2754, 2857, 2960, 3063, 3165, 3268, }
    elseif class == "WARLOCK" then
        return { 90, 98, 107, 102, 113, 126, 144, 162, 180, 198, 200, 218, 237, 257, 278, 300, 308, 332, 357, 383, 395, 423, 452, 467, 498, 530, 548, 582, 602, 638, 674, 695, 731, 752, 788, 809, 830, 866, 887, 923, 944, 965, 1001, 1022, 1043, 1064, 1100, 1121, 1142, 1163, 1184, 1205, 1226, 1247, 1268, 1289, 1310, 1331, 1352, 1373, 1497, 1621, 1745, 1870, 1994, 2118, 2242, 2366, 2490, 2615, 2739, 2863, 2987, 3111, 3235, 3360, 3483, 3608, 3732, 3856, }
    elseif class == "DRUID" then
        return { 60, 66, 73, 81, 90, 100, 111, 123, 136, 150, 165, 182, 200, 219, 239, 260, 282, 305, 329, 354, 380, 392, 420, 449, 479, 509, 524, 554, 584, 614, 629, 659, 689, 704, 734, 749, 779, 809, 824, 854, 869, 899, 914, 944, 959, 989, 1004, 1019, 1049, 1064, 1079, 1109, 1124, 1139, 1154, 1169, 1199, 1214, 1229, 1244, 1357, 1469, 1582, 1694, 1807, 1919, 2032, 2145, 2257, 2370, 2482, 2595, 2708, 2820, 2933, 3045, 3158, 3270, 3383, 3496, }
    end
end)()

local lookups = {
    bol_id_to_hl = {
        [19977] = 210,
        [19978] = 300,
        [19979] = 400,
        [25890] = 400
    },
    bol_rank_to_hl_coef_subtract = {
        [1] = 1.0 - (1 - (20 - 1) * 0.0375) * 2.5 / 3.5, -- lvl 1 hl coef used
        [2] = 1.0 - 0.4,
        [3] = 1.0 - 0.7,
    },
    isb_to_vuln = {
        [17794] = 0.04,
        [17798] = 0.08,
        [17797] = 0.12,
        [17799] = 0.16,
        [17800] = 0.2
    },
    moonkin_form = 24858,
    sheath_of_light = 426159,
    sacred_shield = 412019,
    blessing_of_light = 19979,
    greater_blessing_of_light = 25890,
    lightning_shield = 324,
    rejuvenation = 774,
    regrowth = 8936,
    rapid_healing = 468531,
    water_shield = 408510,
    isb_shadow_vuln = 17800,
};

local function base_mana_pool(clvl, max_mana_mod)
    local intellect = UnitStat("player", 4);
    local int_base = min(20, intellect);
    local base_mana = math.ceil(UnitPowerMax("player", 0) / (1.0 + max_mana_mod))
        - (int_base + 15 * (intellect - int_base));

    return base_mana;
end

local function spirit_mana_regen(spirit)
    local mp2 = 0;
    if class == "PRIEST" or class == "MAGE" then
        mp2 = (13 + spirit / 4);
    elseif class == "DRUID" or class == "SHAMAN" or class == "PALADIN" then
        mp2 = (15 + spirit / 5);
    elseif class == "WARLOCK" then
        mp2 = (8 + spirit / 4);
    end
    return mp2;
end

local special_abilities = nil;
local function set_alias_spell(spell, loadout)
    local alias_spell = spell;

    if spell.base_id == spids.sunfire_bear or spell.base_id == spids.sunfire_cat then
        alias_spell = spells[414684];
    end

    return alias_spell;
end

local extra_effect_flags = {
    triggers_on_crit        = bit.lshift(1, 0),
    use_flat                = bit.lshift(1, 1),
    base_on_periodic_effect = bit.lshift(1, 2),
    should_track_crit_mod   = bit.lshift(1, 3),
};

local function add_extra_periodic_effect(stats, flags, value, ticks, freq, utilization, description)
    stats.num_extra_effects = stats.num_extra_effects + 1;
    local i = stats.num_extra_effects;

    stats["extra_effect_is_periodic" .. i] = true;
    stats["extra_effect_on_crit" .. i] = bit.band(flags, extra_effect_flags.triggers_on_crit) ~= 0;
    stats["extra_effect_use_flat" .. i] = bit.band(flags, extra_effect_flags.use_flat) ~= 0;
    stats["extra_effect_base_on_periodic" .. i] = bit.band(flags, extra_effect_flags.base_on_periodic_effect) ~= 0;
    stats["extra_effect_val" .. i] = value;
    stats["extra_effect_desc" .. i] = description;
    stats["extra_effect_util" .. i] = utilization;

    stats["extra_effect_ticks" .. i] = ticks;
    stats["extra_effect_tick_time" .. i] = freq;

    if bit.band(flags, extra_effect_flags.should_track_crit_mod) ~= 0 then
        stats.special_crit_mod_tracked = i;
    end
end
local function add_extra_direct_effect(stats, flags, value, utilization, description)
    stats.num_extra_effects = stats.num_extra_effects + 1;
    local i = stats.num_extra_effects;

    stats["extra_effect_is_periodic" .. i] = false;
    stats["extra_effect_on_crit" .. i] = bit.band(flags, extra_effect_flags.triggers_on_crit) ~= 0;
    stats["extra_effect_use_flat" .. i] = bit.band(flags, extra_effect_flags.use_flat) ~= 0;
    stats["extra_effect_base_on_periodic" .. i] = bit.band(flags, extra_effect_flags.base_on_periodic_effect) ~= 0;
    stats["extra_effect_val" .. i] = value;
    stats["extra_effect_desc" .. i] = description;
    stats["extra_effect_util" .. i] = utilization;

    if bit.band(flags, extra_effect_flags.should_track_crit_mod) ~= 0 then
        stats.special_crit_mod_tracked = i;
    end
end

local function spell_stats_direct(stats, spell, loadout, effects, eval_flags)

    local benefit_id = spell.base_id;
    if spell.benefits_from_spell then
        benefit_id = spell.benefits_from_spell;
    end

    local direct = spell.direct;
    -- CRIT
    -- rating may come from diffed loadout
    local crit_rating_per_perc = get_combat_rating_effect(CR_CRIT_SPELL, loadout.lvl);
    local crit_from_rating = 0.01 * (loadout.crit_rating + effects.raw.crit_rating) / crit_rating_per_perc;

    local bonus_crit = math.max(0, crit_from_rating) + (effects.ability.crit[benefit_id] or 0);

    stats.crit = stats.crit + bonus_crit + loadout.spell_crit_by_school[direct.school1] + effects.by_school.spell_crit[direct.school1];
    local i = 2;
    while (direct["school"..i]) do
        local s = direct["school"..i];
        stats.crit = stats.crit + loadout.spell_crit_by_school[s] + effects.by_school.spell_crit[s]
            - (loadout.spell_crit_by_school[schools.physical] + effects.by_school.spell_crit[schools.physical])
        i = i + 1;
    end
    -- TODO: cannot crit flag
    if bit.band(direct.flags, comp_flags.cant_crit) ~= 0 and not effects.ability.ignore_cant_crit[benefit_id] then
        stats.crit = 0;
    end
    stats.crit = math.min(math.max(stats.crit, 0.0), 1.0);
    -- CRIT MOD
    local base_crit_mod = 0.5;
    if direct.school1 == schools.physical then
        base_crit_mod = 1.0;
    end
    local best_crit_mod = effects.by_school.crit_mod[direct.school1];
    local i = 2;
    while (direct["school"..i]) do
        best_crit_mod = math.max(best_crit_mod, effects.by_school.crit_mod[direct["school"..i]]);
        i = i + 1;
    end
    base_crit_mod = (1.0 + base_crit_mod) * (1.0 + best_crit_mod) - 1.0;
    stats.crit_mod = 1.0 + base_crit_mod * (1.0 + (effects.ability.crit_mod[benefit_id] or 0.0));

    --local extra_crit_mod = effects.by_school.spell_crit_mod[direct.school1];
    --local i = 2;
    --while (direct["school"..i]) do
    --    local s = direct["school"..i];
    --    extra_crit_mod = extra_crit_mod + effects.by_school.spell_crit_mod[s] -
    --        effects.by_school.spell_crit_mod[magic_school.physical];
    --    i = i + 1;
    --end
    --extra_crit_mod = extra_crit_mod + (effects.ability.crit_mod[benefit_id] or 0);
    --if bit.band(spell.flags, spell_flags.heal) ~= 0 then
    --    stats.crit_mod = stats.crit_mod + 0.5 * effects.raw.special_crit_heal_mod;
    --    if effects.ability.crit_mod[benefit_id] then
    --        stats.crit_mod = stats.crit_mod + effects.ability.crit_mod[benefit_id];
    --    end
    --else
    --    stats.crit_mod = stats.crit_mod * (1.0 + effects.raw.special_crit_mod);
    --    stats.crit_mod = stats.crit_mod + (stats.crit_mod - 1.0) * 2 * extra_crit_mod;
    --end

    -- WANDS
    if spell.base_id == spids.shoot then
        local wand_perc_active = 1.0 + stats.effect_mod;
        local wand_perc_spec = 1.0;

        if class == "PRIEST" then
            wand_perc_spec = wand_perc_spec + loadout.talents_table:pts(1, 2) * 0.05;
        elseif class == "MAGE" then
            wand_perc_spec = wand_perc_spec + loadout.talents_table:pts(1, 4) * 0.125;
        end

        stats.gcd = 0.5;
        if loadout.r_speed ~= 0 then
            spell.cast_time = loadout.r_speed;
            spell.direct.min = (loadout.r_min / (loadout.r_mod * wand_perc_active) - loadout.r_pos) * wand_perc_spec;
            spell.direct.max = (loadout.r_max / (loadout.r_mod * wand_perc_active) - loadout.r_pos) * wand_perc_spec;
        else
            spell.cast_time = 0;
            spell.direct.min = 0;
            spell.direct.max = 0;
        end
        stats.spell_dmg_mod = stats.spell_dmg_mod - stats.effect_mod;
    end

    stats.target_resi = 0;
    stats.target_avg_resi = 0;

    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then

        local base_resi = 0;
        if bit.band(loadout.flags, loadout_flags.target_pvp) == 0 then
            base_resi = npc_lvl_resi_base(loadout.lvl, loadout.target_lvl);
        end

        local res_pen_by_school = effects.by_school.target_res[direct.school1];
        local i = 2;
        while (direct["school"..i]) do
            res_pen_by_school = math.max(res_pen_by_school, effects.by_school.target_res[direct["school"..i]]);
            i = i + 1;
        end
        -- mod res by school currently used to snapshot equipment and set bonuses
        stats.target_resi = math.min(loadout.lvl * 5,
            math.max(0, config.loadout.target_res - res_pen_by_school));

        if bit.band(spell.flags, spell_flags.binary) ~= 0 then
            stats.target_avg_resi = target_avg_magical_res_binary(loadout.lvl, stats.target_resi);
        else
            stats.target_resi = math.min(loadout.lvl * 5,
                math.max(base_resi, config.loadout.target_res - res_pen_by_school + base_resi));
            stats.target_avg_resi = target_avg_magical_mitigation_non_binary(loadout.lvl, stats.target_resi);
        end
    end
    -- HIT
    stats.extra_hit = effects.ability.hit[benefit_id] or 0.0;

    local hit_rating_per_perc = get_combat_rating_effect(CR_HIT_SPELL, loadout.lvl);
    local hit_from_rating = 0.01 * (loadout.hit_rating + effects.raw.hit_rating) / hit_rating_per_perc
    stats.extra_hit = stats.extra_hit + hit_from_rating;

    --if bit.band(spell.flags, spell_flags.affliction) ~= 0 then
    --    stats.extra_hit = stats.extra_hit + loadout.talents_table:pts(1, 1) * 0.02;
    --end

    stats.extra_hit = loadout.spell_dmg_hit_by_school[direct.school1] + effects.by_school.spell_dmg_hit[direct.school1];
    local i = 2;
    while (direct["school"..i]) do
        stats.extra_hit = stats.extra_hit + effects.by_school.spell_dmg_hit[direct["school"..i]] -
        effects.by_school.spell_dmg_hit[magic_school.physical];
        i = i + 1;
    end
    local hit, avg_resi = hit_calc(stats.extra_hit, stats.target_avg_resi, loadout, spell);
    stats.hit = hit;
    stats.hit_ot = hit;
    stats.target_avg_resi = avg_resi;
    stats.target_avg_resi_dot = avg_resi;
    -- TODO: cannot miss spells, partial immunity set hit 1 and res 0
    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
        stats.hit = math.min(math.max(stats.hit, 0.0), 1.0);
    else
        stats.hit = math.min(math.max(stats.hit, 0.0), 0.99);
    end

    -- SP
    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
       stats.spell_power = loadout.healing_power + effects.raw.healing_power + effects.raw.spell_power;
    else
        local sp_school = loadout.spell_dmg_by_school[direct.school1];
        local i = 2;
        while (direct["school"..i]) do
            sp_school = math.max(sp_school, loadout.spell_dmg_by_school[direct["school"..i]]);
            i = i + 1;
        end
        stats.spell_power = sp_school + effects.raw.spell_dmg + effects.raw.spell_power + (effects.ability.sp[benefit_id] or 0);
    end

    -- COEF
    stats.coef = spell.direct.coef + (effects.ability.coef_mod[benefit_id] or 0.0);

    -- SPELL MODIFIERS
    stats.spell_dmg_mod = stats.spell_dmg_mod + effects.by_school.spell_dmg_mod[direct.school1];
    stats.spell_dmg_mod_mul = stats.spell_dmg_mod_mul * effects.mul.by_school.spell_dmg_mod[direct.school1];
    stats.target_vuln_mod_mul_direct = stats.target_vuln_mod_mul;
    if bit.band(spell.flags, spell_flags.heal) ~= 0 then

        stats.target_vuln_mod_mul_direct = stats.target_vuln_mod_mul_direct * effects.mul.raw.target_vuln_heal;

        stats.spell_mod =
            stats.target_vuln_mod_mul_direct
            *
            effects.mul.raw.spell_heal_mod
            *
            (1.0 + stats.effect_mod + effects.raw.spell_heal_mod + (effects.ability.effect_mod_only_heal[benefit_id] or 0.0));
    elseif bit.band(spell.flags, spell_flags.absorb) ~= 0 then

        stats.spell_mod =
            stats.target_vuln_mod_mul_direct * (1.0 + stats.effect_mod);

        -- hacky special case for power word: shield glyph as it scales with healing
        stats.spell_heal_mod = effects.mul.raw.spell_heal_mod
            *
            (1.0 + effects.raw.spell_heal_mod + (effects.ability.effect_ot_mod[benefit_id] or 0.0));
    else
        -- damage spell
        stats.target_vuln_mod_mul_direct = stats.target_vuln_mod_mul_direct * effects.mul.by_school.target_vuln_dmg[direct.school1];
        local i = 2;
        while (direct["school"..i]) do
            local s = direct["school"..i];
            stats.spell_dmg_mod_mul = stats.spell_dmg_mod_mul *
                (1.0 + effects.mul.by_school.spell_dmg_mod[s] - effects.mul.by_school.spell_dmg_mod[magic_school.physical]);
            stats.spell_dmg_mod = stats.spell_dmg_mod + effects.by_school.spell_dmg_mod[s] -
                effects.by_school.spell_dmg_mod[magic_school.physical];

            stats.target_vuln_mod_mul_direct = stats.target_vuln_mod_mul_direct *
                (1.0 + effects.mul.by_school.target_vuln_dmg[s] - effects.mul.by_school.target_vuln_dmg[magic_school.physical]);
            i = i + 1;
        end

        stats.spell_mod =
            stats.target_vuln_mod_mul_direct
            *
            stats.spell_dmg_mod_mul
            *
            (1.0 + stats.effect_mod + stats.spell_dmg_mod);
    end

    stats.direct_jumps = (direct.jumps or 0) + (effects.ability.jumps[benefit_id] or 0);
    stats.direct_jump_amp = 1.0 - (direct.jump_red or 0.0) + (effects.ability.jump_amp[benefit_id] or 0.0);

    -- NOTE: TEMPORARY
    if direct.school1 == magic_school.physical then
        stats.hit = 1.0;
        stats.hit_ot = 1.0;
        stats.crit = loadout.melee_crit;
        stats.crit_mod = 2;
        stats.target_resi = 0;
        stats.target_avg_resi = 0;
    end

end

local function spell_stats_periodic(stats, spell, loadout, effects, eval_flags)

    local benefit_id = spell.base_id;
    if spell.benefits_from_spell then
        benefit_id = spell.benefits_from_spell;
    end

    local periodic = spell.periodic;
    -- CRIT
    local crit_rating_per_perc = get_combat_rating_effect(CR_CRIT_SPELL, loadout.lvl);
    local crit_from_rating = 0.01 * (loadout.crit_rating + effects.raw.crit_rating) / crit_rating_per_perc;

    local bonus_crit =  crit_from_rating + (effects.ability.crit[benefit_id] or 0);

    stats.crit_ot = stats.crit_ot + bonus_crit + loadout.spell_crit_by_school[spell.periodic.school1] + effects.by_school.spell_crit[spell.periodic.school1];
    local i = 2;
    while (periodic["school"..i]) do
        local s = periodic["school"..i];
        stats.crit = stats.crit + loadout.spell_crit_by_school[s] + effects.by_school.spell_crit[s]
            - (loadout.spell_crit_by_school[schools.physical] + effects.by_school.spell_crit[schools.physical])
        i = i + 1;
    end
    -- TODO: cannot crit flag
    if bit.band(periodic.flags, comp_flags.cant_crit) ~= 0 and not effects.ability.ignore_cant_crit[benefit_id] then
        stats.crit_ot = 0;
    end
    stats.crit_ot = math.min(math.max(stats.crit_ot, 0.0), 1.0);
    -- CRIT MOD
    local base_crit_mod = 0.5;
    if periodic.school1 == schools.physical then
        base_crit_mod = 1.0;
    end
    local best_crit_mod = effects.by_school.crit_mod[periodic.school1];
    local i = 2;
    while (periodic["school"..i]) do
        best_crit_mod = math.max(best_crit_mod, effects.by_school.crit_mod[periodic["school"..i]]);
        i = i + 1;
    end
    base_crit_mod = (1.0 + base_crit_mod) * (1.0 + best_crit_mod) - 1.0;
    stats.crit_mod_ot = 1.0 + base_crit_mod * (1.0 + (effects.ability.crit_mod[benefit_id] or 0.0));

    --local extra_crit_mod = effects.by_school.spell_crit_mod[periodic.school1];
    --local i = 2;
    --while (periodic["school"..i]) do
    --    extra_crit_mod = extra_crit_mod + effects.by_school.spell_crit_mod[periodic["school"..i]] -
    --        effects.by_school.spell_crit_mod[magic_school.physical];
    --    i = i + 1;
    --end
    --extra_crit_mod = extra_crit_mod + (effects.ability.crit_mod[benefit_id] or 0);
    --if bit.band(spell.flags, spell_flags.heal) ~= 0 then
    --    stats.crit_mod_ot = stats.crit_mod_ot + 0.5 * effects.raw.special_crit_heal_mod;
    --    if effects.ability.crit_mod[benefit_id] then
    --        stats.crit_mod_ot = stats.crit_mod_ot + effects.ability.crit_mod[benefit_id];
    --    end
    --else
    --    stats.crit_mod_ot = stats.crit_mod_ot * (1.0 + effects.raw.special_crit_mod);
    --    stats.crit_mod_ot = stats.crit_mod_ot + (stats.crit_mod - 1.0) * 2 * extra_crit_mod;
    --end

    stats.target_resi_dot = 0;
    stats.target_avg_resi_dot = 0;

    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then

        local base_resi = 0;
        if bit.band(loadout.flags, loadout_flags.target_pvp) == 0 then
            base_resi = npc_lvl_resi_base(loadout.lvl, loadout.target_lvl);
        end
        local res_pen_by_school_dot = effects.by_school.target_res[periodic.school1];
        local i = 2;
        while (periodic["school"..i]) do
            res_pen_by_school_dot = math.max(res_pen_by_school_dot, effects.by_school.target_res[periodic["school"..i]]);
            i = i + 1;
        end
        -- mod res by school currently used to snapshot equipment and set bonuses
        stats.target_resi_dot = math.min(loadout.lvl * 5,
            math.max(0, config.loadout.target_res - res_pen_by_school_dot));

        if bit.band(spell.flags, spell_flags.binary) ~= 0 then
            stats.target_avg_resi_dot = target_avg_magical_res_binary(loadout.lvl, stats.target_resi_dot);
        else
            stats.target_resi_dot = math.min(loadout.lvl * 5,
                math.max(base_resi, config.loadout.target_res - res_pen_by_school_dot + base_resi));
            stats.target_avg_resi_dot = target_avg_magical_mitigation_non_binary(loadout.lvl, stats.target_resi_dot);
        end
        if bit.band(spell.flags, spell_flags.resi_pen) ~= 0 then
            -- some dots penetrate 9/10th of resi
            stats.target_avg_resi_dot = stats.target_avg_resi_dot * 0.1;
        end
    end
    -- HIT
    stats.extra_hit_ot = effects.ability.hit[benefit_id] or 0.0;

    local hit_rating_per_perc = get_combat_rating_effect(CR_HIT_SPELL, loadout.lvl);
    local hit_from_rating = 0.01 * (loadout.hit_rating + effects.raw.hit_rating) / hit_rating_per_perc
    stats.extra_hit_ot = stats.extra_hit_ot + hit_from_rating;

    --if bit.band(spell.flags, spell_flags.affliction) ~= 0 then
    --    stats.extra_hit_ot = stats.extra_hit_ot + loadout.talents_table:pts(1, 1) * 0.02;
    --end
    stats.extra_hit_ot = loadout.spell_dmg_hit_by_school[periodic.school1] + effects.by_school.spell_dmg_hit[periodic.school1];
    local i = 2;
    while (periodic["school"..i]) do
        stats.extra_hit_ot = stats.extra_hit_ot + effects.by_school.spell_dmg_hit[periodic["school"..i]] -
        effects.by_school.spell_dmg_hit[magic_school.physical];
        i = i + 1;
    end

    local hit, avg_resi = hit_calc(stats.extra_hit_ot, stats.target_avg_resi_dot, loadout, spell);
    stats.hit_ot = hit;
    stats.target_avg_resi_dot = avg_resi;
    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
        stats.hit_ot = math.min(math.max(stats.hit_ot, 0.0), 1.0);
    else
        stats.hit_ot = math.min(math.max(stats.hit_ot, 0.0), 0.99);
    end
    if not spell.direct then
        stats.hit = stats.hit_ot;
    end


    -- SP
    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
        stats.spell_power_ot = loadout.healing_power + effects.raw.healing_power + effects.raw.spell_power;
    else
        local sp_school = loadout.spell_dmg_by_school[periodic.school1];
        local i = 2;
        while (periodic["school"..i]) do
            sp_school = math.max(sp_school, loadout.spell_dmg_by_school[periodic["school"..i]]);
            i = i + 1;
        end
        stats.spell_power_ot = sp_school + effects.raw.spell_dmg + effects.raw.spell_power + (effects.ability.sp[benefit_id] or 0);
    end

    -- COEF
    stats.ot_coef = spell.periodic.coef * (1.0 + (effects.ability.coef_ot_mod[benefit_id] or 0.0));

    -- SPELL MODIFIERS
    stats.spell_dmg_mod_ot = stats.spell_dmg_mod_ot + effects.by_school.spell_dmg_mod[periodic.school1];
    stats.spell_dmg_mod_ot_mul = stats.spell_dmg_mod_ot_mul * effects.mul.by_school.spell_dmg_mod[periodic.school1];
    stats.target_vuln_mod_mul_ot = stats.target_vuln_mod_mul;

    if bit.band(spell.flags, spell_flags.heal) ~= 0 then

        stats.target_vuln_mod_ot_mul = stats.target_vuln_mod_ot_mul * effects.mul.raw.target_vuln_heal;
        stats.spell_ot_mod =
            stats.target_vuln_mod_ot_mul
            *
            effects.mul.raw.spell_heal_mod
            *
            (1.0 + stats.effect_mod + effects.raw.spell_heal_mod + effects.raw.ot_mod + (effects.ability.effect_ot_mod[benefit_id] or 0.0));

    elseif bit.band(spell.flags, spell_flags.absorb) ~= 0 then

        stats.spell_ot_mod = stats.target_vuln_mod_ot_mul *
            ((1.0 + stats.effect_mod + (effects.ability.effect_ot_mod[benefit_id] or 0.0)));
        -- hacky special case for power word: shield glyph as it scales with healing
        stats.spell_heal_mod = effects.mul.raw.spell_heal_mod
            *
            (1.0 + effects.raw.spell_heal_mod + (effects.ability.effect_ot_mod[benefit_id] or 0.0));
    else
        -- damage spell
        stats.target_vuln_mod_ot_mul = stats.target_vuln_mod_ot_mul * effects.mul.by_school.target_vuln_dmg[periodic.school1] * effects.mul.by_school.target_vuln_dmg_ot[periodic.school1];
        local i = 2;
        while (periodic["school"..i]) do
            local s = periodic["school"..i];
            stats.spell_dmg_mod_ot_mul = stats.spell_dmg_mod_ot_mul *
                (1.0 + effects.mul.by_school.spell_dmg_mod[s] - effects.mul.by_school.spell_dmg_mod[magic_school.physical]);
            stats.spell_dmg_mod_ot = stats.spell_dmg_mod + effects.by_school.spell_dmg_mod[s] -
                effects.by_school.spell_dmg_mod[magic_school.physical];

            stats.target_vuln_mod_mul = stats.target_vuln_mod_mul *
                (1.0 + effects.mul.by_school.target_vuln_dmg[s] - effects.mul.by_school.target_vuln_dmg[magic_school.physical])
                *
                (1.0 + effects.mul.by_school.target_vuln_dmg_ot[s] - effects.mul.by_school.target_vuln_dmg_ot[magic_school.physical]);
            i = i + 1;
        end

        stats.spell_ot_mod =
            stats.target_vuln_mod_ot_mul
            *
            stats.spell_dmg_mod_mul
            *
            (1.0 + stats.effect_mod + stats.spell_dmg_mod_ot + effects.raw.ot_mod + (effects.ability.effect_ot_mod[benefit_id] or 0.0));
    end

    stats.periodic_jumps = (periodic.jumps or 0) + (effects.ability.jumps[benefit_id] or 0);
    stats.periodic_jump_amp = 1.0 - (periodic.jump_red or 0.0) + (effects.ability.jump_amp[benefit_id] or 0.0);

    -- NOTE: TEMPORARY
    if periodic.school1 == magic_school.physical then
        stats.hit = 1.0;
        stats.hit_ot = 1.0;
        if bit.band(periodic.flags, comp_flags.cant_crit) == 0 then
            stats.crit_ot = loadout.melee_crit;
        end
        stats.crit_mod = 2;
        stats.target_resi_dot = 0;
        stats.target_avg_resi_dot = 0;
    end
end

local function stats_for_spell(stats, spell, loadout, effects, eval_flags)
    eval_flags = eval_flags or 0;

    local original_base_cost = spell.cost;
    local original_spell_id = spell.base_id;
    -- deal with aliasing spells
    if not stats.no_alias then
        spell = set_alias_spell(spell, loadout);
    end

    local benefit_id = spell.base_id;
    if spell.benefits_from_spell then
        benefit_id = spell.benefits_from_spell;
    end

    stats.special_crit_mod_tracked = 0;
    stats.num_extra_effects = 0;
    stats.num_periodic_effects = 0;
    stats.hit_inflation = 1.0; -- inflate hit value visually while not contributing to expectation

    stats.target_vuln_mod_mul = effects.mul.ability.vuln_mod[benefit_id] or 1.0;
    stats.target_vuln_mod_ot_mul = stats.target_vuln_mod_mul * (effects.mul.ability.vuln_mod_ot[benefit_id] or 1.0);

    stats.spell_dmg_mod = 0.0;
    stats.spell_dmg_mod_ot = 0.0;
    stats.spell_dmg_mod_mul = effects.mul.raw.spell_dmg_mod;
    stats.spell_dmg_mod_ot_mul = effects.mul.raw.spell_dmg_mod;


    stats.ignore_cant_crit = false;
    stats.crit = 0.0;
    stats.crit_ot = 0.0;

    local resource_refund = effects.raw.resource_refund;

    stats.effect_mod = effects.ability.effect_mod[benefit_id] or 0.0;
    stats.effect_ot_mod = effects.ability.effect_ot_mod[benefit_id] or 0.0;
    stats.flat_addition = effects.ability.flat_add[benefit_id] or 0.0;
    stats.flat_addition_ot = stats.flat_addition + (effects.ability.flat_add_ot[benefit_id] or 0.0);
    stats.spell_mod_base = 1.0 + (effects.ability.effect_mod_base[benefit_id] or 0.0);
    stats.spell_mod_base_flat = effects.ability.effect_mod_base_flat[benefit_id] or 0.0;
    --if bit.band(spell.flags, spell_flags.heal) ~= 0 then
    --    stats.spell_mod_base = stats.spell_mod_base + effects.raw.spell_heal_mod_base;
    --end
    stats.regen_while_casting = effects.raw.regen_while_casting;

    stats.gcd = math.min(spell.gcd, 1.5);

    local cost_mod = effects.ability.cost_mod[benefit_id] or 0.0;
    local base_mana = 0;
    if swc.base_mana_by_lvl then
        base_mana = swc.base_mana_by_lvl[loadout.lvl];
    end

    if bit.band(spell.flags, spell_flags.base_mana_cost) ~= 0 then
        original_base_cost = original_base_cost * base_mana;
    end
    local cost_flat = effects.ability.cost_mod_flat[benefit_id] or 0.0;
    stats.cost = math.floor((original_base_cost + cost_flat)) * (1.0 + cost_mod);

    if bit.band(spell.flags, spell_flags.instant) ~= 0 then
        stats.cast_time = stats.gcd;
    end

    stats.cast_time = spell.cast_time;
    if not effects.ability.cast_mod_flat[benefit_id] then
        effects.ability.cast_mod_flat[benefit_id] = 0.0;
    end
    stats.cast_time = stats.cast_time - effects.ability.cast_mod_flat[benefit_id];

    local haste_rating_per_perc = get_combat_rating_effect(CR_HASTE_SPELL, loadout.lvl);
    local haste_from_rating = 0.01 * max(0.0, loadout.haste_rating + effects.raw.haste_rating) / haste_rating_per_perc;

    local cast_reduction = effects.raw.haste_mod + haste_from_rating;

    if effects.ability.cast_mod[benefit_id] then
        cast_reduction = cast_reduction + effects.ability.cast_mod[benefit_id];
    end

    stats.cast_time = stats.cast_time * (1.0 - cast_reduction);

    local resource_refund_mul_crit = 0
    local resource_refund_mul_hit = 0

    if class == "PRIEST" then
        if bit.band(spell_flags.heal, spell.flags) ~= 0 then
            if loadout.runes[rune_ids.divine_aegis] then

                if spell.direct or benefit_id == spids.penance then
                    local aegis_flags = bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod);
                    if benefit_id == spids.penance then
                        aegis_flags = bit.bor(aegis_flags, extra_effect_flags.base_on_periodic_effect);
                    end
                    add_extra_direct_effect(stats, aegis_flags, 0.3, 1.0, "Divine Aegis");
                end
            end
            if benefit_id == spids.greater_heal and loadout.num_set_pieces[set_tiers.pve_3] >= 4 then
                add_extra_direct_effect(stats,
                                        bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.use_flat),
                                        500, 1.0, "Absorb");
            end
            if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 6 then
                if benefit_id == spids.circle_of_healing then
                    add_extra_periodic_effect(stats, 0, 0.25, 5, 3, 1.0, "6P Set Bonus");
                elseif benefit_id == spids.penance then
                    add_extra_periodic_effect(stats, extra_effect_flags.base_on_periodic_effect, 0.25, 5, 3, 1.0, "6P Set Bonus");
                end
            end
        elseif bit.band(spell_flags.absorb, spell.flags) ~= 0 then
        else
            if loadout.runes[rune_ids.despair] then
                stats.ignore_cant_crit = true;
            end
            -- TODO refactor
            --stats.crit = math.min(1.0, stats.crit + loadout.talents_table:pts(1, 14) * 0.01);
        end
        if bit.band(spell.flags, spell_flags.instant) ~= 0 then
            cost_mod = cost_mod - loadout.talents_table:pts(1, 10) * 0.02;
        end


    elseif class == "DRUID" then
        -- clearcast
        local pts = loadout.talents_table:pts(1, 9);
        if bit.band(swc.core.client_deviation, swc.core.client_deviation_flags.sod) ~= 0 and
            bit.band(spell_flags.instant, spell.flags) == 0 then
            cost_mod = cost_mod * (1.0 - 0.1 * pts);
        end

        if (benefit_id == spids.healing_touch or spell.base_id == spids.nourish) then
            if loadout.num_set_pieces[set_tiers.pve_3] >= 8 then
                --resource_refund = resource_refund + stats.crit * 0.3 * original_base_cost;
                resource_refund_mul_crit = resource_refund_mul_crit + 0.3 * original_base_cost;
            end
            if loadout.num_set_pieces[set_tiers.sod_final_pve_1_heal] >= 4 then
                resource_refund = resource_refund + 0.25 * 0.35 * original_base_cost;
            end
        end
        if benefit_id == spids.lifebloom then
            local mana_refund = stats.cost * cost_mod * 0.5;
            resource_refund = resource_refund + mana_refund;
        end

        if loadout.runes[rune_ids.living_seed] then
            if (bit.band(spell_flags.heal, spell.flags) ~= 0 and spell.direct) or
                benefit_id == spids.swiftmend then

                add_extra_direct_effect(stats,
                                        bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod),
                                        0.5, 1.0, "Living Seed");
            end
        end
        --if loadout.runes[rune_ids.lifebloom] and
        --    (benefit_id == spids.rejuvenation or benefit_id == spids.lifebloom) then
        --    stats.gcd = stats.gcd - 0.5;
        --    --print(G);
        --end
        if loadout.num_set_pieces[set_tiers.sod_final_pve_zg] >= 3 and benefit_id == spids.starfire then
            stats.gcd = stats.gcd - 0.5;
        end

        -- nature's grace
        local pts = loadout.talents_table:pts(1, 13);
        --if pts ~= 0 and spell.cast_time ~= spell.periodic.dur and bit.band(spell_flags.instant, spell.flags) == 0 and cast_reduction < 1.0 then
        -- channel check?
        if pts ~= 0 and not (spell.periodic and spell.cast_time == spell.periodic.dur) and bit.band(spell_flags.instant, spell.flags) == 0 and cast_reduction < 1.0 then
            stats.gcd = stats.gcd - 0.5;

            local crit_cast_reduction = 0.5 * stats.crit;
            if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 4 and bit.band(spell_flags.heal, spell.flags) ~= 0 then
                crit_cast_reduction = math.min(0.5, crit_cast_reduction * 2);
            end

            stats.cast_time = spell.cast_time - effects.ability.cast_mod_flat[benefit_id] - crit_cast_reduction;
            stats.cast_time = stats.cast_time * (1.0 - cast_reduction);
        end

        if bit.band(swc.core.client_deviation, swc.core.client_deviation_flags.sod) ~= 0 and
            is_buff_up(loadout, "player", lookups.moonkin_form, true) and
            bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.no_crit)) == 0 then
            --moonkin form periodic crit
            stats.ignore_cant_crit = true;
        end
    elseif class == "PALADIN" then
        if bit.band(spell.flags, spell_flags.heal) ~= 0 then
            -- illumination
            local pts = loadout.talents_table:pts(1, 9);
            if pts ~= 0 then
                --resource_refund = resource_refund + stats.crit * pts * 0.2 * original_base_cost;
                resource_refund_mul_crit = resource_refund_mul_crit + pts * 0.2 * original_base_cost;
            end

            if loadout.runes[rune_ids.fanaticism] and spell.direct then
                add_extra_periodic_effect(stats,
                                          bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod),
                                          0.6, 4, 3, 1.0, "Fanaticism");
            end
            if benefit_id == spids.flash_of_light and is_buff_up(loadout, loadout.friendly_towards, lookups.sacred_shield, false) then
                add_extra_periodic_effect(stats, 0, 1.0, 12, 1, 1.0, "Extra");
            end
            if benefit_id == spids.holy_light and spell.rank < 4 then
                -- Subtract healing to account for blessing of light coef for low rank holy light
                local bol_hl_val = nil;
                for k, v in pairs(lookups.bol_id_to_hl) do
                    local bol = is_buff_up(loadout, loadout.friendly_towards, k, false);
                    if bol then
                        bol_hl_val = v;
                        break;
                    end
                end

                if bol_hl_val then
                    stats.flat_addition = stats.flat_addition
                        - bol_hl_val * lookups.bol_rank_to_hl_coef_subtract[spell.rank];
                end
            end
        else
            if loadout.runes[rune_ids.wrath] then
                stats.crit = stats.crit + loadout.melee_crit;
                stats.crit_ot = stats.crit_ot + loadout.melee_crit;
                stats.ignore_cant_crit = true;
            end
            if loadout.runes[rune_ids.infusion_of_light] and benefit_id == spids.holy_shock then
                --resource_refund = resource_refund + stats.crit * original_base_cost;
                resource_refund_mul_crit = resource_refund_mul_crit + stats.crit * original_base_cost;
            end
        end
        if benefit_id == spids.exorcism and loadout.runes[rune_ids.exorcist] then
            stats.crit = 1.0;
        end
    elseif class == "SHAMAN" then
        -- shaman clearcast

        if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
            -- clearcast
            local pts = loadout.talents_table:pts(1, 6);
            if pts ~= 0 then
                cost_mod = cost_mod * (1.0 - 0.1 * pts);
            end
        end

        if benefit_id == spids.healing_wave or
            benefit_id == spids.lesser_healing_wave or
            benefit_id == spids.riptide then
            if loadout.num_set_pieces[set_tiers.pve_1] >= 5 or loadout.num_set_pieces[set_tiers.sod_final_pve_1_heal] >= 4 then
                local mana_refund = original_base_cost;
                resource_refund = resource_refund + 0.25 * 0.35 * mana_refund;
            end
            if loadout.runes[rune_ids.ancestral_awakening] then
                add_extra_direct_effect(stats,
                                        bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod),
                                        0.3, 1.0, "Awakening");
            end
        end
        if loadout.runes[rune_ids.overload] and (benefit_id == spids.chain_heal or
                benefit_id == spids.chain_lightning or
                benefit_id == spids.healing_wave or
                benefit_id == spids.lightning_bolt or
                benefit_id == spids.lava_burst) then
            add_extra_direct_effect(stats, 0, 0.5, 0.6, "Overload 60% chance");
        end

        if bit.band(spell.flags, spell_flags.weapon_enchant) ~= 0 then
            local mh_speed, oh_speed = UnitAttackSpeed("player");
            local wep_speed = mh_speed;
            if bit.band(eval_flags, swc.calc.evaluation_flags.offhand) ~= 0 then
                if oh_speed then
                    wep_speed = oh_speed;
                end
            end
            -- api may incorrectly return 0, clamp to something
            wep_speed = math.max(wep_speed, 0.1);
            spell.periodic.tick_time = wep_speed;
            -- scaling should change with weapon base speed not current attack speed
            -- but there is no easy way to get it
            if benefit_id == spids.flametongue_weapon then
                stats.spell_mod_base = stats.spell_mod_base * 0.25 * (math.max(1.0, math.min(4.0, wep_speed))) - 1.0;
            elseif benefit_id == spids.frostbrand_weapon then
                local min_proc_chance = 0.15;
                -- TODO: refactor
                --stats.hit = stats.hit * (min_proc_chance * math.max(1.0, math.min(4.0, wep_speed)));
            end
        end
        if benefit_id == spids.earth_shield and loadout.friendly_towards == "player" then
            -- strange behaviour hacked in
            stats.effect_mod = stats.effect_mod + 0.02 * loadout.talents_table:pts(3, 14);
        end
        if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 2 and spell.direct and is_buff_up(loadout, "player", lookups.water_shield, true) then

            --resource_refund = resource_refund + stats.crit * 0.04 * loadout.max_mana;
            resource_refund_mul_crit = resource_refund_mul_crit + 0.04 * loadout.max_mana;
        end
    elseif class == "MAGE" then
        if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
            -- clearcast
            local pts = loadout.talents_table:pts(1, 6);
            if pts ~= 0 then
                cost_mod = cost_mod * (1.0 - 0.02 * pts);
            end

            local pts = loadout.talents_table:pts(2, 12);
            if pts ~= 0 and spell.direct and 
                (spell.direct.school1 == magic_school.fire or spell.direct.school1 == magic_school.frost) then
                -- master of elements
                local mana_refund = pts * 0.1 * original_base_cost;
                --resource_refund = resource_refund + stats.hit * stats.crit * mana_refund;
                resource_refund_mul_crit = resource_refund_mul_crit + mana_refund;
            end

            if loadout.runes[rune_ids.burnout] and spell.direct then
                --resource_refund = resource_refund - stats.crit * 0.01 * base_mana;
                resource_refund_mul_crit = resource_refund_mul_crit + 0.01 * base_mana;
            end

            -- ignite
            local pts = loadout.talents_table:pts(2, 3);
            if pts ~= 0 and spell.direct and spell.direct.school1 == magic_school.fire then
                -- % ignite double dips in % multipliers
                local double_dip = stats.spell_dmg_mod_mul *
                effects.mul.by_school.spell_dmg_mod[magic_school.fire] *
                effects.mul.by_school.target_vuln_dmg[magic_school.fire];

                add_extra_periodic_effect(stats,
                                          bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod),
                                          (pts * 0.08) * double_dip, 2, 2, 1.0, "Ignite");
            end
            if benefit_id == spids.arcane_surge then
                stats.cost = loadout.mana;
                cost_mod = 1.0;

                stats.spell_dmg_mod_mul = stats.spell_dmg_mod_mul *
                    (1.0 + 3 * loadout.mana / math.max(1, loadout.max_mana));
            end

            if loadout.num_set_pieces[set_tiers.pve_2] >= 8 and
                (benefit_id == spids.frostbolt or benefit_id == spids.fireball) then
                stats.cast_time = 0.9 * stats.cast_time + 0.1 * stats.gcd;
            end

            if bit.band(loadout.flags, loadout_flags.target_frozen) ~= 0 then
                local pts = loadout.talents_table:pts(3, 13);

                stats.crit = math.max(0.0, math.min(1.0, stats.crit + pts * 0.1));

                if benefit_id == spids.ice_lance then
                    stats.target_vuln_mod_mul = stats.target_vuln_mod_mul * 3;
                end
            end
            if loadout.runes[rune_ids.overheat] and
                benefit_id == spids.fire_blast then
                stats.gcd = 0.0;
                stats.cast_time = 0.0;
            end

            if loadout.num_set_pieces[set_tiers.sod_final_pve_2] >= 6 and benefit_id == spids.fireball then
                add_extra_periodic_effect(stats, 0, 1.0, 4, 2, 1.0, "6P Set Bonus");
            end

            if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 2 and benefit_id == spids.arcane_missiles then
                resource_refund = resource_refund + 0.5 * original_base_cost;
            end
        end
    elseif class == "WARLOCK" then
        if benefit_id == spids.chaos_bolt then
            -- TODO: refactor
            --stats.hit = 1.0;
            --stats.target_avg_resi = 0.0;
        end

        --if bit.band(spell.flags, spell_flags.destruction) ~= 0 then
        --    cost_mod = cost_mod - loadout.talents_table:pts(3, 2) * 0.01;
        --    stats.crit = math.min(1.0, stats.crit + loadout.talents_table:pts(3, 7) * 0.01);
        --    local crit_mod = loadout.talents_table:pts(3, 14) * 0.5;
        --    stats.crit_mod = stats.crit_mod + crit_mod;
        --    stats.crit_mod_ot = stats.crit_mod_ot + crit_mod;
        --end
        if loadout.runes[rune_ids.pandemic] and
            (benefit_id == spids.corruption or
                benefit_id == spids.immolate or
                benefit_id == spids.unstable_affliction or
                benefit_id == spids.curse_of_agony or
                benefit_id == spids.curse_of_doom or
                benefit_id == spids.siphon_life) then
            stats.ignore_cant_crit = true;
            stats.crit_mod_ot = stats.crit_mod_ot + 0.5;
        end
        if loadout.runes[rune_ids.dance_of_the_wicked] and spell.direct then
            --resource_refund = resource_refund + stats.crit * 0.02 * loadout.max_mana;
            resource_refund_mul_crit = resource_refund_mul_crit + 0.02 * loadout.max_mana;
        end

        if loadout.runes[swc.talents.rune_ids.soul_siphon] then
            if benefit_id == spids.drain_soul then
                if loadout.enemy_hp_perc and loadout.enemy_hp_perc <= 0.2 then
                    stats.target_vuln_mod_ot_mul = stats.target_vuln_mod_ot_mul *
                    math.min(1.5, 1.0 + 0.5 * effects.raw.target_num_shadow_afflictions);
                else
                    stats.target_vuln_mod_ot_mul = stats.target_vuln_mod_ot_mul *
                    math.min(1.18, 1.0 + 0.06 * effects.raw.target_num_shadow_afflictions);
                end
            elseif benefit_id == spids.drain_life then
                stats.target_vuln_mod_ot_mul = stats.target_vuln_mod_ot_mul *
                math.min(1.18, 1.0 + 0.06 * effects.raw.target_num_shadow_afflictions);
            end
        end
        if benefit_id == spids.shadow_bolt then
            if loadout.num_set_pieces[set_tiers.sod_final_pve_2] >= 6 then
                stats.target_vuln_mod_mul = stats.target_vuln_mod_mul * math.min(1.3, 1.1 + 0.1 * effects.raw.target_num_afflictions);
            end
            local isb_buff_val = nil;
            for k, v in pairs(lookups.isb_to_vuln) do
                local isb = is_buff_up(loadout, loadout.hostile_towards, k, false);
                if isb then
                    isb_buff_val = v;
                    break;
                end
            end
            
            local isb_pts = loadout.talents_table:pts(3, 1);
            local isb_uptime = 1.0 - math.pow(1.0 - stats.crit, 4);

            if isb_buff_val and isb_pts ~= 0 then

                stats.target_vuln_mod_mul = stats.target_vuln_mod_mul / (1.0 + isb_buff_val);

                stats.hit_inflation = stats.hit_inflation + (1.0 + isb_buff_val)/(1.0 + isb_pts*0.04*isb_uptime) - 1;
            else
                stats.hit_inflation = stats.hit_inflation / (1.0 + isb_pts*0.04*isb_uptime);
            end
            stats.target_vuln_mod_mul = stats.target_vuln_mod_mul * (1.0 + isb_pts*0.04*isb_uptime);
        end
    end



    if bit.band(spell.flags, spell_flags.alias) ~= 0 then
        stats.spell_mod = 1.0 + stats.effect_mod;
        stats.spell_ot_mod = 1.0 + stats.effect_mod;
    end

    stats.ot_extra_ticks = effects.ability.extra_ticks[benefit_id] or 0.0;
    stats.ot_extra_dur = effects.ability.extra_dur[benefit_id] or 0.0;
    stats.ot_extra_tick_time = effects.ability.extra_tick_time[benefit_id] or 0.0;

    stats.ap = loadout.ap;
    stats.rap = loadout.rap;


    if effects.ability.refund[benefit_id] and effects.ability.refund[benefit_id] ~= 0 then
        local refund = effects.ability.refund[benefit_id];
        local max_rank = spell.rank;
        if benefit_id == spids.lesser_healing_wave then
            max_rank = 6;
        elseif benefit_id == spids.healing_touch then
            max_rank = 11;
        end

        local coef_estimate = spell.rank / max_rank;

        resource_refund = resource_refund + refund * coef_estimate;
    end


    if spell.direct then
        spell_stats_direct(stats, spell, loadout, effects, eval_flags);
    end
    if spell.periodic then
        spell_stats_periodic(stats, spell, loadout, effects, eval_flags);
    end

    stats.cost = stats.cost * cost_mod;
    stats.cost = math.floor(stats.cost + 0.5);

    if not stats.hit then
        print(spell.base_id);
    end
    resource_refund = resource_refund + resource_refund_mul_crit * (stats.crit or stats.crit_ot) * stats.hit;
    resource_refund = resource_refund + resource_refund_mul_hit * stats.hit;

    stats.cost = stats.cost - resource_refund;
    stats.cost = math.max(stats.cost, 0);


    if bit.band(spell.flags, spell_flags.uses_attack_speed) ~= 0 then
        if bit.band(spell.direct.flags, comp_flags.applies_mh) ~= 0 then
            stats.cast_time = loadout.m1_speed;
        elseif bit.band(spell.direct.flags, comp_flags.applies_ranged) ~= 0 then
            stats.cast_time = loadout.r_speed;
        end
    end
    stats.cast_time_nogcd = stats.cast_time;
    stats.cast_time = math.max(stats.cast_time, stats.gcd);


    stats.cost_per_sec = stats.cost / stats.cast_time;


    spell = spells[original_spell_id];
end

local function resolve_extra_spell_effects(info, stats)

    for k = 1, stats.num_extra_effects do
        if (stats["extra_effect_is_periodic" .. k]) then
            info.num_periodic_effects = info.num_periodic_effects + 1;
            local i = info.num_periodic_effects;
            if (stats["extra_effect_on_crit" .. k]) then
                info["ot_min_noncrit_if_hit" .. i] = 0;
                info["ot_max_noncrit_if_hit" .. i] = 0;
                if (stats["extra_effect_base_on_periodic" .. k]) then
                    info["ot_min_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_min_crit_if_hit1;
                    info["ot_max_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_max_crit_if_hit1;
                else
                    info["ot_min_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.min_crit_if_hit1;
                    info["ot_max_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.max_crit_if_hit1;
                end
                info["ot_ticks" .. i] = stats["extra_effect_ticks" .. k];
                info["ot_tick_time" .. i] = stats["extra_effect_tick_time" .. k];
                info["ot_dur" .. i] = stats["extra_effect_ticks" .. k] * stats["extra_effect_tick_time" .. k];
                info["ot_description" .. i] = stats["extra_effect_desc" .. k];
                info["ot_crit" .. i] = stats.crit;
                info["ot_utilization" .. i] = stats["extra_effect_util" .. k];
            else
                if (stats["extra_effect_base_on_periodic" .. k]) then
                    info["ot_min_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_min_noncrit_if_hit1;
                    info["ot_max_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_max_noncrit_if_hit1;
                    info["ot_min_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_min_crit_if_hit1;
                    info["ot_max_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_max_crit_if_hit1;

                else
                    info["ot_min_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.min_noncrit_if_hit1;
                    info["ot_max_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.max_noncrit_if_hit1;
                    info["ot_min_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.min_crit_if_hit1;
                    info["ot_max_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.max_crit_if_hit1;
                end
                info["ot_ticks" .. i] = stats["extra_effect_ticks" .. k];
                info["ot_tick_time" .. i] = stats["extra_effect_tick_time" .. k];
                info["ot_dur" .. i] = stats["extra_effect_ticks" .. k] * stats["extra_effect_tick_time" .. k];
                info["ot_description" .. i] = stats["extra_effect_desc" .. k];
                info["ot_crit" .. i] = stats.crit;
                info["ot_utilization" .. i] = stats["extra_effect_util" .. k];
            end
        else
            info.num_direct_effects = info.num_direct_effects + 1;
            local i = info.num_direct_effects;

            info["direct_description" .. i] = stats["extra_effect_desc" .. k];
            info["direct_utilization" .. i] = stats["extra_effect_util" .. k];

            info["crit" .. i] = stats.crit;

            if (stats["extra_effect_use_flat" .. k]) then
                info["min_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k];
                info["max_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k];
                info["min_crit_if_hit" .. i] = stats["extra_effect_val" .. k];
                info["max_crit_if_hit" .. i] = stats["extra_effect_val" .. k];
            else
                if (stats["extra_effect_base_on_periodic" .. k]) then
                    info["min_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_min_noncrit_if_hit1;
                    info["max_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_max_noncrit_if_hit1;
                    info["min_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_min_crit_if_hit1;
                    info["max_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_max_crit_if_hit1;
                else
                    info["min_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.min_noncrit_if_hit1;
                    info["max_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.max_noncrit_if_hit1;
                    info["min_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.min_crit_if_hit1;
                    info["max_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.max_crit_if_hit1;
                end
            end
            if (stats["extra_effect_on_crit" .. k]) then

                info["min_noncrit_if_hit" .. i] = 0;
                info["max_noncrit_if_hit" .. i] = 0;
            end

        end
    end

    -- accumulate periodics
    info.total_ot_min_noncrit_if_hit = 0;
    info.total_ot_max_noncrit_if_hit = 0;
    info.total_ot_min_crit_if_hit = 0;
    info.total_ot_max_crit_if_hit = 0;
    for i = 1, info.num_periodic_effects do
        local p                   = info["ot_utilization" .. i];
        info.total_ot_min_noncrit_if_hit      = info.total_ot_min_noncrit_if_hit + p * info["ot_min_noncrit_if_hit" .. i];
        info.total_ot_max_noncrit_if_hit  = info.total_ot_max_noncrit_if_hit + p * info["ot_max_noncrit_if_hit" .. i];
        info.total_ot_min_crit_if_hit     = info.total_ot_min_crit_if_hit + p * info["ot_min_crit_if_hit" .. i];
        info.total_ot_max_crit_if_hit = info.total_ot_max_crit_if_hit + p * info["ot_max_crit_if_hit" .. i];
    end

    -- accumulate directs
    info.total_min_noncrit_if_hit = 0;
    info.total_max_noncrit_if_hit = 0;
    info.total_min_crit_if_hit    = 0;
    info.total_max_crit_if_hit    = 0;
    for i = 1, info.num_direct_effects do
        local p                       = info["direct_utilization" .. i];
        info.total_min_noncrit_if_hit = info.total_min_noncrit_if_hit + p * info["min_noncrit_if_hit" .. i];
        info.total_max_noncrit_if_hit = info.total_max_noncrit_if_hit + p * info["max_noncrit_if_hit" .. i];
        info.total_min_crit_if_hit    = info.total_min_crit_if_hit + p * info["min_crit_if_hit" .. i];
        info.total_max_crit_if_hit    = info.total_max_crit_if_hit + p * info["max_crit_if_hit" .. i];
    end
end

local function add_expectation_direct_st(info, num_to_add)
    local added = info.expectation_direct_st * num_to_add;
    info.expectation_direct = info.expectation_direct + added;
    info.expectation = info.expectation + added;
end

local function add_expectation_ot_st(info, num_to_add)
    local added = info.expected_ot_st * num_to_add;
    info.expected_ot = info.expected_ot + added;
    info.expectation = info.expectation + added;
end

local function calc_expectation(info, spell, stats, loadout, num_unbounded_targets)
    if not num_unbounded_targets then
        num_unbounded_targets = 1;
    end

    -- direct
    local expected_direct_if_hit = 0;
    for i = 1, info.num_direct_effects do
        expected_direct_if_hit = expected_direct_if_hit + 0.5 * info["direct_utilization" .. i] *
            ((1.0 - info["crit" .. i]) * (info["min_noncrit_if_hit" .. i] + info["max_noncrit_if_hit" .. i]) +
                info["crit" .. i] * (info["min_crit_if_hit" .. i] + info["max_crit_if_hit" .. i]));
    end

    if info.num_direct_effects > 0 then
        info.expectation_direct_st = stats.hit * expected_direct_if_hit * (1 - stats.target_avg_resi);
        info.expectation_direct = info.expectation_direct_st;
        if spell.direct and bit.band(spell.direct.flags, comp_flags.unbounded_aoe) ~= 0 then
            info.expectation_direct = info.expectation_direct_st * num_unbounded_targets;
        end
    else
        info.expectation_direct_st = 0;
        info.expectation_direct = 0;
    end

    -- over time
    local expected_ot_if_hit = 0;
    for i = 1, info.num_periodic_effects do
        expected_ot_if_hit = expected_ot_if_hit + info["ot_utilization" .. i] *
            ((1.0 - info["ot_crit" .. i]) * 0.5 * (info["ot_min_noncrit_if_hit" .. i] + info["ot_max_noncrit_if_hit" .. i]) +
                info["ot_crit" .. i] * 0.5 * (info["ot_min_crit_if_hit" .. i] + info["ot_max_crit_if_hit" .. i]));
    end

    if info.num_periodic_effects > 0 then
        info.expected_ot_st = stats.hit_ot * expected_ot_if_hit * (1 - stats.target_avg_resi_dot);
        info.expected_ot = info.expected_ot_st;
        if spell.periodic and bit.band(spell.periodic.flags, comp_flags.unbounded_aoe) ~= 0 then
            info.expected_ot = info.expected_ot_st * num_unbounded_targets;
        end
    else
        info.expected_ot_st = 0;
        info.expected_ot = 0;
    end

    -- combine
    info.expectation_st = info.expectation_direct_st + info.expected_ot_st
    info.expectation = info.expectation_direct + info.expected_ot

    if loadout.beacon and bit.band(spell.flags, spell_flags.heal) ~= 0 then
        add_expectation_direct_st(info, 0.75);
    end
end

local function direct_info(info, spell, loadout, stats)
    local clvl = loadout.lvl;

    local base_min = spell.direct.min;
    local base_max = spell.direct.max;

    if spell.direct.per_lvl_sq == 0 then
        local lvl_diff_applicable = math.max(0,
            math.min(clvl - spell.lvl_req, spell.lvl_max - spell.lvl_req));
        base_min = base_min + spell.direct.per_lvl * lvl_diff_applicable;
        base_max = base_max + spell.direct.per_lvl * lvl_diff_applicable;
    else
        local added_effect = spell.direct.base + spell.direct.per_lvl * clvl + spell.direct.per_lvl_sq * clvl * clvl;
        base_min = spell.direct.min * added_effect;
        base_max = spell.direct.max * added_effect;
    end

    if bit.band(spell.direct.flags, comp_flags.applies_mh) ~= 0 then
        base_min = (spell.direct.base + loadout.m1_min) * base_min;
        base_max = (spell.direct.base + loadout.m1_max) * base_max;
    elseif bit.band(spell.direct.flags, comp_flags.applies_ranged) ~= 0 then
        base_min = (spell.direct.base + loadout.r_min) * base_min;
        base_max = (spell.direct.base + loadout.r_max) * base_max;
    elseif bit.band(spell.flags, spell_flags.finishing_move) ~= 0 then
        -- seems like finishing moves are never weapon based
        base_min = base_min + spell.direct.per_resource * loadout.combo_pts;
        base_max = base_max + spell.direct.per_resource * loadout.combo_pts;
    end

    info.min_noncrit_if_hit_base1 =
        (stats.spell_mod_base * (base_min + stats.spell_mod_base_flat) + stats.flat_addition) * stats.spell_mod;
    info.max_noncrit_if_hit_base1 =
        (stats.spell_mod_base * (base_max + stats.spell_mod_base_flat) + stats.flat_addition) * stats.spell_mod;
    info.min_noncrit_if_hit1 =
        info.min_noncrit_if_hit_base1 + stats.spell_power * stats.coef  * stats.spell_mod;
    info.max_noncrit_if_hit1 =
        info.max_noncrit_if_hit_base1 + stats.spell_power * stats.coef * stats.spell_mod;

    info.min_crit_if_hit1 = info.min_noncrit_if_hit1 * stats.crit_mod;
    info.max_crit_if_hit1 = info.max_noncrit_if_hit1 * stats.crit_mod;

    -- needed to fit generalized template for expectation
    info.crit1 = stats.crit;
    info.direct_utilization1 = 1.0;

    info.num_direct_effects = info.num_direct_effects + 1;
end

local function periodic_info(info, spell, loadout, stats)
    local clvl = loadout.lvl;

    local base_tick_min = spell.periodic.min;
    local base_tick_max = spell.periodic.max;

    if spell.periodic.per_lvl_sq == 0 then
        local lvl_diff_applicable = math.max(0,
            math.min(clvl - spell.lvl_req, spell.lvl_max - spell.lvl_req));
        base_tick_min = base_tick_min + spell.periodic.per_lvl * lvl_diff_applicable;
        base_tick_max = base_tick_max + spell.periodic.per_lvl * lvl_diff_applicable;

    else
        local added_effect = spell.periodic.base + spell.periodic.per_lvl * clvl + spell.periodic.per_lvl_sq * clvl * clvl;
        base_tick_min = spell.periodic.min * added_effect;
        base_tick_max = spell.periodic.max * added_effect;
    end

    -- unclear if this ever needs to work in conjunction with any kind of level scaling
    if bit.band(spell.periodic.flags, comp_flags.applies_mh) ~= 0 then
        base_tick_min = (spell.periodic.base + loadout.m1_min) * base_tick_min;
        base_tick_max = (spell.periodic.base + loadout.m1_max) * base_tick_max;
    elseif bit.band(spell.periodic.flags, comp_flags.applies_ranged) ~= 0 then
        base_tick_min = (spell.periodic.base + loadout.r_min) * base_tick_min;
        base_tick_max = (spell.periodic.base + loadout.r_max) * base_tick_max;
    elseif bit.band(spell.flags, spell_flags.finishing_move) ~= 0 then
        -- seems like finishing moves are never weapon based
        base_tick_min = base_tick_min + spell.periodic.per_resource * loadout.combo_pts;
        base_tick_max = base_tick_max + spell.periodic.per_resource * loadout.combo_pts;
        -- TODO: combo pts scaling with dur sometimes
        --extra_ticks = extra_ticks + loadout.combo_pts;
    end

    info.ot_dur1 = spell.periodic.dur + stats.ot_extra_dur;
    info.ot_tick_time1 = spell.periodic.tick_time + stats.ot_extra_tick_time;
    info.ot_ticks1 = (info.ot_dur1 / info.ot_tick_time1);
    info.ot_dur1 = info.ot_tick_time1 * info.ot_ticks1;
    info.longest_ot_duration = info.ot_dur1;

    if bit.band(spell.flags, spell_flags.channel) ~= 0 then
        -- may need to apply haste here on some clients
        stats.cast_time = info.ot_dur1;
    end

    info.ot_min_crit_if_hit1 = 0.0;
    info.ot_max_crit_if_hit1 = 0.0;

    info.ot_min_noncrit_if_hit_base1 = (stats.spell_mod_base * (base_tick_min + stats.spell_mod_base_flat) + stats.flat_addition_ot) * info.ot_ticks1 * stats.spell_ot_mod;

    info.ot_min_noncrit_if_hit1 = info.ot_min_noncrit_if_hit_base1 + stats.ot_coef * stats.spell_power_ot * info.ot_ticks1 * stats.spell_ot_mod;

    info.ot_max_noncrit_if_hit_base1 = (stats.spell_mod_base * (base_tick_max + stats.spell_mod_base_flat) + stats.flat_addition_ot) * info.ot_ticks1 * stats.spell_ot_mod;

    info.ot_max_noncrit_if_hit1 = info.ot_max_noncrit_if_hit_base1 + stats.ot_coef * stats.spell_power_ot * info.ot_ticks1 * stats.spell_ot_mod;

    info.ot_min_crit_if_hit1 = info.ot_min_noncrit_if_hit1 * stats.crit_mod_ot;
    info.ot_max_crit_if_hit1 = info.ot_max_noncrit_if_hit1 * stats.crit_mod_ot;

    -- needed to fit generalized template for expectation
    info.ot_crit1 = stats.crit_ot;
    info.ot_utilization1 = 1.0;

    info.num_periodic_effects = info.num_periodic_effects + 1;
end

local function spell_info(info, spell, stats, loadout, effects, eval_flags)
    eval_flags = eval_flags or 0;

    info.num_periodic_effects = 0;
    info.num_direct_effects = 0;

    -- deal with aliasing spells
    local original_spell_id = spell.base_id;

    spell = set_alias_spell(spell, loadout);
    if spell.direct then
        direct_info(info, spell, loadout, stats);
    end
    if spell.periodic then
        periodic_info(info, spell, loadout, stats);
    end


    local num_unbounded_targets = loadout.unbounded_aoe_targets;
    if bit.band(eval_flags, evaluation_flags.assume_single_effect) ~= 0 then
        num_unbounded_targets = 1;
    end

    resolve_extra_spell_effects(info, stats);

    calc_expectation(info, spell, stats, loadout, num_unbounded_targets);

    if original_spell_id ~= spell.base_id then
        -- using alias for swiftmend/conflagrate
        -- we have the context for the aliased spell but now
        -- switch back to stats for the original spell,
        stats.alias = spell.base_id;
        spell = spells[original_spell_id];
        stats.no_alias = true;
        local alias_coef = stats.coef;
        local alias_ot_coef = stats.ot_coef;
        stats_for_spell(stats, spell, loadout, effects, eval_flags);
        if stats.coef == 0 then
            stats.coef = alias_coef;
        end
        if stats.ot_coef == 0 then
            stats.ot_coef = alias_ot_coef;
        end
        stats.no_alias = nil;
    end

    info.absorb = 0.0;
    if bit.band(spell_flags.absorb, spell.flags) ~= 0 then
        info.absorb = info.min_noncrit_if_hit1;

        info.min_noncrit_if_hit1 = 0.0;
        info.max_noncrit_if_hit1 = 0.0;

        info.min_crit_if_hit1 = 0.0;
        info.max_crit_if_hit1 = 0.0;
    end

    if (stats.direct_jumps) then
        if (stats.direct_jump_amp ~= 1.0) then
            local jmp_sum = 0;
            for i = 1, stats.direct_jumps do
                local jmp_effect = 1;
                for _ = 1, i do
                    jmp_effect = jmp_effect * stats.direct_jump_amp;
                end
                jmp_sum = jmp_sum + jmp_effect;
            end
            add_expectation_direct_st(info, jmp_sum);
        else
            add_expectation_direct_st(info, stats.direct_jumps);
        end
    end
    if (stats.periodic_jumps) then
        if (stats.periodic_jump_amp ~= 1.0) then
            local jmp_sum = 0;
            for i = 1, stats.periodic_jumps do
                local jmp_effect = 1;
                for _ = 1, i do
                    jmp_effect = jmp_effect * stats.periodic_jump_amp;
                end
                jmp_sum = jmp_sum + jmp_effect;
            end
            add_expectation_ot_st(info, jmp_sum);
        else
            add_expectation_ot_st(info, stats.periodic_jumps);
        end
    end
    if special_abilities[original_spell_id] then
        special_abilities[original_spell_id](spell, info, loadout, stats, effects);
    end
    stats.alias = nil;

    if bit.band(eval_flags, evaluation_flags.isolate_periodic) ~= 0 then
        info.expectation_st = info.expectation_st - info.expectation_direct_st;
        info.expectation = info.expectation - info.expectation_direct;

        info.expectation_direct_st = 0;
        info.expectation_direct = 0;
    elseif bit.band(eval_flags, evaluation_flags.isolate_direct) ~= 0 then
        info.expectation_st = info.expectation_st - info.expected_ot_st;
        info.expectation = info.expectation - info.expected_ot;

        info.expected_ot_st = 0;
        info.expected_ot = 0;
    end

    if info.expectation < info.expectation_st or bit.band(eval_flags, evaluation_flags.assume_single_effect) ~= 0 then
        info.expectation = info.expectation_st;
        info.expected_ot = info.expected_ot_st;
        info.expectation_direct = info.expectation_direct_st
    end

    -- soul drain, life drain, mind flay are all casts that can only miss on the entire channel itself
    -- 1.5 sec gcd is always implied which is the only penalty for misses
    if bit.band(spell.flags, spell_flags.entire_channel_missable) ~= 0 then
        -- TODO: refactor needs fix
        local cast_time_avoided_by_miss = info.ot_dur1 - stats.gcd;

        stats.cast_time = stats.cast_time - cast_time_avoided_by_miss * (1.0 - stats.hit);
        stats.cast_time_nogcd = stats.cast_time;

        info.longest_ot_duration = stats.cast_time;
    end

    info.effect_per_sec = info.expectation / stats.cast_time;

    if stats.cost == 0 then
        info.effect_per_cost = math.huge;
    else
        info.effect_per_cost = info.expectation / stats.cost;
    end

    info.cost_per_sec = stats.cost / stats.cast_time;

    if info.num_direct_effects > 0 then

        info.min_noncrit_if_hit1 = info.min_noncrit_if_hit1 * stats.hit_inflation;
        info.max_noncrit_if_hit1 = info.max_noncrit_if_hit1 * stats.hit_inflation;
        info.min_crit_if_hit1 = info.min_crit_if_hit1 * stats.hit_inflation;
        info.max_crit_if_hit1 = info.max_crit_if_hit1 * stats.hit_inflation;
    end

    if info.num_periodic_effects > 0 then
        info.longest_ot_duration = info.longest_ot_duration or 0;
        for i = 2, info.num_periodic_effects do
            info.longest_ot_duration = math.max(info.longest_ot_duration, info["ot_dur" .. i]);
        end
        info.effect_per_dur = 0;
        if info.longest_ot_duration ~= 0 then
            info.effect_per_dur = info.expected_ot / info.longest_ot_duration;
        end

        info.ot_min_noncrit_if_hit1 = info.ot_min_noncrit_if_hit1 * stats.hit_inflation;
        info.ot_max_noncrit_if_hit1 = info.ot_max_noncrit_if_hit1 * stats.hit_inflation;
        info.ot_min_crit_if_hit1 = info.ot_min_crit_if_hit1 * stats.hit_inflation;
        info.ot_max_crit_if_hit1 = info.ot_max_crit_if_hit1 * stats.hit_inflation;
    end

    if bit.band(spell.flags, spell_flags.resource_regen) ~= 0 then
        if spell.base_id == spids.life_tap then
            info.mana_restored = spell.direct.min;

            local pts = loadout.talents_table:pts(1, 5);
            info.mana_restored = info.mana_restored * (1.0 + pts * 0.1);
            if stats.crit == 1.0 then
                info.mana_restored = 2 * info.mana_restored;
            end
        elseif spell.base_id == spids.mana_tide_totem then
            info.mana_restored = spell.periodic.min * spell.periodic.dur / spell.periodic.tick_time;
        elseif spell.base_id == spids.dispersion or spell.base_id == spids.shadowfiend or spell.base_id == spids.shamanistic_rage then
            info.mana_restored = spell.periodic.min * loadout.max_mana * spell.periodic.dur /
            spell.periodic.tick_time;
        else
            -- evocate, innervate
            local spirit = loadout.stats[stat.spirit] + effects.by_attribute.stats[stat.spirit];
            local mp5 = effects.raw.mp5 + loadout.max_mana * effects.raw.perc_max_mana_as_mp5;
            info.mana_restored = 0.2 * mp5 +
                0.5 * spirit_mana_regen(spirit) *
                (1.0 + spell.periodic.min) * math.max(stats.cast_time, spell.periodic.dur);
        end
        info.effect_per_cost = math.huge;
    end


end

local function spell_info_from_stats(info, stats, spell, loadout, effects, eval_flags)
    stats_for_spell(stats, spell, loadout, effects, eval_flags);
    spell_info(info, spell, stats, loadout, effects, eval_flags);
end

local function cast_until_oom(spell_effect, stats, loadout, effects, calculating_weights)
    calculating_weights = calculating_weights or false;

    local mana = loadout.mana + config.loadout.extra_mana + effects.raw.mana;

    -- src: https://wowwiki-archive.fandom.com/wiki/Spirit
    -- without mp5
    local spirit = loadout.stats[stat.spirit] + effects.by_attribute.stats[stat.spirit];

    local mp2_not_casting = spirit_mana_regen(spirit);

    if not calculating_weights then
        mp2_not_casting = math.ceil(mp2_not_casting);
    end
    local mp5 = effects.raw.mp5 + loadout.max_mana * effects.raw.perc_max_mana_as_mp5 +
    effects.raw.mp5_from_int_mod * loadout.stats[stat.int] * (1.0 + effects.by_attribute.stat_mod[stat.int]);

    local mp1_casting = 0.2 * mp5 + 0.5 * mp2_not_casting * stats.regen_while_casting;

    --  don't use dynamic mana regen lua api for now
    calculating_weights = true;

    -- TODO: don't use this when stat comparison is open
    if not config.loadout.use_custom_talents and not calculating_weights then
        -- the mana regen calculation is correct, but use GetManaRegen() to detect
        -- niche MP5 sources dynamically
        local _, x = GetManaRegen()
        mp1_casting = x;
    end

    local resource_loss_per_sec = spell_effect.cost_per_sec - mp1_casting;
    spell_effect.mana = mana;

    if resource_loss_per_sec <= 0 then
        spell_effect.num_casts_until_oom = math.huge;
        spell_effect.effect_until_oom = math.huge;
        spell_effect.time_until_oom = math.huge;
        spell_effect.mp1 = mp1_casting;
    else
        spell_effect.time_until_oom = mana / resource_loss_per_sec;
        spell_effect.num_casts_until_oom = spell_effect.time_until_oom / stats.cast_time;
        spell_effect.effect_until_oom = spell_effect.num_casts_until_oom * spell_effect.expectation;
        spell_effect.mp1 = mp1_casting;
    end
end

if class == "SHAMAN" then
    special_abilities = {
        --[spids.chain_heal] = function(spell, info, loadout)
        --    local jmp_red = 0.5;
        --    local jmp_num = 2;
        --    if loadout.runes[rune_ids.coherence] then
        --        jmp_red = jmp_red + 0.15;
        --        jmp_num = 3;
        --    end
        --    if loadout.num_set_pieces[set_tiers.pve_2] >= 3 then
        --        jmp_red = jmp_red * 1.3;
        --    end

        --    local jmp_sum = 0;
        --    for i = 1, jmp_num do
        --        local jmp_effect = 1;
        --        for j = 1, i do
        --            jmp_effect = jmp_effect * jmp_red;
        --        end
        --        jmp_sum = jmp_sum + jmp_effect;
        --    end
        --    add_expectation_direct_st(info, jmp_sum);
        --end,
        [spids.lightning_shield] = function(spell, info, loadout, stats)
            --if loadout.runes[rune_ids.static_shock] then
            --    add_expectation_direct_st(info, 8);
            --elseif loadout.runes[rune_ids.overcharged] == nil then
            --    add_expectation_direct_st(info, 2);
            --end
            --if loadout.runes[rune_ids.overcharged] then
            --    stats.cost = 0;
            --    stats.cast_time = 1;
            --    stats.cast_time_nogcd = 1;
            --    -- convert into periodic, with duration 1 sec to not go infinite


            --    info.ot_min_noncrit_if_hit1 = info.min_noncrit_if_hit1;
            --    info.ot_max_noncrit_if_hit1 = info.max_noncrit_if_hit1;
            --    info.ot_min_crit_if_hit1 = info.min_crit_if_hit1;
            --    info.ot_max_crit_if_hit1 = info.max_crit_if_hit1;
            --    info.ot_ticks = 1;
            --    info.ot_dur = 1;
            --    info.ot_tick_time = 1;
            --    stats.ignore_cant_crit = true;

            --    stats.ot_coef = stats.coef;
            --    stats.coef = 0;
            --    info.min_noncrit_if_hit1 = 0;
            --    info.max_noncrit_if_hit1 = 0;
            --    info.min_crit_if_hit1 = 0;
            --    info.max_crit_if_hit1 = 0;

            --    calc_expectation(info, spell, stats, loadout);
            --end
        end,
        --[spids.chain_lightning] = function(spell, info, loadout)
        --    local jmp_num = 2;
        --    local jmp_red = 0.7;
        --    if loadout.runes[rune_ids.coherence] then
        --        jmp_red = jmp_red + 0.1;
        --        jmp_num = 3;
        --    end

        --    if loadout.num_set_pieces[set_tiers.pve_2_5_1] >= 3 then
        --        jmp_red = jmp_red + 0.05;
        --    end

        --    local jmp_sum = 0;
        --    for i = 1, jmp_num do
        --        local jmp_effect = 1;
        --        for j = 1, i do
        --            jmp_effect = jmp_effect * jmp_red;
        --        end
        --        jmp_sum = jmp_sum + jmp_effect;
        --    end
        --    add_expectation_direct_st(info, jmp_sum);
        --end,
        [spids.healing_wave] = function(spell, info, loadout)
            if loadout.num_set_pieces[set_tiers.pve_1] >= 8 or loadout.num_set_pieces[set_tiers.sod_final_pve_1_heal] >= 6 then
                add_expectation_direct_st(info, 0.4 + 0.4 * 0.4);
            end
        end,
        --[spids.healing_stream_totem] = function(spell, info, loadout, stats, effects)
        --    add_expectation_ot_st(info, 4);
        --end,
        --[spids.healing_rain] = function(spell, info, loadout, stats, effects)
        --    add_expectation_ot_st(info, 4);
        --end,
        --[spids.earth_shield] = function(spell, info, loadout)
        --    add_expectation_direct_st(info, 8);
        --end,
        [spids.flame_shock] = function(spell, info, loadout, stats, effects)
            if loadout.runes[rune_ids.burn] then
                add_expectation_ot_st(info, 4);
                add_expectation_direct_st(info, 4);
            end
        end,
        [spids.earth_shock] = function(spell, info, loadout, stats, effects)
            --if loadout.runes[rune_ids.rolling_thunder] and spell.base_id == spids.earth_shock then
            --    if not stats.secondary_ability_stats then
            --        stats.secondary_ability_stats = {};
            --        stats.secondary_ability_info = {};
            --    end

            --    local lightning_shield = spells[best_rank_by_lvl(spids.lightning_shield, loadout.lvl)];

            --    spell_info_from_stats(stats.secondary_ability_info,
            --        stats.secondary_ability_stats,
            --        lightning_shield,
            --        loadout,
            --        effects);

            --    local ls_stacks = 0;
            --    if loadout.dynamic_buffs["player"][lookups.lightning_shield] then
            --        ls_stacks = loadout.dynamic_buffs["player"][lookups.lightning_shield].count;
            --        ls_stacks = ls_stacks - 3;
            --    elseif config.loadout.force_apply_buffs and loadout.buffs[lookups.lightning_shield] then
            --        ls_stacks = 9 - 3;
            --    end
            --    if ls_stacks > 0 then
            --        info.num_direct_effects = info.num_direct_effects + 1;
            --        local i = info.num_direct_effects;
            --        info["direct_description" .. i] = string.format("Lightning Shield %dx", ls_stacks);
            --        info["direct_utilization" .. i] = 1.0;

            --        local ls_dmg = stats.secondary_ability_info.min_noncrit_if_hit1 * ls_stacks;

            --        info["min_noncrit_if_hit" .. i] = ls_dmg;
            --        info["max_noncrit_if_hit" .. i] = ls_dmg;
            --        info["min_crit_if_hit" .. i] = ls_dmg * stats.crit_mod;
            --        info["max_crit_if_hit" .. i] = ls_dmg * stats.crit_mod;
            --        info["crit" .. i] = stats.secondary_ability_stats.crit;
            --    end
            --end
            --calc_expectation(info, spell, stats, loadout);
        end,
    };
elseif class == "PRIEST" then
    special_abilities = {
        --[spids.shadowguard] = function(spell, info, loadout)
        --    add_expectation_direct_st(info, 2);
        --end,
        --[spids.prayer_of_healing] = function(spell, info, loadout, stats, effects)
        --    add_expectation_direct_st(info, 4);
        --    add_expectation_ot_st(info, 4);
        --end,
        --[spids.circle_of_healing] = function(spell, info, loadout, stats, effects)
        --    add_expectation_direct_st(info, 4);
        --    add_expectation_ot_st(info, 4);
        --end,
        --[spids.prayer_of_mending] = function(spell, info, loadout, stats, effects)
        --    add_expectation_direct_st(info, 4);
        --end,
        --[spids.shadow_word_pain] = function(spell, info, loadout, stats, effects)
        --    if loadout.runes[rune_ids.shared_pain] then
        --        add_expectation_ot_st(info, 2);
        --    end
        --end,
        --[spids.holy_nova] = function(spell, info, loadout)
        --    if bit.band(spell.flags, spell_flags.heal) ~= 0 then
        --        add_expectation_direct_st(info, 4);
        --    end
        --end,
        [spids.lightwell] = function(spell, info, loadout)
            add_expectation_ot_st(info, 4);
        end,
        [spids.greater_heal] = function(spell, info, loadout, stats, effects)
            if loadout.num_set_pieces[set_tiers.pve_2] >= 8 then
                if not stats.secondary_ability_stats then
                    stats.secondary_ability_stats = {};
                    stats.secondary_ability_info = {};
                end
                spell_info_from_stats(stats.secondary_ability_info, stats.secondary_ability_stats, spells[6077], loadout,
                    effects);

                info.ot_min_noncrit_if_hit1 = stats.secondary_ability_info.ot_min_noncrit_if_hit1;
                info.ot_max_noncrit_if_hit1 = stats.secondary_ability_info.ot_max_noncrit_if_hit1;
                info.ot_min_crit_if_hit1 = stats.secondary_ability_info.ot_min_crit_if_hit1;
                info.ot_max_crit_if_hit1 = stats.secondary_ability_info.ot_max_crit_if_hit1;
                info.ot_ticks = stats.secondary_ability_info.ot_ticks;
                info.ot_dur = stats.secondary_ability_info.ot_dur;
                info.ot_tick_time = stats.secondary_ability_info.ot_tick_time;
                info.expected_ot = stats.secondary_ability_info.expected_ot;

                stats.ot_coef = stats.secondary_ability_stats.ot_coef;
            end

            calc_expectation(info, spell, stats, loadout);
        end,
        [spids.renew] = function(spell, info, loadout, stats, effects)
            if loadout.runes[rune_ids.empowered_renew] then
                local direct = info.ot_min_noncrit_if_hit1 / info.ot_ticks1;

                info.min_noncrit_if_hit1 = direct;
                info.max_noncrit_if_hit1 = direct;
                info.min_crit_if_hit1 = direct * stats.crit_mod;
                info.max_crit_if_hit1 = direct * stats.crit_mod;

                calc_expectation(info, spell, stats, loadout);
            end
        end,
        [spids.binding_heal] = function(spell, info, loadout, stats, effects)
            add_expectation_direct_st(info, 1);
        end,
        [spids.penance] = function(spell, info, loadout, stats, effects)

            if is_buff_up(loadout, "player", lookups.rapid_healing, true) and
                bit.band(swc.core.client_deviation, swc.core.client_deviation_flags.sod) ~= 0 then

                add_expectation_ot_st(info, 2);
            end
        end
    };
elseif class == "DRUID" then
    special_abilities = {
        --[spids.tranquility] = function(spell, info, loadout)
        --    add_expectation_ot_st(info, 4);
        --end,
        
        --[spids.swiftmend] = function(spell, info, loadout, stats, effects)
        --    if not stats.secondary_ability_stats then
        --        stats.secondary_ability_stats = {};
        --        stats.secondary_ability_info = {};
        --    end

        --    local num_ticks = 4;
        --    local hot_spell = spells[best_rank_by_lvl(spids.rejuvenation, loadout.lvl)];
        --    if not loadout.force_apply_buffs then
        --        local rejuv_buff = loadout.dynamic_buffs[loadout.friendly_towards][lookups.rejuvenation];
        --        local regrowth_buff = loadout.dynamic_buffs[loadout.friendly_towards][lookups.regrowth];
        --        -- TODO VANILLA: maybe swiftmend uses remaining ticks so could take that into account
        --        if regrowth_buff then
        --            if not rejuv_buff or regrowth_buff.dur < rejuv_buff.dur then
        --                hot_spell = spells[best_rank_by_lvl(spids.regrowth, loadout.lvl)];
        --            end
        --            num_ticks = 6;
        --        end
        --    end
        --    if not hot_spell then
        --        hot_spell = spells[774];
        --    end

        --    spell_info_from_stats(stats.secondary_ability_info,
        --        stats.secondary_ability_stats,
        --        hot_spell,
        --        loadout,
        --        effects);


        --    stats.coef = stats.ot_coef * num_ticks;
        --    stats.ot_coef = 0;

        --    local heal_amount = stats.secondary_ability_stats.spell_mod * num_ticks *
        --    stats.secondary_ability_info.ot_min_noncrit_if_hit1 / stats.secondary_ability_info.ot_ticks1;

        --    info.min_noncrit_if_hit1 = heal_amount;
        --    info.max_noncrit_if_hit1 = heal_amount;

        --    info.min_crit_if_hit1 = stats.crit_mod * heal_amount;
        --    info.max_crit_if_hit1 = stats.crit_mod * heal_amount;
        --    print("doing swiftmend hot", heal_amount);

        --    if loadout.runes[rune_ids.efflorescence] then
        --        spell_info_from_stats(stats.secondary_ability_info,
        --            stats.secondary_ability_stats,
        --            spells[417149],
        --            loadout,
        --            effects);

        --        info.ot_min_noncrit_if_hit1 = stats.secondary_ability_info.ot_min_noncrit_if_hit1;
        --        info.ot_max_noncrit_if_hit1 = stats.secondary_ability_info.ot_max_noncrit_if_hit1;

        --        info.ot_min_crit_if_hit1 = stats.secondary_ability_info.ot_min_crit_if_hit1;
        --        info.ot_max_crit_if_hit1 = stats.secondary_ability_info.ot_max_crit_if_hit1;
        --        stats.crit_ot = stats.secondary_ability_stats.crit_ot;

        --        info.ot_dur = stats.secondary_ability_info.ot_dur;
        --        info.ot_tick_time = stats.secondary_ability_info.ot_tick_time;
        --        info.ot_ticks = stats.secondary_ability_info.ot_ticks;
        --    end

        --    calc_expectation(info, spell, stats, loadout);
        --    add_expectation_ot_st(info, 4);
        --end,
        --[spids.wild_growth] = function(spell, info, loadout)
        --    add_expectation_ot_st(info, 4);
        --end,
        --[spids.efflorescence] = function(spell, info, loadout)
        --    add_expectation_ot_st(info, 4);
        --end,
    };
elseif class == "WARLOCK" then
    special_abilities = {
        [spids.shadow_cleave] = function(spell, info, loadout, stats, effects)
            add_expectation_direct_st(info, 9);
        end,
        [spids.shadow_bolt] = function(spell, info, loadout)
            if loadout.runes[rune_ids.shadow_bolt_volley] then
                add_expectation_direct_st(info, 4);
            end
        end,
    };
elseif class == "PALADIN" then
    special_abilities = {
        --[spids.avengers_shield] = function(spell, info, loadout)
        --    add_expectation_direct_st(info, 2);
        --end,
    };
elseif class == "MAGE" then
    special_abilities = {
        --[spids.mass_regeneration] = function(spell, info, loadout)
        --    add_expectation_ot_st(info, 4);
        --end,
        [spids.mana_shield] = function(spell, info, loadout, stats)
            local pts = loadout.talents_table:pts(1, 10);
            local drain_mod = 0.1 * pts;
            if loadout.runes[rune_ids.advanced_warding] then
                drain_mod = drain_mod + 0.5;
            end
            stats.cost = stats.cost + 2 * info.absorb * (1.0 - drain_mod);
        end,
        --[spids.temporal_anomaly] = function(spell, info, loadout)
        --    add_expectation_ot_st(info, 4);
        --end,
    };
else
    special_abilities = {};
end


local function evaluate_spell(spell, stats, loadout, effects, eval_flags)
    local spell_effect = {};
    local spell_effect_extra_1sp = {};
    local spell_effect_extra_1crit = {};
    local spell_effect_extra_1hit = {};
    local spell_effect_extra_1pen = {};
    local spell_effect_extra_1int = {};
    local spell_effect_extra_1spirit = {};
    local spell_effect_extra_1mp5 = {};

    spell_info(spell_effect, spell, stats, loadout, effects, eval_flags);
    cast_until_oom(spell_effect, stats, loadout, effects, true);

    local effects_diffed = deep_table_copy(effects);
    local diff = effects_zero_diff();
    local spell_stats_diffed = {};

    diff.sp = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed, eval_flags);
    spell_info(spell_effect_extra_1sp, spell, spell_stats_diffed, loadout, effects_diffed, eval_flags);
    cast_until_oom(spell_effect_extra_1sp, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.sp = 0;

    diff.crit_rating = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed, eval_flags);
    spell_info(spell_effect_extra_1crit, spell, spell_stats_diffed, loadout, effects_diffed, eval_flags);
    cast_until_oom(spell_effect_extra_1crit, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.crit_rating = 0;

    diff.hit_rating = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed, eval_flags);
    spell_info(spell_effect_extra_1hit, spell, spell_stats_diffed, loadout, effects_diffed, eval_flags);
    cast_until_oom(spell_effect_extra_1hit, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.hit_rating = 0;

    diff.spell_pen = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed, eval_flags);
    spell_info(spell_effect_extra_1pen, spell, spell_stats_diffed, loadout, effects_diffed, eval_flags);
    cast_until_oom(spell_effect_extra_1pen, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.spell_pen = 0;

    diff.stats[stat.int] = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed, eval_flags);
    spell_info(spell_effect_extra_1int, spell, spell_stats_diffed, loadout, effects_diffed, eval_flags);
    cast_until_oom(spell_effect_extra_1int, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.stats[stat.int] = 0;

    diff.stats[stat.spirit] = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed, eval_flags);
    spell_info(spell_effect_extra_1spirit, spell, spell_stats_diffed, loadout, effects_diffed, eval_flags);
    cast_until_oom(spell_effect_extra_1spirit, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.stats[stat.spirit] = 0;

    diff.mp5 = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed, eval_flags);
    spell_info(spell_effect_extra_1mp5, spell, spell_stats_diffed, loadout, effects_diffed, eval_flags);
    cast_until_oom(spell_effect_extra_1mp5, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.mp5 = 0;

    -- infinite cast
    local spell_effect_per_sec_1sp_delta = spell_effect_extra_1sp.effect_per_sec - spell_effect.effect_per_sec;

    local spell_effect_per_sec_1crit_delta = spell_effect_extra_1crit.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1hit_delta = spell_effect_extra_1hit.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1pen_delta = spell_effect_extra_1pen.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1int_delta = spell_effect_extra_1int.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1spirit_delta = spell_effect_extra_1spirit.effect_per_sec - spell_effect.effect_per_sec;

    -- cast until oom
    local spell_effect_until_oom_1sp_delta = spell_effect_extra_1sp.effect_until_oom - spell_effect.effect_until_oom;

    local spell_effect_until_oom_1crit_delta = spell_effect_extra_1crit.effect_until_oom - spell_effect.effect_until_oom;
    local spell_effect_until_oom_1hit_delta = spell_effect_extra_1hit.effect_until_oom - spell_effect.effect_until_oom;
    local spell_effect_until_oom_1pen_delta = spell_effect_extra_1pen.effect_until_oom - spell_effect.effect_until_oom;
    local spell_effect_until_oom_1int_delta = spell_effect_extra_1int.effect_until_oom - spell_effect.effect_until_oom;
    local spell_effect_until_oom_1spirit_delta = spell_effect_extra_1spirit.effect_until_oom - spell_effect.effect_until_oom;
    local spell_effect_until_oom_1mp5_delta = spell_effect_extra_1mp5.effect_until_oom - spell_effect.effect_until_oom;

    local result = {
        spell = spell_effect,
    };
    if bit.band(spell.flags, spell_flags.resource_regen) == 0 then
        result.infinite_cast = {
            effect_per_sec_per_sp = spell_effect_per_sec_1sp_delta,

            sp_per_crit           = spell_effect_per_sec_1crit_delta / (spell_effect_per_sec_1sp_delta),
            sp_per_hit            = spell_effect_per_sec_1hit_delta / (spell_effect_per_sec_1sp_delta),
            sp_per_pen            = spell_effect_per_sec_1pen_delta / (spell_effect_per_sec_1sp_delta),
            sp_per_int            = spell_effect_per_sec_1int_delta / (spell_effect_per_sec_1sp_delta),
            sp_per_spirit         = spell_effect_per_sec_1spirit_delta / (spell_effect_per_sec_1sp_delta),
        };
    end
    result.cast_until_oom = {
        effect_until_oom_per_sp = spell_effect_until_oom_1sp_delta,

        sp_per_crit             = spell_effect_until_oom_1crit_delta / (spell_effect_until_oom_1sp_delta),
        sp_per_hit              = spell_effect_until_oom_1hit_delta / (spell_effect_until_oom_1sp_delta),
        sp_per_pen              = spell_effect_until_oom_1pen_delta / (spell_effect_until_oom_1sp_delta),
        sp_per_int              = spell_effect_until_oom_1int_delta / (spell_effect_until_oom_1sp_delta),
        sp_per_spirit           = spell_effect_until_oom_1spirit_delta / (spell_effect_until_oom_1sp_delta),
        sp_per_mp5              = spell_effect_until_oom_1mp5_delta / (spell_effect_until_oom_1sp_delta),
    };

    return result;
end

local function spell_diff(spell_normal, spell_diffed, sim_type)
    if sim_type == simulation_type.spam_cast then
        return {
            diff_ratio = 100 * (spell_diffed.effect_per_sec / spell_normal.effect_per_sec - 1),
            first = spell_diffed.effect_per_sec - spell_normal.effect_per_sec,
            second = spell_diffed.expectation - spell_normal.expectation
        };
    elseif sim_type == simulation_type.cast_until_oom then
        return {
            diff_ratio = 100 * (spell_diffed.effect_until_oom / spell_normal.effect_until_oom - 1),
            first = spell_diffed.effect_until_oom - spell_normal.effect_until_oom,
            second = spell_diffed.time_until_oom - spell_normal.time_until_oom
        };
    end
end

calc.simulation_type          = simulation_type;
calc.evaluation_flags         = evaluation_flags;
calc.stats_for_spell          = stats_for_spell;
calc.spell_info               = spell_info;
calc.cast_until_oom           = cast_until_oom;
calc.evaluate_spell           = evaluate_spell;
calc.get_combat_rating_effect = get_combat_rating_effect;
calc.spell_diff               = spell_diff;

swc.calc                      = calc;
