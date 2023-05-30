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
local addonName, addonTable = ...;
local ensure_exists_and_add         = addonTable.ensure_exists_and_add;
local ensure_exists_and_mul         = addonTable.ensure_exists_and_mul;
local deep_table_copy               = addonTable.deep_table_copy;
local stat                          = addonTable.stat;
local class                         = addonTable.class;
local race                          = addonTable.race;
local faction                       = addonTable.faction;
local loadout_flags                 = addonTable.loadout_flags;

local magic_school                  = addonTable.magic_school;
local spell_name_to_id              = addonTable.spell_name_to_id;
local spell_names_to_id             = addonTable.spell_names_to_id;

local set_tiers                     = addonTable.set_tiers;


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
};


--TODO: 
--    warlock healing taken
--    pala blessing of healing thing
--    boomkin aura
--    tree of life
local buffs_predefined = {
    -- power infusion
    [10060] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * 1.2 - 1.0;
            effects.raw.cost_mod = effects.raw.cost_mod + 0.2;
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "20% haste (fom priest)",
    },
    -- inner fire
    [48040] = {
        apply = function(loadout, effects, buff, inactive)

            if inactive then
                local sp_mod = 1.0 + 0.15 * loadout.talents_table:pts(1, 4); -- improved inner fire
                if loadout.lvl < 77 then
                    effects.raw.spell_power = effects.raw.spell_power + sp_mod*95;
                else
                    effects.raw.spell_power = effects.raw.spell_power + sp_mod*120;
                end
            end
        end,
        filter = buff_filters.priest,
        category = buff_category.class,
        tooltip = "Spell power increase",
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

            effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.shadow]) * (1.0 + c * 0.02) - 1.0;
        end,
        filter = buff_filters.priest,
        category = buff_category.class,
        tooltip = "10% shadow damage",
    },
    --shadow form
    [15473] = {
        apply = function(loadout, effects, buff)
            effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.shadow]) * 1.15 - 1.0;
        end,
        filter = buff_filters.priest,
        category = buff_category.class,
        tooltip = "15% shadow damage",
    },
    --serendipity
    [63734] = {
        apply = function(loadout, effects, buff)
            local effect = 0.12;
            local c = 0;
            if buff.count then
                c = buff.count;
                if buff.id == 63731 then
                    effect = 0.04;
                elseif buff.id == 63735 then 
                    effect = 0.08;
                end
            else
                c = 3;
            end
            local abilities = spell_names_to_id({"Greater Heal", "Prayer of Heal"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.cast_mod_mul, v, c * effect, 0);
            end
        
        end,
        filter = buff_filters.priest,
        category = buff_category.class,
        tooltip = "Prayer and Greater Heal cast speed increase",
    },
    --divine hymn buff
    [24907] = {
        apply = function(loadout, effects, buff, inactive)
            effects.raw.target_healing_taken = effects.raw.target_healing_taken + 0.1;
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "10% more healing taken after hymn procs",
    },
    --eclipse lunar
    [48518] = {
        apply = function(loadout, effects, buff)
            local amount = 0.4;
            if loadout.num_set_pieces[set_tiers.pve_t8_1] >= 2 then
                amount = amount + 0.07;
            end
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Starfire"], amount, 0);
        end,
        filter = buff_filters.druid,
        category = buff_category.class,
        tooltip = "40% starfire crit",
    },
    --eclipse solar
    [48517] = {
        apply = function(loadout, effects, buff)
            local amount = 0.4;
            if loadout.num_set_pieces[set_tiers.pve_t8_1] >= 2 then
                amount = amount + 0.07;
            end
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Wrath"], amount, 1.0);
        end,
        filter = buff_filters.druid,
        category = buff_category.class,
        tooltip = "40% wrath damage",
    },
    --moonkin aura
    [24907] = {
        apply = function(loadout, effects, buff, inactive)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.moonkin_haste) == 0 then
                local haste = 0.03;
                if buff.src and buff.src == "player" then
                    haste = 0.01 * loadout.talents_table:pts(1, 19); -- improved boomkin
                end
                effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * (1.0 + haste) - 1.0;
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.moonkin_haste);
            end

            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.moonkin_crit) == 0 then
                if inactive then
                    for i = 2, 7 do
                        effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.05;
                    end
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.moonkin_crit);
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "5% crit and 3% haste (from druids)",
    },
    --moonkin form
    [24858] = {
        apply = function(loadout, effects, buff, inactive)
            -- mana refund done in later stage
            -- master shapeshifter
            local pts = loadout.talents_table:pts(3, 9);

            effects.by_school.spell_dmg_mod[magic_school.arcane] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.arcane]) * (1.0 + pts * 0.02) - 1.0;
            effects.by_school.spell_dmg_mod[magic_school.nature] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.nature]) * (1.0 + pts * 0.02) - 1.0;

            local imp_moonkin_pts = loadout.talents_table:pts(1, 19);
            local furor_pts = loadout.talents_table:pts(3, 3);

            effects.by_attribute.sp_from_stat_mod[stat.spirit] = 
                effects.by_attribute.sp_from_stat_mod[stat.spirit] + 0.1 * imp_moonkin_pts;
            effects.by_attribute.stat_mod[stat.int] = 
                effects.by_attribute.stat_mod[stat.int] + 0.02 * furor_pts;

            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + loadout.stats[stat.spirit] * 0.1 * imp_moonkin_pts;
                effects.raw.crit_rating = effects.raw.crit_rating + addonTable.crit_rating_from_int(loadout.stats[stat.int] * 0.02*furor_pts, loadout.lvl);
            end
        end,
        filter = buff_filters.druid,
        category = buff_category.class,
        tooltip = "Mana refund on crit, spell damage and SP from spirit",
    },
    --tree of life form
    [33891] = {
        apply = function(loadout, effects, buff, inactive)
            -- mana refund done in later stage
            -- master shapeshifter
            local pts = loadout.talents_table:pts(3, 9);
            effects.raw.spell_heal_mod_mul = effects.raw.spell_heal_mod_mul + pts * 0.02;
            local pts = loadout.talents_table:pts(3, 24);
            effects.by_attribute.hp_from_stat_mod[stat.spirit] =
                effects.by_attribute.hp_from_stat_mod[stat.spirit] + pts * 0.05;

            if inactive then
                effects.raw.healing_power = effects.raw.healing_power + loadout.stats[stat.spirit] * pts * 0.05;
            end
           
        end,
        filter = buff_filters.druid,
        category = buff_category.class,
        tooltip = "Healing % and Healing power from spirit",
    },
    -- bloodlust
    [2825] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * 1.3 - 1.0;
        end,
        filter = buff_filters.horde,
        category = buff_category.raid,
        tooltip = "30% haste (from shamans)",
    },
    -- heroism
    [32182] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * 1.3 - 1.0;
        end,
        filter = buff_filters.alliance,
        category = buff_category.raid,
        tooltip = "30% haste (from shamans)",
    },
    -- focus magic (rebound effect for src mage)
    [54648] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                for i = 2, 7 do
                    effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.03;
                end
            end
        end,
        filter = buff_filters.mage,
        category = buff_category.class,
        tooltip = "3% crit from Focus Magic rebound",
    },
    -- focus magic (any target)
    [54646] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                for i = 2, 7 do
                    effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.03;
                end
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "3% crit from another mage's Focus Magic",
    },
    -- hyperspeed acceleration (engineering gloves enchant)
    [54758] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.haste_rating = effects.raw.haste_rating + 340;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
        tooltip = "340 haste rating from engineering gloves enchant",
    },
    -- lightweave (tailoring cloak enchant)
    [55637] = {
        apply = function(loadout, effects, buff, inactive)

            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + 295;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
        tooltip = "295 spell power from tailoring cloak enchant proc",
    },
    -- potion of wild magic
    [53909] = {
        apply = function(loadout, effects, buff, inactive)

            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + 200;
                effects.raw.crit_rating = effects.raw.crit_rating + 200;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
        tooltip = "200 spell power and crit",
    },
    -- potion of speed
    [53908] = {
        apply = function(loadout, effects, buff, inactive)

            if inactive then
                effects.raw.haste_rating = effects.raw.haste_rating + 500;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
        tooltip = "500 haste rating",
    },
    -- flask of the frost wyrm
    [53755] = {
        apply = function(loadout, effects, buff, inactive)

            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + 125;
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.consumes,
        tooltip = "125 spell power",
    },
    --wrath of air
    [3738] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * (1.05) - 1.0;
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "5% haste (from shamans)",
    },
    --totem of wrath
    [57722] = {
        apply = function(loadout, effects, buff, inactive)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.totem_of_wrath_sp) == 0 then
                if inactive then
                    effects.raw.spell_power = effects.raw.spell_power + 280;
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.totem_of_wrath_sp);
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "280 spell power (from shamans)",
    },
    --demonic pact
    [47240] = {
        apply = function(loadout, effects, buff, inactive)
            -- dynamically scales with the warlock owner's sp but still needs tracking
            -- assume same effect as totem if applied statically
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.totem_of_wrath_sp) == 0 then
                if inactive then
                    effects.raw.spell_power = effects.raw.spell_power + 280;
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.totem_of_wrath_sp);
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "spell power (from warlock)",
    },
    --sanctified retribution
    [31869] = {
        apply = function(loadout, effects, buff, inactive)
            -- dynamically scales with the warlock owner's sp but still needs tracking
            -- assume same effect as totem if applied statically
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.arcane_empowerment) == 0 then
                effects.raw.spell_dmg_mod_mul = 
                    (1.0 + effects.raw.spell_dmg_mod_mul) * 1.03 - 1.0;

                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.arcane_empowerment);
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "3% damage (from paladins)",
    },
    --elemental oath
    [51470] = {
        apply = function(loadout, effects, buff, inactive)

            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.moonkin_crit) == 0 then
                if inactive then
                    for i = 2, 7 do
                        effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.05;
                    end
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.moonkin_crit);
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "5% crit (from shamans)",
    },
    --swift retribution
    [53648] = {
        apply = function(loadout, effects, buff, inactive)

            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.moonkin_haste) == 0 then
                effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * 1.03 - 1.0;
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.moonkin_haste);
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "3% haste (from paladins)",
    },
    --riptide
    [61295] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Chain Heal"], 0.25, 0.0);
        end,
        filter = buff_filters.shaman,
        category = buff_category.class,
        tooltip = "Chain Heal 25% more healing with riptide on",
    },
    --elemental mastery
    [64701] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * 1.15 - 1.0;
        end,
        filter = buff_filters.shaman,
        category = buff_category.class,
        tooltip = "15% haste",
    },
    --elemental focus (clearcasting with talent)
    [16246] = {
        apply = function(loadout, effects, buff, inactive)

            local pts = loadout.talents_table:pts(1, 19);

            effects.by_school.spell_dmg_mod[magic_school.frost] = 
                effects.by_school.spell_dmg_mod[magic_school.frost] + 0.05 * pts;
            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                effects.by_school.spell_dmg_mod[magic_school.fire] + 0.05 * pts;
            effects.by_school.spell_dmg_mod[magic_school.nature] = 
                effects.by_school.spell_dmg_mod[magic_school.nature] + 0.05 * pts;
        end,
        filter = buff_filters.shaman,
        name = "Elemental Focus Clearcasting";
        category = buff_category.class,
        tooltip = "10% spell damage while clearcasting",
    },
    --lava flows
    [64694] = {
        apply = function(loadout, effects, buff)
            local haste = 1.3;
            if buff.src then
                if buff.id == 64694 then
                    haste = 1.1;
                elseif buff.id == 65263 then
                    haste = 1.2;
                end
            end
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * haste - 1.0;
        end,
        filter = buff_filters.shaman,
        category = buff_category.class,
        tooltip = "30% haste after flame shock is dispelled",
    },
    --water shield
    [52127] = {
        apply = function(loadout, effects, buff)

            --trickery to flag that healing crits restore mana
           effects.raw.non_stackable_effect_flags =
               bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.water_shield);

           -- baseline mp5 effect
           local id_to_mp5 = {
               [52127] = 10,
               [52129] = 15,
               [52131] = 21,
               [52134] = 26,
               [52136] = 33,
               [52138] = 38,
               [24398] = 43,
               [33736] = 50,
               [57960] = 100,
           };
           local id = 57960; -- default

           if buff.id and id_to_mp5[buff.id] then
               id = buff.id;
           end
           local water_shield_mod = 0.0;
           if loadout.glyphs[55436] then
               water_shield_mod = water_shield_mod + 0.3;
           end

           if loadout.num_set_pieces[set_tiers.pve_t7_3] >= 2 then
               water_shield_mod = water_shield_mod + 0.1;
           end

           local mp5 = id_to_mp5[id] * (1.0 + water_shield_mod);

           effects.raw.mp5 = effects.raw.mp5 + mp5;

        end,
        filter = buff_filters.shaman,
        category = buff_category.class,
        tooltip = "May proc restore on healing crits if talented",
    },
    --tidal waves
    [53390] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Lesser Healing Wave"], 0.25, 0.0);
            ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id["Healing Wave"], 0.3, 0.0);
        end,
        filter = buff_filters.shaman,
        category = buff_category.class,
        tooltip = "Healing Wave cast speed 30% or Lesser Healing Wave 25% crit",
    },
    --heroic presence (ally only)
    [28878] = {
        apply = function(loadout, effects, buff)
            for i = 2, 7 do 
                effects.by_school.spell_dmg_hit[i] = 
                    effects.by_school.spell_dmg_hit[i] + 0.01;
            end
        end,
        filter = buff_filters.alliance,
        category = buff_category.raid,
        tooltip = "1% hit",
    },
    --metamorphosis
    [47241] = {
        apply = function(loadout, effects, buff)
            --effects.by_school.spell_dmg_mod[magic_school.fire] =
            --    effects.by_school.spell_dmg_mod[magic_school.fire] + 0.2;
            --effects.by_school.spell_dmg_mod[magic_school.shadow] =
            --    effects.by_school.spell_dmg_mod[magic_school.shadow] + 0.2;

            effects.raw.spell_dmg_mod_mul = 
                (1.0 + effects.raw.spell_dmg_mod_mul) * 1.2 - 1.0;
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
        tooltip = "20% spell dmg",
    },
    --arcane power
    [12042] = {
        apply = function(loadout, effects, buff)
            effects.by_school.spell_dmg_mod_add[magic_school.fire] = 
                effects.by_school.spell_dmg_mod_add[magic_school.fire] + 0.2;
            effects.by_school.spell_dmg_mod_add[magic_school.arcane] = 
                effects.by_school.spell_dmg_mod_add[magic_school.arcane] + 0.2;
            effects.by_school.spell_dmg_mod_add[magic_school.frost] = 
                effects.by_school.spell_dmg_mod_add[magic_school.frost] + 0.2;

            effects.raw.cost_mod_base = effects.raw.cost_mod_base - 0.2;
        end,
        filter = buff_filters.mage,
        category = buff_category.class,
        tooltip = "20% spell dmg and mana costs",
    },
    --icy veins
    [12472] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * 1.2 - 1.0;
        end,
        filter = buff_filters.mage,
        category = buff_category.class,
        tooltip = "20% haste",
    },
    --eradication
    [64371] = {
        apply = function(loadout, effects, buff)
            local pts = loadout.talents_table:pts(1, 19);
            local by_pts = {0.06, 0.12, 0.2};
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * (1.0 + by_pts[pts]) - 1.0;
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
        tooltip = "20% haste",
    },
    --molten core
    [47383] = {
        apply = function(loadout, effects, buff)
            local pts = loadout.talents_table:pts(2, 17);
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Incinerate"], pts * 0.06, 0.0); 
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Incinerate"], pts * 0.1 * 2.5, 0.0); 
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Soul Fire"], pts * 0.06, 0.0); 
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Soul Fire"], pts * 0.05, 0.0); 
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
        tooltip = "Incinerate 30% cast speed, Soul Fire 15% crit, 18% dmg to both (procs from Immolate)",
    },
    --pyroclasm
    [63243] = {
        apply = function(loadout, effects, buff)
            local pts = loadout.talents_table:pts(3, 19);

            -- TODO: additive or mul?
            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.fire]) * (1.0 + pts * 0.02) - 1.0;
            effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.shadow]) * (1.0 + pts * 0.02) - 1.0;

        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
        tooltip = "6% fire and shadow spell damage",
    },
    --backdraft
    [54277] = {
        apply = function(loadout, effects, buff)
            local pts = loadout.talents_table:pts(3, 22);

            for k, v in pairs(spell_names_to_id({"Shadow Bolt", "Chaos Bolt", "Immolate", "Soul Fire", "Shadowburn", "Shadowfury", "Searing Pain", "Incinerate"})) do
                ensure_exists_and_add(effects.ability.cast_mod_reduce, v, pts * 0.1, 0.0); 
            end
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
        tooltip = "30% haste to destruction spells",
    },
    --arcane blast
    [36032] = {
        apply = function(loadout, effects, buff)
            local stacks = 4;

            if buff.count then
                stacks = buff.count;
            end
            effects.by_school.spell_dmg_mod[magic_school.arcane] = 
                effects.by_school.spell_dmg_mod[magic_school.arcane] + 0.15 * stacks;

            ensure_exists_and_add(effects.ability.cost_mod_base, spell_name_to_id["Arcane Blast"], -stacks * 1.75, 0.0); 

        end,
        filter = buff_filters.mage,
        category = buff_category.class,
        tooltip = "Arcane Blast stacks",
    },
    --combustion
    [28682] = {
        apply = function(loadout, effects, buff)
            local stacks = 10;

            if buff.count then
                stacks = buff.count;
            end

            effects.by_school.spell_crit_mod[magic_school.fire] = 
                effects.by_school.spell_crit_mod[magic_school.fire] + 0.25;

            effects.by_school.spell_crit[magic_school.fire] = 
                effects.by_school.spell_crit[magic_school.fire] + 0.1 * stacks;

            ensure_exists_and_add(effects.ability.crit_mod, spell_name_to_id["Frostfire Bolt"], 0.25, 0.0); 
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Frostfire Bolt"], 0.1 * stacks, 0.0); 

        end,
        filter = buff_filters.mage,
        category = buff_category.class,
        tooltip = "Combustion, 50% bonus crit damage",
    },
    -- fingers of frost
    [74396] = {
        apply = function(loadout, effects, buff)
            loadout.flags = bit.bor(loadout.flags, loadout_flags.target_frozen);
        end,
        filter = buff_filters.mage,
        category = buff_category.class,
        tooltip = "Frozen effect",
    },
    -- seal of light
    [20165] = {
        apply = function(loadout, effects, buff)
            if loadout.glyphs[54943] then
                effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + 0.05;
            end
        end,
        filter = buff_filters.paladin,
        category = buff_category.class,
        tooltip = "5% heal if glyphed",
    },
    -- seal of wisdom
    [20166] = {
        apply = function(loadout, effects, buff)
            if loadout.glyphs[54943] then
                for k, v in pairs(spell_names_to_id({"Holy Light", "Flash of Heal", "Holy Shock"})) do
                    ensure_exists_and_add(effects.ability.cost_mod, v, 0.05, 0.0); 
                end
            end

        end,
        filter = buff_filters.paladin,
        category = buff_category.class,
        tooltip = "-5% cost of healing spells if glyphed",
    },
    -- life tap (glyph)
    [63321] = {
        apply = function(loadout, effects, buff, inactive)
            if loadout.glyphs[63320] then

                effects.by_attribute.sp_from_stat_mod[stat.spirit] = 
                    effects.by_attribute.sp_from_stat_mod[stat.spirit] + 0.2;

                if inactive then 
                    effects.raw.spell_power = effects.raw.spell_power + loadout.stats[stat.spirit] * 0.2;
                end
            end
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
        tooltip = "20% of spirit into spellpower if glyphed",
    },
    -- divine plea
    [54428] = {
        apply = function(loadout, effects, buff)
            
            effects.raw.spell_heal_mod = -0.5;
        end,
        filter = buff_filters.paladin,
        category = buff_category.class,
        tooltip = "50% reduced healing",
    },
    -- divine illumination
    [31842] = {
        apply = function(loadout, effects, buff)
            
            effects.raw.cost_mod = 0.5;
        end,
        filter = buff_filters.paladin,
        category = buff_category.class,
        tooltip = "50% reduced healing",
    },
    -- judgement of the pure
    [54153] = {
        apply = function(loadout, effects, buff)
            
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * 1.15 - 1.0;
        end,
        filter = buff_filters.paladin,
        category = buff_category.class,
        tooltip = "15% haste after judgement",
    },
    -- hot streak
    [48108] = {
        apply = function(loadout, effects, buff)
            
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Pyroblast"], 3.5, 0.0); 
        end,
        filter = buff_filters.mage,
        category = buff_category.class,
        tooltip = "Instant Pyroblast",
    },
    -- missile barrage
    [44401] = {
        apply = function(loadout, effects, buff)
            
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Arcane Missiles"], 2.5, 0.0); 
            ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Arcane Missiles"], 0.999, 0.0); 
        end,
        filter = buff_filters.mage,
        category = buff_category.class,
        tooltip = "Arcane Missiles 2.5secs faster",
    },
    -- blessing of wisdom
    [19742] = {
        apply = function(loadout, effects, buff)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.bow_mp5) == 0 then

                local id_to_mp5 = {
                    [19742] = 10,
                    [19850] = 15,
                    [19852] = 20,
                    [19853] = 25,
                    [19854] = 30,
                    [25290] = 33,
                    [27142] = 41,
                    [48935] = 73,
                    [48936] = 92,
                };
                local id = 48936; -- default
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
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "MP5",
    },
    -- greater blessing of wisdom
    [25894] = {
        apply = function(loadout, effects, buff)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.bow_mp5) == 0 then

                local id_to_mp5 = {
                    [25894] = 30,
                    [25918] = 33,
                    [27143] = 41,
                    [48937] = 73,
                    [48938] = 92,
                };
                local id = 48938; -- default
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
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "MP5",
    },
    -- mana spring totem
    [5677] = {
        apply = function(loadout, effects, buff)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.bow_mp5) == 0 then

                local id_to_mp5 = {
                    [5677]  = 16,
                    [10491] = 21,
                    [10493] = 26,
                    [10494] = 31,
                    [25569] = 41,
                    [58775] = 73,
                    [58776] = 82,
                    [58777] = 91,
                };
                local id = 58777; -- default
                local mp5 = 0;

                if buff.id and id_to_mp5[buff.id] then
                    id = buff.id;
                end
                if buff.src and buff.src == "player" then

                    mp5 = id_to_mp5[id] * (1.0 + loadout.talents_table:pts(3, 10) * 0.2/3);
                else
                    mp5 = id_to_mp5[id] * 1.2;
                end
                effects.raw.mp5 = effects.raw.mp5 + mp5;


                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.bow_mp5);
            end
        end,
        filter = buff_filters.caster,
        category = buff_category.raid,
        tooltip = "MP5",
    },
    -- shadowy insight
    [61792] = {
        apply = function(loadout, effects, buff, inactive)

            local shadow_form, _, _, _, _, _, _ = GetSpellInfo(15473);
            if (loadout.buffs[shadow_form] and bit.band(loadout.flags, loadout_flags.always_assume_buffs) ~= 0) or
                (loadout.dynamic_buffs["player"][shadow_form] and bit.band(loadout.flags, loadout_flags.always_assume_buffs) == 0) then

                effects.by_attribute.sp_from_stat_mod[stat.spirit] = effects.by_attribute.sp_from_stat_mod[stat.spirit] + 0.3;

                if inactive then
                    effects.raw.spell_power = effects.raw.spell_power + loadout.stats[stat.spirit] * 0.3;
                end
            end
        end,
        filter = buff_filters.priest,
        category = buff_category.class,
        tooltip = "30% of spirit into SP (glyph proc)",
    },
    -- molten amror
    [30482] = {
        apply = function(loadout, effects, buff, inactive)
            local spirit_to_crit_mod = 0.35;
            if loadout.glyphs[56382] then
                spirit_to_crit_mod = spirit_to_crit_mod + 0.20;
            end
            if loadout.num_set_pieces[set_tiers.pve_t9_1] >= 4 then
                spirit_to_crit_mod = spirit_to_crit_mod + 0.15;

            end
            effects.by_attribute.crit_from_stat_mod[stat.spirit] =
                effects.by_attribute.crit_from_stat_mod[stat.spirit] + spirit_to_crit_mod;

            if inactive then
                effects.raw.crit_rating = effects.raw.crit_rating + loadout.stats[stat.spirit] * spirit_to_crit_mod;
            end

        end,
        filter = buff_filters.mage,
        category = buff_category.class,
        tooltip = "% spirit into SP",
    },
    -- mage armor
    [6117] = {
        apply = function(loadout, effects, buff)
            effects.raw.regen_while_casting = effects.raw.regen_while_casting + 0.5;

            if loadout.num_set_pieces[set_tiers.pve_t9_1] >= 4 then
                effects.raw.regen_while_casting = effects.raw.regen_while_casting + 0.1;

            end
        end,
        filter = buff_filters.mage,
        category = buff_category.class,
        tooltip = "50% mana regen while casting",
    },
    -- berserking (troll)
    [26297] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * 1.2 - 1.0;
        end,
        filter = buff_filters.troll,
        category = buff_category.class,
        tooltip = "20% haste (troll)",
    },
    -- arcane potency
    [57531] = {
        apply = function(loadout, effects, buff, inactive)
            if not inactive then
                -- NOTE: won't get called when always assuming buffs and dynamically active
                local pts = loadout.talents_table:pts(1, 20);
                local overdue_crit = pts * 0.15;
                -- we already add arcane potency expected crit for an ability
                -- remove the full amount when dynamically present
                effects.by_school.spell_crit[magic_school.fire] = 
                    effects.by_school.spell_crit[magic_school.fire] - overdue_crit;
                effects.by_school.spell_crit[magic_school.arcane] = 
                    effects.by_school.spell_crit[magic_school.arcane] - overdue_crit;
                effects.by_school.spell_crit[magic_school.frost] = 
                    effects.by_school.spell_crit[magic_school.frost] - overdue_crit;
            end
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.hidden),
        category = buff_category.class,
        tooltip = "",
    },

    -- holy concentration
    [63725] = {
        apply = function(loadout, effects, buff)
            local pts = loadout.talents_table:pts(2, 17);
            effects.raw.regen_while_casting = effects.raw.regen_while_casting + pts * 0.5/3;
        end,
        filter = buff_filters.priest,
        category = buff_category.class,
        tooltip = "% mana regen while casting",
    },
    -- fel armor
    [28176] = {
        apply = function(loadout, effects, buff, inactive)
            local pts = loadout.talents_table:pts(2, 11);

            effects.by_attribute.sp_from_stat_mod[stat.spirit] = 
                effects.by_attribute.sp_from_stat_mod[stat.spirit] + 0.3 * (1.0 + 0.1 * pts);

            if inactive then

                local sp = 180;
                local id = 47893; -- default

                effects.raw.spell_power = effects.raw.spell_power + sp * (1.0 + 0.1 * pts);

                effects.raw.spell_power = effects.raw.spell_power + loadout.stats[stat.spirit] * 0.3 * (1.0 + 0.1 * pts);
            end
                
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
        tooltip = "SP + % of spirit",
    },
    -- master demonologist (imp)
    [23829] = {
        apply = function(loadout, effects, buff)
            local pts = loadout.talents_table:pts(2, 16);

            if not buff.src or buff.id == 35706 then
                effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                    effects.by_school.spell_dmg_mod[magic_school.shadow] + 0.01 * pts;
                effects.by_school.spell_dmg_mod[magic_school.fire] = 
                    effects.by_school.spell_dmg_mod[magic_school.fire] + 0.01 * pts;
            elseif buff.id == 23836 then
                -- succubus
                -- TODO: dynamic crit
                effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                    effects.by_school.spell_dmg_mod[magic_school.shadow] + 0.01 * pts;
            elseif buff.id == 23829 then -- imp
                effects.by_school.spell_dmg_mod[magic_school.fire] = 
                    effects.by_school.spell_dmg_mod[magic_school.fire] + 0.01 * pts;
                
            end

        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
        tooltip = "Pet buff. When forcibly applied without active buff, 5% damage from Felguard is assumed",
    },
    -- demonic knowledge
    [35696] = {
        apply = function(loadout, effects, buff, inactive)
            
            local pts = loadout.talents_table:pts(2, 20);
            if inactive then 
                local felguard_stats = 
                    -- coefs from a quick test estimate
                    loadout.stats[stat.int] * 0.3226 + loadout.stats[stat.stam] * 0.889 + 328 + 150;

                effects.raw.spell_power = effects.raw.spell_power + (0.04 * pts * felguard_stats);
            end
        end,
        filter = buff_filters.warlock,
        category = buff_category.class,
        tooltip = "SP scaling from pet stamina and intellect. Felguard assumed when forcibly applied",
    },
};

