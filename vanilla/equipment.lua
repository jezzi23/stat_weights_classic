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

local ensure_exists_and_add             = swc.utils.ensure_exists_and_add;
local ensure_exists_and_mul             = swc.utils.ensure_exists_and_mul;
local class                             = swc.utils.class;
local stat                              = swc.utils.stat;

local magic_school                      = swc.abilities.magic_school;
local spell_name_to_id                  = swc.abilities.spell_name_to_id;
local spell_names_to_id                 = swc.abilities.spell_names_to_id;

--------------------------------------------------------------------------------
local equipment = {};

local set_tiers = {
    pve_0            = 1,
    pve_0_5          = 2,
    pve_1            = 3,
    pve_2            = 4,
    pve_3            = 5,
    pve_2_5_0        = 6, -- zg
    pve_2_5_1        = 7, -- aq20
    pve_2_5_2        = 8, -- aq40
    pve_3            = 9,
    pvp_1            = 10,
    pvp_2            = 11,
};

local function create_sets()

    local set_tier_ids = {};

    if class == "PRIEST" then

        -- t1
        for i = 16811, 16819 do
            set_tier_ids[i] = set_tiers.pve_1;
        end
        -- t2
        for i = 16919, 16926 do
            set_tier_ids[i] = set_tiers.pve_2;
        end
        -- aq20
        for i = 21410, 21412 do
            set_tier_ids[i] = set_tiers.pve_2_5_1;
        end

        -- aq40
        for i = 21348, 21352 do
            set_tier_ids[i] = set_tiers.pve_2_5_2;
        end

        --naxx
        for i = 22512, 22519 do
            set_tier_ids[i] = set_tiers.pve_3;
        end
        set_tier_ids[23061] = set_tiers.pve_3;

    elseif class == "DRUID" then

        -- t1
        for i = 16828, 16836 do
            set_tier_ids[i] = set_tiers.pve_1;
        end

        -- t2
        for i = 16897, 16904 do
            set_tier_ids[i] = set_tiers.pve_2;
        end

        -- zg
        set_tier_ids[19955] = set_tiers.pve_2_5_0;
        set_tier_ids[19613] = set_tiers.pve_2_5_0;
        set_tier_ids[19840] = set_tiers.pve_2_5_0;
        set_tier_ids[19839] = set_tiers.pve_2_5_0;
        set_tier_ids[19838] = set_tiers.pve_2_5_0;

        --naxx
        for i = 22488, 22495 do
            set_tier_ids[i] = set_tiers.pve_3;
        end
        set_tier_ids[23064] = set_tiers.pve_3;
    elseif class == "SHAMAN" then
        -- t1
        for i = 16837, 16844 do
            set_tier_ids[i] = set_tiers.pve_1;
        end
        -- t2
        for i = 16943, 16950 do
            set_tier_ids[i] = set_tiers.pve_2;
        end
        -- pvp set has non linear ids
        set_tier_ids[22857] = set_tiers.pvp_1;
        set_tier_ids[22867] = set_tiers.pvp_1;
        set_tier_ids[22876] = set_tiers.pvp_1;
        set_tier_ids[22887] = set_tiers.pvp_1;
        set_tier_ids[23259] = set_tiers.pvp_1;
        set_tier_ids[23260] = set_tiers.pvp_1;

        set_tier_ids[16577] = set_tiers.pvp_2;
        set_tier_ids[16578] = set_tiers.pvp_2;
        set_tier_ids[16580] = set_tiers.pvp_2;
        set_tier_ids[16573] = set_tiers.pvp_2;
        set_tier_ids[16574] = set_tiers.pvp_2;
        set_tier_ids[16579] = set_tiers.pvp_2;

        --zg
        set_tier_ids[19609] = set_tiers.pve_2_5_0;
        set_tier_ids[19956] = set_tiers.pve_2_5_0;
        set_tier_ids[19830] = set_tiers.pve_2_5_0;
        set_tier_ids[19829] = set_tiers.pve_2_5_0;
        set_tier_ids[19828] = set_tiers.pve_2_5_0;

        -- aq20
        for i = 21398, 21400 do
            set_tier_ids[i] = set_tiers.pve_2_5_1;
        end

        -- aq40
        for i = 21372, 21376 do
            set_tier_ids[i] = set_tiers.pve_2_5_2;
        end

        --naxx
        for i = 22464, 22471 do
            set_tier_ids[i] = set_tiers.pve_3;
        end
        set_tier_ids[23065] = set_tiers.pve_3;

    elseif class == "WARLOCK" then
        for i = 16803, 16810 do
            set_tier_ids[i] = set_tiers.pve_1;
        end

        -- ally
        set_tier_ids[23296] = set_tiers.pvp_1;
        set_tier_ids[23297] = set_tiers.pvp_1;
        set_tier_ids[23283] = set_tiers.pvp_1;
        set_tier_ids[23311] = set_tiers.pvp_1;
        set_tier_ids[23282] = set_tiers.pvp_1;
        set_tier_ids[23310] = set_tiers.pvp_1;

        set_tier_ids[17581] = set_tiers.pvp_2;
        set_tier_ids[17580] = set_tiers.pvp_2;
        set_tier_ids[17583] = set_tiers.pvp_2;
        set_tier_ids[17584] = set_tiers.pvp_2;
        set_tier_ids[17579] = set_tiers.pvp_2;
        set_tier_ids[17578] = set_tiers.pvp_2;
        -- horde
        set_tier_ids[22865] = set_tiers.pvp_1;
        set_tier_ids[22855] = set_tiers.pvp_1;
        set_tier_ids[23255] = set_tiers.pvp_1;
        set_tier_ids[23256] = set_tiers.pvp_1;
        set_tier_ids[22881] = set_tiers.pvp_1;
        set_tier_ids[22884] = set_tiers.pvp_1;

        set_tier_ids[17586] = set_tiers.pvp_2;
        set_tier_ids[17588] = set_tiers.pvp_2;
        set_tier_ids[17593] = set_tiers.pvp_2;
        set_tier_ids[17591] = set_tiers.pvp_2;
        set_tier_ids[17590] = set_tiers.pvp_2;
        set_tier_ids[17592] = set_tiers.pvp_2;

        -- zg
        set_tier_ids[19957] = set_tiers.pve_2_5_0;
        set_tier_ids[19605] = set_tiers.pve_2_5_0;
        set_tier_ids[19848] = set_tiers.pve_2_5_0;
        set_tier_ids[19849] = set_tiers.pve_2_5_0;
        set_tier_ids[20033] = set_tiers.pve_2_5_0;

        -- aq40      
        for i = 21334, 21338 do
            set_tier_ids[i] = set_tiers.pve_2_5_2;
        end

        --naxx
        for i = 22504, 22511 do
            set_tier_ids[i] = set_tiers.pve_3;
        end
        set_tier_ids[23063] = set_tiers.pve_3;
    elseif class == "MAGE" then
        -- zg
        set_tier_ids[19601] = set_tiers.pve_2_5_0;
        set_tier_ids[19959] = set_tiers.pve_2_5_0;
        set_tier_ids[19846] = set_tiers.pve_2_5_0;
        set_tier_ids[20034] = set_tiers.pve_2_5_0;
        set_tier_ids[19845] = set_tiers.pve_2_5_0;

        -- aq20
        for i = 21413, 21415 do
            set_tier_ids[i] = set_tiers.pve_2_5_1;
        end

        -- t1
        for i = 16795, 16802 do
            set_tier_ids[i] = set_tiers.pve_1;
        end

        -- t2
        set_tier_ids[16818] = set_tiers.pve_2;
        set_tier_ids[16912] = set_tiers.pve_2;
        set_tier_ids[16913] = set_tiers.pve_2;
        set_tier_ids[16914] = set_tiers.pve_2;
        set_tier_ids[16915] = set_tiers.pve_2;
        set_tier_ids[16916] = set_tiers.pve_2;
        set_tier_ids[16917] = set_tiers.pve_2;
        set_tier_ids[16918] = set_tiers.pve_2;

    elseif class == "PALADIN" then
        -- zg
        set_tier_ids[19588] = set_tiers.pve_2_5_0;
        set_tier_ids[19952] = set_tiers.pve_2_5_0;
        set_tier_ids[19827] = set_tiers.pve_2_5_0;
        set_tier_ids[19826] = set_tiers.pve_2_5_0;
        set_tier_ids[19825] = set_tiers.pve_2_5_0;
    end

    return set_tier_ids;
