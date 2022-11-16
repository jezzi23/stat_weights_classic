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


local addonName, addonTable = ...;

local class                             = addonTable.class;
local race                              = addonTable.race;
local faction                           = addonTable.faction;
local ensure_exists_and_add             = addonTable.ensure_exists_and_add;
local ensure_exists_and_mul             = addonTable.ensure_exists_and_mul;
local deep_table_copy                   = addonTable.deep_table_copy;
local stat                              = addonTable.stat;

local spells                            = addonTable.spells;
local spell_name_to_id                  = addonTable.spell_name_to_id;
local spell_names_to_id                 = addonTable.spell_names_to_id;
local magic_school                      = addonTable.magic_school;
local spell_flags                       = addonTable.spell_flags;

local buff_filters                      = addonTable.buff_filters;
local buff_category                     = addonTable.buff_category;
local filter_flags_active               = addonTable.filter_flags_active;
local buffs                             = addonTable.buffs;
local target_buffs                      = addonTable.target_buffs;
local detect_buffs                      = addonTable.detect_buffs;
local apply_buffs                       = addonTable.apply_buffs;
local non_stackable_effects             = addonTable.non_stackable_effects;

local set_tiers                         = addonTable.set_tiers;
local detect_sets                       = addonTable.detect_sets;
local apply_equipment                   = addonTable.apply_equipment;

local glyphs                            = addonTable.glyphs;
local wowhead_talent_link               = addonTable.wowhead_talent_link;
local wowhead_talent_code_from_url      = addonTable.wowhead_talent_code_from_url;
local wowhead_talent_code               = addonTable.wowhead_talent_code;
local talent_glyphs_table               = addonTable.talent_glyphs_table;
local apply_talents_glyphs              = addonTable.apply_talents_glyphs;

-------------------------------------------------------------------------
local sw_addon_name = "Stat Weights Classic";
local version =  "3.0.0";

local sw_addon_loaded = false;

local libstub_data_broker = LibStub("LibDataBroker-1.1", true)
local libstub_icon = libstub_data_broker and LibStub("LibDBIcon-1.0", true)

local font = "GameFontHighlightSmall";
local icon_overlay_font = "Interface\\AddOns\\StatWeightsClassic\\fonts\\Oswald-Bold.ttf";

local action_bar_addon_name = nil;
local spell_book_addon_name = nil;

sw_snapshot_loadout_update_freq = 1;
sw_num_icon_overlay_fields_active = 0;
local snapshot_time_since_last_update = 0;
local sequence_counter = 0;
local talents_update_needed = true;
local equipment_update_needed = true;

local function class_supported()
    return class == "MAGE" or class == "PRIEST" or class == "WARLOCK" or
       class == "SHAMAN" or class == "DRUID" or class == "PALADIN";
end
local class_is_supported = class_supported();


local stat_ids_in_ui = {
    int = 1,
    spirit = 2,
    mana = 3,
    mp5 = 4,
    sp = 5,
    spell_crit = 6,
    spell_hit = 7,
    spell_haste = 8,
    target_spell_res_decrease = 9
};

local icon_stat_display = {
    normal              = bit.lshift(1,1),
    crit                = bit.lshift(1,2),
    expected            = bit.lshift(1,3),
    effect_per_sec      = bit.lshift(1,4),
    effect_per_cost     = bit.lshift(1,5),
    avg_cost            = bit.lshift(1,6),
    avg_cast            = bit.lshift(1,7),
    hit                 = bit.lshift(1,8),
    crit_chance         = bit.lshift(1,9),
    casts_until_oom     = bit.lshift(1,10),
    effect_until_oom    = bit.lshift(1,11),
    time_until_oom      = bit.lshift(1,12),

    show_heal_variant = bit.lshift(1,20)
};

local tooltip_stat_display = {
    normal              = bit.lshift(1,1),
    crit                = bit.lshift(1,2),
    ot                  = bit.lshift(1,3),
    ot_crit             = bit.lshift(1,4),
    expected            = bit.lshift(1,5),
    effect_per_sec      = bit.lshift(1,6),
    effect_per_cost     = bit.lshift(1,7),
    cost_per_sec        = bit.lshift(1,8),
    stat_weights        = bit.lshift(1,9),
    coef                = bit.lshift(1,10),
    avg_cost            = bit.lshift(1,11),
    avg_cast            = bit.lshift(1,12),
    cast_until_oom      = bit.lshift(1,13),
    cast_and_tap        = bit.lshift(1,14)
};

local simulation_type = {
    spam_cast           = 1,
    cast_until_oom      = 2
};

local function get_combat_rating_effect(rating_id, level)
    -- src: https://wowwiki-archive.fandom.com/wiki/Combat_rating_system#Combat_Ratings_formula
    -- base off level 60
    local rating_id_to_base = {
        [CR_HASTE_SPELL] = 10,
        [CR_CRIT_SPELL] = 14,
        [CR_HIT_SPELL] = 8
    };
    local rating_per_percentage = 0.0;
    if level >= 70 then
        rating_per_percentage = rating_id_to_base[rating_id] * (41/26) * math.pow(131/63, 0.1*(level-70));
    elseif level >= 60 then
        rating_per_percentage = rating_id_to_base[rating_id] * (82/(262 - 3*level));
    elseif level >= 10 then
        rating_per_percentage = rating_id_to_base[rating_id] * (level - 8)/52;
    elseif level >= 1 then
        rating_per_percentage = rating_id_to_base[rating_id] / 26;
    end

    return rating_per_percentage;
end

local function empty_loadout()

    return {
        name = "Empty";
        is_dynamic_loadout = true,
        talents_code = "",
        --talents_table = talent_glyphs_table(""),
        talents_table = {},
        always_assume_buffs = false,
        lvl = 1,
        target_lvl = 0,
        use_dynamic_target_lvl = true,
        has_target = false; 

        target_friendly = false,
        buffs = {},
        target_buffs = {},

        stats = {0, 0, 0, 0, 0},
        mana = 0,
        max_mana = 0,
        extra_mana = 0,

        haste_rating = 0.0,
        crit_rating = 0.0,
        hit_rating = 0.0,

        spell_dmg_by_school = {0, 0, 0, 0, 0, 0, 0},
        spell_crit_by_school = {0, 0, 0, 0, 0, 0, 0},
        hit = 0.0,
        spell_power = 0,

        num_set_pieces = {},
        dynamic_buffs = {},
    };
end

local function empty_effects(effects) 


    effects.by_school = {};
    effects.by_school.spell_dmg_hit = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.spell_dmg_mod = {0, 0, 0, 0, 0, 0, 0}; -- mul
    effects.by_school.spell_dmg_mod_add = {0, 0, 0, 0, 0, 0, 0}; --add
    effects.by_school.spell_crit = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.spell_crit_mod = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.target_spell_dmg_taken = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.target_res = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.target_mod_res= {0, 0, 0, 0, 0, 0, 0};

    effects.by_attribute =  {};
    effects.by_attribute.stat_mod = {0, 0, 0, 0, 0};

    effects.raw = {};

    effects.raw.spell_heal_mod = 0;
    effects.raw.spell_heal_mod_mul = 0;
    effects.raw.target_healing_taken = 0;
    effects.raw.mana_mod = 0;
    effects.raw.mp5 = 0;
    effects.raw.regen_while_casting = 0;
    effects.raw.spell_power = 0;

    effects.raw.ot_mod = 0;

    effects.raw.haste_mod = 0.0;
    effects.raw.cost_mod = 0;

    effects.raw.haste_rating = 0;
    effects.raw.crit_rating = 0;

    effects.raw.special_crit_mod = 0;
    effects.raw.non_stackable_effect_flags = 0;

    -- indexable by ability base id
    effects.ability = {};
    effects.ability.crit = {};
    effects.ability.crit_ot = {};
    effects.ability.effect_mod = {};
    effects.ability.cast_mod = {}; -- flat before mul
    effects.ability.cast_mod_mul = {}; -- after flat
    effects.ability.extra_ticks = {};
    effects.ability.cost_mod = {};
    effects.ability.crit_mod = {};
    effects.ability.hit = {};
    effects.ability.sp = {};
    effects.ability.flat_add = {};
    effects.ability.refund = {};
    effects.ability.coef_mod = {};
    effects.ability.coef_ot_mod = {};
    effects.ability.effect_ot_mod = {};
    effects.ability.vuln_mod = {};
    effects.ability.vuln_ot_mod = {};

    -- DELETE
    effects.raw.ignite = 0;
    effects.raw.spiritual_guidance = 0;
    effects.raw.lunar_guidance = 0;
    effects.raw.master_of_elements  = 0;
    effects.raw.improved_immolate = 0;
    effects.raw.improved_shadowbolt = 0;
end

local function zero_effects(effects)
    for k, v in pairs(effects.raw) do
        effects.raw[k] = 0.0;
    end
    for _, e in pairs(effects.ability) do
        for k, v in pairs(e) do
            if v == 0.0 then
                e[k] = nil;
            else
                e[k] = 0.0;
            end
        end
    end
    for _, e in pairs(effects.by_school) do
        for i = 1,7 do
            e[i] = 0.0;
        end
    end
    for i = 1,5 do
        effects.by_attribute.stat_mod[i] = 0.0;
    end
end

-- DELETE THIS
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
    negated.spell_power = -loadout.spell_power;

    for i = 1, 7 do
        negated.spell_crit_by_school[i] = -loadout.spell_crit_by_school[i];
    end

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
    for i = 1, 7 do
        negated.target_res_by_school[i] = -loadout.target_res_by_school[i];
    end

    negated.spell_heal_mod = -negated.spell_heal_mod;
    negated.target_healing_taken = -negated.target_healing_taken;

    negated.dmg_mod = -negated.dmg_mod;

    negated.haste_rating = -negated.haste_rating;
    negated.crit_rating = -negated.crit_rating;
    negated.hit_rating = -negated.hit_rating;

    negated.cost_mod = -negated.cost_mod;

    return negated;
end

-- deep copy to avoid reference entanglement
local function loadout_copy(loadout)
    return deep_table_copy(loadout);
end

local function effects_add(dst, src)
    for k, v in pairs(src.raw) do
        if dst.raw[k] then
            dst.raw[k] = dst.raw[k] + v;
        end
    end
    for k, v in pairs(src.ability) do
        if dst.ability[k] then
            for kk, vv in pairs(v) do
                if not dst.ability[k][kk] then
                   dst.ability[k][kk] = 0.0;
                end
                dst.ability[k][kk] = dst.ability[k][kk] + vv;
            end
        end
    end
    for k, v in pairs(src.by_school) do

        if dst.by_school[k] then
            for i = 1,7 do
                dst.by_school[k][i] = dst.by_school[k][i] + v[i];
            end
        end
    end
    for i = 1,5 do
        dst.by_attribute.stat_mod[i] = dst.by_attribute.stat_mod[i] + src.by_attribute.stat_mod[i];
    end
end

local function loadout_add(primary, diff, effects, effects_diff)

    --local added = loadout_copy(primary);

    for i = 1, 5 do
        primary.stats[i] = primary.stats[i] + diff.stats[i] * (1 + effects.by_attribute.stat_mod[i]);
    end
    -- TODO: outdated stuff here, mana and int crit formula need figuring out

    primary.mana = primary.mana + 
                 (diff.mana * (1 + effects.raw.mana_mod)) + 
                 (15*diff.stats[stat.int]*(1 + effects.by_attribute.stat_mod[stat.int]*effects.raw.mana_mod));

    local sp_gained_from_spirit = diff.stats[stat.spirit] * (1 + effects.by_attribute.stat_mod[stat.spirit]) * effects.raw.spiritual_guidance * 0.01;
    local sp_gained_from_int = diff.stats[stat.int] * (1 + effects.by_attribute.stat_mod[stat.int]) * effects.raw.lunar_guidance * 0.01;
    sp_gained_from_stat = sp_gained_from_spirit + sp_gained_from_int;
    for i = 1, 7 do
        primary.spell_dmg_by_school[i] = primary.spell_dmg_by_school[i] + diff.spell_dmg_by_school[i] + sp_gained_from_stat;
    end
    primary.spell_power = primary.spell_power + diff.spell_power + sp_gained_from_stat;

    -- introduce crit by intellect here
    crit_diff_normalized_to_primary = diff.stats[stat.int] * ((1 + effects.by_attribute.stat_mod[stat.int])/60)/100; -- assume diff has no stat mod
    for i = 1, 7 do
        primary.spell_crit_by_school[i] = primary.spell_crit_by_school[i] + diff.spell_crit_by_school[i] + 
            crit_diff_normalized_to_primary;
    end

    primary.haste_rating = primary.haste_rating + diff.haste_rating;
    primary.crit_rating = primary.crit_rating + diff.crit_rating;
    primary.hit_rating = primary.hit_rating + diff.hit_rating;

    return primary;
end

local active_loadout_base = nil;

local function remove_dynamic_stats_from_talents(loadout)

end

local function static_rescale_from_talents_diff(loadout, old_loadout, effects)
    -- TODO: refactor

    local old_int = old_loadout.stats[stat.int];
    local old_max_mana = old_loadout.mana;

    local int_mod = (1 + loadout.by_attribute.stat_mod[stat.int])/(1 + old_loadout.stat_mod[stat.int]);
    local mana_mod = (1 + loadout.mana_mod)/(1 + old_loadout.mana_mod);
    local new_int = int_mod * old_int
    local mana_gained_from_int =  (new_int - old_int)*15
    local crit_from_int_diff = (new_int - old_int)/6000;
    local new_max_mana = mana_mod * (old_max_mana + mana_gained_from_int);

    loadout.mana = new_max_mana;
    loadout.max_mana = new_max_mana;
    loadout.stats[stat.int] = new_int;
    for i = 2, 7 do
        loadout.spell_crit_by_school[i] = loadout.spell_crit_by_school[i] + crit_from_int_diff;
    end
end

local function print_loadout(loadout, effects)

    print("Stat Weights Classic - Version: "..version);
    for k, v in pairs(loadout) do
        print(k, v);
    end
    for k, v in pairs(effects.raw) do
        print(k, v);
    end
    local str = "spell_dmg_school : {";
    for i = 2,7 do
        str = str .. loadout.spell_dmg_by_school[i] .. ", "
    end
    str = str.."}";
    print(str);
    str = "spell_crit_school : {";
    for i = 2,7 do
        str = str .. loadout.spell_crit_by_school[i] .. ", "
    end
    str = str.."}";
    print(str);
    for w, e in pairs(effects.ability) do
        local str = w.. ": {";
        for k, v in pairs(e) do
            str = str..k..": "..v.." ";
        end
        str = str .."}";
        print(str);
    end
    for k, e in pairs(effects.by_school) do
        local str = k..": {";
        for i = 1,7 do
            str = str .. e[i].. ", ";
        end
        str = str .."}";
        print(str);
    end
    local str = "";
    for i = 1,5 do
        str = str .. effects.by_attribute.stat_mod[i] .. ", "
    end
    print(str);
end

local function default_loadout(loadout)

    loadout.name = "Default";
    loadout.is_dynamic_loadout = true;
end

--local function loadout_prepare_buffs(loadout)
--
--    for k, v in pairs(target_buffs) do
--        if loadout.target_buffs[buff_lname] then
--            loadout.target_buffs[buff_lname] = v;
--        end
--    end
--end

local function dynamic_loadout(loadout)

    loadout.lvl = UnitLevel("player");

    for i = 1, 5 do
        local _, stat, _, _ = UnitStat("player", i);

        loadout.stats[i] = stat;
    end

    loadout.mana = UnitPower("player", 0);
    loadout.max_mana = UnitPowerMax("player", 0);

    -- in wotlk, healing power will equate to spell power
    loadout.spell_power = GetSpellBonusHealing();
    for i = 1, 7 do
        loadout.spell_dmg_by_school[i] = GetSpellBonusDamage(i) - loadout.spell_power;
    end
    for i = 1, 7 do
        loadout.spell_crit_by_school[i] = GetSpellCritChance(i)*0.01;
    end

    -- crit and hit is already gathered indirectly from rating, but not haste
    loadout.haste_rating = GetCombatRating(CR_HASTE_SPELL);
    loadout.hit_rating = GetCombatRating(CR_HIT_SPELL);

    -- CARE: duplicate old code for forgotten reason
    loadout.player_name = UnitName("player"); 
    loadout.target_name = UnitName("target"); 
    loadout.mouseover_name = UnitName("mouseover"); 

    loadout.hostile_towards = nil; 
    loadout.friendly_towards = "player";

    loadout.has_target = false; 
    if UnitExists("target") then
        loadout.has_target = true; 
        loadout.hostile_towards = "target";
        loadout.friendly_towards = "target";

        loadout.target_friendly = UnitIsFriend("player", "target");

        if loadout.use_dynamic_target_lvl and not loadout.target_friendly then
            local target_lvl = UnitLevel("target");
            if target_lvl == -1 then
                loadout.target_lvl = loadout.lvl + 3;
            else
                loadout.target_lvl = target_lvl;
            end
        end
    else
        loadout.target_lvl = loadout.lvl + 3;
    end

    if UnitExists("mouseover") and UnitName("mouseover") ~= UnitName("target") then
        loadout.friendly_towards = "mouseover";
    end
    loadout.friendly_hp_perc = UnitHealth(loadout.friendly_towards)/UnitHealthMax(loadout.friendly_towards);
    loadout.player_hp_perc = UnitHealth("player")/UnitHealthMax("player")
    if loadout.hostile_towards == "target" and not loadout.target_friendly then
        loadout.enemy_hp_perc = UnitHealth("target")/UnitHealthMax("target");
    end

    remove_dynamic_stats_from_talents(loadout);

    detect_buffs(loadout);
    detect_sets(loadout);
end

local function static_loadout_from_dynamic(loadout)
    
   dynamic_loadout(loadout);

   loadout.mana = loadout.max_mana;
   loadout.talents_code = wowhead_talent_code();
   loadout.extra_mana = loadout.extra_mana;
   loadout.is_dynamic_loadout = false;
   --TODO:
   --remove_dynamic_stats_from_talents(loadout);
end

local function begin_tooltip_section(tooltip)
    tooltip:AddLine(" ");
    --tooltip:AddLine("Stat Weights", 1.0, 153.0/255, 102.0/255);
end
local function end_tooltip_section(tooltip)
    tooltip:Show();
end

-- TODO: this is probably still in use along with more scaling punishments
local function level_scaling(lvl)
    return math.min(1, 1 - (20 - lvl)* 0.0375);
end

local function spell_hit(lvl, lvl_target, hit)

    base_hit = 0;
    local lvl_diff = lvl_target - lvl;
    if lvl_diff >= 3 then
        base_hit = 0.83;
    else
        base_hit = 0.96 - 0.01 * (lvl_diff);
    end

    return math.max(0.01, math.min(1.0, base_hit + hit));
