local _, sc = ...;

local spell_cost                                    = sc.utils.spell_cost;
local spell_cast_time                               = sc.utils.spell_cast_time;
local effect_colors                                 = sc.utils.effect_colors;
local format_number                                 = sc.utils.format_number;

local spells                                        = sc.spells;
local spell_flags                                   = sc.spell_flags;
local highest_learned_rank                          = sc.utils.highest_learned_rank;

local update_loadout_and_effects                    = sc.loadout.update_loadout_and_effects;
local update_loadout_and_effects_diffed_from_ui     = sc.loadout.update_loadout_and_effects_diffed_from_ui;
local active_loadout                                = sc.loadout.active_loadout;


local stats_for_spell                               = sc.calc.stats_for_spell;
local spell_info                                    = sc.calc.spell_info;
local cast_until_oom                                = sc.calc.cast_until_oom;
local resource_regen_info                           = sc.calc.resource_regen_info;

local config                                        = sc.config;
--------------------------------------------------------------------------------
local overlay = {};

local active_overlays = {};
local action_bar_frame_names = {};
local action_id_frames = {};
local spell_book_frames = {};
local action_bar_addon_name = "Default";
local externally_registered_spells = {};

local mana_cost_overlay, cast_speed_overlay, mana_restoration_overlay;

sc.ext.register_spell = function(spell_id)
    if spells[spell_id] and bit.band(spell.flags, spell_flags.eval) ~= 0 then
        if not externally_registered_spells[spell_id] then
            externally_registered_spells[spell_id] = 0;
        end
        externally_registered_spells[spell_id] = externally_registered_spells[spell_id] + 1;
    end
end

sc.ext.unregister_spell = function(spell_id)
    if spells[spell_id] and externally_registered_spells[spell_id] then
        externally_registered_spells[spell_id] = math.max(0, externally_registered_spells[spell_id] - 1);
    end
end

sc.ext.currently_casting_spell_id = function()
    return sc.core.currently_casting_spell_id;
end

local function check_old_rank(frame_info, spell_id, clvl)

    local spell = spells[spell_id]
    if not spell then
        return;
    end
    -- spell_id must be valid here
    for i = 1, 3 do
        frame_info.overlay_frames[i]:Hide();
    end
    if not config.settings.overlay_disable and
        config.settings.overlay_old_rank and
        ((config.settings.overlay_old_rank_limit_to_known and spell_id ~= highest_learned_rank(spell.base_id))
         or
         (not config.settings.overlay_old_rank_limit_to_known and clvl > spell.lvl_outdated)) then

        frame_info.overlay_frames[1]:SetText("OLD");
        frame_info.overlay_frames[2]:SetText("RANK");
        frame_info.overlay_frames[3]:SetText("!!!");
        for i = 1, 3 do
            frame_info.overlay_frames[i]:SetTextColor(252.0/255, 69.0/255, 3.0/255);
            frame_info.overlay_frames[i]:Show();
        end
        frame_info.old_rank_marked = true;
    else
        frame_info.old_rank_marked = false;
    end
end

local function old_rank_warning_traversal(clvl)

    if config.settings.overlay_disable then
        return;
    end
    for _, v in pairs(action_id_frames) do
        if v.frame then
            if spells[v.spell_id] then
                check_old_rank(v, v.spell_id, clvl);
            end
        end
    end
end

local function init_frame_overlay(frame_info)

    local offsets = {-3, -1.5, 0};
    local anchors = {"TOP", "CENTER", "BOTTOM"};
    if not frame_info.overlay_frames then
        frame_info.overlay_frames = {};

        for i = 1, 3 do
            frame_info.overlay_frames[i] = frame_info.frame:CreateFontString(nil, "OVERLAY");
        end
    end
    for i = 1, 3 do
        frame_info.overlay_frames[i]:SetFont(
            sc.ui.icon_overlay_font, config.settings.overlay_font_size, "THICKOUTLINE");
        frame_info.overlay_frames[i]:SetPoint(anchors[i], config.settings.overlay_offset + 1.0, offsets[i]);
    end
end

