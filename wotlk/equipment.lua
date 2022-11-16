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
local ensure_exists_and_add             = addonTable.ensure_exists_and_add;
local ensure_exists_and_mul             = addonTable.ensure_exists_and_mul;

local spell_name_to_id                  = addonTable.spell_name_to_id;
local spell_names_to_id                 = addonTable.spell_names_to_id;

local class                             = addonTable.class;

local set_tiers = {
    pve_t7_1         = 1,
    pve_t7_2         = 2,
    pve_t7_3         = 3,
};

local function create_sets()

    local set_tier_ids = {};

    if class == "PRIEST" then

        -- t7 healing 
        for i = 39514, 39519 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        for i = 40445, 40450 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        -- t7 shadow
        set_tier_ids[39521] = set_tiers.pve_t7_3;
        set_tier_ids[39523] = set_tiers.pve_t7_3;
        for i = 39528, 39530 do
            set_tier_ids[i] = set_tiers.pve_t7_3;
        end
        set_tier_ids[40454] = set_tiers.pve_t7_3;
        for i = 40456, 40459 do
            set_tier_ids[i] = set_tiers.pve_t7_3;
        end

    elseif class == "DRUID" then
        -- t7 balance
        for i = 39544, 39548 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        for i = 40466, 40470 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        -- t7 resto
        for i = 40460, 40463 do
            set_tier_ids[i] = set_tiers.pve_t7_3;
        end
        set_tier_ids[40465] = set_tiers.pve_t7_3;

        set_tier_ids[39531] = set_tiers.pve_t7_3;
        set_tier_ids[39538] = set_tiers.pve_t7_3;
        set_tier_ids[39539] = set_tiers.pve_t7_3;
        set_tier_ids[39542] = set_tiers.pve_t7_3;
        set_tier_ids[39543] = set_tiers.pve_t7_3;

    elseif class == "SHAMAN" then

    elseif class == "WARLOCK" then

    elseif class == "MAGE" then


    elseif class == "PALADIN" then
        -- t7 holy
        for i = 39628, 39632 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        for i = 40569, 40573 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
    end

    return set_tier_ids;
end

local function create_set_effects() 

    if class == "PRIEST" then
        return {
            [set_tiers.pve_t7_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    -- TODO: POM calculation done in later stage
                end
                if num_pieces >= 4 then
                    local gh = spell_name_to_id["Greater Heal"];
                    ensure_exists_and_add(effects.ability.cost_mod, gh, 0.05, 0.0);
                end
            end,
            [set_tiers.pve_t7_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    local mb = spell_name_to_id["Mind Blast"];
                    ensure_exists_and_add(effects.ability.cost_mod, mb, 0.1, 0.0);
                end
                if num_pieces >= 4 then
                    local swd = spell_name_to_id["Shadow Word: Death"];
                    ensure_exists_and_add(effects.ability.crit, swd, 0.1, 0.0);
                end
            end,
        };

    elseif class == "DRUID" then
        return {
            [set_tiers.pve_t7_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    local is = spell_name_to_id["Insect Swarm"];
                    ensure_exists_and_add(effects.ability.effect_mod, is, 0.1, 0.0);
                    
                end
                if num_pieces >= 4 then
                    local abilities = spell_names_to_id({"Wrath", "Starfire"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.crit, v, 0.05, 0.0);
                    end
                end
            end,
            [set_tiers.pve_t7_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    local lb = spell_name_to_id["Lifebloom"];
                    ensure_exists_and_add(effects.ability.cost_mod, lb, 0.05, 0.0);
                end
                if num_pieces >= 4 then
                    -- TODO: awkward to implement, could track hots on target and estimate
                end
            end,
        };

    elseif class == "SHAMAN" then

    elseif class == "WARLOCK" then

    elseif class == "MAGE" then

    elseif class == "PALADIN" then
        return {
            [set_tiers.pve_t7_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    local hs = spell_name_to_id["Holy Shock"];
                    ensure_exists_and_add(effects.ability.crit, hs, 0.1, 0.0);

                end
                if num_pieces >= 4 then
                    local hl = spell_name_to_id["Holy Light"];
                    ensure_exists_and_add(effects.ability.cost_mod, hl, 0.05, 0.0);
                end
            end,
        };
    end
end 


local set_items = create_sets();

local set_bonus_effects = create_set_effects();

local function detect_sets(loadout)
    -- go through equipment to find set pieces
    for k, v in pairs(loadout.num_set_pieces) do
        loadout.num_set_pieces[k] = 0;
    end

    for item = 1, 18 do
        local id = GetInventoryItemID("player", item);
        if set_items[id] then
            set_id = set_items[id];
            if not loadout.num_set_pieces[set_id] then
                loadout.num_set_pieces[set_id] = 0;
            end
            loadout.num_set_pieces[set_id] = loadout.num_set_pieces[set_id] + 1;
        end
        --local item_link = GetInventoryItemLink("player", item);
        --if item_link then
        --    local item_stats = GetItemStats(item_link);
        --    if item_stats then

        --        if item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] then
        --            loadout.mp5 = loadout.mp5 + item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] + 1;
        --        end

        --        if item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] then
        --            for i = 2,7 do
        --                loadout.target_res_by_school[i] = 
        --                    loadout.target_res_by_school[i] - (item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] - 1);
        --            end
        --        end
        --    end
        --end
    end
end

local function apply_equipment(loadout, effects)

    -- head slot gems
    for _, v in pairs({GetInventoryItemGems(1)}) do
        -- chaotic skyflare diamond 3% crit dmg, totally janky behaviour
        if v == 41285 or v == 34220 then
            effects.raw.special_crit_mod = effects.raw.special_crit_mod + 0.045;
        end
    end
    -- TODO: idols
    for k, v in pairs(loadout.num_set_pieces) do
        set_bonus_effects[k](v, loadout, effects);
    end
end

addonTable.set_tiers = set_tiers;
addonTable.detect_sets = detect_sets;
addonTable.apply_equipment = apply_equipment;