end

local function target_avg_magical_res(self_lvl, target_res)
    return math.min(0.75, 0.75 * (target_res/(self_lvl * 5)))
end

local function base_mana_pool()

    local intellect = UnitStat("player", 4);
    local base_mana = UnitPowerMax("player", 0) - (min(20, intellect) + 15*(intellect - min(20, intellect)));

    return base_mana;
end

local lvl_to_base_regen = {
    [1 ] = 0.034965,
    [2 ] = 0.034191,
    [3 ] = 0.033465,
    [4 ] = 0.032526,
    [5 ] = 0.031661,
    [6 ] = 0.031076,
    [7 ] = 0.030523,
    [8 ] = 0.029994,
    [9 ] = 0.029307,
    [10] = 0.028661,
    [11] = 0.027584,
    [12] = 0.026215,
    [13] = 0.025381,
    [14] = 0.024300,
    [15] = 0.023345,
    [16] = 0.022748,
    [17] = 0.021958,
    [18] = 0.021386,
    [19] = 0.020790,
    [20] = 0.020121,
    [21] = 0.019733,
    [22] = 0.019155,
    [23] = 0.018819,
    [24] = 0.018316,
    [25] = 0.017936,
    [26] = 0.017576,
    [27] = 0.017201,
    [28] = 0.016919,
    [29] = 0.016581,
    [30] = 0.016233,
    [31] = 0.015994,
    [32] = 0.015707,
    [33] = 0.015464,
    [34] = 0.015204,
    [35] = 0.014956,
    [36] = 0.014744,
    [37] = 0.014495,
    [38] = 0.014302,
    [39] = 0.014094,
    [40] = 0.013895,
    [41] = 0.013724,
    [42] = 0.013522,
    [43] = 0.013363,
    [44] = 0.013175,
    [45] = 0.012996,
    [46] = 0.012853,
    [47] = 0.012687,
    [48] = 0.012539,
    [49] = 0.012384,
    [50] = 0.012233,
    [51] = 0.012113,
    [52] = 0.011973,
    [53] = 0.011859,
    [54] = 0.011714,
    [55] = 0.011575,
    [56] = 0.011473,
    [57] = 0.011342,
    [58] = 0.011245,
    [59] = 0.011110,
    [60] = 0.010999,
    [61] = 0.010700,
    [62] = 0.010522,
    [63] = 0.010290,
    [64] = 0.010119,
    [65] = 0.009968,
    [66] = 0.009808,
    [67] = 0.009651,
    [68] = 0.009553,
    [69] = 0.009445,
    [70] = 0.009327,
    [71] = 0.008859,
    [72] = 0.008415,
    [73] = 0.007993,
    [74] = 0.007592,
    [75] = 0.007211,
    [76] = 0.006849,
    [77] = 0.006506,
    [78] = 0.006179,
    [79] = 0.005869,
    [80] = 0.005575,
};

local function mana_regen_per_5(int, spirit, level)
    local base_regen = lvl_to_base_regen[level];
    if not base_regen then
        base_regen = lvl_to_base_regen[80];
    end
    local mana_regen = math.ceil(5 * (0.001 * math.sqrt(int) * spirit * lvl_to_base_regen[level]) * 0.6);
    return mana_regen;
end

local special_abilities = nil;
if class == "SHAMAN" then
    special_abilities = {
        [spell_name_to_id["Chain Heal"]] = function(spell, info, loadout)
            info.expectation = (1 + 0.6 + 0.6*0.6) * info.expectation_st;
        end,
        [spell_name_to_id["Earth Shield"]] = function(spell, info, loadout)
            info.expectation = 6 * info.expectation_st;
        end,
        [spell_name_to_id["Lightning Shield"]] = function(spell, info, loadout)
            info.expectation = 3 * info.expectation_st;
        end,
        [spell_name_to_id["Chain Lightning"]] = function(spell, info, loadout)
            -- TODO glyph
            info.expectation = (1 + 0.7 + 0.7*0.7) * info.expectation_st;

            local pts = loadout.talents_table:pts(1, 20);
            -- lightning overload
            info.expectation = info.expectation * (1.0 + 0.5 * pts * 0.11);
        end,
        [spell_name_to_id["Lightning Bolt"]] = function(spell, info, loadout)
            local pts = loadout.talents_table:pts(1, 20);
            -- lightning overload
            info.expectation = info.expectation * (1.0 + 0.5 * pts * 0.11);
        end
    };
elseif class == "PRIEST" then
    special_abilities = {
        [spell_name_to_id["Prayer of Healing"]] = function(spell, info, loadout)

            if loadout.glyphs[57195] then
                info.expectation_st = info.expectation_st * 1.2;
                -- hot displayed specialized in tooltip section
            end
            info.expectation = 5 * info.expectation_st;
        end,
        [spell_name_to_id["Circle of Healing"]] = function(spell, info, loadout)

            if loadout.glyphs[55675] then
                info.expectation = 6 * info.expectation_st;
            else
                info.expectation = 5 * info.expectation_st;
            end
        end,
        [spell_name_to_id["Prayer of Mending"]] = function(spell, info, loadout)
            if loadout.num_set_pieces[set_tiers.pve_t7_1] and
                loadout.num_set_pieces[set_tiers.pve_t7_1] >= 2 then
                info.expectation = 6 * info.expectation_st;
            else
                info.expectation = 5 * info.expectation_st;
            end
        end,
        [spell_name_to_id["Power Word: Shield"]] = function(spell, info, loadout)

           info.absorb = info.min_noncrit_if_hit;

            if loadout.glyphs[55672] then
                info.min_noncrit_if_hit = 0.2 * info.min_noncrit_if_hit;
                info.max_noncrit_if_hit = 0.2 * info.max_noncrit_if_hit;

                info.min_crit_if_hit = 0.2 * info.min_crit_if_hit;
                info.max_crit_if_hit = 0.2 * info.max_crit_if_hit;
                info.expectation_st = info.expectation_st * 1.2;
                info.expectation = info.expectation_st;
            else

                info.min_noncrit_if_hit = 0.0;
                info.max_noncrit_if_hit = 0.0;

                info.min_crit_if_hit = 0.0;
                info.max_crit_if_hit = 0.0;
            end
        end,
        [spell_name_to_id["Holy Nova"]] = function(spell, info, loadout)
            if bit.band(spell.flags, spell_flags.heal) ~= 0 then
                info.expectation = 5 * info.expectation_st;
            end
        end,
        [spell_name_to_id["Binding Heal"]] = function(spell, info, loadout)
            info.expectation = 2 * info.expectation_st;
        end,
        [spell_name_to_id["Penance"]] = function(spell, info, loadout)
            info.expectation = 3 * info.expectation_st;
        end,
        [spell_name_to_id["Lightwell"]] = function(spell, info, loadout)
            info.expectation = 10 * info.expectation_st;
        end,
        [spell_name_to_id["Divine Hymn"]] = function(spell, info, loadout)

            info.expectation = 3 * info.expectation_st;
        end,
    };
elseif class == "DRUID" then
    special_abilities = {
        [spell_name_to_id["Wild Growth"]] = function(spell, info, loadout)
            info.expectation = 5 * info.expectation_st;
        end,
        [spell_name_to_id["Tranquility"]] = function(spell, info, loadout)
            info.expectation = 5 * info.expectation_st;
        end,
        [spell_name_to_id["Starfall"]] = function(spell, info, loadout)
            info.expectation = 20 * info.expectation_st;
        end,
    };
elseif class == "WARLOCK" then
    special_abilities = {
        [spell_name_to_id["Shadow Cleave"]] = function(spell, info, loadout)
            info.expectation = 3 * info.expectation_st;
        end,
    };
else
    special_abilities = {};
end

local function spell_info(info, spell, stats, loadout, effects)

    local base_min = spell.base_min;
    local base_max = spell.base_max;
    local base_ot_tick = spell.over_time;
    local base_ot_tick_max = spell.over_time;
    if bit.band(spell.flags, spell_flags.over_time_range) ~= 0 then
        --
        base_ot_tick_max = spell.over_time_max;
    end

    -- level scaling
    -- TODO: unclear how "exactly" spell scaling by lvl works
    local lvl_diff_applicable = 0;
    if spell.lvl_scaling > 0 then
        -- spell data is at spell base lvl
        lvl_diff_applicable = math.max(0,
            math.min(loadout.lvl - spell.lvl_req, spell.lvl_max - spell.lvl_req));
    end
    if base_min > 0.0 then
        base_min = math.ceil(base_min + spell.lvl_scaling * lvl_diff_applicable);
        base_max = math.ceil(base_max + spell.lvl_scaling * lvl_diff_applicable);
    end
    if bit.band(spell.flags, spell_flags.over_time_lvl_scaling) ~= 0 then
        base_ot_tick = math.ceil(base_ot_tick + spell.lvl_scaling * lvl_diff_applicable);
        base_ot_tick_max = math.ceil(base_ot_tick_max + spell.lvl_scaling * lvl_diff_applicable);
    end

    local ot_freq = spell.over_time_tick_freq;
    local ot_dur = spell.over_time_duration;

    if spell.cast_time == spell.over_time_duration then
        ot_freq = spell.over_time_tick_freq*(stats.cast_time/spell.over_time_duration);
        ot_dur = stats.cast_time;
    end

    -- certain ticks may tick faster
    --local shadow_form = localize_spell_name("Shadowform");
    if class == "PRIEST" then
        local shadow_form, _, _, _, _, _, _ = GetSpellInfo(15473);
        if (loadout.buffs[shadow_form] and loadout.always_assume_buffs) or
            (loadout.dynamic_buffs["player"][shadow_form] and not loadout.always_assume_buffs) then -- warlock stuff
            if spell.base_id == spell_name_to_id["Devouring Plague"] or spell.base_id == spell_name_to_id["Vampiric Touch"] then
                -- but locks?
                ot_freq  = spell.over_time_tick_freq/stats.haste_mod;
                ot_dur = ot_dur/stats.haste_mod;
            end
        end
    elseif class == "WARLOCK" then 
        local immolate, _, _, _, _, _, _ = GetSpellInfo(348);
        if (loadout.target_buffs[immolate] and loadout.always_assume_buffs) or
            (loadout.dynamic_buffs["target"][immolate] and not loadout.always_assume_buffs) then
            if spell.base_id == spell_name_to_id["Incinerate"] then
                base_min = base_min + math.floor((base_min-0.001) * 0.25);
                base_max = base_max + math.floor(base_max * 0.25);
            end
        end
    end

    info.min_noncrit_if_hit = 
        (base_min + stats.spell_power * stats.coef + stats.flat_addition) * stats.spell_mod;
    info.max_noncrit_if_hit = 
        (base_max + stats.spell_power * stats.coef + stats.flat_addition) * stats.spell_mod;

    info.min_crit_if_hit = info.min_noncrit_if_hit * stats.crit_mod;
    info.max_crit_if_hit = info.max_noncrit_if_hit * stats.crit_mod;

    -- TODO: Looks like min is ceiled and max is floored
    --       do this until we know any better!

    --min_noncrit_if_hit = math.ceil(min_noncrit_if_hit);
    --max_noncrit_if_hit = math.ceil(max_noncrit_if_hit);

    --min_crit_if_hit = math.ceil(min_crit_if_hit);
    --max_crit_if_hit = math.ceil(max_crit_if_hit);
    
    local direct_crit = stats.crit;

    if bit.band(spell_flags.absorb, spell.flags) ~= 0 then
        direct_crit = 0.0;
    end

    info.min = stats.hit * ((1 - direct_crit) * info.min_noncrit_if_hit + (direct_crit * info.min_crit_if_hit));
    info.max = stats.hit * ((1 - direct_crit) * info.max_noncrit_if_hit + (direct_crit * info.max_crit_if_hit));

    info.absorb = 0.0;

    info.ot_if_hit = 0.0;
    info.ot_if_hit_max = 0.0;
    info.ot_if_crit = 0;
    info.ot_if_crit_max = 0;
    info.ot_ticks = 0;
    if base_ot_tick > 0 then

        local base_ot_num_ticks = (ot_dur/ot_freq);
        local ot_coef_per_tick = stats.ot_coef
        --#local base_ot_tick = base_ot / base_ot_num_ticks;
        --#local base_ot_tick_max = base_ot_max / base_ot_num_ticks;

        info.ot_ticks = base_ot_num_ticks + stats.ot_extra_ticks;

        info.ot_if_hit = (base_ot_tick + ot_coef_per_tick * stats.spell_power) * info.ot_ticks * stats.spell_ot_mod;
        info.ot_if_hit_max = (base_ot_tick_max + ot_coef_per_tick * stats.spell_power) * info.ot_ticks * stats.spell_ot_mod;

        if stats.ot_crit > 0 then
            info.ot_if_crit = info.ot_if_hit * stats.crit_mod;
            info.ot_if_crit_max = info.ot_if_hit_max * stats.crit_mod;
        else
            info.ot_if_crit = 0;
            info.ot_if_crit_max = 0;
        end
    end
    local expected_ot_if_hit = (1.0 - stats.ot_crit) * 0.5 * (info.ot_if_hit + info.ot_if_hit_max) + stats.ot_crit * 0.5 * (info.ot_if_crit + info.ot_if_crit_max);
    info.expected_ot = stats.hit * expected_ot_if_hit;
    -- soul drain, life drain, mind flay are all directed casts that can only miss on the channel itself
    -- 1.5 sec gcd is always implied which is the only penalty for misses
    if bit.band(spell.flags, spell_flags.channel_missable) ~= 0 then

        local channel_ratio_time_lost_to_miss = 1 - (ot_dur - 1.5/stats.haste_mod)/ot_dur;
        info.expected_ot = expected_ot_if_hit - (1 - stats.hit) * channel_ratio_time_lost_to_miss * expected_ot_if_hit;
    end

    if class == "PRIEST" then
        local pts = 0;
        if spell.base_id == spell_name_to_id["Renew"] then
            pts = loadout.talents_table:pts(2, 23);
        elseif spell.base_id == spell_name_to_id["Devouring Plague"] then
            pts = 2 * loadout.talents_table:pts(3, 18);
        end

        if pts ~= 0 then
            local direct = pts * 0.05 * info.ot_if_hit

            info.min_noncrit_if_hit = direct;
            info.max_noncrit_if_hit = direct;

            -- crit mod does not benefit from spec here it seems
            local crit_mod = max(1.5, 1.5 + effects.raw.special_crit_mod);
            info.min_crit_if_hit = direct * crit_mod;
            info.max_crit_if_hit = direct * crit_mod;

            info.min = stats.hit * ((1 - stats.crit) * info.min_noncrit_if_hit + (stats.crit * info.min_crit_if_hit));
            info.max = stats.hit * ((1 - stats.crit) * info.max_noncrit_if_hit + (stats.crit * info.max_crit_if_hit));
        end
    end

    info.expectation_direct = (info.min + info.max) / 2;

    info.expectation = info.expectation_direct + info.expected_ot;

    info.expectation = info.expectation * (1 - stats.target_avg_resi);

    info.expectation_st = info.expectation;

    if special_abilities[spell.base_id] then
        special_abilities[spell.base_id](spell, info, loadout);
    end

    if loadout.beacon then
        info.expectation = inof.expectation * 2;
    end

    info.effect_per_sec = info.expectation/stats.cast_time;

    info.effect_per_cost = info.expectation/stats.cost;
    info.cost_per_sec = stats.cost/stats.cast_time;
    info.ot_duration = ot_dur + stats.ot_extra_ticks * ot_freq;

end

