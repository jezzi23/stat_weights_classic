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

local addon_name, swc = ...;

local spells                                    = swc.abilities.spells;
local spell_flags                               = swc.abilities.spell_flags;
local spell_name_to_id                          = swc.abilities.spell_name_to_id;
local spell_names_to_id                         = swc.abilities.spell_names_to_id;
local next_spell_rank                           = swc.abilities.next_spell_rank;
local best_rank_by_lvl                          = swc.abilities.best_rank_by_lvl;
local magic_school                              = swc.abilities.magic_school;

local loadout_flags                             = swc.utils.loadout_flags;
local class                                     = swc.utils.class;

local set_tiers                                 = swc.equipment.set_tiers;

local stats_for_spell                           = swc.calc.stats_for_spell;
local spell_info                                = swc.calc.spell_info;
local cast_until_oom                            = swc.calc.cast_until_oom;
local evaluate_spell                            = swc.calc.evaluate_spell;

local sort_stat_weights                         = swc.tooltip.sort_stat_weights        
local begin_tooltip_section                     = swc.tooltip.begin_tooltip_section    
local end_tooltip_section                       = swc.tooltip.end_tooltip_section      
-------------------------------------------------------------------------------

local stats = {};

local function tooltip_spell_info(tooltip, spell, loadout, effects)

    -- Set gray spell rank in upper-right corner again after custom SetSpellByID clears it
    local txt_right = getglobal("GameTooltipTextRight1");
    if txt_right then
        txt_right:SetTextColor(0.50196081399918, 0.50196081399918, 0.50196081399918, 1.0);
        txt_right:SetText("Rank "..spell.rank);
        txt_right:Show();
    end

    if sw_frame.settings_frame.tooltip_num_checked == 0 or 
        (sw_frame.settings_frame.show_tooltip_only_when_shift and not IsShiftKeyDown()) then
        return;
    end

    stats_for_spell(stats, spell, loadout, effects); 
    local eval = evaluate_spell(spell, stats, loadout, effects);

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

    begin_tooltip_section(tooltip, spell.base_id);

    tooltip:AddLine("Stat Weights Classic", 1, 1, 1);

    if loadout.lvl > spell.lvl_outdated and not swc.core.__sw__debug__ then
        tooltip:AddLine("Ability downranking is not optimal in WOTLK! A new rank is available at your level.", 252.0/255, 69.0/255, 3.0/255);
    end 
    if sw_frame.settings_frame.tooltip_loadout_info:GetChecked() then

        local clvl_specified = "";
        if bit.band(loadout.flags, loadout_flags.custom_lvl) ~= 0 then
            clvl_specified = string.format(" (clvl: %d)", loadout.lvl);
        end
        if bit.band(spell.flags, bit.bor(spell_flags.absorb, spell_flags.heal, spell_flags.mana_regen)) ~= 0 then
            tooltip:AddLine(string.format("Loadout: %s%s - Target %.1f%% HP",
                                          loadout.name, clvl_specified, loadout.friendly_hp_perc * 100
                                          ),
                            138/256, 134/256, 125/256);
        else
            tooltip:AddLine(string.format("Loadout: %s%s - Target lvl %d, %.1f%% HP",
                                          loadout.name, clvl_specified, loadout.target_lvl, loadout.enemy_hp_perc * 100
                                          ),
                            138/256, 134/256, 125/256);
        end
    end

    if sw_frame.settings_frame.tooltip_spell_rank:GetChecked() then

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
        tooltip:AddLine("WARNING: using custom talents, glyphs, lvl or buffs!", 1, 0, 0);
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
                    if spell.base_id == spell_name_to_id["Chain Lightning"] then
                        local bounce_str = "     + ";
                        local bounces = 2;
                        if loadout.glyphs[55449] then
                            bounces = 3;
                        end
                        local falloff = 0.7;
                        for i = 1, bounces-1 do
                            bounce_str = bounce_str..string.format(" %d-%d  + ",
                                                                   falloff*math.floor(eval.spell.min_noncrit_if_hit), 
                                                                   falloff*math.ceil(eval.spell.max_noncrit_if_hit));

                            falloff = falloff * 0.7;
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

                    -- holy light splash                
                    if loadout.glyphs[54937] and spell.base_id == spell_name_to_id["Holy Light"] then
                        tooltip:AddLine(string.format("     + splash %d-%d on 5 players each",
                                                      math.floor(eval.spell.min_noncrit_if_hit*0.1), 
                                                      math.ceil(eval.spell.max_noncrit_if_hit*0.1)),
                                        232.0/255, 225.0/255, 32.0/255);

                    elseif spell.base_id == spell_name_to_id["Chain Heal"] then
                        local bounce_str = "     + ";
                        local bounces = 2;
                        if loadout.glyphs[55437] then
                            bounces = 3;
                        end
                        local falloff = 0.6;
                        for i = 1, bounces-1 do
                            bounce_str = bounce_str..string.format(" %d-%d  + ",
                                                                   falloff*math.floor(eval.spell.min_noncrit_if_hit), 
                                                                   falloff*math.ceil(eval.spell.max_noncrit_if_hit));

                            falloff = falloff * 0.6;
                        end
                        bounce_str = bounce_str..string.format(" %d-%d",
                                                               falloff*math.floor(eval.spell.min_noncrit_if_hit), 
                                                               falloff*math.ceil(eval.spell.max_noncrit_if_hit));
                        tooltip:AddLine(bounce_str, 232.0/255, 225.0/255, 32.0/255);
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
                    if pts ~= 0 and bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
                        if loadout.num_set_pieces[set_tiers.pve_t9_1] >= 4 then
                            pts = pts + 1;
                        end
                        effect_type_str = "absorbs";
                        extra_crit_mod = pts * 0.1;
                    end
                elseif class == "DRUID" then
                    pts = loadout.talents_table:pts(3, 21);
                    if pts ~= 0 and bit.band(spell.flags, spell_flags.heal) ~= 0 and spell.base_id ~= spell_name_to_id["Lifebloom"] then
                        effect_type_str = "seeds";
                        extra_crit_mod = pts * 0.1;
                    elseif loadout.num_set_pieces[set_tiers.pve_t10_1] >= 4 and
                        (spell.base_id == spell_name_to_id["Wrath"] or spell.base_id == spell_name_to_id["Starfire"]) then
                        effect_type_str = "languish";
                        extra_crit_mod = 0.07;
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

                elseif spell.base_id == spell_name_to_id["Chain Heal"] then

                    local extra_crit_mod = 0.0;
                    if loadout.num_set_pieces[set_tiers.pve_t10_3] >= 4 then
                        extra_crit_mod = 0.25
                    end
                    local min_crit_if_hit = eval.spell.min_crit_if_hit/(1 + extra_crit_mod);
                    local max_crit_if_hit = eval.spell.max_crit_if_hit/(1 + extra_crit_mod);
                    local effect_min = extra_crit_mod * min_crit_if_hit;
                    local effect_max = extra_crit_mod * max_crit_if_hit;

                    tooltip:AddLine(string.format("Critical (%.2f%%): %d-%d", 
                                                  stats.crit*100, 
                                                  math.floor(min_crit_if_hit), 
                                                  math.ceil(max_crit_if_hit)),
                                   252.0/255, 69.0/255, 3.0/255);

                    local bounces = 2;
                    if loadout.glyphs[55437] then
                        bounces = 3;
                    end
                    local falloff = 0.6;


                    local bounce_str = "     + ";
                    for i = 1, bounces-1 do
                        bounce_str = bounce_str..string.format(" %d-%d  + ",
                                                               falloff*math.floor(min_crit_if_hit), 
                                                               falloff*math.ceil(max_crit_if_hit));

                        falloff = falloff * 0.6;
                    end
                    bounce_str = bounce_str..string.format(" %d-%d",
                                                           falloff*math.floor(min_crit_if_hit), 
                                                           falloff*math.ceil(max_crit_if_hit));
                    tooltip:AddLine(bounce_str, 252.0/255, 69.0/255, 3.0/255);


                    if loadout.num_set_pieces[set_tiers.pve_t10_3] >= 4 then
                        tooltip:AddLine("And heals over 9 seconds", 252.0/255, 69.0/255, 3.0/255);
                        bounce_str = " ";         
                        falloff = 1.0;

                        for i = 1, bounces do
                            bounce_str = bounce_str..string.format(" %d-%d  + ",
                                                                   falloff*math.floor(effect_min), 
                                                                   falloff*math.ceil(effect_max));

                            falloff = falloff * 0.6;
                        end
                        bounce_str = bounce_str..string.format(" %d-%d",
                                                               falloff*math.floor(effect_min), 
                                                               falloff*math.ceil(effect_max));
                        tooltip:AddLine(bounce_str, 252.0/255, 69.0/255, 3.0/255);
                    end


                    
                elseif eval.spell.min_crit_if_hit ~= eval.spell.max_crit_if_hit then

                    tooltip:AddLine(string.format("Critical (%.2f%%): %d-%d", 
                                                  stats.crit*100, 
                                                  math.floor(eval.spell.min_crit_if_hit), 
                                                  math.ceil(eval.spell.max_crit_if_hit)),
                                   252.0/255, 69.0/255, 3.0/255);

                    -- holy light splash                
                    if loadout.glyphs[54937] and spell.base_id == spell_name_to_id["Holy Light"] then
                        tooltip:AddLine(string.format("     + splash %d-%d on 5 players each",
                                                      math.floor(eval.spell.min_crit_if_hit*0.1), 
                                                      math.ceil(eval.spell.max_crit_if_hit*0.1)),
                                        252.0/255, 69.0/255, 3.0/255);

                    elseif spell.base_id == spell_name_to_id["Chain Lightning"] then
                        local bounce_str = "     + ";
                        local bounces = 2;
                        if loadout.glyphs[55449] then
                            bounces = 3;
                        end
                        local falloff = 0.7;
                        for i = 1, bounces-1 do
                            bounce_str = bounce_str..string.format(" %d-%d  + ",
                                                                   falloff*math.floor(eval.spell.min_crit_if_hit), 
                                                                   falloff*math.ceil(eval.spell.max_crit_if_hit));

                            falloff = falloff * 0.7;
                        end
                        bounce_str = bounce_str..string.format(" %d-%d",
                                                               falloff*math.floor(eval.spell.min_crit_if_hit), 
                                                               falloff*math.ceil(eval.spell.max_crit_if_hit));
                        tooltip:AddLine(bounce_str, 252.0/255, 69.0/255, 3.0/255);
                    elseif spell.base_id == spell_name_to_id["Lava Burst"] and loadout.num_set_pieces[set_tiers.pve_t10_1] >= 4 and
                        ((loadout.dynamic_buffs["target"][GetSpellInfo(8050)] and loadout.hostile_towards == "target") or
                        loadout.target_buffs[GetSpellInfo(8050)]) then
                    --elseif spell.base_id == spell_name_to_id["Lava Burst"] and loadout.num_set_pieces[set_tiers.pve_t10_1] >= 4 then
                        --for k, v in pairs(loadout.dynamic_buffs["target"]) do
                        --    print(k, v)
                        --end
                        tooltip:AddLine("       + 2 ticks of flameshock", 252.0/255, 69.0/255, 3.0/255);

                    end
                elseif eval.spell.min_crit_if_hit ~= 0 then
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
                local tick_drop_ratio = 0.1425;
                local first_tick_weight = 3*0.1425;
                if loadout.num_set_pieces[set_tiers.pve_t10_3] >= 2 then
                    tick_drop_ratio = 0.1425*0.7;
                end

                tooltip:AddLine(string.format("%s: %d over %ds (%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f ticks)",
                                              effect,
                                              eval.spell.ot_if_hit, 
                                              eval.spell.ot_duration, 
                                              ((first_tick_weight - 0*tick_drop_ratio + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                              ((first_tick_weight - 1*tick_drop_ratio + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                              ((first_tick_weight - 2*tick_drop_ratio + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                              ((first_tick_weight - 3*tick_drop_ratio + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                              ((first_tick_weight - 4*tick_drop_ratio + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                              ((first_tick_weight - 5*tick_drop_ratio + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks,
                                              ((first_tick_weight - 6*tick_drop_ratio + 1.0)*heal_wo_sp + heal_from_sp)/eval.spell.ot_ticks
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
                tooltip:AddLine(string.format("Critical (%.2f%%): %d-%d over %.2fs (%d-%d for %d ticks)",
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
    if sw_frame.settings_frame.tooltip_cast_until_oom:GetChecked() and bit.band(spell.flags, spell_flags.cd) == 0 then

        tooltip:AddLine(string.format("%s until OOM: %.1f (%.1f casts, %.1f sec)", effect, eval.spell.effect_until_oom, eval.spell.num_casts_until_oom, eval.spell.time_until_oom));
    end

    if sw_frame.settings_frame.tooltip_stat_weights:GetChecked() and bit.band(spell.flags, spell_flags.mana_regen) == 0 then
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

        if sw_frame.settings_frame.tooltip_cast_until_oom:GetChecked() and
            bit.band(spell.flags, spell_flags.cd) == 0 then


            tooltip:AddLine(string.format("%s until OOM per SP: %.3f", effect, eval.cast_until_oom.effect_until_oom_per_sp), 0.0, 1.0, 0.0);

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


    if sw_frame.settings_frame.tooltip_more_details:GetChecked() then
        tooltip:AddLine(string.format("Spell power: %d direct / %d periodic", stats.spell_power, stats.spell_power_ot));
        tooltip:AddLine(string.format("Critical modifier %.5f", stats.crit_mod));
        tooltip:AddLine(string.format("Coefficient: %.3f direct / %.3f periodic", stats.coef, stats.ot_coef));
        tooltip:AddLine(string.format("Effect modifier: %.3f direct / %.3f periodic", stats.spell_mod, stats.spell_ot_mod));
        tooltip:AddLine(string.format("Effective coefficient: %.3f direct / %.3f periodic", stats.coef*stats.spell_mod, stats.ot_coef*stats.spell_ot_mod));
        tooltip:AddLine(string.format("Spell power effect: %.3f direct / %.3f periodic", stats.coef*stats.spell_mod*stats.spell_power, stats.ot_coef*stats.spell_ot_mod*stats.spell_power_ot));
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
        tooltip_spell_info(tooltip, spell.healing_version, loadout, effects);
    end
end

swc.tooltip.tooltip_spell_info = tooltip_spell_info;
