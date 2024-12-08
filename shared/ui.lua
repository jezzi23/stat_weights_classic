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
local spell_name_to_id                          = swc.abilities.spell_name_to_id;
local spell_flags                               = swc.abilities.spell_flags;

local wowhead_talent_link                       = swc.talents.wowhead_talent_link;
local wowhead_talent_code_from_url              = swc.talents.wowhead_talent_code_from_url;

local simulation_type                           = swc.calc.simulation_type;

local class                                     = swc.utils.class;
local effect_colors                             = swc.utils.effect_colors;

local active_loadout_and_effects_diffed_from_ui = swc.loadout.active_loadout_and_effects_diffed_from_ui;

local stats_for_spell                           = swc.calc.stats_for_spell;
local spell_info                                = swc.calc.spell_info;
local cast_until_oom                            = swc.calc.cast_until_oom;
local spell_diff                                = swc.calc.spell_diff;

local buff_filters                              = swc.buffs.buff_filters;
local filter_flags_active                       = swc.buffs.filter_flags_active;
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

local update_and_display_spell_diffs = nil;

local function ui_y_offset_incr(y)
    return y - 17;
end

-- generalize some reasonable editbox config that need to update on change
-- that is easy to exit / lose focus
local function editbox_config(frame, update_func, close_func)
    -- TODO: 
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

local function display_spell_diff(spell_id, spell, spell_diff_line, spell_info_normal, spell_info_diff, frame, is_duality_spell, sim_type, lvl)

    local diff = spell_diff(spell_info_normal, spell_info_diff, sim_type);

    local v = nil;
    if is_duality_spell then
        if not spell_diff_line.duality then
            spell_diff_line.duality = {};
        end
        spell_diff_line.duality.name = spell_diff_line.name;
        v = spell_diff_line.duality;
    else
        v = spell_diff_line;
    end
    frame.line_y_offset = ui_y_offset_incr(frame.line_y_offset);
    if not v.name_str then
        v.name_str = frame:CreateFontString(nil, "OVERLAY");
        v.name_str:SetFontObject(font);
        v.change = frame:CreateFontString(nil, "OVERLAY");
        v.change:SetFontObject(font);
        v.first = frame:CreateFontString(nil, "OVERLAY");
        v.first:SetFontObject(font);
        v.second = frame:CreateFontString(nil, "OVERLAY");
        v.second:SetFontObject(font);

        if not spell.healing_version then
            v.cancel_button = CreateFrame("Button", "nil", frame, "UIPanelButtonTemplate"); 
        end
    end

    v.name_str:SetPoint("TOPLEFT", 15, frame.line_y_offset);

    local rank_str = "";
    if swc.core.expansion_loaded == swc.core.expansions.wotlk then
        rank_str = "(OLD RANK!!!)";
        if lvl <= spell.lvl_outdated then
            rank_str = "(Rank "..spell.rank..")";
        end
    else
        rank_str = "(Rank "..spell.rank..")";
    end

    if is_duality_spell and 
        bit.band(spell.flags, spell_flags.heal) ~= 0 then

        v.name_str:SetText(v.name.." H "..rank_str);
    elseif v.name == spell_name_to_id["Holy Nova"] or v.name == spell_name_to_id["Holy Shock"] or v.name == spell_name_to_id["Penance"] then

        v.name_str:SetText(v.name.." D "..rank_str);
    else
        v.name_str:SetText(v.name.." "..rank_str);
    end

    v.name_str:SetTextColor(222/255, 192/255, 40/255);

    if not frame.is_valid then

        v.change:SetPoint("TOPRIGHT", -180, frame.line_y_offset);
        v.change:SetText("NAN");

        v.first:SetPoint("TOPRIGHT", -115, frame.line_y_offset);
        v.first:SetText("NAN");

        v.second:SetPoint("TOPRIGHT", -45, frame.line_y_offset);
        v.second:SetText("NAN");

    else

        v.change:SetPoint("TOPRIGHT", -180, frame.line_y_offset);
        v.first:SetPoint("TOPRIGHT", -115, frame.line_y_offset);
        v.second:SetPoint("TOPRIGHT", -45, frame.line_y_offset);

        if diff.first < 0 then
            v.change:SetText(string.format("%.2f", diff.diff_ratio).."%");
            v.change:SetTextColor(195/255, 44/255, 11/255);

            v.first:SetText(string.format("%.2f", diff.first));
            v.first:SetTextColor(195/255, 44/255, 11/255);

        elseif diff.first > 0 then

            v.change:SetText(string.format("+%.2f", diff.diff_ratio).."%");
            v.change:SetTextColor(33/255, 185/255, 21/255);

            v.first:SetText(string.format("+%.2f", diff.first));
            v.first:SetTextColor(33/255, 185/255, 21/255);

        else
            v.change:SetText("0 %");
            v.change:SetTextColor(1, 1, 1);

            v.first:SetText("0");
            v.first:SetTextColor(1, 1, 1);
        end

        if diff.second < 0 then

            v.second:SetText(string.format("%.2f", diff.second));
            v.second:SetTextColor(195/255, 44/255, 11/255);
        elseif diff.second > 0 then

            v.second:SetText(string.format("+%.2f", diff.second));
            v.second:SetTextColor(33/255, 185/255, 21/255);
        else

            v.second:SetText("0");
            v.second:SetTextColor(1, 1, 1);
        end
            
        if not spell.healing_version then
            v.cancel_button:SetScript("OnClick", function()

                v.change:Hide();
                v.name_str:Hide();
                v.first:Hide();
                v.second:Hide();
                v.cancel_button:Hide();

                -- in case this was the duality spell, i.e. healing counterpart 
                frame.spells[spell_id].change:Hide();
                frame.spells[spell_id].name_str:Hide();
                frame.spells[spell_id].first:Hide();
                frame.spells[spell_id].second:Hide();

                frame.spells[spell_id] = nil;
                update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());

            end);

            v.cancel_button:SetPoint("TOPRIGHT", -10, frame.line_y_offset + 3);
            v.cancel_button:SetHeight(20);
            v.cancel_button:SetWidth(25);
            v.cancel_button:SetText("X");
        end
    end
