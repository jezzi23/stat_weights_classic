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
--
local _, swc                = ...;

local spell_mod_add         = swc.utils.spell_mod_add;
local spell_mod_mul         = swc.utils.spell_mod_mul;
local deep_table_copy       = swc.utils.deep_table_copy;
local stat                  = swc.utils.stat;
local class                 = swc.utils.class;
local race                  = swc.utils.race;
local faction               = swc.utils.faction;
local add_all_spell_crit    = swc.utils.add_all_spell_crit;

local loadout_flags         = swc.loadout.loadout_flags;
local apply_effect          = swc.loadout.apply_effect;

local config                = swc.config;

local magic_school          = swc.abilities.magic_school;
local spids                 = swc.abilities.spids;
local spell_groups          = swc.abilities.spell_groups;

local set_tiers             = swc.equipment.set_tiers;

-------------------------------------------------------------------------------
local buffs_export          = {};

local buff_filters          = {
    caster      = bit.lshift(1, 1),
    --
    priest       = bit.lshift(1, 2),
    mage         = bit.lshift(1, 3),
    warlock      = bit.lshift(1, 4),
    druid        = bit.lshift(1, 5),
    shaman       = bit.lshift(1, 6),
    paladin      = bit.lshift(1, 7),
    --
    troll        = bit.lshift(1, 8),
    belf         = bit.lshift(1, 9),

    horde        = bit.lshift(1, 10),
    alliance     = bit.lshift(1, 11),

    hidden       = bit.lshift(1, 12),
    friendly     = bit.lshift(1, 13),
    hostile      = bit.lshift(1, 14),

    holy        = bit.lshift(1, 15),
    fire        = bit.lshift(1, 16),
    shadow      = bit.lshift(1, 17),
    frost       = bit.lshift(1, 18),
    nature      = bit.lshift(1, 19),
    arcane      = bit.lshift(1, 20),


    sod         = bit.lshift(1, 21),

};

local buff_category         = {
    talent      = 1,
    class       = 2,
    raid        = 3,
    world_buffs = 5,
    consumes    = 4,
    item        = 6,
};

local filter_flags_active   = 0;
filter_flags_active         = bit.bor(filter_flags_active, buff_filters.caster);
if class == "PRIEST" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.priest, buff_filters.holy, buff_filters.shadow);
elseif class == "DRUID" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.druid, buff_filters.nature, buff_filters.arcane);
elseif class == "SHAMAN" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.shaman, buff_filters.nature, buff_filters.frost, buff_filters.fire);
elseif class == "MAGE" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.mage, buff_filters.arcane, buff_filters.frost, buff_filters.fire);
elseif class == "WARLOCK" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.warlock, buff_filters.shadow, buff_filters.fire);
elseif class == "PALADIN" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.paladin, buff_filters.holy);
end

if faction == "Horde" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.horde);
else
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.alliance);
end

if race == "Troll" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.troll);
end

if C_Engraving and C_Engraving.IsEngravingEnabled() then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.sod);
end

filter_flags_active         = bit.bor(filter_flags_active, buff_filters.hidden);
filter_flags_active         = bit.bor(filter_flags_active, buff_filters.friendly);
filter_flags_active         = bit.bor(filter_flags_active, buff_filters.hostile);


local non_stackable_effects = {
    moonkin_crit        = bit.lshift(1, 0),
    stormstrike         = bit.lshift(1, 1),
    druid_nourish_bonus = bit.lshift(1, 2),
    bow_mp5             = bit.lshift(1, 3),
    bok                 = bit.lshift(1, 4),
};

local function alias_buff(buffs_list, alias_id, original_id, should_hide)
    buffs_list[alias_id] = deep_table_copy(buffs_list[original_id]);
    if should_hide then
        buffs_list[alias_id].filter = bit.bor(buffs_list[alias_id].filter, buff_filters.hidden);
    end
end

local function alias_buffs_by_table(buffs_list, buff_alias_ids, original_id)
    local src_id = original_id or buff_alias_ids.default;
    for k, _ in pairs(buff_alias_ids.map) do
        if k ~= src_id then
            alias_buff(buffs_list, k, src_id, true);
        end
    end
end

local lookups = {
    bow_id_to_mp5 = {
        map = {
            [19742] = 10,
            [19850] = 15,
            [19852] = 20,
            [19853] = 25,
            [19854] = 30,
            [25290] = 33,
            [25918] = 33
        },
        default = 25290,
    },
    mana_spring_id_to_mp5 = {
        map = {
            [5677]  = 2.5 * 4,
            [10491] = 2.5 * 6,
            [10493] = 2.5 * 8,
            [10494] = 2.5 * 10,
        },
        default = 10494,
    },
    amp_magic_id_to_hp = {
        map = {
            [1008]  = 30,
            [8455]  = 60,
            [10169] = 100,
            [10170] = 150,
        },
        default = 10170,
    },
    damp_magic_id_to_hp = {
        map = {
            [604]   = 20,
            [8450]  = 40,
            [8451]  = 80,
            [10173] = 120,
            [10174] = 180,
        },
        default = 10174,
    },
    bol_id_to_hl = {
        map = {
            [19977] = 210,
            [19978] = 300,
            [19979] = 400,
            [25890] = 400,
        },
        default = 19979,
    },
    bol_id_to_fl = {
        map = {
            [19977] = 60,
            [19978] = 85,
            [19979] = 115,
            [25890] = 115,
        },
        default = 25890,
    },
    coe_id_to_mod = {
        map = {
            [1490]   = 0.06,
            [11721]  = 0.08,
            [11722]  = 0.1,
            [402792] = 0.1,
        },
        default = 11722,
    },
    coe_id_to_res = {
        map = {
            [1490]   = 45,
            [11721]  = 60,
            [11722]  = 75,
            [402792] = 75,
        },
        default = 11722,
    },
    cos_id_to_mod = {
        map = {
            [17862]  = 0.08,
            [17937]  = 0.1,
            [402791] = 0.1,
        },
        default = 17937,
    },
    cos_id_to_res = {
        map = {
            [17862]  = 60,
            [17937]  = 75,
            [402791] = 75,
        },
        default = 17937,
    },
    md_id_to_mod = {
        map = {
            [23761] = 0.02,
            [23833] = 0.04,
            [23834] = 0.06,
            [23835] = 0.08,
            [23836] = 0.1,
        },
        default = 23836,
    },
    isb_to_vuln = {
        map = {
            [17794] = 0.04,
            [17798] = 0.08,
            [17797] = 0.12,
            [17799] = 0.16,
            [17800] = 0.2,
        },
        default = 17800,
    },
    wep_enchant_id_to_buff = {
        map = {
            [2628] = 25122,
            [2629] = 25123,
            [7099] = 430585,
        },
    },
    beacon_of_light = 407613
};

