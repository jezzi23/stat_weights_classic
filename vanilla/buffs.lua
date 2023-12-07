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
local addon_name, swc = ...;

local ensure_exists_and_add         = swc.utils.ensure_exists_and_add;
local ensure_exists_and_mul         = swc.utils.ensure_exists_and_mul;
local deep_table_copy               = swc.utils.deep_table_copy;
local stat                          = swc.utils.stat;
local class                         = swc.utils.class;
local race                          = swc.utils.race;
local faction                       = swc.utils.faction;
local loadout_flags                 = swc.utils.loadout_flags;

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
    hidden        = bit.lshift(1,15),
};

local buff_category = {
    talent      = 1,
    class       = 2,
    raid        = 3,
    consumes    = 4,
    world_buffs = 5,
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

local FILL_ME_WITH_KNOWN_VALUES = 0;

--TODO VANILLA: 
--    troll beast
--    divine sacrifice expiration buff id unknown
local buffs_predefined = {
    -- onyxia
    [22888] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                for i = 2, 7 do
                    effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.1;
                end
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.world_buffs,
        tooltip = "10% spell crit chance",
    },
    -- wcb
    [16609] = {
        apply = function(loadout, effects, buff, inactive)

           effects.raw.mp5 = effects.raw.mp5 + 10;
        end,
        filter = buff_filters.caster,
        category = buff_category.world_buffs,
        tooltip = "+10 MP5"
    },
    -- songflower
    [15366] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                for i = 2, 7 do
                    effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.05;
                end
                for i = 1, 5 do
                    effects.by_attribute.stats[i] = effects.by_attribute.stats[i] + 15;
                end
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.world_buffs,
        tooltip = "5% spell crit chance and 5 all stats",
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
        tooltip = "15% all stats",
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
        tooltip = "35 spell damage",
    },
    -- runn tum tuber surprise
    [22730] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + 10;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
        tooltip = "10 intellect",
    },
    -- power infusion
    [10060] = {
        apply = function(loadout, effects, buff)
            effects.raw.spell_heal_mod_mul = effects.raw.spell_heal_mod_mul + 0.2;
            effects.raw.spell_dmg_mod_mul = effects.raw.spell_dmg_mod_mul + 0.2;
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "20% spell dmg/heal (fom priest)",
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
        tooltip = "30% spell dmg and mana costs",
    },
    -- mind quickening gem
    [23723] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = effects.raw.haste_mod + 0.33;
        end,
        filter = buff_filters.mage,
        category = buff_category.item,
        tooltip = "33% haste",
    },
    -- dmf dmg
    [23768] = {
        apply = function(loadout, effects, buff)
            effects.raw.spell_dmg_mod_mul = effects.raw.spell_dmg_mod_mul + 0.1;
        end,
        filter = buff_filters.caster,
        category = buff_category.world_buffs,
        tooltip = "10% dmg",
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
        tooltip = "Arcane 50% crit dmg and 5% crit",
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
        tooltip = "Destruction spells 10% crit",
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
            local heals = spell_names_to_id({"Tranquility", "Rejuvenation", "Healing Touch", "Regrowth"});
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
                effects.by_school.spell_dmg_mod[magic_school.shadow] + 0.15;
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
    },
    -- shadow form
    [15473] = {
        apply = function(loadout, effects, buff)
            effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                effects.by_school.spell_dmg_mod[magic_school.shadow] + 0.15;
        end,
        filter = buff_filters.priest,
        category = buff_category.class,
    },
    -- toep
    [23271] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_power = 175;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.item,
    },
    -- zandalari hero charm
    [24658] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_power = 204;
                effects.raw.healing_power = 408;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.item,
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
        tooltip = "10% stats"
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
        tooltip = "10% stats"
    },

    -- vengeance
    [20055] = {
        apply = function(loadout, effects, buff)

            effects.by_school.spell_dmg_mod[magic_school.holy] = 
                effects.by_school.spell_dmg_mod[magic_school.holy] + 0.15;

        end,
        filter = buff_filters.paladin,
        category = buff_category.class,
    },
    -- nature aligned
    [23734] = {
        apply = function(loadout, effects, buff)
            effects.raw.cost_mod = effects.raw.cost_mod - 0.2;
            effects.raw.spell_heal_mod_mul = effects.raw.spell_heal_mod_mul + 0.2;
            effects.raw.spell_dmg_mod_mul = effects.raw.spell_dmg_mod_mul + 0.2;
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
    [17627] = {
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
                if inactive then
                    for i = 2, 7 do
                        effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.03;
                    end
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.moonkin_crit);
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
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
        apply = function(loadout, effects, buff)
            
            local _, _, _, enchant_id = GetWeaponEnchantInfo();
            if enchant_id ~= 2628 then 
                effects.raw.spell_dmg = effects.raw.spell_dmg + 36;
                for i = 2, 7 do
                    effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.01;
                end
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
        tooltip = "36 spell damage and 1% crit",
        icon_id = GetItemIcon(20749)
    },
    --  brilliant mana oil
    [25123] = {
        apply = function(loadout, effects, buff, inactive)


            local _, _, _, enchant_id = GetWeaponEnchantInfo();
            if enchant_id ~= 2629 then 
                effects.raw.healing_power = effects.raw.healing_power + 25;
                effects.raw.mp5 = effects.raw.mp5 + 12;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
        tooltip = "+12 mp5 and 25 healing power",
        icon_id = GetItemIcon(20748)
    },
    -- demonic sacrifice imp
    [18789] = {
        apply = function(loadout, effects, buff)
            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                effects.by_school.spell_dmg_mod[magic_school.fire] + 0.15;
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
        filter = bit.bor(buff_filters.shaman, buff_filters.hidden),
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
    ---- fury of the stormrage
    --[FILL_ME_WITH_KNOWN_VALUES] = {
    --    apply = function(loadout, effects, buff)
    --        ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id("Wrath"), 1.00, 0);
    --    end,
    --    filter = buff_filters.druid,
    --    category = buff_category.class,
    --},
    ---- fury of the stormrage proc
    --[FILL_ME_WITH_KNOWN_VALUES] = {
    --    apply = function(loadout, effects, buff)
    --        ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id("Healing Touch"), 1.00, 0);
    --    end,
    --    filter = buff_filters.druid,
    --    category = buff_category.class,
    --},
    --arcane blast
    [400573] = {
        apply = function(loadout, effects, buff)
            local stacks = 4;

            if buff.count then
                stacks = buff.count;
            end
            effects.by_school.spell_dmg_mod_add[magic_school.arcane] = 
                effects.by_school.spell_dmg_mod_add[magic_school.arcane] + 0.15 * stacks;

            ensure_exists_and_add(effects.ability.cost_mod_base, spell_name_to_id["Arcane Blast"], -stacks * 1.75, 0.0); 

        end,
        filter = buff_filters.mage,
        category = buff_category.class,
        tooltip = "Arcane Blast stacks",
    },
    -- fingers of frost
    [400669] = {
        apply = function(loadout, effects, buff)
            loadout.flags = bit.bor(loadout.flags, loadout_flags.target_frozen);
        end,
        filter = buff_filters.mage,
        category = buff_category.class,
        tooltip = "Frozen effect",
    },

    -- icy veins
    [425121] = {
        apply = function(loadout, effects, buff)

            effects.raw.haste_mod = effects.raw.haste_mod + 0.2;

        end,
        filter = buff_filters.mage,
        category = buff_category.class,
    },
    -- flame shock (lava burst crit)
    [8050] = {
        apply = function(loadout, effects, buff)

            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Lava Burst"], 1.0, 0.0);    
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.hostile),
        category = buff_category.class,
        tooltip = "Lava Burst 100% crit chance",
    },
    -- water shield
    [408510] = {
        apply = function(loadout, effects, buff)
            effects.raw.perc_max_mana_as_mp5 = effects.raw.perc_max_mana_as_mp5 + 0.01;
        end,
        filter = buff_filters.shaman,
        category = buff_category.class,
        tooltip = "1% of max mana per 5 sec",
    },
    -- incinerate
    [412758] = {
        apply = function(loadout, effects, buff)
            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                effects.by_school.spell_dmg_mod[magic_school.fire] + 0.25;
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
    },
    -- metamorphosis
    [403789] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Life Tap"], 1.0, 0.0);    
        end,
        filter = buff_filters.warlock,
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
        filter = buff_filters.priest,
        category = buff_category.class,
    },
    -- demonic grace
    [425463] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                for i = 2, 7 do
                    effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.3;
                end
            end
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
    },
    -- demonic pact
    [425467] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + math.max(0.1*effects.raw.spell_power, loadout.lvl/2);
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "When applied while inactive, 10% of your spellpower is added as an estimate but should be based on the warlock's"
    },
    -- tangled causality
    [432069] = {
        apply = function(loadout, effects, buff)

            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                effects.by_school.spell_dmg_mod[magic_school.fire] - 0.5;
            effects.by_school.spell_dmg_mod[magic_school.frost] = 
                effects.by_school.spell_dmg_mod[magic_school.frost] - 0.5;
        end,
        filter = buff_filters.mage,
        category = buff_category.class,
        tooltip = "50% reduced fire/frost spell damage",
    },
    -- blackfathom mana oil
    [430585] = {
        apply = function(loadout, effects, buff, inactive)
            
            local _, _, _, enchant_id = GetWeaponEnchantInfo();
            if enchant_id ~= 7099 then 
                effects.raw.mp5 = effects.raw.mp5 + 12;
                if inactive then
                    for i = 2, 7 do
                        effects.by_school.spell_dmg_hit[i] = effects.by_school.spell_dmg_hit[i] + 0.02;
                    end
                end
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
        tooltip = "+12 mp5 and 2% spell hit",
        icon_id = GetItemIcon(430409)
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
                [11722]  = 0.1
            };
            local id_to_res = {
                [1490]   = 45,
                [11721]  = 60,
                [11722]  = 75
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
                effects.by_school.target_spell_dmg_taken[magic_school.fire] + id_to_mod[id];
            effects.by_school.target_spell_dmg_taken[magic_school.frost] =
                effects.by_school.target_spell_dmg_taken[magic_school.frost] + id_to_mod[id];
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.warlock, buff_filters.shaman, buff_filters.hostile),
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
        filter = bit.bor(buff_filters.mage, buff_filters.shaman, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- nightfall
    [23605] = {
        apply = function(loadout, effects, buff)
            for i = 2, 7 do
                effects.by_school.target_spell_dmg_taken[i] =
                    effects.by_school.target_spell_dmg_taken[i] + 0.15;
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
                effects.by_school.target_spell_dmg_taken[magic_school.fire] + c * 0.03;

        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- improved shadow bolt
    [17800] = {
        apply = function(loadout, effects, buff)

            if buff.src and buff.src == "player" then
                effects.by_school.target_spell_dmg_taken[magic_school.shadow] =
                    effects.by_school.target_spell_dmg_taken[magic_school.shadow] + 0.04 * loadout.talents_table:pts(3, 1);
            else
                effects.by_school.target_spell_dmg_taken[magic_school.shadow] =
                    effects.by_school.target_spell_dmg_taken[magic_school.shadow] + 0.2;
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
                effects.by_school.target_spell_dmg_taken[magic_school.shadow] + c * 0.03;

        end,
        filter = bit.bor(buff_filters.priest, buff_filters.warlock, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- stormstrike
    [17364] = {
        apply = function(loadout, effects, buff)
            effects.by_school.target_spell_dmg_taken[magic_school.nature] =
                effects.by_school.target_spell_dmg_taken[magic_school.nature] + 0.2;

        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.druid, buff_filters.hostile),
        category = buff_category.raid,
    },
    -- curse of shadow
    [17937] = {
        apply = function(loadout, effects, buff)
            local id_to_mod = {
                [17862]   = 0.08,
                [17937]  = 0.1,
            };
            local id_to_res = {
                [17862]  = 60,
                [17937]  = 75,
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
                effects.by_school.target_spell_dmg_taken[magic_school.shadow] + id_to_mod[id];
            effects.by_school.target_spell_dmg_taken[magic_school.arcane] =
                effects.by_school.target_spell_dmg_taken[magic_school.arcane] + id_to_mod[id];
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
        tooltip = "Frozen effect",
    },
    -- haunt
    [403501] = {
        apply = function(loadout, effects, buff)
            if not buff.src or buff.src == "player" then
                effects.by_school.target_spell_dmg_taken[magic_school.shadow] =
                    effects.by_school.target_spell_dmg_taken[magic_school.shadow] + 0.2;
            end
            if loadout.runes[swc.talents.rune_ids.soul_siphon] then
                ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Drain Soul"], 0.06, 0);
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
    -- curse of agony
    [980] = {
        apply = function(loadout, effects, buff)
            if loadout.runes[swc.talents.rune_ids.soul_siphon] then
                ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Drain Soul"], 0.06, 0);
                ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Drain Life"], 0.06, 0);
            end
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.hostile),
        category = buff_category.class,
    },
    -- siphon life
    [18265] = {
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
                ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Mind Blast"], 0.2, 0);
                ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Mind Flay"], 0.2, 0);
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
                    effects.by_school.target_spell_dmg_taken[magic_school.fire] + 0.4;
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
        tooltip = "Beacon is assumed to be up for the entire duration after each Beacon cast",
    },
    -- beast slaying (troll)
    [20557] = {
        apply = function(loadout, effects, buff)

            for i = 2, 7 do
                effects.by_school.target_spell_dmg_taken[i] = effects.by_school.target_spell_dmg_taken[i] + 0.05;
            end
        end,
        filter = bit.bor(buff_filters.troll, buff_filters.hostile),
        category = buff_category.class,
        tooltip = "5% more damage to beasts (only tracks on english client)",
    },
};

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
end

local function apply_buffs(loadout, effects)

    -- TODO: some subtle things need to be done here when attributes and percentage mods
    --       go together through change
    --local stats_diff_loadout = empty_loadout();

    if bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0 then
        for k, v in pairs(loadout.buffs) do
            -- if dynamically present, some type of buffs must be removed
            -- as they were already counted for, things like sp, crit
            if loadout.dynamic_buffs["player"][k] then
                buffs[k].apply(loadout, effects, loadout.dynamic_buffs["player"][k]);
            end
        end
        -- active buffs must be done first in order to deal with non stackable 
        -- raid buffs, e.g. moonkin aura and shaman crit buff
        for k, v in pairs(loadout.buffs) do
            if not loadout.dynamic_buffs["player"][k] and buffs[k] then
                buffs[k].apply(loadout, effects, buffs[k], true);
            end
        end
        for k, v in pairs(loadout.target_buffs) do
            target_buffs[k].apply(loadout, effects, target_buffs[k]);
        end
        if class == "PALADIN" and loadout.runes[swc.talents.rune_ids.beacon_of_light] and loadout.target_buffs["Beacon of Light"] then
            loadout.beacon = true;
        else
            loadout.beacon = nil
        end
    else
        for k, v in pairs(loadout.dynamic_buffs["player"]) do
            if buffs[k] and bit.band(filter_flags_active, buffs[k].filter) ~= 0 then
                buffs[k].apply(loadout, effects, v); 
            end
        end
        for k, v in pairs(loadout.dynamic_buffs[loadout.friendly_towards]) do
            if target_buffs[k] and bit.band(buff_filters.friendly, target_buffs[k].filter) ~= 0 then
                target_buffs[k].apply(loadout, effects, v); 
            end
        end
        if loadout.hostile_towards then
            for k, v in pairs(loadout.dynamic_buffs[loadout.hostile_towards]) do
                if target_buffs[k] and bit.band(buff_filters.hostile, target_buffs[k].filter) ~= 0 then
                    target_buffs[k].apply(loadout, effects, v); 
                end
            end
        end

        local beacon_duration = 60;
        if class == "PALADIN" and loadout.runes[swc.talents.rune_ids.beacon_of_light] and swc.core.beacon_snapshot_time + beacon_duration >= swc.core.addon_running_time then
            loadout.beacon = true;
        else
            loadout.beacon = nil
        end
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

buffs_export.buff_filters = buff_filters;
buffs_export.filter_flags_active = filter_flags_active;
buffs_export.buff_category = buff_category;
buffs_export.buffs = buffs;
buffs_export.target_buffs = target_buffs;
buffs_export.detect_buffs = detect_buffs;
buffs_export.apply_buffs = apply_buffs;
buffs_export.non_stackable_effects = non_stackable_effects;

swc.buffs = buffs_export;

