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
local spids                                     = swc.abilities.spids;
local spell_flags                               = swc.abilities.spell_flags;
local highest_learned_rank                      = swc.abilities.highest_learned_rank;

local wowhead_talent_link                       = swc.talents.wowhead_talent_link;
local wowhead_talent_code_from_url              = swc.talents.wowhead_talent_code_from_url;

local simulation_type                           = swc.calc.simulation_type;

local effect_colors                             = swc.utils.effect_colors;
local format_number                             = swc.utils.format_number

local update_loadout_and_effects_diffed_from_ui = swc.loadout.update_loadout_and_effects_diffed_from_ui;
local update_loadout_and_effects                = swc.loadout.update_loadout_and_effects;
local active_loadout                            = swc.loadout.active_loadout


local stats_for_spell                           = swc.calc.stats_for_spell;
local spell_info                                = swc.calc.spell_info;
local cast_until_oom                            = swc.calc.cast_until_oom;
local spell_diff                                = swc.calc.spell_diff;

local buff_category                             = swc.buffs.buff_category;
local buffs                                     = swc.buffs.buffs;
local target_buffs                              = swc.buffs.target_buffs;

local config                                    = swc.config;

-------------------------------------------------------------------------
local ui = {};

local sw_frame = {};

local icon_overlay_font = "Interface\\AddOns\\StatWeightsClassic\\font\\Oswald-Bold.ttf";
local font = "GameFontHighlightSmall";
local libstub_data_broker = LibStub("LibDataBroker-1.1", true)
local libstub_icon = libstub_data_broker and LibStub("LibDBIcon-1.0", true)