end

update_and_display_spell_diffs = function(loadout, effects, effects_diffed)

    local frame = sw_frame.calculator_frame;

    frame.line_y_offset = frame.line_y_offset_before_dynamic_spells;

    local spell_stats_normal = {};
    local spell_stats_diffed = {};
    local spell_info_normal = {};
    local spell_info_diffed = {};

    --local num_spells = 0;
    --for k, v in pairs(frame.spells) do
    --    num_spells = num_spells + 1;
    --end
    --if num_spells == 0 then
    --    -- try to find something relevant to display
    --    for i = 1, 120 do
    --        local action_type, id, _ = GetActionInfo(i);
    --        if action_type == "spell" and spells[id] and bit.band(spells[id].flags, spell_flags.mana_regen) == 0 then

    --            num_spells = num_spells + 1;

    --            local lname = GetSpellInfo(id);

    --            frame.spells[id] = {
    --                name = lname
    --            };

    --        end
    --        if num_spells == 3 then
    --            break;
    --        end
    --    end
    --end

    for random_rank, v in pairs(frame.spells) do

        -- best rank
        --local k = best_rank_by_lvl(spells[random_rank].base_id, loadout.lvl);
        --if not k then
        --    k = random_rank;
        --end
        local k = random_rank;

        stats_for_spell(spell_stats_normal, spells[k], loadout, effects);
        stats_for_spell(spell_stats_diffed, spells[k], loadout, effects_diffed);
        spell_info(spell_info_normal, spells[k], spell_stats_normal, loadout, effects);
        cast_until_oom(spell_info_normal, spell_stats_normal, loadout, effects, true);
        spell_info(spell_info_diffed, spells[k], spell_stats_diffed, loadout, effects_diffed);
        cast_until_oom(spell_info_diffed, spell_stats_diffed, loadout, effects_diffed, true);

        display_spell_diff(random_rank, spells[k], v, spell_info_normal, spell_info_diffed, frame, false, sw_frame.calculator_frame.sim_type, loadout.lvl);

        -- for spells with both heal and dmg
        if spells[k].healing_version then

            stats_for_spell(spell_stats_normal, spells[k].healing_version, loadout, effects);
            stats_for_spell(spell_stats_diffed, spells[k].healing_version, loadout, effects_diffed);
            spell_info(spell_info_normal, spells[k].healing_version, spell_stats_normal, loadout, effects);
            cast_until_oom(spell_info_normal, spell_stats_normal, loadout, effects, true);
            spell_info(spell_info_diffed, spells[k].healing_version, spell_stats_diffed, loadout, effects_diffed);
            cast_until_oom(spell_info_diffed, spell_stats_diffed, loadout, effects_diffed, true);

            display_spell_diff(random_rank, spells[k].healing_version, v, spell_info_normal, spell_info_diffed, frame, true, sw_frame.calculator_frame.sim_type, loadout.lvl);
        end
    end

    -- footer
    frame.line_y_offset = ui_y_offset_incr(frame.line_y_offset);
    frame.line_y_offset = ui_y_offset_incr(frame.line_y_offset);

    if not frame.footer then
        frame.footer = frame:CreateFontString(nil, "OVERLAY");
    end
    frame.footer:SetFontObject(font);
    frame.footer:SetPoint("TOPLEFT", 15, frame.line_y_offset);
    frame.footer:SetText("Add abilities by holding CONTROL while hovering their tooltips");
end

