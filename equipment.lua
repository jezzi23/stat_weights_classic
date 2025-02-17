local _, sc = ...;

local apply_effect                     = sc.loadout.apply_effect;
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

    for item = 1, 18 do
        local id = GetInventoryItemID("player", item);
        if sc.set_items[id] then
            local set_id = sc.set_items[id];
            if not loadout.num_set_pieces[set_id] then
                loadout.num_set_pieces[set_id] = 0;
            end
            loadout.num_set_pieces[set_id] = loadout.num_set_pieces[set_id] + 1;
        end
    end
end

local wpn_strs = { [16] = "mh", [17] = "oh", [18] = "ranged"};

local function apply_equipment(loadout, effects)

    detect_sets(loadout);

    local found_anything = false;

    for set_id, num in pairs(loadout.num_set_pieces) do
        if num < 2 then

            if sc.set_bonuses[set_id] then -- remove this check when old sets handling is gone
                for threshold, effect_id in pairs(sc.set_bonuses[set_id]) do
                    if num < threshold then
                        break;
                    end
                    apply_effect(loadout, effects, effect_id, sc.set_effects[effect_id], false, 1.0);
                end
            end
        end
    end

    -- NOTE: shortly after logging in, the equipment querying API won't work
    --       (but does for /reload). Track if we get nothing so we can signal
    --       that equipment scanning needs to be done again on next update

    for item = 1, 18 do
        local item_link = GetInventoryItemLink("player", item);
        if item_link then
            local id = GetInventoryItemID("player", i);
            if id and sc.items[id] then
                apply_effect(loadout, effects, id, sc.item_effects[id], false, 1.0);
            end
            found_anything = true;
            local item_stats = GetItemStats(item_link);
            if item_stats then

                if item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] then
                    effects.raw.mp5 = effects.raw.mp5 + item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] + 1;
                end

                if item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] then
                    for i = 2,7 do
                        effects.by_school.target_res_flat[i] =
                            effects.by_school.target_res_flat[i] - (item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] - 1);
                    end
                end
            end
        end
        if wpn_strs[item] then
            if item_link then
                local subclass_id = select(13, GetItemInfo(item_link));
                loadout[wpn_strs[item].."_subclass"] = subclass_id;
            else
                loadout[wpn_strs[item].."_subclass"] = -1;
            end
        end
    end

    loadout.enchant_effects_applied = {};
    -- just do weapon enchants for now, are others even needed?
    local _, _, _, enchant_id = GetWeaponEnchantInfo();
    if sc.enchants[enchant_id] then
        for _, spid in pairs(sc.enchants[enchant_id]) do
            apply_effect(loadout, effects, spid, sc.enchant_effects[spid], false, 1.0, false);
            loadout.enchant_effects_applied[spid] = 1;
        end
    end

    if bit.band(sc.game_mode, sc.game_modes.season_of_discovery) ~= 0 then
        for i = 1, 18 do
            local rune_slot = C_Engraving.GetRuneForEquipmentSlot(i);
            if rune_slot then
                if rune_slot.itemEnchantmentID then
                    if sc.enchants[rune_slot.itemEnchantmentID] then
                        for _, spid in pairs(sc.enchants[rune_slot.itemEnchantmentID]) do
                            apply_effect(loadout, effects, spid, sc.enchant_effects[spid], false, 1.0, false);
                            loadout.enchant_effects_applied[spid] = 1;
                        end
                    end

                end
            end
        end
    end

    if sc.core.__sw__test_all_codepaths then

        -- Testing all items
        local items_applied = 0;
        for _, v in pairs(sc.items) do
            for _, id in pairs(v) do
                apply_effect(loadout, effects, id, sc.item_effects[id], true, 1.0);
                items_applied = items_applied + 1;
            end
        end
        print(items_applied, "gen items applied");
        local sets_applied = 0;
        for _, v in pairs(sc.set_bonuses) do
            for _, bonus in pairs(v) do
                local id = bonus[2];

                apply_effect(loadout, effects, id, sc.set_effects[id], true, 1.0);
                sets_applied = sets_applied + 1;
            end
        end
        print(sets_applied, "gen sets applied");

        local enchants_applied = 0;
        for _, v in pairs(sc.enchants) do
            for _, id in pairs(v) do

                apply_effect(loadout, effects, id, sc.enchant_effects[id], true, 1.0);
                enchants_applied = enchants_applied + 1;
            end
        end
        print(enchants_applied, "gen enchants applied");
    end

    return found_anything;
end

equipment.set_tiers = set_tiers;
equipment.apply_equipment = apply_equipment;

sc.equipment = equipment;