--TODO VANILLA:
--    troll beast
--    divine sacrifice expiration buff id unknown
local buffs_predefined = {
    -- onyxia
    [22888] = {
        apply = function(loadout, effects, buff, inactive)
            add_all_spell_crit(effects, 0.1, inactive);
        end,
        filter = buff_filters.caster,
        category = buff_category.world_buffs,
    },
    -- wcb
    [16609] = {
        apply = function(loadout, effects, buff, inactive)
            effects.raw.mp5 = effects.raw.mp5 + 10;
        end,
        filter = buff_filters.caster,
        category = buff_category.world_buffs,
    },
    -- songflower
    [15366] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                for i = 1, 5 do
                    effects.by_attribute.stats[i] = effects.by_attribute.stats[i] + 15;
                end
            end

            add_all_spell_crit(effects, 0.05, inactive);
        end,
        filter = buff_filters.caster,
        category = buff_category.world_buffs,
    },
    -- zandalari
    [24425] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                swc.loadout.add_int_mod(loadout, effects, 0.15, 0.15);
                swc.loadout.add_spirit_mod(loadout, effects, 0.15, 0.15);
            else
                swc.loadout.add_int_mod(loadout, effects, 0.0, 0.15);
                swc.loadout.add_spirit_mod(loadout, effects, 0.0, 0.15);
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.world_buffs,
    },
    -- greater arcane elixir
    [17539] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_dmg = effects.raw.spell_dmg + 35;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
    },
    -- runn tum tuber surprise
    [22730] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.by_attribute.stats[stat.int] = effects.by_attribute.stats[stat.int] + 10;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
    },
    -- power infusion
    [10060] = {
        apply = function(loadout, effects, buff)
            effects.mul.raw.spell_heal_mod = effects.mul.raw.spell_heal_mod * 1.2;
            effects.mul.raw.spell_dmg_mod = effects.mul.raw.spell_dmg_mod * 1.2;
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
    },
    --arcane power
    [12042] = {
        apply = function(loadout, effects, buff)
            effects.by_school.spell_dmg_mod[magic_school.fire] =
                effects.by_school.spell_dmg_mod[magic_school.fire] + 0.3;
            effects.by_school.spell_dmg_mod[magic_school.arcane] =
                effects.by_school.spell_dmg_mod[magic_school.arcane] + 0.3;
            effects.by_school.spell_dmg_mod[magic_school.frost] =
                effects.by_school.spell_dmg_mod[magic_school.frost] + 0.3;

            --effects.raw.cost_mod_base = effects.raw.cost_mod_base - 0.3;
        end,
        filter = buff_filters.mage,
        category = buff_category.class,
    },
    -- mind quickening gem
    [23723] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = effects.raw.haste_mod + 0.33;
        end,
        filter = buff_filters.mage,
        category = buff_category.item,
    },
    -- dmf dmg
    [23768] = {
        apply = function(loadout, effects, buff)
            effects.mul.raw.spell_dmg_mod = effects.mul.raw.spell_dmg_mod * 1.1;
        end,
        filter = buff_filters.caster,
        category = buff_category.world_buffs,
    },
    -- zg trinket
    [24544] = {
        apply = function(loadout, effects, buff, inactive)
            effects.by_school.spell_crit_mod[magic_school.arcane] =
                effects.by_school.spell_crit_mod[magic_school.arcane] + 0.25;
            if inactive then
                effects.by_school.spell_crit[magic_school.arcane] =
                    effects.by_school.spell_crit[magic_school.arcane] + 0.05;
            end
        end,
        filter = buff_filters.mage,
        category = buff_category.item,
    },
    -- zg trinket
    [24543] = {
        apply = function(loadout, effects, buff, inactive)
            for k, v in pairs(spell_groups.destruction) do
                spell_mod_add(effects.ability.crit, v, 0.1);
            end
        end,
        filter = buff_filters.warlock,
        category = buff_category.item,
    },
    -- zg trinket
    [24546] = {
        apply = function(loadout, effects, buff)
            spell_mod_add(effects.ability.cast_mod, spids.greater_heal, 0.4);
            for k, v in pairs(spell_groups.heal) do
                spell_mod_add(effects.ability.cost_mod, v, 0.05);
            end
        end,
        filter = buff_filters.priest,
        category = buff_category.item,
    },
    -- zg trinket
    [24499] = {
        apply = function(loadout, effects, buff)
            spell_mod_add(effects.ability.effect_mod, spids.lightning_shield, 1.0);
        end,
        filter = buff_filters.shaman,
        category = buff_category.item,
    },
    -- zg trinket
    [24542] = {
        apply = function(loadout, effects, buff)
            spell_mod_add(effects.ability.cast_mod, spids.healing_touch, 0.4);
            spell_mod_add(effects.ability.cast_mod, spids.nourish, 0.4);
            for k, v in pairs(spell_groups.heal) do
                spell_mod_add(effects.ability.cost_mod, v, 0.05);
            end
        end,
        filter = buff_filters.druid,
        category = buff_category.item,
    },
    -- amplify curse
    [18288] = {
        apply = function(loadout, effects, buff)
            spell_mod_add(effects.ability.effect_mod_base, spids.curse_of_agony, 0.5);
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
    },
    -- demonic sacrifice succ
    [18791] = {
        apply = function(loadout, effects, buff)
            effects.mul.by_school.target_vuln_dmg[magic_school.shadow] =
                effects.mul.by_school.target_vuln_dmg[magic_school.shadow] * 1.15;
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
    },
    -- shadow form
    [15473] = {
        apply = function(loadout, effects, buff)
            if bit.band(swc.core.client_deviation, swc.core.client_deviation_flags.sod) ~= 0 then
                effects.by_school.cost_mod[magic_school.shadow] =
                    effects.by_school.cost_mod[magic_school.shadow] + 0.5;
                effects.mul.by_school.target_vuln_dmg[magic_school.shadow] =
                    effects.mul.by_school.target_vuln_dmg[magic_school.shadow] * 1.25;
            else
                effects.mul.by_school.target_vuln_dmg[magic_school.shadow] =
                    effects.mul.by_school.target_vuln_dmg[magic_school.shadow] * 1.15;
            end
        end,
        filter = buff_filters.priest,
        category = buff_category.class,
    },
    -- toep
    [23271] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + 175;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.item,
    },
    -- zandalari hero charm
    [24658] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_dmg = effects.raw.spell_dmg + 204;
                effects.raw.healing_power = effects.raw.healing_power + 408;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.item,
        icon_id = GetItemIcon(19950)
    },
    -- berserk
    [26635] = {
        apply = function(loadout, effects, buff)
            -- TODO VANILLA: dynamic snapping 0.1:0.3 based on hp
            effects.raw.haste_mod = effects.raw.haste_mod + 0.1;
        end,
        filter = buff_filters.troll,
        category = buff_category.class,
    },
    -- bok
    [25898] = {
        apply = function(loadout, effects, buff, inactive)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.bok) == 0 then
                if inactive then
                    swc.loadout.add_int_mod(loadout, effects, 0.1, 0.1);
                    swc.loadout.add_spirit_mod(loadout, effects, 0.1, 0.1);
                else
                    swc.loadout.add_int_mod(loadout, effects, 0.0, 0.1);
                    swc.loadout.add_spirit_mod(loadout, effects, 0.0, 0.1);
                end

                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.bok);
            end
        end,
        filter = buff_filters.alliance,
        category = buff_category.raid,
    },
    -- vengeance
    [20055] = {
        apply = function(loadout, effects, buff)
            effects.mul.by_school.target_vuln_dmg[magic_school.holy] =
                effects.mul.by_school.target_vuln_dmg[magic_school.holy] * 1.15;
        end,
        filter = buff_filters.paladin,
        category = buff_category.class,
    },
    -- nature aligned
    [23734] = {
        apply = function(loadout, effects, buff)
            effects.raw.cost_mod = effects.raw.cost_mod - 0.2;
            effects.mul.raw.spell_heal_mod =  effects.mul.raw.spell_heal_mod * 1.2;
            effects.mul.raw.spell_dmg_mod = effects.mul.raw.spell_dmg_mod * 1.2;
        end,
        filter = buff_filters.shaman,
        category = buff_category.item,
    },
    -- blessed prayer beads
    [24354] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.healing_power = effects.raw.healing_power + 190;
            end
        end,
        filter = buff_filters.priest,
        category = buff_category.item,
    },
    -- sp flask
    [17628] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_dmg = effects.raw.spell_dmg + 150;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
    },
    -- nightfin
    [18194] = {
        apply = function(loadout, effects, buff)
            effects.raw.mp5 = effects.raw.mp5 + 8;
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
    },
    -- mage armor
    [22783] = {
        apply = function(loadout, effects, buff, inactive)
            local val = 0.3;
            if loadout.num_set_pieces[set_tiers.sod_final_pve_1] >= 6 then
                val = val + 0.15;
            end
            effects.raw.regen_while_casting = effects.raw.regen_while_casting + val;
        end,
        filter = buff_filters.mage,
        category = buff_category.class,
    },
    -- mana flask
    [17627] = {
        apply = function(loadout, effects, buff)
            effects.raw.mana = effects.raw.mana + 2000;
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
    },
    -- bow
    [25290] = {
        apply = function(loadout, effects, buff)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.bow_mp5) == 0 then
                local id_to_mp5 = lookups.bow_id_to_mp5.map;
                local id = 25290; -- default
                local mp5 = 0;

                if buff.id and id_to_mp5[buff.id] then
                    id = buff.id;
                end
                if buff.src and buff.src == "player" then
                    mp5 = id_to_mp5[id] * (1.0 + loadout.talents_table:pts(1, 10) * 0.1);
                else
                    mp5 = id_to_mp5[id] * 1.2;
                end
                effects.raw.mp5 = effects.raw.mp5 + mp5;


                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.bow_mp5);
            end
        end,
        filter = buff_filters.alliance,
        category = buff_category.raid,
    },
    -- moonkin
    [24907] = {
        apply = function(loadout, effects, buff, inactive)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.moonkin_crit) == 0 then
                add_all_spell_crit(effects, 0.03, inactive);
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.moonkin_crit);
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
    },
    -- moonkin form
    [24858] = {
        apply = function(loadout, effects, buff, inactive)
            if bit.band(swc.core.client_deviation, swc.core.client_deviation_flags.sod) ~= 0 then
                spell_mod_add(effects.ability.cost_mod, spids.moonfire, 0.5);
                spell_mod_add(effects.ability.cost_mod, spids.sunfire, 0.5);

                spell_mod_add(effects.ability.effect_ot_mod, spids.moonfire, 1.0);
                spell_mod_add(effects.ability.effect_ot_mod, spids.sunfire, 1.0);

                if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 6 then
                    spell_mod_add(effects.ability.effect_mod, spids.wild_growth, 0.5);
                end

                if inactive then
                    effects.raw.spell_dmg = effects.raw.spell_dmg + 2 * loadout.lvl;
                end
            end
        end,
        filter = buff_filters.druid,
        category = buff_category.class,
    },
    -- mana spring
    [10494] = {
        apply = function(loadout, effects, buff)
            local id_to_mp5 = lookups.mana_spring_id_to_mp5.map;
            local id = 10494; -- default
            local mp5 = 0;

            if buff.id and id_to_mp5[buff.id] then
                id = buff.id;
            end
            if buff.src and buff.src == "player" then
                local mod = loadout.talents_table:pts(3, 10) * 0.05;
                if loadout.num_set_pieces[set_tiers.pve_3] >= 4 then
                    mod = mod + 0.25;
                end
                mp5 = id_to_mp5[id] * (1.0 + mod);
            else
                mp5 = id_to_mp5[id] * 1.2;
            end
            effects.raw.mp5 = effects.raw.mp5 + mp5;
        end,
        filter = buff_filters.horde,
        category = buff_category.raid,
    },
    -- spirit of zanzq
    [24382] = {
        apply = function(loadout, effects, buff)
            effects.by_attribute.stats[stat.spirit] = effects.by_attribute.stats[stat.spirit] + 50;
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
    },
    -- brilliant wizard oil
    [25122] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_dmg = effects.raw.spell_dmg + 36;
            end

            add_all_spell_crit(effects, 0.01, inactive);
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
        icon_id = GetItemIcon(20749)
    },
    --  brilliant mana oil
    [25123] = {
        apply = function(loadout, effects, buff, inactive)
            effects.raw.mp5 = effects.raw.mp5 + 12;
            if inactive then
                effects.raw.healing_power = effects.raw.healing_power + 25;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
        icon_id = GetItemIcon(20748)
    },
    -- demonic sacrifice imp
    [18789] = {
        apply = function(loadout, effects, buff)
            effects.mul.by_school.target_vuln_dmg[magic_school.fire] =
                effects.mul.by_school.target_vuln_dmg[magic_school.fire] * 1.15;
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
    },
    -- lightning shield
    [10432] = {
        apply = function(loadout, effects, buff)
            if loadout.num_set_pieces[set_tiers.pve_3] >= 8 then
                effects.raw.mp5 = effects.raw.mp5 + 15;
            end
        end,
        filter = bit.bor(buff_filters.shaman),
        category = buff_category.class,
    },
    -- ephipany
    [28804] = {
        apply = function(loadout, effects, buff)
            effects.raw.mp5 = effects.raw.mp5 + 24;
        end,
        filter = buff_filters.priest,
        category = buff_category.class,
    },
    ---- fury of the stormrage proc
    [414800] = {
        apply = function(loadout, effects, buff)
            spell_mod_add(effects.ability.cast_mod, spids.healing_touch, 1.00);
            spell_mod_add(effects.ability.cast_mod, spids.nourish, 1.00);
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.sod),
        category = buff_category.class,
    },
    --arcane blast
    [400573] = {
        apply = function(loadout, effects, buff)
            local stacks = 4;

            if buff.count then
                stacks = buff.count;
            end
            effects.by_school.spell_dmg_mod[magic_school.arcane] =
                effects.by_school.spell_dmg_mod[magic_school.arcane] + 0.15 * stacks;
            -- arcane blast is exempt from damage increase
            spell_mod_add(effects.ability.effect_mod, spids.arcane_blast, -0.15 * stacks);
            spell_mod_add(effects.ability.cost_mod, spids.arcane_blast, -stacks * 1.75);

            effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + 0.15 * stacks;
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.class,
    },
    -- fingers of frost
    [400669] = {
        apply = function(loadout, effects, buff)
            loadout.flags = bit.bor(loadout.flags, loadout_flags.target_frozen);
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.class,
    },

    -- icy veins
    [425121] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = effects.raw.haste_mod + 0.2;
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.class,
    },
    -- water shield
    [408510] = {
        apply = function(loadout, effects, buff)
            effects.raw.perc_max_mana_as_mp5 = effects.raw.perc_max_mana_as_mp5 + 0.01;
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.sod),
        category = buff_category.class,
    },
    -- incinerate
    [412758] = {
        apply = function(loadout, effects, buff)
            effects.mul.by_school.target_vuln_dmg[magic_school.fire] =
                effects.mul.by_school.target_vuln_dmg[magic_school.fire] * 1.4;
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.class,
    },
    -- metamorphosis
    [403789] = {
        apply = function(loadout, effects, buff)
            spell_mod_add(effects.ability.effect_mod, spids.life_tap, 1.0);
            effects.mul.raw.spell_dmg_mod = effects.mul.raw.spell_dmg_mod * 0.85;
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.class,
    },
    -- serendipity
    [413247] = {
        apply = function(loadout, effects, buff)
            local c = 3;
            if buff.count then
                c = buff.count
            end
            for k, v in pairs(spell_groups.serendipity_affected) do
                spell_mod_add(effects.ability.cast_mod, v, c * 0.2);
            end
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.sod),
        category = buff_category.class,
    },
    -- demonic grace
    [425463] = {
        apply = function(loadout, effects, buff, inactive)
            add_all_spell_crit(effects, 0.2, inactive);
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.class,
    },
    -- demonic pact
    [425467] = {
        apply = function(loadout, effects, buff, inactive)
            effects.mul.by_school.target_vuln_dmg[magic_school.fire] =
                effects.mul.by_school.target_vuln_dmg[magic_school.fire] * 1.1;
            effects.mul.by_school.target_vuln_dmg[magic_school.shadow] =
                effects.mul.by_school.target_vuln_dmg[magic_school.shadow] * 1.1;
            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + math.max(0.1 * effects.raw.spell_power, loadout.lvl /
                    2);
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.raid,
    },
    -- tangled causality
    [432069] = {
        apply = function(loadout, effects, buff)
            effects.mul.by_school.target_vuln_dmg[magic_school.fire] =
                effects.mul.by_school.target_vuln_dmg[magic_school.fire] * 0.5;
            effects.mul.by_school.target_vuln_dmg[magic_school.frost] =
                effects.mul.by_school.target_vuln_dmg[magic_school.frost] * 0.5;
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.class,
    },
    -- blackfathom mana oil
    [430585] = {
        apply = function(loadout, effects, buff, inactive)
            effects.raw.mp5 = effects.raw.mp5 + 12;
            if inactive then
                for i = 1, 7 do
                    effects.by_school.spell_dmg_hit[i] = effects.by_school.spell_dmg_hit[i] + 0.02;
                end
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.consumes,
        icon_id = GetItemIcon(211848),
    },
    -- ashenvale rallying cry
    [430352] = {
        apply = function(loadout, effects, buff)
            effects.mul.raw.spell_heal_mod = effects.mul.raw.spell_heal_mod * 1.05;
            effects.mul.raw.spell_dmg_mod = effects.mul.raw.spell_dmg_mod * 1.05;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.world_buffs,
    },
    -- boon of blackfathom
    [430947] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_dmg = effects.raw.spell_dmg + 25;
                for i = 1, 7 do
                    effects.by_school.spell_dmg_hit[i] = effects.by_school.spell_dmg_hit[i] + 0.03;
                end
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.world_buffs,
    },
    -- sod arcane power
    [430952] = {
        apply = function(loadout, effects, buff, inactive)
            add_all_spell_crit(effects, 0.01, inactive);
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.class,
        icon_id = GetItemIcon(211957),
    },
    -- enlightened judgements
    [426173] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                for i = 1, 7 do
                    effects.by_school.spell_dmg_hit[i] = effects.by_school.spell_dmg_hit[i] + 0.17;
                end
            end
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.sod),
        category = buff_category.class,
    },
    -- sheath of light
    [426159] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + loadout.attack_power * 0.3;
            end
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.sod),
        category = buff_category.class,
    },
    -- guarded by the light
    [415058] = {
        apply = function(loadout, effects, buff)
            effects.raw.spell_heal_mod = effects.raw.spell_heal_mod - 0.5;
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.sod),
        category = buff_category.class,
    },
    -- fanaticism
    [429142] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.by_school.spell_crit[magic_school.holy] =
                    effects.by_school.spell_crit[magic_school.holy] + 0.18;
            end
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.sod),
        category = buff_category.class,
    },
    -- surge of light
    [431666] = {
        apply = function(loadout, effects, buff)
            spell_mod_add(effects.ability.cast_mod, spids.smite, 1.0);
            spell_mod_add(effects.ability.cast_mod, spids.flash_heal, 1.0);
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.sod),
        category = buff_category.class,
    },
    -- maelstrom weapon
    [408505] = {
        apply = function(loadout, effects, buff)
            local c = 0;
            if buff.count then
                c = buff.count
            else
                c = 5;
            end

            for k, v in pairs(spell_groups.maelstrom_affected) do
                spell_mod_add(effects.ability.cast_mod, v, c * 0.2);
            end
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.sod),
        category = buff_category.class,
    },
    -- power surge
    [415105] = {
        apply = function(loadout, effects, buff)
            for k, v in pairs(spell_groups.power_surge_affected) do
                spell_mod_add(effects.ability.cast_mod, v, 1.0);
            end
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.sod),
        category = buff_category.class,
    },
    -- hot streak
    [400625] = {
        apply = function(loadout, effects, buff)
            spell_mod_add(effects.ability.cast_mod, spids.pyroblast, 1.0);
            spell_mod_add(effects.ability.cost_mod, spids.pyroblast, 1.0);
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.class,
    },
    -- missile barrage
    [400589] = {
        apply = function(loadout, effects, buff)
            --spell_mod_add(effects.ability.cast_mod_reduce, spids.arcane_missiles, 0.5);
            spell_mod_add(effects.ability.cost_mod, spids.arcane_missiles, 1.0);
            if loadout.num_set_pieces[set_tiers.sod_final_pve_2_heal] >= 4 then
                --spell_mod_add(effects.ability.cast_mod_reduce, spids.regeneration, 0.5);
                spell_mod_add(effects.ability.cost_mod, spids.regeneration, 1.0);
            end
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.class,
    },
    -- brain freeze
    [400730] = {
        apply = function(loadout, effects, buff)
            for k, v in pairs(spell_groups.brain_freeze_affected) do
                spell_mod_add(effects.ability.cast_mod, v, 1.0);
                spell_mod_add(effects.ability.cost_mod, v, 1.0);
            end
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.class,
    },
    -- balefire bolt
    [428878] = {
        apply = function(loadout, effects, buff)
            local c = 0;
            if buff.count then
                c = buff.count
            else
                c = 5;
            end

            spell_mod_add(effects.ability.effect_mod, spids.balefire_bolt, c * 0.2);
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.class,
    },
    -- molten armor
    [428741] = {
        apply = function(loadout, effects, buff, inactive)
            add_all_spell_crit(effects, 0.05, inactive);
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.class,
    },
    -- grimoire of synergy
    [426303] = {
        apply = function(loadout, effects, buff)
            effects.mul.raw.spell_dmg_mod = effects.mul.raw.spell_dmg_mod * 1.1;
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.class,
    },
    -- shadow and flame
    [426311] = {
        apply = function(loadout, effects, buff)
            effects.mul.by_school.target_vuln_dmg[magic_school.fire] =
                effects.mul.by_school.target_vuln_dmg[magic_school.fire] * 1.1;
            effects.mul.by_school.target_vuln_dmg[magic_school.shadow] =
                effects.mul.by_school.target_vuln_dmg[magic_school.shadow] * 1.1;
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.class,
    },
    -- backdraft
    [427713] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = effects.raw.haste_mod + 0.3;
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.class,
    },
    -- eclipse: solar
    [408250] = {
        apply = function(loadout, effects, buff)
            spell_mod_add(effects.ability.crit, spids.wrath, 0.3);
            spell_mod_add(effects.ability.crit, spids.starsurge, 0.3);
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.sod),
        category = buff_category.class,
    },
    -- eclipse: lunar
    [408255] = {
        apply = function(loadout, effects, buff)
            spell_mod_add(effects.ability.cast_mod_flat, spids.starfire, 1.0);
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.sod),
        category = buff_category.class,
    },
    -- dreamstate
    [408261] = {
        apply = function(loadout, effects, buff)
            effects.raw.regen_while_casting = effects.raw.regen_while_casting + 0.5;
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.sod),
        category = buff_category.class,
    },
    -- berserking
    [23505] = {
        apply = function(loadout, effects, buff)
            effects.mul.raw.spell_dmg_mod = effects.mul.raw.spell_dmg_mod * 1.3;
        end,
        filter = buff_filters.caster,
        category = buff_category.world_buffs,
    },
    [429868] = {
        apply = function(loadout, effects, buff)
            effects.mul.raw.spell_dmg_mod = effects.mul.raw.spell_dmg_mod * 1.1;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.item,
    },
    -- spark of inspiration
    [438536] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + 42;
            end

            add_all_spell_crit(effects, 0.04, inactive);
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.world_buffs,
    },
    -- mildly irradiated
    [435973] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + 35;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.item,
    },
    -- coin flip
    [437698] = {
        apply = function(loadout, effects, buff, inactive)
            add_all_spell_crit(effects, 0.03, inactive);
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.item,
    },
    -- hyperconductive shock
    [437362] = {
        apply = function(loadout, effects, buff, inactive)
            effects.raw.haste_mod = effects.raw.haste_mod + 0.2;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.item,
    },
    -- charged inspiration
    [437327] = {
        apply = function(loadout, effects, buff, inactive)
            effects.raw.cost_mod = effects.raw.cost_mod + 0.5;
            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + 50;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.item,
    },
    -- starsurge
    [417157] = {
        apply = function(loadout, effects, buff)
            spell_mod_add(effects.ability.effect_mod, spids.starfire, 0.8);
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.sod),
        category = buff_category.class,
    },
    -- enlightenment
    [412326] = {
        apply = function(loadout, effects, buff)
            if buff.id == 412326 then
                effects.mul.raw.spell_dmg_mod = effects.mul.raw.spell_dmg_mod * 1.1;
            elseif buff.id == 412325 then
                effects.raw.regen_while_casting = effects.raw.regen_while_casting + 0.1;
            end
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.class,
    },
    -- mental dexterity
    [415144] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                local sp = loadout.attack_power * 0.3;
                effects.raw.spell_dmg = effects.raw.spell_dmg + sp;
                effects.raw.healing_power = effects.raw.healing_power + sp;
            end
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.sod),
        category = buff_category.class,
    },
    -- tidal waves
    [432041] = {
        apply = function(loadout, effects, buff, inactive)
            spell_mod_add(effects.ability.cast_mod, spids.healing_wave, 0.3);
            spell_mod_add(effects.ability.cast_mod, spids.chain_heal, 0.15);
            spell_mod_add(effects.ability.crit, spids.lesser_healing_wave, 0.25);
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.sod),
        category = buff_category.class,
    },
    -- sigil of living dreams
    [446240] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + 50;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.consumes,
    },
    -- atalai mojo of forbidden magic
    [446256] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + 40;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.consumes,
    },
    -- atalai mojo of life
    [446396] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.healing_power = effects.raw.healing_power + 45;
                effects.raw.mp5 = effects.raw.mp5 + 11;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.consumes,
    },
    -- echoes of madness
    [446518] = {
        apply = function(loadout, effects, buff, inactive)
            effects.raw.haste_mod = effects.raw.haste_mod + 0.1;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.item,
    },
    -- echoes of fear
    [446592] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_dmg = effects.raw.spell_dmg + 50;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.item,
    },
    -- echoes of the depraved
    [446570] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_dmg = effects.raw.spell_dmg + 30;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.item,
    },
    -- shadow spark
    [450013] = {
        apply = function(loadout, effects, buff, inactive)
            local c = 2;
            if buff.src then
                c = buff.count;
            end
            spell_mod_add(effects.ability.cast_mod, spids.immolate, c * 0.5);
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.item,
    },
    -- for lordaeron
    [449982] = {
        apply = function(loadout, effects, buff, inactive)
            spell_mod_add(effects.ability.cast_mod_flat, spids.holy_light, 0.2);
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.sod),
        category = buff_category.item,
    },
    -- roar of the dream
    [446706] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_dmg = effects.raw.spell_dmg + 66;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.item,
        icon_id = GetItemIcon(221440)
    },
    -- roar of the grove
    [446711] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.healing_power = effects.raw.healing_power + 120;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.item,
    },
    -- fervor of the temple explorer
    [446695] = {
        apply = function(loadout, effects, buff, inactive)
            add_all_spell_crit(effects, 0.05, inactive);
            if inactive then
                effects.raw.spell_dmg = effects.raw.spell_dmg + 65;
                swc.loadout.add_int_mod(loadout, effects, 0.08, 0.08);
                swc.loadout.add_spirit_mod(loadout, effects, 0.08, 0.08);
            else
                swc.loadout.add_int_mod(loadout, effects, 0.0, 0.08);
                swc.loadout.add_spirit_mod(loadout, effects, 0.0, 0.08);
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.world_buffs,
    },
    -- fervor of the temple explorer
    [446698] = {
        apply = function(loadout, effects, buff, inactive)
            add_all_spell_crit(effects, 0.05, inactive);
            if inactive then
                effects.raw.spell_dmg = effects.raw.spell_dmg + 65;
                swc.loadout.add_int_mod(loadout, effects, 0.08, 0.08);
                swc.loadout.add_spirit_mod(loadout, effects, 0.08, 0.08);
            else
                swc.loadout.add_int_mod(loadout, effects, 0.0, 0.08);
                swc.loadout.add_spirit_mod(loadout, effects, 0.0, 0.08);
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.world_buffs,
    },
    -- tree of life form
    [439733] = {
        apply = function(loadout, effects, buff, inactive)
            spell_mod_add(effects.ability.cost_mod, spids.lifebloom, 0.2);
            spell_mod_add(effects.ability.cost_mod, spids.regrowth, 0.2);
            spell_mod_add(effects.ability.cost_mod, spids.rejuvenation, 0.2);
            spell_mod_add(effects.ability.cost_mod, spids.tranquility, 0.2);
            spell_mod_add(effects.ability.cost_mod, spids.wild_growth, 0.2);

            spell_mod_add(effects.ability.effect_mod, spids.wild_growth, 0.6);

            if inactive then
                swc.loadout.add_spirit_mod(loadout, effects, 0.25, 0.25);
            else
                swc.loadout.add_spirit_mod(loadout, effects, 0.0, 0.25);
            end
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.sod),
        category = buff_category.class,
    },
    -- decimation
    [440873] = {
        apply = function(loadout, effects, buff, inactive)
            spell_mod_add(effects.ability.cast_mod, spids.soul_fire, 0.4);
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.class,
    },
    -- survival instincts
    [408024] = {
        apply = function(loadout, effects, buff)
            effects.mul.raw.spell_heal_mod = effects.mul.raw.spell_heal_mod * 1.2;
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.sod),
        category = buff_category.class,
    },
    -- fel armor
    [403619] = {
        apply = function(loadout, effects, buff, inactive)
            effects.by_attribute.sp_from_stat_mod[stat.spirit] = effects.by_attribute.sp_from_stat_mod[stat.spirit] + 0.5;
            effects.by_attribute.hp_from_stat_mod[stat.spirit] = effects.by_attribute.hp_from_stat_mod[stat.spirit] + 0.5;
            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + loadout.lvl;
            end
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.class,
    },
    -- immolation aura
    [427726] = {
        apply = function(loadout, effects, buff, inactive)
            effects.mul.by_school.target_vuln_dmg[magic_school.fire] =
                effects.mul.by_school.target_vuln_dmg[magic_school.fire] * 1.1;
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.class,
    },
    -- might of stormwind
    [460940] = {
        apply = function(loadout, effects, buff, inactive)
            effects.raw.mp5 = effects.raw.mp5 + 10;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.alliance),
        category = buff_category.world_buffs,
    },
    -- melting faces
    [456549] = {
        apply = function(loadout, effects, buff, inactive)
            spell_mod_add(effects.ability.cast_mod_flat, spids.mind_flay, 1.5);
            spell_mod_add(effects.ability.effect_mod, spids.mind_flay, 0.5);
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.sod),
        category = buff_category.item,
    },
    -- fire trance
    [457558] = {
        apply = function(loadout, effects, buff, inactive)
            spell_mod_add(effects.ability.cast_mod, spids.immolate, 1.0);
            spell_mod_add(effects.ability.cast_mod, spids.incinerate, 1.0);
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.item,
    },
    -- astral power
    [467088] = {
        apply = function(loadout, effects, buff, inactive)
            local stacks = 3;
            if buff.count then
                stacks = buff.count;
            end
            spell_mod_add(effects.ability.effect_mod, spids.starfire, 0.1 * stacks);
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.sod),
        category = buff_category.item,
    },
    -- spirit tap
    [15271] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                swc.loadout.add_spirit_mod(loadout, effects, 1.0, 1.0);
            else
                swc.loadout.add_spirit_mod(loadout, effects, 0.0, 1.0);
            end
            effects.raw.regen_while_casting = effects.raw.regen_while_casting + 0.5;
            if bit.band(swc.core.client_deviation, swc.core.client_deviation_flags.sod) ~= 0 and
                loadout.num_set_pieces[set_tiers.sod_final_pve_2] >= 6 then
                effects.mul.by_school.target_vuln_dmg[magic_school.shadow] =
                    effects.mul.by_school.target_vuln_dmg[magic_school.shadow] * 1.25;
            end
        end,
        filter = bit.bor(buff_filters.priest),
        category = buff_category.class,
    },
    -- loyal beta
    [443320] = {
        apply = function(loadout, effects, buff, inactive)
            if loadout.num_set_pieces[set_tiers.sod_final_pve_2] >= 4 then
                effects.mul.by_school.target_vuln_dmg[magic_school.fire] =
                    effects.mul.by_school.target_vuln_dmg[magic_school.fire] * 1.05;
                effects.mul.by_school.target_vuln_dmg[magic_school.frost] =
                    effects.mul.by_school.target_vuln_dmg[magic_school.frost] * 1.05;
                effects.mul.by_school.target_vuln_dmg[magic_school.nature] =
                    effects.mul.by_school.target_vuln_dmg[magic_school.nature] * 1.05;
            end
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.sod),
        category = buff_category.class,
    },
    -- elemental focus
    [16164] = {
        apply = function(loadout, effects, buff, inactive)
            if loadout.num_set_pieces[set_tiers.sod_final_pve_2] >= 6 then
                effects.mul.raw.spell_dmg_mod = effects.mul.raw.spell_dmg_mod * 1.15;
            end
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.sod),
        category = buff_category.class,
    },
    -- zg trinket
    [468387] = {
        apply = function(loadout, effects, buff, inactive)
            effects.mul.raw.spell_heal_mod = effects.mul.raw.spell_heal_mod * 1.1;
            effects.mul.raw.spell_dmg_mod = effects.mul.raw.spell_dmg_mod * 1.1;
            add_all_spell_crit(effects, 0.1, inactive);
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.sod),
        category = buff_category.item,
    },
    -- master demonologist
    [23836] = {
        apply = function(loadout, effects, buff, inactive)
            local val = lookups.md_id_to_mod.map[buff.id];
            if val then
                if loadout.num_set_pieces[set_tiers.sod_final_pve_zg] >= 5 then
                    val = val * 1.5;
                end
                effects.mul.raw.spell_dmg_mod = effects.mul.raw.spell_dmg_mod * (1.0 + val);
            end
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
    },
    -- zg trinket
    [468512] = {
        apply = function(loadout, effects, buff, inactive)
            spell_mod_add(effects.ability.crit, spids.frostbolt, 0.05);
            spell_mod_add(effects.ability.crit, spids.spellfrost_bolt, 0.05);
            spell_mod_add(effects.ability.crit, spids.frozen_orb, 0.05);

            spell_mod_add(effects.ability.crit_mod, spids.frostbolt, 0.25);
            spell_mod_add(effects.ability.crit_mod, spids.spellfrost_bolt, 0.25);
            spell_mod_add(effects.ability.crit_mod, spids.frozen_orb, 0.25);
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.item,
    },
    -- sod mage t1 bonus
    [456399] = {
        apply = function(loadout, effects, buff)
            effects.mul.raw.spell_dmg_mod = effects.mul.raw.spell_dmg_mod * 1.01;
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.item,
    },
};

