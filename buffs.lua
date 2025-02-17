local _, sc         = ...;

local class         = sc.class;
local classes       = sc.classes;
local apply_effect  = sc.loadout.apply_effect;

local config        = sc.config;

-------------------------------------------------------------------------------
local buffs_export  = {};
local buff_category = {
    class    = 1,
    player   = 2,
    hostile  = 3,
    friendly = 4,
    enchant  = 5,
};

local buffs         = {};
local target_buffs  = {};
for k, _ in pairs(sc.class_buffs) do
    table.insert(buffs, {
        id = k,
        lname = GetSpellInfo(k),
        cat = buff_category.class,
    });
end
for k, _ in pairs(sc.player_buffs) do
    table.insert(buffs, {
        id = k,
        lname = GetSpellInfo(k),
        cat = buff_category.player,
    });
end
-- allows weapon enchant buffs to be registered as buffs
for k, _ in pairs(sc.enchant_effects) do
    table.insert(buffs, {
        id = k,
        --lname = GetSpellInfo(sc.enchant_effects[k]),
        lname = GetSpellInfo(k),
        cat = buff_category.enchant,
    });
end
for k, _ in pairs(sc.friendly_buffs) do
    table.insert(target_buffs, {
        id = k,
        lname = GetSpellInfo(k),
        cat = buff_category.friendly,
    });
end
for k, _ in pairs(sc.hostile_buffs) do
    table.insert(target_buffs, {
        id = k,
        lname = GetSpellInfo(k),
        cat = buff_category.hostile,
    });
end

local function detect_buffs(loadout)
    loadout.dynamic_buffs = { ["player"] = {}, ["target"] = {}, ["mouseover"] = {} };
    if loadout.player_name == loadout.target_name then
        loadout.dynamic_buffs["target"] = loadout.dynamic_buffs["player"]
    end
    if loadout.player_name == loadout.mouseover_name then
        loadout.dynamic_buffs["mouseover"] = loadout.dynamic_buffs["player"]
    end
    if loadout.target_name == loadout.mouseover_name then
        loadout.dynamic_buffs["mouseover"] = loadout.dynamic_buffs["target"]
    end

    for k, v in pairs(loadout.dynamic_buffs) do
        local i = 1;
        while true do
            local _, _, count, _, _, exp_time, src, _, _, spell_id = UnitBuff(k, i);
            if not spell_id then
                break;
            end
            if not exp_time then
                exp_time = 0.0;
            end
            v[spell_id] = { count = count, id = spell_id, src = src, dur = exp_time - GetTime() };
            i = i + 1;
        end
        local i = 1;
        while true do
            local _, _, count, _, _, exp_time, src, _, _, spell_id = UnitDebuff(k, i);
            if not spell_id then
                break;
            end
            if not exp_time then
                exp_time = 0.0;
            end
            v[spell_id] = { count = count, id = spell_id, src = src, dur = exp_time - GetTime() };
            i = i + 1;
        end
    end
end

local function apply_buffs(loadout, effects)
    for k, v in pairs(loadout.dynamic_buffs["player"]) do
        if sc.class_buffs[k] then
            apply_effect(loadout, effects, k, sc.class_buffs[k], false, v.count);
        elseif sc.player_buffs[k] then
            apply_effect(loadout, effects, k, sc.player_buffs[k], false, v.count);
        end
    end
    for k, v in pairs(loadout.dynamic_buffs[loadout.friendly_towards]) do
        if sc.friendly_buffs[k] then
            apply_effect(loadout, effects, k, sc.friendly_buffs[k], false, v.count);
        end
    end
    if loadout.hostile_towards then
        for k, v in pairs(loadout.dynamic_buffs[loadout.hostile_towards]) do
            if sc.hostile_buffs[k] then
                apply_effect(loadout, effects, k, sc.hostile_buffs[k], false, v.count);
            end
        end
    end

    local beacon_duration = 60;
    if class == classes.paladin and loadout.enchant_effects_applied[407613] and
        sc.core.beacon_snapshot_time + beacon_duration >= sc.core.addon_running_time then
        loadout.beacon = true;
    else
        loadout.beacon = nil
    end

    -- some shapeshifts like stances cannot be detected as buff
    -- assigned from data override
    if sc.shapeshift_id_to_effects and sc.shapeshift_id_to_effects[loadout.shapeshift] then
        for _, k in pairs(sc.shapeshift_id_to_effects[loadout.shapeshift]) do
            apply_effect(loadout, effects, k, sc.shapeshift_passives[k], false, 1);
        end
    end


    if config.loadout.force_apply_buffs then
        for k, cnt in pairs(config.loadout.buffs) do
            if not loadout.dynamic_buffs["player"][k] then
                if sc.class_buffs[k] then
                    apply_effect(loadout, effects, k, sc.class_buffs[k], true, cnt, false);
                elseif sc.player_buffs[k] then
                    apply_effect(loadout, effects, k, sc.player_buffs[k], true, cnt, false);
                elseif sc.enchant_effects[k] and not loadout.enchant_effects_applied[k] then
                    apply_effect(loadout, effects, k, sc.player_buffs[k], true, cnt, false);
                end
            end
        end
        for k, cnt in pairs(config.loadout.target_buffs) do
            if not loadout.dynamic_buffs[loadout.friendly_towards][k] and
                (not loadout.hostile_towards or not loadout.dynamic_buffs[loadout.hostile_towards][k])
            then
                if sc.friendly_buffs[k] then
                    apply_effect(loadout, effects, k, sc.friendly_buffs[k], true, cnt);
                end
                if sc.hostile_buffs[k] then
                    apply_effect(loadout, effects, k, sc.hostile_buffs[k], true, cnt);
                end
            end
        end

        if class == classes.paladin and config.loadout.target_buffs[407613] then
            loadout.beacon = true;
        end
    end

    if sc.core.__sw__test_all_codepaths then
        -- Testing all buffs
        local buffs_applied = 0;
        for k, v in pairs(sc.player_buffs) do
            apply_effect(loadout, effects, k, v, true, 1);
            buffs_applied = buffs_applied + 1;
        end
        for k, v in pairs(sc.class_buffs) do
            apply_effect(loadout, effects, k, v, true, 1);
            buffs_applied = buffs_applied + 1;
        end
        for k, v in pairs(sc.friendly_buffs) do
            apply_effect(loadout, effects, k, v, true, 1);
            buffs_applied = buffs_applied + 1;
        end
        for k, v in pairs(sc.hostile_buffs) do
            apply_effect(loadout, effects, k, v, true, 1);
            buffs_applied = buffs_applied + 1;
        end
        print(buffs_applied, "gen buffs applied");
    end
end

local function is_buff_up(loadout, unit, buff_id, only_self_buff)
    if only_self_buff then
        return (unit ~= nil and loadout.dynamic_buffs[unit][buff_id] ~= nil) or
            (config.loadout.force_apply_buffs and config.loadout.buffs[buff_id] ~= nil);
    else
        return (unit ~= nil and loadout.dynamic_buffs[unit][buff_id] ~= nil) or
            (config.loadout.force_apply_buffs and config.loadout.target_buffs[buff_id] ~= nil);
    end
end

buffs_export.buff_filters = buff_filters;
buffs_export.filter_flags_active = filter_flags_active;
buffs_export.buff_category = buff_category;
buffs_export.buffs = buffs;
buffs_export.target_buffs = target_buffs;
buffs_export.detect_buffs = detect_buffs;
buffs_export.apply_buffs = apply_buffs;
buffs_export.non_stackable_effects = non_stackable_effects;
buffs_export.is_buff_up = is_buff_up;

sc.buffs = buffs_export;
