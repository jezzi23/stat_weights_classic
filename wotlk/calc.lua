
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


local spells                            = addonTable.spells;
local spell_name_to_id                  = addonTable.spell_name_to_id;
local spell_names_to_id                 = addonTable.spell_names_to_id;
local magic_school                      = addonTable.magic_school;
local spell_flags                       = addonTable.spell_flags;
local best_rank_by_lvl                  = addonTable.best_rank_by_lvl;

local stat                              = addonTable.stat;
local loadout_flags                     = addonTable.loadout_flags;
local class                             = addonTable.class;

local effects_zero_diff                 = addonTable.effects_zero_diff;
local effects_diff                      = addonTable.effects_diff;

local set_tiers                         = addonTable.set_tiers;

local deep_table_copy                   = addonTable.deep_table_copy;

local buff_filters                      = addonTable.buff_filters;
local buff_category                     = addonTable.buff_category;
local filter_flags_active               = addonTable.filter_flags_active;
local buffs                             = addonTable.buffs;
local target_buffs                      = addonTable.target_buffs;
local non_stackable_effects             = addonTable.non_stackable_effects;
local loadout_flags                     = addonTable.loadout_flags;

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

-- TODO: this is probably still in use along with more wotlk scaling punishments
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
    local mana_regen = 5 * (0.001 + math.sqrt(int) * spirit * lvl_to_base_regen[level]) * 0.6;
    return mana_regen;
end

local special_abilities = nil;
if class == "SHAMAN" then
    special_abilities = {
        [spell_name_to_id["Chain Heal"]] = function(spell, info, loadout)
            if loadout.glyphs[55437] then
                info.expectation = (1 + 0.6 + 0.6*0.6 + 0.6*0.6*0.6) * info.expectation_st;
            else
                info.expectation = (1 + 0.6 + 0.6*0.6) * info.expectation_st;
            end
        end,
        [spell_name_to_id["Earth Shield"]] = function(spell, info, loadout)
            info.expectation = 6 * info.expectation_st;
        end,
        [spell_name_to_id["Lightning Shield"]] = function(spell, info, loadout)
            info.expectation = 3 * info.expectation_st;
        end,
        [spell_name_to_id["Chain Lightning"]] = function(spell, info, loadout)
            if loadout.glyphs[55449] then
                info.expectation = (1 + 0.7 + 0.7*0.7 + 0.7*0.7*0.7) * info.expectation_st;
            else
                info.expectation = (1 + 0.7 + 0.7*0.7) * info.expectation_st;
            end

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
        [spell_name_to_id["Prayer of Healing"]] = function(spell, info, loadout, stats, effects)

            if loadout.glyphs[55680] then
                
                info.ot_duration = 6;
                info.ot_freq = 3;
                info.ot_ticks = 2;

                -- some spell mods are applied again on the hot effect for some reason
                local special_mods = 1.0 + effects.raw.spell_heal_mod_mul;
                
                info.ot_if_hit = 0.2 * info.min_noncrit_if_hit * special_mods
                info.ot_if_hit_max = 0.2 * info.max_noncrit_if_hit * special_mods

                -- aegis
                local pts = loadout.talents_table:pts(1, 24);
                local overdue = (1.0 + 0.1 * pts);

                info.ot_if_crit = 0.2 * info.min_crit_if_hit * special_mods / overdue;
                info.ot_if_crit_max = 0.2 * info.max_crit_if_hit * special_mods / overdue;

                local expected_ot_if_hit = (1.0 - stats.crit) * 0.5 * (info.ot_if_hit + info.ot_if_hit_max) + stats.crit * 0.5 * (info.ot_if_crit + info.ot_if_crit_max);

                info.expectation_st = info.expectation_st + expected_ot_if_hit;
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
            if loadout.num_set_pieces[set_tiers.pve_t7_1] >= 2 then
                info.expectation = 6 * info.expectation_st;
            else
                info.expectation = 5 * info.expectation_st;
            end
        end,
        [spell_name_to_id["Power Word: Shield"]] = function(spell, info, loadout)

            info.absorb = info.min_noncrit_if_hit;

            if loadout.glyphs[55672] then
                local mod = 0.2 * info.healing_mod_from_absorb_glyph;
                info.healing_mod_from_absorb_glyph = nil;

                info.min_noncrit_if_hit = mod * info.min_noncrit_if_hit;
                info.max_noncrit_if_hit = mod * info.max_noncrit_if_hit;

                info.min_crit_if_hit = mod * info.min_crit_if_hit;
                info.max_crit_if_hit = mod * info.max_crit_if_hit;
                info.expectation_st = info.expectation_st * (1.0 + mod);
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
            if loadout.glyphs[62970] then
                info.expectation = 6 * info.expectation_st;
            else
                info.expectation = 5 * info.expectation_st;
            end
        end,
        [spell_name_to_id["Tranquility"]] = function(spell, info, loadout)
            info.expectation = 5 * info.expectation_st;
        end,
        [spell_name_to_id["Starfall"]] = function(spell, info, loadout)
            info.expectation = 20 * info.expectation_st;
        end,
        [spell_name_to_id["Swiftmend"]] = function(spell, info, loadout, stats)

            local num_ticks = 4;
            if stats.alias and stats.alias == spell_name_to_id["Regrowth"] then
                num_ticks = 6;
            end
            
            local heal_amount = stats.spell_mod * num_ticks * info.ot_if_hit/info.ot_ticks;
            
            info.min_noncrit_if_hit = heal_amount;
            info.max_noncrit_if_hit = heal_amount;

            info.min_crit_if_hit = stats.crit_mod*heal_amount;
            info.max_crit_if_hit = stats.crit_mod*heal_amount;

            info.min = stats.hit * ((1 - stats.crit) * info.min_noncrit_if_hit + (stats.crit * info.min_crit_if_hit));
            info.max = stats.hit * ((1 - stats.crit) * info.max_noncrit_if_hit + (stats.crit * info.max_crit_if_hit));

            info.expectation_st = 0.5 * (info.min + info.max);
            info.expectation = info.expectation_st;

            -- clear over time
            info.ot_if_hit = 0.0;
            info.ot_if_hit_max = 0.0;
            info.ot_if_crit = 0.0;
            info.ot_if_crit_max = 0.0;
            info.ot_ticks = 0;
            info.expected_ot_if_hit = 0.0;
            info.ot_duration = 0.0;
            info.ot_freq = 0.0;
        end,
    };
