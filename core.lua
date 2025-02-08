local _, sc                    = ...;

local wowhead_talent_code       = sc.talents.wowhead_talent_code;

local spells                    = sc.abilities.spells;
local spell_flags               = sc.abilities.spell_flags;

local font                      = sc.ui.font;
local load_sw_ui                = sc.ui.load_sw_ui;
local create_sw_base_ui         = sc.ui.create_sw_base_ui;
local sw_activate_tab           = sc.ui.sw_activate_tab;
local update_buffs_frame        = sc.ui.update_buffs_frame;
local update_profile_frame      = sc.ui.update_profile_frame;
local update_loadout_frame      = sc.ui.update_loadout_frame;

local config                    = sc.config;
local load_config               = sc.config.load_config;
local save_config               = sc.config.save_config;
local set_active_settings       = sc.config.set_active_settings;
local set_active_loadout        = sc.config.set_active_loadout;
local activate_settings         = sc.config.activate_settings;
local activate_loadout_config   = sc.config.activate_loadout_config;


local reassign_overlay_icon     = sc.overlay.reassign_overlay_icon;
local update_overlay            = sc.overlay.update_overlay;

local update_tooltip            = sc.tooltip.update_tooltip;
local tooltip_spell_info        = sc.tooltip.tooltip_spell_info;

-------------------------------------------------------------------------
local core                      = {};
sc.core                        = core;

core.sw_addon_name              = "SpellCoda";

--local version_id              = 10000;
--local version_id                = 00101;
local version_id                = 30309;
core.version_id                 = version_id;
local version                   = tostring(version_id);
core.version                    = (tonumber(version:sub(1, 1)) or 0) ..
    "." .. (tonumber(version:sub(2, 3)) or 0) .. "." .. (tonumber(version:sub(4, 5)) or 0);

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

core.talents_update_needed = true;
core.equipment_update_needed = true;
core.special_action_bar_changed = true;
core.setup_action_bar_needed = true;
core.update_action_bar_needed = false;
core.addon_message_on_update = false;
core.old_ranks_checks_needed = true;

core.sequence_counter = 0;
core.addon_running_time = 0;
core.active_spec = 1;

core.beacon_snapshot_time = -1000;
core.currently_casting_spell_id = 0;
core.cast_expire_timer = 0;
core.action_id_of_wand = 0;


local function class_supported()
    --return utils.class == "MAGE" or utils.class == "PRIEST" or utils.class == "WARLOCK" or
    --    utils.class == "SHAMAN" or utils.class == "DRUID" or utils.class == "PALADIN";
    return true;
end
local class_is_supported = class_supported();

local addon_msg_sc_id = "__SC";

local function set_current_casting_spell(spell_id)
    if spells[spell_id] and bit.band(spells[spell_id].flags, spell_flags.eval) ~= 0 then
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
    ["UNIT_SPELLCAST_CHANNEL_START"] = function(_, caster, _, spell_id)
        if caster == "player" then
            set_current_casting_spell(spell_id);
        end
    end,
    ["UNIT_SPELLCAST_CHANNEL_STOP"] = function(_, caster, _, spell_id)
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
    ["ADDON_LOADED"] = function(_, arg)
        if arg == "SpellCoda" then
            load_config();
            core.active_spec = GetActiveTalentGroup();
            set_active_settings();
            set_active_loadout(__sc_p_char.active_loadout);
            load_sw_ui();
            activate_settings();
            activate_loadout_config();
            update_profile_frame()
            update_loadout_frame();
        end

    end,
    ["PLAYER_LOGOUT"] = function()
        save_config();
    end,
    ["PLAYER_LOGIN"] = function()
        core.setup_action_bar_needed = true;
        core.sw_addon_loaded = true;
        -- Don't do this in case this was causing "prevented from a forbidden action" type of bug
        --table.insert(UISpecialFrames, __sc_frame:GetName()) -- Allows ESC to close frame
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
        sc.ui.add_spell_book_button();
        C_ChatInfo.RegisterAddonMessagePrefix(addon_msg_sc_id)
        if core.__sw__debug__ or core.use_char_defaults or core.__sw__test_all_codepaths or core.__sw__test_all_spells then
            for i = 1, 10 do
                print("WARNING: SC DEBUG TOOLS ARE ON!!!");
            end
        end

    end,
    ["ACTIONBAR_SLOT_CHANGED"] = function(_, arg)
        if not core.sw_addon_loaded or config.settings.overlay_disable then
            return;
        end

        reassign_overlay_icon(arg)
    end,
    ["UPDATE_STEALTH"] = function()
        if not core.sw_addon_loaded then
            return;
        end
        core.special_action_bar_changed = true;
    end,
    ["UPDATE_BONUS_ACTIONBAR"] = function()
        if not core.sw_addon_loaded then
            return;
        end

        core.special_action_bar_changed = true;
    end,
    ["ACTIONBAR_PAGE_CHANGED"] = function()
        if not core.sw_addon_loaded then
            return;
        end

        core.special_action_bar_changed = true;
    end,
    ["UNIT_EXITED_VEHICLE"] = function(_, arg)
        if not core.sw_addon_loaded or config.settings.overlay_disable then
            return;
        end

        if arg == "player" then
            core.special_action_bar_changed = true;
        end
    end,
    ["ACTIVE_TALENT_GROUP_CHANGED"] = function()

        core.active_spec = GetActiveTalentGroup();
        set_active_settings()
        activate_settings();
        core.update_action_bar_needed = true;
        core.talents_update_needed = true;
        update_profile_frame();
    end,
    ["CHARACTER_POINTS_CHANGED"] = function()

        set_active_settings();
        activate_settings();
        if not config.loadout.use_custom_talents then
            config.loadout.talents_code = wowhead_talent_code();
            core.talents_update_needed = true;
            update_buffs_frame();
        end
    end,
    ["PLAYER_EQUIPMENT_CHANGED"] = function()
        core.equipment_update_needed = true;
    end,
    ["PLAYER_LEVEL_UP"] = function()
        core.old_ranks_checks_needed = true;
    end,
    ["LEARNED_SPELL_IN_TAB"] = function()
        core.old_ranks_checks_needed = true;
    end,
    ["SOCKET_INFO_UPDATE"] = function()
        core.equipment_update_needed = true;
    end,
    ["GLYPH_ADDED"] = function()
        if not config.loadout.use_custom_talents then
            core.talents_update_needed = true;
        end
    end,
    ["GLYPH_REMOVED"] = function()
        if not config.loadout.use_custom_talents then
            core.talents_update_needed = true;
        end
    end,
    ["GLYPH_UPDATED"] = function()
        if not config.loadout.use_custom_talents then
            core.talents_update_needed = true;
        end
    end,
    ["CHAT_MSG_SKILL"] = function()
        core.talents_update_needed = true;
    end,
    ["ENGRAVING_MODE_CHANGED"] = function()
        core.equipment_update_needed = true;
    end,
    ["RUNE_UPDATED"] = function()
        core.equipment_update_needed = true;
    end,
    ["PLAYER_REGEN_DISABLED"] = function()
        -- Currently only registered when in Hardcore mode
        -- Hide addon UI when in combat
        __sc_frame:Hide();
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
    local dt = 1.0 / sc.config.settings.overlay_update_freq;

    local t = GetTime();

    local t_elapsed = t - timestamp;

    core.addon_running_time = core.addon_running_time + t_elapsed;

    spell_tracking(t_elapsed);

    update_overlay();
    if core.addon_message_on_update then
        C_ChatInfo.SendAddonMessage(addon_msg_sc_id, "UPDATE_TRIGGER", "WHISPER", pname);
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
    create_sw_base_ui();

    C_Timer.After(1.0, main_update);
    C_Timer.After(1.0, refresh_tooltip);

    GameTooltip:HookScript("OnTooltipSetSpell", function(_, is_fake)
        tooltip_spell_info(is_fake);
    end)
