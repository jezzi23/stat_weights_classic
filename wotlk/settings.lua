
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

local icon_stat_display         = addonTable.icon_stat_display;
local tooltip_stat_display      = addonTable.tooltip_stat_display;

local function default_sw_settings()
    local settings = {};
    settings.ability_icon_overlay = 
        bit.bor(icon_stat_display.normal, 
                icon_stat_display.crit, 
                icon_stat_display.effect_per_sec,
                icon_stat_display.show_heal_variant
                );

    settings.ability_tooltip = 
        bit.bor(tooltip_stat_display.normal, 
                tooltip_stat_display.crit, 
                tooltip_stat_display.ot,
                tooltip_stat_display.ot_crit,
                tooltip_stat_display.avg_cost,
                tooltip_stat_display.avg_cast,
                tooltip_stat_display.expected,
                tooltip_stat_display.effect_per_sec,
                tooltip_stat_display.effect_per_cost,
                tooltip_stat_display.cost_per_sec,
                tooltip_stat_display.stat_weights,
                tooltip_stat_display.cast_until_oom);

    settings.icon_overlay_update_freq = 3;
    settings.icon_overlay_font_size = 8;
    settings.icon_overlay_mana_abilities = true;
    settings.icon_overlay_old_rank = true;
    settings.show_tooltip_only_when_shift = false;
    settings.clear_original_tooltip = false;
    settings.libstub_minimap_icon = { hide = false };

    return settings;
end

local function save_sw_settings()

    local icon_overlay_settings = 0;
    local tooltip_settings = 0;

    if sw_frame.settings_frame.icon_normal_effect:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.normal);
    end
    if sw_frame.settings_frame.icon_crit_effect:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.crit);
    end
    if sw_frame.settings_frame.icon_expected_effect:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.expected);
    end
    if sw_frame.settings_frame.icon_effect_per_sec:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.effect_per_sec);
    end
    if sw_frame.settings_frame.icon_effect_per_cost:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.effect_per_cost);
    end
    if sw_frame.settings_frame.icon_avg_cost:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.avg_cost);
    end
    if sw_frame.settings_frame.icon_avg_cast:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.avg_cast);
    end
    if sw_frame.settings_frame.icon_hit:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.hit);
    end
    if sw_frame.settings_frame.icon_crit:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.crit_chance);
    end
    if sw_frame.settings_frame.icon_casts_until_oom:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.casts_until_oom);
    end
    if sw_frame.settings_frame.icon_effect_until_oom:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.effect_until_oom);
    end
    if sw_frame.settings_frame.icon_time_until_oom:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.time_until_oom);
    end
    if sw_frame.settings_frame.icon_heal_variant:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.show_heal_variant);
    end
    if sw_frame.settings_frame.tooltip_normal_effect:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.normal);
    end
    if sw_frame.settings_frame.tooltip_crit_effect:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.crit);
    end
    if sw_frame.settings_frame.tooltip_normal_ot:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.ot);
    end
    if sw_frame.settings_frame.tooltip_crit_ot:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.ot_crit);
    end
    if sw_frame.settings_frame.tooltip_expected_effect:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.expected);
    end
    if sw_frame.settings_frame.tooltip_effect_per_sec:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.effect_per_sec);
    end
    if sw_frame.settings_frame.tooltip_effect_per_cost:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.effect_per_cost);
    end
    if sw_frame.settings_frame.tooltip_cost_per_sec:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.cost_per_sec);
    end
    if sw_frame.settings_frame.tooltip_stat_weights:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.stat_weights);
    end
    if sw_frame.settings_frame.tooltip_more_details:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.more_details);
    end
    if sw_frame.settings_frame.tooltip_avg_cost:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.avg_cost);
    end
    if sw_frame.settings_frame.tooltip_avg_cast:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.avg_cast);
    end
    if sw_frame.settings_frame.tooltip_cast_until_oom:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.cast_until_oom);
    end

    __sw__persistent_data_per_char.settings.icon_overlay_mana_abilities = sw_frame.settings_frame.icon_mana_overlay:GetChecked();
    __sw__persistent_data_per_char.settings.icon_overlay_old_rank = sw_frame.settings_frame.icon_old_rank_warning:GetChecked();

    __sw__persistent_data_per_char.settings.ability_icon_overlay = icon_overlay_settings;
    __sw__persistent_data_per_char.settings.ability_tooltip = tooltip_settings;
    __sw__persistent_data_per_char.settings.show_tooltip_only_when_shift = sw_frame.settings_frame.show_tooltip_only_when_shift;
    __sw__persistent_data_per_char.settings.clear_original_tooltip = sw_frame.settings_frame.clear_original_tooltip;
    __sw__persistent_data_per_char.settings.icon_overlay_update_freq = sw_snapshot_loadout_update_freq;
    __sw__persistent_data_per_char.settings.icon_overlay_font_size = sw_frame.settings_frame.icon_overlay_font_size;
end

addonTable.default_sw_settings = default_sw_settings;
addonTable.save_sw_settings = save_sw_settings;
