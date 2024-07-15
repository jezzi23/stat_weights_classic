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
local _, swc = ...;

local ensure_exists_and_add         = swc.utils.ensure_exists_and_add;
local deep_table_copy               = swc.utils.deep_table_copy;
local stat                          = swc.utils.stat;
local class                         = swc.utils.class;
local race                          = swc.utils.race;
local faction                       = swc.utils.faction;
local loadout_flags                 = swc.utils.loadout_flags;
local add_all_spell_crit            = swc.utils.add_all_spell_crit;

local magic_school                  = swc.abilities.magic_school;
local spell_name_to_id              = swc.abilities.spell_name_to_id;
local spell_names_to_id             = swc.abilities.spell_names_to_id;

local set_tiers                     = swc.equipment.set_tiers;

-------------------------------------------------------------------------------
local buffs_export = {};

local buff_filters = {
    caster      = bit.lshift(1,1),
    --
    priest      = bit.lshift(1,2),
    mage        = bit.lshift(1,3),
    warlock     = bit.lshift(1,4),
    druid       = bit.lshift(1,5),
    shaman      = bit.lshift(1,6),
    paladin     = bit.lshift(1,7),
    --
    troll       = bit.lshift(1,8),
    belf        = bit.lshift(1,9),

    -- for buffs/debuffs that affect healing taken or dmg taken
    friendly    = bit.lshift(1,11),
    hostile     = bit.lshift(1,12),
    horde       = bit.lshift(1,13),
    alliance    = bit.lshift(1,14),

    -- hidden buffs to deal with, not toggled
    hidden      = bit.lshift(1,15),

    sod         = bit.lshift(1,16),
    sod_p1_only = bit.lshift(1,17),
    sod_p2_only = bit.lshift(1,18),
    sod_p3_only = bit.lshift(1,19),
};

local buff_category = {
    talent      = 1,
    class       = 2,
    raid        = 3,
    world_buffs = 5,
    consumes    = 4,
    item        = 6,
};

local filter_flags_active = 0;
filter_flags_active = bit.bor(filter_flags_active, buff_filters.caster);
if class == "PRIEST" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.priest);
elseif class == "DRUID" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.druid);
elseif class == "SHAMAN" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.shaman);
elseif class == "MAGE" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.mage);
elseif class == "WARLOCK" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.warlock);
elseif class == "PALADIN" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.paladin);
end

if faction == "Horde" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.horde);
else
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.alliance);
end

if race == "Troll" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.troll);
end