elseif class == "WARLOCK" then
    special_abilities = {
        [spell_name_to_id["Shadow Cleave"]] = function(spell, info, loadout)
            info.expectation = 3 * info.expectation_st;
        end,
        [spell_name_to_id["Conflagrate"]] = function(spell, info, loadout, stats)

            local immolate_effect = stats.spell_mod * info.ot_if_hit;
            local direct = 0.6 * immolate_effect;
            
            -- direct component
            info.min_noncrit_if_hit = direct;
            info.max_noncrit_if_hit = direct;

            info.min_crit_if_hit = stats.crit_mod*direct;
            info.max_crit_if_hit = stats.crit_mod*direct;

            info.min = stats.hit * ((1 - stats.crit) * info.min_noncrit_if_hit + (stats.crit * info.min_crit_if_hit));
            info.max = stats.hit * ((1 - stats.crit) * info.max_noncrit_if_hit + (stats.crit * info.max_crit_if_hit));


            -- over time component
            info.ot_ticks = 3;
            info.ot_duration = 6.0;
            info.ot_freq = 2.0;

            info.ot_if_hit = 0.4 * immolate_effect;
            info.ot_if_hit_max = info.ot_if_hit;
            info.ot_if_crit = info.ot_if_hit * stats.crit_mod;
            info.ot_if_crit_max = info.ot_if_crit;

            local expected_ot_if_hit = (1.0 - stats.ot_crit) * 0.5 * (info.ot_if_hit + info.ot_if_hit_max) + stats.ot_crit * 0.5 * (info.ot_if_crit + info.ot_if_crit_max);
            info.expected_ot = stats.hit * expected_ot_if_hit;

            -- combined
            info.expectation_st = 0.5 * (info.min + info.max) + info.expected_ot;
            info.expectation = info.expectation_st + info.expected_ot;
        end,
    };
elseif class == "PALADIN" then
    special_abilities = {
        [spell_name_to_id["Holy Light"]] = function(spell, info, loadout)
            if loadout.glyphs[54937] then
                -- splash for 10% of heal to 5 targets
                info.expectation = 1.5 * info.expectation_st;
            end
        end,
        [spell_name_to_id["Avenger's Shield"]] = function(spell, info, loadout)
            info.expectation = 3 * info.expectation_st;
        end,
    };
else
    special_abilities = {};
end

local function set_alias_spell(spell, loadout)

    local alias_spell = spell;

    local swiftmend = spell_name_to_id["Swiftmend"];
    local conflagrate = spell_name_to_id["Conflagrate"];
    if spell.base_id == swiftmend then
        alias_spell = spells[best_rank_by_lvl[spell_name_to_id["Rejuvenation"]]];
        if bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0 then
            local rejuv_buff = loadout.dynamic_buffs[loadout.friendly_towards][GetSpellInfo(774)];
            local regrowth_buff = loadout.dynamic_buffs[loadout.friendly_towards][GetSpellInfo(8936)];
            if regrowth_buff then
                if not rejuv_buff or regrowth_buff.dur < rejuv_buff.dur then
                    alias_spell = spells[best_rank_by_lvl[spell_name_to_id["Regrowth"]]];
                end
            end
        end
    elseif spell.base_id == conflagrate then
        alias_spell = spells[best_rank_by_lvl[spell_name_to_id["Immolate"]]];
        if bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0 and
            loadout.hostile_towards == "target" and
            loadout.dynamic_buffs["target"][GetSpellInfo(61291)] and
            not loadout.dynamic_buffs["target"][GetSpellInfo(348)] then

            alias_spell = spells[best_rank_by_lvl[spell_name_to_id["Shadowflame"]]];
        end
    end

    return alias_spell;
end

