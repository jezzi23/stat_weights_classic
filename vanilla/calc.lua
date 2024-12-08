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

local _, swc = ...;


local spells            = swc.abilities.spells;
local spell_name_to_id  = swc.abilities.spell_name_to_id;
local magic_school      = swc.abilities.magic_school;
local spell_flags       = swc.abilities.spell_flags;
local best_rank_by_lvl  = swc.abilities.best_rank_by_lvl;

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

-- base mana doesn't seem to follow a formula
-- use some rough estimate when using a custom level by interpolating between
local lvl_20_mana_bracket = {
    ["DRUID"] = { start = 50, per_lvl = (329 - 50) / 19 },
    ["MAGE"] = { start = 100, per_lvl = (343 - 100) / 19 },
    ["PALADIN"] = { start = 60, per_lvl = (390 - 60) / 19 },
    ["PRIEST"] = { start = 110, per_lvl = (350 - 110) / 19 },
    ["SHAMAN"] = { start = 55, per_lvl = (346 - 55) / 19 },
    ["WARLOCK"] = { start = 90, per_lvl = (325 - 50) / 19 },
};
local lvl_40_mana_bracket = {
    ["DRUID"] = { start = 354, per_lvl = (824 - 354) / 21 },
    ["MAGE"] = { start = 371, per_lvl = (853 - 371) / 21 },
    ["PALADIN"] = { start = 412, per_lvl = (987 - 412) / 21 },
    ["PRIEST"] = { start = 375, per_lvl = (911 - 375) / 21 },
    ["SHAMAN"] = { start = 370, per_lvl = (975 - 370) / 21 },
    ["WARLOCK"] = { start = 365, per_lvl = (965 - 365) / 23 },
};
local lvl_60_mana_bracket = {
    ["DRUID"] = { start = 854, per_lvl = (1244 - 854) / 20 },
    ["MAGE"] = { start = 853, per_lvl = (1213 - 853) / 20 },
    ["PALADIN"] = { start = 987, per_lvl = (1512 - 987) / 20 },
    ["PRIEST"] = { start = 911, per_lvl = (1400 - 911) / 20 },
    ["SHAMAN"] = { start = 975, per_lvl = (1520 - 975) / 20 },
    ["WARLOCK"] = { start = 918, per_lvl = (1522 - 918) / 20 },
};
local lvl_70_mana_bracket = {
    ["DRUID"] = { start = 1244 },
    ["MAGE"] = { start = 1213 },
    ["PALADIN"] = { start = 1512 },
    ["PRIEST"] = { start = 1400 },
    ["SHAMAN"] = { start = 1520 },
    ["WARLOCK"] = { start = 1522 },
};

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


    if clvl ~= UnitLevel("player") then
        if clvl >= 60 then
            return lvl_70_mana_bracket[class].start;
        elseif clvl >= 40 then
            return lvl_60_mana_bracket[class].start + lvl_60_mana_bracket[class].per_lvl * (clvl - 40);
        elseif clvl >= 20 then
            return lvl_40_mana_bracket[class].start + lvl_40_mana_bracket[class].per_lvl * (clvl - 20);
        else
            return lvl_20_mana_bracket[class].start + lvl_20_mana_bracket[class].per_lvl * clvl;
        end
    end

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

    if spell.base_id == spell_name_to_id["Sunfire (Bear)"] or spell.base_id == spell_name_to_id["Sunfire (Cat)"] then
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
    stats["extra_effect_freq" .. i] = freq;

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

    stats.crit = loadout.spell_crit_by_school[spell.school] + effects.by_school.spell_crit[spell.school];

    stats.ot_crit = 0.0;
    if effects.ability.crit[benefit_id] then
        stats.crit = stats.crit + effects.ability.crit[benefit_id];
    end
    if bit.band(spell.flags, spell_flags.multi_school) ~= 0 then
        for _, v in pairs(spell.multi_school) do
            stats.crit = stats.crit + loadout.spell_crit_by_school[v] + effects.by_school.spell_crit[v]
                - (loadout.spell_crit_by_school[magic_school.physical] + effects.by_school.spell_crit[magic_school.physical])
        end
    end
    -- rating may come from diffed loadout
    local crit_rating_per_perc = get_combat_rating_effect(CR_CRIT_SPELL, loadout.lvl);
    local crit_from_rating = 0.01 * (loadout.crit_rating + effects.raw.crit_rating) / crit_rating_per_perc;
    stats.crit = math.max(0.0, math.min(1.0, stats.crit + crit_from_rating));

    if bit.band(spell.flags, spell_flags.no_crit) ~= 0 then
        stats.crit = 0.0;
    end

    local extra_ot_crit = 0.0;
    if effects.ability.crit_ot[benefit_id] then
        extra_ot_crit = effects.ability.crit_ot[benefit_id];
    end

    if bit.band(spell.flags, spell_flags.over_time_crit) ~= 0 then
        stats.ot_crit = stats.crit + extra_ot_crit;
    end

    stats.crit_mod = 1.5;
    if bit.band(spell.flags, spell_flags.double_crit) ~= 0 then
        stats.crit_mod = 2.0;
    end

    local extra_crit_mod = effects.by_school.spell_crit_mod[spell.school];

    if bit.band(spell.flags, spell_flags.multi_school) ~= 0 then
        for _, v in pairs(spell.multi_school) do
            extra_crit_mod = extra_crit_mod + effects.by_school.spell_crit_mod[v] -
            effects.by_school.spell_crit_mod[magic_school.physical];
        end
    end
    if effects.ability.crit_mod[benefit_id] then
        extra_crit_mod = extra_crit_mod + effects.ability.crit_mod[benefit_id];
    end
    if bit.band(spell.flags, spell_flags.heal) ~= 0 then
        stats.crit_mod = stats.crit_mod + 0.5 * effects.raw.special_crit_heal_mod;
        if effects.ability.crit_mod[benefit_id] then
            stats.crit_mod = stats.crit_mod + effects.ability.crit_mod[benefit_id];
        end
    elseif bit.band(spell.flags, spell_flags.absorb) ~= 0 then
        stats.crit = 0.0;
    else
        stats.crit_mod = stats.crit_mod * (1.0 + effects.raw.special_crit_mod);
        stats.crit_mod = stats.crit_mod + (stats.crit_mod - 1.0) * 2 * extra_crit_mod;
    end

    stats.special_crit_mod_tracked = 0;

    stats.num_extra_effects = 0;

    stats.num_extra_periodic_effects = 0;

    stats.hit_inflation = 1.0; -- inflate hit value visually while not contributing to expectation

    local target_vuln_mod_mul = 1.0;
    if effects.mul.ability.vuln_mod[benefit_id] then
        target_vuln_mod_mul = target_vuln_mod_mul * effects.mul.ability.vuln_mod[benefit_id];
    end

    local target_vuln_mod_ot_mul = target_vuln_mod_mul;

    if effects.mul.ability.vuln_mod_ot[benefit_id] then
        target_vuln_mod_ot_mul = target_vuln_mod_ot_mul * effects.mul.ability.vuln_mod_ot[benefit_id];
    end

    stats.spell_mod = 1.0;
    stats.spell_ot_mod = 1.0;
    stats.flat_addition = 0;
    stats.effect_mod = 0.0;
    stats.spell_mod_base = 1.0; -- modifier than only works on spell base
    stats.spell_dmg_mod_mul = effects.mul.raw.spell_dmg_mod;
    stats.regen_while_casting = effects.raw.regen_while_casting;
    local spell_dmg_mod_school = effects.by_school.spell_dmg_mod[spell.school];
    local spell_dmg_mod_school_mul = effects.mul.by_school.spell_dmg_mod[spell.school];

    local resource_refund = effects.raw.resource_refund;

    if effects.ability.effect_mod[benefit_id] then
        stats.effect_mod = stats.effect_mod + effects.ability.effect_mod[benefit_id];
    end
    if not effects.ability.effect_ot_mod[benefit_id] then
        effects.ability.effect_ot_mod[benefit_id] = 0.0;
    end

    if effects.ability.flat_add[benefit_id] then
        stats.flat_addition = effects.ability.flat_add[benefit_id];
    end
    stats.flat_addition_ot = stats.flat_addition;
    if effects.ability.flat_add_ot[benefit_id] then
        stats.flat_addition_ot = stats.flat_addition_ot + effects.ability.flat_add_ot[benefit_id];
    end
    if effects.ability.effect_mod_base[benefit_id] then
        stats.spell_mod_base = stats.spell_mod_base + effects.ability.effect_mod_base[benefit_id];
    end


    stats.gcd = 1.5;
    if spell.base_id == spell_name_to_id["Shoot"] then
        local wand_perc_active = 1.0 + stats.effect_mod;
        local wand_perc_spec = 1.0;

        if class == "PRIEST" then
            wand_perc_spec = wand_perc_spec + loadout.talents_table:pts(1, 2) * 0.05;
        elseif class == "MAGE" then
            wand_perc_spec = wand_perc_spec + loadout.talents_table:pts(1, 4) * 0.125;
        end

        local wand_speed, wand_min, wand_max, bonus, _, perc = UnitRangedDamage("player");
        stats.gcd = 0.5;
        if wand_speed ~= 0 then
            spell.cast_time = wand_speed;
            spell.base_min = (wand_min / (perc * wand_perc_active) - bonus) * wand_perc_spec;
            spell.base_max = (wand_max / (perc * wand_perc_active) - bonus) * wand_perc_spec;
        else
            spell.cast_time = 0;
            spell.base_min = 0;
            spell.base_max = 0;
        end
        spell_dmg_mod_school = spell_dmg_mod_school - stats.effect_mod;
    end
    local cost_mod_base = effects.raw.cost_mod_base;
    if effects.ability.cost_mod_base[benefit_id] then
        cost_mod_base = cost_mod_base + effects.ability.cost_mod_base[benefit_id];
    end
    local base_mana = base_mana_pool(loadout.lvl, effects.raw.mana_mod_active);

    if bit.band(spell.flags, spell_flags.base_mana_cost) ~= 0 then
        original_base_cost = original_base_cost * base_mana;
    end
    local cost_flat = effects.raw.cost_flat;
    if effects.ability.cost_flat[benefit_id] then
        cost_flat = cost_flat + effects.ability.cost_flat[benefit_id];
    end
    stats.cost = math.floor((original_base_cost - cost_flat)) * (1.0 - cost_mod_base);

    local cost_mod = 1 - effects.raw.cost_mod - effects.by_school.cost_mod[spell.school];

    if effects.ability.cost_mod[benefit_id] then
        cost_mod = cost_mod - effects.ability.cost_mod[benefit_id]
    end

    if bit.band(spell.flags, spell_flags.multi_school) ~= 0 then
        for _, v in pairs(spell.multi_school) do
            cost_mod = cost_mod - effects.by_school.cost_mod[v];
        end
    end

    stats.target_resi = 0;
    stats.target_resi_dot = 0;
    stats.target_avg_resi = 0;
    stats.target_avg_resi_dot = 0;

    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
        local res_pen_by_school = effects.by_school.target_res[spell.school];
        if bit.band(spell.flags, spell_flags.multi_school) ~= 0 then
            for _, v in pairs(spell.multi_school) do
                res_pen_by_school = math.max(res_pen_by_school, effects.by_school.target_res[v]);
            end
        end
        -- mod res by school currently used to snapshot equipment and set bonuses
        stats.target_resi = math.min(loadout.lvl * 5,
            math.max(0, config.loadout.target_res - res_pen_by_school));

        if bit.band(spell.flags, spell_flags.special_periodic_school) ~= 0 then
            res_pen_by_school = effects.by_school.target_res[spell.multi_school[1]];
        end
        stats.target_resi_dot = math.min(loadout.lvl * 5,
            math.max(0, config.loadout.target_res - res_pen_by_school));


        if bit.band(spell.flags, spell_flags.binary) ~= 0 then
            stats.target_avg_resi = target_avg_magical_res_binary(loadout.lvl, stats.target_resi);
            stats.target_avg_resi_dot = target_avg_magical_res_binary(loadout.lvl, stats.target_resi_dot);
        else
            local base_resi = 0;
            if bit.band(loadout.flags, loadout_flags.target_pvp) == 0 then
                base_resi = npc_lvl_resi_base(loadout.lvl, loadout.target_lvl);
            end
            stats.target_resi = math.min(loadout.lvl * 5,
                math.max(base_resi, config.loadout.target_res - effects.by_school.target_res[spell.school] + base_resi));
            stats.target_avg_resi = target_avg_magical_mitigation_non_binary(loadout.lvl, stats.target_resi);

            stats.target_resi_dot = math.min(loadout.lvl * 5,
                math.max(base_resi, config.loadout.target_res - res_pen_by_school + base_resi));
            stats.target_avg_resi_dot = target_avg_magical_mitigation_non_binary(loadout.lvl, stats.target_resi_dot);
        end

        if bit.band(spell.flags, spell_flags.dot_resi_penetrate) ~= 0 then
            -- some dots penetrate 9/10th of resi
            stats.target_avg_resi_dot = stats.target_avg_resi_dot * 0.1;
        end
    end

    stats.extra_hit = loadout.spell_dmg_hit_by_school[spell.school] + effects.by_school.spell_dmg_hit[spell.school];
    if bit.band(spell.flags, spell_flags.multi_school) ~= 0 then
        for _, v in pairs(spell.multi_school) do
            stats.extra_hit = stats.extra_hit + effects.by_school.spell_dmg_hit[v] -
            effects.by_school.spell_dmg_hit[magic_school.physical];
        end
    end

    if effects.ability.hit[benefit_id] then
        stats.extra_hit = stats.extra_hit + effects.ability.hit[benefit_id];
    end

    local hit_rating_per_perc = get_combat_rating_effect(CR_HIT_SPELL, loadout.lvl);
    local hit_from_rating = 0.01 * (loadout.hit_rating + effects.raw.hit_rating) / hit_rating_per_perc
    stats.extra_hit = stats.extra_hit + hit_from_rating;

    if bit.band(spell.flags, spell_flags.affliction) ~= 0 then
        stats.extra_hit = stats.extra_hit + loadout.talents_table:pts(1, 1) * 0.02;
    end

    local target_is_pvp = bit.band(loadout.flags, loadout_flags.target_pvp) ~= 0;
    stats.hit = spell_hit(loadout.lvl, loadout.target_lvl, stats.extra_hit, target_is_pvp);
    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
        stats.hit = 1.0;
    elseif bit.band(spell.flags, spell_flags.binary) ~= 0 then
        -- @src: https://royalgiraffe.github.io/resist-guide
        -- binary spells will have lower hit chance against higher resistances
        -- rather than partial resists
        local base_hit = spell_hit(loadout.lvl, loadout.target_lvl, 0.0, target_is_pvp);
        stats.hit = math.min(0.99,
            base_hit * (1.0 - stats.target_avg_resi) + stats.extra_hit);


        stats.target_avg_resi = 0.0;
        stats.target_avg_resi_dot = 0.0;
    else
        stats.hit = math.min(0.99, stats.hit);
    end

    stats.cast_time = spell.cast_time;
    if not effects.ability.cast_mod[benefit_id] then
        effects.ability.cast_mod[benefit_id] = 0.0;
    end
    stats.cast_time = stats.cast_time - effects.ability.cast_mod[benefit_id];

    local haste_rating_per_perc = get_combat_rating_effect(CR_HASTE_SPELL, loadout.lvl);
    local haste_from_rating = 0.01 * max(0.0, loadout.haste_rating + effects.raw.haste_rating) / haste_rating_per_perc;

    local cast_reduction = effects.raw.haste_mod + haste_from_rating;

    if effects.ability.cast_mod_mul[benefit_id] then
        cast_reduction = cast_reduction + effects.ability.cast_mod_mul[benefit_id];
    end

    stats.cast_time = stats.cast_time * (1.0 - cast_reduction);

    stats.ot_crit_mod = stats.crit_mod;

    if class == "PRIEST" then
        if bit.band(spell_flags.heal, spell.flags) ~= 0 then
            if loadout.runes[rune_ids.divine_aegis] then

                local aegis_flags = bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod);
                if benefit_id == spell_name_to_id["Penance"] then
                    aegis_flags = bit.bor(aegis_flags, extra_effect_flags.base_on_periodic_effect);
                end
                add_extra_direct_effect(stats, aegis_flags, 0.3, 1.0, "Divine Aegis");
            end
            if benefit_id == spell_name_to_id["Greater Heal"] and loadout.num_set_pieces[set_tiers.pve_3] >= 4 then
                add_extra_direct_effect(stats,
                                        bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.use_flat),
                                        500, 1.0, "Absorb");
            end
            if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 6 then
                if benefit_id == spell_name_to_id["Circle of Healing"] then
                    add_extra_periodic_effect(stats, 0, 0.25, 5, 3, 1.0, "6P Set Bonus");
                elseif benefit_id == spell_name_to_id["Penance"] then
                    add_extra_periodic_effect(stats, extra_effect_flags.base_on_periodic_effect, 0.25, 5, 3, 1.0, "6P Set Bonus");
                end
            end
        elseif bit.band(spell_flags.absorb, spell.flags) ~= 0 then
        else
            if loadout.runes[rune_ids.despair] then
                stats.ot_crit = stats.crit + extra_ot_crit;
            end
            stats.crit = math.min(1.0, stats.crit + loadout.talents_table:pts(1, 14) * 0.01);
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

        if (benefit_id == spell_name_to_id["Healing Touch"] or spell.base_id == spell_name_to_id["Nourish"]) then
            if loadout.num_set_pieces[set_tiers.pve_3] >= 8 then
                local mana_refund = original_base_cost;
                resource_refund = resource_refund + stats.crit * 0.3 * mana_refund;
            end
            if loadout.num_set_pieces[set_tiers.sod_final_pve_1_heal] >= 4 then
                local mana_refund = original_base_cost;
                resource_refund = resource_refund + 0.25 * 0.35 * mana_refund;
            end
        end
        if benefit_id == spell_name_to_id["Lifebloom"] then
            local mana_refund = stats.cost * cost_mod * 0.5;
            resource_refund = resource_refund + mana_refund;
        end

        if loadout.runes[rune_ids.living_seed] then
            -- looks like seeds will work on lifebloom in sod
            if (bit.band(spell_flags.heal, spell.flags) ~= 0 and spell.base_min ~= 0)
                or benefit_id == spell_name_to_id["Rejuvenation"] or benefit_id == spell_name_to_id["Swiftmend"] then
                add_extra_direct_effect(stats,
                                        bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod),
                                        0.5, 1.0, "Living Seed");
            end
        end
        if loadout.runes[rune_ids.lifebloom] and
            (benefit_id == spell_name_to_id["Rejuvenation"] or benefit_id == spell_name_to_id["Lifebloom"]) then
            stats.gcd = stats.gcd - 0.5;
        end
        if loadout.num_set_pieces[set_tiers.sod_final_pve_zg] >= 3 and benefit_id == spell_name_to_id["Starfire"] then
            stats.gcd = stats.gcd - 0.5;
        end

        -- nature's grace
        local pts = loadout.talents_table:pts(1, 13);
        if pts ~= 0 and spell.cast_time ~= spell.over_time_duration and bit.band(spell_flags.instant, spell.flags) == 0 and cast_reduction < 1.0 then
            stats.gcd = stats.gcd - 0.5;

            local crit_cast_reduction = 0.5 * stats.crit;
            if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 4 and bit.band(spell_flags.heal, spell.flags) ~= 0 then
                crit_cast_reduction = math.min(0.5, crit_cast_reduction * 2);
            end

            stats.cast_time = spell.cast_time - effects.ability.cast_mod[benefit_id] - crit_cast_reduction;
            stats.cast_time = stats.cast_time * (1.0 - cast_reduction);
        end

        if bit.band(swc.core.client_deviation, swc.core.client_deviation_flags.sod) ~= 0 and
            is_buff_up(loadout, "player", lookups.moonkin_form, true) and
            bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.no_crit)) == 0 then
            --moonkin form periodic crit
            stats.ot_crit = stats.crit + extra_ot_crit;
        end
    elseif class == "PALADIN" then
        if bit.band(spell.flags, spell_flags.heal) ~= 0 then
            -- illumination
            local pts = loadout.talents_table:pts(1, 9);
            if pts ~= 0 then
                resource_refund = resource_refund + stats.crit * pts * 0.2 * original_base_cost;
            end

            if loadout.runes[rune_ids.fanaticism] and spell.base_min ~= 0 then
                add_extra_periodic_effect(stats,
                                          bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod),
                                          0.6, 4, 3, 1.0, "Fanaticism");
            end
            if benefit_id == spell_name_to_id["Flash of Light"] and is_buff_up(loadout, loadout.friendly_towards, lookups.sacred_shield, false) then
                add_extra_periodic_effect(stats, 0, 1.0, 12, 1, 1.0, "Extra");
            end
            if benefit_id == spell_name_to_id["Holy Light"] and spell.rank < 4 then
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
                stats.crit = math.min(1.0, stats.crit + loadout.melee_crit);
                stats.ot_crit = stats.crit;
            end
            if loadout.runes[rune_ids.infusion_of_light] and benefit_id == spell_name_to_id["Holy Shock"] then
                resource_refund = resource_refund + stats.crit * original_base_cost;
            end
        end
        if benefit_id == spell_name_to_id["Exorcism"] and loadout.runes[rune_ids.exorcist] then
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

        if benefit_id == spell_name_to_id["Healing Wave"] or
            benefit_id == spell_name_to_id["Lesser Healing Wave"] or
            benefit_id == spell_name_to_id["Riptide"] then
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
        if loadout.runes[rune_ids.overload] and (benefit_id == spell_name_to_id["Chain Heal"] or
                benefit_id == spell_name_to_id["Chain Lightning"] or
                benefit_id == spell_name_to_id["Healing Wave"] or
                benefit_id == spell_name_to_id["Lightning Bolt"] or
                benefit_id == spell_name_to_id["Lava Burst"]) then
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
            spell.over_time_tick_freq = wep_speed;
            -- scaling should change with weapon base speed not current attack speed
            -- but there is no easy way to get it
            if benefit_id == spell_name_to_id["Flametongue Weapon"] then
                stats.spell_mod_base = stats.spell_mod_base * 0.25 * (math.max(1.0, math.min(4.0, wep_speed)));
            elseif benefit_id == spell_name_to_id["Frostbrand Weapon"] then
                local min_proc_chance = 0.15;
                stats.hit = stats.hit * (min_proc_chance * math.max(1.0, math.min(4.0, wep_speed)));
            end
        end
        if benefit_id == spell_name_to_id["Earth Shield"] and loadout.friendly_towards == "player" then
            -- strange behaviour hacked in
            stats.effect_mod = stats.effect_mod + 0.02 * loadout.talents_table:pts(3, 14);
        end
        if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 2 and spell.base_min ~= 0 and is_buff_up(loadout, "player", lookups.water_shield, true) then

            resource_refund = resource_refund + stats.crit * 0.04 * loadout.max_mana;
        end
    elseif class == "MAGE" then
        if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
            -- clearcast
            local pts = loadout.talents_table:pts(1, 6);
            if pts ~= 0 then
                cost_mod = cost_mod * (1.0 - 0.02 * pts);
            end

            local pts = loadout.talents_table:pts(2, 12);
            if pts ~= 0 and
                (spell.school == magic_school.fire or spell.school == magic_school.frost) and
                spell.base_min ~= 0 then
                -- master of elements
                local mana_refund = pts * 0.1 * original_base_cost;
                resource_refund = resource_refund + stats.hit * stats.crit * mana_refund;
            end

            if loadout.runes[rune_ids.burnout] and spell.base_min ~= 0 then
                resource_refund = resource_refund - stats.crit * 0.01 * base_mana;
            end

            -- ignite
            local pts = loadout.talents_table:pts(2, 3);
            if pts ~= 0 and spell.school == magic_school.fire and spell.base_min ~= 0 then
                -- % ignite double dips in % multipliers
                local double_dip = stats.spell_dmg_mod_mul *
                effects.mul.by_school.spell_dmg_mod[magic_school.fire] *
                effects.mul.by_school.target_vuln_dmg[magic_school.fire];

                add_extra_periodic_effect(stats,
                                          bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod),
                                          (pts * 0.08) * double_dip, 2, 2, 1.0, "Ignite");
            end
            if benefit_id == spell_name_to_id["Arcane Surge"] then
                stats.cost = loadout.mana;
                cost_mod = 1.0;

                spell_dmg_mod_school_mul = spell_dmg_mod_school_mul *
                (1.0 + 3 * loadout.mana / math.max(1, loadout.max_mana));
            end

            if loadout.num_set_pieces[set_tiers.pve_2] >= 8 and
                (benefit_id == spell_name_to_id["Frostbolt"] or benefit_id == spell_name_to_id["Fireball"]) then
                stats.cast_time = 0.9 * stats.cast_time + 0.1 * stats.gcd;
            end

            if bit.band(loadout.flags, loadout_flags.target_frozen) ~= 0 then
                local pts = loadout.talents_table:pts(3, 13);

                stats.crit = math.max(0.0, math.min(1.0, stats.crit + pts * 0.1));

                if benefit_id == spell_name_to_id["Ice Lance"] then
                    target_vuln_mod_mul = target_vuln_mod_mul * 3;
                end
            end
            if loadout.runes[rune_ids.overheat] and
                benefit_id == spell_name_to_id["Fire Blast"] then
                stats.gcd = 0.0;
                stats.cast_time = 0.0;
            end

            if loadout.num_set_pieces[set_tiers.sod_final_pve_2] >= 6 and benefit_id == spell_name_to_id["Fireball"] then
                add_extra_periodic_effect(stats, 0, 1.0, 4, 2, 1.0, "6P Set Bonus");
            end

            if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 2 and benefit_id == spell_name_to_id["Arcane Missiles"] then
                resource_refund = resource_refund + 0.5 * original_base_cost;
            end
        end
    elseif class == "WARLOCK" then
        if benefit_id == spell_name_to_id["Chaos Bolt"] then
            stats.hit = 1.0;
            stats.target_avg_resi = 0.0;
        end

        if bit.band(spell.flags, spell_flags.destruction) ~= 0 then
            cost_mod = cost_mod - loadout.talents_table:pts(3, 2) * 0.01;
            stats.crit = math.min(1.0, stats.crit + loadout.talents_table:pts(3, 7) * 0.01);
            local crit_mod = loadout.talents_table:pts(3, 14) * 0.5;
            stats.crit_mod = stats.crit_mod + crit_mod;
            stats.ot_crit_mod = stats.ot_crit_mod + crit_mod;
        end
        if loadout.runes[rune_ids.pandemic] and
            (benefit_id == spell_name_to_id["Corruption"] or
                benefit_id == spell_name_to_id["Immolate"] or
                benefit_id == spell_name_to_id["Unstable Affliction"] or
                benefit_id == spell_name_to_id["Curse of Agony"] or
                benefit_id == spell_name_to_id["Curse of Doom"] or
                benefit_id == spell_name_to_id["Siphon Life"]) then
            stats.ot_crit = stats.crit;
            stats.ot_crit_mod = stats.ot_crit_mod + 0.5;
        end
        if loadout.runes[rune_ids.dance_of_the_wicked] and spell.base_min ~= 0 then
            resource_refund = resource_refund + stats.crit * 0.02 * loadout.max_mana;
        end

        if loadout.runes[swc.talents.rune_ids.soul_siphon] then
            if benefit_id == spell_name_to_id["Drain Soul"] then
                if loadout.enemy_hp_perc and loadout.enemy_hp_perc <= 0.2 then
                    target_vuln_mod_ot_mul = target_vuln_mod_ot_mul *
                    math.min(1.5, 1.0 + 0.5 * effects.raw.target_num_shadow_afflictions);
                else
                    target_vuln_mod_ot_mul = target_vuln_mod_ot_mul *
                    math.min(1.18, 1.0 + 0.06 * effects.raw.target_num_shadow_afflictions);
                end
            elseif benefit_id == spell_name_to_id["Drain Life"] then
                target_vuln_mod_ot_mul = target_vuln_mod_ot_mul *
                math.min(1.18, 1.0 + 0.06 * effects.raw.target_num_shadow_afflictions);
            end
        end
        if benefit_id == spell_name_to_id["Shadow Bolt"] then
            if loadout.num_set_pieces[set_tiers.sod_final_pve_2] >= 6 then
                target_vuln_mod_mul = target_vuln_mod_mul * math.min(1.3, 1.1 + 0.1 * effects.raw.target_num_afflictions);
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

                target_vuln_mod_mul = target_vuln_mod_mul / (1.0 + isb_buff_val);

                stats.hit_inflation = stats.hit_inflation + (1.0 + isb_buff_val)/(1.0 + isb_pts*0.04*isb_uptime) - 1;
            else
                stats.hit_inflation = stats.hit_inflation / (1.0 + isb_pts*0.04*isb_uptime);
            end
            target_vuln_mod_mul = target_vuln_mod_mul * (1.0 + isb_pts*0.04*isb_uptime);
        end
    end

    if spell.cast_time == spell.over_time_duration then
        -- vanilla channels cannot be improved by % spell casting speed
        stats.cast_time = spell.cast_time;
        if effects.ability.cast_mod_reduce[benefit_id] then
            stats.cast_time = stats.cast_time * (1.0 - effects.ability.cast_mod_reduce[benefit_id]);
        end
    end


    stats.cast_time_nogcd = stats.cast_time;
    stats.cast_time = math.max(stats.cast_time, stats.gcd);

    if bit.band(spell.flags, spell_flags.heal) ~= 0 then
        if not effects.ability.effect_mod_only_heal[benefit_id] then
            effects.ability.effect_mod_only_heal[benefit_id] = 0.0;
        end

        stats.spell_mod_base = stats.spell_mod_base + effects.raw.spell_heal_mod_base;

        target_vuln_mod_mul = target_vuln_mod_mul * effects.mul.raw.target_vuln_heal;
        target_vuln_mod_ot_mul = target_vuln_mod_ot_mul * effects.mul.raw.target_vuln_heal;

        stats.spell_mod =
            target_vuln_mod_mul
            *
            effects.mul.raw.spell_heal_mod
            *
            (1.0 + stats.effect_mod + effects.raw.spell_heal_mod + effects.ability.effect_mod_only_heal[benefit_id]);
        stats.spell_ot_mod =
        target_vuln_mod_ot_mul
            *
            effects.mul.raw.spell_heal_mod
            *
            (1.0 + stats.effect_mod + effects.ability.effect_ot_mod[benefit_id] + effects.raw.spell_heal_mod + effects.raw.ot_mod);
    elseif bit.band(spell.flags, spell_flags.absorb) ~= 0 then
        stats.spell_mod_base = stats.spell_mod_base + effects.raw.spell_heal_mod_base;

        stats.spell_mod =
            target_vuln_mod_mul * (1.0 + stats.effect_mod);

        stats.spell_ot_mod = target_vuln_mod_mul *
            ((1.0 + stats.effect_mod + effects.ability.effect_ot_mod[benefit_id]));
        -- hacky special case for power word: shield glyph as it scales with healing
        stats.spell_heal_mod = effects.mul.raw.spell_heal_mod
            *
            (1.0 + effects.ability.effect_ot_mod[benefit_id] + effects.raw.spell_heal_mod);
    else
        -- damage spell
        target_vuln_mod_mul = target_vuln_mod_mul * effects.mul.by_school.target_vuln_dmg[spell.school];

        local spell_dmg_mod_school_ot_mul = spell_dmg_mod_school_mul;
        local spell_dmg_mod_school_ot = spell_dmg_mod_school;

        if bit.band(spell.flags, spell_flags.special_periodic_school) ~= 0 then
            spell_dmg_mod_school_ot_mul = effects.mul.by_school.spell_dmg_mod[spell.multi_school[1]];
            spell_dmg_mod_school_ot = effects.by_school.spell_dmg_mod[spell.multi_school[1]];
            target_vuln_mod_ot_mul = target_vuln_mod_ot_mul *
                effects.mul.by_school.target_vuln_dmg[spell.multi_school[1]] * effects.mul.by_school.target_vuln_dmg_ot[spell.multi_school[1]];
        else
            target_vuln_mod_ot_mul = target_vuln_mod_ot_mul *
                effects.mul.by_school.target_vuln_dmg[spell.school] * effects.mul.by_school.target_vuln_dmg_ot[spell.school];
        end

        -- multischool dipping
        if bit.band(spell.flags, spell_flags.multi_school) ~= 0 then
            for _, v in pairs(spell.multi_school) do
                spell_dmg_mod_school_mul = spell_dmg_mod_school_mul *
                    (1.0 + effects.mul.by_school.spell_dmg_mod[v] - effects.mul.by_school.spell_dmg_mod[magic_school.physical]);
                spell_dmg_mod_school = spell_dmg_mod_school + effects.by_school.spell_dmg_mod[v] -
                effects.by_school.spell_dmg_mod[magic_school.physical];

                target_vuln_mod_mul = target_vuln_mod_mul *
                (1.0 + effects.mul.by_school.target_vuln_dmg[v] - effects.mul.by_school.target_vuln_dmg[magic_school.physical]);
                target_vuln_mod_ot_mul = target_vuln_mod_ot_mul *
                (1.0 + effects.mul.by_school.target_vuln_dmg[v] + effects.mul.by_school.target_vuln_dmg_ot[v] - (effects.mul.by_school.target_vuln_dmg[magic_school.physical] + effects.mul.by_school.target_vuln_dmg_ot[magic_school.physical]));
            end
            spell_dmg_mod_school_ot_mul = spell_dmg_mod_school_mul;
            spell_dmg_mod_school_ot = spell_dmg_mod_school;
        end

        stats.spell_mod =
            target_vuln_mod_mul
            *
            stats.spell_dmg_mod_mul
            *
            spell_dmg_mod_school_mul
            *
            (1.0 + stats.effect_mod + spell_dmg_mod_school);

        stats.spell_ot_mod =
            target_vuln_mod_ot_mul
            *
            stats.spell_dmg_mod_mul
            *
            spell_dmg_mod_school_ot_mul
            *
            (1.0 + stats.effect_mod + effects.ability.effect_ot_mod[benefit_id] + spell_dmg_mod_school_ot + effects.raw.ot_mod);
    end

    if bit.band(spell.flags, spell_flags.alias) ~= 0 then
        stats.spell_mod = 1.0 + stats.effect_mod;
        stats.spell_ot_mod = 1.0 + stats.effect_mod;
    end

    stats.ot_extra_ticks = effects.ability.extra_ticks[benefit_id];
    if not stats.ot_extra_ticks then
        stats.ot_extra_ticks = 0.0;
    end

    stats.spell_dmg = loadout.spell_dmg + loadout.spell_dmg_by_school[spell.school] +
        effects.raw.spell_dmg + effects.raw.spell_power;

    if bit.band(spell.flags, spell_flags.multi_school) ~= 0 then
        for _, v in pairs(spell.multi_school) do
            stats.spell_dmg = stats.spell_dmg + loadout.spell_dmg_by_school[v];
        end
    end

    stats.spell_heal = loadout.healing_power + effects.raw.healing_power + effects.raw.spell_power;
    stats.attack_power = loadout.attack_power;
    if bit.band(spell.flags, spell_flags.heal) ~= 0 or bit.band(spell.flags, spell_flags.absorb) ~= 0 then
        stats.spell_power = stats.spell_heal;
    else
        stats.spell_power = stats.spell_dmg;
    end

    if bit.band(spell.flags, spell_flags.hybrid_scaling) ~= 0 then
        stats.spell_power = stats.spell_power + stats.attack_power;
    end

    if effects.ability.sp[benefit_id] then
        stats.spell_power = stats.spell_power + effects.ability.sp[benefit_id];
    end
    if bit.band(spell.flags, spell_flags.special_periodic_school) ~= 0 then
        stats.spell_power_ot = loadout.spell_dmg + loadout.spell_dmg_by_school[spell.multi_school[1]] +
            effects.raw.spell_dmg + effects.raw.spell_power;
    else
        stats.spell_power_ot = stats.spell_power;
    end

    if effects.ability.sp_ot[benefit_id] then
        stats.spell_power_ot = stats.spell_power_ot + effects.ability.sp_ot[benefit_id];
    end

    stats.cost = stats.cost * cost_mod;
    stats.cost = math.floor(stats.cost + 0.5);

    if effects.ability.refund[benefit_id] and effects.ability.refund[benefit_id] ~= 0 then
        local refund = effects.ability.refund[benefit_id];
        local max_rank = spell.rank;
        if benefit_id == spell_name_to_id["Lesser Healing Wave"] then
            max_rank = 6;
        elseif benefit_id == spell_name_to_id["Healing Touch"] then
            max_rank = 11;
        end

        local coef_estimate = spell.rank / max_rank;

        resource_refund = resource_refund + refund * coef_estimate;
    end

    stats.cost = stats.cost - resource_refund;
    stats.cost = math.max(stats.cost, 0);

    stats.coef = spell.coef;
    stats.ot_coef = spell.over_time_coef;

    if effects.ability.coef_mod[benefit_id] then
        stats.coef = stats.coef + effects.ability.coef_mod[benefit_id];
    end
    if effects.ability.coef_ot_mod[benefit_id] then
        stats.ot_coef = stats.ot_coef * (1.0 + effects.ability.coef_ot_mod[benefit_id]);
    end

    stats.cost_per_sec = stats.cost / stats.cast_time;

    spell = spells[original_spell_id];
