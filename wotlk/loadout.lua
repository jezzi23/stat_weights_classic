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

local stat                              = swc.utils.stat;

local function int_to_crit_rating(int, lvl)
    if lvl ~= 80 then
        return 0;
    end

    local lvl_80_int_to_crit_ratio = 166.66638409698;
    --local lvl_80_int_per_crit_rating = lvl_80_int_to_crit_ratio/addonTable.get_combat_rating_effect(CR_CRIT_SPELL, 80);
    local lvl_80_crit_rating_from_int = int*swc.calc.get_combat_rating_effect(CR_CRIT_SPELL, 80)/lvl_80_int_to_crit_ratio;

    return lvl_80_crit_rating_from_int;
end

local function effects_diff(loadout, effects, diff)
    -- TODO: mp5 from int scaling too

    --for i = 1, 5 do
    --    effects.stats[i] = loadout.stats[i] + diff.stats[i] * (1 + effects.by_attribute.stat_mod[i]);
    --end
    -- TODO: outdated stuff here, mana and int crit formula need figuring out

    --loadout.mana = loadout.mana + 
    --             (15*diff.stats[stat.int]*(1 + effects.by_attribute.stat_mod[stat.int]*effects.raw.mana_mod));

    local sp_gained_from_spirit = diff.stats[stat.spirit] * (1 + effects.by_attribute.stat_mod[stat.spirit]) * effects.by_attribute.sp_from_stat_mod[stat.spirit];
    local sp_gained_from_int = diff.stats[stat.int] * (1 + effects.by_attribute.stat_mod[stat.int]) * effects.by_attribute.sp_from_stat_mod[stat.int];
    local sp_gained_from_stat = sp_gained_from_spirit + sp_gained_from_int;

    local hp_gained_from_spirit = diff.stats[stat.spirit] * (1 + effects.by_attribute.stat_mod[stat.spirit]) * effects.by_attribute.hp_from_stat_mod[stat.spirit];
    local hp_gained_from_int = diff.stats[stat.int] * (1 + effects.by_attribute.stat_mod[stat.int]) * effects.by_attribute.hp_from_stat_mod[stat.int];
    local hp_gained_from_stat = hp_gained_from_spirit + hp_gained_from_int;

    effects.raw.spell_power = effects.raw.spell_power + diff.sp + sp_gained_from_stat;
    effects.raw.healing_power = effects.raw.healing_power + hp_gained_from_stat;


    effects.raw.mp5 = effects.raw.mp5 + diff.mp5;
    effects.raw.mp5 = effects.raw.mp5 + diff.stats[stat.int] * (1 + effects.by_attribute.stat_mod[stat.int]) * effects.raw.mp5_from_int_mod;

    -- TODO: crit and mana yields from intellect
    --       Missing formulas, seems to depend on lvl and class/race?
    --       It looks like in many cases 166.67 int is needed per 1% crit at many lvl 80 caster classes
    --
    --       Only contribute mana and crit IF we are level 80 since the generalized case is unknown atm
    local lvl_80_int_to_crit_ratio = 166.66638409698;
    local lvl_80_int_per_crit_rating = lvl_80_int_to_crit_ratio/swc.calc.get_combat_rating_effect(CR_CRIT_SPELL, 80);
    
    local crit_rating_from_int = int_to_crit_rating(diff.stats[stat.int]*(1.0 + effects.by_attribute.stat_mod[stat.int]), loadout.lvl);

    effects.raw.mana = effects.raw.mana + (diff.stats[stat.int]*(1.0 + effects.by_attribute.stat_mod[stat.int]) * 15)*(1.0 + effects.raw.mana_mod);

    effects.raw.haste_rating = effects.raw.haste_rating + diff.haste_rating;
    effects.raw.crit_rating = effects.raw.crit_rating + diff.crit_rating + diff.stats[stat.spirit]*effects.by_attribute.crit_from_stat_mod[stat.spirit] + crit_rating_from_int;
    effects.raw.hit_rating = effects.raw.hit_rating + diff.hit_rating;

    for i = 1, 5 do
        effects.by_attribute.stats[i] = effects.by_attribute.stats[i] + diff.stats[i];
    end
end

swc.loadout.int_to_crit_rating =  int_to_crit_rating;
swc.loadout.effects_diff =  effects_diff;

