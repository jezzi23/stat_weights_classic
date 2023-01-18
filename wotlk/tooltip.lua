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

local spells                                    = addonTable.spells;
local spell_flags                               = addonTable.spell_flags;

local loadout_flags                             = addonTable.loadout_flags;

local spell_name_to_id                          = addonTable.spell_name_to_id;
local spell_names_to_id                         = addonTable.spell_names_to_id;
local magic_school                              = addonTable.magic_school;
local spell_flags                               = addonTable.spell_flags;

local stats_for_spell                           = addonTable.stats_for_spell;
local spell_info                                = addonTable.spell_info;
local cast_until_oom                            = addonTable.cast_until_oom;
local evaluate_spell                            = addonTable.evaluate_spell;

local active_loadout_and_effects                = addonTable.active_loadout_and_effects;
local active_loadout_and_effects_diffed_from_ui = addonTable.active_loadout_and_effects_diffed_from_ui;



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
    more_details        = bit.lshift(1,10),
    avg_cost            = bit.lshift(1,11),
    avg_cast            = bit.lshift(1,12),
    cast_until_oom      = bit.lshift(1,13),
    cast_and_tap        = bit.lshift(1,14)
};


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

local function begin_tooltip_section(tooltip)
    tooltip:AddLine(" ");
    --tooltip:AddLine("Stat Weights", 1.0, 153.0/255, 102.0/255);
end
local function end_tooltip_section(tooltip)
    tooltip:Show();
end

