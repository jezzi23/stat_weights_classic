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
local spell_name_to_id                          = swc.abilities.spell_name_to_id;
local spell_names_to_id                         = swc.abilities.spell_names_to_id;
local magic_school                              = swc.abilities.magic_school;
local spell_flags                               = swc.abilities.spell_flags;
local best_rank_by_lvl                          = swc.abilities.best_rank_by_lvl;

local wowhead_talent_link                       = swc.talents.wowhead_talent_link;
local wowhead_talent_code                       = swc.talents.wowhead_talent_code;
local wowhead_talent_code_from_url              = swc.talents.wowhead_talent_code_from_url;

local simulation_type                           = swc.calc.simulation_type;

local default_sw_settings                       = swc.settings.default_sw_settings;

local update_icon_overlay_settings              = swc.overlay.update_icon_overlay_settings
local icon_stat_display                         = swc.overlay.icon_stat_display;

local loadout_flags                             = swc.utils.loadout_flags;
local stat_ids_in_ui                            = swc.utils.stat_ids_in_ui;
local class                                     = swc.utils.class;
local deep_table_copy                           = swc.utils.deep_table_copy;

local empty_loadout                             = swc.loadout.empty_loadout;
local empty_effects                             = swc.loadout.empty_effects;
local effects_add                               = swc.loadout.effects_add;
local effects_zero_diff                         = swc.loadout.effects_zero_diff;
local default_loadout                           = swc.loadout.default_loadout;
local active_loadout                            = swc.loadout.active_loadout;
local active_loadout_entry                      = swc.loadout.active_loadout_entry;
local static_loadout_from_dynamic               = swc.loadout.static_loadout_from_dynamic;
local active_loadout_and_effects                = swc.loadout.active_loadout_and_effects;
local print_loadout                             = swc.loadout.print_loadout;
local active_loadout_and_effects_diffed_from_ui = swc.loadout.active_loadout_and_effects_diffed_from_ui;

local stats_for_spell                           = swc.calc.stats_for_spell;
local spell_info                                = swc.calc.spell_info;
local cast_until_oom                            = swc.calc.cast_until_oom;
local evaluate_spell                            = swc.calc.evaluate_spell;
local spell_diff                                = swc.calc.spell_diff;

local tooltip_stat_display                      = swc.tooltip.tooltip_stat_display;

local buff_filters                              = swc.buffs.buff_filters;
local filter_flags_active                       = swc.buffs.filter_flags_active;
local buff_category                             = swc.buffs.buff_category;
local buffs                                     = swc.buffs.buffs;
local target_buffs                              = swc.buffs.target_buffs;

-------------------------------------------------------------------------
local ui = {};

local sw_frame = {};

local icon_overlay_font = "Interface\\AddOns\\StatWeightsClassic\\fonts\\Oswald-Bold.ttf";
local font = "GameFontHighlightSmall";

local libstub_data_broker = LibStub("LibDataBroker-1.1", true)
local libstub_icon = libstub_data_broker and LibStub("LibDBIcon-1.0", true)

local update_and_display_spell_diffs = nil;

local function ui_y_offset_incr(y) 
    return y - 17;
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
            v.cancel_button = CreateFrame("Button", "button", frame, "UIPanelButtonTemplate"); 
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

    local frame = sw_frame.stat_comparison_frame;

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
        local k = best_rank_by_lvl(spells[random_rank].base_id, loadout.lvl);
        if k == 0 then
            k = random_rank;
        end
        

        stats_for_spell(spell_stats_normal, spells[k], loadout, effects);
        stats_for_spell(spell_stats_diffed, spells[k], loadout, effects_diffed);
        spell_info(spell_info_normal, spells[k], spell_stats_normal, loadout, effects);
        cast_until_oom(spell_info_normal, spell_stats_normal, loadout, effects, true);
        spell_info(spell_info_diffed, spells[k], spell_stats_diffed, loadout, effects_diffed);
        cast_until_oom(spell_info_diffed, spell_stats_diffed, loadout, effects_diffed, true);

        display_spell_diff(random_rank, spells[k], v, spell_info_normal, spell_info_diffed, frame, false, sw_frame.stat_comparison_frame.sim_type, loadout.lvl);

        -- for spells with both heal and dmg
        if spells[k].healing_version then

            stats_for_spell(spell_stats_normal, spells[k].healing_version, loadout, effects);
            stats_for_spell(spell_stats_diffed, spells[k].healing_version, loadout, effects_diffed);
            spell_info(spell_info_normal, spells[k].healing_version, spell_stats_normal, loadout, effects);
            cast_until_oom(spell_info_normal, spell_stats_normal, loadout, effects, true);
            spell_info(spell_info_diffed, spells[k].healing_version, spell_stats_diffed, loadout, effects_diffed);
            cast_until_oom(spell_info_diffed, spell_stats_diffed, loadout, effects_diffed, true);

            display_spell_diff(random_rank, spells[k].healing_version, v, spell_info_normal, spell_info_diffed, frame, true, sw_frame.stat_comparison_frame.sim_type, loadout.lvl);
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

local function loadout_name_already_exists(name)

    local already_exists = false;    
    for i = 1, sw_frame.loadouts_frame.lhs_list.num_loadouts do
    
        if name == sw_frame.loadouts_frame.lhs_list.loadouts[i].base.name then
            already_exists = true;
        end
    end
    return already_exists;
end

local function update_loadouts_rhs()

    local loadout = active_loadout();

    if sw_frame.loadouts_frame.lhs_list.num_loadouts == 1 then

        sw_frame.loadouts_frame.rhs_list.delete_button:Hide();
    else
        sw_frame.loadouts_frame.rhs_list.delete_button:Show();
    end

    sw_frame.stat_comparison_frame.loadout_name_label:SetText(
        loadout.name
    );

    sw_frame.loadouts_frame.rhs_list.name_editbox:SetText(
        loadout.name
    );

    sw_frame.loadouts_frame.rhs_list.level_editbox:SetText(
        loadout.default_target_lvl_diff
    );

    if bit.band(loadout.flags, loadout_flags.custom_lvl) ~= 0 then

        sw_frame.loadouts_frame.rhs_list.custom_lvl_checkbutton:SetChecked(true);
        sw_frame.loadouts_frame.rhs_list.loadout_clvl_editbox:SetText(
            loadout.lvl
        );
        --sw_frame.loadouts_frame.rhs_list.loadout_clvl_editbox:Show();
        sw_frame.loadouts_frame.rhs_list.loadout_clvl_editbox:SetAlpha(1.0);
    else
        sw_frame.loadouts_frame.rhs_list.custom_lvl_checkbutton:SetChecked(false);
        --sw_frame.loadouts_frame.rhs_list.loadout_clvl_editbox:Hide();
        sw_frame.loadouts_frame.rhs_list.loadout_clvl_editbox:SetAlpha(0.2);
    end

    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetText(
        loadout.extra_mana
    );

    sw_frame.loadouts_frame.rhs_list.hp_perc_label_editbox:SetText(
        loadout.target_hp_perc_default * 100
    );

    if sw_frame.loadouts_frame.rhs_list.target_res_editbox then
        sw_frame.loadouts_frame.rhs_list.target_res_editbox:SetText(
            loadout.target_res
        );
    end

    sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetText(loadout.unbounded_aoe_targets);

    if bit.band(loadout.flags, loadout_flags.is_dynamic_loadout) ~= 0 then

        sw_frame.loadouts_frame.rhs_list.talent_editbox:SetText(
            wowhead_talent_link(loadout.talents_code)
        );
        sw_frame.loadouts_frame.rhs_list.talent_editbox:SetAlpha(0.2);
        sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(false);
    else

        sw_frame.loadouts_frame.rhs_list.talent_editbox:SetText(
            wowhead_talent_link(loadout.custom_talents_code)
        );
        sw_frame.loadouts_frame.rhs_list.talent_editbox:SetAlpha(1.0);
        sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(true);
    end

    if bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0 then
        sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetChecked(true);
    else
        sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetChecked(false);
    end

    local num_checked_buffs = 0;
    local num_checked_target_buffs = 0;
    local buffs_list_alpha = 1.0;
    if bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0 then
        buffs_list_alpha = 0.2;
        for k = 1, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs do
            local v = sw_frame.loadouts_frame.rhs_list.buffs[k];
            v.checkbutton:SetChecked(true);
            v.checkbutton:Hide();
            v.icon:Hide();
        end

        for k = 1, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs do
            local v = sw_frame.loadouts_frame.rhs_list.target_buffs[k];
            v.checkbutton:SetChecked(true);
            v.checkbutton:Hide();
            v.icon:Hide();
        end
    else
        for k = 1, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs do

            local v = sw_frame.loadouts_frame.rhs_list.buffs[k];
            if v.checkbutton.buff_type == "self" then
                
                if loadout.buffs[v.checkbutton.buff_lname] then
                    v.checkbutton:SetChecked(true);
                    num_checked_buffs = num_checked_buffs + 1;
                else
                    v.checkbutton:SetChecked(false);
                end
            end
            v.checkbutton:Hide();
            v.icon:Hide();
        end
        for k = 1, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs do

            local v = sw_frame.loadouts_frame.rhs_list.target_buffs[k];

            if loadout.target_buffs[v.checkbutton.buff_lname] then
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
    local y_offset = 0;
    local buffs_show_max = 0;
    local num_buffs = 0;
    local num_skips = 0;
    local self_buffs_tab = sw_frame.loadouts_frame.rhs_list.self_buffs_frame:IsShown();

    if self_buffs_tab then
        y_offset = sw_frame.loadouts_frame.rhs_list.self_buffs_y_offset_start;
        buffs_show_max = sw_frame.loadouts_frame.rhs_list.buffs.num_buffs_can_fit;
        num_buffs = sw_frame.loadouts_frame.rhs_list.buffs.num_buffs;
        num_skips = math.floor(sw_frame.loadouts_frame.self_buffs_slider:GetValue()) + 1;
    else
        y_offset = sw_frame.loadouts_frame.rhs_list.target_buffs_y_offset_start;
        buffs_show_max = sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs_can_fit;
        num_buffs = sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs;
        num_skips = math.floor(sw_frame.loadouts_frame.target_buffs_slider:GetValue()) + 1;
    end

    local icon_offset = -4;

    if self_buffs_tab then
        for i = num_skips, math.min(num_skips + buffs_show_max - 1, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs) do
            sw_frame.loadouts_frame.rhs_list.buffs[i].checkbutton:SetPoint("TOPLEFT", 20, y_offset);
            sw_frame.loadouts_frame.rhs_list.buffs[i].checkbutton:SetAlpha(buffs_list_alpha);
            sw_frame.loadouts_frame.rhs_list.buffs[i].checkbutton:Show();
            sw_frame.loadouts_frame.rhs_list.buffs[i].icon:SetPoint("TOPLEFT", 5, y_offset + icon_offset);
            sw_frame.loadouts_frame.rhs_list.buffs[i].icon:SetAlpha(buffs_list_alpha);
            sw_frame.loadouts_frame.rhs_list.buffs[i].icon:Show();
            y_offset = y_offset - 20;
        end
    else
        
        local target_buffs_iters = 
            math.max(0, math.min(buffs_show_max - num_skips, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs - num_skips) + 1);
        if buffs_show_max < num_skips and num_skips <= sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs then
            target_buffs_iters = buffs_show_max;
        end
        if target_buffs_iters > 0 then
            for i = num_skips, num_skips + target_buffs_iters - 1 do
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].checkbutton:SetPoint("TOPLEFT", 20, y_offset);
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].checkbutton:SetAlpha(buffs_list_alpha);
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].checkbutton:Show();
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].icon:SetPoint("TOPLEFT", 5, y_offset + icon_offset);
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].icon:SetAlpha(buffs_list_alpha);
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].icon:Show();
                y_offset = y_offset - 20;
            end
        end

        num_skips = num_skips + target_buffs_iters - sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs;
    end

    sw_frame.loadouts_frame.rhs_list.num_checked_buffs = num_checked_buffs;
    sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs = num_checked_target_buffs;

    if bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0 then
        sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(true);
        sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(true);
    else
        if sw_frame.loadouts_frame.rhs_list.num_checked_buffs == 0 then
            sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(true);
        end
        if sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs == 0 then

            sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(true);
        end
    end
    sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetAlpha(buffs_list_alpha);
    sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetAlpha(buffs_list_alpha);
