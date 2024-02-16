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

local class                              = swc.utils.class;
local stat                               = swc.utils.stat;

local class_to_int_to_crit_scaling = {
    [60] = {
        ["WARLOCK"] = 60.6061,
        ["DRUID"]   = 59.8802,
        ["SHAMAN"]  = 59.1716,
        ["MAGE"]    = 59.5238,
        ["PRIEST"]  = 59.5238,
        ["PALADIN"] = 59.8802,
    },
    [40] = {
        ["WARLOCK"] = 38.1679,
        ["DRUID"]   = 38.4615,
        ["SHAMAN"]  = 38.1679,
        ["MAGE"]    = 36.2319,
        ["PRIEST"]  = 37.1747,
        ["PALADIN"] = 40.6504,
    },
    [25] = {
        ["WARLOCK"] = 23.3100,
        ["DRUID"]   = 23.4192,
        ["SHAMAN"]  = 23.6967,
        ["MAGE"]    = 21.0526,
        ["PRIEST"]  = 21.8818,
        ["PALADIN"] = 28.0112
    },
    [1] = {
        ["WARLOCK"] =  6.6667,
        ["DRUID"]   =  6.8729,
        ["SHAMAN"]  =  7.7760,
        ["MAGE"]    =  5.2083,
        ["PRIEST"]  =  5.2383,
        ["PALADIN"] = 13.3333,
    },
};
local class_to_base_crit = {
    ["WARLOCK"] = 1.7,
    ["DRUID"]   = 1.8,
    ["SHAMAN"]  = 2.3,
    ["MAGE"]    = 0.2,
    ["PRIEST"]  = 0.8,
    ["PALADIN"] = 3.5,
};

local function int_to_crit_rating(int, loadout, effects)

    local upper = 0;
    local lower = 0;
    if loadout.lvl >= 60 then
        upper = 60;
        lower = 40;
    elseif loadout.lvl >= 50 then
        upper = 60;
        lower = 40;
    elseif loadout.lvl >= 40 then
        upper = 60;
        lower = 40;
    elseif loadout.lvl >= 25 then
        upper = 40;
        lower = 25;
    elseif loadout.lvl >= 2 and loadout.lvl == UnitLevel("player") then
        upper = 0;
    else
        upper = 25;
        lower = 1;
    end
    if upper == 0 then
        -- this only works when equipment doesn't give % crit
        local _, intellect = UnitStat("player", 4);
        ratio = intellect/(GetSpellCritChance(1)-class_to_base_crit[class]-effects.raw.added_physical_spell_crit*100);
    else
        -- interpolate between brackets
        ratio = (loadout.lvl-lower) * (class_to_int_to_crit_scaling[upper][class] - class_to_int_to_crit_scaling[lower][class])/(upper-lower)
            + class_to_int_to_crit_scaling[lower][class];
    end

    return int/ratio;
end

