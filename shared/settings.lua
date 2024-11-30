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

local icon_stat_display         = swc.overlay.icon_stat_display;
local tooltip_stat_display      = swc.tooltip.tooltip_stat_display;
-------------------------------------------------------------------------------
local settings = {};

--local function default_sw_settings()
--    local default = {};
--    default.ability_icon_overlay =
--        bit.bor(
--                icon_stat_display.normal, 
--                icon_stat_display.crit, 
--                icon_stat_display.effect_per_sec,
--                icon_stat_display.show_heal_variant
--                );
--
--    default.ability_tooltip =
--        bit.bor(tooltip_stat_display.normal,
--                tooltip_stat_display.crit,
--                tooltip_stat_display.avg_cost,
--                tooltip_stat_display.avg_cast,
--                tooltip_stat_display.expected,
--                tooltip_stat_display.effect_per_sec,
--                tooltip_stat_display.effect_per_cost,
--                tooltip_stat_display.cost_per_sec,
--                tooltip_stat_display.stat_weights,
--                tooltip_stat_display.cast_until_oom
--                );
--
--    default.icon_overlay_update_freq = 3;
--    default.icon_overlay_font_size = 8;
--    default.icon_overlay_offset = 0.0;
--    default.icon_overlay_disable = false;
--    default.icon_overlay_mana_abilities = true;
--    default.icon_overlay_old_rank = false;
--    default.show_tooltip_only_when_shift = false;
--    default.clear_original_tooltip = false;

local default_sw_settings = {

    -- new


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

    overlay_update_freq                 = 3,
    overlay_font_size                   = 8,
    overlay_offset                      = 0.0,

    -- general
    libstub_minimap_icon_show           = true,
};

local function save_sw_settings()

    --local icon_overlay_settings = 0;
    --local tooltip_settings = 0;


    --if sw_frame.tooltip_frame.icon_normal_effect:GetChecked() then
    --    icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.normal);
    --end
    --if sw_frame.tooltip_frame.icon_crit_effect:GetChecked() then
    --    icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.crit);
    --end
    --if sw_frame.tooltip_frame.icon_expected_effect:GetChecked() then
    --    icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.expected);
    --end
    --if sw_frame.tooltip_frame.icon_effect_per_sec:GetChecked() then
    --    icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.effect_per_sec);
    --end
    --if sw_frame.tooltip_frame.icon_effect_per_cost:GetChecked() then
    --    icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.effect_per_cost);
    --end
    --if sw_frame.tooltip_frame.icon_avg_cost:GetChecked() then
    --    icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.avg_cost);
    --end
    --if sw_frame.tooltip_frame.icon_avg_cast:GetChecked() then
    --    icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.avg_cast);
    --end
    --if sw_frame.tooltip_frame.icon_hit:GetChecked() then
    --    icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.hit);
    --end
    --if sw_frame.tooltip_frame.icon_crit:GetChecked() then
    --    icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.crit_chance);
    --end
    --if sw_frame.tooltip_frame.icon_casts_until_oom:GetChecked() then
    --    icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.casts_until_oom);
    --end
    --if sw_frame.tooltip_frame.icon_effect_until_oom:GetChecked() then
    --    icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.effect_until_oom);
    --end
    --if sw_frame.tooltip_frame.icon_time_until_oom:GetChecked() then
    --    icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.time_until_oom);
    --end
    --if sw_frame.tooltip_frame.icon_heal_variant:GetChecked() then
    --    icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.show_heal_variant);
    --end
    --if not sw_frame.tooltip_frame.tooltip_addon_name:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.addon_name);
    --end
    --if not sw_frame.tooltip_frame.tooltip_loadout_info:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.loadout_info);
    --end
    --if sw_frame.tooltip_frame.tooltip_spell_rank:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.spell_rank);
    --end
    --if sw_frame.tooltip_frame.tooltip_normal_effect:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.normal);
    --end
    --if sw_frame.tooltip_frame.tooltip_crit_effect:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.crit);
    --end
    --if sw_frame.tooltip_frame.tooltip_expected_effect:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.expected);
    --end
    --if sw_frame.tooltip_frame.tooltip_effect_per_sec:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.effect_per_sec);
    --end
    --if sw_frame.tooltip_frame.tooltip_effect_per_cost:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.effect_per_cost);
    --end
    --if sw_frame.tooltip_frame.tooltip_cost_per_sec:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.cost_per_sec);
    --end
    --if sw_frame.tooltip_frame.tooltip_stat_weights:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.stat_weights);
    --end
    --if sw_frame.tooltip_frame.tooltip_avg_cost:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.avg_cost);
    --end
    --if sw_frame.tooltip_frame.tooltip_avg_cast:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.avg_cast);
    --end
    --if sw_frame.tooltip_frame.tooltip_cast_until_oom:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.cast_until_oom);
    --end
    --if not sw_frame.tooltip_frame.tooltip_sp_effect_calc:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.sp_effect_calc);
    --end
    --if not sw_frame.tooltip_frame.tooltip_dynamic_tip:GetChecked() then
    --    tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.dynamic_tip);
    --end

    --__sw__persistent_data_per_char.settings.icon_overlay_disable = sw_frame.tooltip_frame.icon_overlay_disable:GetChecked();
    --__sw__persistent_data_per_char.settings.icon_overlay_mana_abilities = sw_frame.tooltip_frame.icon_mana_overlay:GetChecked();
    --__sw__persistent_data_per_char.settings.icon_overlay_old_rank = sw_frame.tooltip_frame.icon_old_rank_warning:GetChecked();
    --__sw__persistent_data_per_char.settings.icon_show_single_target_only = sw_frame.tooltip_frame.icon_show_single_target_only:GetChecked();
    --__sw__persistent_data_per_char.settings.icon_bottom_clearance = sw_frame.tooltip_frame.icon_bottom_clearance:GetChecked();
    --__sw__persistent_data_per_char.settings.icon_top_clearance = sw_frame.tooltip_frame.icon_top_clearance:GetChecked();

    --__sw__persistent_data_per_char.settings.ability_icon_overlay = icon_overlay_settings;
    --__sw__persistent_data_per_char.settings.ability_tooltip = tooltip_settings;
    --__sw__persistent_data_per_char.settings.show_tooltip_only_when_shift = sw_frame.tooltip_frame.show_tooltip_only_when_shift;
    --__sw__persistent_data_per_char.settings.clear_original_tooltip = sw_frame.tooltip_frame.clear_original_tooltip;
    --__sw__persistent_data_per_char.settings.icon_overlay_update_freq = sw_snapshot_loadout_update_freq;
    --__sw__persistent_data_per_char.settings.icon_overlay_font_size = sw_frame.tooltip_frame.icon_overlay_font_size;
    --__sw__persistent_data_per_char.settings.icon_overlay_offset = sw_frame.tooltip_frame.icon_overlay_offset;

    --__sw__persistent_data_per_char.settings.libstub_minimap_icon_show = sw_frame.libstub_icon_checkbox:GetChecked();
    __sw__persistent_data_per_char.version_saved = swc.core.version_id;
end

settings.default_sw_settings = default_sw_settings;
settings.save_sw_settings = save_sw_settings;

swc.settings = settings;
