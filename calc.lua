local _, sc = ...;

local attr                                          = sc.attr;
local spells                                        = sc.spells;
local spids                                         = sc.spids;
local schools                                       = sc.schools;
local class                                         = sc.class;
local classes                                       = sc.classes;
local powers                                        = sc.powers;
local spell_flags                                   = sc.spell_flags;
local comp_flags                                    = sc.comp_flags;

local best_rank_by_lvl                              = sc.utils.best_rank_by_lvl;

local config                                        = sc.config;

local effects_zero_diff                             = sc.loadout.effects_zero_diff;
local effects_diff                                  = sc.loadout.effects_diff;
local empty_effects                                 = sc.loadout.empty_effects;
local cpy_effects                                   = sc.loadout.cpy_effects;
local loadout_flags                                 = sc.loadout.loadout_flags;

local set_tiers                                     = sc.equipment.set_tiers;

local is_buff_up                                    = sc.buffs.is_buff_up;

local dps_per_ap                                    = sc.scaling.dps_per_ap;
local get_combat_rating_effect                      = sc.scaling.get_combat_rating_effect;
local spirit_mana_regen                             = sc.scaling.spirit_mana_regen;

local client_class_stats_spell                      = sc.mechanics.client_class_stats_spell;

--------------------------------------------------------------------------------
local calc              = {};

local simulation_type   = {
    spam_cast      = 1,
    cast_until_oom = 2
};

local evaluation_flags = {
    assume_single_effect                    = bit.lshift(1, 1),
    isolate_periodic                        = bit.lshift(1, 2),
    isolate_direct                          = bit.lshift(1, 3),
    isolate_mh                              = bit.lshift(1, 4),
    isolate_oh                              = bit.lshift(1, 5),
    stat_weights                            = bit.lshift(1, 6),

    -- To ignore when e.g. heroic strike normally uses expectation as gains over normal attack
    expectation_of_self                     = bit.lshift(1, 7),
};

local lookups = {
    bol_ids = { 19977, 19978, 19979, 25890 },
    bol_rank_to_hl_coef_subtract = {
        [1] = 1.0 - (1 - (20 - 1) * 0.0375) * 2.5 / 3.5, -- lvl 1 hl coef used
        [2] = 1.0 - 0.4,
        [3] = 1.0 - 0.7,
    },
    isb_ids = { 177944, 177988, 177972, 177996, 17800 },
    sacred_shield = 412019,
    lightning_shield = 324,
    rejuvenation = 774,
    regrowth = 8936,
    rapid_healing = 468531,
    water_shield = 408510,
};


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

local function spell_hit_calc(extra_hit, avg_resi, loadout, spell)
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
        final_avg_resi = 0.0;
    else
        final_hit = math.min(0.99, final_hit);
    end

    return final_hit, final_avg_resi;
end

local special_abilities;

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

-- For physical mechanics, formulas are based on this
-- @src: https://github.com/magey/classic-warrior/wiki/Attack-table
local function stats_attack_skill(comp, loadout, effects, eval_flags)
    if comp.school1 ~= schools.physical then
        return 0, nil;
    elseif loadout.shapeshift_no_weapon then
        return loadout.lvl * 5, nil
    end

    local skill = effects.raw.skill;

    local subclass = nil;
    if bit.band(eval_flags, evaluation_flags.isolate_oh) ~= 0 and
        bit.band(comp.flags, comp_flags.applies_oh) ~= 0 then
        subclass = loadout.oh_subclass;
    elseif bit.band(comp.flags, comp_flags.applies_ranged) ~= 0 then
        subclass = loadout.ranged_subclass;
    else
        subclass = loadout.mh_subclass;
    end

    local wpn_skill = loadout.wpn_skills[subclass];
    if wpn_skill then
        skill = skill + wpn_skill;
    else
        skill = skill +  loadout.lvl * 5;
    end
    return skill, subclass;
end

local function stats_crit(attack_skill, attack_subclass, bid, comp, loadout, effects)

    -- rating may come from diffed loadout
    local crit_rating_per_perc = get_combat_rating_effect(CR_CRIT_SPELL, loadout.lvl);
    local crit_from_rating = 0.01 * (loadout.crit_rating + effects.raw.crit_rating) / crit_rating_per_perc;

    local crit = math.max(0, crit_from_rating) + (effects.ability.crit[bid] or 0);

    if comp.school1 == schools.physical then
        if bit.band(comp.flags, comp_flags.applies_ranged) ~= 0 then
            crit = crit + loadout.ranged_crit;
        else
            crit = crit + loadout.melee_crit;
        end
        if attack_subclass then
            for mask, v in pairs(effects.wpn_subclass.phys_crit) do
                if bit.band(mask, bit.lshift(1, attack_subclass)) ~= 0 then
                    crit = crit + v;
                end
            end
        end
        crit = crit + effects.raw.phys_crit; -- TODO: flat modifier may be here for >+3 lvl mobs, see reference guide

        if bit.band(loadout.flags, loadout_flags.target_pvp) == 0 then
            local base_skill = math.min(attack_skill, loadout.lvl*5);
            local diff = base_skill - loadout.target_defense;
            if diff < 0 then
                -- this clamping allows crit to still be shown to avoid confusion
                crit = math.max(0.0000000001, crit + diff * 0.002);
            else
                crit = crit + diff * 0.0004;
            end
        else
            crit = crit + (attack_skill - loadout.target_defense) * 0.0004;
        end
    else
        crit = crit + loadout.spell_crit_by_school[comp.school1] + effects.by_school.crit[comp.school1];
        local i = 2;
        while (comp["school"..i]) do
            local s = comp["school"..i];
            crit = crit + loadout.spell_crit_by_school[s] + effects.by_school.crit[s]
                - (loadout.spell_crit_by_school[schools.physical] + effects.by_school.crit[schools.physical])
            i = i + 1;
        end
    end
    if bit.band(comp.flags, comp_flags.cant_crit) ~= 0 and
        (not effects.ability.ignore_cant_crit[bid] or
         effects.ability.ignore_cant_crit[bid] == 0) then
        crit = 0;
    end
    return math.min(math.max(crit, 0.0), 1.0);
end

local function stats_crit_mod(bid, comp, spell, loadout, effects)

    local base_crit_mod = 0.5;
    if comp.school1 == schools.physical then
        base_crit_mod = 1.0;
    end

    local crit_mod_extra = 0;
    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
        crit_mod_extra = effects.by_school.crit_mod[comp.school1];
        local i = 2;
        while (comp["school"..i]) do
            crit_mod_extra = crit_mod_extra + effects.by_school.crit_mod[comp["school"..i]] -
                effects.by_school.crit_mod[schools.physical];
            i = i + 1;
        end

        if loadout.target_creature_mask then
            for mask, v in pairs(effects.creature.crit_mod) do
                if bit.band(mask, loadout.target_creature_mask) ~= 0 then
                    crit_mod_extra = crit_mod_extra + v;
                end
            end
        end
    end

    base_crit_mod = (1.0 + base_crit_mod) * (1.0 + crit_mod_extra) - 1.0;
    return 1.0 + base_crit_mod * (1.0 + (effects.ability.crit_mod[bid] or 0.0));
end

local function stats_res(comp, spell, loadout, effects)

    local target_resi = 0;
    local target_avg_mitigated = 0;

    if comp.school1 ~= schools.physical and
        bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) then

        local base_resi = 0;
        if bit.band(loadout.flags, loadout_flags.target_pvp) == 0 then
            base_resi = npc_lvl_resi_base(loadout.lvl, loadout.target_lvl);
        end
        local res_pen_flat = effects.by_school.target_res_flat[comp.school1];
        local i = 2;
        while (comp["school"..i]) do
            res_pen_flat = math.max(res_pen_flat, effects.by_school.target_res_flat[comp["school"..i]]);
            i = i + 1;
        end
        local resi = (1.0 + effects.by_school.target_res[comp.school1]) * (config.loadout.target_res + res_pen_flat);
        -- mod res by school currently used to snapshot equipment and set bonuses

        if bit.band(spell.flags, spell_flags.binary) ~= 0 then
            target_resi = math.min(loadout.lvl * 5,
                math.max(0, resi));
            target_avg_mitigated = target_avg_magical_res_binary(loadout.lvl, target_resi);
        else
            target_resi = math.min(loadout.lvl * 5,
                math.max(base_resi, resi + base_resi));
            target_avg_mitigated = target_avg_magical_mitigation_non_binary(loadout.lvl, target_resi);
        end
        if bit.band(spell.flags, spell_flags.resi_pen) ~= 0 then
            -- some dots penetrate 9/10th of resi
            target_avg_mitigated = target_avg_mitigated * 0.1;
        end
    end
    return target_resi, target_avg_mitigated;
end