-- identical implementations
buffs_predefined[31583] = deep_table_copy(buffs_predefined[31869]);-- arcane_empowerment
buffs_predefined[34460] = deep_table_copy(buffs_predefined[31869]);-- ferocious inspiration

local target_buffs_predefined = {
    -- grace
    [47930] = {
        apply = function(loadout, effects, buff)
            --TODO: this is probably multiplied last after % healing
            local c = 3;
            if buff.count then
                c = buff.count
            end
            effects.raw.target_healing_taken = effects.raw.target_healing_taken + c * 0.03; 
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.friendly),
        category = buff_category.raid,
        tooltip = "9% more healing taken",
    },
    -- focused will
    [45242] = {
        apply = function(loadout, effects, buff)
            --TODO: this is probably multiplied last after % healing
            local heal_effect = 0.05;
            local c = 3;
            if buff.count then
                c = buff.count
                if buff.id == 45237 then
                    heal_effect = 0.03;
                elseif buff.id == 45241 then 
                    heal_effect = 0.04;
                end
            end
            effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + c * heal_effect; 
            
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.friendly),
        category = buff_category.class,
        tooltip = "5% more healing taken",
    },
    -- weakened soul (renewed hope talent effect)
    [6788] = {
        apply = function(loadout, effects, buff)
            local pts = loadout.talents_table:pts(1, 21);
            if pts ~= 0 and loadout.target_friendly then
                    
                    local abilities = spell_names_to_id({"Flash Heal", "Greater heal", "Penance"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.crit, v, pts * 0.02, 0);
                    end
                end
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.friendly),
        name = "Renewed Hope",
        icon_id = GetSpellTexture(63944),
        category = buff_category.class,
        tooltip = "4% crit with Greater, Flash Heal, and Penance",
    },
    --shadow word: pain (twisted faith)
    [589] = {
        apply = function(loadout, effects, buff)

            local pts = loadout.talents_table:pts(3, 26);
            if pts ~= 0 then
                local abilities = spell_names_to_id({"Mind Flay", "Mind Blast"});
                for k, v in pairs(abilities) do
                    ensure_exists_and_add(effects.ability.vuln_mod, v, pts * 0.02, 0.0);
                end
            end
            -- apply mind flay glyph here
            if loadout.glyphs[55687] then
                ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Mind Flay"], 0.1, 0.0);
            end
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.hostile),
        name = "Twisted Faith",
        icon_id = GetSpellTexture(51167),
        category = buff_category.class,
        tooltip = "10% damage taken from Mind Flay and Mind Blast (+ Mind Flay glyph)",
    },
    --beacon of light
    [53563] = {
        -- just used for toggle and icon in buffs, applied later
        apply = function(loadout, effects, buff)
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.friendly),
        category = buff_category.class,
        tooltip = "Beacon is assumed to be up for the entire duration after each Beacon cast",
    },
    --tree of life
    [34123] = {
        apply = function(loadout, effects, buff)
            effects.raw.target_healing_taken = effects.raw.target_healing_taken + 0.06;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.friendly),
        category = buff_category.raid,
        tooltip = "6% healing taken (from druids)",
    },
    --moonfire (improved insect swarm talent)
    [8921] = {
        apply = function(loadout, effects, buff)
            local pts = loadout.talents_table:pts(1, 14);
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Starfire"], pts * 0.01, 0);
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.hostile),
        name = "Improved Insect Swarm",
        category = buff_category.class,
        tooltip = "3% Starfire crit",
    },
    --insect swarm (improved insect swarm talent)
    [5570] = {
        apply = function(loadout, effects, buff)
            -- done in later stage
        end,
        name = "Improved Insect Swarm",
        filter = bit.bor(buff_filters.druid, buff_filters.hostile),
        category = buff_category.class,
        tooltip = "3% Wrath damage",
    },
    --earth and moon
    [60431] = {
        apply = function(loadout, effects, buff)

            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.earth_and_moon) == 0 then
                local dmg_taken = 0.13;
                if buff.src then
                    if buff.id == 60431 then
                        dmg_taken = 0.04;
                    elseif buff.id == 60432 then
                        dmg_taken = 0.09;
                    end
                end

                for i = 2, 7 do
                    effects.by_school.target_spell_dmg_taken[i] = effects.by_school.target_spell_dmg_taken[i] + dmg_taken;
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.earth_and_moon);
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
        tooltip = "13% spell damage taken",
    },
    --ebon plaguebringer
    [51161] = {
        apply = function(loadout, effects, buff)

            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.earth_and_moon) == 0 then
                for i = 2, 7 do
                    effects.by_school.target_spell_dmg_taken[i] = effects.by_school.target_spell_dmg_taken[i] + 0.13;
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.earth_and_moon);
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
        tooltip = "13% spell damage taken",
    },
    --curse of elemements
    [47865] = {
        apply = function(loadout, effects, buff)

            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.earth_and_moon) == 0 then
                for i = 2, 7 do
                    effects.by_school.target_spell_dmg_taken[i] = effects.by_school.target_spell_dmg_taken[i] + 0.13;
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.earth_and_moon);
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
        tooltip = "13% spell damage taken",
    },
    --misery
    [33198] = {
        apply = function(loadout, effects, buff)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.misery_hit) == 0 then
                local hit = 0.03;
                if buff.src then
                    if buff.id == 33196 then
                        hit = 0.01;
                    elseif buff.id == 33197 then
                        hit = 0.02;
                    end
                end
                
                for i = 2, 7 do
                    effects.by_school.spell_dmg_hit[i] = effects.by_school.spell_dmg_hit[i] + hit;
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.misery_hit);
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
        tooltip = "3% spell hit",
    },
    --faerie fire 3% hit
    [770] = {
        apply = function(loadout, effects, buff)
            -- this effect is baked into ordinary faerie fire hiddenly?
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.misery_hit) == 0 then
                local hit = 0.03
                if buff.src and buff.src == "player" then
                    hit = 0.01 * loadout.talents_table:pts(1, 20); -- improved faerie fire
                end
                for i = 2, 7 do
                    effects.by_school.spell_dmg_hit[i] = effects.by_school.spell_dmg_hit[i] + hit;
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.misery_hit);
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
        tooltip = "3% spell hit",
    },
    -- heart of the crusader
    [54499] = {
        apply = function(loadout, effects, buff)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.totem_of_wrath_crit_target) == 0 then
                for i = 2, 7 do
                    effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.03;
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.totem_of_wrath_crit_target);
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
        tooltip = "3% crit",
    },
    -- shadow mastery
    [17800] = {
        apply = function(loadout, effects, buff)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.mage_crit_target) == 0 then
                for i = 2, 7 do
                    effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.05;
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.mage_crit_target);
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
        tooltip = "5% crit",
    },
    -- winter's chill
    [12579] = {
        apply = function(loadout, effects, buff)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.mage_crit_target) == 0 then
                local crit = 0.05;
                if buff.count then
                    crit = 0.01 * buff.count;
                end
                for i = 2, 7 do
                    effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + crit;
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.mage_crit_target);
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
        category = buff_category.raid,
        tooltip = "5% crit",
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
    --haunt
    [48181] = {
        apply = function(loadout, effects, buff)
            if buff.src and buff.src ~= "player" then
                return;
            end
            local amount = 0.2;
            if loadout.glyphs[63302] then
                amount = 0.23;
            end
            for k, v in pairs(spell_names_to_id({"Unstable Affliction", "Curse of Agony", "Curse of Doom", "Seed of Corruption", "Corruption"})) do
                ensure_exists_and_add(effects.ability.vuln_ot_mod, v, amount, 0.0);
            end
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.hostile),
        category = buff_category.class,
        tooltip = "20% periodic shadow damage taken",
    },
    --immolate
    [348] = {
        apply = function(loadout, effects, buff)
            -- incinerate damage flat dmg increase done in later stage
            if buff.src and buff.src ~= "player" then
                return;
            end
            local pts  = loadout.talents_table:pts(3, 25);
            ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Incinerate"], pts * 0.02, 0.0);
            ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Chaos Bolt"], pts * 0.02, 0.0);

        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.hostile),
        category = buff_category.class,
        tooltip = "Incinerate extra damage. 10% more taken from Incinerate and Chaos Bolt. Conflagrate 25% crit",
    },
    --shadow embrace talent
    [32386] = {
        apply = function(loadout, effects, buff)
            local c = 3;
            if buff.src then
                if buff.src ~= "player" then
                    return;
                else
                    c = buff.count;
                end
            end

            local pts  = loadout.talents_table:pts(1, 14);
            for k, v in pairs(spell_names_to_id({"Unstable Affliction", "Curse of Agony", "Curse of Doom", "Seed of Corruption", "Corruption"})) do
                ensure_exists_and_add(effects.ability.vuln_ot_mod, v, c*pts*0.01, 0.0);
            end
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.hostile),
        category = buff_category.class,
        tooltip = "15% periodic shadow damage taken",
    },
    --thunder clap
    [23931] = {
        apply = function(loadout, effects, buff)
            loadout.flags = bit.bor(loadout.flags, loadout_flags.target_snared);

        end,
        filter = bit.bor(buff_filters.mage, buff_filters.hostile),
        category = buff_category.raid,
        tooltip = "Snared effect",
    },
    -- frost nova 
    [42917] = {
        apply = function(loadout, effects, buff)
            loadout.flags = bit.bor(loadout.flags, loadout_flags.target_frozen, loadout_flags.target_snared);
        end,
        filter = bit.bor(buff_filters.mage, buff_filters.hostile),
        category = buff_category.class,
        tooltip = "Frozen effect",
    },
    -- TODO: scared shield
    -- sacred shield flash of light crit proc
    [58597] = {
        apply = function(loadout, effects, buff)
            if not buff.src or buff.src == "player" then
                ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Flash of Light"], 0.5, 0.0);
            end
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.friendly),
        category = buff_category.class,
        tooltip = "Flash of Light 50% crit proc",
    },
    -- sacred shield flash of light hot
    [58597] = {
        -- TODO:
        apply = function(loadout, effects, buff)
            if not buff.src or buff.src == loadout.friendly_towards then
                ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Flash of Light"], 0.5, 0.0);
            end
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.friendly),
        category = buff_category.class,
        tooltip = "Flash of Light HOT",
    },
    -- regrowth
    [8936] = {
        apply = function(loadout, effects, buff)

            if not buff.src or buff.src == "player" then

                if loadout.glyphs[54743] then
                    ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Regrowth"], 0.2, 0.0);
                end

                if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.druid_nourish_bonus) == 0 then

                    ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Nourish"], 0.2, 0.0); 

                    effects.raw.non_stackable_effect_flags =
                        bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.druid_nourish_bonus);
                end
            end

        end,
        filter = bit.bor(buff_filters.druid, buff_filters.friendly),
        category = buff_category.class,
        tooltip = "",
    },
    -- rejuvenation (nourish bonus)
    [774] = {
        apply = function(loadout, effects, buff)
            
            if not buff.src or buff.src == "player" then

                if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.druid_nourish_bonus) == 0 then

                    ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Nourish"], 0.2, 0.0); 

                    effects.raw.non_stackable_effect_flags =
                        bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.druid_nourish_bonus);
                end
            end
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.friendly),
        category = buff_category.class,
        tooltip = "",
    },
    -- lifebloom (nourish bonus)
    [33763] = {
        apply = function(loadout, effects, buff)
            
            if not buff.src or buff.src == "player" then

                if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.druid_nourish_bonus) == 0 then

                    ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Nourish"], 0.2, 0.0); 

                    effects.raw.non_stackable_effect_flags =
                        bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.druid_nourish_bonus);
                end
            end
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.friendly),
        category = buff_category.class,
        tooltip = "",
    },
    -- lifebloom (nourish bonus)
    [48438] = {
        apply = function(loadout, effects, buff)
            
            if not buff.src or buff.src == "player" then

                if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.druid_nourish_bonus) == 0 then

                    ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Nourish"], 0.2, 0.0); 

                    effects.raw.non_stackable_effect_flags =
                        bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.druid_nourish_bonus);
                end
            end
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.friendly),
        category = buff_category.class,
        tooltip = "",
    },
    --shadowflame
    [61291] = {
        apply = function(loadout, effects, buff)
            -- dummy to track for conflagrate
        end,
        filter = bit.bor(buff_filters.warlock, buff_filters.hostile, buff_filters.hidden),
        category = buff_category.class,
        tooltip = "",
    },
};