end

local loadout_checkbutton_id_counter = 1;

function update_loadouts_lhs()

    local y_offset = -13;
    local max_slider_val = math.max(0, sw_frame.loadouts_frame.lhs_list.num_loadouts - sw_frame.loadouts_frame.lhs_list.num_loadouts_can_fit);

    sw_frame.loadouts_frame.loadouts_slider:SetMinMaxValues(0, max_slider_val);
    if sw_frame.loadouts_frame.loadouts_slider:GetValue() > max_slider_val then
        sw_frame.loadouts_frame.loadouts_slider:SetValue(max_slider_val);
    end

    local num_skips = math.floor(sw_frame.loadouts_frame.loadouts_slider:GetValue()) + 1;


    -- precheck to create if needed and hide by default
    for k, v in pairs(sw_frame.loadouts_frame.lhs_list.loadouts) do

        local checkbutton_name = "sw_frame_loadouts_lhs_list"..k;
        v.check_button = getglobal(checkbutton_name);

        if not v.check_button then


            v.check_button = 
                CreateFrame("CheckButton", checkbutton_name, sw_frame.loadouts_frame.lhs_list, "ChatConfigCheckButtonTemplate");

            v.check_button.target_index = k;

            v.check_button:SetScript("OnClick", function(self)
                
                for i = 1, sw_frame.loadouts_frame.lhs_list.num_loadouts  do

                    sw_frame.loadouts_frame.lhs_list.loadouts[i].check_button:SetChecked(false);
                    
                end
                self:SetChecked(true);

                swc.core.talents_update_needed = true;
                swc.core.equipment_update_needed = true;

                sw_frame.loadouts_frame.lhs_list.active_loadout = self.target_index;

                update_loadouts_rhs();
            end);
        end

        v.check_button:Hide();
    end

    -- show the ones in frames according to scroll slider
    for k = num_skips, math.min(num_skips + sw_frame.loadouts_frame.lhs_list.num_loadouts_can_fit - 1, 
                                sw_frame.loadouts_frame.lhs_list.num_loadouts) do

        local v = sw_frame.loadouts_frame.lhs_list.loadouts[k];

        getglobal(v.check_button:GetName() .. 'Text'):SetText(v.loadout.name);
        v.check_button:SetPoint("TOPLEFT", 10, y_offset);
        v.check_button:Show();

        if k == sw_frame.loadouts_frame.lhs_list.active_loadout then
            v.check_button:SetChecked(true);
        else
            v.check_button:SetChecked(false);
        end

        y_offset = y_offset - 20;
    end

    update_loadouts_rhs();
end

local function create_new_loadout_as_copy(loadout_entry)


    sw_frame.loadouts_frame.lhs_list.loadouts[
        sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(false);

    sw_frame.loadouts_frame.lhs_list.num_loadouts = sw_frame.loadouts_frame.lhs_list.num_loadouts + 1;
    sw_frame.loadouts_frame.lhs_list.active_loadout = sw_frame.loadouts_frame.lhs_list.num_loadouts;

    sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.num_loadouts] = {};
    local new_entry = sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.num_loadouts];
    new_entry.loadout = deep_table_copy(loadout_entry.loadout);
    new_entry.equipped = deep_table_copy(loadout_entry.equipped);
    new_entry.talented = {};
    empty_effects(new_entry.talented);
    new_entry.final_effects = {};
    empty_effects(new_entry.final_effects);

    swc.core.talents_update_needed = true;

    new_entry.loadout.name = loadout_entry.loadout.name.." (Copy)";

    update_loadouts_lhs();

    sw_frame.loadouts_frame.lhs_list.loadouts[
        sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(true);
end

local function sw_activate_tab(tab_index)

    sw_frame.active_tab = tab_index;

    sw_frame:Show();

    sw_frame.settings_frame:Hide();
    sw_frame.loadouts_frame:Hide();
    sw_frame.stat_comparison_frame:Hide();

    sw_frame.tab1:UnlockHighlight();
    sw_frame.tab1:SetButtonState("NORMAL");
    sw_frame.tab2:UnlockHighlight();
    sw_frame.tab2:SetButtonState("NORMAL");
    sw_frame.tab3:UnlockHighlight();
    sw_frame.tab3:SetButtonState("NORMAL");

    if tab_index == 1 then
        sw_frame.settings_frame:Show();
        sw_frame.tab1:LockHighlight();
        sw_frame.tab1:SetButtonState("PUSHED");
    elseif tab_index == 2 then
        sw_frame.loadouts_frame:Show();
        sw_frame.tab2:LockHighlight();
        sw_frame.tab2:SetButtonState("PUSHED");
    elseif tab_index == 3 then

        update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());
        sw_frame.stat_comparison_frame:Show();
        sw_frame.tab3:LockHighlight();
        sw_frame.tab3:SetButtonState("PUSHED");
    end
end

local function create_sw_checkbox(name, parent, line_pos_index, y_offset, text, check_func)

    local checkbox_frame = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate"); 
    local x_spacing = 180;
    local x_pad = 10;
    checkbox_frame:SetPoint("TOPLEFT", x_pad + (line_pos_index - 1) * x_spacing, y_offset);
    getglobal(checkbox_frame:GetName() .. 'Text'):SetText(text);
    if check_func then
        checkbox_frame:SetScript("OnClick", check_func);
    end

    return checkbox_frame;
end