alias_buff(buffs_predefined, 20217, 25898, false); -- greater blessing of kings
alias_buff(buffs_predefined, 456400, 456399, false);
alias_buff(buffs_predefined, 456401, 456399, false);


alias_buffs_by_table(buffs_predefined, lookups.bow_id_to_mp5);
alias_buffs_by_table(buffs_predefined, lookups.mana_spring_id_to_mp5);
alias_buffs_by_table(buffs_predefined, lookups.md_id_to_mod);

local target_buffs_predefined = {
    -- amplify magic
    [10170] = {
        apply = function(loadout, effects, buff)
            local id_to_hp = lookups.amp_magic_id_to_hp.map;
            local id = 10170; -- default
            local hp = 0;

            if buff.id and id_to_hp[buff.id] then
                id = buff.id;
            end
            if buff.src and buff.src == "player" then
                hp = id_to_hp[id] * (1.0 + loadout.talents_table:pts(1, 7) * 0.25);
            else
                hp = id_to_hp[id] * 1.2;
            end
            effects.raw.healing_power = effects.raw.healing_power + hp;
            effects.raw.spell_dmg = effects.raw.spell_dmg + hp / 2;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- dampen magic
    [10174] = {
        apply = function(loadout, effects, buff)
            local id_to_hp = lookups.damp_magic_id_to_hp.map;
            local id = 10174; -- default
            local hp = 0;

            if buff.id and id_to_hp[buff.id] then
                id = buff.id;
            end
            if buff.src and buff.src == "player" then
                hp = id_to_hp[id] * (1.0 + loadout.talents_table:pts(1, 7) * 0.25);
            else
                hp = id_to_hp[id] * 1.2;
            end
            effects.raw.healing_power = effects.raw.healing_power - hp;
            effects.raw.spell_dmg = effects.raw.spell_dmg - hp / 2;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- blessing of light
    [19979] = {
        apply = function(loadout, effects, buff)
            local id_to_hl = lookups.bol_id_to_hl.map;
            local id_to_fl = lookups.bol_id_to_fl.map;
            local id = 19979; -- default

            if buff.id and id_to_hl[buff.id] and id_to_fl[buff.id] then
                id = buff.id;
            end

            spell_mod_add(effects.ability.flat_add, spids.holy_light, id_to_hl[id]);
            spell_mod_add(effects.ability.flat_add, spids.flash_of_light, id_to_fl[id]);
            -- NOTE: A special coef is applied to lower ranks of Holy Light and subtracted in later stage
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.friendly),
        category = buff_category.class,
    },
    -- healing way
    [29203] = {
        apply = function(loadout, effects, buff)
            local c = 0;
            if buff.count then
                c = buff.count
            else
                c = 3;
            end

            spell_mod_mul(effects.mul.ability.vuln_mod, spids.healing_wave, c * 0.06);
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.friendly),
        category = buff_category.class,
    },

    -- curse of the elements
    [11722] = {
        apply = function(loadout, effects, buff)
            local id_to_mod = lookups.coe_id_to_mod.map;
            local id_to_res = lookups.coe_id_to_res.map;
            local id = 11722; -- default

            if buff.id and id_to_mod[buff.id] and id_to_res[buff.id] then
                id = buff.id;
            end

            effects.by_school.target_res[magic_school.fire] =
                effects.by_school.target_res[magic_school.fire] + id_to_res[id];
            effects.by_school.target_res[magic_school.frost] =
                effects.by_school.target_res[magic_school.frost] + id_to_res[id];

            effects.mul.by_school.target_vuln_dmg[magic_school.fire] =
                effects.mul.by_school.target_vuln_dmg[magic_school.fire] * (1.0 + id_to_mod[id]);
            effects.mul.by_school.target_vuln_dmg[magic_school.frost] =
                effects.mul.by_school.target_vuln_dmg[magic_school.frost] * (1.0 + id_to_mod[id]);
            if buff.src and buff.src == "player" then
                effects.raw.target_num_afflictions = effects.raw.target_num_afflictions + 1;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- winters chill
    [12579] = {
        apply = function(loadout, effects, buff)
            local c = 0;
            if buff.count then
                c = buff.count
            else
                c = 5;
            end

            effects.by_school.spell_crit[magic_school.frost] =
                effects.by_school.spell_crit[magic_school.frost] + c * 0.02;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.frost, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- nightfall
    [23605] = {
        apply = function(loadout, effects, buff)
            for i = 1, 7 do
                effects.mul.by_school.target_vuln_dmg[i] =
                    effects.mul.by_school.target_vuln_dmg[i] * 1.15;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- improved scorch
    [22959] = {
        apply = function(loadout, effects, buff)
            local c = 0;
            if buff.count then
                c = buff.count
            else
                c = 5;
            end

            effects.mul.by_school.target_vuln_dmg[magic_school.fire] =
                effects.mul.by_school.target_vuln_dmg[magic_school.fire] * (1.0 + c * 0.03);
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- improved shadow bolt
    [17800] = {
        apply = function(loadout, effects, buff)
            local m = 0.2;
            if lookups.isb_to_vuln.map[buff.id] then
                m = lookups.isb_to_vuln.map[buff.id];
            end
            effects.mul.by_school.target_vuln_dmg[magic_school.shadow] =
                effects.mul.by_school.target_vuln_dmg[magic_school.shadow] * (1.0 + m);
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.shadow, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- shadow weaving
    [15258] = {
        apply = function(loadout, effects, buff)
            local c = 0;
            if buff.count then
                c = buff.count
            else
                c = 5;
            end

            effects.mul.by_school.target_vuln_dmg[magic_school.shadow] =
                effects.mul.by_school.target_vuln_dmg[magic_school.shadow] * (1.0 + c * 0.03);
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.shadow, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- stormstrike
    [17364] = {
        apply = function(loadout, effects, buff)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.stormstrike) == 0 then
                effects.mul.by_school.target_vuln_dmg[magic_school.nature] =
                    effects.mul.by_school.target_vuln_dmg[magic_school.nature] * 1.2;

                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.stormstrike);
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.nature, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- curse of shadow
    [17937] = {
        apply = function(loadout, effects, buff)
            local id_to_mod = lookups.cos_id_to_mod.map;
            local id_to_res = lookups.cos_id_to_res.map;
            local id = 17937; -- default

            if buff.id and id_to_mod[buff.id] and id_to_res[buff.id] then
                id = buff.id;
            end

            effects.by_school.target_res[magic_school.shadow] =
                effects.by_school.target_res[magic_school.shadow] + id_to_res[id];
            effects.by_school.target_res[magic_school.arcane] =
                effects.by_school.target_res[magic_school.arcane] + id_to_res[id];

            effects.mul.by_school.target_vuln_dmg[magic_school.shadow] =
                effects.mul.by_school.target_vuln_dmg[magic_school.shadow] * (1.0 + id_to_mod[id]);
            effects.mul.by_school.target_vuln_dmg[magic_school.arcane] =
                effects.mul.by_school.target_vuln_dmg[magic_school.arcane] * (1.0 + id_to_mod[id]);

            if buff.src and buff.src == "player" then
                effects.raw.target_num_afflictions = effects.raw.target_num_afflictions + 1;
                effects.raw.target_num_shadow_afflictions = effects.raw.target_num_shadow_afflictions + 1;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- frost nova
    [122] = {
        apply = function(loadout, effects, buff)
            loadout.flags = bit.bor(loadout.flags, loadout_flags.target_frozen, loadout_flags.target_snared);
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.hostile),
        category = buff_category.class,
    },
    -- haunt
    [403501] = {
        apply = function(loadout, effects, buff)
            if not buff.src and buff.src == "player" then
                effects.mul.by_school.target_vuln_dmg_ot[magic_school.shadow] =
                    effects.mul.by_school.target_vuln_dmg_ot[magic_school.shadow] * 1.2;

                effects.raw.target_num_afflictions = effects.raw.target_num_afflictions + 1;
                effects.raw.target_num_shadow_afflictions = effects.raw.target_num_shadow_afflictions + 1;
            end
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.hostile),
        category = buff_category.class,
    },
    -- corruption
    [172] = {
        apply = function(loadout, effects, buff)
            if not buff.src and buff.src == "player" then
                effects.raw.target_num_afflictions = effects.raw.target_num_afflictions + 1;
                effects.raw.target_num_shadow_afflictions = effects.raw.target_num_shadow_afflictions + 1;
            end
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.hostile),
        category = buff_category.class,
    },
    -- shadow word: pain, twisted faith sod rune
    [589] = {
        apply = function(loadout, effects, buff)
            if not buff.src or buff.src == "player" then
                spell_mod_mul(effects.mul.ability.vuln_mod, spids.mind_blast, 0.5);
                spell_mod_mul(effects.mul.ability.vuln_mod, spids.mind_flay, 0.5);
            end
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.hostile),
        category = buff_category.class,
    },
    -- lake of fire
    [403650] = {
        apply = function(loadout, effects, buff)
            if not buff.src or buff.src == "player" then
                effects.raw.target_num_afflictions = effects.raw.target_num_afflictions + 1;
                effects.mul.by_school.target_vuln_dmg[magic_school.fire] =
                    effects.mul.by_school.target_vuln_dmg[magic_school.fire] * 1.5;
            end
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.hostile),
        category = buff_category.class,
    },
    --beacon of light
    [407613] = {
        -- just used for toggle and icon in buffs, applied later
        apply = function(loadout, effects, buff)
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.friendly),
        category = buff_category.class,
    },
    -- beast slaying (troll)
    [20557] = {
        apply = function(loadout, effects, buff)
            for i = 1, 7 do
                effects.mul.by_school.target_vuln_dmg[i] = effects.mul.by_school.target_vuln_dmg[i] * 1.05;
            end
        end,
        filter = bit.bor(buff_filters.troll, buff_filters.hostile),
        category = buff_category.class,
    },
    -- flame shock (lava burst crit)
    [8050] = {
        apply = function(loadout, effects, buff)
            spell_mod_add(effects.ability.crit, spids.lava_burst, 1.0);
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.hostile),
        category = buff_category.class,
    },
    -- weakened soul
    [6788] = {
        apply = function(loadout, effects, buff)
            if loadout.runes[swc.talents.rune_ids.renewed_hope] then
                for k, v in pairs(spell_groups.weakened_soul_affected) do
                    spell_mod_add(effects.ability.crit, v, 0.2);
                end
            end
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.friendly),
        category = buff_category.class,
    },
    -- deep freeze
    [428739] = {
        apply = function(loadout, effects, buff)
            loadout.flags = bit.bor(loadout.flags, loadout_flags.target_frozen, loadout_flags.target_snared);
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.hostile),
        category = buff_category.class,
    },
    -- dreamstate
    [437132] = {
        apply = function(loadout, effects, buff)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.stormstrike) == 0 then
                effects.mul.by_school.target_vuln_dmg[magic_school.nature] =
                    effects.mul.by_school.target_vuln_dmg[magic_school.nature] * 1.2;

                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.stormstrike);
            end
            effects.mul.by_school.target_vuln_dmg[magic_school.arcane] =
                effects.mul.by_school.target_vuln_dmg[magic_school.arcane] * 1.2;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- rejuv
    [774] = {
        apply = function(loadout, effects, buff)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.druid_nourish_bonus) == 0 then
                spell_mod_mul(effects.mul.ability.vuln_mod, spids.nourish, 0.2);

                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.druid_nourish_bonus);
            end
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.sod, buff_filters.friendly),
        category = buff_category.class,
    },
    -- mind spike
    [431655] = {
        apply = function(loadout, effects, buff)
            local c = 0;
            if buff.count then
                c = buff.count
            else
                c = 3;
            end
            spell_mod_add(effects.ability.crit, spids.mind_blast, c * 0.3);
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.sod, buff_filters.hostile),
        category = buff_category.class,
    },
    -- sacred shield
    [412019] = {
        apply = function(loadout, effects, buff)
            spell_mod_add(effects.ability.crit, spids.flash_of_light, 0.5);
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.sod, buff_filters.friendly),
        category = buff_category.class,
    },
    -- riptide
    [408521] = {
        apply = function(loadout, effects, buff)
            spell_mod_mul(effects.mul.ability.vuln_mod, spids.chain_heal, 0.25);
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.sod, buff_filters.friendly),
        category = buff_category.class,
    },
    -- tree of life
    [439745] = {
        apply = function(loadout, effects, buff)
            effects.mul.raw.target_vuln_heal = effects.mul.raw.target_vuln_heal * 1.1;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod, buff_filters.friendly),
        category = buff_category.raid,
    },
    -- mark of chaos
    [461615] = {
        apply = function(loadout, effects, buff)
            for i = 1, 7 do
                effects.mul.by_school.target_vuln_dmg[i] =
                    effects.mul.by_school.target_vuln_dmg[i] * 1.11;
                effects.by_school.target_res[i] = effects.by_school.target_res[i] + 0.75
            end
            if not buff.src and buff.src == "player" then
                effects.raw.target_num_afflictions = effects.raw.target_num_afflictions + 1;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile, buff_filters.sod),
        category = buff_category.raid,
    },
    -- fireball
    [133] = {
        apply = function(loadout, effects, buff)
            if loadout.num_set_pieces[set_tiers.sod_final_pve_2] >= 4 then
                spell_mod_mul(effects.mul.ability.vuln_mod, spids.pyroblast, 0.2);
            end
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.hostile, buff_filters.sod),
        category = buff_category.class,
    },
    -- immolate
    [348] = {
        apply = function(loadout, effects, buff)
            if not buff.src and buff.src == "player" then
                effects.raw.target_num_afflictions = effects.raw.target_num_afflictions + 1;
            end
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.hostile),
        category = buff_category.class,
    },
};