local function clear_overlays()

    for _, v in pairs(action_id_frames) do
        v.old_rank_marked = false;
        if v.frame then
            for i = 1, 3 do
                v.overlay_frames[i]:SetText("");
                v.overlay_frames[i]:Hide();
            end
        end
    end
    for _, v in pairs(spell_book_frames) do
        v.old_rank_marked = false;
        if v.frame then
            for i = 1, 3 do
                v.overlay_frames[i]:SetText("");
                v.overlay_frames[i]:Hide();
            end
        end
    end
end

local function action_id_of_button(button)

    if not button then
        return nil;
    end
    if action_bar_addon_name == "Default" then
        return button.action;
    else
        -- Dominos seems to set GetAttribute function for the 1-6 default blizz bars
        return button:GetAttribute("action");
    end
end

local function spell_id_of_action(action_id)

    local spell_id = 0;
    local action_type, id, _ = GetActionInfo(action_id);
    if action_type == "macro" then
         spell_id, _ = GetMacroSpell(id);
    elseif action_type == "spell" then
         spell_id = id;
    end
    if not spells[spell_id] then
        spell_id = 0;
    elseif (bit.band(spells[spell_id].flags, spell_flags.eval) == 0) and
        (mana_cost_overlay and not spell_cost(spell_id)) and
        (cast_speed_overlay and not spell_cast_time(spell_id)) and
        (mana_restoration_overlay and bit.band(spells[spell_id].flags, spell_flags.resource_regen) == 0) then
        spell_id = 0;
    end

    return spell_id;
end

local function try_register_frame(action_id, frame_name)
    -- creates it if it suddenly exists but not registered
    local frame = _G[frame_name];
    if frame then
        action_id_frames[action_id].frame = frame;
        local spell_id = spell_id_of_action(action_id);
        if spell_id ~= 0 then
            active_overlays[action_id] = spell_id;
            if spell_id == 5019 then
                sc.core.action_id_of_wand = action_id;
            end
        else
            active_overlays[action_id] = nil; -- this okay?
        end
        action_id_frames[action_id].spell_id = spell_id;
        init_frame_overlay(action_id_frames[action_id]);
    end
end


local function scan_action_frames()

    for action_id, v in pairs(action_bar_frame_names) do

        if not action_id_frames[action_id] then
            action_id_frames[action_id] = {};

            local button_frame = _G[v];
            if button_frame then
                button_frame:HookScript("OnMouseWheel", sc.tooltip.eval_mode_scroll_fn);
            end
        end
        try_register_frame(action_id, v);
    end
end

local function gather_spell_icons()

    active_overlays = {};

    -- gather spell book icons
    if false then -- check for some common addons if they overrite spellbook frames

    else -- default spellbook frames
        for i = 1, 12 do

            if not spell_book_frames[i] then
                spell_book_frames[i] = {
                    frame = _G["SpellButton"..i];
                };
                if spell_book_frames[i].frame then
                    spell_book_frames[i].frame:HookScript("OnMouseWheel", sc.tooltip.eval_mode_scroll_fn);
                end
            end
        end
    end
    for i = 1, 12 do
        init_frame_overlay(spell_book_frames[i]);
    end

    -- gather action bar icons
    local index = 1;
    if IsAddOnLoaded("Bartender4") then -- check for some common addons if they overrite spellbook frames

        for i = 1, 120 do
            action_bar_frame_names[i] = "BT4Button"..i;
        end
        action_bar_addon_name = "Bartender4";

    elseif IsAddOnLoaded("ElvUI") then -- check for some common addons if they overrite spellbook frames

        for i = 1, 10 do
            for j = 1, 12 do
                action_bar_frame_names[index] = 
                    "ElvUI_Bar"..i.."Button"..j;

                index = index + 1;
            end
        end
        action_bar_addon_name = "ElvUI";

    elseif IsAddOnLoaded("Dominos") then -- check for some common addons if they overrite spellbook frames

        local bars = {
            "ActionButton", "DominosActionButton", "MultiBarRightButton",
            "MultiBarLeftButton", "MultiBarBottomRightButton", "MultiBarBottomLeftButton"
        };
        for k, v in pairs(bars) do
            for j = 1, 12 do
                action_bar_frame_names[index] = v..j;

                index = index + 1;
            end
        end

        for i = index, 120 do
            action_bar_frame_names[i] = "DominosActionButton"..i;
        end
        for i = 13, 24 do
            action_bar_frame_names[i] = "DominosActionButton"..i;
        end
        action_bar_addon_name = "Dominos";

    else -- default action bars

        local bars = {
            "ActionButton", "BonusActionButton", "MultiBarRightButton",
            "MultiBarLeftButton", "MultiBarBottomRightButton", "MultiBarBottomLeftButton"
        };
        index = 1;
        for k, v in pairs(bars) do
            for j = 1, 12 do
                action_bar_frame_names[index] = v..j;

                index = index + 1;
            end
        end
        action_bar_addon_name = "Default";
    end
