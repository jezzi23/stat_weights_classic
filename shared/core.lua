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

local _, swc                    = ...;

local utils                     = swc.utils;

local wowhead_talent_code       = swc.talents.wowhead_talent_code;

local spells                    = swc.abilities.spells;
local spell_flags               = swc.abilities.spell_flags;

local font                      = swc.ui.font;
local load_sw_ui                = swc.ui.load_sw_ui;
local create_sw_base_gui        = swc.ui.create_sw_base_gui;
local sw_activate_tab           = swc.ui.sw_activate_tab;
local update_loadouts_rhs       = swc.ui.update_loadouts_rhs;

local save_sw_settings          = swc.settings.save_sw_settings;

local reassign_overlay_icon     = swc.overlay.reassign_overlay_icon;
local update_overlay            = swc.overlay.update_overlay;

local update_tooltip            = swc.tooltip.update_tooltip;
local append_tooltip_spell_info = swc.tooltip.append_tooltip_spell_info;

local active_loadout            = swc.loadout.active_loadout;
local active_loadout_entry      = swc.loadout.active_loadout_entry;

-------------------------------------------------------------------------
local core                      = {};
swc.core                        = core;

core.sw_addon_name              = "Stat Weights Classic";

local version_id                = 30308;
core.version_id                 = version_id;
local version                   = tostring(version_id);
core.version                    = tonumber(version:sub(1, 1)) ..
    "." .. tonumber(version:sub(2, 3)) .. "." .. tonumber(version:sub(4, 5));

core.expansions                 = {
    vanilla = 1,
    tbc     = 2,
    wotlk   = 3
};

local client_build_version      = GetBuildInfo();
core.expansion_loaded           = tonumber(client_build_version:sub(1, 1));

core.sw_addon_loaded            = false;

core.client_deviation_flags     = {
    sod = bit.lshift(1, 0)
};

core.client_deviation           = 0;

if C_Engraving and C_Engraving.IsEngravingEnabled() then
    core.client_deviation = bit.bor(core.client_deviation, core.client_deviation_flags.sod);
end

sw_snapshot_loadout_update_freq = 1;
sw_num_icon_overlay_fields_active = 0;

core.talents_update_needed = true;
core.equipment_update_needed = true;
core.special_action_bar_changed = true;
core.setup_action_bar_needed = true;
core.update_action_bar_needed = true;
core.addon_message_on_update = false;

core.sequence_counter = 0;
core.addon_running_time = 0;

core.beacon_snapshot_time = -1000;
core.currently_casting_spell_id = 0;
core.cast_expire_timer = 0;
core.action_id_of_wand = 0;


local function class_supported()
    return utils.class == "MAGE" or utils.class == "PRIEST" or utils.class == "WARLOCK" or
        utils.class == "SHAMAN" or utils.class == "DRUID" or utils.class == "PALADIN";
end
local class_is_supported = class_supported();

local addon_msg_swc_id = "__SWC";

local function set_current_casting_spell(spell_id)
    if spells[spell_id] and bit.band(spells[spell_id].flags, spell_flags.mana_regen) == 0 then
        core.cast_expire_timer = math.max(2.5, 2 * spells[spell_id].cast_time);
        core.currently_casting_spell_id = spell_id;
    else
        core.currently_casting_spell_id = 0;
    end
end