local function stats_for_spell(stats, spell, loadout, effects)

    local original_base_cost = spell.cost_base_percent;
    local original_spell_id = spell.base_id;
    -- deal with aliasing spells
    if not stats.no_alias then
        spell = set_alias_spell(spell, loadout);
    end

    stats.crit = loadout.spell_crit_by_school[spell.school] +
        effects.by_school.spell_crit[spell.school];
    if spell.base_id == spell_name_to_id["Frostfire Bolt"] then
        stats.crit = math.max(stats.crit, loadout.spell_crit_by_school[magic_school.frost] +
            effects.by_school.spell_crit[magic_school.frost]);
    end
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

    stats.crit_mod = 1.5;
    if bit.band(spell.flags, spell_flags.double_crit) ~= 0 then
        stats.crit_mod = 2.0;
    end

    local extra_crit_mod = effects.by_school.spell_crit_mod[spell.school]
    if spell.base_id == spell_name_to_id["Frostfire Bolt"] then
        extra_crit_mod = math.max(extra_crit_mod, effects.by_school.spell_crit_mod[magic_school.frost]);
    end
    if effects.ability.crit_mod[spell.base_id] then
        extra_crit_mod = extra_crit_mod + effects.ability.crit_mod[spell.base_id];
    end
    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then

        stats.crit_mod = stats.crit_mod * (1.0 + effects.raw.special_crit_mod);
        stats.crit_mod = stats.crit_mod + (stats.crit_mod - 1.0)*2*extra_crit_mod;
    else
        stats.crit_mod = stats.crit_mod + 0.5*effects.raw.special_crit_heal_mod;
        if effects.ability.crit_mod[spell.base_id] then
            stats.crit_mod = stats.crit_mod + effects.ability.crit_mod[spell.base_id];
        end

    end

    local target_vuln_mod = 1.0;
    local target_vuln_ot_mod = 1.0;

    if effects.ability.vuln_mod[spell.base_id] then
        target_vuln_mod = target_vuln_mod + effects.ability.vuln_mod[spell.base_id];
    end
    
    target_vuln_ot_mod = target_vuln_mod;

    if effects.ability.vuln_ot_mod[spell.base_id] then
        target_vuln_ot_mod =  target_vuln_ot_mod + effects.ability.vuln_ot_mod[spell.base_id];
    end

    local global_mod = 1.0;
    stats.spell_mod = 1.0;
    stats.spell_ot_mod = 1.0;
    stats.flat_addition = 0;
    local resource_refund = effects.raw.resource_refund;

    if not effects.ability.effect_mod[spell.base_id] then
        effects.ability.effect_mod[spell.base_id] = 0.0;
    end
    if not effects.ability.effect_ot_mod[spell.base_id] then
        effects.ability.effect_ot_mod[spell.base_id] = 0.0;
    end

    if effects.ability.flat_add[spell.base_id] then
        stats.flat_addition = effects.ability.flat_add[spell.base_id];
    end
    stats.flat_addition_ot = stats.flat_addition;
    if effects.ability.flat_add_ot[spell.base_id] then
        stats.flat_addition_ot = stats.flat_addition_ot + effects.ability.flat_add_ot[spell.base_id];
    end

    stats.gcd = 1.0;

    local cost_mod_base = effects.raw.cost_mod_base;
    if effects.ability.cost_mod_base[spell.base_id] then
        cost_mod_base = cost_mod_base + effects.ability.cost_mod_base[spell.base_id];
    end
    stats.cost = math.floor(math.floor(original_base_cost * base_mana_pool()-effects.raw.cost_flat) * (1.0 - cost_mod_base));
    
    if effects.ability.cost_flat[spell.base_id] then
        stats.cost = stats.cost - effects.ability.cost_flat[spell.base_id];
    end
    local cost_mod = 1 - effects.raw.cost_mod;

    if effects.ability.cost_mod[spell.base_id] then
        cost_mod = cost_mod - effects.ability.cost_mod[spell.base_id]
    end

    local cast_mod_mul = 0.0;

    stats.extra_hit = effects.by_school.spell_dmg_hit[spell.school];
    if spell.base_id == spell_name_to_id["Frostfire Bolt"] then
        stats.extra_hit = math.max(stats.extra_hit, effects.by_school.spell_dmg_hit[magic_school.frost]);
    end
    if effects.ability.hit[spell.base_id] then
        stats.extra_hit = stats.extra_hit + effects.ability.hit[spell.base_id];
    end

    local hit_rating_per_perc = get_combat_rating_effect(CR_HIT_SPELL, loadout.lvl);
    local hit_from_rating = 0.01 * (loadout.hit_rating + effects.raw.hit_rating)/hit_rating_per_perc
    stats.extra_hit = stats.extra_hit + hit_from_rating;

    stats.hit = spell_hit(loadout.lvl, loadout.target_lvl, stats.extra_hit);
    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
        stats.hit = 1.0;
    else
        stats.hit = math.min(1.0, stats.hit);
    end

    if class == "PRIEST" then
        if spell.base_id == spell_name_to_id["Flash Heal"] and loadout.friendly_hp_perc and loadout.friendly_hp_perc <= 0.5  then
            local pts = loadout.talents_table:pts(1, 20);
            stats.crit = stats.crit + pts * 0.04;
        end
        -- test of faith
        if loadout.friendly_hp_perc and loadout.friendly_hp_perc <= 0.5 then
            effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + 0.04 * loadout.talents_table:pts(2, 25);
        end
        if spell.base_id == spell_name_to_id["Shadow Word: Death"] and loadout.enemy_hp_perc and loadout.enemy_hp_perc <= 0.35 then
            target_vuln_mod = target_vuln_mod + 0.1;
        end
        --shadow form
        local shadow_form, _, _, _, _, _, _ = GetSpellInfo(15473);
        if (loadout.buffs[shadow_form] and bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0) or
            (loadout.dynamic_buffs["player"][shadow_form] and bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0) then
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
        if pts ~= 0 and spell_name_to_id["Lifebloom"] then
            stats.gcd = stats.gcd - pts * 0.02;
        end

        --moonkin form
        local moonkin_form, _, _, _, _, _, _ = GetSpellInfo(24858);
        if (loadout.buffs[moonkin_form] and bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0) or
            (loadout.dynamic_buffs["player"][moonkin_form] and bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0) then
            resource_refund = resource_refund + stats.hit*stats.crit * 0.02 * loadout.max_mana;
        end

        --improved insect swarm talent
        local insect_swarm = spell_name_to_id["Insect Swarm"];
        if (loadout.target_buffs[insect_swarm] and bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0) or
            (loadout.dynamic_buffs["target"][insect_swarm] and bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0) then
            if spell.base_id == spell_name_to_id["Wrath"] then
                global_mod = global_mod + 0.01 * loadout.talents_table:pts(1, 14);
                --target_vuln_mod = target_vuln_mod * (1.0 + 0.01 * loadout.talents_table:pts(1, 14));
                --796
            end
        end

        if (bit.band(spell_flags.heal, spell.flags) ~= 0 and spell.base_min ~= 0 and spell.base_id ~= spell_name_to_id["Lifebloom"])
            or spell.base_id == spell_name_to_id["Rejuvenation"] or spell.base_id == spell_name_to_id["Swiftmend"] then
            -- living seed
            local pts = loadout.talents_table:pts(3, 21);
            stats.crit_mod = stats.crit_mod * (1 + 0.1 * pts);
        end

        if loadout.glyphs[54754] and spell.base_id == spell_name_to_id["Rejuvenation"] and loadout.friendly_hp_perc and loadout.friendly_hp_perc <= 0.5  then
            target_vuln_ot_mod = target_vuln_ot_mod + 0.5;
        end

        -- clearcast (omen of clarity)
        local pts = loadout.talents_table:pts(3, 8);
        if pts ~= 0 then
            cost_mod = cost_mod*0.9;
        end

        
    elseif class == "PALADIN" and bit.band(spell.flags, spell_flags.heal) ~= 0 then
        -- illumination
        local pts = loadout.talents_table:pts(1, 7);
        if pts ~= 0 then
            local mana_refund = 0.3 * original_base_cost * base_mana_pool();
            resource_refund = resource_refund + stats.crit * pts*0.2 * mana_refund;
        end

        -- tier 8 p2 holy bonus
        if loadout.num_set_pieces[set_tiers.pve_t8_1] >= 2 and bit.band(spell.flags, spell_flags.heal) ~= 0 and
            spell.base_id == spell_name_to_id["Holy Shock"] then

            stats.crit_mod = stats.crit_mod * 1.15;
        end

        local pts = loadout.talents_table:pts(2, 1);
        if pts ~= 0 and UnitName(loadout.friendly_towards) == UnitName("player") then
            target_vuln_mod = target_vuln_mod + pts * 0.01;
            target_vuln_ot_mod = target_vuln_ot_mod + pts * 0.01;
        end


    elseif class == "SHAMAN" then
        -- shaman clearcast
        -- elemental focus
        local pts = loadout.talents_table:pts(1, 7);
        if pts ~= 0 and spell.base_min ~= 0 and bit.band(spell.flags, spell_flags.heal) == 0 then
            local not_crit = 1.0 - (stats.crit*stats.hit);
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
            if loadout.num_set_pieces[set_tiers.pve_t7_3] >= 2 then
                water_shield_proc_gain = water_shield_proc_gain * 1.1;
            end
            resource_refund = resource_refund + stats.crit * mana_proc_chance * water_shield_proc_gain;
        end

        local pts = loadout.talents_table:pts(3, 22);
        if pts ~= 0 and
            (spell.base_id == spell_name_to_id["Healing Wave"] or
             spell.base_id == spell_name_to_id["Lesser Healing Wave"] or
             spell.base_id == spell_name_to_id["Riptide"]) then

            stats.crit_mod = stats.crit_mod * (1.0 + pts * 0.1);
        end

        if loadout.glyphs[55442] ~= 0 and
            (spell.base_id == spell_name_to_id["Flame Shock"] or
             spell.base_id == spell_name_to_id["Frost Shock"] or
             spell.base_id == spell_name_to_id["Earth Shock"]) then

            stats.gcd = stats.gcd - 0.5;
        end

        -- tier 8 ele p4 bonus
        if loadout.num_set_pieces[set_tiers.pve_t8_1] >= 4 and
            spell.base_id == spell_name_to_id["Lightning Bolt"] then

            stats.crit_mod = stats.crit_mod * 1.08;
        end
        
    elseif class == "MAGE" then

        -- clearcast
        local pts = loadout.talents_table:pts(1, 6);
        if pts ~= 0 then
            cost_mod = cost_mod*(1.0 - 0.02 * pts);
        end

        local pts = loadout.talents_table:pts(2, 13);
        if pts ~= 0 then
            -- master of elements
            local mana_refund = pts * 0.1 * original_base_cost * base_mana_pool();
            resource_refund = resource_refund + stats.hit*stats.crit * mana_refund;
        end

        -- ignite
        local pts = loadout.talents_table:pts(2, 4);
        if pts ~= 0 and spell.school == magic_school.fire then
            stats.crit_mod = stats.crit_mod * (1.0 + pts * 0.08);
        end

        -- molten fury
        local pts = loadout.talents_table:pts(2, 21);
        if loadout.enemy_hp_perc and loadout.enemy_hp_perc <= 0.35 then
            target_vuln_mod = target_vuln_mod + 0.06 * pts;
            target_vuln_ot_mod = target_vuln_ot_mod + 0.06 * pts;
        end

        -- torment of the weak
        local pts = loadout.talents_table:pts(1, 14);
        if bit.band(loadout.flags, loadout_flags.target_snared) ~= 0 then
            if spell.base_id == spell_name_to_id["Frostbolt"] or
                spell.base_id == spell_name_to_id["Fireball"] or
                spell.base_id == spell_name_to_id["Frostfire Bolt"] or
                spell.base_id == spell_name_to_id["Pyroblast"] or
                spell.base_id == spell_name_to_id["Arcane Missiles"] or
                spell.base_id == spell_name_to_id["Arcane Blast"] or
                spell.base_id == spell_name_to_id["Arcane Barrage"] then

                target_vuln_mod = target_vuln_mod + 0.04 * pts;
                target_vuln_ot_mod = target_vuln_ot_mod + 0.04 * pts;
            end
        end

        if bit.band(loadout.flags, loadout_flags.target_frozen) ~= 0 then

            local pts = loadout.talents_table:pts(3, 13);
            stats.crit = stats.crit + pts*0.5/3;
            stats.ot_crit = stats.ot_crit + pts*0.5/3;

            if spell.base_id == spell_name_to_id["Ice Lance"] then
                if loadout.glyphs[56377] and loadout.lvl < loadout.target_lvl then
                    target_vuln_mod = target_vuln_mod * 4;
                else
                    target_vuln_mod = target_vuln_mod * 3;
                end
            end
        end

    elseif class == "WARLOCK" then
        if loadout.talents_table:pts(1, 10) ~= 0 and bit.band(spell.flags, spell_flags.curse) ~= 0 then
            stats.gcd = stats.gcd - 0.5;
        end

        -- death's embrace
        local pts = loadout.talents_table:pts(1, 24);
        if pts ~= 0 then
            if spell.base_id == spell_name_to_id["Drain Life"] and
                loadout.player_hp_perc and loadout.player_hp_perc <= 0.2 then
                target_vuln_ot_mod = target_vuln_ot_mod + pts*0.1;
            end
            if spell.school == magic_school.shadow and loadout.enemy_hp_perc and loadout.enemy_hp_perc <= 0.35 then
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
        if pts ~= 0 and spell.base_id == spell_name_to_id["Soul Fire"] and loadout.enemy_hp_perc and loadout.enemy_hp_perc <= 0.35 then
            cast_mod_mul = (1.0 + cast_mod_mul) * (1.0 + 0.2 * pts) - 1.0;
        end

        if loadout.glyphs[56229] and spell.base_id == spell_name_to_id["Shadowburn"] and loadout.enemy_hp_perc and loadout.enemy_hp_perc <= 0.35 then
            stats.crit = stats.crit + 0.2;
        end

        -- drain soul execute
        if loadout.enemy_hp_perc and loadout.enemy_hp_perc <= 0.25 then
            target_vuln_mod = target_vuln_mod + 3;
            target_vuln_ot_mod = target_vuln_ot_mod + 3;
        end
    end

    stats.cast_time = spell.cast_time;
    if effects.ability.cast_mod[spell.base_id] then
        stats.cast_time = stats.cast_time - effects.ability.cast_mod[spell.base_id];
    end
    if effects.ability.cast_mod_mul[spell.base_id] then
        stats.cast_time = stats.cast_time/(1.0 + effects.ability.cast_mod_mul[spell.base_id]);
    end
    stats.cast_time = stats.cast_time/(1.0 + cast_mod_mul);


    -- apply global haste which has been multiplied at each step
    local haste_rating_per_perc = get_combat_rating_effect(CR_HASTE_SPELL, loadout.lvl);
    local haste_from_rating = 0.01 * max(0.0, loadout.haste_rating + effects.raw.haste_rating) / haste_rating_per_perc;

    stats.haste_mod = (1.0 + effects.raw.haste_mod) * (1.0 + haste_from_rating);

    stats.cast_time = math.max(stats.cast_time/stats.haste_mod, stats.gcd);

    if effects.ability.cast_mod_reduce[spell.base_id] then
        -- final vanilla style reduction but also reduces gcd (rare)
        stats.cast_time = stats.cast_time * (1.0 - effects.ability.cast_mod_reduce[spell.base_id]);
    end

    -- nature's grace
    local pts = loadout.talents_table:pts(1, 7);
    if class == "DRUID" and pts ~= 0 and spell.base_min ~= 0 then

        -- 
        local casts_in_3_sec_wo_grace = math.floor(3/stats.cast_time);
        local uptime_wo_grace = 1.0 - math.pow(1.0-stats.crit*pts/3, casts_in_3_sec_wo_grace);
        local casts_in_3_sec = math.floor((1.0 + 0.2*uptime_wo_grace)*3/stats.cast_time);
        local uptime = 1.0 - math.pow(1.0-stats.crit*pts/3, casts_in_3_sec);

        local optimizable_cast_time = math.max(stats.cast_time - stats.gcd, 0);
        local effective_haste = math.min(optimizable_cast_time, 0.2*stats.gcd); -- [0;0.2*gcd]%
        
        stats.cast_time = math.max(stats.cast_time/(1.0 + effective_haste*uptime), stats.gcd);
    end

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

        stats.spell_mod = target_vuln_mod * global_mod *
            ((1.0 + effects.ability.effect_mod[spell.base_id]));

        stats.spell_ot_mod = target_vuln_mod * global_mod *
            ((1.0 + effects.ability.effect_mod[spell.base_id] + effects.ability.effect_ot_mod[spell.base_id]));
        -- hacky special case for power word: shield glyph as it scales with healing
        stats.spell_heal_mod = (1.0 + effects.raw.spell_heal_mod_mul)
            *
            (1.0 + effects.ability.effect_ot_mod[spell.base_id] +  effects.raw.spell_heal_mod);
    else 
        target_vuln_mod = target_vuln_mod * (1.0 + effects.by_school.target_spell_dmg_taken[spell.school]);
        target_vuln_ot_mod = target_vuln_ot_mod * (1.0 + effects.by_school.target_spell_dmg_taken[spell.school]);

        local spell_dmg_mod_school = effects.by_school.spell_dmg_mod[spell.school];
        local spell_dmg_mod_school_add = effects.by_school.spell_dmg_mod_add[spell.school];

        if spell.base_id == spell_name_to_id["Frostfire Bolt"] then
            spell_dmg_mod_school = (1.0 + spell_dmg_mod_school) * (1.0 + effects.by_school.spell_dmg_mod[magic_school.frost]) - 1.0;
            spell_dmg_mod_school_add = (1.0 + spell_dmg_mod_school_add) * (1.0 + effects.by_school.spell_dmg_mod_add[magic_school.frost]) - 1.0;
        end

        stats.spell_mod = target_vuln_mod * global_mod
            *
            (1.0 + spell_dmg_mod_school)
            *
            (1.0 + effects.raw.spell_dmg_mod_mul)
            *
            (1.0 + effects.raw.spell_dmg_mod)
            *
            (1.0 + effects.ability.effect_mod[spell.base_id] + spell_dmg_mod_school_add);

        stats.spell_ot_mod = target_vuln_ot_mod * global_mod
            *
            (1.0 + spell_dmg_mod_school)
            *
            (1.0 + effects.raw.spell_dmg_mod_mul)
            *
            (1.0 + effects.raw.spell_dmg_mod)
            *
            (1.0 + effects.ability.effect_mod[spell.base_id] + effects.ability.effect_ot_mod[spell.base_id] + spell_dmg_mod_school_add + effects.raw.ot_mod);
    end

    if bit.band(spell.flags, spell_flags.alias) ~= 0 then
        stats.spell_mod = 1.0 + effects.ability.effect_mod[spell.base_id];
        stats.spell_ot_mod = 1.0 + effects.ability.effect_mod[spell.base_id];
    end

    stats.ot_extra_ticks = effects.ability.extra_ticks[spell.base_id];
    if not stats.ot_extra_ticks then
       stats.ot_extra_ticks = 0.0;
    end

    if bit.band(spell.flags, spell_flags.heal) ~= 0 or bit.band(spell.flags, spell_flags.absorb) ~= 0 then
        stats.spell_power = loadout.spell_power + effects.raw.healing_power;
    else
        stats.spell_power = loadout.spell_power + loadout.spell_dmg_by_school[spell.school];
    end
    stats.spell_power = stats.spell_power + effects.raw.spell_power;

    if bit.band(spell.flags, spell_flags.hybrid_scaling) ~= 0 then
        
        stats.spell_power = stats.spell_power + loadout.attack_power;
    end

    if effects.ability.sp[spell.base_id] then
        stats.spell_power = stats.spell_power + effects.ability.sp[spell.base_id];
    end
    stats.spell_power_ot = stats.spell_power;
    if effects.ability.sp_ot[spell.base_id] then
        stats.spell_power_ot = stats.spell_power_ot + effects.ability.sp_ot[spell.base_id];
    end

    stats.target_resi = 0;
    if bit.band(spell.flags, spell_flags.heal) == 0 then
        -- mod res by school currently used to snapshot equipment and set bonuses
        stats.target_resi = math.max(0, effects.by_school.target_res[spell.school] + effects.by_school.target_mod_res[spell.school]);
    end

    stats.target_avg_resi = target_avg_magical_res(loadout.lvl, stats.target_resi);

    stats.cost = stats.cost * cost_mod;
    -- is this rounding correct?
    stats.cost = math.floor(stats.cost + 0.5);
    --stats.cost = math.floor(stats.cost);
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

    local lvl_scaling = level_scaling(spell.lvl_req);
    stats.coef = spell.coef * lvl_scaling;
    stats.ot_coef = spell.over_time_coef *lvl_scaling;

    if effects.ability.coef_mod[spell.base_id] then
        stats.coef = stats.coef + effects.ability.coef_mod[spell.base_id];
    end
    if effects.ability.coef_ot_mod[spell.base_id] then
        stats.ot_coef = stats.ot_coef * (1.0 + effects.ability.coef_ot_mod[spell.base_id]);
    end

    stats.cost_per_sec = stats.cost / stats.cast_time;

    spell = spells[original_spell_id];
