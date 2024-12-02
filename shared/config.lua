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

local _, swc           = ...;

local empty_loadout    = swc.loadout.empty_loadout;
local empty_effects    = swc.loadout.empty_effects;
local default_loadout  = swc.loadout.default_loadout;

-------------------------------------------------------------------------------
local config           = {};

local default_settings = {
    -- tooltip
    tooltip_display_hit                 = true,
    tooltip_display_normal              = false,
    tooltip_display_normal_hit_combined = true,
    tooltip_display_crit                = false,
    tooltip_display_crit_combined       = true,
    tooltip_display_expected            = true,
    tooltip_display_effect_per_sec      = true,
    tooltip_display_effect_per_cost     = true,
    tooltip_display_cost_per_sec        = false,
    tooltip_display_stat_weights        = false,
    tooltip_display_avg_cost            = false,
    tooltip_display_avg_cast            = false,
    tooltip_display_cast_until_oom      = false,
    tooltip_display_cast_and_tap        = false,
    tooltip_display_spell_rank          = false,
    tooltip_display_loadout_info        = true,
    tooltip_display_sp_effect_calc      = false,
    tooltip_display_sp_effect_ratio     = false,
    tooltip_display_addon_name          = true,
    tooltip_display_dynamic_tip         = true,
    tooltip_display_spell_id            = false,

    tooltip_disable                     = false,
    tooltip_shift_to_show               = false,
    tooltip_clear_original              = false,

    -- overlay
    overlay_display_normal              = false,
    overlay_display_crit                = false,
    overlay_display_expected            = false,
    overlay_display_effect_per_sec      = true,
    overlay_display_effect_per_cost     = false,
    overlay_display_avg_cost            = false,
    overlay_display_actual_cost         = false,
    overlay_display_avg_cast            = false,
    overlay_display_actual_cast         = false,
    overlay_display_hit                 = false,
    overlay_display_crit_chance         = false,
    overlay_display_casts_until_oom     = false,
    overlay_display_effect_until_oom    = false,
    overlay_display_time_until_oom      = false,

    overlay_disable                     = false,
    overlay_mana_abilities              = true,
    overlay_old_rank                    = false,
    overlay_single_effect_only          = false,
    overlay_top_clearance               = false,
    overlay_bottom_clearance            = false,
    overlay_prioritize_heal             = true,

    overlay_update_freq                 = 3,
    overlay_font_size                   = 8,
    overlay_offset                      = 0.0,

    -- general
    libstub_minimap_icon                = { hide = false },
};

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

local default_profiles = {
    num_profiles = 1,
    settings_list = {
        ["Default"] = swc.utils.deep_table_copy(default_settings)
    }
};

local function load_config()
    if not p_acc then
        swc.core.use_acc_defaults = true;
        p_acc = { profiles = {} };
    end
    load_persistent_data(p_acc.profiles, default_profiles);
    for k, v in pairs(p_acc.profiles.settings_list) do
        load_persistent_data(v, default_settings);
    end

    -- load settings
    if not p_char then
        swc.core.use_char_defaults = true;
        p_char = {};
        p_char.main_spec_profile = "Default";
        p_char.second_spec_profile = "Default";
    end
    if not p_acc.profiles.settings_list[p_char.main_spec_profile] then
        p_char.main_spec_profile = next(p_acc.profiles.settings_list);
    end
    if not p_acc.profiles.settings_list[p_char.second_spec_profile] then
        p_char.second_spec_profile = next(p_acc.profiles.settings_list);
    end

    -- load loadouts
    if not p_char.loadouts or not p_char.loadouts.num_loadouts then
        -- load defaults
        p_char.loadouts = {};
        p_char.loadouts.loadouts_list = {};

        p_char.loadouts.loadouts_list[1] = {};
        p_char.loadouts.loadouts_list[1].loadout = empty_loadout();
        default_loadout(p_char.loadouts.loadouts_list[1].loadout);
        p_char.loadouts.loadouts_list[1].equipped = {};
        p_char.loadouts.loadouts_list[1].talented = {};
        p_char.loadouts.loadouts_list[1].final_effects = {};
        empty_effects(p_char.loadouts.loadouts_list[1].equipped);
        empty_effects(p_char.loadouts.loadouts_list[1].talented);
        empty_effects(p_char.loadouts.loadouts_list[1].final_effects);
        p_char.loadouts.active_loadout = 1;

        -- add secondary PVP loadout with lvl diff of 0 by default
        p_char.loadouts.loadouts_list[2] = {};
        p_char.loadouts.loadouts_list[2].loadout = empty_loadout();
        default_loadout(p_char.loadouts.loadouts_list[2].loadout);
        p_char.loadouts.loadouts_list[2].loadout.default_target_lvl_diff = 0;
        p_char.loadouts.loadouts_list[2].loadout.name = "PVP";
        p_char.loadouts.loadouts_list[2].equipped = {};
        p_char.loadouts.loadouts_list[2].talented = {};
        p_char.loadouts.loadouts_list[2].final_effects = {};
        empty_effects(p_char.loadouts.loadouts_list[2].equipped);
        empty_effects(p_char.loadouts.loadouts_list[2].talented);
        empty_effects(p_char.loadouts.loadouts_list[2].final_effects);

        p_char.loadouts.num_loadouts = 2;
    end
end

local function set_active_settings()
    -- TODO: dual spec
    local active_profile = p_char.main_spec_profile;
    -- active settings
    config.settings = p_acc.profiles.settings_list[active_profile];


    for k, v in pairs(config.settings) do
        print(k, v);
    end
end

local function save_config()
    --
    p_acc.version_saved = swc.core.version_id;
    p_char.version_saved = swc.core.version_id;
    if swc.core.use_acc_defaults then
        p_acc = nil;
    end
    if swc.core.use_char_defaults then
        p_char = nil;
        return;
    end

    -- clear previous ui elements from spells table
    p_char.stat_comparison_spells = {};
    for k, v in pairs(self.stat_comparison_frame.spells) do
        p_char.stat_comparison_spells[k] = {};
        p_char.stat_comparison_spells[k].name = v.name;
    end
    p_char.sim_type = self.stat_comparison_frame.sim_type;

    p_char.loadouts = {};
    p_char.loadouts.loadouts_list = {};
    for k, v in pairs(self.loadouts_frame.lhs_list.loadouts) do
        p_char.loadouts.loadouts_list[k] = {};
        p_char.loadouts.loadouts_list[k].loadout = v.loadout;
        p_char.loadouts.loadouts_list[k].equipped = v.equipped;
    end
    p_char.loadouts.active_loadout = self.loadouts_frame.lhs_list.active_loadout;
    p_char.loadouts.num_loadouts = self.loadouts_frame.lhs_list.num_loadouts;
end


config.load_settings = load_settings;
config.load_config = load_config;
config.save_config = save_config;
config.set_active_settings = set_active_settings;

swc.config = config;