local function stats_for_spell(stats, spell, loadout, effects)

    stats.crit = loadout.spell_crit_by_school[spell.school] +
        effects.by_school.spell_crit[spell.school];
    stats.ot_crit = 0.0;
    if effects.ability.crit[spell.base_id] then
        stats.crit = stats.crit + effects.ability.crit[spell.base_id];
    end
    -- rating may come from diffed loadout
    local crit_rating_per_perc = get_combat_rating_effect(CR_CRIT_SPELL, loadout.lvl);
    local crit_from_rating = 0.01 * (loadout.crit_rating + effects.raw.crit_rating)/crit_rating_per_perc;
    stats.crit = math.max(0.0, math.min(1.0, stats.crit + crit_from_rating));

    if bit.band(spell.flags, spell_flags.over_time_crit) ~= 0 then
        if effects.ability.crit_ot[spell.base_id] then
            stats.ot_crit = stats.crit + effects.ability.crit_ot[spell.base_id];
        else
            stats.ot_crit = stats.crit;
        end
    end

    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
        -- avoiding issue with skyfury 3% crit dmg gem
        stats.crit_mod = 1.5;
    else
        stats.crit_mod = 1.5 + effects.by_school.spell_crit_mod[spell.school];
        if effects.ability.crit_mod[spell.base_id] then
            stats.crit_mod = stats.crit_mod + effects.ability.crit_mod[spell.base_id];
        end
        stats.crit_mod = stats.crit_mod + ((stats.crit_mod-1.5)*2 + 1.0)*effects.raw.special_crit_mod;
    end

    local target_vuln_mod = 1.0;
    local target_vuln_ot_mod = 1.0;

    if effects.ability.vuln_mod[spell.base_id] then
        target_vuln_mod = target_vuln_mod + effects.ability.vuln_mod[spell.base_id];
    end
    if effects.ability.vuln_ot_mod[spell.base_id] then
        target_vuln_ot_mod = target_vuln_mod + effects.ability.vuln_ot_mod[spell.base_id];
    end
    local global_mod = 1.0;
    stats.spell_mod = 1.0;
    stats.spell_ot_mod = 1.0;
    stats.flat_addition = 0;
    local resource_refund = 0;

    if not effects.ability.effect_mod[spell.base_id] then
        effects.ability.effect_mod[spell.base_id] = 0.0;
    end
    if not effects.ability.effect_ot_mod[spell.base_id] then
        effects.ability.effect_ot_mod[spell.base_id] = 0.0;
    end

    ---- regarding blessing of light effect
    --if effects.ability.flat_add[spell.base_id] and class == "PALADIN" then

    --    local scaling_coef_by_lvl = 1;
    --    if spell.lvl_req == 1 then -- rank 1 holy light
    --        scaling_coef_by_lvl = 0.2;
    --    elseif spell.lvl_req == 6 then -- rank 2 holy light
    --        scaling_coef_by_lvl = 0.4;
    --    elseif spell.lvl_req == 14 then -- rank 3 holy light
    --        scaling_coef_by_lvl = 0.7;
    --    end
    --    
    --    stats.flat_addition = 
    --        stats.flat_addition + effects.ability.flat_add[spell.base_id] * scaling_coef_by_lvl;
    --end

    stats.gcd = 1.0;

    stats.cost = spell.cost_base_percent * base_mana_pool();
    local cost_mod = 1 - effects.raw.cost_mod;

    if effects.ability.cost_mod[spell.base_id] then
        cost_mod = cost_mod - effects.ability.cost_mod[spell.base_id]
    end

    local cast_mod_mul = 0.0;

    if class == "PRIEST" then
        if spell.base_id == spell_name_to_id["Flash Heal"] and loadout.friendly_hp_perc and loadout.friendly_hp_perc < 0.5  then
            local pts = loadout.talents_table:pts(1, 20);
            stats.crit = stats.crit + pts * 0.04;
        end
        -- test of faith
        if loadout.friendly_hp_perc and loadout.friendly_hp_perc < 0.5 then
            effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + 0.04 * loadout.talents_table:pts(2, 25);
        end
        if spell.base_id == spell_name_to_id["Shadow Word: Death"] and loadout.enemy_hp_perc and loadout.enemy_hp_perc < 0.35 then
            target_vuln_mod = target_vuln_mod + 0.1;
        end
        --shadow form
        local shadow_form, _, _, _, _, _, _ = GetSpellInfo(15473);
        if (loadout.buffs[shadow_form] and loadout.always_assume_buffs) or
            (loadout.dynamic_buffs["player"][shadow_form] and not loadout.always_assume_buffs) then
            if spell.base_min == 0.0 and stats.ot_crit == 0.0  and bit.band(spell.flags, spell_flags.heal) == 0 then
                -- must be shadow word pain, devouring plague or vampiric touch
                stats.ot_crit = stats.crit;
                stats.crit_mod = stats.crit_mod + 0.5;
            end
        end
        -- glyph of renew
        if spell.base_id == spell_name_to_id["Renew"] and loadout.glyphs[55674] then
            global_mod = global_mod * 1.25;
        end

        if bit.band(spell_flags.heal, spell.flags) ~= 0 and spell.base_min ~= 0 then
            -- divine aegis
            local pts = loadout.talents_table:pts(1, 24);
            stats.crit_mod = stats.crit_mod * (1 + 0.1 * pts);
        end

    elseif class == "DRUID" then

        local pts = loadout.talents_table:pts(3, 25);
        if pts ~= 0 then
            stats.gcd = stats.gcd - pts * 0.02;
        end

        --moonkin form
        local moonkin_form, _, _, _, _, _, _ = GetSpellInfo(24858);
        if (loadout.buffs[moonkin_form] and loadout.always_assume_buffs) or
            (loadout.dynamic_buffs["player"][moonkin_form] and not loadout.always_assume_buffs) then
            resource_refund = stats.crit * 0.02 * loadout.max_mana;
        end

        -- never mind ...this tick resource refund is only on target,... could apply if targeting self?
        --local pts = loadout.talents_table:pts(3, 22);
        --if (spell.base_id == spell_name_to_id["Wild Growth") or spell.base_id == localized_spell_name("Rejuvenation")]
        --    and pts ~= 0 and bit.band(spell.flags, spell_flags.heal) ~= 0 then

        --    local refund_amount = 0.15 * loadout.max_mana * 0.01 * ot_ticks;
        --    if spell.base_id == spell_name_to_id["Wild Growth"] then
        --        refund_amount = refund_amount * 5;
        --    end
        --    cost = cost - refund_amount;
        --end
        --
        --improved insect swarm talent

        local insect_swarm = spell_name_to_id["Insect Swarm"];
        if (loadout.target_buffs[insect_swarm] and loadout.always_assume_buffs) or
            (loadout.dynamic_buffs["target"][insect_swarm] and not loadout.always_assume_buffs) then
            -- TODO: is this correct? 
            if spell.base_id == spell_name_to_id["Wrath"] then
                global_mod = global_mod + 0.01 * loadout.talents_table:pts(1, 14);
                --target_vuln_mod = target_vuln_mod * (1.0 + 0.01 * loadout.talents_table:pts(1, 14));
                --796
            end
        end

        if bit.band(spell_flags.heal, spell.flags) ~= 0 and spell.base_min ~= 0 then
            -- living seed
            local pts = loadout.talents_table:pts(3, 21);
            stats.crit_mod = stats.crit_mod * (1 + 0.1 * pts);
        end
        
    elseif class == "PALADIN" and bit.band(spell.flags, spell_flags.heal) ~= 0 then
        -- illumination
        local pts = loadout.talents_table:pts(1, 7);
        if pts ~= 0 then

            local mana_refund = 0.3 * spell.cost_base_percent * base_mana_pool();
            resource_refund = stats.crit * pts*0.2 * mana_refund;
        end

    elseif class == "SHAMAN" then
        -- shaman clearcast
        -- elemental focus
        local pts = loadout.talents_table:pts(1, 7);
        if pts ~= 0 and spell.base_min ~= 0 and bit.band(spell.flags, spell_flags.heal) == 0 then
            local not_crit = 1.0 - stats.crit;
            local probability_of_critting_at_least_once_in_two = 1.0 - not_crit*not_crit;
            cost_mod = cost_mod - 0.4*probability_of_critting_at_least_once_in_two;
            
        end

        -- improved water shield
        local pts = loadout.talents_table:pts(3, 6);
        if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.water_shield) ~= 0 and pts ~= 0 then
            local mana_proc_chance = 0.0;
            if spell.base_id == spell_name_to_id["Healing Wave"] or spell.base_id == spell_name_to_id["Riptide"] then
                mana_proc_chance = pts * 1.0/3;
            elseif spell.base_id == spell_name_to_id["Lesser Healing Wave"] then
                mana_proc_chance = 0.2*pts;
            elseif spell.base_id == spell_name_to_id["Chain Heal"] then
                local bounces = 3;
                mana_proc_chance = 0.1*pts*bounces;
            end
            local water_shield_proc_gain = 52;
            if loadout.lvl >= 76 then
                water_shield_proc_gain = 428;
            elseif loadout.lvl >= 69 then
                water_shield_proc_gain = 214;
            elseif loadout.lvl >= 62 then
                water_shield_proc_gain = 182;
            elseif loadout.lvl >= 55 then
                water_shield_proc_gain = 162;
            elseif loadout.lvl >= 48 then
                water_shield_proc_gain = 142;
            elseif loadout.lvl >= 41 then
                water_shield_proc_gain = 117;
            elseif loadout.lvl >= 34 then
                water_shield_proc_gain = 97;
            elseif loadout.lvl >= 28 then
                water_shield_proc_gain = 81;
            end
            resource_refund = stats.crit * mana_proc_chance * water_shield_proc_gain;
        end

        local pts = loadout.talents_table:pts(3, 22);
        if pts ~= 0 and
            (spell.base_id == spell_name_to_id["Healing Wave"] or
             spell.base_id == spell_name_to_id["Lesser Healing Wave"] or
             spell.base_id == spell_name_to_id["Riptide"]) then

            stats.crit_mod = stats.crit_mod * (1.0 + pts * 0.1);
        end
        
    elseif class == "MAGE" then

        -- clearcast
        local pts = loadout.talents_table:pts(1, 6);
        if pts ~= 0 then
            cost_mod = 1.0 - (1.0 - cost_mod)*(1.0 - 0.02 * pts);
        end

        local pts = loadout.talents_table:pts(2, 13);
        if pts ~= 0 then
            -- master of elements
            local mana_refund = pts * 0.1 * spell.cost_base_percent * base_mana_pool();
            resource_refund = stats.crit * mana_refund;
        end

        -- ignite
        local pts = loadout.talents_table:pts(2, 4);
        if pts ~= 0 and spell.school == magic_school.fire then
            stats.crit_mod = stats.crit_mod * (1.0 + pts * 0.08);
        end

        -- molten fury
        local pts = loadout.talents_table:pts(2, 21);
        if loadout.enemy_hp_perc and loadout.enemy_hp_perc < 0.35 then
            target_vuln_mod = target_vuln_mod + 0.06 * pts;
            target_vuln_ot_mod = target_vuln_ot_mod + 0.06 * pts;
        end

    elseif class == "WARLOCK" then
        if loadout.talents_table:pts(1, 10) ~= 0 and bit.band(spell.flags, spell_flags.curse) ~= 0 then
            stats.gcd = stats.gcd - 0.5;
        end

        -- death's embrace
        local pts = loadout.talents_table:pts(1, 24);
        if pts ~= 0 then
            if spell.base_id == spell_name_to_id["Drain Life"] and
                loadout.player_hp_perc and loadout.player_hp_perc < 0.2 then
                vuln_ot_mod = vuln_ot_mod + pts*0.1;
            end
            if spell.school == magic_school.shadow and loadout.enemy_hp_perc and loadout.enemy_hp_perc < 0.35 then
                target_vuln_mod = target_vuln_mod + pts * 0.04;
                target_vuln_ot_mod = target_vuln_ot_mod + pts * 0.04;
            end
        end
        -- pandemic
        if loadout.talents_table:pts(1, 26) ~= 0 and
            (spell.base_id == spell_name_to_id["Corruption"] or
             spell.base_id == spell_name_to_id["Unstable Affliction"]) then

            if effects.ability.crit_ot[spell.base_id] then
                stats.ot_crit = stats.crit + effects.ability.crit_ot[spell.base_id];
            else
                stats.ot_crit = stats.crit;
            end
        end
        -- decimation
        local pts = loadout.talents_table:pts(2, 22);
        if pts ~= 0 and spell.base_id == spell_name_to_id["Soul Fire"] and loadout.enemy_hp_perc and loadout.enemy_hp_perc < 0.35 then
            cast_mod_mul = (1.0 + cast_mod_mul) * (1.0 + 0.2 * pts) - 1.0;
        end
    end

    --if spell.base_id == spell_name_to_id["Healing Touch"] and loadout.num_set_pieces[set_tiers.pve_3] >= 8 then

    --    cost = cost - cost * crit * 0.3;
    --end


    --if loadout.master_of_elements ~= 0 and spell.base_min > 0 and
    --   (spell.school == magic_school.fire or spell.school == magic_school.frost) then

    --    cost = cost - cost * crit * (loadout.master_of_elements * 0.1);
    --end


    --TODO: wotlk haste, cast speed calculation is different
    -- so far it seems like gcd cap is 1.0 instead of 1.5?
    stats.cast_time = spell.cast_time;
    if effects.ability.cast_mod[spell.base_id] then
        stats.cast_time = stats.cast_time - effects.ability.cast_mod[spell.base_id];
    end
    if effects.ability.cast_mod_mul[spell.base_id] then
        stats.cast_time = stats.cast_time/(1.0 + effects.ability.cast_mod_mul[spell.base_id]);
    end
    stats.cast_time = stats.cast_time/(1.0 + cast_mod_mul);

    -- nature's grace
    -- TODO: revisit?
    local pts = loadout.talents_table:pts(1, 7);
    if class == "DRUID" and pts ~= 0 and spell.base_min ~= 0 then
        stats.cast_time = stats.cast_time/(1.0 + pts * 0.2*stats.crit/3);
    end

    --if loadout.natures_grace and loadout.natures_grace ~= 0  and cast_time > 1.5 and 
    --    spell.base_id ~= spell_name_to_id["Tranquility") and spell.base_id ~= localized_spell_name("Hurricane"] then
    --    local cast_reduction = 0.5;
    --    if cast_time - 1.5 < 0.5 then
    --        --cast_time is between ]1.5:2]
    --        -- partially account for natures grace as the cast is lower than 2 and natures grace doesnt ignore gcd
    --        cast_reduction = cast_time - 1.5; -- i.e. between [0:0.5]
    --    end
    --    cast_time = cast_time - cast_reduction * crit;
    --end

    -- apply global haste which has been multiplied at each step
    local haste_rating_per_perc = get_combat_rating_effect(CR_HASTE_SPELL, loadout.lvl);
    local haste_from_rating = 0.01 * max(0.0, loadout.haste_rating + effects.raw.haste_rating) / haste_rating_per_perc;

    stats.haste_mod = (1.0 + effects.raw.haste_mod) * (1.0 + haste_from_rating);

    stats.cast_time = math.max(stats.cast_time/stats.haste_mod, stats.gcd);


    -- delete this?
    --if spell.base_id == spell_name_to_id["Shadow Bolt"] and 
    --    bit.band(target_debuffs1.improved_shadow_bolt.flag, loadout.target_debuffs1) ~= 0 and 
    --    ((not loadout.target_friendly and loadout.has_target and loadout.target_debuffs[target_debuffs1.improved_shadow_bolt.id]) or 
    --    loadout.always_assume_buffs) then


    --    -- undo for shadow bolt in order to get real average stat weights for crit, which increases buff uptime
    --    loadout.target_spell_dmg_taken[magic_school.shadow] = 
    --        loadout.target_spell_dmg_taken[magic_school.shadow] - 0.2;
    --end
    -- multiplicitive vs additive can become an error here 
    if bit.band(spell.flags, spell_flags.heal) ~= 0 then

        target_vuln_mod = target_vuln_mod * (1.0 + effects.raw.target_healing_taken);
        target_vuln_ot_mod = target_vuln_ot_mod * (1.0 + effects.raw.target_healing_taken);

        stats.spell_mod = target_vuln_mod * global_mod *
            (1.0 + effects.raw.spell_heal_mod_mul)
            *
            (1.0 + effects.ability.effect_mod[spell.base_id] + effects.raw.spell_heal_mod);
        stats.spell_ot_mod = target_vuln_ot_mod * global_mod *
            (1.0 + effects.raw.spell_heal_mod_mul)
            *
            (1.0 + effects.ability.effect_mod[spell.base_id] + effects.ability.effect_ot_mod[spell.base_id]+ effects.raw.spell_heal_mod + effects.raw.ot_mod);

    elseif bit.band(spell.flags, spell_flags.absorb) ~= 0 then

        -- TODO: looks like healing % from talents is added with twin disciples talent
        -- then multiplied by effect mod...

        stats.spell_mod = target_vuln_mod * global_mod *
            ((1.0 + effects.ability.effect_mod[spell.base_id]) * (1.0 + effects.raw.spell_heal_mod));
    else 
        target_vuln_mod = target_vuln_mod * (1.0 + effects.by_school.target_spell_dmg_taken[spell.school]);
        target_vuln_ot_mod = target_vuln_ot_mod * (1.0 + effects.by_school.target_spell_dmg_taken[spell.school]);

        stats.spell_mod = target_vuln_mod * global_mod
            *
            (1 + effects.by_school.spell_dmg_mod[spell.school])
            *
            (1.0 + effects.ability.effect_mod[spell.base_id] + effects.by_school.spell_dmg_mod_add[spell.school]);

        stats.spell_ot_mod = target_vuln_ot_mod * global_mod
            *
            (1 + effects.by_school.spell_dmg_mod[spell.school])
            *
            (1.0 + effects.ability.effect_mod[spell.base_id] + effects.ability.effect_ot_mod[spell.base_id] + effects.by_school.spell_dmg_mod_add[spell.school] + effects.raw.ot_mod);
    end

    stats.extra_hit = effects.by_school.spell_dmg_hit[spell.school];
    if effects.ability.hit[spell.base_id] then
        stats.extra_hit = stats.extra_hit + effects.ability.hit[spell.base_id];
    end

    local hit_rating_per_perc = get_combat_rating_effect(CR_HIT_SPELL, loadout.lvl);
    local hit_from_rating = 0.01 * loadout.hit_rating/hit_rating_per_perc
    stats.extra_hit = stats.extra_hit + hit_from_rating;

    stats.hit = spell_hit(loadout.lvl, loadout.target_lvl, stats.extra_hit);
    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
        stats.hit = 1.0;
    else
        stats.hit = math.min(1.0, stats.hit);
    end

    stats.ot_extra_ticks = effects.ability.extra_ticks[spell.base_id];
    if not stats.ot_extra_ticks then
       stats.ot_extra_ticks = 0.0;
    end

    if bit.band(spell.flags, spell_flags.heal) ~= 0 or bit.band(spell.flags, spell_flags.absorb) ~= 0 then
        stats.spell_power = loadout.spell_power;
    else
        stats.spell_power = loadout.spell_power + loadout.spell_dmg_by_school[spell.school];
    end
    stats.spell_power = stats.spell_power + effects.raw.spell_power;

    -- redundant in wotlk?
    if effects.ability.sp[spell.base_id] then
        stats.spell_power = stats.spell_power + effects.ability.sp[spell.base_id];
    end

    stats.target_resi = 0;
    if bit.band(spell.flags, spell_flags.heal) == 0 then
        -- mod res by school currently used to snapshot equipment and set bonuses
        stats.target_resi = math.max(0, effects.by_school.target_res[spell.school] + effects.by_school.target_mod_res[spell.school]);
    end

    stats.target_avg_resi = target_avg_magical_res(loadout.lvl, stats.target_resi);

    stats.cost = stats.cost * cost_mod;
    stats.cost = stats.cost - resource_refund;

    if effects.ability.refund[spell.base_id] and effects.ability.refund[spell.base_id] ~= 0 then

        local refund = effects.ability.refund[spell.base_id];
        local max_rank = spell.rank;
        if spell.base_id == spell_name_to_id["Lesser Healing Wave"] then
            max_rank = 6;
        elseif spell.base_id == spell_name_to_id["Healing Touch"] then
            max_rank = 11;
        end

        coef_estimate = spell.rank/max_rank;

        stats.cost = stats.cost - refund*coef_estimate;
    end

    -- cost rounding?
    stats.cost = tonumber(string.format("%.0f", stats.cost));

    local lvl_scaling = level_scaling(loadout.lvl);
    stats.coef = spell.coef * lvl_scaling;
    stats.ot_coef = spell.over_time_coef *lvl_scaling;

    if effects.ability.coef_mod[spell.base_id] then
        stats.coef = stats.coef + effects.ability.coef_mod[spell.base_id];
    end
    if effects.ability.coef_ot_mod[spell.base_id] then
        stats.ot_coef = stats.ot_coef * (1.0 + effects.ability.coef_ot_mod[spell.base_id]);
    end

    stats.cost_per_sec = stats.cost / stats.cast_time;
end

local function spell_info_from_stats(spell_info, stats, spell, loadout, effects)

    stats_for_spell(stats, spell, loadout, effects);
    spell_info(spell_info, spell, stats, loadout, effects);
end