local function stats_hit(res_mitigation, attack_skill, attack_subclass, bid, comp, spell, loadout, effects)

    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
        return 1.0, 0, 0;
    end

    local hit_extra = effects.ability.hit[bid] or 0.0;

    local hit_rating_per_perc = get_combat_rating_effect(CR_HIT_SPELL, loadout.lvl);
    local hit_from_rating = 0.01 * (loadout.hit_rating + effects.raw.hit_rating) / hit_rating_per_perc
    hit_extra = hit_extra + hit_from_rating;

    if comp.school1 == schools.physical then
        hit_extra = hit_extra + loadout.phys_hit + effects.raw.phys_hit;
        if attack_subclass then
            for mask, v in pairs(effects.wpn_subclass.phys_hit) do
                if bit.band(mask, bit.lshift(1, attack_subclass)) ~= 0 then
                    hit_extra = hit_extra + v;
                end
            end
        end

        local miss;
        if loadout.target_defense - attack_skill >= 11 then
            miss = 0.05 + (loadout.target_defense - attack_skill) * 0.002;
        else
            miss = 0.05 + (loadout.target_defense - attack_skill) * 0.001;
        end
        if bit.band(loadout.flags, loadout_flags.target_pvp) ~= 0 then
            miss = 0.05 + (loadout.target_defense - attack_skill) * 0.04;
        elseif loadout.target_lvl < 10 then
            miss = miss * loadout.target_lvl * 0.1;
        end
        if loadout.m2_speed and bit.band(comp.flags, comp_flags.white) ~= 0 then
            miss = miss + 0.19;
        end
        local hit = math.min(math.max(1.0 - miss + hit_extra, 0.0), 0.99);

        if bit.band(comp.flags, comp_flags.always_hit) ~= 0 then
            hit = 1.0;
        end
        return hit, hit_extra, 0;
    else
        hit_extra = hit_extra +
            loadout.spell_dmg_hit_by_school[comp.school1] +
            effects.by_school.spell_hit[comp.school1];

        local i = 2;
        while (comp["school"..i]) do
            hit_extra = hit_extra + effects.by_school.spell_hit[comp["school"..i]] -
            effects.by_school.spell_hit[schools.physical];
            i = i + 1;
        end

        local hit, new_res_mitigation = spell_hit_calc(hit_extra, res_mitigation, loadout, spell);
        hit = math.min(math.max(hit, 0.0), 0.99);
        if bit.band(comp.flags, comp_flags.always_hit) ~= 0 then
            hit = 1.0;
        end
        if bit.band(comp.flags, comp_flags.ignores_mitigation) ~= 0 then
            new_res_mitigation = 0.0;
        end
        return hit, hit_extra, new_res_mitigation;
    end
end

local function stats_threat_mod(bid, comp, spell, effects)

    local threat_mod_flat = effects.ability.threat_flat[bid] or 0.0;
    local threat_mod = effects.ability.threat[bid] or 0.0;

    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
        threat_mod = threat_mod + effects.by_school.threat[comp.school1];
    end

    return threat_mod_flat, threat_mod;
end

local function stats_avoidances(attack_skill, comp, spell, loadout)
    if comp.school1 ~= schools.physical then
        return 0.0, 0.0, 0.0, 0.0, 0.0;
    end
    local block;
    local block_amount;

    local parry;
    if config.loadout.behind_target or bit.band(spell.flags, spell_flags.behind_target) ~= 0 then
        block = 0.0;
        block_amount = 0.0;
        parry = 0.0;
    else
        block = math.min(0.05, 0.05 + (loadout.target_defense - attack_skill)*0.001);
        block_amount = math.floor(loadout.target_lvl*0.5);

        parry = 0.05;
        local lvl_diff = loadout.target_lvl - loadout.lvl;
        if lvl_diff >= 3 then
            parry = 0.14;
        elseif lvl_diff >= 1 and lvl_diff <= 2 then
            parry = parry + lvl_diff*0.01;
        end
    end
    local dodge;
    if bit.band(loadout.flags, loadout_flags.target_pvp) ~= 0 then
        block = 0.0;
        block_amount = 0.0;
        dodge = (loadout.target_defense - attack_skill) * 0.0004;
    else
        dodge = 0.05 + (loadout.target_defense - attack_skill) * 0.001;
    end
    if bit.band(comp.flags, comp_flags.applies_ranged) ~= 0 then
        dodge = 0.0;
        parry = 0.0;
    end

    return math.max(0.0, dodge), math.max(0.0, parry), math.max(0.0, block), block_amount;
end

local function stats_sp(bid, comp, spell, loadout, effects)

    local sp;

    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
        sp = loadout.healing_power + effects.raw.healing_power_flat + effects.raw.spell_power;
    elseif comp.school1 == schools.physical then
        if bit.band(comp.flags, comp_flags.applies_ranged) ~= 0 then
            sp = loadout.rap + effects.raw.rap_flat;
        else
            sp = loadout.ap + effects.raw.ap_flat;
        end
    else
        local sp_school = loadout.spell_dmg_by_school[comp.school1] + effects.by_school.sp_dmg_flat[comp.school1];
        local i = 2;
        while (comp["school"..i]) do
            sp_school = sp_school +
                (loadout.spell_dmg_by_school[comp["school"..i]] - loadout.spell_dmg_by_school[schools.physical])
                +
                (effects.by_school.sp_dmg_flat[comp.school1] - effects.by_school.sp_dmg_flat[schools.physical]);
            i = i + 1;
        end
        sp = sp_school + effects.raw.spell_dmg + effects.raw.spell_power + (effects.ability.sp[bid] or 0);
    end

    return sp;
end

local function stats_coef(bid, comp, spell, loadout, effects, eval_flags)

    local coef;
    if comp.school1 == schools.physical then
        if loadout.m2_speed and
            bit.band(comp.flags, comp_flags.applies_oh) ~= 0 and
            bit.band(eval_flags, evaluation_flags.isolate_oh) ~= 0 then
            local speed;
            if bit.band(comp.flags, comp_flags.normalized_weapon) ~= 0 then
                speed = sc.wep_subclass_to_normalized_speed[loadout.oh_subclass or -1];
            else
                speed = loadout.m2_speed/effects.mul.raw.melee_haste;
            end
            coef = (0.5*(1.0 + effects.raw.offhand_mod))*dps_per_ap*speed;
        elseif bit.band(comp.flags, comp_flags.applies_mh) ~= 0 then
            local speed;
            if bit.band(comp.flags, comp_flags.normalized_weapon) ~= 0 then
                speed = sc.wep_subclass_to_normalized_speed[loadout.mh_subclass or -1];
            else
                speed = loadout.m1_speed/effects.mul.raw.melee_haste;
            end
            coef = dps_per_ap*speed;
        elseif bit.band(comp.flags, comp_flags.applies_ranged) ~= 0 then
            local speed;
            if bit.band(comp.flags, comp_flags.normalized_weapon) ~= 0 then
                speed = sc.wep_subclass_to_normalized_speed[loadout.ranged_subclass or 2];
            else
                speed = loadout.r_speed/effects.mul.raw.melee_haste;
            end
            coef = dps_per_ap*speed;
        elseif bit.band(spell.flags, spell_flags.finishing_move_dmg) ~= 0 then
            coef = (comp.coef_ap or 0) + (comp.per_cp_coef_ap or 0) * loadout.resources[powers.combopoints];
            if comp.coef_ap_by_cp then
                coef = coef + comp.coef_ap_by_cp[loadout.resources[powers.combopoints]];
            end
        else
            coef = comp.coef_ap or 0;
        end
    else
        coef = (comp.coef + (effects.ability.coef_mod_flat[bid] or 0.0))
            * (1.0 + (effects.ability.coef_mod[bid] or 0.0));
    end
    return coef;
end

local function stats_armor_dr(armor, comp, loadout)

    local dr = 0.0;
    if comp.school1 ~= schools.physical then
        return dr;

    elseif bit.band(comp.flags, comp_flags.ignores_mitigation) == 0 then
        dr = armor/(armor + 400 + 85 * (loadout.lvl + 4.5*(math.max(0, loadout.lvl-59))));
    end
    return dr;
end

local function stats_spell_mod(armor_dr, comp, spell, effects, stats)

    local effect_mod = stats.effect_mod;
    if bit.band(comp.flags, comp_flags.periodic) ~= 0 then
        --effect_mod = effect_mod + stats.effect_mod_ot;
        effect_mod = stats.effect_mod_ot;
    end
    local spell_mod;
    if bit.band(spell.flags, spell_flags.heal) ~= 0 then

        spell_mod =
            (stats.target_vuln_mod_mul * effects.mul.raw.vuln_heal)
            *
            effects.mul.raw.heal_mod
            *
            effect_mod;

    elseif bit.band(spell.flags, spell_flags.absorb) ~= 0 then

        spell_mod = stats.target_vuln_mod_mul * effect_mod;

    elseif comp.school1 == schools.physical then
        spell_mod =
            (1.0 - armor_dr)
            *
            (stats.target_vuln_mod_mul * effects.mul.raw.vuln_phys)
            *
            (stats.spell_dmg_mod_mul * effects.mul.raw.phys_mod)
            *
            effect_mod;
    else

        local mod_mul = stats.spell_dmg_mod_mul * effects.mul.by_school.dmg_mod[comp.school1];
        local vuln_mul = stats.target_vuln_mod_mul * effects.mul.by_school.vuln_mod[comp.school1];
        local i = 2;
        while (comp["school"..i]) do
            local s = comp["school"..i];
            mod_mul = mod_mul *
                (1.0 + effects.mul.by_school.dmg_mod[s] - effects.mul.by_school.dmg_mod[schools.physical]);

            vuln_mul = vuln_mul *
                (1.0 + effects.mul.by_school.vuln_mod[s] - effects.mul.by_school.vuln_mod[schools.physical])
            i = i + 1;
        end

        spell_mod =
            vuln_mul
            *
            mod_mul
            *
            effect_mod;
    end

    return spell_mod;
end

local function stats_glance(stats, comp, loadout)
    if bit.band(comp.flags, comp_flags.white) == 0 or
        bit.band(comp.flags, comp_flags.applies_ranged) ~= 0 then
        return 0.0, 0.0;
    end
    local glance_prob = 0.1 + (loadout.target_defense - math.min(loadout.lvl*5, stats.attack_skill)) * 0.02;
    local glance_red = 0.5 * (
        math.max(0.01, math.min(0.91, 1.3 - 0.05*(loadout.target_defense-stats.attack_skill)))
        +
        math.max(0.2, math.min(0.99, 1.3 - 0.03*(loadout.target_defense-stats.attack_skill)))
    );

    return glance_prob, glance_red;
end

