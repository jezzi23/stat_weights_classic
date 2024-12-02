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

local update_icon_overlay_settings              = swc.overlay.update_icon_overlay_settings

local loadout_flags                             = swc.utils.loadout_flags;
local class                                     = swc.utils.class;
local deep_table_copy                           = swc.utils.deep_table_copy;
local effect_colors                             = swc.utils.effect_colors;

local empty_loadout                             = swc.loadout.empty_loadout;
local empty_effects                             = swc.loadout.empty_effects;
local active_loadout                            = swc.loadout.active_loadout;
local active_loadout_entry                      = swc.loadout.active_loadout_entry;
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

local function loadout_name_already_exists(name)

    local already_exists = false;    
    for i = 1, sw_frame.loadout_frame.lhs_list.num_loadouts do
    
        if name == sw_frame.loadout_frame.lhs_list.loadouts[i].base.name then
            already_exists = true;
        end
    end
    return already_exists;
end

local function update_loadouts_rhs()

    local loadout = active_loadout();

    if sw_frame.loadout_frame.lhs_list.num_loadouts == 1 then

        sw_frame.loadout_frame.rhs_list.delete_button:Hide();
    else
        sw_frame.loadout_frame.rhs_list.delete_button:Show();
    end

    sw_frame.calculator_frame.loadout_name_label:SetText(
        loadout.name
    );

    sw_frame.loadout_frame.rhs_list.name_editbox:SetText(
        loadout.name
    );

    sw_frame.loadout_frame.rhs_list.level_editbox:SetText(
        loadout.default_target_lvl_diff
    );

    if bit.band(loadout.flags, loadout_flags.custom_lvl) ~= 0 then

        sw_frame.loadout_frame.rhs_list.custom_lvl_checkbutton:SetChecked(true);
        sw_frame.loadout_frame.rhs_list.loadout_clvl_editbox:SetText(
            loadout.lvl
        );
        --sw_frame.loadout_frame.rhs_list.loadout_clvl_editbox:Show();
        sw_frame.loadout_frame.rhs_list.loadout_clvl_editbox:SetAlpha(1.0);
    else
        sw_frame.loadout_frame.rhs_list.custom_lvl_checkbutton:SetChecked(false);
        --sw_frame.loadout_frame.rhs_list.loadout_clvl_editbox:Hide();
        sw_frame.loadout_frame.rhs_list.loadout_clvl_editbox:SetAlpha(0.2);
    end

    sw_frame.loadout_frame.rhs_list.loadout_extra_mana_editbox:SetText(
        loadout.extra_mana
    );

    sw_frame.loadout_frame.rhs_list.hp_perc_label_editbox:SetText(
        loadout.target_hp_perc_default * 100
    );

    if sw_frame.loadout_frame.rhs_list.target_res_editbox then
        sw_frame.loadout_frame.rhs_list.target_res_editbox:SetText(
            loadout.target_res
        );
    end

    sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetText(loadout.unbounded_aoe_targets);

    if bit.band(loadout.flags, loadout_flags.is_dynamic_loadout) ~= 0 then

        sw_frame.loadout_frame.rhs_list.talent_editbox:SetText(
            wowhead_talent_link(loadout.talents_code)
        );
        sw_frame.loadout_frame.rhs_list.talent_editbox:SetAlpha(0.2);
        sw_frame.loadout_frame.rhs_list.dynamic_button:SetChecked(false);
    else

        sw_frame.loadout_frame.rhs_list.talent_editbox:SetText(
            wowhead_talent_link(loadout.custom_talents_code)
        );
        sw_frame.loadout_frame.rhs_list.talent_editbox:SetAlpha(1.0);
        sw_frame.loadout_frame.rhs_list.dynamic_button:SetChecked(true);
    end

    if bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0 then
        sw_frame.loadout_frame.rhs_list.always_apply_buffs_button:SetChecked(true);
    else
        sw_frame.loadout_frame.rhs_list.always_apply_buffs_button:SetChecked(false);
    end

    local num_checked_buffs = 0;
    local num_checked_target_buffs = 0;
    local buffs_list_alpha = 1.0;
    if bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0 then
        buffs_list_alpha = 0.2;
        for k = 1, sw_frame.loadout_frame.rhs_list.buffs.num_buffs do
            local v = sw_frame.loadout_frame.rhs_list.buffs[k];
            v.checkbutton:SetChecked(true);
            v.checkbutton:Hide();
            v.icon:Hide();
        end

        for k = 1, sw_frame.loadout_frame.rhs_list.target_buffs.num_buffs do
            local v = sw_frame.loadout_frame.rhs_list.target_buffs[k];
            v.checkbutton:SetChecked(true);
            v.checkbutton:Hide();
            v.icon:Hide();
        end
    else
        for k = 1, sw_frame.loadout_frame.rhs_list.buffs.num_buffs do

            local v = sw_frame.loadout_frame.rhs_list.buffs[k];
            if v.checkbutton.buff_type == "self" then
                
                if loadout.buffs[v.checkbutton.buff_id] then
                    v.checkbutton:SetChecked(true);
                    num_checked_buffs = num_checked_buffs + 1;
                else
                    v.checkbutton:SetChecked(false);
                end
            end
            v.checkbutton:Hide();
            v.icon:Hide();
        end
        for k = 1, sw_frame.loadout_frame.rhs_list.target_buffs.num_buffs do

            local v = sw_frame.loadout_frame.rhs_list.target_buffs[k];

            if loadout.target_buffs[v.checkbutton.buff_id] then
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
    local self_buffs_tab = sw_frame.loadout_frame.rhs_list.self_buffs_frame:IsShown();

    if self_buffs_tab then
        y_offset = sw_frame.loadout_frame.rhs_list.self_buffs_y_offset_start;
        buffs_show_max = sw_frame.loadout_frame.rhs_list.buffs.num_buffs_can_fit;
        num_buffs = sw_frame.loadout_frame.rhs_list.buffs.num_buffs;
        num_skips = math.floor(sw_frame.loadout_frame.self_buffs_slider:GetValue()) + 1;
    else
        y_offset = sw_frame.loadout_frame.rhs_list.target_buffs_y_offset_start;
        buffs_show_max = sw_frame.loadout_frame.rhs_list.target_buffs.num_buffs_can_fit;
        num_buffs = sw_frame.loadout_frame.rhs_list.target_buffs.num_buffs;
        num_skips = math.floor(sw_frame.loadout_frame.target_buffs_slider:GetValue()) + 1;
    end

    local icon_offset = -4;

    if self_buffs_tab then
        for i = num_skips, math.min(num_skips + buffs_show_max - 1, sw_frame.loadout_frame.rhs_list.buffs.num_buffs) do
            sw_frame.loadout_frame.rhs_list.buffs[i].checkbutton:SetPoint("TOPLEFT", 20, y_offset);
            sw_frame.loadout_frame.rhs_list.buffs[i].checkbutton:SetAlpha(buffs_list_alpha);
            sw_frame.loadout_frame.rhs_list.buffs[i].checkbutton:Show();
            sw_frame.loadout_frame.rhs_list.buffs[i].icon:SetPoint("TOPLEFT", 5, y_offset + icon_offset);
            sw_frame.loadout_frame.rhs_list.buffs[i].icon:SetAlpha(buffs_list_alpha);
            sw_frame.loadout_frame.rhs_list.buffs[i].icon:Show();
            y_offset = y_offset - 20;
        end
    else
        
        local target_buffs_iters = 
            math.max(0, math.min(buffs_show_max - num_skips, sw_frame.loadout_frame.rhs_list.target_buffs.num_buffs - num_skips) + 1);
        if buffs_show_max < num_skips and num_skips <= sw_frame.loadout_frame.rhs_list.target_buffs.num_buffs then
            target_buffs_iters = buffs_show_max;
        end
        if target_buffs_iters > 0 then
            for i = num_skips, num_skips + target_buffs_iters - 1 do
                sw_frame.loadout_frame.rhs_list.target_buffs[i].checkbutton:SetPoint("TOPLEFT", 20, y_offset);
                sw_frame.loadout_frame.rhs_list.target_buffs[i].checkbutton:SetAlpha(buffs_list_alpha);
                sw_frame.loadout_frame.rhs_list.target_buffs[i].checkbutton:Show();
                sw_frame.loadout_frame.rhs_list.target_buffs[i].icon:SetPoint("TOPLEFT", 5, y_offset + icon_offset);
                sw_frame.loadout_frame.rhs_list.target_buffs[i].icon:SetAlpha(buffs_list_alpha);
                sw_frame.loadout_frame.rhs_list.target_buffs[i].icon:Show();
                y_offset = y_offset - 20;
            end
        end

        num_skips = num_skips + target_buffs_iters - sw_frame.loadout_frame.rhs_list.target_buffs.num_buffs;
    end

    sw_frame.loadout_frame.rhs_list.num_checked_buffs = num_checked_buffs;
    sw_frame.loadout_frame.rhs_list.num_checked_target_buffs = num_checked_target_buffs;

    if bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0 then
        sw_frame.loadout_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(true);
        sw_frame.loadout_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(true);
    else
        if sw_frame.loadout_frame.rhs_list.num_checked_buffs == 0 then
            sw_frame.loadout_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.loadout_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(true);
        end
        if sw_frame.loadout_frame.rhs_list.num_checked_target_buffs == 0 then

            sw_frame.loadout_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.loadout_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(true);
        end
    end
    sw_frame.loadout_frame.rhs_list.select_all_buffs_checkbutton:SetAlpha(buffs_list_alpha);
    sw_frame.loadout_frame.rhs_list.select_all_target_buffs_checkbutton:SetAlpha(buffs_list_alpha);
