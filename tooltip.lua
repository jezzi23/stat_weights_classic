local _, sc = ...;

local spells                                    = sc.abilities.spells;
local spell_flags                               = sc.spell_flags;
local next_rank                                 = sc.abilities.next_rank;
local best_rank_by_lvl                          = sc.abilities.best_rank_by_lvl;

local effect_colors                             = sc.utils.effect_colors;

local update_loadout_and_effects                = sc.loadout.update_loadout_and_effects;
local update_loadout_and_effects_diffed_from_ui = sc.loadout.update_loadout_and_effects_diffed_from_ui;

local config                                    = sc.config;
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

local function format_bounce_spell(min_hit, max_hit, bounces, falloff)
    local bounce_str = "     + ";
    for _ = 1, bounces - 1 do
        bounce_str = bounce_str .. string.format(" %d-%d  + ",
            falloff * math.floor(min_hit),
            falloff * math.ceil(max_hit));
        falloff = falloff * falloff;
    end
    bounce_str = bounce_str .. string.format(" %d-%d",
        falloff * math.floor(min_hit),
        falloff * math.ceil(max_hit));
    return bounce_str;
end

local function append_tooltip_spell_rank(tooltip, spell, lvl)
    if spell.rank == 0 then
        return;
    end


    local next_r = next_rank(spell);
    local best = best_rank_by_lvl(spell, lvl);
    local rank_str = "";
    if spell.lvl_req > lvl then
        rank_str = rank_str.."Trained at level "..spell.lvl_req;
    elseif best and best.rank ~= spell.rank then
        rank_str = rank_str.."Downranked. Best available is rank "..best.rank;
    elseif next_r then
        rank_str = rank_str.."Next rank "..next_r.rank.." available at level "..next_r.lvl_req;
    end

    if rank_str ~= "" then
        tooltip:AddLine(rank_str,
            effect_colors.spell_rank[1], effect_colors.spell_rank[2], effect_colors.spell_rank[3]);
    end
end

local spell_jump_itr = pairs(spells);
local spell_jump_key = spell_jump_itr(spells);

CreateFrame("GameTooltip", "sc_stat_calc_tooltip", nil, "GameTooltipTemplate" );
sc_stat_calc_tooltip:SetOwner(GameTooltip, "ANCHOR_LEFT" );
-- TODO: Font of this tooltip appears much bigger even though same font is used?
sc_stat_calc_tooltip:AddFontStrings(
--    --sc_stat_calc_tooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipTextSmall"),
--    --sc_stat_calc_tooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipTextSmall")
--
    sc_stat_calc_tooltip:CreateFontString("$parentHeaderText", nil, "GameTooltipHeaderText"),
    sc_stat_calc_tooltip:CreateFontString("$parentText", nil, "GameTooltipText"),
    sc_stat_calc_tooltip:CreateFontString("$parentTextSmall", nil, "GameTooltipTextSmall")
    --sc_stat_calc_tooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
);
--

sc_stat_calc_tooltipHeaderText:SetFont(GameTooltipHeaderText:GetFont())
sc_stat_calc_tooltipText:SetFont(GameTooltipText:GetFont())
sc_stat_calc_tooltipTextSmall:SetFont(GameTooltipTextSmall:GetFont())
--sc_stat_calc_tooltip
--for _, v in pairs({GameTooltipHeaderText, GameTooltipText GameTooltipTextSmall}) do
--for _, v in pairs({GameTooltipHeaderText, GameTooltipText GameTooltipTextSmall}) do
--    local fnt, sz = 
--end

GameTooltip:HookScript("OnHide", function()
    sc_stat_calc_tooltip:Hide();
end);


local spell_id_of_cleared_tooltip = 0;
local clear_tooltip_refresh_id = 463;

local function update_tooltip(tooltip)


    if sc.core.__sw__test_all_spells and __sc_frame.spells_frame:IsShown() then

        spell_jump_key = spell_jump_itr(spells, spell_jump_key);
        if not spell_jump_key then
            spell_jump_key = spell_jump_itr(spells);
        end
        __sc_frame.spell_id_viewer_editbox:SetText(tostring(spell_jump_key));
    end
    --tooltips update dynamically without debug setting
    if not (PlayerTalentFrame and MouseIsOver(PlayerTalentFrame)) and
        not sc.core.__sw__debug__ and tooltip:IsShown() then

        local spell_name, id = tooltip:GetSpell();
        if not spell_name then
            -- Attack tooltip may be a dummy, so link it to its actual spell id
            local attack_lname = GetSpellInfo(sc.auto_attack_spell_id);
            local txt = getglobal("GameTooltipTextLeft1");
            if txt and txt:GetText() == attack_lname then
                spell_name = attack_lname;
                id = sc.auto_attack_spell_id;
            end
        end

        -- Workaround: need to set some spell id that exists to get tooltip refreshed when
        --            looking at custom spell id tooltip
        if spells[id] or id == clear_tooltip_refresh_id or id == __sc_frame.spell_viewer_invalid_spell_id then
            if  id ~= clear_tooltip_refresh_id then
                spell_id_of_cleared_tooltip = id;
            end
            if id == __sc_frame.spell_viewer_invalid_spell_id then
                tooltip:SetSpellByID(__sc_frame.spell_viewer_invalid_spell_id);
            elseif config.settings.tooltip_clear_original then
                if (not config.settings.tooltip_shift_to_show or IsShiftKeyDown()) and
                    bit.band(spells[spell_id_of_cleared_tooltip].flags, spell_flags.eval) ~= 0 then
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

