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
    -- for vanilla, treat rating as same as percentage
    return 1;
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

local function target_avg_magical_res(self_lvl, target_res)
    return math.min(0.75, 0.75 * (target_res/(self_lvl * 5)))
end

local function base_mana_pool()

    local intellect = UnitStat("player", 4);
    local base_mana = UnitPowerMax("player", 0) - (min(20, intellect) + 15*(intellect - min(20, intellect)));

    return base_mana;
end

local special_abilities = nil;
local function set_alias_spell(spell, loadout)

    local alias_spell = spell;

    local swiftmend = spell_name_to_id["Swiftmend"];
    if spell.base_id == swiftmend then
        alias_spell = spells[best_rank_by_lvl[spell_name_to_id["Rejuvenation"]]];
        if bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0 then
            local rejuv_buff = loadout.dynamic_buffs[loadout.friendly_towards][GetSpellInfo(774)];
            local regrowth_buff = loadout.dynamic_buffs[loadout.friendly_towards][GetSpellInfo(8936)];
            -- TODO VANILLA: maybe swiftmend uses remaining ticks so could take that into account
            if regrowth_buff then
                if not rejuv_buff or regrowth_buff.dur < rejuv_buff.dur then
                    alias_spell = spells[best_rank_by_lvl[spell_name_to_id["Regrowth"]]];
                end
            end
        end
    elseif spell.base_id == conflagrate then
        alias_spell = spells[best_rank_by_lvl[spell_name_to_id["Immolate"]]];
    end

    return alias_spell;
end