end

local loadout_checkbutton_id_counter = 1;

function update_loadouts_lhs()

    local y_offset = -13;
    local max_slider_val = math.max(0, sw_frame.loadout_frame.lhs_list.num_loadouts - sw_frame.loadout_frame.lhs_list.num_loadouts_can_fit);

    sw_frame.loadout_frame.loadouts_slider:SetMinMaxValues(0, max_slider_val);
    if sw_frame.loadout_frame.loadouts_slider:GetValue() > max_slider_val then
        sw_frame.loadout_frame.loadouts_slider:SetValue(max_slider_val);
    end

    local num_skips = math.floor(sw_frame.loadout_frame.loadouts_slider:GetValue()) + 1;


    -- precheck to create if needed and hide by default
    for k, v in pairs(sw_frame.loadout_frame.lhs_list.loadouts) do

        local checkbutton_name = "sw_frame_loadouts_lhs_list"..k;
        v.check_button = getglobal(checkbutton_name);

        if not v.check_button then


            v.check_button = 
                CreateFrame("CheckButton", checkbutton_name, sw_frame.loadout_frame.lhs_list, "ChatConfigCheckButtonTemplate");

            v.check_button.target_index = k;

            v.check_button:SetScript("OnClick", function(self)
                
                for i = 1, sw_frame.loadout_frame.lhs_list.num_loadouts  do

                    sw_frame.loadout_frame.lhs_list.loadouts[i].check_button:SetChecked(false);
                    
                end
                self:SetChecked(true);

                swc.core.talents_update_needed = true;
                swc.core.equipment_update_needed = true;

                sw_frame.loadout_frame.lhs_list.active_loadout = self.target_index;

                update_loadouts_rhs();
            end);
        end

        v.check_button:Hide();
    end

    -- show the ones in frames according to scroll slider
    for k = num_skips, math.min(num_skips + sw_frame.loadout_frame.lhs_list.num_loadouts_can_fit - 1, 
                                sw_frame.loadout_frame.lhs_list.num_loadouts) do

        local v = sw_frame.loadout_frame.lhs_list.loadouts[k];

        getglobal(v.check_button:GetName() .. 'Text'):SetText(v.loadout.name);
        v.check_button:SetPoint("TOPLEFT", 10, y_offset);
        v.check_button:Show();

        if k == sw_frame.loadout_frame.lhs_list.active_loadout then
            v.check_button:SetChecked(true);
        else
            v.check_button:SetChecked(false);
        end

        y_offset = y_offset - 20;
    end

    update_loadouts_rhs();
end

local function create_new_loadout_as_copy(loadout_entry)


    sw_frame.loadout_frame.lhs_list.loadouts[
        sw_frame.loadout_frame.lhs_list.active_loadout].check_button:SetChecked(false);

    sw_frame.loadout_frame.lhs_list.num_loadouts = sw_frame.loadout_frame.lhs_list.num_loadouts + 1;
    sw_frame.loadout_frame.lhs_list.active_loadout = sw_frame.loadout_frame.lhs_list.num_loadouts;

    sw_frame.loadout_frame.lhs_list.loadouts[sw_frame.loadout_frame.lhs_list.num_loadouts] = {};
    local new_entry = sw_frame.loadout_frame.lhs_list.loadouts[sw_frame.loadout_frame.lhs_list.num_loadouts];
    new_entry.loadout = deep_table_copy(loadout_entry.loadout);
    new_entry.equipped = deep_table_copy(loadout_entry.equipped);
    new_entry.talented = {};
    empty_effects(new_entry.talented);
    new_entry.final_effects = {};
    empty_effects(new_entry.final_effects);

    swc.core.talents_update_needed = true;

    new_entry.loadout.name = loadout_entry.loadout.name.." (Copy)";

    update_loadouts_lhs();

    sw_frame.loadout_frame.lhs_list.loadouts[
        sw_frame.loadout_frame.lhs_list.active_loadout].check_button:SetChecked(true);
end

local function sw_activate_tab(tab_window)

    sw_frame:Show();

    for _, v in pairs(sw_frame.tabs) do
        v.frame_to_open:Hide();
        v:UnlockHighlight();
        v:SetButtonState("NORMAL");
    end

    --PanelTemplates_SetTab(sw_frame, 1);

    if tab_window.frame_to_open == sw_frame.calculator_frame then
        update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());
    end

    tab_window.frame_to_open:Show();
    tab_window:LockHighlight();
    tab_window:SetButtonState("PUSHED");
end

