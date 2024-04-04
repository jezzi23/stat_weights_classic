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

local spells                                    = swc.abilities.spells;
local spell_flags                               = swc.abilities.spell_flags;
local spell_name_to_id                          = swc.abilities.spell_name_to_id;
local next_spell_rank                           = swc.abilities.next_spell_rank;
local best_rank_by_lvl                          = swc.abilities.best_rank_by_lvl;

local loadout_flags                             = swc.utils.loadout_flags;
local class                                     = swc.utils.class;
local spell_cost                                = swc.utils.spell_cost;
local spell_cast_time                           = swc.utils.spell_cast_time;

local set_tiers                                 = swc.equipment.set_tiers;


local stats_for_spell                           = swc.calc.stats_for_spell;
local evaluate_spell                            = swc.calc.evaluate_spell;

local sort_stat_weights                         = swc.tooltip.sort_stat_weights        
local begin_tooltip_section                     = swc.tooltip.begin_tooltip_section    
local end_tooltip_section                       = swc.tooltip.end_tooltip_section      

-------------------------------------------------------------------------------

local stats = {};

local function tooltip_spell_info(tooltip, spell, loadout, effects, repeated_tooltip_on, spell_id)

    -- Set gray spell rank in upper-right corner again after custom SetSpellByID clears it
    if bit.band(spell.flags, spell_flags.sod_rune) == 0 then
        local txt_right = getglobal("GameTooltipTextRight1");
        if txt_right then
            txt_right:SetTextColor(0.50196081399918, 0.50196081399918, 0.50196081399918, 1.0);
            txt_right:SetText("Rank "..spell.rank);
            txt_right:Show();
        end
    end

    if sw_frame.settings_frame.tooltip_num_checked == 0 or 
        (sw_frame.settings_frame.show_tooltip_only_when_shift and not IsShiftKeyDown()) then
        return;
    end

    local eval_flags = 0;
    if IsAltKeyDown() then
        eval_flags = bit.bor(eval_flags, swc.calc.evaluation_flags.assume_single_effect);
        eval_flags = bit.bor(eval_flags, swc.calc.evaluation_flags.offhand);
    end
    
    if IsControlKeyDown() then
        
        if math.abs(GetPlayerFacing()-math.pi)>0.5*math.pi then
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
    local effect_per_sec_per_sp = "";
    local sp_name = "";

    if bit.band(spell.flags, spell_flags.heal) ~= 0 or bit.band(spell.flags, spell_flags.absorb) ~= 0 then
        effect = "Heal";
        effect_per_sec = "HPS";
        effect_per_cost = "Heal per Mana";
        cost_per_sec = "Mana per sec";
        effect_per_sec_per_sp = "Repeated casts HPS per SP";
        sp_name = "Spell power";
    else
        effect = "Damage";
        effect_per_sec = "DPS";
        effect_per_cost = "Damage per Mana";
        cost_per_sec = "Mana per sec";
        effect_per_sec_per_sp = "Repeated casts DPS per SP";
        sp_name = "Spell power";
    end

    begin_tooltip_section(tooltip, spell, spell_id);

    local clvl_specified = "";

    if sw_frame.settings_frame.tooltip_loadout_info:GetChecked() then
        if bit.band(loadout.flags, loadout_flags.custom_lvl) ~= 0 then
            clvl_specified = string.format(" (clvl: %d)", loadout.lvl);
        end
        if bit.band(spell.flags, bit.bor(spell_flags.absorb, spell_flags.heal, spell_flags.mana_regen)) ~= 0 then
            tooltip:AddLine(string.format("%s%s | Target: %.0f%% HP",
                                          loadout.name, clvl_specified, loadout.friendly_hp_perc * 100
                                          ),
                            138/256, 134/256, 125/256);
        else
            tooltip:AddLine(string.format("%s%s | Target: %dx | LVL %d | %.0f%% HP | %d RES",
                                          loadout.name, clvl_specified, loadout.unbounded_aoe_targets, loadout.target_lvl,
                                          loadout.enemy_hp_perc * 100, stats.target_resi
                                          ),
                            138/256, 134/256, 125/256);
        end
    end
    if sw_frame.settings_frame.tooltip_spell_rank:GetChecked() and not repeated_tooltip_on then

        local next_rank_str = "";
        local best_rank, highest_rank = best_rank_by_lvl(spell.base_id, loadout.lvl);
        local next_rank = next_spell_rank(spell);
        if next_rank and best_rank and spells[best_rank].rank + 1 == spells[next_rank].rank then
            next_rank_str = next_rank_str.."(highest yet; next rank at lvl "..spells[next_rank].lvl_req..")";
        elseif best_rank and spells[best_rank].rank == spell.rank then
            next_rank_str = "(highest available)";
        elseif best_rank and spells[best_rank].rank > spell.rank then
            next_rank_str = "(downranked)";
        else 
            next_rank_str = "(unavailable)";
        end

        tooltip:AddLine(string.format("Spell Rank: %d %s", spell.rank, next_rank_str),
                        138/256, 134/256, 125/256);
    end

    if bit.band(loadout.flags, loadout_flags.is_dynamic_loadout) == 0 or
        bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0 or 
        bit.band(loadout.flags, loadout_flags.custom_lvl) ~= 0 then
        tooltip:AddLine("WARNING: using custom talents, runes, lvl or buffs!", 1, 0, 0);
    end

    if bit.band(spell.flags, spell_flags.mana_regen) ~= 0 then
        tooltip:AddLine(string.format("Restores %d mana over %.1f sec for yourself.",
                                      math.ceil(eval.spell.mana_restored),
                                      math.max(stats.cast_time, spell.over_time_duration)
                                      ),
                        0, 1, 1);
        if spell.over_time_tick_freq > 1 then
            tooltip:AddLine(string.format("Mana per tick: %.1f",
                                          spell.over_time_tick_freq*math.ceil(eval.spell.mana_restored)/
                                          math.max(stats.cast_time, spell.over_time_duration)
                                          ),
                            0, 1, 1);
        end
        tooltip:AddLine(string.format("Mana per sec: %.1f",
                                      eval.spell.mana_restored/math.max(stats.cast_time, spell.over_time_duration)
                                      ),
                        0, 1, 1);

        end_tooltip_section(tooltip);
        return;
    end

    local hit_str = string.format("(%.1f%% hit)", stats.hit*100);
    if stats.target_avg_resi > 0 then
        hit_str = string.format("(%.1f%%hit||%.1f%%resist)", stats.hit*100, stats.target_avg_resi*100);
    end

    if sw_frame.settings_frame.tooltip_normal_effect:GetChecked() and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_periodic) == 0 then
        if eval.spell.min_noncrit_if_hit + eval.spell.absorb ~= 0 then
            if eval.spell.min_noncrit_if_hit ~= eval.spell.max_noncrit_if_hit then
                -- dmg spells with real direct range
                if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                    
                    tooltip:AddLine(string.format("%s %s: %d-%d",
                                                   effect,
                                                   hit_str,
                                                   math.floor(eval.spell.min_noncrit_if_hit),
                                                   math.ceil(eval.spell.max_noncrit_if_hit)),
                                     232.0/255, 225.0/255, 32.0/255);
                    if spell.base_id == spell_name_to_id["Chain Lightning"] and bit.band(eval_flags, swc.calc.evaluation_flags.assume_single_effect) == 0 then
                        local bounce_str = "     + ";
                        local bounces = 2;
                        local falloff = 0.7;
                        if loadout.num_set_pieces[set_tiers.pve_2_5_1] >= 3 then
                            falloff = 0.75;
                        end
                        for i = 1, bounces-1 do
                            bounce_str = bounce_str..string.format(" %d-%d  + ",
                                                                   falloff*math.floor(eval.spell.min_noncrit_if_hit), 
                                                                   falloff*math.ceil(eval.spell.max_noncrit_if_hit));

                            falloff = falloff * falloff;
                        end
                        bounce_str = bounce_str..string.format(" %d-%d",
                                                               falloff*math.floor(eval.spell.min_noncrit_if_hit), 
                                                               falloff*math.ceil(eval.spell.max_noncrit_if_hit));
                        tooltip:AddLine(bounce_str, 232.0/255, 225.0/255, 32.0/255);
                    end
                    
                -- heal spells with real direct range
                else
                    tooltip:AddLine(string.format("%s: %d-%d", 
                                                  effect, 
                                                  math.floor(eval.spell.min_noncrit_if_hit), 
                                                  math.ceil(eval.spell.max_noncrit_if_hit)),
                                    232.0/255, 225.0/255, 32.0/255);

                    if spell.base_id == spell_name_to_id["Chain Heal"] and bit.band(eval_flags, swc.calc.evaluation_flags.assume_single_effect) == 0 then
                        local bounce_str = "     + ";
                        local bounces = 2;
                        local falloff = 0.5;
                        if loadout.num_set_pieces[set_tiers.pve_2] >= 3 then
                            falloff = 0.5 * 1.3;
                        end

                        for i = 1, bounces-1 do
                            bounce_str = bounce_str..string.format(" %d-%d  + ",
                                                                   falloff*math.floor(eval.spell.min_noncrit_if_hit), 
                                                                   falloff*math.ceil(eval.spell.max_noncrit_if_hit));

                            falloff = falloff * falloff;
                        end
                        bounce_str = bounce_str..string.format(" %d-%d",
                                                               falloff*math.floor(eval.spell.min_noncrit_if_hit), 
                                                               falloff*math.ceil(eval.spell.max_noncrit_if_hit));
                        tooltip:AddLine(bounce_str, 232.0/255, 225.0/255, 32.0/255);
                    end
                end

            else
                if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                    tooltip:AddLine(string.format("%s %s: %.1f", 
                                                  effect,
                                                  hit_str,
                                                  eval.spell.min_noncrit_if_hit),
                                                  --string.format("%.0f", eval.spell.min_noncrit_if_hit)),
                                    232.0/255, 225.0/255, 32.0/255);
                else
                    if eval.spell.absorb ~= 0 then
                        tooltip:AddLine(string.format("Absorb: %.1f", 
                                                      eval.spell.absorb),
                                        232.0/255, 225.0/255, 32.0/255);
                    end
                    if eval.spell.min_noncrit_if_hit ~= 0 then
                        tooltip:AddLine(string.format("%s: %.1f", 
                                                      effect,
                                                      eval.spell.min_noncrit_if_hit),
                                        232.0/255, 225.0/255, 32.0/255);
                    end
                end

            end
        end

        for i = 1, eval.spell.num_extra_direct_effects do
            if eval.spell["min_noncrit_if_hit"..i] ~= eval.spell["max_noncrit_if_hit"..i] then
                tooltip:AddLine(string.format("%s: %d-%d",
                                              eval.spell["direct_description"..i],
                                              math.floor(eval.spell["min_noncrit_if_hit"..i]), 
                                              math.ceil(eval.spell["max_noncrit_if_hit"..i])),
                                232.0/255, 225.0/255, 32.0/255);
            elseif eval.spell["min_noncrit_if_hit"..i] ~= 0 then
                tooltip:AddLine(string.format("%s: %.1f",
                                              eval.spell["direct_description"..i],
                                              eval.spell["min_noncrit_if_hit"..i]),
                                232.0/255, 225.0/255, 32.0/255);
            end
        end
    end
    if sw_frame.settings_frame.tooltip_crit_effect:GetChecked() and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_periodic) == 0 then
        if stats.crit ~= 0 and eval.spell.min_crit_if_hit + eval.spell.absorb ~= 0 and stats.crit ~= 0 then
            local effect_type_str = nil;
            local extra_crit_mod = 0;
            if stats.extra_crit_mod_mul or (stats.crit_into_periodic and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_direct) == 0) then

                if class == "MAGE" then
                    effect_type_str = "ignite"
                elseif class == "DRUID" then
                    effect_type_str = "seeds";
                elseif class == "PALADIN" then
                    effect_type_str = "sheath";
                elseif class == "PRIEST" then
                    effect_type_str = "absorbs";
                elseif class == "SHAMAN" then
                    effect_type_str = "awakens";
                end
            end
            if effect_type_str and eval.spell.min_crit_if_hit ~= 0 then
                local crit_mod = stats.crit_mod;
                if stats.crit_into_periodic then
                    crit_mod = crit_mod * (1.0 + stats.crit_into_periodic);
                end
                if stats.extra_crit_mod_mul then
                    extra_crit_mod = stats.extra_crit_mod_mul;
                end
                local min_crit_if_hit = eval.spell.min_crit_if_hit/(1 + extra_crit_mod);
                local max_crit_if_hit = eval.spell.max_crit_if_hit/(1 + extra_crit_mod);
                local effect_min = extra_crit_mod * min_crit_if_hit;
                local effect_max = extra_crit_mod * max_crit_if_hit;
                if eval.spell.min_crit_if_hit ~= eval.spell.max_crit_if_hit then
                    if not stats.crit_into_periodic then
                        effect_type_str = effect_type_str..string.format(" %d-%d", math.floor(effect_min), math.ceil(effect_max));
                    end
                    tooltip:AddLine(string.format("Critical (%.2f%%||%.2fx): %d-%d + %s", 
                                                  stats.crit*100, 
                                                  crit_mod,
                                                  math.floor(min_crit_if_hit), 
                                                  math.ceil(max_crit_if_hit),
                                                  effect_type_str),
                                   252.0/255, 69.0/255, 3.0/255);
                elseif eval.spell.min_crit_if_hit ~= 0 then
                    if not stats.crit_into_periodic then
                        effect_type_str = effect_type_str..string.format(" %.1f", effect_min);
                    end

                    tooltip:AddLine(string.format("Critical (%.2f%%||%.2fx): %.1f + %s", 
                                                  stats.crit*100, 
                                                  crit_mod,
                                                  min_crit_if_hit, 
                                                  effect_type_str),
                                   252.0/255, 69.0/255, 3.0/255);

                end

            elseif eval.spell.min_crit_if_hit ~= eval.spell.max_crit_if_hit then

                tooltip:AddLine(string.format("Critical (%.2f%%||%.2fx): %d-%d", 
                                              stats.crit*100, 
                                              stats.crit_mod,
                                              math.floor(eval.spell.min_crit_if_hit), 
                                              math.ceil(eval.spell.max_crit_if_hit)),
                               252.0/255, 69.0/255, 3.0/255);

                if spell.base_id == spell_name_to_id["Chain Heal"] and bit.band(eval_flags, swc.calc.evaluation_flags.assume_single_effect) == 0 then
                    local bounce_str = "     + ";
                    local bounces = 2;
                    local falloff = 0.5;
                    if loadout.num_set_pieces[set_tiers.pve_2] >= 3 then
                        falloff = 1.3*0.5;
                    end
                    for i = 1, bounces-1 do
                        bounce_str = bounce_str..string.format(" %d-%d  + ",
                                                               falloff*math.floor(eval.spell.min_crit_if_hit), 
                                                               falloff*math.ceil(eval.spell.max_crit_if_hit));

                        falloff = falloff * falloff;
                    end
                    bounce_str = bounce_str..string.format(" %d-%d",
                                                           falloff*math.floor(eval.spell.min_crit_if_hit), 
                                                           falloff*math.ceil(eval.spell.max_crit_if_hit));
                    tooltip:AddLine(bounce_str, 252.0/255, 69.0/255, 3.0/255);

                elseif spell.base_id == spell_name_to_id["Chain Lightning"] and bit.band(eval_flags, swc.calc.evaluation_flags.assume_single_effect) == 0 then
                    local bounce_str = "     + ";
                    local bounces = 2;
                    local falloff = 0.7;
                    if loadout.num_set_pieces[set_tiers.pve_2_5_1] >= 3 then
                        falloff = 0.75;
                    end
                    for i = 1, bounces-1 do
                        bounce_str = bounce_str..string.format(" %d-%d  + ",
                                                               falloff*math.floor(eval.spell.min_crit_if_hit), 
                                                               falloff*math.ceil(eval.spell.max_crit_if_hit));

                        falloff = falloff * falloff;
                    end
                    bounce_str = bounce_str..string.format(" %d-%d",
                                                           falloff*math.floor(eval.spell.min_crit_if_hit), 
                                                           falloff*math.ceil(eval.spell.max_crit_if_hit));
                    tooltip:AddLine(bounce_str, 252.0/255, 69.0/255, 3.0/255);
                elseif spell.base_id == spell_name_to_id["Greater Heal"] and loadout.num_set_pieces[set_tiers.pve_3] >= 4 then
                    tooltip:AddLine("                         + 500 absorb",
                                    252.0/255, 69.0/255, 3.0/255);
                end
            elseif eval.spell.min_crit_if_hit ~= 0 then

                tooltip:AddLine(string.format("Critical (%.2f%%||%.2fx): %.1f", 
                                              stats.crit*100, 
                                              stats.crit_mod,
                                              eval.spell.min_crit_if_hit),
                               252.0/255, 69.0/255, 3.0/255);
            end
        end

        for i = 1, eval.spell.num_extra_direct_effects do
            if eval.spell["min_crit_if_hit"..i] ~= eval.spell["max_crit_if_hit"..i] then
                tooltip:AddLine(string.format("%s (%.2f%%): %d-%d",
                                              eval.spell["direct_description"..i],
                                              eval.spell["crit"..i]*100,
                                              math.floor(eval.spell["min_crit_if_hit"..i]),
                                              math.ceil(eval.spell["max_crit_if_hit"..i])),
                               252.0/255, 69.0/255, 3.0/255);
            else
                tooltip:AddLine(string.format("%s (%.2f%%): %.1f",
                                              eval.spell["direct_description"..i],
                                              eval.spell["crit"..i]*100,
                                              eval.spell["min_crit_if_hit"..i]),
                               252.0/255, 69.0/255, 3.0/255);
            end
        end
    end

    if sw_frame.settings_frame.tooltip_normal_ot:GetChecked() and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_direct) == 0 then

        if eval.spell.ot_if_hit ~= 0  then
            if stats.target_avg_resi_dot > 0 then 
                hit_str = string.format("(%.1f%%hit||%.1f%%resist)", stats.hit*100, stats.target_avg_resi_dot*100);
            end
            -- round over time num for niceyness
            local ot = tonumber(string.format("%.0f", eval.spell.ot_if_hit));

            if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                if spell.base_id == spell_name_to_id["Curse of Agony"] then
                    local dmg_from_sp = stats.ot_coef*stats.spell_ot_mod*stats.spell_power*eval.spell.ot_ticks;
                    local dmg_wo_sp = (eval.spell.ot_if_hit - dmg_from_sp);
                    tooltip:AddLine(string.format("%s %s: %.1f over %.1fs (%.1f-%.1f-%.1f every %.1fs x %d)",
                                                  effect,
                                                  hit_str,
                                                  eval.spell.ot_if_hit, 
                                                  eval.spell.ot_duration, 
                                                  (0.5*dmg_wo_sp + dmg_from_sp)/eval.spell.ot_ticks,
                                                  eval.spell.ot_if_hit/eval.spell.ot_ticks,
                                                  (1.5*dmg_wo_sp + dmg_from_sp)/eval.spell.ot_ticks,
                                                  eval.spell.ot_freq, 
                                                  eval.spell.ot_ticks),
                                    232.0/255, 225.0/255, 32.0/255);
                elseif spell.base_id == spell_name_to_id["Starshards"] then
                    local dmg_from_sp = stats.ot_coef*stats.spell_ot_mod*stats.spell_power*eval.spell.ot_ticks;
                    local dmg_wo_sp = (eval.spell.ot_if_hit - dmg_from_sp);
                    tooltip:AddLine(string.format("%s %s: %.1f over %.1fs (%.1f-%.1f-%.1f every %.1fs x %d)",
                                                  effect,
                                                  hit_str,
                                                  eval.spell.ot_if_hit, 
                                                  eval.spell.ot_duration, 
                                                  ((2/3)*dmg_wo_sp + dmg_from_sp)/eval.spell.ot_ticks,
                                                  eval.spell.ot_if_hit/eval.spell.ot_ticks,
                                                  ((4/3)*dmg_wo_sp + dmg_from_sp)/eval.spell.ot_ticks,
                                                  eval.spell.ot_freq,
                                                  eval.spell.ot_ticks), 
                                    232.0/255, 225.0/255, 32.0/255);
                elseif bit.band(spell.flags, spell_flags.over_time_range) ~= 0 then
                    tooltip:AddLine(string.format("%s %s: %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                                                  effect,
                                                  hit_str,
                                                  math.floor(eval.spell.ot_if_hit),
                                                  math.ceil(eval.spell.ot_if_hit_max),
                                                  eval.spell.ot_duration, 
                                                  math.floor(eval.spell.ot_if_hit/eval.spell.ot_ticks),
                                                  math.ceil(eval.spell.ot_if_hit_max/eval.spell.ot_ticks),
                                                  eval.spell.ot_freq,
                                                  eval.spell.ot_ticks), 
                                    232.0/255, 225.0/255, 32.0/255);
                else
                    tooltip:AddLine(string.format("%s %s: %.1f over %.1fs (%.1f every %.1fs x %d)",
                                                  effect,
                                                  hit_str,
                                                  eval.spell.ot_if_hit, 
                                                  eval.spell.ot_duration, 
                                                  eval.spell.ot_if_hit/eval.spell.ot_ticks,
                                                  eval.spell.ot_freq, 
                                                  eval.spell.ot_ticks), 
                                    232.0/255, 225.0/255, 32.0/255);
                end
            else
                -- wild growth
                if spell.base_id == spell_name_to_id["Wild Growth"] then
                    local heal_from_sp = stats.ot_coef*stats.spell_ot_mod*stats.spell_power*eval.spell.ot_ticks;
                    local heal_wo_sp = (eval.spell.ot_if_hit - heal_from_sp);
                    tooltip:AddLine(string.format("%s: %.1f over %ds (%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f every %.1fs x %d)",
                                                  effect,
                                                  eval.spell.ot_if_hit, 
                                                  eval.spell.ot_duration, 
                                                  (( 3*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                                  (( 2*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                                  (( 1*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                                  (( 0*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                                  ((-1*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                                  ((-2*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                                  ((-3*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                                  eval.spell.ot_freq,
                                                  eval.spell.ot_ticks), 
                                    232.0/255, 225.0/255, 32.0/255);
                elseif bit.band(spell.flags, spell_flags.over_time_range) ~= 0 then
                     tooltip:AddLine(string.format("%s: %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                                                   effect,
                                                   math.floor(eval.spell.ot_if_hit),
                                                   math.ceil(eval.spell.ot_if_hit_max), 
                                                   eval.spell.ot_duration, 
                                                   math.floor(eval.spell.ot_if_hit/eval.spell.ot_ticks),
                                                   math.ceil(eval.spell.ot_if_hit_max/eval.spell.ot_ticks),
                                                  eval.spell.ot_freq,
                                                  eval.spell.ot_ticks), 
                                    232.0/255, 225.0/255, 32.0/255);
                else
                     tooltip:AddLine(string.format("%s: %.1f over %.1fs (%.1f every %.1fs x %d)",
                                                   effect,
                                                   eval.spell.ot_if_hit, 
                                                   eval.spell.ot_duration, 
                                                   eval.spell.ot_if_hit_max/eval.spell.ot_ticks,
                                                   eval.spell.ot_freq,
                                                   eval.spell.ot_ticks), 
                                    232.0/255, 225.0/255, 32.0/255);
                end
            end
        end
        for i = 1, eval.spell.num_extra_periodic_effects do

            if eval.spell["ot_if_hit"..i] ~= 0.0 then
                if eval.spell["ot_if_hit"..i] ~= eval.spell["ot_if_hit_max"..i] then
                    tooltip:AddLine(string.format("%s: %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                                                  eval.spell["ot_description"..i], 
                                                  math.floor(eval.spell["ot_if_hit"..i]), 
                                                  math.ceil(eval.spell["ot_if_hit_max"..i]), 
                                                  eval.spell["ot_duration"..i], 
                                                  math.floor(eval.spell["ot_if_hit"..i]/eval.spell["ot_ticks"..i]),
                                                  math.ceil(eval.spell["ot_if_hit_max"..i]/eval.spell["ot_ticks"..i]),
                                                  eval.spell["ot_freq"..i], 
                                                  eval.spell["ot_ticks"..i]), 
                               232.0/255, 225.0/255, 32.0/255);
                else
                    tooltip:AddLine(string.format("%s (%.2f%%): %.1f over %.1fs (%.1f every %.1fs x %d)",
                                                  eval.spell["ot_description"..i], 
                                                  stats.crit*100, 
                                                  eval.spell["ot_if_hit"..i], 
                                                  eval.spell["ot_duration"..i], 
                                                  eval.spell["ot_if_hit"..i]/eval.spell["ot_ticks"..i],
                                                  eval.spell["ot_freq"..i], 
                                                  eval.spell["ot_ticks"..i]), 
                               232.0/255, 225.0/255, 32.0/255);
            end
        end
    end


    if sw_frame.settings_frame.tooltip_crit_ot:GetChecked() then
        if stats.ot_crit ~= 0.0 and eval.spell.ot_if_crit ~= 0 then
            if eval.spell.ot_if_crit ~= eval.spell.ot_if_crit_max then
                tooltip:AddLine(string.format("Critical (%.2f%%||%.2fx): %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                                              stats.crit*100, 
                                              stats.crit_mod,
                                              math.floor(eval.spell.ot_if_crit), 
                                              math.ceil(eval.spell.ot_if_crit_max), 
                                              eval.spell.ot_duration, 
                                              math.floor(eval.spell.ot_if_crit/eval.spell.ot_ticks),
                                              math.ceil(eval.spell.ot_if_crit_max/eval.spell.ot_ticks),
                                              eval.spell.ot_freq, 
                                              eval.spell.ot_ticks), 
                           252.0/255, 69.0/255, 3.0/255);
                
            else
                tooltip:AddLine(string.format("Critical (%.2f%%||%.2fx): %.1f over %.1fs (%.1f every %.1fs x %d)",
                                              stats.ot_crit*100, 
                                              stats.crit_mod,
                                              eval.spell.ot_if_crit, 
                                              eval.spell.ot_duration, 
                                              eval.spell.ot_if_crit/eval.spell.ot_ticks,
                                              eval.spell.ot_freq, 
                                              eval.spell.ot_ticks), 
                           252.0/255, 69.0/255, 3.0/255);
            end
            
        end

        for i = 1, eval.spell.num_extra_periodic_effects do
            if eval.spell["ot_crit"..i] ~= 0.0 then
                if eval.spell["ot_if_crit"..i] ~= eval.spell["ot_if_crit_max"..i] then
                    tooltip:AddLine(string.format("%s (%.2f%%): %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                                                  eval.spell["ot_description"..i], 
                                                  stats.crit*100, 
                                                  math.floor(eval.spell["ot_if_crit"..i]), 
                                                  math.ceil(eval.spell["ot_if_crit_max"..i]), 
                                                  eval.spell["ot_duration"..i], 
                                                  math.floor(eval.spell["ot_if_crit"..i]/eval.spell["ot_ticks"..i]),
                                                  math.ceil(eval.spell["ot_if_crit_max"..i]/eval.spell["ot_ticks"..i]),
                                                  eval.spell["ot_freq"..i], 
                                                  eval.spell["ot_ticks"..i]), 
                               252.0/255, 69.0/255, 3.0/255);
                else
                    tooltip:AddLine(string.format("%s (%.2f%%): %.1f over %.1fs (%.1f every %.1fs x %d)",
                                                  eval.spell["ot_description"..i], 
                                                  stats.crit*100, 
                                                  eval.spell["ot_if_crit"..i], 
                                                  eval.spell["ot_duration"..i], 
                                                  eval.spell["ot_if_crit"..i]/eval.spell["ot_ticks"..i],
                                                  eval.spell["ot_freq"..i], 
                                                  eval.spell["ot_ticks"..i]), 
                               252.0/255, 69.0/255, 3.0/255);
                end
            end
        end

    end
end

    if sw_frame.settings_frame.tooltip_expected_effect:GetChecked() then

        local extra_info_st = "";
        local extra_info_multi = "";

        if  eval.spell.expectation_direct ~= 0 and eval.spell.expected_ot ~= 0 then

            local direct_ratio = eval.spell.expectation_direct/(eval.spell.expectation_direct + eval.spell.expected_ot);
            extra_info_multi = extra_info_multi..string.format("%.1f%% direct | %.1f%% periodic", direct_ratio*100, (1.0-direct_ratio)*100);

            local direct_ratio = eval.spell.expectation_direct_st/(eval.spell.expectation_direct_st + eval.spell.expected_ot_st);
            extra_info_st = extra_info_st..string.format("%.1f%% direct | %.1f%% periodic", direct_ratio*100, (1.0-direct_ratio)*100);
        elseif eval.spell.expectation_direct ~= 0 then
            extra_info_multi = extra_info_multi.."100% direct";
            extra_info_st = "100% direct";
        elseif eval.spell.expected_ot ~= 0 then
            extra_info_multi = extra_info_multi.."100% periodic";
            extra_info_st = "100% periodic";
        end

        if eval.spell.expectation ~= eval.spell.expectation_st then


            if extra_info_st == "" then
                extra_info_st = "(1.00x effect)";
            else
                extra_info_st = "("..extra_info_st.." | 1.00x effect)";
            end
            local aoe_ratio = string.format("%.2fx effect", eval.spell.expectation/eval.spell.expectation_st);
            if extra_info_multi == "" then
                extra_info_multi = "("..aoe_ratio..")";
            else
                extra_info_multi = "("..extra_info_multi.." | "..aoe_ratio..")";
            end
            tooltip:AddLine(string.format("Expected: %.1f %s",eval.spell.expectation_st, extra_info_st),
                          255.0/256, 128.0/256, 0);
            tooltip:AddLine(string.format("Optimistic: %.1f %s", eval.spell.expectation, extra_info_multi),
                            255.0/256, 128.0/256, 0);
        else
            if extra_info_st ~= "" then
                extra_info_st = "("..extra_info_st..")";
            end
            if extra_info_multi ~= "" then
                extra_info_multi = "("..extra_info_multi..")";
            end
            tooltip:AddLine("Expected"..string.format(": %.1f %s",eval.spell.expectation, extra_info_st),
                            255.0/256, 128.0/256, 0);
        end
    end

    if sw_frame.settings_frame.tooltip_effect_per_sec:GetChecked() then

        --if eval.spell.effect_per_sec ~= eval.spell.effect_per_dur then
        --    tooltip:AddLine(string.format("%s: %.1f%s", 
        --                                  effect_per_sec.." (cast time)",
        --                                  eval.spell.effect_per_sec, direct_to_periodic_str),
        --                    255.0/256, 128.0/256, 0);
        --    tooltip:AddLine(string.format("%s: %.1f", 
        --                                  effect_per_sec.." (duration)",
        --                                  eval.spell.effect_per_dur),
        --                    255.0/256, 128.0/256, 0);
        --    else
        --    tooltip:AddLine(string.format("%s: %.1f%s", 
        --                                  effect_per_sec,
        --                                  eval.spell.effect_per_sec, direct_to_periodic_str),
        --                    255.0/256, 128.0/256, 0);
        --end

        local periodic_part = "";
        if eval.spell.effect_per_dur ~= 0  and eval.spell.effect_per_dur ~= eval.spell.effect_per_sec then
            periodic_part = string.format("| %.1f periodic for %d sec", eval.spell.effect_per_dur, eval.spell.longest_ot_duration);
        end

        tooltip:AddLine(string.format("%s: %.1f by execution time %s", 
                                      effect_per_sec,
                                      eval.spell.effect_per_sec, periodic_part),
                        255.0/256, 128.0/256, 0);
    end
    if sw_frame.settings_frame.tooltip_avg_cast:GetChecked() and not repeated_tooltip_on then

        local tooltip_cast = spell_cast_time(spell_id);
        if not tooltip_cast or tooltip_cast ~= stats.cast_time then
            if stats.cast_time_nogcd ~= stats.cast_time then
                tooltip:AddLine(string.format("Expected Cast Time: %.1f sec (%.3f but gcd capped)", stats.gcd, stats.cast_time_nogcd), 215/256, 83/256, 234/256);
            else
                tooltip:AddLine(string.format("Expected Cast Time: %.3f sec", stats.cast_time), 215/256, 83/256, 234/256);
            end
        end

    end
    local tooltip_cost = spell_cost(spell_id);
    if sw_frame.settings_frame.tooltip_avg_cost:GetChecked() then
        if not tooltip_cost or tooltip_cost ~= stats.cost or repeated_tooltip_on then
            if loadout.lvl ~= UnitLevel("player") and bit.band(spell.flags, spell_flags.base_mana_cost) ~= 0 then
                tooltip:AddLine(string.format("NOTE: Mana cost at custom lvl may be inaccurate; roughly estimated",stats.cost), 1.0, 0.0, 0.0);
            end
            tooltip:AddLine(string.format("Expected Cost: %.1f",stats.cost), 0.0, 1.0, 1.0);
        end
    end
    if sw_frame.settings_frame.tooltip_effect_per_cost:GetChecked() then
        tooltip:AddLine(effect_per_cost..": "..string.format("%.2f",eval.spell.effect_per_cost), 0.0, 1.0, 1.0);
    end
    if sw_frame.settings_frame.tooltip_cost_per_sec:GetChecked() then
        if not tooltip_cost or tooltip_cost ~= stats.cost or not repeated_tooltip_on then
            tooltip:AddLine(cost_per_sec..": "..string.format("- %.1f out | + %.1f in", eval.spell.cost_per_sec, eval.spell.mp1), 0.0, 1.0, 1.0);
        end
    end

    if sw_frame.settings_frame.tooltip_cast_until_oom:GetChecked() then

        tooltip:AddLine(string.format("%s until OOM: %.1f (%.1f casts, %.1f sec)", effect, eval.spell.effect_until_oom, eval.spell.num_casts_until_oom, eval.spell.time_until_oom),
                        232.0/255, 225.0/255, 32.0/255);
        if loadout.mana ~= eval.spell.mana then
            tooltip:AddLine(string.format("                                   casting from %d mana", eval.spell.mana),
                            232.0/255, 225.0/255, 32.0/255);
    
        end
    end
    if sw_frame.settings_frame.tooltip_sp_effect_calc:GetChecked() then
        
        if stats.coef > 0 and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_periodic) == 0 then
            tooltip:AddLine(string.format("Direct:    %.3f coef * %.3f mod * %d SP = %.1f",
                                           stats.coef,
                                           stats.spell_mod,
                                           stats.spell_power,
                                           stats.coef*stats.spell_mod*stats.spell_power
                                          ),
                            138/256, 134/256, 125/256);
        end
        if stats.ot_coef > 0 and bit.band(eval_flags, swc.calc.evaluation_flags.isolate_direct) == 0 then
            tooltip:AddLine(string.format("Periodic: %d ticks * %.3f coef * %.3f mod * %d SP",
                                           eval.spell.ot_ticks,
                                           stats.ot_coef,
                                           stats.spell_ot_mod,
                                           stats.spell_power_ot
                                           ),
                            138/256, 134/256, 125/256);
            tooltip:AddLine(string.format("            = %d ticks * %.1f = %.1f",
                                           eval.spell.ot_ticks,
                                           stats.ot_coef*stats.spell_ot_mod*stats.spell_power_ot,
                                           stats.ot_coef*stats.spell_ot_mod*stats.spell_power_ot*eval.spell.ot_ticks),
                            138/256, 134/256, 125/256);
        end
    end

    if sw_frame.settings_frame.tooltip_stat_weights:GetChecked() and bit.band(spell.flags, spell_flags.mana_regen) == 0 then
        if eval.infinite_cast.effect_per_sec_per_sp > 0 then
            tooltip:AddLine(effect_per_sec_per_sp..": "..string.format("%.3f, weighing",eval.infinite_cast.effect_per_sec_per_sp), 0.0, 1.0, 0.0);
            local stat_weights = {};
            stat_weights[1] = {weight = 1.0, str = "SP"};
            stat_weights[2] = {weight = eval.infinite_cast.sp_per_crit, str = "Crit"};
            local num_weights = 2;
            --if eval.sp_per_int ~= 0 then
            num_weights = num_weights + 1;
            stat_weights[num_weights] = {weight = eval.infinite_cast.sp_per_int, str = "Int"};
            --end
            --if eval.sp_per_spirit ~= 0 then
            num_weights = num_weights + 1;
            stat_weights[num_weights] = {weight = eval.infinite_cast.sp_per_spirit, str = "Spirit"};
            --end

            if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                num_weights = num_weights + 1;
                stat_weights[num_weights] = {weight = eval.infinite_cast.sp_per_hit, str = "Hit"};
                num_weights = num_weights + 1;
                stat_weights[num_weights] = {weight = eval.infinite_cast.sp_per_pen, str = "Spell Pen"};
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
                    stat_weights_str = stat_weights_str..string.format(" %.3f %s |", stat_weights[i].weight, stat_weights[i].str);
                else
                    stat_weights_str = stat_weights_str..string.format(" %d %s |", 0, stat_weights[i].str);
                end
                if i == max_weights_per_line and i ~= num_weights then
                    stat_weights_str = stat_weights_str.."\n|";
                end
            end
            tooltip:AddLine(stat_weights_str, 0.0, 1.0, 0.0);
        end

        if sw_frame.settings_frame.tooltip_cast_until_oom:GetChecked() and eval.spell.cost_per_sec > 0 then

            if eval.cast_until_oom.effect_until_oom_per_sp > 0 then
                tooltip:AddLine(string.format("%s until OOM per SP: %.3f, weighing", effect, eval.cast_until_oom.effect_until_oom_per_sp), 0.0, 1.0, 0.0);
                local stat_weights = {};
                stat_weights[1] = {weight = 1.0, str = "SP"};
                stat_weights[2] = {weight = eval.cast_until_oom.sp_per_crit, str = "Crit"};
                stat_weights[3] = {weight = eval.cast_until_oom.sp_per_int, str = "Int"};
                stat_weights[4] = {weight = eval.cast_until_oom.sp_per_spirit, str = "Spirit"};
                stat_weights[5] = {weight = eval.cast_until_oom.sp_per_mp5, str = "MP5"};
                local num_weights = 5;

                if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                    num_weights = 7;
                    stat_weights[6] = {weight = eval.cast_until_oom.sp_per_hit, str = "Hit"};
                    stat_weights[7] = {weight = eval.cast_until_oom.sp_per_pen, str = "Spell Pen"};
                end

                local stat_weights_str = "|";
                local max_weights_per_line = 4;
                sort_stat_weights(stat_weights, num_weights);
                for i = 1, num_weights do
                    if stat_weights[i].weight ~= 0 then
                        stat_weights_str = stat_weights_str..string.format(" %.3f %s |", stat_weights[i].weight, stat_weights[i].str);
                    else
                        stat_weights_str = stat_weights_str..string.format(" %d %s |", 0, stat_weights[i].str);
                    end
                    if i == max_weights_per_line then
                        stat_weights_str = stat_weights_str.."\n|";
                    end
                end
                tooltip:AddLine(stat_weights_str, 0.0, 1.0, 0.0);
            end
        end
    end

    local evaluation_options = "";
    if  eval.spell.expectation_direct ~= 0 and eval.spell.expected_ot ~= 0 then
        evaluation_options = "CTRL facing north=periodic, south=direct";
    end

    if eval.spell.expectation ~= eval.spell.expectation_st then
        if evaluation_options == "" then
            evaluation_options = "ALT for 1.00x effect";
        else
            evaluation_options = evaluation_options.." | ALT for 1.00x";
        end
    end


    if evaluation_options ~= "" then
        --tooltip:AddLine("Hold key to isolate: "..evaluation_options, 1.0, 1.0, 1.0);
        tooltip:AddLine("To isolate: Hold "..evaluation_options, 1.0, 1.0, 1.0);
    end
    if bit.band(spell.flags, spell_flags.weapon_enchant) ~= 0 and bit.band(eval_flags, swc.calc.evaluation_flags.offhand) == 0 then
        tooltip:AddLine("Hold ALT key to show for offhand", 1.0, 1.0, 1.0);

    end

    -- debug tooltip stuff
    if swc.core.__sw__debug__ then
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
        tooltip_spell_info(tooltip, spell.healing_version, loadout, effects, true, spell_id);
    end
end

swc.tooltip.tooltip_spell_info = tooltip_spell_info;

