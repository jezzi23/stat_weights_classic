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

local spells                                        = swc.abilities.spells;
local spell_flags                                   = swc.abilities.spell_flags;

local active_loadout_and_effects                    = swc.loadout.active_loadout_and_effects;
local active_loadout_and_effects_diffed_from_ui     = swc.loadout.active_loadout_and_effects_diffed_from_ui;

local stats_for_spell                               = swc.calc.stats_for_spell;
local spell_info                                    = swc.calc.spell_info;
local cast_until_oom                                = swc.calc.cast_until_oom;
--------------------------------------------------------------------------------
local overlay = {};

local icon_stat_display = {
    normal                  = bit.lshift(1,1),
    crit                    = bit.lshift(1,2),
    expected                = bit.lshift(1,3),
    effect_per_sec          = bit.lshift(1,4),
    effect_per_cost         = bit.lshift(1,5),
    avg_cost                = bit.lshift(1,6),
    avg_cast                = bit.lshift(1,7),
    hit                     = bit.lshift(1,8),
    crit_chance             = bit.lshift(1,9),
    casts_until_oom         = bit.lshift(1,10),
    effect_until_oom        = bit.lshift(1,11),
    time_until_oom          = bit.lshift(1,12),

    show_heal_variant       = bit.lshift(1,20),
};

local function init_frame_overlay(frame_info)

    frame_info.overlay_frames = {};
    local offsets = {-3, -1.5, 0};
    local anchors = {"TOP", "CENTER", "BOTTOM"};

    for i = 1, 3 do
        frame_info.overlay_frames[i] = frame_info.frame:CreateFontString(nil, "OVERLAY");
        
        frame_info.overlay_frames[i]:SetFont(
            swc.ui.icon_overlay_font, sw_frame.settings_frame.icon_overlay_font_size, "THICKOUTLINE");
        frame_info.overlay_frames[i]:SetPoint(anchors[i], 1, offsets[i]);
    end
end

local function clear_overlays()

    for k, v in pairs( __sw__icon_frames.bars) do
        if v.frame then
            for i = 1, 3 do
                v.overlay_frames[i]:SetText("");
                v.overlay_frames[i]:Hide();
            end
        end
    end
    for k, v in pairs(__sw__icon_frames.book) do
        if v.frame then
            for i = 1, 3 do
                v.overlay_frames[i]:SetText("");
                v.overlay_frames[i]:Hide();
            end
        end
    end
end

local function action_id_of_button(button)

    if not button then
        return nil;
    end
    if action_bar_addon_name == "Default" then
        return button.action;
    else
        -- Dominos seems to set GetAttribute function for the 1-6 default blizz bars
        return button:GetAttribute("action");
    end
end

