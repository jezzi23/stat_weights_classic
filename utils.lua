local utils = {};

local _, class = UnitClass("player");
local _, race = UnitRace("player");
local faction, _ = UnitFactionGroup("player");

local function spell_mod_add(table, key, add)
    if not table then
        print(table, key, add, debugstack())
    end
    if not table[key] then
        table[key] = 0.0;
    end
    table[key] = table[key] + add;
end

local function spell_mod_mul(table, key, mul)
    if not table[key] then
        table[key] = 1.0
    end
    table[key] = table[key] * mul;
end

local function deep_table_copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[deep_table_copy(k, s)] = deep_table_copy(v, s) end
  return res
end

local stat = {
    str = 1,
    agi = 2,
    stam = 3,
    int = 4,
    spirit = 5
};

local function spell_cost(spell_id)

    local costs = GetSpellPowerCost(spell_id);
    if costs then
        local cost_table = costs[1];
        if cost_table then
            if cost_table.cost then
                return cost_table.cost, cost_table.name;
            else
                return nil;
            end
        end
    end
end

local function spell_cast_time(spell_id)

    local cast_time = select(4, GetSpellInfo(spell_id));
    if cast_time  then
        if cast_time == 0 then
            --cast_time = nil;
            cast_time = 1.5;
        else
            cast_time = cast_time/1000;
        end
    end
    return cast_time;
end

local function add_all_spell_crit(effects, amount, inactive)
    if inactive then
        for i = 1, 7 do
            effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + amount;
        end
    else
        effects.raw.added_physical_spell_crit = effects.raw.added_physical_spell_crit + amount;
    end
end

local effect_colors = {
    hit                     = { 232 / 255, 225 / 255,  32 / 255 },
    normal                  = { 232 / 255, 225 / 255,  32 / 255 },
    crit                    = { 252 / 255,  69 / 255,   3 / 255 },
    expectation             = { 255 / 255, 128 / 255,   0 / 255 },
    effect_per_sec          = { 255 / 255, 128 / 255,   0 / 255 },
    avg_cast                = { 215 / 255,  83 / 255, 234 / 255 },
    avg_cost                = {   0 / 255, 255 / 255, 255 / 255 },
    effect_per_cost         = {   0 / 255, 255 / 255, 255 / 255 },
    cost_per_sec            = {   0 / 255, 255 / 255, 255 / 255 },
    effect_until_oom        = { 255 / 255, 128 / 255,   0 / 255 },
    casts_until_oom         = {   0 / 255, 255 / 255,   0 / 255 },
    time_until_oom          = {   0 / 255, 255 / 255,   0 / 255 },
    sp_effect               = { 138 / 255, 134 / 255, 125 / 255 },
    stat_weights            = {   0 / 255, 255 / 255,   0 / 255 },
    spell_rank              = { 138 / 255, 134 / 255, 125 / 255 },
    loadout_info            = { 138 / 255, 134 / 255, 125 / 255 },
    miss_info               = { 138 / 255, 134 / 255, 125 / 255 },
};

local function format_number(val, max_accuracy_digits)

    local abs_val = math.abs(val);
    if (abs_val < 100.0 and max_accuracy_digits >= 2) then
        return string.format("%.2f", val);
    elseif (abs_val < 1000.0 and max_accuracy_digits >= 1) then
        return string.format("%.1f", val);
    elseif (abs_val < 10000.0) then
        return string.format("%d", 0.5+math.floor(val));
    elseif (abs_val < 1000000.0) then
        return string.format("%.1fk", val/1000);
    elseif (abs_val < 1000000000.0) then
        return string.format("%.1fm", val/1000000);
    else
        return "∞";
    end
end


utils.spell_mod_mul = spell_mod_mul;
utils.spell_mod_add = spell_mod_add;
utils.beacon_snapshot_time = beacon_snapshot_time;
utils.addon_running_time = addon_running_time;
utils.class = class;
utils.race = race;
utils.faction = faction;
utils.deep_table_copy = deep_table_copy;
utils.stat = stat;
utils.stat_ids_in_ui = stat_ids_in_ui;
utils.spell_cost = spell_cost;
utils.spell_cast_time = spell_cast_time;
utils.add_all_spell_crit = add_all_spell_crit;
utils.effect_colors = effect_colors;
utils.format_number = format_number;

local _, sc = ...;
sc.utils = utils;
sc.ext = {};