local function tooltip_spell_info(tooltip, spell, loadout, effects)

    if sw_frame.settings_frame.tooltip_num_checked == 0 or 
        (sw_frame.settings_frame.show_tooltip_only_when_shift and not IsShiftKeyDown()) then
        return;
    end

    local stats = {};
    stats_for_spell(stats, spell, loadout, effects); 
    local eval = evaluate_spell(spell, stats, loadout, effects);

    --local cast_til_oom = cast_until_oom_stat_weights(
    --  spell, stats,
    --  eval.spell, eval.spell_1_sp, eval.spell_1_crit, eval.spell_1_hit, eval.spell_1_haste, eval.spell_1_int, eval.spell_1_spirit, eval.spell_1_mp5,
    --  loadout, effects
    --);

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
        effect_per_sec_per_sp = "HPS (by cast time) per SP";
        sp_name = "Spell power";
    else
        effect = "Damage";
        effect_per_sec = "DPS";
        effect_per_cost = "Damage per Mana";
        cost_per_sec = "Mana per sec";
        effect_per_sec_per_sp = "DPS (by cast time) per SP";
        sp_name = "Spell power";
    end

    begin_tooltip_section(tooltip);

    tooltip:AddLine("Stat Weights Classic", 1, 1, 1);

    if loadout.lvl > spell.lvl_outdated and not addonTable.__sw__debug__ then
        tooltip:AddLine("Ability downranking is not optimal in WOTLK! A new rank is available at your level.", 252.0/255, 69.0/255, 3.0/255);
        end_tooltip_section(tooltip);
        return;
    end 

    local loadout_type = "";
    if bit.band(loadout.flags, loadout_flags.is_dynamic_loadout) ~= 0 then
        loadout_type = "dynamic";
    else
        loadout_type = "static";
    end
    if bit.band(spell.flags, bit.bor(spell_flags.absorb, spell_flags.heal, spell_flags.mana_regen)) ~= 0 then
        tooltip:AddLine(string.format("Active Loadout (%s): %s", loadout_type, loadout.name), 1, 1,1);
    else
        tooltip:AddLine(string.format("Active Loadout (%s): %s - Target lvl %d", loadout_type, loadout.name, loadout.target_lvl), 1, 1, 1);
    end
    if bit.band(spell.flags, spell_flags.mana_regen) ~= 0 then
        tooltip:AddLine(string.format("Restores %d mana over %.2f sec for yourself",
                                      math.ceil(eval.spell.mana_restored),
                                      math.max(stats.cast_time, spell.over_time_duration)
                                      ),
                        0, 1, 1);

        if spell.base_id ~= spell_name_to_id["Shadowfiend"] then
            end_tooltip_section(tooltip);
            return;
        end
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

                    if spell.base_id == spell_name_to_id["Prayer of Healing"] and loadout.glyphs[55680] then
                        tooltip:AddLine(string.format("        and %d-%d over %d sec (%d-%d for %d ticks)", 
                                                      math.floor(0.2*eval.spell.min_noncrit_if_hit),
                                                      math.ceil(0.2*eval.spell.max_noncrit_if_hit),
                                                      2,
                                                      math.floor(0.2*eval.spell.min_noncrit_if_hit/2),
                                                      math.ceil(0.2*eval.spell.max_noncrit_if_hit/2),
                                                      2),
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
                local effect_type_str = nil;
                local extra_crit_mod = 0;
                local pts = 0;
                if class == "PRIEST" then
                    pts = loadout.talents_table:pts(1, 24);
                    if pts ~= 0 and bit.band(spell.flags, spell_flags.heal) ~= 0 then
                        effect_type_str = "absorbs";
                        extra_crit_mod = pts * 0.1;
                    end
                elseif class == "DRUID" then
                    pts = loadout.talents_table:pts(3, 21);
                    if pts ~= 0 and bit.band(spell.flags, spell_flags.heal) ~= 0 and spell.base_id ~= spell_name_to_id["Lifebloom"] then
                        effect_type_str = "seeds";
                        extra_crit_mod = pts * 0.1;
                    end
                elseif class == "SHAMAN" then
                    pts = loadout.talents_table:pts(3, 22);
                    if pts ~= 0 and
                        (spell.base_id == spell_name_to_id["Healing Wave"] or
                         spell.base_id == spell_name_to_id["Lesser Healing Wave"] or
                         spell.base_id == spell_name_to_id["Riptide"]) then

                        effect_type_str = "awakens";
                        extra_crit_mod = pts * 0.1;
                    elseif loadout.num_set_pieces[set_tiers.pve_t8_1] >= 4 and
                        spell.base_id == spell_name_to_id["Lightning Bolt"] then

                        effect_type_str = "worldbreaks"
                        extra_crit_mod = 0.08;
                    end
                elseif class == "PALADIN" then
                    -- tier 8 p2 holy bonus
                    if loadout.num_set_pieces[set_tiers.pve_t8_1] >= 2 and bit.band(spell.flags, spell_flags.heal) ~= 0 and
                        spell.base_id == spell_name_to_id["Holy Shock"] then

                        effect_type_str = "aegis"
                        extra_crit_mod = 0.15;
                    end

                elseif class == "MAGE" and spell.school == magic_school.fire and loadout.talents_table:pts(2, 4) ~= 0 then

                    pts = loadout.talents_table:pts(2, 4);
                    effect_type_str = "ignites"
                    extra_crit_mod = 0.08 * pts;

                end
                if effect_type_str and eval.spell.min_crit_if_hit ~= 0 then
                    local min_crit_if_hit = eval.spell.min_crit_if_hit/(1 + extra_crit_mod);
                    local max_crit_if_hit = eval.spell.max_crit_if_hit/(1 + extra_crit_mod);
                    local effect_min = extra_crit_mod * min_crit_if_hit;
                    local effect_max = extra_crit_mod * max_crit_if_hit;
                    if eval.spell.min_crit_if_hit ~= eval.spell.max_crit_if_hit then
                        tooltip:AddLine(string.format("Critical (%.2f%%): %d-%d + %s %d-%d", 
                                                      stats.crit*100, 
                                                      math.floor(min_crit_if_hit), 
                                                      math.ceil(max_crit_if_hit),
                                                      effect_type_str,
                                                      math.floor(effect_min), 
                                                      math.ceil(effect_max)),
                                       252.0/255, 69.0/255, 3.0/255);
                    else
                        tooltip:AddLine(string.format("Critical (%.2f%%): %d + %s %d", 
                                                      stats.crit*100, 
                                                      math.floor(min_crit_if_hit), 
                                                      effect_type_str,
                                                      math.floor(effect_min)),
                                       252.0/255, 69.0/255, 3.0/255);

                    end

                    if spell.base_id == spell_name_to_id["Prayer of Healing"] and loadout.glyphs[55680] then
                        tooltip:AddLine(string.format("        and %d-%d over %d sec (%d-%d for %d ticks)", 
                                                      math.floor(0.2*min_crit_if_hit), 
                                                      math.ceil(0.2*max_crit_if_hit),
                                                      2,
                                                      math.floor(0.2*min_crit_if_hit/2), 
                                                      math.ceil(0.2*max_crit_if_hit/2),
                                                      2),
                                       252.0/255, 69.0/255, 3.0/255);
                    end
                    
                elseif eval.spell.min_crit_if_hit ~= eval.spell.max_crit_if_hit then

                    tooltip:AddLine(string.format("Critical (%.2f%%): %d-%d", 
                                                  stats.crit*100, 
                                                  math.floor(eval.spell.min_crit_if_hit), 
                                                  math.ceil(eval.spell.max_crit_if_hit)),
                                   252.0/255, 69.0/255, 3.0/255);
                    if spell.base_id == spell_name_to_id["Prayer of Healing"] and loadout.glyphs[55680] then
                        tooltip:AddLine(string.format("        and %d-%d over %d sec (%d-%d for %d ticks)", 
                                                      math.floor(0.2*eval.spell.min_crit_if_hit), 
                                                      math.ceil(0.2*eval.spell.max_crit_if_hit),
                                                      2,
                                                      math.floor(0.2*eval.spell.min_crit_if_hit)/2, 
                                                      math.ceil(0.2*eval.spell.max_crit_if_hit/2),
                                                      2),
                                       252.0/255, 69.0/255, 3.0/255);
                    end

                else 
                    tooltip:AddLine(string.format("Critical (%.2f%%): %d", 
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
                tooltip:AddLine(string.format("%s (%.1f%% hit): %d over %.2fs (%.1f-%.1f-%.1f for %d ticks)",
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
                                              eval.spell.ot_if_hit/eval.spell.ot_ticks,
                                              eval.spell.ot_if_hit_max/eval.spell.ot_ticks,
                                              eval.spell.ot_ticks), 
                                232.0/255, 225.0/255, 32.0/255);
            else
                tooltip:AddLine(string.format("%s (%.1f%% hit): %d over %.2fs (%.1f for %d ticks)",
                                              effect,
                                              stats.hit * 100,
                                              eval.spell.ot_if_hit, 
                                              eval.spell.ot_duration, 
                                              eval.spell.ot_if_hit/eval.spell.ot_ticks,
                                              eval.spell.ot_ticks), 
                                232.0/255, 225.0/255, 32.0/255);
            end
        else
            -- wild growth
            if spell.base_id == spell_name_to_id["Wild Growth"] then
                local heal_from_sp = stats.ot_coef*stats.spell_ot_mod*stats.spell_power*eval.spell.ot_ticks;
                local heal_wo_sp = (eval.spell.ot_if_hit - heal_from_sp);
                tooltip:AddLine(string.format("%s: %d over %ds (%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %d ticks)",
                                              effect,
                                              eval.spell.ot_if_hit, 
                                              eval.spell.ot_duration, 
                                              (( 3*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                              (( 2*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                              (( 1*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                              (( 0*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                              ((-1*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                              ((-2*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                              ((-3*0.1425 + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks
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
                 tooltip:AddLine(string.format("%s: %d over %.2fs (%.1f for %d ticks)",
                                               effect,
                                               eval.spell.ot_if_hit, 
                                               eval.spell.ot_duration, 
                                               eval.spell.ot_if_hit_max/eval.spell.ot_ticks,
                                               eval.spell.ot_ticks), 
                                232.0/255, 225.0/255, 32.0/255);
            end
        end

        if eval.spell.ot_if_crit ~= 0.0 or (loadout.glyphs[63091] and spell.base_id == spell_name_to_id["Living Bomb"]) and 
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

                if class == "MAGE" and loadout.talents_table:pts(2, 4) ~= 0 and spell.base_id == spell_name_to_id["Living Bomb"] then
                    local pts = loadout.talents_table:pts(2, 4) 
                    local min_crit_if_hit = (eval.spell.ot_if_crit/eval.spell.ot_ticks)/(1 + pts * 0.08);
                    local ignite_min = pts * 0.08 * min_crit_if_hit;
                    tooltip:AddLine(string.format("Critical (%.2f%%): %d over %.2fs (%.1f for %d ticks + ignites %d)",
                                                  stats.crit*100, 
                                                  min_crit_if_hit * eval.spell.ot_ticks,
                                                  eval.spell.ot_duration, 
                                                  min_crit_if_hit,
                                                  eval.spell.ot_ticks,
                                                  ignite_min), 
                               252.0/255, 69.0/255, 3.0/255);
                else
                    tooltip:AddLine(string.format("Critical (%.2f%%): %d over %.2fs (%.1f for %d ticks)",
                                                  stats.ot_crit*100, 
                                                  eval.spell.ot_if_crit, 
                                                  eval.spell.ot_duration, 
                                                  eval.spell.ot_if_crit/eval.spell.ot_ticks,
                                                  eval.spell.ot_ticks), 
                               252.0/255, 69.0/255, 3.0/255);
                end
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

    if sw_frame.settings_frame.tooltip_effect_per_sec:GetChecked() then
        if eval.spell.effect_per_sec ~= eval.spell.effect_per_dur then
            tooltip:AddLine(string.format("%s: %.1f", 
                                          effect_per_sec.." (cast time)",
                                          eval.spell.effect_per_sec),
                            255.0/256, 128.0/256, 0);
            tooltip:AddLine(string.format("%s: %.1f", 
                                          effect_per_sec.." (duration)",
                                          eval.spell.effect_per_dur),
                            255.0/256, 128.0/256, 0);
            else
            tooltip:AddLine(string.format("%s: %.1f", 
                                          effect_per_sec,
                                          eval.spell.effect_per_sec),
                            255.0/256, 128.0/256, 0);
        end
    end
    if sw_frame.settings_frame.tooltip_avg_cast:GetChecked() then

        tooltip:AddLine(string.format("Expected Cast Time: %.3f sec", stats.cast_time), 215/256, 83/256, 234/256);
    end
    if sw_frame.settings_frame.tooltip_avg_cost:GetChecked() then
        tooltip:AddLine(string.format("Expected Cost: %.1f",stats.cost), 0.0, 1.0, 1.0);
    end
    if sw_frame.settings_frame.tooltip_effect_per_cost:GetChecked() then
        tooltip:AddLine(effect_per_cost..": "..string.format("%.1f",eval.spell.effect_per_cost), 0.0, 1.0, 1.0);
    end
    if sw_frame.settings_frame.tooltip_cost_per_sec:GetChecked() then
        tooltip:AddLine(cost_per_sec..": "..string.format("- %.1f / + %.1f", eval.spell.cost_per_sec, eval.spell.mp1), 0.0, 1.0, 1.0);
    end

    if sw_frame.settings_frame.tooltip_stat_weights:GetChecked() then
        tooltip:AddLine("Scenario: Repeated casts", 1, 1, 1);
        tooltip:AddLine(effect_per_sec_per_sp..": "..string.format("%.3f",eval.infinite_cast.effect_per_sec_per_sp), 0.0, 1.0, 0.0);
        local stat_weights = {};
        stat_weights[1] = {weight = 1.0, str = "SP"};
        stat_weights[2] = {weight = eval.infinite_cast.sp_per_crit, str = "Crit"};
        stat_weights[3] = {weight = eval.infinite_cast.sp_per_haste, str = "Haste"};
        local num_weights = 3;
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
            if i == max_weights_per_line then
                stat_weights_str = stat_weights_str.."\n|";
            end
        end
        tooltip:AddLine(stat_weights_str, 0.0, 1.0, 0.0);
    end

    if sw_frame.settings_frame.tooltip_cast_until_oom:GetChecked() and
        bit.band(spell.flags, spell_flags.cd) == 0 then

        tooltip:AddLine("Scenario: Cast Until OOM", 1, 1, 1);

        tooltip:AddLine(string.format("%s until OOM : %.1f (%.1f casts, %.1f sec)", effect, eval.spell.effect_until_oom, eval.spell.num_casts_until_oom, eval.spell.time_until_oom));
        if sw_frame.settings_frame.tooltip_stat_weights:GetChecked() then

            tooltip:AddLine(string.format("%s per SP: %.3f", effect, eval.cast_until_oom.effect_until_oom_per_sp), 0.0, 1.0, 0.0);

            local stat_weights = {};
            stat_weights[1] = {weight = 1.0, str = "SP"};
            stat_weights[2] = {weight = eval.cast_until_oom.sp_per_crit, str = "Crit"};
            stat_weights[3] = {weight = eval.cast_until_oom.sp_per_haste, str = "Haste"};
            stat_weights[4] = {weight = eval.cast_until_oom.sp_per_int, str = "Int"};
            stat_weights[5] = {weight = eval.cast_until_oom.sp_per_spirit, str = "Spirit"};
            stat_weights[6] = {weight = eval.cast_until_oom.sp_per_mp5, str = "MP5"};
            local num_weights = 6;

            if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                num_weights = 7;
                stat_weights[7] = {weight = eval.cast_until_oom.sp_per_hit, str = "Hit"};
            end

            local stat_weights_str = "|";
            local max_weights_per_line = 4;
            sort_stat_weights(stat_weights, num_weights);
            for i = 1, num_weights do
                if stat_weights[i].weight ~= 0 then
                    --print(string.format("%.3f %s | ", stat_weights[i].weight, stat_weights[i].str))
                    stat_weights_str = stat_weights_str..string.format(" %.3f %s |", stat_weights[i].weight, stat_weights[i].str);
                else
                    --print(string.format("%.3f %s | ", stat_weights[i].weight, stat_weights[i].str))
                    stat_weights_str = stat_weights_str..string.format(" %d %s |", 0, stat_weights[i].str);
                end
                if i == max_weights_per_line then
                    stat_weights_str = stat_weights_str.."\n|";
                end
            end
            tooltip:AddLine(stat_weights_str, 0.0, 1.0, 0.0);
        end
    end

    if sw_frame.settings_frame.tooltip_more_details:GetChecked() then
        tooltip:AddLine(string.format("Spell power: %d direct / %d periodic", stats.spell_power, stats.spell_power_ot));
        tooltip:AddLine(string.format("Critical modifier %.5f", stats.crit_mod));
        tooltip:AddLine(string.format("Coefficient: %.3f direct / %.3f periodic", stats.coef, stats.ot_coef));
        tooltip:AddLine(string.format("Effect modifier: %.3f direct / %.3f periodic", stats.spell_mod, stats.spell_ot_mod));
        tooltip:AddLine(string.format("Effective coefficient: %.3f direct / %.3f periodic", stats.coef*stats.spell_mod, stats.ot_coef*stats.spell_ot_mod));
        tooltip:AddLine(string.format("Spell power effect: %.3f direct / %.3f periodic", stats.coef*stats.spell_mod*stats.spell_power, stats.ot_coef*stats.spell_ot_mod*stats.spell_power_ot));
    end
    -- debug tooltip stuff
    if addonTable.__sw__debug__ then
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

local function append_tooltip_spell_info(is_fake)

    local spell_name, spell_id = GameTooltip:GetSpell();

    local spell = spells[spell_id];
    if not spell then
        return;
    end

    if not sw_frame.stat_comparison_frame:IsShown() or not sw_frame:IsShown() then

        local loadout, effects = active_loadout_and_effects();
        tooltip_spell_info(GameTooltip, spell, loadout, effects);
    else

        local loadout, effects, effects_diffed = active_loadout_and_effects_diffed_from_ui();
        tooltip_spell_info(GameTooltip, spell, loadout, effects_diffed);

        if IsShiftKeyDown() and not sw_frame.stat_comparison_frame.spells[spell_id] 
                and bit.band(spells[spell_id].flags, spell_flags.mana_regen) == 0 then
            sw_frame.stat_comparison_frame.spells[spell_id] = {
                name = spell_name
            };

            addonTable.update_and_display_spell_diffs(loadout, effects, effects_diffed);
        end
    end
end

---- DELETE ME
---- tooltip test
--CreateFrame( "GameTooltip", "TestTip", UIParent, "GameTooltipTemplate" ); -- Tooltip 
----TestTip:SetOwner(WorldFrame, "ANCHOR_NONE")
--TestTip:AddFontStrings(
--    TestTip:CreateFontString( "$parentTextLeft1", nil, "GameTooltipText" ),
--    TestTip:CreateFontString( "$parentTextRight1", nil, "GameTooltipText" ) );
--
--TestTip:SetPoint("TOPLEFT", 400, -30)
--
--TestTip:SetWidth(400);
--TestTip:SetHeight(600);
--TestTip:AddLine(string.format("Test"), 1, 1,1);
--TestTip:Show();

addonTable.tooltip_stat_display             = tooltip_stat_display;
addonTable.append_tooltip_spell_info        = append_tooltip_spell_info;
