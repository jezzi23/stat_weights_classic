local _, sc                    = ...;

local spells                    = sc.spells;
local spell_flags               = sc.spell_flags;

local font                      = sc.ui.font;
local load_sw_ui                = sc.ui.load_sw_ui;
local create_sw_base_ui         = sc.ui.create_sw_base_ui;
local sw_activate_tab           = sc.ui.sw_activate_tab;
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
local write_spell_tooltip       = sc.tooltip.write_spell_tooltip;
local write_item_tooltip        = sc.tooltip.write_item_tooltip;
local on_clear_tooltip          = sc.tooltip.on_clear_tooltip;
local on_show_tooltip           = sc.tooltip.on_show_tooltip;

-------------------------------------------------------------------------
local core                      = {};
sc.core                         = core;

core.addon_name                 = "SpellCoda";

local version_major             = 0;
local version_minor             = 1;
local version_build             = sc.addon_build_id;

core.version_id                 = version_build + version_minor*1000 + version_major*1000000;
core.version                    = tostring(version_major) .. "." ..
                                  tostring(version_minor) .. "." ..
                                  tostring(version_build);

core.sw_addon_loaded            = false;

sc.sequence_counter             = 0;
core.addon_running_time         = 0;
core.active_spec                = 1;

core.talents_update_needed      = true;
core.equipment_update_needed    = true;
core.special_action_bar_changed = true;
core.setup_action_bar_needed    = true;
core.update_action_bar_needed   = false;
core.addon_message_on_update    = false;
core.old_ranks_checks_needed    = true;
core.rescan_action_bar_needed   = false;


core.beacon_snapshot_time       = -1000;
core.currently_casting_spell_id = 0;
core.cast_expire_timer          = 0;
core.action_id_of_wand          = 0;

local addon_msg_sc_id = "__SpellCoda";

local function generated_data_is_outdated(loaded_version, gen_version)
    local loaded = string.gmatch(loaded_version, "[^.]+");
    local gen = string.gmatch(gen_version, "[^.]+");
    for _ = 1, 4 do
        local l = loaded();
        local g = gen();
        if l and g then
            local l_num = tonumber(l);
            local g_num = tonumber(g);
            if g_num < l_num then
                return true;
            end
        end
    end
    return false;
end

local function client_age_days()
    local months = { Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6,
        Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12
    };

    local client_month_str, client_day, client_year = sc.client_date_loaded:match("(%a+) (%d+) (%d+)");
    local month_str, day, year = date("%b %d %Y"):match("(%a+) (%d+) (%d+)");
    if not client_month_str or not client_day or not client_year or not month_str or not day or not year then
        return 0;
    end
    local client_month = months[client_month_str] or 1;
    local month = months[month_str] or 1;

    local client_build_time = time({year = tonumber(client_year), month = client_month, day = tonumber(client_day)});
    local now = time({year = tonumber(year), month = month, day = tonumber(day)});

    local diff_seconds = math.abs(now - client_build_time);
    local diff_days = diff_seconds / 86400;

    return diff_days;
end

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
        -- force setup action bar to hook scroll script
        -- even if overlays are disabled
        sc.overlay.setup_action_bars();
        core.sw_addon_loaded = true;
        table.insert(UISpecialFrames, __sc_frame:GetName()) -- Allows ESC to close frame
        if sc.expansion == sc.expansions.vanilla and C_Engraving.IsEngravingEnabled then
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
        sc.ui.add_to_options();
        C_ChatInfo.RegisterAddonMessagePrefix(addon_msg_sc_id);
        if core.__sw__debug__ or core.__sw__test_all_codepaths or core.__sw__test_all_spells then
            print("WARNING: SC DEBUG TOOLS ARE ON!!!");
            for _ = 1, 10 do
                print("WARNING: SC DEBUG TOOLS ARE ON!!!");
            end
            local num_spells = 0;
            for _, _ in pairs(sc.spells) do
                num_spells = num_spells + 1;
            end
            print("Spells in data:", num_spells);
        end
        -- don't warn about updates when build is relatively fresh
        local version_warning_build_threshold_days = 3;
        if core.__sw__debug__ then
            version_warning_build_threshold_days = 0;
        end
        if config.settings.general_version_mismatch_notify and
            generated_data_is_outdated(sc.client_version_loaded, sc.client_version_src) and
            client_age_days() > version_warning_build_threshold_days then
            print(core.addon_name..": detected client and addon data mismatch. Consider checking for an update.");
        end

    end,
    ["ACTIONBAR_SLOT_CHANGED"] = function(_, slot)
        if not core.sw_addon_loaded or config.settings.overlay_disable then
            return;
        end

        core.rescan_action_bar_needed = true;
        reassign_overlay_icon(slot);
        sc.loadouts.force_update = true;
    end,
    ["UPDATE_STEALTH"] = function()
        if not core.sw_addon_loaded then
            return;
        end
        core.special_action_bar_changed = true;
        sc.loadouts.force_update = true;
    end,
    ["UPDATE_BONUS_ACTIONBAR"] = function()
        if not core.sw_addon_loaded then
            return;
        end

        core.special_action_bar_changed = true;
        sc.loadouts.force_update = true;
    end,
    ["ACTIONBAR_PAGE_CHANGED"] = function()
        if not core.sw_addon_loaded then
            return;
        end

        core.special_action_bar_changed = true;
        sc.loadouts.force_update = true;
    end,
    ["UNIT_EXITED_VEHICLE"] = function(_, arg)
        if not core.sw_addon_loaded or config.settings.overlay_disable then
            return;
        end

        if arg == "player" then
            core.special_action_bar_changed = true;
            sc.loadouts.force_update = true;
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

        sc.loadouts.force_update = true;
        set_active_settings();
        activate_settings();
        if not config.loadout.use_custom_talents then
            core.talents_update_needed = true;
            update_loadout_frame();
        end
    end,
    ["PLAYER_EQUIPMENT_CHANGED"] = function()
        core.equipment_update_needed = true;
    end,
    ["PLAYER_LEVEL_UP"] = function()
        core.old_ranks_checks_needed = true;
        sc.loadouts.force_update = true;
    end,
    ["LEARNED_SPELL_IN_TAB"] = function()
        core.old_ranks_checks_needed = true;
        sc.loadouts.force_update = true;
    end,
    ["SOCKET_INFO_UPDATE"] = function()
        core.equipment_update_needed = true;
        sc.loadouts.force_update = true;
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
    ["ENGRAVING_MODE_CHANGED"] = sc.expansions.vanilla,
    ["RUNE_UPDATED"]           = sc.expansions.vanilla,
};