local function create_sw_spell_id_viewer()

    sw_frame.spell_id_viewer_editbox = CreateFrame("EditBox", "sw_spell_id_viewer_editbox", sw_frame, "InputBoxTemplate");
    sw_frame.spell_id_viewer_editbox:SetPoint("TOPLEFT", sw_frame, 10, -7);
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
    sw_frame.spell_id_viewer_editbox_label:SetPoint("TOPLEFT", sw_frame, 9, -7);

    sw_frame.spell_icon = CreateFrame("Frame", "__swc_custom_spell_id", sw_frame);
    sw_frame.spell_icon:SetSize(15, 15);
    sw_frame.spell_icon:SetPoint("TOPLEFT", sw_frame, 101, -5);
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
local function create_sw_gui_settings_frame()

    sw_frame.settings_frame:SetWidth(370);
    sw_frame.settings_frame:SetHeight(600);
    sw_frame.settings_frame:SetPoint("TOP", sw_frame, 0, -20);

    -- content frame for settings
    sw_frame.settings_frame.y_offset = -35;

    sw_frame.settings_frame.icon_settings_label = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.icon_settings_label:SetFontObject(font);
    sw_frame.settings_frame.icon_settings_label:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_settings_label:SetText("Ability Icon Overlay Display Options (max 3)");
    sw_frame.settings_frame.icon_settings_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    -- TODO: this needs to be checked based on saved vars
    sw_frame.settings_frame.icons_num_checked = 0;

    local icon_checkbox_func = function(self)
        if self:GetChecked() then
            if sw_frame.settings_frame.icons_num_checked >= 3 then
                self:SetChecked(false);
            else
                sw_frame.settings_frame.icons_num_checked = sw_frame.settings_frame.icons_num_checked + 1;
            end
        else
            sw_frame.settings_frame.icons_num_checked = sw_frame.settings_frame.icons_num_checked - 1;
        end
        update_icon_overlay_settings();
    end;

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 15;
    sw_frame.settings_frame.icon_normal_effect = 
        create_sw_checkbox("sw_icon_normal_effect", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Normal effect", icon_checkbox_func);
    sw_frame.settings_frame.icon_crit_effect = 
        create_sw_checkbox("sw_icon_crit_effect", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Critical effect", icon_checkbox_func); 
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_expected_effect = 
        create_sw_checkbox("sw_icon_expected_effect", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Expected effect", icon_checkbox_func);  
    getglobal(sw_frame.settings_frame.icon_expected_effect:GetName()).tooltip = 
        "Expected effect is the DMG or Heal dealt on average for a single cast considering miss chance, crit chance, spell power etc. This equates to your DPS or HPS number multiplied with the ability's cast time"

    sw_frame.settings_frame.icon_effect_per_sec = 
        create_sw_checkbox("sw_icon_effect_per_sec", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Effect per sec", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_effect_per_cost = 
        create_sw_checkbox("sw_icon_effect_per_costs", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Effect per cost", icon_checkbox_func);  
    sw_frame.settings_frame.icon_avg_cost = 
        create_sw_checkbox("sw_icon_avg_cost", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Expected cost", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_avg_cast = 
        create_sw_checkbox("sw_icon_avg_cast", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Expected cast time", icon_checkbox_func);
    sw_frame.settings_frame.icon_hit = 
        create_sw_checkbox("sw_icon_hit", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Hit chance", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_crit = 
        create_sw_checkbox("sw_icon_crit_chance", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Critical chance", icon_checkbox_func);  
    sw_frame.settings_frame.icon_casts_until_oom = 
        create_sw_checkbox("sw_icon_casts_until_oom", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Casts until OOM", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    sw_frame.settings_frame.icon_effect_until_oom = 
        create_sw_checkbox("sw_icon_effect_until_oom", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Effect until OOM", icon_checkbox_func);  
    sw_frame.settings_frame.icon_time_until_oom = 
        create_sw_checkbox("sw_icon_time_until_oom", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Time until OOM", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 10;

    sw_frame.settings_frame.icon_settings_label = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.icon_settings_label:SetFontObject(font);
    sw_frame.settings_frame.icon_settings_label:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_settings_label:SetText("Ability Icon Overlay Configuration");
    sw_frame.settings_frame.icon_settings_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    sw_frame.settings_frame.icon_overlay_disable = 
        create_sw_checkbox("sw_icon_overlay_disable", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Disable all overlays", nil);

    sw_frame.settings_frame.icon_mana_overlay = 
        create_sw_checkbox("sw_icon_mana_overlay", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Show mana restoration", nil);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    sw_frame.settings_frame.icon_heal_variant = 
        create_sw_checkbox("sw_icon_heal_variant", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Show healing for hybrids", nil);  

    sw_frame.settings_frame.icon_old_rank_warning = 
        create_sw_checkbox("sw_icon_old_rank_warning", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Old rank warning", nil);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    sw_frame.settings_frame.icon_overlay_disable:SetScript("OnClick", function(self)
            
        swc.overlay.clear_overlays();
        
    end);

    sw_frame.settings_frame.icon_show_single_target_only = 
        create_sw_checkbox("sw_icon_show_single_target_only", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Show single target only", nil);  

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 30;
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetFontObject(font);
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetText("Update frequency");

    sw_frame.settings_frame.icon_settings_update_freq_label_lhs = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetFontObject(font);
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetPoint("TOPLEFT", 170, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetText("Hz (higher = more responsive overlay)");

    sw_frame.settings_frame.icon_settings_update_freq_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.settings_frame, "InputBoxTemplate");
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetPoint("TOPLEFT", 120, sw_frame.settings_frame.y_offset + 3);
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetText("");
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetSize(40, 15);
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetAutoFocus(false);

    local hz_editbox = function(self)

        local hz = tonumber(self:GetText());
        if hz and hz >= 0.01 and hz <= 300 then

            sw_snapshot_loadout_update_freq = tonumber(hz);
            
        else
            self:SetText("3"); 
            sw_snapshot_loadout_update_freq = 3;
        end

    	self:ClearFocus();
        self:HighlightText(0,0);
    end

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 30;

    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetScript("OnEnterPressed", hz_editbox);
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetScript("OnEscapePressed", hz_editbox);
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetScript("OnEditFocusLost", hz_editbox);
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetScript("OnTextChanged", function(self)
        local hz = tonumber(self:GetText());
        if hz and hz >= 0.01 and hz <= 300 then

            sw_snapshot_loadout_update_freq = tonumber(hz);
        end

    end);

    sw_frame.settings_frame.icon_overlay_font_size_slider =
        CreateFrame("Slider", "icon_overlay_font_size", sw_frame.settings_frame, "OptionsSliderTemplate");
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetMinMaxValues(2, 24)
    getglobal(sw_frame.settings_frame.icon_overlay_font_size_slider:GetName()..'Text'):SetText("Icon overlay font size");
    getglobal(sw_frame.settings_frame.icon_overlay_font_size_slider:GetName()..'Low'):SetText("");
    getglobal(sw_frame.settings_frame.icon_overlay_font_size_slider:GetName()..'High'):SetText("");
    sw_frame.settings_frame.icon_overlay_font_size = __sw__persistent_data_per_char.settings.icon_overlay_font_size;
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetValue(sw_frame.settings_frame.icon_overlay_font_size);
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetValueStep(1)
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetScript("OnValueChanged", function(self, val)
        sw_frame.settings_frame.icon_overlay_font_size = val;

        for k, v in pairs(swc.overlay.spell_book_frames) do
            if v.frame then
                local spell_name = v.frame.SpellName:GetText();
                local spell_rank_name = v.frame.SpellSubName:GetText();
                local _, _, _, _, _, _, id = GetSpellInfo(spell_name, spell_rank_name);
                for i = 1, 3 do
                    v.overlay_frames[i]:SetFont(
                        icon_overlay_font, sw_frame.settings_frame.icon_overlay_font_size, "THICKOUTLINE");
                end
            end
        end
        for k, v in pairs(swc.overlay.action_id_frames) do
            if v.frame then
                for i = 1, 3 do
                    v.overlay_frames[i]:SetFont(
                        icon_overlay_font, sw_frame.settings_frame.icon_overlay_font_size, "THICKOUTLINE");
                end
            end
        end
    end);


    local num_icon_overlay_checks = 0;
    -- set checkboxes for _icon options as  according to persistent data per char
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.normal) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_normal_effect:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.crit) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_crit_effect:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.expected) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_expected_effect:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.effect_per_sec) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_effect_per_sec:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.effect_per_cost) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_effect_per_cost:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.avg_cost) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_avg_cost:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.avg_cast) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_avg_cast:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.hit) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_hit:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.crit_chance) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_crit:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.casts_until_oom) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_casts_until_oom:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.effect_until_oom) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_effect_until_oom:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.time_until_oom) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_time_until_oom:SetChecked(true);
        end
    end
    sw_frame.settings_frame.icons_num_checked = num_icon_overlay_checks;

    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.show_heal_variant) ~= 0 then
        sw_frame.settings_frame.icon_heal_variant:SetChecked(true);
    end

    if __sw__persistent_data_per_char.settings.icon_overlay_disable then
        sw_frame.settings_frame.icon_overlay_disable:SetChecked(true);
    end

    if __sw__persistent_data_per_char.settings.icon_overlay_mana_abilities then
        sw_frame.settings_frame.icon_mana_overlay:SetChecked(true);
    end

    if __sw__persistent_data_per_char.settings.icon_overlay_old_rank then
        sw_frame.settings_frame.icon_old_rank_warning:SetChecked(true);
    end

    if __sw__persistent_data_per_char.settings.icon_show_single_target_only then
        sw_frame.settings_frame.icon_show_single_target_only:SetChecked(true);
    end

    sw_snapshot_loadout_update_freq = __sw__persistent_data_per_char.settings.icon_overlay_update_freq;
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetText(""..sw_snapshot_loadout_update_freq);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    sw_frame.settings_frame.tooltip_settings_label = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.tooltip_settings_label:SetFontObject(font);
    sw_frame.settings_frame.tooltip_settings_label:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.tooltip_settings_label:SetText("Ability Tooltip Display Options");
    sw_frame.settings_frame.tooltip_settings_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 15;

    -- tooltip options
    sw_frame.settings_frame.tooltip_num_checked = 0;
    local tooltip_checkbox_func = function(self)
        if self:GetChecked() then
            sw_frame.settings_frame.tooltip_num_checked = sw_frame.settings_frame.tooltip_num_checked + 1;
        else
            sw_frame.settings_frame.tooltip_num_checked = sw_frame.settings_frame.tooltip_num_checked - 1;
        end
    end;

    sw_frame.settings_frame.tooltip_loadout_info = 
        create_sw_checkbox("sw_tooltip_loadout_info", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Loadout info", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_spell_rank = 
        create_sw_checkbox("sw_tooltip_spell_rank", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Spell rank info", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    sw_frame.settings_frame.tooltip_normal_effect = 
        create_sw_checkbox("sw_tooltip_normal_effect", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Normal effect", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_crit_effect = 
        create_sw_checkbox("sw_tooltip_crit_effect", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Critical effect", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_normal_ot = 
        create_sw_checkbox("sw_tooltip_normal_ot", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Normal over time effect", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_crit_ot = 
        create_sw_checkbox("sw_tooltip_crit_ot", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Critical over time effect", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_expected_effect = 
        create_sw_checkbox("sw_tooltip_expected_effect", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Expected effect", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_effect_per_sec = 
        create_sw_checkbox("sw_tooltip_effect_per_sec", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Effect per sec", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_effect_per_cost = 
        create_sw_checkbox("sw_tooltip_effect_per_cost", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Effect per cost", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_cost_per_sec = 
        create_sw_checkbox("sw_tooltip_cost_per_sec", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Cost per sec", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_stat_weights = 
        create_sw_checkbox("sw_tooltip_stat_weights", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Stat weights", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_avg_cost = 
        create_sw_checkbox("sw_tooltip_avg_cost", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Expected cost", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_avg_cast = 
        create_sw_checkbox("sw_tooltip_avg_cast", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Expected cast time", tooltip_checkbox_func);

    sw_frame.settings_frame.tooltip_cast_until_oom = 
        create_sw_checkbox("sw_tooltip_cast_until_oom", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Cast until OOM", tooltip_checkbox_func);
    getglobal(sw_frame.settings_frame.tooltip_cast_until_oom:GetName()).tooltip = 
        "Assumes you cast a particular ability until you are OOM with no cooldowns.";
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    sw_frame.settings_frame.tooltip_sp_effect_calc = 
        create_sw_checkbox("sw_tooltip_sp_effect_calc", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Coef & SP effect calc", tooltip_checkbox_func);
    --if class == "WARLOCK" then    
    --    sw_frame.settings_frame.tooltip_cast_and_tap = 
    --        create_sw_checkbox("sw_tooltip_cast_and_tap", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
    --                            "Cast and Lifetap", tooltip_checkbox_func);
    --end

    -- set tooltip options as according to saved persistent data
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.loadout_info) == 0 then
        sw_frame.settings_frame.tooltip_loadout_info:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.spell_rank) ~= 0 then
        sw_frame.settings_frame.tooltip_spell_rank:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.normal) ~= 0 then
        sw_frame.settings_frame.tooltip_normal_effect:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.crit) ~= 0 then
        sw_frame.settings_frame.tooltip_crit_effect:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.ot) ~= 0 then
        sw_frame.settings_frame.tooltip_normal_ot:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.ot_crit) ~= 0 then
        sw_frame.settings_frame.tooltip_crit_ot:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.expected) ~= 0 then
        sw_frame.settings_frame.tooltip_expected_effect:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.effect_per_sec) ~= 0 then
        sw_frame.settings_frame.tooltip_effect_per_sec:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.effect_per_cost) ~= 0 then
        sw_frame.settings_frame.tooltip_effect_per_cost:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.cost_per_sec) ~= 0 then
        sw_frame.settings_frame.tooltip_cost_per_sec:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.stat_weights) ~= 0 then
        sw_frame.settings_frame.tooltip_stat_weights:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.sp_effect_calc) == 0 then
        sw_frame.settings_frame.tooltip_sp_effect_calc:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.avg_cost) ~= 0 then
        sw_frame.settings_frame.tooltip_avg_cost:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.avg_cast) ~= 0 then
        sw_frame.settings_frame.tooltip_avg_cast:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.cast_until_oom) ~= 0 then
        sw_frame.settings_frame.tooltip_cast_until_oom:SetChecked(true);
    end
    --if class == "WARLOCK" then
        --if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.cast_and_tap) ~= 0 then
        --    sw_frame.settings_frame.tooltip_cast_and_tap:SetChecked(true);
        --end
    --end

    for i = 1, 32 do
        if bit.band(bit.lshift(1, i), __sw__persistent_data_per_char.settings.ability_tooltip) ~= 0 then
            sw_frame.settings_frame.tooltip_num_checked = sw_frame.settings_frame.tooltip_num_checked + 1;
        end
    end;
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 25;
    
    sw_frame.settings_frame.tooltip_settings_label_misc = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.tooltip_settings_label_misc:SetFontObject(font);
    sw_frame.settings_frame.tooltip_settings_label_misc:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.tooltip_settings_label_misc:SetText("Miscellaneous Settings");
    sw_frame.settings_frame.tooltip_settings_label_misc:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 15;
    sw_frame.settings_frame.libstub_icon_checkbox = 
        create_sw_checkbox("sw_settings_show_minimap_button", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Minimap Icon", function(self) 

        __sw__persistent_data_per_char.settings.libstub_minimap_icon.hide = not self:GetChecked();
        if __sw__persistent_data_per_char.settings.libstub_minimap_icon.hide then
            libstub_icon:Hide(swc.core.sw_addon_name);

        else
            libstub_icon:Show(swc.core.sw_addon_name);
        end
    end);

    sw_frame.settings_frame.show_tooltip_only_when_shift_button = 
        create_sw_checkbox("sw_settings_show_tooltip_only_when_shift_button", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Hold SHIFT to show tooltip", function(self)
        sw_frame.settings_frame.show_tooltip_only_when_shift = self:GetChecked();
    end);
    sw_frame.settings_frame.show_tooltip_only_when_shift = 
        __sw__persistent_data_per_char.settings.show_tooltip_only_when_shift;
    sw_frame.settings_frame.show_tooltip_only_when_shift_button:SetChecked(
        sw_frame.settings_frame.show_tooltip_only_when_shift
    );

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    sw_frame.settings_frame.clear_original_tooltip_button = 
        create_sw_checkbox("sw_settings_clear_original_tooltip", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Clear original tooltip", function(self)
        sw_frame.settings_frame.clear_original_tooltip = self:GetChecked();
    end);
    sw_frame.settings_frame.clear_original_tooltip = 
        __sw__persistent_data_per_char.settings.clear_original_tooltip;
    sw_frame.settings_frame.clear_original_tooltip_button:SetChecked(
        sw_frame.settings_frame.clear_original_tooltip
    );

    if swc.core.expansion_loaded ~= swc.core.expansions.vanilla then
        sw_frame.settings_frame.icon_show_single_target_only:Hide();
    end
end

local function create_sw_gui_stat_comparison_frame()

    sw_frame.stat_comparison_frame:SetWidth(400);
    sw_frame.stat_comparison_frame:SetHeight(600);
    sw_frame.stat_comparison_frame:SetPoint("TOP", sw_frame, 0, -20);

    sw_frame.stat_comparison_frame.line_y_offset = -20;

    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.instructions_label = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.instructions_label:SetFontObject(font);
    sw_frame.stat_comparison_frame.instructions_label:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.instructions_label:SetText("While this tab is open, ability overlay & tooltips reflect the change below");


    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

    sw_frame.stat_comparison_frame.loadout_label = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.loadout_label:SetFontObject(font);
    sw_frame.stat_comparison_frame.loadout_label:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.loadout_label:SetText("Active Loadout: ");
    sw_frame.stat_comparison_frame.loadout_label:SetTextColor(222/255, 192/255, 40/255);

    sw_frame.stat_comparison_frame.loadout_name_label = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.loadout_name_label:SetFontObject(font);
    sw_frame.stat_comparison_frame.loadout_name_label:SetPoint("TOPLEFT", 110, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.loadout_name_label:SetText("Missing loadout!");
    sw_frame.stat_comparison_frame.loadout_name_label:SetTextColor(222/255, 192/255, 40/255);


    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

    sw_frame.stat_comparison_frame.stat_diff_header_left = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.stat_diff_header_left:SetFontObject(font);
    sw_frame.stat_comparison_frame.stat_diff_header_left:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.stat_diff_header_left:SetText("Stat");

    sw_frame.stat_comparison_frame.stat_diff_header_center = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.stat_diff_header_center:SetFontObject(font);
    sw_frame.stat_comparison_frame.stat_diff_header_center:SetPoint("TOPRIGHT", -80, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.stat_diff_header_center:SetText("Difference");


    local comparison_stats_listing_order = {};

    if swc.core.expansion_loaded == swc.core.expansions.wotlk then

        sw_frame.stat_comparison_frame.stats = {
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
        sw_frame.stat_comparison_frame.stats = {
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
    for _ in pairs(sw_frame.stat_comparison_frame.stats) do
        num_stats = num_stats + 1;
    end

    sw_frame.stat_comparison_frame.clear_button = CreateFrame("Button", "button", sw_frame.stat_comparison_frame, "UIPanelButtonTemplate"); 
    sw_frame.stat_comparison_frame.clear_button:SetScript("OnClick", function()

        for k, v in pairs(sw_frame.stat_comparison_frame.stats) do
            v.editbox:SetText("");
        end
        --for i = 1, num_stats do

        --    sw_frame.stat_comparison_frame.stats[i].editbox:SetText("");
        --end

        update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());
    end);

    sw_frame.stat_comparison_frame.clear_button:SetPoint("TOPRIGHT", -30, sw_frame.stat_comparison_frame.line_y_offset + 3);
    sw_frame.stat_comparison_frame.clear_button:SetHeight(15);
    sw_frame.stat_comparison_frame.clear_button:SetWidth(50);
    sw_frame.stat_comparison_frame.clear_button:SetText("Clear");

    --sw_frame.stat_comparison_frame.line_y_offset = sw_frame.stat_comparison_frame.line_y_offset - 10;


    for i, k in pairs(comparison_stats_listing_order) do

        v = sw_frame.stat_comparison_frame.stats[k];

        sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

        v.label = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");

        v.label:SetFontObject(font);
        v.label:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
        v.label:SetText(v.label_str);
        v.label:SetTextColor(222/255, 192/255, 40/255);

        v.editbox = CreateFrame("EditBox", v.label_str.."editbox"..k, sw_frame.stat_comparison_frame, "InputBoxTemplate");
        v.editbox:SetPoint("TOPRIGHT", -30, sw_frame.stat_comparison_frame.line_y_offset);
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
            sw_frame.stat_comparison_frame.stats[comparison_stats_listing_order[next_index]].editbox:SetFocus();
        end);
    end

    sw_frame.stat_comparison_frame.stats.sp.editbox:SetText("1");
    if swc.core.__sw__test_all_codepaths then
        for k, v in pairs(sw_frame.stat_comparison_frame.stats) do
            v.editbox:SetText("1");
        end
    end

    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

    -- sim type button
    sw_frame.stat_comparison_frame.sim_type_button = 
        CreateFrame("Button", "sw_sim_type_button", sw_frame.stat_comparison_frame, "UIDropDownMenuTemplate"); 
    sw_frame.stat_comparison_frame.sim_type_button:SetPoint("TOPLEFT", -5, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.sim_type_button.init_func = function()
        UIDropDownMenu_Initialize(sw_frame.stat_comparison_frame.sim_type_button, function()
            
            if sw_frame.stat_comparison_frame.sim_type == simulation_type.spam_cast then 
                UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Repeated casts");
            elseif sw_frame.stat_comparison_frame.sim_type == simulation_type.cast_until_oom then 
                UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Cast until OOM");
            end
            UIDropDownMenu_SetWidth(sw_frame.stat_comparison_frame.sim_type_button, 130);

            UIDropDownMenu_AddButton(
                {
                    text = "Repeated cast",
                    func = function()

                        sw_frame.stat_comparison_frame.sim_type = simulation_type.spam_cast;
                        UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Repeated casts");
                        sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Show();
                        sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:Hide();
                        update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());
                    end
                }
            );
            UIDropDownMenu_AddButton(
                {
                    text = "Cast until OOM",
                    func = function()

                        sw_frame.stat_comparison_frame.sim_type = simulation_type.cast_until_oom;
                        UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Cast until OOM");
                        sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Hide();
                        sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:Show();
                        update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());
                    end
                }
            );
        end);
    end;

    sw_frame.stat_comparison_frame.sim_type_button:SetText("Simulation type");

    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

    sw_frame.stat_comparison_frame.line_y_offset_before_dynamic_spells = sw_frame.stat_comparison_frame.line_y_offset;

    sw_frame.stat_comparison_frame.spell_diff_header_spell = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_spell:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_spell:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_spell:SetText("Spell");

    sw_frame.stat_comparison_frame.spell_diff_header_left = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_left:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_left:SetPoint("TOPRIGHT", -180, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_left:SetText("Change");

    sw_frame.stat_comparison_frame.spell_diff_header_center = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_center:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_center:SetPoint("TOPRIGHT", -110, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_center:SetText("DPS/HPS");

    sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:SetPoint("TOPRIGHT", -30, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:SetText("DMG/HEAL");

    sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:SetPoint("TOPRIGHT", -20, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:SetText("DURATION (s)");

    -- always have at least one
    sw_frame.stat_comparison_frame.spells = {};
    sw_frame.stat_comparison_frame.sim_type = simulation_type.spam_cast;

    if class == "DRUID" then
        local lname = GetSpellInfo(5185);
        sw_frame.stat_comparison_frame.spells[5185] = {name = lname};
    elseif class == "MAGE" then
        local lname = GetSpellInfo(133);
        sw_frame.stat_comparison_frame.spells[133] = {name = lname};
    elseif class == "WARLOCK" then
        local lname = GetSpellInfo(686);
        sw_frame.stat_comparison_frame.spells[686] = {name = lname};
    elseif class == "PALADIN" then
        local lname = GetSpellInfo(635);
        sw_frame.stat_comparison_frame.spells[635] = {name = lname};
    elseif class == "PRIEST" then
        local lname = GetSpellInfo(585);
        sw_frame.stat_comparison_frame.spells[585] = {name = lname};
    elseif class == "SHAMAN" then
        local lname = GetSpellInfo(403);
        sw_frame.stat_comparison_frame.spells[403] = {name = lname};
    end


end

local function create_loadout_buff_checkbutton(buffs_table, buff_lname, buff_info, buff_type, parent_frame, func)

    local index = buffs_table.num_buffs + 1;

    buffs_table[index] = {};
    buffs_table[index].checkbutton = CreateFrame("CheckButton", "loadout_apply_buffs_"..buff_lname, parent_frame, "ChatConfigCheckButtonTemplate");
    buffs_table[index].checkbutton.buff_info = buff_info.filter;
    buffs_table[index].checkbutton.buff_category = buff_info.category;
    buffs_table[index].checkbutton.buff_lname = buff_lname;
    buffs_table[index].checkbutton.buff_type = buff_type;
    local category_txt = "";
    local rgb = {};
    if buff_info.category == buff_category.class  then
        category_txt = "CLASS: ";
        rgb = {235/255, 52/255, 88/255};
    elseif buff_info.category == buff_category.raid  then
        category_txt = "RAID: ";
        rgb = {103/255, 52/255, 235/255};
    elseif buff_info.category == buff_category.consumes  then
        category_txt = "CONSUME: ";
        rgb = {225/255, 235/255, 52/255};
    elseif buff_info.category == buff_category.item  then
        category_txt = "ITEM: ";
        rgb = {0/255, 204/255, 255/255};
    elseif buff_info.category == buff_category.world_buffs  then
        category_txt = "WORLD: ";
        rgb = {0/255, 153/255, 51/255};
    end
    local buff_name_max_len = 25;
    category_txt = "";
    local name_appear =  category_txt..buff_lname;
    if buff_info.name then
        name_appear =  category_txt..buff_info.name;
    end
    getglobal(buffs_table[index].checkbutton:GetName() .. 'Text'):SetText(name_appear:sub(1, buff_name_max_len));
    local checkbutton_txt = getglobal(buffs_table[index].checkbutton:GetName() .. 'Text');
    checkbutton_txt:SetTextColor(rgb[1], rgb[2], rgb[3]);
    buffs_table[index].checkbutton:SetScript("OnClick", func);

    buffs_table[index].icon = CreateFrame("Frame", "loadout_apply_buffs_icon_"..buff_lname, parent_frame);
    buffs_table[index].icon:SetSize(15, 15);
    local tex = buffs_table[index].icon:CreateTexture(nil);
    tex:SetAllPoints(buffs_table[index].icon);
    if buff_info.icon_id then
        tex:SetTexture(buff_info.icon_id);
    else
        tex:SetTexture(GetSpellTexture(buff_info.id));
    end

    buffs_table[index].checkbutton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
        GameTooltip:SetSpellByID(buff_info.id);
        GameTooltip:Show();
    end);
    buffs_table[index].checkbutton:SetScript("OnLeave", function(self)
        GameTooltip:Hide();
    end);

    buffs_table.num_buffs = index;

    return buffs_table[index].checkbutton;
end

local function create_sw_gui_loadout_frame()

    sw_frame.loadouts_frame:SetWidth(400);
    sw_frame.loadouts_frame:SetHeight(600);
    sw_frame.loadouts_frame:SetPoint("TOP", sw_frame, 0, -20);

    sw_frame.loadouts_frame.lhs_list = CreateFrame("ScrollFrame", "sw_loadout_frame_lhs", sw_frame.loadouts_frame);
    sw_frame.loadouts_frame.lhs_list:SetWidth(180);
    sw_frame.loadouts_frame.lhs_list:SetHeight(600-30-200-10-25-10-20-20);
    sw_frame.loadouts_frame.lhs_list:SetPoint("TOPLEFT", sw_frame, 0, -50);

    sw_frame.loadouts_frame.lhs_list:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.loadouts_frame.loadouts_slider:GetMinMaxValues();
        local val = sw_frame.loadouts_frame.loadouts_slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.loadouts_frame.loadouts_slider:SetValue(val - dir);
            update_loadouts_lhs();
        end
    end);

    sw_frame.loadouts_frame.rhs_list = CreateFrame("ScrollFrame", "sw_loadout_frame_rhs", sw_frame.loadouts_frame);
    sw_frame.loadouts_frame.rhs_list:SetWidth(400-180);
    sw_frame.loadouts_frame.rhs_list:SetHeight(600-30-30-20);
    sw_frame.loadouts_frame.rhs_list:SetPoint("TOPLEFT", sw_frame, 180, -50);

    sw_frame.loadouts_frame.loadouts_select_label = sw_frame.loadouts_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.loadouts_select_label:SetFontObject(font);
    sw_frame.loadouts_frame.loadouts_select_label:SetPoint("TOPLEFT", sw_frame.loadouts_frame.lhs_list, 15, -2);
    sw_frame.loadouts_frame.loadouts_select_label:SetText("Select active loadout");
    sw_frame.loadouts_frame.loadouts_select_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.loadouts_frame.loadouts_slider =
        CreateFrame("Slider", "sw_loadouts_slider", sw_frame.loadouts_frame.lhs_list, "OptionsSliderTemplate");
    sw_frame.loadouts_frame.loadouts_slider:SetOrientation('VERTICAL');
    sw_frame.loadouts_frame.loadouts_slider:SetPoint("TOPRIGHT", 0, -14);
    sw_frame.loadouts_frame.loadouts_slider:SetSize(15, 248);
    sw_frame.loadouts_frame.lhs_list.num_loadouts_can_fit =
        math.floor(sw_frame.loadouts_frame.loadouts_slider:GetHeight()/20);
    getglobal(sw_frame.loadouts_frame.loadouts_slider:GetName()..'Text'):SetText("");
    getglobal(sw_frame.loadouts_frame.loadouts_slider:GetName()..'Low'):SetText("");
    getglobal(sw_frame.loadouts_frame.loadouts_slider:GetName()..'High'):SetText("");
    sw_frame.loadouts_frame.loadouts_slider:SetMinMaxValues(0, 0);
    sw_frame.loadouts_frame.loadouts_slider:SetValue(0);
    sw_frame.loadouts_frame.loadouts_slider:SetValueStep(1);
    sw_frame.loadouts_frame.loadouts_slider:SetScript("OnValueChanged", function(self, val)
        update_loadouts_lhs();
    end);

    sw_frame.loadouts_frame.rhs_list.self_buffs_frame = 
        CreateFrame("ScrollFrame", "sw_loadout_frame_rhs_self_buffs", sw_frame.loadouts_frame.rhs_list);
    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetWidth(400-180);
    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetHeight(600-30-30);
    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetPoint("TOPLEFT", sw_frame.loadouts_frame.rhs_list, 0, 0);

    sw_frame.loadouts_frame.rhs_list.target_buffs_frame = 
        CreateFrame("ScrollFrame", "sw_loadout_frame_rhs_target_buffs", sw_frame.loadouts_frame.rhs_list);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetWidth(400-180);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetHeight(600-30-30);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetPoint("TOPLEFT", sw_frame.loadouts_frame.rhs_list, 0, 0);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:Hide();

    sw_frame.loadouts_frame.rhs_list.num_buffs_checked = 0;
    sw_frame.loadouts_frame.rhs_list.num_target_buffs_checked = 0;

    local y_offset_lhs = 0;
    
    sw_frame.loadouts_frame.rhs_list.delete_button =
        CreateFrame("Button", "sw_loadouts_delete_button", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.delete_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.delete_button:SetText("Delete Loadout");
    sw_frame.loadouts_frame.rhs_list.delete_button:SetSize(170, 25);
    sw_frame.loadouts_frame.rhs_list.delete_button:SetScript("OnClick", function(self)
        
        if sw_frame.loadouts_frame.lhs_list.num_loadouts == 1 then
            return;
        end

        sw_frame.loadouts_frame.lhs_list.loadouts[
            sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(false);
        
        for i = sw_frame.loadouts_frame.lhs_list.num_loadouts - 1, sw_frame.loadouts_frame.lhs_list.active_loadout, -1  do
            sw_frame.loadouts_frame.lhs_list.loadouts[i].loadout = sw_frame.loadouts_frame.lhs_list.loadouts[i+1].loadout;
            sw_frame.loadouts_frame.lhs_list.loadouts[i].equipped_talented = sw_frame.loadouts_frame.lhs_list.loadouts[i+1].equipped_talented;
            sw_frame.loadouts_frame.lhs_list.loadouts[i].buffed_equipped_talented = sw_frame.loadouts_frame.lhs_list.loadouts[i+1].buffed_equipped_talented;
        end

        sw_frame.loadouts_frame.lhs_list.loadouts[
            sw_frame.loadouts_frame.lhs_list.num_loadouts].check_button:Hide();

        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.num_loadouts] = nil;

        sw_frame.loadouts_frame.lhs_list.num_loadouts = sw_frame.loadouts_frame.lhs_list.num_loadouts - 1;

        sw_frame.loadouts_frame.lhs_list.active_loadout = sw_frame.loadouts_frame.lhs_list.num_loadouts;

        swc.core.talents_update_needed = true;
        swc.core.equipment_update_needed = true;

        update_loadouts_lhs();
    end);

    y_offset_lhs = y_offset_lhs - 30;

    sw_frame.loadouts_frame.rhs_list.export_button =
        CreateFrame("Button", "sw_loadouts_export_button", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.export_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.export_button:SetText("Create loadout as a copy");
    sw_frame.loadouts_frame.rhs_list.export_button:SetSize(170, 25);
    sw_frame.loadouts_frame.rhs_list.export_button:SetScript("OnClick", function(self)

        create_new_loadout_as_copy(active_loadout_entry());
    end);

    y_offset_lhs = y_offset_lhs - 20;


    sw_frame.loadouts_frame.rhs_list.loadout_rename_label = 
        sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_rename_label:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_rename_label:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_rename_label:SetText("Rename");

    sw_frame.loadouts_frame.rhs_list.name_editbox = 
        CreateFrame("EditBox", "sw_loadout_name_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 65, y_offset_lhs - 2);
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetText("");
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetSize(110, 15);
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetAutoFocus(false);
    local editbox_save = function(self)

        local txt = self:GetText();
        active_loadout().name = txt;

        update_loadouts_lhs();
    end

    sw_frame.loadouts_frame.rhs_list.name_editbox:SetScript("OnEnterPressed", function(self) 
        editbox_save(self);
        self:ClearFocus();
    end);
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetScript("OnEscapePressed", function(self) 
        editbox_save(self);
        self:ClearFocus();
    end);
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetScript("OnTextChanged", editbox_save);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.loadout_talent_label = sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_talent_label:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_talent_label:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_talent_label:SetText("Talents (Wowhead link)");

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.talent_editbox = 
        CreateFrame("EditBox", "sw_loadout_talent_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 20, y_offset_lhs - 2);
    --sw_frame.loadouts_frame.rhs_list.talent_editbox:SetText("");
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetSize(150, 15);
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetAutoFocus(false);
    local talent_editbox = function(self)

        local loadout_entry = active_loadout_entry();
        local loadout = loadout_entry.loadout;

        local txt = self:GetText();

        swc.core.talents_update_needed = true;

        if bit.band(loadout.flags, loadout_flags.is_dynamic_loadout) == 0 then
            loadout.custom_talents_code = wowhead_talent_code_from_url(txt);
        end

        update_loadouts_lhs();
    end

    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetScript("OnEnterPressed", function(self) 
        talent_editbox(self);
        self:ClearFocus();
    end);
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetScript("OnEscapePressed", function(self) 
        talent_editbox(self);
        self:ClearFocus();
    end);

    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetScript("OnTextChanged", function(self) 
        talent_editbox(self);
        self:ClearFocus();
    end);


    y_offset_lhs = y_offset_lhs - 30;

    sw_frame.loadouts_frame.rhs_list.dynamic_button = 
        CreateFrame("CheckButton", "sw_loadout_dynamic_check", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.dynamic_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);

    if swc.core.expansion_loaded == swc.core.expansions.wotlk then
        getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_button:GetName()..'Text'):SetText("Custom talents & glyphs");
        getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_button:GetName()).tooltip = 
            "Given a valid wowhead talents link above, your loadout will use its talents & glyphs instead of your active ones.";
    else
        getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_button:GetName()..'Text'):SetText("Custom talents & runes");
        getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_button:GetName()).tooltip = 
            "Given a valid wowhead talents link above, your loadout will use its talents & runes instead of your active ones.";
    end

    sw_frame.loadouts_frame.rhs_list.dynamic_button:SetScript("OnClick", function(self)
        
        local loadout_entry = active_loadout_entry();

        swc.core.talents_update_needed = true;
        swc.core.equipment_update_needed = true;

        if self:GetChecked() then
            loadout_entry.loadout.flags = bit.band(loadout_entry.loadout.flags, bit.bnot(loadout_flags.is_dynamic_loadout));
        else
            loadout_entry.loadout.flags = bit.bor(loadout_entry.loadout.flags, loadout_flags.is_dynamic_loadout);
        end
        update_loadouts_rhs();
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.custom_lvl_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_custom_lvl_checkbutton", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.custom_lvl_checkbutton:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.custom_lvl_checkbutton:SetHitRectInsets(0, 0, 0, 0);

    getglobal(sw_frame.loadouts_frame.rhs_list.custom_lvl_checkbutton:GetName()..'Text'):SetText("Custom char lvl");
    getglobal(sw_frame.loadouts_frame.rhs_list.custom_lvl_checkbutton:GetName()).tooltip = 
        "Displays ability information as if character is a custom level (attributes from levels are not accounted for)";

    sw_frame.loadouts_frame.rhs_list.custom_lvl_checkbutton:SetScript("OnClick", function(self)
        
        local loadout_entry = active_loadout_entry();

        if self:GetChecked() then
            loadout_entry.loadout.flags = bit.bor(loadout_entry.loadout.flags, loadout_flags.custom_lvl);
        else
            loadout_entry.loadout.flags = bit.band(loadout_entry.loadout.flags, bit.bnot(loadout_flags.custom_lvl));
        end
        update_loadouts_rhs();
    end);

    sw_frame.loadouts_frame.rhs_list.loadout_clvl_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.loadout_clvl_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 130, y_offset_lhs + 7);
    sw_frame.loadouts_frame.rhs_list.loadout_clvl_editbox:SetSize(40, 15);
    sw_frame.loadouts_frame.rhs_list.loadout_clvl_editbox:SetAutoFocus(false);

    local clvl_editbox = function(self)

        local loadout = active_loadout();
        local lvl = tonumber(self:GetText());
        if lvl and lvl >= 1 and lvl <= 100 then
            loadout.lvl = lvl;
        else

            local clvl = UnitLevel("player");
            self:SetText(""..clvl);
        end

    	self:ClearFocus();
        self:HighlightText(0,0);
    end

    sw_frame.loadouts_frame.rhs_list.loadout_clvl_editbox:SetScript("OnEnterPressed", clvl_editbox);
    sw_frame.loadouts_frame.rhs_list.loadout_clvl_editbox:SetScript("OnEscapePressed", clvl_editbox);
    sw_frame.loadouts_frame.rhs_list.loadout_clvl_editbox:SetScript("OnEditFocusLost", clvl_editbox);
    sw_frame.loadouts_frame.rhs_list.loadout_clvl_editbox:SetScript("OnTextChanged", function(self)

        local loadout = active_loadout();
        local lvl = tonumber(self:GetText());
        if lvl and lvl >= 1 and lvl <= 100 then
            loadout.lvl = lvl;
        end
    end);

    y_offset_lhs = y_offset_lhs - 12;

    sw_frame.loadouts_frame.rhs_list.loadout_level_label = 
        sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_level_label:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_level_label:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_level_label:SetText("Default target lvl diff");

    sw_frame.loadouts_frame.rhs_list.level_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 130, y_offset_lhs - 2);
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetText("");
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetSize(40, 15);
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetAutoFocus(false);

    local editbox_lvl = function(self)

        local lvl_diff = tonumber(self:GetText());
        local loadout = active_loadout();
        if lvl_diff and lvl_diff == math.floor(lvl_diff) and loadout.lvl + lvl_diff >= 1 and loadout.lvl + lvl_diff <= 83 then

            loadout.default_target_lvl_diff = lvl_diff;
        else
            self:SetText(""..loadout.default_target_lvl_diff); 
        end

        self:ClearFocus();
        self:HighlightText(0,0);
    end

    sw_frame.loadouts_frame.rhs_list.level_editbox:SetScript("OnEnterPressed", editbox_lvl);
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetScript("OnEscapePressed", editbox_lvl);
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetScript("OnEditFocusLost", editbox_lvl);
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetScript("OnTextChanged", function(self)
        -- silently try to apply valid changes but don't panic while focus is on
        local lvl_diff = tonumber(self:GetText());
        local loadout = active_loadout();
        if lvl_diff and lvl_diff == math.floor(lvl_diff) and loadout.lvl + lvl_diff >= 1 and loadout.lvl + lvl_diff <= 83 then

            loadout.default_target_lvl_diff = lvl_diff;
        end
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.hp_perc_label = 
        sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.hp_perc_label:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.hp_perc_label:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.hp_perc_label:SetText("Default target HP                   %");

    sw_frame.loadouts_frame.rhs_list.hp_perc_label_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.hp_perc_label_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 130, y_offset_lhs - 2);
    sw_frame.loadouts_frame.rhs_list.hp_perc_label_editbox:SetText("");
    sw_frame.loadouts_frame.rhs_list.hp_perc_label_editbox:SetSize(40, 15);
    sw_frame.loadouts_frame.rhs_list.hp_perc_label_editbox:SetAutoFocus(false);

    local editbox_hp_perc = function(self)

        local hp_perc = tonumber(self:GetText());
        local loadout = active_loadout();
        if hp_perc and hp_perc >= 0 then

            loadout.target_hp_perc_default = 0.01*hp_perc;
        else
            self:SetText(""..loadout.target_hp_perc_default*100); 
        end

        self:ClearFocus();
        self:HighlightText(0,0);
    end

    sw_frame.loadouts_frame.rhs_list.hp_perc_label_editbox:SetScript("OnEnterPressed", editbox_hp_perc);
    sw_frame.loadouts_frame.rhs_list.hp_perc_label_editbox:SetScript("OnEscapePressed", editbox_hp_perc);
    sw_frame.loadouts_frame.rhs_list.hp_perc_label_editbox:SetScript("OnEditFocusLost", editbox_hp_perc);
    sw_frame.loadouts_frame.rhs_list.hp_perc_label_editbox:SetScript("OnTextChanged", function(self)

        local hp_perc = tonumber(self:GetText());
        local loadout = active_loadout();
        if hp_perc and hp_perc >= 0 then

            loadout.target_hp_perc_default = 0.01*hp_perc;
        end
    end);

    if swc.core.expansion_loaded == swc.core.expansions.vanilla then

        y_offset_lhs = y_offset_lhs - 20;

        sw_frame.loadouts_frame.rhs_list.target_res_label = 
            sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
        sw_frame.loadouts_frame.rhs_list.target_res_label:SetFontObject(font);
        sw_frame.loadouts_frame.rhs_list.target_res_label:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
        sw_frame.loadouts_frame.rhs_list.target_res_label:SetText("Target resistance                   ");

        sw_frame.loadouts_frame.rhs_list.target_res_editbox= CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
        sw_frame.loadouts_frame.rhs_list.target_res_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 130, y_offset_lhs - 2);
        sw_frame.loadouts_frame.rhs_list.target_res_editbox:SetText("");
        sw_frame.loadouts_frame.rhs_list.target_res_editbox:SetSize(40, 15);
        sw_frame.loadouts_frame.rhs_list.target_res_editbox:SetAutoFocus(false);

        local editbox_target_res = function(self)

            local target_res = tonumber(self:GetText());
            local loadout = active_loadout();
            if target_res and target_res >= 0 then

                loadout.target_res = target_res;
            else
                self:SetText("0"); 
                loadout.target_res = 0;
            end

            self:ClearFocus();
            self:HighlightText(0,0);
        end

        sw_frame.loadouts_frame.rhs_list.target_res_editbox:SetScript("OnEnterPressed", editbox_target_res);
        sw_frame.loadouts_frame.rhs_list.target_res_editbox:SetScript("OnEscapePressed", editbox_target_res);
        sw_frame.loadouts_frame.rhs_list.target_res_editbox:SetScript("OnEditFocusLost", editbox_target_res);
        sw_frame.loadouts_frame.rhs_list.target_res_editbox:SetScript("OnTextChanged", function(self)
            local target_res = tonumber(self:GetText());
            local loadout = active_loadout();
            if target_res and target_res >= 0 then
                loadout.target_res = target_res;
            end
        end);
    end

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana = 
        sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana:SetText("Extra mana (pots)");

    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 130, y_offset_lhs - 2);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetSize(40, 15);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetAutoFocus(false);

    local mana_editbox = function(self)
        local loadout = active_loadout();
        local txt = self:GetText();
        
        local mana = tonumber(txt);
        if mana then
            loadout.extra_mana = mana;
            
        else
            self:SetText("0");
            loadout.extra_mana = 0;
        end

    	self:ClearFocus();
        self:HighlightText(0,0);
    end

    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetScript("OnEnterPressed", mana_editbox);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetScript("OnEscapePressed", mana_editbox);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetScript("OnEditFocusLost", mana_editbox);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetScript("OnTextChanged", function(self)

        local loadout = active_loadout();
        local mana = tonumber(self:GetText());
        if mana then
            loadout.extra_mana = mana;
        end
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets = 
        sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets:SetText("Limitless AOE targets");

    sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 130, y_offset_lhs - 2);
    sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetSize(40, 15);
    sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetAutoFocus(false);

    local aoe_targets_editbox_fn = function(self)
        local loadout = active_loadout();
        local txt = self:GetText();
        
        local targets = tonumber(txt);
        if targets and targets >= 1 then
            loadout.unbounded_aoe_targets = math.floor(targets);
        else
            self:SetText("1");
            loadout.unbounded_aoe_targets = 1;
        end

    	self:ClearFocus();
        self:HighlightText(0,0);
    end

    sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetScript("OnEnterPressed", aoe_targets_editbox_fn);
    sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetScript("OnEscapePressed", aoe_targets_editbox_fn);
    sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetScript("OnEditFocusLost", aoe_targets_editbox_fn);
    sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetScript("OnTextChanged", function(self)

        local loadout = active_loadout();
        local targets = tonumber(self:GetText());
        if targets and targets >= 1 then
            loadout.unbounded_aoe_targets = math.floor(targets);
        end

    end);
    if swc.core.expansion_loaded ~= swc.core.expansions.vanilla then
        sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets:Hide();
        sw_frame.loadouts_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:Hide();
    end

    y_offset_lhs = y_offset_lhs - 27;

    sw_frame.loadouts_frame.rhs_list.max_mana_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_max_mana", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.max_mana_checkbutton:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    getglobal(sw_frame.loadouts_frame.rhs_list.max_mana_checkbutton:GetName()..'Text'):SetText("Maximum mana");
    getglobal(sw_frame.loadouts_frame.rhs_list.max_mana_checkbutton:GetName()).tooltip = 
        "Casting until OOM uses maximum mana instead of current.";
    sw_frame.loadouts_frame.rhs_list.max_mana_checkbutton:SetScript("OnClick", function(self)
        local loadout = active_loadout();
        if self:GetChecked() then
            loadout.flags = bit.bor(loadout.flags, loadout_flags.always_max_mana);
        else    
            loadout.flags = bit.band(loadout.flags, bit.bnot(loadout_flags.always_max_mana));
        end
    end)

    local y_offset_rhs = 0;

    sw_frame.loadouts_frame.loadouts_select_label = sw_frame.loadouts_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.loadouts_select_label:SetFontObject(font);
    sw_frame.loadouts_frame.loadouts_select_label:SetPoint("TOPLEFT", sw_frame.loadouts_frame.rhs_list, 5, -2);
    sw_frame.loadouts_frame.loadouts_select_label:SetText("Trackable effects");
    sw_frame.loadouts_frame.loadouts_select_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    y_offset_rhs = y_offset_rhs - 15;

    sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button = 
        CreateFrame("CheckButton", "sw_loadout_always_apply_buffs_button", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetPoint("TOPLEFT", sw_frame.loadouts_frame.rhs_list, 0, y_offset_rhs);
    getglobal(sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:GetName() .. 'Text'):SetText("Apply buffs even when inactive");
    getglobal(sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:GetName()).tooltip = 
        "The selected buffs will be forcibly applied behind the scenes to the spell calculations";
    sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetScript("OnClick", function(self)

        local loadout = active_loadout();
        if self:GetChecked() then

            loadout.flags = bit.bor(loadout.flags, loadout_flags.always_assume_buffs);
            loadout.buffs = {};
            loadout.target_buffs = {};
            
        else
            loadout.flags = bit.band(loadout.flags, bit.bnot(loadout_flags.always_assume_buffs));

            loadout.buffs = {};
            loadout.target_buffs = {};
        end
        update_loadouts_rhs();
    end);

    y_offset_rhs = y_offset_rhs - 20;


    sw_frame.loadouts_frame.rhs_list.buffs_button =
        CreateFrame("Button", "sw_frame_buffs_button", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetScript("OnClick", function(self)

        sw_frame.loadouts_frame.rhs_list.self_buffs_frame:Show();

        sw_frame.loadouts_frame.rhs_list.buffs_button:LockHighlight();
        sw_frame.loadouts_frame.rhs_list.buffs_button:SetButtonState("PUSHED");

        sw_frame.loadouts_frame.rhs_list.target_buffs_frame:Hide();

        sw_frame.loadouts_frame.rhs_list.target_buffs_button:UnlockHighlight();
        sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetButtonState("NORMAL");

        update_loadouts_rhs();

    end);
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetPoint("TOPLEFT", 20, y_offset_rhs);
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetText("SELF");
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetWidth(93);
    sw_frame.loadouts_frame.rhs_list.buffs_button:LockHighlight();
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetButtonState("PUSHED");

    sw_frame.loadouts_frame.rhs_list.target_buffs_button =
        CreateFrame("Button", "sw_frame_target_buffs_button", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetScript("OnClick", function(self)

        sw_frame.loadouts_frame.rhs_list.target_buffs_frame:Show();

        sw_frame.loadouts_frame.rhs_list.target_buffs_button:LockHighlight();
        sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetButtonState("PUSHED");

        sw_frame.loadouts_frame.rhs_list.self_buffs_frame:Hide();

        sw_frame.loadouts_frame.rhs_list.buffs_button:UnlockHighlight();
        sw_frame.loadouts_frame.rhs_list.buffs_button:SetButtonState("NORMAL");

        update_loadouts_rhs();

    end);
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetPoint("TOPLEFT", 93 + 20, y_offset_rhs);
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetText("TARGET");
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetWidth(93);

    y_offset_rhs = y_offset_rhs - 20;

    sw_frame.loadouts_frame.rhs_list.buffs = {};
    sw_frame.loadouts_frame.rhs_list.buffs.num_buffs = 0;

    sw_frame.loadouts_frame.rhs_list.target_buffs = {};
    sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs = 0;

    local check_button_buff_func = function(self)

        local loadout = sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout;
        if bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0 then
            self:SetChecked(true);
            return;
        end
        if self:GetChecked() then
            if self.buff_type == "self" then
                loadout.buffs[self.buff_lname] = self.buff_info;
                sw_frame.loadouts_frame.rhs_list.num_checked_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_buffs + 1;
            elseif self.buff_type == "target_buffs" then
                loadout.target_buffs[self.buff_lname] = self.buff_info;
                sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs + 1;
            end

        else    
            if self.buff_type == "self" then
                loadout.buffs[self.buff_lname] = nil;
                sw_frame.loadouts_frame.rhs_list.num_checked_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_buffs - 1;
            elseif self.buff_type == "target_buffs" then
                loadout.target_buffs[self.buff_lname] = nil;
                sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs - 1;
            end
        end

        if sw_frame.loadouts_frame.rhs_list.num_checked_buffs == 0 then
            sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(true);
        end

        if sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs == 0 then
            sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(true);
        end
    end

    local y_offset_rhs_buffs = y_offset_rhs - 3;
    local y_offset_rhs_target_buffs = y_offset_rhs - 3;

    -- add select all optoin for both buffs and debuffs

    sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_select_all_buffs", sw_frame.loadouts_frame.rhs_list.self_buffs_frame, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetPoint("TOPLEFT", 20, y_offset_rhs_buffs);
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:GetName() .. 'Text'):SetText("SELECT ALL/NONE");
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:GetName() .. 'Text'):SetTextColor(1, 0, 0);

    sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetScript("OnClick", function(self) 

        local loadout = active_loadout();
        if bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0 then
            self:SetChecked(true)
            return;
        end
        if self:GetChecked() then

            loadout.buffs = {};

            for i = 1, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs do
                loadout.buffs[sw_frame.loadouts_frame.rhs_list.buffs[i].checkbutton.buff_lname] =
                    sw_frame.loadouts_frame.rhs_list.buffs[i].checkbutton.buff_info;
            end
        else
            loadout.buffs = {};
        end

        update_loadouts_rhs();
    end);

    sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_select_all_target_buffs", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetPoint("TOPLEFT", 20, y_offset_rhs_target_buffs);
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:GetName() .. 'Text'):SetText("SELECT ALL/NONE");
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:GetName() .. 'Text'):SetTextColor(1, 0, 0);
    sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetScript("OnClick", function(self)
        local loadout = active_loadout();
        if bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0 then
            self:SetChecked(true)
            return;
        end
        if self:GetChecked() then
            
            for  i = 1, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs  do
                loadout.target_buffs[sw_frame.loadouts_frame.rhs_list.target_buffs[i].checkbutton.buff_lname] =
                    sw_frame.loadouts_frame.rhs_list.target_buffs[i].checkbutton.buff_info;
            end
        else
            loadout.target_buffs = {};
        end
        update_loadouts_rhs();
    end);


    y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
    y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;

    sw_frame.loadouts_frame.rhs_list.self_buffs_y_offset_start = y_offset_rhs_buffs;
    sw_frame.loadouts_frame.rhs_list.target_buffs_y_offset_start = y_offset_rhs_target_buffs;

    -- buffs
    local sorted_buffs_by_name = {};
    for k, v in pairs(buffs) do
        if bit.band(filter_flags_active, v.filter) ~= 0 and bit.band(buff_filters.hidden, v.filter) == 0 then
            table.insert(sorted_buffs_by_name, {k, v.category});
        end
    end
    table.sort(sorted_buffs_by_name, function(lhs, rhs)  return lhs[2]..lhs[1] < rhs[2]..rhs[1] end);
    for _, k in ipairs(sorted_buffs_by_name) do
        k = k[1];
        local v = buffs[k];
        create_loadout_buff_checkbutton(
            sw_frame.loadouts_frame.rhs_list.buffs, k, v, "self", 
            sw_frame.loadouts_frame.rhs_list.self_buffs_frame, check_button_buff_func
        );
    
    end

    -- debuffs
    sorted_buffs_by_name = {};
    for k, v in pairs(target_buffs) do
        if bit.band(filter_flags_active, v.filter) ~= 0 and bit.band(buff_filters.hidden, v.filter) == 0 then
            table.insert(sorted_buffs_by_name, {k, v.category});
        end
    end
    table.sort(sorted_buffs_by_name, function(lhs, rhs)  return lhs[2]..lhs[1] < rhs[2]..rhs[1] end);
    for _, k in ipairs(sorted_buffs_by_name) do
        local k = k[1];
        local v = target_buffs[k];
        create_loadout_buff_checkbutton(
            sw_frame.loadouts_frame.rhs_list.target_buffs, k, v, "target_buffs", 
            sw_frame.loadouts_frame.rhs_list.target_buffs_frame, check_button_buff_func
        );
    end

    sw_frame.loadouts_frame.self_buffs_slider =
        CreateFrame("Slider", "sw_self_buffs_slider", sw_frame.loadouts_frame.rhs_list.self_buffs_frame, "OptionsSliderTemplate");
    sw_frame.loadouts_frame.self_buffs_slider:SetOrientation('VERTICAL');
    sw_frame.loadouts_frame.self_buffs_slider:SetPoint("TOPRIGHT", -10, -82);
    sw_frame.loadouts_frame.self_buffs_slider:SetSize(15, 465);
    sw_frame.loadouts_frame.rhs_list.buffs.num_buffs_can_fit =
        math.floor(sw_frame.loadouts_frame.self_buffs_slider:GetHeight()/20);
    sw_frame.loadouts_frame.self_buffs_slider:SetMinMaxValues(
        0, 
        max(0, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs - sw_frame.loadouts_frame.rhs_list.buffs.num_buffs_can_fit)
    );
    getglobal(sw_frame.loadouts_frame.self_buffs_slider:GetName()..'Text'):SetText("");
    getglobal(sw_frame.loadouts_frame.self_buffs_slider:GetName()..'Low'):SetText("");
    getglobal(sw_frame.loadouts_frame.self_buffs_slider:GetName()..'High'):SetText("");
    sw_frame.loadouts_frame.self_buffs_slider:SetValue(0);
    sw_frame.loadouts_frame.self_buffs_slider:SetValueStep(1);
    sw_frame.loadouts_frame.self_buffs_slider:SetScript("OnValueChanged", function(self, val)

        update_loadouts_rhs();
    end);

    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.loadouts_frame.self_buffs_slider:GetMinMaxValues();
        local val = sw_frame.loadouts_frame.self_buffs_slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.loadouts_frame.self_buffs_slider:SetValue(val - dir);
            update_loadouts_rhs();
        end
    end);

    sw_frame.loadouts_frame.target_buffs_slider =
        CreateFrame("Slider", "sw_target_buffs_slider", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, "OptionsSliderTemplate");
    sw_frame.loadouts_frame.target_buffs_slider:SetOrientation('VERTICAL');
    sw_frame.loadouts_frame.target_buffs_slider:SetPoint("TOPRIGHT", -10, -82);
    sw_frame.loadouts_frame.target_buffs_slider:SetSize(15, 465);
    sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs_can_fit = 
        math.floor(sw_frame.loadouts_frame.target_buffs_slider:GetHeight()/20);
    sw_frame.loadouts_frame.target_buffs_slider:SetMinMaxValues(
        0, 
        max(0, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs - sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs_can_fit)
    );
    getglobal(sw_frame.loadouts_frame.target_buffs_slider:GetName()..'Text'):SetText("");
    getglobal(sw_frame.loadouts_frame.target_buffs_slider:GetName()..'Low'):SetText("");
    getglobal(sw_frame.loadouts_frame.target_buffs_slider:GetName()..'High'):SetText("");
    sw_frame.loadouts_frame.target_buffs_slider:SetValue(0);
    sw_frame.loadouts_frame.target_buffs_slider:SetValueStep(1);
    sw_frame.loadouts_frame.target_buffs_slider:SetScript("OnValueChanged", function(self, val)
        update_loadouts_rhs();
    end);

    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.loadouts_frame.target_buffs_slider:GetMinMaxValues();
        local val = sw_frame.loadouts_frame.target_buffs_slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.loadouts_frame.target_buffs_slider:SetValue(val - dir);
            update_loadouts_rhs();
        end
    end);