local function update_buffs_frame()

    if config.loadout.force_apply_buffs then
        sw_frame.loadout_frame.always_apply_buffs_button:SetChecked(true);
    else
        sw_frame.loadout_frame.always_apply_buffs_button:SetChecked(false);
    end

    local num_checked_buffs = 0;
    local num_checked_target_buffs = 0;
    local buffs_list_alpha = 1.0;
    if not config.loadout.force_apply_buffs then
        buffs_list_alpha = 0.2;
        for k = 1, sw_frame.buffs_frame.lhs.buffs.num do
            local v = sw_frame.buffs_frame.lhs.buffs[k];
            --v.checkbutton:SetChecked(true);
            v.checkbutton:Hide();
            v.icon:Hide();
        end

        for k = 1, sw_frame.buffs_frame.rhs.buffs.num do
            local v = sw_frame.buffs_frame.rhs.buffs[k];
            --v.checkbutton:SetChecked(true);
            v.checkbutton:Hide();
            v.icon:Hide();
        end
    else
        for k = 1, sw_frame.buffs_frame.lhs.buffs.num do

            local v = sw_frame.buffs_frame.lhs.buffs[k];
            if v.checkbutton.buff_type == "self" then
                if config.loadout.buffs[v.checkbutton.buff_id] then
                    v.checkbutton:SetChecked(true);
                    num_checked_buffs = num_checked_buffs + 1;
                else
                    v.checkbutton:SetChecked(false);
                end
            end
            v.checkbutton:Hide();
            v.icon:Hide();
        end
        for k = 1, sw_frame.buffs_frame.rhs.buffs.num do

            local v = sw_frame.buffs_frame.rhs.buffs[k];

            if config.loadout.target_buffs[v.checkbutton.buff_id] then
                v.checkbutton:SetChecked(true);
                num_checked_target_buffs = num_checked_target_buffs + 1;
            else
                v.checkbutton:SetChecked(false);
            end
            v.checkbutton:Hide();
            v.icon:Hide();
        end
    end
    -- all checkbuttons have been hidden, now unhide and set positions depending on slider

    local icon_offset = -4;
    for _, v in pairs({sw_frame.buffs_frame.lhs, sw_frame.buffs_frame.rhs}) do
        local y_offset = 0;
        local buffs_show_max = v.num_buffs_can_fit;
        local num_skips = math.floor(v.slider:GetValue()) + 1;

        for i = num_skips, math.min(num_skips + buffs_show_max - 1, v.buffs.num) do
            v.buffs[i].checkbutton:SetPoint("TOPLEFT", 20, y_offset);
            v.buffs[i].checkbutton:SetAlpha(buffs_list_alpha);
            v.buffs[i].checkbutton:Show();
            v.buffs[i].icon:SetPoint("TOPLEFT", 5, y_offset + icon_offset);
            v.buffs[i].icon:SetAlpha(buffs_list_alpha);
            v.buffs[i].icon:Show();
            y_offset = y_offset - 20;
        end
    end

    --local target_buffs_iters = 
    --    math.max(0, math.min(buffs_show_max - num_skips, sw_frame.buffs_frame.rhs.buffs.num - num_skips) + 1);
    --if buffs_show_max < num_skips and num_skips <= sw_frame.buffs_frame.rhs.buffs.num then
    --    target_buffs_iters = buffs_show_max;
    --end
    --if target_buffs_iters > 0 then
    --    for i = num_skips, num_skips + target_buffs_iters - 1 do
    --        sw_frame.buffs_frame.rhs.buffs[i].checkbutton:SetPoint("TOPLEFT", 20, y_offset);
    --        sw_frame.buffs_frame.rhs.buffs[i].checkbutton:SetAlpha(buffs_list_alpha);
    --        sw_frame.buffs_frame.rhs.buffs[i].checkbutton:Show();
    --        sw_frame.buffs_frame.rhs.buffs[i].icon:SetPoint("TOPLEFT", 5, y_offset + icon_offset);
    --        sw_frame.buffs_frame.rhs.buffs[i].icon:SetAlpha(buffs_list_alpha);
    --        sw_frame.buffs_frame.rhs.buffs[i].icon:Show();
    --        y_offset = y_offset - 20;
    --    end
    --end

    --    num_skips = num_skips + target_buffs_iters - sw_frame.buffs_frame.rhs.buffs.num;
    --end

    sw_frame.buffs_frame.lhs.buffs.num_checked = num_checked_buffs;
    sw_frame.buffs_frame.rhs.buffs.num_checked = num_checked_target_buffs;

    if not config.loadout.force_apply_buffs then
        --sw_frame.buffs_frame.lhs.select_all_buffs_checkbutton:SetChecked(true);
        --sw_frame.buffs_frame.rhs.select_all_buffs_checkbutton:SetChecked(true);
    else
        sw_frame.buffs_frame.lhs.select_all_buffs_checkbutton:SetChecked(sw_frame.buffs_frame.lhs.buffs.num_checked ~= 0);

        sw_frame.buffs_frame.rhs.select_all_buffs_checkbutton:SetChecked(sw_frame.buffs_frame.rhs.buffs.num_checked ~= 0);
    end
    sw_frame.buffs_frame.lhs.select_all_buffs_checkbutton:SetAlpha(buffs_list_alpha);
    sw_frame.buffs_frame.rhs.select_all_buffs_checkbutton:SetAlpha(buffs_list_alpha);
end

function update_loadout_frame()

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
        config.loadout.name
    );

    update_buffs_frame();

    update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());
end


local function sw_activate_tab(tab_window)

    sw_frame:Show();

    for _, v in pairs(sw_frame.tabs) do
        v.frame_to_open:Hide();
        v:UnlockHighlight();
        v:SetButtonState("NORMAL");
    end

    if tab_window.frame_to_open == sw_frame.calculator_frame then
        update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());
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
        if spell_name_to_id[txt] then
            self:SetText(tostring(spell_name_to_id[txt]));
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

