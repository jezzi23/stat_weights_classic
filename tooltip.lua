local _, sc = ...;

local spell_flags                               = sc.spell_flags;
local spells                                    = sc.spells;
local spids                                     = sc.spids;
local schools                                   = sc.schools;
local comp_flags                                = sc.comp_flags;

local next_rank                                 = sc.utils.next_rank;
local best_rank_by_lvl                          = sc.utils.best_rank_by_lvl;

local effect_color                              = sc.utils.effect_color;
local spell_cost                                = sc.utils.spell_cost;
local spell_cast_time                           = sc.utils.spell_cast_time;

local update_loadout_and_effects                = sc.loadout.update_loadout_and_effects;
local update_loadout_and_effects_diffed_from_ui = sc.loadout.update_loadout_and_effects_diffed_from_ui;

local set_tiers                                 = sc.equipment.set_tiers;

local spell_info                                = sc.calc.spell_info;
local stats_for_spell                           = sc.calc.stats_for_spell;
local stat_weights                              = sc.calc.stat_weights;
local cast_until_oom                            = sc.calc.cast_until_oom;
local resource_regen_info                       = sc.calc.resource_regen_info;
local only_threat_info                          = sc.calc.only_threat_info;
local evaluation_flags                          = sc.calc.evaluation_flags;

local config                                    = sc.config;
-------------------------------------------------------------------------------
local tooltip_export = {};
local eps = 0.000000001;

local function sort_stat_weights(weights, sort_by_field)

    for i = 1, #weights do
        local j = i;
        while j ~= 1 and weights[j][sort_by_field] > weights[j-1][sort_by_field] do
            local tmp = weights[j];
            weights[j] = weights[j-1];
            weights[j-1] = tmp;
            j = j - 1;
        end
    end
end

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

local function stat_weights_tooltip(tooltip, weights_list, key, weight_normalize_to, effect_type_str)

    if config.settings["tooltip_display_stat_weights_"..key] and weight_normalize_to[key.."_delta"] > 0 then
        local num_weights = #weights_list;
        local max_weights_per_line = 4;
        tooltip:AddLine(
            string.format("%s per %s: %.3f, weighing",
                          effect_type_str,
                          weight_normalize_to.display,
                          weight_normalize_to[key.."_delta"]),
            effect_color("stat_weights"));

        local stat_weights_str = "|";
        sort_stat_weights(weights_list, key.."_weight");
        for i = 1, num_weights do
            if math.abs(weights_list[i][key.."_weight"]) > eps then
                stat_weights_str = stat_weights_str ..
                    string.format(" %.3f %s |", weights_list[i][key.."_weight"], weights_list[i].display);
            else
                stat_weights_str = stat_weights_str .. string.format(" %d %s |", 0, weights_list[i].display);
            end
            if i == max_weights_per_line and i ~= num_weights then
                stat_weights_str = stat_weights_str .. "\n|";
            end
        end
        tooltip:AddLine(stat_weights_str, effect_color("stat_weights"));
    end
end

local function append_tooltip_spell_rank(tooltip, spell, lvl)
    if spell.rank == 0 then
        return;
    end

    local next_r = next_rank(spell);
    local best = best_rank_by_lvl(spell, lvl);
    local rank_str = "";
    if spell.lvl_req > lvl then
        rank_str = rank_str.."Trained at level "..spell.lvl_req;
    elseif best and best.rank ~= spell.rank then
        rank_str = rank_str.."Downranked. Best available is rank "..best.rank;
    elseif next_r then
        rank_str = rank_str.."Next rank "..next_r.rank.." available at level "..next_r.lvl_req;
    end

    if rank_str ~= "" then
        tooltip:AddLine(rank_str, effect_color("spell_rank"));
    end
end

local function append_tooltip_addon_name(tooltip)
    if config.settings.tooltip_display_addon_name then
        local loadout_extra_info = "";
        if config.loadout.use_custom_lvl then
            loadout_extra_info = string.format(" (clvl %d)", config.loadout.lvl);
        end
        tooltip:AddLine(sc.core.addon_name.." v"..sc.core.version.." | "..config.loadout.name..loadout_extra_info, 1, 1, 1);
    end
end

local spell_jump_itr = pairs(spells);
local spell_jump_key = spell_jump_itr(spells);

CreateFrame("GameTooltip", "sc_stat_calc_tooltip", nil, "SharedTooltipTemplate")
sc_stat_calc_tooltip:SetOwner(UIParent, "ANCHOR_NONE")

local header_txt = sc_stat_calc_tooltip:CreateFontString("$parentHeaderText", nil, "GameTooltipHeaderText")
local text = sc_stat_calc_tooltip:CreateFontString("$parentText", nil, "GameTooltipText")
local text_small = sc_stat_calc_tooltip:CreateFontString("$parentTextSmall", nil, "GameTooltipTextSmall")

header_txt:SetFont(GameTooltipHeaderText:GetFont())
text:SetFont(GameTooltipText:GetFont())
text_small:SetFont(GameTooltipTextSmall:GetFont())

sc_stat_calc_tooltip:AddFontStrings(header_txt, text, text_small);
-- Font for some reason is always larger than GameTooltip even though
-- they have same fonts and size. Downscale instead
sc_stat_calc_tooltip:SetScale(0.75);

GameTooltip:HookScript("OnHide", function()
    sc_stat_calc_tooltip:Hide();
end);

local spell_id_of_cleared_tooltip = 0;
local clear_tooltip_refresh_id = 463;

-- Meddles with tooltip and sets its spell id accordingly,
-- which in return is handled by "OnTooltipSetSpell" event
-- which finally calls write_tooltip() to append to tooltip
local function update_tooltip(tooltip)

    if sc.core.__sw__test_all_spells and __sc_frame.spells_frame:IsShown() then

        spell_jump_key = spell_jump_itr(spells, spell_jump_key);
        if not spell_jump_key then
            spell_jump_key = spell_jump_itr(spells);
            print("Spells circled");
        end
        __sc_frame.spell_id_viewer_editbox:SetText(tostring(spell_jump_key));
    end

    if not (PlayerTalentFrame and MouseIsOver(PlayerTalentFrame)) and tooltip:IsShown() then

        local spell_name, id = tooltip:GetSpell();
        if not spell_name then
            -- Attack tooltip may be a dummy, so link it to its actual spell id
            local attack_lname = GetSpellInfo(sc.auto_attack_spell_id);
            local txt = getglobal("GameTooltipTextLeft1");
            if txt and txt:GetText() == attack_lname then
                spell_name = attack_lname;
                id = sc.auto_attack_spell_id;
            end
        end

        -- Workaround: need to set some spell id that exists to get tooltip refreshed when
        --            looking at custom spell id tooltip
        if spells[id] or id == clear_tooltip_refresh_id or id == __sc_frame.spell_viewer_invalid_spell_id then
            if id ~= clear_tooltip_refresh_id then
                spell_id_of_cleared_tooltip = id;
            end
            if id == __sc_frame.spell_viewer_invalid_spell_id then
                tooltip:SetSpellByID(__sc_frame.spell_viewer_invalid_spell_id);
            elseif config.settings.tooltip_clear_original then
                if (not config.settings.tooltip_shift_to_show or bit.band(sc.tooltip_mod, sc.tooltip_mod_flags.SHIFT) ~= 0) and
                    bit.band(spells[spell_id_of_cleared_tooltip].flags,
                             bit.bor(spell_flags.eval, spell_flags.resource_regen, spell_flags.no_threat)) ~= 0 then
                    tooltip:SetSpellByID(clear_tooltip_refresh_id);
                else
                    tooltip:SetSpellByID(spell_id_of_cleared_tooltip);
                end
            elseif id then
                tooltip:ClearLines();
                tooltip:SetSpellByID(id);

            end
        end
    end