local non_stackable_effects = {
    moonkin_crit                = bit.lshift(1, 0),
    arcane_empowerment          = bit.lshift(1, 1),
    totem_of_wrath_sp           = bit.lshift(1, 2),
    moonkin_haste               = bit.lshift(1, 3),
    earth_and_moon              = bit.lshift(1, 4),
    totem_of_wrath_crit_target  = bit.lshift(1, 5),
    misery_hit                  = bit.lshift(1, 6),
    mage_crit_target            = bit.lshift(1, 7),
    water_shield                = bit.lshift(1, 9),
    druid_nourish_bonus         = bit.lshift(1, 10),
    bow_mp5                     = bit.lshift(1, 11),
    bok                         = bit.lshift(1, 12),
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
            effects.raw.spell_heal_mod_mul = (1.0 + effects.raw.spell_heal_mod_mul) * 1.2 - 1.0;
            effects.raw.spell_dmg_mod_mul = (1.0 + effects.raw.spell_dmg_mod_mul) * 1.2 - 1.0;
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
    },
    --arcane power
    [12042] = {
        apply = function(loadout, effects, buff)
            effects.by_school.spell_dmg_mod_add[magic_school.fire] = 
                effects.by_school.spell_dmg_mod_add[magic_school.fire] + 0.3;
            effects.by_school.spell_dmg_mod_add[magic_school.arcane] = 
                effects.by_school.spell_dmg_mod_add[magic_school.arcane] + 0.3;
            effects.by_school.spell_dmg_mod_add[magic_school.frost] = 
                effects.by_school.spell_dmg_mod_add[magic_school.frost] + 0.3;

            effects.raw.cost_mod_base = effects.raw.cost_mod_base - 0.3;
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
            effects.raw.spell_dmg_mod_mul = (1.0 + effects.raw.spell_dmg_mod_mul) * 1.1 - 1.0;
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
            local destr = spell_names_to_id({"Immolate", "Shadow Bolt", "Hellfire", "Searing Pain", "Rain of Fire", "Conflagrate", "Shadowburn", "Soul Fire"});
            for k, v in pairs(destr) do
                ensure_exists_and_add(effects.ability.crit, v, 0.1, 0);
            end
        end,
        filter = buff_filters.warlock,
        category = buff_category.item,
    },
    -- zg trinket
    [24546] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id["Greater Heal"], 0.4, 0);
            local heals = spell_names_to_id({"Greater Heal", "Renew", "Prayer of Healing", "Lesser Heal", "Heal", "Flash Heal", "Holy Nova"});
            for k, v in pairs(heals) do
                ensure_exists_and_add(effects.ability.cost_mod, v, 0.05, 0);
            end
        end,
        filter = buff_filters.priest,
        category = buff_category.item,
    },
    -- zg trinket
    [24499] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Lightning Shield"], 0.5, 0);
        end,
        filter = buff_filters.shaman,
        category = buff_category.item,
    },
    -- zg trinket
    [24542] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id["Healing Touch"], 0.4, 0);
            ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id["Nourish"], 0.4, 0);
            local heals = spell_names_to_id({"Tranquility", "Rejuvenation", "Healing Touch", "Regrowth", "Nourish"});
            for k, v in pairs(heals) do
                ensure_exists_and_add(effects.ability.cost_mod, v, 0.05, 0);
            end
        end,
        filter = buff_filters.druid,
        category = buff_category.item,
    },
    -- amplify curse
    [18288] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.effect_mod_base, spell_name_to_id["Curse of Agony"], 0.5, 0);
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
    },
    -- demonic sacrifice succ
    [18791] = {
        apply = function(loadout, effects, buff)
            effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.shadow]) * 1.15 - 1.0;
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
                effects.by_school.spell_dmg_mod[magic_school.shadow] =
                    (1.0 + effects.by_school.spell_dmg_mod[magic_school.shadow]) * 1.25 - 1.0;
            else
                effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                    (1.0 + effects.by_school.spell_dmg_mod[magic_school.shadow]) * 1.15 - 1.0;

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
    [20217] = {
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
        filter = bit.bor(buff_filters.alliance, buff_filters.hidden),
        category = buff_category.raid,
    },

    -- vengeance
    [20055] = {
        apply = function(loadout, effects, buff)

            effects.by_school.spell_dmg_mod[magic_school.holy] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.holy]) * 1.15 - 1.0;

        end,
        filter = buff_filters.paladin,
        category = buff_category.class,
    },
    -- nature aligned
    [23734] = {
        apply = function(loadout, effects, buff)
            effects.raw.cost_mod = effects.raw.cost_mod - 0.2;
            effects.raw.spell_heal_mod_mul = (1.0 + effects.raw.spell_heal_mod_mul) * 1.2 - 1.0;
            effects.raw.spell_dmg_mod_mul = (1.0 + effects.raw.spell_dmg_mod_mul) * 1.2 - 1.0;
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

            effects.raw.regen_while_casting = effects.raw.regen_while_casting + 0.3;
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

                local id_to_mp5 = {
                    [19742] = 10,
                    [19850] = 15,
                    [19852] = 20,
                    [19853] = 25,
                    [19854] = 30,
                    [25290] = 33,
                };
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
                ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Moonfire"], 0.5, 0);
                ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Sunfire"], 0.5, 0);

                ensure_exists_and_add(effects.ability.effect_ot_mod, spell_name_to_id["Moonfire"], 0.5, 0);
                ensure_exists_and_add(effects.ability.effect_ot_mod, spell_name_to_id["Sunfire"], 0.5, 0);

                if inactive then
                    effects.raw.spell_dmg = effects.raw.spell_dmg + 2*loadout.lvl;
                end
            end
        end,
        filter = buff_filters.druid,
        category = buff_category.class,
    },
    -- mana spring
    [10497] = {
        apply = function(loadout, effects, buff)

            local id_to_mp5 = {
                [5677]  = 4,
                [10495] = 6,
                [10496] = 8,
                [10497] = 10,
            };
            local id = 10497; -- default
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
            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.fire]) * 1.15 - 1.0;
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
            ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id["Healing Touch"], 1.00, 0);
            ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id["Nourish"], 1.00, 0);
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
            effects.by_school.spell_dmg_mod_add[magic_school.arcane] = 
                effects.by_school.spell_dmg_mod_add[magic_school.arcane] + 0.15 * stacks;
            -- arcane blast is exempt from damage increase
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Arcane Blast"], -0.15 * stacks, 0.0); 
            ensure_exists_and_add(effects.ability.cost_mod_base, spell_name_to_id["Arcane Blast"], -stacks * 1.75, 0.0); 

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
            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.fire]) * 1.25 - 1.0;
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.class,
    },
    -- metamorphosis
    [403789] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Life Tap"], 1.0, 0.0);    
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
            local heals = spell_names_to_id({"Lesser Heal", "Heal", "Greater Heal", "Prayer of Healing"});
            for k, v in pairs(heals) do
                ensure_exists_and_add(effects.ability.cast_mod_mul, v, c*0.2, 0.0);    
            end
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.sod),
        category = buff_category.class,
    },
    -- demonic grace
    [425463] = {
        apply = function(loadout, effects, buff, inactive)

            add_all_spell_crit(effects, 0.3, inactive);
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.class,
    },
    -- demonic pact
    [425467] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + math.max(0.1*effects.raw.spell_power, loadout.lvl/2);
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod),
        category = buff_category.raid,
    },
    -- tangled causality
    [432069] = {
        apply = function(loadout, effects, buff)

            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.fire]) * 0.5 - 1.0;
            effects.by_school.spell_dmg_mod[magic_school.frost] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.frost]) * 0.5 - 1.0;
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
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p1_only),
        category = buff_category.consumes,
        icon_id = GetItemIcon(211848),
    },
    -- ashenvale rallying cry
    [430352] = {
        apply = function(loadout, effects, buff)
            effects.raw.spell_heal_mod_mul = (1.0 + effects.raw.spell_heal_mod_mul) * 1.05 - 1.0;
            effects.raw.spell_dmg_mod_mul = (1.0 + effects.raw.spell_dmg_mod_mul) * 1.05 - 1.0;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p1_only),
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
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p1_only),
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
            ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id["Smite"], 1.0, 0);
            ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id["Flash Heal"], 1.0, 0);
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

            for k, v in pairs(spell_names_to_id({"Lightning Bolt", "Chain Lightning", "Lesser Healing Wave", "Healing Wave", "Chain Heal", "Lava Burst"})) do
                ensure_exists_and_add(effects.ability.cast_mod_mul, v, c*0.2, 0);
            end
            
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.sod),
        category = buff_category.class,
    },
    -- power surge
    [415105] = {
        apply = function(loadout, effects, buff)
            for k, v in pairs(spell_names_to_id({"Chain Lightning", "Lava Burst", "Chain Heal"})) do
                ensure_exists_and_add(effects.ability.cast_mod_mul, v, 1.0, 0);
            end
            
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.sod),
        category = buff_category.class,
    },
    -- hot streak
    [400625] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id["Pyroblast"], 1.0, 0);
            
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.class,
    },
    -- missile barrage
    [400589] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.cast_mod_reduce, spell_name_to_id["Arcane Missiles"], 0.5, 0);
            ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Arcane Missiles"], 1.0, 0);
            
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.sod),
        category = buff_category.class,
    },
    -- brain freeze
    [400730] = {
        apply = function(loadout, effects, buff)

            for k, v in pairs(spell_names_to_id({"Fireball", "Spellfrost Bolt", "Frostfire Bolt"})) do
                ensure_exists_and_add(effects.ability.cast_mod_mul, v, 1.0, 0);
                ensure_exists_and_add(effects.ability.cost_mod, v, 1.0, 0);
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
                c = 10;
            end

            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Balefire Bolt"], c*0.1, 0);
            
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
            effects.raw.spell_dmg_mod_mul = (1.0 + effects.raw.spell_dmg_mod_mul) * 1.25 - 1.0;
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod),
        category = buff_category.class,
    },
    -- shadow and flame
    [426311] = {
        apply = function(loadout, effects, buff)

            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.fire]) * 1.1 - 1.0;
            effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.shadow]) * 1.1 - 1.0;
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
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Wrath"], 0.3, 0);
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Starsurge"], 0.3, 0);
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.sod),
        category = buff_category.class,
    },
    -- eclipse: lunar
    [408255] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Starfire"], 1.0, 0);
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
            effects.raw.spell_dmg_mod_mul = (1.0 + effects.raw.spell_dmg_mod_mul) * 1.3 - 1.0;
        end,
        filter = buff_filters.caster,
        category = buff_category.world_buffs,
    },
    [429868] = {
        apply = function(loadout, effects, buff)

            effects.raw.spell_dmg_mod_mul = (1.0 + effects.raw.spell_dmg_mod_mul) * 1.1 - 1.0;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod, buff_filters.sod_p1_only),
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
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p2_only),
        category = buff_category.world_buffs,
    },
    -- mildly irradiated
    [435973] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + 35;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p2_only),
        category = buff_category.item,
    },
    -- coin flip
    [437698] = {
        apply = function(loadout, effects, buff, inactive)
            add_all_spell_crit(effects, 0.03, inactive);
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p2_only),
        category = buff_category.item,
    },
    -- hyperconductive shock
    [437362] = {
        apply = function(loadout, effects, buff, inactive)
            effects.raw.haste_mod = effects.raw.haste_mod + 0.2;
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.paladin, buff_filters.sod_p2_only),
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
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p2_only),
        category = buff_category.item,
    },
    -- starsurge
    [417157] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Starfire"], 0.8, 0);
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.sod),
        category = buff_category.class,
    },
    -- enlightenment
    [412326] = {
        apply = function(loadout, effects, buff)
            if buff.id == 412326 then
                effects.raw.spell_dmg_mod_mul = (1.0 + effects.raw.spell_dmg_mod_mul) * 1.1 - 1.0;
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
            ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id["Healing Wave"], 0.3, 0);
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Lesser Healing Wave"], 0.25, 0);
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
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p3_only),
        category = buff_category.consumes,
    },
    -- atalai mojo of forbidden magic
    [446256] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + 40;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p3_only),
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
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p3_only),
        category = buff_category.consumes,
    },
    -- echoes of madness
    [446518] = {
        apply = function(loadout, effects, buff, inactive)
            effects.raw.haste_mod = effects.raw.haste_mod + 0.1;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p3_only),
        category = buff_category.item,
    },
    -- echoes of fear
    [446592] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_dmg = effects.raw.spell_dmg + 50;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p3_only),
        category = buff_category.item,
    },
    -- echoes of the depraved
    [446570] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_dmg = effects.raw.spell_dmg + 30;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p3_only),
        category = buff_category.item,
    },
    -- shadow spark
    [450013] = {
        apply = function(loadout, effects, buff, inactive)
            local c = 2;
            if buff.src then
                c = buff.count;
            end
            ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id["Immolate"], c*0.5, 0);
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod_p3_only),
        category = buff_category.item,
    },
    -- for lordaeron
    [449982] = {
        apply = function(loadout, effects, buff, inactive)
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Holy Light"], 0.2, 0);
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.sod_p3_only),
        category = buff_category.item,
    },
    -- roar of the dream
    [446706] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_dmg = effects.raw.spell_dmg + 66;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p3_only),
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
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p3_only),
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
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p3_only),
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
        filter = bit.bor(buff_filters.caster, buff_filters.sod_p3_only),
        category = buff_category.world_buffs,
    },
    -- tree of life form
    [439733] = {
        apply = function(loadout, effects, buff, inactive)
            
            ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Lifebloom"], 0.2, 0);
            ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Regrowth"], 0.2, 0);
            ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Rejuvenation"], 0.2, 0);
            ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Tranquility"], 0.2, 0);
            ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Wild Growth"], 0.2, 0);

            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Wild Growth"], 0.6, 0);

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
            ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id["Soul Fire"], 0.4, 0);
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.sod_p3_only),
        category = buff_category.class,
    },
};