local function stats_for_spell(stats, spell, loadout, effects)

    local original_base_cost = spell.cost;
    local original_spell_id = spell.base_id;
    -- deal with aliasing spells
    if not stats.no_alias then
        spell = set_alias_spell(spell, loadout);
    end

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

    if bit.band(spell.flags, spell_flags.no_crit) ~= 0 then
        stats.crit = 0.0;
    end

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
    stats.spell_mod_base = 1.0; -- modifier than only works on spell base but with spellpower
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
    if effects.ability.effect_mod_base[spell.base_id] then
        stats.spell_mod_base = stats.spell_mod_base + effects.ability.effect_mod_base[spell.base_id];
    end


    stats.gcd = 1.5;

    local cost_mod_base = effects.raw.cost_mod_base;
    if effects.ability.cost_mod_base[spell.base_id] then
        cost_mod_base = cost_mod_base + effects.ability.cost_mod_base[spell.base_id];
    end

    if bit.band(spell.flags, spell_flags.base_mana_cost) ~= 0 then
        stats.cost = math.floor(math.floor(original_base_cost * base_mana_pool()-effects.raw.cost_flat) * (1.0 - cost_mod_base));
    else
        stats.cost = math.floor((original_base_cost - effects.raw.cost_flat)) * (1.0 - cost_mod_base);
    end
    
    if effects.ability.cost_flat[spell.base_id] then
        stats.cost = stats.cost - effects.ability.cost_flat[spell.base_id];
    end
    local cost_mod = 1 - effects.raw.cost_mod;

    if effects.ability.cost_mod[spell.base_id] then
        cost_mod = cost_mod - effects.ability.cost_mod[spell.base_id]
    end

    local cast_mod_mul = 0.0;

    stats.extra_hit = effects.by_school.spell_dmg_hit[spell.school];
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
        stats.hit = math.min(0.99, stats.hit);
    end

    if class == "PRIEST" then
    elseif class == "DRUID" then

        if spell.base_id == spell_name_to_id["Healing Touch"] and loadout.num_set_pieces[set_tiers.pve_3] >= 8 then
            local mana_refund = original_base_cost;
            resource_refund = resource_refund + stats.crit * 0.3 * mana_refund;
        end

        
    elseif class == "PALADIN" and bit.band(spell.flags, spell_flags.heal) ~= 0 then
        -- illumination
        local pts = loadout.talents_table:pts(1, 9);
        if pts ~= 0 then
            local mana_refund = original_base_cost;
            resource_refund = resource_refund + stats.crit * pts*0.2 * mana_refund;
        end

    elseif class == "SHAMAN" then
        -- shaman clearcast
        
        if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
            -- clearcast
            local pts = loadout.talents_table:pts(1, 6);
            if pts ~= 0 then
                cost_mod = cost_mod*(1.0 - 0.1 * pts);
            end
        end

        if (spell.base_id == spell_name_to_id["Healing Wave"] or spell.base_id == spell_name_to_id["Lesser Healing Wave"])
                and loadout.num_set_pieces[set_tiers.pve_1] >= 5 then

            local mana_refund = original_base_cost;
            resource_refund = resource_refund + 0.25 * 0.35 * mana_refund;
        end
    elseif class == "MAGE" then

        if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
            -- clearcast
            local pts = loadout.talents_table:pts(1, 6);
            if pts ~= 0 then
                cost_mod = cost_mod*(1.0 - 0.02 * pts);
            end

            local pts = loadout.talents_table:pts(2, 12);
            if pts ~= 0 and
                (spell.school == magic_school.fire or spell.school == magic_school.frost) and
                spell.base_min ~= 0 then

                -- master of elements
                local mana_refund = pts * 0.1 * original_base_cost;
                resource_refund = resource_refund + stats.hit*stats.crit * mana_refund;
            end

            -- ignite
            local pts = loadout.talents_table:pts(2, 3);
            if pts ~= 0 and spell.school == magic_school.fire then
                stats.crit_mod = stats.crit_mod * (1.0 + pts * 0.08);
            end
        end
    elseif class == "WARLOCK" then
    end

    stats.cast_time = spell.cast_time;
    if effects.ability.cast_mod[spell.base_id] then

        stats.cast_time = stats.cast_time - effects.ability.cast_mod[spell.base_id];
    end
    
    local haste_rating_per_perc = get_combat_rating_effect(CR_HASTE_SPELL, loadout.lvl);
    local haste_from_rating = 0.01 * max(0.0, loadout.haste_rating + effects.raw.haste_rating) / haste_rating_per_perc;

    local cast_reduction = effects.raw.haste_mod + haste_from_rating;

    if effects.ability.cast_mod_mul[spell.base_id] then
        cast_reduction = cast_reduction + effects.ability.cast_mod_mul[spell.base_id];
    end

    
    stats.cast_time = stats.cast_time * (1.0 - cast_reduction);


    -- nature's grace
    local pts = loadout.talents_table:pts(1, 13);
    if class == "DRUID" and pts ~= 0 and spell.base_min ~= 0 then

        stats.cast_time = (1.0 - stats.crit) * stats.cast_time +
            stats.crit * math.max(stats.cast_time * 0.8, stats.gcd);

    elseif class == "MAGE" and loadout.num_set_pieces[set_tiers.pve_2] >= 8 and
             (spell.base_id == spell_name_to_id["Frostbolt"] or spell.base_id == spell_name_to_id["Fireball"]) then

             stats.cast_time = 0.9 * stats.cast_time + 0.1 * stats.gcd;
    end

    stats.cast_time_nogcd = stats.cast_time;
    stats.cast_time = math.max(stats.cast_time, stats.gcd);

    -- multiplicitive vs additive can become an error here 
    if bit.band(spell.flags, spell_flags.heal) ~= 0 then

        stats.spell_mod_base = stats.spell_mod_base + effects.raw.spell_heal_mod_base;

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

        stats.spell_mod_base = stats.spell_mod_base + effects.raw.spell_heal_mod_base;

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
        stats.spell_power = loadout.healing_power + effects.raw.healing_power + effects.raw.spell_power;
    else
        stats.spell_power = loadout.spell_dmg + loadout.spell_dmg_by_school[spell.school] +
            effects.raw.spell_dmg + effects.raw.spell_power;
    end

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
        stats.target_resi = math.max(0, loadout.target_res + effects.by_school.target_res[spell.school]);
    end

    stats.target_avg_resi = target_avg_magical_res(loadout.lvl, stats.target_resi);

    stats.cost = stats.cost * cost_mod;
    stats.cost = math.floor(stats.cost + 0.5);

    if effects.ability.refund[spell.base_id] and effects.ability.refund[spell.base_id] ~= 0 then

        local refund = effects.ability.refund[spell.base_id];
        local max_rank = spell.rank;
        if spell.base_id == spell_name_to_id["Lesser Healing Wave"] then
            max_rank = 6;
        elseif spell.base_id == spell_name_to_id["Healing Touch"] then
            max_rank = 11;
        end

        coef_estimate = spell.rank/max_rank;

        resource_refund = resource_refund + refund*coef_estimate;
    end

    stats.cost = stats.cost - resource_refund;

    stats.coef = spell.coef;
    stats.ot_coef = spell.over_time_coef;

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
        base_min = math.floor(base_min + spell.lvl_scaling * lvl_diff_applicable);
        base_max = math.ceil(base_max + spell.lvl_scaling * lvl_diff_applicable);
    end
    if bit.band(spell.flags, spell_flags.over_time_lvl_scaling) ~= 0 then
        base_ot_tick = math.floor(base_ot_tick + spell.lvl_scaling * lvl_diff_applicable);
        base_ot_tick_max = math.ceil(base_ot_tick_max + spell.lvl_scaling * lvl_diff_applicable);
    end

    info.ot_freq = spell.over_time_tick_freq;
    info.ot_duration = spell.over_time_duration;

    if spell.cast_time == spell.over_time_duration then
        info.ot_freq = spell.over_time_tick_freq*(stats.cast_time/spell.over_time_duration);
        info.ot_duration = stats.cast_time;
    end

    -- certain ticks may tick faster
    if class == "PRIEST" then

    elseif class == "WARLOCK" then
    elseif class == "MAGE" then
    elseif class == "DRUID" then
    end

    info.min_noncrit_if_hit = 
        (base_min*stats.spell_mod_base + stats.spell_power * stats.coef + stats.flat_addition) * stats.spell_mod;
    info.max_noncrit_if_hit = 
        (base_max*stats.spell_mod_base + stats.spell_power * stats.coef + stats.flat_addition) * stats.spell_mod;

    info.min_crit_if_hit = info.min_noncrit_if_hit * stats.crit_mod;
    info.max_crit_if_hit = info.max_noncrit_if_hit * stats.crit_mod;

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

        info.ot_if_hit = (base_ot_tick*stats.spell_mod_base + ot_coef_per_tick * stats.spell_power_ot + stats.flat_addition_ot) * info.ot_ticks * stats.spell_ot_mod;
        info.ot_if_hit_max = (base_ot_tick_max*stats.spell_mod_base + ot_coef_per_tick * stats.spell_power_ot + stats.flat_addition_ot) * info.ot_ticks * stats.spell_ot_mod;

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

        local channel_ratio_time_lost_to_miss = 1 - (info.ot_duration - 1.5)/info.ot_duration;
        info.expected_ot = expected_ot_if_hit - (1 - stats.hit) * channel_ratio_time_lost_to_miss * expected_ot_if_hit;
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

    if stats.cost == 0 then
        info.effect_per_cost = math.huge;
    else
        info.effect_per_cost = info.expectation/stats.cost;
    end

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
        info.effect_per_cost = math.huge;
    end