local function gather_spell_icons()

    local action_bar_frame_names = {};
    local spell_book_frames = {};

    local index = 1;
    -- gather spell book icons
    if false then -- check for some common addons if they overrite spellbook frames

    else -- default spellbook frames
        for i = 1, 12 do

            spell_book_frames[i] = { 
                frame = getfenv()["SpellButton"..i];
            };
        end
    end
    for i = 1, 12 do


        init_frame_overlay(spell_book_frames[i]);
    end

    -- gather action bar icons
    index = 1;
    if IsAddOnLoaded("Bartender4") then -- check for some common addons if they overrite spellbook frames

        for i = 1, 120 do
            action_bar_frame_names[i] = "BT4Button"..i;
        end
        action_bar_addon_name = "Bartender4";

    elseif IsAddOnLoaded("ElvUI") then -- check for some common addons if they overrite spellbook frames

        local elvi_bar_order_to_match_action_ids = {1, 6, 5, 4, 2, 3, 7, 8, 9, 10};
        for i = 1, 10 do
            for j = 1, 12 do
                action_bar_frame_names[index] = 
                    "ElvUI_Bar"..elvi_bar_order_to_match_action_ids[i].."Button"..j;

                index = index + 1;
            end
        end
        action_bar_addon_name = "ElvUI";

    elseif IsAddOnLoaded("Dominos") then -- check for some common addons if they overrite spellbook frames

        local bars = {
            "ActionButton", "DominosActionButton", "MultiBarRightButton",
            "MultiBarLeftButton", "MultiBarBottomRightButton", "MultiBarBottomLeftButton"
        };
        index = 1;
        for k, v in pairs(bars) do
            for j = 1, 12 do
                action_bar_frame_names[index] = v..j;

                index = index + 1;
            end
        end

        local dominos_button_index = 13;
        for i = index, 120 do
            action_bar_frame_names[i] = "DominosActionButton"..dominos_button_index;

            dominos_button_index = dominos_button_index + 1;
        end
        action_bar_addon_name = "Dominos";

    else -- default action bars
        
        local bars = {
            "ActionButton", "BonusActionButton", "MultiBarRightButton",
            "MultiBarLeftButton", "MultiBarBottomRightButton", "MultiBarBottomLeftButton"
        };
        index = 1;
        for k, v in pairs(bars) do
            for j = 1, 12 do
                action_bar_frame_names[index] = v..j;

                index = index + 1;
            end
        end
        action_bar_addon_name = "Default";
    end

    local action_bar_frames_of_interest = {};

    for k, v in pairs(action_bar_frame_names) do

        local frame = getfenv()[v];
        if frame then

            local action_id = action_id_of_button(frame);
            if action_id then
                local spell_id = 0;
                local action_type, id, _ = GetActionInfo(action_id);
                if action_type == "macro" then
                     spell_id, _ = GetMacroSpell(id);
                elseif action_type == "spell" then
                     spell_id = id;
                else
                    spell_id = 0;
                end
                if not spells[spell_id] then
                    spell_id = 0;
                end

                action_bar_frames_of_interest[action_id] = {};
                action_bar_frames_of_interest[action_id].frame = frame; 
                action_bar_frames_of_interest[action_id].spell_id = spell_id;

                init_frame_overlay(action_bar_frames_of_interest[action_id]);

            end
        end
    end
    

    return {
        bar_names = action_bar_frame_names,
        bars = action_bar_frames_of_interest,
        book = spell_book_frames
    };
end

local function reassign_overlay_icon_spell(action_id, spell_id, action_button_frame)

    if not spells[spell_id] then
        spell_id = 0;
    end

    if __sw__icon_frames.bars[action_id] then
        __sw__icon_frames.bars[action_id].spell_id = spell_id;
        for i = 1, 3 do
            __sw__icon_frames.bars[action_id].overlay_frames[i]:SetText("");
            __sw__icon_frames.bars[action_id].overlay_frames[i]:Hide();
        end
    end
end

local function reassign_overlay_icon(action_id)

    local spell_id = 0;
    local action_type, id, _ = GetActionInfo(action_id);
    if action_type == "macro" then
        spell_id, _ = GetMacroSpell(id);
    elseif action_type == "spell" then
         spell_id = id;
    else
        spell_id = 0;
    end
    -- NOTE: any action_id > 12 we might have mirrored action ids
    -- with Bar 1 due to shapeshifts, and forms taking over Bar 1
    -- so check if the action slot in bar 1 is the same
    if action_id > 12 then
        local mirrored_bar_id = (action_id-1)%12 + 1;
        local mirrored_action_button_frame = getfenv()[__sw__icon_frames.bar_names[mirrored_bar_id]];
        local mirrored_action_id = action_id_of_button(mirrored_action_button_frame);
        if mirrored_action_id == action_id then
            -- yep was mirrored, update that as well
            reassign_overlay_icon_spell(mirrored_bar_id, spell_id, mirrored_action_button_frame)
        end
    end
    local button_frame = getfenv()[__sw__icon_frames.bar_names[action_id]]; 

    reassign_overlay_icon_spell(action_id, spell_id, button_frame)
end

