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

local class                                 = addonTable.class;
local race                                  = addonTable.race;
local faction                               = addonTable.faction;
local ensure_exists_and_add                 = addonTable.ensure_exists_and_add;
local ensure_exists_and_mul                 = addonTable.ensure_exists_and_mul;
local deep_table_copy                       = addonTable.deep_table_copy;
local stat                                  = addonTable.stat;
local loadout_flags                         = addonTable.loadout_flags;

local glyphs                                = addonTable.glyphs;
local wowhead_talent_link                   = addonTable.wowhead_talent_link;
local wowhead_talent_code_from_url          = addonTable.wowhead_talent_code_from_url;
local wowhead_talent_code                   = addonTable.wowhead_talent_code;

local font                                  = addonTable.font;
local load_sw_ui                            = addonTable.load_sw_ui;
local create_sw_base_gui                    = addonTable.create_sw_base_gui;
local sw_activate_tab                       = addonTable.sw_activate_tab;
local update_loadouts_rhs                   = addonTable.update_loadouts_rhs;

local save_sw_settings                      = addonTable.save_sw_settings;

local reassign_overlay_icon                 = addonTable.reassign_overlay_icon;
local setup_action_bars                     = addonTable.setup_action_bars;
local update_overlay                        = addonTable.update_overlay;
local update_tooltip                        = addonTable.update_tooltip;

local append_tooltip_spell_info             = addonTable.append_tooltip_spell_info;

local active_loadout                        = addonTable.active_loadout;
local active_loadout_entry                  = addonTable.active_loadout_entry;
local active_loadout_and_effects            = addonTable.active_loadout_and_effects;

-------------------------------------------------------------------------
addonTable.sw_addon_name = "Stat Weights Classic";
addonTable.version =  "3.0.6";

addonTable.sw_addon_loaded = false;

local action_bar_addon_name = nil;
local spell_book_addon_name = nil;

sw_snapshot_loadout_update_freq = 1;
sw_num_icon_overlay_fields_active = 0;

addonTable.talents_update_needed = true;
addonTable.equipment_update_needed = true;
addonTable.special_action_bar_changed = true;
addonTable.setup_action_bar_needed = true;
addonTable.sequence_counter = 0;

local snapshot_time_since_last_update = 0;

local function class_supported()
    return class == "MAGE" or class == "PRIEST" or class == "WARLOCK" or
       class == "SHAMAN" or class == "DRUID" or class == "PALADIN";
end
local class_is_supported = class_supported();

local event_dispatch = {
    ["UNIT_SPELLCAST_SUCCEEDED"] = function(self, msg, msg2, msg3)
        if msg3 == 53563 then  -- beacon
             addonTable.beacon_snapshot_time = addonTable.addon_running_time;
        end
    end,
    ["ADDON_LOADED"] = function(self, msg, msg2, msg3)
        if msg == "StatWeightsClassic" then
            load_sw_ui();
        end
    end,
    ["PLAYER_LOGOUT"] = function(self, msg, msg2, msg3)
        if addonTable.__sw__use_defaults__ then
            __sw__persistent_data_per_char = nil;
            return;
        end

        -- clear previous ui elements from spells table
        __sw__persistent_data_per_char.stat_comparison_spells = {};
        for k, v in pairs(self.stat_comparison_frame.spells) do
            __sw__persistent_data_per_char.stat_comparison_spells[k] = {};
            __sw__persistent_data_per_char.stat_comparison_spells[k].name = v.name;
        end
        __sw__persistent_data_per_char.sim_type = self.stat_comparison_frame.sim_type;

        __sw__persistent_data_per_char.loadouts = {};
        __sw__persistent_data_per_char.loadouts.loadouts_list = {};
        for k, v in pairs(self.loadouts_frame.lhs_list.loadouts) do
            __sw__persistent_data_per_char.loadouts.loadouts_list[k] = {};
            __sw__persistent_data_per_char.loadouts.loadouts_list[k].loadout = v.loadout;
            __sw__persistent_data_per_char.loadouts.loadouts_list[k].equipped = v.equipped;
        end
        __sw__persistent_data_per_char.loadouts.active_loadout = self.loadouts_frame.lhs_list.active_loadout;
        __sw__persistent_data_per_char.loadouts.num_loadouts = self.loadouts_frame.lhs_list.num_loadouts;

        -- save settings from ui
        save_sw_settings();
    end,
    ["PLAYER_LOGIN"] = function(self, msg, msg2, msg3)

        setup_action_bars();
        addonTable.sw_addon_loaded = true;
    end,
    ["ACTIONBAR_SLOT_CHANGED"] = function(self, msg, msg2, msg3)
        if not addonTable.sw_addon_loaded then
            return;
        end

        reassign_overlay_icon(msg)
    end,
    ["UPDATE_STEALTH"] = function(self, msg, msg2, msg3)
        if not addonTable.sw_addon_loaded then
            return;
        end
        addonTable.special_action_bar_changed = true;
    end,
    -- NOTE: Some bug is causing this event to be spammed even if no shapeshifts
    --       of any sort are taking place
    --["UPDATE_SHAPESHIFT_FORM"] = function(self, msg, msg2, msg3)
    --end,
    ["UPDATE_BONUS_ACTIONBAR"] = function(self, msg, msg2, msg3)
        if not addonTable.sw_addon_loaded then
            return;
        end

        addonTable.special_action_bar_changed = true;
    end,
    --["ACTIONBAR_UPDATE_STATE"] = function(self, msg, msg2, msg3)
    --    -- test
    --end,
    --["UNIT_AURA"] = function(self, msg, msg2, msg3)
    --    if msg == "player" or msg == "target" or msg == "mouseover" then
    --        buffs_update_needed = true;
    --    end
    --end,
    --["PLAYER_TARGET_CHANGED"] = function(self, msg, msg2, msg3)
    --    buffs_update_needed = true;
    --end,
    ["ACTIVE_TALENT_GROUP_CHANGED"] = function(self, msg, msg2, msg3)
        if addonTable.sw_addon_loaded  then
            for k, v in pairs(__sw__icon_frames.bars) do
                for i = 1, 3 do
                    if v.overlay_frames[i] then
                        v.overlay_frames[i]:Hide();
                    end
                end

            end
        end
        addonTable.setup_action_bar_needed = true;
        if bit.band(active_loadout_entry().loadout.flags, loadout_flags.is_dynamic_loadout) ~= 0 then
            addonTable.talents_update_needed = true;
        end
    end,
    ["CHARACTER_POINTS_CHANGED"] = function(self, msg)

        local loadout = active_loadout();
       
        if bit.band(loadout.flags, loadout_flags.is_dynamic_loadout) ~= 0 then

            loadout.talents_code = wowhead_talent_code();
            addonTable.talents_update_needed = true;
            update_loadouts_rhs();
        end
    end,
    ["PLAYER_EQUIPMENT_CHANGED"] = function(self, msg, msg2, msg3)
        addonTable.equipment_update_needed = true;
    end,
    ["SOCKET_INFO_UPDATE"] = function(self, msg, msg2, msg3)
        addonTable.equipment_update_needed = true;
    end,
    ["GLYPH_ADDED"] = function(self, msg, msg2, msg3)

        if bit.band(active_loadout_entry().loadout.flags, loadout_flags.is_dynamic_loadout) ~= 0 then
            addonTable.talents_update_needed = true;
        end
    end,
    ["GLYPH_REMOVED"] = function(self, msg, msg2, msg3)
        if bit.band(active_loadout_entry().loadout.flags, loadout_flags.is_dynamic_loadout) ~= 0 then
            addonTable.talents_update_needed = true;
        end
    end,
    ["GLYPH_UPDATED"] = function(self, msg, msg2, msg3)
        if bit.band(active_loadout_entry().loadout.flags, loadout_flags.is_dynamic_loadout) ~= 0 then
            addonTable.talents_update_needed = true;
        end
    end,
};