-- Execution time of spell
local function stats_cast_time(stats, bid, comp, spell, loadout, effects)

    local cast_time;
    if bit.band(spell.flags, spell_flags.uses_attack_speed) ~= 0 then
        if loadout.m2_speed and
            bit.band(comp.flags, comp_flags.applies_oh) ~= 0 and
            bit.band(eval_flags, evaluation_flags.isolate_oh) ~= 0 then
            cast_time = loadout.m2_speed * effects.mul.raw.melee_haste_forced;
        elseif bit.band(comp.flags, comp_flags.applies_mh) ~= 0 then
            cast_time = loadout.m1_speed * effects.mul.raw.melee_haste_forced;
        elseif bit.band(comp.flags, comp_flags.applies_ranged) ~= 0 then
            cast_time = loadout.r_speed * effects.mul.raw.ranged_haste_forced;
        end
        return cast_time, cast_time;
    end

    if bit.band(spell.flags, spell_flags.instant) ~= 0 then
        cast_time = stats.gcd;
    elseif bit.band(spell.flags, spell_flags.channel) ~= 0 then
        cast_time = stats.dur_ot;
    else
        cast_time = spell.cast_time;
    end

    if comp.school1 == schools.physical then
        return cast_time, cast_time;
    end
    cast_time = cast_time + (effects.ability.cast_mod_flat[bid] or 0.0);

    local haste_rating_per_perc = get_combat_rating_effect(CR_HASTE_SPELL, loadout.lvl);
    local haste_from_rating = 0.01 * max(0.0, loadout.haste_rating + effects.raw.haste_rating) / haste_rating_per_perc;


    if bit.band(spell.flags, spell_flags.channel) == 0 then
        -- TODO: Needs to be changed for non vanilla
        local cast_mod =
            -effects.raw.cast_haste +
            -haste_from_rating +
            (effects.ability.cast_mod[bid] or 0.0);
        cast_time = cast_time * (1.0 + cast_mod);

        if config.settings.average_proc_effects then
            cast_time = cast_time * (1.0 - stats.becomes_instant_p);
        end
    end

    -- soul drain, life drain, mind flay are all casts that can only miss on the entire channel itself
    -- 1.5 sec gcd is always implied which is the only penalty for misses
    if bit.band(spell.flags, spell_flags.entire_channel_missable) ~= 0 then
        -- TODO: refactor needs fix
        local cast_time_avoided_by_miss = cast_time - stats.gcd;

        cast_time = cast_time - cast_time_avoided_by_miss * (1.0 - stats.hit_ot);
    end

    -- TODO: handle  stats.crit_reduces_cast_flat
    --       Nautres grace: Wrath special case with gcd, remove gcd change from buff

    local cast_time_nogcd = cast_time;
    cast_time = math.max(cast_time, stats.gcd);

    return cast_time, cast_time_nogcd;