end

local function reassign_overlay_icon_spell(action_id, spell_id)

    if action_id_frames[action_id].frame then
        if spell_id == 0 then
            for i = 1, 3 do
                action_id_frames[action_id].overlay_frames[i]:SetText("");
                action_id_frames[action_id].overlay_frames[i]:Hide();
            end
            active_overlays[action_id] = nil;
        else
            check_old_rank(action_id_frames[action_id], spell_id, active_loadout().lvl);
            active_overlays[action_id] = spell_id;
        end
        action_id_frames[action_id].spell_id = spell_id;
        if spell_id == 5019 then
            sc.core.action_id_of_wand = action_id;
        end
    end
end

local function reassign_overlay_icon(action_id)

    --action_id might not have a named frame (e.g. blizzard bars) at high IDs
    --but still be mirrored to named frames 1-12
    if action_id > 120 or action_id <= 0 then
        return;
    end
    if action_bar_frame_names[action_id] then
        try_register_frame(action_id, action_bar_frame_names[action_id]);
    end

    local spell_id = spell_id_of_action(action_id);

    -- NOTE: any action_id > 12 we might have mirrored action ids
    -- with Bar 1 due to shapeshifts, and forms taking over Bar 1
    -- so check if the action slot in bar 1 is the same
    if action_id > 12 then
        local mirrored_bar_id = (action_id-1)%12 + 1;
        local mirrored_action = action_id_frames[mirrored_bar_id];
        if mirrored_action then
            local mirrored_action_id = action_id_of_button(mirrored_action.frame);
            if mirrored_action_id and mirrored_action_id == action_id then
                -- was mirrored, update that as well
                reassign_overlay_icon_spell(mirrored_bar_id, spell_id)
            end
        end
    end

    if action_bar_frame_names[action_id] then
        local button_frame = action_id_frames[action_id].frame;
        if button_frame then
            reassign_overlay_icon_spell(action_id, spell_id)
        end
    end
end

local function on_special_action_bar_changed()

    for i = 1, 12 do

        -- Hopefully the Actionbar host has updated the new action id of its 1-12 action id bar
        local frame = action_id_frames[i].frame;
        if frame then

            local action_id = action_id_of_button(frame);

            local spell_id = 0;
            if action_id then
                spell_id = spell_id_of_action(action_id);
            end
            --if spell_id ~= 0 then
            --    active_overlays[i] = spell_id;
            --    --check_old_rank(action_id_frames[action_id], spell_id, active_loadout().lvl);
            --else
            --    active_overlays[i] = nil;
            --end
            reassign_overlay_icon_spell(i, spell_id);
        end
    end
end