local function evaluate_spell(spell, stats, loadout, effects)

    local spell_effect = {};
    local spell_effect_extra_1sp = {};
    local spell_effect_extra_1crit = {};
    local spell_effect_extra_1hit = {};
    local spell_effect_extra_1haste = {};

    spell_info(spell_effect, spell, stats, loadout, effects);

    -- careful of reusing stats for each diff if stats is used further

    local spell_power_prev = stats.spell_power;
    stats.spell_power = stats.spell_power + 1;
    spell_info(spell_effect_extra_1sp, spell, stats, loadout, effects);
    stats.spell_power = spell_power_prev;

    local crit_prev = stats.crit;  
    local ot_crit_prev = stats.ot_crit; 

    local crit_rating_per_perc = get_combat_rating_effect(CR_CRIT_SPELL, loadout.lvl);
    if stats.crit ~= 0.0 then
        stats.crit = math.min(1.0, stats.crit + 0.01/crit_rating_per_perc);
    end
    if stats.ot_crit ~= 0.0 then
        stats.ot_crit = math.min(1.0, stats.ot_crit + 0.01/crit_rating_per_perc);
    end
    spell_info(spell_effect_extra_1crit, spell, stats, loadout, effects);
    stats.crit = crit_prev;
    stats.ot_crit = ot_crit_prev;

    local hit_prev = stats.hit;
    local hit_rating_per_perc = get_combat_rating_effect(CR_HIT_SPELL, loadout.lvl);
    if bit.band(spell.flags, spell_flags.heal) == 0 and bit.band(spell.flags, spell_flags.absorb) == 0 then
        stats.hit = math.min(1.0, stats.hit + 0.01/hit_rating_per_perc);
    end
    spell_info(spell_effect_extra_1hit, spell, stats, loadout, effects);
    stats.hit = hit_prev;

    local cast_time_prev = stats.cast_time;
    local haste_rating_per_perc = get_combat_rating_effect(CR_HASTE_SPELL, loadout.lvl);
    local haste_from_rating = 0.01 * math.max(0.0, loadout.haste_rating) / haste_rating_per_perc;
    local cast_time_wo_haste = cast_time_prev * (1.0 + haste_from_rating);
    stats.cast_time = math.max(cast_time_wo_haste/(1.0 + haste_from_rating + 0.01/haste_rating_per_perc), stats.gcd);

    spell_info(spell_effect_extra_1haste, spell, stats, loadout, effects);
    stats.cast_time = cast_time_prev;

    local spell_effect_per_sec_1sp_delta = spell_effect_extra_1sp.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1crit_delta = spell_effect_extra_1crit.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1hit_delta = spell_effect_extra_1hit.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1haste_delta = spell_effect_extra_1haste.effect_per_sec - spell_effect.effect_per_sec;

    local sp_per_crit = spell_effect_per_sec_1crit_delta/(spell_effect_per_sec_1sp_delta);
    local sp_per_hit = spell_effect_per_sec_1hit_delta/(spell_effect_per_sec_1sp_delta);
    local sp_per_haste = spell_effect_per_sec_1haste_delta/(spell_effect_per_sec_1sp_delta);

    return {
        effect_per_sec_per_sp = spell_effect_per_sec_1sp_delta,
        sp_per_crit = sp_per_crit,
        sp_per_hit = sp_per_hit,
        sp_per_haste = sp_per_haste,

        spell = spell_effect,
        spell_1_sp = spell_effect_extra_1sp,
        spell_1_crit = spell_effect_extra_1crit,
        spell_1_hit = spell_effect_extra_1hit,
        spell_1_haste = spell_effect_extra_1haste,
    };
end

local function cast_until_oom_sim(spell_effect, stats, loadout, effects)

    local num_casts = 0;
    local effect = 0;

    local mana = loadout.mana + loadout.extra_mana;

    -- src: https://wowwiki-archive.fandom.com/wiki/Spirit
    local mp1_not_casting = 0.2 * mana_regen_per_5(loadout.stats[stat.int], loadout.stats[stat.spirit], loadout.lvl);
    local mp1_casting = 0.2 * (0.05 * base_mana_pool() + effects.raw.mp5) + mp1_not_casting * effects.raw.regen_while_casting;

    local resource_loss_per_sec = stats.cost/stats.cast_time - mp1_casting;

    if resource_loss_per_sec <= 0 then
        -- divide by 0 party!
        spell_effect.num_casts_until_oom = 1/0;
        spell_effect.effect_until_oom = 1/0;
        spell_effect.time_until_oom = 1/0;
        spell_effect.mp1 = mp1_casting;
    else
        spell_effect.time_until_oom = mana/resource_loss_per_sec;
        spell_effect.num_casts_until_oom = spell_effect.time_until_oom/stats.cast_time;
        spell_effect.effect_until_oom = spell_effect.num_casts_until_oom * spell_effect.expectation;
        spell_effect.mp1 = mp1_casting;
    end
end

local function cast_until_oom_sim_default(spell_effect, stats, loadout, effects)

    cast_until_oom_sim(spell_effect, stats, loadout, effects);
end

local function cast_until_oom_stat_weights(
        spell, stats,
        spell_effect_normal, spell_effect_1_sp, spell_effect_1_crit, spell_effect_1_hit, spell_effect_1_haste, loadout, effects)

    -- TODO: stats must be tied to effect
    cast_until_oom_sim(spell_effect_normal, stats, loadout, effects);
    cast_until_oom_sim(spell_effect_1_sp, stats, loadout, effects);
    cast_until_oom_sim(spell_effect_1_crit, stats, loadout, effects);
    cast_until_oom_sim(spell_effect_1_hit, stats, loadout, effects);
    cast_until_oom_sim(spell_effect_1_haste, stats, loadout, effects);

    local loadout_1_mp5 = empty_loadout();
    --loadout_1_mp5.mp5  = loadout_1_mp5.mp5 + 1;
    local loadout_added_1_mp5 = loadout_add(loadout, loadout_1_mp5, effects);
    local stats_1_mp5_added = {};
    stats_for_spell(stats_1_mp5_added, spell, loadout_added_1_mp5, effects);
    local spell_effect_1_mp5 = {};
    spell_info(spell_effect_1_mp5, spell, stats_1_mp5_added, loadout_added_1_mp5, effects);
    cast_until_oom_sim(spell_effect_1_mp5, stats, loadout_added_1_mp5, effects);

    local loadout_1_spirit = empty_loadout();
    loadout_1_spirit.stats[stat.spirit] = 1;
    local loadout_added_1_spirit = loadout_add(loadout, loadout_1_spirit, effects);
    local stats_1_spirit_added = {};
    stats_for_spell(stats_1_spirit_added, spell, loadout_added_1_spirit, effects);
    local added_1_spirit_effect = {};
    spell_info(added_1_spirit_effect, spell, stats_1_spirit_added, loadout_added_1_spirit, effects);
    cast_until_oom_sim(added_1_spirit_effect, stats_1_spirit_added, loadout_added_1_spirit, effects);

    local loadout_1_int = empty_loadout();
    loadout_1_int.stats[stat.int] = 1;
    local loadout_added_1_int = loadout_add(loadout, loadout_1_int, effects);
    local stats_1_int_added = {};
    stats_for_spell(stats_1_int_added, spell, loadout_added_1_int, effects);
    local added_1_int_effect = {};
    spell_info(added_1_int_effect, spell, stats_1_int_added, loadout_added_1_int, effects);
    cast_until_oom_sim(added_1_int_effect, stats_1_int_added, loadout_added_1_int, effects);

    local diff_1_sp = spell_effect_1_sp.effect_until_oom - spell_effect_normal.effect_until_oom;
    local diff_1_crit = spell_effect_1_crit.effect_until_oom - spell_effect_normal.effect_until_oom;
    local diff_1_hit = spell_effect_1_hit.effect_until_oom - spell_effect_normal.effect_until_oom;
    local diff_1_haste = spell_effect_1_haste.effect_until_oom - spell_effect_normal.effect_until_oom;
    local diff_1_mp5 = spell_effect_1_mp5.effect_until_oom - spell_effect_normal.effect_until_oom;
    local diff_1_spirit = added_1_spirit_effect.effect_until_oom - spell_effect_normal.effect_until_oom;
    local diff_1_int = added_1_int_effect.effect_until_oom - spell_effect_normal.effect_until_oom;

    local sp_per_crit = diff_1_crit/diff_1_sp;
    local sp_per_hit = diff_1_hit/diff_1_sp;
    local sp_per_haste = diff_1_haste/diff_1_sp;
    local sp_per_mp5 = diff_1_mp5/diff_1_sp;
    local sp_per_spirit = diff_1_spirit/diff_1_sp;
    local sp_per_int = diff_1_int/diff_1_sp;

    return {
        effect_per_1_sp = diff_1_sp,

        sp_per_crit = sp_per_crit,
        sp_per_hit = sp_per_hit,
        sp_per_haste = sp_per_haste,
        sp_per_mp5 = sp_per_mp5,
        sp_per_spirit = sp_per_spirit,
        sp_per_int = sp_per_int,

        normal = spell_effect_normal,
    };
end

local spell_cache = {};    

local function sort_stat_weights(stat_weights, num_weights) 
    
    for i = 1, num_weights do
        local j = i;
        while j ~= 1 and stat_weights[j].weight > stat_weights[j-1].weight do
            local tmp = stat_weights[j];
            stat_weights[j] = stat_weights[j-1];
            stat_weights[j-1] = tmp;
            j = j - 1;
        end
    end
end