end
-- Execution time of spell
local function stats_avg_cost(cost, stats, bid, spell, loadout, effects)

    if config.settings.average_proc_effects then
        cost = cost * (1.0 - stats.clearcast_p);
    end

    if bit.band(spell.flags, spell_flags.uses_all_power) ~= 0 then
        cost = loadout.resources[spell.power_type];
    end
    -- Assemble refunds
    local resource_refund =
        stats.resource_refund
        +
        stats.resource_refund_mul_crit * stats.crit * stats.hit
        +
        stats.resource_refund_mul_hit * stats.hit
        +
        stats.resource_refund_mul_cost_hit * cost * stats.hit;

    if effects.ability.refund[bid] and effects.ability.refund[bid] ~= 0 then
        local refund = effects.ability.refund[bid];
        local max_rank = spells[sc.rank_seqs[spell.base_id][#sc.rank_seqs[spell.base_id]]].rank;
        -- TODO: find max rank
        -- NOTE: unclear how this works, best guess it to interopolate between first and last rank
        local coef_estimate = 1.0;
        if spell.rank > 0 then
            coef_estimate = spell.rank / max_rank;
        end

        resource_refund = resource_refund + refund * coef_estimate;
    end
    if bit.band(spell.flags, spell_flags.refund_on_miss) ~= 0 then
        resource_refund = resource_refund + cost*(1.0 - stats.hit);
    end

    cost = cost - resource_refund;
    cost = math.max(cost, 0);

    return cost, cost_actual;
end


local function spell_stats_direct(stats, spell, loadout, effects, eval_flags)

    local bid = spell.base_id;

    local benefit_id = spell.beneficiary_id or bid;

    local direct = spell.direct;

    stats.attack_skill, stats.attack_subclass = stats_attack_skill(direct, loadout, effects, eval_flags);

    stats.crit = stats_crit(stats.attack_skill,
                            stats.attack_subclass,
                            benefit_id,
                            direct,
                            loadout,
                            effects);

    stats.crit_mod = stats_crit_mod(benefit_id, direct, spell, loadout, effects);

    -- WANDS
    -- TODO: needs changing
    --if spell.base_id == spids.shoot then
    --    local wand_perc_active = 1.0 + stats.effect_mod;
    --    local wand_perc_spec = 1.0;

    --    if class == "PRIEST" then
    --        wand_perc_spec = wand_perc_spec + loadout.talents_table[102] * 0.05;
    --    elseif class == "MAGE" then
    --        wand_perc_spec = wand_perc_spec + loadout.talents_table[104] * 0.125;
    --    end

    --    stats.gcd = 0.5;
    --    if loadout.r_speed ~= 0 then
    --        spell.cast_time = loadout.r_speed;
    --        spell.direct.min = (loadout.r_min / (loadout.r_mod * wand_perc_active) - loadout.r_pos) * wand_perc_spec;
    --        spell.direct.max = (loadout.r_max / (loadout.r_mod * wand_perc_active) - loadout.r_pos) * wand_perc_spec;
    --    else
    --        spell.cast_time = 0;
    --        spell.direct.min = 0;
    --        spell.direct.max = 0;
    --    end
    --    --stats.spell_dmg_mod = stats.spell_dmg_mod - stats.effect_mod;
    --end

    stats.target_resi, stats.target_avg_resi = stats_res(direct, spell, loadout, effects);
    stats.hit, stats.extra_hit, stats.target_avg_resi = stats_hit(stats.target_avg_resi,
                                                                  stats.attack_skill,
                                                                  stats.attack_subclass,
                                                                  bid,
                                                                  direct,
                                                                  spell,
                                                                  loadout,
                                                                  effects);

    stats.threat_mod_flat, stats.threat_mod = stats_threat_mod(benefit_id, direct, spell, effects);
    stats.glance = stats_glance(stats, direct, loadout);
    stats.dodge, stats.parry, stats.block, stats.block_amount = stats_avoidances(stats.attack_skill, direct, spell, loadout);
    stats.spell_power = stats_sp(benefit_id, direct, spell, loadout, effects);
    stats.coef = stats_coef(benefit_id, direct, spell, loadout, effects, eval_flags);
    stats.armor_dr = stats_armor_dr(stats.armor, direct, loadout);
    stats.spell_mod = stats_spell_mod(stats.armor_dr, direct, spell, effects, stats);
    stats.direct_jumps = (direct.jumps or 0) + (effects.ability.jumps_flat[bid] or 0);
    stats.direct_jump_amp = 1.0 - (direct.jump_red or 0.0) + (effects.ability.jump_amp[bid] or 0.0);

end

local function spell_stats_periodic(stats, spell, loadout, effects, eval_flags)

    local bid = spell.base_id;
    local benefit_id = spell.beneficiary_id or bid;
    local periodic = spell.periodic;

    stats.attack_skill_ot, stats.attack_subclass_ot = stats_attack_skill(periodic, loadout, effects, eval_flags);

    stats.crit_ot = stats_crit(stats.attack_skill_ot,
                               stats.attack_subclass_ot,
                               benefit_id,
                               periodic,
                               loadout,
                               effects);

    stats.crit_mod_ot = stats_crit_mod(benefit_id, periodic, spell, loadout, effects);

    stats.target_resi_ot, stats.target_avg_resi_ot = stats_res(periodic, spell, loadout, effects);

    stats.hit_ot, stats.extra_hit_ot, stats.target_avg_resi_ot = stats_hit(stats.target_avg_resi_ot,
                                                                            stats.attack_skill_ot,
                                                                            stats.attack_subclass_ot,
                                                                            bid,
                                                                            periodic,
                                                                            spell,
                                                                            loadout,
                                                                            effects);

    stats.threat_mod_flat_ot, stats.threat_mod_ot = stats_threat_mod(benefit_id, periodic, spell, effects);

    stats.dodge_ot, stats.parry_ot, stats.block_ot, stats.block_amount_ot = stats_avoidances(stats.attack_skill_ot, periodic, spell, loadout);
    stats.spell_power_ot = stats_sp(benefit_id, periodic, spell, loadout, effects);
    stats.coef_ot = stats_coef(benefit_id, periodic, spell, loadout, effects, eval_flags);
    stats.armor_dr_ot = stats_armor_dr(stats.armor, periodic, loadout);
    stats.spell_mod_ot = stats_spell_mod(stats.armor_dr_ot, periodic, spell, effects, stats);
    stats.periodic_jumps = (periodic.jumps or 0) + (effects.ability.jumps_flat[bid] or 0);
    stats.periodic_jump_amp = 1.0 - (periodic.jump_red or 0.0) + (effects.ability.jump_amp[bid] or 0.0);

    -- prematurely calculate final ot duration here so that channels can set cast_time to this
    -- before moving onto spell info calculation
    stats.dur_ot =
        (periodic.dur + (effects.ability.extra_dur_flat[bid] or 0.0))
        *
        (1.0 + (effects.ability.extra_dur[bid] or 0.0));
    stats.tick_time_ot =
        periodic.tick_time + (effects.ability.extra_tick_time_flat[bid] or 0.0);
end


local stats_needing_both_components = {
    "crit_mod",
    "crit",
    "hit",
    "target_avg_resi",
    "threat_mod",
    "threat_mod_flat",
    "armor_dr",
};

local class_stats_spell = (function()
    if class == classes.warrior then
        return function(anycomp, bid, stats, spell, loadout, effects)
            if bid == spids.execute then
                stats.effect_mod_flat = stats.effect_mod_flat +
                    spell.direct.per_resource*math.max(loadout.resources[powers.rage] - stats.cost_actual, 0);
            elseif bid == spids.shield_slam then
                stats.effect_mod_flat = stats.effect_mod_flat
                    +
                    spell.direct.per_resource *
                        (loadout.stats[attr.strength] +
                            effects.by_attr.stats[attr.strength]
                            *
                            (1.0 + effects.by_attr.stat_mod[attr.strength])
                        )
                    + loadout.block_value;
            end
        end
    elseif class == classes.paladin then
        return function(anycomp, bid, stats, spell, loadout, effects)
            if bit.band(spell.flags, spell_flags.heal) ~= 0 then
                -- illumination
                local pts = loadout.talents_table[109];
                if pts ~= 0 then
                    stats.resource_refund_mul_crit = stats.resource_refund_mul_crit + pts * 0.2 * stats.original_base_cost;
                end

                --if loadout.runes[rune_ids.fanaticism] and spell.direct then
                --    add_extra_periodic_effect(stats,
                --                              bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod),
                --                              0.6, 4, 3, 1.0, "Fanaticism");
                --end
                if bid == spids.flash_of_light and is_buff_up(loadout, loadout.friendly_towards, lookups.sacred_shield, false) then
                    add_extra_periodic_effect(stats, 0, 1.0, 12, 1, 1.0, "Extra");
                end
                if bid == spids.holy_light and spell.rank < 4 then
                    -- Subtract healing to account for blessing of light coef for low rank holy light
                    local bol_hl_val = nil;
                    for _, id in pairs(lookups.bol_ids) do
                        local bol = is_buff_up(loadout, loadout.friendly_towards, id, false);
                        if bol then
                            -- manually configured to be at index 1
                            bol_hl_val = sc.friendly_buffs[id][1][sc.aura_idx_value];
                            break;
                        end
                    end

                    if bol_hl_val then
                        stats.effect_mod_flat = stats.effect_mod_flat
                            - bol_hl_val * lookups.bol_rank_to_hl_coef_subtract[spell.rank];
                    end
                end
            else
                -- Put a spell flag for this
                --if loadout.runes[rune_ids.wrath] then
                --    stats.crit = stats.crit + loadout.melee_crit;
                --    stats.crit_ot = stats.crit_ot + loadout.melee_crit;
                --    stats.ignore_cant_crit = true;
                --end
                --if loadout.runes[rune_ids.infusion_of_light] and bid == spids.holy_shock then
                --    stats.resource_refund_mul_crit = stats.resource_refund_mul_crit + stats.crit * stats.original_base_cost;
                --end
            end
            -- Add special passive that gives exorcist 0 crit, this then improves its aura pts
            --if bid == spids.exorcism and loadout.runes[rune_ids.exorcist] then
            --    stats.crit = 1.0;
            --end
        end
    elseif class == classes.hunter then
        return function(anycomp, bid, stats, spell, loadout, effects)
        end
    elseif class == classes.rogue then
        return function(stats, spell, loadout, effects)
        end
    elseif class == classes.priest then
        return function(anycomp, bid, stats, spell, loadout, effects)
            if bit.band(spell_flags.heal, spell.flags) ~= 0 then
                --if loadout.runes[rune_ids.divine_aegis] then

                --    if spell.direct or bid == spids.penance then
                --        local aegis_flags = bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod);
                --        if bid == spids.penance then
                --            aegis_flags = bit.bor(aegis_flags, extra_effect_flags.base_on_periodic_effect);
                --        end
                --        add_extra_direct_effect(stats, aegis_flags, 0.3, 1.0, "Divine Aegis");
                --    end
                --end
                if bid == spids.greater_heal and loadout.num_set_pieces[set_tiers.pve_3] >= 4 then
                    add_extra_direct_effect(stats,
                                            bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.use_flat),
                                            500, 1.0, "Absorb");
                end
                if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 6 then
                    if bid == spids.circle_of_healing then
                        add_extra_periodic_effect(stats, 0, 0.25, 5, 3, 1.0, "6P Set Bonus");
                    elseif bid == spids.penance then
                        add_extra_periodic_effect(stats, extra_effect_flags.base_on_periodic_effect, 0.25, 5, 3, 1.0, "6P Set Bonus");
                    end
                end
            end
        end
    elseif class == classes.shaman then
        return function(anycomp, bid, stats, spell, loadout, effects)
            -- shaman clearcast

            if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                -- clearcast
                local pts = loadout.talents_table[106];
                if pts ~= 0 then
                    stats.clearcast_p = stats.clearcast_p + 0.1;
                end
            end

            if bid == spids.healing_wave or
                bid == spids.lesser_healing_wave or
                bid == spids.riptide then
                if loadout.num_set_pieces[set_tiers.pve_1] >= 5 or loadout.num_set_pieces[set_tiers.sod_final_pve_1_heal] >= 4 then
                    stats.resource_refund = stats.resource_refund + 0.25 * 0.35 * stats.original_base_cost;
                end
                --if loadout.runes[rune_ids.ancestral_awakening] then
                --    add_extra_direct_effect(stats,
                --                            bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod),
                --                            0.3, 1.0, "Awakening");
                --end
            end
            --if loadout.runes[rune_ids.overload] and (bid == spids.chain_heal or
            --        bid == spids.chain_lightning or
            --        bid == spids.healing_wave or
            --        bid == spids.lightning_bolt or
            --        bid == spids.lava_burst) then
            --    add_extra_direct_effect(stats, 0, 0.5, 0.6, "Overload 60% chance");
            --end

            -- TODO: broken after refactor
            --if bit.band(spell.flags, spell_flags.weapon_enchant) ~= 0 then
            --    local mh_speed, oh_speed = UnitAttackSpeed("player");
            --    local wep_speed = mh_speed;
            --    if bit.band(eval_flags, sc.calc.evaluation_flags.isolate_oh) ~= 0 then
            --        if oh_speed then
            --            wep_speed = oh_speed;
            --        end
            --    end
            --    -- api may incorrectly return 0, clamp to something
            --    wep_speed = math.max(wep_speed, 0.1);
            --    spell.periodic.tick_time = wep_speed;
            --    -- scaling should change with weapon base speed not current attack speed
            --    -- but there is no easy way to get it
            --    if bid == spids.flametongue_weapon then
            --        stats.base_mod = stats.base_mod * 0.25 * (math.max(1.0, math.min(4.0, wep_speed))) - 1.0;
            --    elseif bid == spids.frostbrand_weapon then
            --        local min_proc_chance = 0.15;
            --        --stats.hit = stats.hit * (min_proc_chance * math.max(1.0, math.min(4.0, wep_speed)));
            --    end
            --end
            if bid == spids.earth_shield and loadout.friendly_towards == "player" then
                -- strange behaviour hacked in
                stats.effect_mod = stats.effect_mod + 0.02 * loadout.talents_table[314];
            end
            if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 2 and spell.direct and is_buff_up(loadout, "player", lookups.water_shield, true) then

                --stats.resource_refund = stats.resource_refund + stats.crit * 0.04 * loadout.resources_max[powers.mana];
                stats.resource_refund_mul_crit = stats.resource_refund_mul_crit + 0.04 * loadout.resources_max[powers.mana];
            end
        end
    elseif class == classes.mage then
        return function(anycomp, bid, stats, spell, loadout, effects)
            if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                -- clearcast
                local pts = loadout.talents_table[106];
                if pts ~= 0 then
                    cost_mod = cost_mod * (1.0 - 0.02 * pts);
                end

                local pts = loadout.talents_table[212];
                if pts ~= 0 and spell.direct and 
                    (spell.direct.school1 == schools.fire or spell.direct.school1 == schools.frost) then
                    -- master of elements
                    local mana_refund = pts * 0.1 * stats.original_base_cost;
                    stats.resource_refund_mul_crit = stats.resource_refund_mul_crit + mana_refund;
                end

                --if loadout.runes[rune_ids.burnout] and spell.direct then
                --    stats.resource_refund_mul_crit = stats.resource_refund_mul_crit + 0.01 * base_mana;
                --end

                -- ignite
                local pts = loadout.talents_table[203];
                if pts ~= 0 and spell.direct and spell.direct.school1 == schools.fire then
                    -- % ignite double dips in % multipliers
                    local double_dip = stats.spell_dmg_mod_mul *
                    effects.mul.by_school.dmg_mod[schools.fire] *
                    effects.mul.by_school.vuln_mod[schools.fire];

                    add_extra_periodic_effect(stats,
                                              bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod),
                                              (pts * 0.08) * double_dip, 2, 2, 1.0, "Ignite");
                end
                if loadout.num_set_pieces[set_tiers.pve_2] >= 8 and
                    (bid == spids.frostbolt or bid == spids.fireball) then
                    stats.cast_time = 0.9 * stats.cast_time + 0.1 * stats.gcd;
                end

                if bit.band(loadout.flags, loadout_flags.target_frozen) ~= 0 then
                    local pts = loadout.talents_table[313];

                    stats.crit = math.max(0.0, math.min(1.0, stats.crit + pts * 0.1));

                    if bid == spids.ice_lance then
                        stats.target_vuln_mod_mul = stats.target_vuln_mod_mul * 3;
                    end
                end
                --if loadout.runes[rune_ids.overheat] and
                --    bid == spids.fire_blast then
                --    stats.gcd = 0.0;
                --    stats.cast_time = 0.0;
                --end

                if loadout.num_set_pieces[set_tiers.sod_final_pve_2] >= 6 and bid == spids.fireball then
                    add_extra_periodic_effect(stats, 0, 1.0, 4, 2, 1.0, "6P Set Bonus");
                end

                if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 2 and bid == spids.arcane_missiles then
                    stats.resource_refund = stats.resource_refund + 0.5 * stats.original_base_cost;
                end
            end
        end
    elseif class == classes.warlock then
        return function(anycomp, bid, stats, spell, loadout, effects)
            --if loadout.runes[rune_ids.dance_of_the_wicked] and spell.direct then
            --    stats.resource_refund_mul_crit = stats.resource_refund_mul_crit + 0.02 * loadout.resources_max[powers.mana];
            --end

            --if loadout.runes[sc.talents.rune_ids.soul_siphon] then
            --    if bid == spids.drain_soul then
            --        if loadout.enemy_hp_perc and loadout.enemy_hp_perc <= 0.2 then
            --            stats.target_vuln_mod_ot_mul = stats.target_vuln_mod_ot_mul *
            --            math.min(1.5, 1.0 + 0.5 * effects.raw.target_num_shadow_afflictions);
            --        else
            --            stats.target_vuln_mod_ot_mul = stats.target_vuln_mod_ot_mul *
            --            math.min(1.18, 1.0 + 0.06 * effects.raw.target_num_shadow_afflictions);
            --        end
            --    elseif bid == spids.drain_life then
            --        stats.target_vuln_mod_ot_mul = stats.target_vuln_mod_ot_mul *
            --        math.min(1.18, 1.0 + 0.06 * effects.raw.target_num_shadow_afflictions);
            --    end
            --end
            if bid == spids.shadow_bolt then
                --if loadout.num_set_pieces[set_tiers.sod_final_pve_2] >= 6 then
                --    stats.target_vuln_mod_mul = stats.target_vuln_mod_mul * math.min(1.3, 1.1 + 0.1 * effects.raw.target_num_afflictions);
                --end
                -- Averages out ISB effect uptime based on crit
                if config.settings.average_proc_effects then
                    --local isb_buff_val = nil;
                    --for k, _ in pairs(lookups.isb_ids) do
                    --    local isb = is_buff_up(loadout, loadout.hostile_towards, k, false);
                    --    if isb then
                    --        isb_buff_val = sc.hostile_buffs[id][1][sc.aura_idx_value];
                    --        break;
                    --    end
                    --end

                    --local isb_pts = loadout.talents_table[301];
                    --local isb_uptime = 1.0 - math.pow(1.0 - stats.crit, 4);

                    --if isb_buff_val and isb_pts ~= 0 then

                    --    stats.spell_dmg_mod_mul = stats.spell_dmg_mod_mul / (1.0 + isb_buff_val);

                    --    stats.hit_inflation = stats.hit_inflation + (1.0 + isb_buff_val)/(1.0 + isb_pts*0.04*isb_uptime) - 1;
                    --else
                    --    stats.hit_inflation = stats.hit_inflation / (1.0 + isb_pts*0.04*isb_uptime);
                    --end
                    --stats.spell_dmg_mod_mul = stats.spell_dmg_mod_mul * (1.0 + isb_pts*0.04*isb_uptime);
                end
            end
        end
    elseif class == classes.druid then
        return function(anycomp, bid, stats, spell, loadout, effects)
            -- clearcast
            local pts = loadout.talents_table[109];
            if pts ~= 0 then
                if anycomp.school1 == schools.physical then
                    stats.clearcast_p = stats.clearcast_p + 0.1*pts;

                elseif bit.band(sc.game_mode, sc.game_modes.season_of_discovery) ~= 0 and
                       bit.band(spell_flags.instant, spell.flags) == 0 then

                    stats.clearcast_p = stats.clearcast_p + 0.1*pts;
                end
            end

            if (bid == spids.healing_touch or spell.base_id == spids.nourish) then
                if loadout.num_set_pieces[set_tiers.pve_3] >= 8 then
                    stats.resource_refund_mul_crit = stats.resource_refund_mul_crit + 0.3 * stats.original_base_cost;
                end
                if loadout.num_set_pieces[set_tiers.sod_final_pve_1_heal] >= 4 then
                    stats.resource_refund = stats.resource_refund + 0.25 * 0.35 * stats.original_base_cost;
                end
            end
            if bid == spids.lifebloom then
                stats.resource_refund_mul_cost_hit = stats.resource_refund_mul_cost_hit + 0.5;
            end

            --if loadout.runes[rune_ids.living_seed] then
            --    if (bit.band(spell_flags.heal, spell.flags) ~= 0 and spell.direct) or
            --        bid == spids.swiftmend then

            --        add_extra_direct_effect(stats,
            --                                bit.bor(extra_effect_flags.triggers_on_crit, extra_effect_flags.should_track_crit_mod),
            --                                0.5, 1.0, "Living Seed");
            --    end
            --end

            -- nature's grace
            local pts = loadout.talents_table[113];
            --if pts ~= 0 and spell.cast_time ~= spell.periodic.dur and bit.band(spell_flags.instant, spell.flags) == 0 and cast_reduction < 1.0 then
            -- channel check?
            if pts ~= 0 and spell.direct and bit.band(spell_flags.instant, spell.flags) == 0 then
                --stats.crit_reduces_cast_flat = 

                --local crit_cast_reduction = 0.5 * stats.crit;

                --stats.cast_time = spell.cast_time - crit_cast_reduction;
                --stats.cast_time = stats.cast_time * (1.0 - stats.cast_mod);

                stats.crit_reduces_cast_flat = stats.crit_reduces_cast_flat + 0.5*pts/3;
            end
            if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 4 and bit.band(spell_flags.heal, spell.flags) ~= 0 then
                --crit_cast_reduction = math.min(0.5, crit_cast_reduction * 2);
                stats.crit_reduces_cast_flat = stats.crit_reduces_cast_flat + 0.5*pts/3;
            end
        end
    end