end

local function create_set_effects() 

    if class == "PRIEST" then
        return {
            [set_tiers.pve_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 3 then
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Flash Heal"], 0.1, 0.0);
                end
                if num_pieces >= 8 then
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Prayer of Healing"], 0.25, 0.0);
                end
            end,
            [set_tiers.pve_2] = function(num_pieces, loadout, effects)
                if num_pieces >= 3 then
                    effects.raw.regen_while_casting = effects.raw.regen_while_casting + 0.15;
                end
            end,
            [set_tiers.pve_2_5_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 3 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Shadow Word: Pain"], 0.05, 0.0);
                end
            end,
            [set_tiers.pve_2_5_2] = function(num_pieces, loadout, effects)
                if num_pieces >= 5 then
                    ensure_exists_and_add(effects.ability.extra_ticks, spell_name_to_id["Renew"], 1, 0.0);
                end
            end,
            [set_tiers.pve_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Renew"], 0.12, 0.0);
                end
            end,
        };

    elseif class == "DRUID" then
        return {
            [set_tiers.pve_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 3 then
                    ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Thorns"], 4, 0.0);
                end
            end,
            [set_tiers.pve_2] = function(num_pieces, loadout, effects)
                if num_pieces >= 3 then
                    effects.raw.regen_while_casting = effects.raw.regen_while_casting + 0.15;
                end
                if num_pieces >= 5 then
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Regrowth"], 0.2, 0.0);
                end
                if num_pieces >= 8 then
                    ensure_exists_and_add(effects.ability.extra_ticks, spell_name_to_id["Rejuvenation"], 1, 0.0);
                end
            end,
            [set_tiers.pve_2_5_0] = function(num_pieces, loadout, effects)
                if num_pieces >= 5 then
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Starfire"], 0.03, 0.0);
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Starsurge"], 0.03, 0.0);
                end
            end,
            [set_tiers.pve_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 4 then
                    local spells = spell_names_to_id({"Healing Touch", "Regrowth", "Rejuvenation", "Tranquility", "Nourish"});
                    for k, v in pairs(spells) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, 0.03, 0.0);
                    end
                end
            end,
        };

    elseif class == "SHAMAN" then
        return {
            [set_tiers.pve_2_5_0] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    effects.raw.mp5 = effects.raw.mp5 + 4;
                end
            end,
            [set_tiers.pve_2_5_2] = function(num_pieces, loadout, effects)
                if num_pieces >= 5 then
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Chain Heal"], 0.4, 0.0);
                end
            end,
            [set_tiers.pve_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    local spells = spell_names_to_id({"Healing Stream Totem", "Magma Totem", "Searing Totem", "Mana Tide", "Fire Nova Totem"});
                    for k, v in pairs(spells) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, 0.03, 0.0);
                    end
                end
                if num_pieces >= 6 then
                    --TODO VANILLA: Totem power, buff tracking
                end
            end,
            [set_tiers.pvp_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 4 then
                    local shocks = spell_names_to_id({"Earth Shock", "Flame Shock", "Frost Shock"});
                    for k, v in pairs(shocks) do
                        ensure_exists_and_add(effects.ability.crit, v, 0.02, 0.0);
                    end
                end
            end,
            [set_tiers.pvp_2] = function(num_pieces, loadout, effects)
                if num_pieces >= 4 then
                    local shocks = spell_names_to_id({"Earth Shock", "Flame Shock", "Frost Shock"});
                    for k, v in pairs(shocks) do
                        ensure_exists_and_add(effects.ability.crit, v, 0.02, 0.0);
                    end
                end
            end,
        };

    elseif class == "WARLOCK" then
        return {
            [set_tiers.pve_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 3 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Drain Life"], 0.15, 0.0);
                end
                if num_pieces >= 8 then
                    local shadow = spell_names_to_id({"Curse of Doom", "Death Coil", "Curse of Agony", "Drain Life", "Corruption", "Shadow Ward", "Drain Soul"});
                    for k, v in pairs(shadow) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, 0.15, 0.0);
                    end
                end
            end,
            [set_tiers.pve_2_5_0] = function(num_pieces, loadout, effects)
                if num_pieces >= 3 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Corruption"], 0.02, 0.0);
                end
            end,
            [set_tiers.pve_2_5_2] = function(num_pieces, loadout, effects)
                if num_pieces >= 3 then
                    ensure_exists_and_add(effects.ability.effect_mod_base, spell_name_to_id["Immolate"], 0.05, 0.0);
                end
                if num_pieces >= 5 then
                    ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Shadow Bolt"], 0.15, 0.0);
                end
            end,
            [set_tiers.pve_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 4 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Corruption"], 0.12, 0.0);
                end
            end,
            [set_tiers.pvp_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 3 then
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Immolate"], 0.2, 0.0);
                end
            end,
            [set_tiers.pvp_2] = function(num_pieces, loadout, effects)
                if num_pieces >= 3 then
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Immolate"], 0.2, 0.0);
                end
            end,
        };


    elseif class == "MAGE" then
        return {
            [set_tiers.pve_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 5 then
                    for i = 2,7 do
                        effects.by_school.target_res[i] = 
                            effects.by_school.target_res[i] - 10;
                    end
                end
            end,
            [set_tiers.pve_2_5_0] = function(num_pieces, loadout, effects)
                if num_pieces >= 5 then
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Flamestrike"], 0.5, 0.0);
                end
            end,
            [set_tiers.pve_2_5_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 3 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Mana Shield"], 0.15, 0.0);
                end
            end,
        };

    elseif class == "PALADIN" then
        -- TODO VANILLA: Tier3 holy power buff tracking
        return {
            [set_tiers.pve_2_5_0] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    effects.raw.mp5 = effects.raw.mp5 + 4;
                end
                if num_pieces >= 3 then
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Holy Light"], 0.1, 0.0);
                end
            end,
        };
    end
end 


local function create_relics()
    if class == "PALADIN" then
        return {
            [23201] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 53, 0.0);
            end,
            [23202] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 53, 0.0);
            end,
            [23006] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 83, 0.0);
            end,
        };
    elseif class == "SHAMAN" then
        return {
            [22395] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Earth Shock"], 30, 0.0);
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flame Shock"], 30, 0.0);
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Frost Shock"], 30, 0.0);
            end,
            [23200] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lesser Healing Wave"], 53, 0.0);
            end,
            [22396] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lesser Healing Wave"], 80, 0.0);
            end,
            [23199] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Chain Lightning"], 33, 0.0);
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lightning Bolt"], 33, 0.0);
            end,
            [23005] = function(effects)
                ensure_exists_and_add(effects.ability.refund, spell_name_to_id["Lesser Healing Wave"], 10, 0.0);
            end,
        };
    elseif class == "DRUID" then
        return {
            [22398] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Rejuvenation"], 50, 0.0);
            end,
            [23197] = function(effects)
                ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Moonfire"], 0.17, 0.0);
                ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Sunfire"], 0.17, 0.0);
            end,
            [22399] = function(effects)
                ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Healing Touch"], 0.15, 0.0);
                ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Nourish"], 0.15, 0.0);
            end,
            [23004] = function(effects)
                ensure_exists_and_add(effects.ability.refund, spell_name_to_id["Healing Touch"], 25, 0.0);
            end,
        };
    else 
        return {};
    end
    
end 

local set_items = create_sets();

local set_bonus_effects = create_set_effects();

local relics = create_relics();

local function create_items()
    if class == "PRIEST" then
        return {
            [19594] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Power Word: Shield"], 35, 0.0);
            end,
        };
    else
        return {};
    end
end

local items = create_items();

local function detect_sets(loadout)
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
    -- TODO VANILLA: special items like zg necks

    local relic_id = GetInventoryItemID("player", 18);
    if relic_id and relics[relic_id] then
        relics[relic_id](effects);
    end

    --local trinket1 = GetInventoryItemID("player", 13);
    --local trinket2 = GetInventoryItemID("player", 14);
    --if trinket1 and items[trinket1] then
    --    items[trinket1](effects);
    --end
    --if trinket2 and items[trinket2] then
    --    items[trinket2](effects);
    --end
    
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
    loadout.crit_rating = 0;
    for item = 1, 18 do
        local item_link = GetInventoryItemLink("player", item);
        if item_link then
            local item_id = GetInventoryItemID("player", i);
            if item_id and items[item_id] then
                items[item_id](effects);
            end
            found_anything = true;
            local item_stats = GetItemStats(item_link);
            if item_stats then
                -- TODO: Track spell crit for int per crit calc correction

                if item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] then
                    effects.raw.mp5 = effects.raw.mp5 + item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] + 1;
                end

                if item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] then
                    for i = 2,7 do
                        effects.by_school.target_res[i] = 
                            effects.by_school.target_res[i] - (item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] - 1);
                    end
                end
            end
        end
    end

    if swc.core.__sw__test_all_codepaths then
        for k, v in pairs(items) do
            if v then
                v(effects);
            end
        end
        for _, v in pairs(relics) do
            if v then
                v(effects);
            end
        end
        for k, v in pairs(loadout.num_set_pieces) do
            if set_bonus_effects[k] then
                set_bonus_effects[k](10, loadout, effects);
            end
        end
    end

    return found_anything;
end

equipment.set_tiers = set_tiers;
equipment.apply_equipment = apply_equipment;

swc.equipment = equipment;