local function multi_row_checkbutton(buttons_info, parent_frame, num_columns, func)
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
        local x_pad = 10;
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
        elseif func then
            f:SetScript("OnClick", func);
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
    f_txt:SetText("Tooltip display options         Presets:");
    f_txt:SetTextColor(232.0/255, 225.0/255, 32.0/255);


    local tooltip_components = {
        {
            id = "tooltip_display_addon_name",
            txt = "Addon Name"
        },
        {
            id = "tooltip_display_dynamic_tip",
            txt = "Evaluation options",
            tooltip = "For certain spells, shows hotkey to change evaluation method dynamically in the tooltip.";
        },
        {
            id = "tooltip_display_loadout_info",
            txt = "Loadout info",
            color = effect_colors.addon_info,
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
            id = "tooltip_display_hit",
            txt = "Hit & resist chance",
            color = effect_colors.normal
        },
        {
            id = "tooltip_display_normal",
            txt = "Normal effect",
            color = effect_colors.normal
        },
        {
            id = "tooltip_display_normal_hit_combined",
            txt = "Normal effect & hit info combined",
            color = effect_colors.normal
        },
        {
            id = "tooltip_display_crit_chance",
            txt = "Critical chance & modifier",
            color = effect_colors.crit
        },
        {
            id = "tooltip_display_crit",
            txt = "Critical effect",
            color = effect_colors.crit
        },
        {
            id = "tooltip_display_crit_combined",
            txt = "Critical effect & chance combined",
            color = effect_colors.crit
        },
        {
            id = "tooltip_display_expected",
            txt = "Expected effect",
            color = effect_colors.expectation
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

    sw_frame.tooltip_frame.preset_minimalistic_button:SetPoint("TOPLEFT", 230, sw_frame.tooltip_frame.y_offset+14);
    sw_frame.tooltip_frame.preset_minimalistic_button:SetText("Minimalistic");
    sw_frame.tooltip_frame.preset_minimalistic_button:SetWidth(90);

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
        getglobal("sw_frame_setting_tooltip_display_normal_hit_combined"):Click();
        getglobal("sw_frame_setting_tooltip_display_crit_combined"):Click();
        getglobal("sw_frame_setting_tooltip_display_expected"):Click();
        getglobal("sw_frame_setting_tooltip_display_effect_per_sec"):Click();
        getglobal("sw_frame_setting_tooltip_display_effect_per_cost"):Click();
        getglobal("sw_frame_setting_tooltip_display_dynamic_tip"):Click();
    end);
    sw_frame.tooltip_frame.preset_default_button:SetPoint("TOPLEFT", 320, sw_frame.tooltip_frame.y_offset+14);
    sw_frame.tooltip_frame.preset_default_button:SetText("Default");
    sw_frame.tooltip_frame.preset_default_button:SetWidth(70);

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
        getglobal("sw_frame_setting_tooltip_display_normal_hit_combined"):Click();
        getglobal("sw_frame_setting_tooltip_display_crit_combined"):Click();
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
    sw_frame.tooltip_frame.preset_detailed_button:SetPoint("TOPLEFT", 390, sw_frame.tooltip_frame.y_offset+14);
    sw_frame.tooltip_frame.preset_detailed_button:SetText("Detailed");
    sw_frame.tooltip_frame.preset_detailed_button:SetWidth(80);
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
            end
        },
        {
            id = "overlay_old_rank",
            txt = "Old rank warning",
            color = effect_colors.crit,
        },
        {
            id = "overlay_mana_abilities",
            txt = "Show mana restorative spells ",
            color = effect_colors.avg_cost,
            tooltip = "Puts mana restoration amount on overlay for spells like Evocation."
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
        config.settings.overlay_disable = false;
        sw_frame_setting_overlay_disable:SetChecked(false);

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
        elseif sw_frame.overlay_frame.num_overlay_components_toggled == 0 then
            config.settings.overlay_disable = true;
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
            color = effect_colors.expectation
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

    sw_frame.calculator_frame.line_y_offset = -20;

    sw_frame.calculator_frame.line_y_offset = ui_y_offset_incr(sw_frame.calculator_frame.line_y_offset);
    sw_frame.calculator_frame.instructions_label = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.instructions_label:SetFontObject(font);
    sw_frame.calculator_frame.instructions_label:SetPoint("TOPLEFT", 15, sw_frame.calculator_frame.line_y_offset);
    sw_frame.calculator_frame.instructions_label:SetText("While this tab is open, ability overlay & tooltips reflect the change below");


    sw_frame.calculator_frame.line_y_offset = ui_y_offset_incr(sw_frame.calculator_frame.line_y_offset);

    sw_frame.calculator_frame.loadout_label = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.loadout_label:SetFontObject(font);
    sw_frame.calculator_frame.loadout_label:SetPoint("TOPLEFT", 15, sw_frame.calculator_frame.line_y_offset);
    sw_frame.calculator_frame.loadout_label:SetText("Active Loadout: ");
    sw_frame.calculator_frame.loadout_label:SetTextColor(222/255, 192/255, 40/255);

    sw_frame.calculator_frame.loadout_name_label = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.loadout_name_label:SetFontObject(font);
    sw_frame.calculator_frame.loadout_name_label:SetPoint("TOPLEFT", 110, sw_frame.calculator_frame.line_y_offset);
    sw_frame.calculator_frame.loadout_name_label:SetText("Missing loadout!");
    sw_frame.calculator_frame.loadout_name_label:SetTextColor(222/255, 192/255, 40/255);


    sw_frame.calculator_frame.line_y_offset = ui_y_offset_incr(sw_frame.calculator_frame.line_y_offset);

    sw_frame.calculator_frame.stat_diff_header_left = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.stat_diff_header_left:SetFontObject(font);
    sw_frame.calculator_frame.stat_diff_header_left:SetPoint("TOPLEFT", 15, sw_frame.calculator_frame.line_y_offset);
    sw_frame.calculator_frame.stat_diff_header_left:SetText("Stat");

    sw_frame.calculator_frame.stat_diff_header_center = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.stat_diff_header_center:SetFontObject(font);
    sw_frame.calculator_frame.stat_diff_header_center:SetPoint("TOPRIGHT", -80, sw_frame.calculator_frame.line_y_offset);
    sw_frame.calculator_frame.stat_diff_header_center:SetText("Difference");


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
        --for i = 1, num_stats do

        --    sw_frame.calculator_frame.stats[i].editbox:SetText("");
        --end

        update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());
    end);

    sw_frame.calculator_frame.clear_button:SetPoint("TOPRIGHT", -30, sw_frame.calculator_frame.line_y_offset + 3);
    sw_frame.calculator_frame.clear_button:SetHeight(15);
    sw_frame.calculator_frame.clear_button:SetWidth(50);
    sw_frame.calculator_frame.clear_button:SetText("Clear");

    --sw_frame.calculator_frame.line_y_offset = sw_frame.calculator_frame.line_y_offset - 10;


    for i, k in pairs(comparison_stats_listing_order) do

        v = sw_frame.calculator_frame.stats[k];

        sw_frame.calculator_frame.line_y_offset = ui_y_offset_incr(sw_frame.calculator_frame.line_y_offset);

        v.label = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");

        v.label:SetFontObject(font);
        v.label:SetPoint("TOPLEFT", 15, sw_frame.calculator_frame.line_y_offset);
        v.label:SetText(v.label_str);
        v.label:SetTextColor(222/255, 192/255, 40/255);

        v.editbox = CreateFrame("EditBox", v.label_str.."editbox"..k, sw_frame.calculator_frame, "InputBoxTemplate");
        v.editbox:SetPoint("TOPRIGHT", -30, sw_frame.calculator_frame.line_y_offset);
        v.editbox:SetText("");
        v.editbox:SetAutoFocus(false);
        v.editbox:SetSize(100, 10);
        v.editbox:SetScript("OnTextChanged", function(self)

            if string.match(self:GetText(), "[^-+0123456789. ()]") ~= nil then
                self:ClearFocus();
                self:SetText("");
                self:SetFocus();
            else 
                update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());
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

    sw_frame.calculator_frame.line_y_offset = ui_y_offset_incr(sw_frame.calculator_frame.line_y_offset);

    -- sim type button
    sw_frame.calculator_frame.sim_type_button = 
        CreateFrame("Button", "sw_sim_type_button", sw_frame.calculator_frame, "UIDropDownMenuTemplate"); 
    sw_frame.calculator_frame.sim_type_button:SetPoint("TOPLEFT", -5, sw_frame.calculator_frame.line_y_offset);
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
                        sw_frame.calculator_frame.spell_diff_header_right_spam_cast:Show();
                        sw_frame.calculator_frame.spell_diff_header_right_cast_until_oom:Hide();
                        update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());
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
                        sw_frame.calculator_frame.spell_diff_header_right_spam_cast:Hide();
                        sw_frame.calculator_frame.spell_diff_header_right_cast_until_oom:Show();
                        update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());
                    end
                }
            );
        end);
    end;

    sw_frame.calculator_frame.sim_type_button:SetText("Simulation type");

    sw_frame.calculator_frame.line_y_offset = ui_y_offset_incr(sw_frame.calculator_frame.line_y_offset);
    sw_frame.calculator_frame.line_y_offset = ui_y_offset_incr(sw_frame.calculator_frame.line_y_offset);

    sw_frame.calculator_frame.line_y_offset_before_dynamic_spells = sw_frame.calculator_frame.line_y_offset;

    sw_frame.calculator_frame.spell_diff_header_spell = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.spell_diff_header_spell:SetFontObject(font);
    sw_frame.calculator_frame.spell_diff_header_spell:SetPoint("TOPLEFT", 15, sw_frame.calculator_frame.line_y_offset);
    sw_frame.calculator_frame.spell_diff_header_spell:SetText("Spell");

    sw_frame.calculator_frame.spell_diff_header_left = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.spell_diff_header_left:SetFontObject(font);
    sw_frame.calculator_frame.spell_diff_header_left:SetPoint("TOPRIGHT", -180, sw_frame.calculator_frame.line_y_offset);
    sw_frame.calculator_frame.spell_diff_header_left:SetText("Change");

    sw_frame.calculator_frame.spell_diff_header_center = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.spell_diff_header_center:SetFontObject(font);
    sw_frame.calculator_frame.spell_diff_header_center:SetPoint("TOPRIGHT", -110, sw_frame.calculator_frame.line_y_offset);
    sw_frame.calculator_frame.spell_diff_header_center:SetText("DPS/HPS");

    sw_frame.calculator_frame.spell_diff_header_right_spam_cast = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.spell_diff_header_right_spam_cast:SetFontObject(font);
    sw_frame.calculator_frame.spell_diff_header_right_spam_cast:SetPoint("TOPRIGHT", -30, sw_frame.calculator_frame.line_y_offset);
    sw_frame.calculator_frame.spell_diff_header_right_spam_cast:SetText("DMG/HEAL");

    sw_frame.calculator_frame.spell_diff_header_right_cast_until_oom = sw_frame.calculator_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.calculator_frame.spell_diff_header_right_cast_until_oom:SetFontObject(font);
    sw_frame.calculator_frame.spell_diff_header_right_cast_until_oom:SetPoint("TOPRIGHT", -20, sw_frame.calculator_frame.line_y_offset);
    sw_frame.calculator_frame.spell_diff_header_right_cast_until_oom:SetText("DURATION (s)");

    -- always have at least one
    sw_frame.calculator_frame.spells = {};
    sw_frame.calculator_frame.sim_type = simulation_type.spam_cast;

    if class == "DRUID" then
        local lname = GetSpellInfo(5185);
        sw_frame.calculator_frame.spells[5185] = {name = lname};
    elseif class == "MAGE" then
        local lname = GetSpellInfo(133);
        sw_frame.calculator_frame.spells[133] = {name = lname};
    elseif class == "WARLOCK" then
        local lname = GetSpellInfo(686);
        sw_frame.calculator_frame.spells[686] = {name = lname};
    elseif class == "PALADIN" then
        local lname = GetSpellInfo(635);
        sw_frame.calculator_frame.spells[635] = {name = lname};
    elseif class == "PRIEST" then
        local lname = GetSpellInfo(585);
        sw_frame.calculator_frame.spells[585] = {name = lname};
    elseif class == "SHAMAN" then
        local lname = GetSpellInfo(403);
        sw_frame.calculator_frame.spells[403] = {name = lname};
    end