end)();

local function stats_for_spell(stats, spell, loadout, effects, eval_flags)

    eval_flags = eval_flags or 0;

    stats.original_base_cost = spell.cost;
    local anycomp = spell.direct or spell.periodic;

    local bid = spell.base_id;
    -- benefit id may be different than base id in rare cases
    -- such as where hybrid spells' (holy shock) effect benefits 
    -- only on healing part which is not on base id
    local benefit_id = spell.beneficiary_id or bid;

    stats.special_crit_mod_tracked = 0;
    stats.num_extra_effects = 0;
    stats.num_periodic_effects = 0;
    stats.hit_inflation = 1.0; -- inflate hit value visually while not contributing to expectation

    stats.target_vuln_mod_mul = effects.mul.ability.vuln_mod[bid] or 1.0;
    if loadout.target_creature_mask ~= 0 then
        for mask, v in pairs(effects.mul.creature.dmg_mod) do
            if bit.band(mask, loadout.target_creature_mask) ~= 0 then
                stats.target_vuln_mod_mul = stats.target_vuln_mod_mul * v;
            end
        end
    end

    stats.spell_dmg_mod_mul = 1.0;
    stats.effect_mod = 1.0 + (effects.ability.effect_mod[benefit_id] or 0.0);
    stats.effect_mod_ot = 1.0 + (effects.ability.effect_mod_ot[benefit_id] or 0.0);
    stats.effect_mod_flat = effects.ability.effect_mod_flat[benefit_id] or 0.0;
    stats.effect_mod_ot_flat = effects.ability.effect_mod_ot_flat[benefit_id] or 0.0;
    stats.base_mod = 1.0 + (effects.ability.base_mod[benefit_id] or 0.0);
    stats.base_mod_ot = 1.0 + (effects.ability.base_mod_ot[benefit_id] or 0.0);
    stats.base_mod_flat = effects.ability.base_mod_flat[benefit_id] or 0.0;
    stats.base_mod_ot_flat = effects.ability.base_mod_ot_flat[benefit_id] or 0.0;

    stats.gcd = math.min(spell.gcd, 1.5);

    local base_mana = 0;
    if sc.base_mana_by_lvl then
        base_mana = sc.base_mana_by_lvl[loadout.lvl];
    end

    if bit.band(spell.flags, spell_flags.base_mana_cost) ~= 0 then
        stats.original_base_cost = stats.original_base_cost * base_mana;
    end

    stats.cost_actual =
        math.floor(stats.original_base_cost +
                  (effects.ability.cost_mod_flat[bid] or 0.0))
        *
        (1.0 + (effects.ability.cost_mod[bid] or 0.0));

    stats.cost_actual = math.floor(stats.cost_actual + 0.5);

    -- generalized spell handling that may be applied
    stats.clearcast_p = 0.0;
    stats.becomes_instant_p = 0.0; -- spell is instant with probability
    stats.crit_reduces_cast_flat = 0.0; -- nature's grace like effect
    stats.resource_refund = 0.0;
    stats.resource_refund_mul_crit = 0.0; -- resource refunded to be multiplied by crit
    stats.resource_refund_mul_hit = 0.0; -- resource refunded to be multiplied by hit
    -- resource refunded to be multiplied by pontentially modified spell cost and by hit
    stats.resource_refund_mul_cost_hit = 0.0;

    stats.armor = math.max(0, (loadout.armor + effects.by_school.target_res_flat[schools.physical]) * (1.0 + effects.by_school.target_res[schools.physical]));


    class_stats_spell(anycomp, bid, stats, spell, loadout, effects);
    client_class_stats_spell(anycomp, bid, stats, spell, loadout, effects);

    if spell.direct then
        spell_stats_direct(stats, spell, loadout, effects, eval_flags);
    end
    if spell.periodic then
        spell_stats_periodic(stats, spell, loadout, effects, eval_flags);
    end
    if bit.band(anycomp.flags, comp_flags.heal_to_full) ~= 0 then
        anycomp.spell_mod = 1.0;
        anycomp.spell_mod_ot = 1.0;
        stats.effect_mod = 1.0;
        stats.effect_mod_ot = 1.0;
        stats.effect_mod_flat = 0.0;
        stats.effect_mod_ot_flat = 0.0;
        stats.base_mod = 1.0;
        stats.base_mod_ot = 1.0;
        stats.crit = 0.0;

        local amount = (1.0 - loadout.friendly_hp_perc) * loadout.friendly_hp_max;
        stats.base_mod_flat = amount;
        stats.base_mod_ot_flat = amount;
    end


    -- Temporary workaround:
    -- Direct or OT counterpart my need to be defined for tooltips
    -- when secondary components are dynamically added like ignite
    for _, v in pairs(stats_needing_both_components) do
        stats[v] = stats[v] or stats[v.."_ot"];
        stats[v.."_ot"] = stats[v.."_ot"] or stats[v];
    end

    stats.cast_time, stats.cast_time_nogcd = stats_cast_time(stats, bid, anycomp, spell, loadout, effects);

    stats.cost = stats_avg_cost(stats.cost_actual, stats, bid, spell, loadout, effects);

    stats.cost_per_sec = stats.cost / stats.cast_time;
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
        info.total_ot_min_noncrit_if_hit = info.total_ot_min_noncrit_if_hit + p * info["ot_min_noncrit_if_hit" .. i];
        info.total_ot_max_noncrit_if_hit = info.total_ot_max_noncrit_if_hit + p * info["ot_max_noncrit_if_hit" .. i];
        if info["ot_crit" .. i] ~= 0 then
            info.total_ot_min_crit_if_hit    = info.total_ot_min_crit_if_hit    + p * info["ot_min_crit_if_hit" .. i];
            info.total_ot_max_crit_if_hit    = info.total_ot_max_crit_if_hit    + p * info["ot_max_crit_if_hit" .. i];
        end
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
        if info["crit" .. i] ~= 0 then
            info.total_min_crit_if_hit    = info.total_min_crit_if_hit + p * info["min_crit_if_hit" .. i];
            info.total_max_crit_if_hit    = info.total_max_crit_if_hit + p * info["max_crit_if_hit" .. i];
        end
    end