local event_dispatch = {
    ["UNIT_SPELLCAST_SUCCEEDED"] = function(self, caster, _, spell_id)
        if caster == "player" then
            if spell_id == 53563 or spell_id == 407613 then -- beacon
                core.beacon_snapshot_time = core.addon_running_time;
            end
            set_current_casting_spell(spell_id);
        end
    end,
    ["UNIT_SPELLCAST_CHANNEL_START"] = function(self, caster, _, spell_id)
        if caster == "player" then
            set_current_casting_spell(spell_id);
        end
    end,
    ["UNIT_SPELLCAST_CHANNEL_STOP"] = function(self, caster, _, spell_id)
        if caster == "player" then
            core.currently_casting_spell_id = 0;
        end
    end,
    ["UNIT_SPELLCAST_START"] = function(self, caster, _, spell_id)
        if caster == "player" then
            set_current_casting_spell(spell_id);
        end
    end,
    ["UNIT_SPELLCAST_STOP"] = function(self, caster, _, spell_id)
        if caster == "player" then
            core.currently_casting_spell_id = 0;
        end
    end,
    ["ADDON_LOADED"] = function(self, msg, msg2, msg3)
        if msg == "StatWeightsClassic" then
            if __sw__persistent_data_per_char and __sw__persistent_data_per_char.settings and not __sw__persistent_data_per_char.settings.version_saved
                and core.expansion_loaded ~= core.expansions.wotlk then
                core.__sw__use_defaults__ = true;
            end
            load_sw_ui();
        end
    end,
    ["PLAYER_LOGOUT"] = function(self, msg, msg2, msg3)
        if core.__sw__use_defaults__ then
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
        swc.core.setup_action_bar_needed = true;
        core.sw_addon_loaded = true;

        if core.expansion_loaded == core.expansions.vanilla and C_Engraving.IsEngravingEnabled then
            --after fresh login the runes cannot be queried until
            --character frame has been opened!!!

            if CharacterFrame then
                ShowUIPanel(CharacterFrame);
                if CharacterFrameTab1 then
                    CharacterFrameTab1:Click();
                end
                HideUIPanel(CharacterFrame);
            end
        end
        C_ChatInfo.RegisterAddonMessagePrefix(addon_msg_swc_id)
        if core.__sw__debug__ or core.__sw__use_defaults__ or core.__sw__test_all_codepaths or core.__sw__test_all_spells then
            for i = 1, 10 do
                print("WARNING: SWC DEBUG TOOLS ARE ON!!!");
            end
        end
    end,
    ["ACTIONBAR_SLOT_CHANGED"] = function(self, msg, msg2, msg3)
        if not core.sw_addon_loaded then
            return;
        end

        reassign_overlay_icon(msg)
    end,
    ["UPDATE_STEALTH"] = function(self, msg, msg2, msg3)
        if not core.sw_addon_loaded then
            return;
        end
        core.special_action_bar_changed = true;
    end,
    ["UPDATE_BONUS_ACTIONBAR"] = function(self, msg, msg2, msg3)
        if not core.sw_addon_loaded then
            return;
        end

        core.special_action_bar_changed = true;
    end,
    ["ACTIONBAR_PAGE_CHANGED"] = function(self, msg, msg2, msg3)
        if not core.sw_addon_loaded then
            return;
        end

        core.special_action_bar_changed = true;
    end,
    ["UNIT_EXITED_VEHICLE"] = function(self, msg, msg2, msg3)
        if not core.sw_addon_loaded then
            return;
        end

        if msg == "player" then
            core.special_action_bar_changed = true;
        end
    end,
    ["ACTIVE_TALENT_GROUP_CHANGED"] = function(self, msg, msg2, msg3)
        core.update_action_bar_needed = true;
        core.talents_update_needed = true;
    end,
    ["CHARACTER_POINTS_CHANGED"] = function(self, msg)
        local loadout = active_loadout();

        if bit.band(loadout.flags, utils.loadout_flags.is_dynamic_loadout) ~= 0 then
            loadout.talents_code = wowhead_talent_code();
            core.talents_update_needed = true;
            update_loadouts_rhs();
        end
    end,
    ["PLAYER_EQUIPMENT_CHANGED"] = function(self, msg, msg2, msg3)
        core.equipment_update_needed = true;
    end,
    ["SOCKET_INFO_UPDATE"] = function(self, msg, msg2, msg3)
        core.equipment_update_needed = true;
    end,
    ["GLYPH_ADDED"] = function(self, msg, msg2, msg3)
        if bit.band(active_loadout_entry().loadout.flags, utils.loadout_flags.is_dynamic_loadout) ~= 0 then
            core.talents_update_needed = true;
        end
    end,
    ["GLYPH_REMOVED"] = function(self, msg, msg2, msg3)
        if bit.band(active_loadout_entry().loadout.flags, utils.loadout_flags.is_dynamic_loadout) ~= 0 then
            core.talents_update_needed = true;
        end
    end,
    ["GLYPH_UPDATED"] = function(self, msg, msg2, msg3)
        if bit.band(active_loadout_entry().loadout.flags, utils.loadout_flags.is_dynamic_loadout) ~= 0 then
            core.talents_update_needed = true;
        end
    end,
    ["ENGRAVING_MODE_CHANGED"] = function(self)
        core.equipment_update_needed = true;
    end,
    ["RUNE_UPDATED"] = function(self)
        core.equipment_update_needed = true;
    end,
};