-- identical implementations
-- is master poisoner baked into the poison debuff??
--target_buffs_predefined[45176] = target_buffs_predefined[54499]; -- master poisoner 3% crit
target_buffs_predefined[30708]  = deep_table_copy(target_buffs_predefined[54499]); -- totem of wrath 3% crit

target_buffs_predefined[116]    = deep_table_copy(target_buffs_predefined[23931]); -- snared
target_buffs_predefined[246]    = deep_table_copy(target_buffs_predefined[23931]); -- snared
target_buffs_predefined[67719]  = deep_table_copy(target_buffs_predefined[23931]); -- snared
target_buffs_predefined[53696]  = deep_table_copy(target_buffs_predefined[23931]); -- snared
target_buffs_predefined[48485]  = deep_table_copy(target_buffs_predefined[23931]); -- snared
target_buffs_predefined[120]    = deep_table_copy(target_buffs_predefined[23931]); -- snared
target_buffs_predefined[11113]  = deep_table_copy(target_buffs_predefined[23931]); -- snared
target_buffs_predefined[44614]  = deep_table_copy(target_buffs_predefined[23931]); -- snared

target_buffs_predefined[33395]  = deep_table_copy(target_buffs_predefined[42917]); -- frozen
target_buffs_predefined[44572]  = deep_table_copy(target_buffs_predefined[42917]); -- frozen