end

local function spell_info(info, spell, stats, loadout, effects)

    -- deal with aliasing spells
    local original_spell_id = spell.base_id;

    spell = set_alias_spell(spell, loadout);

    local base_min = spell.base_min;
    local base_max = spell.base_max;
    local base_ot_tick = spell.over_time;
    local base_ot_tick_max = spell.over_time;
    if bit.band(spell.flags, spell_flags.over_time_range) ~= 0 then
        base_ot_tick_max = spell.over_time_max;
    end

    -- level scaling
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

    info.ot_freq = spell.over_time_tick_freq;
    info.ot_duration = spell.over_time_duration;

    if spell.cast_time == spell.over_time_duration then
        info.ot_freq = spell.over_time_tick_freq*(stats.cast_time/spell.over_time_duration);
        info.ot_duration = stats.cast_time;
    end
    if bit.band(spell.flags, spell_flags.duration_haste_scaling) ~= 0 then
        info.ot_freq  = spell.over_time_tick_freq/stats.haste_mod;
        info.ot_duration = info.ot_duration/stats.haste_mod;
    end

    -- certain ticks may tick faster
    if class == "PRIEST" then
        local shadow_form, _, _, _, _, _, _ = GetSpellInfo(15473);
        if (loadout.buffs[shadow_form] and bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0) or
            (loadout.dynamic_buffs["player"][shadow_form] and bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0) then
            if spell.base_id == spell_name_to_id["Devouring Plague"] or spell.base_id == spell_name_to_id["Vampiric Touch"] then
                info.ot_freq  = spell.over_time_tick_freq/stats.haste_mod;
                info.ot_duration = info.ot_duration/stats.haste_mod;
            end
        end

        if loadout.glyphs[55672] and spell.base_id == spell_name_to_id["Power Word: Shield"] then
            info.healing_mod_from_absorb_glyph = stats.spell_heal_mod;
        end
    elseif class == "WARLOCK" then
        local immolate, _, _, _, _, _, _ = GetSpellInfo(348);
        if (loadout.target_buffs[immolate] and bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0) or
            (loadout.dynamic_buffs["target"][immolate] and bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0) then
            if spell.base_id == spell_name_to_id["Incinerate"] then
                base_min = base_min + math.floor((base_min-0.001) * 0.25);
                base_max = base_max + math.floor(base_max * 0.25);
            end
        end
        -- glyph of quick decay
        if loadout.glyphs[70947] and spell.base_id == spell_name_to_id["Corruption"] then
            info.ot_freq  = spell.over_time_tick_freq/stats.haste_mod;
            info.ot_duration = info.ot_duration/stats.haste_mod;
        end
    elseif class == "MAGE" then
        -- glyph of fireball
        if loadout.glyphs[56368] and spell.base_id == spell_name_to_id["Fireball"] then
            base_ot_tick = 0.0;
            info.ot_freq = 0;
            info.ot_duration = 0;
        end
        -- glyph of living bomb
        if loadout.glyphs[63091] and spell.base_id == spell_name_to_id["Living Bomb"] then
            stats.ot_crit = stats.crit;
        end
    elseif class == "DRUID" then

        -- rapid rejvenation
        if loadout.glyphs[71013] and spell.base_id == spell_name_to_id["Rejuvenation"] then
            info.ot_freq  = spell.over_time_tick_freq/stats.haste_mod;
            info.ot_duration = info.ot_duration/stats.haste_mod;
        end
        -- t8 resto rejuv bonus
        if loadout.num_set_pieces[set_tiers.pve_t8_3] >= 4 and spell.base_id == spell_name_to_id["Rejuvenation"] then

            base_min = spell.over_time;
            base_max = spell.over_time;
            stats.coef = stats.ot_coef;
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
    info.ot_if_crit = 0.0;
    info.ot_if_crit_max = 0.0;
    info.ot_ticks = 0;

    if base_ot_tick > 0 then

        local base_ot_num_ticks = (info.ot_duration/info.ot_freq);
        local ot_coef_per_tick = stats.ot_coef

        info.ot_ticks = base_ot_num_ticks + stats.ot_extra_ticks;

        info.ot_if_hit = (base_ot_tick + ot_coef_per_tick * stats.spell_power_ot + stats.flat_addition_ot) * info.ot_ticks * stats.spell_ot_mod;
        info.ot_if_hit_max = (base_ot_tick_max + ot_coef_per_tick * stats.spell_power_ot + stats.flat_addition_ot) * info.ot_ticks * stats.spell_ot_mod;

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

        local channel_ratio_time_lost_to_miss = 1 - (info.ot_duration - 1.5/stats.haste_mod)/info.ot_duration;
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

    info.expectation_direct = 0.5 * (info.min + info.max);

    info.expectation = info.expectation_direct + info.expected_ot;

    info.expectation = info.expectation * (1 - stats.target_avg_resi);

    info.expectation_st = info.expectation;

    if original_spell_id ~= spell.base_id then
        -- using alias for swiftmend/conflagrate
        -- we have the context for the aliased spell but now
        -- switch back to stats for the original spell,
        stats.alias = spell.base_id;
        spell = spells[original_spell_id];
        stats.no_alias = true;
        stats_for_spell(stats, spell, loadout, effects);
        stats.no_alias = nil;
    end

    if special_abilities[original_spell_id] then
        special_abilities[original_spell_id](spell, info, loadout, stats, effects);
    end
    stats.alias = nil;

    if loadout.beacon then
        -- holy light glyph may have been been applied to expectation
        info.expectation = info.expectation + info.expectation_st;
    end

    info.effect_per_sec = info.expectation/stats.cast_time;

    info.effect_per_cost = info.expectation/stats.cost;
    info.cost_per_sec = stats.cost/stats.cast_time;
    info.ot_duration = info.ot_duration + stats.ot_extra_ticks * info.ot_freq;
    if bit.band(spell.flags, spell_flags.cast_with_ot_dur) ~= 0 then
        info.effect_per_dur = info.expectation/math.max(info.ot_duration + stats.cast_time);
    else
        info.effect_per_dur = info.expectation/math.max(info.ot_duration, stats.cast_time);
    end

    if bit.band(spell.flags, spell_flags.mana_regen) ~= 0 then
        if spell.base_id == spell_name_to_id["Innervate"] then
            if loadout.glyphs[54832] then
                info.mana_restored = base_mana_pool()*2.70;
            else
                info.mana_restored = base_mana_pool()*2.25;
            end
        elseif spell.base_id == spell_name_to_id["Life Tap"] then
            info.mana_restored = spell.base_min + stats.spell_power*spell.coef;

            local pts = loadout.talents_table:pts(1, 6);
            info.mana_restored = info.mana_restored * (1.0 + pts*0.1);
        elseif spell.base_id == spell_name_to_id["Shadowfiend"] then
            info.mana_restored = 0.05*loadout.max_mana*10;
        else
            -- evocate, mana tide, divine plea of % max mana
            info.mana_restored = spell.base_min * loadout.max_mana;
        end
    end
