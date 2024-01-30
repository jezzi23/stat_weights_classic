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
local spell_flags                               = swc.abilities.spell_flags;

local active_loadout_and_effects                = swc.loadout.active_loadout_and_effects;
local active_loadout_and_effects_diffed_from_ui = swc.loadout.active_loadout_and_effects_diffed_from_ui;
-------------------------------------------------------------------------------
local tooltip_export = {};

local tooltip_stat_display = {
    normal              = bit.lshift(1,1),
    crit                = bit.lshift(1,2),
    ot                  = bit.lshift(1,3),
    ot_crit             = bit.lshift(1,4),
    expected            = bit.lshift(1,5),
    effect_per_sec      = bit.lshift(1,6),
    effect_per_cost     = bit.lshift(1,7),
    cost_per_sec        = bit.lshift(1,8),
    stat_weights        = bit.lshift(1,9),
    more_details        = bit.lshift(1,10), -- not used anymore, was not default
    avg_cost            = bit.lshift(1,11),
    avg_cast            = bit.lshift(1,12),
    cast_until_oom      = bit.lshift(1,13),
    cast_and_tap        = bit.lshift(1,14),
    spell_rank          = bit.lshift(1,15),
    loadout_info        = bit.lshift(1,16), -- negate default
    sp_effect_calc      = bit.lshift(1,17), -- negate default
};

local function sort_stat_weights(stat_weights, num_weights) 
    
    for i = 1, num_weights do
        local j = i;
        while j ~= 1 and stat_weights[j].weight > stat_weights[j-1].weight do
            local tmp = stat_weights[j];
            stat_weights[j] = stat_weights[j-1];
            stat_weights[j-1] = tmp;
            j = j - 1;
        end
    end
end

local function begin_tooltip_section(tooltip, spell)

    if sw_frame.settings_frame.clear_original_tooltip or tooltip ~= GameTooltip then
        tooltip:ClearLines();
        local lname = GetSpellInfo(spell.base_id);
        if bit.band(spell.flags, spell_flags.sod_rune) == 0 then
            tooltip:AddDoubleLine(lname, "Rank "..spell.rank, 1.0, 1.0, 1.0, 0.50196081399918, 0.50196081399918, 0.50196081399918);
        else
            tooltip:AddLine(lname, 1.0, 1.0, 1.0);
        end
    end

    if tooltip == GameTooltip then
        tooltip:AddLine("Stat Weights Classic", 1, 1, 1);
        if sw_frame.stat_comparison_frame:IsShown() and sw_frame:IsShown() then
            tooltip:AddLine("AFTER STAT CHANGES", 1.0, 0.0, 0.0);
        end
    else
        tooltip:AddLine("BEFORE STAT CHANGES", 1.0, 0.0, 0.0);
    end

end
local function end_tooltip_section(tooltip)
    tooltip:Show();
end

local spell_jump_itr = pairs(spells);
local spell_jump_key = spell_jump_itr(spells);

CreateFrame( "GameTooltip", "swc_stat_calc_tooltip", nil, "GameTooltipTemplate" );
swc_stat_calc_tooltip:SetOwner(GameTooltip, "ANCHOR_LEFT" );
-- TODO: Font of this tooltip appears much bigger even though same font is used?
swc_stat_calc_tooltip:AddFontStrings(
    swc_stat_calc_tooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
    swc_stat_calc_tooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
);
GameTooltip:HookScript("OnHide", function()
    swc_stat_calc_tooltip:Hide();
end);

local function append_tooltip_spell_info(is_fake)

    local spell_name, spell_id = GameTooltip:GetSpell();
    local spell = spells[spell_id];

    if not spell then
        return;
    end

    if not sw_frame.stat_comparison_frame:IsShown() or not sw_frame:IsShown() then

        local loadout, effects = active_loadout_and_effects();
        swc.tooltip.tooltip_spell_info(GameTooltip, spell, loadout, effects, nil, spell_id);
    else

        local loadout, effects, effects_diffed = active_loadout_and_effects_diffed_from_ui();
        swc.tooltip.tooltip_spell_info(GameTooltip, spell, loadout, effects_diffed, nil, spell_id);

        swc_stat_calc_tooltip:ClearLines();
        swc_stat_calc_tooltip:SetOwner(GameTooltip, "ANCHOR_LEFT", 0, -select(2, swc_stat_calc_tooltip:GetSize()));
        swc.tooltip.tooltip_spell_info(swc_stat_calc_tooltip, spell, loadout, effects, nil, spell_id);
    end
end

local function update_tooltip(tooltip)


    if swc.core.__sw__test_all_spells and sw_frame:IsShown() then

        spell_jump_key = spell_jump_itr(spells, spell_jump_key);
        if not spell_jump_key then
            spell_jump_key = spell_jump_itr(spells);
        end
        sw_frame.spell_id_viewer_editbox:SetText(tostring(spell_jump_key));
    end
    --tooltips update dynamically without debug setting
    if not swc.core.__sw__debug__ and tooltip:IsShown() then
        local spell_name, id = tooltip:GetSpell();

        if spells[id] and IsControlKeyDown() and sw_frame.stat_comparison_frame:IsShown() and 
                not sw_frame.stat_comparison_frame.spells[spells[id].base_id] and
                bit.band(spells[id].flags, spell_flags.mana_regen) == 0 then

            sw_frame.stat_comparison_frame.spells[spells[id].base_id] = {
                name = spell_name
            };

            local loadout, effects, effects_diffed = active_loadout_and_effects_diffed_from_ui();
            swc.ui.update_and_display_spell_diffs(loadout, effects, effects_diffed);
        end

        -- Workaround: need to set some spell id that exists to get tooltip refreshed when
        --            looking at custom spell id tooltip
        if swc.core.__sw__test_all_spells and spells[tmp_tooltip_overwrite_spell_id] then
            local tmp_tooltip_overwrite_spell_id = tonumber(sw_frame.spell_id_viewer_editbox:GetText());
            tooltip:ClearLines();
            local lname, _, _, _, _, _, _ ,_  = GetSpellInfo(tmp_tooltip_overwrite_spell_id);
            if lname then
                tooltip:ClearLines();
                tooltip:SetSpellByID(tmp_tooltip_overwrite_spell_id);
            else
                tooltip:SetSpellByID(6603);
            end
        end

        if id and spells[id] then
            tooltip:ClearLines();
            tooltip:SetSpellByID(id);

        end
    end
end

tooltip_export.tooltip_stat_display             = tooltip_stat_display;
tooltip_export.sort_stat_weights                = sort_stat_weights;
tooltip_export.begin_tooltip_section            = begin_tooltip_section;
tooltip_export.end_tooltip_section              = end_tooltip_section;
tooltip_export.append_tooltip_spell_info        = append_tooltip_spell_info;
tooltip_export.update_tooltip                   = update_tooltip;

swc.tooltip = tooltip_export;

