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

local utils = {};

local _, class = UnitClass("player");
local _, race = UnitRace("player");
local faction, _ = UnitFactionGroup("player");

local function ensure_exists_and_add(table, key, add, default_if_not_exists)
    if not table[key] then
        table[key] = default_if_not_exists + add;
    else
        table[key] = table[key] + add;
    end
end

local function ensure_exists_and_mul(table, key, mul, default_if_not_exists)
    if not table[key] then
        table[key] = default_if_not_exists * mul;
    else
        table[key] = table[key] * mul;
    end
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

local loadout_flags = {
    is_dynamic_loadout                  = bit.lshift(1, 1),
    always_assume_buffs                 = bit.lshift(1, 2),
    --use_dynamic_target_lvl              = bit.lshift(1, 3),
    has_target                          = bit.lshift(1, 4),
    target_snared                       = bit.lshift(1, 5),
    target_frozen                       = bit.lshift(1, 6),
    target_friendly                     = bit.lshift(1, 7),
    always_max_mana                     = bit.lshift(1, 8),
    custom_lvl                          = bit.lshift(1, 9),
};


utils.ensure_exists_and_mul = ensure_exists_and_mul;
utils.ensure_exists_and_add = ensure_exists_and_add;
utils.beacon_snapshot_time = beacon_snapshot_time;
utils.addon_running_time = addon_running_time;
utils.class = class;
utils.race = race;
utils.faction = faction;
utils.deep_table_copy = deep_table_copy;
utils.stat = stat;
utils.stat_ids_in_ui = stat_ids_in_ui;
utils.loadout_flags = loadout_flags;

local addon_name, swc = ...;
swc.utils = utils;