local target_buffs_predefined = {
    -- amplify magic
    [10170] = {
        apply = function(loadout, effects, buff)

            local id_to_hp = {
                [1008]  = 30,
                [8455]  = 60,
                [10169] = 100,
                [10170] = 150,
            };
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
            effects.raw.spell_dmg = effects.raw.spell_dmg + hp/2;

        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- dampen magic
    [10174] = {
        apply = function(loadout, effects, buff)

            local id_to_hp = {
                [604]   = 20,
                [8450]  = 40,
                [8451]  = 80,
                [10173] = 120,
                [10174] = 180,
            };
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
            effects.raw.spell_dmg = effects.raw.spell_dmg - hp/2;

        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- blessing of light
    [19979] = {
        apply = function(loadout, effects, buff)

            local id_to_hl = {
                [19977]  = 210,
                [19978]  = 300,
                [19979]  = 400
            };
            local id_to_fl = {
                [19977]  = 60,
                [19978]  = 85,
                [19979]  = 115
            };
            local id = 19979; -- default

            if buff.id and id_to_hl[buff.id] and id_to_fl[buff.id] then
                id = buff.id;
            end

            ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Holy Light"], id_to_hl[id], 0);
            ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Flash of Light"], id_to_fl[id], 0);

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

            ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Healing Wave"], 3 * 0.06, 0);

        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.friendly),
        category = buff_category.class,
    },

    -- curse of the elements
    [11722] = {
        apply = function(loadout, effects, buff)
            local id_to_mod = {
                [1490]   = 0.06,
                [11721]  = 0.08,
                [11722]  = 0.1,
                [402792] = 0.1
            };
            local id_to_res = {
                [1490]   = 45,
                [11721]  = 60,
                [11722]  = 75,
                [402792] = 75
            };
            local id = 11722; -- default

            if buff.id and id_to_mod[buff.id] and id_to_res[buff.id] then
                id = buff.id;
            end

            effects.by_school.target_res[magic_school.fire] =
                effects.by_school.target_res[magic_school.fire] + id_to_res[id];
            effects.by_school.target_res[magic_school.frost] =
                effects.by_school.target_res[magic_school.frost] + id_to_res[id];

            effects.by_school.target_spell_dmg_taken[magic_school.fire] =
                (1.0 + effects.by_school.target_spell_dmg_taken[magic_school.fire]) * (1.0 + id_to_mod[id]) - 1.0;
            effects.by_school.target_spell_dmg_taken[magic_school.frost] =
                (1.0 + effects.by_school.target_spell_dmg_taken[magic_school.frost]) * (1.0 + id_to_mod[id]) - 1.0;
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
        filter = bit.bor(buff_filters.mage, buff_filters.shaman, buff_filters.priest, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- nightfall
    [23605] = {
        apply = function(loadout, effects, buff)
            for i = 1, 7 do
                effects.by_school.target_spell_dmg_taken[i] =
                    (1.0 + effects.by_school.target_spell_dmg_taken[i]) * 1.15 - 1.0;
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

            effects.by_school.target_spell_dmg_taken[magic_school.fire] =
                (1.0 + effects.by_school.target_spell_dmg_taken[magic_school.fire]) * (1.0 + c * 0.03) - 1.0;

        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- improved shadow bolt
    [17800] = {
        apply = function(loadout, effects, buff)

            if buff.src and buff.src == "player" then
                effects.by_school.target_spell_dmg_taken[magic_school.shadow] =
                    (1.0 + effects.by_school.target_spell_dmg_taken[magic_school.shadow]) * (1.0 + 0.04 * loadout.talents_table:pts(3, 1)) - 1.0;
            else
                effects.by_school.target_spell_dmg_taken[magic_school.shadow] =
                    (1.0 + effects.by_school.target_spell_dmg_taken[magic_school.shadow]) * 1.2 - 1.0;
            end

        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.hostile),
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

            effects.by_school.target_spell_dmg_taken[magic_school.shadow] =
                (1.0 + effects.by_school.target_spell_dmg_taken[magic_school.shadow]) * (1.0 + c * 0.03) - 1.0;

        end,
        filter = bit.bor(buff_filters.priest, buff_filters.warlock, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- stormstrike
    [17364] = {
        apply = function(loadout, effects, buff)
            effects.by_school.target_spell_dmg_taken[magic_school.nature] =
                (1.0 + effects.by_school.target_spell_dmg_taken[magic_school.nature]) * 1.2 - 1.0;

        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.druid, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- curse of shadow
    [17937] = {
        apply = function(loadout, effects, buff)
            local id_to_mod = {
                [17862]  = 0.08,
                [17937]  = 0.1,
                [402791]  = 0.1,
            };
            local id_to_res = {
                [17862]  = 60,
                [17937]  = 75,
                [402791] = 75,
            };
            local id = 17937; -- default

            if buff.id and id_to_mod[buff.id] and id_to_res[buff.id] then
                id = buff.id;
            end

            effects.by_school.target_res[magic_school.shadow] =
                effects.by_school.target_res[magic_school.shadow] + id_to_res[id];
            effects.by_school.target_res[magic_school.arcane] =
                effects.by_school.target_res[magic_school.arcane] + id_to_res[id];

            effects.by_school.target_spell_dmg_taken[magic_school.shadow] =
                (1.0 + effects.by_school.target_spell_dmg_taken[magic_school.shadow]) * (1.0 + id_to_mod[id]) - 1.0;
            effects.by_school.target_spell_dmg_taken[magic_school.arcane] =
                (1.0 + effects.by_school.target_spell_dmg_taken[magic_school.arcane]) * (1.0 + id_to_mod[id]) - 1.0;
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.priest, buff_filters.mage, buff_filters.druid, buff_filters.hostile),
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
            if not buff.src or buff.src == "player" then
                effects.by_school.target_spell_dmg_taken_ot[magic_school.shadow] =
                    effects.by_school.target_spell_dmg_taken_ot[magic_school.shadow] + 0.2;
            end
            if loadout.runes[swc.talents.rune_ids.soul_siphon] then
                if loadout.enemy_hp_perc and loadout.enemy_hp_perc <= 0.2 then
                    ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Drain Soul"], 0.5, 0);
                else
                    ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Drain Soul"], 0.06, 0);

                end
                ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Drain Life"], 0.06, 0);
            end
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.hostile),
        category = buff_category.class,
    },
    -- corruption
    [172] = {
        apply = function(loadout, effects, buff)
            if loadout.runes[swc.talents.rune_ids.soul_siphon] then
                ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Drain Soul"], 0.06, 0);
                ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Drain Life"], 0.06, 0);
            end
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.hostile),
        category = buff_category.class,
    },
    -- shadow word: pain, twisted faith sod rune
    [589] = {
        apply = function(loadout, effects, buff)
            if not buff.src or buff.src == "player" then
                ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Mind Blast"], 0.5, 0);
                ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Mind Flay"], 0.5, 0);
            end
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.hostile),
        category = buff_category.class,
    },
    -- lake of fire
    [403650] = {
        apply = function(loadout, effects, buff)
            if not buff.src or buff.src == "player" then
                effects.by_school.target_spell_dmg_taken[magic_school.fire] =
                    (1.0 + effects.by_school.target_spell_dmg_taken[magic_school.fire]) * 1.5 - 1.0;
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
                effects.by_school.target_spell_dmg_taken[i] = (1.0 + effects.by_school.target_spell_dmg_taken[i]) * 1.05 - 1.0;
            end
        end,
        filter = bit.bor(buff_filters.troll, buff_filters.hostile),
        category = buff_category.class,
    },
    -- flame shock (lava burst crit)
    [8050] = {
        apply = function(loadout, effects, buff)

            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Lava Burst"], 1.0, 0.0);    
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.hostile),
        category = buff_category.class,
    },
    -- weakened soul
    [6788] = {
        apply = function(loadout, effects, buff)

            if loadout.runes[swc.talents.rune_ids.renewed_hope] then
                for k, v in pairs(spell_names_to_id({"Flash Heal", "Lesser Heal", "Heal", "Greater Heal", "Penance"})) do
                    ensure_exists_and_add(effects.ability.crit, v, 0.1, 0);
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
            effects.by_school.target_spell_dmg_taken[magic_school.nature] =
                (1.0 + effects.by_school.target_spell_dmg_taken[magic_school.nature]) * 1.2 - 1.0;

        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.druid, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- rejuv
    [774] = {
        apply = function(loadout, effects, buff)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.druid_nourish_bonus) == 0 then

                ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Nourish"], 0.2, 0.0);

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
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Mind Blast"], c*0.3, 0);
            
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.sod, buff_filters.hostile),
        category = buff_category.class,
    },
    -- sacred shield
    [412019] = {
        apply = function(loadout, effects, buff)

            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Flash of Light"], 0.5, 0);

        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.sod, buff_filters.friendly),
        category = buff_category.class,
    },
    -- riptide
    [408521] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Chain Heal"], 0.25, 0.0);
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.sod, buff_filters.friendly),
        category = buff_category.class,
    },
    -- tree of life
    [439745] = {
        apply = function(loadout, effects, buff)
            effects.raw.target_healing_taken = effects.raw.target_healing_taken + 0.1;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.sod, buff_filters.friendly),
        category = buff_category.raid,
    },
    -- mark of chaos
    [461615] = {
        apply = function(loadout, effects, buff)
            for i = 1, 7 do
                effects.by_school.target_spell_dmg_taken[i] =
                    (1.0 + effects.by_school.target_spell_dmg_taken[i]) * 1.11 - 1.0;
                effects.by_school.target_res[i] = effects.by_school.target_res[i] + 0.75
            end

        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
    },
};