local event_dispatch_client_exceptions = {
    ["ENGRAVING_MODE_CHANGED"] = core.expansions.vanilla,
    ["RUNE_UPDATED"]           = core.expansions.vanilla,
};

core.event_dispatch = event_dispatch;
core.event_dispatch_client_exceptions = event_dispatch_client_exceptions;


local timestamp = 0;

local pname = UnitName("player");

local function spell_tracking(dt)
    core.cast_expire_timer = core.cast_expire_timer - dt;
    if core.cast_expire_timer < 0.0 then
        core.currently_casting_spell_id = 0;
    end

    if core.action_id_of_wand ~= 0 then
        if IsAutoRepeatAction(core.action_id_of_wand) then
            set_current_casting_spell(5019);
        elseif core.currently_casting_spell_id == 5019 then
            core.currently_casting_spell_id = 0;
        end
    end
end

local function main_update()
    local dt = 1.0 / sw_snapshot_loadout_update_freq;

    local t = GetTime();

    local t_elapsed = t - timestamp;

    core.addon_running_time = core.addon_running_time + t_elapsed;

    spell_tracking(t_elapsed);

    update_overlay();
    if core.addon_message_on_update then
        C_ChatInfo.SendAddonMessage(addon_msg_swc_id, "UPDATE_TRIGGER", "WHISPER", pname);
    end

    core.sequence_counter = core.sequence_counter + 1;
    timestamp = t;

    C_Timer.After(dt, main_update);
end

local function refresh_tooltip()
    local dt = 0.1;
    if core.__sw__test_all_spells then
        dt = 0.01;
    end

    update_tooltip(GameTooltip);

    C_Timer.After(dt, refresh_tooltip);
end

if class_is_supported then
    create_sw_base_gui();

    C_Timer.After(1.0, main_update);
    C_Timer.After(1.0, refresh_tooltip);

    GameTooltip:HookScript("OnTooltipSetSpell", function(_, is_fake)
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
    str:SetText("Stats Weights Classic - Version " .. core.version);

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

    if not class_is_supported then
        str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
        str:SetFontObject(font);
        str:SetPoint("TOPLEFT", x_offset, y_offset);
        str:SetText("This addon only loads for caster classes. Sorry!");
        return;
    end

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
    str:SetText("/swc");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/swc conf");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/swc loadouts");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/swc calc");

    y_offset = y_offset - 15;
    x_offset = x_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Hard reset: /swc reset");
end

local function command(msg, editbox)
    if class_is_supported then
        if msg == "print" then
            --print_loadout(active_loadout_and_effects());
        elseif msg == "loadout" or msg == "loadouts" then
            sw_activate_tab(2);
        elseif msg == "settings" or msg == "opt" or msg == "options" or msg == "conf" or msg == "configure" then
            sw_activate_tab(1);
        elseif msg == "compare" or msg == "sc" or msg == "stat compare" or msg == "stat" or msg == "calc" or msg == "calculator" then
            sw_activate_tab(3);
        elseif msg == "reset" then
            core.__sw__use_defaults__ = 1;
            ReloadUI();
        else
            sw_activate_tab(2);
        end
    end
end

SLASH_STAT_WEIGHTS1 = "/sw"
SLASH_STAT_WEIGHTS2 = "/stat-weights"
SLASH_STAT_WEIGHTS3 = "/stat-weights-classic"
SLASH_STAT_WEIGHTS3 = "/statweightsclassic"
SLASH_STAT_WEIGHTS4 = "/swc"
SlashCmdList["STAT_WEIGHTS"] = command

swc.ext.enable_addon_message_on_update = function()
    core.addon_message_on_update = true;
end
swc.ext.disable_addon_message_on_update = function()
    core.addon_message_on_update = false;
end
swc.ext.version_id = core.version_id;

__SWC = swc.ext;

--core.__sw__debug__ = 1;
--core.__sw__use_defaults__ = 1;
--core.__sw__test_all_codepaths = 1;
--core.__sw__test_all_spells = 1;
