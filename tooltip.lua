local _, sc = ...;

local spell_flags                               = sc.spell_flags;
local spells                                    = sc.spells;
local spids                                     = sc.spids;
local schools                                   = sc.schools;
local comp_flags                                = sc.comp_flags;
local powers                                    = sc.powers;

local next_rank                                 = sc.utils.next_rank;
local best_rank_by_lvl                          = sc.utils.best_rank_by_lvl;
local highest_learned_rank                      = sc.utils.highest_learned_rank;
local effect_color                              = sc.utils.effect_color;
local spell_cost                                = sc.utils.spell_cost;
local spell_cast_time                           = sc.utils.spell_cast_time;
local format_number                             = sc.utils.format_number;
local color_by_lvl_diff                         = sc.utils.color_by_lvl_diff;

local update_loadout_and_effects                = sc.loadouts.update_loadout_and_effects;
local update_loadout_and_effects_diffed_from_ui = sc.loadouts.update_loadout_and_effects_diffed_from_ui;
local effects_finalize_forced                   = sc.loadouts.effects_finalize_forced;
local cpy_effects                               = sc.loadouts.cpy_effects;
local empty_effects                             = sc.loadouts.empty_effects;

local apply_item_cmp                            = sc.equipment.apply_item_cmp;
local slots                                     = sc.equipment.slots;

local fight_types                               = sc.calc.fight_types;
local stat_weights                              = sc.calc.stat_weights;
local cast_until_oom                            = sc.calc.cast_until_oom;
local spell_diff                                = sc.calc.spell_diff;
local evaluation_flags                          = sc.calc.evaluation_flags;
local effect_flags                              = sc.calc.effect_flags;
local calc_spell_eval                           = sc.calc.calc_spell_eval;
local calc_spell_threat                         = sc.calc.calc_spell_threat;
local calc_spell_resource_regen                 = sc.calc.calc_spell_resource_regen;

local config                                    = sc.config;
-------------------------------------------------------------------------------
local tooltip_export = {};

local eps = 0.000000001;
local tooltip_effects_diffed_finalized = {};
local tooltip_effects_finalized = {};
empty_effects(tooltip_effects_diffed_finalized);
empty_effects(tooltip_effects_finalized);

-- Tooltip add, share signature so that optional works
local function add_double_line(tooltip, lhs, rhs, rgb_r, rgb_g, rgb_b)
    if lhs == "" then
        lhs = " ";
    end
    if rhs == "" then
        rhs = " ";
    end
    tooltip:AddDoubleLine(lhs, rhs, rgb_r, rgb_g, rgb_b, rgb_r, rgb_g, rgb_b);
end
local function add_single_line(tooltip, lhs, rhs, rgb_r, rgb_g, rgb_b)
    local combined;
    if lhs == "" or rhs == "" then
        combined = lhs..rhs;
    else
        combined = lhs.." "..rhs;
    end
    tooltip:AddLine(combined, rgb_r, rgb_g, rgb_b);
end

local add_line = add_double_line;

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
        bounce_str = bounce_str .. string.format(" %.0f to %.0f  + ",
            falloff * math.floor(min_hit),
            falloff * math.ceil(max_hit));
        falloff = falloff * falloff;
    end
    bounce_str = bounce_str .. string.format(" %.0f to %.0f",
        falloff * math.floor(min_hit),
        falloff * math.ceil(max_hit));
    return bounce_str;
end

local function stat_weights_tooltip(tooltip, weights_list, key, weight_normalize_to, effect_type_str)

    if config.settings["tooltip_display_stat_weights_"..key] and weight_normalize_to[key.."_delta"] > 0 then
        local num_weights = #weights_list;
        local max_weights_per_line = 4;

        add_line(
            tooltip,
            string.format("%s per %s:",
                          effect_type_str,
                          weight_normalize_to.display),
            string.format("%.3f, weighing",
                          weight_normalize_to[key.."_delta"]),
            effect_color("stat_weights")
        );

        local stat_weights_str = "|";
        sort_stat_weights(weights_list, key.."_weight");
        for i = 1, num_weights do
            if math.abs(weights_list[i][key.."_weight"]) > eps then
                stat_weights_str = stat_weights_str ..
                    string.format(" %.3f %s |", weights_list[i][key.."_weight"], weights_list[i].display);
            else
                stat_weights_str = stat_weights_str .. string.format(" %d %s |", 0, weights_list[i].display);
            end
            if (i == max_weights_per_line and i ~= num_weights) or i == num_weights then

                stat_weights_str = stat_weights_str;
                add_line(tooltip, "", stat_weights_str, effect_color("stat_weights"));
                stat_weights_str = "|";
            end
        end
    end
end

local function append_tooltip_spell_rank(tooltip, spell, lvl)
    if spell.rank == 0 then
        return;
    end

    local next_r = next_rank(spell);
    local best = best_rank_by_lvl(spell, lvl);

    if spell.lvl_req > lvl then
        add_line(tooltip, "Trained at level:", string.format("%d", spell.lvl_req), effect_color("spell_rank"));
    elseif best and best.rank ~= spell.rank then
        add_line(tooltip, "Downranked. Best available rank:", string.format("%d", best.rank), effect_color("spell_rank"));
    elseif next_r then
        add_line(tooltip, "Next rank:", string.format("%d available at level %d", next_r.rank, next_r.lvl_req), effect_color("spell_rank"));
    end
end

local function append_tooltip_addon_name(tooltip)
    if config.settings.tooltip_display_addon_name then
        local loadout_extra_info = "";
        if config.loadout.use_custom_lvl then
            loadout_extra_info = string.format(" (clvl %d)", config.loadout.lvl);
        end
        add_line(tooltip,
                 sc.core.addon_name.." v"..sc.core.version.." | "..config.loadout.name..loadout_extra_info,
                 "", 1, 1, 1);
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


local spell_tooltip_cached = {
    loadout = nil,
    effects = nil,
    effects_finalized = nil,
    needs_update = true,
}; -- filled on update need

local tooltip_spell_update_id = 0;

-- Meddles with tooltip and sets its spell id accordingly,
-- which in return is handled by "OnTooltipSetSpell" event
-- which finally calls write_spell_tooltip() to append to tooltip
local function update_tooltip(tooltip, mod_change)

    if sc.core.__sw__test_all_spells and __sc_frame.spells_frame:IsShown() then

        spell_jump_key = spell_jump_itr(spells, spell_jump_key);
        if not spell_jump_key then
            spell_jump_key = spell_jump_itr(spells);
            print("Spells circled");
        end
        __sc_frame.spell_id_viewer_editbox:SetText(tostring(spell_jump_key));
    end
    if not (PlayerTalentFrame and MouseIsOver(PlayerTalentFrame)) and tooltip:IsShown() then
        local _, id = tooltip:GetSpell();

        -- Try to skip periodic update if everything is normal and nothing changed
        if (not __sc_frame.calculator_frame:IsShown() or not __sc_frame:IsShown()) and
            not mod_change then

            local update_id;
            spell_tooltip_cached.loadout, spell_tooltip_cached.effects, spell_tooltip_cached.effects_finalized, update_id =
                update_loadout_and_effects();
            local updated = update_id > tooltip_spell_update_id;
            tooltip_spell_update_id = update_id;

            if not updated then
                spell_tooltip_cached.needs_update = false;
                return;
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

