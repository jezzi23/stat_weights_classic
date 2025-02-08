local _, swc               = ...;

local config               = {};

local spell_filter_options = {
    spells_filter_already_known     = true,
    spells_filter_available         = true,
    spells_filter_unavailable       = true,
    spells_filter_learned_from_item = true,
    spells_filter_pet               = true,
    spells_filter_ignored_spells    = false,
    spells_filter_other_spells      = false,
};

-- Avoiding all bit flags here simply any changes between versions
local default_settings     = {
    -- tooltip
    tooltip_display_addon_name        = true,
    tooltip_display_loadout_info      = true,
    tooltip_display_spell_rank        = false,
    tooltip_display_hit               = true,
    tooltip_display_normal            = false,
    tooltip_display_crit              = false,
    tooltip_display_expected          = true,
    tooltip_display_effect_per_sec    = true,
    tooltip_display_effect_per_cost   = true,
    tooltip_display_cost_per_sec      = false,
    tooltip_display_stat_weights_dps  = false,
    tooltip_display_stat_weights_doom = false,
    tooltip_display_avg_cost          = false,
    tooltip_display_avg_cast          = false,
    tooltip_display_cast_until_oom    = false,
    tooltip_display_cast_and_tap      = false,
    tooltip_display_sp_effect_calc    = false,
    tooltip_display_sp_effect_ratio   = false,
    tooltip_display_base_mod          = false,
    tooltip_display_spell_id          = false,
    tooltip_display_dynamic_tip       = true,

    tooltip_disable                   = false,
    tooltip_shift_to_show             = false,
    tooltip_clear_original            = false,

    -- overlay
    overlay_display_normal            = false,
    overlay_display_crit              = false,
    overlay_display_expected          = false,
    overlay_display_effect_per_sec    = true,
    overlay_display_effect_per_cost   = false,
    overlay_display_avg_cost          = false,
    overlay_display_actual_cost       = false,
    overlay_display_avg_cast          = false,
    overlay_display_actual_cast       = false,
    overlay_display_hit               = false,
    overlay_display_crit_chance       = false,
    overlay_display_casts_until_oom   = false,
    overlay_display_effect_until_oom  = false,
    overlay_display_time_until_oom    = false,


    overlay_disable                 = false,
    overlay_mana_abilities          = true,
    overlay_old_rank                = false,
    overlay_old_rank_limit_to_known = false,
    overlay_single_effect_only      = false,
    overlay_top_clearance           = false,
    overlay_bottom_clearance        = false,
    overlay_prioritize_heal         = true,

    overlay_update_freq             = 3,
    overlay_font_size               = 8,
    overlay_offset                  = 0.0,

    -- profiles
    profiles_dual_spec              = false,

    -- spell catalogue
    spells_ignore_list              = {},

    -- calculator
    spell_calc_list                 = {
        [6603] = 6603,
        [78] = 78,
        [75] = 75,
        [2973] = 2973,
        [133] = 133,
        [5176] = 5176,
        [5185] = 5185,
        [403] = 403,
        [331] = 331,
        [635] = 635,
        [585] = 585,
        [2050] = 2050,
        [1752] = 1752,
        [2098] = 2098,
        [686] = 686,
    },
    calc_list_use_highest_rank      = true,

    -- general
    libstub_minimap_icon            = { hide = false },
};

for k, v in pairs(spell_filter_options) do
    default_settings[k] = v;
end

local function load_persistent_data(persistent_data, template_data)
    if not persistent_data then
        persistent_data = {};
    end

    -- purge obsolete settings
    for k, v in pairs(persistent_data) do
        if template_data[k] == nil then
            persistent_data[k] = nil;
        end
    end
    -- load defaults for new settings
    for k, v in pairs(template_data) do
        if persistent_data[k] == nil then
            persistent_data[k] = v
        end
    end
end

local function default_profile()
    return {
        settings = swc.utils.deep_table_copy(default_settings)
    };
end

-- persistent account data template
local function default_p_acc()
    return {
        profiles = {
            ["Default"] = default_profile()
        }
    };
end

local default_loadout_config = {

    name = "Default",

    use_custom_talents = false,
    talents_code = "",
    custom_talents_code = "",

    force_apply_buffs = false,

    use_custom_lvl = false,
    lvl = 1,

    default_target_lvl_diff = 3,

    default_target_hp_perc = 100.0,

    target_res = 0,
    target_automatic_armor = true,
    target_automatic_armor_pct = 100,
    target_armor = 0,
    target_facing = false,

    unbounded_aoe_targets = 1,

    always_max_resource = false,
    behind_target = false,
    extra_mana = 0,

    buffs = {},
    target_buffs = {}
};

local function default_p_char()
    local data = {
        main_spec_profile = "Default",
        second_spec_profile = "Default",
        active_loadout = 1,
        loadouts = {
            swc.utils.deep_table_copy(default_loadout_config),
        },
    };
    return data;
end

local function load_config()
    if not __sc_p_acc then
        --swc.core.use_acc_defaults = true;
        __sc_p_acc = {};
    end
    load_persistent_data(__sc_p_acc, default_p_acc());
    for _, v in pairs(__sc_p_acc.profiles) do
        load_persistent_data(v, default_profile());
    end
    for _, v in pairs(__sc_p_acc.profiles) do
        load_persistent_data(v.settings, default_settings);
    end

    -- load settings
    if not __sc_p_char then
        --swc.core.use_char_defaults = true;
        __sc_p_char = {};
    end
    load_persistent_data(__sc_p_char, default_p_char());
    for _, v in pairs(__sc_p_char.loadouts) do
        load_persistent_data(v, default_loadout_config);
    end
