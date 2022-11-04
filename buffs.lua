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
local class                         = addonTable.class;
local race                          = addonTable.race;

local magic_school                  = addonTable.magic_school;
local spell_name_to_id              = addonTable.spell_name_to_id;
local spell_names_to_id             = addonTable.spell_names_to_id;

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

local non_stackable_effects = {
    moonkin_crit                = bit.lshift(1, 0),
    arcane_empowerment          = bit.lshift(1, 1),
    totem_of_wrath_sp           = bit.lshift(1, 2),
    moonkin_haste               = bit.lshift(1, 3),
    earth_and_moon              = bit.lshift(1, 4),
    totem_of_wrath_crit_target  = bit.lshift(1, 5),
    misery_hit                  = bit.lshift(1, 6),
    mage_crit_target            = bit.lshift(1, 7),
    divine_hymn_buff            = bit.lshift(1, 8),
    water_shield                = bit.lshift(1, 9),
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
            effects.raw.cost_mod = effects.raw.cost_mod * 0.2;
        end,
        filter = buff_filters.caster,
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
    },
    --shadow form
    [15473] = {
        apply = function(loadout, effects, buff)
            effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.shadow]) * 1.15 - 1.0;
        end,
        filter = buff_filters.priest,
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
    },
    --divine hymn buff
    [24907] = {
        apply = function(loadout, effects, buff, inactive)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.divine_hymn_buff) == 0 then
                effects.raw.target_healing_taken = effects.raw.target_healing_taken + 0.1;
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.divine_hymn_buff);
            end
        end,
        filter = buff_filters.caster,
    },
    --eclipse lunar
    [48518] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Starfire"], 0.4, 0);
        end,
        filter = buff_filters.druid,
    },
    --eclipse solar
    [48517] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Wrath"], 0.4, 1.0);
        end,
        filter = buff_filters.druid,
    },
    --moonkin aura
    [24907] = {
        apply = function(loadout, effects, buff, inactive)
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.moonkin_haste) == 0 then
                local haste = 0.03;
                if buff.src == "player" then
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
    },
    --moonkin form
    [24858] = {
        apply = function(loadout, effects, buff)
            -- mana refund done in later stage
            -- master shapeshifter
            local pts = loadout.talents_table:pts(3, 9);
            effects.by_school.target_spell_dmg_taken[magic_school.arcane] =
                effects.by_school.target_spell_dmg_taken[magic_school.arcane] + pts * 0.02;
            effects.by_school.target_spell_dmg_taken[magic_school.nature] =
                effects.by_school.target_spell_dmg_taken[magic_school.nature] + pts * 0.02;
        end,
        filter = buff_filters.druid,
    },
    --tree of life form
    [33891] = {
        apply = function(loadout, effects, buff)
            -- mana refund done in later stage
            -- master shapeshifter
            local pts = loadout.talents_table:pts(3, 9);
            effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + pts * 0.02;
        end,
        filter = buff_filters.druid,
    },
    -- bloodlust
    [2825] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * 1.3 - 1.0;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.horde),
    },
    -- heroism
    [32182] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * 1.3 - 1.0;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.alliance),
    },
    -- focus magic (mage being src)
    [32182] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                for i = 2, 7 do
                    effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.03;
                end
            end
        end,
        filter = buff_filters.mage,
    },
    -- focus magic (any target)
    [54648] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                for i = 2, 7 do
                    effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.03;
                end
            end
        end,
        filter = buff_filters.caster,
    },
    -- hyperspeed acceleration (engineering gloves enchant)
    [54758] = {
        apply = function(loadout, effects, buff, inactive)
            if inactive then
                effects.raw.haste_rating = effects.raw.haste_rating + 340;
            end
        end,
        filter = buff_filters.caster,
    },
    -- lightweave (tailoring cloak enchant)
    [55637] = {
        apply = function(loadout, effects, buff, inactive)

            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + 295;
            end
        end,
        filter = buff_filters.caster,
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
    },
    -- potion of speed
    [53908] = {
        apply = function(loadout, effects, buff, inactive)

            if inactive then
                effects.raw.haste_rating = effects.raw.haste_rating + 500;
            end
        end,
        filter = buff_filters.caster,
    },
    -- flask of the frost wyrm
    [53755] = {
        apply = function(loadout, effects, buff, inactive)

            if inactive then
                effects.raw.spell_power = effects.raw.spell_power + 125;
            end
        end,
        filter = buff_filters.caster,
    },
    --wrath of air
    [3738] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * (1.05) - 1.0;
        end,
        filter = buff_filters.caster,
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
    },
    --sanctified retribution
    [31869] = {
        apply = function(loadout, effects, buff, inactive)
            -- dynamically scales with the warlock owner's sp but still needs tracking
            -- assume same effect as totem if applied statically
            if bit.band(effects.raw.non_stackable_effect_flags, non_stackable_effects.arcane_empowerment) == 0 then
                for i = 2, 7 do
                    effects.by_school.spell_dmg_mod[i] = 
                        effects.by_school.spell_dmg_mod[i] + 0.03;
                end
                effects.raw.non_stackable_effect_flags =
                    bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.arcane_empowerment);
            end
        end,
        filter = buff_filters.caster,
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
    },
    --riptide
    [61295] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.vuln_mod, spell_name_to_id["Chain Heal"], 0.25, 0.0);
        end,
        filter = buff_filters.shaman,
    },
    --elemental mastery
    [64701] = {
        apply = function(loadout, effects, buff)
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * 1.15 - 1.0;
        end,
        filter = buff_filters.shaman,
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
    },
    --water shield
    [52127] = {
        apply = function(loadout, effects, buff)

            --trickery to flag that healing crits restore mana
           effects.raw.non_stackable_effect_flags =
               bit.bor(effects.raw.non_stackable_effect_flags, non_stackable_effects.water_shield);
        end,
        filter = buff_filters.shaman,
    },
    --tidal waves
    [53390] = {
        apply = function(loadout, effects, buff)
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Lesser Healing Wave"], 0.25, 0.0);
            ensure_exists_and_add(effects.ability.cast_mod_mul, spell_name_to_id["Healing Wave"], 0.3, 0.0);
        end,
        filter = buff_filters.shaman,
    },

};
-- identical implementations
buffs_predefined[31583] = buffs_predefined[31869];-- arcane_empowerment
buffs_predefined[34460] = buffs_predefined[31869];-- ferocious inspiration

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
    },
    --beacon of light
    [53563] = {
        -- just used for toggle and icon in buffs, applied later
        apply = function(loadout, effects, buff)
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.friendly),
    },
    --tree of life
    [34123] = {
        apply = function(loadout, effects, buff)
            effects.raw.target_healing_taken = effects.raw.target_healing_taken + 0.06;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.friendly),
    },
    --moonfire (improved insect swarm talent)
    [8921] = {
        apply = function(loadout, effects, buff)
            local pts = loadout.talents_table:pts(1, 14);
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Starfire"], pts * 0.01, 0);
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.hostile),
        name = "Improved Insect Swarm",
    },
    --insect swarm (improved insect swarm talent)
    [5570] = {
        apply = function(loadout, effects, buff)
            -- done in later stage
        end,
        name = "Improved Insect Swarm",
        filter = bit.bor(buff_filters.druid, buff_filters.hostile),
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
    },
    --totem of wrath crit
    [57722] = {
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
    },
    -- winter's chill
    [17800] = {
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
    },
    -- flame shock (lava burst crit)
    [17800] = {
        apply = function(loadout, effects, buff)

            ensure_exists_and_add(effects.ability.spell_crit, spell_name_to_id["Lava Burst"], 1.0, 0.0);    
        end,
        filter = bit.bor(buff_filters.shaman, buff_filters.hostile),
    },
};