end

local stats = {};
local info = {};

tooltip_export.eval_mode = 0;
local eval_spid_before = 0;
local eval_dual_components = false;

local function eval_mode_scroll_fn(_, delta)
    tooltip_export.eval_mode = math.max(0, tooltip_export.eval_mode + delta);
end

-- key to dynamic flags, allowing scrolling through eval options depending on spell
local eval_mode_to_flag = {
    isolate_direct = -1,
    isolate_periodic = -1,
    isolate_mh = -1,
    isolate_oh = -1,
    expectation_of_self = -1,
};

local function append_to_txt_delimitered(str, append_str)
    if str ~= "" then
        str = str.." | ";
    end
    return str..append_str;

end

local function append_tooltip_spell_eval(tooltip, spell, spell_id, loadout, effects, eval_flags)

    local anycomp = spell.direct or spell.periodic;

    local num_eval_mode_comps = 0;
    for k in pairs(eval_mode_to_flag) do
        eval_mode_to_flag[k] = -1;
    end
    if spell_id ~= eval_spid_before then
        tooltip_export.eval_mode = 0;
        eval_spid_before = spell_id;
        eval_dual_components = false;
    end

    -- Setup dynamice evalulation modes
    if eval_dual_components then
        eval_mode_to_flag.isolate_direct = num_eval_mode_comps;
        num_eval_mode_comps = num_eval_mode_comps + 1;
        eval_mode_to_flag.isolate_periodic = num_eval_mode_comps;
        num_eval_mode_comps = num_eval_mode_comps + 1;
    end

    local dual_wield_flags = bit.bor(comp_flags.applies_mh, comp_flags.applies_oh);
    local dual_wield = loadout.m2_speed ~= nil and bit.band(anycomp.flags, dual_wield_flags) == dual_wield_flags;

    if dual_wield then
        eval_mode_to_flag.isolate_mh = num_eval_mode_comps;
        num_eval_mode_comps = num_eval_mode_comps + 1;
        eval_mode_to_flag.isolate_oh = num_eval_mode_comps;
        num_eval_mode_comps = num_eval_mode_comps + 1;
    end

    if bit.band(spell.flags, spell_flags.on_next_attack) ~= 0 then
        eval_mode_to_flag.expectation_of_self = num_eval_mode_comps;
        num_eval_mode_comps = num_eval_mode_comps + 1;
    end

    local eval_mode_combinations = bit.lshift(1, num_eval_mode_comps);
    local eval_mode_mod = tooltip_export.eval_mode%eval_mode_combinations;

    local evaluation_options = "";
    local scrollable_eval_mode_txt = "";

    -- Set eval flags depending on dynamic evaluation modes
    if dual_wield then

        if bit.band(eval_mode_mod, bit.lshift(1, eval_mode_to_flag.isolate_mh)) ~= 0 then
            eval_flags = bit.bor(eval_flags, evaluation_flags.isolate_mh);
        end
        if bit.band(eval_mode_mod, bit.lshift(1, eval_mode_to_flag.isolate_oh)) ~= 0 then
            eval_flags = bit.bor(eval_flags, evaluation_flags.isolate_oh);
        end
        local both = bit.bor(evaluation_flags.isolate_mh, evaluation_flags.isolate_oh);
        local both_band = bit.band(eval_flags, both);
        if both_band == 0 then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Combined main and offhand");
        elseif both_band == both then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Invalid");
        elseif bit.band(eval_flags, evaluation_flags.isolate_mh) ~= 0 then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Main hand");
        elseif bit.band(eval_flags, evaluation_flags.isolate_oh) ~= 0 then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Offhand");
        end
    end

    if eval_dual_components then

        if bit.band(eval_mode_mod, bit.lshift(1, eval_mode_to_flag.isolate_direct)) ~= 0 then
            eval_flags = bit.bor(eval_flags, evaluation_flags.isolate_direct);
        end
        if bit.band(eval_mode_mod, bit.lshift(1, eval_mode_to_flag.isolate_periodic)) ~= 0 then
            eval_flags = bit.bor(eval_flags, evaluation_flags.isolate_periodic);
        end
        local both = bit.bor(evaluation_flags.isolate_direct, evaluation_flags.isolate_periodic);
        local both_band = bit.band(eval_flags, both);
        if both_band == 0 then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Combined direct & periodic");
        elseif both_band == both then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Invalid");
        elseif bit.band(eval_flags, evaluation_flags.isolate_direct) ~= 0 then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Direct");
        elseif bit.band(eval_flags, evaluation_flags.isolate_periodic) ~= 0 then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Periodic");
        end
    end
    if bit.band(spell.flags, spell_flags.on_next_attack) ~= 0 then
        if bit.band(eval_mode_mod, bit.lshift(1, eval_mode_to_flag.expectation_of_self)) ~= 0 then
            eval_flags = bit.bor(eval_flags, evaluation_flags.expectation_of_self);
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Expectation of whole attack");
        else
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Expectation beyond auto attack");
        end
    end

    local hybrid_spell = spell.healing_version;
    local ctrl = bit.band(sc.tooltip_mod, sc.tooltip_mod_flags.CTRL) ~= 0;
    if hybrid_spell and
        ((config.settings.general_prioritize_heal and not ctrl)
        or
        (not config.settings.general_prioritize_heal and ctrl)) then
        spell = spell.healing_version;
    end

    stats_for_spell(stats, spell, loadout, effects, eval_flags);
    spell_info(info, spell, stats, loadout, effects, eval_flags);
    cast_until_oom(info, stats, loadout, effects, true);

    local stats_eval, stat_normalize_to;
    if bit.band(eval_flags, evaluation_flags.stat_weights) ~= 0 then
        stats_eval, stat_normalize_to = stat_weights(info, spell, loadout, effects, eval_flags);
    end

    if info.expected_direct ~= 0 and info.expected_ot ~= 0 then
        eval_dual_components = true;
    end

    local effect = "";
    local effect_per_sec = "";
    local effect_per_cost = "";
    local cost_per_sec = "";
    local cost_str = "";
    local cost_str_cap = "";
    if spell.power_type == sc.powers.mana then
        cost_str = "mana";
        cost_str_cap = "Mana";
    elseif spell.power_type == sc.powers.rage then
        cost_str = "rage";
        cost_str_cap = "Rage";
    elseif spell.power_type == sc.powers.energy then
        cost_str = "energy";
        cost_str_cap = "Energy";
    end

    local pwr;
    if bit.band(spell.flags, spell_flags.heal) ~= 0 then
        effect = "Heal";
        pwr = "HP";
        effect_per_sec = "HPS";
        effect_per_cost = "Heal per "..cost_str;
        cost_per_sec = cost_str_cap.." per sec";
    elseif bit.band(spell.flags, spell_flags.absorb) ~= 0 then
        effect = "Absorb";
        pwr = "HP";
        effect_per_sec = "HPS";
        effect_per_cost = "Absorb per "..cost_str;
        cost_per_sec = cost_str_cap.." per sec";
    else
        effect = "Damage";
        effect_per_sec = "DPS";
        effect_per_cost = "Damage per "..cost_str;
        cost_per_sec = cost_str_cap.." per sec";

        if anycomp.school1 == schools.physical then
            if bit.band(anycomp.flags, comp_flags.applies_ranged) ~= 0 then
                pwr = "RAP";
            else
                pwr = "AP";
            end
        else
            pwr = "SP";
        end
    end

    if config.settings.tooltip_display_eval_options then
        if num_eval_mode_comps ~= 0 then
            tooltip:AddLine(string.format("Eval mode %d/%d: %s",
                                          eval_mode_mod+1,
                                          eval_mode_combinations,
                                          scrollable_eval_mode_txt),

                1.0, 1.0, 1.0);

            evaluation_options = append_to_txt_delimitered(evaluation_options, "scroll wheel to change mode");
        end
        if hybrid_spell and not ctrl then
            if spell.healing_version then
                evaluation_options = append_to_txt_delimitered(evaluation_options, "CTRL for healing");
            else
                evaluation_options = append_to_txt_delimitered(evaluation_options, "CTRL for damage");
            end
        end

        if info.expected ~= info.expected_st then
            evaluation_options = append_to_txt_delimitered(evaluation_options, "ALT for 1.00x effect");
        end

        if evaluation_options ~= "" then
            tooltip:AddLine("Use " .. evaluation_options, 1.0, 1.0, 1.0);
        end
    end

    if config.settings.tooltip_display_target_info then

        local specified = "";
        if config.loadout.unbounded_aoe_targets > 1 then
            specified = string.format("%dx |", config.loadout.unbounded_aoe_targets);
        end
        if bit.band(spell.flags, bit.bor(spell_flags.absorb, spell_flags.heal)) ~= 0 then
            if loadout.friendly_hp_perc ~= 1 then
                tooltip:AddLine(string.format("Target: %.0f%% Health",
                        loadout.friendly_hp_perc * 100
                    ),
                    effect_color("target_info")
                );
             end
        else
            tooltip:AddLine(string.format("Target: %s Level %d | %.0f%% Health | %d Armor | %d Res",
                    specified,
                    loadout.target_lvl,
                    loadout.enemy_hp_perc * 100,
                    stats.armor,
                    stats.target_resi
                ),
                effect_color("target_info"));
        end
    end

    if config.loadout.force_apply_buffs or config.loadout.use_custom_talents or config.loadout.use_custom_lvl then

        tooltip:AddLine("WARNING: using custom talents, runes, lvl or buffs!", 1, 0, 0);
    end

    local display_direct_avoidance = spell.direct and
        bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 and
        bit.band(eval_flags, evaluation_flags.isolate_periodic) == 0;

    if config.settings.tooltip_display_avoidance_info and
        display_direct_avoidance then

        if spell.direct.school1 == sc.schools.physical then
            if bit.band(spell.direct.flags, comp_flags.no_attack) ~= 0 then
                tooltip:AddLine(
                    string.format("| Hit +%d%%->%.1f%% Miss | Mitigated %.1f%% |",
                        100*stats.extra_hit,
                        100*(1.0 - stats.miss),
                        100*stats.armor_dr
                        ),
                    effect_color("avoidance_info")
                );
            else
                tooltip:AddLine(
                    string.format("| Skill %s | Hit +%d%%->%.1f%% Miss | Mitigated %.1f%% |",
                        stats.attack_skill,
                        100*stats.extra_hit,
                        100*(1.0 - stats.miss),
                        100*stats.armor_dr
                        ),
                    effect_color("avoidance_info")
                );
                tooltip:AddLine(
                    string.format("| Dodge %.1f%% | Parry %.1f%% | Block %.1f%% for %d |",
                        100*stats.dodge,
                        100*stats.parry,
                        100*stats.block,
                        stats.block_amount
                        ),
                    effect_color("avoidance_info")
                );
            end
        else
            tooltip:AddLine(
                string.format("| Hit +%d%%->%.1f%% Miss | Mitigated %.1f%% |",
                    100*stats.extra_hit,
                    100*(1.0 - stats.miss),
                    100*stats.target_avg_resi),
                effect_color("avoidance_info")
            );
        end
    end

    if config.settings.tooltip_display_normal and
        bit.band(eval_flags, evaluation_flags.isolate_periodic) == 0 and
        info.num_direct_effects > 0 then

        if spell.direct then

            local hit_str = string.format(" (%.1f%%)", info.hit_normal1 * 100);
            if info.min_noncrit_if_hit1 ~= info.max_noncrit_if_hit1 then
                -- dmg spells with real direct range
                if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                    local oh = "";
                    if info.oh_info then
                        oh = string.format(" | %d-%d",
                            math.floor(info.oh_info.min_noncrit_if_hit1),
                            math.ceil(info.oh_info.max_noncrit_if_hit1)
                        );
                    end
                    tooltip:AddLine(string.format("%s%s: %d-%d%s",
                            effect,
                            hit_str,
                            math.floor(info.min_noncrit_if_hit1),
                            math.ceil(info.max_noncrit_if_hit1),
                            oh
                            ),
                        effect_color("normal")
                    );
                    -- heal spells with real direct range
                else
                    tooltip:AddLine(string.format("%s: %d-%d",
                            effect,
                            math.floor(info.min_noncrit_if_hit1),
                            math.ceil(info.max_noncrit_if_hit1)),
                        effect_color("normal")
                    );
                end
                if bit.band(eval_flags, evaluation_flags.assume_single_effect) == 0 and
                    stats.direct_jumps ~= 0 and stats.direct_jump_amp ~= 1 then
                        tooltip:AddLine(format_bounce_spell(
                                info.min_noncrit_if_hit1,
                                info.max_noncrit_if_hit1,
                                stats.direct_jumps,
                                stats.direct_jump_amp),
                            effect_color("normal")
                        );
                end
            else
                if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                    local oh = "";
                    if info.oh_info then
                        oh = string.format(" | %.1f", info.oh_info.min_noncrit_if_hit1);
                    end
                    tooltip:AddLine(string.format("%s%s: %.1f%s",
                            effect,
                            hit_str,
                            info.min_noncrit_if_hit1,
                            oh
                            ),
                        effect_color("normal")
                        );
                else
                    tooltip:AddLine(string.format("%s: %.1f",
                            effect,
                            info.min_noncrit_if_hit1),
                        effect_color("normal")
                    );
                end
            end
        end

        for i = 2, info.num_direct_effects do
            if info["min_noncrit_if_hit" .. i] ~= info["max_noncrit_if_hit" .. i] then
                tooltip:AddLine(string.format("%s: %d-%d",
                        info["direct_description" .. i],
                        math.floor(info["min_noncrit_if_hit" .. i]),
                        math.ceil(info["max_noncrit_if_hit" .. i])),
                    effect_color("normal")
                        );
            elseif info["min_noncrit_if_hit" .. i] ~= 0 then
                tooltip:AddLine(string.format("%s: %.1f",
                        info["direct_description" .. i],
                        info["min_noncrit_if_hit" .. i]),
                    effect_color("normal")
                        );
            end
        end
    end
    local crit_mod = stats.crit_mod;
    local special_crit_mod_str = "";

    if info.min_crit_if_hit1 ~= 0 and stats.special_crit_mod_tracked ~= 0 and
        (not stats["extra_effect_is_periodic" .. stats.special_crit_mod_tracked] or
        bit.band(eval_flags, evaluation_flags.isolate_direct) == 0) then

        special_crit_mod_str = " + "..stats["extra_effect_desc" .. stats.special_crit_mod_tracked];
        crit_mod = stats.crit_mod * (1.0 + stats["extra_effect_val" .. stats.special_crit_mod_tracked]);
    end

    if config.settings.tooltip_display_crit and
        bit.band(eval_flags, evaluation_flags.isolate_periodic) == 0 and
        info.num_direct_effects > 0 then

        local crit_chance_info_str = string.format(" (%.2f%%||%.2fx)", info.crit1*100, crit_mod);
        if info.crit1 ~= 0 and spell.direct then
            local oh = "";
            if info.min_crit_if_hit1 ~= info.max_crit_if_hit1 then
                if info.oh_info then
                    oh = string.format(" | %d-%d",
                        math.floor(info.oh_info.min_crit_if_hit1),
                        math.ceil(info.oh_info.max_crit_if_hit1)
                    );
                end
                tooltip:AddLine(string.format("Critical%s: %d-%d%s%s",
                        crit_chance_info_str,
                        math.floor(info.min_crit_if_hit1),
                        math.ceil(info.max_crit_if_hit1),
                        special_crit_mod_str,
                        oh),
                    effect_color("crit")
                );
            elseif info.min_crit_if_hit1 ~= 0 then
                if info.oh_info then
                    oh = string.format(" | %.1f", info.oh_info.min_crit_if_hit1);
                end
                tooltip:AddLine(string.format("Critical%s: %.1f%s%s",
                        crit_chance_info_str,
                        info.min_crit_if_hit1,
                        special_crit_mod_str,
                        oh),
                    effect_color("crit")
                );
            end

            if bit.band(eval_flags, evaluation_flags.assume_single_effect) == 0 and
                stats.direct_jumps ~= 0 and stats.direct_jump_amp ~= 1 then
                    tooltip:AddLine(format_bounce_spell(
                            info.min_crit_if_hit1,
                            info.max_crit_if_hit1,
                            stats.direct_jumps,
                            stats.direct_jump_amp),
                        effect_color("crit")
                    );
            end
        end

        for i = 2, info.num_direct_effects do
            if info["crit" .. i] ~= 0 then
                if info["min_crit_if_hit" .. i] ~= info["max_crit_if_hit" .. i] then
                    tooltip:AddLine(string.format("%s (%.2f%%): %d-%d",
                            info["direct_description" .. i],
                            info["crit" .. i] * 100,
                            math.floor(info["min_crit_if_hit" .. i]),
                            math.ceil(info["max_crit_if_hit" .. i])),
                        effect_color("crit")
                    );
                else
                    tooltip:AddLine(string.format("%s (%.2f%%): %.1f",
                            info["direct_description" .. i],
                            info["crit" .. i] * 100,
                            info["min_crit_if_hit" .. i]),
                        effect_color("crit")
                    );
                end
            end
        end
    end

    if config.settings.tooltip_display_avoidance_info and
        bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 and
        spell.periodic and
        bit.band(eval_flags, evaluation_flags.isolate_direct) == 0 and
        (not display_direct_avoidance or
            stats.target_avg_resi ~= stats.target_avg_resi_ot or
            stats.armor_dr ~= stats.armor_dr_ot) then

        if spell.periodic.school1 == sc.schools.physical then
            if bit.band(spell.periodic.flags, comp_flags.periodic) ~= 0 then
                tooltip:AddLine(
                    string.format("| Skill %s | Hit +%d%%->%.1f%% Miss | Mitigated %.1f%% |",
                        stats.attack_skill_ot,
                        100*stats.extra_hit_ot,
                        100*(1 - stats.miss_ot),
                        0
                        ),
                    effect_color("avoidance_info")
                );
                tooltip:AddLine(
                    string.format("| Dodge %.1f%% | Parry %.1f%% |",
                        100*stats.dodge_ot,
                        100*stats.parry_ot
                        ),
                    effect_color("avoidance_info")
                );
            else
                tooltip:AddLine(
                    string.format("| Skill %s | Hit +%d%%->%.1f%% Miss | Mitigated %.1f%% |",
                        stats.attack_skill_ot,
                        stats.extra_hit_ot * 100,
                        100*(1 - stats.miss_ot),
                        100*stats.armor_dr_ot
                        ),
                    effect_color("avoidance_info")
                );
                tooltip:AddLine(
                    string.format("| Dodge %.1f%% | Parry %.1f%% | Block %.1f%% for %d |",
                        100*stats.dodge_ot,
                        100*stats.parry_ot,
                        100*stats.block_ot,
                        stats.block_amount_ot
                        ),
                    effect_color("avoidance_info")
                );
            end
        else
            tooltip:AddLine(
                string.format("| Hit +%d%%->%.1f%% Miss | Mitigated %.1f%% |",
                    100*stats.extra_hit_ot,
                    100*(1 - stats.miss_ot),
                    100*stats.target_avg_resi_ot),
                effect_color("avoidance_info")
            );
        end
    end

    if config.settings.tooltip_display_normal and bit.band(eval_flags, evaluation_flags.isolate_direct) == 0 and info.num_periodic_effects > 0 then
        if spell.periodic then
            local hit_str = string.format(" (%.1f%%hit)", info.ot_hit_normal1* 100);
            if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                if spell.base_id == spids.curse_of_agony then
                    local dmg_from_sp = info.ot_min_noncrit_if_hit1 - info.ot_min_noncrit_if_hit_base1;
                    local dmg_wo_sp = info.ot_min_noncrit_if_hit_base1;
                    tooltip:AddLine(string.format("%s%s: %.1f over %.1fs (%.1f-%.1f-%.1f every %.1fs x %d)",
                            effect,
                            hit_str,
                            info.ot_min_noncrit_if_hit1,
                            info.ot_dur1,
                            (0.5 * dmg_wo_sp + dmg_from_sp) / info.ot_ticks1,
                            info.ot_min_noncrit_if_hit1 / info.ot_ticks1,
                            (1.5 * dmg_wo_sp + dmg_from_sp) / info.ot_ticks1,
                            info.ot_tick_time1,
                            info.ot_ticks1),

                        effect_color("normal")
                    );
                elseif spell.base_id == spids.starshards then
                    local dmg_from_sp = info.ot_min_noncrit_if_hit1 - info.ot_min_noncrit_if_hit_base1;
                    local dmg_wo_sp = info.ot_min_noncrit_if_hit_base1;
                    tooltip:AddLine(string.format("%s%s: %.1f over %.1fs (%.1f-%.1f-%.1f every %.1fs x %d)",
                            effect,
                            hit_str,
                            info.ot_min_noncrit_if_hit1,
                            info.ot_dur1,
                            ((2 / 3) * dmg_wo_sp + dmg_from_sp) / info.ot_ticks1,
                            info.ot_min_noncrit_if_hit1 / info.ot_ticks1,
                            ((4 / 3) * dmg_wo_sp + dmg_from_sp) / info.ot_ticks1,
                            info.ot_tick_time1,
                            info.ot_ticks1),
                        effect_color("normal")
                    );
                elseif info.ot_min_noncrit_if_hit1 ~=  info.ot_max_noncrit_if_hit1 then
                    tooltip:AddLine(string.format("%s%s: %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                            effect,
                            hit_str,
                            math.floor(info.ot_min_noncrit_if_hit1),
                            math.ceil(info.ot_max_noncrit_if_hit1),
                            info.ot_dur1,
                            math.floor(info.ot_min_noncrit_if_hit1 / info.ot_ticks1),
                            math.ceil(info.ot_max_noncrit_if_hit1 / info.ot_ticks1),
                            info.ot_tick_time1,
                            info.ot_ticks1),
                        effect_color("normal")
                    );
                else
                    tooltip:AddLine(string.format("%s%s: %.1f over %.1fs (%.1f every %.1fs x %d)",
                            effect,
                            hit_str,
                            info.ot_min_noncrit_if_hit1,
                            info.ot_dur1,
                            info.ot_min_noncrit_if_hit1 / info.ot_ticks1,
                            info.ot_tick_time1,
                            info.ot_ticks1),
                        effect_color("normal")
                    );
                end
            else
                -- wild growth
                if spell.base_id == spids.wild_growth then
                    local heal_from_sp = info.ot_min_noncrit_if_hit1 - info.ot_min_noncrit_if_hit_base1;
                    local heal_wo_sp = info.ot_min_noncrit_if_hit_base1;
                    tooltip:AddLine(
                        string.format("%s: %.1f over %ds (%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f every %.1fs x %d)",
                            effect,
                            info.ot_min_noncrit_if_hit1,
                            info.ot_dur1,
                            ((3 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / info.ot_ticks1,
                            ((2 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / info.ot_ticks1,
                            ((1 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / info.ot_ticks1,
                            ((0 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / info.ot_ticks1,
                            ((-1 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / info.ot_ticks1,
                            ((-2 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / info.ot_ticks1,
                            ((-3 * 0.1425 + 1.0) * heal_wo_sp + heal_from_sp) / info.ot_ticks1,
                            info.ot_tick_time1,
                            info.ot_ticks1),
                        effect_color("normal")
                    );
                elseif info.ot_min_noncrit_if_hit1 ~= info.ot_max_noncrit_if_hit1 then
                    tooltip:AddLine(string.format("%s: %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                            effect,
                            math.floor(info.ot_min_noncrit_if_hit1),
                            math.ceil(info.ot_max_noncrit_if_hit1),
                            info.ot_dur1,
                            math.floor(info.ot_min_noncrit_if_hit1 / info.ot_ticks1),
                            math.ceil(info.ot_max_noncrit_if_hit1 / info.ot_ticks1),
                            info.ot_tick_time1,
                            info.ot_ticks1),
                        effect_color("normal")
                    );
                else
                    tooltip:AddLine(string.format("%s: %.1f over %.1fs (%.1f every %.1fs x %d)",
                            effect,
                            info.ot_min_noncrit_if_hit1,
                            info.ot_dur1,
                            info.ot_max_noncrit_if_hit1 / info.ot_ticks1,
                            info.ot_tick_time1,
                            info.ot_ticks1),
                        effect_color("normal")
                    );
                end
            end
        end
        for i = 2, info.num_periodic_effects do
            if info["ot_min_noncrit_if_hit" .. i] ~= 0.0 then
                if info["ot_min_noncrit_if_hit" .. i] ~= info["ot_max_noncrit_if_hit" .. i] then
                    tooltip:AddLine(string.format("%s: %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                            info["ot_description" .. i],
                            math.floor(info["ot_min_noncrit_if_hit" .. i]),
                            math.ceil(info["ot_max_noncrit_if_hit" .. i]),
                            info["ot_dur" .. i],
                            math.floor(info["ot_min_noncrit_if_hit" .. i] / info["ot_ticks" .. i]),
                            math.ceil(info["ot_max_noncrit_if_hit" .. i] / info["ot_ticks" .. i]),
                            info["ot_tick_time" .. i],
                            info["ot_ticks" .. i]),
                        effect_color("normal")
                    );
                else
                    tooltip:AddLine(string.format("%s (%.2f%%): %.1f over %.1fs (%.1f every %.1fs x %d)",
                            info["ot_description" .. i],
                            stats.crit * 100,
                            info["ot_min_noncrit_if_hit" .. i],
                            info["ot_dur" .. i],
                            info["ot_min_noncrit_if_hit" .. i] / info["ot_ticks" .. i],
                            info["ot_tick_time" .. i],
                            info["ot_ticks" .. i]),
                        effect_color("normal")
                    );
                end
            end
        end


        if info.num_periodic_effects > 0 and config.settings.tooltip_display_crit then
            if stats.crit_ot ~= 0.0 and spell.periodic then
                local crit_mod_ot = stats.crit_mod_ot or stats.crit_mod;
                if stats.special_crit_mod_tracked ~= 0 then
                    crit_mod_ot = crit_mod_ot * (1.0 + stats["extra_effect_val" .. stats.special_crit_mod_tracked]);
                end
                local crit_chance_info_str =  string.format(" (%.2f%%||%.2fx)", stats.crit_ot * 100, crit_mod_ot);

                if info.ot_min_crit_if_hit1 ~= info.ot_max_crit_if_hit1 then
                    tooltip:AddLine(string.format("Critical%s: %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                            crit_chance_info_str,
                            math.floor(info.ot_min_crit_if_hit1),
                            math.ceil(info.ot_max_crit_if_hit1),
                            info.ot_dur1,
                            math.floor(info.ot_min_crit_if_hit1 / info.ot_ticks1),
                            math.ceil(info.ot_max_crit_if_hit1 / info.ot_ticks1),
                            info.ot_tick_time1,
                            info.ot_ticks1),
                        effect_color("crit")
                    );
                else
                    tooltip:AddLine(string.format("Critical%s: %.1f over %.1fs (%.1f every %.1fs x %d)",
                            crit_chance_info_str,
                            info.ot_min_crit_if_hit1,
                            info.ot_dur1,
                            info.ot_min_crit_if_hit1 / info.ot_ticks1,
                            info.ot_tick_time1,
                            info.ot_ticks1),
                        effect_color("crit")
                    );
                end
            end

            for i = 2, info.num_periodic_effects do
                if info["crit_ot" .. i] ~= 0.0 then
                    if info["ot_min_crit_if_hit" .. i] ~= info["ot_max_crit_if_hit" .. i] then
                        tooltip:AddLine(string.format("%s (%.2f%%): %d-%d over %.1fs (%d-%d every %.1fs x %d)",
                                info["ot_description" .. i],
                                stats.crit * 100,
                                math.floor(info["ot_min_crit_if_hit" .. i]),
                                math.ceil(info["ot_max_crit_if_hit" .. i]),
                                info["ot_dur" .. i],
                                math.floor(info["ot_min_crit_if_hit" .. i] / info["ot_ticks" .. i]),
                                math.ceil(info["ot_max_crit_if_hit" .. i] / info["ot_ticks" .. i]),
                                info["ot_tick_time" .. i],
                                info["ot_ticks" .. i]),
                            effect_color("crit")
                        );
                    else
                        tooltip:AddLine(string.format("%s (%.2f%%): %.1f over %.1fs (%.1f every %.1fs x %d)",
                                info["ot_description" .. i],
                                stats.crit * 100,
                                info["ot_min_crit_if_hit" .. i],
                                info["ot_dur" .. i],
                                info["ot_min_crit_if_hit" .. i] / info["ot_ticks" .. i],
                                info["ot_tick_time" .. i],
                                info["ot_ticks" .. i]),
                            effect_color("crit")
                        );
                    end
                end
            end
        end
    end

    if config.settings.tooltip_display_expected then
        local extra_info_st = "";
        local extra_info_multi = "";

        if info.expected_direct ~= 0 and info.expected_ot ~= 0 then
            local direct_ratio = info.expected_direct / (info.expected_direct + info.expected_ot);
            extra_info_multi = extra_info_multi ..
                string.format("%.1f%% direct | %.1f%% periodic", direct_ratio * 100, (1.0 - direct_ratio) * 100);

            local direct_ratio = info.expected_direct_st /
                (info.expected_direct_st + info.expected_ot_st);
            extra_info_st = extra_info_st ..
                string.format("%.1f%% direct | %.1f%% periodic", direct_ratio * 100, (1.0 - direct_ratio) * 100);
        end
        --if spell.base_id == spids.shadow_bolt and loadout.talents.pts[301] ~= 0 then
        --    local isb_uptime = 1.0 - math.pow(1.0 - stats.crit, 4);

        --    extra_info_st = extra_info_st .. string.format("ISB debuff uptime %.1f%%", 100 * isb_uptime);
        --    extra_info_multi = extra_info_multi .. string.format("ISB debuff uptime %.1f%%", 100 * isb_uptime);
        --end


        if info.expected ~= info.expected_st then
            if extra_info_st == "" then
                extra_info_st = "(1.00x effect)";
            else
                extra_info_st = "(" .. extra_info_st .. " | 1.00x effect)";
            end
            local aoe_ratio = string.format("%.2fx effect", info.expected / info.expected_st);
            if extra_info_multi == "" then
                extra_info_multi = "(" .. aoe_ratio .. ")";
            else
                extra_info_multi = "(" .. extra_info_multi .. " | " .. aoe_ratio .. ")";
            end
            tooltip:AddLine(string.format("Expected: %.1f %s", info.expected_st, extra_info_st),
                effect_color("expectation")
            );
            tooltip:AddLine(string.format("Optimistic: %.1f %s", info.expected, extra_info_multi),
                effect_color("expectation")
            );
        else
            if extra_info_st ~= "" then
                extra_info_st = "(" .. extra_info_st .. ")";
            end
            if extra_info_multi ~= "" then
                extra_info_multi = "(" .. extra_info_multi .. ")";
            end
            tooltip:AddLine("Expected" .. string.format(": %.1f %s", info.expected, extra_info_st),
                effect_color("expectation")
            );
        end
    end

    if config.settings.tooltip_display_effect_per_sec and stats.cast_time ~= 0 then
        local periodic_part = "";
        if info.num_periodic_effects > 0 and info.effect_per_dur ~= 0 and info.effect_per_dur ~= info.effect_per_sec then
            periodic_part = string.format("| %.1f periodic for %d sec", info.effect_per_dur,
                info.longest_ot_duration);
        end

        tooltip:AddLine(string.format("%s: %.1f by execution time %s",
                effect_per_sec,
                info.effect_per_sec, periodic_part),
            effect_color("effect_per_sec")
        );
    end
    if config.settings.tooltip_display_threat and info.threat ~= 0 then
        tooltip:AddLine(string.format("Expected threat: %.1f", info.threat),
            effect_color("threat")
        );
    end
    if config.settings.tooltip_display_threat_per_sec and
        stats.cast_time ~= 0 and
        info.threat_per_sec ~= 0 then

        tooltip:AddLine(string.format("Threat per sec: %.1f", info.threat_per_sec),
            effect_color("threat")
        );
    end
    if config.settings.tooltip_display_avg_cast then
        local tooltip_cast = spell_cast_time(spell_id);
        if bit.band(spell.flags, bit.bor(spell_flags.uses_attack_speed, spell_flags.instant)) ~= 0 or
            (not tooltip_cast or math.abs(tooltip_cast-stats.cast_time_nogcd) > 0.00001) then

            local oh = "";
            if info.oh_stats then
                oh = string.format(" | %.3f", info.oh_stats.cast_time);
            end
            if stats.cast_time_nogcd ~= stats.cast_time then
                tooltip:AddLine(
                    string.format("Expected execution time: %.1f sec (%.3f but gcd capped)", stats.gcd, stats.cast_time_nogcd),
                    effect_color("avg_cast")
                );
            else
                tooltip:AddLine(string.format("Expected execution time: %.3f%s sec", stats.cast_time, oh),
                    effect_color("avg_cast")
                );
            end
        end
    end
    local tooltip_cost = spell_cost(spell_id);
    if config.settings.tooltip_display_avg_cost and
       spell.power_type == sc.powers.mana and
       (not tooltip_cost or tooltip_cost ~= stats.cost) then

        tooltip:AddLine(string.format("Expected cost: %.1f", stats.cost),
            effect_color("avg_cost")
        );
    end
    if config.settings.tooltip_display_effect_per_cost and stats.cost ~= 0 then
        tooltip:AddLine(effect_per_cost .. ": " .. string.format("%.2f", info.effect_per_cost),
            effect_color("effect_per_cost")
        );
    end
    if config.settings.tooltip_display_threat_per_cost and stats.cost ~= 0 and info.threat_per_cost ~= 0 then
        tooltip:AddLine(string.format("Threat per %s: %.2f", cost_str, info.threat_per_cost),
            effect_color("effect_per_cost")
        );
    end
    if config.settings.tooltip_display_cost_per_sec and
       stats.cost ~= 0 and
       spell.power_type == sc.powers.mana then

        tooltip:AddLine(
            cost_per_sec .. ": " .. string.format("- %.1f out | + %.1f in", info.cost_per_sec, info.mp1),
            effect_color("cost_per_sec")
        );
    end

    if config.settings.tooltip_display_cast_until_oom and
       spell.power_type == sc.powers.mana and
       (not config.settings.tooltip_hide_cd_coom or bit.band(spell.flags, spell_flags.cd) == 0)
        then
        tooltip:AddLine(
            string.format("%s until OOM: %.1f (%.1f casts, %.1f sec)", effect, info.effect_until_oom,
                info.num_casts_until_oom, info.time_until_oom),
            effect_color("normal")
        );
        if loadout.extra_mana ~= 0 then
            tooltip:AddLine(string.format("                                   casting from %d %s",
                                          loadout.resources[powers.mana] + loadout.extra_mana, cost_str),
                effect_color("normal")
            );
        end
    end

    if config.settings.tooltip_display_base_mod then
        if spell.direct and spell.direct.min ~= info.min_noncrit_if_hit_base1 then
            local armor_dr_adjusted = 1/(1 - stats.armor_dr);
            if info.min_noncrit_if_hit_base1 ~= info.max_noncrit_if_hit_base1 then
                tooltip:AddLine(string.format("Direct base: %.1f to %.1f (+%d x %.3f mod) + %d = %.1f to %.1f",
                        info.base_min,
                        info.base_max,
                        stats.base_mod_flat,
                        stats.base_mod,
                        stats.effect_mod_flat,
                        info.min_noncrit_if_hit_base1*armor_dr_adjusted,
                        info.max_noncrit_if_hit_base1*armor_dr_adjusted
                    ),
                    effect_color("sp_effect")
                );
                    
            else
                tooltip:AddLine(string.format("Direct base: %.1f (+%d x %.3f mod) + %d = %.1f",
                        info.base_min,
                        stats.base_mod_flat,
                        stats.base_mod,
                        stats.effect_mod_flat,
                        info.min_noncrit_if_hit_base1*armor_dr_adjusted
                    ),
                    effect_color("sp_effect")
                );

            end
        end
        if spell.periodic and spell.periodic.min ~= info.ot_min_noncrit_if_hit_base1 then
            local armor_dr_adjusted = 1/(1 - stats.armor_dr_ot);
            if info.ot_min_noncrit_if_hit_base1 ~= info.ot_max_noncrit_if_hit_base1 then
                tooltip:AddLine(string.format("Periodic base = %.1f to %.1f (+%d * %.3f mod) + %d = %.1f to %.1f",
                        info.ot_base_min,
                        info.ot_base_max,
                        stats.base_mod_ot_flat,
                        stats.base_mod_ot,
                        stats.effect_mod_ot_flat,
                        info.ot_min_noncrit_if_hit_base1*armor_dr_adjusted,
                        info.ot_max_noncrit_if_hit_base1*armor_dr_adjusted
                    ),
                    effect_color("sp_effect")
                );
                    
            else
                tooltip:AddLine(string.format("Periodic base = %.1f (+%d * %.3f mod) +%d = %.1f",
                        info.ot_base_min,
                        stats.base_mod_ot_flat,
                        stats.base_mod_ot,
                        stats.effect_mod_ot_flat,
                        info.ot_min_noncrit_if_hit_base1*armor_dr_adjusted
                    ),
                    effect_color("sp_effect")
                );

            end
        end
    end

    if config.settings.tooltip_display_sp_effect_calc then

        if spell.direct and stats.coef > 0 and bit.band(eval_flags, evaluation_flags.isolate_periodic) == 0 then
            local armor_dr_adjusted = 1/(1 - stats.armor_dr);
            tooltip:AddLine(string.format("Direct:    %.3f coef * %.3f mod * %d %s = %.1f",
                    stats.coef,
                    stats.spell_mod*armor_dr_adjusted,
                    stats.spell_power,
                    pwr,
                    stats.coef * stats.spell_mod * stats.spell_power * armor_dr_adjusted
                ),
                effect_color("sp_effect")
            );
        end
        if spell.periodic and stats.coef_ot > 0 and bit.band(eval_flags, evaluation_flags.isolate_direct) == 0 then
            local armor_dr_adjusted = 1/(1 - stats.armor_dr_ot);
            tooltip:AddLine(string.format("Periodic: %d ticks * %.3f coef * %.3f mod * %d %s",
                    info.ot_ticks1,
                    stats.coef_ot,
                    stats.spell_mod_ot*armor_dr_adjusted,
                    stats.spell_power_ot,
                    pwr
                ),
                effect_color("sp_effect")
            );
            tooltip:AddLine(string.format("            = %d ticks * %.1f = %.1f",
                    info.ot_ticks1,
                    stats.coef_ot * stats.spell_mod_ot * stats.spell_power_ot * armor_dr_adjusted,
                    stats.coef_ot * stats.spell_mod_ot * stats.spell_power_ot * info.ot_ticks1 * armor_dr_adjusted),
                effect_color("sp_effect")
            );
        end
    end
    if config.settings.tooltip_display_sp_effect_ratio and
        ((spell.direct and stats.coef > 0) or (spell.periodic and stats.coef_ot > 0)) then
        local effect_base = 0;
        local effect_total = 0;
        if spell.direct then
            effect_base = effect_base + 0.5*(info.min_noncrit_if_hit_base1 + info.max_noncrit_if_hit_base1);
            effect_total = effect_total + 0.5*(info.min_noncrit_if_hit1 + info.max_noncrit_if_hit1);
        end
        if spell.periodic then
            effect_base = effect_base + 0.5*(info.ot_min_noncrit_if_hit_base1 + info.ot_max_noncrit_if_hit_base1);
            effect_total = effect_total + 0.5*(info.ot_min_noncrit_if_hit1 + info.ot_max_noncrit_if_hit1);
        end
        local effect_sp = effect_total - effect_base;

        tooltip:AddLine(string.format("%s=%d improves base by %.1f%%",
                pwr,
                stats.spell_power,
                100*effect_sp/effect_base
            ),
            effect_color("sp_effect")
        );
        tooltip:AddLine(string.format("Total: %.1f%% base, %.1f%% %s",
                100*effect_base/(effect_base + effect_sp),
                100*effect_sp/(effect_base + effect_sp),
                pwr
            ),
            effect_color("sp_effect")
        );
    end
    if config.settings.tooltip_display_spell_rank then
        append_tooltip_spell_rank(tooltip, spell, loadout.lvl);
    end
    if config.settings.tooltip_display_spell_id then
        tooltip:AddLine(string.format("Spell ID: %d", spell_id),
            effect_color("spell_rank")
        );
    end

    if bit.band(eval_flags, evaluation_flags.stat_weights) ~= 0 and stat_normalize_to then

        stat_weights_tooltip(tooltip, stats_eval, "effect", stat_normalize_to, effect);
        stat_weights_tooltip(tooltip, stats_eval, "effect_per_sec", stat_normalize_to, effect_per_sec);

        if spell.power_type == sc.powers.mana and
            info.cost_per_sec > 0 and
            (not config.settings.tooltip_hide_cd_coom or bit.band(spell.flags, spell_flags.cd) == 0) then

            stat_weights_tooltip(tooltip, stats_eval, "effect_until_oom", stat_normalize_to, effect.." until OOM:");
        end
    end

end

local function write_tooltip_spell_info(tooltip, spell, spell_id, loadout, effects)
    -- Set gray spell rank in upper-right corner again after custom SetSpellByID clears it
    if spell.rank ~= 0 then
        local txt_right = getglobal("GameTooltipTextRight1");
        if txt_right then
            txt_right:SetTextColor(0.50196081399918, 0.50196081399918, 0.50196081399918, 1.0);
            txt_right:SetText("Rank " .. spell.rank);
            txt_right:Show();
        end
    end

    if __sc_frame.tooltip_frame.tooltip_num_checked == 0 or
        (config.settings.tooltip_shift_to_show and bit.band(sc.tooltip_mod, sc.tooltip_mod_flags.SHIFT) == 0) then
        return;
    end

    if config.settings.tooltip_clear_original or tooltip ~= GameTooltip or not GetSpellInfo(spell.base_id) then
        local txt_left = getglobal("GameTooltipTextLeft1");
        if txt_left then

            local lname = GetSpellInfo(spell.base_id);
            if not lname then
                lname = ""..spell.base_id;
            end
            txt_left:SetTextColor(1.0, 1.0, 1.0, 1.0);
            txt_left:SetText(lname);
            txt_left:Show();
        end
    end

    local eval_flags = 0;
    if config.settings.tooltip_display_stat_weights_effect or
        config.settings.tooltip_display_stat_weights_effect_per_sec or
        config.settings.tooltip_display_stat_weights_effect_until_oom then

        eval_flags = bit.bor(eval_flags, sc.calc.evaluation_flags.stat_weights);
    end

    if bit.band(sc.tooltip_mod, sc.tooltip_mod_flags.ALT) ~= 0 then
        eval_flags = bit.bor(eval_flags, sc.calc.evaluation_flags.assume_single_effect);
    end

    if (bit.band(spell.flags, spell_flags.eval) ~= 0) then
        if tooltip == GameTooltip then
            append_tooltip_addon_name(tooltip);
            if __sc_frame.calculator_frame:IsShown() and __sc_frame:IsShown() then
                tooltip:AddLine("AFTER STAT CHANGES", 1.0, 0.0, 0.0);
            end
        else
            tooltip:AddLine("BEFORE STAT CHANGES", 1.0, 0.0, 0.0);
        end

        append_tooltip_spell_eval(tooltip, spell, spell_id, loadout, effects, eval_flags);
    else
        if (bit.band(spell.flags, spell_flags.resource_regen) ~= 0) and
            config.settings.tooltip_display_resource_regen then

            append_tooltip_addon_name(tooltip);
            resource_regen_info(info, spell, spell_id, loadout, effects);
            tooltip:AddLine(string.format("Restored for player: %d", math.floor(info.total_restored)),
                effect_color("avg_cost")
            );
            if spell.periodic then
                tooltip:AddLine(string.format("Periodically: %d every %.1fs x %d",
                    math.floor(info.restored),
                    info.tick_time,
                    math.floor(info.ticks)
                    ),
                    effect_color("avg_cost")
                );
            end
        elseif bit.band(spell.flags, spell_flags.only_threat) ~= 0 and
               (config.settings.tooltip_display_threat or
               config.settings.tooltip_display_threat_per_sec or
               config.settings.tooltip_display_threat_per_cost) then

            only_threat_info(info, stats, spell, loadout, effects, eval_flags);

            append_tooltip_addon_name(tooltip);
            if config.settings.tooltip_display_avoidance_info and spell.direct then

                if spell.direct.school1 == sc.schools.physical and
                    bit.band(spell.direct.flags, bit.bor(comp_flags.always_hit, comp_flags.no_attack)) == 0 then

                    tooltip:AddLine(
                        string.format("| Skill %s | Hit +%d%%->%.1f%% Miss |",
                            stats.attack_skill,
                            100*stats.extra_hit,
                            100 * (1.0 - stats.miss)
                            ),
                        effect_color("avoidance_info")
                    );
                    tooltip:AddLine(
                        string.format("| Dodge %.1f%% | Parry %.1f%% | Block %.1f%% for %d |",
                            100*stats.dodge,
                            100*stats.parry,
                            100*stats.block,
                            stats.block_amount
                            ),
                        effect_color("avoidance_info")
                    );
                else
                    tooltip:AddLine(
                        string.format("| Hit +%d%%->%.1f%% Miss |",
                            100*stats.extra_hit,
                            100 * (1.0 - stats.miss)
                            ),
                        effect_color("avoidance_info")
                    );
                end
            end

            if config.settings.tooltip_display_threat then
                tooltip:AddLine(string.format("Expected threat: %.1f", info.threat),
                    effect_color("threat")
                );
            end
            if config.settings.tooltip_display_threat_per_sec and
                stats.cast_time ~= 0 then

                tooltip:AddLine(string.format("Threat per sec: %.1f", info.threat_per_sec),
                    effect_color("threat")
                );
            end
            if config.settings.tooltip_display_avg_cast then
                local tooltip_cast = spell_cast_time(spell_id);
                if bit.band(spell.flags, bit.bor(spell_flags.uses_attack_speed, spell_flags.instant)) ~= 0 or
                    (not tooltip_cast or math.abs(tooltip_cast-stats.cast_time_nogcd) > 0.00001) then

                    if stats.cast_time_nogcd ~= stats.cast_time then
                        tooltip:AddLine(
                            string.format("Expected execution time: %.1f sec (%.3f but gcd capped)", stats.gcd, stats.cast_time_nogcd),
                            effect_color("avg_cast")
                        );
                    else
                        tooltip:AddLine(string.format("Expected execution time: %.3f sec", stats.cast_time),
                            effect_color("avg_cast")
                        );
                    end
                end
            end

            if config.settings.tooltip_display_threat_per_cost and info.threat_per_cost ~= 0 then
                local cost_str = "";
                if spell.power_type == sc.powers.mana then
                    cost_str = "mana";
                elseif spell.power_type == sc.powers.rage then
                    cost_str = "rage";
                elseif spell.power_type == sc.powers.energy then
                    cost_str = "energy";
                end
                tooltip:AddLine(string.format("Threat per %s: %.2f", cost_str, info.threat_per_cost),
                    effect_color("effect_per_cost")
                );
            end
        end

        if config.settings.tooltip_display_spell_rank then
            append_tooltip_spell_rank(tooltip, spell, loadout.lvl);
        end
        if config.settings.tooltip_display_spell_id then
            tooltip:AddLine(string.format("Spell ID: %d", spell_id),
                effect_color("spell_rank")
            );
        end
    end
    tooltip:Show();
end

local function write_tooltip()

    local _, spell_id = GameTooltip:GetSpell();

    if spell_id == clear_tooltip_refresh_id then
        spell_id = spell_id_of_cleared_tooltip;
    elseif spell_id == __sc_frame.spell_viewer_invalid_spell_id then
        spell_id = tonumber(__sc_frame.spell_id_viewer_editbox:GetText());
    elseif config.settings.tooltip_clear_original and
        (not config.settings.tooltip_shift_to_show or bit.band(sc.tooltip_mod, sc.tooltip_mod_flags.SHIFT) ~= 0) then
        --if spells[spell_id] and bit.band(spells[spell_id].flags, spell_flags.eval) ~= 0 then
        if spells[spell_id] then
            spell_id_of_cleared_tooltip = spell_id;
            --GameTooltip:ClearLines();
            --GameTooltip:SetSpellByID(clear_tooltip_refresh_id);
            return;
        end
    end

    local spell = spells[spell_id];

    if not spell then
        return;
    end

    if not __sc_frame.calculator_frame:IsShown() or not __sc_frame:IsShown() then

        local loadout, effects = update_loadout_and_effects();
        write_tooltip_spell_info(GameTooltip, spell, spell_id, loadout, effects);
    else

        local loadout, effects, effects_diffed = update_loadout_and_effects_diffed_from_ui();
        write_tooltip_spell_info(GameTooltip, spell, spell_id, loadout, effects_diffed);

        sc_stat_calc_tooltip:ClearLines();
        sc_stat_calc_tooltip:SetOwner(GameTooltip, "ANCHOR_LEFT", 0, -select(2, sc_stat_calc_tooltip:GetSize()));
        write_tooltip_spell_info(sc_stat_calc_tooltip, spell, spell_id, loadout, effects);
    end
end

tooltip_export.tooltip_stat_display             = tooltip_stat_display;
tooltip_export.sort_stat_weights                = sort_stat_weights;
tooltip_export.format_bounce_spell              = format_bounce_spell;
tooltip_export.write_tooltip                    = write_tooltip;
tooltip_export.update_tooltip                   = update_tooltip;
tooltip_export.append_tooltip_spell_rank        = append_tooltip_spell_rank;
tooltip_export.tooltip_eval_mode                = eval_mode;
tooltip_export.eval_mode_scroll_fn              = eval_mode_scroll_fn;

sc.tooltip = tooltip_export;