local function display_spell_diff(i, spell_id_eval, spell_id_src, calc_list, spell_info_normal, spell_info_diff, frame, dual_spell, sim_type)
    if not calc_list[i] then
        calc_list[i] = {};

        frame.y_offset = frame.y_offset - 15;
        calc_list[i].name_str = frame:CreateFontString(nil, "OVERLAY");
        calc_list[i].name_str:SetFontObject(font);
        calc_list[i].name_str:SetPoint("TOPLEFT", 5, frame.y_offset);

        calc_list[i].role_icon = CreateFrame("Frame", nil, frame);
        calc_list[i].role_icon:SetSize(15, 15);
        calc_list[i].role_icon:SetPoint("TOPRIGHT", -230, frame.y_offset+2);
        calc_list[i].role_icon.tex = calc_list[i].role_icon:CreateTexture(nil, "ARTWORK");
        calc_list[i].role_icon.tex:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-ROLES");

        calc_list[i].change = frame:CreateFontString(nil, "OVERLAY");
        calc_list[i].change:SetFontObject(font);
        calc_list[i].change:SetPoint("TOPRIGHT", -180, frame.y_offset);
        calc_list[i].first = frame:CreateFontString(nil, "OVERLAY");
        calc_list[i].first:SetFontObject(font);
        calc_list[i].first:SetPoint("TOPRIGHT", -115, frame.y_offset);
        calc_list[i].second = frame:CreateFontString(nil, "OVERLAY");
        calc_list[i].second:SetFontObject(font);
        calc_list[i].second:SetPoint("TOPRIGHT", -45, frame.y_offset);


        calc_list[i].cancel_button = CreateFrame("Button", "nil", frame, "UIPanelButtonTemplate");
        calc_list[i].cancel_button:SetScript("OnClick", function(self)
            config.settings.spell_calc_list[self.__id_src] = nil;
            for k, v in pairs(calc_list[frame.num_spells]) do
                v:Hide();
            end
            ui.update_calc_list();
        end);

        calc_list[i].cancel_button:SetPoint("TOPRIGHT", -10, frame.y_offset + 4);
        calc_list[i].cancel_button:SetSize(17, 17);
        calc_list[i].cancel_button:SetText("x");
        local fontstr = calc_list[i].cancel_button:GetFontString();
        if fontstr then
            fontstr:ClearAllPoints();
            fontstr:SetPoint("CENTER", calc_list[i].cancel_button, "CENTER");
        end
    end
    local spell = spells[spell_id_eval];

    local v = calc_list[i];

    v.cancel_button.__id_src = spell_id_src;

    local diff = spell_diff(spell_info_normal, spell_info_diff, sim_type);
    local rank_str = "(Rank "..spell.rank..")";
    if spell.rank == 0 then
        rank_str = "";
    end
    local lname = GetSpellInfo(spell_id_eval);
    v.name_str:SetText(lname.." "..rank_str);

    v.name_str:SetTextColor(222/255, 192/255, 40/255);

    if dual_spell or bit.band(spells[spell_id_eval].flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
        v.role_icon.tex:SetTexCoord(0.25, 0.5, 0.0, 0.25);
    else
        v.role_icon.tex:SetTexCoord(0.25, 0.5, 0.25, 0.5);
    end
    v.role_icon.tex:SetAllPoints(v.role_icon);

    v.change:SetText(format_number(diff.diff_ratio, 2).."%");
    if diff.diff_ratio < 0 then
        v.change:SetTextColor(195/255, 44/255, 11/255);
    elseif diff.diff_ratio > 0 then
        v.change:SetTextColor(33/255, 185/255, 21/255);
    else
        v.change:SetTextColor(1, 1, 1);
    end

    v.first:SetText(format_number(diff.first, 2));
    if diff.first < 0 then
        v.first:SetTextColor(195/255, 44/255, 11/255);
    elseif diff.first > 0 then
        v.first:SetTextColor(33/255, 185/255, 21/255);
    else
        v.first:SetTextColor(1, 1, 1);
    end

    v.second:SetText(format_number(diff.second, 2));
    if diff.second < 0 then
        v.second:SetTextColor(195/255, 44/255, 11/255);
    elseif diff.second > 0 then
        v.second:SetTextColor(33/255, 185/255, 21/255);
    else
        v.second:SetTextColor(1, 1, 1);
    end

    for _, f in pairs(v) do
        f:Show();
    end
    if dual_spell then
        calc_list[i].cancel_button:Hide();
    end
end

local function update_calc_list()

    local frame = sw_frame.calculator_frame;
    for _, v in pairs(frame.calc_list) do
        for _, f in pairs(v) do
            f:Hide();
        end
    end
    local loadout, effects, effects_diffed = update_loadout_and_effects_diffed_from_ui()

    local spell_stats_normal = {};
    local spell_stats_diffed = {};
    local spell_info_normal = {};
    local spell_info_diffed = {};

    local i = 0;
    for k, _ in pairs(config.settings.spell_calc_list) do

        local spell_id_src = k;
        if config.settings.calc_list_use_highest_rank and spells[k] then
            k = highest_learned_rank(spells[k].base_id);
        end
        if k and spells[k] and bit.band(spells[k].flags, spell_flags.eval) ~= 0 then

            i = i + 1;

            stats_for_spell(spell_stats_normal, spells[k], loadout, effects);
            stats_for_spell(spell_stats_diffed, spells[k], loadout, effects_diffed);
            spell_info(spell_info_normal, spells[k], spell_stats_normal, loadout, effects);
            cast_until_oom(spell_info_normal, spell_stats_normal, loadout, effects, true);
            spell_info(spell_info_diffed, spells[k], spell_stats_diffed, loadout, effects_diffed);
            cast_until_oom(spell_info_diffed, spell_stats_diffed, loadout, effects_diffed, true);

            display_spell_diff(i, k, spell_id_src, frame.calc_list, spell_info_normal, spell_info_diffed, frame, false, sw_frame.calculator_frame.sim_type);

            -- for spells with both heal and dmg
            if spells[k].healing_version then

                i = i + 1;
                stats_for_spell(spell_stats_normal, spells[k].healing_version, loadout, effects);
                stats_for_spell(spell_stats_diffed, spells[k].healing_version, loadout, effects_diffed);
                spell_info(spell_info_normal, spells[k].healing_version, spell_stats_normal, loadout, effects);
                cast_until_oom(spell_info_normal, spell_stats_normal, loadout, effects, true);
                spell_info(spell_info_diffed, spells[k].healing_version, spell_stats_diffed, loadout, effects_diffed);
                cast_until_oom(spell_info_diffed, spell_stats_diffed, loadout, effects_diffed, true);

                ui.display_spell_diff(i, k, spell_id_src, frame.calc_list, spell_info_normal, spell_info_diffed, frame, true, sw_frame.calculator_frame.sim_type);
            end
        end
    end
    sw_frame.calculator_frame.num_spells = i;
end

-- generalize some reasonable editbox config that need to update on change
-- that is easy to exit / lose focus
local function editbox_config(frame, update_func, close_func)
    close_func = close_func or update_func;
    frame:SetScript("OnEnterPressed", function(self)
        close_func(self);
        self:ClearFocus();
    end);
    frame:SetScript("OnEscapePressed", function(self)
        close_func(self);
        self:ClearFocus();
    end);
    frame:SetScript("OnEditFocusLost", close_func);
    frame:SetScript("OnTextChanged", update_func);

end

local filtered_buffs = {};
local filtered_target_buffs = {};
local buffs_views = {
    {side = "lhs", subject = "self", buffs = buffs, filtered = filtered_buffs},
    {side = "rhs", subject = "target_buffs", buffs = target_buffs, filtered = filtered_target_buffs}
};

local function update_buffs_frame()

    if config.loadout.force_apply_buffs then
        sw_frame.buffs_frame.always_apply_buffs_button:SetChecked(true);
    else
        sw_frame.buffs_frame.always_apply_buffs_button:SetChecked(false);
    end

    local buffs_list_alpha = 1.0;

    if not config.loadout.force_apply_buffs then
        buffs_list_alpha = 0.2;
    end

    for _, view in ipairs(buffs_views) do

        local n = #view.filtered;

        for _, v in ipairs(sw_frame.buffs_frame[view.side].buffs) do
            v.checkbutton:Hide();
            v.checkbutton.__stacks_str:Hide();
            v.icon:Hide();
        end

        local buff_frame_idx = math.floor(sw_frame.buffs_frame[view.side].slider:GetValue());

        for _, v in ipairs(sw_frame.buffs_frame[view.side].buffs) do

            if buff_frame_idx > n then
                break;
            end
            local buff_info = view.buffs[view.filtered[buff_frame_idx]];
            v.checkbutton.buff_id = buff_info.id;

            if v.checkbutton.side == "lhs" then
                if config.loadout.buffs[buff_info.id] then
                    v.checkbutton:SetChecked(true);
                    v.checkbutton.__stacks_str:SetText(tostring(config.loadout.buffs[buff_info.id]));
                else
                    v.checkbutton:SetChecked(false);
                    v.checkbutton.__stacks_str:SetText("0");
                end
            else
                if config.loadout.target_buffs[buff_info.id] then
                    v.checkbutton:SetChecked(true);
                    v.checkbutton.__stacks_str:SetText(tostring(config.loadout.target_buffs[buff_info.id]));
                else
                    v.checkbutton:SetChecked(false);
                    v.checkbutton.__stacks_str:SetText("0");
                end
            end

            v.icon.tex:SetTexture(GetSpellTexture(buff_info.id));

            local buff_name_max_len = 28;
            local name_appear =  buff_info.lname;
            getglobal(v.checkbutton:GetName() .. 'Text'):SetText(name_appear:sub(1, buff_name_max_len));
            local checkbutton_txt = getglobal(v.checkbutton:GetName() .. 'Text');
            if buff_info.cat == buff_category.class  then
                checkbutton_txt:SetTextColor(0/255, 204/255, 255/255);
            elseif buff_info.cat == buff_category.player  then
                checkbutton_txt:SetTextColor(225/255, 235/255, 52/255);
            elseif buff_info.cat == buff_category.friendly  then
                checkbutton_txt:SetTextColor(0/255, 153/255, 51/255);
            elseif buff_info.cat == buff_category.hostile  then
                checkbutton_txt:SetTextColor(235/255, 52/255, 88/255);
            elseif buff_info.cat == buff_category.enchant  then
                checkbutton_txt:SetTextColor(103/255, 52/255, 235/255);
            end

            v.checkbutton:Show();
            v.checkbutton.__stacks_str:Show();
            v.icon:Show();

            sw_frame.buffs_frame[view.side].frame:SetAlpha(buffs_list_alpha);
            buff_frame_idx = buff_frame_idx + 1;
        end
    end

end

local function update_loadout_frame()

    swc.config.activate_loadout_config();

    sw_frame.loadout_frame.loadout_dropdown.init_func();

    if #p_char.loadouts == 1 then
        sw_frame.loadout_frame.delete_button:Hide();
    else
        sw_frame.loadout_frame.delete_button:Show();
    end

    if sw_frame.loadout_frame.new_loadout_name_editbox:GetText() == "" then
        for _, v in pairs(sw_frame.loadout_frame.new_loadout_section) do
            v:Hide();
        end
    else
        for _, v in pairs(sw_frame.loadout_frame.new_loadout_section) do
            v:Show();
        end
    end

    sw_frame.calculator_frame.loadout_name_label:SetText(
        "Active loadout: "..config.loadout.name
    );
    for _, v in pairs(sw_frame.loadout_frame.auto_armor_frames) do
        if config.loadout.target_automatic_armor_pct == v._value then
            v:Click();
        end
    end

    update_buffs_frame();

    update_calc_list();
end

local spell_filter_listing = {
    {
        id = "spells_filter_already_known",
        disp = "Already known",
    },
    {
        id = "spells_filter_available",
        disp = "Available",
    },
    {
        id = "spells_filter_unavailable",
        disp = "Unavailable",
    },
    {
        id = "spells_filter_learned_from_item",
        disp = "Learned from item",
    },
    {
        id = "spells_filter_pet",
        disp = "Pet spells",
    },
    {
        id = "spells_filter_ignored_spells",
        disp = "Ignored spells",
    },
    {
        id = "spells_filter_other_spells",
        disp = "Other spells",
    },
};
local spell_filters = {};
for k, v in pairs(spell_filter_listing) do
    spell_filters[v.id] = k;
end

local spell_browser_sort_options = {
    "Level",
    "|cFFFF8000".."Damage per second",
    "|cFFFF8000".."Healing per second",
    "|cFF00FFFF".."Damage per cost",
    "|cFF00FFFF".."Healing per cost",
};
local spell_browser_sort_keys = {
    lvl = 1,
    dps = 2,
    hps = 3,
    dpc = 4,
    hpc = 5,
};

local spell_browser_active_sort_key = spell_browser_sort_keys.lvl;
-- meant to happen only the first time
local spell_browser_scroll_to_lvl = true;

local stats = {};
local info = {};

local function filtered_spell_view(spell_ids, name_filter)

    local eval_flags = swc.overlay.overlay_eval_flags();
    local loadout, effects = update_loadout_and_effects();

    local lvl = active_loadout().lvl;
    local next_lvl = lvl + 1;
    if lvl % 2 == 0 then
        next_lvl = lvl + 2;
    end
    local avail_cost = 0;
    local next_cost = 0;
    local total_cost = 0;
    local filtered = {};
    local i = 1
    for _, id in pairs(spell_ids) do
        --local known = IsSpellKnown(id);
        local known = IsSpellKnownOrOverridesKnown(id);
        if not known then
            known = IsSpellKnownOrOverridesKnown(id, true);
        end
        if not known then
            -- deal with spells that you unlearn when you have a higher rank
            local highest = highest_learned_rank(spells[id].base_id);
            if spells[highest] then
                known = spells[highest].rank > spells[id].rank;
            end
        end
        if name_filter ~= "" and not string.find(string.lower(GetSpellInfo(id)), string.lower(name_filter)) then
        elseif config.settings.spells_filter_already_known and known then
            filtered[i] = {spell_id = id, trigger = spell_filters.spells_filter_already_known};
        elseif config.settings.spells_filter_available and
            lvl >= spells[id].lvl_req and not known then
            filtered[i] = {spell_id = id, trigger = spell_filters.spells_filter_available};
        elseif config.settings.spells_filter_unavailable and
            lvl < spells[id].lvl_req then
            filtered[i] = {spell_id = id, trigger = spell_filters.spells_filter_unavailable};
        end

        if not config.settings.spells_filter_learned_from_item and
            spells[id].train < 0 then
            filtered[i] = nil;
        end
        if not config.settings.spells_filter_pet and
            bit.band(spells[id].flags, spell_flags.pet) ~= 0 then
            filtered[i] = nil;
        end
        if not config.settings.spells_filter_ignored_spells and
            config.settings.spells_ignore_list[id] then
            filtered[i] = nil;
        end
        if not config.settings.spells_filter_other_spells and
            spells[id].train == 0 then
            filtered[i] = nil;
        end
        if spells[id].race_flags and bit.band(spells[id].race_flags, bit.lshift(1, swc.race-1)) == 0 then
            filtered[i] = nil;
        end
        if filtered[i] then
            -- spell i is in list
            if spells[id].train > 0 then
                if spells[id].lvl_req == next_lvl then
                    next_cost = next_cost + spells[id].train;
                end
                if filtered[i].trigger == spell_filters.spells_filter_available then
                    avail_cost = avail_cost + spells[id].train;
                end
                if filtered[i].trigger ~= spell_filters.spells_filter_already_known then
                    total_cost = total_cost + spells[id].train;
                end
            end
            -- comparable fields
            filtered[i].dps = 0;
            filtered[i].hps = 0;
            filtered[i].dpc = 0;
            filtered[i].hpc = 0;
            if bit.band(spells[id].flags, spell_flags.eval) ~= 0 then
                stats_for_spell(stats, spells[id], loadout, effects, eval_flags);
                spell_info(info, spells[id], stats, loadout, effects, eval_flags);
                filtered[i].effect_per_sec = info.effect_per_sec;
                filtered[i].effect_per_cost = info.effect_per_cost;
                if bit.band(spells[id].flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
                    filtered[i].dps = info.effect_per_sec;
                    filtered[i].dpc = info.effect_per_cost;
                else
                    filtered[i].hps = info.effect_per_sec;
                    filtered[i].hpc = info.effect_per_cost;
                end
            end
            i = i + 1;
            if spells[id].healing_version then
                filtered[i] = {};
                for k, v in pairs(filtered[i-1]) do
                    filtered[i][k] = v;
                end
                filtered[i].is_dual = true;

                stats_for_spell(stats, spells[id].healing_version, loadout, effects, eval_flags);
                spell_info(info, spells[id].healing_version, stats, loadout, effects, eval_flags);
                filtered[i].effect_per_sec = info.effect_per_sec;
                filtered[i].effect_per_cost = info.effect_per_cost;
                filtered[i].hps = info.effect_per_sec;
                filtered[i].hpc = info.effect_per_cost;

                i = i + 1;
            end
        end
    end
    local cost_str = "";
    if avail_cost ~= 0 then
        cost_str = cost_str.."   |cFF00FF00Available cost:|r "..GetCoinTextureString(avail_cost);
    end
    if next_cost ~= 0 then
        cost_str = cost_str.."   |cFFFF8C00Next level "..next_lvl.." cost:|r "..GetCoinTextureString(next_cost);
    end
    if total_cost ~= 0 then
        cost_str = cost_str.."   |cFFFF0000Total cost:|r "..GetCoinTextureString(total_cost);
    end
    sw_frame.spells_frame.footer_cost:SetText(cost_str);

    if spell_browser_active_sort_key == spell_browser_sort_keys.lvl then
        sw_frame.spells_frame.header_level:Hide();
        local filtered_with_level_barriers = {};
        -- injects level brackets into the filtered list
        local prev_lvl = -1;
        local i = 1;
        for _, v in pairs(filtered) do
            if spells[v.spell_id].lvl_req ~= prev_lvl then
                filtered_with_level_barriers[i] = {lvl_barrier = spells[v.spell_id].lvl_req, trigger_flag = 0};
                prev_lvl = spells[v.spell_id].lvl_req;
                i = i + 1;
            end
            filtered_with_level_barriers[i] = v;
            i = i + 1;
        end
        filtered = filtered_with_level_barriers;
    else
        -- filtered only contains spell ids from here
        sw_frame.spells_frame.header_level:Show();

        if spell_browser_active_sort_key == spell_browser_sort_keys.dps then
            table.sort(filtered, function(lhs, rhs) return lhs.dps > rhs.dps end);
        elseif spell_browser_active_sort_key == spell_browser_sort_keys.hps then
            table.sort(filtered, function(lhs, rhs) return lhs.hps > rhs.hps end);
        elseif spell_browser_active_sort_key == spell_browser_sort_keys.dpc then
            table.sort(filtered, function(lhs, rhs) return lhs.dpc > rhs.dpc end);
        elseif spell_browser_active_sort_key == spell_browser_sort_keys.hpc then
            table.sort(filtered, function(lhs, rhs) return lhs.hpc > rhs.hpc end);
        end
    end

    return filtered;
end

local function color_by_lvl_diff(clvl, other_lvl)
    if other_lvl + 6 <= clvl then
        return "|cFFA9A9A9";
    elseif other_lvl + 3 <= clvl then
        return "|cFF00FF00";
    elseif other_lvl - 2 <= clvl then
        return "|cFFFFFF00";
    elseif other_lvl - 3 <= clvl then
        return "|cFFFF8C00";

    else
        return "|cFFFF0000";
    end
end

local function populate_scrollable_spell_view(view, starting_idx)
    local cnt = 1;
    local n = #sw_frame.spells_frame.scroll_view;
    local list_len = #view;
    local i = starting_idx;
    local lvl = active_loadout().lvl;

    -- clear previous
    for _, v in pairs(sw_frame.spells_frame.scroll_view) do
        for _, e in pairs(v) do
            e:Hide();
        end
    end
    while cnt <= n and i <= list_len do
        local v = view[i];
        local line = sw_frame.spells_frame.scroll_view[cnt];
        if v.spell_id then
            --line.spell_icon.__id = v.spell_id;
            line.tooltip_area.__id = v.spell_id;
            line.spell_tex:SetTexture(GetSpellTexture(v.spell_id));
            line.spell_icon:Show();
            line.spell_tex:Show();
            line.tooltip_area:Show();
            line.dropdown_menu.__spid = v.spell_id;
            line.dropdown_button:Show();

            if spells[v.spell_id].rank ~= 0 then
                line.spell_name:SetText(string.format("%s (Rank %d)",
                    GetSpellInfo(v.spell_id),
                    spells[v.spell_id].rank
                ));
            else
                line.spell_name:SetText(GetSpellInfo(v.spell_id));
            end
            if v.trigger == spell_filters.spells_filter_already_known then
                line.spell_name:SetTextColor(138 / 255, 134 / 255, 125 / 255);
            elseif v.trigger == spell_filters.spells_filter_available then
                line.spell_name:SetTextColor(0 / 255, 255 / 255,   0 / 255);
            elseif v.trigger == spell_filters.spells_filter_unavailable then
                line.spell_name:SetTextColor(252 / 255,  69 / 255,   3 / 255);
            end
            line.spell_name:Show();
            -- do level per line if not sorting by lvl
            if spell_browser_active_sort_key ~= spell_browser_sort_keys.lvl then
                line.lvl_str:SetText(color_by_lvl_diff(lvl, spells[v.spell_id].lvl_req)..spells[v.spell_id].lvl_req);
                line.lvl_str:Show();
            end
            -- write in currency/book cost column
            if spells[v.spell_id].train > 0 then
                if v.trigger == spell_filters.spells_filter_already_known or v.is_dual then
                    line.cost_str:SetText("");
                else
                    line.cost_str:SetText(GetCoinTextureString(spells[v.spell_id].train));
                end
                line.cost_str:Show();
            elseif spells[v.spell_id].train < 0 then
                if v.trigger == spell_filters.spells_filter_already_known or v.is_dual then
                else
                    line.book_icon.__id = -spells[v.spell_id].train;
                    line.book_tex:SetTexture(GetItemIcon(-spells[v.spell_id].train));
                    line.book_tex:Show();
                    line.book_icon:Show();
                end
            else
                if v.trigger == spell_filters.spells_filter_already_known or v.is_dual then
                else
                    line.cost_str:SetText("Unknown");
                    line.cost_str:Show();
                end
            end
            if bit.band(spells[v.spell_id].flags, spell_flags.eval) ~= 0 then
                if v.is_dual or bit.band(spells[v.spell_id].flags, bit.bor(spell_flags.heal, spell_flags.absorb)) ~= 0 then
                    line.effect_type_tex:SetTexCoord(0.25, 0.5, 0.0, 0.25);
                else
                    line.effect_type_tex:SetTexCoord(0.25, 0.5, 0.25, 0.5);
                end
                line.effect_type_tex:SetAllPoints(line.effect_type_icon);
                line.effect_type_tex:Show();
                line.effect_type_icon:Show();
                line.per_sec_str:SetText(format_number(v.effect_per_sec, 1));
                line.per_cost_str:SetText(format_number(v.effect_per_cost, 2));
                line.type_str:Show();
                line.per_sec_str:Show();
                line.per_cost_str:Show();
            end
            if config.settings.spells_ignore_list[v.spell_id] then
                line.ignore_line:Show();
            end

        elseif v.lvl_barrier then
            line.spell_name:SetText("<<< ".."Level".." "..color_by_lvl_diff(lvl, v.lvl_barrier)..v.lvl_barrier.."|cFFFFFFFF >>>");
            line.spell_name:SetTextColor(1.0, 1.0, 1.0);
            line.spell_name:Show();
        end
        i = i + 1;
        cnt = cnt + 1;
    end
end


local function update_spells_frame()

    --sw_frame.spells_frame.filter.init_func();
    sw_frame.spells_frame.sort_by.init_func();

    local view = filtered_spell_view(
        swc.spells_lvl_ordered,
        sw_frame.spells_frame.search:GetText()
    );
    sw_frame.spells_frame.filtered_list = view;
    sw_frame.spells_frame.slider:SetMinMaxValues(1, math.max(1, #view - math.floor(#sw_frame.spells_frame.scroll_view/2)));
    if spell_browser_scroll_to_lvl then
        local suitable_idx = 1;
        local lvl = active_loadout().lvl;
        for k, v in pairs(view) do
            if v.spell_id and lvl <= spells[v.spell_id].lvl_req then
                suitable_idx = k;
                break;
            end
        end
        suitable_idx = math.max(1, suitable_idx-10);
        sw_frame.spells_frame.slider_val = suitable_idx;
        spell_browser_scroll_to_lvl = false;
    end
    sw_frame.spells_frame.slider:SetValue(sw_frame.spells_frame.slider_val);
    populate_scrollable_spell_view(view, math.floor(sw_frame.spells_frame.slider_val));
end


local function sw_activate_tab(tab_window)

    sw_frame:Show();

    for _, v in pairs(sw_frame.tabs) do
        v.frame_to_open:Hide();
        v:UnlockHighlight();
        v:SetButtonState("NORMAL");
    end

    if tab_window.frame_to_open == sw_frame.spells_frame then
        update_spells_frame();
    elseif tab_window.frame_to_open == sw_frame.calculator_frame then
        update_calc_list();
    end

    tab_window.frame_to_open:Show();
    tab_window:LockHighlight();
    tab_window:SetButtonState("PUSHED");
end

local function create_sw_spell_id_viewer()

    sw_frame.spell_id_viewer_editbox = CreateFrame("EditBox", "sw_spell_id_viewer_editbox", sw_frame, "InputBoxTemplate");
    sw_frame.spell_id_viewer_editbox:SetPoint("TOPLEFT", sw_frame, 10, -6);
    sw_frame.spell_id_viewer_editbox:SetText("");
    sw_frame.spell_id_viewer_editbox:SetSize(90, 10);
    sw_frame.spell_id_viewer_editbox:SetAutoFocus(false);


    local tooltip_overwrite_editbox = function(self)
        local txt = self:GetText();
        if txt == "" then
            sw_frame.spell_id_viewer_editbox_label:Show();
        else
            sw_frame.spell_id_viewer_editbox_label:Hide();
        end
        local id = tonumber(txt);
        if GetSpellInfo(id) or spells[id] then
            self:SetTextColor(0, 1, 0);
        else
            self:SetTextColor(1, 0, 0);
        end
        self:ClearFocus();
    end

    sw_frame.spell_viewer_invalid_spell_id = 204;

    sw_frame.spell_id_viewer_editbox:SetScript("OnEnterPressed", tooltip_overwrite_editbox);
    sw_frame.spell_id_viewer_editbox:SetScript("OnEscapePressed", tooltip_overwrite_editbox);
    sw_frame.spell_id_viewer_editbox:SetScript("OnEditFocusLost", tooltip_overwrite_editbox);
    sw_frame.spell_id_viewer_editbox:SetScript("OnTextChanged", function(self)
        local txt = self:GetText();
        if txt == "" then
            sw_frame.spell_id_viewer_editbox_label:Show();
        else
            sw_frame.spell_id_viewer_editbox_label:Hide();
        end
        if spids[txt] then
            self:SetText(tostring(spids[txt]));
        end
        local id = tonumber(txt);
        if id and id <= bit.lshift(1, 31) and (GetSpellInfo(id) or spells[id]) then
            self:SetTextColor(0, 1, 0);
        else
            self:SetTextColor(1, 0, 0);
            id = 0;
        end

        if id == 0 then
            sw_frame.spell_icon_tex:SetTexture(GetSpellTexture(265));
        elseif not GetSpellInfo(id) then
            sw_frame.spell_icon_tex:SetTexture(135791);
        else
            sw_frame.spell_icon_tex:SetTexture(GetSpellTexture(id));
        end
        GameTooltip:SetOwner(sw_frame.spell_icon, "ANCHOR_BOTTOMRIGHT");
        if not GetSpellInfo(id) and spells[id] then

            GameTooltip:SetSpellByID(sw_frame.spell_viewer_invalid_spell_id);
        else
            GameTooltip:SetSpellByID(id);
        end
    end);

    if swc.core.__sw__test_all_spells then
        sw_frame.spell_id_viewer_editbox:SetText(pairs(spells)(spells));
    end

    sw_frame.spell_id_viewer_editbox_label = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.spell_id_viewer_editbox_label:SetFontObject(font);
    sw_frame.spell_id_viewer_editbox_label:SetText("SPELL ID VIEWER");
    sw_frame.spell_id_viewer_editbox_label:SetPoint("TOPLEFT", sw_frame, 9, -6);

    sw_frame.spell_icon = CreateFrame("Frame", "__swc_custom_spell_id", sw_frame);
    sw_frame.spell_icon:SetSize(15, 15);
    sw_frame.spell_icon:SetPoint("TOPLEFT", sw_frame, 101, -4);
    local tex = sw_frame.spell_icon:CreateTexture(nil);
    tex:SetAllPoints(sw_frame.spell_icon);
    tex:SetTexture(GetSpellTexture(265));
    sw_frame.spell_icon_tex = tex;


    local tooltip_viewer_on = function(self)
        local txt = sw_frame.spell_id_viewer_editbox:GetText();
        local id = tonumber(txt);
        if txt == "" then
            id = 265;
        elseif not id then
            id = 0;
        end
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
        if not GetSpellInfo(id) and spells[id] then

            GameTooltip:SetSpellByID(sw_frame.spell_viewer_invalid_spell_id);
        else
            GameTooltip:SetSpellByID(id);
        end
        GameTooltip:Show();
    end
    local tooltip_viewer_off = function(self)
        GameTooltip:Hide();
    end

    sw_frame.spell_icon:SetScript("OnEnter", tooltip_viewer_on);
    sw_frame.spell_icon:SetScript("OnLeave", tooltip_viewer_off);
end

local function multi_row_checkbutton(buttons_info, parent_frame, num_columns, func, x_pad)
    x_pad = x_pad or 10;
    --  assume max 2 columns
    local check_button_type = "CheckButton";
    for i, v in pairs(buttons_info) do
        local f = CreateFrame(check_button_type, "sw_frame_setting_"..v.id, parent_frame, "ChatConfigCheckButtonTemplate");
        f._settings_id = v.id;
        f._type = check_button_type;

        local x_spacing = 0;
        if i%num_columns == 0 then
            x_spacing = 230;
        end
        local x = x_pad + x_spacing;
        f:SetPoint("TOPLEFT", x, parent_frame.y_offset);
        local txt = getglobal(f:GetName() .. 'Text');
        txt:SetText(v.txt);
        if v.color then
            txt:SetTextColor(v.color[1], v.color[2], v.color[3]);
        end
        if v.tooltip then
            getglobal(f:GetName()).tooltip = v.tooltip;
        end
        if v.func then
            f:SetScript("OnClick", v.func);
        --elseif func then
        --    f:SetScript("OnClick", func);
        else
            f:SetScript("OnClick", function(self)
                config.settings[self._settings_id] = self:GetChecked();
                if func then
                    func(self);
                end
            end);
        end
        if i%num_columns == 0 then
            parent_frame.y_offset = parent_frame.y_offset - 20;
        end
    end
end

local function create_sw_ui_spells_frame()

    sw_frame.spells_frame.y_offset = sw_frame.spells_frame.y_offset - 8;

    local f = CreateFrame("EditBox", "sw_frame_spells_search", sw_frame.spells_frame, "InputBoxTemplate");
    f:SetPoint("TOPLEFT", 5, sw_frame.spells_frame.y_offset);
    f:SetSize(100, 15);
    f:SetAutoFocus(false);
    f:SetScript("OnTextChanged", function(self)
        update_spells_frame();
        local txt =self:GetText();
        if txt == "" then
            sw_frame.spells_frame.search_empty_label:Show();
        else
            sw_frame.spells_frame.search_empty_label:Hide();
        end
    end);
    sw_frame.spells_frame.search = f;

    local f = sw_frame.spells_frame:CreateFontString(nil, "OVERLAY");
    f:SetFontObject(font);
    f:SetText("Search");
    f:SetPoint("LEFT", sw_frame.spells_frame.search, 5, 0);
    sw_frame.spells_frame.search_empty_label = f;

    -- Sorted by dropdown
    sw_frame.spells_frame.sort_by =
        CreateFrame("Button", "sw_frame_spells_frame_sort_by", sw_frame.spells_frame, "UIDropDownMenuTemplate");
    sw_frame.spells_frame.sort_by:SetPoint("TOPLEFT", 130, sw_frame.spells_frame.y_offset+6);
    sw_frame.spells_frame.sort_by.init_func = function()

        UIDropDownMenu_SetText(sw_frame.spells_frame.sort_by, "Order by "..spell_browser_sort_options[spell_browser_active_sort_key]);
        UIDropDownMenu_Initialize(sw_frame.spells_frame.sort_by, function()

            UIDropDownMenu_SetWidth(sw_frame.spells_frame.sort_by, 160);

            for k, v in pairs(spell_browser_sort_options) do
                UIDropDownMenu_AddButton({
                        text = v;
                        checked = k == spell_browser_active_sort_key;
                        func = function()
                            spell_browser_active_sort_key = k;
                            update_spells_frame();
                            sw_frame.spells_frame.slider:SetValue(1);
                        end
                    }
                );
            end
        end);
    end;
    sw_frame.spells_frame.sort_by.init_func();

    -- Filter dropdown
    sw_frame.spells_frame.filter =
        CreateFrame("Button", "sw_frame_spells_frame_filter", sw_frame.spells_frame, "UIDropDownMenuTemplate");
    sw_frame.spells_frame.filter:SetPoint("TOPLEFT", 320, sw_frame.spells_frame.y_offset+6);
    sw_frame.spells_frame.filter.init_func = function()

        UIDropDownMenu_SetText(sw_frame.spells_frame.filter, "Includes");
        UIDropDownMenu_Initialize(sw_frame.spells_frame.filter, function()

            UIDropDownMenu_SetWidth(sw_frame.spells_frame.filter, 80);

            for _, v in pairs(spell_filter_listing) do
                local txt = v.disp;
                if v.id == "spells_filter_already_known" then
                    txt = "|cFF8a867d"..txt;
                elseif v.id == "spells_filter_available" then
                    txt = "|cFF00FF00"..txt;
                elseif v.id == "spells_filter_unavailable" then
                    txt = "|cFFFF0000"..txt;
                end
                local is_checked = config.settings[v.id];

                UIDropDownMenu_AddButton({
                        text = txt,
                        checked = is_checked,
                        func = function(self)
                            if config.settings[v.id] then
                                config.settings[v.id] = false;
                            else
                                config.settings[v.id] = true;
                            end
                            update_spells_frame();
                        end,
                        keepShownOnClick = true,
                        notCheckable = false
                    }
                );
            end
        end);
    end;

    sw_frame.spells_frame.filter.init_func();

    local f = CreateFrame("Button", nil, sw_frame.spells_frame, "UIPanelButtonTemplate");
    f:SetSize(25, 25);
    f:SetPoint("TOPRIGHT", sw_frame.spells_frame, 0, sw_frame.spells_frame.y_offset+6);
    local tex = f:CreateTexture(nil, "ARTWORK");
    tex:SetTexture("Interface\\Buttons\\UI-RefreshButton");
    tex:SetSize(12, 12);
    tex:SetPoint("CENTER", f, "CENTER", 0, 0);
    f:SetScript("OnClick", function()
        update_spells_frame();
    end);
    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Refresh")
        GameTooltip:Show()
    end);
    f:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end);

    sw_frame.spells_frame.y_offset = sw_frame.spells_frame.y_offset - 25;
    -- Headers
    local icon_x_offset = 0;
    local name_x_offset = 20;
    local lvl_x_offset = 200;
    local effect_x_offset = 230;
    local per_sec_x_offset = 260;
    local per_cost_x_offset = 325;
    local acquisition_x_offset = 380;
    local dropdown_x_offset = 440;

    local f = sw_frame.spells_frame:CreateFontString(nil, "OVERLAY");
    f:SetFontObject(font);
    f:SetText("Spell name");
    f:SetPoint("TOPLEFT", name_x_offset, sw_frame.spells_frame.y_offset);

    local f = sw_frame.spells_frame:CreateFontString(nil, "OVERLAY");
    f:SetFontObject(font);
    f:SetText("Level");
    f:SetPoint("TOPLEFT", lvl_x_offset, sw_frame.spells_frame.y_offset);
    sw_frame.spells_frame.header_level = f;

    local f = sw_frame.spells_frame:CreateFontString(nil, "OVERLAY");
    f:SetFontObject(font);
    f:SetText("Per second");
    f:SetPoint("TOPLEFT", per_sec_x_offset, sw_frame.spells_frame.y_offset);
    f:SetTextColor(effect_colors.effect_per_sec[1],
                   effect_colors.effect_per_sec[2],
                   effect_colors.effect_per_sec[3]);

    local f = sw_frame.spells_frame:CreateFontString(nil, "OVERLAY");
    f:SetFontObject(font);
    f:SetText("Per cost");
    f:SetPoint("TOPLEFT", per_cost_x_offset, sw_frame.spells_frame.y_offset);
    f:SetTextColor(effect_colors.effect_per_cost[1],
                   effect_colors.effect_per_cost[2],
                   effect_colors.effect_per_cost[3]);

    local f = sw_frame.spells_frame:CreateFontString(nil, "OVERLAY");
    f:SetFontObject(font);
    f:SetText("Acquisition");
    f:SetPoint("TOPLEFT", acquisition_x_offset, sw_frame.spells_frame.y_offset);

    sw_frame.spells_frame.y_offset = sw_frame.spells_frame.y_offset - 23;
    local num_view_list_entries = 29;
    local entry_y_offset = 16;

    -- sliders
    f = CreateFrame("Slider", nil, sw_frame.spells_frame, "UIPanelScrollBarTrimTemplate");
    f:SetOrientation('VERTICAL');
    f:SetPoint("RIGHT", sw_frame.spells_frame, "RIGHT", 10, -15);
    f:SetHeight(sw_frame.spells_frame:GetHeight()-63);
    f:SetScript("OnValueChanged", function(self, val)
        sw_frame.spells_frame.slider_val = val;
        populate_scrollable_spell_view(sw_frame.spells_frame.filtered_list, math.floor(val));
    end);
    sw_frame.spells_frame.slider = f;
    sw_frame.spells_frame.slider_val = 1;
    f:SetValue(sw_frame.spells_frame.slider_val);
    f:SetValueStep(1);

    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(f);
    bg:SetColorTexture(0, 0, 0, 0.5);

    sw_frame.spells_frame:EnableMouseWheel(true)
    sw_frame.spells_frame:SetScript("OnMouseWheel", function(_, delta)
        local scrollbar = sw_frame.spells_frame.slider;
        scrollbar:SetValue(scrollbar:GetValue() - delta);
    end);

    -- Spell list
    sw_frame.spells_frame.filtered_list = {};
    sw_frame.spells_frame.scroll_view = {};
    for i = 1, num_view_list_entries do

        local tooltip_area_f = CreateFrame("Frame", nil, sw_frame.spells_frame);
        tooltip_area_f:SetSize(220, 16);
        tooltip_area_f:SetPoint("TOPLEFT", 0, sw_frame.spells_frame.y_offset+4);
        tooltip_area_f:EnableMouse(true);
        tooltip_area_f:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
            GameTooltip:SetSpellByID(self.__id);
            GameTooltip:Show();
        end);
        tooltip_area_f:SetScript("OnLeave", function(self)
            GameTooltip:Hide();
        end);


        local icon = CreateFrame("Frame", nil, sw_frame.spells_frame);
        icon:SetSize(15, 15);
        icon:SetPoint("TOPLEFT", icon_x_offset, sw_frame.spells_frame.y_offset+2);
        local icon_texture = icon:CreateTexture(nil);
        icon_texture:SetAllPoints(icon);

        local book = CreateFrame("Frame", nil, sw_frame.spells_frame);
        book:SetSize(15, 15);
        book:SetPoint("TOPLEFT", acquisition_x_offset, sw_frame.spells_frame.y_offset+2);
        local book_texture = book:CreateTexture(nil);
        book_texture:SetAllPoints(book);
        book:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
            GameTooltip:SetItemByID(self.__id);
            GameTooltip:Show();
        end);
        book:SetScript("OnLeave", function(self)
            GameTooltip:Hide();
        end);

        local spell_str = sw_frame.spells_frame:CreateFontString(nil, "OVERLAY");
        spell_str:SetFontObject(font);
        spell_str:SetText("");
        spell_str:SetPoint("TOPLEFT", name_x_offset, sw_frame.spells_frame.y_offset);

        local level_str = sw_frame.spells_frame:CreateFontString(nil, "OVERLAY");
        level_str:SetFontObject(font);
        level_str:SetText("");
        level_str:SetPoint("TOPLEFT", lvl_x_offset, sw_frame.spells_frame.y_offset);

        local effect_type_str = sw_frame.spells_frame:CreateFontString(nil, "OVERLAY");
        effect_type_str:SetFontObject(font);
        effect_type_str:SetText("");
        effect_type_str:SetPoint("TOPLEFT", effect_x_offset, sw_frame.spells_frame.y_offset);

        local role_icon = CreateFrame("Frame", nil, sw_frame.spells_frame);
        role_icon:SetSize(15, 15);
        role_icon:SetPoint("TOPLEFT", effect_x_offset, sw_frame.spells_frame.y_offset+2);
        local role_icon_texture = role_icon:CreateTexture(nil, "ARTWORK");
        role_icon_texture:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-ROLES");


        local effect_per_sec_str = sw_frame.spells_frame:CreateFontString(nil, "OVERLAY");
        effect_per_sec_str:SetFontObject(font);
        effect_per_sec_str:SetText("");
        effect_per_sec_str:SetPoint("TOPLEFT", per_sec_x_offset, sw_frame.spells_frame.y_offset);
        effect_per_sec_str:SetTextColor(effect_colors.effect_per_sec[1],
                                        effect_colors.effect_per_sec[2],
                                        effect_colors.effect_per_sec[3]);

        local effect_per_cost_str = sw_frame.spells_frame:CreateFontString(nil, "OVERLAY");
        effect_per_cost_str:SetFontObject(font);
        effect_per_cost_str:SetText("");
        effect_per_cost_str:SetPoint("TOPLEFT", per_cost_x_offset, sw_frame.spells_frame.y_offset);
        effect_per_cost_str:SetTextColor(effect_colors.effect_per_cost[1],
                                         effect_colors.effect_per_cost[2],
                                         effect_colors.effect_per_cost[3]);

        local cost = sw_frame.spells_frame:CreateFontString(nil, "OVERLAY");
        cost:SetFontObject(font);
        cost:SetText("");
        cost:SetPoint("TOPLEFT", acquisition_x_offset, sw_frame.spells_frame.y_offset+1);

        -- spell option dropdown
        local spell_options = CreateFrame("Button", "sw_frame_spells_frame_dropdown"..i, sw_frame.spells_frame, "UIDropDownMenuTemplate");
        spell_options:SetPoint("TOPLEFT", dropdown_x_offset, sw_frame.spells_frame.y_offset+15);
        spell_options.init_func = function()

            UIDropDownMenu_Initialize(spell_options, function()

                UIDropDownMenu_SetWidth(spell_options, 15);

                UIDropDownMenu_AddButton({
                        text = "Add/remove to spell ignore list",
                        func = function(self)
                            if config.settings.spells_ignore_list[spell_options.__spid] then
                                config.settings.spells_ignore_list[spell_options.__spid] = nil;
                            else
                                config.settings.spells_ignore_list[spell_options.__spid] = 1;
                            end
                            update_spells_frame();
                        end,
                    }
                );
                UIDropDownMenu_AddButton({
                        text = "Add to calculator list",
                        func = function()

                            local id = spell_options.__spid;
                            if spells[id] and bit.band(spells[id].flags, spell_flags.eval) ~= 0 then

                                config.settings.spell_calc_list[spell_options.__spid] = 1;
                                update_calc_list();
                            end

                        end,
                    }
                );
            end);
        end;
        spell_options.init_func();
        local dropdown_button = _G[spell_options:GetName().."Button"];
        dropdown_button:SetSize(20, 20);
        spell_options:Hide();


        local f = CreateFrame("Button", nil, sw_frame.spells_frame, "UIPanelButtonTemplate");
        f:SetText(":");
        f:SetSize(15, 15);
        f:SetPoint("TOPLEFT", dropdown_x_offset, sw_frame.spells_frame.y_offset+3);
        f:SetScript("OnClick", function()
            _G["sw_frame_spells_frame_dropdown"..i.."Button"]:Click();
        end);

        local ignore_line_f = sw_frame.spells_frame:CreateTexture(nil, "OVERLAY")
        ignore_line_f:SetColorTexture(1.0, 0.0, 0.0, 1.0);
        ignore_line_f:SetDrawLayer("OVERLAY");
        ignore_line_f:SetHeight(0.5);
        ignore_line_f:SetPoint("TOPLEFT", -10, sw_frame.spells_frame.y_offset-5);
        ignore_line_f:SetPoint("TOPRIGHT", -30, sw_frame.spells_frame.y_offset-5);


        sw_frame.spells_frame.scroll_view[i] = {
            tooltip_area = tooltip_area_f,
            spell_icon = icon,
            spell_tex = icon_texture,
            spell_name = spell_str,
            lvl_str = level_str,
            type_str = effect_type_str,
            effect_type_icon = role_icon,
            effect_type_tex = role_icon_texture,
            per_sec_str = effect_per_sec_str,
            per_cost_str = effect_per_cost_str,
            book_icon = book,
            book_tex = book_texture,
            cost_str = cost,
            dropdown_menu = spell_options,
            dropdown_button = f,
            ignore_line = ignore_line_f,
        };
        sw_frame.spells_frame.y_offset = sw_frame.spells_frame.y_offset - entry_y_offset;
    end
    local footer_cost = sw_frame.spells_frame:CreateFontString(nil, "OVERLAY");
    footer_cost:SetFontObject(font);
    footer_cost:SetPoint("BOTTOMRIGHT", sw_frame.spells_frame, "BOTTOMRIGHT", -15, 5);

    sw_frame.spells_frame.footer_cost = footer_cost;

    local header_divider = sw_frame.spells_frame:CreateTexture(nil, "ARTWORK")
    header_divider:SetColorTexture(0.5, 0.5, 0.5, 0.6);
    header_divider:SetHeight(1);
    header_divider:SetPoint("TOPLEFT", sw_frame.spells_frame, "TOPLEFT", 0, -48);
    header_divider:SetPoint("TOPRIGHT", sw_frame.spells_frame, "TOPRIGHT", 0, -48);

    local footer_divider = sw_frame.spells_frame:CreateTexture(nil, "ARTWORK")
    footer_divider:SetColorTexture(0.5, 0.5, 0.5, 0.6)
    footer_divider:SetHeight(1)
    footer_divider:SetPoint("BOTTOMLEFT", sw_frame.spells_frame, "BOTTOMLEFT", 0, 20)
    footer_divider:SetPoint("BOTTOMRIGHT", sw_frame.spells_frame, "BOTTOMRIGHT", 0, 20)
