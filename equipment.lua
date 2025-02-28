local _, sc = ...;

local attr                             = sc.attr;
local apply_effect                     = sc.loadouts.apply_effect;
local special_item_properties          = sc.loadouts.special_item_properties;
---------------------------------------------------------------------------------------------------
local equipment = {};

-- TODO: retire this, maybe keep some of the old behaviour using new data format
local set_tiers = {
    pve_0                   = 1,
    pve_0_5                 = 2,
    pve_1                   = 3,
    pve_2                   = 4,
    pve_2_5_0               = 6, -- zg
    pve_2_5_1               = 7, -- aq20
    pve_2_5_2               = 8, -- aq40
    pve_3                   = 9,
    pvp_1                   = 10,
    pvp_2                   = 11,
    sod_p2_anyclass         = 12,
    sod_p2_class            = 13,
    sod_p3_t1               = 14,
    sod_p3_t1_dmg           = 15,
    sod_final_pve_0_5       = 16,
    sod_final_pve_0_5_heal  = 17,
    sod_final_pve_1         = 18,
    sod_final_pve_1_heal    = 19,
    sod_final_pve_2         = 20,
    sod_final_pve_2_heal    = 21,
    sod_final_pve_zg        = 22,
};

local function detect_sets(loadout)

    -- TODO: Retire this
    for k, v in pairs(set_tiers) do
        loadout.num_set_pieces[v] = 0;
    end

    for k, _ in pairs(sc.set_bonuses) do
        loadout.num_set_pieces[k] = 0;
    end

    for _, id in pairs(loadout.items) do
        local set_id = sc.set_items[id];
        if set_id then
            if not loadout.num_set_pieces[set_id] then
                loadout.num_set_pieces[set_id] = 0;
            end
            loadout.num_set_pieces[set_id] = loadout.num_set_pieces[set_id] + 1;
        end
    end
end

local GetItemStats = GetItemStats or C_Item.GetItemStats
-- NOTE: ItemStat mods are quite useless, e.g. Nature spell damage comes up as spell power to all
--       Instead rely on generator to all effects except for stat attributes and 
--

local function check_item_properties(lname)
    for k, v in pairs(lname_item_property_to_id) do
        if string.find(lname, k) then
            return v;
        end
    end
    return nil;
end

-- Generated spell effects handle most item effects but some require special handling
local item_stats_handler = {
    ITEM_MOD_POWER_REGEN0_SHORT = function(effects, val, special_property, forced, undo)
        if special_property == special_item_properties.concentration then
            if undo then
                val = -(val + 1);
            else
                val = val + 1;
            end
            effects.raw.mp5 = effects.raw.mp5 + val;
        end
    end,
    ITEM_MOD_SPELL_POWER = function(effects, val, special_property, forced, undo)
        if not forced then
            return;
        end
        if special_property >= special_item_properties.holy_wrath and
            special_property <= special_item_properties.arcane_wrath then
            -- special_property is now the school id
            if undo then
                val = -(val + 1);
            else
                val = val + 1;
            end
            effects.by_school.sp_dmg_flat[special_property] = effects.by_school.sp_dmg_flat[special_property] + val;
        end
    end,
    ITEM_MOD_SPELL_HEALING_DONE = function(effects, val, special_property, forced, undo)
        if not forced then
            return;
        end
        if special_property == special_item_properties.healing then
            if undo then
                val = -(val + 1);
            else
                val = val + 1;
            end
            effects.raw.healing_power_flat = effects.raw.healing_power_flat + val;
        end
    end,
    ITEM_MOD_ATTACK_POWER_SHORT = function(effects, val, special_property, forced, undo)
        if not forced then
            return;
        end
        if special_property == special_item_properties.power then
            if undo then
                val = -(val + 1);
            else
                val = val + 1;
            end
            effects.raw.ap = effects.raw.ap + val;
            effects.raw.rap = effects.raw.rap + val;
        end
    end,
    ITEM_MOD_INTELLECT_SHORT = function(effects, val, _, forced, undo)
        if not forced then
            return;
        end
        if undo then
            val = -val;
        end
        effects.by_attr.stats[attr.intellect] = effects.by_attr.stats[attr.intellect] + val;
    end,
    ITEM_MOD_SPIRIT_SHORT = function(effects, val, _, forced, undo)
        if not forced then
            return;
        end
        if undo then
            val = -val;
        end
        effects.by_attr.stats[attr.spirit] = effects.by_attr.stats[attr.spirit] + val;
    end,
    ITEM_MOD_STRENGTH_SHORT = function(effects, val, _, forced, undo)
        if not forced then
            return;
        end
        if undo then
            val = -val;
        end
        effects.by_attr.stats[attr.strength] = effects.by_attr.stats[attr.strength] + val;
    end,
    ITEM_MOD_AGILITY_SHORT = function(effects, val, _, forced, undo)
        if not forced then
            return;
        end
        if undo then
            val = -val;
        end
        effects.by_attr.stats[attr.agility] = effects.by_attr.stats[attr.agility] + val;
    end,
};

local function apply_item_stats(effects, link, forced, undo)

    local property = check_item_properties(lname);
    local item_stats = GetItemStats(link);

    if item_stats[1] then
        for k, v in pairs(item_stats[1]) do
            item_stats_handler[k](effects, v, property, forced, undo);
        end
    end
end

local function apply_item_cmp(effects, effects_diffed, new, old)

    cpy_effects(effects_diffed, effects);
    -- force undo old item
    if sc.items[old.id] then
        for _, id in pairs(sc.items[old.id]) do
            if sc.item_effects[id] then
                apply_effect(effects_diffed, id, sc.item_effects[id], true, 1, true, false)
            end
        end
    end
    apply_item_stats(effects_diffed, new.link, true, true);
    -- force add new item
    if sc.items[new.id] then
        for _, id in pairs(sc.items[new.id]) do
            if sc.item_effects[id] then
                apply_effect(effects_diffed, id, sc.item_effects[id], true, 1, false, false)
            end
        end
    end
    apply_item_stats(effects_diffed, old.link, true, false);

    return effects, effects_diffed, true;