local function write_tooltip_spell_info(tooltip, spell, spell_id, loadout, effects, repeated_tooltip_on)
    -- Set gray spell rank in upper-right corner again after custom SetSpellByID clears it
    if spell.rank ~= 0 then
        local txt_right = getglobal("GameTooltipTextRight1");
        if txt_right then
            txt_right:SetTextColor(0.50196081399918, 0.50196081399918, 0.50196081399918, 1.0);
            txt_right:SetText("Rank " .. spell.rank);
            txt_right:Show();
        end
    end

    if __sc_frame.tooltip_frame.tooltip_num_checked == 0 or
        (config.settings.tooltip_shift_to_show and not IsShiftKeyDown()) then
        return;
    end

    local eval_flags = 0;
    if IsAltKeyDown() then
        eval_flags = bit.bor(eval_flags, sc.calc.evaluation_flags.assume_single_effect);
        if loadout.m2_speed then
            eval_flags = bit.bor(eval_flags, sc.calc.evaluation_flags.isolate_offhand);
        end
    end

    if IsControlKeyDown() then
        local dir = GetPlayerFacing();
        if dir and math.abs(dir - math.pi) > 0.5 * math.pi then
            -- facing north
            eval_flags = bit.bor(eval_flags, sc.calc.evaluation_flags.isolate_periodic);
        else
            eval_flags = bit.bor(eval_flags, sc.calc.evaluation_flags.isolate_direct);
        end
    end

    -- was begin section
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

    if (bit.band(spell.flags, spell_flags.eval) ~= 0) then
        if tooltip == GameTooltip then
            if config.settings.tooltip_display_addon_name then
                local loadout_extra_info = "";
                if config.loadout.use_custom_lvl then
                    loadout_extra_info = string.format(" (clvl %d)", config.loadout.lvl);
                end
                tooltip:AddLine("SpellCoda v"..sc.core.version.." | "..config.loadout.name..loadout_extra_info, 1, 1, 1);
            end
            if __sc_frame.calculator_frame:IsShown() and __sc_frame:IsShown() then
                tooltip:AddLine("AFTER STAT CHANGES", 1.0, 0.0, 0.0);
            end
        else
            tooltip:AddLine("BEFORE STAT CHANGES", 1.0, 0.0, 0.0);
        end
        sc.tooltip.append_tooltip_spell_info(tooltip, spell, spell_id, loadout, effects, eval_flags, repeated_tooltip_on);
        if spell.healing_version then
            -- used for holy nova
            sc.tooltip.append_tooltip_spell_info(tooltip, spell.healing_version, spell_id, loadout, effects, eval_flags, true);
        end
    else

        if config.settings.tooltip_display_spell_rank and not repeated_tooltip_on then
            append_tooltip_spell_rank(tooltip, spell, loadout.lvl);
        end
        if config.settings.tooltip_display_spell_id and not repeated_tooltip_on then
            tooltip:AddLine(string.format("Spell ID: %d", spell_id),
                effect_colors.spell_rank[1], effect_colors.spell_rank[2], effect_colors.spell_rank[3]);
        end
    end
    tooltip:Show();
end

local function tooltip_spell_info(is_fake)

    local _, spell_id = GameTooltip:GetSpell();

    if spell_id == clear_tooltip_refresh_id then
        spell_id = spell_id_of_cleared_tooltip;
    elseif spell_id == __sc_frame.spell_viewer_invalid_spell_id then
        spell_id = tonumber(__sc_frame.spell_id_viewer_editbox:GetText());
    elseif config.settings.tooltip_clear_original and (not config.settings.tooltip_shift_to_show or IsShiftKeyDown()) then
        --if spells[spell_id] and bit.band(spells[spell_id].flags, spell_flags.eval) ~= 0 then
        if spells[spell_id] then
            spell_id_of_cleared_tooltip = spell_id;
            --GameTooltip:ClearLines();
            --GameTooltip:SetSpellByID(clear_tooltip_refresh_id);
            return;
        end
    end

    local spell = spells[spell_id];

    if not spell then
        return;
    end

    if not __sc_frame.calculator_frame:IsShown() or not __sc_frame:IsShown() then

        local loadout, effects = update_loadout_and_effects();
        write_tooltip_spell_info(GameTooltip, spell, spell_id, loadout, effects, nil);
    else

        local loadout, effects, effects_diffed = update_loadout_and_effects_diffed_from_ui();
        write_tooltip_spell_info(GameTooltip, spell, spell_id, loadout, effects_diffed, nil);

        sc_stat_calc_tooltip:ClearLines();
        sc_stat_calc_tooltip:SetOwner(GameTooltip, "ANCHOR_LEFT", 0, -select(2, sc_stat_calc_tooltip:GetSize()));
        write_tooltip_spell_info(sc_stat_calc_tooltip, spell, spell_id, loadout, effects, nil);
    end
end




tooltip_export.tooltip_stat_display             = tooltip_stat_display;
tooltip_export.sort_stat_weights                = sort_stat_weights;
tooltip_export.format_bounce_spell              = format_bounce_spell;
tooltip_export.tooltip_spell_info               = tooltip_spell_info;
tooltip_export.update_tooltip                   = update_tooltip;
tooltip_export.append_tooltip_spell_rank        = append_tooltip_spell_rank;

sc.tooltip = tooltip_export;