end

local function create_sw_ui_tooltip_frame()

    sw_frame.tooltip_frame.y_offset = sw_frame.tooltip_frame.y_offset - 5;

    sw_frame.tooltip_frame.num_tooltip_toggled = 0;

    sw_frame.tooltip_frame.checkboxes = {};

    local tooltip_setting_checks = {
        {
            id = "tooltip_disable",
            txt = "Disable tooltip",
        },
        {
            id = "tooltip_shift_to_show",
            txt = "Require SHIFT to show tooltip"
        },
        {
            id = "tooltip_clear_original",
            txt = "Clear original tooltip",
        }
    };

    local f_txt = sw_frame.tooltip_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", 0, sw_frame.tooltip_frame.y_offset);
    f_txt:SetText("Tooltip settings");
    f_txt:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.tooltip_frame.y_offset = sw_frame.tooltip_frame.y_offset - 15;
    multi_row_checkbutton(tooltip_setting_checks, sw_frame.tooltip_frame, 2);
    sw_frame.tooltip_frame.y_offset = sw_frame.tooltip_frame.y_offset - 30;

    f_txt = sw_frame.tooltip_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", 0, sw_frame.tooltip_frame.y_offset);
    f_txt:SetText("Tooltip display options:");
    f_txt:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.tooltip_frame.y_offset = sw_frame.tooltip_frame.y_offset - 20;
    f_txt = sw_frame.tooltip_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", 0, sw_frame.tooltip_frame.y_offset);
    f_txt:SetText("Presets:");
    f_txt:SetTextColor(1.0, 1.0, 1.0);


    local tooltip_components = {
        {
            id = "tooltip_display_addon_name",
            txt = "Addon & loadout name"
        },
        {
            id = "tooltip_display_dynamic_tip",
            txt = "Evaluation options",
            tooltip = "For certain spells, shows hotkey to change evaluation method dynamically in the tooltip.";
        },
        {
            id = "tooltip_display_loadout_info",
            txt = "Target info",
            color = effect_colors.loadout_info,
            tooltip = "Target level, armor and resistance assumed in calculation."
        },
        {
            id = "tooltip_display_hit",
            txt = "Miss, avoidance & mitigation",
            color = effect_colors.miss_info,
            tooltip = "Avoidance based on weapon skill & target level. Mitigation based on target armor or resistance."
        },
        {
            id = "tooltip_display_normal",
            txt = "Normal effect",
            color = effect_colors.normal
        },
        {
            id = "tooltip_display_crit",
            txt = "Critical effect",
            color = effect_colors.crit
        },
        {
            id = "tooltip_display_expected",
            txt = "Expected effect",
            color = effect_colors.expectation,
            tooltip = "This average considers all kinds of outcomes like critical, miss, resist, dodge, parry, glance etc.",
        },
        {
            id = "tooltip_display_effect_per_sec",
            txt = "Effect per second",
            color = effect_colors.effect_per_sec
        },
        {
            id = "tooltip_display_effect_per_cost",
            txt = "Effect per cost",
            color = effect_colors.effect_per_cost
        },
        {
            id = "tooltip_display_cost_per_sec",
            txt = "Cost per second" ,
            color = effect_colors.cost_per_sec
        },
        {
            id = "tooltip_display_avg_cost",
            txt = "Expected cost",
            color = effect_colors.avg_cost,
        },
        {
            id = "tooltip_display_avg_cast",
            txt = "Expected execution time",
            color = effect_colors.avg_cast,
        },
        {
            id = "tooltip_display_cast_until_oom",
            txt = "Casts until OOM",
            color = effect_colors.normal,
            tooltip = "Assumes you cast a particular ability until you are OOM with no cooldowns."
        },
        {
            id = "tooltip_display_sp_effect_calc",
            txt = "Coef & SP effect calculation",
            color = effect_colors.sp_effect,
        },
        {
            id = "tooltip_display_sp_effect_ratio",
            txt = "SP to base effect ratio",
            color = effect_colors.sp_effect,
        },
        {
            id = "tooltip_display_base_mod",
            txt = "Base only spell mod",
            color = effect_colors.sp_effect,
        },
        {
            id = "tooltip_display_spell_rank",
            txt = "Spell rank info",
            color = effect_colors.spell_rank,
        },
        {
            id = "tooltip_display_spell_id",
            txt = "Spell id",
            color = effect_colors.spell_rank,
        },
        {
            id = "tooltip_display_stat_weights_dps",
            txt = "Stat weights: Effect per sec",
            color = effect_colors.stat_weights
        },
        {
            id = "tooltip_display_stat_weights_doom",
            txt = "Stat weights: Effect until OOM",
            color = effect_colors.stat_weights
        },
        --tooltip_display_cast_and_tap       
    };

    sw_frame.tooltip_frame.y_offset = sw_frame.tooltip_frame.y_offset - 10;
    sw_frame.tooltip_frame.preset_minimalistic_button =
        CreateFrame("Button", nil, sw_frame.tooltip_frame, "UIPanelButtonTemplate");
    sw_frame.tooltip_frame.preset_minimalistic_button:SetScript("OnClick", function(self)

        for _, v in pairs(tooltip_components) do
            local f = getglobal("sw_frame_setting_"..v.id);
            if f:GetChecked() then
                f:Click();
            end
        end
        getglobal("sw_frame_setting_tooltip_display_expected"):Click();
        getglobal("sw_frame_setting_tooltip_display_effect_per_sec"):Click();
        getglobal("sw_frame_setting_tooltip_display_effect_per_cost"):Click();

    end);

    sw_frame.tooltip_frame.preset_minimalistic_button:SetPoint("TOPLEFT", 80, sw_frame.tooltip_frame.y_offset+16);
    sw_frame.tooltip_frame.preset_minimalistic_button:SetText("Minimalistic");
    sw_frame.tooltip_frame.preset_minimalistic_button:SetWidth(120);

    sw_frame.tooltip_frame.preset_default_button =
        CreateFrame("Button", nil, sw_frame.tooltip_frame, "UIPanelButtonTemplate");
    sw_frame.tooltip_frame.preset_default_button:SetScript("OnClick", function(self)

        for _, v in pairs(tooltip_components) do
            local f = getglobal("sw_frame_setting_"..v.id);
            if f:GetChecked() then
                f:Click();
            end
        end

        getglobal("sw_frame_setting_tooltip_display_addon_name"):Click();
        getglobal("sw_frame_setting_tooltip_display_loadout_info"):Click();
        getglobal("sw_frame_setting_tooltip_display_normal"):Click();
        getglobal("sw_frame_setting_tooltip_display_crit"):Click();
        getglobal("sw_frame_setting_tooltip_display_expected"):Click();
        getglobal("sw_frame_setting_tooltip_display_effect_per_sec"):Click();
        getglobal("sw_frame_setting_tooltip_display_effect_per_cost"):Click();
        getglobal("sw_frame_setting_tooltip_display_dynamic_tip"):Click();
    end);
    sw_frame.tooltip_frame.preset_default_button:SetPoint("TOPLEFT", 200, sw_frame.tooltip_frame.y_offset+16);
    sw_frame.tooltip_frame.preset_default_button:SetText("Default");
    sw_frame.tooltip_frame.preset_default_button:SetWidth(120);

    sw_frame.tooltip_frame.preset_detailed_button =
        CreateFrame("Button", nil, sw_frame.tooltip_frame, "UIPanelButtonTemplate");
    sw_frame.tooltip_frame.preset_detailed_button:SetScript("OnClick", function(self)

        for _, v in pairs(tooltip_components) do
            local f = getglobal("sw_frame_setting_"..v.id);
            if f:GetChecked() then
                f:Click();
            end
        end

        getglobal("sw_frame_setting_tooltip_display_addon_name"):Click();
        getglobal("sw_frame_setting_tooltip_display_loadout_info"):Click();
        getglobal("sw_frame_setting_tooltip_display_spell_rank"):Click();
        getglobal("sw_frame_setting_tooltip_display_normal"):Click();
        getglobal("sw_frame_setting_tooltip_display_crit"):Click();
        getglobal("sw_frame_setting_tooltip_display_expected"):Click();
        getglobal("sw_frame_setting_tooltip_display_avg_cost"):Click();
        getglobal("sw_frame_setting_tooltip_display_avg_cast"):Click();
        getglobal("sw_frame_setting_tooltip_display_effect_per_sec"):Click();
        getglobal("sw_frame_setting_tooltip_display_effect_per_cost"):Click();
        getglobal("sw_frame_setting_tooltip_display_cost_per_sec"):Click();
        getglobal("sw_frame_setting_tooltip_display_cast_until_oom"):Click();
        getglobal("sw_frame_setting_tooltip_display_sp_effect_calc"):Click();
        getglobal("sw_frame_setting_tooltip_display_sp_effect_ratio"):Click();
        getglobal("sw_frame_setting_tooltip_display_stat_weights_dps"):Click();
        getglobal("sw_frame_setting_tooltip_display_stat_weights_doom"):Click();
        getglobal("sw_frame_setting_tooltip_display_dynamic_tip"):Click();
    end);
    sw_frame.tooltip_frame.preset_detailed_button:SetPoint("TOPLEFT", 320, sw_frame.tooltip_frame.y_offset+16);
    sw_frame.tooltip_frame.preset_detailed_button:SetText("Detailed");
    sw_frame.tooltip_frame.preset_detailed_button:SetWidth(120);
    local tooltip_toggle = function(self)

        local checked = self:GetChecked();
        if checked then

            if sw_frame.tooltip_frame.num_tooltip_toggled == 0 then
                if sw_frame_setting_tooltip_disable:GetChecked() then
                    sw_frame_setting_tooltip_disable:Click();
                end
            end
            sw_frame.tooltip_frame.num_tooltip_toggled = sw_frame.tooltip_frame.num_tooltip_toggled + 1;
        else
            sw_frame.tooltip_frame.num_tooltip_toggled = sw_frame.tooltip_frame.num_tooltip_toggled - 1;
            if sw_frame.tooltip_frame.num_tooltip_toggled == 0 then
                if not sw_frame_setting_tooltip_disable:GetChecked() then
                    sw_frame_setting_tooltip_disable:Click();
                end
            end
        end
        config.settings[self._settings_id] = self:GetChecked();
    end;
    sw_frame.tooltip_frame.y_offset = sw_frame.tooltip_frame.y_offset - 15;
    multi_row_checkbutton(tooltip_components, sw_frame.tooltip_frame, 2, tooltip_toggle);


    --sw_frame.tooltip_frame.reset_addon_button =
    --    CreateFrame("Button", nil, sw_frame.tooltip_frame, "UIPanelButtonTemplate");
    --sw_frame.tooltip_frame.reset_addon_button:SetScript("OnClick", function(self)
    --    swc.core.use_char_defaults = 1;
    --    ReloadUI();
    --end);
    --sw_frame.tooltip_frame.reset_addon_button:SetPoint("TOPLEFT", 10, sw_frame.tooltip_frame.y_offset);
    --sw_frame.tooltip_frame.reset_addon_button:SetText("Reset all to default (UI Reload)");
    --sw_frame.tooltip_frame.reset_addon_button:SetWidth(190);