local function update_icon_overlay_settings()

    mana_cost_overlay = config.settings.overlay_display_avg_cost or config.settings.overlay_display_casts_until_oom or config.settings.overlay_display_time_until_oom;
    cast_speed_overlay = config.settings.overlay_display_avg_cast;
    mana_restoration_overlay = config.settings.overlay_resource_regen;

    __sc_frame.overlay_frame.icon_overlay = {};

    local index = 1;

    for k, v in pairs(__sc_frame.overlay_frame.overlay_components) do
        if config.settings[k] then
            __sc_frame.overlay_frame.icon_overlay[index] = {
                label_type = k,
                color = v.color,
                optional_evaluation = v.optional_evaluation,
            };
            index = index + 1;
        end
    end

    -- if 1, do bottom
    if not __sc_frame.overlay_frame.icon_overlay[2] then
        __sc_frame.overlay_frame.icon_overlay[3] = __sc_frame.overlay_frame.icon_overlay[1];
        __sc_frame.overlay_frame.icon_overlay[1] = nil;
    -- if 2, do top and bottom
    elseif not __sc_frame.overlay_frame.icon_overlay[3] then
        __sc_frame.overlay_frame.icon_overlay[3] = __sc_frame.overlay_frame.icon_overlay[2];
        __sc_frame.overlay_frame.icon_overlay[2] = nil;
    end

    if config.settings.overlay_icon_bottom_clearance then
        __sc_frame.overlay_frame.icon_overlay[2] = __sc_frame.overlay_frame.icon_overlay[1];
        __sc_frame.overlay_frame.icon_overlay[1] = __sc_frame.overlay_frame.icon_overlay[3];
        __sc_frame.overlay_frame.icon_overlay[3] = nil;
    end

    if config.settings.overlay_icon_top_clearance then
        if config.settings.overlay_icon_bottom_clearance then
            __sc_frame.overlay_frame.icon_overlay[2] = __sc_frame.overlay_frame.icon_overlay[1];
        else
            __sc_frame.overlay_frame.icon_overlay[3] = __sc_frame.overlay_frame.icon_overlay[1] or __sc_frame.overlay_frame.icon_overlay[3];
        end
        __sc_frame.overlay_frame.icon_overlay[1] = nil;
    end

    --sw_num_icon_overlay_fields_active = index - 1;

    -- hide existing overlay frames that should no longer exist
    for i = 1, 3 do

        if not __sc_frame.overlay_frame.icon_overlay[i] then
            for _, v in pairs(spell_book_frames) do
                if v.overlay_frames[i] then
                    v.overlay_frames[i]:Hide();
                end
            end
            for _, v in pairs(action_id_frames) do
                if v.frame then
                    v.overlay_frames[i]:Hide();
                end
            end
        end
    end

    active_overlays = {};
    scan_action_frames();
    on_special_action_bar_changed();
end

local function setup_action_bars()
    gather_spell_icons();
    update_icon_overlay_settings();
end
local function update_action_bars()
    update_icon_overlay_settings();
end

local spell_cache = {};

local overlay_label_handler = {
    overlay_display_normal = function(frame_overlay, info)
        local val = 0.0;
        if info.num_direct_effects > 0 then
            val = val + 0.5*(info.total_min_noncrit_if_hit + info.total_max_noncrit_if_hit);
        end
        if info.num_periodic_effects > 0 then
            val = val + 0.5*(info.total_ot_min_noncrit_if_hit + info.total_ot_max_noncrit_if_hit);
        end
        frame_overlay:SetText(format_number(val, 1));
    end,
    overlay_display_crit = function(frame_overlay, info, _, stats)
        local crit_sum = 0;

        if info.num_direct_effects > 0 then
            crit_sum = crit_sum + 0.5*(info.total_min_crit_if_hit + info.total_max_crit_if_hit);
        end
        if info.num_periodic_effects > 0 then
            crit_sum = crit_sum + 0.5*(info.total_ot_min_crit_if_hit + info.total_ot_max_crit_if_hit);
        end
        if stats.crit > 0 and crit_sum > 0 then
            frame_overlay:SetText(format_number(crit_sum, 1));
        else
            frame_overlay:SetText("");
        end
    end,
    overlay_display_expected = function(frame_overlay, info)
        frame_overlay:SetText(format_number(info.expected, 1));
    end,
    overlay_display_effect_per_sec = function(frame_overlay, info)
        if info.effect_per_sec == math.huge then
            frame_overlay:SetText("inf");
        else
            frame_overlay:SetText(format_number(info.effect_per_sec, 1));
        end
    end,
    overlay_display_effect_per_cost = function(frame_overlay, info)
        frame_overlay:SetText(format_number(info.effect_per_cost, 2));
    end,
    overlay_display_threat = function(frame_overlay, info)
        frame_overlay:SetText(format_number(info.threat, 1));
    end,
    overlay_display_threat_per_sec = function(frame_overlay, info)
        if info.threat_per_sec == math.huge then
            frame_overlay:SetText("inf");
        else
            frame_overlay:SetText(format_number(info.threat_per_sec, 1));
        end
    end,
    overlay_display_threat_per_cost = function(frame_overlay, info)
        frame_overlay:SetText(format_number(info.threat_per_cost, 2));
    end,
    overlay_display_avg_cost = function(frame_overlay, _, _, stats)
        if stats.cost >= 0 then
            frame_overlay:SetText(string.format("%d", stats.cost));
        else
            frame_overlay:SetText("");
        end
    end,
    overlay_display_actual_cost = function(frame_overlay, _, _, stats)
        if stats.cost >= 0 then
            frame_overlay:SetText(string.format("%d", stats.cost));
        else
            frame_overlay:SetText("");
        end
    end,
    overlay_display_avg_cast = function(frame_overlay, _, _, stats)
        if stats.cast_time > 0 then
            frame_overlay:SetText(format_number(stats.cast_time, 2));
        else
            frame_overlay:SetText("");
        end
    end,
    overlay_display_actual_cast = function(frame_overlay, _, _, stats)
        if stats.cast_time > 0 then
            frame_overlay:SetText(format_number(stats.cast_time, 2));
        else
            frame_overlay:SetText("");
        end
    end,
    overlay_display_hit_chance = function(frame_overlay, _, spell, stats)
         if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
            frame_overlay:SetText(string.format("%d%%", 100*stats.hit));
        else
            frame_overlay:SetText("");
        end
    end,
    overlay_display_crit_chance = function(frame_overlay, info, _, stats)

        if stats.crit ~= 0 and info.total_ot_min_crit_if_hit + info.total_min_crit_if_hit > 0 then
            frame_overlay:SetText(string.format("%.1f%%", 100*max(0, min(1, stats.crit))));
        else
            frame_overlay:SetText("");
        end
    end,
    overlay_display_casts_until_oom = function(frame_overlay, info)

        if info.num_casts_until_oom >= 0 then
            frame_overlay:SetText(format_number(info.num_casts_until_oom, 1));
        else
            frame_overlay:SetText("");
        end

    end,
    overlay_display_effect_until_oom = function(frame_overlay, info)
        frame_overlay:SetText(format_number(info.effect_until_oom, 0));
    end,
    overlay_display_time_until_oom = function(frame_overlay, info)
        if info.time_until_oom >= 0 then
            frame_overlay:SetText(format_number(info.time_until_oom, 2));
        else
            frame_overlay:SetText("");
        end
    end,
};