end

local wpn_strs = { [16] = "mh", [17] = "oh", [18] = "ranged"};

-- set through /sc force set [Set ID] [Number of pieces]
local force_item_sets = {};
-- set through /sc force item [Item ID]
local force_items = {};

local function apply_equipment(loadout, effects)

    for slot = 1, 18 do
        loadout.items[slot] = GetInventoryItemID("player", slot);
    end
    detect_sets(loadout);

    local found_anything = false;

    for set_id, num in pairs(loadout.num_set_pieces) do
        if num > 1 then
            local bonuses = sc.set_bonuses[set_id];
            if bonuses then -- remove this check when old sets handling is gone
                for _, v in pairs(bonuses) do
                    local threshold = v[1];
                    local effect_id = v[2];
                    if num < threshold then
                        break;
                    end
                    apply_effect(effects, effect_id, sc.set_effects[effect_id], false, 1.0);
                end
            end
        end
    end

    for force_set_id, force_threshold in pairs(force_item_sets) do
        local bonuses = sc.set_bonuses[force_set_id];
        local equipped_num_pieces = loadout.num_set_pieces[force_set_id];
        if bonuses then -- remove this check when old sets handling is gone
            for _, v in pairs(bonuses) do
                local threshold = v[1];
                local effect_id = v[2];
                if force_threshold < threshold then
                    break;
                end
                if not equipped_num_pieces or equipped_num_pieces < threshold then
                    apply_effect(effects, effect_id, sc.set_effects[effect_id], true, 1.0);
                end
            end
        end
    end

    -- NOTE: Enchant changes might not force an equipment update
    for k, v in pairs(loadout.enchants) do
        loadout.enchants[k] = nil;
    end

    -- NOTE: shortly after logging in, the equipment querying API won't work
    --       (but does for /reload). Track if we get nothing so we can signal
    --       that equipment scanning needs to be done again on next update

    for item = 1, 18 do
        local item_link = GetInventoryItemLink("player", item);
        if item_link then
            local id = loadout.items[item];
            if id and sc.items[id] then
                for _, effect_id in pairs(sc.items[id]) do
                    apply_effect(effects, effect_id, sc.item_effects[effect_id], false, 1.0);
                end
            end
            found_anything = true;
            local _, enchant_id, gem1, gem2, gem3, gem4 =
                strsplit(":", item_link:match("|Hitem:(.+)|h"));
                print(item_link:match("|Hitem:(.+)|h"));
            enchant_id = tonumber(enchant_id);
            if enchant_id then
                loadout.enchants[enchant_id] = 1;
            end
            local item_stats = GetItemStats(item_link);
            print(GetItemInfo(id));
            for k, v in pairs(item_stats) do
                print(k,v);
            end
        end
        if wpn_strs[item] then
            if item_link then
                local subclass_id = select(13, GetItemInfo(item_link));
                loadout.wpn_subclasses[wpn_strs[item]] = subclass_id;
            else
                loadout.wpn_subclasses[wpn_strs[item]] = -1;
            end
        end
    end

    for id, _ in pairs(force_items) do
        if sc.items[id] then
            for _, effect_id in pairs(sc.items[id]) do
                apply_effect(effects, effect_id, sc.item_effects[effect_id], true, 1.0);
            end
        end
    end

    -- just do weapon enchants for now, are others even needed?
    local _, _, _, enchant_id = GetWeaponEnchantInfo();
    if sc.enchants[enchant_id] then
        loadout.enchants[enchant_id] = 1;
    end

    if bit.band(sc.game_mode, sc.game_modes.season_of_discovery) ~= 0 then
        for i = 1, 18 do
            local rune_slot = C_Engraving.GetRuneForEquipmentSlot(i);
            if rune_slot then
                if rune_slot.itemEnchantmentID then
                    loadout.enchants[rune_slot.itemEnchantmentID] = 1;
                end
            end
        end
    end

    for id, _ in pairs(loadout.enchants) do
        if sc.enchants[id] then
            for _, effect_id in pairs(sc.enchants[id]) do
                apply_effect(effects, effect_id, sc.enchant_effects[effect_id], false, 1.0, false);
            end
        end

    end

    if sc.core.__sw__test_all_codepaths then

        -- Testing all items
        local items_applied = 0;
        for _, v in pairs(sc.items) do
            for _, id in pairs(v) do
                apply_effect(effects, id, sc.item_effects[id], true, 1.0);
                items_applied = items_applied + 1;
            end
        end
        print(items_applied, "gen items applied");
        local sets_applied = 0;
        for _, v in pairs(sc.set_bonuses) do
            for _, bonus in pairs(v) do
                local id = bonus[2];

                apply_effect(effects, id, sc.set_effects[id], true, 1.0);
                sets_applied = sets_applied + 1;
            end
        end
        print(sets_applied, "gen sets applied");

        local enchants_applied = 0;
        for _, v in pairs(sc.enchants) do
            for _, id in pairs(v) do

                apply_effect(effects, id, sc.enchant_effects[id], true, 1.0);
                enchants_applied = enchants_applied + 1;
            end
        end
        print(enchants_applied, "gen enchants applied");
    end

    return found_anything;
end

equipment.set_tiers = set_tiers;
equipment.apply_equipment = apply_equipment;
equipment.force_item_sets = force_item_sets;
equipment.force_items = force_items;
equipment.apply_item_cmp = apply_item_cmp;

sc.equipment = equipment;