end

local function create_sw_ui_overlay_frame()

    sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 5;
    sw_frame.overlay_frame.icon_settings_label = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.overlay_frame.icon_settings_label:SetFont("Fonts\\FRIZQT__.TTF", 12)
    sw_frame.overlay_frame.icon_settings_label:SetPoint("TOPLEFT", 0, sw_frame.overlay_frame.y_offset);
    sw_frame.overlay_frame.icon_settings_label:SetText("Spell overlay settings");
    sw_frame.overlay_frame.icon_settings_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 15;

    local overlay_settings_checks = {
        {
            id = "overlay_disable",
            txt = "Disable action bar overlay",
            func = function(self)
                config.settings[self._settings_id] = self:GetChecked();
                swc.overlay.clear_overlays();
                swc.core.old_ranks_checks_needed = true;
            end
        },
        {
            id = "overlay_mana_abilities",
            txt = "Show mana restorative spells ",
            color = effect_colors.avg_cost,
            tooltip = "Puts mana restoration amount on overlay for spells like Evocation."
        },
        {
            id = "overlay_old_rank",
            txt = "Old rank warning",
            color = effect_colors.crit,
            func = function(self)
                config.settings[self._settings_id] = self:GetChecked();
                swc.core.old_ranks_checks_needed = true;
            end
        },
        {
            id = "overlay_old_rank_limit_to_known",
            txt = "Restrict old rank warning",
            color = effect_colors.crit,
            func = function(self)
                config.settings[self._settings_id] = self:GetChecked();
                swc.core.old_ranks_checks_needed = true;
            end,
            tooltip = "Does not warn about old rank when the higher rank is not learned/known by player. Requires old rank warning option to be toggled.",
        },
        {
            id = "overlay_single_effect_only",
            txt = "Show for 1x effect",
            tooltip = "Numbers derived from expected effect is displayed as 1.0x effect instead of optimistic 5.0x for Prayer of Healing as an example.";
        },
        {
            id = "icon_top_clearance",
            txt = "Icon top clearance",
        },
        {
            id = "icon_bottom_clearance",
            txt = "Icon bottom clearance",
        },
        {
            id = "overlay_prioritize_heal",
            txt = "Prioritize heal for hybrid spells",
        },
    };

    multi_row_checkbutton(overlay_settings_checks, sw_frame.overlay_frame, 2);

    sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 30;

    local slider_frame_type = "Slider";
    local f = CreateFrame(slider_frame_type, "sw_frame_setting_overlay_update_freq", sw_frame.overlay_frame, "UISliderTemplate");
    f._type = slider_frame_type;
    f:SetOrientation('HORIZONTAL');
    f:SetPoint("TOPLEFT", 250, sw_frame.overlay_frame.y_offset+4);
    f:SetMinMaxValues(1, 30)
    f:SetValueStep(1)
    f:SetWidth(175)
    f:SetHeight(20)
    f:SetScript("OnValueChanged", function(self, val)
        config.settings.overlay_update_freq = val;
        self.val_txt:SetText(string.format("%.1f Hz", val));
    end);

    local f_txt = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY")
    f_txt:SetFontObject(GameFontNormal)
    f_txt:SetTextColor(1.0, 1.0, 1.0);
    f_txt:SetPoint("TOPLEFT", 15, sw_frame.overlay_frame.y_offset)
    f_txt:SetText("Update frequency (responsiveness)");

    f.val_txt = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY")
    f.val_txt:SetFontObject(font)
    f.val_txt:SetPoint("TOPLEFT", 430, sw_frame.overlay_frame.y_offset)
    f.val_txt:SetText(string.format("%.1f Hz", 3));

    sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 25;

    f = CreateFrame(slider_frame_type, "sw_frame_setting_overlay_font_size", sw_frame.overlay_frame, "UISliderTemplate");
    f._type = slider_frame_type;
    f:SetOrientation('HORIZONTAL');
    f:SetPoint("TOPLEFT", 250, sw_frame.overlay_frame.y_offset+4);
    f:SetMinMaxValues(2, 24)
    f:SetValueStep(1)
    f:SetWidth(175)
    f:SetHeight(20)

    f_txt = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY")
    f_txt:SetFontObject(GameFontNormal)
    f_txt:SetTextColor(1.0, 1.0, 1.0);
    f_txt:SetPoint("TOPLEFT", 15, sw_frame.overlay_frame.y_offset)
    f_txt:SetText("Font size")

    f.val_txt = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY")
    f.val_txt:SetFontObject(font)
    f.val_txt:SetPoint("TOPLEFT", 430, sw_frame.overlay_frame.y_offset)
    f.val_txt:SetText(string.format("%.2fx", 0.0));
    f:SetScript("OnValueChanged", function(self, val)
        config.settings.overlay_font_size = val;

        self.val_txt:SetText(string.format("%.2fx", config.settings.overlay_font_size));

        for _, v in pairs(swc.overlay.spell_book_frames) do
            if v.frame then
                local spell_name = v.frame.SpellName:GetText();
                local spell_rank_name = v.frame.SpellSubName:GetText();
                local _, _, _, _, _, _, id = GetSpellInfo(spell_name, spell_rank_name);
                for i = 1, 3 do
                    v.overlay_frames[i]:SetFont(
                        icon_overlay_font, val, "THICKOUTLINE");
                end
            end
        end
        for _, v in pairs(swc.overlay.action_id_frames) do
            if v.frame then
                for i = 1, 3 do
                    v.overlay_frames[i]:SetFont(
                        icon_overlay_font, val, "THICKOUTLINE");
                end
            end
        end

    end);

    sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 25;
    f = CreateFrame(slider_frame_type, "sw_frame_setting_overlay_offset", sw_frame.overlay_frame, "UISliderTemplate");
    f._type = slider_frame_type;
    f:SetOrientation('HORIZONTAL');
    f:SetPoint("TOPLEFT", 250, sw_frame.overlay_frame.y_offset+4);
    f:SetMinMaxValues(-15, 15);
    f:SetWidth(175)
    f:SetHeight(20)
    f:SetValueStep(0.1);

    f_txt = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY")
    f_txt:SetFontObject(GameFontNormal)
    f_txt:SetTextColor(1.0, 1.0, 1.0);
    f_txt:SetPoint("TOPLEFT", 15, sw_frame.overlay_frame.y_offset)
    f_txt:SetText("Horizontal offset")


    f.val_txt = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY")
    f.val_txt:SetFontObject(font)
    f.val_txt:SetPoint("TOPLEFT", 430, sw_frame.overlay_frame.y_offset)
    f.val_txt:SetText(string.format("%.1f", 0));

    f:SetValue(config.settings.overlay_offset);
    f:SetScript("OnValueChanged", function(self, val)
        config.settings.overlay_offset = val;
        self.val_txt:SetText(string.format("%.1f", val))
        swc.core.setup_action_bar_needed = true;
        swc.overlay.update_overlay();
    end);

    sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 20;

    f_txt = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", 0, sw_frame.overlay_frame.y_offset);
    f_txt:SetText("Spell overlay components (max 3)");
    f_txt:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 15;

    sw_frame.overlay_frame.num_overlay_components_toggled = 0;
    sw_frame.overlay_frame.num_overlay_special_toggled = 0;

    local icon_checkbox_func = function(self)

        local checked = self:GetChecked();
        if checked then

            sw_frame.overlay_frame.num_overlay_components_toggled = sw_frame.overlay_frame.num_overlay_components_toggled + 1;
        else
            sw_frame.overlay_frame.num_overlay_components_toggled = sw_frame.overlay_frame.num_overlay_components_toggled - 1;
        end

        if sw_frame.overlay_frame.num_overlay_components_toggled > 3 then
            -- toggled fourth
            self:SetChecked(false);
            sw_frame.overlay_frame.num_overlay_components_toggled = 3;
        --elseif sw_frame.overlay_frame.num_overlay_components_toggled == 0 then
        --    config.settings.overlay_disable = true;
        else
            config.settings[self._settings_id] = checked;
        end

        swc.core.update_action_bar_needed = true;
    end;

    --local special_overlay_component_func = function(self)

    --    icon_checkbox_func(self);
    --    local checked = self:GetChecked();

    --    if checked then
    --        sw_frame.overlay_frame.num_overlay_special_toggled = sw_frame.overlay_frame.num_overlay_special_toggled + 1;
    --    else
    --        sw_frame.overlay_frame.num_overlay_special_toggled = sw_frame.overlay_frame.num_overlay_special_toggled - 1;
    --    end
    --end

    local overlay_components = {
        {
            id = "overlay_display_normal",
            txt = "Normal effect",
            color = effect_colors.normal,
        },
        {
            id = "overlay_display_crit",
            txt = "Critical effect",
            color = effect_colors.crit,
        },
        {
            id = "overlay_display_expected",
            txt = "Expected effect",
            color = effect_colors.expectation,
            tooltip = "Expected effect is the DMG or Heal dealt on average for a single cast considering miss chance, crit chance, spell power etc. This equates to your DPS or HPS number multiplied by the ability's execution time"
        },
        {
            id = "overlay_display_effect_per_sec",
            txt = "Effect per sec",
            color = effect_colors.effect_per_sec,
        },
        {
            id = "overlay_display_effect_per_cost",
            txt = "Effect per cost",
            color = effect_colors.effect_per_cost
        },
        {
            id = "overlay_display_avg_cost",
            txt = "Expected cost",
            color = effect_colors.avg_cost,
            optional_evaluation = true,
        },
        {
            id = "overlay_display_actual_cost",
            txt = "Actual cost",
            color = effect_colors.avg_cost,
            optional_evaluation = true,
        },
        {
            id = "overlay_display_avg_cast",
            txt = "Expected execution time",
            color = effect_colors.avg_cast,
            optional_evaluation = true,
        },
        {
            id = "overlay_display_actual_cast",
            txt = "Actual execution time",
            color = effect_colors.avg_cast,
            optional_evaluation = true,
        },
        {
            id = "overlay_display_hit",
            txt = "Hit chance",
            color = effect_colors.hit
        },
        {
            id = "overlay_display_crit_chance",
            txt = "Critical chance",
            color = effect_colors.crit
        },
        {
            id = "overlay_display_effect_until_oom",
            txt = "Effect until OOM" ,
            color = effect_colors.effect_until_oom,
            optional_evaluation = true,
        },
        {
            id = "overlay_display_casts_until_oom",
            txt = "Casts until OOM",
            color = effect_colors.casts_until_oom,
            optional_evaluation = true,
        },
        {
            id = "overlay_display_time_until_oom",
            txt = "Time until OOM",
            color = effect_colors.time_until_oom,
            optional_evaluation = true,
        },
    };

    multi_row_checkbutton(overlay_components, sw_frame.overlay_frame, 2, icon_checkbox_func);

    sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 15;

    sw_frame.overlay_frame.overlay_components = {};
    for k, v in pairs(overlay_components) do
        sw_frame.overlay_frame.overlay_components[v.id] = {
            color = v.color,
            optional_evaluation = v.optional_evaluation,
        }

    end