local function cache_spell(spell, spell_id, loadout, effects, eval_flags)

    if not spell_cache[spell_id] then
        spell_cache[spell_id] = {};
        spell_cache[spell_id].dmg = {};
        spell_cache[spell_id].heal = {};
    end
    local spell_variant = spell_cache[spell_id].dmg;
    if bit.band(spell.flags, spell_flags.heal) ~= 0 then
        spell_variant = spell_cache[spell_id].heal;
    end

    if not spell_variant.seq then

        spell_variant.seq = -1;
        spell_variant.stats = {};
        spell_variant.spell_effect = {};
    end
    local spell_effect = spell_variant.spell_effect;
    local stats = spell_variant.stats;

    if spell_variant.seq ~= sc.sequence_counter then

        if bit.band(spell.flags, spell_flags.eval) ~= 0 then
            spell_variant.seq = sc.sequence_counter;
            stats_for_spell(stats, spell, loadout, effects, eval_flags);
            spell_info(spell_effect, spell, stats, loadout, effects, eval_flags);
            cast_until_oom(spell_effect, stats, loadout, effects);
        elseif bit.band(spell.flags, spell_flags.resource_regen) ~= 0 then
            resource_regen_info(spell_effect, spell, spell_id, loadout, effects);
        end
    end

    return spell_effect, stats;
end

local function update_spell_icon_frame(frame_info, spell, spell_id, loadout, effects, eval_flags)

    local spell_effect, stats = cache_spell(spell, spell_id, loadout, effects, eval_flags);

    if bit.band(spell.flags, spell_flags.resource_regen) ~= 0 then

        if config.settings.overlay_resource_regen then
            local idx = 3;
            if config.settings.overlay_icon_bottom_clearance and config.settings.overlay_icon_top_clearance then
                idx = 2;
            elseif config.settings.overlay_icon_bottom_clearance then
                idx = 1;
            end
            frame_info.overlay_frames[idx]:SetText(string.format("%d", math.ceil(spell_effect.total_restored)));
            frame_info.overlay_frames[idx]:SetTextColor(effect_colors.avg_cost[1], effect_colors.avg_cost[2], effect_colors.avg_cost[3]);
            frame_info.overlay_frames[idx]:Show();
        end

    elseif __sc_frame.overlay_frame.num_overlay_components_toggled > 0 then
        for i = 1, 3 do

            if __sc_frame.overlay_frame.icon_overlay[i] then

                overlay_label_handler[__sc_frame.overlay_frame.icon_overlay[i].label_type](
                    frame_info.overlay_frames[i],
                    spell_effect,
                    spell,
                    stats
                 );

                frame_info.overlay_frames[i]:SetTextColor(__sc_frame.overlay_frame.icon_overlay[i].color[1],
                                                          __sc_frame.overlay_frame.icon_overlay[i].color[2],
                                                          __sc_frame.overlay_frame.icon_overlay[i].color[3]);

                frame_info.overlay_frames[i]:Show();
            end
        end
    end