target_buffs_predefined[8936]   = deep_table_copy(target_buffs_predefined[774]);
target_buffs_predefined[408124] = deep_table_copy(target_buffs_predefined[774]);
target_buffs_predefined[408120] = deep_table_copy(target_buffs_predefined[774]);

target_buffs_predefined[980]    = deep_table_copy(target_buffs_predefined[172]);
target_buffs_predefined[18265]  = deep_table_copy(target_buffs_predefined[172]);
target_buffs_predefined[427717] = deep_table_copy(target_buffs_predefined[172]);

local buffs = {};
for k, v in pairs(buffs_predefined) do
    if bit.band(filter_flags_active, v.filter) ~= 0 then
        local buff_lname = GetSpellInfo(k);
        if buff_lname then
            buffs[buff_lname] = v;
            buffs[buff_lname].id = k;
        end
    end
end
local target_buffs = {};
for k, v in pairs(target_buffs_predefined) do
    if bit.band(filter_flags_active, v.filter) ~= 0 then
        local buff_lname = GetSpellInfo(k);
        if buff_lname then
            target_buffs[buff_lname] = v;
            target_buffs[buff_lname].id = k;
        end
    end
end

-- allows weapon enchant buffs to be registered as buffs
local wep_enchant_id_to_buff = {
    [2628] = 25122,
    [2629] = 25123,
    [7099] = 430585,
};