alias_buff(target_buffs_predefined, 8936, 774, false);
alias_buff(target_buffs_predefined, 408124, 774, false);
alias_buff(target_buffs_predefined, 408120, 774, false);

alias_buff(target_buffs_predefined, 980, 172, false);
alias_buff(target_buffs_predefined, 18265, 172, false);
alias_buff(target_buffs_predefined, 427717, 172, false);

--alias_buff(target_buffs_predefined, 25890, 19979, false); -- greater blessing of light

alias_buffs_by_table(target_buffs_predefined, lookups.amp_magic_id_to_hp);
alias_buffs_by_table(target_buffs_predefined, lookups.damp_magic_id_to_hp);
alias_buffs_by_table(target_buffs_predefined, lookups.bol_id_to_hl);
alias_buffs_by_table(target_buffs_predefined, lookups.coe_id_to_mod);
alias_buffs_by_table(target_buffs_predefined, lookups.cos_id_to_mod);
alias_buffs_by_table(target_buffs_predefined, lookups.isb_to_vuln);

local buffs = {};
for k, v in pairs(buffs_predefined) do
    if v.filter == bit.band(filter_flags_active, v.filter) then
        local buff_lname = GetSpellInfo(k);
        buffs[k] = v;
        buffs[k].lname = buff_lname;
        buffs[k].id = k;
    end