core.event_dispatch = event_dispatch;
core.event_dispatch_client_exceptions = event_dispatch_client_exceptions;



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

local timestamp = 0.0;

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

    sc.sequence_counter = sc.sequence_counter + 1;
    timestamp = t;

    C_Timer.After(dt, main_update);
end

local function key_mod_flags()

    local mod = 0;
    if IsAltKeyDown() then
        mod = bit.bor(mod, sc.tooltip_mod_flags.ALT);
    end
    if IsControlKeyDown() then
        mod = bit.bor(mod, sc.tooltip_mod_flags.CTRL);
    end
    if IsShiftKeyDown() then
        mod = bit.bor(mod, sc.tooltip_mod_flags.SHIFT);
    end
    mod = bit.bor(mod, bit.lshift(sc.tooltip.eval_mode, 3));

    return mod;
end

local tooltip_timestamp = 0.0;
sc.tooltip_mod = 0;
sc.tooltip_mod_flags = {
    ALT =   bit.lshift(1, 0),
    CTRL =  bit.lshift(1, 1),
    SHIFT = bit.lshift(1, 2),
};

local tooltip_time = 1.0/2.0;

local function refresh_tooltip()
    local dt = 0.1;
    if config.settings.tooltip_disable then

        C_Timer.After(dt, refresh_tooltip);
        return;
    end
    local mod = key_mod_flags();
    if core.__sw__test_all_spells then
        dt = 0.01;
        sc.tooltip_mod = mod;
        update_tooltip(GameTooltip, true);
    else
        local t = GetTime();
        local t_elapsed = t - tooltip_timestamp;
        if t_elapsed > tooltip_time or sc.tooltip_mod ~= mod then
            update_tooltip(GameTooltip, sc.tooltip_mod ~= mod);
            sc.tooltip_mod = mod;
            tooltip_timestamp = t;
        end
    end

    C_Timer.After(dt, refresh_tooltip);
end

create_sw_base_ui();

C_Timer.After(1.0, main_update);
C_Timer.After(1.0, refresh_tooltip);

GameTooltip:HookScript("OnTooltipSetSpell", function()
    if not config.settings.tooltip_disable then
        sc.tooltip_mod = key_mod_flags()
        write_spell_tooltip();
    end
end);

local item_tooltip_mod = 0;
GameTooltip:HookScript("OnTooltipSetItem", function(self)
    if not config.settings.tooltip_disable_item then
        local mod = key_mod_flags();
        local mod_change = mod ~= item_tooltip_mod;
        item_tooltip_mod = mod;
        write_item_tooltip(self, mod, mod_change);
    end
end);

hooksecurefunc(ItemRefTooltip, "SetHyperlink", function(self, link)
    if not config.settings.tooltip_disable_item then
        local mod = key_mod_flags();
        local mod_change = mod ~= item_tooltip_mod;
        item_tooltip_mod = mod;
        write_item_tooltip(self, mod, mod_change, link);
    end
end);

GameTooltip:HookScript("OnTooltipCleared", function(self)
    on_clear_tooltip(self);
end);
ItemRefTooltip:HookScript("OnTooltipCleared", function(self)
    on_clear_tooltip(self);
end);
GameTooltip:HookScript("OnShow", function(self)
    on_show_tooltip(self);
end);


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
    elseif arg == "tooltip" then
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
    elseif arg == "settings" or arg == "opt" or arg == "options" or arg == "conf" or arg == "configure" then
        sw_activate_tab(__sc_frame.tabs[8]);
    elseif string.find(arg, "force set") then
        local substrs = {};
        for s in arg:gmatch("%S+") do
            table.insert(substrs, s);
        end
        local set_id = tonumber(substrs[3]);
        local num_pieces = tonumber(substrs[4]);
        if set_id and num_pieces then
            core.equipment_update_needed = true;
            sc.equipment.force_item_sets[set_id] = num_pieces;
        end
        print(string.format("Forcing item set %d to have %d pieces", set_id, num_pieces));
    elseif string.find(arg, "force item") then
        local substrs = {};
        for s in arg:gmatch("%S+") do
            table.insert(substrs, s);
        end
        local item_id = tonumber(substrs[3]);
        if item_id then
            core.equipment_update_needed = true;
            sc.equipment.force_items[item_id] = item_id;
        end
        print(string.format("Forcing item %d", item_id));
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
--core.__sw__test_all_codepaths = 1;
--core.__sw__test_all_spells = 1;