end


local function spell_info_from_stats(spell_info, stats, spell, loadout, effects)

    stats_for_spell(stats, spell, loadout, effects);
    spell_info(spell_info, spell, stats, loadout, effects);
end

local function cast_until_oom(spell_effect, stats, loadout, effects, calculating_weights)

    calculating_weights = calculating_weights or false;

    local num_casts = 0;
    local effect = 0;

    local mana = loadout.mana + loadout.extra_mana + effects.raw.mana;

    -- src: https://wowwiki-archive.fandom.com/wiki/Spirit
    -- without mp5
    local intellect = loadout.stats[stat.int] + effects.by_attribute.stats[stat.int];
    local spirit = loadout.stats[stat.spirit] + effects.by_attribute.stats[stat.spirit];
    local mp5_not_casting = mana_regen_per_5(intellect, spirit, loadout.lvl);
    if not calculating_weights then
        mp5_not_casting = math.ceil(mp5_not_casting);
    end
    local mp1_not_casting = 0.2 * mp5_not_casting;
    -- Note: Can't see 5% of base mana as regen while casting being a thing
    --local mp1_casting = 0.2 * (0.05 * base_mana_pool() + effects.raw.mp5) + mp1_not_casting * effects.raw.regen_while_casting;
    local mp1_casting = 0.2 * (effects.raw.mp5 + effects.raw.mp5_from_int_mod * loadout.stats[stat.int]*(1.0 + effects.by_attribute.stat_mod[stat.int]))
        + mp1_not_casting * effects.raw.regen_while_casting;

    if bit.band(loadout.flags, loadout_flags.is_dynamic_loadout) ~= 0 and not calculating_weights then
        -- the mana regen calculation is correct, but use GetManaRegen() to detect
        -- niche MP5 sources dynamically
        local _, x = GetManaRegen()
        mp1_casting = x;
    end

    local resource_loss_per_sec = spell_effect.cost_per_sec - mp1_casting;

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