local function append_tooltip_spell_eval(tooltip, spell, spell_id, loadout, effects_base, effects_finalized, eval_flags)

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
    local dual_wield = loadout.attack_delay_oh ~= nil and bit.band(anycomp.flags, dual_wield_flags) == dual_wield_flags;

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
    end

    if eval_dual_components then
        if bit.band(eval_mode_mod, bit.lshift(1, eval_mode_to_flag.isolate_direct)) ~= 0 then
            eval_flags = bit.bor(eval_flags, evaluation_flags.isolate_direct);
        end
        if bit.band(eval_mode_mod, bit.lshift(1, eval_mode_to_flag.isolate_periodic)) ~= 0 then
            eval_flags = bit.bor(eval_flags, evaluation_flags.isolate_periodic);
        end
    end
    if bit.band(spell.flags, spell_flags.on_next_attack) ~= 0 then
        if bit.band(eval_mode_mod, bit.lshift(1, eval_mode_to_flag.expectation_of_self)) ~= 0 then
            eval_flags = bit.bor(eval_flags, evaluation_flags.expectation_of_self);
        end
    end

    local hybrid_spell = spell.healing_version;
    local ctrl = bit.band(sc.tooltip_mod, sc.tooltip_mod_flags.CTRL) ~= 0;
    if hybrid_spell and
        ((config.settings.general_prio_heal and not ctrl)
        or
        (not config.settings.general_prio_heal and ctrl)) then
        spell = spell.healing_version;
    end

    local info, stats = calc_spell_eval(spell, loadout, effects_finalized, eval_flags);
    cast_until_oom(info, spell, stats, loadout, effects_finalized, true);

    local stats_eval, stat_normalize_to;
    if bit.band(eval_flags, evaluation_flags.stat_weights) ~= 0 then
        stats_eval, stat_normalize_to = stat_weights(info, spell, loadout, effects_base, eval_flags);
    end

    if info.expected_direct ~= 0 and info.expected_ot ~= 0 then
        if not eval_dual_components then
            -- hack for first time view, can't know if dual components
            -- before spell is calculated and it's too late
            eval_mode_combinations = eval_mode_combinations*4;
        end
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


    if dual_wield then
        local both = bit.bor(evaluation_flags.isolate_mh, evaluation_flags.isolate_oh);
        local both_band = bit.band(eval_flags, both);
        if both_band == 0 then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Combined main and offhand");
        elseif both_band == both then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "INVALID");
        elseif bit.band(eval_flags, evaluation_flags.isolate_mh) ~= 0 then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Main hand");
        elseif bit.band(eval_flags, evaluation_flags.isolate_oh) ~= 0 then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Offhand");
        end
    end

    if eval_dual_components then

        local both = bit.bor(evaluation_flags.isolate_direct, evaluation_flags.isolate_periodic);
        local both_band = bit.band(eval_flags, both);
        if both_band == 0 then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Combined direct & periodic");
        elseif both_band == both then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "INVALID");
        elseif bit.band(eval_flags, evaluation_flags.isolate_direct) ~= 0 then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Direct");
        elseif bit.band(eval_flags, evaluation_flags.isolate_periodic) ~= 0 then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Periodic");
        end
    end
    if bit.band(spell.flags, spell_flags.on_next_attack) ~= 0 then
        if bit.band(eval_flags, evaluation_flags.expectation_of_self) ~= 0 then
            eval_flags = bit.bor(eval_flags, evaluation_flags.expectation_of_self);
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Expectation of whole attack");
        else
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Expectation beyond auto attack");
        end
    end

    if info.aoe_to_single_ratio > 1 then
        if info.expected ~= info.expected_st then
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Optimistic effect");
        else
            scrollable_eval_mode_txt = append_to_txt_delimitered(scrollable_eval_mode_txt, "Single effect");
        end
    end

    if config.settings.tooltip_display_eval_options then
        if eval_mode_combinations > 1 then
            add_line(tooltip,
                     string.format("Eval mode %d/%d:",
                                   eval_mode_mod+1,
                                   eval_mode_combinations),
                     string.format("%s", scrollable_eval_mode_txt),

                1.0, 1.0, 1.0);

            evaluation_options = append_to_txt_delimitered(evaluation_options, "Scroll wheel to change mode");
        else

            if scrollable_eval_mode_txt ~= "" then
                add_line(tooltip, "Eval mode:", scrollable_eval_mode_txt, 1.0, 1.0, 1.0);
            end
        end
        if hybrid_spell and not ctrl then
            if spell.healing_version then
                evaluation_options = append_to_txt_delimitered(evaluation_options, "CTRL for healing");
            else
                evaluation_options = append_to_txt_delimitered(evaluation_options, "CTRL for damage");
            end
        end

        if info.aoe_to_single_ratio > 1 then
            if info.expected ~= info.expected_st then
                evaluation_options = append_to_txt_delimitered(evaluation_options, "ALT for 1.00x effect");
            else
                evaluation_options = append_to_txt_delimitered(evaluation_options, string.format("ALT for %.2fx effect", info.aoe_to_single_ratio));
            end
        end

        if evaluation_options ~= "" then
            add_line(tooltip, "Use:", evaluation_options, 1.0, 1.0, 1.0);
        end
    end

    if config.settings.tooltip_display_target_info then

        local specified = "";
        if config.loadout.unbounded_aoe_targets > 1 then
            specified = string.format("%dx |", config.loadout.unbounded_aoe_targets);
        end
        if bit.band(spell.flags, bit.bor(spell_flags.absorb, spell_flags.heal)) ~= 0 then
            if loadout.friendly_hp_perc ~= 1 then

                add_line(tooltip,
                         "Target:",
                         string.format("%.0f%% Health", loadout.friendly_hp_perc * 100),
                         effect_color("target_info"));
             end
        else
            local en_hp = "";
            if loadout.enemy_hp_perc ~= 1 then
                en_hp = string.format(" | %.0f%% Health", 100*loadout.enemy_hp_perc);
            end
            add_line(
                tooltip,
                "Target:",
                string.format("%s Level %s%d|r | %d Armor | %d Res%s",
                    specified,
                    color_by_lvl_diff(loadout.lvl, loadout.target_lvl),
                    loadout.target_lvl,
                    stats.armor,
                    stats.target_resi,
                    en_hp
                ),
                effect_color("target_info")
            );
        end
    end

    if config.loadout.force_apply_buffs or config.loadout.use_custom_talents or config.loadout.use_custom_lvl then

        add_line(
            tooltip,
            "WARNING:",
            "using custom talents, glyphs, runes, lvl or buffs!",
            1, 0, 0);
    end

    local display_direct_avoidance = spell.direct and
        bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 and
        bit.band(eval_flags, evaluation_flags.isolate_periodic) == 0;

    if config.settings.tooltip_display_avoidance_info and
        display_direct_avoidance then

        if spell.direct.school1 == sc.schools.physical then
            if bit.band(spell.direct.flags, comp_flags.no_attack) ~= 0 then
                add_line(
                    tooltip,
                    "",
                    string.format("| Hit +%d%%->%.1f%% Miss | Mitigated %.1f%% |",
                        100*stats.extra_hit,
                        100*stats.miss,
                        100*stats.armor_dr
                        ),
                    effect_color("avoidance_info")
                );
            else
                add_line(
                    tooltip,
                    "",
                    string.format("| Skill %s | Hit +%d%%->%.1f%% Miss | Mitigated %.1f%% |",
                        stats.attack_skill,
                        100*stats.extra_hit,
                        100*stats.miss,
                        100*stats.armor_dr
                        ),
                    effect_color("avoidance_info")
                );
                add_line(
                    tooltip,
                    "",
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
            add_line(
                tooltip,
                "",
                string.format("| Hit +%d%%->%.1f%% Miss | Mitigated %.1f%% |",
                    100*stats.extra_hit,
                    100*stats.miss,
                    100*stats.target_avg_resi),
                effect_color("avoidance_info")
            );
        end
    end

    if config.settings.tooltip_display_normal and
        bit.band(eval_flags, evaluation_flags.isolate_periodic) == 0 and
        info.num_direct_effects > 0 and
info.min_noncrit_if_hit1
        then

        if spell.direct then

            local hit_str;
            local hit = info.hit_normal1 * info.direct_utilization1;
            if hit ~= 1 then
                hit_str = string.format(" (%.2f%%)",  hit * 100);
            else
                hit_str = "";
            end
            if info.min_noncrit_if_hit1 ~= info.max_noncrit_if_hit1 then
                -- dmg spells with real direct range
                local oh = "";
                if info.oh_info then
                    oh = string.format(" | %.0f to %.0f",
                        math.floor(info.oh_info.min_noncrit_if_hit1),
                        math.ceil(info.oh_info.max_noncrit_if_hit1)
                    );
                end 
                add_line(
                    tooltip,
                    string.format("%s%s:", effect, hit_str),
                    string.format("%.0f to %.0f%s",
                        math.floor(info.min_noncrit_if_hit1),
                        math.ceil(info.max_noncrit_if_hit1),
                        oh
                    ),
                    effect_color("normal")
                );
                if bit.band(eval_flags, evaluation_flags.assume_single_effect) == 0 and
                    stats.direct_jumps ~= 0 and stats.direct_jump_amp ~= 1 then
                        add_line(tooltip,
                            "",
                            format_bounce_spell(
                                info.min_noncrit_if_hit1,
                                info.max_noncrit_if_hit1,
                                stats.direct_jumps,
                                stats.direct_jump_amp
                            ),
                            effect_color("normal")
                        );
                end
            else
                local oh = "";
                if info.oh_info then
                    oh = string.format(" | %.1f", info.oh_info.min_noncrit_if_hit1);
                end
                add_line(
                    tooltip,
                    string.format("%s%s:", effect, hit_str),
                    string.format("%.1f%s", info.min_noncrit_if_hit1, oh),
                    effect_color("normal")
                );
            end
        end

        for i = 1, info.num_direct_effects do
            if i ~= 1 or not spell.direct then
                local oh = "";
                if info.oh_info then
                    oh = " | ...";
                end
                if i == info.glance_index then
                    local avg_red = 0.5*(stats.glance_min+stats.glance_max);
                    add_line(
                        tooltip,
                        string.format("%s (%.2f%%|%.2fx to %.2fx):",
                            info["direct_description" .. i],
                            100*info["hit_normal" .. i]*info["direct_utilization" .. i],
                            stats.glance_min,
                            stats.glance_max
                            ),
                        string.format("(%.0f to %.0f) to (%.0f to %.0f)%s",
                            math.floor(info["min_noncrit_if_hit" .. i]*stats.glance_min/avg_red),
                            math.ceil(info["max_noncrit_if_hit" .. i]*stats.glance_min/avg_red),
                            math.floor(info["min_noncrit_if_hit" .. i]*stats.glance_max/avg_red),
                            math.ceil(info["max_noncrit_if_hit" .. i]*stats.glance_max/avg_red),
                            oh
                            ),
                        effect_color("normal")
                      );

                elseif info["min_noncrit_if_hit" .. i] ~= info["max_noncrit_if_hit" .. i] then
                    add_line(
                        tooltip,
                        string.format("%s (%.2f%%):",
                            info["direct_description" .. i],
                            100*info["hit_normal" .. i]*info["direct_utilization" .. i]),

                        string.format("%.0f to %.0f%s",
                            math.floor(info["min_noncrit_if_hit" .. i]),
                            math.ceil(info["max_noncrit_if_hit" .. i]),
                            oh),
                        effect_color("normal")
                            );
                elseif info["min_noncrit_if_hit" .. i] ~= 0 then
                    add_line(
                        tooltip,
                        string.format("%s (%.2f%%):",
                            info["direct_description" .. i],
                            100*info["hit_normal" .. i]*info["direct_utilization" .. i]),
                        string.format("%.1f%s",
                            info["min_noncrit_if_hit" .. i],
                            oh),
                        effect_color("normal")
                            );
                end
            end
        end
    end

    if config.settings.tooltip_display_crit and
        bit.band(eval_flags, evaluation_flags.isolate_periodic) == 0 and
        info.num_direct_effects > 0 then

        local crit_mod = stats.crit_mod;
        local special_crit_mod_str = "";

        if info.min_crit_if_hit1 ~= 0 and stats.special_crit_mod_tracked ~= 0 and
            (bit.band(stats["extra_effect_flags" .. stats.special_crit_mod_tracked], effect_flags.is_periodic) == 0 or
            bit.band(eval_flags, evaluation_flags.isolate_direct) == 0) then

            special_crit_mod_str = " + "..stats["extra_effect_desc" .. stats.special_crit_mod_tracked];
            crit_mod = stats.crit_mod * (1.0 + stats["extra_effect_val" .. stats.special_crit_mod_tracked]);
        end

        local crit_chance_info_str = string.format(" (%.2f%%||%.2fx)", info.crit1*100, crit_mod);
        if spell.direct and (info.crit1 ~= 0 or 
            (spell.direct.school1 == schools.physical and
                bit.band(spell.direct.flags, comp_flags.no_attack) == 0)) then
            local oh = "";
            if info.min_crit_if_hit1 ~= info.max_crit_if_hit1 then
                if info.oh_info then
                    oh = string.format(" | %.0f to %.0f",
                        math.floor(info.oh_info.min_crit_if_hit1),
                        math.ceil(info.oh_info.max_crit_if_hit1)
                    );
                end
                add_line(
                    tooltip,
                    string.format("Critical%s:", crit_chance_info_str, oh),
                    string.format("%.0f to %0.f%s%s",
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
                add_line(
                    tooltip,
                string.format("Critical%s:", crit_chance_info_str, oh),
                string.format("%.1f%s%s",
                        info.min_crit_if_hit1,
                        special_crit_mod_str,
                        oh),
                    effect_color("crit")
                );
            end

            if bit.band(eval_flags, evaluation_flags.assume_single_effect) == 0 and
                stats.direct_jumps ~= 0 and stats.direct_jump_amp ~= 1 then
                    add_line(
                        tooltip,
                        "",
                        format_bounce_spell(
                            info.min_crit_if_hit1,
                            info.max_crit_if_hit1,
                            stats.direct_jumps,
                            stats.direct_jump_amp),
                        effect_color("crit")
                    );
            end
        end
        if stats.crit_excess > 0 then
            add_line(
                tooltip,
                "Critical pushed off attack table:",
                string.format("%.2f%%", 100*stats.crit_excess),
                effect_color("crit")
            );
        end

        for i = 1, info.num_direct_effects do
            if i ~= 1 or not spell.direct then
                if info["crit" .. i] ~= 0 then
                    if info["min_crit_if_hit" .. i] ~= info["max_crit_if_hit" .. i] then
                        add_line(
                            tooltip,
                            string.format("%s (%.2f%%):",
                                info["direct_description" .. i],
                                100*info["crit" .. i]*info["direct_utilization" .. i]),
                            string.format("%.0f to %.0f",
                                math.floor(info["min_crit_if_hit" .. i]),
                                math.ceil(info["max_crit_if_hit" .. i])),
                            effect_color("crit")
                        );
                    else
                        add_line(
                            tooltip,
                            string.format("%s (%.2f%%):",
                                info["direct_description" .. i],
                                100*info["crit" .. i]*info["direct_utilization" .. i]),
                            string.format("%.1f",
                                info["min_crit_if_hit" .. i]),
                            effect_color("crit")
                        );
                    end
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
                add_line(
                    tooltip,
                    "",
                    string.format("| Skill %s | Hit +%d%%->%.1f%% Miss | Mitigated %.1f%% |",
                        stats.attack_skill_ot,
                        100*stats.extra_hit_ot,
                        100*stats.miss_ot,
                        0
                        ),
                    effect_color("avoidance_info")
                );
                add_line(
                    tooltip,
                    "",
                    string.format("| Dodge %.1f%% | Parry %.1f%% |",
                        100*stats.dodge_ot,
                        100*stats.parry_ot
                        ),
                    effect_color("avoidance_info")
                );
            else
                add_line(
                    tooltip,
                    "",
                    string.format("| Skill %s | Hit +%d%%->%.1f%% Miss | Mitigated %.1f%% |",
                        stats.attack_skill_ot,
                        stats.extra_hit_ot * 100,
                        100*stats.miss_ot,
                        100*stats.armor_dr_ot
                        ),
                    effect_color("avoidance_info")
                );
                add_line(
                    tooltip,
                    "",
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
            add_line(
                tooltip,
                "",
                string.format("| Hit +%d%%->%.1f%% Miss | Mitigated %.1f%% |",
                    100*stats.extra_hit_ot,
                    100*stats.miss_ot,
                    100*stats.target_avg_resi_ot),
                effect_color("avoidance_info")
            );
        end
    end

    if config.settings.tooltip_display_normal and bit.band(eval_flags, evaluation_flags.isolate_direct) == 0 and info.num_periodic_effects > 0 then
        if spell.periodic then
            local hit_str;
            local hit = info.ot_hit_normal1 * info.ot_utilization1;
            if hit ~= 1 then
                hit_str = string.format(" (%.2f%%)",  hit * 100);
            else
                hit_str = "";
            end
            if spell.base_id == spids.curse_of_agony then
                local dmg_from_sp = info.ot_min_noncrit_if_hit1 - info.ot_min_noncrit_if_hit_base1;
                local dmg_wo_sp = info.ot_min_noncrit_if_hit_base1;
                add_line(
                    tooltip,
                    string.format("%s%s:", effect, hit_str),
                    string.format("%.1f over %.1fs (%.1f,%.1f,%.1f every %.1fs x %.0f)",
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
                add_line(
                    tooltip,
                    string.format("%s%s:", effect, hit_str),
                    string.format("%.1f over %.1fs (%.1f,%.1f,%.1f every %.1fs x %.0f)",
                        info.ot_min_noncrit_if_hit1,
                        info.ot_dur1,
                        ((2 / 3) * dmg_wo_sp + dmg_from_sp) / info.ot_ticks1,
                        info.ot_min_noncrit_if_hit1 / info.ot_ticks1,
                        ((4 / 3) * dmg_wo_sp + dmg_from_sp) / info.ot_ticks1,
                        info.ot_tick_time1,
                        info.ot_ticks1),
                    effect_color("normal")
                );
            elseif spell.base_id == spids.wild_growth then
                local heal_from_sp = info.ot_min_noncrit_if_hit1 - info.ot_min_noncrit_if_hit_base1;
                local heal_wo_sp = info.ot_min_noncrit_if_hit_base1;
                add_line(
                    tooltip,
                    string.format("%s:", effect),
                    string.format("%.1f over %.0fs (%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f every %.1fs x %.0f)",
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
                add_line(
                    tooltip,
                    string.format("%s%s:", effect, hit_str),
                    string.format("%.0f to %.0f over %.1fs (%.0f to %.0f every %.1fs x %.0f)",
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
                add_line(
                    tooltip,
                    string.format("%s%s:", effect, hit_str),
                    string.format("%.1f over %.1fs (%.1f every %.1fs x %.0f)",
                        info.ot_min_noncrit_if_hit1,
                        info.ot_dur1,
                        info.ot_min_noncrit_if_hit1 / info.ot_ticks1,
                        info.ot_tick_time1,
                        info.ot_ticks1),
                    effect_color("normal")
                );
            end
        end
        for i = 1, info.num_periodic_effects do
            if i ~= 1 or not spell.periodic then
                if info["ot_min_noncrit_if_hit" .. i] ~= 0.0 then
                    if info["ot_min_noncrit_if_hit" .. i] ~= info["ot_max_noncrit_if_hit" .. i] then
                        add_line(
                            tooltip,
                            string.format("%s (%.2f%%):",
                                info["ot_description" .. i],
                                100*info["ot_hit_normal" .. i]*info["ot_utilization" .. i]),
                            string.format("%.0f to %.0f over %.1fs (%.0f to %.0f every %.1fs x %.0f)",
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
                        add_line(
                            tooltip,
                            string.format("%s (%.2f%%):",
                                info["ot_description" .. i],
                                100*info["ot_hit_normal" .. i]*info["ot_utilization" .. i]),
                            string.format("%.1f over %.1fs (%.1f every %.1fs x %.0f)",
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
        end


        if info.num_periodic_effects > 0 and config.settings.tooltip_display_crit then
            if stats.crit_ot ~= 0.0 and spell.periodic then
                local crit_mod_ot = stats.crit_mod_ot or stats.crit_mod;
                if stats.special_crit_mod_tracked ~= 0 then
                    crit_mod_ot = crit_mod_ot * (1.0 + stats["extra_effect_val" .. stats.special_crit_mod_tracked]);
                end
                local crit_chance_info_str =  string.format(" (%.2f%%||%.2fx)", stats.crit_ot * 100, crit_mod_ot);

                if info.ot_min_crit_if_hit1 ~= info.ot_max_crit_if_hit1 then
                    add_line(
                        tooltip,
                        string.format("Critical%s:", crit_chance_info_str),
                        string.format("%.0f to %.0f over %.1fs (%.0f to %.0f every %.1fs x %.0f)",
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
                    add_line(
                        tooltip,
                        string.format("Critical%s:", crit_chance_info_str),
                        string.format("%.1f over %.1fs (%.1f every %.1fs x %.0f)",
                            info.ot_min_crit_if_hit1,
                            info.ot_dur1,
                            info.ot_min_crit_if_hit1 / info.ot_ticks1,
                            info.ot_tick_time1,
                            info.ot_ticks1),
                        effect_color("crit")
                    );
                end
            end

            for i = 1, info.num_periodic_effects do
                if i ~= 1 or not spell.periodic then
                    if info["ot_crit" .. i] ~= 0.0 then
                        if info["ot_min_crit_if_hit" .. i] ~= info["ot_max_crit_if_hit" .. i] then
                            add_line(
                                tooltip,
                                string.format("%s (%.2f%%):",
                                    info["ot_description" .. i],
                                    100*(info["ot_crit" .. i]*info["ot_utilization" .. i])),
                                string.format("%.0f to %.0f over %.1fs (%.0f to %.0f every %.1fs x %.0f)",
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
                            add_line(
                                tooltip,
                                string.format("%s (%.2f%%):",
                                    info["ot_description" .. i],
                                    100*info["ot_crit" .. i]*info["ot_utilization" .. i]),
                                string.format("%.1f over %.1fs (%.1f every %.1fs x %.0f)",
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
        if config.settings.general_average_proc_effects and spell.base_id == spids.shadow_bolt and loadout.talents.pts[301] ~= 0 then
            local isb_uptime = 1.0 - math.pow(1.0 - stats.crit, 4);

            extra_info_st = extra_info_st .. string.format("ISB debuff uptime %.1f%%", 100 * isb_uptime);
            extra_info_multi = extra_info_multi .. string.format("ISB debuff uptime %.1f%%", 100 * isb_uptime);
        end

        if info.aoe_to_single_ratio > 1 then
            if extra_info_st == "" then
                extra_info_st = "1.00x effect";
            else
                extra_info_st = "(" .. extra_info_st .. " | 1.00x effect)";
            end
        end

        if extra_info_st ~= "" then
            extra_info_st = "(" .. extra_info_st .. ")";
        end
        add_line(
            tooltip,
            "Expected:",
            string.format("%.1f %s", info.expected_st, extra_info_st),
            effect_color("expectation")
        );

        if info.expected ~= info.expected_st then
            local aoe_ratio = string.format("%.2fx effect", info.aoe_to_single_ratio);
            if extra_info_multi == "" then
                extra_info_multi = "(" .. aoe_ratio .. ")";
            else
                extra_info_multi = "(" .. extra_info_multi .. " | " .. aoe_ratio .. ")";
            end
            add_line(
                tooltip,
                "Optimistic",
                string.format("%.1f %s", info.expected, extra_info_multi),
                effect_color("expectation")
            );
        end
    end

    if config.settings.tooltip_display_effect_per_sec and stats.cast_time ~= 0 then
        local periodic_part = "";
        if info.num_periodic_effects > 0 and info.effect_per_dur ~= 0 and info.effect_per_dur ~= info.effect_per_sec then
            periodic_part = string.format("| %.1f periodic for %.0f sec", info.effect_per_dur,
                info.longest_ot_duration);
        end

        add_line(
            tooltip,
            string.format("%s:", effect_per_sec),
            string.format("%.1f by execution time %s", info.effect_per_sec, periodic_part),
            effect_color("effect_per_sec")
        );
    end
    if config.settings.tooltip_display_threat and info.threat ~= 0 then
        add_line(
            tooltip,
            "Expected threat:",
            string.format("%.1f", info.threat),
            effect_color("threat")
        );
    end
    if config.settings.tooltip_display_threat_per_sec and
        stats.cast_time ~= 0 and
        info.threat_per_sec ~= 0 then

        add_line(
            tooltip,
            "Threat per sec:",
            string.format("%.1f", info.threat_per_sec),
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
                add_line(
                    tooltip,
                    "Expected execution time:",
                    string.format("%.1f sec (%.3f but gcd capped)", stats.gcd, stats.cast_time_nogcd),
                    effect_color("avg_cast")
                );
            else
                add_line(
                    tooltip,
                    "Expected execution time:",
                    string.format("%.3f%s sec", stats.cast_time, oh),
                    effect_color("avg_cast")
                );
            end
        end
    end
    local tooltip_cost = spell_cost(spell_id);
    if config.settings.tooltip_display_avg_cost and
       spell.power_type == sc.powers.mana and
       (not tooltip_cost or tooltip_cost ~= stats.cost) then

        add_line(
            tooltip,
            "Expected cost:",
            string.format("%.1f", stats.cost),
            effect_color("avg_cost")
        );
    end
    if config.settings.tooltip_display_effect_per_cost and stats.cost ~= 0 then
        add_line(
            tooltip,
            string.format("%s:", effect_per_cost),
            string.format("%.2f", info.effect_per_cost),
            effect_color("effect_per_cost")
        );
    end
    if config.settings.tooltip_display_threat_per_cost and stats.cost ~= 0 and info.threat_per_cost ~= 0 then
        add_line(
            tooltip,
            string.format("Threat per %s:", cost_str),
            string.format("%.2f", info.threat_per_cost),
            effect_color("effect_per_cost")
        );
    end
    if config.settings.tooltip_display_cost_per_sec and
       stats.cost ~= 0 and
       spell.power_type == sc.powers.mana then

        add_line(
            tooltip,
            string.format("%s:", cost_per_sec),
            string.format("- %.1f out | + %.1f in", info.cost_per_sec, info.mp1),
            effect_color("cost_per_sec")
        );
    end

    if config.settings.tooltip_display_cast_until_oom and
       spell.power_type == sc.powers.mana and
       (not config.settings.tooltip_hide_cd_coom or bit.band(spell.flags, spell_flags.cd) == 0)
        then

        add_line(
            tooltip,
            string.format("%s until OOM:", effect),
            string.format("%.1f (%.1f casts, %.1f sec)",
                info.effect_until_oom,
                info.num_casts_until_oom,
                info.time_until_oom),
            effect_color("normal")
        );
        if config.loadout.extra_mana ~= 0 then
            add_line(
                tooltip,
                "",
                string.format("       casting from %.0f %s",
                    loadout.resources[powers.mana] + config.loadout.extra_mana, cost_str),
                effect_color("normal")
            );
        end
    end

    if config.settings.tooltip_display_base_mod then
        if spell.direct and spell.direct.min ~= info.min_noncrit_if_hit_base1 then
            local armor_dr_adjusted = 1/(1 - stats.armor_dr);
            if info.min_noncrit_if_hit_base1 ~= info.max_noncrit_if_hit_base1 then
                add_line(
                    tooltip,
                    "Direct base:",
                    string.format("%.1f to %.1f (+%.0f x %.3f mod) + %.0f = %.1f to %.1f",
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
                add_line(
                    tooltip,
                    "Direct base:",
                    string.format("%.1f (+%.0f x %.3f mod) + %.0f = %.1f",
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
                add_line(
                    tooltip,
                    "Periodic base:",
                    string.format("%.1f to %.1f (+%.0f * %.3f mod) + %.0f = %.1f to %.1f",
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
                add_line(
                    tooltip,
                    "Periodic base:",
                    string.format("%.1f (+%.0f * %.3f mod) +%.0f = %.1f",
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
            add_line(
                tooltip,
                "Direct:   ",
                string.format("%.3f coef * %.3f mod * %.0f %s = %.1f",
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
            add_line(
                tooltip,
                "Periodic:",
                string.format("%.0f ticks * %.3f coef * %.3f mod * %.0f %s",
                    info.ot_ticks1,
                    stats.coef_ot,
                    stats.spell_mod_ot*armor_dr_adjusted,
                    stats.spell_power_ot,
                    pwr
                ),
                effect_color("sp_effect")
            );
            add_line(
                tooltip,
                "           ",
                string.format("= %.0f ticks * %.1f = %.1f",
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

        add_line(
            tooltip,
            string.format("Improved by %.0f %s:", stats.spell_power, pwr),
            string.format("%.1f%% (%.1f%% base, %.1f%% %s)",
                100*effect_sp/effect_base,
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
        add_line(
            tooltip,
            "Spell ID:",
            string.format("%d", spell_id),
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

local function write_tooltip_spell_info(tooltip, spell, spell_id, loadout, effects, effects_finalized)
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

    if (config.settings.general_prio_multiplied_effect and bit.band(sc.tooltip_mod, sc.tooltip_mod_flags.ALT) ~= 0)
        or
        (not config.settings.general_prio_multiplied_effect and bit.band(sc.tooltip_mod, sc.tooltip_mod_flags.ALT) == 0) then

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

        append_tooltip_spell_eval(tooltip, spell, spell_id, loadout, effects, effects_finalized, eval_flags);
    else

        if (bit.band(spell.flags, spell_flags.resource_regen) ~= 0) and
            config.settings.tooltip_display_resource_regen then

            append_tooltip_addon_name(tooltip);
            local info = calc_spell_resource_regen(spell, spell_id, loadout, effects_finalized);

            add_line(
                tooltip,
                "Restored for player:",
                string.format("%.0f", math.floor(info.total_restored)),
                effect_color("avg_cost")
            );
            if spell.periodic then
                add_line(
                    tooltip,
                    "Periodically:",
                    string.format("%.0f every %.1fs x %.0f",
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

            local info, stats = calc_spell_threat(spell, loadout, effects_finalized, eval_flags);

            append_tooltip_addon_name(tooltip);
            if config.settings.tooltip_display_avoidance_info and spell.direct then

                if spell.direct.school1 == sc.schools.physical and
                    bit.band(spell.direct.flags, bit.bor(comp_flags.always_hit, comp_flags.no_attack)) == 0 then

                    add_line(
                        tooltip,
                        "",
                        string.format("| Skill %s | Hit +%d%%->%.1f%% Miss |",
                            stats.attack_skill,
                            100*stats.extra_hit,
                            100*stats.miss
                            ),
                        effect_color("avoidance_info")
                    );
                    add_line(
                        tooltip,
                        "",
                        string.format("| Dodge %.1f%% | Parry %.1f%% | Block %.1f%% for %d |",
                            100*stats.dodge,
                            100*stats.parry,
                            100*stats.block,
                            stats.block_amount
                            ),
                        effect_color("avoidance_info")
                    );
                else
                    add_line(
                        tooltip,
                        "",
                        string.format("| Hit +%d%%->%.1f%% Miss |",
                            100*stats.extra_hit,
                            100*stats.miss
                            ),
                        effect_color("avoidance_info")
                    );
                end
            end

            if config.settings.tooltip_display_threat then
                add_line(
                    tooltip,
                    "Expected threat:",
                    string.format("%.1f", info.threat),
                    effect_color("threat")
                );
            end
            if config.settings.tooltip_display_threat_per_sec and
                stats.cast_time ~= 0 then

                add_line(
                    tooltip,
                    "Threat per sec:",
                    string.format("%.1f", info.threat_per_sec),
                    effect_color("threat")
                );
            end
            if config.settings.tooltip_display_avg_cast then
                local tooltip_cast = spell_cast_time(spell_id);
                if bit.band(spell.flags, bit.bor(spell_flags.uses_attack_speed, spell_flags.instant)) ~= 0 or
                    (not tooltip_cast or math.abs(tooltip_cast-stats.cast_time_nogcd) > 0.00001) then

                    if stats.cast_time_nogcd ~= stats.cast_time then
                        add_line(
                            tooltip,
                            "Expected execution time:",
                            string.format("%.1f sec (%.3f but gcd capped)", stats.gcd, stats.cast_time_nogcd),
                            effect_color("avg_cast")
                        );
                    else
                        add_line(
                            tooltip,
                            "Expected execution time:",
                            string.format("%.3f sec", stats.cast_time),
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
                add_line(
                    tooltip,
                    string.format("Threat per %s:", cost_str),
                    string.format("%.2f", info.threat_per_cost),
                    effect_color("effect_per_cost")
                );
            end
        end

        if config.settings.tooltip_display_spell_rank then
            append_tooltip_spell_rank(tooltip, spell, loadout.lvl);
        end
        if config.settings.tooltip_display_spell_id then
            add_line(
                tooltip,
                "Spell ID:",
                string.format("%d", spell_id),
                effect_color("spell_rank")
            );
        end
    end
    tooltip:Show();
end

local function write_spell_tooltip()

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

    if config.settings.tooltip_double_line then
        add_line = add_double_line;
    else
        add_line = add_single_line;
    end

    if not __sc_frame.calculator_frame:IsShown() or not __sc_frame:IsShown() then

        if spell_tooltip_cached.needs_update then
            spell_tooltip_cached.loadout, spell_tooltip_cached.effects, spell_tooltip_cached.effects_finalized = update_loadout_and_effects();

        end
        write_tooltip_spell_info(GameTooltip, spell, spell_id,
                                 spell_tooltip_cached.loadout,
                                 spell_tooltip_cached.effects,
                                 spell_tooltip_cached.effects_finalized);

    else

        spell_tooltip_cached.needs_update = true;

        local loadout, effects, effects_diffed = update_loadout_and_effects_diffed_from_ui(true);

        cpy_effects(tooltip_effects_diffed_finalized, effects_diffed);
        effects_finalize_forced(loadout, tooltip_effects_diffed_finalized);
        write_tooltip_spell_info(GameTooltip, spell, spell_id, loadout, effects_diffed, tooltip_effects_diffed_finalized);

        sc_stat_calc_tooltip:ClearLines();
        sc_stat_calc_tooltip:SetOwner(GameTooltip, "ANCHOR_LEFT", 0, -select(2, sc_stat_calc_tooltip:GetSize()));

        cpy_effects(tooltip_effects_finalized, effects);
        effects_finalize_forced(loadout, tooltip_effects_finalized);

        write_tooltip_spell_info(sc_stat_calc_tooltip, spell, spell_id, loadout, effects, tooltip_effects_finalized);
    end
end

local inv_type_to_slot_ids = {
    INVTYPE_AMMO = {slots.AmmoSlot},
    INVTYPE_HEAD = {slots.HeadSlot},
    INVTYPE_NECK = {slots.NeckSlot},
    INVTYPE_SHOULDER = {slots.ShoulderSlot},
    INVTYPE_BODY = {slots.ShirtSlot},
    INVTYPE_CHEST = {slots.ChestSlot},
    INVTYPE_ROBE = {slots.ChestSlot},
    INVTYPE_WAIST = {slots.WaistSlot},
    INVTYPE_LEGS = {slots.LegsSlot},
    INVTYPE_FEET = {slots.FeetSlot},
    INVTYPE_WRIST = {slots.WristSlot},
    INVTYPE_HAND = {slots.HandsSlot},
    INVTYPE_FINGER = {slots.Finger0Slot, slots.Finger1Slot},
    INVTYPE_TRINKET = {slots.Trinket0Slot, slots.Trinket1Slot},
    INVTYPE_CLOAK = {slots.BackSlot},
    INVTYPE_WEAPON = {slots.MainHandSlot, slots.SecondaryHandSlot},
    INVTYPE_2HWEAPON = {slots.MainHandSlot},
    INVTYPE_WEAPONMAINHAND = {slots.MainHandSlot},
    INVTYPE_WEAPONOFFHAND = {slots.SecondaryHandSlot},
    INVTYPE_SHIELD = {slots.SecondaryHandSlot},
    INVTYPE_HOLDABLE = {slots.SecondaryHandSlot},
    INVTYPE_TABARD = {slots.TabardSlot},
    INVTYPE_RANGED = {slots.RangedSlot},
    INVTYPE_RANGEDRIGHT = {slots.RangedSlot},
    INVTYPE_RELIC = {slots.RangedSlot},
};

local cached_spells_cmp_item_slots = { [1] = {len = 0, diff_list = {}}, [2] = {len = 0, diff_list = {}} };
local tooltip_item_id_last = 0;
local item_tooltip_frames_hidden = false;

local function make_item_tooltip_line_frames()

    local role_tex = GameTooltip:CreateTexture(nil, "ARTWORK");
    role_tex:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-ROLES");
    role_tex:SetSize(16, 16);

    return {
        role_tex = role_tex,
        change_fstr = GameTooltip:CreateFontString(nil, "ARTWORK", "GameFontNormal"),
        first_fstr = GameTooltip:CreateFontString(nil, "ARTWORK", "GameFontNormal"),
        second_fstr = GameTooltip:CreateFontString(nil, "ARTWORK", "GameFontNormal"),
    };
end

local empty_tex = "Interface\\Buttons\\UI-Quickslot2";
local new_item = {};
local old_item1 = {};
local old_item2 = {};
local headers = {
    change_fstr = GameTooltip:CreateFontString(nil, "ARTWORK", "GameFontNormal"),
    first_fstr = GameTooltip:CreateFontString(nil, "ARTWORK", "GameFontNormal"),
    second_fstr = GameTooltip:CreateFontString(nil, "ARTWORK", "GameFontNormal"),
};

for _, v in pairs(headers) do
    v:SetTextColor(effect_color("effect_per_sec"));
end

local item_tooltip_effects_update_id = 0;

-- The only reliable way to get alignment on item comparison numbers to be nicely aligned
-- is to set them as frame objects because monospaced fonts seem to be broken ingame
local function write_item_tooltip(tooltip, mod, mod_change)
    if config.settings.tooltip_shift_to_show and bit.band(mod, sc.tooltip_mod_flags.SHIFT) == 0 then
        return;
    end

    new_item.lname, new_item.link = GameTooltip:GetItem();
    new_item.id = nil;
    if new_item.link then

        local item_id, _, _, _, _, _, suffix_id =
            strsplit(":", new_item.link:match("|Hitem:(.+)|h"));
        new_item.id = tonumber(item_id);
        new_item.suffix_id = tonumber(suffix_id);
    else
        return;
    end

    _, _, new_item.quality, _, _, _, _, _, new_item.inv_type, new_item.tex, _, new_item.class_id, new_item.subclass_id = GetItemInfo(new_item.link);

    if not new_item.inv_type then
        return;
    end
    local cmp_slots = inv_type_to_slot_ids[new_item.inv_type];
    if not cmp_slots then
        return;
    end

    local loadout, effects, effects_finalized, update_id = update_loadout_and_effects();
    local updated = update_id > item_tooltip_effects_update_id;
    item_tooltip_effects_update_id = update_id;

    if new_item.id == loadout.items[cmp_slots[1]] or
        (cmp_slots[2] and new_item.id == loadout.items[cmp_slots[2]]) then
        return;
    end
    local fight_type = config.settings.calc_fight_type;
    if bit.band(mod, sc.tooltip_mod_flags.ALT) ~= 0 then
        if fight_type == fight_types.repeated_casts then
            fight_type = fight_types.cast_until_oom;
        else
            fight_type = fight_types.repeated_casts;
        end
    end

    -- "On next attack" spells eval the entire attack instead of net gain
    local eval_flags = bit.bor(sc.overlay.overlay_eval_flags(), evaluation_flags.expectation_of_self);
    local should_fix_wpn_skill =
        new_item.class_id == 2 and -- weapon type
        loadout.lvl ~= sc.max_lvl and
        config.settings.tooltip_item_leveling_skill_normalize;

    if should_fix_wpn_skill then
        eval_flags = bit.bor(eval_flags, evaluation_flags.fix_weapon_skill_to_level);
    end

    local effects_diffed = sc.loadouts.diffed;
    if tooltip_item_id_last ~= new_item.id or updated or mod_change then
        -- actual evaluation update step and overwrites cache

        for item_fits_in_slot, slot in pairs(cmp_slots) do

            local slot_cmp;
            local old_item;
            if item_fits_in_slot > 1 then
                slot_cmp = cached_spells_cmp_item_slots[2];
                old_item = old_item2;
            else
                slot_cmp = cached_spells_cmp_item_slots[1];
                old_item = old_item1;
            end
            old_item.link = GetInventoryItemLink("player", slot);
            old_item.id = GetInventoryItemID("player", slot);
            if old_item.link then

                local _, _, _, _, _, _, suffix_id =
                    strsplit(":", old_item.link:match("|Hitem:(.+)|h"));

                old_item.lname, _, old_item.quality, _, _, _, _, _, old_item.inv_type, old_item.tex, _, _, old_item.subclass_id = GetItemInfo(old_item.link);
                old_item.suffix_id = tonumber(suffix_id);
            else
                old_item.tex = empty_tex;
                old_item.subclass_id = nil;
            end

            apply_item_cmp(loadout, effects, effects_diffed, new_item, old_item, slot);

            local i = 0;
            slot_cmp.len = 0;

            for k, _ in pairs(config.settings.spell_calc_list) do

                if config.settings.calc_list_use_highest_rank and spells[k] then
                    k = highest_learned_rank(spells[k].base_id);
                end
                if k and spells[k] and bit.band(spells[k].flags, spell_flags.eval) ~= 0 then

                    i = i + 1;
                    slot_cmp.diff_list[i] = slot_cmp.diff_list[i] or {frames = make_item_tooltip_line_frames()};

                    spell_diff(slot_cmp.diff_list[i],
                               fight_type,
                               spells[k],
                               k,
                               loadout,
                               effects_finalized,
                               effects_diffed,
                               eval_flags);

                    -- for spells with both heal and dmg
                    if spells[k].healing_version then

                        i = i + 1;
                        slot_cmp.diff_list[i] = slot_cmp.diff_list[i] or {frames = make_item_tooltip_line_frames()};

                        spell_diff(slot_cmp.diff_list[i],
                                   fight_type,
                                   spells[k].healing_version,
                                   k,
                                   loadout,
                                   effects_finalized,
                                   effects_diffed,
                                   eval_flags);
                    end
                end
                slot_cmp.len = i;
            end
        end
    end

    tooltip_item_id_last = new_item.id;

    -- display the cached evaluation data

    local header1 = "Change";
    local header2;
    local header3;
    local fight_type_str;
    if fight_type == fight_types.repeated_casts then
        header2 = "Per sec";
        header3 = "Effect";
        fight_type_str = "Repeated casts";
    else
        header2 = "Effect  ";
        header3 = "Duration (s)";
        fight_type_str = "Cast until OOM";
    end

    headers.change_fstr:SetText(header1);
    headers.first_fstr:SetText(header2);
    headers.second_fstr:SetText(header3);

    for _, v in pairs(headers) do
        v:Show();
    end

    tooltip:AddLine(" ");
    tooltip:AddDoubleLine(sc.core.addon_name,
                          string.format("Target Level %s%d|r | %s",
                              color_by_lvl_diff(loadout.lvl, loadout.target_lvl),
                              loadout.target_lvl,
                          fight_type_str),
                    1, 1, 1,
                    1, 1, 1);

    local wpn_skill_change = "";

    if should_fix_wpn_skill then
        wpn_skill_change = string.format(" Skill: as %d", loadout.lvl * 5);
    elseif new_item.wpn_skill ~= old_item1.wpn_skill then
        wpn_skill_change = string.format(" Skill: %d -> %d",
                                         old_item1.wpn_skill,
                                         new_item.wpn_skill);
    end
    local header0 = string.format("|cFF4682B4|T%s:16:16:0:0|t -> |T%s:16:16:0:0|t%s|r",
                                  old_item1.tex,
                                  new_item.tex,
                                  wpn_skill_change
                                  );
    tooltip:AddDoubleLine(header0,
                          " ",
                    1, 1, 1,
                    effect_color("effect_per_sec"));

    local num_lines = tooltip:NumLines();
    local min_width = 50;

    local offset_to_first = math.max(min_width, headers.second_fstr:GetWidth());
    local offset_to_change = offset_to_first + math.max(min_width, headers.first_fstr:GetWidth());
    local offset_to_role_icon = offset_to_change + math.max(min_width, headers.change_fstr:GetWidth());

    local rhs_txt = _G["GameTooltipTextRight"..num_lines];
    headers.second_fstr:SetPoint("RIGHT", rhs_txt, "RIGHT", 0, 0);
    headers.first_fstr:SetPoint("RIGHT", rhs_txt, "RIGHT", -offset_to_first, 0);
    headers.change_fstr:SetPoint("RIGHT", rhs_txt, "RIGHT", -offset_to_change, 0);

    for item_fits_in_slot, _ in pairs(cmp_slots) do
        local slot_cmp;
        if item_fits_in_slot > 1 then

            slot_cmp = cached_spells_cmp_item_slots[2];

            local wpn_skill_change = "";
            if should_fix_wpn_skill then
                wpn_skill_change = string.format(" Skill: as %d", loadout.lvl * 5);
            elseif new_item.wpn_skill ~= old_item2.wpn_skill then
                wpn_skill_change = string.format(" Skill: %d -> %d",
                                                 old_item2.wpn_skill,
                                                 new_item.wpn_skill);
            end
            tooltip:AddDoubleLine(string.format("|cFF4682B4|T%s:16:16:0:0|t -> |T%s:16:16:0:0|t%s|r",
                                  old_item2.tex,
                                  new_item.tex,
                                  wpn_skill_change),
                                  " ",
                            1, 1, 1);
            num_lines = num_lines + 1;
        else
            slot_cmp = cached_spells_cmp_item_slots[1];
        end
        for i = 1, slot_cmp.len do

            local diff = slot_cmp.diff_list[i];
            local spell_texture_str = "|T" .. diff.tex .. ":16:16:0:0|t "

            local change_fmt = format_number(diff.diff_ratio, 2);
            local change = change_fmt.."%";
            if not diff.diff_ratio  then
                change = "";
            elseif change_fmt == "∞" then
                diff.frames.change_fstr:SetTextColor(1, 1, 1);
            elseif diff.diff_ratio < 0 then
                diff.frames.change_fstr:SetTextColor(195/255, 44/255, 11/255);
                change = change;
            elseif diff.diff_ratio > 0 then
                diff.frames.change_fstr:SetTextColor(33/255, 185/255, 21/255);
                change = "+"..change;
            else
                diff.frames.change_fstr:SetTextColor(1, 1, 1);
            end
            diff.frames.change_fstr:SetText(change);

            local first = format_number(diff.first, 2);
            if not diff.first then
                first = "";
            elseif first == "∞" then
                diff.frames.first_fstr:SetTextColor(1, 1, 1);
            elseif diff.first < 0 then
                diff.frames.first_fstr:SetTextColor(195/255, 44/255, 11/255);
            elseif diff.first > 0 then
                diff.frames.first_fstr:SetTextColor(33/255, 185/255, 21/255);
                first = "+"..first;
            else
                diff.frames.first_fstr:SetTextColor(1, 1, 1);
            end
            diff.frames.first_fstr:SetText(first);

            local second = format_number(diff.second, 2);
            if not diff.second then
                second = "";
            elseif second == "∞" then
                diff.frames.second_fstr:SetTextColor(1, 1, 1);
            elseif diff.second < 0 then
                diff.frames.second_fstr:SetTextColor(195/255, 44/255, 11/255);
            elseif diff.second > 0 then
                diff.frames.second_fstr:SetTextColor(33/255, 185/255, 21/255);
                second = "+"..second;
            else
                diff.frames.second_fstr:SetTextColor(1, 1, 1);
            end
            diff.frames.second_fstr:SetText(second);

            if diff.id == sc.auto_attack_spell_id and cmp_slots[item_fits_in_slot] == slots.MainHandSlot then
                tooltip:AddDoubleLine(string.format("  |T%s:16:16:0:0|t %s", new_item.tex, diff.disp), " ");
            elseif diff.id == 75 and cmp_slots[item_fits_in_slot] == slots.RangedSlot then
                tooltip:AddDoubleLine(string.format("  |T%s:16:16:0:0|t %s", new_item.tex, diff.disp), " ");
            else
                tooltip:AddDoubleLine(string.format("  %s%s", spell_texture_str, diff.extra), " ");
            end

            num_lines = num_lines + 1;

            rhs_txt = _G["GameTooltipTextRight"..num_lines];
            diff.frames.second_fstr:SetPoint("RIGHT", rhs_txt, "RIGHT", 0, 0);
            diff.frames.first_fstr:SetPoint("RIGHT", rhs_txt, "RIGHT", -offset_to_first, 0);
            diff.frames.change_fstr:SetPoint("RIGHT", rhs_txt, "RIGHT", -offset_to_change, 0);


            if diff.heal_like then
                diff.frames.role_tex:SetTexCoord(0.25, 0.5, 0.0, 0.25);
            else
                diff.frames.role_tex:SetTexCoord(0.25, 0.5, 0.25, 0.5);
            end
            diff.frames.role_tex:SetPoint("RIGHT", rhs_txt, "RIGHT", -offset_to_role_icon-10, 0);
            for k, v in pairs(diff.frames) do
                v:Show();
            end
        end
    end
    item_tooltip_frames_hidden = false;
    tooltip:Show();
end

local function on_clear_tooltip()
    if item_tooltip_frames_hidden then
        return;
    end
    item_tooltip_frames_hidden = true;
    for _, v in pairs(cached_spells_cmp_item_slots) do
        for _, vv in ipairs(v.diff_list) do
            for _, frame in pairs(vv.frames) do
                frame:Hide();
            end
        end
    end
    for _, v in pairs(headers) do
        v:Hide();
    end
end

local function on_show_tooltip(tooltip)
    local spell_name, _ = tooltip:GetSpell();
    if not spell_name then
        -- Attack tooltip may be a dummy, so link it to its actual spell id
        local attack_lname = GetSpellInfo(sc.auto_attack_spell_id);
        local txt = getglobal("GameTooltipTextLeft1");
        if txt and txt:GetText() == attack_lname then
            spell_name = attack_lname;
            tooltip:SetSpellByID(sc.auto_attack_spell_id);
        end
    end
    spell_tooltip_cached.needs_update = true;
end

tooltip_export.tooltip_stat_display             = tooltip_stat_display;
tooltip_export.sort_stat_weights                = sort_stat_weights;
tooltip_export.format_bounce_spell              = format_bounce_spell;
tooltip_export.write_spell_tooltip              = write_spell_tooltip;
tooltip_export.write_item_tooltip               = write_item_tooltip;
tooltip_export.update_tooltip                   = update_tooltip;
tooltip_export.append_tooltip_spell_rank        = append_tooltip_spell_rank;
tooltip_export.tooltip_eval_mode                = eval_mode;
tooltip_export.eval_mode_scroll_fn              = eval_mode_scroll_fn;
tooltip_export.on_clear_tooltip                 = on_clear_tooltip;
tooltip_export.on_show_tooltip                  = on_show_tooltip;

sc.tooltip = tooltip_export;