target_buffs_predefined[22959]  = deep_table_copy(target_buffs_predefined[17800]); -- improved scorch 5% crit

local buffs = {};
for k, v in pairs(buffs_predefined) do
    if bit.band(filter_flags_active, v.filter) ~= 0 then
        local buff_lname = GetSpellInfo(k);
        buffs[buff_lname] = v;
        buffs[buff_lname].id = k;
    end
end
local target_buffs = {};
for k, v in pairs(target_buffs_predefined) do
    if bit.band(filter_flags_active, v.filter) ~= 0 then
        local buff_lname = GetSpellInfo(k);
        target_buffs[buff_lname] = v;
        target_buffs[buff_lname].id = k;
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
            if not loadout.dynamic_buffs["player"][k] then
                buffs[k].apply(loadout, effects, buffs[k], true);
            end
        end
        for k, v in pairs(loadout.target_buffs) do
            target_buffs[k].apply(loadout, effects, target_buffs[k]);
        end
        if class == "PALADIN" and loadout.talents_table:pts(1, 26) ~= 0 and loadout.target_buffs["Beacon of Light"] then
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
        if loadout.glyphs[63218] then
            beacon_duration = 90;
        end
 
        if class == "PALADIN" and loadout.talents_table:pts(1, 26) and addonTable.beacon_snapshot_time + beacon_duration >= addonTable.addon_running_time then
            loadout.beacon = true;
        else
            loadout.beacon = nil
        end
    end

    --loadout_add(loadout, stats_diff_loadout, effects);
end

addonTable.buff_filters = buff_filters;
addonTable.filter_flags_active = filter_flags_active;
addonTable.buff_category = buff_category;
addonTable.buffs = buffs;
addonTable.target_buffs = target_buffs;
addonTable.detect_buffs = detect_buffs;
addonTable.apply_buffs = apply_buffs;
addonTable.non_stackable_effects = non_stackable_effects;