addonTable.event_dispatch = event_dispatch;

if class_is_supported then
    create_sw_base_gui();

    UIParent:HookScript("OnUpdate", function(self, elapsed)
    
        addonTable.addon_running_time = addonTable.addon_running_time + elapsed;
        snapshot_time_since_last_update = snapshot_time_since_last_update + elapsed;

        if snapshot_time_since_last_update > 1/sw_snapshot_loadout_update_freq then

            update_tooltip(GameTooltip);
            update_overlay();

            addonTable.sequence_counter = addonTable.sequence_counter + 1;
            snapshot_time_since_last_update = 0;
        end

    end)

    GameTooltip:HookScript("OnTooltipSetSpell", function(tooltip, is_fake, ...)
        append_tooltip_spell_info(is_fake);
    end)

else
    --print("Stat Weights Classic currently does not support your class :(");
end

-- add addon to Addons list under Interface
if InterfaceOptions_AddCategory then

    local addon_interface_panel = CreateFrame("FRAME");
    addon_interface_panel.name = "Stat Weights Classic";
    InterfaceOptions_AddCategory(addon_interface_panel);


    local y_offset = -20;
    local x_offset = 20;

    local str = "";
    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Stats Weights Classic - Version"..addonTable.version);

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Project Page: https://www.curseforge.com/wow/addons/stat-weights-classic");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Author: jezzi23");

    y_offset = y_offset - 30;

    addon_interface_panel.open_sw_frame_button = 
        CreateFrame("Button", "sw_addon_interface_open_frame_button", addon_interface_panel, "UIPanelButtonTemplate"); 

    addon_interface_panel.open_sw_frame_button:SetPoint("TOPLEFT", x_offset, y_offset);
    addon_interface_panel.open_sw_frame_button:SetWidth(150);
    addon_interface_panel.open_sw_frame_button:SetHeight(25);
    addon_interface_panel.open_sw_frame_button:SetText("Open Addon Frame");
    addon_interface_panel.open_sw_frame_button:SetScript("OnClick", function()
        sw_activate_tab(1);
    end);

    y_offset = y_offset - 30;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Or type any of the following:");

    y_offset = y_offset - 15;
    x_offset = x_offset + 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sw");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sw conf");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sw loadouts");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sw stat");
    
end

local function command(msg, editbox)
    if class_is_supported then
        if msg == "print" then
            print_loadout(active_loadout_and_effects());
        elseif msg == "loadout" or msg == "loadouts" then
            sw_activate_tab(2);
        elseif msg == "settings" or msg == "opt" or msg == "options" or msg == "conf" or msg == "configure" then
            sw_activate_tab(1);
        elseif msg == "compare" or msg == "sc" or msg == "stat compare"  or msg == "stat" then
            sw_activate_tab(3);
        elseif msg == "reset" then

            addonTable.__sw__use_defaults__ = 1;
            ReloadUI();

        else
            sw_activate_tab(3);
        end
    end
end

SLASH_STAT_WEIGHTS1 = "/sw"
SLASH_STAT_WEIGHTS2 = "/stat-weights"
SLASH_STAT_WEIGHTS3 = "/stat-weights-classic"
SLASH_STAT_WEIGHTS3 = "/statweightsclassic"
SLASH_STAT_WEIGHTS4 = "/swc"
SlashCmdList["STAT_WEIGHTS"] = command

--addonTable.__sw__debug__ = 1;
--addonTable.__sw__use_defaults__ = 1;