end

local function create_sw_base_gui()

    sw_frame = CreateFrame("Frame", "sw_frame", UIParent, "BasicFrameTemplate, BasicFrameTemplateWithInset");

    sw_frame:SetMovable(true)
    sw_frame:EnableMouse(true)
    sw_frame:RegisterForDrag("LeftButton")
    sw_frame:SetScript("OnDragStart", sw_frame.StartMoving)
    sw_frame:SetScript("OnDragStop", sw_frame.StopMovingOrSizing)

    sw_frame.settings_frame = CreateFrame("ScrollFrame", "sw_settings_frame", sw_frame);
    sw_frame.loadouts_frame = CreateFrame("ScrollFrame", "sw_loadout_frame ", sw_frame);
    sw_frame.stat_comparison_frame = CreateFrame("ScrollFrame", "sw_stat_comparison_frame", sw_frame);

    --sw_frame:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
    --sw_frame:RegisterEvent("ACTIONBAR_UPDATE_STATE");
    for k, v in pairs(swc.core.event_dispatch) do
        
        if not swc.core.event_dispatch_client_exceptions[k] or
                swc.core.event_dispatch_client_exceptions[k] == swc.core.expansion_loaded then

            sw_frame:RegisterEvent(k);
        end
    end
    if class ~= "PALADIN" then
        sw_frame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
    end

    sw_frame:SetWidth(400);
    sw_frame:SetHeight(600);
    sw_frame:SetPoint("TOPLEFT", 400, -30);

    sw_frame.title = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.title:SetFontObject(font)
    sw_frame.title:SetText("Stat Weights Classic v"..swc.core.version);
    sw_frame.title:SetPoint("CENTER", sw_frame.TitleBg, "CENTER", 50, 0);

    sw_frame:SetScript("OnEvent", function(self, event, msg, msg2, msg3)
        swc.core.event_dispatch[event](self, msg, msg2, msg3);
        end
    );

    create_sw_spell_id_viewer();
    
    sw_frame.tab1 = CreateFrame("Button", "__sw_settings_button", sw_frame, "UIPanelButtonTemplate"); 

    sw_frame.tab1:SetPoint("TOPLEFT", 10, -25);
    sw_frame.tab1:SetWidth(116);
    sw_frame.tab1:SetHeight(25);
    sw_frame.tab1:SetText("Settings");
    sw_frame.tab1:SetScript("OnClick", function()
        sw_activate_tab(1);
    end);


    sw_frame.tab2 = CreateFrame("Button", "__sw_loadouts_button", sw_frame, "UIPanelButtonTemplate"); 
    sw_frame.tab2:SetPoint("TOPLEFT", 124, -25);
    sw_frame.tab2:SetWidth(116);
    sw_frame.tab2:SetHeight(25);
    sw_frame.tab2:SetText("Loadouts");

    sw_frame.tab2:SetScript("OnClick", function()
        sw_activate_tab(2);
    end);

    sw_frame.tab3 = CreateFrame("Button", "__sw_stat_comparison_button", sw_frame, "UIPanelButtonTemplate"); 
    sw_frame.tab3:SetPoint("TOPLEFT", 238, -25);
    sw_frame.tab3:SetWidth(150);
    sw_frame.tab3:SetHeight(25);
    sw_frame.tab3:SetText("Stat Calculator");
    sw_frame.tab3:SetScript("OnClick", function()
        sw_activate_tab(3);
    end);