end

local function create_sw_ui_calculator_frame()

    sw_frame.loadout_frame.y_offset = sw_frame.calculator_frame.y_offset - 5;
    local x_pad = 5;

    local f = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    f:SetFontObject(GameFontNormal);
    f:SetPoint("TOPLEFT", 0, sw_frame.calculator_frame.y_offset);
    f:SetText("While this tab is open, ability overlay & tooltips reflect the change below");
    f:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.calculator_frame.y_offset = -20;

    f = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    f:SetFontObject(font);
    f:SetPoint("TOPLEFT", x_pad, sw_frame.calculator_frame.y_offset);
    f:SetText("Active Loadout: ");
    sw_frame.calculator_frame.loadout_name_label = f;

    sw_frame.calculator_frame.stat_diff_header_center = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.stat_diff_header_center:SetFontObject(font);
    sw_frame.calculator_frame.stat_diff_header_center:SetPoint("TOPRIGHT", -80, sw_frame.calculator_frame.y_offset);
    sw_frame.calculator_frame.stat_diff_header_center:SetText("Delta");


    local comparison_stats_listing_order = {};

    if swc.core.expansion_loaded == swc.core.expansions.wotlk then

        sw_frame.calculator_frame.stats = {
            int = {
                label_str = "Intellect"
            },
            spirit = {
                label_str = "Spirit"
            },
            mp5 = {
                label_str = "MP5"
            },
            sp = {
                label_str = "Spell Power"
            },
            spell_crit = {
                label_str = "Critical rating"
            },
            spell_hit = {
                label_str = "Hit rating"
            },
            spell_haste = {
                label_str = "Haste rating"
            },
        };
        comparison_stats_listing_order = {"int", "spirit", "mp5", "sp", "spell_crit", "spell_hit", "spell_haste"};
    else
        sw_frame.calculator_frame.stats = {
            int = {
                label_str = "Intellect"
            },
            spirit = {
                label_str = "Spirit"
            },
            mp5 = {
                label_str = "MP5"
            },
            sp = {
                label_str = "Spell Power"
            },
            sd = {
                label_str = "Spell Damage"
            },
            hp = {
                label_str = "Healing Power"
            },
            spell_crit = {
                label_str = "Critical %"
            },
            spell_hit = {
                label_str = "Hit %"
            },
            spell_haste = {
                label_str = "Cast Speed %"
            },
            spell_pen = {
                label_str = "Spell Penetration"
            },
        };
        comparison_stats_listing_order = {"int", "spirit", "mp5", "sp", "sd", "hp", "spell_crit", "spell_hit", "spell_haste", "spell_pen"};
    end


    local num_stats = 0;
    for _ in pairs(sw_frame.calculator_frame.stats) do
        num_stats = num_stats + 1;
    end

    sw_frame.calculator_frame.clear_button = CreateFrame("Button", "nil", sw_frame.calculator_frame, "UIPanelButtonTemplate"); 
    sw_frame.calculator_frame.clear_button:SetScript("OnClick", function()

        for k, v in pairs(sw_frame.calculator_frame.stats) do
            v.editbox:SetText("");
        end
        update_calc_list();
    end);

    sw_frame.calculator_frame.clear_button:SetPoint("TOPRIGHT", -30, sw_frame.calculator_frame.y_offset + 3);
    sw_frame.calculator_frame.clear_button:SetHeight(15);
    sw_frame.calculator_frame.clear_button:SetWidth(50);
    sw_frame.calculator_frame.clear_button:SetText("Clear");

    for i, k in pairs(comparison_stats_listing_order) do

        v = sw_frame.calculator_frame.stats[k];

        sw_frame.calculator_frame.y_offset = sw_frame.calculator_frame.y_offset - 17;

        v.label = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");

        v.label:SetFontObject(font);
        v.label:SetPoint("TOPLEFT", x_pad, sw_frame.calculator_frame.y_offset);
        v.label:SetText(v.label_str);
        v.label:SetTextColor(222/255, 192/255, 40/255);

        v.editbox = CreateFrame("EditBox", v.label_str.."editbox"..k, sw_frame.calculator_frame, "InputBoxTemplate");
        v.editbox:SetPoint("TOPRIGHT", -30, sw_frame.calculator_frame.y_offset);
        v.editbox:SetText("");
        v.editbox:SetAutoFocus(false);
        v.editbox:SetSize(100, 10);
        v.editbox:SetScript("OnTextChanged", function(self)

            if string.match(self:GetText(), "[^-+0123456789. ()]") ~= nil then
                self:ClearFocus();
                self:SetText("");
                self:SetFocus();
            else 
                update_calc_list();
            end
        end);

        v.editbox:SetScript("OnEnterPressed", function(self)

        	self:ClearFocus()
        end);

        v.editbox:SetScript("OnEscapePressed", function(self)
        	self:ClearFocus()
        end);

        v.editbox:SetScript("OnTabPressed", function(self)

            local next_index = 0;
            if IsShiftKeyDown() then
                next_index = 1 + ((i-2) %num_stats);
            else
                next_index = 1 + (i %num_stats);

            end
        	self:ClearFocus()
            sw_frame.calculator_frame.stats[comparison_stats_listing_order[next_index]].editbox:SetFocus();
        end);
    end

    sw_frame.calculator_frame.stats.sp.editbox:SetText("1");
    if swc.core.__sw__test_all_codepaths then
        for k, v in pairs(sw_frame.calculator_frame.stats) do
            v.editbox:SetText("1");
        end
    end

    sw_frame.calculator_frame.y_offset = sw_frame.calculator_frame.y_offset - 20;

    multi_row_checkbutton(
        {{id = "calc_list_use_highest_rank", txt = "Use highest learned rank of spell"}},
        sw_frame.calculator_frame,
        2,
        function()
            update_calc_list();
        end,
        5);

    -- sim type button
    sw_frame.calculator_frame.sim_type_button = 
        CreateFrame("Button", "sw_sim_type_button", sw_frame.calculator_frame, "UIDropDownMenuTemplate"); 
    sw_frame.calculator_frame.sim_type_button:SetPoint("TOPRIGHT", 10, sw_frame.calculator_frame.y_offset);
    sw_frame.calculator_frame.sim_type_button.init_func = function()
        UIDropDownMenu_Initialize(sw_frame.calculator_frame.sim_type_button, function()
            
            if sw_frame.calculator_frame.sim_type == simulation_type.spam_cast then 
                UIDropDownMenu_SetText(sw_frame.calculator_frame.sim_type_button, "Repeated casts");
            elseif sw_frame.calculator_frame.sim_type == simulation_type.cast_until_oom then 
                UIDropDownMenu_SetText(sw_frame.calculator_frame.sim_type_button, "Cast until OOM");
            end
            UIDropDownMenu_SetWidth(sw_frame.calculator_frame.sim_type_button, 130);

            UIDropDownMenu_AddButton(
                {
                    text = "Repeated cast",
                    checked = sw_frame.calculator_frame.sim_type == simulation_type.spam_cast;
                    func = function()

                        sw_frame.calculator_frame.sim_type = simulation_type.spam_cast;
                        UIDropDownMenu_SetText(sw_frame.calculator_frame.sim_type_button, "Repeated casts");
                        sw_frame.calculator_frame.spell_diff_header_center:SetText("Effet per sec");
                        update_calc_list();
                    end
                }
            );
            UIDropDownMenu_AddButton(
                {
                    text = "Cast until OOM",
                    checked = sw_frame.calculator_frame.sim_type == simulation_type.cast_until_oom;
                    func = function()

                        sw_frame.calculator_frame.sim_type = simulation_type.cast_until_oom;
                        UIDropDownMenu_SetText(sw_frame.calculator_frame.sim_type_button, "Cast until OOM");
                        sw_frame.calculator_frame.spell_diff_header_center:SetText("Duration (s)");
                        update_calc_list();
                    end
                }
            );
        end);
    end;

    f = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    f:SetFontObject(font);
    f:SetPoint("BOTTOMLEFT", x_pad, 5);
    f:SetText("Abilities can be added from Spells tab");
    f:SetTextColor(1.0,  1.0,  1.0);

    sw_frame.calculator_frame.sim_type_button:SetText("Simulation type");

    sw_frame.calculator_frame.y_offset = sw_frame.calculator_frame.y_offset - 17;
    sw_frame.calculator_frame.y_offset = sw_frame.calculator_frame.y_offset - 17;

    sw_frame.calculator_frame.spell_diff_header_spell = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.spell_diff_header_spell:SetFontObject(font);
    sw_frame.calculator_frame.spell_diff_header_spell:SetPoint("TOPLEFT", x_pad, sw_frame.calculator_frame.y_offset);
    sw_frame.calculator_frame.spell_diff_header_spell:SetText("Spell");

    sw_frame.calculator_frame.spell_diff_header_left = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.spell_diff_header_left:SetFontObject(font);
    sw_frame.calculator_frame.spell_diff_header_left:SetPoint("TOPRIGHT", -180, sw_frame.calculator_frame.y_offset);
    sw_frame.calculator_frame.spell_diff_header_left:SetText("Change");

    sw_frame.calculator_frame.spell_diff_header_center = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.spell_diff_header_center:SetFontObject(font);
    sw_frame.calculator_frame.spell_diff_header_center:SetPoint("TOPRIGHT", -110, sw_frame.calculator_frame.y_offset);
    sw_frame.calculator_frame.spell_diff_header_center:SetText("Per sec");

    sw_frame.calculator_frame.spell_diff_header_right = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.spell_diff_header_right:SetFontObject(font);
    sw_frame.calculator_frame.spell_diff_header_right:SetPoint("TOPRIGHT", -45, sw_frame.calculator_frame.y_offset);
    sw_frame.calculator_frame.spell_diff_header_right:SetText("Effect");


    sw_frame.calculator_frame.calc_list = {};
    sw_frame.calculator_frame.sim_type = simulation_type.spam_cast;
end