local function tooltip_spell_info(tooltip, spell, loadout, effects)

    if sw_frame.settings_frame.tooltip_num_checked == 0 or 
        (sw_frame.settings_frame.show_tooltip_only_when_shift and not IsShiftKeyDown()) then
        return;
    end

    local stats = {};
    stats_for_spell(stats, spell, loadout, effects); 
    local eval = evaluate_spell(spell, stats, loadout, effects);

    local cast_til_oom = cast_until_oom_stat_weights(
      spell, stats,
      eval.spell, eval.spell_1_sp, eval.spell_1_crit, eval.spell_1_hit, eval.spell_1_haste, 
      loadout, effects
    );

    local effect = "";
    local effect_per_sec = "";
    local effect_per_cost = "";
    local effect_per_sec_per_sp = "";
    local sp_name = "";

    -- TODO: might want to separate dps and dmg per execution time for clarity
    if bit.band(spell.flags, spell_flags.heal) ~= 0 or bit.band(spell.flags, spell_flags.absorb) ~= 0 then
        effect = "Heal";
        effect_per_sec = "HPS (by execution time)";
        effect_per_cost = "Heal per Mana";
        cost_per_sec = "Mana per sec";
        effect_per_sec_per_sp = "HPS per spell power";
        sp_name = "Spell power";
    else
        effect = "Damage";
        effect_per_sec = "DPS (by execution time)";
        effect_per_cost = "Damage per Mana";
        cost_per_sec = "Mana per sec";
        effect_per_sec_per_sp = "DPS per spell power";
        sp_name = "Spell power";
    end

    begin_tooltip_section(tooltip);

    tooltip:AddLine("Stat Weights Classic", 1, 1, 1);

    if loadout.lvl > spell.lvl_outdated and not __sw__debug__ then
        tooltip:AddLine("Ability downranking is not optimal in WOTLK! A new rank is available at your level.", 252.0/255, 69.0/255, 3.0/255);
        end_tooltip_section(tooltip);
        return;
    end 

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
    if eval.spell.min_noncrit_if_hit + eval.spell.absorb ~= 0 then
        if sw_frame.settings_frame.tooltip_normal_effect:GetChecked() then
            if eval.spell.min_noncrit_if_hit ~= eval.spell.max_noncrit_if_hit then
                -- dmg spells with real direct range
                if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                    
                    tooltip:AddLine(string.format("%s (%.1f%% hit): %d-%d", 
                                                   effect, 
                                                   stats.hit*100,
                                                   math.floor(eval.spell.min_noncrit_if_hit), 
                                                   math.ceil(eval.spell.max_noncrit_if_hit)),
                                     232.0/255, 225.0/255, 32.0/255);
                    
                -- heal spells with real direct range
                else
                    tooltip:AddLine(string.format("%s: %d-%d", 
                                                  effect, 
                                                  math.floor(eval.spell.min_noncrit_if_hit), 
                                                  math.ceil(eval.spell.max_noncrit_if_hit)),
                                    232.0/255, 225.0/255, 32.0/255);

                    if spell.base_id == spell_name_to_id["Prayer of Healing"] and loadout.glyphs[57195] then
                        tooltip:AddLine(string.format("        and %d-%d over %d sec (%d-%d for %d ticks)", 
                                                      math.floor(0.2*eval.spell.min_noncrit_if_hit),
                                                      math.ceil(0.2*eval.spell.max_noncrit_if_hit),
                                                      6,
                                                      math.floor(0.2*eval.spell.min_noncrit_if_hit/6),
                                                      math.ceil(0.2*eval.spell.max_noncrit_if_hit/6),
                                                      6),
                                        232.0/255, 225.0/255, 32.0/255);
                    end
                end
            else
                if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                    tooltip:AddLine(string.format("%s (%.1f%% hit): %d", 
                                                  effect,
                                                  stats.hit*100,
                                                  math.floor(eval.spell.min_noncrit_if_hit)),
                                                  --string.format("%.0f", eval.spell.min_noncrit_if_hit)),
                                    232.0/255, 225.0/255, 32.0/255);
                else
                    if eval.spell.absorb ~= 0 then
                        tooltip:AddLine(string.format("Absorb: %d", 
                                                      math.floor(eval.spell.absorb)),
                                        232.0/255, 225.0/255, 32.0/255);
                    end
                    if eval.spell.min_noncrit_if_hit ~= 0 then
                        tooltip:AddLine(string.format("%s: %d", 
                                                      effect,
                                                      math.floor(eval.spell.min_noncrit_if_hit)),
                                                      --string.format("%.0f", eval.spell.min_noncrit_if_hit)),
                                        232.0/255, 225.0/255, 32.0/255);
                    end
                end

            end
        end
        if sw_frame.settings_frame.tooltip_crit_effect:GetChecked() then
            if stats.crit ~= 0 then
                --if effects.raw.ignite ~= 0 and eval.spell.ignite_min > 0 then
                --    local ignite_min = effects.ignite * 0.08 * eval.spell.min_crit_if_hit;
                --    local ignite_max = effects.ignite * 0.08 * eval.spell.max_crit_if_hit;
                --    tooltip:AddLine(string.format("Critical (%.2f%%): %d-%d (ignites for %d-%d)", 
                --                                  stats.crit*100, 
                --                                  math.floor(eval.spell.min_crit_if_hit), 
                --                                  math.ceil(eval.spell.max_crit_if_hit),
                --                                  math.floor(ignite_min), 
                --                                  math.ceil(ignite_max)),
                --                   252.0/255, 69.0/255, 3.0/255);


                -- divine aegis
                -- elseif
                local effect_type_str = nil;
                local pts = 0;
                if class == "PRIEST" then
                    pts = loadout.talents_table:pts(1, 24);
                    if pts ~= 0 then
                        effect_type_str = "absorbs";
                    end
                elseif class == "DRUID"   then
                    pts = loadout.talents_table:pts(3, 21);
                    if pts ~= 0 then
                        effect_type_str = "seeds";
                    end
                elseif class == "SHAMAN" then
                    pts = loadout.talents_table:pts(3, 22);
                    if pts ~= 0 and
                        (spell.base_id == spell_name_to_id["Healing Wave"] or
                         spell.base_id == spell_name_to_id["Lesser Healing Wave"] or
                         spell.base_id == spell_name_to_id["Riptide"]) then

                        effect_type_str = "awakens";
                    end
                end
                if effect_type_str and bit.band(spell_flags.heal, spell.flags) ~= 0 and eval.spell.min_crit_if_hit ~= 0 then
                    local min_crit_if_hit = eval.spell.min_crit_if_hit/(1 + pts * 0.1);
                    local max_crit_if_hit = eval.spell.max_crit_if_hit/(1 + pts * 0.1);
                    local effect_min = pts * 0.1 * min_crit_if_hit;
                    local effect_max = pts * 0.1 * max_crit_if_hit;
                    if eval.spell.min_crit_if_hit ~= eval.spell.max_crit_if_hit then
                        tooltip:AddLine(string.format("Critical (%.2f%% crit): %d-%d (+ %s %d-%d)", 
                                                      stats.crit*100, 
                                                      math.floor(min_crit_if_hit), 
                                                      math.ceil(max_crit_if_hit),
                                                      effect_type_str,
                                                      math.floor(effect_min), 
                                                      math.ceil(effect_max)),
                                       252.0/255, 69.0/255, 3.0/255);
                    else
                        tooltip:AddLine(string.format("Critical (%.2f%% crit): %d (+ %s %d)", 
                                                      stats.crit*100, 
                                                      math.floor(min_crit_if_hit), 
                                                      effect_type_str,
                                                      math.floor(effect_min)),
                                       252.0/255, 69.0/255, 3.0/255);

                    end

                    if spell.base_id == spell_name_to_id["Prayer of Healing"] and loadout.glyphs[57195] then
                        tooltip:AddLine(string.format("        and %d-%d over %d sec (%d-%d for %d ticks)", 
                                                      math.floor(0.2*min_crit_if_hit), 
                                                      math.ceil(0.2*max_crit_if_hit),
                                                      6,
                                                      math.floor(0.2*min_crit_if_hit/6), 
                                                      math.ceil(0.2*max_crit_if_hit/6),
                                                      6),
                                       252.0/255, 69.0/255, 3.0/255);
                    end
                    
                -- ignite
                elseif class == "MAGE" and spell.school == magic_school.fire and loadout.talents_table:pts(2, 4) ~= 0 then
                    local pts =loadout.talents_table:pts(2, 4) 
                    local min_crit_if_hit = eval.spell.min_crit_if_hit/(1 + pts * 0.08);
                    local max_crit_if_hit = eval.spell.max_crit_if_hit/(1 + pts * 0.08);
                    local ignite_min = pts * 0.08 * min_crit_if_hit;
                    local ignite_max = pts * 0.08 * max_crit_if_hit;
                    tooltip:AddLine(string.format("Critical (%.2f%% crit): %d-%d (+ ignites %d-%d)", 
                                                  stats.crit*100, 
                                                  math.floor(min_crit_if_hit), 
                                                  math.ceil(max_crit_if_hit),
                                                  math.floor(ignite_min), 
                                                  math.ceil(ignite_max)),
                                   252.0/255, 69.0/255, 3.0/255);

                elseif eval.spell.min_crit_if_hit ~= eval.spell.max_crit_if_hit then
                    tooltip:AddLine(string.format("Critical (%.2f%% crit): %d-%d", 
                                                  stats.crit*100, 
                                                  math.floor(eval.spell.min_crit_if_hit), 
                                                  math.ceil(eval.spell.max_crit_if_hit)),
                                   252.0/255, 69.0/255, 3.0/255);
                else 
                    tooltip:AddLine(string.format("Critical (%.2f%% crit): %d", 
                                                  stats.crit*100, 
                                                  math.floor(eval.spell.min_crit_if_hit)),
                                   252.0/255, 69.0/255, 3.0/255);
                end

            end
        end
    end


    if eval.spell.ot_if_hit ~= 0 and sw_frame.settings_frame.tooltip_normal_ot:GetChecked() then

        -- round over time num for niceyness
        local ot = tonumber(string.format("%.0f", eval.spell.ot_if_hit));

        if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
            if spell.base_id == spell_name_to_id["Curse of Agony"] then
                local dmg_from_sp = stats.ot_coef*stats.spell_ot_mod*stats.spell_power*eval.spell.ot_ticks;
                local dmg_wo_sp = (eval.spell.ot_if_hit - dmg_from_sp);
                tooltip:AddLine(string.format("%s (%.1f%% hit): %d over %.2fs (%.0f-%.0f-%.0f for %d ticks)",
                                              effect,
                                              stats.hit * 100,
                                              eval.spell.ot_if_hit, 
                                              eval.spell.ot_duration, 
                                              (0.5*dmg_wo_sp + dmg_from_sp)/eval.spell.ot_ticks,
                                              eval.spell.ot_if_hit/eval.spell.ot_ticks,
                                              (1.5*dmg_wo_sp + dmg_from_sp)/eval.spell.ot_ticks,
                                              eval.spell.ot_ticks), 
                                232.0/255, 225.0/255, 32.0/255);
            elseif bit.band(spell.flags, spell_flags.over_time_range) ~= 0 then
                tooltip:AddLine(string.format("%s (%.1f%% hit): %d-%d over %.2fs (%d-%d for %d ticks)",
                                              effect,
                                              stats.hit * 100,
                                              eval.spell.ot_if_hit,
                                              eval.spell.ot_if_hit_max,
                                              eval.spell.ot_duration, 
                                              math.floor(eval.spell.ot_if_hit/eval.spell.ot_ticks),
                                              math.ceil(eval.spell.ot_if_hit_max/eval.spell.ot_ticks),
                                              eval.spell.ot_ticks), 
                                232.0/255, 225.0/255, 32.0/255);
            else
                tooltip:AddLine(string.format("%s (%.1f%% hit): %d over %.2fs (%d-%d for %d ticks)",
                                              effect,
                                              stats.hit * 100,
                                              eval.spell.ot_if_hit, 
                                              eval.spell.ot_duration, 
                                              math.floor(eval.spell.ot_if_hit/eval.spell.ot_ticks),
                                              math.ceil(eval.spell.ot_if_hit/eval.spell.ot_ticks),
                                              eval.spell.ot_ticks), 
                                232.0/255, 225.0/255, 32.0/255);
            end
        else
            -- wild growth
            if spell.base_id == spell_name_to_id["Wild Growth"] then
                tooltip:AddLine(string.format("%s: %d over %ds (%d, %d, %d, %d, %d, %d, %d ticks)",
                                              effect,
                                              eval.spell.ot_if_hit, 
                                              eval.spell.ot_duration, 
                                              math.floor(eval.spell.ot_if_hit/eval.spell.ot_ticks * (1.0 + 0.09245475363 *  3) + 0.5),
                                              math.floor(eval.spell.ot_if_hit/eval.spell.ot_ticks * (1.0 + 0.09245475363 *  2) + 0.5),
                                              math.floor(eval.spell.ot_if_hit/eval.spell.ot_ticks * (1.0 + 0.09245475363 *  1) + 0.5),
                                              math.floor(eval.spell.ot_if_hit/eval.spell.ot_ticks * (1.0 + 0.09245475363 *  0) + 0.5),
                                              math.floor(eval.spell.ot_if_hit/eval.spell.ot_ticks * (1.0 + 0.09245475363 * -1) + 0.5),
                                              math.floor(eval.spell.ot_if_hit/eval.spell.ot_ticks * (1.0 + 0.09245475363 * -2) + 0.5),
                                              math.floor(eval.spell.ot_if_hit/eval.spell.ot_ticks * (1.0 + 0.09245475363 * -3) + 0.5)
                                              ), 
                                232.0/255, 225.0/255, 32.0/255);
            elseif bit.band(spell.flags, spell_flags.over_time_range) ~= 0 then
                 tooltip:AddLine(string.format("%s: %d-%d over %.2fs (%d-%d for %d ticks)",
                                               effect,
                                               eval.spell.ot_if_hit, 
                                               eval.spell.ot_if_hit_max, 
                                               eval.spell.ot_duration, 
                                               math.floor(eval.spell.ot_if_hit/eval.spell.ot_ticks),
                                               math.ceil(eval.spell.ot_if_hit_max/eval.spell.ot_ticks),
                                               eval.spell.ot_ticks), 
                                232.0/255, 225.0/255, 32.0/255);
            else
                 tooltip:AddLine(string.format("%s: %d over %.2fs (%d-%d for %d ticks)",
                                               effect,
                                               eval.spell.ot_if_hit, 
                                               eval.spell.ot_duration, 
                                               math.floor(eval.spell.ot_if_hit/eval.spell.ot_ticks),
                                               math.ceil(eval.spell.ot_if_hit/eval.spell.ot_ticks),
                                               eval.spell.ot_ticks), 
                                232.0/255, 225.0/255, 32.0/255);
            end
        end

        if eval.spell.ot_if_crit ~= 0.0 and 
            sw_frame.settings_frame.tooltip_crit_ot:GetChecked() then
            if bit.band(spell.flags, spell_flags.over_time_range) ~= 0 then
                tooltip:AddLine(string.format("Critical (%.2f%% crit): %d-%d over %.2fs (%d-%d for %d ticks)",
                                              stats.crit*100, 
                                              eval.spell.ot_if_crit, 
                                              eval.spell.ot_if_crit_max, 
                                              eval.spell.ot_duration, 
                                              math.floor(eval.spell.ot_if_crit/eval.spell.ot_ticks),
                                              math.ceil(eval.spell.ot_if_crit_max/eval.spell.ot_ticks),
                                              eval.spell.ot_ticks), 
                           252.0/255, 69.0/255, 3.0/255);
                
            else
                tooltip:AddLine(string.format("Critical (%.2f%% crit): %d over %.2fs (%d-%d for %d ticks)",
                                              stats.crit*100, 
                                              eval.spell.ot_if_crit, 
                                              eval.spell.ot_duration, 
                                              math.floor(eval.spell.ot_if_crit/eval.spell.ot_ticks),
                                              math.ceil(eval.spell.ot_if_crit/eval.spell.ot_ticks),
                                              eval.spell.ot_ticks), 
                           252.0/255, 69.0/255, 3.0/255);
            end
                
        end
    end

    if sw_frame.settings_frame.tooltip_expected_effect:GetChecked() then

        -- show avg target magical resi if present
        if stats.target_resi > 0 then
            tooltip:AddLine(string.format("Target resi: %d with average %.2f% resists",
                                          stats.target_resi,
                                          eval.spell.target_avg_resi * 100
                                          ), 
                          232.0/255, 225.0/255, 32.0/255);
        end

        local effect_extra_str = "";

        --if spell.base_id == spell_name_to_id["Prayer of Healing"] or 
        --   spell.base_id == spell_name_to_id["Chain Heal"] or 
        --   spell.base_id == spell_name_to_id["Chain Heal"] or 
        --   spell.base_id == spell_name_to_id["Tranquility"] then

        --    effect_extra_str = "";
        --elseif bit.band(spell.flags, spell_flags.aoe) ~= 0 and 
        --        eval.spell.expectation == eval.spell.expectation_st then
        --    effect_extra_str = "(single effect)";
        --end


        if eval.spell.expectation ~=  eval.spell.expectation_st then

          tooltip:AddLine("Expected "..effect..string.format(": %.1f",eval.spell.expectation_st).." (single effect)",
                          255.0/256, 128.0/256, 0);
        end
        tooltip:AddLine("Expected "..effect..string.format(": %.1f ",eval.spell.expectation)..effect_extra_str,
                        255.0/256, 128.0/256, 0);

    end
    if sw_frame.settings_frame.tooltip_avg_cast:GetChecked() then

        tooltip:AddLine(string.format("Expected Cast Time: %.3f sec", stats.cast_time), 0.0, 1.0, 1.0);
    end
    if sw_frame.settings_frame.tooltip_avg_cost:GetChecked() then
        tooltip:AddLine(string.format("Expected Cost: %.1f",stats.cost), 0.0, 1.0, 1.0);
    end


    tooltip:AddLine("Scenario: Repeated casts", 1, 1, 1);
    if sw_frame.settings_frame.tooltip_effect_per_sec:GetChecked() then
        tooltip:AddLine(string.format("%s: %.1f", 
                                      effect_per_sec,
                                      eval.spell.effect_per_sec),
                        255.0/256, 128.0/256, 0);
    end
    if sw_frame.settings_frame.tooltip_effect_per_cost:GetChecked() then
        tooltip:AddLine(effect_per_cost..": "..string.format("%.1f",eval.spell.effect_per_cost), 0.0, 1.0, 1.0);
    end
    if sw_frame.settings_frame.tooltip_cost_per_sec:GetChecked() then
        tooltip:AddLine(cost_per_sec.." burn: "..string.format("%.1f",eval.spell.cost_per_sec), 0.0, 1.0, 1.0);
        tooltip:AddLine(cost_per_sec.." gain: "..string.format("%.1f",cast_til_oom.normal.mp1), 0.0, 1.0, 1.0);
    end

    if sw_frame.settings_frame.tooltip_stat_weights:GetChecked() then
        tooltip:AddLine(effect_per_sec_per_sp..": "..string.format("%.3f",eval.effect_per_sec_per_sp), 0.0, 1.0, 0.0);
        local stat_weights = {};
        stat_weights[1] = {weight = 1.0, str = "SP"};
        stat_weights[2] = {weight = eval.sp_per_crit, str = "Crit"};
        stat_weights[3] = {weight = eval.sp_per_haste, str = "Haste"};
        local num_weights = 3;

        if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
            num_weights = 4;
            stat_weights[4] = {weight = eval.sp_per_hit, str = "Hit"};
        --    tooltip:AddLine(sp_name.." per Hit rating: "..string.format("%.3f",eval.sp_per_hit), 0.0, 1.0, 0.0);
            --tooltip:AddLine(string.format("1 SP = %.3f Critical = %.3f Haste = %.3f Hit",eval.sp_per_crit, eval.sp_per_haste, eval.sp_per_hit), 0.0, 1.0, 0.0);
        else
            --tooltip:AddLine(string.format("1 SP = %.3f Critical = %.3f Haste",eval.sp_per_crit, eval.sp_per_haste), 0.0, 1.0, 0.0);
        end
        local stat_weights_str = "";
        sort_stat_weights(stat_weights, num_weights);
        for i = 1, num_weights-1 do
            stat_weights_str = stat_weights_str..string.format("%.3f %s | ", stat_weights[i].weight, stat_weights[i].str);
        end
        stat_weights_str = stat_weights_str..string.format("%.3f %s", stat_weights[num_weights].weight, stat_weights[num_weights].str);
        tooltip:AddLine(stat_weights_str, 0.0, 1.0, 0.0);
    end

    if sw_frame.settings_frame.tooltip_cast_until_oom:GetChecked() and
        bit.band(spell.flags, spell_flags.cd) == 0 then

        tooltip:AddLine("Scenario: Cast until OOM", 1, 1, 1);
        tooltip:AddLine("   Coming in a future update", 1, 1, 1);


        --tooltip:AddLine(string.format("%s until OOM : %.1f (%.1f casts, %.1f sec)", effect, cast_til_oom.normal.effect_until_oom, cast_til_oom.normal.num_casts_until_oom, cast_til_oom.normal.time_until_oom));
        --tooltip:AddLine("Effect per 1 SP: "..string.format("%.3f",cast_til_oom.effect_per_1_sp), 0.0, 1.0, 0.0);

        --local stat_weights = {};
        --stat_weights[1] = {weight = 1.0, str = "SP"};
        --stat_weights[2] = {weight = cast_til_oom.sp_per_crit, str = "Crit"};
        --stat_weights[3] = {weight = cast_til_oom.sp_per_haste, str = "Haste"};
        --stat_weights[4] = {weight = cast_til_oom.sp_per_int, str = "Int"};
        --stat_weights[5] = {weight = cast_til_oom.sp_per_spirit, str = "Spirit"};
        --stat_weights[6] = {weight = cast_til_oom.sp_per_mp5, str = "MP5"};
        --local num_weights = 6;

        --if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
        --    num_weights = 7;
        --    stat_weights[7] = {weight = eval.sp_per_hit, str = "Hit"};
        ----    tooltip:AddLine(sp_name.." per Hit rating: "..string.format("%.3f",eval.sp_per_hit), 0.0, 1.0, 0.0);
        --    --tooltip:AddLine(string.format("1 SP = %.3f Critical = %.3f Haste = %.3f Hit",eval.sp_per_crit, eval.sp_per_haste, eval.sp_per_hit), 0.0, 1.0, 0.0);
        --else
        --    --tooltip:AddLine(string.format("1 SP = %.3f Critical = %.3f Haste",eval.sp_per_crit, eval.sp_per_haste), 0.0, 1.0, 0.0);
        --end
        --local stat_weights_str = "";
        --sort_stat_weights(stat_weights, num_weights);
        --for i = 1, num_weights-1 do
        --    stat_weights_str = stat_weights_str..string.format("%.3f %s | spell_flags.over_time_range), ", stat_weights[i].weight, stat_weights[i].str);
        --end
        --stat_weights_str = stat_weights_str..string.format("%.3f %s", stat_weights[num_weights].weight, stat_weights[num_weights].str);
        --tooltip:AddLine(stat_weights_str, 0.0, 1.0, 0.0);
    end

    if sw_frame.settings_frame.tooltip_coef:GetChecked() then
        tooltip:AddLine(string.format("Coefficient direct: %.3f", stats.direct_coef), 232.0/255, 225.0/255, 32.0/255);
        tooltip:AddLine(string.format("Coefficient over time: %.3f", stats.over_time_coef), 232.0/255, 225.0/255, 32.0/255);
    end
    -- debug tooltip stuff
    if __sw__debug__ then
        tooltip:AddLine("Base "..effect..": "..spell.base_min.."-"..spell.base_max);
        tooltip:AddLine("Base "..effect..": "..spell.over_time);
        tooltip:AddLine(
          string.format("Stats: sp %d, crit %.4f, crit_mod %.4f, hit %.4f, mod %.4f, ot_mod %.4f, flat add %.4f",
                        stats.spell_power,
                        stats.crit,
                        stats.crit_mod,
                        stats.hit,
                        stats.spell_mod,
                        stats.spell_ot_mod,
                        stats.flat_addition));

        tooltip:AddLine(
          string.format("cost %f, cast %f, coef %f, ot %f, mcoef %f, ot %f",
                        stats.cost,
                        stats.cast_time,
                        stats.coef,
                        stats.ot_coef,
                        stats.coef*stats.spell_mod,
                        stats.ot_coef*stats.spell_ot_mod
                        ));
                        
    end


    end_tooltip_section(tooltip);

    if spell.healing_version then
        -- used for holy nova
        tooltip_spell_info(tooltip, spell.healing_version, loadout, effects);
    end
end


local function print_spell(spell, spell_name, loadout)

    if spell then

        local stats = {};
        stats_for_spell(stats, spell, loadout); 
        local eval = evaluate_spell(spell, stats, loadout);
        
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
                            spell.coef,
                            spell.over_time_coef,
                            spell.cost_base_percent
                            ));

        print(string.format("Spell noncrit: min %d, max %d", eval.spell.min_noncrit_if_hit, eval.spell.max_noncrit_if_hit));
        print(string.format("Spell crit: min %d, max %d", eval.spell.min_crit_if_hit, eval.spell.max_crit_if_hit));
                            

        print("Spell evaluation");
        print(string.format("ot if hit: %.3f", eval.spell.ot_if_hit));
        print(string.format("including hit/miss - expectation: %.3f, effect_per_sec: %.3f, effect per cost:%.3f, effect_per_sec_per_sp : %.3f, sp_per_crit: %.3f, sp_per_hit: %.3f", 
                            eval.spell.expectation, 
                            eval.spell.effect_per_sec, 
                            eval.spell.effect_per_cost, 
                            eval.effect_per_sec_per_sp, 
                            eval.sp_per_crit, 
                            eval.sp_per_hit
                            ));
        print("---------------------------------------------------");
    end
end

--local function diff_spell(spell, spell_name, loadout1, loadout2)
--

--    lhs = evaluate_spell(spell, spell_name, loadout1);
--    rhs = evaluate_spell(spell, spell_name, loadout2);
--    return {
--        expectation = rhs.spell.expectation - lhs.spell.expectation,
--        effect_per_sec = rhs.spell.effect_per_sec - lhs.spell.effect_per_sec
--    };
--end

-- UI code
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

    loadout.crit_rating = stats[stat_ids_in_ui.spell_crit].editbox_val;
    loadout.hit_rating = stats[stat_ids_in_ui.spell_hit].editbox_val;
    loadout.haste_rating = stats[stat_ids_in_ui.spell_haste].editbox_val;

    local loadout_sp = stats[stat_ids_in_ui.sp].editbox_val;
    loadout.spell_power = loadout.spell_power + loadout_sp;

    --local loadout_decrease_target_res = stats[stat_ids_in_ui.target_spell_res_decrease].editbox_val;
    --for i = 2, 7 do
    --    loadout.target_mod_res_by_school[i] = loadout.target_mod_res_by_school[i] - loadout_decrease_target_res;
    --end

    frame.is_valid = true;

    return loadout;
end

local function spell_diff(spell, loadout, diff, sim_type)

    local loadout_diffed = loadout_add(loadout, diff);

    local stats = {};
    local stats_diff = {};
    local expectation_loadout = {};
    spell_info_from_stats(expectation_loadout, stats, spell, loadout);
    local expectation_loadout_diffed = {};
    spell_info_from_stats(expectation_loadout_diffed, stats_diff, spell, loadout_diffed);

    if sim_type == simulation_type.spam_cast then
        return {
            diff_ratio = 100 * 
                (expectation_loadout_diffed.effect_per_sec/expectation_loadout.effect_per_sec - 1),
            expectation = expectation_loadout_diffed.expectation - 
                expectation_loadout.expectation,
            effect_per_sec = expectation_loadout_diffed.effect_per_sec - 
                expectation_loadout.effect_per_sec
        };
    elseif sim_type == simulation_type.cast_until_oom then
        
        local race_for_loadout = {};
        cast_until_oom_sim_default(race_for_loadout, expectation_loadout, loadout);
        local race_for_loadout_diffed = {};
        cast_until_oom_sim_default(race_for_loadout_diffed, expectation_loadout_diffed, loadout_diffed);
        -- Misleading! effect_per_sec used here to use previous code but doesnt mean efect_per_sec here
        return {
            diff_ratio = 100 * 
                (race_for_loadout_diffed.effect_until_oom/race_for_loadout.effect_until_oom - 1),
            expectation = race_for_loadout_diffed.effect_until_oom - 
                race_for_loadout.effect_until_oom,
            effect_per_sec = race_for_loadout_diffed.time_until_oom - 
                race_for_loadout.time_until_oom
        };
    end