end

local spec_keys = {
    [1] = "main_spec_profile",
    [2] = "second_spec_profile",
};

local function set_active_settings()
    for k, v in pairs(spec_keys) do
        if not __sc_p_acc.profiles[__sc_p_char[v]] then
            __sc_p_char[v] = next(__sc_p_acc.profiles);
        end

        if swc.core.active_spec == k then
            config.settings = __sc_p_acc.profiles[__sc_p_char[v]].settings;
        end
    end
    config.active_profile_name = __sc_p_char[spec_keys[swc.core.active_spec]];
end

local function activate_settings()
    for k, v in pairs(config.settings) do
        local f = getglobal("sw_frame_setting_" .. k);
        if f then
            local ft = f._type;
            if ft == "CheckButton" then
                if f:GetChecked() ~= v then
                    f:Click();
                end
            elseif ft == "Slider" then
                if f:GetValue() ~= v then
                    f:SetValue(v);
                end
            elseif ft == "EditBox" then
                if f.number_editbox then
                    if tonumber(f:GetText()) ~= v then
                        f:SetText(tostring(v));
                    end
                else
                    if f:GetText() ~= v then
                        f:SetText(v);
                    end
                end
            end
        end
    end

    if sw_frame.libstub_icon_checkbox:GetChecked() == config.settings.libstub_minimap_icon.hide then
        sw_frame.libstub_icon_checkbox:Click();
    end
end

local function set_active_loadout(idx)
    __sc_p_char.active_loadout = idx;
    config.loadout = __sc_p_char.loadouts[idx];
end

local function activate_loadout_config()
    for k, v in pairs(config.loadout) do
        local f = getglobal("sw_frame_loadout_" .. k);
        if f and f._type then
            local ft = f._type;
            if ft == "CheckButton" then
                if f:GetChecked() ~= v then
                    f:Click();
                end
            elseif ft == "Slider" then
                if f:GetValue() ~= v then
                    f:SetValue(v);
                end
            elseif ft == "EditBox" then
                if f.number_editbox then
                    if tonumber(f:GetText()) ~= v then
                        f:SetText(tostring(v));
                    end
                else
                    if f:GetText() ~= v then
                        f:SetText(v);
                    end
                end
            end
        end
    end
end

local function save_config()
    --
    __sc_p_acc.version_saved = swc.core.version_id;
    __sc_p_char.version_saved = swc.core.version_id;
    if swc.core.use_acc_defaults then
        __sc_p_acc = nil;
    end
    if swc.core.use_char_defaults then
        __sc_p_char = nil;
    end
end

local function new_profile(profile_name, profile_to_copy)
    if __sc_p_acc.profiles[profile_name] or profile_name == "" then
        return false;
    end
    __sc_p_acc.profiles[profile_name] = {};
    load_persistent_data(__sc_p_acc.profiles[profile_name], profile_to_copy);
    __sc_p_acc.profiles[profile_name].settings = swc.utils.deep_table_copy(profile_to_copy.settings);
    print(__sc_p_acc.profiles[profile_name].settings);
    -- switch to new profile
    __sc_p_char[spec_keys[swc.core.active_spec]] = profile_name;
    print(config.settings);
    set_active_settings()
    print(config.settings);
    activate_settings();
    print(config.settings);
    return true;
end

local function new_profile_from_default(profile_name)
    return new_profile(profile_name, swc.utils.deep_table_copy(default_profile()));
end

local function new_profile_from_active_copy(profile_name)
    return new_profile(profile_name, __sc_p_acc.profiles[config.active_profile_name]);
end

local function new_loadout(name, loadout_to_copy)
    if name == "" then
        return false;
    end
    for _, v in pairs(__sc_p_char.loadouts) do
        if v.name == name then
            return false;
        end
    end

    local n = #__sc_p_char.loadouts + 1;
    __sc_p_char.loadouts[n] = {};
    load_persistent_data(__sc_p_char.loadouts[n], loadout_to_copy);
    __sc_p_char.active_loadout = n;
    __sc_p_char.loadouts[n].name = name;

    set_active_loadout(n);

    return true;
end

local function new_loadout_from_active_copy(name)
    return new_loadout(name, swc.utils.deep_table_copy(__sc_p_char.loadouts[__sc_p_char.active_loadout]));
end

local function new_loadout_from_default(name)
    return new_loadout(name, swc.utils.deep_table_copy(default_loadout_config));
end


config.new_profile_from_default = new_profile_from_default;
config.new_profile_from_active_copy = new_profile_from_active_copy;
config.load_settings = load_settings;
config.load_config = load_config;
config.save_config = save_config;
config.set_active_settings = set_active_settings;
config.activate_settings = activate_settings;
config.activate_loadout_config = activate_loadout_config;
config.set_active_loadout = set_active_loadout;
config.new_loadout_from_active_copy = new_loadout_from_active_copy;
config.new_loadout_from_default = new_loadout_from_default;
config.active_profile_name = active_profile_name;
config.spec_keys = spec_keys;
config.spell_filter_options = spell_filter_options;

swc.config = config;