-- identical implementations
target_buffs_predefined[58410] = target_buffs_predefined[57722]; -- master poisoner 3% crit
target_buffs_predefined[20337] = target_buffs_predefined[57722]; -- heart of the crusader 3% crit

target_buffs_predefined[22959] = target_buffs_predefined[17800]; -- improved scorch 5% crit

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
              local name, icon_tex, count, _, _, _, src, _, _, spell_id = UnitBuff(k, i);
              if not name then
                  break;
              end
              v[name] = {count = count, id = spell_id, src = src};
              i = i + 1;
        end
        local i = 1;
        while true do
              local name, _, count, _, _, _, src, _, _, spell_id = UnitDebuff(k, i);
              if not name then
                  break;
              end
              v[name] = {count = count, id = spell_id, src = src};
              i = i + 1;
        end
    end
end

local function apply_buffs(loadout, effects)

    -- TODO: some subtle things need to be done here when attributes and percentage mods
    --       go together through change
    --local stats_diff_loadout = empty_loadout();

    if loadout.always_assume_buffs then
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
        if class == "PALADIN" and loadout.talents_table:pts(1, 26) ~= 0 and loadout.target_buffs[spell_name_to_id["Beacon of Light"]] then
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

        if class == "PALADIN" and loadout.talents_table:pts(1, 26) and (loadout.target_buffs[spell_name_to_id["Beacon of Light"]] or not loadout.always_assume_buffs) and addonTable.beacon_snapshot_time + 60 >= addonTable.addon_running_time then
            loadout.beacon = true;
        else
            loadout.beacon = nil
        end
    end

    --loadout_add(loadout, stats_diff_loadout, effects);
end


addonTable.buff_filters = buff_filters;
addonTable.filter_flags_active = filter_flags_active;
addonTable.buffs = buffs;
addonTable.target_buffs = target_buffs;
addonTable.detect_buffs = detect_buffs;
addonTable.apply_buffs = apply_buffs;
addonTable.non_stackable_effects = non_stackable_effects;