end


local function spell_info_from_stats(info, stats, spell, loadout, effects)

    stats_for_spell(stats, spell, loadout, effects);
    spell_info(info, spell, stats, loadout, effects);
end

local function cast_until_oom(spell_effect, stats, loadout, effects, calculating_weights)

    calculating_weights = calculating_weights or false;

    local num_casts = 0;
    local effect = 0;

    local mana = loadout.mana + loadout.extra_mana + effects.raw.mana;

    -- src: https://wowwiki-archive.fandom.com/wiki/Spirit
    -- without mp5
    local spirit = loadout.stats[stat.spirit] + effects.by_attribute.stats[stat.spirit];

    local mp2_not_casting = 0;
    if class == "PRIEST" or class == "MAGE" then
        mp2_not_casting = (13 + spirit/4);
    elseif class == "DRUID" or class == "SHAMAN" or class == "PALADIN" then
        mp2_not_casting = (15 + spirit/5);
    elseif class == "WARLOCK" then
        mp2_not_casting = (8 + spirit/4);
    end
    if not calculating_weights then
        mp2_not_casting = math.ceil(mp2_not_casting);
    end
    local mp1_casting = 0.2 * effects.raw.mp5 + 0.5 * mp2_not_casting * effects.raw.regen_while_casting;

    -- TODO: don't use this when stat comparison is open
    -- TODO VANILLA: formula seems incorrect
    if bit.band(loadout.flags, loadout_flags.is_dynamic_loadout) ~= 0 and not calculating_weights then
        -- the mana regen calculation is correct, but use GetManaRegen() to detect
        -- niche MP5 sources dynamically
        local _, x = GetManaRegen()
        mp1_casting = x;
    end

    local resource_loss_per_sec = spell_effect.cost_per_sec - mp1_casting;

    if resource_loss_per_sec <= 0 then
        spell_effect.num_casts_until_oom = math.huge;
        spell_effect.effect_until_oom = math.huge;
        spell_effect.time_until_oom = math.huge;
        spell_effect.mp1 = mp1_casting;
    else
        spell_effect.time_until_oom = mana/resource_loss_per_sec;
        spell_effect.num_casts_until_oom = spell_effect.time_until_oom/stats.cast_time;
        spell_effect.effect_until_oom = spell_effect.num_casts_until_oom * spell_effect.expectation;
        spell_effect.mp1 = mp1_casting;
    end