end

-- for spells that are not evaluated but cast time & mana cost can be extracted from lua api
-- to be displayed as overlays
local function update_non_evaluated_spell(frame_info, spell_id, loadout, effects)

    local cost, resource_name = spell_cost(spell_id);
    if not cost then
        cost = -1.0;
    end
    local cast_time = spell_cast_time(spell_id) or -1.0;

    if not spell_cache[spell_id] then
        spell_cache[spell_id] = {};
        spell_cache[spell_id].dmg = {};
    end
    local spell_variant = spell_cache[spell_id].dmg;
    --if not spell_cache[spell_id].seq then
    if not spell_variant.seq then

        spell_variant.seq = -1;
        spell_variant.stats = {};
        spell_variant.spell_effect = {};
    end
    local spell_effect = spell_variant.spell_effect;
    local stats = spell_variant.stats;

    if spell_variant.seq ~= sc.sequence_counter then
        spell_variant.seq = sc.sequence_counter;
        -- fill dummy stats
        stats.cost = cost;
        stats.cast_time = cast_time;
        stats.regen_while_casting = effects.raw.regen_while_casting;
        spell_effect.cost_per_sec = cost/cast_time;
        spell_effect.expected = 0
        cast_until_oom(spell_effect, stats, loadout, effects);
        -- hack to display non mana cost as mana but don't show "until oom" if rage/energy etc
        if resource_name ~= "MANA" then
            stats.cast_time = 0.0;
            spell_effect.time_until_oom = -1;
            spell_effect.num_casts_until_oom = -1;
        end
    end

    if __sc_frame.overlay_frame.num_overlay_components_toggled > 0 then
        for i = 1, 3 do
            if __sc_frame.overlay_frame.icon_overlay[i] and __sc_frame.overlay_frame.icon_overlay[i].optional_evaluation then

                overlay_label_handler[__sc_frame.overlay_frame.icon_overlay[i].label_type](
                    frame_info.overlay_frames[i],
                    spell_effect,
                    spell,
                    stats
                );

                frame_info.overlay_frames[i]:SetTextColor(__sc_frame.overlay_frame.icon_overlay[i].color[1],
                                                          __sc_frame.overlay_frame.icon_overlay[i].color[2],
                                                          __sc_frame.overlay_frame.icon_overlay[i].color[3]);

                frame_info.overlay_frames[i]:Show();
            end
        end
    end
end

local function update_overlay_frame(frame, loadout, effects, id, eval_flags)

    if frame.old_rank_marked then
        return;
    end
    if bit.band(spells[id].flags, bit.bor(spell_flags.eval, spell_flags.resource_regen)) ~= 0 then
        -- TODO: icon overlay not working for healing version checkbox
        if spells[id].healing_version and config.settings.general_prioritize_heal then
            update_spell_icon_frame(frame, spells[id].healing_version, id, loadout, effects, eval_flags);
        else
            update_spell_icon_frame(frame, spells[id], id, loadout, effects, eval_flags);
        end
    end
    --for i = 1, 3 do
    --    frame.overlay_frames[i]:Hide();
    --end
end

local special_action_bar_changed_id = 0;

