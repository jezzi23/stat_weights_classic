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

local magic_school                      = addonTable.magic_school;
local spell_name_to_id                  = addonTable.spell_name_to_id;
local spell_names_to_id                 = addonTable.spell_names_to_id;

local class                             = addonTable.class;
local stat                              = addonTable.stat;

local set_tiers = {
    pve_t1_1         = 1,
    pve_t2_1         = 2,
    pve_t3_1         = 3,
};

local function create_sets()

    local set_tier_ids = {};

    if class == "PRIEST" then

        -- t7 healing 
        --for i = 39514, 39519 do
        --    set_tier_ids[i] = set_tiers.pve_t7_1;
        --end

    elseif class == "DRUID" then
    elseif class == "SHAMAN" then

    elseif class == "WARLOCK" then
    elseif class == "MAGE" then
    elseif class == "PALADIN" then
    end

    return set_tier_ids;
end

local function create_set_effects() 

    if class == "PRIEST" then
        return {
            --[set_tiers.pve_t7_1] = function(num_pieces, loadout, effects)
            --    if num_pieces >= 2 then
            --        -- TODO: POM calculation done in later stage
            --    end
            --    if num_pieces >= 4 then
            --        local gh = spell_name_to_id["Greater Heal"];
            --        ensure_exists_and_add(effects.ability.cost_mod, gh, 0.05, 0.0);
            --    end
            --end,
        };

    elseif class == "DRUID" then
        return {
        };

    elseif class == "SHAMAN" then
        return {
        };

    elseif class == "WARLOCK" then
        return {
        };


    elseif class == "MAGE" then
        return {
        };

    elseif class == "PALADIN" then
        return {
        };
    end
end 


local function create_relics()
    if class == "PALADIN" then
        return {
            --[40705] = function(effects)
            --    ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Holy Light"], 113, 0.0);
            --end,
        };
    elseif class == "SHAMAN" then
        return {
        };
    elseif class == "DRUID" then
        return {
        };
    else 
        return {};
    end
    
end 

local set_items = create_sets();

local set_bonus_effects = create_set_effects();

local relics = create_relics();

local items = {
    --[45703] = function(effects)
    --    effects.raw.cost_flat = effects.raw.cost_flat + 44;
    --end,
};

local function detect_sets(loadout)
    -- go through equipment to find set pieces
    for k, v in pairs(set_tiers) do
        loadout.num_set_pieces[v] = 0;
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
    end
end

local function apply_equipment(loadout, effects)

    detect_sets(loadout);

    local found_anything = false;

    local relic_id = GetInventoryItemID("player", 18);
    if relic_id and relics[relic_id] then
        relics[relic_id](effects);
    end

    local trinket1 = GetInventoryItemID("player", 13);
    local trinket2 = GetInventoryItemID("player", 14);
    if trinket1 and items[trinket1] then
        items[trinket1](effects);
    end
    if trinket2 and items[trinket2] then
        items[trinket2](effects);
    end
    
    for k, v in pairs(loadout.num_set_pieces) do
        if v >= 2 then
            if set_bonus_effects[k] then
                set_bonus_effects[k](v, loadout, effects);
            end
        end
    end

    -- NOTE: shortly after logging in, the equipment querying API won't work
    --       (but does for /reload). Track if we get nothing so we can signal
    --       that equipment scanning needs to be done again on next update
    for item = 1, 18 do
        local item_link = GetInventoryItemLink("player", item);
        if item_link then
            found_anything = true;
            local item_stats = GetItemStats(item_link);
            if item_stats then

                if item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] then
                    effects.raw.mp5 = effects.raw.mp5 + item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] + 1;
                end

                -- TODO VANILLA
                --if item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] then
                --    for i = 2,7 do
                --        loadout.target_res_by_school[i] = 
                --            loadout.target_res_by_school[i] - (item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] - 1);
                --    end
                --end
            end
        end
    end

    return found_anything;
end

addonTable.set_tiers = set_tiers;
addonTable.apply_equipment = apply_equipment;