local function create_sw_ui_loadout_frame()

    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 5;
    local x_pad = 5;

    local f_txt = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", 0, sw_frame.loadout_frame.y_offset);
    f_txt:SetText("Loadouts consist of all the parameters going into spell calculations");
    f_txt:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 25;

    f_txt = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", x_pad, sw_frame.loadout_frame.y_offset);
    f_txt:SetText("Active loadout:");
    f_txt:SetTextColor(1.0, 1.0, 1.0);

    local f = CreateFrame("Button", nil, sw_frame.loadout_frame, "UIDropDownMenuTemplate");
    f:SetPoint("TOPLEFT", x_pad + 80, sw_frame.loadout_frame.y_offset+6);
    f.init_func = function()
        UIDropDownMenu_SetText(sw_frame.loadout_frame.loadout_dropdown, config.loadout.name);
        UIDropDownMenu_Initialize(sw_frame.loadout_frame.loadout_dropdown, function()

            UIDropDownMenu_SetWidth(sw_frame.loadout_frame.loadout_dropdown, 100);

            for k, v in pairs(p_char.loadouts) do
                UIDropDownMenu_AddButton({
                        text = v.name,
                        checked = p_char.active_loadout == k,
                        func = function()
                            swc.core.talents_update_needed = true;
                            swc.core.equipment_update_needed = true;

                            config.set_active_loadout(k);
                            update_loadout_frame();
                        end
                    }
                );
            end
        end);
    end;
    sw_frame.loadout_frame.loadout_dropdown = f;

    f = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f:SetFontObject(GameFontNormal);
    f:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad + 240, sw_frame.loadout_frame.y_offset);
    f:SetText("Rename");
    f:SetTextColor(1.0, 1.0, 1.0);

    f = CreateFrame("EditBox", "sw_frame_loadout_name", sw_frame.loadout_frame, "InputBoxTemplate");
    f._type = "EditBox";
    f:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad + 315, sw_frame.loadout_frame.y_offset+2);
    f:SetSize(70, 15);
    f:SetAutoFocus(false);
    local editbox_save = function(self)

        local txt = self:GetText();
        config.loadout.name = txt;
        update_loadout_frame();
    end
    f:SetScript("OnEnterPressed", function(self)
        editbox_save(self);
        self:ClearFocus();
    end);
    f:SetScript("OnEscapePressed", function(self)
        editbox_save(self);
        self:ClearFocus();
    end);
    f:SetScript("OnTextChanged", editbox_save);
    sw_frame.loadout_frame.name_editbox = f;

    f = CreateFrame("Button", "sw_frame_loadouts_delete_button", sw_frame.loadout_frame, "UIPanelButtonTemplate");
    f:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad + 390, sw_frame.loadout_frame.y_offset+6);
    f:SetText("Delete");
    f:SetSize(80, 25);
    f:SetScript("OnClick", function(self)

        local n = #p_char.loadouts;
        if n == 1 then
            return;
        end

        if n ~= active_loadout then
            for i = p_char.active_loadout, n-1 do
                p_char.loadouts[i] = p_char.loadouts[i+1]
            end
        end
        p_char.loadouts[n] = nil;

        config.set_active_loadout(1);

        swc.core.talents_update_needed = true;
        swc.core.equipment_update_needed = true;

        update_loadout_frame();
    end);
    sw_frame.loadout_frame.delete_button = f;

    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 30;

    f = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f:SetFontObject(GameFontNormal);
    f:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad, sw_frame.loadout_frame.y_offset);
    f:SetText("New loadout:");
    f:SetTextColor(1.0, 1.0, 1.0);

    f = CreateFrame("EditBox", nil, sw_frame.loadout_frame, "InputBoxTemplate");
    f:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad + 90, sw_frame.loadout_frame.y_offset+3);
    f:SetSize(80, 15);
    f:SetAutoFocus(false);
    local editbox_save = function(self)

        local txt = self:GetText();
        if txt ~= "" then

            for _, v in pairs(sw_frame.loadout_frame.new_loadout_section) do
                v:Show();
            end
        else
            for _, v in pairs(sw_frame.loadout_frame.new_loadout_section) do
                v:Hide();
            end
        end
    end
    editbox_config(f, editbox_save);
    sw_frame.loadout_frame.new_loadout_name_editbox = f;

    f_txt = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", x_pad + 175, sw_frame.loadout_frame.y_offset);
    f_txt:SetText("from");
    f_txt:SetTextColor(1.0,  1.0,  1.0);
    sw_frame.loadout_frame.new_loadout_txt1 = f_txt;

    f = CreateFrame("Button", nil, sw_frame.loadout_frame, "UIPanelButtonTemplate");
    f:SetScript("OnClick", function(self)

        if config.new_loadout_from_default(sw_frame.loadout_frame.new_loadout_name_editbox:GetText()) then
            sw_frame.loadout_frame.new_loadout_name_editbox:SetText("");
            swc.core.talents_update_needed = true;
            update_loadout_frame();
        end
    end);
    f:SetPoint("TOPLEFT", x_pad + 220, sw_frame.loadout_frame.y_offset+6);
    f:SetText("Default preset");
    f:SetWidth(130);
    sw_frame.loadout_frame.new_loadout_button1 = f;

    f_txt = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", x_pad + 360, sw_frame.loadout_frame.y_offset);
    f_txt:SetText("or");
    f_txt:SetTextColor(1.0,  1.0,  1.0);
    sw_frame.loadout_frame.new_loadout_txt2 = f_txt;

    f = CreateFrame("Button", nil, sw_frame.loadout_frame, "UIPanelButtonTemplate");
    f:SetScript("OnClick", function(self)
        if config.new_loadout_from_active_copy(sw_frame.loadout_frame.new_loadout_name_editbox:GetText()) then
            sw_frame.loadout_frame.new_loadout_name_editbox:SetText("");
            swc.core.talents_update_needed = true;
            update_loadout_frame();
        end
    end);
    f:SetPoint("TOPLEFT", x_pad + 390, sw_frame.loadout_frame.y_offset+6);
    f:SetText("Copy");
    f:SetWidth(80);
    sw_frame.loadout_frame.new_loadout_button2 = f;

    sw_frame.loadout_frame.new_loadout_section = {
        sw_frame.loadout_frame.new_loadout_txt1,
        sw_frame.loadout_frame.new_loadout_txt2,
        sw_frame.loadout_frame.new_loadout_button1,
        sw_frame.loadout_frame.new_loadout_button2
    };

    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 20;

    f = CreateFrame("CheckButton", "sw_frame_loadout_dynamic_check", sw_frame.loadout_frame, "ChatConfigCheckButtonTemplate");
    f._type = "CheckButton";
    f:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad, sw_frame.loadout_frame.y_offset);

    getglobal(f:GetName()..'Text'):SetText("Custom talents");
    getglobal(f:GetName()).tooltip =
        "Accepts a valid wowhead talents link, your loadout will use its talents & glyphs instead of your active ones.";
    f:SetScript("OnClick", function(self)

        swc.core.talents_update_needed = true;
        swc.core.equipment_update_needed = true;

        config.loadout.use_custom_talents = self:GetChecked();
        if config.loadout.use_custom_talents then
            sw_frame.loadout_frame.talent_editbox:SetText(
                wowhead_talent_link(config.loadout.custom_talents_code)
            );
        else
            sw_frame.loadout_frame.talent_editbox:SetText("");
        end
        update_buffs_frame();
    end);
    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 25;

    f = CreateFrame("EditBox", "sw_frame_loadout_talent_editbox", sw_frame.loadout_frame, "InputBoxTemplate");
    f:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad, sw_frame.loadout_frame.y_offset);
    f:SetSize(460, 15);
    f:SetAutoFocus(false);
    editbox_config(f, function(self)

        local txt = self:GetText();
        swc.core.talents_update_needed = true;

        if config.loadout.use_custom_talents then
            config.loadout.custom_talents_code = wowhead_talent_code_from_url(txt);

            sw_frame.loadout_frame.talent_editbox:SetText(
                wowhead_talent_link(config.loadout.custom_talents_code)
            );
            sw_frame.loadout_frame.talent_editbox:SetAlpha(1.0);
        else

            sw_frame.loadout_frame.talent_editbox:SetText(
                wowhead_talent_link(config.loadout.talents_code)
            );
            sw_frame.loadout_frame.talent_editbox:SetAlpha(0.2);
            sw_frame.loadout_frame.talent_editbox:SetCursorPosition(0);
        end

        update_loadout_frame();
        self:ClearFocus();
    end);

    sw_frame.loadout_frame.talent_editbox = f;

    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 25;

    f = CreateFrame("CheckButton", "sw_frame_loadout_use_custom_lvl", sw_frame.loadout_frame, "ChatConfigCheckButtonTemplate");
    f._type = "CheckButton";
    f:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad, sw_frame.loadout_frame.y_offset);
    f:SetHitRectInsets(0, 0, 0, 0);
    getglobal(f:GetName()..'Text'):SetText("Custom player level");
    getglobal(f:GetName()).tooltip =
        "Displays ability information as if character is a custom level (attributes from levels are not accounted for)";

    f:SetScript("OnClick", function(self)

        config.loadout.use_custom_lvl = self:GetChecked();
        swc.core.old_ranks_checks_needed = true;
        if config.loadout.use_custom_lvl then
            sw_frame.loadout_frame.loadout_clvl_editbox:Show();
        else
            sw_frame.loadout_frame.loadout_clvl_editbox:Hide();
        end
    end);
    sw_frame.loadout_frame.custom_lvl_checkbutton = f;

    f = CreateFrame("EditBox", "sw_frame_loadout_lvl", sw_frame.loadout_frame, "InputBoxTemplate");
    f._type = "EditBox";
    f:SetPoint("LEFT", getglobal(sw_frame.loadout_frame.custom_lvl_checkbutton:GetName()..'Text'), "RIGHT", 10, 0);
    f:SetSize(50, 15);
    f:SetAutoFocus(false);
    f:Hide();
    f.number_editbox = true;
    local clvl_editbox_update = function(self)
        local lvl = tonumber(self:GetText());
        local valid = lvl and lvl >= 1 and lvl <= 100;
        swc.core.old_ranks_checks_needed = true;
        if valid then
            config.loadout.lvl = lvl;
        end
        return valid;
    end
    local clvl_editbox_close = function(self)
        if not clvl_editbox_update(self) then
            local clvl = UnitLevel("player");
            self:SetText(""..clvl);
        end

    	self:ClearFocus();
        self:HighlightText(0,0);
    end
    editbox_config(f, clvl_editbox_update, clvl_editbox_close);
    sw_frame.loadout_frame.loadout_clvl_editbox = f;

    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 25;

    f_txt = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad + 23, sw_frame.loadout_frame.y_offset);
    f_txt:SetText("Target level difference");
    f_txt:SetTextColor(1.0,  1.0,  1.0);

    f = CreateFrame("EditBox", "sw_frame_loadout_default_target_lvl_diff", sw_frame.loadout_frame, "InputBoxTemplate");
    f._type = "EditBox";
    f:SetPoint("LEFT", f_txt, "RIGHT", 10, 0);
    f:SetText("");
    f:SetSize(40, 15);
    f:SetAutoFocus(false);
    f.number_editbox = true;
    local editbox_update = function(self)
        -- silently try to apply valid changes but don't panic while focus is on
        local lvl_diff = tonumber(self:GetText());
        local valid = lvl_diff and lvl_diff == math.floor(lvl_diff) and config.loadout.lvl + lvl_diff >= 1 and config.loadout.lvl + lvl_diff <= 83;
        if valid then

            config.loadout.default_target_lvl_diff = lvl_diff;
        end
        return valid;
    end;
    local editbox_close = function(self)

        if not editbox_update(self) then
            self:SetText(""..config.loadout.default_target_lvl_diff);
        end
        self:ClearFocus();
        self:HighlightText(0,0);
    end
    editbox_config(f, editbox_update, editbox_close);
    sw_frame.loadout_frame.level_editbox = f;

    f = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f:SetFontObject(GameFontNormal);
    f:SetPoint("LEFT", sw_frame.loadout_frame.level_editbox, "RIGHT", 10, 0);
    f:SetText("(when no hostile target available)");
    f:SetTextColor(1.0,  1.0,  1.0);

    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 25;

    f_txt = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad + 23, sw_frame.loadout_frame.y_offset);
    f_txt:SetText("Default target HP");
    f_txt:SetTextColor(1.0,  1.0,  1.0);

    f = CreateFrame("EditBox", "sw_frame_loadout_default_target_hp_perc", sw_frame.loadout_frame, "InputBoxTemplate");
    f._type = "EditBox";
    f:SetPoint("LEFT", f_txt, "RIGHT", 10, 0);
    f:SetText("");
    f:SetSize(40, 15);
    f:SetAutoFocus(false);
    f.number_editbox = true;
    local editbox_hp_perc_update = function(self)
        local hp_perc = tonumber(self:GetText());
        local valid = hp_perc and hp_perc >= 0;
        if valid then
            config.loadout.default_target_hp_perc = hp_perc;
        end
        return valid;
    end
    local editbox_hp_perc_close = function(self)

        if not editbox_hp_perc_update(self) then
            self:SetText(""..loadout.default_target_hp_perc);
        end
        self:ClearFocus();
        self:HighlightText(0,0);
    end
    editbox_config(f, editbox_hp_perc_update, editbox_hp_perc_close);
    sw_frame.loadout_frame.hp_perc_label_editbox = f;
    f_txt = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("LEFT", f, "RIGHT", 5, 0);
    f_txt:SetText("%");
    f_txt:SetTextColor(1.0,  1.0,  1.0);

    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 30;

    f_txt = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad + 23, sw_frame.loadout_frame.y_offset);
    f_txt:SetText("Target resistance");
    f_txt:SetTextColor(1.0,  1.0,  1.0);

    f = CreateFrame("EditBox", "sw_frame_loadout_target_res", sw_frame.loadout_frame, "InputBoxTemplate");
    f._type = "EditBox";
    f:SetPoint("LEFT", f_txt, "RIGHT", 10, 0);
    f:SetText("");
    f:SetSize(40, 15);
    f:SetAutoFocus(false);
    f.number_editbox = true;
    local editbox_target_res_update = function(self)
        local target_res = tonumber(self:GetText());
        local valid = target_res and target_res >= 0;
        if valid then
            config.loadout.target_res = target_res;
        end
        return valid;
    end
    local editbox_target_res_close = function(self)

        if not editbox_target_res_update(self) then
            self:SetText("0");
            config.loadout.target_res = 0;
        end
        self:ClearFocus();
        self:HighlightText(0,0);
    end

    editbox_config(f, editbox_target_res_update, editbox_target_res_close);

    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 25;

    sw_frame.loadout_frame.auto_armor_frames = {};
    sw_frame.loadout_frame.custom_armor_frames = {};

    f = CreateFrame("CheckButton", "sw_frame_loadout_target_automatic_armor", sw_frame.loadout_frame, "ChatConfigCheckButtonTemplate");
    f._type = "CheckButton";
    f:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad, sw_frame.loadout_frame.y_offset);
    getglobal(f:GetName()..'Text'):SetText("Estimate armor");
    getglobal(f:GetName()).tooltip = 
        "Estimates armor from target level";
    f:SetScript("OnClick", function(self)
        local checked = self:GetChecked();
        config.loadout.target_automatic_armor = checked;
        if checked then
            for _, v in pairs(sw_frame.loadout_frame.auto_armor_frames) do
                v:Show();
            end
            for _, v in pairs(sw_frame.loadout_frame.custom_armor_frames) do
                v:Hide();
            end
        else
            for _, v in pairs(sw_frame.loadout_frame.auto_armor_frames) do
                v:Hide();
            end
            for _, v in pairs(sw_frame.loadout_frame.custom_armor_frames) do
                v:Show();
            end
        end
    end);
    f:SetHitRectInsets(0, 0, 0, 0);
    sw_frame.loadout_frame.automatic_armor = f;

    f_txt = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("LEFT", getglobal(f:GetName()..'Text'), "RIGHT", 50, 0);
    f_txt:SetText("Custom armor value");
    f_txt:SetTextColor(1.0,  1.0,  1.0);
    sw_frame.loadout_frame.custom_armor_frames[1] = f_txt;


    f = CreateFrame("EditBox", "sw_frame_loadout_target_armor", sw_frame.loadout_frame, "InputBoxTemplate");
    f._type = "EditBox";
    f:SetPoint("LEFT", f_txt, "RIGHT", 10, 0);
    f:SetText("");
    f:SetSize(40, 15);
    f:SetAutoFocus(false);
    f.number_editbox = true;
    local editbox_target_armor_update = function(self)
        local target_armor = tonumber(self:GetText());
        local valid = target_armor and target_armor >= 0;
        if valid then
            config.loadout.target_armor = target_armor;
        end
        return valid;
    end
    local editbox_target_armor_close = function(self)

        if not editbox_target_res_update(self) then
            self:SetText("0");
            config.loadout.target_armor = 0;
        end
        self:ClearFocus();
        self:HighlightText(0,0);
    end
    editbox_config(f, editbox_target_armor_update, editbox_target_armor_close);
    sw_frame.loadout_frame.custom_armor_frames[2] = f;

    local armor_pct_fn = function(self)
        if self:GetChecked() then
            config.loadout.target_automatic_armor_pct = self._value;
        end
        for _, v in pairs(sw_frame.loadout_frame.auto_armor_frames) do
            v:SetChecked(config.loadout.target_automatic_armor_pct == v._value);
        end
    end;

    f = CreateFrame("CheckButton", "sw_frame_loadout_target_automatic_armor_100", sw_frame.loadout_frame, "ChatConfigCheckButtonTemplate");
    f._type = "CheckButton";
    f._value = 100;
    f:SetPoint("LEFT", getglobal(sw_frame.loadout_frame.automatic_armor:GetName()..'Text'), "RIGHT", 40, 0);
    getglobal(f:GetName()..'Text'):SetText("Heavy 100%");
    f:SetHitRectInsets(0, 0, 0, 0);
    f:SetScript("OnClick", armor_pct_fn);
    sw_frame.loadout_frame.auto_armor_frames[1] = f;

    f = CreateFrame("CheckButton", "sw_frame_loadout_target_automatic_armor_80", sw_frame.loadout_frame, "ChatConfigCheckButtonTemplate");
    f._type = "CheckButton";
    f._value = 80;
    f:SetPoint("LEFT", getglobal(sw_frame.loadout_frame.auto_armor_frames[1]:GetName()..'Text'), "RIGHT", 10, 0);
    getglobal(f:GetName()..'Text'):SetText("Medium 80%");
    f:SetHitRectInsets(0, 0, 0, 0);
    f:SetScript("OnClick", armor_pct_fn);
    sw_frame.loadout_frame.auto_armor_frames[2] = f;

    f = CreateFrame("CheckButton", "sw_frame_loadout_target_automatic_armor_50", sw_frame.loadout_frame, "ChatConfigCheckButtonTemplate");
    f._type = "CheckButton";
    f._value = 50;
    f:SetPoint("LEFT", getglobal(sw_frame.loadout_frame.auto_armor_frames[2]:GetName()..'Text'), "RIGHT", 10, 0);
    getglobal(f:GetName()..'Text'):SetText("Light 50%");
    f:SetHitRectInsets(0, 0, 0, 0);
    f:SetScript("OnClick", armor_pct_fn);
    sw_frame.loadout_frame.auto_armor_frames[3] = f;

    for _, v in pairs(sw_frame.loadout_frame.auto_armor_frames) do
        v:Hide();
    end
    for _, v in pairs(sw_frame.loadout_frame.custom_armor_frames) do
        v:Show();
    end

    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 25;

    f_txt = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad + 23, sw_frame.loadout_frame.y_offset);
    f_txt:SetText("Number of targets for unbounded AOE spells");
    f_txt:SetTextColor(1.0,  1.0,  1.0);

    f = CreateFrame("EditBox", "sw_frame_loadout_unbounded_aoe_targets", sw_frame.loadout_frame, "InputBoxTemplate");
    f._type = "EditBox";
    f:SetPoint("LEFT", f_txt, "RIGHT", 10, 0);
    f:SetSize(40, 15);
    f:SetAutoFocus(false);
    f.number_editbox = true;
    local aoe_targets_editbox_update = function(self)
        local targets = tonumber(self:GetText());
        local valid = targets and targets >= 1;
        if valid then
            config.loadout.unbounded_aoe_targets = math.floor(targets);
        end
        return valid;
    end
    local aoe_targets_editbox_close = function(self)
        if not aoe_targets_editbox_update(self) then
            self:SetText("1");
            config.loadout.unbounded_aoe_targets = 1;
        end
    	self:ClearFocus();
        self:HighlightText(0,0);
    end

    editbox_config(f, aoe_targets_editbox_update, aoe_targets_editbox_close);
    sw_frame.loadout_frame.loadout_unbounded_aoe_targets_editbox = f;


    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 25;

    f_txt = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad + 23, sw_frame.loadout_frame.y_offset);
    f_txt:SetText("Extra mana for casts until OOM");
    f_txt:SetTextColor(1.0,  1.0,  1.0);

    f = CreateFrame("EditBox", "sw_frame_loadout_extra_mana", sw_frame.loadout_frame, "InputBoxTemplate");
    f._type = "EditBox";
    f:SetPoint("LEFT", f_txt, "RIGHT", 10, 0);
    f:SetSize(40, 15);
    f:SetAutoFocus(false);
    f.number_editbox = true;
    local mana_editbox_update = function(self)

        local mana = tonumber(self:GetText());
        local valid = mana ~= nil;
        if vald then
            config.loadout.extra_mana = mana;
        end
        return valid;
    end
    local mana_editbox_close = function(self)
        if not mana_editbox_update(self) then
            self:SetText("0");
            loadout.extra_mana = 0;
        end
    	self:ClearFocus();
        self:HighlightText(0,0);
    end

    editbox_config(f, mana_editbox_update, mana_editbox_close);
    sw_frame.loadout_frame.loadout_extra_mana_editbox = f;

    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 25;

    f = CreateFrame("CheckButton", "sw_frame_loadout_always_max_resource", sw_frame.loadout_frame, "ChatConfigCheckButtonTemplate");
    f._type = "CheckButton";
    f:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad, sw_frame.loadout_frame.y_offset);
    getglobal(f:GetName()..'Text'):SetText("Always at maximum resource");
    getglobal(f:GetName()).tooltip = 
        "Assumes you are casting from maximum mana, energy, rage or combo points";
    f:SetScript("OnClick", function(self)
        config.loadout.always_max_resource = self:GetChecked();
    end)
    sw_frame.loadout_frame.max_mana_checkbutton = f;

    sw_frame.loadout_frame.y_offset = sw_frame.loadout_frame.y_offset - 25;

    f = CreateFrame("CheckButton", "sw_frame_loadout_behind_target", sw_frame.loadout_frame, "ChatConfigCheckButtonTemplate");
    f._type = "CheckButton";
    f:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad, sw_frame.loadout_frame.y_offset);
    getglobal(f:GetName()..'Text'):SetText("Always behind target, eliminating parried attacks");
    f:SetScript("OnClick", function(self)
        config.loadout.behind_target = self:GetChecked();
    end)