end

local function create_loadout_buff_checkbutton(buffs_table, buff_id, buff_info, buff_type, parent_frame, func)

    local index = buffs_table.num + 1;

    buffs_table[index] = {};
    buffs_table[index].checkbutton = CreateFrame("CheckButton", "loadout_apply_buffs_"..buff_info.lname..index, parent_frame, "ChatConfigCheckButtonTemplate");
    buffs_table[index].checkbutton.buff_info = buff_info.filter;
    buffs_table[index].checkbutton.buff_category = buff_info.category;
    buffs_table[index].checkbutton.buff_lname = buff_info.lname;
    buffs_table[index].checkbutton.buff_type = buff_type;
    buffs_table[index].checkbutton.buff_id = buff_id;
    local rgb = {};
    if buff_info.category == buff_category.class  then
        rgb = {235/255, 52/255, 88/255};
    elseif buff_info.category == buff_category.raid  then
        rgb = {103/255, 52/255, 235/255};
    elseif buff_info.category == buff_category.consumes  then
        rgb = {225/255, 235/255, 52/255};
    elseif buff_info.category == buff_category.item  then
        rgb = {0/255, 204/255, 255/255};
    elseif buff_info.category == buff_category.world_buffs  then
        rgb = {0/255, 153/255, 51/255};
    end
    local buff_name_max_len = 27;
    local name_appear =  buff_info.lname;
    if buff_info.name then
        name_appear =  buff_info.name;
    end
    getglobal(buffs_table[index].checkbutton:GetName() .. 'Text'):SetText(name_appear:sub(1, buff_name_max_len));
    local checkbutton_txt = getglobal(buffs_table[index].checkbutton:GetName() .. 'Text');
    checkbutton_txt:SetTextColor(rgb[1], rgb[2], rgb[3]);
    buffs_table[index].checkbutton:SetScript("OnClick", func);

    buffs_table[index].icon = CreateFrame("Frame", "loadout_apply_buffs_icon_"..buff_info.lname, parent_frame);
    buffs_table[index].icon:SetSize(15, 15);
    local tex = buffs_table[index].icon:CreateTexture(nil);
    tex:SetAllPoints(buffs_table[index].icon);
    if buff_info.icon_id then
        tex:SetTexture(buff_info.icon_id);
    else
        tex:SetTexture(GetSpellTexture(buff_id));
    end

    buffs_table[index].checkbutton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
        GameTooltip:SetSpellByID(buff_id);
        GameTooltip:Show();
    end);
    buffs_table[index].checkbutton:SetScript("OnLeave", function(self)
        GameTooltip:Hide();
    end);

    buffs_table.num = index;

    return buffs_table[index].checkbutton;
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

            UIDropDownMenu_SetWidth(sw_frame.loadout_frame.loadout_dropdown, 130);

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
    f:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad + 250, sw_frame.loadout_frame.y_offset);
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
        "Accepts a valid wowhead talents link, your loadout will use its talents, glyphs and runes instead of your active ones.";
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

        print("updating talents editbox");
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

    if swc.core.expansion_loaded == swc.core.expansions.vanilla then

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

    f = CreateFrame("CheckButton", "sw_frame_loadout_always_max_mana", sw_frame.loadout_frame, "ChatConfigCheckButtonTemplate");
    f._type = "CheckButton";
    f:SetPoint("TOPLEFT", sw_frame.loadout_frame, x_pad, sw_frame.loadout_frame.y_offset);
    getglobal(f:GetName()..'Text'):SetText("Always at maximum mana");
    getglobal(f:GetName()).tooltip = 
        "Casting until OOM uses maximum mana instead of current.";
    f:SetScript("OnClick", function(self)
        config.loadout.always_max_mana = self:GetChecked();
    end)

    sw_frame.loadout_frame.max_mana_checkbutton = f;