end
local target_buffs = {};
for k, v in pairs(target_buffs_predefined) do
    if v.filter == bit.band(filter_flags_active, v.filter) then
        local buff_lname = GetSpellInfo(k);
        target_buffs[k] = v;
        target_buffs[k].lname = buff_lname;
        target_buffs[k].id = k;
    end
end

-- allows weapon enchant buffs to be registered as buffs
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
    if race == "Troll" and loadout.target_creature_type == "Beast" then
        local racial_id = 20557;
        loadout.dynamic_buffs["target"][racial_id] = { count = 1, id = racial_id, nil, nil };
    end
    local _, _, _, enchant_id = GetWeaponEnchantInfo();
    local wep_enchant_id_to_buff = lookups.wep_enchant_id_to_buff.map;
    if enchant_id and wep_enchant_id_to_buff[enchant_id] then

        local buff_id = wep_enchant_id_to_buff[enchant_id];
        loadout.dynamic_buffs["player"][buff_id] = { count = 1, id = buff_id, nil, nil };
    end
end

local function apply_buffs(loadout, effects)

    --TEST
    for k, v in pairs(swc.player_buffs) do
        apply_effect(loadout, effects, v, false, nil, k);
    end
    --

    for k, v in pairs(loadout.dynamic_buffs["player"]) do
        if buffs[k] then
            buffs[k].apply(loadout, effects, v);
        end
    end
    local target_buffs_applied = {};
    for k, v in pairs(loadout.dynamic_buffs[loadout.friendly_towards]) do
        if target_buffs[k] and bit.band(buff_filters.friendly, target_buffs[k].filter) ~= 0 then
            target_buffs[k].apply(loadout, effects, v);
            target_buffs_applied[k] = true;
        end
    end
    if loadout.hostile_towards then
        for k, v in pairs(loadout.dynamic_buffs[loadout.hostile_towards]) do
            if target_buffs[k] and bit.band(buff_filters.hostile, target_buffs[k].filter) ~= 0 then
                target_buffs[k].apply(loadout, effects, v);
                target_buffs_applied[k] = true;
            end
        end
    end

    local beacon_duration = 60;
    if class == "PALADIN" and loadout.runes[swc.talents.rune_ids.beacon_of_light] and swc.core.beacon_snapshot_time + beacon_duration >= swc.core.addon_running_time then
        loadout.beacon = true;
    else
        loadout.beacon = nil
    end

    if config.loadout.force_apply_buffs then
        for k, _ in pairs(config.loadout.buffs) do
            if not loadout.dynamic_buffs["player"][k] and buffs[k] then
                buffs[k].apply(loadout, effects, buffs[k], true);
            end
        end
        for k, _ in pairs(config.loadout.target_buffs) do
            if not target_buffs_applied[k] then
                target_buffs[k].apply(loadout, effects, target_buffs[k], true);
            end
        end

        if class == "PALADIN" and config.loadout.target_buffs[lookups.beacon_of_light] then
            loadout.beacon = true;
        end
    end

    if swc.core.__sw__test_all_codepaths then
        for k, v in pairs(buffs) do
            if v then
                v.apply(loadout, effects, v, true);
                v.apply(loadout, effects, v, false);
            end
        end
        for k, v in pairs(target_buffs) do
            v.apply(loadout, effects, v, true);
            v.apply(loadout, effects, v);
        end
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

swc.buffs = buffs_export;