local function create_sw_checkbox(name, parent, line_pos_index, y_offset, text, check_func, color)

    local checkbox_frame = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate"); 
    local x_spacing = 180;
    local x_pad = 10;
    checkbox_frame:SetPoint("TOPLEFT", x_pad + (line_pos_index - 1) * x_spacing, y_offset);
    local txt = getglobal(checkbox_frame:GetName() .. 'Text');
    txt:SetText(text);
    if color then
        txt:SetTextColor(color[1], color[2], color[3]);
    end
    if check_func then
        checkbox_frame:SetScript("OnClick", check_func);
    end

    return checkbox_frame;
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
    for i, v in pairs(buttons_info) do
        local f = CreateFrame("CheckButton", "sw_frame_"..v.id, parent_frame, "ChatConfigCheckButtonTemplate");
        f._settings_id = v.id;

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
        if f.func then
            f:SetScript("OnClick", f.func);
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

    sw_frame.tooltip_frame.tooltip_settings_label_misc = sw_frame.tooltip_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.tooltip_frame.tooltip_settings_label_misc:SetFont("Fonts\\FRIZQT__.TTF", 12);
    sw_frame.tooltip_frame.tooltip_settings_label_misc:SetPoint("TOPLEFT", 0, sw_frame.tooltip_frame.y_offset);
    sw_frame.tooltip_frame.tooltip_settings_label_misc:SetText("Tooltip settings");
    sw_frame.tooltip_frame.tooltip_settings_label_misc:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.tooltip_frame.y_offset = sw_frame.tooltip_frame.y_offset - 15;
    multi_row_checkbutton(tooltip_setting_checks, sw_frame.tooltip_frame, 2);
    sw_frame.tooltip_frame.y_offset = sw_frame.tooltip_frame.y_offset - 30;

    sw_frame.tooltip_frame.tooltip_settings_label = sw_frame.tooltip_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.tooltip_frame.tooltip_settings_label:SetFont("Fonts\\FRIZQT__.TTF", 12);
    sw_frame.tooltip_frame.tooltip_settings_label:SetPoint("TOPLEFT", 0, sw_frame.tooltip_frame.y_offset);
    sw_frame.tooltip_frame.tooltip_settings_label:SetText("Tooltip display options         Presets:");
    sw_frame.tooltip_frame.tooltip_settings_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);


    sw_frame.tooltip_frame.y_offset = sw_frame.tooltip_frame.y_offset - 10;
    sw_frame.tooltip_frame.preset_default_button =
        CreateFrame("Button", nil, sw_frame.tooltip_frame, "UIPanelButtonTemplate");
    sw_frame.tooltip_frame.preset_default_button:SetScript("OnClick", function(self)

        --sw_frame.tooltip_frame.tooltip_addon_name:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_loadout_info:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_spell_rank:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_normal_effect:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_crit_effect:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_expected_effect:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_effect_per_sec:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_effect_per_cost:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_cost_per_sec:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_stat_weights:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_avg_cost:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_avg_cast:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_cast_until_oom:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_sp_effect_calc:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_dynamic_tip:SetChecked(true);

    end);
    sw_frame.tooltip_frame.preset_default_button:SetPoint("TOPLEFT", 230, sw_frame.tooltip_frame.y_offset+14);
    sw_frame.tooltip_frame.preset_default_button:SetText("Minimalistic");
    sw_frame.tooltip_frame.preset_default_button:SetWidth(90);

    sw_frame.tooltip_frame.preset_minimalistic_button =
        CreateFrame("Button", nil, sw_frame.tooltip_frame, "UIPanelButtonTemplate");
    sw_frame.tooltip_frame.preset_minimalistic_button:SetScript("OnClick", function(self)

        --sw_frame.tooltip_frame.tooltip_addon_name:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_loadout_info:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_spell_rank:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_normal_effect:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_crit_effect:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_expected_effect:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_effect_per_sec:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_effect_per_cost:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_cost_per_sec:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_stat_weights:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_avg_cost:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_avg_cast:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_cast_until_oom:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_sp_effect_calc:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_dynamic_tip:SetChecked(true);

    end);
    sw_frame.tooltip_frame.preset_minimalistic_button:SetPoint("TOPLEFT", 320, sw_frame.tooltip_frame.y_offset+14);
    sw_frame.tooltip_frame.preset_minimalistic_button:SetText("Default");
    sw_frame.tooltip_frame.preset_minimalistic_button:SetWidth(70);

    sw_frame.tooltip_frame.preset_detailed_button =
        CreateFrame("Button", nil, sw_frame.tooltip_frame, "UIPanelButtonTemplate");
    sw_frame.tooltip_frame.preset_detailed_button:SetScript("OnClick", function(self)

        --sw_frame.tooltip_frame.tooltip_addon_name:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_loadout_info:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_spell_rank:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_normal_effect:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_crit_effect:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_expected_effect:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_effect_per_sec:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_effect_per_cost:SetChecked(true);
        --sw_frame.tooltip_frame.tooltip_cost_per_sec:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_stat_weights:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_avg_cost:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_avg_cast:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_cast_until_oom:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_sp_effect_calc:SetChecked(false);
        --sw_frame.tooltip_frame.tooltip_dynamic_tip:SetChecked(true);

    end);
    sw_frame.tooltip_frame.preset_detailed_button:SetPoint("TOPLEFT", 390, sw_frame.tooltip_frame.y_offset+14);
    sw_frame.tooltip_frame.preset_detailed_button:SetText("Detailed");
    sw_frame.tooltip_frame.preset_detailed_button:SetWidth(80);

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
            txt = "Hit & resist",
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
            id = "tooltip_display_crit",
            txt = "Critical chance & modifier",
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
            color = effect_colors.cost_per_second
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
            id = "tooltip_display_stat_weights",
            txt = "Stat weights",
            color = effect_colors.stat_weights
        },
        --tooltip_display_cast_and_tap       
    };
    local tooltip_toggle = function(self)

        local checked = self:GetChecked();
        if checked then

            if sw_frame.tooltip_frame.num_tooltip_toggled == 0 then
                sw_frame_tooltip_disable:SetChecked(false);
            end
            sw_frame.tooltip_frame.num_tooltip_toggled = sw_frame.tooltip_frame.num_tooltip_toggled + 1;
        else
            sw_frame.tooltip_frame.num_tooltip_toggled = sw_frame.tooltip_frame.num_tooltip_toggled - 1;
            if sw_frame.tooltip_frame.num_tooltip_toggled == 0 then
                sw_frame_tooltip_disable:SetChecked(true);
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
            func = function()
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

    local f = CreateFrame("Slider", "sw_frame_overlay_update_freq", sw_frame.overlay_frame, "UISliderTemplate");
    f:SetOrientation('HORIZONTAL');
    f:SetPoint("TOPLEFT", 250, sw_frame.overlay_frame.y_offset+4);
    f:SetMinMaxValues(1, 30)
    f:SetValueStep(1)
    f:SetWidth(175)
    f:SetHeight(20)
    f:SetScript("OnValueChanged", function(self, val)
        p_char.overlay_update_freq = val;
    end);

    f_txt = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY")
    f_txt:SetFontObject(font)
    f_txt:SetPoint("TOPLEFT", 15, sw_frame.overlay_frame.y_offset)
    f_txt:SetText("Update frequency (higher = more responsive)");

    f_txt = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY")
    f_txt:SetFontObject(font)
    f_txt:SetPoint("TOPLEFT", 455, sw_frame.overlay_frame.y_offset)
    f_txt:SetText("Hz")

    local f_val = nil;

    -- move to reconf
    f:SetValue(config.settings.overlay_font_size);

    sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 25;

    f = CreateFrame("Slider", nil, sw_frame.overlay_frame, "UISliderTemplate");
    f:SetOrientation('HORIZONTAL');
    f:SetPoint("TOPLEFT", 250, sw_frame.overlay_frame.y_offset+4);
    f:SetMinMaxValues(2, 24)
    f:SetValueStep(1)
    f:SetWidth(175)
    f:SetHeight(20)
    f:SetValue(config.settings.overlay_font_size);

    f_txt = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY")
    f_txt:SetFontObject(font)
    f_txt:SetPoint("TOPLEFT", 15, sw_frame.overlay_frame.y_offset)
    f_txt:SetText("Font size")
    --sw_frame.overlay_frame.icon_overlay_font_size = config.settings.overlay_font_size;


    f.val_txt = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY")
    f.val_txt:SetFontObject(font)
    f.val_txt:SetPoint("TOPLEFT", 430, sw_frame.overlay_frame.y_offset)
    f.val_txt:SetText(string.format("%.2fx", config.settings.overlay_font_size));
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
    f = CreateFrame("Slider", nil, sw_frame.overlay_frame, "UISliderTemplate");
    f:SetOrientation('HORIZONTAL');
    f:SetPoint("TOPLEFT", 250, sw_frame.overlay_frame.y_offset+4);
    f:SetMinMaxValues(-15, 15);
    f:SetWidth(175)
    f:SetHeight(20)
    f:SetValue(config.settings.overlay_offset);

    f_txt = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY")
    f_txt:SetFontObject(font)
    f_txt:SetPoint("TOPLEFT", 15, sw_frame.overlay_frame.y_offset)
    f_txt:SetText("Horizontal offset")


    f.val_txt = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY")
    f.val_txt:SetFontObject(font)
    f.val_txt:SetPoint("TOPLEFT", 430, sw_frame.overlay_frame.y_offset)
    f.val_txt:SetText(string.format("%.1f", config.settings.overlay_offset))


    f:SetValueStep(0.1);
    f:SetScript("OnValueChanged", function(self, val)
        config.settings.overlay_offset = val;

        self.val_txt:SetText(string.format("%.1f", val))
        swc.core.setup_action_bar_needed = true;
        swc.overlay.update_overlay();
    end);

    sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 20;

    sw_frame.overlay_frame.icon_components_settings_label = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.overlay_frame.icon_components_settings_label:SetFont("Fonts\\FRIZQT__.TTF", 12);
    sw_frame.overlay_frame.icon_components_settings_label:SetPoint("TOPLEFT", 0, sw_frame.overlay_frame.y_offset);
    sw_frame.overlay_frame.icon_components_settings_label:SetText("Spell overlay components (max 3)");
    sw_frame.overlay_frame.icon_components_settings_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 15;

    sw_frame.overlay_frame.num_overlay_components_toggled = 0;
    sw_frame.overlay_frame.num_overlay_special_toggled = 0;

    local icon_checkbox_func = function(self)

        config.settings.overlay_disable = false;
        sw_frame_overlay_disable:SetChecked(false);

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
        update_icon_overlay_settings();
    end;

    local special_overlay_component_func = function(self)

        icon_checkbox_func(self);
        print("lol");
    end

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
            func = special_overlay_component_func
        },
        {
            id = "overlay_display_effect_per_cost",
            txt = "Effect per cost",
            color = effect_colors.effect_per_cost
        },
        {
            id = "overlay_display_avg_cost",
            txt = "Expected cost",
            color = effect_colors.avg_cost
        },
        {
            id = "overlay_display_actual_cost",
            txt = "Actual cost",
            color = effect_colors.avg_cost
        },
        {
            id = "overlay_display_avg_cast",
            txt = "Expected execution time",
            color = effect_colors.avg_cast
        },
        {
            id = "overlay_display_actual_cast",
            txt = "Actual execution time",
            color = effect_colors.avg_cast
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
            color = effect_colors.effect_until_oom
        },
        {
            id = "overlay_display_casts_until_oom",
            txt = "Casts until OOM",
            color = effect_colors.casts_until_oom
        },
        {
            id = "overlay_display_time_until_oom",
            txt = "Time until OOM",
            color = effect_colors.time_until_oom,
        },
    };

    multi_row_checkbutton(overlay_components, sw_frame.overlay_frame, 2, icon_checkbox_func);

    sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 15;

    sw_frame.overlay_frame.overlay_components = {};
    for k, v in pairs(overlay_components) do
        sw_frame.overlay_frame.overlay_components[v.id] = v.color;
    end

    --sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 30;
    --sw_frame.overlay_frame.icon_settings_update_freq_label_lhs = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY");
    --sw_frame.overlay_frame.icon_settings_update_freq_label_lhs:SetFontObject(font);
    --sw_frame.overlay_frame.icon_settings_update_freq_label_lhs:SetPoint("TOPLEFT", 15, sw_frame.overlay_frame.y_offset);
    --sw_frame.overlay_frame.icon_settings_update_freq_label_lhs:SetText("Update frequency");

    --sw_frame.overlay_frame.icon_settings_update_freq_label_lhs = sw_frame.overlay_frame:CreateFontString(nil, "OVERLAY");
    --sw_frame.overlay_frame.icon_settings_update_freq_label_lhs:SetFontObject(font);
    --sw_frame.overlay_frame.icon_settings_update_freq_label_lhs:SetPoint("TOPLEFT", 170, sw_frame.overlay_frame.y_offset);
    --sw_frame.overlay_frame.icon_settings_update_freq_label_lhs:SetText("Hz (higher = more responsive overlay)");


    --local hz_editbox = function(self)

    --    local hz = tonumber(self:GetText());
    --    if hz and hz >= 0.01 and hz <= 300 then
    --        sw_snapshot_loadout_update_freq = hz;
    --    else
    --        self:SetText("3"); 
    --        sw_snapshot_loadout_update_freq = 3;
    --    end

    --	self:ClearFocus();
    --    self:HighlightText(0,0);
    --end

    --sw_frame.overlay_frame.y_offset = sw_frame.overlay_frame.y_offset - 25;

    --sw_frame.overlay_frame.icon_settings_update_freq_editbox:SetScript("OnEnterPressed", hz_editbox);
    --sw_frame.overlay_frame.icon_settings_update_freq_editbox:SetScript("OnEscapePressed", hz_editbox);
    --sw_frame.overlay_frame.icon_settings_update_freq_editbox:SetScript("OnEditFocusLost", hz_editbox);
    --sw_frame.overlay_frame.icon_settings_update_freq_editbox:SetScript("OnTextChanged", function(self)
    --    local hz = tonumber(self:GetText());
    --    if hz and hz >= 0.01 and hz <= 300 then

    --        sw_snapshot_loadout_update_freq = tonumber(hz);
    --    end

    --end);

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

    local index = buffs_table.num_buffs + 1;

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
    local buff_name_max_len = 25;
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

    buffs_table.num_buffs = index;

    return buffs_table[index].checkbutton;
