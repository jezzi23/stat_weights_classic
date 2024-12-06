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
local spell_flags                               = swc.abilities.spell_flags;

local active_loadout_and_effects                = swc.loadout.active_loadout_and_effects;
local active_loadout_and_effects_diffed_from_ui = swc.loadout.active_loadout_and_effects_diffed_from_ui;

local config                                    = swc.config;
-------------------------------------------------------------------------------
local tooltip_export = {};

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

    
    if config.settings.tooltip_clear_original or tooltip ~= GameTooltip or not GetSpellInfo(spell.base_id) then
        local txt_left = getglobal("GameTooltipTextLeft1");
        if txt_left then

            local lname = GetSpellInfo(spell.base_id);
            if not lname then
                lname = ""..spell.base_id;
            end
            txt_left:SetTextColor(1.0, 1.0, 1.0, 1.0);
            txt_left:SetText(lname);
            txt_left:Show();
        end
    end

    if tooltip == GameTooltip then

        if config.settings.tooltip_display_addon_name then
            tooltip:AddLine("Stat Weights Classic v"..swc.core.version, 1, 1, 1);
        end
        if sw_frame.calculator_frame:IsShown() and sw_frame:IsShown() then
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

CreateFrame("GameTooltip", "swc_stat_calc_tooltip", nil, "GameTooltipTemplate" );
swc_stat_calc_tooltip:SetOwner(GameTooltip, "ANCHOR_LEFT" );
-- TODO: Font of this tooltip appears much bigger even though same font is used?
swc_stat_calc_tooltip:AddFontStrings(
--    --swc_stat_calc_tooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipTextSmall"),
--    --swc_stat_calc_tooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipTextSmall")
--
    swc_stat_calc_tooltip:CreateFontString("$parentHeaderText", nil, "GameTooltipHeaderText"),
    swc_stat_calc_tooltip:CreateFontString("$parentText", nil, "GameTooltipText"),
    swc_stat_calc_tooltip:CreateFontString("$parentTextSmall", nil, "GameTooltipTextSmall")
    --swc_stat_calc_tooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
);
--

swc_stat_calc_tooltipHeaderText:SetFont(GameTooltipHeaderText:GetFont())
swc_stat_calc_tooltipText:SetFont(GameTooltipText:GetFont())
swc_stat_calc_tooltipTextSmall:SetFont(GameTooltipTextSmall:GetFont())
--swc_stat_calc_tooltip
--for _, v in pairs({GameTooltipHeaderText, GameTooltipText GameTooltipTextSmall}) do
--for _, v in pairs({GameTooltipHeaderText, GameTooltipText GameTooltipTextSmall}) do
--    local fnt, sz = 
--end

GameTooltip:HookScript("OnHide", function()
    swc_stat_calc_tooltip:Hide();
end);


local spell_id_of_cleared_tooltip = 0;
local clear_tooltip_refresh_id = 463;

local function update_tooltip(tooltip)


    if swc.core.__sw__test_all_spells and sw_frame.spells_frame:IsShown() then

        spell_jump_key = spell_jump_itr(spells, spell_jump_key);
        if not spell_jump_key then
            spell_jump_key = spell_jump_itr(spells);
        end
        sw_frame.spell_id_viewer_editbox:SetText(tostring(spell_jump_key));
    end
    --tooltips update dynamically without debug setting
    if not (PlayerTalentFrame and MouseIsOver(PlayerTalentFrame)) and
        not swc.core.__sw__debug__ and tooltip:IsShown() then

        local spell_name, id = tooltip:GetSpell();

        if spells[id] and IsControlKeyDown() and sw_frame.calculator_frame:IsShown() and 
                not sw_frame.calculator_frame.spells[id] and
                bit.band(spells[id].flags, spell_flags.mana_regen) == 0 then

            sw_frame.calculator_frame.spells[id] = {
                name = spell_name
            };

            local loadout, effects, effects_diffed = active_loadout_and_effects_diffed_from_ui();
            swc.ui.update_and_display_spell_diffs(loadout, effects, effects_diffed);
        end

        -- Workaround: need to set some spell id that exists to get tooltip refreshed when
        --            looking at custom spell id tooltip
        if spells[id] or id == clear_tooltip_refresh_id or id == sw_frame.spell_viewer_invalid_spell_id then
            if  id ~= clear_tooltip_refresh_id then
                spell_id_of_cleared_tooltip = id;
            end
            if id == sw_frame.spell_viewer_invalid_spell_id then
                tooltip:SetSpellByID(sw_frame.spell_viewer_invalid_spell_id);
            elseif config.settings.tooltip_clear_original then
                if (not config.settings.tooltip_shift_to_show or IsShiftKeyDown()) then
                    tooltip:SetSpellByID(clear_tooltip_refresh_id);
                else
                    tooltip:SetSpellByID(spell_id_of_cleared_tooltip);
                end
            elseif id then
                tooltip:ClearLines();
                tooltip:SetSpellByID(id);

            end
        end

    end
end

local function append_tooltip_spell_info(is_fake)

    local spell_name, spell_id = GameTooltip:GetSpell();

    if spell_id == clear_tooltip_refresh_id then
        spell_id = spell_id_of_cleared_tooltip;
    elseif spell_id == sw_frame.spell_viewer_invalid_spell_id then
        spell_id = tonumber(sw_frame.spell_id_viewer_editbox:GetText());
    elseif config.settings.tooltip_clear_original and (not config.settings.tooltip_shift_to_show or IsShiftKeyDown()) then
        if spells[spell_id] then
            spell_id_of_cleared_tooltip = spell_id;
            GameTooltip:ClearLines();
            GameTooltip:SetSpellByID(clear_tooltip_refresh_id);
            return;
        end
    end

    local spell = spells[spell_id];

    if not spell then
        return;
    end

    if not sw_frame.calculator_frame:IsShown() or not sw_frame:IsShown() then

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

tooltip_export.tooltip_stat_display             = tooltip_stat_display;
tooltip_export.sort_stat_weights                = sort_stat_weights;
tooltip_export.begin_tooltip_section            = begin_tooltip_section;
tooltip_export.end_tooltip_section              = end_tooltip_section;
tooltip_export.append_tooltip_spell_info        = append_tooltip_spell_info;
tooltip_export.update_tooltip                   = update_tooltip;

swc.tooltip = tooltip_export;