end

-- TODO: delete
--function active_loadout_base()
--    if sw_frame.loadouts_frame.lhs_list.loadouts and sw_frame.loadouts_frame.lhs_list.active_loadout then
--        return sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout;
--    else
--        assert(false, "Why was there nothing before?");
--        return default_loadout();
--    end
--end

--local function active_loadout_copy()
--
--    local loadout = active_loadout_base();
--    if loadout.is_dynamic_loadout then
--        loadout_modified = dynamic_loadout(loadout);
--    else
--        loadout_modified = loadout_copy(loadout);
--    end
--
--    return loadout_modified;
--end

local function active_loadout_entry()
    
    return sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout];
end

local function active_loadout()
    
    return active_loadout_entry().loadout;
end

function __sw_active_loadout()
    return active_loadout();
end


local function active_loadout_and_effects()

    --if not sw_frame.loadouts_frame.lhs_list.loadouts or not sw_frame.loadouts_frame.lhs_list.active_loadout then
    --    return nil, nil;
    --end
    local loadout_entry = active_loadout_entry();
    if loadout_entry.loadout.is_dynamic_loadout then
        dynamic_loadout(loadout_entry.loadout);
    end
        
    if equipment_update_needed then
        zero_effects(loadout_entry.equipped);
        apply_equipment(loadout_entry.loadout, loadout_entry.equipped);
        talents_update_needed = true;
    end

    if talents_update_needed then
        if loadout_entry.loadout.is_dynamic_loadout then
            loadout_entry.loadout.talents_code = wowhead_talent_code();
        end
        zero_effects(loadout_entry.talented);
        effects_add(loadout_entry.talented, loadout_entry.equipped);
        apply_talents_glyphs(loadout_entry.loadout, loadout_entry.talented);
    end

    zero_effects(loadout_entry.final_effects);
    effects_add(loadout_entry.final_effects, loadout_entry.talented);
    apply_buffs(loadout_entry.loadout, loadout_entry.final_effects);

    talents_update_needed = false;
    equipment_update_needed = false;

    return loadout_entry.loadout, loadout_entry.final_effects;
end

-- non local functions intended to be usable by other addons
--TODO: No good! Use cached spells
--function __sw__spell_info_from_loadout(spell_id, loadout)
--
--
--    local spell = spells[spell_id];
--
--    if not spell or not loadout then
--        return nil;
--    end
--
--    local stats = stats_for_spell(spell, loadout);
--
--    local info = spell_info(spell, stats, loadout);
--
--    return {
--        stats = stats,
--        info = info
--    };
--end
--
--function __sw__spell_info(spell_id)
--    return __sw__spell_info_from_loadout(spell_id, active_loadout_buffed_talented_copy());
--end
--
--function __sw__spell_evaluation_from_loadout(spell_id, loadout)
--
--    local spell = spells[spell_id];
--
--    if not spell or not loadout then
--        return nil;
--    end
--
--    local stats = stats_for_spell(spell, loadout);
--
--    local eval = evaluate_spell(spell, stats, loadout);
--    return {
--        stats = stats,
--        eval = eval
--    };
--end

--function __sw__spell_evaluation(spell_id)
--    return __sw__spell_evaluation_from_loadout(spell_id, active_loadout_buffed_talented_copy());
--end

--function __sw__spell_cast_til_oom_evaluation_from_loadout(spell_id, loadout)
--
--    local spell = spells[spell_id];
--
--    if not spell or not loadout then
--        return nil;
--    end
--
--    local stats = stats_for_spell(spell, loadout);
--
--    local eval = evaluate_spell(spell, stats, loadout);
--
--    local rtb = cast_until_oom_stat_weights(
--        spell,
--        stats,
--        eval.spell, 
--        eval.spell_1_sp,
--        eval.spell_1_crit,
--        eval.spell_1_hit,
--        eval.spell_1_haste,
--        loadout
--    );
--
--    return {
--        stats = stats,
--        eval = rtb
--    };
--end

--function __sw__spell_cast_til_oom_evaluation(spell_id)
--    return __sw__spell_cast_til_oom_evaluation_from_loadout(spell_id, active_loadout_buffed_talented_copy());
--end

local update_and_display_spell_diffs = nil;

local function display_spell_diff(spell_id, spell, spell_diff_line, loadout, loadout_diff, frame, is_duality_spell, sim_type)

    local diff = spell_diff(spell, loadout, loadout_diff, sim_type);

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
    

        if not spell.healing_version then
            v.cancel_button = CreateFrame("Button", "button", frame, "UIPanelButtonTemplate"); 
        end
    end
    
    v.name_str:SetPoint("TOPLEFT", 15, frame.line_y_offset);
    if is_duality_spell and 
        bit.band(spell.flags, spell_flags.heal) ~= 0 then

        v.name_str:SetText(v.name.." H (Rank "..spell.rank..")");
    elseif v.name == spell_name_to_id["Holy Nova"] or v.name == spell_name_to_id["Holy Shock"] then

        v.name_str:SetText(v.name.." D (Rank "..spell.rank..")");
    else
        v.name_str:SetText(v.name.." (Rank "..spell.rank..")");
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
            

        if not spell.healing_version then
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

    -- TODO: refactor

    --frame.line_y_offset = frame.line_y_offset_before_dynamic_spells;

    --local loadout, effects = active_loadout_and_effects();

    --local loadout_diff = create_loadout_from_ui_diff(frame);

    --for k, v in pairs(frame.spells) do
    --    display_spell_diff(k, spells[k], v, loadout, loadout_diff, frame, false, sw_frame.stat_comparison_frame.sim_type);

    --    -- for spells with both heal and dmg
    --    if spells[k].healing_version then
    --        display_spell_diff(k, spells[k].healing_version, v, loadout, loadout_diff, frame, true, sw_frame.stat_comparison_frame.sim_type);
    --    end
    --end

    ---- footer
    --frame.line_y_offset = ui_y_offset_incr(frame.line_y_offset);
    --frame.line_y_offset = ui_y_offset_incr(frame.line_y_offset);

    --if not frame.footer then
    --    frame.footer = frame:CreateFontString(nil, "OVERLAY");
    --end
    --frame.footer:SetFontObject(font);
    --frame.footer:SetPoint("TOPLEFT", 15, frame.line_y_offset);
    --frame.footer:SetText("Add abilities by holding SHIFT and HOVERING over them!");
end

local function loadout_name_already_exists(name)

    local already_exists = false;    
    for i = 1, sw_frame.loadouts_frame.lhs_list.num_loadouts do
    
        if name == sw_frame.loadouts_frame.lhs_list.loadouts[i].base.name then
            already_exists = true;
        end
    end
    return already_exists;
end

local function update_loadouts_rhs()

    local loadout = active_loadout();

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

    --for i = 2, 7 do
    --    sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetText(loadout.target_res_by_school[i]);
    --end

    local num_checked_buffs = 0;
    local num_checked_target_buffs = 0;
    if not loadout.always_assume_buffs then
        for k = 1, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs do
            local v = sw_frame.loadouts_frame.rhs_list.buffs[k];
            v.checkbutton:SetChecked(true);
            v.checkbutton:Hide();
            v.icon:Hide();
        end

        for k = 1, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs do
            local v = sw_frame.loadouts_frame.rhs_list.target_buffs[k];
            v.checkbutton:SetChecked(true);
            v.checkbutton:Hide();
            v.icon:Hide();
        end
    else
        for k = 1, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs do

            local v = sw_frame.loadouts_frame.rhs_list.buffs[k];
            if v.checkbutton.buff_type == "self" then
                
                if loadout.buffs[v.checkbutton.buff_lname] then
                    v.checkbutton:SetChecked(true);
                    num_checked_buffs = num_checked_buffs + 1;
                else
                    v.checkbutton:SetChecked(false);
                end
            end
            v.checkbutton:Hide();
            v.icon:Hide();
        end
        for k = 1, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs do

            local v = sw_frame.loadouts_frame.rhs_list.target_buffs[k];

            if loadout.target_buffs[v.checkbutton.buff_lname] then
                v.checkbutton:SetChecked(true);
                num_checked_target_buffs = num_checked_target_buffs + 1;
            else
                v.checkbutton:SetChecked(false);
            end
            v.checkbutton:Hide();
            v.icon:Hide();
        end
    end
    -- all checkbuttons have been hidden, now unhide and set positions depending on slider
    local y_offset = 0;
    local buffs_show_max = 0;
    local num_buffs = 0;
    local num_skips = 0;
    local self_buffs_tab = sw_frame.loadouts_frame.rhs_list.self_buffs_frame:IsShown();

    if self_buffs_tab then
        y_offset = sw_frame.loadouts_frame.rhs_list.self_buffs_y_offset_start;
        buffs_show_max = sw_frame.loadouts_frame.rhs_list.buffs.num_buffs_can_fit;
        num_buffs = sw_frame.loadouts_frame.rhs_list.buffs.num_buffs;
        num_skips = math.floor(sw_frame.loadouts_frame.self_buffs_slider:GetValue()) + 1;
    else
        y_offset = sw_frame.loadouts_frame.rhs_list.target_buffs_y_offset_start;
        buffs_show_max = sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs_can_fit;
        num_buffs = sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs;
        num_skips = math.floor(sw_frame.loadouts_frame.target_buffs_slider:GetValue()) + 1;
    end

    local icon_offset = -4;

    if self_buffs_tab then
        for i = num_skips, math.min(num_skips + buffs_show_max - 1, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs) do
            sw_frame.loadouts_frame.rhs_list.buffs[i].checkbutton:SetPoint("TOPLEFT", 20, y_offset);
            sw_frame.loadouts_frame.rhs_list.buffs[i].checkbutton:Show();
            sw_frame.loadouts_frame.rhs_list.buffs[i].icon:SetPoint("TOPLEFT", 5, y_offset + icon_offset);
            sw_frame.loadouts_frame.rhs_list.buffs[i].icon:Show();
            y_offset = y_offset - 20;
        end
    else
        
        local target_buffs_iters = 
            math.max(0, math.min(buffs_show_max - num_skips, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs - num_skips) + 1);
        if buffs_show_max < num_skips and num_skips <= sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs then
            target_buffs_iters = buffs_show_max;
        end
        if target_buffs_iters > 0 then
            for i = num_skips, num_skips + target_buffs_iters - 1 do
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].checkbutton:SetPoint("TOPLEFT", 20, y_offset);
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].checkbutton:Show();
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].icon:SetPoint("TOPLEFT", 5, y_offset + icon_offset);
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].icon:Show();
                y_offset = y_offset - 20;
            end
        end

        num_skips = num_skips + target_buffs_iters - sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs;
    end

    sw_frame.loadouts_frame.rhs_list.num_checked_buffs = num_checked_buffs;
    sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs = num_checked_target_buffs;

    if not loadout.always_assume_buffs then
        sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(true);
        sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(true);
    else
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
end

local loadout_checkbutton_id_counter = 1;

-- TODO: localize
function update_loadouts_lhs()

    local y_offset = -13;
    local max_slider_val = math.max(0, sw_frame.loadouts_frame.lhs_list.num_loadouts - sw_frame.loadouts_frame.lhs_list.num_loadouts_can_fit);

    sw_frame.loadouts_frame.loadouts_slider:SetMinMaxValues(0, max_slider_val);
    if sw_frame.loadouts_frame.loadouts_slider:GetValue() > max_slider_val then
        sw_frame.loadouts_frame.loadouts_slider:SetValue(max_slider_val);
    end

    local num_skips = math.floor(sw_frame.loadouts_frame.loadouts_slider:GetValue()) + 1;


    -- precheck to create if needed and hide by default
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

                talents_update_needed = true;

                sw_frame.loadouts_frame.lhs_list.active_loadout = self.target_index;

                update_loadouts_rhs();
            end);
        end

        v.check_button:Hide();
    end

    -- show the ones in frames according to scroll slider
    for k = num_skips, math.min(num_skips + sw_frame.loadouts_frame.lhs_list.num_loadouts_can_fit - 1, 
                                sw_frame.loadouts_frame.lhs_list.num_loadouts) do

        local v = sw_frame.loadouts_frame.lhs_list.loadouts[k];

        getglobal(v.check_button:GetName() .. 'Text'):SetText(v.loadout.name);
        v.check_button:SetPoint("TOPLEFT", 10, y_offset);
        v.check_button:Show();

        if k == sw_frame.loadouts_frame.lhs_list.active_loadout then
            v.check_button:SetChecked(true);
        else
            v.check_button:SetChecked(false);
        end

        y_offset = y_offset - 20;
    end

    update_loadouts_rhs();
end