end

local function add_expectation_direct_st(info, num_to_add)
    local added = info.expected_direct_st * num_to_add;
    info.expected_direct = info.expected_direct + added;
    info.expected = info.expected + added;

    local threat_added = info.threat_direct_st * num_to_add;
    info.threat_direct = info.threat_direct + threat_added;
    info.threat = info.threat + threat_added;
end

local function add_expectation_ot_st(info, num_to_add)
    local added = info.expected_ot_st * num_to_add;
    info.expected_ot = info.expected_ot + added;
    info.expected = info.expected + added;

    local threat_added = info.threat_ot_st * num_to_add;
    info.threat_ot = info.threat_ot + threat_added;
    info.threat = info.threat + threat_added;
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
        info.expected_direct_st = stats.hit * expected_direct_if_hit * (1 - stats.target_avg_resi);
        info.expected_direct = info.expected_direct_st;

        local flat_threat = stats.threat_mod_flat;
        local threat_mod_of_expected = 1.0;
        if spell.direct then
            flat_threat = flat_threat + (spell.direct.threat_mod_flat or 0.0);
            threat_mod_of_expected = threat_mod_of_expected + (spell.direct.threat_mod or 0.0);
        end
        info.threat_direct_st = (1.0 + stats.threat_mod) *
            ((info.expected_direct_st * threat_mod_of_expected) + (stats.hit * (flat_threat)));
        info.threat_direct = info.threat_direct_st;

        if spell.direct and bit.band(spell.direct.flags, comp_flags.unbounded_aoe) ~= 0 then
            info.expected_direct = info.expected_direct_st * num_unbounded_targets;

            info.threat_direct = info.threat_direct_st * num_unbounded_targets;
        end
    else
        info.expected_direct_st = 0;
        info.expected_direct = 0;

        info.threat_direct_st = 0;
        info.threat_direct = 0;
    end

    -- over time
    local expected_ot_if_hit = 0;
    for i = 1, info.num_periodic_effects do
        expected_ot_if_hit = expected_ot_if_hit + info["ot_utilization" .. i] *
            ((1.0 - info["ot_crit" .. i]) * 0.5 * (info["ot_min_noncrit_if_hit" .. i] + info["ot_max_noncrit_if_hit" .. i]) +
                info["ot_crit" .. i] * 0.5 * (info["ot_min_crit_if_hit" .. i] + info["ot_max_crit_if_hit" .. i]));
    end

    if info.num_periodic_effects > 0 then
        info.expected_ot_st = stats.hit_ot * expected_ot_if_hit * (1 - stats.target_avg_resi_ot);
        info.expected_ot = info.expected_ot_st;

        local flat_threat = stats.threat_mod_flat_ot;
        local threat_mod_of_expected = 1.0;
        if spell.periodic then
            flat_threat = (flat_threat + (spell.periodic.threat_mod_flat or 0.0)) * info.ot_ticks1;
            threat_mod_of_expected = threat_mod_of_expected + (spell.periodic.threat_mod or 0.0);
        end

        info.threat_ot_st = (1.0 + stats.threat_mod_ot) *
            ((info.expected_ot_st * threat_mod_of_expected) + (stats.hit_ot * flat_threat));
        info.threat_ot = info.threat_ot_st;

        if spell.periodic and bit.band(spell.periodic.flags, comp_flags.unbounded_aoe) ~= 0 then
            info.expected_ot = info.expected_ot_st * num_unbounded_targets;
            info.threat_ot = info.threat_ot_st * num_unbounded_targets;
        end
    else
        info.expected_ot_st = 0;
        info.expected_ot = 0;

        info.threat_ot_st = 0;
        info.threat_ot = 0;
    end

    -- combine
    info.expected_st = info.expected_direct_st + info.expected_ot_st
    info.expected = info.expected_direct + info.expected_ot

    info.threat_st = info.threat_direct_st + info.threat_ot_st
    info.threat = info.threat_direct + info.threat_ot

    if loadout.beacon and bit.band(spell.flags, spell_flags.heal) ~= 0 then
        add_expectation_direct_st(info, 0.75);
    end
end

local function direct_info(info, spell, loadout, stats, effects, eval_flags)
    local direct = spell.direct;
    local clvl = loadout.lvl;

    local base_min = direct.min;
    local base_max = direct.max;

    if direct.per_lvl_sq == 0 then
        local lvl_diff_applicable = math.max(0,
            math.min(clvl - spell.lvl_req, spell.lvl_max - spell.lvl_req));
        base_min = base_min + direct.per_lvl * lvl_diff_applicable;
        base_max = base_max + direct.per_lvl * lvl_diff_applicable;
    else
        local added_effect = direct.per_lvl * clvl + direct.per_lvl_sq * clvl * clvl;
        base_min = direct.min * (direct.base_min + added_effect);
        base_max = direct.max * (direct.base_max + added_effect);
    end

    -- TODO: For weapons, need to figure out where m_pos and m_neg comes from
    --       and whether it is detectable through auras
    if loadout.m2_speed and
        bit.band(direct.flags, comp_flags.applies_oh) ~= 0 and
        bit.band(eval_flags, evaluation_flags.isolate_oh) ~= 0 then
        local ap_reduce = loadout.ap*stats.coef;
        local m2_min_base = (loadout.m2_min/loadout.m_mod) - ap_reduce;--loadout.m_pos + loadout.m_neg;
        local m2_max_base = (loadout.m2_max/loadout.m_mod) - ap_reduce;--loadout.m_pos + loadout.m_neg;
        base_min = (direct.base_min + m2_min_base) * base_min;
        base_max = (direct.base_max + m2_max_base) * base_max;
    elseif bit.band(direct.flags, comp_flags.applies_mh) ~= 0 then
        local ap_reduce = loadout.ap*stats.coef;
        local m1_min_base = (loadout.m1_min/loadout.m_mod) - ap_reduce;--loadout.m_pos + loadout.m_neg;
        local m1_max_base = (loadout.m1_max/loadout.m_mod) - ap_reduce;--loadout.m_pos + loadout.m_neg;
        base_min = (direct.base_min + m1_min_base) * base_min;
        base_max = (direct.base_max + m1_max_base) * base_max;
    elseif bit.band(direct.flags, comp_flags.applies_ranged) ~= 0 then
        local ap_reduce = loadout.rap*stats.coef;
        local r_min_base = (loadout.r_min/loadout.r_mod) - ap_reduce;-- loadout.r_pos + loadout.r_neg;
        local r_max_base = (loadout.r_max/loadout.r_mod) - ap_reduce;-- loadout.r_pos + loadout.r_neg;
        base_min = (direct.base_min + r_min_base) * base_min;
        base_max = (direct.base_max + r_max_base) * base_max;

    elseif bit.band(spell.flags, spell_flags.finishing_move_dmg) ~= 0 then
        -- seems like finishing moves are never weapon based
        base_min = base_min + direct.per_resource * loadout.resources[powers.combopoints];
        base_max = base_max + direct.per_resource * loadout.resources[powers.combopoints];
    end

    info.base_min = base_min;
    info.base_max = base_max;

    info.min_noncrit_if_hit_base1 =
        (stats.base_mod * (base_min + stats.base_mod_flat) + stats.effect_mod_flat);
    info.max_noncrit_if_hit_base1 =
        (stats.base_mod * (base_max + stats.base_mod_flat) + stats.effect_mod_flat);

    info.min_noncrit_if_hit1 =
        (info.min_noncrit_if_hit_base1 + stats.spell_power * stats.coef) * stats.spell_mod;
    info.max_noncrit_if_hit1 =
        (info.max_noncrit_if_hit_base1 + stats.spell_power * stats.coef) * stats.spell_mod;

    info.min_crit_if_hit1 = info.min_noncrit_if_hit1 * stats.crit_mod;
    info.max_crit_if_hit1 = info.max_noncrit_if_hit1 * stats.crit_mod;

    -- needed to fit generalized template for expectation
    info.crit1 = stats.crit;
    info.direct_utilization1 = 1.0;

    info.num_direct_effects = info.num_direct_effects + 1;
end