end

local function create_sw_ui_loadout_frame()

    sw_frame.loadout_frame.lhs_list = CreateFrame("ScrollFrame", "sw_loadout_frame_lhs", sw_frame.loadout_frame);
    sw_frame.loadout_frame.lhs_list:SetWidth(180);
    sw_frame.loadout_frame.lhs_list:SetHeight(600-30-200-10-25-10-20-20);
    sw_frame.loadout_frame.lhs_list:SetPoint("TOPLEFT", sw_frame, 0, -50);

    sw_frame.loadout_frame.lhs_list:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.loadout_frame.loadouts_slider:GetMinMaxValues();
        local val = sw_frame.loadout_frame.loadouts_slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.loadout_frame.loadouts_slider:SetValue(val - dir);
            update_loadouts_lhs();
        end
    end);

    sw_frame.loadout_frame.rhs_list = CreateFrame("ScrollFrame", "sw_loadout_frame_rhs", sw_frame.loadout_frame);
    sw_frame.loadout_frame.rhs_list:SetWidth(400-180);
    sw_frame.loadout_frame.rhs_list:SetHeight(600-30-30-20);
    sw_frame.loadout_frame.rhs_list:SetPoint("TOPLEFT", sw_frame, 180, -50);

    sw_frame.loadout_frame.loadouts_select_label = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.loadout_frame.loadouts_select_label:SetFontObject(font);
    sw_frame.loadout_frame.loadouts_select_label:SetPoint("TOPLEFT", sw_frame.loadout_frame.lhs_list, 15, -2);
    sw_frame.loadout_frame.loadouts_select_label:SetText("Select active loadout");
    sw_frame.loadout_frame.loadouts_select_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.loadout_frame.loadouts_slider =
        CreateFrame("Slider", nil, sw_frame.loadout_frame.lhs_list, "UISliderTemplate");
    sw_frame.loadout_frame.loadouts_slider:SetOrientation('VERTICAL');
    sw_frame.loadout_frame.loadouts_slider:SetPoint("TOPRIGHT", 0, -14);
    sw_frame.loadout_frame.loadouts_slider:SetSize(15, 248);
    sw_frame.loadout_frame.lhs_list.num_loadouts_can_fit =
        math.floor(sw_frame.loadout_frame.loadouts_slider:GetHeight()/20);
    sw_frame.loadout_frame.loadouts_slider:SetMinMaxValues(0, 0);
    sw_frame.loadout_frame.loadouts_slider:SetValue(0);
    sw_frame.loadout_frame.loadouts_slider:SetValueStep(1);
    sw_frame.loadout_frame.loadouts_slider:SetScript("OnValueChanged", function(self, val)
        update_loadouts_lhs();
    end);

    sw_frame.loadout_frame.rhs_list.self_buffs_frame = 
        CreateFrame("ScrollFrame", "sw_loadout_frame_rhs_self_buffs", sw_frame.loadout_frame.rhs_list);
    sw_frame.loadout_frame.rhs_list.self_buffs_frame:SetWidth(400-180);
    sw_frame.loadout_frame.rhs_list.self_buffs_frame:SetHeight(600-30-30);
    sw_frame.loadout_frame.rhs_list.self_buffs_frame:SetPoint("TOPLEFT", sw_frame.loadout_frame.rhs_list, 0, 0);

    sw_frame.loadout_frame.rhs_list.target_buffs_frame = 
        CreateFrame("ScrollFrame", "sw_loadout_frame_rhs_target_buffs", sw_frame.loadout_frame.rhs_list);
    sw_frame.loadout_frame.rhs_list.target_buffs_frame:SetWidth(400-180);
    sw_frame.loadout_frame.rhs_list.target_buffs_frame:SetHeight(600-30-30);
    sw_frame.loadout_frame.rhs_list.target_buffs_frame:SetPoint("TOPLEFT", sw_frame.loadout_frame.rhs_list, 0, 0);
    sw_frame.loadout_frame.rhs_list.target_buffs_frame:Hide();

    sw_frame.loadout_frame.rhs_list.num_buffs_checked = 0;
    sw_frame.loadout_frame.rhs_list.num_target_buffs_checked = 0;

    local y_offset_lhs = 0;
    
    sw_frame.loadout_frame.rhs_list.delete_button =
        CreateFrame("Button", "sw_loadouts_delete_button", sw_frame.loadout_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadout_frame.rhs_list.delete_button:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 10, y_offset_lhs);
    sw_frame.loadout_frame.rhs_list.delete_button:SetText("Delete Loadout");
    sw_frame.loadout_frame.rhs_list.delete_button:SetSize(170, 25);
    sw_frame.loadout_frame.rhs_list.delete_button:SetScript("OnClick", function(self)
        
        if sw_frame.loadout_frame.lhs_list.num_loadouts == 1 then
            return;
        end

        sw_frame.loadout_frame.lhs_list.loadouts[
            sw_frame.loadout_frame.lhs_list.active_loadout].check_button:SetChecked(false);
        
        for i = sw_frame.loadout_frame.lhs_list.num_loadouts - 1, sw_frame.loadout_frame.lhs_list.active_loadout, -1  do
            sw_frame.loadout_frame.lhs_list.loadouts[i].loadout = sw_frame.loadout_frame.lhs_list.loadouts[i+1].loadout;
            sw_frame.loadout_frame.lhs_list.loadouts[i].equipped_talented = sw_frame.loadout_frame.lhs_list.loadouts[i+1].equipped_talented;
            sw_frame.loadout_frame.lhs_list.loadouts[i].buffed_equipped_talented = sw_frame.loadout_frame.lhs_list.loadouts[i+1].buffed_equipped_talented;
        end

        sw_frame.loadout_frame.lhs_list.loadouts[
            sw_frame.loadout_frame.lhs_list.num_loadouts].check_button:Hide();

        sw_frame.loadout_frame.lhs_list.loadouts[sw_frame.loadout_frame.lhs_list.num_loadouts] = nil;

        sw_frame.loadout_frame.lhs_list.num_loadouts = sw_frame.loadout_frame.lhs_list.num_loadouts - 1;

        sw_frame.loadout_frame.lhs_list.active_loadout = sw_frame.loadout_frame.lhs_list.num_loadouts;

        swc.core.talents_update_needed = true;
        swc.core.equipment_update_needed = true;

        update_loadouts_lhs();
    end);

    y_offset_lhs = y_offset_lhs - 30;

    sw_frame.loadout_frame.rhs_list.export_button =
        CreateFrame("Button", "sw_loadouts_export_button", sw_frame.loadout_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadout_frame.rhs_list.export_button:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 10, y_offset_lhs);
    sw_frame.loadout_frame.rhs_list.export_button:SetText("Create loadout as a copy");
    sw_frame.loadout_frame.rhs_list.export_button:SetSize(170, 25);
    sw_frame.loadout_frame.rhs_list.export_button:SetScript("OnClick", function(self)

        create_new_loadout_as_copy(active_loadout_entry());
    end);

    y_offset_lhs = y_offset_lhs - 20;


    sw_frame.loadout_frame.rhs_list.loadout_rename_label = 
        sw_frame.loadout_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadout_frame.rhs_list.loadout_rename_label:SetFontObject(font);
    sw_frame.loadout_frame.rhs_list.loadout_rename_label:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadout_frame.rhs_list.loadout_rename_label:SetText("Rename");

    sw_frame.loadout_frame.rhs_list.name_editbox = 
        CreateFrame("EditBox", "sw_loadout_name_editbox", sw_frame.loadout_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadout_frame.rhs_list.name_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 65, y_offset_lhs - 2);
    sw_frame.loadout_frame.rhs_list.name_editbox:SetText("");
    sw_frame.loadout_frame.rhs_list.name_editbox:SetSize(110, 15);
    sw_frame.loadout_frame.rhs_list.name_editbox:SetAutoFocus(false);
    local editbox_save = function(self)

        local txt = self:GetText();
        active_loadout().name = txt;

        update_loadouts_lhs();
    end

    sw_frame.loadout_frame.rhs_list.name_editbox:SetScript("OnEnterPressed", function(self) 
        editbox_save(self);
        self:ClearFocus();
    end);
    sw_frame.loadout_frame.rhs_list.name_editbox:SetScript("OnEscapePressed", function(self) 
        editbox_save(self);
        self:ClearFocus();
    end);
    sw_frame.loadout_frame.rhs_list.name_editbox:SetScript("OnTextChanged", editbox_save);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadout_frame.rhs_list.loadout_talent_label = sw_frame.loadout_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadout_frame.rhs_list.loadout_talent_label:SetFontObject(font);
    sw_frame.loadout_frame.rhs_list.loadout_talent_label:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadout_frame.rhs_list.loadout_talent_label:SetText("Talents (Wowhead link)");

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadout_frame.rhs_list.talent_editbox = 
        CreateFrame("EditBox", "sw_loadout_talent_editbox", sw_frame.loadout_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadout_frame.rhs_list.talent_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 20, y_offset_lhs - 2);
    --sw_frame.loadout_frame.rhs_list.talent_editbox:SetText("");
    sw_frame.loadout_frame.rhs_list.talent_editbox:SetSize(150, 15);
    sw_frame.loadout_frame.rhs_list.talent_editbox:SetAutoFocus(false);
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

    sw_frame.loadout_frame.rhs_list.talent_editbox:SetScript("OnEnterPressed", function(self) 
        talent_editbox(self);
        self:ClearFocus();
    end);
    sw_frame.loadout_frame.rhs_list.talent_editbox:SetScript("OnEscapePressed", function(self) 
        talent_editbox(self);
        self:ClearFocus();
    end);

    sw_frame.loadout_frame.rhs_list.talent_editbox:SetScript("OnTextChanged", function(self) 
        talent_editbox(self);
        self:ClearFocus();
    end);


    y_offset_lhs = y_offset_lhs - 30;

    sw_frame.loadout_frame.rhs_list.dynamic_button = 
        CreateFrame("CheckButton", "sw_loadout_dynamic_check", sw_frame.loadout_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadout_frame.rhs_list.dynamic_button:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 10, y_offset_lhs);

    if swc.core.expansion_loaded == swc.core.expansions.wotlk then
        getglobal(sw_frame.loadout_frame.rhs_list.dynamic_button:GetName()..'Text'):SetText("Custom talents & glyphs");
        getglobal(sw_frame.loadout_frame.rhs_list.dynamic_button:GetName()).tooltip = 
            "Given a valid wowhead talents link above, your loadout will use its talents & glyphs instead of your active ones.";
    else
        getglobal(sw_frame.loadout_frame.rhs_list.dynamic_button:GetName()..'Text'):SetText("Custom talents & runes");
        getglobal(sw_frame.loadout_frame.rhs_list.dynamic_button:GetName()).tooltip = 
            "Given a valid wowhead talents link above, your loadout will use its talents & runes instead of your active ones.";
    end

    sw_frame.loadout_frame.rhs_list.dynamic_button:SetScript("OnClick", function(self)
        
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

    sw_frame.loadout_frame.rhs_list.custom_lvl_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_custom_lvl_checkbutton", sw_frame.loadout_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadout_frame.rhs_list.custom_lvl_checkbutton:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 10, y_offset_lhs);
    sw_frame.loadout_frame.rhs_list.custom_lvl_checkbutton:SetHitRectInsets(0, 0, 0, 0);

    getglobal(sw_frame.loadout_frame.rhs_list.custom_lvl_checkbutton:GetName()..'Text'):SetText("Custom char lvl");
    getglobal(sw_frame.loadout_frame.rhs_list.custom_lvl_checkbutton:GetName()).tooltip = 
        "Displays ability information as if character is a custom level (attributes from levels are not accounted for)";

    sw_frame.loadout_frame.rhs_list.custom_lvl_checkbutton:SetScript("OnClick", function(self)
        
        local loadout_entry = active_loadout_entry();

        if self:GetChecked() then
            loadout_entry.loadout.flags = bit.bor(loadout_entry.loadout.flags, loadout_flags.custom_lvl);
        else
            loadout_entry.loadout.flags = bit.band(loadout_entry.loadout.flags, bit.bnot(loadout_flags.custom_lvl));
        end
        update_loadouts_rhs();
    end);

    sw_frame.loadout_frame.rhs_list.loadout_clvl_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadout_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadout_frame.rhs_list.loadout_clvl_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 130, y_offset_lhs + 7);
    sw_frame.loadout_frame.rhs_list.loadout_clvl_editbox:SetSize(40, 15);
    sw_frame.loadout_frame.rhs_list.loadout_clvl_editbox:SetAutoFocus(false);

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

    sw_frame.loadout_frame.rhs_list.loadout_clvl_editbox:SetScript("OnEnterPressed", clvl_editbox);
    sw_frame.loadout_frame.rhs_list.loadout_clvl_editbox:SetScript("OnEscapePressed", clvl_editbox);
    sw_frame.loadout_frame.rhs_list.loadout_clvl_editbox:SetScript("OnEditFocusLost", clvl_editbox);
    sw_frame.loadout_frame.rhs_list.loadout_clvl_editbox:SetScript("OnTextChanged", function(self)

        local loadout = active_loadout();
        local lvl = tonumber(self:GetText());
        if lvl and lvl >= 1 and lvl <= 100 then
            loadout.lvl = lvl;
        end
    end);

    y_offset_lhs = y_offset_lhs - 12;

    sw_frame.loadout_frame.rhs_list.loadout_level_label = 
        sw_frame.loadout_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadout_frame.rhs_list.loadout_level_label:SetFontObject(font);
    sw_frame.loadout_frame.rhs_list.loadout_level_label:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadout_frame.rhs_list.loadout_level_label:SetText("Default target lvl diff");

    sw_frame.loadout_frame.rhs_list.level_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadout_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadout_frame.rhs_list.level_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 130, y_offset_lhs - 2);
    sw_frame.loadout_frame.rhs_list.level_editbox:SetText("");
    sw_frame.loadout_frame.rhs_list.level_editbox:SetSize(40, 15);
    sw_frame.loadout_frame.rhs_list.level_editbox:SetAutoFocus(false);

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

    sw_frame.loadout_frame.rhs_list.level_editbox:SetScript("OnEnterPressed", editbox_lvl);
    sw_frame.loadout_frame.rhs_list.level_editbox:SetScript("OnEscapePressed", editbox_lvl);
    sw_frame.loadout_frame.rhs_list.level_editbox:SetScript("OnEditFocusLost", editbox_lvl);
    sw_frame.loadout_frame.rhs_list.level_editbox:SetScript("OnTextChanged", function(self)
        -- silently try to apply valid changes but don't panic while focus is on
        local lvl_diff = tonumber(self:GetText());
        local loadout = active_loadout();
        if lvl_diff and lvl_diff == math.floor(lvl_diff) and loadout.lvl + lvl_diff >= 1 and loadout.lvl + lvl_diff <= 83 then

            loadout.default_target_lvl_diff = lvl_diff;
        end
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadout_frame.rhs_list.hp_perc_label = 
        sw_frame.loadout_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadout_frame.rhs_list.hp_perc_label:SetFontObject(font);
    sw_frame.loadout_frame.rhs_list.hp_perc_label:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadout_frame.rhs_list.hp_perc_label:SetText("Default target HP                   %");

    sw_frame.loadout_frame.rhs_list.hp_perc_label_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadout_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadout_frame.rhs_list.hp_perc_label_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 130, y_offset_lhs - 2);
    sw_frame.loadout_frame.rhs_list.hp_perc_label_editbox:SetText("");
    sw_frame.loadout_frame.rhs_list.hp_perc_label_editbox:SetSize(40, 15);
    sw_frame.loadout_frame.rhs_list.hp_perc_label_editbox:SetAutoFocus(false);

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

    sw_frame.loadout_frame.rhs_list.hp_perc_label_editbox:SetScript("OnEnterPressed", editbox_hp_perc);
    sw_frame.loadout_frame.rhs_list.hp_perc_label_editbox:SetScript("OnEscapePressed", editbox_hp_perc);
    sw_frame.loadout_frame.rhs_list.hp_perc_label_editbox:SetScript("OnEditFocusLost", editbox_hp_perc);
    sw_frame.loadout_frame.rhs_list.hp_perc_label_editbox:SetScript("OnTextChanged", function(self)

        local hp_perc = tonumber(self:GetText());
        local loadout = active_loadout();
        if hp_perc and hp_perc >= 0 then

            loadout.target_hp_perc_default = 0.01*hp_perc;
        end
    end);

    if swc.core.expansion_loaded == swc.core.expansions.vanilla then

        y_offset_lhs = y_offset_lhs - 20;

        sw_frame.loadout_frame.rhs_list.target_res_label = 
            sw_frame.loadout_frame.rhs_list:CreateFontString(nil, "OVERLAY");
        sw_frame.loadout_frame.rhs_list.target_res_label:SetFontObject(font);
        sw_frame.loadout_frame.rhs_list.target_res_label:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 15, y_offset_lhs);
        sw_frame.loadout_frame.rhs_list.target_res_label:SetText("Target resistance                   ");

        sw_frame.loadout_frame.rhs_list.target_res_editbox= CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadout_frame.rhs_list, "InputBoxTemplate");
        sw_frame.loadout_frame.rhs_list.target_res_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 130, y_offset_lhs - 2);
        sw_frame.loadout_frame.rhs_list.target_res_editbox:SetText("");
        sw_frame.loadout_frame.rhs_list.target_res_editbox:SetSize(40, 15);
        sw_frame.loadout_frame.rhs_list.target_res_editbox:SetAutoFocus(false);

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

        sw_frame.loadout_frame.rhs_list.target_res_editbox:SetScript("OnEnterPressed", editbox_target_res);
        sw_frame.loadout_frame.rhs_list.target_res_editbox:SetScript("OnEscapePressed", editbox_target_res);
        sw_frame.loadout_frame.rhs_list.target_res_editbox:SetScript("OnEditFocusLost", editbox_target_res);
        sw_frame.loadout_frame.rhs_list.target_res_editbox:SetScript("OnTextChanged", function(self)
            local target_res = tonumber(self:GetText());
            local loadout = active_loadout();
            if target_res and target_res >= 0 then
                loadout.target_res = target_res;
            end
        end);
    end

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadout_frame.rhs_list.loadout_extra_mana = 
        sw_frame.loadout_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadout_frame.rhs_list.loadout_extra_mana:SetFontObject(font);
    sw_frame.loadout_frame.rhs_list.loadout_extra_mana:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadout_frame.rhs_list.loadout_extra_mana:SetText("Extra mana (pots)");

    sw_frame.loadout_frame.rhs_list.loadout_extra_mana_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadout_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadout_frame.rhs_list.loadout_extra_mana_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 130, y_offset_lhs - 2);
    sw_frame.loadout_frame.rhs_list.loadout_extra_mana_editbox:SetSize(40, 15);
    sw_frame.loadout_frame.rhs_list.loadout_extra_mana_editbox:SetAutoFocus(false);

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

    sw_frame.loadout_frame.rhs_list.loadout_extra_mana_editbox:SetScript("OnEnterPressed", mana_editbox);
    sw_frame.loadout_frame.rhs_list.loadout_extra_mana_editbox:SetScript("OnEscapePressed", mana_editbox);
    sw_frame.loadout_frame.rhs_list.loadout_extra_mana_editbox:SetScript("OnEditFocusLost", mana_editbox);
    sw_frame.loadout_frame.rhs_list.loadout_extra_mana_editbox:SetScript("OnTextChanged", function(self)

        local loadout = active_loadout();
        local mana = tonumber(self:GetText());
        if mana then
            loadout.extra_mana = mana;
        end
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets = 
        sw_frame.loadout_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets:SetFontObject(font);
    sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets:SetText("Limitless AOE targets");

    sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadout_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 130, y_offset_lhs - 2);
    sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetSize(40, 15);
    sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetAutoFocus(false);

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

    sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetScript("OnEnterPressed", aoe_targets_editbox_fn);
    sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetScript("OnEscapePressed", aoe_targets_editbox_fn);
    sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetScript("OnEditFocusLost", aoe_targets_editbox_fn);
    sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:SetScript("OnTextChanged", function(self)

        local loadout = active_loadout();
        local targets = tonumber(self:GetText());
        if targets and targets >= 1 then
            loadout.unbounded_aoe_targets = math.floor(targets);
        end

    end);
    if swc.core.expansion_loaded ~= swc.core.expansions.vanilla then
        sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets:Hide();
        sw_frame.loadout_frame.rhs_list.loadout_unbounded_aoe_targets_editbox:Hide();
    end

    y_offset_lhs = y_offset_lhs - 27;

    sw_frame.loadout_frame.rhs_list.max_mana_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_max_mana", sw_frame.loadout_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadout_frame.rhs_list.max_mana_checkbutton:SetPoint("BOTTOMLEFT", sw_frame.loadout_frame.lhs_list, 10, y_offset_lhs);
    getglobal(sw_frame.loadout_frame.rhs_list.max_mana_checkbutton:GetName()..'Text'):SetText("Maximum mana");
    getglobal(sw_frame.loadout_frame.rhs_list.max_mana_checkbutton:GetName()).tooltip = 
        "Casting until OOM uses maximum mana instead of current.";
    sw_frame.loadout_frame.rhs_list.max_mana_checkbutton:SetScript("OnClick", function(self)
        local loadout = active_loadout();
        if self:GetChecked() then
            loadout.flags = bit.bor(loadout.flags, loadout_flags.always_max_mana);
        else    
            loadout.flags = bit.band(loadout.flags, bit.bnot(loadout_flags.always_max_mana));
        end
    end)

    local y_offset_rhs = 0;

    sw_frame.loadout_frame.loadouts_select_label = sw_frame.loadout_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.loadout_frame.loadouts_select_label:SetFontObject(font);
    sw_frame.loadout_frame.loadouts_select_label:SetPoint("TOPLEFT", sw_frame.loadout_frame.rhs_list, 5, -2);
    sw_frame.loadout_frame.loadouts_select_label:SetText("Toggle-able effects");
    sw_frame.loadout_frame.loadouts_select_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    y_offset_rhs = y_offset_rhs - 15;

    sw_frame.loadout_frame.rhs_list.always_apply_buffs_button = 
        CreateFrame("CheckButton", "sw_loadout_always_apply_buffs_button", sw_frame.loadout_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadout_frame.rhs_list.always_apply_buffs_button:SetPoint("TOPLEFT", sw_frame.loadout_frame.rhs_list, 0, y_offset_rhs);
    getglobal(sw_frame.loadout_frame.rhs_list.always_apply_buffs_button:GetName() .. 'Text'):SetText("Apply buffs even when inactive");
    getglobal(sw_frame.loadout_frame.rhs_list.always_apply_buffs_button:GetName()).tooltip = 
        "The selected buffs will be forcibly applied behind the scenes to the spell calculations";
    sw_frame.loadout_frame.rhs_list.always_apply_buffs_button:SetScript("OnClick", function(self)

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

    y_offset_rhs = y_offset_rhs - 15;


    sw_frame.loadout_frame.rhs_list.buffs_button =
        CreateFrame("Button", "sw_frame_buffs_button", sw_frame.loadout_frame.rhs_list, "PanelTopTabButtonTemplate");
    sw_frame.loadout_frame.rhs_list.buffs_button:SetScript("OnClick", function(self)

        sw_frame.loadout_frame.rhs_list.self_buffs_frame:Show();

        sw_frame.loadout_frame.rhs_list.buffs_button:LockHighlight();
        sw_frame.loadout_frame.rhs_list.buffs_button:SetButtonState("PUSHED");

        sw_frame.loadout_frame.rhs_list.target_buffs_frame:Hide();

        sw_frame.loadout_frame.rhs_list.target_buffs_button:UnlockHighlight();
        sw_frame.loadout_frame.rhs_list.target_buffs_button:SetButtonState("NORMAL");

        update_loadouts_rhs();

    end);
    sw_frame.loadout_frame.rhs_list.buffs_button:SetPoint("TOPLEFT", 20, y_offset_rhs);
    sw_frame.loadout_frame.rhs_list.buffs_button:SetText("PLAYER");
    sw_frame.loadout_frame.rhs_list.buffs_button:SetWidth(93);
    sw_frame.loadout_frame.rhs_list.buffs_button:LockHighlight();
    sw_frame.loadout_frame.rhs_list.buffs_button:SetButtonState("PUSHED");

    sw_frame.loadout_frame.rhs_list.buffs_button:SetID(1);
    PanelTemplates_TabResize(sw_frame.loadout_frame.rhs_list.buffs_button, 0)

    sw_frame.loadout_frame.rhs_list.target_buffs_button =
        CreateFrame("Button", "sw_frame_target_buffs_button", sw_frame.loadout_frame.rhs_list, "PanelTopTabButtonTemplate");
    sw_frame.loadout_frame.rhs_list.target_buffs_button:SetScript("OnClick", function(self)

        sw_frame.loadout_frame.rhs_list.target_buffs_frame:Show();

        sw_frame.loadout_frame.rhs_list.target_buffs_button:LockHighlight();
        sw_frame.loadout_frame.rhs_list.target_buffs_button:SetButtonState("PUSHED");

        sw_frame.loadout_frame.rhs_list.self_buffs_frame:Hide();

        sw_frame.loadout_frame.rhs_list.buffs_button:UnlockHighlight();
        sw_frame.loadout_frame.rhs_list.buffs_button:SetButtonState("NORMAL");

        update_loadouts_rhs();

    end);
    sw_frame.loadout_frame.rhs_list.target_buffs_button:SetPoint("TOPLEFT", 93, y_offset_rhs);
    sw_frame.loadout_frame.rhs_list.target_buffs_button:SetText("TARGET");
    sw_frame.loadout_frame.rhs_list.target_buffs_button:SetWidth(93);
    sw_frame.loadout_frame.rhs_list.target_buffs_button:SetID(2);
    PanelTemplates_TabResize(sw_frame.loadout_frame.rhs_list.target_buffs_button, 0)

    y_offset_rhs = y_offset_rhs - 30;

    sw_frame.loadout_frame.rhs_list.buffs = {};
    sw_frame.loadout_frame.rhs_list.buffs.num_buffs = 0;

    sw_frame.loadout_frame.rhs_list.target_buffs = {};
    sw_frame.loadout_frame.rhs_list.target_buffs.num_buffs = 0;

    local check_button_buff_func = function(self)

        local loadout = sw_frame.loadout_frame.lhs_list.loadouts[sw_frame.loadout_frame.lhs_list.active_loadout].loadout;
        if bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0 then
            self:SetChecked(true);
            return;
        end
        if self:GetChecked() then
            if self.buff_type == "self" then
                loadout.buffs[self.buff_id] = self.buff_info;
                sw_frame.loadout_frame.rhs_list.num_checked_buffs = sw_frame.loadout_frame.rhs_list.num_checked_buffs + 1;
            elseif self.buff_type == "target_buffs" then
                loadout.target_buffs[self.buff_id] = self.buff_info;
                sw_frame.loadout_frame.rhs_list.num_checked_target_buffs = sw_frame.loadout_frame.rhs_list.num_checked_target_buffs + 1;
            end

        else    
            if self.buff_type == "self" then
                loadout.buffs[self.buff_id] = nil;
                sw_frame.loadout_frame.rhs_list.num_checked_buffs = sw_frame.loadout_frame.rhs_list.num_checked_buffs - 1;
            elseif self.buff_type == "target_buffs" then
                loadout.target_buffs[self.buff_id] = nil;
                sw_frame.loadout_frame.rhs_list.num_checked_target_buffs = sw_frame.loadout_frame.rhs_list.num_checked_target_buffs - 1;
            end
        end

        if sw_frame.loadout_frame.rhs_list.num_checked_buffs == 0 then
            sw_frame.loadout_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.loadout_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(true);
        end

        if sw_frame.loadout_frame.rhs_list.num_checked_target_buffs == 0 then
            sw_frame.loadout_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.loadout_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(true);
        end
    end

    local y_offset_rhs_buffs = y_offset_rhs - 3;
    local y_offset_rhs_target_buffs = y_offset_rhs - 3;

    -- add select all optoin for both buffs and debuffs

    sw_frame.loadout_frame.rhs_list.select_all_buffs_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_select_all_buffs", sw_frame.loadout_frame.rhs_list.self_buffs_frame, "ChatConfigCheckButtonTemplate");
    sw_frame.loadout_frame.rhs_list.select_all_buffs_checkbutton:SetPoint("TOPLEFT", 20, y_offset_rhs_buffs);
    getglobal(sw_frame.loadout_frame.rhs_list.select_all_buffs_checkbutton:GetName() .. 'Text'):SetText("SELECT ALL/NONE");
    getglobal(sw_frame.loadout_frame.rhs_list.select_all_buffs_checkbutton:GetName() .. 'Text'):SetTextColor(1, 0, 0);

    sw_frame.loadout_frame.rhs_list.select_all_buffs_checkbutton:SetScript("OnClick", function(self) 

        local loadout = active_loadout();
        if bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0 then
            self:SetChecked(true)
            return;
        end
        if self:GetChecked() then
            loadout.buffs = {};
            for i = 1, sw_frame.loadout_frame.rhs_list.buffs.num_buffs do
                loadout.buffs[sw_frame.loadout_frame.rhs_list.buffs[i].checkbutton.buff_id] =
                    sw_frame.loadout_frame.rhs_list.buffs[i].checkbutton.buff_info;
            end
        else
            loadout.buffs = {};
        end

        update_loadouts_rhs();
    end);

    sw_frame.loadout_frame.rhs_list.select_all_target_buffs_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_select_all_target_buffs", sw_frame.loadout_frame.rhs_list.target_buffs_frame, "ChatConfigCheckButtonTemplate");
    sw_frame.loadout_frame.rhs_list.select_all_target_buffs_checkbutton:SetPoint("TOPLEFT", 20, y_offset_rhs_target_buffs);
    getglobal(sw_frame.loadout_frame.rhs_list.select_all_target_buffs_checkbutton:GetName() .. 'Text'):SetText("SELECT ALL/NONE");
    getglobal(sw_frame.loadout_frame.rhs_list.select_all_target_buffs_checkbutton:GetName() .. 'Text'):SetTextColor(1, 0, 0);
    sw_frame.loadout_frame.rhs_list.select_all_target_buffs_checkbutton:SetScript("OnClick", function(self)
        local loadout = active_loadout();
        if bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0 then
            self:SetChecked(true)
            return;
        end
        if self:GetChecked() then
            for  i = 1, sw_frame.loadout_frame.rhs_list.target_buffs.num_buffs  do
                loadout.target_buffs[sw_frame.loadout_frame.rhs_list.target_buffs[i].checkbutton.buff_id] =
                    sw_frame.loadout_frame.rhs_list.target_buffs[i].checkbutton.buff_info;
            end
        else
            loadout.target_buffs = {};
        end
        update_loadouts_rhs();
    end);


    y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
    y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;

    sw_frame.loadout_frame.rhs_list.self_buffs_y_offset_start = y_offset_rhs_buffs;
    sw_frame.loadout_frame.rhs_list.target_buffs_y_offset_start = y_offset_rhs_target_buffs;

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
            sw_frame.loadout_frame.rhs_list.buffs, buff_id, v, "self",
            sw_frame.loadout_frame.rhs_list.self_buffs_frame, check_button_buff_func
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
            sw_frame.loadout_frame.rhs_list.target_buffs, buff_id, v, "target_buffs",
            sw_frame.loadout_frame.rhs_list.target_buffs_frame, check_button_buff_func
        );
    end

    sw_frame.loadout_frame.self_buffs_slider =
        CreateFrame("Slider", nil, sw_frame.loadout_frame.rhs_list.self_buffs_frame, "UISliderTemplate");
    sw_frame.loadout_frame.self_buffs_slider:SetOrientation('VERTICAL');
    sw_frame.loadout_frame.self_buffs_slider:SetPoint("TOPRIGHT", -10, -82);
    sw_frame.loadout_frame.self_buffs_slider:SetSize(15, 465);
    sw_frame.loadout_frame.rhs_list.buffs.num_buffs_can_fit =
        math.floor(sw_frame.loadout_frame.self_buffs_slider:GetHeight()/20);
    sw_frame.loadout_frame.self_buffs_slider:SetMinMaxValues(
        0, 
        max(0, sw_frame.loadout_frame.rhs_list.buffs.num_buffs - sw_frame.loadout_frame.rhs_list.buffs.num_buffs_can_fit)
    );
    sw_frame.loadout_frame.self_buffs_slider:SetValue(0);
    sw_frame.loadout_frame.self_buffs_slider:SetValueStep(1);
    sw_frame.loadout_frame.self_buffs_slider:SetScript("OnValueChanged", function(self, val)

        update_loadouts_rhs();
    end);

    sw_frame.loadout_frame.rhs_list.self_buffs_frame:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.loadout_frame.self_buffs_slider:GetMinMaxValues();
        local val = sw_frame.loadout_frame.self_buffs_slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.loadout_frame.self_buffs_slider:SetValue(val - dir);
            update_loadouts_rhs();
        end
    end);

    sw_frame.loadout_frame.target_buffs_slider =
        CreateFrame("Slider", nil, sw_frame.loadout_frame.rhs_list.target_buffs_frame, "UISliderTemplate");
    sw_frame.loadout_frame.target_buffs_slider:SetOrientation('VERTICAL');
    sw_frame.loadout_frame.target_buffs_slider:SetPoint("TOPRIGHT", -10, -82);
    sw_frame.loadout_frame.target_buffs_slider:SetSize(15, 465);
    sw_frame.loadout_frame.rhs_list.target_buffs.num_buffs_can_fit = 
        math.floor(sw_frame.loadout_frame.target_buffs_slider:GetHeight()/20);
    sw_frame.loadout_frame.target_buffs_slider:SetMinMaxValues(
        0, 
        max(0, sw_frame.loadout_frame.rhs_list.target_buffs.num_buffs - sw_frame.loadout_frame.rhs_list.target_buffs.num_buffs_can_fit)
    );
    sw_frame.loadout_frame.target_buffs_slider:SetValue(0);
    sw_frame.loadout_frame.target_buffs_slider:SetValueStep(1);
    sw_frame.loadout_frame.target_buffs_slider:SetScript("OnValueChanged", function(self, val)
        update_loadouts_rhs();
    end);

    sw_frame.loadout_frame.rhs_list.target_buffs_frame:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.loadout_frame.target_buffs_slider:GetMinMaxValues();
        local val = sw_frame.loadout_frame.target_buffs_slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.loadout_frame.target_buffs_slider:SetValue(val - dir);
            update_loadouts_rhs();
        end
    end);
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

    for _, v in pairs({"spells_frame", "tooltip_frame", "overlay_frame", "loadout_frame", "calculator_frame", "profile_frame"}) do
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

    sw_frame.libstub_icon_checkbox = CreateFrame("CheckButton", "sw_show_minimap_button", sw_frame, "ChatConfigCheckButtonTemplate");
    sw_frame.libstub_icon_checkbox:SetPoint("TOPRIGHT", sw_frame, -110, 0);
    sw_frame.libstub_icon_checkbox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            libstub_icon:Show(swc.core.sw_addon_name);
        else
            libstub_icon:Hide(swc.core.sw_addon_name);
        end
    end);
    sw_frame.libstub_icon_checkbox_txt = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.libstub_icon_checkbox_txt:SetFontObject(font);
    sw_frame.libstub_icon_checkbox_txt:SetText("Minimap button");
    sw_frame.libstub_icon_checkbox_txt:SetPoint("TOPRIGHT", sw_frame, -30, -6);


    sw_frame.tabs = {};

    local i = 1;

    sw_frame.tabs[i] = CreateFrame("Button", "sw_frame_tab_button"..i, sw_frame, "PanelTopTabButtonTemplate");
    sw_frame.tabs[i]:SetPoint("TOPLEFT", 10, -25);
    sw_frame.tabs[i]:SetWidth(116);
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
    sw_frame.tabs[i]:SetPoint("TOPLEFT", 75, -25);
    sw_frame.tabs[i]:SetWidth(116);
    sw_frame.tabs[i]:SetHeight(25);
    sw_frame.tabs[i]:SetText("Tooltip");
    sw_frame.tabs[i]:SetScript("OnClick", function(self)
        sw_activate_tab(self);
    end);
    sw_frame.tabs[i]:SetID(i);
    sw_frame.tabs[i].frame_to_open = sw_frame.tooltip_frame;
    PanelTemplates_TabResize(sw_frame.tabs[i], 0)

    i = i + 1;
    sw_frame.tabs[i] = CreateFrame("Button", "sw_frame_tab_button"..i, sw_frame, "PanelTopTabButtonTemplate");
    sw_frame.tabs[i]:SetPoint("TOPLEFT", 145, -25);
    sw_frame.tabs[i]:SetWidth(116);
    sw_frame.tabs[i]:SetHeight(25);
    sw_frame.tabs[i]:SetText("Overlay");
    sw_frame.tabs[i]:SetID(i);
    sw_frame.tabs[i]:SetScript("OnClick", function(self)
        sw_activate_tab(self);
    end);
    sw_frame.tabs[i].frame_to_open = sw_frame.overlay_frame;
    PanelTemplates_TabResize(sw_frame.tabs[i], 0)

    i = i + 1;
    sw_frame.tabs[i] = CreateFrame("Button", "sw_frame_tab_button"..i, sw_frame, "PanelTopTabButtonTemplate");
    sw_frame.tabs[i]:SetPoint("TOPLEFT", 220, -25);
    sw_frame.tabs[i]:SetWidth(150);
    sw_frame.tabs[i]:SetHeight(25);
    sw_frame.tabs[i]:SetText("Loadout");
    sw_frame.tabs[i]:SetScript("OnClick", function(self)
        sw_activate_tab(self);
    end);
    sw_frame.tabs[i]:SetID(i);
    sw_frame.tabs[i].frame_to_open = sw_frame.loadout_frame;
    PanelTemplates_TabResize(sw_frame.tabs[i], 0);

    i = i + 1;
    sw_frame.tabs[i] = CreateFrame("Button", "sw_frame_tab_button"..i, sw_frame, "PanelTopTabButtonTemplate");
    sw_frame.tabs[i]:SetPoint("TOPLEFT", 298, -25);
    sw_frame.tabs[i]:SetWidth(150);
    sw_frame.tabs[i]:SetHeight(25);
    sw_frame.tabs[i]:SetText("Calculator");
    sw_frame.tabs[i]:SetScript("OnClick", function(self)
        sw_activate_tab(self);
    end);
    sw_frame.tabs[i]:SetID(i);
    sw_frame.tabs[i].frame_to_open = sw_frame.calculator_frame;
    PanelTemplates_TabResize(sw_frame.tabs[i], 0);

    i = i + 1;
    sw_frame.tabs[i] = CreateFrame("Button", "sw_frame_tab_button"..i, sw_frame, "PanelTopTabButtonTemplate");
    sw_frame.tabs[i]:SetPoint("TOPLEFT", 385, -25);
    sw_frame.tabs[i]:SetWidth(150);
    sw_frame.tabs[i]:SetHeight(25);
    sw_frame.tabs[i]:SetText("Profile");
    sw_frame.tabs[i]:SetScript("OnClick", function(self)
        sw_activate_tab(self);
    end);
    sw_frame.tabs[i]:SetID(i);
    sw_frame.tabs[i].frame_to_open = sw_frame.profile_frame;
    PanelTemplates_TabResize(sw_frame.tabs[i], 0);

    PanelTemplates_SetNumTabs(sw_frame, i);