local function update_spell_icons(loadout, effects, eval_flags)

    if sc.core.setup_action_bar_needed then
        setup_action_bars();
        sc.core.setup_action_bar_needed = false;
    end
    if sc.core.update_action_bar_needed then
        update_action_bars();
        sc.core.update_action_bar_needed = false;
    end

    --NOTE: sometimes the Action buttons 1-12 haven't been updated
    --      to reflect the new action id's for forms that change the action bar
    --      Schedule for this to be executed the next update as well to catch late updates
    if sc.core.special_action_bar_changed then
        on_special_action_bar_changed();
        special_action_bar_changed_id = special_action_bar_changed_id + 1;
        if special_action_bar_changed_id%2 == 0 then
            sc.core.special_action_bar_changed = false;
        end
    end

    if sc.core.old_ranks_checks_needed then

        old_rank_warning_traversal(loadout.lvl);
        sc.core.old_ranks_checks_needed = false;
    end

    -- update spell book icons
    local current_tab = SpellBookFrame.selectedSkillLine;
    local num_spells_in_tab = select(4, GetSpellTabInfo(current_tab));
    local page, page_max = SpellBook_GetCurrentPage(current_tab);
    if SpellBookFrame:IsShown() then

        for k, v in pairs(spell_book_frames) do

            if v.frame then
                for _, ov in pairs(v.overlay_frames) do
                    ov:Hide();
                end
                local spell_name = v.frame.SpellName:GetText();
                local spell_rank_name = v.frame.SpellSubName:GetText();
                
                local _, _, _, _, _, _, id = GetSpellInfo(spell_name, spell_rank_name);

                local remaining_spells_in_page = 12;
                if page == page_max then
                    remaining_spells_in_page = 1 + (num_spells_in_tab-1)%12;
                end
                local rearranged_k = 1 + 5*(1-k%2) + (k-k%2)/2;

                if id and spells[id] and v.frame:IsShown() and rearranged_k <= remaining_spells_in_page then
                    update_overlay_frame(v, loadout, effects, id, eval_flags);
                end
            end
        end
    end

    -- update action bar icons
    local num_evals = 0;
    for k, _ in pairs(active_overlays) do
        local v = action_id_frames[k];
        if v.frame and v.frame:IsShown() and spells[v.spell_id] then
            num_evals = num_evals + 1;
            update_overlay_frame(v, loadout, effects, v.spell_id, eval_flags);
        end
    end
    --print("Num overlay evals", num_evals);

    if mana_cost_overlay or cast_speed_overlay then
        for _, v in pairs(action_id_frames) do
            if v.frame and v.spell_id and not spells[v.spell_id] then
                update_non_evaluated_spell(v, v.spell_id, loadout, effects);
            end
        end
    end
end

local function overlay_eval_flags()
    local eval_flags = 0;
    if config.settings.overlay_single_effect_only then
        eval_flags = bit.bor(eval_flags, sc.calc.evaluation_flags.assume_single_effect);
    end
    return eval_flags;
end

local function update_overlay()

    local loadout, effects, loadout_changed;
    if not __sc_frame.calculator_frame:IsShown() or not __sc_frame:IsShown() then
        loadout, effects, loadout_changed = update_loadout_and_effects();
        if not loadout_changed then

            return;
        end
    else
        loadout, _, effects = update_loadout_and_effects_diffed_from_ui();
    end

    local eval_flags = overlay_eval_flags();

    for k, count in pairs(externally_registered_spells) do
        if count > 0 then
            cache_spell(spells[k], k, loadout, effects, eval_flags);
            if spells[k].healing_version then
                cache_spell(spells[k].healing_version, k, loadout, effects, eval_flags);
            end
        end
    end

    local k = sc.core.currently_casting_spell_id;

    if spells[k] and bit.band(spells[k].flags, spell_flags.eval) ~= 0 then
        cache_spell(spells[k], k, loadout, effects, eval_flags);
        if spells[k].healing_version then
            cache_spell(spells[k].healing_version, k, loadout, effects, eval_flags);
        end
    end

    if not config.settings.overlay_disable then

        update_spell_icons(loadout, effects, eval_flags);
    end
end

overlay.spell_book_frames            = spell_book_frames;
overlay.action_id_frames             = action_id_frames;
overlay.setup_action_bars            = setup_action_bars;
overlay.update_overlay               = update_overlay;
overlay.update_icon_overlay_settings = update_icon_overlay_settings;
overlay.reassign_overlay_icon        = reassign_overlay_icon;
overlay.clear_overlays               = clear_overlays;
overlay.old_rank_warning_traversal   = old_rank_warning_traversal;
overlay.overlay_eval_flags           = overlay_eval_flags;

sc.overlay = overlay;

sc.ext.spell_cache = spell_cache;