local function periodic_info(info, spell, loadout, stats, effects, eval_flags)
    local periodic = spell.periodic;
    local clvl = loadout.lvl;

    local base_tick_min = periodic.min;
    local base_tick_max = periodic.max;

    if periodic.per_lvl_sq == 0 then
        local lvl_diff_applicable = math.max(0,
            math.min(clvl - spell.lvl_req, spell.lvl_max - spell.lvl_req));
        base_tick_min = base_tick_min + periodic.per_lvl * lvl_diff_applicable;
        base_tick_max = base_tick_max + periodic.per_lvl * lvl_diff_applicable;

    else
        local added_effect = periodic.per_lvl * clvl + periodic.per_lvl_sq * clvl * clvl;
        base_tick_min = periodic.min * (periodic.base_min + added_effect);
        base_tick_max = periodic.max * (periodic.base_max + added_effect);
    end

    info.ot_dur1 = stats.dur_ot;
    info.ot_tick_time1 = stats.tick_time_ot;

    -- Not clear if we want to apply weapon as periodic?
    --if bit.band(periodic.flags, comp_flags.applies_mh) ~= 0 then
    --    base_tick_min = (periodic.base + loadout.m1_min) * base_tick_min;
    --    base_tick_max = (periodic.base + loadout.m1_max) * base_tick_max;
    --elseif bit.band(periodic.flags, comp_flags.applies_ranged) ~= 0 then
    --    base_tick_min = (periodic.base + loadout.r_min) * base_tick_min;
    --    base_tick_max = (periodic.base + loadout.r_max) * base_tick_max;
    --elseif bit.band(spell.flags, spell_flags.finishing_move_dmg) ~= 0 then
    --    -- seems like finishing moves are never weapon based
    --    base_tick_min = base_tick_min + periodic.per_cp_dmg * loadout.resources[powers.combopoints];
    --    base_tick_max = base_tick_max + periodic.per_cp_dmg * loadout.resources[powers.combopoints];
    --end
    if bit.band(spell.flags, spell_flags.finishing_move_dmg) ~= 0 then
        base_tick_min = base_tick_min + periodic.per_resource * loadout.resources[powers.combopoints];
        base_tick_max = base_tick_max + periodic.per_resource * loadout.resources[powers.combopoints];
    end
    if bit.band(spell.flags, spell_flags.finishing_move_dur) ~= 0 or
        periodic.per_cp_dur then

        info.ot_dur1 = info.ot_dur1 + (periodic.per_cp_dur or info.ot_tick_time1) * loadout.resources[powers.combopoints];
    end

    -- round so tooltip is displayed nicely
    info.ot_ticks1 = math.floor(0.5 + (info.ot_dur1 / info.ot_tick_time1));
    --info.ot_dur1 = info.ot_tick_time1 * info.ot_ticks1;
    info.longest_ot_duration = info.ot_dur1;

    info.ot_min_crit_if_hit1 = 0.0;
    info.ot_max_crit_if_hit1 = 0.0;

    info.ot_base_min = base_tick_min;
    info.ot_base_max = base_tick_max;

    info.ot_min_noncrit_if_hit_base1 = (stats.base_mod_ot * (base_tick_min + stats.base_mod_ot_flat) + stats.effect_mod_ot_flat);
    info.ot_max_noncrit_if_hit_base1 = (stats.base_mod_ot * (base_tick_max + stats.base_mod_ot_flat) + stats.effect_mod_ot_flat);

    info.ot_min_noncrit_if_hit1 = (info.ot_min_noncrit_if_hit_base1 + stats.coef_ot * stats.spell_power_ot) * info.ot_ticks1 * stats.spell_mod_ot;
    info.ot_max_noncrit_if_hit1 = (info.ot_max_noncrit_if_hit_base1 + stats.coef_ot * stats.spell_power_ot) * info.ot_ticks1 * stats.spell_mod_ot;

    info.ot_min_crit_if_hit1 = info.ot_min_noncrit_if_hit1 * stats.crit_mod_ot;
    info.ot_max_crit_if_hit1 = info.ot_max_noncrit_if_hit1 * stats.crit_mod_ot;

    -- needed to fit generalized template for expectation
    info.ot_crit1 = stats.crit_ot;
    info.ot_utilization1 = 1.0;

    info.num_periodic_effects = info.num_periodic_effects + 1;
end

local expectation_variations = {
    "expected", "expected_st", "expected_ot", "expected_ot_st", "expected_direct", "expected_direct_st", "threat", "threat_st", "threat_ot", "threat_ot_st", "threat_direct", "threat_direct_st"
};

local secondary_info = {};
local secondary_stats = {};

local spell_info_from_stats;

local function spell_info(info, spell, stats, loadout, effects, eval_flags)

    eval_flags = eval_flags or 0;

    info.num_periodic_effects = 0;
    info.num_direct_effects = 0;

    local anycomp = spell.direct or spell.periodic;

    if spell.direct then
        direct_info(info, spell, loadout, stats, effects, eval_flags);
    end
    if spell.periodic then
        periodic_info(info, spell, loadout, stats, effects, eval_flags);
    end

    local num_unbounded_targets = loadout.unbounded_aoe_targets;
    if bit.band(eval_flags, evaluation_flags.assume_single_effect) ~= 0 then
        num_unbounded_targets = 1;
    end

    resolve_extra_spell_effects(info, stats);

    calc_expectation(info, spell, stats, loadout, num_unbounded_targets);

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

    if bit.band(eval_flags, evaluation_flags.isolate_periodic) ~= 0 then
        info.expected_st = info.expected_st - info.expected_direct_st;
        info.expected = info.expected - info.expected_direct;

        info.expected_direct_st = 0;
        info.expected_direct = 0;
    end
    if bit.band(eval_flags, evaluation_flags.isolate_direct) ~= 0 then
        info.expected_st = info.expected_st - info.expected_ot_st;
        info.expected = info.expected - info.expected_ot;

        info.expected_ot_st = 0;
        info.expected_ot = 0;
    end

    if info.expected < info.expected_st or
        bit.band(eval_flags, evaluation_flags.assume_single_effect) ~= 0 then

        info.expected = info.expected_st;
        info.expected_ot = info.expected_ot_st;
        info.expected_direct = info.expected_direct_st
    end

    if info.threat < info.threat_st or
        bit.band(eval_flags, evaluation_flags.assume_single_effect) ~= 0 then

        info.threat = info.threat_st;
        info.threat_ot = info.threat_ot_st;
        info.threat_direct = info.threat_direct_st
    end

    if bit.band(spell.flags, spell_flags.on_next_attack) ~= 0 and
        bit.band(eval_flags, evaluation_flags.expectation_of_self) == 0 then

        spell_info_from_stats(secondary_info,
                              secondary_stats,
                              spells[sc.auto_attack_spell_id],
                              loadout,
                              effects,
                              eval_flags);

        local atk = secondary_info;
        for _, v in pairs(expectation_variations) do
            info[v] = info[v] - atk[v];
        end
    end
    if bit.band(spell.flags, spell_flags.no_threat) ~= 0 then
        info.threat = 0;
    end

    info.effect_per_sec = info.expected / stats.cast_time;
    info.threat_per_sec = info.threat / stats.cast_time;

    local dual_wield_flags = bit.bor(comp_flags.applies_mh, comp_flags.applies_oh);

    if loadout.m2_speed ~= nil and
        bit.band(anycomp.flags, dual_wield_flags) == dual_wield_flags and
        bit.band(eval_flags, bit.bor(evaluation_flags.isolate_mh, evaluation_flags.isolate_oh)) == 0 then
        -- evaluate dual wield combined weapons

        spell_info_from_stats(secondary_info,
                              secondary_stats,
                              spell,
                              loadout,
                              effects,
                              bit.bor(eval_flags, evaluation_flags.isolate_oh));

        info.oh_info = secondary_info;
        info.oh_stats = secondary_stats;

        for _, v in pairs(expectation_variations) do 
            info[v] = info[v] - info.oh_info[v];
        end

        info.effect_per_sec = info.effect_per_sec + info.oh_info.effect_per_sec;
        info.threat_per_sec = info.threat_per_sec + info.oh_info.threat_per_sec;
    else
        info.oh_info, info.oh_stats = nil, nil;
    end

    if stats.cost == 0 then
        info.effect_per_cost = math.huge;
        info.threat_per_cost = math.huge;
    else
        info.effect_per_cost = info.expected / stats.cost;
        info.threat_per_cost = info.threat / stats.cost;
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

end

spell_info_from_stats = function(info, stats, spell, loadout, effects, eval_flags)
    stats_for_spell(stats, spell, loadout, effects, eval_flags);
    spell_info(info, spell, stats, loadout, effects, eval_flags);
end

local function cast_until_oom(spell_effect, stats, loadout, effects, calculating_weights)
    calculating_weights = calculating_weights or false;

    local mana = loadout.resources[powers.mana] + config.loadout.extra_mana + effects.raw.mana;

    local spirit = loadout.stats[attr.spirit] +
        effects.by_attr.stats[attr.spirit] * (1.0 + effects.by_attr.stat_mod[attr.spirit]);

    local mp2_not_casting = spirit_mana_regen(spirit);

    if not calculating_weights then
        mp2_not_casting = math.ceil(mp2_not_casting);
    end
    local mp5 = effects.raw.mp5
        +
        loadout.resources_max[powers.mana] * effects.raw.perc_max_mana_as_mp5
        +
        effects.raw.mp5_from_int_mod * (loadout.stats[attr.intellect] +
            effects.by_attr.stats[attr.intellect] * (1.0 + effects.by_attr.stat_mod[attr.intellect]));

    local mp1_casting =
        0.2 * mp5 +
        0.5 * mp2_not_casting * math.max(0, math.min(1.0, effects.raw.regen_while_casting));

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
        spell_effect.effect_until_oom = spell_effect.num_casts_until_oom * spell_effect.expected;
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

            --    stats.coef_ot = stats.coef;
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
            --if loadout.runes[rune_ids.burn] then
            --    add_expectation_ot_st(info, 4);
            --    add_expectation_direct_st(info, 4);
            --end
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

                stats.coef_ot = stats.secondary_ability_stats.coef_ot;
            end

            calc_expectation(info, spell, stats, loadout);
        end,
        [spids.renew] = function(spell, info, loadout, stats, effects)
            --if loadout.runes[rune_ids.empowered_renew] then
            --    local direct = info.ot_min_noncrit_if_hit1 / info.ot_ticks1;

            --    info.min_noncrit_if_hit1 = direct;
            --    info.max_noncrit_if_hit1 = direct;
            --    info.min_crit_if_hit1 = direct * stats.crit_mod;
            --    info.max_crit_if_hit1 = direct * stats.crit_mod;

            --    calc_expectation(info, spell, stats, loadout);
            --end
        end,
        [spids.binding_heal] = function(spell, info, loadout, stats, effects)
            add_expectation_direct_st(info, 1);
        end,
        [spids.penance] = function(spell, info, loadout, stats, effects)

            if is_buff_up(loadout, "player", lookups.rapid_healing, true) and
                bit.band(sc.game_mode, sc.game_modes.season_of_discovery) ~= 0 then

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


        --    stats.coef = stats.coef_ot * num_ticks;
        --    stats.coef_ot = 0;

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
            --if loadout.runes[rune_ids.shadow_bolt_volley] then
            --    add_expectation_direct_st(info, 4);
            --end
        end,
    };