end


local function load_sw_ui()

    create_sw_ui_spells_frame();

    create_sw_ui_calculator_frame();

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
                tooltip:AddLine("|cFF9CD6DEMiddle click:|r Destroy this foolish button");
                tooltip:AddLine("More info about this addon at:");
                tooltip:AddLine("https://www.curseforge.com/wow/addons/stat-weights-classic");
                tooltip:AddLine("Factory reset: /swc reset");
            end,
        });
        if libstub_icon then
            libstub_icon:Register(swc.core.sw_addon_name, sw_launcher, config.settings.libstub_minimap_icon);
        end
    end

    if config.settings.libstub_minimap_icon.hide then
        libstub_icon:Hide(swc.core.sw_addon_name);
    else
        libstub_icon:Show(swc.core.sw_addon_name);
        sw_frame.libstub_icon_checkbox:SetChecked(true);
    end


    create_sw_ui_tooltip_frame();

    create_sw_ui_overlay_frame();

    create_sw_ui_loadout_frame();

    --if not p_char.loadouts or not p_char.loadouts.num_loadouts  then
    --    -- load defaults
    --    p_char.loadouts = {};
    --    p_char.loadouts.loadouts_list = {};

    --    p_char.loadouts.loadouts_list[1] = {};
    --    p_char.loadouts.loadouts_list[1].loadout = empty_loadout();
    --    default_loadout(p_char.loadouts.loadouts_list[1].loadout);
    --    p_char.loadouts.loadouts_list[1].equipped = {};
    --    p_char.loadouts.loadouts_list[1].talented = {};
    --    p_char.loadouts.loadouts_list[1].final_effects = {};
    --    empty_effects(p_char.loadouts.loadouts_list[1].equipped);
    --    empty_effects(p_char.loadouts.loadouts_list[1].talented);
    --    empty_effects(p_char.loadouts.loadouts_list[1].final_effects);
    --    p_char.loadouts.active_loadout = 1;

    --    -- add secondary PVP loadout with lvl diff of 0 by default
    --    p_char.loadouts.loadouts_list[2] = {};
    --    p_char.loadouts.loadouts_list[2].loadout = empty_loadout();
    --    default_loadout(p_char.loadouts.loadouts_list[2].loadout);
    --    p_char.loadouts.loadouts_list[2].loadout.default_target_lvl_diff = 0;
    --    p_char.loadouts.loadouts_list[2].loadout.name = "PVP";
    --    p_char.loadouts.loadouts_list[2].equipped = {};
    --    p_char.loadouts.loadouts_list[2].talented = {};
    --    p_char.loadouts.loadouts_list[2].final_effects = {};
    --    empty_effects(p_char.loadouts.loadouts_list[2].equipped);
    --    empty_effects(p_char.loadouts.loadouts_list[2].talented);
    --    empty_effects(p_char.loadouts.loadouts_list[2].final_effects);

    --    p_char.loadouts.num_loadouts = 2;
    --end

    sw_frame.loadout_frame.lhs_list.loadouts = {};
    for k, v in pairs(p_char.loadouts.loadouts_list) do
        sw_frame.loadout_frame.lhs_list.loadouts[k] = {};
        sw_frame.loadout_frame.lhs_list.loadouts[k].loadout = empty_loadout();
        for kk, vv in pairs(v.loadout) do
            -- for forward compatability: if there are changes to loadout in new version
            -- we copy what we can from the old loadout
            sw_frame.loadout_frame.lhs_list.loadouts[k].loadout[kk] = v.loadout[kk];
        end

        sw_frame.loadout_frame.lhs_list.loadouts[k].equipped = {};
        sw_frame.loadout_frame.lhs_list.loadouts[k].talented = {};
        sw_frame.loadout_frame.lhs_list.loadouts[k].final_effects = {};
        empty_effects(sw_frame.loadout_frame.lhs_list.loadouts[k].equipped);
        empty_effects(sw_frame.loadout_frame.lhs_list.loadouts[k].talented);
        empty_effects(sw_frame.loadout_frame.lhs_list.loadouts[k].final_effects);
    end

    sw_frame.loadout_frame.lhs_list.active_loadout = p_char.loadouts.active_loadout;
    sw_frame.loadout_frame.lhs_list.num_loadouts = p_char.loadouts.num_loadouts;

    update_loadouts_lhs();

    sw_frame.loadout_frame.lhs_list.loadouts[
        sw_frame.loadout_frame.lhs_list.active_loadout].check_button:SetChecked(true);

    if not p_char.sim_type or swc.core.use_char_defaults then
        sw_frame.calculator_frame.sim_type = simulation_type.spam_cast;
    else
        sw_frame.calculator_frame.sim_type = p_char.sim_type;
    end
    if sw_frame.calculator_frame.sim_type  == simulation_type.spam_cast then
        sw_frame.calculator_frame.spell_diff_header_right_spam_cast:Show();
        sw_frame.calculator_frame.spell_diff_header_right_cast_until_oom:Hide();
    elseif sw_frame.calculator_frame.sim_type  == simulation_type.cast_until_oom then
        sw_frame.calculator_frame.spell_diff_header_right_spam_cast:Hide();
        sw_frame.calculator_frame.spell_diff_header_right_cast_until_oom:Show();
    end
    sw_frame.calculator_frame.sim_type_button.init_func();

    if p_char.stat_comparison_spells and not swc.core.use_char_defaults then

        sw_frame.calculator_frame.spells = p_char.stat_comparison_spells;

        update_and_display_spell_diffs(active_loadout_and_effects_diffed_from_ui());
    end

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
ui.update_loadouts_rhs                  = update_loadouts_rhs;

swc.ui = ui;