local function create_new_loadout_as_copy(loadout_entry)


    sw_frame.loadouts_frame.lhs_list.loadouts[
        sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(false);

    sw_frame.loadouts_frame.lhs_list.num_loadouts = sw_frame.loadouts_frame.lhs_list.num_loadouts + 1;
    sw_frame.loadouts_frame.lhs_list.active_loadout = sw_frame.loadouts_frame.lhs_list.num_loadouts;

    sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.num_loadouts] = {};
    local new_entry = sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.num_loadouts];
    new_entry.loadout = deep_table_copy(loadout_entry.loadout);
    new_entry.equipped = deep_table_copy(loadout_entry.equipped);
    new_entry.talented = {};
    empty_effects(new_entry.talented);
    new_entry.final_effects = {};
    empty_effects(new_entry.final_effects);

    talents_update_needed = true;

    new_entry.loadout.name = loadout_entry.loadout.name.." (Copy)";

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
                tooltip_stat_display.avg_cost,
                tooltip_stat_display.avg_cast,
                tooltip_stat_display.expected,
                tooltip_stat_display.effect_per_sec,
                tooltip_stat_display.effect_per_cost,
                tooltip_stat_display.cost_per_sec,
                tooltip_stat_display.stat_weights,
                tooltip_stat_display.cast_until_oom);

    settings.icon_overlay_update_freq = 3;
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
    if sw_frame.settings_frame.tooltip_cast_until_oom:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.cast_until_oom);
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
                           "Expected cost", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_avg_cast = 
        create_sw_checkbox("sw_icon_avg_cast", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Expected cast time", icon_checkbox_func);
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
            self:SetText("3"); 
            sw_snapshot_loadout_update_freq = 3;
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
                            "Expected cost", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_avg_cast = 
        create_sw_checkbox("sw_tooltip_avg_cast", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Expected cast time", tooltip_checkbox_func);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_cast_until_oom = 
        create_sw_checkbox("sw_tooltip_cast_until_oom", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Cast until OOM", tooltip_checkbox_func);
    getglobal(sw_frame.settings_frame.tooltip_cast_until_oom:GetName()).tooltip = 
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
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.cast_until_oom) ~= 0 then
        sw_frame.settings_frame.tooltip_cast_until_oom:SetChecked(true);
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

    sw_frame.stat_comparison_frame:SetWidth(400);
    sw_frame.stat_comparison_frame:SetHeight(600);
    sw_frame.stat_comparison_frame:SetPoint("TOP", sw_frame, 0, -20);

    sw_frame.stat_comparison_frame.line_y_offset = -20;

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
            label_str = "Critical rating"
        },
        [7] = {
            label_str = "Hit rating"
        },
        [8] = {
            label_str = "Haste rating"
        },
        [9] = {
            label_str = "Reduced resistance (target)"
        }
    };

    local num_stats = 0;
    for _ in pairs(sw_frame.stat_comparison_frame.stats) do
        num_stats = num_stats + 1;
    end

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
                UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Repeated casts");
            elseif sw_frame.stat_comparison_frame.sim_type == simulation_type.cast_until_oom then 
                UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Cast until OOM");
            end
            UIDropDownMenu_SetWidth(sw_frame.stat_comparison_frame.sim_type_button, 130);

            UIDropDownMenu_AddButton(
                {
                    text = "Repeated cast",
                    func = function()

                        sw_frame.stat_comparison_frame.sim_type = simulation_type.spam_cast;
                        UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Repeated casts");
                        sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Show();
                        sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:Hide();
                        update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
                    end
                }
            );
            UIDropDownMenu_AddButton(
                {
                    text = "Cast until OOM",
                    func = function()

                        sw_frame.stat_comparison_frame.sim_type = simulation_type.cast_until_oom;
                        UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Cast until OOM");
                        sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Hide();
                        sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:Show();
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


    sw_frame.stat_comparison_frame.export_button:SetPoint("TOPRIGHT", -10, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.export_button:SetHeight(25);
    sw_frame.stat_comparison_frame.export_button:SetWidth(180);
    sw_frame.stat_comparison_frame.export_button:SetText("New loadout with difference");

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

    sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:SetPoint("TOPRIGHT", -20, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:SetText("DURATION (s)");

    -- always have at least one
    sw_frame.stat_comparison_frame.spells = {};
    sw_frame.stat_comparison_frame.sim_type = simulation_type.spam_cast;

    -- TODO: wotlk stuff
    --if UnitLevel("player") == 60 then

    --    if class == "MAGE" then
    --        sw_frame.stat_comparison_frame.spells[25304] = {
    --            name = localized_spell_name("Frostbolt")
    --        };
    --        sw_frame.stat_comparison_frame.spells[25306] = {
    --            name = localized_spell_name("Fireball")
    --        };
    --    elseif class == "DRUID" then

    --        sw_frame.stat_comparison_frame.spells[25297] = {
    --            name = localized_spell_name("Healing Touch")
    --        };
    --        sw_frame.stat_comparison_frame.spells[25298] = {
    --            name = localized_spell_name("Starfire")
    --        };

    --    elseif class == "PALADIN" then

    --        sw_frame.stat_comparison_frame.spells[19943] = {
    --            name = localized_spell_name("Flash of Light")
    --        };
    --        sw_frame.stat_comparison_frame.spells[25292] = {
    --            name = localized_spell_name("Holy Light")
    --        };
    --    elseif class == "SHAMAN" then

    --        sw_frame.stat_comparison_frame.spells[25357] = {
    --            name = localized_spell_name("Healing Wave")
    --        };
    --        sw_frame.stat_comparison_frame.spells[15208] = {
    --            name = localized_spell_name("Lightning Bolt")
    --        };
    --    elseif class == "PRIEST" then

    --        sw_frame.stat_comparison_frame.spells[25314] = {
    --            name = localized_spell_name("Greater Heal")
    --        };
    --        sw_frame.stat_comparison_frame.spells[25315] = {
    --            name = localized_spell_name("Renew")
    --        };
    --    elseif class == "WARLOCK" then

    --        sw_frame.stat_comparison_frame.spells[25307] = {
    --            name = localized_spell_name("Shadow Bolt")
    --        };
    --        sw_frame.stat_comparison_frame.spells[25311] = {
    --            name = localized_spell_name("Corruption")
    --        };
    --        sw_frame.stat_comparison_frame.spells[11713] = {
    --            name = localized_spell_name("Curse of Agony")
    --        };
    --    end
    --end

end

local function create_loadout_buff_checkbutton(buffs_table, buff_lname, buff_info, buff_type, parent_frame, func)

    local index = buffs_table.num_buffs + 1;

    buffs_table[index] = {};
    buffs_table[index].checkbutton = CreateFrame("CheckButton", "loadout_apply_buffs_"..buff_lname, parent_frame, "ChatConfigCheckButtonTemplate");
    buffs_table[index].checkbutton.buff_info = buff_info.filter;
    buffs_table[index].checkbutton.buff_lname = buff_lname;
    buffs_table[index].checkbutton.buff_type = buff_type;
    if buff_info.name then
        -- overwrite name if its bad for display
        getglobal(buffs_table[index].checkbutton:GetName() .. 'Text'):SetText(buff_info.name);
    else
        getglobal(buffs_table[index].checkbutton:GetName() .. 'Text'):SetText(buff_lname);
    end
    local buff_text_colors = {

    };
    local category_txt = "";
    if buff_info.category == buff_category.class  then
        category_txt = "CLASS: ";
        getglobal(buffs_table[index].checkbutton:GetName() .. 'Text'):SetTextColor(235/255, 52/255, 88/255);
    elseif buff_info.category == buff_category.raid  then
        category_txt = "RAID: ";
        getglobal(buffs_table[index].checkbutton:GetName() .. 'Text'):SetTextColor(103/255, 52/255, 235/255);
    elseif buff_info.category == buff_category.consumes  then
        category_txt = "CONSUMES/EFFECTS: ";
        getglobal(buffs_table[index].checkbutton:GetName() .. 'Text'):SetTextColor(225/255, 235/255, 52/255);
    end
    if buff_info.tooltip then
        getglobal(buffs_table[index].checkbutton:GetName()).tooltip = category_txt..buff_info.tooltip;
    end
    buffs_table[index].checkbutton:SetScript("OnClick", func);

    buffs_table[index].icon = CreateFrame("Frame", "loadout_apply_buffs_icon_"..buff_lname, parent_frame);
    buffs_table[index].icon:SetSize(15, 15);
    local tex = buffs_table[index].icon:CreateTexture(nil);
    tex:SetAllPoints(buffs_table[index].icon);
    if buff_info.icon_id then
        tex:SetTexture(buff_info.icon_id);
    else
        tex:SetTexture(GetSpellTexture(buff_info.id));
    end

    buffs_table.num_buffs = index;

    return buffs_table[index].checkbutton;
end

local function create_sw_gui_loadout_frame()

    sw_frame.loadouts_frame:SetWidth(400);
    sw_frame.loadouts_frame:SetHeight(600);
    sw_frame.loadouts_frame:SetPoint("TOP", sw_frame, 0, -20);

    sw_frame.loadouts_frame.lhs_list = CreateFrame("ScrollFrame", "sw_loadout_frame_lhs", sw_frame.loadouts_frame);
    sw_frame.loadouts_frame.lhs_list:SetWidth(180);
    sw_frame.loadouts_frame.lhs_list:SetHeight(600-30-200-10-25-10-20-20);
    sw_frame.loadouts_frame.lhs_list:SetPoint("TOPLEFT", sw_frame, 0, -50);

    sw_frame.loadouts_frame.lhs_list:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.loadouts_frame.loadouts_slider:GetMinMaxValues();
        local val = sw_frame.loadouts_frame.loadouts_slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.loadouts_frame.loadouts_slider:SetValue(val - dir);
            update_loadouts_lhs();
        end
    end);

    sw_frame.loadouts_frame.rhs_list = CreateFrame("ScrollFrame", "sw_loadout_frame_rhs", sw_frame.loadouts_frame);
    sw_frame.loadouts_frame.rhs_list:SetWidth(400-180);
    sw_frame.loadouts_frame.rhs_list:SetHeight(600-30-30);
    sw_frame.loadouts_frame.rhs_list:SetPoint("TOPLEFT", sw_frame, 180, -50);

    sw_frame.loadouts_frame.loadouts_select_label = sw_frame.loadouts_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.loadouts_select_label:SetFontObject(font);
    sw_frame.loadouts_frame.loadouts_select_label:SetPoint("TOPLEFT", sw_frame.loadouts_frame.lhs_list, 15, -2);
    sw_frame.loadouts_frame.loadouts_select_label:SetText("Select Active Loadout");
    sw_frame.loadouts_frame.loadouts_select_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.loadouts_frame.loadouts_slider =
        CreateFrame("Slider", "sw_loadouts_slider", sw_frame.loadouts_frame.lhs_list, "OptionsSliderTemplate");
    sw_frame.loadouts_frame.loadouts_slider:SetOrientation('VERTICAL');
    sw_frame.loadouts_frame.loadouts_slider:SetPoint("TOPRIGHT", 0, -14);
    sw_frame.loadouts_frame.loadouts_slider:SetSize(15, 248);
    sw_frame.loadouts_frame.lhs_list.num_loadouts_can_fit =
        math.floor(sw_frame.loadouts_frame.loadouts_slider:GetHeight()/20);
    getglobal(sw_frame.loadouts_frame.loadouts_slider:GetName()..'Text'):SetText("");
    getglobal(sw_frame.loadouts_frame.loadouts_slider:GetName()..'Low'):SetText("");
    getglobal(sw_frame.loadouts_frame.loadouts_slider:GetName()..'High'):SetText("");
    sw_frame.loadouts_frame.loadouts_slider:SetMinMaxValues(0, 0);
    sw_frame.loadouts_frame.loadouts_slider:SetValue(0);
    sw_frame.loadouts_frame.loadouts_slider:SetValueStep(1);
    sw_frame.loadouts_frame.loadouts_slider:SetScript("OnValueChanged", function(self, val)
        update_loadouts_lhs();
    end);

    sw_frame.loadouts_frame.rhs_list.self_buffs_frame = 
        CreateFrame("ScrollFrame", "sw_loadout_frame_rhs_self_buffs", sw_frame.loadouts_frame.rhs_list);
    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetWidth(400-180);
    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetHeight(600-30-30);
    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetPoint("TOPLEFT", sw_frame.loadouts_frame.rhs_list, 0, 0);

    sw_frame.loadouts_frame.rhs_list.target_buffs_frame = 
        CreateFrame("ScrollFrame", "sw_loadout_frame_rhs_target_buffs", sw_frame.loadouts_frame.rhs_list);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetWidth(400-180);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetHeight(600-30-30);
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
            sw_frame.loadouts_frame.lhs_list.loadouts[i].equipped_talented = sw_frame.loadouts_frame.lhs_list.loadouts[i+1].equipped_talented;
            sw_frame.loadouts_frame.lhs_list.loadouts[i].buffed_equipped_talented = sw_frame.loadouts_frame.lhs_list.loadouts[i+1].buffed_equipped_talented;
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

        create_new_loadout_as_copy(active_loadout_entry());
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.loadout_talent_label = sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_talent_label:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_talent_label:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_talent_label:SetText("Custom talents (Wowhead link)");

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.talent_editbox = 
        CreateFrame("EditBox", "sw_loadout_talent_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 20, y_offset_lhs - 2);
    --sw_frame.loadouts_frame.rhs_list.talent_editbox:SetText("");
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetSize(150, 15);
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetAutoFocus(false);
    local talent_editbox = function(self)

        local loadout_entry = active_loadout_entry();
        local loadout = loadout_entry.loadout;

        local txt = self:GetText();

        if txt == wowhead_talent_link(loadout.talents_code) then
            return;
        end

        --TODO: This needs fixing after loadout, effects changes
        if loadout.is_dynamic_loadout then

            static_loadout_from_dynamic(loadout);
        end
        talents_update_needed = true;

        --local loadout_before = sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout_talented;
        --loadout_talented(loadout_before);

        loadout.talents_code = wowhead_talent_code_from_url(txt);

        --local loadout_after = sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout_talented;
        --local loadout_after = active_loadout_talented_copy();

        sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(false);

        --static_rescale_from_talents_diff(loadout_after, loadout_before);

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

    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetScript("OnTextChanged", function(self) 
        talent_editbox(self);
        self:ClearFocus();
    end);


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
        active_loadout().name = txt;

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
        local loadout = active_loadout();
        local txt = self:GetText();
        
        local mana = tonumber(txt);
        if mana then
            loadout.extra_mana = mana;
            
        else
            self:SetText("0");
            loadout.extra_mana = 0;
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
        local loadout = active_loadout();
        if lvl and lvl == math.floor(lvl) and lvl >= 1 and lvl <= 63 then

            loadout.target_lvl = lvl;
            
        else
            self:SetText(""..loadout.target_lvl); 
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
        active_loadout().use_dynamic_target_lvl = self:GetChecked();
    end)

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.dynamic_button = 
        CreateFrame("CheckButton", "sw_loadout_dynamic_check", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.dynamic_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_button:GetName()..'Text'):SetText("Dynamic loadout");
    getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_button:GetName()).tooltip = 
        "Dynamic loadouts use your current equipment, set bonuses, talents. In addition, self buffs and target's buffs/debuffs may be applied if so chosen";

    sw_frame.loadouts_frame.rhs_list.dynamic_button:SetScript("OnClick", function(self)
        
        local loadout_entry = active_loadout_entry();
        -- TODO: refactor
        if self:GetChecked() then

            loadout_entry.loadout.is_dynamic_loadout = true;
            talents_update_needed = true;
            equipment_update_needed = true;
            
            sw_frame.loadouts_frame.rhs_list.static_button:SetChecked(false);
        else

            static_loadout_from_dynamic(loadout_entry.loadout);

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
        "Static loadouts never change and can be used to create custom setups. When checked, a static loadout is a snapshot of a dynamic loadout or can be created with modified stats through the stat comparison tool. Max mana is always assumed before Cast until OOM type of fight starts."
    sw_frame.loadouts_frame.rhs_list.static_button:SetScript("OnClick", function(self)

        local loadout = active_loadout();
        if self:GetChecked() then

            static_loadout_from_dynamic(loadout);

            sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(false);
        else

            loadout.is_dynamic_loadout = true;
            talents_update_needed = true;
            equipment_update_needed = true;

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

        local loadout = active_loadout();
        if self:GetChecked() then
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.always_assume_buffs = true;
            loadout.buffs = {};
            loadout.target_buffs = {};
            
            sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetChecked(false);
        else
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.always_assume_buffs = false;
            sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetChecked(true);
        end
        update_loadouts_rhs();
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
            loadout.buffs = {};
            loadout.target_buffs = {};
        end

        update_loadouts_rhs();
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.loadout_dump =
        CreateFrame("Button", "sw_loadouts_loadout_dump", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.loadout_dump:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_dump:SetText("Debug print Loadout");
    sw_frame.loadouts_frame.rhs_list.loadout_dump:SetSize(170, 20);
    sw_frame.loadouts_frame.rhs_list.loadout_dump:SetScript("OnClick", function(self)

        print_loadout(active_loadout_and_effects());
    end);

    local y_offset_rhs = 0;

    sw_frame.loadouts_frame.rhs_list.buffs_button =
        CreateFrame("Button", "sw_frame_buffs_button", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetScript("OnClick", function(self)

        sw_frame.loadouts_frame.rhs_list.self_buffs_frame:Show();

        sw_frame.loadouts_frame.rhs_list.buffs_button:LockHighlight();
        sw_frame.loadouts_frame.rhs_list.buffs_button:SetButtonState("PUSHED");

        sw_frame.loadouts_frame.rhs_list.target_buffs_frame:Hide();

        sw_frame.loadouts_frame.rhs_list.target_buffs_button:UnlockHighlight();
        sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetButtonState("NORMAL");

        update_loadouts_rhs();

    end);
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetPoint("TOPLEFT", 20, y_offset_rhs);
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetText("SELF");
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetWidth(93);
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

        update_loadouts_rhs();

    end);
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetPoint("TOPLEFT", 93 + 20, y_offset_rhs);
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetText("TARGET");
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetWidth(93);

    y_offset_rhs = y_offset_rhs - 20;

    sw_frame.loadouts_frame.rhs_list.buffs = {};
    sw_frame.loadouts_frame.rhs_list.buffs.num_buffs = 0;

    sw_frame.loadouts_frame.rhs_list.target_buffs = {};
    sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs = 0;

    local check_button_buff_func = function(self)

        local loadout = sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout;
        if not loadout.always_assume_buffs then
            self:SetChecked(true);
            return;
        end
        if self:GetChecked() then
            if self.buff_type == "self" then
                loadout.buffs[self.buff_lname] = self.buff_info;
                sw_frame.loadouts_frame.rhs_list.num_checked_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_buffs + 1;
            elseif self.buff_type == "target_buffs" then
                loadout.target_buffs[self.buff_lname] = self.buff_info;
                sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs + 1;
            end

        else    
            if self.buff_type == "self" then
                loadout.buffs[self.buff_lname] = nil;
                sw_frame.loadouts_frame.rhs_list.num_checked_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_buffs - 1;
            elseif self.buff_type == "target_buffs" then
                loadout.target_buffs[self.buff_lname] = nil;
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
    sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetPoint("TOPLEFT", 20, y_offset_rhs_buffs);
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:GetName() .. 'Text'):SetText("SELECT ALL/NONE");
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:GetName() .. 'Text'):SetTextColor(1, 0, 0);

    sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetScript("OnClick", function(self) 

        local loadout = active_loadout();
        if not loadout.always_assume_buffs then
            self:SetChecked(true)
            return;
        end
        if self:GetChecked() then

            loadout.buffs = {};

            for i = 1, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs do
                loadout.buffs[sw_frame.loadouts_frame.rhs_list.buffs[i].checkbutton.buff_lname] =
                    sw_frame.loadouts_frame.rhs_list.buffs[i].checkbutton.buff_info;
            end
        else
            loadout.buffs = {};
        end

        update_loadouts_rhs();
    end);


    sw_frame.loadouts_frame.rhs_list.target_resi_editbox = {};

    local num_target_resi_labels = 6;
    local target_resi_labels = {
        [2] = {
            label = "Holy",
            color = {255/255, 255/255, 153/255}
        },
        [3] = {
            label = "Fire",
            color = {255/255, 0, 0}
        },
        [4] = {
            label = "Nature",
            color = {0, 153/255, 51/255}
        },
        [5] = {
            label = "Frost",
            color = {51/255, 102/255, 255/255}
        },
        [6] = {
            label = "Shadow",
            color = {102/255, 0, 102/255}
        },
        [7] = {
            label = "Arcane",
            color = {102/255, 0, 204/255}
        }
    };

    local target_resi_label = sw_frame.loadouts_frame.rhs_list.target_buffs_frame:CreateFontString(nil, "OVERLAY");

    target_resi_label:SetFontObject(font);
    target_resi_label:SetPoint("TOPLEFT", 22, y_offset_rhs_target_buffs);
    target_resi_label:SetText("Presumed enemy resistances");

    y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 15;

    for i = 2, 7 do

        local resi_school_label = sw_frame.loadouts_frame.rhs_list.target_buffs_frame:CreateFontString(nil, "OVERLAY");

        resi_school_label:SetFontObject(font);
        resi_school_label:SetPoint("TOPLEFT", 22, y_offset_rhs_target_buffs);
        resi_school_label:SetText(target_resi_labels[i].label);
        resi_school_label:SetTextColor(
            target_resi_labels[i].color[1], target_resi_labels[i].color[2], target_resi_labels[i].color[3]
        );


        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i] = 
            CreateFrame("EditBox", "sw_"..target_resi_labels[i].label.."editbox", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, "InputBoxTemplate");

        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i].school_type = i;
        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetPoint("TOPLEFT", 130, y_offset_rhs_target_buffs);
        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetAutoFocus(false);
        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetSize(60, 10);
        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetScript("OnTextChanged", function(self)

            -- TODO: refactoring
            --if self:GetText() == "" then
            --    sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_res_by_school[self.school_type] = 0;

            --elseif not string.match(self:GetText(), "[^0123456789]") then
            --    sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_res_by_school[self.school_type] = tonumber(self:GetText());
            --else 
            --    self:ClearFocus();
            --    self:SetText(tostring(sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_res_by_school[self.school_type]));
            --end
        end);

        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetScript("OnEnterPressed", function(self)
        	self:ClearFocus()
        end);
        
        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetScript("OnEscapePressed", function(self)
        	self:ClearFocus()
        end);

        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetScript("OnTabPressed", function(self)

            local next_index = 0;
            if IsShiftKeyDown() then
                next_index = 1 + ((i-3) %num_target_resi_labels);
            else
                next_index = 1 + ((i-1) %num_target_resi_labels);

            end
        	self:ClearFocus()
            sw_frame.loadouts_frame.rhs_list.target_resi_editbox[next_index + 1]:SetFocus();
        end);


        y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 15;
    end

    sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_select_all_target_buffs", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetPoint("TOPLEFT", 20, y_offset_rhs_target_buffs);
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:GetName() .. 'Text'):SetText("SELECT ALL/NONE");
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:GetName() .. 'Text'):SetTextColor(1, 0, 0);
    sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetScript("OnClick", function(self)
        local loadout = active_loadout();
        if not loadout.always_assume_buffs then
            self:SetChecked(true)
            return;
        end
        if self:GetChecked() then
            
            for  i = 1, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs  do
                loadout.target_buffs[sw_frame.loadouts_frame.rhs_list.target_buffs[i].checkbutton.buff_lname] =
                    sw_frame.loadouts_frame.rhs_list.target_buffs[i].checkbutton.buff_info;
            end
        else
            loadout.target_buffs = {};
        end
        update_loadouts_rhs();
    end);


    y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
    y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;

    sw_frame.loadouts_frame.rhs_list.self_buffs_y_offset_start = y_offset_rhs_buffs;
    sw_frame.loadouts_frame.rhs_list.target_buffs_y_offset_start = y_offset_rhs_target_buffs;

    for k, v in pairs(buffs) do
        if bit.band(filter_flags_active, v.filter) ~= 0 then
            create_loadout_buff_checkbutton(
                sw_frame.loadouts_frame.rhs_list.buffs, k, v, "self", 
                sw_frame.loadouts_frame.rhs_list.self_buffs_frame, check_button_buff_func
            );
        end
    end
    for k, v in pairs(target_buffs) do
        if bit.band(filter_flags_active, v.filter) ~= 0 then
            create_loadout_buff_checkbutton(
                sw_frame.loadouts_frame.rhs_list.target_buffs, k, v, "target_buffs", 
                sw_frame.loadouts_frame.rhs_list.target_buffs_frame, check_button_buff_func
            );
        end
    end

    sw_frame.loadouts_frame.self_buffs_slider =
        CreateFrame("Slider", "sw_self_buffs_slider", sw_frame.loadouts_frame.rhs_list.self_buffs_frame, "OptionsSliderTemplate");
    sw_frame.loadouts_frame.self_buffs_slider:SetOrientation('VERTICAL');
    sw_frame.loadouts_frame.self_buffs_slider:SetPoint("TOPRIGHT", -10, -42);
    sw_frame.loadouts_frame.self_buffs_slider:SetSize(15, 505);
    sw_frame.loadouts_frame.rhs_list.buffs.num_buffs_can_fit =
        math.floor(sw_frame.loadouts_frame.self_buffs_slider:GetHeight()/20);
    sw_frame.loadouts_frame.self_buffs_slider:SetMinMaxValues(
        0, 
        max(0, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs - sw_frame.loadouts_frame.rhs_list.buffs.num_buffs_can_fit)
    );
    getglobal(sw_frame.loadouts_frame.self_buffs_slider:GetName()..'Text'):SetText("");
    getglobal(sw_frame.loadouts_frame.self_buffs_slider:GetName()..'Low'):SetText("");
    getglobal(sw_frame.loadouts_frame.self_buffs_slider:GetName()..'High'):SetText("");
    sw_frame.loadouts_frame.self_buffs_slider:SetValue(0);
    sw_frame.loadouts_frame.self_buffs_slider:SetValueStep(1);
    sw_frame.loadouts_frame.self_buffs_slider:SetScript("OnValueChanged", function(self, val)

        update_loadouts_rhs();
    end);

    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.loadouts_frame.self_buffs_slider:GetMinMaxValues();
        local val = sw_frame.loadouts_frame.self_buffs_slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.loadouts_frame.self_buffs_slider:SetValue(val - dir);
            update_loadouts_rhs();
        end
    end);

    sw_frame.loadouts_frame.target_buffs_slider =
        CreateFrame("Slider", "sw_target_buffs_slider", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, "OptionsSliderTemplate");
    sw_frame.loadouts_frame.target_buffs_slider:SetOrientation('VERTICAL');
    sw_frame.loadouts_frame.target_buffs_slider:SetPoint("TOPRIGHT", -10, -147);
    sw_frame.loadouts_frame.target_buffs_slider:SetSize(15, 400);
    sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs_can_fit = 
        math.floor(sw_frame.loadouts_frame.target_buffs_slider:GetHeight()/20);
    sw_frame.loadouts_frame.target_buffs_slider:SetMinMaxValues(
        0, 
        max(0, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs - sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs_can_fit)
    );
    getglobal(sw_frame.loadouts_frame.target_buffs_slider:GetName()..'Text'):SetText("");
    getglobal(sw_frame.loadouts_frame.target_buffs_slider:GetName()..'Low'):SetText("");
    getglobal(sw_frame.loadouts_frame.target_buffs_slider:GetName()..'High'):SetText("");
    sw_frame.loadouts_frame.target_buffs_slider:SetValue(0);
    sw_frame.loadouts_frame.target_buffs_slider:SetValueStep(1);
    sw_frame.loadouts_frame.target_buffs_slider:SetScript("OnValueChanged", function(self, val)
        update_loadouts_rhs();
    end);

    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.loadouts_frame.target_buffs_slider:GetMinMaxValues();
        local val = sw_frame.loadouts_frame.target_buffs_slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.loadouts_frame.target_buffs_slider:SetValue(val - dir);
            update_loadouts_rhs();
        end
    end);


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
            if action_id then
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