local function detect_buffs(loadout)

    loadout.dynamic_buffs = {["player"] = {}, ["target"] = {}, ["mouseover"] = {}};
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
              local name, icon_tex, count, _, _, exp_time, src, _, _, spell_id = UnitBuff(k, i);
              if not name then
                  break;
              end
              if not exp_time then
                  exp_time = 0.0;
              end
              v[name] = {count = count, id = spell_id, src = src, dur = exp_time - GetTime()};
              i = i + 1;
        end
        local i = 1;
        while true do
              local name, _, count, _, _, exp_time, src, _, _, spell_id = UnitDebuff(k, i);
              if not name then
                  break;
              end
              if not exp_time then
                  exp_time = 0.0;
              end
              -- if multiple buffs with same name, prioritize player applied
              if not v[name] or v[name].src ~= "player" then
                v[name] = {count = count, id = spell_id, src = src, dur = exp_time - GetTime()};
              end
              i = i + 1;
        end
    end
    if race == "Troll" and loadout.target_creature_type == "Beast" then
        local racial_id = 20557;
        local lname = GetSpellInfo(racial_id);
        loadout.dynamic_buffs["target"][lname] = {count = 1, id = racial_id, nil, nil};
    end
    local _, _, _, enchant_id = GetWeaponEnchantInfo();
    if enchant_id and wep_enchant_id_to_buff[enchant_id] then
        local lname = GetSpellInfo(wep_enchant_id_to_buff[enchant_id]);
        loadout.dynamic_buffs["player"][lname] = {count = 1, id = wep_enchant_id_to_buff[enchant_id], nil, nil};
    end