end

local function create_sw_ui_buffs_frame()



    local f = CreateFrame("CheckButton", "sw_frame_buffs_frame_toggle", sw_frame.buffs_frame, "ChatConfigCheckButtonTemplate");
    f:SetPoint("TOPLEFT", sw_frame.buffs_frame, 0, sw_frame.buffs_frame.y_offset);
    getglobal(f:GetName() .. 'Text'):SetText("Apply buffs even when inactive");
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
    sw_frame.loadout_frame.always_apply_buffs_button = f;

    local w = sw_buffs_frame;
    f = CreateFrame("ScrollFrame", "sw_frame_lhs_frame", sw_frame.buffs_frame);
    f:SetWidth(235);
    f:SetHeight(500);
    f:SetPoint("TOPLEFT", sw_frame.buffs_frame, 0, -50);
    sw_frame.buffs_frame.lhs = {}
    sw_frame.buffs_frame.lhs.frame = f;

    f = CreateFrame("ScrollFrame", "sw_frame_rhs_frame", sw_frame.buffs_frame);
    f:SetWidth(235);
    f:SetHeight(500);
    f:SetPoint("TOPLEFT", sw_frame.buffs_frame, 235, -50);
    sw_frame.buffs_frame.rhs = {}
    sw_frame.buffs_frame.rhs.frame = f;

    f = CreateFrame("ScrollFrame", "sw_frame_lhs_buffs_list_frame", sw_frame.buffs_frame.lhs.frame);
    f:SetWidth(235);
    f:SetHeight(470);
    f:SetPoint("TOPLEFT", sw_frame.buffs_frame.lhs.frame, 0, -25);
    sw_frame.buffs_frame.lhs.buffs_list_frame = f;

    f = CreateFrame("ScrollFrame", "sw_frame_rhs_buffs_list_frame", sw_frame.buffs_frame.rhs.frame);
    f:SetWidth(235);
    f:SetHeight(470);
    f:SetPoint("TOPLEFT", sw_frame.buffs_frame.rhs.frame, 0, -25);
    sw_frame.buffs_frame.rhs.buffs_list_frame = f;

    sw_frame.buffs_frame.lhs.num_checked = 0;
    sw_frame.buffs_frame.rhs.num_checked = 0;

    sw_frame.buffs_frame.lhs.buffs = {};
    sw_frame.buffs_frame.lhs.buffs.num = 0;
    sw_frame.buffs_frame.rhs.buffs = {};
    sw_frame.buffs_frame.rhs.buffs.num = 0;

    local y_offset = sw_frame.buffs_frame.y_offset;

    local y_offset_buffs = y_offset;
    local y_offset_target_buffs = y_offset;

    local check_button_buff_func = function(self)

        if not config.loadout.force_apply_buffs then
            self:SetChecked(true);
            return;
        end
        if self:GetChecked() then
            if self.buff_type == "self" then
                config.loadout.buffs[self.buff_id] = self.buff_info;
                sw_frame.buffs_frame.lhs.buffs.num_checked = sw_frame.buffs_frame.lhs.buffs.num_checked + 1;
            elseif self.buff_type == "target_buffs" then
                config.loadout.target_buffs[self.buff_id] = self.buff_info;
                sw_frame.buffs_frame.rhs.buffs.num_checked = sw_frame.buffs_frame.rhs.buffs.num_checked + 1;
            end

        else    
            if self.buff_type == "self" then
                config.loadout.buffs[self.buff_id] = nil;
                sw_frame.buffs_frame.lhs.buffs.num_checked = sw_frame.buffs_frame.lhs.buffs.num_checked - 1;
            elseif self.buff_type == "target_buffs" then
                config.loadout.target_buffs[self.buff_id] = nil;
                sw_frame.buffs_frame.rhs.buffs.num_checked = sw_frame.buffs_frame.rhs.buffs.num_checked - 1;
            end
        end

        if sw_frame.buffs_frame.lhs.buffs.num_checked == 0 then
            sw_frame.buffs_frame.lhs.select_all_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.buffs_frame.lhs.select_all_buffs_checkbutton:SetChecked(true);
        end

        if sw_frame.buffs_frame.rhs.buffs.num_checked == 0 then
            sw_frame.buffs_frame.rhs.select_all_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.buffs_frame.rhs.select_all_buffs_checkbutton:SetChecked(true);
        end
    end

    f = CreateFrame("CheckButton", "sw_frame_buffs_frame_lhs_select_buffs", sw_frame.buffs_frame.lhs.frame, "ChatConfigCheckButtonTemplate");
    f:SetPoint("TOPLEFT", 20, y_offset_buffs);
    getglobal(f:GetName() .. 'Text'):SetText("SELECT ALL/NONE");
    getglobal(f:GetName() .. 'Text'):SetTextColor(1, 0, 0);

    f:SetScript("OnClick", function(self)

        if not config.loadout.force_apply_buffs then
            --self:SetChecked(true)
            return;
        end
        if self:GetChecked() then
            for i = 1, sw_frame.buffs_frame.lhs.buffs.num do
                config.loadout.buffs[sw_frame.buffs_frame.lhs.buffs[i].checkbutton.buff_id] =
                    sw_frame.buffs_frame.lhs.buffs[i].checkbutton.buff_info;
            end
        else
            config.loadout.buffs = {};
        end

        update_buffs_frame();
    end);
    sw_frame.buffs_frame.lhs.select_all_buffs_checkbutton = f;

    f = CreateFrame("CheckButton", "sw_frame_buffs_frame_rhs_select_buffs", sw_frame.buffs_frame.rhs.frame, "ChatConfigCheckButtonTemplate");
    f:SetPoint("TOPLEFT", 20, y_offset_buffs);
    getglobal(f:GetName() .. 'Text'):SetText("SELECT ALL/NONE");
    getglobal(f:GetName() .. 'Text'):SetTextColor(1, 0, 0);

    f:SetScript("OnClick", function(self) 

        if not config.loadout.force_apply_buffs then
            --self:SetChecked(true)
            return;
        end
        if self:GetChecked() then
            for i = 1, sw_frame.buffs_frame.rhs.buffs.num do
                config.loadout.target_buffs[sw_frame.buffs_frame.rhs.buffs[i].checkbutton.buff_id] =
                    sw_frame.buffs_frame.rhs.buffs[i].checkbutton.buff_info;
            end
        else
            config.loadout.target_buffs = {};
        end

        update_buffs_frame();
    end);
    sw_frame.buffs_frame.rhs.select_all_buffs_checkbutton = f;

    -- 
    y_offset_buffs = y_offset_buffs - 20;
    y_offset_target_buffs = y_offset_target_buffs - 20;

    -- buffs
    local sorted_buffs_by_name = {};
    for k, v in pairs(buffs) do
        if bit.band(filter_flags_active, v.filter) ~= 0 and bit.band(buff_filters.hidden, v.filter) == 0 then
            local lname = select(1, GetSpellInfo(k));
            table.insert(sorted_buffs_by_name, {lname, v.category, k});
        end
    end
    table.sort(sorted_buffs_by_name, function(lhs, rhs)  return lhs[2]..lhs[1] < rhs[2]..rhs[1] end);
    for _, k in ipairs(sorted_buffs_by_name) do
        local buff_id = k[3];
        local v = buffs[buff_id];
        create_loadout_buff_checkbutton(
            sw_frame.buffs_frame.lhs.buffs, buff_id, v, "self",
            sw_frame.buffs_frame.lhs.buffs_list_frame, check_button_buff_func
        );
    end

    -- debuffs
    sorted_buffs_by_name = {};
    for k, v in pairs(target_buffs) do
        if bit.band(filter_flags_active, v.filter) ~= 0 and bit.band(buff_filters.hidden, v.filter) == 0 then
            local lname = select(1, GetSpellInfo(k));
            table.insert(sorted_buffs_by_name, {lname, v.category, k});
        end
    end
    table.sort(sorted_buffs_by_name, function(lhs, rhs)  return lhs[2]..lhs[1] < rhs[2]..rhs[1] end);
    for _, k in ipairs(sorted_buffs_by_name) do
        local buff_id = k[3];
        local v = target_buffs[buff_id];
        create_loadout_buff_checkbutton(
            sw_frame.buffs_frame.rhs.buffs, buff_id, v, "target_buffs",
            sw_frame.buffs_frame.rhs.buffs_list_frame, check_button_buff_func
        );
    end

    -- sliders
    f = CreateFrame("Slider", nil, sw_frame.buffs_frame.lhs.buffs_list_frame, "UISliderTemplate");
    f:SetOrientation('VERTICAL');
    f:SetPoint("RIGHT", sw_frame.buffs_frame.lhs.buffs_list_frame, "RIGHT", 0, 5);
    f:SetSize(15, sw_frame.buffs_frame.lhs.buffs_list_frame:GetHeight());
    sw_frame.buffs_frame.lhs.num_buffs_can_fit =
        math.floor(f:GetHeight()/20);
    f:SetMinMaxValues(
        0,
        max(0, sw_frame.buffs_frame.lhs.buffs.num - sw_frame.buffs_frame.lhs.num_buffs_can_fit)
    );
    f:SetValue(0);
    f:SetValueStep(1);
    f:SetScript("OnValueChanged", function(self, val)
        update_buffs_frame();
    end);
    sw_frame.buffs_frame.lhs.slider = f;

    sw_frame.buffs_frame.lhs.buffs_list_frame:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.buffs_frame.lhs.slider:GetMinMaxValues();
        local val = sw_frame.buffs_frame.lhs.slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.buffs_frame.lhs.slider:SetValue(val - dir);
            update_buffs_frame();
        end
    end);

    f = CreateFrame("Slider", nil, sw_frame.buffs_frame.rhs.buffs_list_frame, "UISliderTemplate");
    f:SetOrientation('VERTICAL');
    f:SetPoint("RIGHT", sw_frame.buffs_frame.rhs.buffs_list_frame, "RIGHT", 0, 5);
    f:SetSize(15, sw_frame.buffs_frame.rhs.buffs_list_frame:GetHeight());
    sw_frame.buffs_frame.rhs.num_buffs_can_fit = 
        math.floor(f:GetHeight()/20);
    f:SetMinMaxValues(
        0,
        max(0, sw_frame.buffs_frame.rhs.buffs.num - sw_frame.buffs_frame.rhs.num_buffs_can_fit)
    );
    f:SetValue(0);
    f:SetValueStep(1);
    f:SetScript("OnValueChanged", function(self, val)
        update_buffs_frame();
    end);

    sw_frame.buffs_frame.rhs.buffs_list_frame:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.buffs_frame.rhs.slider:GetMinMaxValues();
        local val = sw_frame.buffs_frame.rhs.slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.buffs_frame.rhs.slider:SetValue(val - dir);
            update_buffs_frame();
        end
    end);
    sw_frame.buffs_frame.rhs.slider = f;