end


local function load_sw_ui()
    create_sw_gui_stat_comparison_frame();

    if not __sw__persistent_data_per_char then
        __sw__persistent_data_per_char = {};
    end
    if swc.core.__sw__use_defaults__ then
        __sw__persistent_data_per_char.settings = nil;
        __sw__persistent_data_per_char.loadouts = nil;
    end

    local default_settings = default_sw_settings();
    if not __sw__persistent_data_per_char.settings then
        __sw__persistent_data_per_char.settings = default_settings;
    else
        -- allows old clients with old settings to pick up on settings in newer versions
        for k, v in pairs(default_settings) do
            if __sw__persistent_data_per_char.settings[k] == nil then
                __sw__persistent_data_per_char.settings[k] = v;
            end
        end
    end

    create_sw_gui_settings_frame();

    if libstub_data_broker then
        local sw_launcher = libstub_data_broker:NewDataObject(swc.core.sw_addon_name, {
            type = "launcher",
            icon = "Interface\\Icons\\spell_fire_elementaldevastation",
            OnClick = function(self, button)
                if button == "LeftButton" or button == "RightButton" then 
                    if sw_frame:IsShown() then 
                         sw_frame:Hide() 
                    else 
                         sw_frame:Show() 
                    end
                end
            end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine(swc.core.sw_addon_name..": Version "..swc.core.version);
                tooltip:AddLine("This icon can be removed in the addon's settings tab");
                tooltip:AddLine("More info about this addon at:");
                tooltip:AddLine("https://www.curseforge.com/wow/addons/stat-weights-classic");
                tooltip:AddLine("Factory reset: /swc reset");
            end,
        });
        if libstub_icon then
            libstub_icon:Register(swc.core.sw_addon_name, sw_launcher, __sw__persistent_data_per_char.settings.libstub_minimap_icon);
        end
    end

    if __sw__persistent_data_per_char.settings.libstub_minimap_icon.hide then
        libstub_icon:Hide(swc.core.sw_addon_name);
    else
        libstub_icon:Show(swc.core.sw_addon_name);
        sw_frame.settings_frame.libstub_icon_checkbox:SetChecked(true);
    end

    create_sw_gui_loadout_frame();


    if not __sw__persistent_data_per_char.loadouts or not __sw__persistent_data_per_char.loadouts.num_loadouts  then
        -- load defaults
        __sw__persistent_data_per_char.loadouts = {};
        __sw__persistent_data_per_char.loadouts.loadouts_list = {};

        __sw__persistent_data_per_char.loadouts.loadouts_list[1] = {};
        __sw__persistent_data_per_char.loadouts.loadouts_list[1].loadout = empty_loadout();
        default_loadout(__sw__persistent_data_per_char.loadouts.loadouts_list[1].loadout);
        __sw__persistent_data_per_char.loadouts.loadouts_list[1].equipped = {};
        __sw__persistent_data_per_char.loadouts.loadouts_list[1].talented = {};
        __sw__persistent_data_per_char.loadouts.loadouts_list[1].final_effects = {};
        empty_effects(__sw__persistent_data_per_char.loadouts.loadouts_list[1].equipped);
        empty_effects(__sw__persistent_data_per_char.loadouts.loadouts_list[1].talented);
        empty_effects(__sw__persistent_data_per_char.loadouts.loadouts_list[1].final_effects);
        __sw__persistent_data_per_char.loadouts.active_loadout = 1;
        __sw__persistent_data_per_char.loadouts.num_loadouts = 1;

        -- add secondary PVP loadout with lvl diff of 0 by default
        __sw__persistent_data_per_char.loadouts.loadouts_list[2] = {};
        __sw__persistent_data_per_char.loadouts.loadouts_list[2].loadout = empty_loadout();
        default_loadout(__sw__persistent_data_per_char.loadouts.loadouts_list[2].loadout);
        __sw__persistent_data_per_char.loadouts.loadouts_list[2].loadout.default_target_lvl_diff = 0;
        __sw__persistent_data_per_char.loadouts.loadouts_list[2].loadout.name = "PVP";
        __sw__persistent_data_per_char.loadouts.loadouts_list[2].equipped = {};
        __sw__persistent_data_per_char.loadouts.loadouts_list[2].talented = {};
        __sw__persistent_data_per_char.loadouts.loadouts_list[2].final_effects = {};
        empty_effects(__sw__persistent_data_per_char.loadouts.loadouts_list[2].equipped);
        empty_effects(__sw__persistent_data_per_char.loadouts.loadouts_list[2].talented);
        empty_effects(__sw__persistent_data_per_char.loadouts.loadouts_list[2].final_effects);
        __sw__persistent_data_per_char.loadouts.num_loadouts = 2;
    end

    sw_frame.loadouts_frame.lhs_list.loadouts = {};
    for k, v in pairs(__sw__persistent_data_per_char.loadouts.loadouts_list) do
        sw_frame.loadouts_frame.lhs_list.loadouts[k] = {};
        sw_frame.loadouts_frame.lhs_list.loadouts[k].loadout = empty_loadout();
        for kk, vv in pairs(v.loadout) do
            -- for forward compatability: if there are changes to loadout in new version
            -- we copy what we can from the old loadout
            sw_frame.loadouts_frame.lhs_list.loadouts[k].loadout[kk] = v.loadout[kk];
        end
        
        sw_frame.loadouts_frame.lhs_list.loadouts[k].equipped = {};
        empty_effects(sw_frame.loadouts_frame.lhs_list.loadouts[k].equipped);
        effects_add(sw_frame.loadouts_frame.lhs_list.loadouts[k].equipped, v.equipped);
        sw_frame.loadouts_frame.lhs_list.loadouts[k].talented = {};
        sw_frame.loadouts_frame.lhs_list.loadouts[k].final_effects = {};
        empty_effects(sw_frame.loadouts_frame.lhs_list.loadouts[k].talented);
        empty_effects(sw_frame.loadouts_frame.lhs_list.loadouts[k].final_effects);
    end

    sw_frame.loadouts_frame.lhs_list.active_loadout = __sw__persistent_data_per_char.loadouts.active_loadout;
    sw_frame.loadouts_frame.lhs_list.num_loadouts = __sw__persistent_data_per_char.loadouts.num_loadouts;

    update_loadouts_lhs();

    sw_frame.loadouts_frame.lhs_list.loadouts[
        sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(true);

    if not __sw__persistent_data_per_char.sim_type or swc.core.__sw__use_defaults__ then
        sw_frame.stat_comparison_frame.sim_type = simulation_type.spam_cast;
    else
        sw_frame.stat_comparison_frame.sim_type = __sw__persistent_data_per_char.sim_type;
    end
    if sw_frame.stat_comparison_frame.sim_type  == simulation_type.spam_cast then
        sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Show();
        sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:Hide();
    elseif sw_frame.stat_comparison_frame.sim_type  == simulation_type.cast_until_oom then
        sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Hide();
        sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:Show();
    end
    sw_frame.stat_comparison_frame.sim_type_button.init_func();

    if __sw__persistent_data_per_char.stat_comparison_spells and not swc.core.__sw__use_defaults__ then

        sw_frame.stat_comparison_frame.spells = __sw__persistent_data_per_char.stat_comparison_spells;

        update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());
    end

    sw_activate_tab(1);
    sw_frame:Hide();

end

ui.font                                 = font;
ui.load_sw_ui                           = load_sw_ui;
ui.icon_overlay_font                    = icon_overlay_font;
ui.create_sw_base_gui                   = create_sw_base_gui;
ui.effects_from_ui                      = effects_from_ui;
ui.update_and_display_spell_diffs       = update_and_display_spell_diffs;
ui.sw_activate_tab                      = sw_activate_tab;
ui.update_loadouts_rhs                  = update_loadouts_rhs;

swc.ui = ui;