end

if class == "SHAMAN" then
    special_abilities = {
        [spell_name_to_id["Chain Heal"]] = function(spell, info, loadout)

            if loadout.num_set_pieces[set_tiers.pve_2] >= 3 then
                info.expectation = (1 + 1.3*0.5 + 1.3*1.3*0.5*0.5) * info.expectation_st;
            else
                info.expectation = (1 + 0.5 + 0.5*0.5) * info.expectation_st;
            end
        end,
        [spell_name_to_id["Lightning Shield"]] = function(spell, info, loadout)
            info.expectation = 3 * info.expectation_st;
        end,
        [spell_name_to_id["Chain Lightning"]] = function(spell, info, loadout)

            if loadout.num_set_pieces[set_tiers.pve_2_5_1] >= 3 then
                info.expectation = (1 + 0.75 + 0.75*0.75) * info.expectation_st;
            else
                info.expectation = (1 + 0.7 + 0.7*0.7) * info.expectation_st;
            end
        end,
        [spell_name_to_id["Healing Wave"]] = function(spell, info, loadout)
            if loadout.num_set_pieces[set_tiers.pve_1] >= 8 then
                info.expectation = (1 + 0.2 + 0.2*0.2) * info.expectation_st;
            end
        end

    };
elseif class == "PRIEST" then
    special_abilities = {
        [spell_name_to_id["Prayer of Healing"]] = function(spell, info, loadout, stats, effects)
            info.expectation = 5 * info.expectation_st;
        end,
        [spell_name_to_id["Power Word: Shield"]] = function(spell, info, loadout)

            info.absorb = info.min_noncrit_if_hit;

            info.min_noncrit_if_hit = 0.0;
            info.max_noncrit_if_hit = 0.0;

            info.min_crit_if_hit = 0.0;
            info.max_crit_if_hit = 0.0;
        end,
        [spell_name_to_id["Holy Nova"]] = function(spell, info, loadout)
            if bit.band(spell.flags, spell_flags.heal) ~= 0 then
                info.expectation = 5 * info.expectation_st;
            end
        end,
        [spell_name_to_id["Lightwell"]] = function(spell, info, loadout)
            info.expectation = 5 * info.expectation_st;
        end,
        [spell_name_to_id["Greater Heal"]] = function(spell, info, loadout, stats, effects)
            if loadout.num_set_pieces[set_tiers.pve_3] >= 4 then
                info.expectation_direct = info.expectation_direct + stats.crit * 500;
            end

            if loadout.num_set_pieces[set_tiers.pve_2] >= 8 then
                if not stats.secondary_ability_stats then
                    stats.secondary_ability_stats = {};
                    stats.secondary_ability_info = {};
                end
                spell_info_from_stats(stats.secondary_ability_info, stats.secondary_ability_stats, spells[6077], loadout, effects);

                info.ot_if_hit = stats.secondary_ability_info.ot_if_hit;
                info.ot_if_hit_max = stats.secondary_ability_info.ot_if_hit_max;
                info.ot_if_crit = stats.secondary_ability_info.ot_if_crit;
                info.ot_if_crit_max = stats.secondary_ability_info.ot_if_crit_max;
                info.ot_ticks = stats.secondary_ability_info.ot_ticks;
                info.ot_duration = stats.secondary_ability_info.ot_duration; 
                info.ot_freq = stats.secondary_ability_info.ot_freq; 
                info.expected_ot = stats.secondary_ability_info.expected_ot;

            end

            info.expectation_st = info.expectation_st + info.expected_ot;
            info.expectation = info.expectation_st;
        end,
    };
