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

local _, swc                = ...;

local spells                = swc.abilities.spells;
local spell_flags           = swc.abilities.spell_flags;
local spids                 = swc.abilities.spids;
local next_spell_rank       = swc.abilities.next_spell_rank;
local best_rank_by_lvl      = swc.abilities.best_rank_by_lvl;

local spell_cost            = swc.utils.spell_cost;
local spell_cast_time       = swc.utils.spell_cast_time;
local effect_colors         = swc.utils.effect_colors;

local set_tiers             = swc.equipment.set_tiers;

local rune_ids              = swc.talents.rune_ids;

local stats_for_spell       = swc.calc.stats_for_spell;
local evaluate_spell        = swc.calc.evaluate_spell;

local sort_stat_weights     = swc.tooltip.sort_stat_weights;
local begin_tooltip_section = swc.tooltip.begin_tooltip_section;
local end_tooltip_section   = swc.tooltip.end_tooltip_section;

local config                = swc.config;

-------------------------------------------------------------------------------

local stats                 = {};

local function format_bounce_spell(min_hit, max_hit, bounces, falloff)
    local bounce_str = "     + ";
    for _ = 1, bounces - 1 do
        bounce_str = bounce_str .. string.format(" %d-%d  + ",
            falloff * math.floor(min_hit),
            falloff * math.ceil(max_hit));
        falloff = falloff * falloff;
    end
    bounce_str = bounce_str .. string.format(" %d-%d",
        falloff * math.floor(min_hit),
        falloff * math.ceil(max_hit));
    return bounce_str;
end

