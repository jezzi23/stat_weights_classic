local _, sc = ...;

local class                              = sc.utils.class;
local stats                              = sc.stats;

local class_to_int_to_crit_scaling = {
    [60] = {
        ["WARLOCK"] = 60.6061,
        ["DRUID"]   = 59.8802,
        ["SHAMAN"]  = 59.1716,
        ["MAGE"]    = 59.5238,
        ["PRIEST"]  = 59.5238,
        ["PALADIN"] = 59.8802,
    },
    [50] = {
        ["WARLOCK"] = 49.0196,
        ["DRUID"]   = 48.7804,
        ["SHAMAN"]  = 48.0769,
        ["MAGE"]    = 47.3933,
        ["PRIEST"]  = 48.0769,
        ["PALADIN"] = 50.0000,
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
-- TODO: real values
-- fill with temp trash
for _, c in pairs({"HUNTER", "ROGUE", "WARRIOR"}) do
    class_to_base_crit[c] = 0.0;
    for _, v in pairs(class_to_int_to_crit_scaling) do
        v[c] = 0.0;
    end
end

local function int_to_crit_rating(int, loadout, effects)

    local upper = 0;
    local lower = 0;
    if loadout.lvl >= 50 then
        upper = 60;
        lower = 50;
    elseif loadout.lvl >= 40 then
        upper = 50;
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
    local ratio;
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
    --    effects.stats[i] = loadout.stats[i] + diff.stats[i] * (1 + effects.by_attr.stat_mod[i]);
    --end

    --loadout.mana = loadout.mana + 
    --             (15*diff.stats[stats.intellect]*(1 + effects.by_attr.stat_mod[stats.intellect]*effects.raw.mana_mod));

    local sp_gained_from_spirit = diff.stats[stats.spirit] * (1 + effects.by_attr.stat_mod[stats.spirit]) * effects.by_attr.sp_from_stat_mod[stats.spirit];
    local sp_gained_from_int = diff.stats[stats.intellect] * (1 + effects.by_attr.stat_mod[stats.intellect]) * effects.by_attr.sp_from_stat_mod[stats.intellect];
    local sp_gained_from_stat = sp_gained_from_spirit + sp_gained_from_int;

    local hp_gained_from_spirit = diff.stats[stats.spirit] * (1 + effects.by_attr.stat_mod[stats.spirit]) * effects.by_attr.hp_from_stat_mod[stats.spirit];
    local hp_gained_from_int = diff.stats[stats.intellect] * (1 + effects.by_attr.stat_mod[stats.intellect]) * effects.by_attr.hp_from_stat_mod[stats.intellect];
    local hp_gained_from_stat = hp_gained_from_spirit + hp_gained_from_int;

    effects.raw.spell_power = effects.raw.spell_power + diff.sp;
    effects.raw.spell_dmg = effects.raw.spell_dmg + diff.sd + sp_gained_from_stat;
    effects.raw.healing_power_flat = effects.raw.healing_power_flat + diff.hp + hp_gained_from_stat;

    effects.raw.mp5 = effects.raw.mp5 + diff.mp5;
    effects.raw.mp5 = effects.raw.mp5 + diff.stats[stats.intellect] * (1 + effects.by_attr.stat_mod[stats.intellect]) * effects.raw.mp5_from_int_mod;

    local crit_rating_from_int = int_to_crit_rating(diff.stats[stats.intellect]*(1.0 + effects.by_attr.stat_mod[stats.intellect]), loadout, effects);

    effects.raw.mana = effects.raw.mana + (diff.stats[stats.intellect]*(1.0 + effects.by_attr.stat_mod[stats.intellect]) * 15)*(1.0 + effects.raw.mana_mod);

    effects.raw.haste_rating = effects.raw.haste_rating + diff.haste_rating;
    effects.raw.crit_rating = effects.raw.crit_rating + diff.crit_rating + diff.stats[stats.spirit]*effects.by_attr.crit_from_stat_mod[stats.spirit] + crit_rating_from_int;
    effects.raw.hit_rating = effects.raw.hit_rating + diff.hit_rating;

    for i = 1, 5 do
        effects.by_attr.stats[i] = effects.by_attr.stats[i] + diff.stats[i];
    end
    for i = 2, 7 do
        effects.by_school.target_res[i] = effects.by_school.target_res[i] + diff.spell_pen;
    end
end

local function add_mana_mod(loadout, effects, inactive_value, mod_value)

    effects.raw.mana_mod = effects.raw.mana_mod + mod_value-inactive_value;
    effects.raw.mana_mod_active = effects.raw.mana_mod_active + mod_value-inactive_value;

    local mana_gained = inactive_value * loadout.mana/(1.0 + effects.raw.mana_mod);
    loadout.mana = loadout.mana + mana_gained;

    effects.raw.mana_mod = effects.raw.mana_mod + inactive_value;


end
local function add_int_mod(loadout, effects, inactive_value, mod_value)
    effects.by_attr.stat_mod[stats.intellect] = effects.by_attr.stat_mod[stats.intellect] + mod_value-inactive_value;

    local int_gained = inactive_value * loadout.stats[stats.intellect]/(1.0 + effects.by_attr.stat_mod[stats.intellect]);
    local crit_rating_gained = int_to_crit_rating(int_gained, loadout, effects);
    local mana_gained = int_gained * 15 * (1.0 + effects.raw.mana_mod);

    effects.raw.crit_rating = effects.raw.crit_rating +  crit_rating_gained;
    loadout.mana = loadout.mana + mana_gained;
    loadout.max_mana = loadout.max_mana + mana_gained;
    loadout.stats[stats.intellect] = loadout.stats[stats.intellect] + int_gained;

    effects.by_attr.stat_mod[stats.intellect] = effects.by_attr.stat_mod[stats.intellect] + inactive_value;
end

local function add_spirit_mod(loadout, effects, inactive_value, mod_value)
    effects.by_attr.stat_mod[stats.spirit] = effects.by_attr.stat_mod[stats.spirit] + mod_value-inactive_value;

    local spirit_gained = inactive_value * loadout.stats[stats.spirit]/(1.0 + effects.by_attr.stat_mod[stats.spirit]);
    local sd_gained = spirit_gained * effects.by_attr.sp_from_stat_mod[stats.spirit];
    local hp_gained = spirit_gained * effects.by_attr.hp_from_stat_mod[stats.spirit];
    effects.raw.spell_dmg = effects.raw.spell_dmg + sd_gained;
    effects.raw.healing_power = effects.raw.healing_power + hp_gained;
    loadout.stats[stats.spirit] = loadout.stats[stats.spirit] + spirit_gained;

    effects.by_attr.stat_mod[stats.spirit] = effects.by_attr.stat_mod[stats.spirit] + inactive_value;
end

sc.loadout.effects_diff =  effects_diff;
sc.loadout.add_mana_mod =  add_mana_mod;
sc.loadout.add_int_mod =  add_int_mod;
sc.loadout.add_spirit_mod =  add_spirit_mod;