end

local function apply_buffs(loadout, effects)

    for k, v in pairs(loadout.dynamic_buffs["player"]) do
        if buffs[k] and bit.band(filter_flags_active, buffs[k].filter) ~= 0 then
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

    if bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0 then
        for k, v in pairs(loadout.buffs) do
            if not loadout.dynamic_buffs["player"][k] and buffs[k] then
                buffs[k].apply(loadout, effects, buffs[k], true);
            end
        end
        for k, v in pairs(loadout.target_buffs) do
            if not target_buffs_applied[k] then
                target_buffs[k].apply(loadout, effects, target_buffs[k], true);
            end
        end

        if class == "PALADIN" and loadout.target_buffs[GetSpellInfo(407613)] then
            loadout.beacon = true;
        end
    else
    end

    if swc.core.__sw__test_all_codepaths then
        for k, v in pairs(buffs) do
            if v then
                v.apply(loadout, effects, v, true);
            end
        end
        for k, v in pairs(target_buffs) do
            v.apply(loadout, effects, v);
        end
    end
end

local function is_buff_up(loadout, unit, buff_name, is_self)
    if is_self then
        return loadout.dynamic_buffs[unit][buff_name] ~= nil or (bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0 and loadout.buffs[buff_name]);
    else
        return loadout.dynamic_buffs[unit][buff_name] ~= nil or (bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0 and loadout.target_buffs[buff_name]);
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