local function effects_diff(loadout, effects, diff)

    --for i = 1, 5 do
    --    effects.stats[i] = loadout.stats[i] + diff.stats[i] * (1 + effects.by_attribute.stat_mod[i]);
    --end

    --loadout.mana = loadout.mana + 
    --             (15*diff.stats[stat.int]*(1 + effects.by_attribute.stat_mod[stat.int]*effects.raw.mana_mod));

    local sp_gained_from_spirit = diff.stats[stat.spirit] * (1 + effects.by_attribute.stat_mod[stat.spirit]) * effects.by_attribute.sp_from_stat_mod[stat.spirit];
    local sp_gained_from_int = diff.stats[stat.int] * (1 + effects.by_attribute.stat_mod[stat.int]) * effects.by_attribute.sp_from_stat_mod[stat.int];
    local sp_gained_from_stat = sp_gained_from_spirit + sp_gained_from_int;

    local hp_gained_from_spirit = diff.stats[stat.spirit] * (1 + effects.by_attribute.stat_mod[stat.spirit]) * effects.by_attribute.hp_from_stat_mod[stat.spirit];
    local hp_gained_from_int = diff.stats[stat.int] * (1 + effects.by_attribute.stat_mod[stat.int]) * effects.by_attribute.hp_from_stat_mod[stat.int];
    local hp_gained_from_stat = hp_gained_from_spirit + hp_gained_from_int;

    effects.raw.spell_power = effects.raw.spell_power + diff.sp;
    effects.raw.spell_dmg = effects.raw.spell_dmg + diff.sd + sp_gained_from_stat;
    effects.raw.healing_power = effects.raw.healing_power + diff.hp + hp_gained_from_stat;

    effects.raw.mp5 = effects.raw.mp5 + diff.mp5;
    effects.raw.mp5 = effects.raw.mp5 + diff.stats[stat.int] * (1 + effects.by_attribute.stat_mod[stat.int]) * effects.raw.mp5_from_int_mod;

    local crit_rating_from_int = int_to_crit_rating(diff.stats[stat.int]*(1.0 + effects.by_attribute.stat_mod[stat.int]), loadout, effects);

    effects.raw.mana = effects.raw.mana + (diff.stats[stat.int]*(1.0 + effects.by_attribute.stat_mod[stat.int]) * 15)*(1.0 + effects.raw.mana_mod);

    effects.raw.haste_rating = effects.raw.haste_rating + diff.haste_rating;
    effects.raw.crit_rating = effects.raw.crit_rating + diff.crit_rating + diff.stats[stat.spirit]*effects.by_attribute.crit_from_stat_mod[stat.spirit] + crit_rating_from_int;
    effects.raw.hit_rating = effects.raw.hit_rating + diff.hit_rating;

    for i = 1, 5 do
        effects.by_attribute.stats[i] = effects.by_attribute.stats[i] + diff.stats[i];
    end
    for i = 2, 7 do
        effects.by_school.target_res[i] = effects.by_school.target_res[i] + diff.spell_pen;
    end
end

local function add_mana_mod(loadout, effects, inactive_value, mod_value)

    effects.raw.mana_mod = effects.raw.mana_mod + mod_value-inactive_value;

    local mana_gained = inactive_value * loadout.mana/(1.0 + effects.raw.mana_mod);
    loadout.mana = loadout.mana + mana_gained;

    effects.raw.mana_mod = effects.raw.mana_mod + inactive_value;


end
local function add_int_mod(loadout, effects, inactive_value, mod_value)
    effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + mod_value-inactive_value;

    local int_gained = inactive_value * loadout.stats[stat.int]/(1.0 + effects.by_attribute.stat_mod[stat.int]);
    local crit_rating_gained = int_to_crit_rating(int_gained, loadout, effects);
    local mana_gained = int_gained * 15 * (1.0 + effects.raw.mana_mod);

    effects.raw.crit_rating = effects.raw.crit_rating +  crit_rating_gained;
    loadout.mana = loadout.mana + mana_gained;
    loadout.max_mana = loadout.max_mana + mana_gained;
    loadout.stats[stat.int] = loadout.stats[stat.int] + int_gained;

    effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + inactive_value;
end

local function add_spirit_mod(loadout, effects, inactive_value, mod_value)
    effects.by_attribute.stat_mod[stat.spirit] = effects.by_attribute.stat_mod[stat.spirit] + mod_value-inactive_value;

    local spirit_gained = inactive_value * loadout.stats[stat.spirit]/(1.0 + effects.by_attribute.stat_mod[stat.spirit]);
    local sd_gained = spirit_gained * effects.by_attribute.sp_from_stat_mod[stat.spirit];
    local hp_gained = spirit_gained * effects.by_attribute.hp_from_stat_mod[stat.spirit];
    effects.raw.spell_dmg = effects.raw.spell_dmg + sd_gained;
    effects.raw.healing_power = effects.raw.healing_power + hp_gained;
    loadout.stats[stat.spirit] = loadout.stats[stat.spirit] + spirit_gained;

    effects.by_attribute.stat_mod[stat.spirit] = effects.by_attribute.stat_mod[stat.spirit] + inactive_value;
end

swc.loadout.effects_diff =  effects_diff;
swc.loadout.add_mana_mod =  add_mana_mod;
swc.loadout.add_int_mod =  add_int_mod;
swc.loadout.add_spirit_mod =  add_spirit_mod;