local function tooltip_spell_info(tooltip, spell, loadout, effects, repeated_tooltip_on, spell_id)
    -- Set gray spell rank in upper-right corner again after custom SetSpellByID clears it
    if spell.rank ~= 0 then
        local txt_right = getglobal("GameTooltipTextRight1");
        if txt_right then
            txt_right:SetTextColor(0.50196081399918, 0.50196081399918, 0.50196081399918, 1.0);
            txt_right:SetText("Rank " .. spell.rank);
            txt_right:Show();
        end
    end

    if sw_frame.tooltip_frame.tooltip_num_checked == 0 or
        (config.settings.tooltip_shift_to_show and not IsShiftKeyDown()) then
        return;
    end

    local eval_flags = 0;
    if IsAltKeyDown() then
        eval_flags = bit.bor(eval_flags, swc.calc.evaluation_flags.assume_single_effect);
        eval_flags = bit.bor(eval_flags, swc.calc.evaluation_flags.offhand);
    end

    if IsControlKeyDown() then
        local dir = GetPlayerFacing();
        if dir and math.abs(dir - math.pi) > 0.5 * math.pi then
            -- facing north
            eval_flags = bit.bor(eval_flags, swc.calc.evaluation_flags.isolate_periodic);
        else
            eval_flags = bit.bor(eval_flags, swc.calc.evaluation_flags.isolate_direct);
        end
    end

    stats_for_spell(stats, spell, loadout, effects, eval_flags);
    local eval = evaluate_spell(spell, stats, loadout, effects, eval_flags);

    local effect = "";
    local effect_per_sec = "";
    local effect_per_cost = "";
    local cost_per_sec = "";
    local effect_per_sec_per_sp = "";

    local cost_str = "";
    local cost_str_cap = "";
    if spell.power_type == swc.powers.mana then
        cost_str = "mana";
        cost_str_cap = "Mana";
    elseif spell.power_type == swc.powers.rage then
        cost_str = "rage";
        cost_str_cap = "Rage";
    elseif spell.power_type == swc.powers.energy then
        cost_str = "energy";
        cost_str_cap = "Energy";
    end

    if bit.band(spell.flags, spell_flags.heal) ~= 0 or bit.band(spell.flags, spell_flags.absorb) ~= 0 then
        effect = "Heal";
        effect_per_sec = "HPS";
        effect_per_cost = "Heal per "..cost_str;
        cost_per_sec = cost_str_cap.." per sec";
        effect_per_sec_per_sp = "HPS per SP";
    else
        effect = "Damage";
        effect_per_sec = "DPS";
        effect_per_cost = "Damage per "..cost_str;
        cost_per_sec = cost_str_cap.." per sec";
        effect_per_sec_per_sp = "DPS per SP";
    end

    begin_tooltip_section(tooltip, spell, spell_id);


    if config.settings.tooltip_display_loadout_info then

        local specified = "";
        if config.loadout.unbounded_aoe_targets > 1 then
            specified = string.format("%dx |", config.loadout.unbounded_aoe_targets);
        end
        if bit.band(spell.flags, bit.bor(spell_flags.absorb, spell_flags.heal, spell_flags.resource_regen)) ~= 0 then
            tooltip:AddLine(string.format("Target: %.0f%% HP",
                    loadout.friendly_hp_perc * 100
                ),
                effect_colors.loadout_info[1], effect_colors.loadout_info[2], effect_colors.loadout_info[3]);
        else
            tooltip:AddLine(string.format("Target: %slvl %d | %.0f%% HP | %d RES",
                    specified,
                    loadout.target_lvl,
                    loadout.enemy_hp_perc * 100,
                    stats.target_resi
                ),
                effect_colors.loadout_info[1], effect_colors.loadout_info[2], effect_colors.loadout_info[3]);
        end
    end
    if config.settings.tooltip_display_spell_rank and not repeated_tooltip_on then
        local next_rank_str = "";
        local next_rank = next_spell_rank(spell);
        local lvl_req_str = "trained at level "..spell.lvl_req..")";
        if next_rank and best_rank and spells[best_rank].rank + 1 == spells[next_rank].rank then
            next_rank_str = next_rank_str .. "(highest yet; next rank at lvl " .. spells[next_rank].lvl_req .. ")";
        elseif best_rank and spells[best_rank].rank == spell.rank then
            next_rank_str = "(highest available "..lvl_req_str;
        elseif best_rank and spells[best_rank].rank > spell.rank then
            next_rank_str = "(downranked "..lvl_req_str;
        else
            next_rank_str = "(unavailable "..lvl_req_str;
        end

        tooltip:AddLine(string.format("Spell rank: %d %s", spell.rank, next_rank_str),
            effect_colors.spell_rank[1], effect_colors.spell_rank[2], effect_colors.spell_rank[3]);
    end
    if config.settings.tooltip_display_spell_id and not repeated_tooltip_on then
        tooltip:AddLine(string.format("Spell ID: %d", spell_id),
            effect_colors.spell_rank[1], effect_colors.spell_rank[2], effect_colors.spell_rank[3]);
    end

    if config.loadout.force_apply_buffs or config.loadout.use_custom_talents or config.loadout.use_custom_lvl then

        tooltip:AddLine("WARNING: using custom talents, runes, lvl or buffs!", 1, 0, 0);
    end

    if bit.band(spell.flags, spell_flags.resource_regen) ~= 0 then
        tooltip:AddLine(string.format("Restores %d %s over %.1f sec for yourself.",
                math.ceil(eval.spell.mana_restored),
                math.max(stats.cast_time, spell.over_time_duration),
                cost_str
            ),
            0, 1, 1);
        if spell.over_time_tick_freq > 1 then
            tooltip:AddLine(string.format("Mana per tick: %.1f",
                    spell.over_time_tick_freq * math.ceil(eval.spell.mana_restored) /
                    math.max(stats.cast_time, spell.over_time_duration)
                ),
                0, 1, 1);
        end
        tooltip:AddLine(string.format("Mana per sec: %.1f",
                eval.spell.mana_restored / math.max(stats.cast_time, spell.over_time_duration)
            ),
            0, 1, 1);

        end_tooltip_section(tooltip);
        return;
    end

    local hit_str = "";
    if spell.direct then
        hit_str = string.format(" (%.1f%% hit)", stats.hit * 100);
        if stats.target_avg_resi > 0 then
            hit_str = string.format(" (%.1f%%hit||%.1f%%resist)", stats.hit * 100, stats.target_avg_resi * 100);
        end

        if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
            if config.settings.tooltip_display_hit and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_periodic) == 0 then
                tooltip:AddLine(

                    string.format("Hit (lvl %d): %.1f%% | Resisted (%d resistance): %.1f%%",  loadout.target_lvl, stats.hit * 100, stats.target_resi ,stats.target_avg_resi*100),
                    effect_colors.hit[1], effect_colors.hit[2], effect_colors.hit[3]);
                hit_str = "";
            end
            if config.settings.tooltip_display_normal and not config.settings.tooltip_display_normal_hit_combined then
                hit_str = "";
            end
        end
    end
    if (config.settings.tooltip_display_normal_hit_combined or config.settings.tooltip_display_normal) and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_periodic) == 0 and eval.spell.num_direct_effects > 0 then
        if spell.direct then
            if eval.spell.min_noncrit_if_hit1 ~= eval.spell.max_noncrit_if_hit1 then
                -- dmg spells with real direct range
                if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                    tooltip:AddLine(string.format("%s%s: %d-%d",
                            effect,
                            hit_str,
                            math.floor(eval.spell.min_noncrit_if_hit1),
                            math.ceil(eval.spell.max_noncrit_if_hit1)),
                        effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                    -- heal spells with real direct range
                else
                    tooltip:AddLine(string.format("%s: %d-%d",
                            effect,
                            math.floor(eval.spell.min_noncrit_if_hit1),
                            math.ceil(eval.spell.max_noncrit_if_hit1)),
                        effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                end
                if bit.band(eval_flags, swc.calc.evaluation_flags.assume_single_effect) == 0 then
                    if spell.base_id == spids.chain_heal then
                        local bounces = 2;
                        local falloff = 0.5;
                        if loadout.runes[rune_ids.coherence] then
                            bounces = 3;
                            falloff = falloff + 0.15;
                        end
                        if loadout.num_set_pieces[set_tiers.pve_2] >= 3 then
                            falloff = 0.5 * 1.3;
                        end

                        tooltip:AddLine(format_bounce_spell(eval.spell.min_noncrit_if_hit1,
                                eval.spell.max_noncrit_if_hit1,
                                bounces,
                                falloff),
                            effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                    elseif spell.base_id == spids.chain_lightning then
                        local bounces = 2;
                        local falloff = 0.7;
                        if loadout.runes[rune_ids.coherence] then
                            bounces = 3;
                            falloff = falloff + 0.1;
                        end
                        if loadout.num_set_pieces[set_tiers.pve_2_5_1] >= 3 then
                            falloff = falloff + 0.05;
                        end
                        tooltip:AddLine(format_bounce_spell(eval.spell.min_noncrit_if_hit1,
                                eval.spell.max_noncrit_if_hit1,
                                bounces,
                                falloff),
                            effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                    elseif spell.base_id == spids.healing_wave and
                        (loadout.num_set_pieces[set_tiers.pve_1] >= 8 or
                            loadout.num_set_pieces[set_tiers.sod_final_pve_1_heal] >= 6) then
                        local bounces = 2;
                        local falloff = 0.4;
                        tooltip:AddLine(format_bounce_spell(eval.spell.min_noncrit_if_hit1,
                                eval.spell.max_noncrit_if_hit1,
                                bounces,
                                falloff),
                            effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                    end
                end
            else
                if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                    tooltip:AddLine(string.format("%s%s: %.1f",
                            effect,
                            hit_str,
                            eval.spell.min_noncrit_if_hit1),
                        --string.format("%.0f", eval.spell.min_noncrit_if_hit1)),
                        effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                else
                    if eval.spell.absorb ~= 0 then
                        tooltip:AddLine(string.format("Absorb: %.1f",
                                eval.spell.absorb),
                            effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                    end
                    if eval.spell.min_noncrit_if_hit1 ~= 0 then
                        tooltip:AddLine(string.format("%s: %.1f",
                                effect,
                                eval.spell.min_noncrit_if_hit1),
                            effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                    end
                end
            end
        end

        for i = 2, eval.spell.num_direct_effects do
            if eval.spell["min_noncrit_if_hit" .. i] ~= eval.spell["max_noncrit_if_hit" .. i] then
                tooltip:AddLine(string.format("%s: %d-%d",
                        eval.spell["direct_description" .. i],
                        math.floor(eval.spell["min_noncrit_if_hit" .. i]),
                        math.ceil(eval.spell["max_noncrit_if_hit" .. i])),
                    effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
            elseif eval.spell["min_noncrit_if_hit" .. i] ~= 0 then
                tooltip:AddLine(string.format("%s: %.1f",
                        eval.spell["direct_description" .. i],
                        eval.spell["min_noncrit_if_hit" .. i]),
                    effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
            end
        end
    end
    local crit_mod = stats.crit_mod;
    local special_crit_mod_str = "";

    if eval.spell.min_crit_if_hit1 ~= 0 and stats.special_crit_mod_tracked ~= 0 and
        (not stats["extra_effect_is_periodic" .. stats.special_crit_mod_tracked] or bit.band(eval_flags, swc.calc.evaluation_flags.isolate_direct) == 0) then
        special_crit_mod_str = " + "..stats["extra_effect_desc" .. stats.special_crit_mod_tracked];
        crit_mod = stats.crit_mod * (1.0 + stats["extra_effect_val" .. stats.special_crit_mod_tracked]);
    end

    local crit_chance_info_str = string.format(" (%.2f%%||%.2fx)", stats.crit*100, crit_mod);
    if spell.direct and config.settings.tooltip_display_crit_chance and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_periodic) == 0 and stats.crit ~= 0 and eval.spell.min_crit_if_hit1 + eval.spell.absorb ~= 0 then

        tooltip:AddLine(string.format("Critical chance: %.2f%% | Modifier %.2fx", stats.crit*100, crit_mod),
            effect_colors.crit[1], effect_colors.crit[2], effect_colors.crit[3]);
        crit_chance_info_str = "";
    end
    if config.settings.tooltip_display_crit and not config.settings.tooltip_display_crit_combined then
        crit_chance_info_str = "";
    end

    if (config.settings.tooltip_display_crit or config.settings.tooltip_display_crit_combined) and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_periodic) == 0 and eval.spell.num_direct_effects > 0 then
        if stats.crit ~= 0 and spell.direct then
            if eval.spell.min_crit_if_hit1 ~= eval.spell.max_crit_if_hit1 then
                tooltip:AddLine(string.format("Critical%s: %d-%d%s",
                        crit_chance_info_str,
                        math.floor(eval.spell.min_crit_if_hit1),
                        math.ceil(eval.spell.max_crit_if_hit1),
                        special_crit_mod_str),
                    effect_colors.crit[1], effect_colors.crit[2], effect_colors.crit[3]);
            elseif eval.spell.min_crit_if_hit1 ~= 0 then
                tooltip:AddLine(string.format("Critical%s: %.1f%s",
                        crit_chance_info_str,
                        eval.spell.min_crit_if_hit1,
                        special_crit_mod_str),
                    effect_colors.crit[1], effect_colors.crit[2], effect_colors.crit[3]);
            end

            if bit.band(eval_flags, swc.calc.evaluation_flags.assume_single_effect) == 0 then
                if spell.base_id == spids.chain_heal then
                    local bounces = 2;
                    local falloff = 0.5;
                    if loadout.runes[rune_ids.coherence] then
                        bounces = 3;
                        falloff = falloff + 0.15;
                    end
                    if loadout.num_set_pieces[set_tiers.pve_2] >= 3 then
                        falloff = 0.5 * 1.3;
                    end

                    tooltip:AddLine(format_bounce_spell(eval.spell.min_crit_if_hit1,
                            eval.spell.max_crit_if_hit1,
                            bounces,
                            falloff),
                        effect_colors.crit[1], effect_colors.crit[2], effect_colors.crit[3]);
                elseif spell.base_id == spids.chain_lightning then
                    local bounces = 2;
                    local falloff = 0.7;
                    if loadout.runes[rune_ids.coherence] then
                        bounces = 3;
                        falloff = falloff + 0.1;
                    end
                    if loadout.num_set_pieces[set_tiers.pve_2_5_1] >= 3 then
                        falloff = falloff + 0.05;
                    end
                    tooltip:AddLine(format_bounce_spell(eval.spell.min_crit_if_hit1,
                            eval.spell.max_crit_if_hit1,
                            bounces,
                            falloff),
                        effect_colors.crit[1], effect_colors.crit[2], effect_colors.crit[3]);
                elseif spell.base_id == spids.healing_wave and
                    (loadout.num_set_pieces[set_tiers.pve_1] >= 8 or
                        loadout.num_set_pieces[set_tiers.sod_final_pve_1_heal] >= 6) then
                    local bounces = 2;
                    local falloff = 0.4;
                    tooltip:AddLine(format_bounce_spell(eval.spell.min_crit_if_hit1,
                            eval.spell.max_crit_if_hit1,
                            bounces,
                            falloff),
                        effect_colors.crit[1], effect_colors.crit[2], effect_colors.crit[3]);
                end
            end
        end

        for i = 2, eval.spell.num_direct_effects do
            if eval.spell["min_crit_if_hit" .. i] ~= eval.spell["max_crit_if_hit" .. i] then
                tooltip:AddLine(string.format("%s (%.2f%%): %d-%d",
                        eval.spell["direct_description" .. i],
                        eval.spell["crit" .. i] * 100,
                        math.floor(eval.spell["min_crit_if_hit" .. i]),
                        math.ceil(eval.spell["max_crit_if_hit" .. i])),
                    effect_colors.crit[1], effect_colors.crit[2], effect_colors.crit[3]);
            else
                tooltip:AddLine(string.format("%s (%.2f%%): %.1f",
                        eval.spell["direct_description" .. i],
                        eval.spell["crit" .. i] * 100,
                        eval.spell["min_crit_if_hit" .. i]),
                    effect_colors.crit[1], effect_colors.crit[2], effect_colors.crit[3]);
            end
        end
    end

    hit_str = "";
    if spell.periodic and bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
        if stats.target_avg_resi_dot > 0 then
            hit_str = string.format(" (%.1f%%hit||%.1f%%resist)", stats.hit_ot * 100, stats.target_avg_resi_dot * 100);
        end
        if config.settings.tooltip_display_normal and not config.settings.tooltip_display_normal_hit_combined then
            hit_str = "";
        end
        if config.settings.tooltip_display_hit and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_direct) == 0 then
            if stats.target_avg_resi ~= stats.target_avg_resi_dot then
                tooltip:AddLine(
                    string.format("Hit (lvl %d): %.1f%% | Resisted (%d resistance): %.1f%%", loadout.target_lvl, stats.hit_ot * 100, stats.target_resi_dot, stats.target_avg_resi_dot*100),
                    effect_colors.hit[1], effect_colors.hit[2], effect_colors.hit[3]);
            end
            hit_str = "";
        end
    end

    if (config.settings.tooltip_display_normal or config.settings.tooltip_display_normal_hit_combined) and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_direct) == 0 and eval.spell.num_periodic_effects > 0 then
        if spell.periodic then
            if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                if spell.base_id == spids.curse_of_agony then
                    --local dmg_from_sp = stats.ot_coef * stats.spell_ot_mod * stats.spell_power * eval.spell.ot_ticks;
                    --local dmg_wo_sp = (eval.spell.ot_min_noncrit_if_hit1 - dmg_from_sp);
                    local dmg_from_sp = eval.spell.ot_min_noncrit_if_hit1 - eval.spell.ot_min_noncrit_if_hit_base1;
                    local dmg_wo_sp = eval.spell.ot_min_noncrit_if_hit_base1;
                    tooltip:AddLine(string.format("%s%s: %.1f over %.1fs (%.1f-%.1f-%.1f every %.1fs x %d)",
                            effect,
                            hit_str,
                            eval.spell.ot_min_noncrit_if_hit1,
                            eval.spell.ot_dur1,
                            (0.5 * dmg_wo_sp + dmg_from_sp) / eval.spell.ot_ticks1,
                            eval.spell.ot_min_noncrit_if_hit1 / eval.spell.ot_ticks1,
                            (1.5 * dmg_wo_sp + dmg_from_sp) / eval.spell.ot_ticks1,
                            eval.spell.ot_tick_time1,
                            eval.spell.ot_ticks1),

                        effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                elseif spell.base_id == spids.starshards then
                    --local dmg_from_sp = stats.ot_coef * stats.spell_ot_mod * stats.spell_power * eval.spell.ot_ticks;
                    --local dmg_wo_sp = (eval.spell.ot_min_noncrit_if_hit1 - dmg_from_sp);
                    local dmg_from_sp = eval.spell.ot_min_noncrit_if_hit1 - eval.spell.ot_min_noncrit_if_hit_base1;
                    local dmg_wo_sp = eval.spell.ot_min_noncrit_if_hit_base1;
                    tooltip:AddLine(string.format("%s%s: %.1f over %.1fs (%.1f-%.1f-%.1f every %.1fs x %d)",
                            effect,
                            hit_str,
                            eval.spell.ot_min_noncrit_if_hit1,
                            eval.spell.ot_dur1,
                            ((2 / 3) * dmg_wo_sp + dmg_from_sp) / eval.spell.ot_ticks1,
                            eval.spell.ot_min_noncrit_if_hit1 / eval.spell.ot_ticks1,
                            ((4 / 3) * dmg_wo_sp + dmg_from_sp) / eval.spell.ot_ticks1,
                            eval.spell.ot_tick_time1,
                            eval.spell.ot_ticks1),
                        effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                elseif eval.spell.ot_min_noncrit_if_hit1 ~=  eval.spell.ot_max_noncrit_if_hit1 then
                    tooltip:AddLine(string.format("%s%s: %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                            effect,
                            hit_str,
                            math.floor(eval.spell.ot_min_noncrit_if_hit1),
                            math.ceil(eval.spell.ot_max_noncrit_if_hit1),
                            eval.spell.ot_dur1,
                            math.floor(eval.spell.ot_min_noncrit_if_hit1 / eval.spell.ot_ticks1),
                            math.ceil(eval.spell.ot_max_noncrit_if_hit1 / eval.spell.ot_ticks1),
                            eval.spell.ot_tick_time1,
                            eval.spell.ot_ticks1),
                        effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                else
                    tooltip:AddLine(string.format("%s%s: %.1f over %.1fs (%.1f every %.1fs x %d)",
                            effect,
                            hit_str,
                            eval.spell.ot_min_noncrit_if_hit1,
                            eval.spell.ot_dur1,
                            eval.spell.ot_min_noncrit_if_hit1 / eval.spell.ot_ticks1,
                            eval.spell.ot_tick_time1,
                            eval.spell.ot_ticks1),
                        effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                end
            else
                -- wild growth
                if spell.base_id == spids.wild_growth then
                    --local heal_from_sp = stats.ot_coef * stats.spell_ot_mod * stats.spell_power * eval.spell.ot_ticks;
                    --local heal_wo_sp = (eval.spell.ot_min_noncrit_if_hit1 - heal_from_sp);
                    local heal_from_sp = eval.spell.ot_min_noncrit_if_hit1 - eval.spell.ot_min_noncrit_if_hit_base1;
                    local heal_wo_sp = eval.spell.ot_min_noncrit_if_hit_base1;
                    tooltip:AddLine(
                        string.format("%s: %.1f over %ds (%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f every %.1fs x %d)",
                            effect,
                            eval.spell.ot_min_noncrit_if_hit1,
                            eval.spell.ot_dur1,
                            ((3 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / eval.spell.ot_ticks1,
                            ((2 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / eval.spell.ot_ticks1,
                            ((1 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / eval.spell.ot_ticks1,
                            ((0 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / eval.spell.ot_ticks1,
                            ((-1 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / eval.spell.ot_ticks1,
                            ((-2 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / eval.spell.ot_ticks1,
                            ((-3 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / eval.spell.ot_ticks1,
                            eval.spell.ot_tick_time1,
                            eval.spell.ot_ticks1),
                        effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                elseif eval.spell.ot_min_noncrit_if_hit1 ~= eval.spell.ot_max_noncrit_if_hit1 then
                    tooltip:AddLine(string.format("%s: %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                            effect,
                            math.floor(eval.spell.ot_min_noncrit_if_hit1),
                            math.ceil(eval.spell.ot_max_noncrit_if_hit1),
                            eval.spell.ot_dur1,
                            math.floor(eval.spell.ot_min_noncrit_if_hit1 / eval.spell.ot_ticks1),
                            math.ceil(eval.spell.ot_max_noncrit_if_hit1 / eval.spell.ot_ticks1),
                            eval.spell.ot_tick_time1,
                            eval.spell.ot_ticks1),
                        effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                else
                    tooltip:AddLine(string.format("%s: %.1f over %.1fs (%.1f every %.1fs x %d)",
                            effect,
                            eval.spell.ot_min_noncrit_if_hit1,
                            eval.spell.ot_dur1,
                            eval.spell.ot_max_noncrit_if_hit1 / eval.spell.ot_ticks1,
                            eval.spell.ot_tick_time1,
                            eval.spell.ot_ticks1),
                        effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                end
            end
        end
        for i = 2, eval.spell.num_periodic_effects do
            if eval.spell["ot_min_noncrit_if_hit" .. i] ~= 0.0 then
                if eval.spell["ot_min_noncrit_if_hit" .. i] ~= eval.spell["ot_max_noncrit_if_hit" .. i] then
                    tooltip:AddLine(string.format("%s: %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                            eval.spell["ot_description" .. i],
                            math.floor(eval.spell["ot_min_noncrit_if_hit" .. i]),
                            math.ceil(eval.spell["ot_max_noncrit_if_hit" .. i]),
                            eval.spell["ot_dur" .. i],
                            math.floor(eval.spell["ot_min_noncrit_if_hit" .. i] / eval.spell["ot_ticks" .. i]),
                            math.ceil(eval.spell["ot_max_noncrit_if_hit" .. i] / eval.spell["ot_ticks" .. i]),
                            eval.spell["ot_tick_time" .. i],
                            eval.spell["ot_ticks" .. i]),
                        effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                else
                    tooltip:AddLine(string.format("%s (%.2f%%): %.1f over %.1fs (%.1f every %.1fs x %d)",
                            eval.spell["ot_description" .. i],
                            stats.crit * 100,
                            eval.spell["ot_min_noncrit_if_hit" .. i],
                            eval.spell["ot_dur" .. i],
                            eval.spell["ot_min_noncrit_if_hit" .. i] / eval.spell["ot_ticks" .. i],
                            eval.spell["ot_tick_time" .. i],
                            eval.spell["ot_ticks" .. i]),
                        effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
                end
            end
        end

        local crit_mod_ot = stats.crit_mod_ot;
        if stats.special_crit_mod_tracked ~= 0 then
            crit_mod_ot = crit_mod_ot * (1.0 + stats["extra_effect_val" .. stats.special_crit_mod_tracked]);
        end
        -- TODO: not isolating periodoic??
        local crit_chance_info_str =  string.format(" (%.2f%%||%.2fx)",
                                               stats.crit_ot * 100,
                                               crit_mod_ot);

        if config.settings.tooltip_display_crit_chance  and stats.crit_ot ~= 0.0 and eval.spell.ot_min_crit_if_hit1 ~= 0 then

            tooltip:AddLine(string.format("Critical chance: %.2f%% | Modifier: %.2fx", stats.crit*100, crit_mod_ot),
                effect_colors.crit[1], effect_colors.crit[2], effect_colors.crit[3]);
            crit_chance_info_str = "";
        end
        if config.settings.tooltip_display_crit and not config.settings.tooltip_display_crit_combined then
            crit_chance_info_str = "";
        end

        if eval.spell.num_periodic_effects > 0 and (config.settings.tooltip_display_crit_combined or config.settings.tooltip_display_crit) then
            if stats.crit_ot ~= 0.0 and spell.periodic then

                if eval.spell.ot_min_crit_if_hit1 ~= eval.spell.ot_max_crit_if_hit1 then
                    tooltip:AddLine(string.format("Critical%s: %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                            crit_chance_info_str,
                            math.floor(eval.spell.ot_min_crit_if_hit1),
                            math.ceil(eval.spell.ot_max_crit_if_hit1),
                            eval.spell.ot_dur1,
                            math.floor(eval.spell.ot_min_crit_if_hit1 / eval.spell.ot_ticks1),
                            math.ceil(eval.spell.ot_max_crit_if_hit1 / eval.spell.ot_ticks1),
                            eval.spell.ot_tick_time1,
                            eval.spell.ot_ticks1),
                        effect_colors.crit[1], effect_colors.crit[2], effect_colors.crit[3]);
                else
                    tooltip:AddLine(string.format("Critical%s: %.1f over %.1fs (%.1f every %.1fs x %d)",
                            crit_chance_info_str,
                            eval.spell.ot_min_crit_if_hit1,
                            eval.spell.ot_dur1,
                            eval.spell.ot_min_crit_if_hit1 / eval.spell.ot_ticks1,
                            eval.spell.ot_tick_time1,
                            eval.spell.ot_ticks1),
                        effect_colors.crit[1], effect_colors.crit[2], effect_colors.crit[3]);
                end
            end

            for i = 2, eval.spell.num_periodic_effects do
                if eval.spell["crit_ot" .. i] ~= 0.0 then
                    if eval.spell["ot_min_crit_if_hit" .. i] ~= eval.spell["ot_max_crit_if_hit" .. i] then
                        tooltip:AddLine(string.format("%s (%.2f%%): %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                                eval.spell["ot_description" .. i],
                                stats.crit * 100,
                                math.floor(eval.spell["ot_min_crit_if_hit" .. i]),
                                math.ceil(eval.spell["ot_max_crit_if_hit" .. i]),
                                eval.spell["ot_dur" .. i],
                                math.floor(eval.spell["ot_min_crit_if_hit" .. i] / eval.spell["ot_ticks" .. i]),
                                math.ceil(eval.spell["ot_max_crit_if_hit" .. i] / eval.spell["ot_ticks" .. i]),
                                eval.spell["ot_tick_time" .. i],
                                eval.spell["ot_ticks" .. i]),
                            effect_colors.crit[1], effect_colors.crit[2], effect_colors.crit[3]);
                    else
                        tooltip:AddLine(string.format("%s (%.2f%%): %.1f over %.1fs (%.1f every %.1fs x %d)",
                                eval.spell["ot_description" .. i],
                                stats.crit * 100,
                                eval.spell["ot_min_crit_if_hit" .. i],
                                eval.spell["ot_dur" .. i],
                                eval.spell["ot_min_crit_if_hit" .. i] / eval.spell["ot_ticks" .. i],
                                eval.spell["ot_tick_time" .. i],
                                eval.spell["ot_ticks" .. i]),
                            effect_colors.crit[1], effect_colors.crit[2], effect_colors.crit[3]);
                    end
                end
            end
        end
    end

    if config.settings.tooltip_display_expected then
        local extra_info_st = "";
        local extra_info_multi = "";

        if eval.spell.expectation_direct ~= 0 and eval.spell.expected_ot ~= 0 then
            local direct_ratio = eval.spell.expectation_direct / (eval.spell.expectation_direct + eval.spell.expected_ot);
            extra_info_multi = extra_info_multi ..
                string.format("%.1f%% direct | %.1f%% periodic", direct_ratio * 100, (1.0 - direct_ratio) * 100);

            local direct_ratio = eval.spell.expectation_direct_st /
                (eval.spell.expectation_direct_st + eval.spell.expected_ot_st);
            extra_info_st = extra_info_st ..
                string.format("%.1f%% direct | %.1f%% periodic", direct_ratio * 100, (1.0 - direct_ratio) * 100);
        end
        if spell.base_id == spids.shadow_bolt and loadout.talents_table:pts(3, 1) ~= 0 then
            local isb_uptime = 1.0 - math.pow(1.0 - stats.crit, 4);

            extra_info_st = extra_info_st .. string.format("ISB debuff uptime %.1f%%", 100 * isb_uptime);
            extra_info_multi = extra_info_multi .. string.format("ISB debuff uptime %.1f%%", 100 * isb_uptime);
        end


        if eval.spell.expectation ~= eval.spell.expectation_st then
            if extra_info_st == "" then
                extra_info_st = "(1.00x effect)";
            else
                extra_info_st = "(" .. extra_info_st .. " | 1.00x effect)";
            end
            local aoe_ratio = string.format("%.2fx effect", eval.spell.expectation / eval.spell.expectation_st);
            if extra_info_multi == "" then
                extra_info_multi = "(" .. aoe_ratio .. ")";
            else
                extra_info_multi = "(" .. extra_info_multi .. " | " .. aoe_ratio .. ")";
            end
            tooltip:AddLine(string.format("Expected: %.1f %s", eval.spell.expectation_st, extra_info_st),
                effect_colors.expectation[1], effect_colors.expectation[2], effect_colors.expectation[3]);
            tooltip:AddLine(string.format("Optimistic: %.1f %s", eval.spell.expectation, extra_info_multi),
                effect_colors.expectation[1], effect_colors.expectation[2], effect_colors.expectation[3]);
        else
            if extra_info_st ~= "" then
                extra_info_st = "(" .. extra_info_st .. ")";
            end
            if extra_info_multi ~= "" then
                extra_info_multi = "(" .. extra_info_multi .. ")";
            end
            tooltip:AddLine("Expected" .. string.format(": %.1f %s", eval.spell.expectation, extra_info_st),
                effect_colors.expectation[1], effect_colors.expectation[2], effect_colors.expectation[3]);
        end
    end

    if config.settings.tooltip_display_effect_per_sec then
        local periodic_part = "";
        if eval.spell.num_periodic_effects > 0 and eval.spell.effect_per_dur ~= 0 and eval.spell.effect_per_dur ~= eval.spell.effect_per_sec then
            periodic_part = string.format("| %.1f periodic for %d sec", eval.spell.effect_per_dur,
                eval.spell.longest_ot_duration);
        end

        tooltip:AddLine(string.format("%s: %.1f by execution time %s",
                effect_per_sec,
                eval.spell.effect_per_sec, periodic_part),
            effect_colors.effect_per_sec[1], effect_colors.effect_per_sec[2], effect_colors.effect_per_sec[3]);
    end
    if config.settings.tooltip_display_avg_cast and not repeated_tooltip_on then
        local tooltip_cast = spell_cast_time(spell_id);
        --if bit.band(spell_flags.instant, spell.flags) == 0 and (not tooltip_cast or tooltip_cast ~= stats.cast_time_nogcd) then
        --    if stats.cast_time_nogcd ~= stats.cast_time then
        --        tooltip:AddLine(
        --            string.format("Expected execution time: %.1f sec (%.3f but gcd capped)", stats.gcd, stats.cast_time_nogcd),
        --            effect_colors.avg_cast[1], effect_colors.avg_cast[2], effect_colors.avg_cast[3]);
        --    else
        --        tooltip:AddLine(string.format("Expected execution time: %.3f sec", stats.cast_time),
        --            effect_colors.avg_cast[1], effect_colors.avg_cast[2], effect_colors.avg_cast[3]);
        --    end
        --end

        -- for debugging new stuff always show this
        tooltip:AddLine(string.format("Expected execution time: %.3f sec", stats.cast_time),
            effect_colors.avg_cast[1], effect_colors.avg_cast[2], effect_colors.avg_cast[3]);
    end
    local tooltip_cost = spell_cost(spell_id);
    if config.settings.tooltip_display_avg_cost then
        --if not tooltip_cost or tooltip_cost ~= stats.cost or repeated_tooltip_on then
        --    if loadout.lvl ~= UnitLevel("player") and bit.band(spell.flags, spell_flags.base_mana_cost) ~= 0 then
        --        tooltip:AddLine(
        --            string.format("NOTE: Mana cost at custom lvl may be inaccurate; roughly estimated", stats.cost), 1.0,
        --            0.0,
        --            0.0);
        --    end
        --    tooltip:AddLine(string.format("Expected cost: %.1f", stats.cost),
        --        effect_colors.avg_cost[1], effect_colors.avg_cost[2], effect_colors.avg_cost[3]);
        --end

        -- for debugging new stuff always show this
        tooltip:AddLine(string.format("Expected cost: %.1f", stats.cost),
            effect_colors.avg_cost[1], effect_colors.avg_cost[2], effect_colors.avg_cost[3]);
    end
    if config.settings.tooltip_display_effect_per_cost then
        tooltip:AddLine(effect_per_cost .. ": " .. string.format("%.2f", eval.spell.effect_per_cost),
            effect_colors.effect_per_cost[1], effect_colors.effect_per_cost[2], effect_colors.effect_per_cost[3]);
    end
    if config.settings.tooltip_display_effect_per_cast then
        if not tooltip_cost or tooltip_cost ~= stats.cost or not repeated_tooltip_on then
            tooltip:AddLine(
                cost_per_sec .. ": " .. string.format("- %.1f out | + %.1f in", eval.spell.cost_per_sec, eval.spell.mp1),
                effect_colors.cost_per_sec[1], effect_colors.cost_per_sec[2], effect_colors.cost_per_sec[3]);
        end
    end

    if config.settings.tooltip_display_cast_until_oom then
        tooltip:AddLine(
            string.format("%s until OOM: %.1f (%.1f casts, %.1f sec)", effect, eval.spell.effect_until_oom,
                eval.spell.num_casts_until_oom, eval.spell.time_until_oom),
            effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
        if loadout.mana ~= eval.spell.mana then
            tooltip:AddLine(string.format("                                   casting from %d %s", eval.spell.mana, cost_str),
                effect_colors.normal[1], effect_colors.normal[2], effect_colors.normal[3]);
        end
    end
    if config.settings.tooltip_display_sp_effect_calc then
        if spell.direct and stats.coef > 0 and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_periodic) == 0 then
            tooltip:AddLine(string.format("Direct:    %.3f coef * %.3f mod * %d SP = %.1f",
                    stats.coef,
                    stats.spell_mod,
                    stats.spell_power,
                    stats.coef * stats.spell_mod * stats.spell_power
                ),
                effect_colors.sp_effect[1], effect_colors.sp_effect[2], effect_colors.sp_effect[3]);
        end
        if spell.periodic and stats.ot_coef > 0 and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_direct) == 0 then
            tooltip:AddLine(string.format("Periodic: %d ticks * %.3f coef * %.3f mod * %d SP",
                    eval.spell.ot_ticks1,
                    stats.ot_coef,
                    stats.spell_ot_mod,
                    stats.spell_power_ot
                ),
                effect_colors.sp_effect[1], effect_colors.sp_effect[2], effect_colors.sp_effect[3]);
            tooltip:AddLine(string.format("            = %d ticks * %.1f = %.1f",
                    eval.spell.ot_ticks1,
                    stats.ot_coef * stats.spell_ot_mod * stats.spell_power_ot,
                    stats.ot_coef * stats.spell_ot_mod * stats.spell_power_ot * eval.spell.ot_ticks1),
                effect_colors.sp_effect[1], effect_colors.sp_effect[2], effect_colors.sp_effect[3]);
        end
    end
    if config.settings.tooltip_display_sp_effect_ratio and
        ((spell.direct and stats.coef > 0) or (spell.periodic and stats.ot_coef > 0)) then
        local effect_base = 0;
        local effect_total = 0;
        if spell.direct then
            effect_base = effect_base + 0.5*(eval.spell.min_noncrit_if_hit_base1 + eval.spell.max_noncrit_if_hit_base1);
            effect_total = effect_total + 0.5*(eval.spell.min_noncrit_if_hit1 + eval.spell.max_noncrit_if_hit1);
        end
        if spell.periodic then
            effect_base = effect_base + 0.5*(eval.spell.ot_min_noncrit_if_hit_base1 + eval.spell.ot_max_noncrit_if_hit_base1);
            effect_total = effect_total + 0.5*(eval.spell.ot_min_noncrit_if_hit1 + eval.spell.ot_max_noncrit_if_hit1);
        end
        local effect_sp = effect_total - effect_base;

        tooltip:AddLine(string.format("SP=%d improves base by %.1f%%. Total: %.1f%% base, %.1f%% SP",
                stats.spell_power,
                100*effect_sp/effect_base,
                100*effect_base/(effect_base + effect_sp),
                100*effect_sp/(effect_base + effect_sp)
            ),
            effect_colors.sp_effect[1], effect_colors.sp_effect[2], effect_colors.sp_effect[3]);
    end

    if bit.band(spell.flags, spell_flags.resource_regen) == 0 then
        if config.settings.tooltip_display_stat_weights_dps and eval.infinite_cast.effect_per_sec_per_sp > 0 then
            tooltip:AddLine(
                effect_per_sec_per_sp ..
                ": " .. string.format("%.3f, weighing", eval.infinite_cast.effect_per_sec_per_sp),
                effect_colors.stat_weights[1], effect_colors.stat_weights[2], effect_colors.stat_weights[3]);
            local stat_weights = {};
            stat_weights[1] = { weight = 1.0, str = "SP" };
            stat_weights[2] = { weight = eval.infinite_cast.sp_per_crit, str = "Crit" };
            local num_weights = 2;
            --if eval.sp_per_int ~= 0 then
            num_weights = num_weights + 1;
            stat_weights[num_weights] = { weight = eval.infinite_cast.sp_per_int, str = "Int" };
            --end
            --if eval.sp_per_spirit ~= 0 then
            num_weights = num_weights + 1;
            stat_weights[num_weights] = { weight = eval.infinite_cast.sp_per_spirit, str = "Spirit" };
            --end

            if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                num_weights = num_weights + 1;
                stat_weights[num_weights] = { weight = eval.infinite_cast.sp_per_hit, str = "Hit" };
                num_weights = num_weights + 1;
                stat_weights[num_weights] = { weight = eval.infinite_cast.sp_per_pen, str = "Spell Pen" };
                --    tooltip:AddLine(sp_name.." per Hit rating: "..string.format("%.3f",eval.sp_per_hit), 0.0, 1.0, 0.0);
                --tooltip:AddLine(string.format("1 SP = %.3f Critical = %.3f Haste = %.3f Hit",eval.sp_per_crit, eval.sp_per_haste, eval.sp_per_hit), 0.0, 1.0, 0.0);
            else
                --tooltip:AddLine(string.format("1 SP = %.3f Critical = %.3f Haste",eval.sp_per_crit, eval.sp_per_haste), 0.0, 1.0, 0.0);
            end
            local stat_weights_str = "|";
            local max_weights_per_line = 4;
            sort_stat_weights(stat_weights, num_weights);
            for i = 1, num_weights do
                if stat_weights[i].weight ~= 0 then
                    stat_weights_str = stat_weights_str ..
                        string.format(" %.3f %s |", stat_weights[i].weight, stat_weights[i].str);
                else
                    stat_weights_str = stat_weights_str .. string.format(" %d %s |", 0, stat_weights[i].str);
                end
                if i == max_weights_per_line and i ~= num_weights then
                    stat_weights_str = stat_weights_str .. "\n|";
                end
            end
            tooltip:AddLine(stat_weights_str,
                effect_colors.stat_weights[1], effect_colors.stat_weights[2], effect_colors.stat_weights[3]);
        end

        if config.settings.tooltip_display_stat_weights_doom and eval.spell.cost_per_sec > 0 and
            eval.cast_until_oom.effect_until_oom_per_sp > 0 then

            tooltip:AddLine(
                string.format("%s until OOM per SP: %.3f, weighing", effect,
                    eval.cast_until_oom.effect_until_oom_per_sp),
                effect_colors.stat_weights[1], effect_colors.stat_weights[2], effect_colors.stat_weights[3]);
            local stat_weights = {};
            stat_weights[1] = { weight = 1.0, str = "SP" };
            stat_weights[2] = { weight = eval.cast_until_oom.sp_per_crit, str = "Crit" };
            stat_weights[3] = { weight = eval.cast_until_oom.sp_per_int, str = "Int" };
            stat_weights[4] = { weight = eval.cast_until_oom.sp_per_spirit, str = "Spirit" };
            stat_weights[5] = { weight = eval.cast_until_oom.sp_per_mp5, str = "MP5" };
            local num_weights = 5;

            if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                num_weights = 7;
                stat_weights[6] = { weight = eval.cast_until_oom.sp_per_hit, str = "Hit" };
                stat_weights[7] = { weight = eval.cast_until_oom.sp_per_pen, str = "Spell Pen" };
            end

            local stat_weights_str = "|";
            local max_weights_per_line = 4;
            sort_stat_weights(stat_weights, num_weights);
            for i = 1, num_weights do
                if stat_weights[i].weight ~= 0 then
                    stat_weights_str = stat_weights_str ..
                        string.format(" %.3f %s |", stat_weights[i].weight, stat_weights[i].str);
                else
                    stat_weights_str = stat_weights_str .. string.format(" %d %s |", 0, stat_weights[i].str);
                end
                if i == max_weights_per_line then
                    stat_weights_str = stat_weights_str .. "\n|";
                end
            end
            tooltip:AddLine(stat_weights_str,
                effect_colors.stat_weights[1], effect_colors.stat_weights[2], effect_colors.stat_weights[3]);
        end
    end
    if config.settings.tooltip_display_dynamic_tip then
        local evaluation_options = "";
        if eval.spell.expectation_direct ~= 0 and eval.spell.expected_ot ~= 0 then
            evaluation_options = "CTRL facing north=periodic, south=direct";
        end

        if eval.spell.expectation ~= eval.spell.expectation_st then
            if evaluation_options == "" then
                evaluation_options = "ALT for 1.00x effect";
            else
                evaluation_options = evaluation_options .. " | ALT for 1.00x";
            end
        end


        if evaluation_options ~= "" then
            tooltip:AddLine("To isolate: Hold " .. evaluation_options, 1.0, 1.0, 1.0);
        end
        if bit.band(spell.flags, spell_flags.weapon_enchant) ~= 0 and bit.band(eval_flags, swc.calc.evaluation_flags.offhand) == 0 then
            tooltip:AddLine("Hold ALT key to show for offhand", 1.0, 1.0, 1.0);
        end
    end

    end_tooltip_section(tooltip);

    if spell.healing_version then
        -- used for holy nova
        tooltip_spell_info(tooltip, spell.healing_version, loadout, effects, true, spell_id);
    end
end

swc.tooltip.tooltip_spell_info = tooltip_spell_info;