elseif class == "DRUID" then
    special_abilities = {
        [spell_name_to_id["Tranquility"]] = function(spell, info, loadout)
            info.expectation = 5 * info.expectation_st;
        end,
        [spell_name_to_id["Swiftmend"]] = function(spell, info, loadout, stats)

            local num_ticks = 4;
            if stats.alias and stats.alias == spell_name_to_id["Regrowth"] then
                num_ticks = 7;
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
        [spell_name_to_id["Conflagrate"]] = function(spell, info, loadout, stats)

            local immolate_effect = stats.spell_mod * info.ot_if_hit;
            local direct = 1.0 * immolate_effect;
            
            -- direct component
            info.min_noncrit_if_hit = direct;
            info.max_noncrit_if_hit = direct;

            info.min_crit_if_hit = stats.crit_mod*direct;
            info.max_crit_if_hit = stats.crit_mod*direct;

            info.min = stats.hit * ((1 - stats.crit) * info.min_noncrit_if_hit + (stats.crit * info.min_crit_if_hit));
            info.max = stats.hit * ((1 - stats.crit) * info.max_noncrit_if_hit + (stats.crit * info.max_crit_if_hit));

            -- clear over time
            info.ot_ticks = 0;
            info.ot_duration = 0.0;
            info.ot_freq = 0.0;

            info.ot_if_hit = 0;
            info.ot_if_hit_max = 0;
            info.ot_if_crit = 0;
            info.ot_if_crit_max = 0;

            local expected_ot_if_hit = 0;
            info.expected_ot = 0;

            info.expectation_st = 0.5 * (info.min + info.max);
            info.expectation = info.expectation_st;
        end,
    };
elseif class == "PALADIN" then
    special_abilities = {
    };
else
    special_abilities = {};
end


local function evaluate_spell(spell, stats, loadout, effects)

    local spell_effect = {};
    local spell_effect_extra_1sp = {};
    local spell_effect_extra_1crit = {};
    local spell_effect_extra_1hit = {};
    local spell_effect_extra_1pen = {};
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

    diff.spell_pen = 1;
    effects_diff(loadout, effects_diffed, diff);
    stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed);
    spell_info(spell_effect_extra_1pen, spell, spell_stats_diffed, loadout, effects_diffed);
    cast_until_oom(spell_effect_extra_1pen, spell_stats_diffed, loadout, effects_diffed, true);
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
    if bit.band(spell.flags, spell_flags.mana_regen) == 0 then
        result.infinite_cast = {
            effect_per_sec_per_sp = spell_effect_per_sec_1sp_delta,

            sp_per_crit   = spell_effect_per_sec_1crit_delta/(spell_effect_per_sec_1sp_delta),
            sp_per_hit    = spell_effect_per_sec_1hit_delta/(spell_effect_per_sec_1sp_delta),
            sp_per_pen    = spell_effect_per_sec_1pen_delta/(spell_effect_per_sec_1sp_delta),
            sp_per_int    = spell_effect_per_sec_1int_delta/(spell_effect_per_sec_1sp_delta),
            sp_per_spirit = spell_effect_per_sec_1spirit_delta/(spell_effect_per_sec_1sp_delta),
        };
    end
    if stats.cost ~= 0 then
        result.cast_until_oom = {
            effect_until_oom_per_sp = spell_effect_until_oom_1sp_delta,

            sp_per_crit     = spell_effect_until_oom_1crit_delta/(spell_effect_until_oom_1sp_delta),
            sp_per_hit      = spell_effect_until_oom_1hit_delta/(spell_effect_until_oom_1sp_delta),
            sp_per_pen      = spell_effect_until_oom_1pen_delta/(spell_effect_until_oom_1sp_delta),
            sp_per_int      = spell_effect_until_oom_1int_delta/(spell_effect_until_oom_1sp_delta),
            sp_per_spirit   = spell_effect_until_oom_1spirit_delta/(spell_effect_until_oom_1sp_delta),
            sp_per_mp5      = spell_effect_until_oom_1mp5_delta/(spell_effect_until_oom_1sp_delta),
        };
    end

    return result;
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