local function evaluate_spell(spell, stats, loadout, effects)

    local spell_effect = {};
    local spell_effect_extra_1sp = {};
    local spell_effect_extra_1crit = {};
    local spell_effect_extra_1hit = {};
    local spell_effect_extra_1haste = {};
    local spell_effect_extra_1int = {};
    local spell_effect_extra_1spirit = {};
    local spell_effect_extra_1mp5 = {};

    spell_info(spell_effect, spell, stats, loadout, effects);
    cast_until_oom(spell_effect, stats, loadout, effects, true);

    local effects_diffed = deep_table_copy(effects);
    local diff = effects_zero_diff();
    local spell_stats_diffed = {};

    diff.sp = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed);
    spell_info(spell_effect_extra_1sp, spell, spell_stats_diffed, loadout, effects_diffed);
    cast_until_oom(spell_effect_extra_1sp, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.sp = 0;

    diff.crit_rating = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed);
    spell_info(spell_effect_extra_1crit, spell, spell_stats_diffed, loadout, effects_diffed);
    cast_until_oom(spell_effect_extra_1crit, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.crit_rating = 0;

    diff.hit_rating = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed);
    spell_info(spell_effect_extra_1hit, spell, spell_stats_diffed, loadout, effects_diffed);
    cast_until_oom(spell_effect_extra_1hit, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.hit_rating = 0;

    diff.haste_rating = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed);
    spell_info(spell_effect_extra_1haste, spell, spell_stats_diffed, loadout, effects_diffed);
    cast_until_oom(spell_effect_extra_1haste, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.haste_rating = 0;

    diff.stats[stat.int] = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed);
    spell_info(spell_effect_extra_1int, spell, spell_stats_diffed, loadout, effects_diffed);
    cast_until_oom(spell_effect_extra_1int, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.stats[stat.int] = 0;

    diff.stats[stat.spirit] = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed);
    spell_info(spell_effect_extra_1spirit, spell, spell_stats_diffed, loadout, effects_diffed);
    cast_until_oom(spell_effect_extra_1spirit, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.stats[stat.spirit] = 0;

    diff.mp5 = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed);
    spell_info(spell_effect_extra_1mp5, spell, spell_stats_diffed, loadout, effects_diffed);
    cast_until_oom(spell_effect_extra_1mp5, spell_stats_diffed, loadout, effects_diffed, true);
    effects_diffed = deep_table_copy(effects);
    diff.mp5 = 0;

    -- infinite cast
    local spell_effect_per_sec_1sp_delta = spell_effect_extra_1sp.effect_per_sec - spell_effect.effect_per_sec;

    local spell_effect_per_sec_1crit_delta = spell_effect_extra_1crit.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1hit_delta = spell_effect_extra_1hit.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1haste_delta = spell_effect_extra_1haste.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1int_delta = spell_effect_extra_1int.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1spirit_delta = spell_effect_extra_1spirit.effect_per_sec - spell_effect.effect_per_sec;

    -- cast until oom
    local spell_effect_until_oom_1sp_delta = spell_effect_extra_1sp.effect_until_oom - spell_effect.effect_until_oom;

    local spell_effect_until_oom_1crit_delta = spell_effect_extra_1crit.effect_until_oom - spell_effect.effect_until_oom;
    local spell_effect_until_oom_1hit_delta = spell_effect_extra_1hit.effect_until_oom - spell_effect.effect_until_oom;
    local spell_effect_until_oom_1haste_delta = spell_effect_extra_1haste.effect_until_oom - spell_effect.effect_until_oom;
    local spell_effect_until_oom_1int_delta = spell_effect_extra_1int.effect_until_oom - spell_effect.effect_until_oom;
    local spell_effect_until_oom_1spirit_delta = spell_effect_extra_1spirit.effect_until_oom - spell_effect.effect_until_oom;
    local spell_effect_until_oom_1mp5_delta = spell_effect_extra_1mp5.effect_until_oom - spell_effect.effect_until_oom;

    return {
        infinite_cast = {
            effect_per_sec_per_sp = spell_effect_per_sec_1sp_delta,

            sp_per_crit   = spell_effect_per_sec_1crit_delta/(spell_effect_per_sec_1sp_delta),
            sp_per_hit    = spell_effect_per_sec_1hit_delta/(spell_effect_per_sec_1sp_delta),
            sp_per_haste  = spell_effect_per_sec_1haste_delta/(spell_effect_per_sec_1sp_delta),
            sp_per_int    = spell_effect_per_sec_1int_delta/(spell_effect_per_sec_1sp_delta),
            sp_per_spirit = spell_effect_per_sec_1spirit_delta/(spell_effect_per_sec_1sp_delta),
        },
        cast_until_oom = {
            effect_until_oom_per_sp = spell_effect_until_oom_1sp_delta,

            sp_per_crit     = spell_effect_until_oom_1crit_delta/(spell_effect_until_oom_1sp_delta),
            sp_per_hit      = spell_effect_until_oom_1hit_delta/(spell_effect_until_oom_1sp_delta),
            sp_per_haste    = spell_effect_until_oom_1haste_delta/(spell_effect_until_oom_1sp_delta),
            sp_per_int      = spell_effect_until_oom_1int_delta/(spell_effect_until_oom_1sp_delta),
            sp_per_spirit   = spell_effect_until_oom_1spirit_delta/(spell_effect_until_oom_1sp_delta),
            sp_per_mp5      = spell_effect_until_oom_1mp5_delta/(spell_effect_until_oom_1sp_delta),
        },
        spell = spell_effect,
    };
end

local function spell_diff(spell_normal, spell_diffed, sim_type)

    if sim_type == simulation_type.spam_cast then
        return {
            diff_ratio = 100 * (spell_diffed.effect_per_sec/spell_normal.effect_per_sec - 1),
            first = spell_diffed.effect_per_sec - spell_normal.effect_per_sec,
            second = spell_diffed.expectation - spell_normal.expectation
        };
    elseif sim_type == simulation_type.cast_until_oom then
        
        return {
            diff_ratio = 100 * (spell_diffed.effect_until_oom/spell_normal.effect_until_oom - 1),
            first = spell_diffed.effect_until_oom - spell_normal.effect_until_oom,
            second = spell_diffed.time_until_oom - spell_normal.time_until_oom
        };
    end
end

addonTable.simulation_type              = simulation_type;
addonTable.stats_for_spell              = stats_for_spell;
addonTable.spell_info                   = spell_info;
addonTable.cast_until_oom               = cast_until_oom;
addonTable.evaluate_spell               = evaluate_spell;
addonTable.get_combat_rating_effect     = get_combat_rating_effect;
addonTable.spell_diff                   = spell_diff;