else
    --print("SpellCoda currently does not support your class :(");
end

-- add addon to Addons list under Interface
if InterfaceOptions_AddCategory then
    local addon_interface_panel = CreateFrame("FRAME");
    addon_interface_panel.name = "SpellCoda";
    InterfaceOptions_AddCategory(addon_interface_panel);


    local y_offset = -20;
    local x_offset = 20;

    local str = "";
    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("SpellCoda - Version " .. core.version);

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Project Page: https://www.curseforge.com/wow/addons/spellcoda");

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

    addon_interface_panel.open___sc_frame_button =
        CreateFrame("Button", "sw_addon_interface_open_frame_button", addon_interface_panel, "UIPanelButtonTemplate");

    addon_interface_panel.open___sc_frame_button:SetPoint("TOPLEFT", x_offset, y_offset);
    addon_interface_panel.open___sc_frame_button:SetWidth(150);
    addon_interface_panel.open___sc_frame_button:SetHeight(25);
    addon_interface_panel.open___sc_frame_button:SetText("Open Addon Frame");
    addon_interface_panel.open___sc_frame_button:SetScript("OnClick", function()
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
    str:SetText("/sc");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sc conf");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sc loadouts");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sc calc");

    y_offset = y_offset - 15;
    x_offset = x_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Hard reset: /sc reset");
end

local function command(arg)
    arg = string.lower(arg);

    if arg == "spell" or arg == "spells" then
        sw_activate_tab(__sc_frame.tabs[1]);
    elseif arg == "settings" or arg == "opt" or arg == "options" or arg == "conf" or arg == "configure"  or "tooltip" then
        sw_activate_tab(__sc_frame.tabs[2]);
    elseif arg == "overlay" then
        sw_activate_tab(__sc_frame.tabs[3]);
    elseif arg == "compare" or arg == "stat" or arg == "calc" or arg == "calculator" then
        sw_activate_tab(__sc_frame.tabs[4]);
    elseif arg == "profile" or arg == "profiles" then
        sw_activate_tab(__sc_frame.tabs[5]);
    elseif arg == "loadout" or arg == "loadouts" then
        sw_activate_tab(__sc_frame.tabs[6]);
    elseif arg == "buffs" or arg == "auras" then
        sw_activate_tab(__sc_frame.tabs[7]);
    elseif arg == "reset" then
        core.use_char_defaults = 1;
        core.use_acc_defaults = 1;
        ReloadUI();
    else
        sw_activate_tab(__sc_frame.tabs[1]);
    end
end

SLASH_SPELL_CODA1 = "/sc"
SLASH_SPELL_CODA3 = "/SC"
SLASH_SPELL_CODA2 = "/spellcoda"
SLASH_SPELL_CODA3 = "/SpellCoda"
SlashCmdList["SPELL_CODA"] = command

sc.ext.enable_addon_message_on_update = function()
    core.addon_message_on_update = true;
end
sc.ext.disable_addon_message_on_update = function()
    core.addon_message_on_update = false;
end
sc.ext.version_id = core.version_id;

__SC = sc.ext;

--core.__sw__debug__ = 1;
--core.sc.core.use_char_defaults = 1;
--core.__sw__test_all_codepaths = 1;
--core.__sw__test_all_spells = 1;