elseif class == "PALADIN" then
    special_abilities = {
        --[spids.avengers_shield] = function(spell, info, loadout)
        --    add_expected_direct_st(info, 2);
        --end,
    };
elseif class == "MAGE" then
    special_abilities = {
        --[spids.mass_regeneration] = function(spell, info, loadout)
        --    add_expectation_ot_st(info, 4);
        --end,
        [spids.mana_shield] = function(spell, info, loadout, stats)
            local pts = loadout.talents_table[110];
            local drain_mod = 0.1 * pts;
            --if loadout.runes[rune_ids.advanced_warding] then
            --    drain_mod = drain_mod + 0.5;
            --end
            stats.cost = stats.cost + 2 * info.absorb * (1.0 - drain_mod);
        end,
        --[spids.temporal_anomaly] = function(spell, info, loadout)
        --    add_expectation_ot_st(info, 4);
        --end,
    };
else
    special_abilities = {};
end

local function resource_regen_info(info, spell, spell_id, loadout, effects)

    local min;
    local bid = spell.base_id;
    local direct = spell.direct;
    local clvl = loadout.lvl;
    if direct then

        if direct.per_lvl_sq == 0 then
            local lvl_diff_applicable = math.max(0,
                math.min(clvl - spell.lvl_req, spell.lvl_max - spell.lvl_req));
            min = direct.min + direct.per_lvl * lvl_diff_applicable;
        else
            local added_effect = direct.per_lvl * clvl + direct.per_lvl_sq * clvl * clvl;
            min = direct.min * (direct.base_min + added_effect);
        end
        min =
            (
                (
                    (min + (effects.ability.base_mod_flat[bid] or 0.0))
                    *
                    (1.0 + (effects.ability.base_mod[bid] or 0.0))
                )
                +
                (effects.ability.effect_mod_flat[bid] or 0.0)
            )
            *
            (1.0 + (effects.ability.effect_mod[bid] or 0.0));
    else
        local periodic = spell.periodic;

        if periodic.per_lvl_sq == 0 then
            local lvl_diff_applicable = math.max(0,
                math.min(clvl - spell.lvl_req, spell.lvl_max - spell.lvl_req));
            min = periodic.min + periodic.per_lvl * lvl_diff_applicable;
        else
            local added_effect = periodic.per_lvl * clvl + periodic.per_lvl_sq * clvl * clvl;
            min = periodic.min * (periodic.base_min + added_effect);
        end
        min =
            (
                (
                    (min + (effects.ability.base_mod_ot_flat[bid] or 0.0))
                    *
                    (1.0 + (effects.ability.base_mod_ot[bid] or 0.0))
                )
                +
                (effects.ability.effect_mod_ot_flat[bid] or 0.0)
            )
            *
            (1.0 + (effects.ability.effect_mod_ot[bid] or 0.0));

        info.dur =
            (periodic.dur + (effects.ability.extra_dur_flat[bid] or 0.0))
            *
            (1.0 + (effects.ability.extra_dur[bid] or 0.0));
        info.tick_time =
            periodic.tick_time + (effects.ability.extra_tick_time_flat[bid] or 0.0);
        info.ticks = info.dur / info.tick_time;
    end

    if bit.band(spell.flags, spell_flags.regen_pct) ~= 0 then
        -- percentage off mana regen
        info.restored = 0.0;
        info.total_restored = 0.0;

        local casting_regen = effects.raw.regen_while_casting;
        if is_buff_up(loadout, "player", spell_id, true) then
            casting_regen = casting_regen - 1.0;
        end
        casting_regen = math.max(0, math.min(1.0, casting_regen));

        -- evocate, innervate etc
        local spirit = loadout.stats[attr.spirit] +
        (effects.by_attr.stats[attr.spirit] * (1.0 + effects.by_attr.stat_mod[attr.spirit]));
        -- Prevents combat casting regen % gained from this ability affecting this evaluation
        -- This becomes mana restored otherwise not gained from normal % regen while casting
        info.restored =
            (1.0 - casting_regen + min) * spirit_mana_regen(spirit);
        info.total_restored = info.restored * info.dur/info.tick_time;

    elseif bit.band(spell.flags, spell_flags.regen_max_pct) ~= 0 then
        info.restored = min * loadout.resources_max[powers.mana];
        info.total_restored = info.restored * info.dur/info.tick_time;

    elseif spell.periodic then
        info.restored = min;
        info.total_restored = info.restored * info.dur/info.tick_time;
    else
        info.restored = min;
        info.total_restored = info.restored;
    end
end

local dmg_magic_stat_weights = {
    { display = "SP", key = "sp", normalize_to = true},
    { display = "Int", key = "stats", key2 = attr.intellect},
    { display = "Spirit", key = "stats", key2 = attr.spirit},
    { display = "Crit", key = "crit_rating"},
    { display = "Hit", key = "hit_rating"},
    { display = "Spell Pen", key = "spell_pen"},
    { display = "MP5", key = "mp5"},
};

local heal_stat_weights = {
    { display = "HP", key = "sp", normalize_to = true},
    { display = "Int", key = "stats", key2 = attr.intellect},
    { display = "Spirit", key= "stats", key2 = attr.spirit},
    { display = "MP5", key = "mp5"},
    { display = "Crit", key = "crit_rating"},
};

local melee_stat_weights = {
    { display = "AP", key = "ap", normalize_to = true},
    { display = "Str", key = "stats", key2 = attr.strength},
    { display = "Agi", key= "stats", key2 = attr.agility},
    { display = "Crit", key = "crit_rating"},
    { display = "Hit", key = "hit_rating"},
    { display = "Wep skill", key = "weapon_skill"},
};
local ranged_stat_weights = {
    { display = "RAP", key = "rap", normalize_to = true},
    { display = "Agi", key= "stats", key2 = attr.agility},
    { display = "Crit", key = "crit_rating"},
    { display = "Hit", key = "hit_rating"},
    { display = "Wep skill", key = "weapon_skill"},
};

local info_diff = {};
local spell_stats_diffed = {};
local diff = effects_zero_diff();
local effects_diffed = {}
empty_effects(effects_diffed);

local function stat_weights(normal_info, spell, loadout, effects, eval_flags)

    local weights;
    local anycomp = spell.direct or spell.periodic;
    if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
        weights = heal_stat_weights;
    elseif anycomp.school1 ~= schools.physical then
        weights = dmg_magic_stat_weights;
    elseif bit.band(anycomp.flags, comp_flags.applies_ranged) ~= 0 then
        weights = ranged_stat_weights;
    else
        weights = melee_stat_weights;
    end

    local normalize_table;

    cpy_effects(effects_diffed, effects);

    for _, v in ipairs(weights) do
        if v.normalize_to then
            normalize_table = v;
        end
        if v.key2 then
            diff[v.key][v.key2] = 1;
        else
            diff[v.key] = 1;
        end
        effects_diff(loadout, effects_diffed, diff);
        stats_for_spell(spell_stats_diffed, spell, loadout, effects_diffed, eval_flags);
        spell_info(info_diff, spell, spell_stats_diffed, loadout, effects_diffed, eval_flags);
        cast_until_oom(info_diff, spell_stats_diffed, loadout, effects_diffed, true);
        cpy_effects(effects_diffed, effects);
        if v.key2 then
            diff[v.key][v.key2] = 0;
        else
            diff[v.key] = 0;
        end

        v.effect_per_sec_delta = info_diff.effect_per_sec - normal_info.effect_per_sec;
        v.effect_delta = info_diff.expected - normal_info.expected;
        v.effect_until_oom_delta = info_diff.effect_until_oom - normal_info.effect_until_oom;
    end

    local eps = 0.000000001;
    if normalize_table.effect_per_sec_delta < eps then
        normalize_table = nil;
        local lowest = math.huge;
        -- need to find any other field to normalize to
        for _, v in ipairs(weights) do
            if v.effect_per_sec_delta > eps and v.effect_per_sec_delta < lowest then
                lowest = v.effect_per_sec_delta;
                normalize_table = v;
            end
        end
    end
    if normalize_table then
        -- Normalize to first weight
        for _, v in ipairs(weights) do
            v.effect_per_sec_weight = v.effect_per_sec_delta/normalize_table.effect_per_sec_delta;
            v.effect_weight = v.effect_delta/normalize_table.effect_delta;
        end
        if spell.power_type == sc.powers.mana then
            for _, v in ipairs(weights) do
                v.effect_until_oom_weight = v.effect_until_oom_delta/normalize_table.effect_until_oom_delta;
            end
        end
    end

    return weights, normalize_table;
end

local function spell_diff(spell_normal, spell_diffed, sim_type)
    if sim_type == simulation_type.spam_cast then
        return {
            diff_ratio = 100 * (spell_diffed.effect_per_sec / spell_normal.effect_per_sec - 1),
            first = spell_diffed.effect_per_sec - spell_normal.effect_per_sec,
            second = spell_diffed.expected - spell_normal.expected
        };
    elseif sim_type == simulation_type.cast_until_oom then
        return {
            diff_ratio = 100 * (spell_diffed.effect_until_oom / spell_normal.effect_until_oom - 1),
            first = spell_diffed.time_until_oom - spell_normal.time_until_oom,
            second = spell_diffed.effect_until_oom - spell_normal.effect_until_oom
        };
    end
end

calc.simulation_type          = simulation_type;
calc.evaluation_flags         = evaluation_flags;
calc.stats_for_spell          = stats_for_spell;
calc.spell_info               = spell_info;
calc.cast_until_oom           = cast_until_oom;
calc.stat_weights             = stat_weights;
calc.get_combat_rating_effect = get_combat_rating_effect;
calc.spell_diff               = spell_diff;
calc.resource_regen_info      = resource_regen_info;

sc.calc                      = calc;