end

local function create_sw_ui_buffs_frame()

    local f = CreateFrame("CheckButton", "sw_frame_buffs_frame_toggle", sw_frame.buffs_frame, "ChatConfigCheckButtonTemplate");
    f:SetPoint("TOPLEFT", sw_frame.buffs_frame, 0, sw_frame.buffs_frame.y_offset);
    getglobal(f:GetName() .. 'Text'):SetText("Enable selected auras even when inactive");
    getglobal(f:GetName()).tooltip = 
        "The selected buffs will be applied behind the scenes to the spell calculations";
    f:SetScript("OnClick", function(self)
        if self:GetChecked() then
            config.loadout.force_apply_buffs = true;
        else
            config.loadout.force_apply_buffs = false;
        end
        update_buffs_frame();
    end);
    sw_frame.buffs_frame.always_apply_buffs_button = f;

    sw_frame.buffs_frame.y_offset = sw_frame.buffs_frame.y_offset - 25;

    local f = CreateFrame("EditBox", "sw_frame_buffs_search", sw_frame.buffs_frame, "InputBoxTemplate");
    f:SetPoint("TOPLEFT", 8, sw_frame.buffs_frame.y_offset);
    f:SetSize(160, 15);
    f:SetAutoFocus(false);
    f:SetScript("OnTextChanged", function(self)
        local txt = self:GetText();
        if txt == "" then
            sw_frame.buffs_frame.search_empty_label:Show();
            for _, view in ipairs(buffs_views) do
                for k, _ in ipairs(view.buffs) do
                    view.filtered[k] = k;
                end
            end
        else
            sw_frame.buffs_frame.search_empty_label:Hide();
            local num = tonumber(txt);
            for _, view in ipairs(buffs_views) do
                view.filtered = {};
                for k, v in ipairs(view.buffs) do
                    if string.find(string.lower(v.lname), string.lower(txt)) or 
                        (num and num == v.id) then
                        table.insert(view.filtered, k);
                    end
                end
            end
        end
        for _, view in ipairs(buffs_views) do
            sw_frame.buffs_frame[view.side].slider:SetMinMaxValues(1, max(1, #view.filtered - math.floor(sw_frame.buffs_frame[view.side].num_buffs_can_fit/2)));
        end
        update_buffs_frame();
    end);
    sw_frame.buffs_frame.search = f;

    local f = sw_frame.buffs_frame:CreateFontString(nil, "OVERLAY");
    f:SetFontObject(font);
    f:SetText("Search");
    f:SetPoint("LEFT", sw_frame.buffs_frame.search, 5, 0);
    sw_frame.buffs_frame.search_empty_label = f;

    for view_idx, view in ipairs(buffs_views) do

        -- init without any filter, 1 to 1
        for k, _ in ipairs(view.buffs) do
            view.filtered[k] = k;
        end

        local y_offset = sw_frame.buffs_frame.y_offset;

        y_offset = y_offset - 20;

        local f = CreateFrame("ScrollFrame", "sw_frame_buffs_frame_"..view.side, sw_frame.buffs_frame);
        f:SetWidth(235);
        f:SetHeight(490);
        f:SetPoint("TOPLEFT", sw_frame.buffs_frame, 240*(view_idx-1), y_offset);
        sw_frame.buffs_frame[view.side] = {}
        sw_frame.buffs_frame[view.side].frame = f;

        f = CreateFrame("ScrollFrame", "sw_frame_buffs_list_"..view.side, sw_frame.buffs_frame[view.side].frame);
        f:SetWidth(235);
        f:SetHeight(455);
        f:SetPoint("TOPLEFT", sw_frame.buffs_frame[view.side].frame, 0, -35);
        sw_frame.buffs_frame[view.side].buffs_list_frame = f;

        sw_frame.buffs_frame[view.side].num_checked = 0;
        sw_frame.buffs_frame[view.side].buffs = {};
        sw_frame.buffs_frame[view.side].buffs_num = 0;

        y_offset = -5;

        f = sw_frame.buffs_frame[view.side].frame:CreateFontString(nil, "OVERLAY");
        f:SetFontObject(GameFontNormal);
        local fp, _, flags = f:GetFont();
        f:SetFont(fp, 17, flags);
        if (view_idx == 1) then
            f:SetText("Player auras");
        else
            f:SetText("Subject auras");
        end
        f:SetPoint("TOPLEFT", 5, y_offset);

        y_offset = y_offset - 15;
        local f = CreateFrame("CheckButton", "sw_frame_check_all_"..view.side, sw_frame.buffs_frame[view.side].frame, "ChatConfigCheckButtonTemplate");
        f:SetPoint("TOPLEFT", 20, y_offset);
        getglobal(f:GetName() .. 'Text'):SetText("Select all/none");
        getglobal(f:GetName() .. 'Text'):SetTextColor(1, 0, 0);

        f:SetScript("OnClick", function(self)

            if self:GetChecked() then
                if view.side == "lhs" then
                    for _, v in ipairs(view.buffs) do
                        config.loadout.buffs[v.id] = 1;
                    end
                else
                    for _, v in ipairs(view.buffs) do
                        config.loadout.target_buffs[v.id] = 1;
                    end
                end
            else
                if view.side == "lhs" then
                    config.loadout.buffs = {};
                else
                    config.loadout.target_buffs = {};
                end
            end

            update_buffs_frame();
        end);
        sw_frame.buffs_frame[view.side].select_all_buffs_checkbutton = f;

        local f = CreateFrame("Slider", nil, sw_frame.buffs_frame[view.side].buffs_list_frame, "UIPanelScrollBarTrimTemplate");
        f:SetOrientation('VERTICAL');
        f:SetPoint("RIGHT", sw_frame.buffs_frame[view.side].buffs_list_frame, "RIGHT", 0, 2);
        f:SetHeight(sw_frame.buffs_frame[view.side].buffs_list_frame:GetHeight()-30);
        sw_frame.buffs_frame[view.side].num_buffs_can_fit =
            math.floor(sw_frame.buffs_frame[view.side].buffs_list_frame:GetHeight()/15);
        f:SetMinMaxValues( 1, max(1, #view.filtered - math.floor(sw_frame.buffs_frame[view.side].num_buffs_can_fit/2)));
        f:SetValue(1);
        f:SetValueStep(1);
        f:SetScript("OnValueChanged", function(self, val)
            update_buffs_frame();
        end);

        local bg = f:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(f);
        bg:SetColorTexture(0, 0, 0, 0.5);

        sw_frame.buffs_frame[view.side].slider = f;

        sw_frame.buffs_frame[view.side].buffs_list_frame:SetScript("OnMouseWheel", function(self, dir)
            local min_val, max_val = sw_frame.buffs_frame[view.side].slider:GetMinMaxValues();
            local val = sw_frame.buffs_frame[view.side].slider:GetValue();
            if val - dir >= min_val and val - dir <= max_val then
                sw_frame.buffs_frame[view.side].slider:SetValue(val - dir);
                update_buffs_frame();
            end
        end);


        y_offset = 0;
        for i = 1, sw_frame.buffs_frame[view.side].num_buffs_can_fit do
            sw_frame.buffs_frame[view.side].buffs[i] = {};

            local checkbtn = CreateFrame("CheckButton", "loadout_buffs_checkbutton"..view.side..i, sw_frame.buffs_frame[view.side].buffs_list_frame, "ChatConfigCheckButtonTemplate");
            checkbtn.side = view.side;
            checkbtn:SetScript("OnMouseDown", function(self, btn)

                local config_buffs;
                if view.side == "lhs" then
                    config_buffs = config.loadout.buffs;
                else
                    config_buffs = config.loadout.target_buffs;
                end
                if btn == "LeftButton" then
                    if not config_buffs[self.buff_id] then
                        config_buffs[self.buff_id] = 1;
                        sw_frame.buffs_frame[view.side].num_checked = sw_frame.buffs_frame[view.side].num_checked + 1;
                    else
                        config_buffs[self.buff_id] = nil;
                        sw_frame.buffs_frame[view.side].num_checked = sw_frame.buffs_frame[view.side].num_checked - 1;
                    end

                    if sw_frame.buffs_frame[view.side].num_checked == 0 then
                        sw_frame.buffs_frame[view.side].select_all_buffs_checkbutton:SetChecked(false);
                    else
                        sw_frame.buffs_frame[view.side].select_all_buffs_checkbutton:SetChecked(true);
                    end
                elseif btn == "Button4" then
                    if config_buffs[self.buff_id] then
                        config_buffs[self.buff_id] = math.max(1, config_buffs[self.buff_id] - 1);
                    end
                elseif btn == "Button5"  or btn == "RightButton" then
                    if config_buffs[self.buff_id] then
                        config_buffs[self.buff_id] = config_buffs[self.buff_id] + 1;
                    end
                end
                self.__stacks_str:SetText(tostring(config_buffs[self.buff_id] or 0));
            end);
            local icon = CreateFrame("Frame", "loadout_buffs_icon"..view.side..i, sw_frame.buffs_frame[view.side].buffs_list_frame);
            icon:SetSize(15, 15);
            local tex = icon:CreateTexture(nil);
            icon.tex = tex;
            tex:SetAllPoints(icon);

            checkbtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
                GameTooltip:SetSpellByID(self.buff_id);
                GameTooltip:Show();
            end);
            checkbtn:SetScript("OnLeave", function()
                GameTooltip:Hide();
            end);

            local stacks_str = icon:CreateFontString(nil, "OVERLAY");
            stacks_str:SetFontObject(font);
            stacks_str:SetPoint("BOTTOMRIGHT", 0, 0);
            checkbtn.__stacks_str = stacks_str;

            checkbtn:SetPoint("TOPLEFT", 20, y_offset);
            icon:SetPoint("TOPLEFT", 5, y_offset -4);
            y_offset = y_offset - 15;

            sw_frame.buffs_frame[view.side].buffs[i].checkbutton = checkbtn;
            sw_frame.buffs_frame[view.side].buffs[i].icon = icon;
        end
    end
end

local function update_profile_frame()

    swc.config.set_active_settings();
    swc.config.activate_settings();

    sw_frame.profile_frame.primary_spec.init_func();
    sw_frame.profile_frame.second_spec.init_func();

    sw_frame.profile_frame.active_main_spec:Hide();
    sw_frame.profile_frame.active_second_spec:Hide();
    if swc.core.active_spec == 1 then
        sw_frame.profile_frame.active_main_spec:Show();
    else
        sw_frame.profile_frame.active_second_spec:Show();
    end

    sw_frame.profile_frame.delete_profile_button:Hide();
    sw_frame.profile_frame.delete_profile_label:Hide();

    local cnt = 0;
    for _, _ in pairs(p_acc.profiles) do
        cnt = cnt + 1;
        if cnt > 1 then
            break;
        end
    end
    if cnt > 1 then

        sw_frame.profile_frame.delete_profile_button:Show();
        sw_frame.profile_frame.delete_profile_label:Show();
    end

    sw_frame.profile_frame.rename_editbox:SetText(config.active_profile_name);
end

local function create_sw_ui_profile_frame()

    sw_frame.profile_frame.y_offset = sw_frame.profile_frame.y_offset - 5;


    local f_txt = sw_frame.profile_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", 0, sw_frame.profile_frame.y_offset);
    f_txt:SetText("Profiles retain settings except for loadout/buffs configuration");
    f_txt:SetTextColor(232.0/255, 225.0/255, 32.0/255);


    sw_frame.profile_frame.y_offset = sw_frame.profile_frame.y_offset - 35;

    f_txt = sw_frame.profile_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", 30, sw_frame.profile_frame.y_offset);
    f_txt:SetText("Main spec profile: ");
    f_txt:SetTextColor(1.0, 1.0, 1.0);

    sw_frame.profile_frame.primary_spec = 
        CreateFrame("Button", "sw_frame_profile_main_spec", sw_frame.profile_frame, "UIDropDownMenuTemplate");
    sw_frame.profile_frame.primary_spec:SetPoint("TOPLEFT", 170, sw_frame.profile_frame.y_offset+6);
    sw_frame.profile_frame.primary_spec.init_func = function()

        UIDropDownMenu_SetText(sw_frame.profile_frame.primary_spec, p_char.main_spec_profile);
        UIDropDownMenu_Initialize(sw_frame.profile_frame.primary_spec, function()

            UIDropDownMenu_SetWidth(sw_frame.profile_frame.primary_spec, 130);

            for k, _ in pairs(p_acc.profiles) do
                UIDropDownMenu_AddButton({
                        text = k,
                        checked = p_char.main_spec_profile == k,
                        func = function()
                            p_char.main_spec_profile = k;
                            UIDropDownMenu_SetText(sw_frame.profile_frame.primary_spec, k);
                            update_profile_frame();
                        end
                    }
                );
            end
        end);
    end;

    sw_frame.profile_frame.active_main_spec = sw_frame.profile_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.profile_frame.active_main_spec:SetFontObject(GameFontNormal);
    sw_frame.profile_frame.active_main_spec:SetPoint("TOPLEFT", 350, sw_frame.profile_frame.y_offset);
    sw_frame.profile_frame.active_main_spec:SetText("<--- Active");
    sw_frame.profile_frame.active_main_spec:SetTextColor(1.0,  0.0,  0.0);


    sw_frame.profile_frame.y_offset = sw_frame.profile_frame.y_offset - 25;
    f_txt = sw_frame.profile_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", 30, sw_frame.profile_frame.y_offset);
    f_txt:SetText("Secondary spec profile: ");
    f_txt:SetTextColor(1.0, 1.0, 1.0);

    sw_frame.profile_frame.second_spec = 
        CreateFrame("Button", "sw_frame_profile_second_spec", sw_frame.profile_frame, "UIDropDownMenuTemplate");
    sw_frame.profile_frame.second_spec:SetPoint("TOPLEFT", 170, sw_frame.profile_frame.y_offset+6);
    sw_frame.profile_frame.second_spec.init_func = function()

        UIDropDownMenu_SetText(sw_frame.profile_frame.second_spec, p_char.second_spec_profile);
        UIDropDownMenu_Initialize(sw_frame.profile_frame.second_spec, function()

            UIDropDownMenu_SetWidth(sw_frame.profile_frame.second_spec, 130);

            for k, _ in pairs(p_acc.profiles) do

                UIDropDownMenu_AddButton({
                        text = k,
                        checked = p_char.second_spec_profile == k,
                        func = function()
                            p_char.second_spec_profile = k;
                            UIDropDownMenu_SetText(sw_frame.profile_frame.second_spec, k);
                            update_profile_frame();
                        end
                    }
                );
            end
        end);
    end;

    sw_frame.profile_frame.active_second_spec = sw_frame.profile_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.profile_frame.active_second_spec:SetFontObject(GameFontNormal);
    sw_frame.profile_frame.active_second_spec:SetPoint("TOPLEFT", 350, sw_frame.profile_frame.y_offset);
    sw_frame.profile_frame.active_second_spec:SetText("<--- Active");
    sw_frame.profile_frame.active_second_spec:SetTextColor(1.0,  0.0,  0.0);

    sw_frame.profile_frame.y_offset = sw_frame.profile_frame.y_offset - 35;

    f_txt = sw_frame.profile_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", 30, sw_frame.profile_frame.y_offset);
    f_txt:SetText("Rename active profile: ");
    f_txt:SetTextColor(1.0, 1.0, 1.0);

    local f = CreateFrame("EditBox", "sw_frame_profile_name_editbox", sw_frame.profile_frame, "InputBoxTemplate");
    f:SetPoint("TOPLEFT", sw_frame.profile_frame, 195, sw_frame.profile_frame.y_offset+3);
    f:SetSize(140, 15);
    f:SetAutoFocus(false);
    local editbox_save = function(self)

        local txt = self:GetText();
        local k = swc.config.spec_keys[swc.core.active_spec];

        if p_char[k] ~= txt then

            p_acc.profiles[txt] = p_acc.profiles[p_char[k]];
            p_acc.profiles[p_char[k]] = nil
            p_char[k] = txt;
        end

        update_profile_frame()
    end
    f:SetScript("OnEnterPressed", function(self) 
        editbox_save(self);
        self:ClearFocus();
    end);
    f:SetScript("OnEscapePressed", function(self) 
        editbox_save(self);
        self:ClearFocus();
    end);
    f:SetScript("OnTextChanged", editbox_save);
    sw_frame.profile_frame.rename_editbox = f;

    sw_frame.profile_frame.y_offset = sw_frame.profile_frame.y_offset - 35;

    f_txt = sw_frame.profile_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", 30, sw_frame.profile_frame.y_offset);
    f_txt:SetText("Delete active profile");
    f_txt:SetTextColor(1.0, 1.0, 1.0);
    sw_frame.profile_frame.delete_profile_label = f_txt;

    f = CreateFrame("Button", nil, sw_frame.profile_frame, "UIPanelButtonTemplate");
    f:SetScript("OnClick", function(self)


        local cnt = 0; 
        for _, _ in pairs(p_acc.profiles) do
            cnt = cnt + 1;
            if cnt > 1 then
                break;
            end
        end
        if cnt > 1 then
            p_acc.profiles[p_char[swc.config.spec_keys[swc.core.active_spec]]] = nil;
            update_profile_frame();
        end
    end);
    f:SetPoint("TOPLEFT", 190, sw_frame.profile_frame.y_offset+4);
    f:SetText("Delete");
    f:SetWidth(200);
    sw_frame.profile_frame.delete_profile_button = f;

    sw_frame.profile_frame.y_offset = sw_frame.profile_frame.y_offset - 35;
    f_txt = sw_frame.profile_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", 30, sw_frame.profile_frame.y_offset);
    f_txt:SetText("New profile name: ");
    f_txt:SetTextColor(1.0, 1.0, 1.0);

    f = CreateFrame("EditBox", nil, sw_frame.profile_frame, "InputBoxTemplate");
    f:SetPoint("TOPLEFT", sw_frame.profile_frame, 195, sw_frame.profile_frame.y_offset+3);
    f:SetSize(140, 15);
    f:SetAutoFocus(false);
    local editbox_save = function(self)
        local txt = self:GetText();
        if txt ~= "" then

            for _, v in pairs(sw_frame.profile_frame.new_profile_section) do
                v:Show();
            end
        else
            for _, v in pairs(sw_frame.profile_frame.new_profile_section) do
                v:Hide();
            end
        end
    end
    f:SetScript("OnEnterPressed", function(self)
        editbox_save(self);
        self:ClearFocus();
    end);
    f:SetScript("OnEscapePressed", function(self)
        editbox_save(self);
        self:ClearFocus();
    end);
    f:SetScript("OnTextChanged", editbox_save);
    sw_frame.profile_frame.new_profile_name_editbox = f;


    sw_frame.profile_frame.y_offset = sw_frame.profile_frame.y_offset - 35;
    sw_frame.profile_frame.new_profile_section = {};
    f_txt = sw_frame.profile_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", 30, sw_frame.profile_frame.y_offset);
    f_txt:SetText("Create new profile as:");
    f_txt:SetTextColor(1.0,  1.0,  1.0);
    sw_frame.profile_frame.new_profile_section.txt1 = f_txt;


    f = CreateFrame("Button", nil, sw_frame.profile_frame, "UIPanelButtonTemplate");
    f:SetScript("OnClick", function(self)

        if config.new_profile_from_default(sw_frame.profile_frame.new_profile_name_editbox:GetText()) then
            sw_frame.profile_frame.new_profile_name_editbox:SetText("");
        end
        update_profile_frame();
    end);
    f:SetPoint("TOPLEFT", 190, sw_frame.profile_frame.y_offset+4);
    f:SetText("Default preset");
    f:SetWidth(200);
    sw_frame.profile_frame.new_profile_section.button1 = f;

    sw_frame.profile_frame.y_offset = sw_frame.profile_frame.y_offset - 25;
    f_txt = sw_frame.profile_frame:CreateFontString(nil, "OVERLAY");
    f_txt:SetFontObject(GameFontNormal);
    f_txt:SetPoint("TOPLEFT", 190, sw_frame.profile_frame.y_offset);
    f_txt:SetText("or");
    f_txt:SetTextColor(1.0,  1.0,  1.0);
    sw_frame.profile_frame.new_profile_section.txt2 = f_txt;

    sw_frame.profile_frame.y_offset = sw_frame.profile_frame.y_offset - 25;
    f = CreateFrame("Button", nil, sw_frame.profile_frame, "UIPanelButtonTemplate");
    f:SetScript("OnClick", function(self)
        if config.new_profile_from_active_copy(sw_frame.profile_frame.new_profile_name_editbox:GetText()) then
            sw_frame.profile_frame.new_profile_name_editbox:SetText("");
        end
        update_profile_frame();
    end);
    f:SetPoint("TOPLEFT", 190, sw_frame.profile_frame.y_offset+4);
    f:SetText("Copy of active profile");
    f:SetWidth(200);
    sw_frame.profile_frame.new_profile_section.button2 = f;
end

local function create_sw_base_ui()

    sw_frame = CreateFrame("Frame", "sw_frame", UIParent, "BasicFrameTemplate, BasicFrameTemplateWithInset");

    sw_frame:SetFrameStrata("HIGH")
    sw_frame:SetMovable(true)
    sw_frame:EnableMouse(true)
    sw_frame:RegisterForDrag("LeftButton")
    sw_frame:SetScript("OnDragStart", sw_frame.StartMoving)
    sw_frame:SetScript("OnDragStop", sw_frame.StopMovingOrSizing)

    local width = 500;
    local height = 600;

    sw_frame:SetWidth(width);
    sw_frame:SetHeight(height);
    sw_frame:SetPoint("TOPLEFT", 400, -30);

    sw_frame.title = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.title:SetFontObject(font)
    sw_frame.title:SetText("Stat Weights Classic v"..swc.core.version);
    sw_frame.title:SetPoint("CENTER", sw_frame.TitleBg, "CENTER", 0, 0);

    sw_frame:Hide();

    local tabbed_child_frames_y_offset = 20;
    local x_margin = 15;

    for _, v in pairs({"spells_frame", "tooltip_frame", "overlay_frame", "loadout_frame", "buffs_frame", "calculator_frame", "profile_frame"}) do
        sw_frame[v] = CreateFrame("ScrollFrame", "sw_"..v, sw_frame);
        sw_frame[v]:SetPoint("TOP", sw_frame, 0, -tabbed_child_frames_y_offset-35);
        sw_frame[v]:SetWidth(width-x_margin*2);
        sw_frame[v]:SetHeight(height-tabbed_child_frames_y_offset-35-5);
        sw_frame[v].y_offset = 0;
    end

    for k, _ in pairs(swc.core.event_dispatch) do
        if not swc.core.event_dispatch_client_exceptions[k] or
                swc.core.event_dispatch_client_exceptions[k] == swc.core.expansion_loaded then
            sw_frame:RegisterEvent(k);
        end
    end

    sw_frame:SetScript("OnEvent", function(self, event, msg, msg2, msg3)
        swc.core.event_dispatch[event](self, msg, msg2, msg3);
        end
    );

    create_sw_spell_id_viewer();

    sw_frame.libstub_icon_checkbox = CreateFrame("CheckButton", "sw_libstub_minimap_button", sw_frame, "ChatConfigCheckButtonTemplate");
    sw_frame.libstub_icon_checkbox._libstub_icon = libstub_icon;
    sw_frame.libstub_icon_checkbox:SetPoint("TOPRIGHT", sw_frame, -115, 0);
    sw_frame.libstub_icon_checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked();
        if checked then
            libstub_icon:Show(swc.core.sw_addon_name);
        else
            libstub_icon:Hide(swc.core.sw_addon_name);
        end
        config.settings.libstub_minimap_icon.hide = not checked;
    end);
    sw_frame.libstub_icon_checkbox:SetHitRectInsets(0, 0, 0, 0);
    sw_frame.libstub_icon_checkbox_txt = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.libstub_icon_checkbox_txt:SetFontObject(font);
    sw_frame.libstub_icon_checkbox_txt:SetText("Minimap button");
    sw_frame.libstub_icon_checkbox_txt:SetPoint("TOPRIGHT", sw_frame, -35, -6);

    sw_frame.tabs = {};

    local i = 1;

    sw_frame.tabs[i] = CreateFrame("Button", "sw_frame_tab_button"..i, sw_frame, "PanelTopTabButtonTemplate");
    --sw_frame.tabs[i]:SetPoint("TOPLEFT", 5, -25);
    --sw_frame.tabs[i]:SetWidth(116);
    sw_frame.tabs[i]:SetHeight(25);
    sw_frame.tabs[i]:SetText("Spells");
    sw_frame.tabs[i]:SetID(1);
    sw_frame.tabs[i]:SetScript("OnClick", function(self)
        sw_activate_tab(self);
    end);
    sw_frame.tabs[i].frame_to_open = sw_frame.spells_frame;
    PanelTemplates_TabResize(sw_frame.tabs[i], 0)

    i = i + 1;
    sw_frame.tabs[i] = CreateFrame("Button", "sw_frame_tab_button"..i, sw_frame, "PanelTopTabButtonTemplate");
    sw_frame.tabs[i]:SetText("Tooltip");
    sw_frame.tabs[i].frame_to_open = sw_frame.tooltip_frame;

    i = i + 1;
    sw_frame.tabs[i] = CreateFrame("Button", "sw_frame_tab_button"..i, sw_frame, "PanelTopTabButtonTemplate");
    sw_frame.tabs[i]:SetText("Overlay");
    sw_frame.tabs[i].frame_to_open = sw_frame.overlay_frame;

    i = i + 1;
    sw_frame.tabs[i] = CreateFrame("Button", "sw_frame_tab_button"..i, sw_frame, "PanelTopTabButtonTemplate");
    sw_frame.tabs[i]:SetText("Loadout");
    sw_frame.tabs[i].frame_to_open = sw_frame.loadout_frame;

    i = i + 1;
    sw_frame.tabs[i] = CreateFrame("Button", "sw_frame_tab_button"..i, sw_frame, "PanelTopTabButtonTemplate");
    sw_frame.tabs[i]:SetText("Buffs");
    sw_frame.tabs[i].frame_to_open = sw_frame.buffs_frame;

    i = i + 1;
    sw_frame.tabs[i] = CreateFrame("Button", "sw_frame_tab_button"..i, sw_frame, "PanelTopTabButtonTemplate");
    sw_frame.tabs[i]:SetText("Calculator");
    sw_frame.tabs[i].frame_to_open = sw_frame.calculator_frame;

    i = i + 1;
    sw_frame.tabs[i] = CreateFrame("Button", "sw_frame_tab_button"..i, sw_frame, "PanelTopTabButtonTemplate");
    sw_frame.tabs[i]:SetText("Profile");
    sw_frame.tabs[i].frame_to_open = sw_frame.profile_frame;

    local x = 5;
    for k, v in pairs(sw_frame.tabs) do

        local w = v:GetFontString():GetStringWidth() + 33;
        v:SetPoint("TOPLEFT", x, -25);
        v:SetWidth(w);
        v:SetHeight(25);
        x = x + w;

        v:SetScript("OnClick", function(self)
            sw_activate_tab(self);
        end);
        v:SetID(k);
        PanelTemplates_TabResize(v, 0);
    end

    PanelTemplates_SetNumTabs(sw_frame, i);
end

local function load_sw_ui()

    if libstub_data_broker then
        local sw_launcher = libstub_data_broker:NewDataObject(swc.core.sw_addon_name, {
            type = "launcher",
            icon = "Interface\\Icons\\spell_fire_elementaldevastation",
            OnClick = function(self, button)
                if button == "MiddleButton" then

                    sw_frame.libstub_icon_checkbox:Click();
                elseif button == "RightButton" then

                    sw_frame_setting_overlay_old_rank:Click();
                    if sw_frame_setting_overlay_disable:GetChecked() then
                        sw_frame_setting_overlay_disable:Click();
                    end
                else
                    if sw_frame:IsShown() then
                        sw_frame:Hide();
                    else
                        sw_activate_tab(sw_frame.tabs[1]);
                    end
                end
            end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine(swc.core.sw_addon_name..": Version "..swc.core.version);
                tooltip:AddLine("|cFF9CD6DELeft click:|r Interact with addon");
                tooltip:AddLine("|cFF9CD6DEMiddle click:|r Hide this button");
                if config.settings.overlay_old_rank then
                    tooltip:AddLine("|cFF9CD6DERight click:|r |cFF00FF00(IS ON)|r Toggle old rank warning overlay");
                else
                    tooltip:AddLine("|cFF9CD6DERight click:|r |cFFFF0000(IS OFF)|r Toggle old rank warning overlay");
                end
                tooltip:AddLine("More info about this addon at:");
                tooltip:AddLine("https://www.curseforge.com/wow/addons/stat-weights-classic");
                tooltip:AddLine("|cFF9CD6DEFactory reset:|r /swc reset");
            end

        });
        if libstub_icon then
            libstub_icon:Register(swc.core.sw_addon_name, sw_launcher, config.settings.libstub_minimap_icon);
        end
    end

    create_sw_ui_spells_frame();
    create_sw_ui_tooltip_frame();
    create_sw_ui_overlay_frame();
    create_sw_ui_loadout_frame();
    create_sw_ui_buffs_frame();
    create_sw_ui_calculator_frame();
    create_sw_ui_profile_frame();

    sw_frame.calculator_frame.sim_type = simulation_type.spam_cast;
    sw_frame.calculator_frame.sim_type_button.init_func();

    sw_activate_tab(sw_frame.tabs[1]);
    sw_frame:Hide();
end

local function add_spell_book_button()
    -- add button to SpellBookFrame
    if SpellBookFrame and SpellBookSkillLineTab1 then
        local button = CreateFrame("Button", "__swc_frame_spellbook_tab", SpellBookFrame);
        button.background = button:CreateTexture(nil, "BACKGROUND");
        button:ClearAllPoints();
        button:SetSize(32, 32);
        button:SetNormalTexture("Interface\\Icons\\spell_fire_elementaldevastation");
        button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");

        button.background:ClearAllPoints()
        button.background:SetPoint("TOPLEFT", -3, 11)
        button.background:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
        button:SetScript("OnClick", function() 
            if sw_frame:IsShown() then
                sw_frame:Hide();
            else
                sw_activate_tab(sw_frame.tabs[1]);
            end
        end);

        local n = GetNumSpellTabs();
        local y_padding = 17;
        local y_tab_offsets = SpellBookSkillLineTab2:GetHeight() + y_padding;
        -- Clique is right after last slot, put after where clique could be
        button:SetPoint("TOPLEFT", _G["SpellBookSkillLineTab"..n], "BOTTOMLEFT", 0, -(y_tab_offsets + y_padding));
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
            GameTooltip:ClearLines();
            GameTooltip:SetText("SpellCoda ability catalogue");
        end);
        button:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end);


    end

end


ui.font                                 = font;
ui.load_sw_ui                           = load_sw_ui;
ui.icon_overlay_font                    = icon_overlay_font;
ui.create_sw_base_ui                    = create_sw_base_ui;
ui.effects_from_ui                      = effects_from_ui;
ui.display_spell_diff                   = display_spell_diff;
ui.update_calc_list                     = update_calc_list;
ui.sw_activate_tab                      = sw_activate_tab;
ui.update_buffs_frame                   = update_buffs_frame;
ui.update_profile_frame                 = update_profile_frame;
ui.update_loadout_frame                 = update_loadout_frame;
ui.add_spell_book_button                = add_spell_book_button;

swc.ui = ui;