end

local function resolve_extra_spell_effects(info, stats)
    info.num_extra_periodic_effects = 0;
    info.num_extra_direct_effects = 0;

    for k = 1, stats.num_extra_effects do
        if (stats["extra_effect_is_periodic" .. k]) then
            info.num_extra_periodic_effects = info.num_extra_periodic_effects + 1;
            local i = info.num_extra_periodic_effects;
            if (stats["extra_effect_on_crit" .. k]) then
                info["ot_if_hit" .. i] = 0;
                info["ot_if_hit_max" .. i] = 0;
                if (stats["extra_effect_base_on_periodic" .. k]) then
                    info["ot_if_crit" .. i] = stats["extra_effect_val" .. k] * info.ot_if_crit;
                    info["ot_if_crit_max" .. i] = stats["extra_effect_val" .. k] * info.ot_if_crit_max;
                else
                    info["ot_if_crit" .. i] = stats["extra_effect_val" .. k] * info.min_crit_if_hit;
                    info["ot_if_crit_max" .. i] = stats["extra_effect_val" .. k] * info.max_crit_if_hit;
                end
                info["ot_ticks" .. i] = stats["extra_effect_ticks" .. k];
                info["ot_freq" .. i] = stats["extra_effect_freq" .. k];
                info["ot_duration" .. i] = stats["extra_effect_ticks" .. k] * stats["extra_effect_freq" .. k];
                info["ot_description" .. i] = stats["extra_effect_desc" .. k];
                info["ot_crit" .. i] = stats.crit;
                info["ot_utilization" .. i] = stats["extra_effect_util" .. k];
            else
                if (stats["extra_effect_base_on_periodic" .. k]) then
                    info["ot_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_if_hit;
                    info["ot_if_hit_max" .. i] = stats["extra_effect_val" .. k] * info.ot_if_hit_max;
                    info["ot_if_crit" .. i] = stats["extra_effect_val" .. k] * info.ot_if_crit;
                    info["ot_if_crit_max" .. i] = stats["extra_effect_val" .. k] * info.ot_if_crit_max;

                else
                    info["ot_if_hit" .. i] = stats["extra_effect_val" .. k] * info.min_noncrit_if_hit;
                    info["ot_if_hit_max" .. i] = stats["extra_effect_val" .. k] * info.max_noncrit_if_hit;
                    info["ot_if_crit" .. i] = stats["extra_effect_val" .. k] * info.min_crit_if_hit;
                    info["ot_if_crit_max" .. i] = stats["extra_effect_val" .. k] * info.max_crit_if_hit;
                end
                info["ot_ticks" .. i] = stats["extra_effect_ticks" .. k];
                info["ot_freq" .. i] = stats["extra_effect_freq" .. k];
                info["ot_duration" .. i] = stats["extra_effect_ticks" .. k] * stats["extra_effect_freq" .. k];
                info["ot_description" .. i] = stats["extra_effect_desc" .. k];
                info["ot_crit" .. i] = stats.crit;
                info["ot_utilization" .. i] = stats["extra_effect_util" .. k];
            end
        else
            info.num_extra_direct_effects = info.num_extra_direct_effects + 1;
            local i = info.num_extra_direct_effects;

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
                    info["min_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_if_hit;
                    info["max_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_if_hit_max;
                    info["min_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_if_crit;
                    info["max_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.ot_if_crit_max;
                else
                    info["min_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.min_noncrit_if_hit;
                    info["max_noncrit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.max_noncrit_if_hit;
                    info["min_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.min_crit_if_hit;
                    info["max_crit_if_hit" .. i] = stats["extra_effect_val" .. k] * info.max_crit_if_hit;
                end
            end
            if (stats["extra_effect_on_crit" .. k]) then
                info["min_noncrit_if_hit" .. i] = 0;
                info["max_noncrit_if_hit" .. i] = 0;
            end
        end
    end

    -- accumulate periodics
    info.total_ot_if_hit      = info.ot_if_hit;
    info.total_ot_if_hit_max  = info.ot_if_hit_max;
    info.total_ot_if_crit     = info.ot_if_crit;
    info.total_ot_if_crit_max = info.ot_if_crit_max;
    for i = 1, info.num_extra_periodic_effects do
        local p                   = info["ot_utilization" .. i];
        info.total_ot_if_hit      = info.total_ot_if_hit + p * info["ot_if_hit" .. i];
        info.total_ot_if_hit_max  = info.total_ot_if_hit_max + p * info["ot_if_hit_max" .. i];
        info.total_ot_if_crit     = info.total_ot_if_crit + p * info["ot_if_crit" .. i];
        info.total_ot_if_crit_max = info.total_ot_if_crit_max + p * info["ot_if_crit_max" .. i];
    end

    -- accumulate directs
    info.total_min_noncrit_if_hit = info.min_noncrit_if_hit;
    info.total_max_noncrit_if_hit = info.max_noncrit_if_hit;
    info.total_min_crit_if_hit    = info.min_crit_if_hit;
    info.total_max_crit_if_hit    = info.max_crit_if_hit;
    for i = 1, info.num_extra_direct_effects do
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
    local expected_direct_if_hit = (1 - stats.crit) * 0.5 * (info.min_noncrit_if_hit + info.max_noncrit_if_hit) +
        stats.crit * 0.5 * (info.min_crit_if_hit + info.max_crit_if_hit);

    for i = 1, info.num_extra_direct_effects do
        expected_direct_if_hit = expected_direct_if_hit + info["direct_utilization" .. i] *
            ((1.0 - info["crit" .. i]) * 0.5 * (info["min_noncrit_if_hit" .. i] + info["max_noncrit_if_hit" .. i]) +
                info["crit" .. i] * 0.5 * (info["min_crit_if_hit" .. i] + info["max_crit_if_hit" .. i]));
    end

    info.expectation_direct_st = stats.hit * expected_direct_if_hit * (1 - stats.target_avg_resi);
    info.expectation_direct = info.expectation_direct_st;
    if bit.band(spell.flags, spell_flags.unbounded_aoe_direct) ~= 0 then
        info.expectation_direct = info.expectation_direct_st * num_unbounded_targets;
    end

    -- over time
    local expected_ot_if_hit = (1.0 - stats.ot_crit) * 0.5 * (info.ot_if_hit + info.ot_if_hit_max) +
    stats.ot_crit * 0.5 * (info.ot_if_crit + info.ot_if_crit_max);

    for i = 1, info.num_extra_periodic_effects do
        expected_ot_if_hit = expected_ot_if_hit + info["ot_utilization" .. i] *
            ((1.0 - info["ot_crit" .. i]) * 0.5 * (info["ot_if_hit" .. i] + info["ot_if_hit_max" .. i]) +
                info["ot_crit" .. i] * 0.5 * (info["ot_if_crit" .. i] + info["ot_if_crit_max" .. i]));
    end

    info.expected_ot_st = stats.hit * expected_ot_if_hit * (1 - stats.target_avg_resi_dot);

    info.expected_ot = info.expected_ot_st;
    if bit.band(spell.flags, spell_flags.unbounded_aoe_ot) ~= 0 then
        info.expected_ot = info.expected_ot_st * num_unbounded_targets;
    end

    -- combine
    info.expectation_st = info.expectation_direct_st + info.expected_ot_st
    info.expectation = info.expectation_direct + info.expected_ot

    if loadout.beacon and bit.band(spell_flags.heal, spell.flags) ~= 0 then
        add_expectation_direct_st(info, 0.75);
    end
end

local function spell_info(info, spell, stats, loadout, effects, eval_flags)
    eval_flags = eval_flags or 0;

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
    local num_unbounded_targets = loadout.unbounded_aoe_targets;
    if bit.band(eval_flags, evaluation_flags.assume_single_effect) ~= 0 then
        num_unbounded_targets = 1;
    end

    -- level scaling
    local lvl_diff_applicable = 0;
    if spell.lvl_scaling > 0 then
        -- spell data is at spell base lvl
        lvl_diff_applicable = math.max(0,
            math.min(loadout.lvl - spell.lvl_req, spell.lvl_max - spell.lvl_req));
    end
    if base_min > 0.0 then
        -- special sod runed ability lvl scaling
        if bit.band(spell.flags, spell_flags.sod_rune) ~= 0 then
            base_min = spell.lvl_coef *
            (base_min + spell.lvl_scaling * lvl_diff_applicable + spell.lvl_scaling_squared * lvl_diff_applicable * lvl_diff_applicable);
            base_max = spell.lvl_coef_max *
            (base_max + spell.lvl_scaling * lvl_diff_applicable + spell.lvl_scaling_squared * lvl_diff_applicable * lvl_diff_applicable);
        else
            -- normal direct per lvl scaling
            base_min = base_min + spell.lvl_scaling * lvl_diff_applicable;
            base_max = base_max + spell.lvl_scaling * lvl_diff_applicable;
        end
    end

    if bit.band(spell.flags, spell_flags.sod_rune) ~= 0 then
        -- special sod runed ability periodic lvl scaling
        base_ot_tick = spell.lvl_coef_ot *
        (base_ot_tick + spell.lvl_scaling * lvl_diff_applicable + spell.lvl_scaling_squared * lvl_diff_applicable * lvl_diff_applicable);
        base_ot_tick_max = spell.lvl_coef_ot_max *
        (base_ot_tick_max + spell.lvl_scaling * lvl_diff_applicable + spell.lvl_scaling_squared * lvl_diff_applicable * lvl_diff_applicable);
    elseif bit.band(spell.flags, spell_flags.over_time_lvl_scaling) ~= 0 then
        -- normal over time per lvl scaling
        base_ot_tick = base_ot_tick + spell.lvl_scaling * lvl_diff_applicable;
        base_ot_tick_max = base_ot_tick_max + spell.lvl_scaling * lvl_diff_applicable;
    end

    info.ot_freq = spell.over_time_tick_freq;
    info.ot_duration = spell.over_time_duration;

    if spell.cast_time == spell.over_time_duration then
        info.ot_freq = spell.over_time_tick_freq * (stats.cast_time / spell.over_time_duration);
        info.ot_duration = stats.cast_time;
    end

    info.min_noncrit_if_hit_base =
        (base_min * stats.spell_mod_base + stats.flat_addition) * stats.spell_mod;
    info.max_noncrit_if_hit_base =
        (base_max * stats.spell_mod_base + stats.flat_addition) * stats.spell_mod;

    info.min_noncrit_if_hit =
        info.min_noncrit_if_hit_base + stats.spell_power * stats.coef  * stats.spell_mod;
    info.max_noncrit_if_hit =
        info.max_noncrit_if_hit_base + stats.spell_power * stats.coef * stats.spell_mod;

    info.min_crit_if_hit = info.min_noncrit_if_hit * stats.crit_mod;
    info.max_crit_if_hit = info.max_noncrit_if_hit * stats.crit_mod;

    info.ot_if_hit_base = 0.0;
    info.ot_if_hit_max_base = 0.0;
    info.ot_if_hit = 0.0;
    info.ot_if_hit_max = 0.0;
    info.ot_if_crit = 0.0;
    info.ot_if_crit_max = 0.0;
    info.ot_ticks = 0;

    if base_ot_tick > 0 then
        local base_ot_num_ticks = (info.ot_duration / info.ot_freq);
        local ot_coef_per_tick = stats.ot_coef

        info.ot_ticks = base_ot_num_ticks + stats.ot_extra_ticks;

        info.ot_if_hit_base = (base_ot_tick * stats.spell_mod_base + stats.flat_addition_ot) * info.ot_ticks * stats.spell_ot_mod;

        info.ot_if_hit = info.ot_if_hit_base + ot_coef_per_tick * stats.spell_power_ot * info.ot_ticks * stats.spell_ot_mod;

        info.ot_if_hit_max_base = (base_ot_tick_max * stats.spell_mod_base + stats.flat_addition_ot) * info.ot_ticks * stats.spell_ot_mod;

        info.ot_if_hit_max = info.ot_if_hit_max_base + ot_coef_per_tick * stats.spell_power_ot * info.ot_ticks * stats.spell_ot_mod;

        if stats.ot_crit > 0 then
            info.ot_if_crit = info.ot_if_hit * stats.ot_crit_mod;
            info.ot_if_crit_max = info.ot_if_hit_max * stats.ot_crit_mod;
        end
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
        info.absorb = info.min_noncrit_if_hit;

        info.min_noncrit_if_hit = 0.0;
        info.max_noncrit_if_hit = 0.0;

        info.min_crit_if_hit = 0.0;
        info.max_crit_if_hit = 0.0;
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
    if bit.band(spell.flags, spell_flags.channel_missable) ~= 0 then
        local cast_time_avoided_by_miss = info.ot_duration - stats.gcd;

        stats.cast_time = stats.cast_time - cast_time_avoided_by_miss * (1.0 - stats.hit);
        stats.cast_time_nogcd = stats.cast_time;

        info.longest_ot_duration = stats.cast_time;
    else
        info.longest_ot_duration = info.ot_duration;
    end

    info.effect_per_sec = info.expectation / stats.cast_time;

    if stats.cost == 0 then
        info.effect_per_cost = math.huge;
    else
        info.effect_per_cost = info.expectation / stats.cost;
    end

    info.cost_per_sec = stats.cost / stats.cast_time;
    info.ot_duration = info.ot_duration + stats.ot_extra_ticks * info.ot_freq;

    for i = 1, info.num_extra_periodic_effects do
        info.longest_ot_duration = math.max(info.longest_ot_duration, info["ot_duration" .. i]);
    end
    info.effect_per_dur = 0;
    if info.longest_ot_duration ~= 0 then
        info.effect_per_dur = info.expected_ot / info.longest_ot_duration;
    end

    if bit.band(spell.flags, spell_flags.mana_regen) ~= 0 then
        if spell.base_id == spell_name_to_id["Life Tap"] then
            info.mana_restored = base_min;

            local pts = loadout.talents_table:pts(1, 5);
            info.mana_restored = info.mana_restored * (1.0 + pts * 0.1);
            if stats.crit == 1.0 then
                info.mana_restored = 2 * info.mana_restored;
            end
        elseif spell.base_id == spell_name_to_id["Mana Tide Totem"] then
            info.mana_restored = spell.over_time * spell.over_time_duration / spell.over_time_tick_freq;
        elseif spell.base_id == spell_name_to_id["Dispersion"] or spell.base_id == spell_name_to_id["Shadowfiend"] or spell.base_id == spell_name_to_id["Shamanistic Rage"] then
            info.mana_restored = spell.over_time * loadout.max_mana * spell.over_time_duration /
            spell.over_time_tick_freq;
        else
            -- evocate, innervate
            local spirit = loadout.stats[stat.spirit] + effects.by_attribute.stats[stat.spirit];
            local mp5 = effects.raw.mp5 + loadout.max_mana * effects.raw.perc_max_mana_as_mp5;
            info.mana_restored = 0.2 * mp5 +
                0.5 * spirit_mana_regen(spirit) *
                (1.0 + spell.base_min) * math.max(stats.cast_time, spell.over_time_duration);
        end
        info.effect_per_cost = math.huge;
    end

    info.min_noncrit_if_hit = info.min_noncrit_if_hit * stats.hit_inflation;
    info.max_noncrit_if_hit = info.max_noncrit_if_hit * stats.hit_inflation;
    info.min_crit_if_hit = info.min_crit_if_hit       * stats.hit_inflation;
    info.max_crit_if_hit = info.max_crit_if_hit       * stats.hit_inflation;

    info.ot_if_hit = info.ot_if_hit                   * stats.hit_inflation;
    info.ot_if_hit_max = info.ot_if_hit_max           * stats.hit_inflation;
    info.ot_if_crit = info.ot_if_crit                 * stats.hit_inflation;
    info.ot_if_crit_max = info.ot_if_crit_max         * stats.hit_inflation;

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
        [spell_name_to_id["Chain Heal"]] = function(spell, info, loadout)
            local jmp_red = 0.5;
            local jmp_num = 2;
            if loadout.runes[rune_ids.coherence] then
                jmp_red = jmp_red + 0.15;
                jmp_num = 3;
            end
            if loadout.num_set_pieces[set_tiers.pve_2] >= 3 then
                jmp_red = jmp_red * 1.3;
            end

            local jmp_sum = 0;
            for i = 1, jmp_num do
                local jmp_effect = 1;
                for j = 1, i do
                    jmp_effect = jmp_effect * jmp_red;
                end
                jmp_sum = jmp_sum + jmp_effect;
            end
            add_expectation_direct_st(info, jmp_sum);
        end,
        [spell_name_to_id["Lightning Shield"]] = function(spell, info, loadout, stats)
            if loadout.runes[rune_ids.static_shock] then
                add_expectation_direct_st(info, 8);
            elseif loadout.runes[rune_ids.overcharged] == nil then
                add_expectation_direct_st(info, 2);
            end
            if loadout.runes[rune_ids.overcharged] then
                stats.cost = 0;
                stats.cast_time = 1;
                stats.cast_time_nogcd = 1;
                -- convert into periodic, with duration 1 sec to not go infinite


                info.ot_if_hit = info.min_noncrit_if_hit;
                info.ot_if_hit_max = info.max_noncrit_if_hit;
                info.ot_if_crit = info.min_crit_if_hit;
                info.ot_if_crit_max = info.max_crit_if_hit;
                info.ot_ticks = 1;
                info.ot_duration = 1;
                info.ot_freq = 1;
                stats.ot_crit = stats.crit;

                stats.ot_coef = stats.coef;
                stats.coef = 0;
                info.min_noncrit_if_hit = 0;
                info.max_noncrit_if_hit = 0;
                info.min_crit_if_hit = 0;
                info.max_crit_if_hit = 0;

                calc_expectation(info, spell, stats, loadout);
            end
        end,
        [spell_name_to_id["Chain Lightning"]] = function(spell, info, loadout)
            local jmp_num = 2;
            local jmp_red = 0.7;
            if loadout.runes[rune_ids.coherence] then
                jmp_red = jmp_red + 0.1;
                jmp_num = 3;
            end

            if loadout.num_set_pieces[set_tiers.pve_2_5_1] >= 3 then
                jmp_red = jmp_red + 0.05;
            end

            local jmp_sum = 0;
            for i = 1, jmp_num do
                local jmp_effect = 1;
                for j = 1, i do
                    jmp_effect = jmp_effect * jmp_red;
                end
                jmp_sum = jmp_sum + jmp_effect;
            end
            add_expectation_direct_st(info, jmp_sum);
        end,
        [spell_name_to_id["Healing Wave"]] = function(spell, info, loadout)
            if loadout.num_set_pieces[set_tiers.pve_1] >= 8 or loadout.num_set_pieces[set_tiers.sod_final_pve_1_heal] >= 6 then
                add_expectation_direct_st(info, 0.4 + 0.4 * 0.4);
            end
        end,
        [spell_name_to_id["Healing Stream Totem"]] = function(spell, info, loadout, stats, effects)
            add_expectation_ot_st(info, 4);
        end,
        [spell_name_to_id["Healing Rain"]] = function(spell, info, loadout, stats, effects)
            add_expectation_ot_st(info, 4);
        end,
        [spell_name_to_id["Earth Shield"]] = function(spell, info, loadout)
            add_expectation_direct_st(info, 8);
        end,
        [spell_name_to_id["Flame Shock"]] = function(spell, info, loadout, stats, effects)
            if loadout.runes[rune_ids.burn] then
                add_expectation_ot_st(info, 4);
                add_expectation_direct_st(info, 4);
            end
        end,
        [spell_name_to_id["Earth Shock"]] = function(spell, info, loadout, stats, effects)
            if loadout.runes[rune_ids.rolling_thunder] and spell.base_id == spell_name_to_id["Earth Shock"] then
                if not stats.secondary_ability_stats then
                    stats.secondary_ability_stats = {};
                    stats.secondary_ability_info = {};
                end

                local lightning_shield = spells[best_rank_by_lvl(spell_name_to_id["Lightning Shield"], loadout.lvl)];

                spell_info_from_stats(stats.secondary_ability_info,
                    stats.secondary_ability_stats,
                    lightning_shield,
                    loadout,
                    effects);

                local ls_stacks = 0;
                if loadout.dynamic_buffs["player"][lookups.lightning_shield] then
                    ls_stacks = loadout.dynamic_buffs["player"][lookups.lightning_shield].count;
                    ls_stacks = ls_stacks - 3;
                elseif config.loadout.force_apply_buffs and loadout.buffs[lookups.lightning_shield] then
                    ls_stacks = 9 - 3;
                end
                if ls_stacks > 0 then
                    info.num_extra_direct_effects = info.num_extra_direct_effects + 1;
                    local i = info.num_extra_direct_effects;
                    info["direct_description" .. i] = string.format("Lightning Shield %dx", ls_stacks);
                    info["direct_utilization" .. i] = 1.0;

                    local ls_dmg = stats.secondary_ability_info.min_noncrit_if_hit * ls_stacks;

                    info["min_noncrit_if_hit" .. i] = ls_dmg;
                    info["max_noncrit_if_hit" .. i] = ls_dmg;
                    info["min_crit_if_hit" .. i] = ls_dmg * stats.crit_mod;
                    info["max_crit_if_hit" .. i] = ls_dmg * stats.crit_mod;
                    info["crit" .. i] = stats.secondary_ability_stats.crit;
                end
            end
            calc_expectation(info, spell, stats, loadout);
        end,
    };
elseif class == "PRIEST" then
    special_abilities = {
        [spell_name_to_id["Shadowguard"]] = function(spell, info, loadout)
            add_expectation_direct_st(info, 2);
        end,
        [spell_name_to_id["Prayer of Healing"]] = function(spell, info, loadout, stats, effects)
            add_expectation_direct_st(info, 4);
            add_expectation_ot_st(info, 4);
        end,
        [spell_name_to_id["Circle of Healing"]] = function(spell, info, loadout, stats, effects)
            add_expectation_direct_st(info, 4);
            add_expectation_ot_st(info, 4);
        end,
        [spell_name_to_id["Prayer of Mending"]] = function(spell, info, loadout, stats, effects)
            add_expectation_direct_st(info, 4);
        end,
        [spell_name_to_id["Shadow Word: Pain"]] = function(spell, info, loadout, stats, effects)
            if loadout.runes[rune_ids.shared_pain] then
                add_expectation_ot_st(info, 2);
            end
        end,
        [spell_name_to_id["Holy Nova"]] = function(spell, info, loadout)
            if bit.band(spell.flags, spell_flags.heal) ~= 0 then
                add_expectation_direct_st(info, 4);
            end
        end,
        [spell_name_to_id["Lightwell"]] = function(spell, info, loadout)
            add_expectation_ot_st(info, 4);
        end,
        [spell_name_to_id["Greater Heal"]] = function(spell, info, loadout, stats, effects)
            if loadout.num_set_pieces[set_tiers.pve_2] >= 8 then
                if not stats.secondary_ability_stats then
                    stats.secondary_ability_stats = {};
                    stats.secondary_ability_info = {};
                end
                spell_info_from_stats(stats.secondary_ability_info, stats.secondary_ability_stats, spells[6077], loadout,
                    effects);

                info.ot_if_hit = stats.secondary_ability_info.ot_if_hit;
                info.ot_if_hit_max = stats.secondary_ability_info.ot_if_hit_max;
                info.ot_if_crit = stats.secondary_ability_info.ot_if_crit;
                info.ot_if_crit_max = stats.secondary_ability_info.ot_if_crit_max;
                info.ot_ticks = stats.secondary_ability_info.ot_ticks;
                info.ot_duration = stats.secondary_ability_info.ot_duration;
                info.ot_freq = stats.secondary_ability_info.ot_freq;
                info.expected_ot = stats.secondary_ability_info.expected_ot;

                stats.ot_coef = stats.secondary_ability_stats.ot_coef;
            end

            calc_expectation(info, spell, stats, loadout);
        end,
        [spell_name_to_id["Renew"]] = function(spell, info, loadout, stats, effects)
            if loadout.runes[rune_ids.empowered_renew] then
                local direct = info.ot_if_hit / info.ot_ticks;

                info.min_noncrit_if_hit = direct;
                info.max_noncrit_if_hit = direct;
                info.min_crit_if_hit = direct * stats.crit_mod;
                info.max_crit_if_hit = direct * stats.crit_mod;

                calc_expectation(info, spell, stats, loadout);
            end
        end,
        [spell_name_to_id["Binding Heal"]] = function(spell, info, loadout, stats, effects)
            add_expectation_direct_st(info, 1);
        end,
        [spell_name_to_id["Penance"]] = function(spell, info, loadout, stats, effects)

            if is_buff_up(loadout, "player", lookups.rapid_healing, true) and
                bit.band(swc.core.client_deviation, swc.core.client_deviation_flags.sod) ~= 0 then

                add_expectation_ot_st(info, 2);
            end
        end
    };
elseif class == "DRUID" then
    special_abilities = {
        [spell_name_to_id["Tranquility"]] = function(spell, info, loadout)
            add_expectation_ot_st(info, 4);
        end,
        [spell_name_to_id["Swiftmend"]] = function(spell, info, loadout, stats, effects)
            if not stats.secondary_ability_stats then
                stats.secondary_ability_stats = {};
                stats.secondary_ability_info = {};
            end

            local num_ticks = 4;
            local hot_spell = spells[best_rank_by_lvl(spell_name_to_id["Rejuvenation"], loadout.lvl)];
            if not loadout.force_apply_buffs then
                local rejuv_buff = loadout.dynamic_buffs[loadout.friendly_towards][lookups.rejuvenation];
                local regrowth_buff = loadout.dynamic_buffs[loadout.friendly_towards][lookups.regrowth];
                -- TODO VANILLA: maybe swiftmend uses remaining ticks so could take that into account
                if regrowth_buff then
                    if not rejuv_buff or regrowth_buff.dur < rejuv_buff.dur then
                        hot_spell = spells[best_rank_by_lvl(spell_name_to_id["Regrowth"], loadout.lvl)];
                    end
                    num_ticks = 6;
                end
            end
            if not hot_spell then
                hot_spell = spells[774];
            end

            spell_info_from_stats(stats.secondary_ability_info,
                stats.secondary_ability_stats,
                hot_spell,
                loadout,
                effects);


            stats.coef = stats.ot_coef * num_ticks;
            stats.ot_coef = 0;

            local heal_amount = stats.secondary_ability_stats.spell_mod * num_ticks *
            stats.secondary_ability_info.ot_if_hit / stats.secondary_ability_info.ot_ticks;

            info.min_noncrit_if_hit = heal_amount;
            info.max_noncrit_if_hit = heal_amount;

            info.min_crit_if_hit = stats.crit_mod * heal_amount;
            info.max_crit_if_hit = stats.crit_mod * heal_amount;

            if loadout.runes[rune_ids.efflorescence] then
                spell_info_from_stats(stats.secondary_ability_info,
                    stats.secondary_ability_stats,
                    spells[417149],
                    loadout,
                    effects);

                info.ot_if_hit = stats.secondary_ability_info.ot_if_hit;
                info.ot_if_hit_max = stats.secondary_ability_info.ot_if_hit_max;

                info.ot_if_crit = stats.secondary_ability_info.ot_if_crit;
                info.ot_if_crit_max = stats.secondary_ability_info.ot_if_crit_max;
                stats.ot_crit = stats.secondary_ability_stats.ot_crit;

                info.ot_duration = stats.secondary_ability_info.ot_duration;
                info.ot_freq = stats.secondary_ability_info.ot_freq;
                info.ot_ticks = stats.secondary_ability_info.ot_ticks;
            end

            calc_expectation(info, spell, stats, loadout);
            add_expectation_ot_st(info, 4);
        end,
        [spell_name_to_id["Wild Growth"]] = function(spell, info, loadout)
            add_expectation_ot_st(info, 4);
        end,
        [spell_name_to_id["Efflorescence"]] = function(spell, info, loadout)
            add_expectation_ot_st(info, 4);
        end,
    };
elseif class == "WARLOCK" then
    special_abilities = {
        [spell_name_to_id["Shadow Cleave"]] = function(spell, info, loadout, stats, effects)
            add_expectation_direct_st(info, 9);
        end,
        [spell_name_to_id["Shadow Bolt"]] = function(spell, info, loadout)
            if loadout.runes[rune_ids.shadow_bolt_volley] then
                add_expectation_direct_st(info, 4);
            end
        end,
    };
elseif class == "PALADIN" then
    special_abilities = {
        [spell_name_to_id["Avenger's Shield"]] = function(spell, info, loadout)
            add_expectation_direct_st(info, 2);
        end,
    };
elseif class == "MAGE" then
    special_abilities = {
        [spell_name_to_id["Mass Regeneration"]] = function(spell, info, loadout)
            add_expectation_ot_st(info, 4);
        end,
        [spell_name_to_id["Mana Shield"]] = function(spell, info, loadout, stats)
            local pts = loadout.talents_table:pts(1, 10);
            local drain_mod = 0.1 * pts;
            if loadout.runes[rune_ids.advanced_warding] then
                drain_mod = drain_mod + 0.5;
            end
            stats.cost = stats.cost + 2 * info.absorb * (1.0 - drain_mod);
        end,
        [spell_name_to_id["Temporal Anomaly"]] = function(spell, info, loadout)
            add_expectation_ot_st(info, 4);
        end,
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
    local spell_effect_until_oom_1spirit_delta = spell_effect_extra_1spirit.effect_until_oom -
    spell_effect.effect_until_oom;
    local spell_effect_until_oom_1mp5_delta = spell_effect_extra_1mp5.effect_until_oom - spell_effect.effect_until_oom;

    local result = {
        spell = spell_effect,
    };
    if bit.band(spell.flags, spell_flags.mana_regen) == 0 then
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