local function on_special_action_bar_changed()

    for i = 1, 12 do
    
        -- Hopefully the Actionbar host has updated the new action id of its 1-12 action id bar
        local frame = getfenv()[__sw__icon_frames.bar_names[i]];
        if frame then
    
            local action_id = action_id_of_button(frame);
                
            local spell_id = 0;
            local action_type, id, _ = GetActionInfo(action_id);
            if action_type == "macro" then
                 spell_id, _ = GetMacroSpell(id);
            elseif action_type == "spell" then
                 spell_id = id;
            else
                spell_id = 0;
            end

            reassign_overlay_icon_spell(action_id, spell_id, getfenv()[__sw__icon_frames.bar_names[action_id]]);
            reassign_overlay_icon_spell(i, spell_id, frame);
        end
    end

end

local function update_icon_overlay_settings()

    sw_frame.settings_frame.icon_overlay = {};
    
    local index = 1; 

    if sw_frame.settings_frame.icon_normal_effect:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.normal,
            color = {232.0/255, 225.0/255, 32.0/255}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_crit_effect:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.crit,
            color = {252.0/255, 69.0/255, 3.0/255}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_expected_effect:GetChecked() then 
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.expected,
            color = {255.0/256, 128/256, 0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_effect_per_sec:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.effect_per_sec,
            color = {255.0/256, 128/256, 0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_effect_per_cost:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.effect_per_cost,
            color = {0.0, 1.0, 1.0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_avg_cost:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.avg_cost,
            color = {0.0, 1.0, 1.0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_avg_cast:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.avg_cast,
            color = {215/256, 83/256, 234/256}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_hit:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.hit,
            color = {232.0/255, 225.0/255, 32.0/255}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_crit:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.crit_chance,
            color = {252.0/255, 69.0/255, 3.0/255}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_effect_until_oom:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.effect_until_oom,
            color = {255.0/256, 128/256, 0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_casts_until_oom:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.casts_until_oom,
            color = {0.0, 1.0, 0.0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_time_until_oom:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.time_until_oom,
            color = {0.0, 1.0, 0.0}
        };
        index = index + 1;
    end

    -- if 1, do bottom
    if not sw_frame.settings_frame.icon_overlay[2] then
        sw_frame.settings_frame.icon_overlay[3] = sw_frame.settings_frame.icon_overlay[1];
        sw_frame.settings_frame.icon_overlay[1] = nil;
    -- if 2, do top and bottom
    elseif not sw_frame.settings_frame.icon_overlay[3] then
        sw_frame.settings_frame.icon_overlay[3] = sw_frame.settings_frame.icon_overlay[2];
        sw_frame.settings_frame.icon_overlay[2] = nil;
    end

    sw_num_icon_overlay_fields_active = index - 1;

    -- hide existing overlay frames that should no longer exist
    for i = 1, 3 do

        if not sw_frame.settings_frame.icon_overlay[i] then
            for k, v in pairs(__sw__icon_frames.book) do
                if v.overlay_frames[i] then
                    v.overlay_frames[i]:Hide();
                end
            end
            for k, v in pairs(__sw__icon_frames.bars) do
                if v.overlay_frames[i] then
                    v.overlay_frames[i]:Hide();
                end
            end
        end
    end
end

local function setup_action_bars()
    __sw__icon_frames = gather_spell_icons();
    update_icon_overlay_settings();
end

local spell_cache = {};    

local overlay_label_handler = {
    [icon_stat_display.normal] = function(frame_overlay, spell, spell_effect, stats)
        frame_overlay:SetText(string.format("%d",
            (spell_effect.min_noncrit_if_hit + spell_effect.max_noncrit_if_hit)/2 + spell_effect.ot_if_hit + spell_effect.absorb));
    end,
    [icon_stat_display.crit] = function(frame_overlay, spell, spell_effect, stats)
        if spell_effect.ot_if_crit > 0  then
            frame_overlay:SetText(string.format("%d",
                (spell_effect.min_crit_if_hit + spell_effect.max_crit_if_hit)/2 + spell_effect.ot_if_crit + spell_effect.absorb));
        elseif spell_effect.min_crit_if_hit ~= 0.0 then
            frame_overlay:SetText(string.format("%d", 
                (spell_effect.min_crit_if_hit + spell_effect.max_crit_if_hit)/2 + spell_effect.ot_if_hit + spell_effect.absorb));
        else
            frame_overlay:SetText("");
        end
    end,
    [icon_stat_display.expected] = function(frame_overlay, spell, spell_effect, stats)
        frame_overlay:SetText(string.format("%d", spell_effect.expectation));
    end,
    [icon_stat_display.effect_per_sec] = function(frame_overlay, spell, spell_effect, stats)
        frame_overlay:SetText(string.format("%d", spell_effect.effect_per_sec));
    end,
    [icon_stat_display.effect_per_cost] = function(frame_overlay, spell, spell_effect, stats)
        frame_overlay:SetText(string.format("%.2f", spell_effect.effect_per_cost));
    end,
    [icon_stat_display.avg_cost] = function(frame_overlay, spell, spell_effect, stats)
        frame_overlay:SetText(string.format("%d", stats.cost));
    end,
    [icon_stat_display.avg_cast] = function(frame_overlay, spell, spell_effect, stats)
        frame_overlay:SetText(string.format("%.2f", stats.cast_time));
    end,
    [icon_stat_display.hit] = function(frame_overlay, spell, spell_effect, stats)
         if bit.band(spell.flags, bit.bor(spell_flags.heal, spell_flags.absorb)) == 0 then
            frame_overlay:SetText(string.format("%d%%", 100*stats.hit));
        else
            frame_overlay:SetText("");
        end
    end,
    [icon_stat_display.crit_chance] = function(frame_overlay, spell, spell_effect, stats)
    
        if stats.crit ~= 0 then
            frame_overlay:SetText(string.format("%.1f%%", 100*max(0, min(1, stats.crit))));
        else 
            frame_overlay:SetText("");
        end
    end,
    [icon_stat_display.casts_until_oom] = function(frame_overlay, spell, spell_effect, stats)
        frame_overlay:SetText(string.format("%.1f", spell_effect.num_casts_until_oom));
    end,
    [icon_stat_display.effect_until_oom] = function(frame_overlay, spell, spell_effect, stats)
        frame_overlay:SetText(string.format("%.0f", spell_effect.effect_until_oom));
    end,
    [icon_stat_display.time_until_oom] = function(frame_overlay, spell, spell_effect, stats)
        frame_overlay:SetText(string.format("%.1fs", spell_effect.time_until_oom));
    end,
};

local function update_spell_icon_frame(frame_info, spell, spell_id, loadout, effects)

    if sw_frame.settings_frame.icon_old_rank_warning:GetChecked() and loadout.lvl > spell.lvl_outdated and not __sw__debug__ then

        frame_info.overlay_frames[1]:SetPoint("TOP", 1, -3);
        frame_info.overlay_frames[2]:SetPoint("CENTER", 1, -1.5);
        frame_info.overlay_frames[3]:SetPoint("BOTTOM", 1, 0);

        frame_info.overlay_frames[1]:SetText("OLD");
        frame_info.overlay_frames[2]:SetText("RANK");
        frame_info.overlay_frames[3]:SetText("!!!");

        for i = 1, 3 do
            frame_info.overlay_frames[i]:SetTextColor(252.0/255, 69.0/255, 3.0/255); 
            frame_info.overlay_frames[i]:Show();
        end
        
        return;
    end

    if not spell_cache[spell_id] then
        spell_cache[spell_id] = {};
        spell_cache[spell_id].dmg = {};
        spell_cache[spell_id].heal = {};
    end
    local spell_variant = spell_cache[spell_id].dmg;
    if bit.band(spell.flags, spell_flags.heal) then
        spell_variant = spell_cache[spell_id].heal;
    end
    if not spell_variant.seq then

        spell_variant.seq = -1;
        spell_variant.stats = {};
        spell_variant.spell_effect = {};
    end
    local spell_effect = spell_variant.spell_effect;
    local stats = spell_variant.stats;
    if spell_cache[spell_id].seq ~= swc.core.sequence_counter then

        spell_cache[spell_id].seq = swc.core.sequence_counter;
        stats_for_spell(stats, spell, loadout, effects);
        spell_info(spell_effect, spell, stats, loadout, effects);
        cast_until_oom(spell_effect, stats, loadout, effects);
    end

    if bit.band(spell.flags, spell_flags.mana_regen) ~= 0 then

        if sw_frame.settings_frame.icon_mana_overlay:GetChecked() then
            frame_info.overlay_frames[3]:SetText(string.format("%d", math.ceil(spell_effect.mana_restored)));
            frame_info.overlay_frames[3]:SetTextColor(0.0, 1.0, 1.0);
            frame_info.overlay_frames[3]:Show();
        end

    elseif sw_num_icon_overlay_fields_active > 0 then
        for i = 1, 3 do
            
            if sw_frame.settings_frame.icon_overlay[i] then

                overlay_label_handler[sw_frame.settings_frame.icon_overlay[i].label_type](frame_info.overlay_frames[i], spell, spell_effect, stats);

                frame_info.overlay_frames[i]:SetTextColor(sw_frame.settings_frame.icon_overlay[i].color[1], 
                                                          sw_frame.settings_frame.icon_overlay[i].color[2], 
                                                          sw_frame.settings_frame.icon_overlay[i].color[3]);

                frame_info.overlay_frames[i]:Show();
            end
        end
    end
end

__sw__icon_frames = {};

local function update_spell_icons(loadout, effects)

    if swc.core.setup_action_bar_needed then
        setup_action_bars();
        swc.core.setup_action_bar_needed = false;
    end

    if swc.core.special_action_bar_changed then
        on_special_action_bar_changed();
        swc.core.special_action_bar_changed = false;
    end

    -- update spell book icons
    if SpellBookFrame:IsShown() then

        for k, v in pairs(__sw__icon_frames.book) do

            if v.frame then

                for i = 1, 3 do
                    v.overlay_frames[i]:Hide();
                end

                local spell_name = v.frame.SpellName:GetText();
                local spell_rank_name = v.frame.SpellSubName:GetText();
                local _, _, _, _, _, _, id = GetSpellInfo(spell_name, spell_rank_name);

                if v.frame:IsShown() and spells[id] then
                    local spell_name = GetSpellInfo(id);
                    -- TODO: icon overlay not working for healing version checkbox
                    if spells[id].healing_version and sw_frame.settings_frame.icon_heal_variant:GetChecked() then
                        update_spell_icon_frame(v, spells[id].healing_version, id, loadout, effects);
                    else
                        update_spell_icon_frame(v, spells[id], id, loadout, effects);
                    end
                end
            end
        end
    end

    -- update action bar icons
    for k, v in pairs(__sw__icon_frames.bars) do

        if v.frame then

            local id = v.spell_id;
            for i = 1, 3 do
                v.overlay_frames[i]:Hide();
            end
            if id ~= 0 and v.frame:IsShown() then

                if spells[id].healing_version and sw_frame.settings_frame.icon_heal_variant:GetChecked() then
                    update_spell_icon_frame(v, spells[id].healing_version, id, loadout, effects);
                else
                    update_spell_icon_frame(v, spells[id], id, loadout, effects);
                end
            end
        end
    end
end

local function update_overlay()

    if not sw_frame.settings_frame.icon_overlay_disable:GetChecked() then

        if not sw_frame.stat_comparison_frame:IsShown() or not sw_frame:IsShown() then
            update_spell_icons(active_loadout_and_effects());
        else
            local loadout, effects, effects_diffed = active_loadout_and_effects_diffed_from_ui()
            update_spell_icons(loadout, effects_diffed);
        end
    end
end

overlay.setup_action_bars            = setup_action_bars;
overlay.update_overlay               = update_overlay;
overlay.icon_stat_display            = icon_stat_display;
overlay.update_icon_overlay_settings = update_icon_overlay_settings;
overlay.reassign_overlay_icon        = reassign_overlay_icon;
overlay.clear_overlays               = clear_overlays;

swc.overlay = overlay;