local event_dispatch = {
    ["UNIT_SPELLCAST_SUCCEEDED"] = function(self, msg, msg2, msg3)
        if msg3 == 53563 then  -- beacon
             addonTable.beacon_snapshot_time = addonTable.addon_running_time;
        end
    end,
    ["ADDON_LOADED"] = function(self, msg, msg2, msg3)
        if msg == "StatWeightsClassic" then
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
                        tooltip:AddLine("If this addon confuses you, instructions and pointers at");
                        tooltip:AddLine("https://www.curseforge.com/wow/addons/stat-weights-classic");
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
                sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:Hide();
            elseif sw_frame.stat_comparison_frame.sim_type  == simulation_type.cast_until_oom then
                sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Hide();
                sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:Show();
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
                __sw__persistent_data_per_char.loadouts.loadouts_list[1] = {};
                __sw__persistent_data_per_char.loadouts.loadouts_list[1].loadout = empty_loadout();
                default_loadout(__sw__persistent_data_per_char.loadouts.loadouts_list[1].loadout);
                __sw__persistent_data_per_char.loadouts.loadouts_list[1].equipped = {};
                __sw__persistent_data_per_char.loadouts.loadouts_list[1].talented = {};
                __sw__persistent_data_per_char.loadouts.loadouts_list[1].final_effects = {};
                empty_effects(__sw__persistent_data_per_char.loadouts.loadouts_list[1].equipped);
                empty_effects(__sw__persistent_data_per_char.loadouts.loadouts_list[1].talented);
                empty_effects(__sw__persistent_data_per_char.loadouts.loadouts_list[1].final_effects);
                __sw__persistent_data_per_char.loadouts.active_loadout = 1;
                __sw__persistent_data_per_char.loadouts.num_loadouts = 1;
            end

            sw_frame.loadouts_frame.lhs_list.loadouts = {};
            for k, v in pairs(__sw__persistent_data_per_char.loadouts.loadouts_list) do
                sw_frame.loadouts_frame.lhs_list.loadouts[k] = {};
                sw_frame.loadouts_frame.lhs_list.loadouts[k].loadout = empty_loadout();
                for kk, vv in pairs(v.loadout) do
                    -- for forward compatability: if there are changes to loadout in new version
                    -- we copy what we can from the old loadout
                    sw_frame.loadouts_frame.lhs_list.loadouts[k].loadout[kk] = v.loadout[kk];
                end
                
                sw_frame.loadouts_frame.lhs_list.loadouts[k].equipped = {};
                empty_effects(sw_frame.loadouts_frame.lhs_list.loadouts[k].equipped);
                effects_add(sw_frame.loadouts_frame.lhs_list.loadouts[k].equipped, v.equipped);
                sw_frame.loadouts_frame.lhs_list.loadouts[k].talented = {};
                sw_frame.loadouts_frame.lhs_list.loadouts[k].final_effects = {};
                empty_effects(sw_frame.loadouts_frame.lhs_list.loadouts[k].talented);
                empty_effects(sw_frame.loadouts_frame.lhs_list.loadouts[k].final_effects);
            end

            sw_frame.loadouts_frame.lhs_list.active_loadout = __sw__persistent_data_per_char.loadouts.active_loadout;
            sw_frame.loadouts_frame.lhs_list.num_loadouts = __sw__persistent_data_per_char.loadouts.num_loadouts;

            update_loadouts_lhs();

            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(true);

            sw_activate_tab(3);
            sw_frame:Hide();
        end
    end,
    ["PLAYER_LOGOUT"] = function(self, msg, msg2, msg3)
        if not class_is_supported then
            return;
        end
        if __sw__use_defaults__ then
            __sw__persistent_data_per_char = nil;
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
            __sw__persistent_data_per_char.loadouts.loadouts_list[k] = {};
            __sw__persistent_data_per_char.loadouts.loadouts_list[k].loadout = v.loadout;
            __sw__persistent_data_per_char.loadouts.loadouts_list[k].equipped = v.equipped;
        end
        __sw__persistent_data_per_char.loadouts.active_loadout = self.loadouts_frame.lhs_list.active_loadout;
        __sw__persistent_data_per_char.loadouts.num_loadouts = self.loadouts_frame.lhs_list.num_loadouts;

        -- save settings from ui
        save_sw_settings();
    end,
    ["PLAYER_LOGIN"] = function(self, msg, msg2, msg3)
        if not class_is_supported then
            return;
        end
        __sw__icon_frames = gather_spell_icons();
        update_icon_overlay_settings();

        sw_addon_loaded = true;
    end,
    ["ACTIONBAR_SLOT_CHANGED"] = function(self, msg, msg2, msg3)
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
            if __sw__icon_frames.bars[action_id] then
                for i = 1, 3 do
                    if __sw__icon_frames.bars[action_id].overlay_frames[i] then
                        __sw__icon_frames.bars[action_id].overlay_frames[i]:Hide();
                    end
                end
            end

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
    end,
    ["UPDATE_STEALTH"] = function(self, msg, msg2, msg3)
        if not sw_addon_loaded then
            return;
        end
        on_special_action_bar_changed();
    end,
    ["UPDATE_SHAPESHIFT_FORM"] = function(self, msg, msg2, msg3)
        if not sw_addon_loaded then
            return;
        end
        on_special_action_bar_changed();
    end,
    --["UNIT_AURA"] = function(self, msg, msg2, msg3)
    --    if msg == "player" or msg == "target" or msg == "mouseover" then
    --        buffs_update_needed = true;
    --    end
    --end,
    --["PLAYER_TARGET_CHANGED"] = function(self, msg, msg2, msg3)
    --    buffs_update_needed = true;
    --end,
    ["ACTIVE_TALENT_GROUP_CHANGED"] = function(self, msg, msg2, msg3)
        __sw__icon_frames = gather_spell_icons();
        update_icon_overlay_settings();
        if active_loadout_entry().loadout.is_dynamic_loadout then
            talents_update_needed = true;
        end
    end,
    ["CHARACTER_POINTS_CHANGED"] = function(self, msg)

        local loadout = active_loadout();
       
        if loadout.is_dynamic_loadout then

            loadout.talents_code = wowhead_talent_code();
            talents_update_needed = true;
            update_loadouts_rhs();
        end
    end,
    ["PLAYER_EQUIPMENT_CHANGED"] = function(self, msg, msg2, msg3)
        equipment_update_needed = true;
    end,
    ["GLYPH_ADDED"] = function(self, msg, msg2, msg3)
        if active_loadout_entry().loadout.is_dynamic_loadout then
            talents_update_needed = true;
        end
    end,
    ["GLYPH_REMOVED"] = function(self, msg, msg2, msg3)
        if active_loadout_entry().loadout.is_dynamic_loadout then
            talents_update_needed = true;
        end
    end,
    ["GLYPH_UPDATED"] = function(self, msg, msg2, msg3)
        if active_loadout_entry().loadout.is_dynamic_loadout then
            talents_update_needed = true;
        end
    end,
};

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

    --sw_frame:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
    --sw_frame:RegisterEvent("ACTIONBAR_UPDATE_STATE");
    for k, v in pairs(event_dispatch) do
        
        sw_frame:RegisterEvent(k);
    end
    if class ~= "PALADIN" then
        sw_frame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
    end
    sw_frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM");

    sw_frame:SetWidth(400);
    sw_frame:SetHeight(600);
    sw_frame:SetPoint("TOPLEFT", 400, -30);

    sw_frame.title = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.title:SetFontObject(font)
    sw_frame.title:SetText("Stat Weights Classic WOTLK");
    sw_frame.title:SetPoint("CENTER", sw_frame.TitleBg, "CENTER", 11, 0);

    sw_frame:SetScript("OnEvent", function(self, event, msg, msg2, msg3)
        event_dispatch[event](self, msg, msg2, msg3);
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
    sw_frame.tab3:SetWidth(150);
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
        elseif msg == "reset" then

            __sw__use_defaults__ = 1;
            ReloadUI();

        else
            sw_activate_tab(3);
        end
    end
end

if class_is_supported then
    GameTooltip:HookScript("OnTooltipSetSpell", function(tooltip, ...)
        local spell_name, spell_id = tooltip:GetSpell();
    
        local spell = spells[spell_id];
        if not spell then
            return;
        end

        local loadout, effects = active_loadout_and_effects();
    
        tooltip_spell_info(GameTooltip, spell, loadout, effects);
    
        if IsShiftKeyDown() and sw_frame.stat_comparison_frame:IsShown() and 
                not sw_frame.stat_comparison_frame.spells[spell_id] then
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

local function update_spell_icon_frame(frame_info, spell, spell_id, loadout, effects)

    if loadout.lvl > spell.lvl_outdated and not __sw__debug__ then
        -- low spell rank

        for i = 1, 3 do
            if not frame_info.overlay_frames[i] then
                frame_info.overlay_frames[i] = frame_info.frame:CreateFontString(nil, "OVERLAY");
            end
            frame_info.overlay_frames[i]:SetFont(
                icon_overlay_font, sw_frame.settings_frame.icon_overlay_font_size, "THICKOUTLINE");
        end

        frame_info.overlay_frames[1]:SetPoint("TOP", 1, -3);
        frame_info.overlay_frames[2]:SetPoint("CENTER", 1, -1.5);
        frame_info.overlay_frames[3]:SetPoint("BOTTOM", 1, 0);

        frame_info.overlay_frames[1]:SetText("OLD");
        frame_info.overlay_frames[2]:SetText("RANK");
        frame_info.overlay_frames[3]:SetText("!!!");

        for i = 1, 3 do
            frame_info.overlay_frames[i]:SetTextColor(252.0/255, 69.0/255, 3.0/255); 
            frame_info.overlay_frames[i]:Show();
        end
        
        return;
    end

    if not spell_cache[spell_id] then
        spell_cache[spell_id] = {};
        spell_cache[spell_id].dmg = {};
        spell_cache[spell_id].heal = {};
    end
    local spell_variant = spell_cache[spell_id].dmg;
    if bit.band(spell.flags, spell_flags.heal) then
        spell_variant = spell_cache[spell_id].heal;
    end
    if not spell_variant.seq then

        spell_variant.seq = -1;
        spell_variant.stats = {};
        spell_variant.spell_effect = {};
    end
    local spell_effect = spell_variant.spell_effect;
    local stats = spell_variant.stats;
    if spell_cache[spell_id].seq ~= sequence_counter then

        spell_cache[spell_id].seq = sequence_counter;
        stats_for_spell(stats, spell, loadout, effects);
        spell_info(spell_effect, spell, stats, loadout, effects);
        cast_until_oom_sim(spell_effect, stats, loadout, effects);
    end

    for i = 1, 3 do
        
        if sw_frame.settings_frame.icon_overlay[i] then
            if not frame_info.overlay_frames[i] then
                frame_info.overlay_frames[i] = frame_info.frame:CreateFontString(nil, "OVERLAY");

                frame_info.overlay_frames[i]:SetFont(
                    icon_overlay_font, sw_frame.settings_frame.icon_overlay_font_size, "THICKOUTLINE");

                if i == 1 then
                    frame_info.overlay_frames[i]:SetPoint("TOP", 1, -3);
                elseif i == 2 then
                    frame_info.overlay_frames[i]:SetPoint("CENTER", 1, -1.5);
                elseif i == 3 then 
                    frame_info.overlay_frames[i]:SetPoint("BOTTOM", 1, 0);
                end
            end
            if sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.normal then
                frame_info.overlay_frames[i]:SetText(string.format("%d",
                    (spell_effect.min_noncrit_if_hit + spell_effect.max_noncrit_if_hit)/2 + spell_effect.ot_if_hit + spell_effect.absorb));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.crit  then
                if spell_effect.ot_if_crit > 0  then
                    frame_info.overlay_frames[i]:SetText(string.format("%d",
                        (spell_effect.min_crit_if_hit + spell_effect.max_crit_if_hit)/2 + spell_effect.ot_if_crit + spell_effect.absorb));
                elseif spell_effect.min_crit_if_hit ~= 0.0 then
                    frame_info.overlay_frames[i]:SetText(string.format("%d", 
                        (spell_effect.min_crit_if_hit + spell_effect.max_crit_if_hit)/2 + spell_effect.ot_if_hit + spell_effect.absorb));
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
                frame_info.overlay_frames[i]:SetText(string.format("%d", stats.cost));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.avg_cast then
                frame_info.overlay_frames[i]:SetText(string.format("%.2f", stats.cast_time));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.hit and 
                 bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                    frame_info.overlay_frames[i]:SetText(string.format("%d%%", 100*stats.hit));

            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.crit_chance and
                    stats.crit ~= 0 then

                frame_info.overlay_frames[i]:SetText(string.format("%.1f%%", 100*max(0, min(1, stats.crit))));
                ---
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.casts_until_oom then
                frame_info.overlay_frames[i]:SetText(string.format("%.1f", spell_effect.num_casts_until_oom));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.effect_until_oom then
                frame_info.overlay_frames[i]:SetText(string.format("%.0f", spell_effect.effect_until_oom));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.time_until_oom then
                frame_info.overlay_frames[i]:SetText(string.format("%.1fs", spell_effect.time_until_oom));
            end
            frame_info.overlay_frames[i]:SetTextColor(sw_frame.settings_frame.icon_overlay[i].color[1], 
                                                      sw_frame.settings_frame.icon_overlay[i].color[2], 
                                                      sw_frame.settings_frame.icon_overlay[i].color[3]);

            frame_info.overlay_frames[i]:Show();
        end
    end
end

__sw__icon_frames = {};

local function update_spell_icons(loadout, effects)

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
                            update_spell_icon_frame(v, spells[id].healing_version, id, loadout, effects);
                        else
                            update_spell_icon_frame(v, spells[id], id, loadout, effects);
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
            if spells[id].healing_version and sw_frame.settings_frame.icon_heal_variant:GetChecked() then
                update_spell_icon_frame(v, spells[id].healing_version, id, loadout, effects);
            else
                update_spell_icon_frame(v, spells[id], id, loadout, effects);
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

if class_is_supported then
    create_sw_base_gui();

    UIParent:HookScript("OnUpdate", function(self, elapsed)
    
        addonTable.addon_running_time = addonTable.addon_running_time + snapshot_time_since_last_update;
        snapshot_time_since_last_update = snapshot_time_since_last_update + elapsed;
        
        if snapshot_time_since_last_update > 1/sw_snapshot_loadout_update_freq and 
                sw_num_icon_overlay_fields_active > 0 then

            update_spell_icons(active_loadout_and_effects());

            sequence_counter = sequence_counter + 1;
            snapshot_time_since_last_update = 0;
        end

    end)
else
    print("Stat Weights Classic currently does not support your class :(");
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
SLASH_STAT_WEIGHTS3 = "/statweightsclassic"
SLASH_STAT_WEIGHTS4 = "/swc"
SlashCmdList["STAT_WEIGHTS"] = command

--__sw__debug__ = 1;
--__sw__use_defaults__ = 1;