end

local function update_profile_frame()

    swc.config.set_active_settings(swc.core.active_spec);

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

    --if sw_frame.profile_frame.new_profile_name_editbox:GetText() ~= "" then
    --    for _, v in pairs(sw_frame.profile_frame.new_profile_section) do
    --        v:Show();
    --    end
    --else
    --    for _, v in pairs(sw_frame.profile_frame.new_profile_section) do
    --        v:Hide();
    --    end
    --end

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
                            swc.config.activate_settings();
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
                            swc.config.activate_settings();
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

    local f = CreateFrame("EditBox", nil, sw_frame.profile_frame, "InputBoxTemplate");
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
                else
                    if sw_frame:IsShown() then
                         sw_frame:Hide();
                    else
                         sw_frame:Show();
                    end
                end
            end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine(swc.core.sw_addon_name..": Version "..swc.core.version);
                tooltip:AddLine("|cFF9CD6DELeft click:|r Interact with addon");
                tooltip:AddLine("|cFF9CD6DEMiddle click:|r Hide this button");
                tooltip:AddLine("More info about this addon at:");
                tooltip:AddLine("https://www.curseforge.com/wow/addons/stat-weights-classic");
                tooltip:AddLine("|cFF9CD6DEFactory reset:|r /swc reset");
            end,
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
    sw_frame.calculator_frame.spell_diff_header_right_spam_cast:Show();
    sw_frame.calculator_frame.spell_diff_header_right_cast_until_oom:Hide();
    sw_frame.calculator_frame.sim_type_button.init_func();

    sw_activate_tab(sw_frame.tabs[1]);
    sw_frame:Hide();
end

ui.font                                 = font;
ui.load_sw_ui                           = load_sw_ui;
ui.icon_overlay_font                    = icon_overlay_font;
ui.create_sw_base_ui                    = create_sw_base_ui;
ui.effects_from_ui                      = effects_from_ui;
ui.update_and_display_spell_diffs       = update_and_display_spell_diffs;
ui.sw_activate_tab                      = sw_activate_tab;
ui.update_buffs_frame                   = update_buffs_frame;
ui.update_profile_frame                 = update_profile_frame;

swc.ui = ui;

