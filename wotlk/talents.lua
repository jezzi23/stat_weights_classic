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

local addonName, addonTable = ...;
local ensure_exists_and_add         = addonTable.ensure_exists_and_add;
local ensure_exists_and_mul         = addonTable.ensure_exists_and_mul;
local class                         = addonTable.class;
local race                          = addonTable.race;

local magic_school                  = addonTable.magic_school;
local spell_name_to_id              = addonTable.spell_name_to_id;
local spell_names_to_id             = addonTable.spell_names_to_id;
local spells                        = addonTable.spells;

local stat                          = addonTable.stat;

local function create_glyphs()
    if class == "PRIEST" then
        return {
            -- glyph of circle of healing
            [55675] = {
                apply = function(loadout, effects)
                    --TODO
                end,
                wowhead_id = "pbv"
            },
            -- glyph of shadow
            [55689] = {
                apply = function(loadout, effects)
                    --TODO: trackable buff?
                end,
                wowhead_id = "pc9"
            },
            -- glyph of word pain
            [55681] = {
                apply = function(loadout, effects)
                    --TODO
                end,
                wowhead_id = "pc1"
            },
            -- glyph of mind flay
            [55687] = {
                apply = function(loadout, effects)
                    -- TODO
                end,
                wowhead_id = "pc7"
            },
            -- glyph of power word shield
            [55672] = {
                wowhead_id = "pbr"
            },
            -- glyph of flash heal
            [55679] = {
                apply = function(loadout, effects)
                    local fl = spell_name_to_id["Flash Heal"];
                    ensure_exists_and_add(effects.ability.cost_mod, fl, 0.1, 0);
                end,
                wowhead_id = "pbz"
            },
            -- glyph of holy nova
            [55683] = {
                apply = function(loadout, effects)
                    local hn = spell_name_to_id["Holy Nova"];
                    ensure_exists_and_mul(effects.ability.effect_mod, hn, 1.20, 1.0);
                end,
                wowhead_id = "pc3"
            },
            -- glyph of prayer of healing
            [55680] = {
                apply = function(loadout, effects)
                    local ph = spell_name_to_id["Prayer of Healing"];
                    --TODO
                end,
                wowhead_id = "pc0"
            },
            -- glyph of smite
            [55692] = {
                apply = function(loadout, effects)
                    --TODO
                end,
                wowhead_id = "pcc"
            },
            -- glyph of shadow word death
            [55682] = {
                apply = function(loadout, effects)
                    --TODO
                end,
                wowhead_id = "pc2"
            },
            -- glyph of renew
            [55674] = {
                apply = function(loadout, effects)
                    local renew = spell_name_to_id["Renew"];

                    ensure_exists_and_add(effects.ability.extra_ticks, renew, -1, 0);
                    -- heal increase applied later calculation
                end,
                wowhead_id = "pbt"
            },
            -- glyph of lightwell
            [55673] = {
                apply = function(loadout, effects)
                    local lw = spell_name_to_id["Lightwell"];
                    ensure_exists_and_mul(effects.ability.effect_mod, lw, 1.20, 1.0);
                end,
                wowhead_id = "pbs"
            }
        };
    elseif class == "DRUID" then
        return {
            -- glyph of focus
            [62080] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Starfall"], 0.1, 0.0);
                end,
                wowhead_id = "wm0"
            },
            -- glyph of healing touch
            [54825] = {
                apply = function(loadout, effects)
                    local ht = spell_name_to_id["Healing Touch"];
                    ensure_exists_and_add(effects.ability.effect_mod, ht, -0.5, 0.0);
                    ensure_exists_and_add(effects.ability.cost_mod, ht, 0.25, 0.0);
                    ensure_exists_and_add(effects.ability.cast_mod, ht, 1.5, 0.0);
                end,
                wowhead_id = "nh9"
            },
            -- glyph of insect swarm
            [54830] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Insect Swarm"], 0.3, 0.0);
                end,
                wowhead_id = "nhe"
            },
            -- glyph of lifebloom
            [54826] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.extra_ticks, spell_name_to_id["Lifebloom"], 1, 0.0);
                end,
                wowhead_id = "nha"
            },
            -- glyph of moonfire
            [54829] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Moonfire"], -0.9 , 0.0);
                    ensure_exists_and_add(effects.ability.effect_ot_mod, spell_name_to_id["Moonfire"], 0.9 + 0.75, 0.0);
                end,
                wowhead_id = "nhd"
            },
            -- glyph of nourish
            [62971] = {
                apply = function(loadout, effects)
                    -- TODO: need to track  some druid hots and
                    --       swiftmend could be implemented in the process
                end,
                wowhead_id = "xfv"
            },
            -- glyph of rapid rejuvenation
            -- TODO: wowhead id begins with _002 intead of _001???
            [71013] = {
                apply = function(loadout, effects)
                    -- implementeed in later stage
                end,
                wowhead_id = "5b5",
                special = true
            },
            -- glyph of regrowth
            [54743] = {
                apply = function(loadout, effects)
                    -- TODO: regrowth tracking
                end,
                wowhead_id = "neq"
            },
            -- glyph of rejuvenatioin
            [54754] = {
                apply = function(loadout, effects)
                end,
                wowhead_id = "nf2"
            },
            -- glyph of wild growth
            [62970] = {
                apply = function(loadout, effects)
                    -- implemented in later stage
                end,
                wowhead_id = "xft"
            },
            -- glyph of innervate
            [54832] = {
                apply = function(loadout, effects)
                    -- implemented in later stage
                end,
                wowhead_id = "nhg"
            },
        };
    elseif class == "PALADIN" then
        return {
            -- glyph of beacon of light
            [63218] = {
                apply = function(loadout, effects)
                    -- TODO: 60 to 90
                end,
                wowhead_id = "xqj"
            },
            -- glyph of flash of light
            [54936] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Flash of Light"], 0.05, 0.0);
                end,
                wowhead_id = "nmr"
            },
            -- glyph of holy light
            [54937] = {
                apply = function(loadout, effects)
                    -- Implemented in later stage
                end,
                wowhead_id = "nms"
            },
            -- glyph of seal of light
            [54943] = {
                apply = function(loadout, effects)
                    -- Implemented in buffs
                end,
                wowhead_id = "nmz"
            },
            -- glyph of seal of wisdom
            [54940] = {
                apply = function(loadout, effects)
                    -- Implemented in buffs
                end,
                wowhead_id = "nmw"
            },
        };
    elseif class == "SHAMAN" then
        return {
            -- glyph of chain heal
            [55437] = {
                apply = function(loadout, effects)
                    -- Impemented in later stage
                end,
                wowhead_id = "p4d"
            },
            -- glyph of chain lightning
            [55449] = {
                apply = function(loadout, effects)
                    -- Impemented in later stage
                end,
                wowhead_id = "p4s"
            },
            -- glyph of earth shield
            [63279] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Earth Shield"], 0.2, 0.0);
                end,
                wowhead_id = "xsf"
            },
            -- glyph of earthliving weapon
            [55439] = {
                apply = function(loadout, effects)
                    -- TODO
                end,
                wowhead_id = "p4f"
            },
            -- glyph of flametongue weapon
            [55451] = {
                apply = function(loadout, effects)
                    -- TODO
                end,
                wowhead_id = "p4v"
            },
            -- glyph of flame shock
            [55447] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.crit_mod, spell_name_to_id["Flame Shock"], 0.3, 0.0);
                end,
                wowhead_id = "p4q"
            },
            -- glyph of healing stream totem
            [55456] = {
                apply = function(loadout, effects)
                    -- wording is interesting, could be a multiplier
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Healing Stream Totem"], 0.2, 0.0);
                end,
                wowhead_id = "p50"
            },
            -- glyph of lava
            [55454] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Lava Burst"], 0.1, 0.0);
                end,
                wowhead_id = "p4y"
            },
            -- glyph of lightning bolt
            [55453] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Lightning Bolt"], 0.04, 0.0);
                end,
                wowhead_id = "p4x"
            },
            -- glyph of lightning shield
            [55448] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Lightning Shield"], 0.2, 0.0);
                end,
                wowhead_id = "p4r"
            },
            -- glyph of shocking
            [55442] = {
                apply = function(loadout, effects)
                    local shocks = spell_names_to_id({"Flame Shock", "Earth Shock", "Frost Shock"});
                    for _, v in pairs(shocks) do
                        ensure_exists_and_add(effects.ability.cast_mod, v, 0.5, 0.0);
                    end
                end,
                wowhead_id = "p4j"
            },
            -- glyph of totem of wrath
            [63280] = {
                apply = function(loadout, effects)
                    -- TODO: see if this is a separate buff or baked into the main one
                end,
                wowhead_id = "xsg"
            },
            -- glyph of water mastery
            [55436] = {
                apply = function(loadout, effects)
                    -- TODO: 
                end,
                wowhead_id = "p4c"
            },

        };
    elseif class == "MAGE" then
        return {
            -- glyph of arcane barrage
            [63092] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Arcane Barrage"], 0.2, 0.0);
                end,
                wowhead_id = "xkm"
            },
            -- glyph of arcane blast
            [62210] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Arcane Blast"], 0.03, 0.0);
                end,
                wowhead_id = "wr2"
            },
            -- glyph of arcane exposion
            [56360] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Arcane Explosion"], 0.1, 0.0);
                end,
                wowhead_id = "q18"
            },
            -- glyph of arcane missiles
            [56363] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.crit_mod, spell_name_to_id["Arcane Missiles"], 0.125, 0.0);
                end,
                wowhead_id = "q1b"
            },
            -- glyph of frostbolt
            [56370] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Frostbolt"], 0.05, 0.0);
                end,
                wowhead_id = "q1j"
            },
            -- glyph of frostfire
            [61205] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Frostfire Bolt"], 0.02, 0.0);
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Frostfire Bolt"], 0.02, 0.0);
                end,
                wowhead_id = "vrn"
            },
            -- glyph of ice barrier
            [63095] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Ice Barrier"], 0.3, 0.0);
                end,
                wowhead_id = "xkq"
            },
            -- glyph of ice lance
            [56377] = {
                apply = function(loadout, effects)
                    -- Implemented in a later stage
                end,
                wowhead_id = "q1s"
            },
            -- glyph of mage armor
            [56383] = {
                apply = function(loadout, effects)
                    effects.raw.regen_while_casting = effects.raw.regen_while_casting + 0.2;
                end,
                wowhead_id = "q1z"
            },
            -- glyph of molten armor
            [56382] = {
                apply = function(loadout, effects)
                    -- TODO:
                end,
                wowhead_id = "q1y"
            },
            -- glyph of scorch
            [56371] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Scorch"], 0.2, 0.0);
                end,
                wowhead_id = "q1k"
            },
            -- glyph of fireball
            [56368] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Fireball"], 0.15, 0.0);
                end,
                wowhead_id = "q1g"
            },
            -- glyph of living bomb
            [63091] = {
                apply = function(loadout, effects)
                    -- implemented in later stage
                end,
                wowhead_id = "xkk"
            }
        };

    elseif class == "WARLOCK" then
        return {
            -- glyph of haunt
            [63302] = {
                apply = function(loadout, effects)
                    -- Implemented in buffs
                end,
                wowhead_id = "xt6"
            },
            -- glyph of immolate
            [56228] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_ot_mod, spell_name_to_id["Immolate"], 0.1, 0.0);
                end,
                wowhead_id = "px4"
            },
            -- glyph of incinerate
            [56242] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Incinerate"], 0.05, 0.0);
                end,
                wowhead_id = "pxj"
            },
            -- glyph of life tap
            [63320] = {
                apply = function(loadout, effects)
                    -- TODO: to be implemented in buffs
                end,
                wowhead_id = "xtr"
            },
            -- glyph of quick decay
            [70947] = {
                apply = function(loadout, effects)
                    -- Implemented in later stage
                end,
                -- TODO: _002 prefix instead of _001, won't work atm via import
                wowhead_id = "593",
                special = true
            },
            -- glyph of searing pain
            [56226] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.crit_mod, spell_name_to_id["Searing Pain"], 0.1, 0.0);
                end,
                wowhead_id = "px2"
            },
            -- glyph of shadow bolt
            [56240] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Shadow Bolt"], 0.1, 0.0);
                end,
                wowhead_id = "pxg"
            },
            -- glyph of shadow burn
            [56229] = {
                apply = function(loadout, effects)
                    -- Implemented in later stage
                end,
                wowhead_id = "px5"
            },
            -- glyph of unstable affliction
            [56233] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Unstable Affliction"], 0.2, 0.0);
                end,
                wowhead_id = "px9"
            },
            -- glyph of curse of agony
            [56241] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.extra_ticks, spell_name_to_id["Curse of Agony"], 2, 0.0);
                end,
                wowhead_id = "phx"
            },
        };
    else
        return {};
    end
end

local function create_talents()
    if class == "PRIEST" then
        return {
            [102] = {
                apply = function(loadout, effects, pts)
                    local instants = spell_names_to_id({"Renew", "Holy Nova", "Circle of Healing", "Prayer of Mending", "Devouring Plague", "Shadow Word: Pain", "Shadow Word: Death",  "Mind Flay", "Mind Sear", "Desperate Prayer"});
                    for k, v in pairs(instants) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.01, 0.0);
                    end

                    -- super hack to get absorb glyph correct
                    ensure_exists_and_add(effects.ability.effect_ot_mod, spell_name_to_id["Power Word: Shield"], pts * 0.01, 0.0);
                end
            },
            [107] = {
                apply = function(loadout, effects, pts)
                    if pts ~= 0 then
                        local regen = {0.17, 0.33, 0.5};
                        effects.raw.regen_while_casting = effects.raw.regen_while_casting + regen[pts];
                    end
                end
            },
            [109] = {
                apply = function(loadout, effects, pts)
                    local shield = spell_name_to_id["Power Word: Shield"];
                    ensure_exists_and_mul(effects.ability.effect_mod, shield, 1.0 + pts * 0.05, 0.0);
                    if not effects.ability.effect_mod then
                        effects.ability.effect_mod[shield] = 0.0;
                    end
                    effects.ability.effect_mod[shield] =
                        (1.0 + effects.ability.effect_mod[shield]) * (1.0 + pts * 0.05) - 1.0;
                end
            },
            [111] = {
                apply = function(loadout, effects, pts)
                    if pts ~= 0 then
                        local mod = {0.04, 0.07, 0.1};
                        local instants = spell_names_to_id({"Renew", "Holy Nova", "Circle of Healing", "Prayer of Mending", "Devouring Plague", "Shadow Word: Pain", "Shadow Word: Death",  "Mind Flay", "Mind Sear", "Desperate Prayer"});
                        for k, v in pairs(instants) do
                            ensure_exists_and_add(effects.ability.cost_mod, v, mod[pts], 0);
                        end
                        local shield = spell_name_to_id["Power Word: Shield"];
                        ensure_exists_and_add(effects.ability.cost_mod, shield, mod[pts], 0);
                    end
                end
            },
            [114] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + pts * 0.03;
                end
            },
            [116] = {
                apply = function(loadout, effects, pts)
                    effects.raw.spell_heal_mod_mul =
                        (1.0 + effects.raw.spell_heal_mod_mul)*(1.0 + pts * 0.02) - 1.0;
                    effects.by_school.spell_dmg_mod[magic_school.holy] =
                        effects.by_school.spell_dmg_mod[magic_school.holy] + pts * 0.02;
                    effects.by_school.spell_dmg_mod[magic_school.shadow] =
                        effects.by_school.spell_dmg_mod[magic_school.shadow] + pts * 0.02;
                end
            },
            [117] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.stat_mod[stat.spirit] = effects.by_attribute.stat_mod[stat.spirit] + pts * 0.02;
                    effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * (1.0 + pts * 0.02) - 1.0;
                end
            },
            [118] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_crit[magic_school.holy] = 
                        effects.by_school.spell_crit[magic_school.holy] + 0.01 * pts;
                    effects.by_school.spell_crit[magic_school.shadow] = 
                        effects.by_school.spell_crit[magic_school.shadow] + 0.01 * pts;
                end
            },
            [120] = {
                apply = function(loadout, effects, pts)
                    local flash_heal = spell_name_to_id["Flash Heal"];
                    ensure_exists_and_add(effects.ability.cost_mod, flash_heal, pts * 0.05, 0);
                end
            },
            [127] = {
                apply = function(loadout, effects, pts)
                    local shield = spell_name_to_id["Power Word: Shield"];
                    ensure_exists_and_add(effects.ability.coef_mod, shield, pts * 0.08, 0); 
                end
            },
            [202] = {
                apply = function(loadout, effects, pts)
                    local renew = spell_name_to_id["Renew"];
                    ensure_exists_and_add(effects.ability.effect_mod, renew, pts * 0.05, 0.0); 
                end
            },
            [203] = {
                apply = function(loadout, effects, pts, missing_pts)
                    effects.by_school.spell_crit[magic_school.holy] = 
                        effects.by_school.spell_crit[magic_school.holy] + 0.01 * missing_pts;
                end
            },
            [205] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Smite", "Holy Fire", "Heal", "Greater Heal"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.cast_mod, v, pts * 0.1, 0);
                    end
                end
            },
            [210] = {
                apply = function(loadout, effects, pts)
                    local abilities =
                        spell_names_to_id({"Lesser Heal", "Heal", "Greater Heal", "Divine Hymn", "Penance"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.05, 0);
                    end
                end
            },
            [211] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Smite", "Holy Fire", "Holy Nova", "Penance"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.05, 0.0);
                    end
                end
            },
            [212] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Prayer of Healing", "Prayer of Mending"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.1, 0);
                    end
                end
            },
            [213] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.stat_mod[stat.spirit] = effects.by_attribute.stat_mod[stat.spirit] + pts * 0.05;
                end
            },
            [214] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.sp_from_stat_mod[stat.spirit] = effects.by_attribute.sp_from_stat_mod[stat.spirit] + pts * 0.05;
                end
            },
            [216] = {
                apply = function(loadout, effects, pts)
                    effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + pts * 0.02;
                end
            },
            [219] = {
                apply = function(loadout, effects, pts)
                    effects.raw.spell_heal_mod_mul =
                        (1.0 + effects.raw.spell_heal_mod_mul)*(1.0 + pts * 0.01) - 1.0;
                end
            },
            [221] = {
                apply = function(loadout, effects, pts)
                    local gh = spell_name_to_id["Greater Heal"];
                    local fh = spell_name_to_id["Flash Heal"];
                    local bh = spell_name_to_id["Binding Heal"];

                    ensure_exists_and_add(effects.ability.coef_mod, gh, pts * 0.08, 0);
                    ensure_exists_and_add(effects.ability.coef_mod, fh, pts * 0.04, 0);
                    ensure_exists_and_add(effects.ability.coef_mod, bh, pts * 0.04, 0);
                end
            },
            [223] = {
                apply = function(loadout, effects, pts)
                    local renew = spell_name_to_id["Renew"];
                    ensure_exists_and_add(effects.ability.coef_ot_mod, renew, pts * 0.05, 0);
                end
            },
            [226] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Circle of Healing", "Binding Heal", "Holy Nova", "Prayer of Healing", "Divine Hymn", "Prayer of Mending"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.02, 0.0);
                    end
                end
            },
            [303] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id(
                        {"Devouring Plague", "Mind Blast", "Shadow Word: Pain", "Mind Flay", "Vampiric Touch", "Shadow Word: Death", "Mind Sear"}
                    );
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.02, 0.0);
                    end
                end
            },
            [305] = {
                apply = function(loadout, effects, pts)
                    local swp = spell_name_to_id["Shadow Word: Pain"];                
                    ensure_exists_and_add(effects.ability.effect_mod, swp, pts * 0.03, 0.0);
                end
            },
            [306] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_hit[magic_school.shadow] = 
                        effects.by_school.spell_dmg_hit[magic_school.shadow] + pts * 0.01;

                    local abilities = spell_names_to_id(
                        {"Devouring Plague", "Mind Blast", "Shadow Word: Pain", "Mind Flay", "Vampiric Touch", "Shadow Word: Death", "Mind Sear"}
                    );
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.02, 0);
                    end
                end
            },
            [316] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Mind Blast", "Mind Flay", "Mind Sear"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.05, 0);
                    end
                end
            },
            [317] = {
                apply = function(loadout, effects, pts)
                    local mind = spell_names_to_id({"Mind Blast", "Mind Flay", "Mind Sear"});
                    for k, v in pairs(mind) do
                        ensure_exists_and_add(effects.ability.crit, v, pts * 0.02, 0);
                    end
                    local dots = spell_names_to_id({"Vampiric Touch", "Shadow Word: Pain", "Devouring Plague"});
                    for k, v in pairs(dots) do
                        ensure_exists_and_add(effects.ability.crit, v, pts * 0.03, 0);
                    end
                end
            },
            [318] = {
                apply = function(loadout, effects, pts)
                    local dp = spell_name_to_id["Devouring Plague"];
                    ensure_exists_and_add(effects.ability.effect_mod, dp, pts * 0.05, 0.0);
                end
            },
            [320] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Mind Blast", "Mind Flay", "Shadow Word: Death"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.crit_mod, v, pts * 0.1, 0);
                    end
                end
            },
            [322] = {
                apply = function(loadout, effects, pts)
                    local mind_flay = spell_name_to_id["Mind Flay"];
                    ensure_exists_and_add(effects.ability.coef_ot_mod, mind_flay,  pts * 0.05, 0);
                    local mind_sear = spell_name_to_id["Mind Sear"];
                    ensure_exists_and_add(effects.ability.coef_ot_mod, mind_sear, pts * 0.05, 0);
                    local mind_blast = spell_name_to_id["Mind Blast"];
                    ensure_exists_and_add(effects.ability.coef_mod, mind_blast, pts * 0.05 * 0.4286, 0);
                end
            },
            [326] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.sp_from_stat_mod[stat.spirit] = effects.by_attribute.sp_from_stat_mod[stat.spirit] + pts * 0.04;
                end
            },
        };
    elseif class == "DRUID" then
        return {
            [101] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Wrath", "Starfire"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.cast_mod, v, pts * 0.1, 0);
                    end
                end
            },
            [102] = {
                apply = function(loadout, effects, pts)
                    effects.raw.ot_mod = effects.raw.ot_mod + 0.01 * pts;
                end
            },
            [103] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Moonfire", "Starfire", "Wrath", "Healing Touch", "Nourish", "Regrowth", "Rejuvenation"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.03, 0);
                    end
                end
            },
            [104] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Wrath", "Starfire", "Starfall", "Nourish", "Healing Touch"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.crit, v, pts * 0.02, 0.0);
                    end
                end
            },
            [105] = {
                apply = function(loadout, effects, pts)
                    local mf = spell_name_to_id["Moonfire"];
                    ensure_exists_and_add(effects.ability.crit, mf, pts * 0.05, 0);
                    ensure_exists_and_add(effects.ability.effect_mod, mf, pts * 0.05, 0.0);
                end
            },
            [106] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Thorns", "Entangling Roots"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.25, 0.0);
                    end
                end
            },
            [108] = {
                apply = function(loadout, effects, pts)
                    local one_ticks = spell_names_to_id({"Moonfire", "Rejuvenation", "Insect Swarm"});
                    local two_ticks = spell_names_to_id({"Regrowth", "Lifebloom"});
                    for k, v in pairs(one_ticks) do
                        ensure_exists_and_add(effects.ability.extra_ticks, v, 1 * pts, 0);
                    end
                    for k, v in pairs(two_ticks) do
                        ensure_exists_and_add(effects.ability.extra_ticks, v, 2 * pts, 0);
                    end
                end
            },
            [110] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Starfire", "Starfall", "Moonfire", "Wrath"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.crit_mod, v, pts * 0.1, 0);
                    end
                end
            },
            [111] = {
                apply = function(loadout, effects, pts)
                    effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * (1.0 + pts * 0.01) - 1.0;
                end
            },
            [112] = {
                apply = function(loadout, effects, pts)
                    -- TODO: scaling
                    -- dynamic fix
                    effects.by_attribute.sp_from_stat_mod[stat.int] = effects.by_attribute.sp_from_stat_mod[stat.int]+ pts * 0.04;
                end
            },
            [115] = {
                apply = function(loadout, effects, pts)
                    effects.raw.mp5_from_int_mod = effects.raw.mp5_from_int_mod + 0.04 * pts;
                end
            },
            [116] = {
                apply = function(loadout, effects, pts)
                    if pts ~= 0 then
                        local abilities = spell_names_to_id({"Starfire", "Moonfire", "Wrath"});
                        local dmg_mod_by_pts = {0.03, 0.06, 0.1};
                        for k, v in pairs(abilities) do
                            ensure_exists_and_add(effects.ability.effect_mod, v, dmg_mod_by_pts[pts], 0.0);
                        end
                    end
                end
            },
            [117] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_hit[magic_school.nature] = 
                        effects.by_school.spell_dmg_hit[magic_school.nature] + pts * 0.02;
                    effects.by_school.spell_dmg_hit[magic_school.arcane] = 
                        effects.by_school.spell_dmg_hit[magic_school.arcane] + pts * 0.02;
                end
            },
            [122] = {
                apply = function(loadout, effects, pts)
                    local sf = spell_name_to_id["Starfire"];
                    local w = spell_name_to_id["Wrath"];
                    ensure_exists_and_add(effects.ability.coef_mod, sf, pts * 0.04, 0);
                    ensure_exists_and_add(effects.ability.coef_mod, w, pts * 0.02, 0);
                end
            },
            [126] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Hurricane", "Typhoon"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.15, 0.0);
                    end
                end
            },
            [127] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_mod[magic_school.arcane] = 
                        effects.by_school.spell_dmg_mod[magic_school.arcane] + 0.02 * pts;
                    effects.by_school.spell_dmg_mod[magic_school.nature] = 
                        effects.by_school.spell_dmg_mod[magic_school.nature] + 0.02 * pts;
                end
            },
            [217] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + pts * 0.04;
                end
            },
            [304] = {
                apply = function(loadout, effects, pts)
                    local ht = spell_name_to_id["Healing Touch"];
                    ensure_exists_and_add(effects.ability.cast_mod, ht, pts * 0.1, 0);
                end
            },
            [307] = {
                apply = function(loadout, effects, pts)
                    if pts ~= 0 then
                        local regen = {0.17, 0.33, 0.5};
                        effects.raw.regen_while_casting = effects.raw.regen_while_casting + regen[pts];
                    end
                end
            },
            [310] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Healing Touch", "Tranquility", "Nourish"});
                    
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.02, 0);
                    end
                end
            },
            [311] = {
                apply = function(loadout, effects, pts)
                    local rejuv = spell_name_to_id["Rejuvenation"];
                    ensure_exists_and_add(effects.ability.effect_mod, rejuv, pts * 0.05, 0.0);
                end
            },
            [313] = {
                apply = function(loadout, effects, pts)
                    effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + pts * 0.02;
                end
            },
            [315] = {
                apply = function(loadout, effects, pts)
                    local ht = spell_name_to_id["Healing Touch"];
                    local no = spell_name_to_id["Nourish"];
                    ensure_exists_and_add(effects.ability.coef_mod, ht, pts * 0.2, 0);
                    ensure_exists_and_add(effects.ability.coef_mod, no, pts * 0.1, 0);
                end
            },
            [316] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Regrowth", "Nourish"});
                    
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.crit, v, pts * 0.05, 0);
                    end
                end
            },
            [317] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.stat_mod[stat.spirit] = effects.by_attribute.stat_mod[stat.spirit] + pts * 0.05;
                end
            },
            [319] = {
                apply = function(loadout, effects, pts, missing_pts)
                    for i = 2, 7 do
                        effects.by_school.spell_crit[i] = 
                            effects.by_school.spell_crit[i] + 0.01 * missing_pts;
                    end
                end
            },
            [320] = {
                apply = function(loadout, effects, pts)
                    local hots = spell_names_to_id({"Lifebloom", "Regrowth",  "Wild Growth", "Rejuvenation", "Tranquility"});
                    for k, v in pairs(hots) do
                        ensure_exists_and_add(effects.ability.coef_ot_mod, v, pts * 0.04, 0);
                    end

                    ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Lifebloom"], pts*0.02064, 0);
                end
            },
            [323] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Regrowth", "Rejuvenation", "Lifebloom", "Wild Growth"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts*0.2, 0);
                    end
                end
            },
            [326] = {
                apply = function(loadout, effects, pts)
                    effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * (1.0 + pts * 0.02) - 1.0;
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Lifebloom"], pts * 0.02, 0.0);
                end
            },
        };
    elseif class == "PALADIN" then
        return {
            [103] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Holy Light", "Flash of Light", "Holy Shock"});

                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.04, 0.0);
                    end
                end
            },
            [104] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + pts * 0.02;
                end
            },
            [114] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Holy Light", "Holy Shock"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.crit, v, pts * 0.02, 0);
                    end
                end
            },
            [116] = {
                apply = function(loadout, effects, pts, missing_pts)
                    effects.by_school.spell_crit[magic_school.holy] = 
                        effects.by_school.spell_crit[magic_school.holy] + missing_pts * 0.01;
                end
            },
            [117] = {
                apply = function(loadout, effects, pts)
                    local hl = spell_name_to_id["Holy Light"];
                    ensure_exists_and_add(effects.ability.cast_mod, hl, pts * 0.5 / 3.0, 0);
                end
            },
            [121] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.sp_from_stat_mod[stat.int] = effects.by_attribute.sp_from_stat_mod[stat.int]+ pts * 0.04;
                end
            },
            [201] = {
                apply = function(loadout, effects, pts)
                    effects.raw.spell_heal_mod_mul = effects.raw.spell_heal_mod_mul + pts * 0.01;
                end
            },
            [302] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Holy Shock"], pts * 0.02, 0.0); 
                    ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Sacred Shield"], pts * 0.02, 0.0); 
                end
            },
        };
    elseif class == "SHAMAN" then
        return {
            [101] = {
                apply = function(loadout, effects, pts)
                    local ele_abilities = spell_names_to_id({"Earth Shock", "Frost Shock", "Flame Shock", "Lightning Bolt", "Chain Lightning", "Lava Burst", "Thunderstorm"});
                    for k, v in pairs(ele_abilities) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.02, 0.0);
                    end
                end
            },
            [102] = {
                apply = function(loadout, effects, pts)
                    local ele_abilities = spell_names_to_id({"Earth Shock", "Frost Shock", "Flame Shock", "Lightning Bolt", "Chain Lightning", "Lava Burst", "Thunderstorm"});
                    for k, v in pairs(ele_abilities) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.01, 0.0);
                    end
                end
            },
            [103] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Magma Totem", "Searing Totem", "Fire Nova"})) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.05, 0.0);
                    end
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Lava Burst"], pts * 0.02, 0.0);
                end
            },
            [108] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_crit_mod[magic_school.frost] = 
                        effects.by_school.spell_crit_mod[magic_school.frost] + pts * 0.1;
                    effects.by_school.spell_crit_mod[magic_school.fire] = 
                        effects.by_school.spell_crit_mod[magic_school.fire] + pts * 0.1;
                    effects.by_school.spell_crit_mod[magic_school.nature] = 
                        effects.by_school.spell_crit_mod[magic_school.nature] + pts * 0.1;
                end
            },
            [109] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Fire Nova"], pts * 0.1, 0.0);
                end
            },
            [112] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Lightning Bolt", "Chain Lightning", "Thunderstorm"})) do
                        ensure_exists_and_add(effects.ability.crit, v, 0.05*pts, 0.0);
                    end
                end
            },
            [113] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.raw.mp5_from_int_mod = effects.raw.mp5_from_int_mod + 0.04 * pts;
                end
            },
            [114] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_hit[magic_school.frost] = 
                        effects.by_school.spell_dmg_hit[magic_school.frost] + pts * 0.01;
                    effects.by_school.spell_dmg_hit[magic_school.fire] = 
                        effects.by_school.spell_dmg_hit[magic_school.fire] + pts * 0.01;
                    effects.by_school.spell_dmg_hit[magic_school.nature] = 
                        effects.by_school.spell_dmg_hit[magic_school.nature] + pts * 0.01;
                end
            },
            [115] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Lightning Bolt", "Chain Lightning", "Lava Burst"})) do
                        ensure_exists_and_add(effects.ability.cast_mod, v, pts * 0.1, 0.0);
                    end
                end
            },
            [117] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_ot_mod, spell_name_to_id["Flame Shock"], pts * 0.2, 0.0);
                end
            },
            [118] = {
                apply = function(loadout, effects, pts)
                    local flame_shock = spell_name_to_id["Flame Shock"];
                    ensure_exists_and_add(effects.ability.effect_mod, flame_shock, pts * 0.1, 0.0);
                    ensure_exists_and_add(effects.ability.effect_ot_mod, flame_shock, -pts * 0.1, 0.0);
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Frost Shock"], pts * 0.1, 0.0);
                end
            },
            [123] = {
                apply = function(loadout, effects, pts)
                    if pts ~= 0 then
                        local crit_mod = 0.03*bit.lshift(1, pts);
                        -- 0.06, 0.12 or 0.24
                        ensure_exists_and_add(effects.ability.crit_mod, spell_name_to_id["Lava Burst"], 0.5*crit_mod, 0.0);
                    end
                end
            },
            [124] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Lightning Bolt"], pts * 0.04, 0);
                    ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Chain Lightning"], pts * 0.04, 0);
                    ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Lava Burst"], pts * 0.05, 0);
                end
            },
            [203] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + pts * 0.02;
                end
            },
            [205] = {
                apply = function(loadout, effects, pts, missing_pts)
                    for i = 2,7 do
                        effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.01 * missing_pts;
                    end
                end
            },
            [207] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Lightning Shield"], pts * 0.05, 0.0);
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Earth Shield"], pts * 0.05, 0.0);
                end
            },
            [209] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Earth Shock", "Flame Shock", "Frost Shock"})) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.45, 0.0);
                    end
                end
            },
            [301] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Healing Wave"], pts * 0.1, 0.0);
                end
            },
            [302] = {
                apply = function(loadout, effects, pts)
                    -- TODO: is fire nova not a totem?
                    for k, v in pairs(spell_names_to_id({"Healing Stream Totem", "Magma Totem", "Searing Totem"})) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.05, 0.0);
                    end
                end
            },
            [305] = {
                apply = function(loadout, effects, pts)
                    -- TODO: healing totem included?
                    local healing_spells = spell_names_to_id({"Chain Heal", "Lesser Healing Wave", "Healing Wave", "Riptide", "Earth Shield"});
                    for k, v in pairs(healing_spells) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.01, 0.0);
                    end
                end
            },
            [310] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Healing Stream Totem"], pts * 0.15, 0.0);
                end
            },
            [311] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Lightning Bolt", "Chain Lightning", "Thunderstorm",  "Lesser Healing Wave", "Healing Wave", "Riptide", "Earth Shield", "Chain Heal"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.crit, v, pts * 0.01, 0.0);
                    end
                end
            },
            [312] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Healing Wave"], pts * 0.25/3, 0.0);
                end
            },
            [315] = {
                apply = function(loadout, effects, pts)
                    effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + pts * 0.02;
                end
            },
            [319] = {
                apply = function(loadout, effects, pts, missing_pts)
                    for i = 2,7 do
                        effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + missing_pts * 0.02;
                    end
                end
            },
            [320] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Chain Heal"], pts * 0.1, 0.0);
                end
            },
            [321] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.hp_from_stat_mod[stat.int] = effects.by_attribute.hp_from_stat_mod[stat.int] + pts * 0.05;
                end
            },
            [324] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Earth Shield"], pts * 0.05, 0.0);
                end
            },
            [325] = {
                apply = function(loadout, effects, pts)
                    local sf = spell_name_to_id["Starfire"];
                    local w = spell_name_to_id["Wrath"];
                    ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Healing Wave"], pts * 0.04, 0);
                    ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Lesser Healing Wave"], pts * 0.02, 0);
                end
            },
        };
    elseif class == "MAGE" then
        return {
            -- arcane focus
            [102] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_hit[magic_school.arcane] = 
                        effects.by_school.spell_dmg_hit[magic_school.arcane] + pts * 0.01;

                    for k, v in pairs(spell_names_to_id({"Arcane Blast", "Arcane Missiles", "Arcane Explosion", "Arcane Barrage"})) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.01, 0);
                    end
                end
            },
            -- spell impact
            [108] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Arcane Explosion", "Arcane Blast", "Blast Wave", "Fire Blast", "Scorch", "Fireball", "Ice Lance", "Cone of Cold"})) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.02, 0.0);
                    end
                end
            },
            [109] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    if pts ~= 0 then
                        local val_by_pts = {0.04, 0.07, 0.1};
                        effects.by_attribute.stat_mod[stat.spirit] = 
                            effects.by_attribute.stat_mod[stat.spirit] + val_by_pts[pts];
                    end
                end
            },
            -- arcane meditation
            [113] = {
                apply = function(loadout, effects, pts)
                    effects.raw.regen_while_casting = effects.raw.regen_while_casting + pts * 0.5/3;
                end
            },
            -- arcane mind
            [117] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.stat_mod[stat.int] = 
                        effects.by_attribute.stat_mod[stat.int] + pts*0.03;
                end
            },
            -- arcane instability
            [119] = {
                apply = function(loadout, effects, pts, missing_pts)
                    effects.raw.spell_dmg_mod_mul = 
                        (1.0 + effects.raw.spell_dmg_mod_mul) * (1.0 + pts * 0.01) - 1.0;
                    for i = 2,7 do
                        effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.01 * missing_pts;
                    end
                end
            },
            -- arcane potency
            [120] = {
                apply = function(loadout, effects, pts)
                    -- NOTE: add crit as is expected by clearcast proc chance
                    local expected_extra_crit = loadout.talents_table:pts(1, 6)*0.02*0.15*pts;
                    effects.by_school.spell_crit[magic_school.fire] = 
                        effects.by_school.spell_crit[magic_school.fire] + expected_extra_crit;
                    effects.by_school.spell_crit[magic_school.frost] = 
                        effects.by_school.spell_crit[magic_school.frost] + expected_extra_crit;
                    effects.by_school.spell_crit[magic_school.arcane] = 
                        effects.by_school.spell_crit[magic_school.arcane] + expected_extra_crit;
                end
            },
            -- arcane empowerment
            [121] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.coef_mod,
                                          spell_name_to_id["Arcane Blast"], pts * 0.03, 0.0);
                    ensure_exists_and_add(effects.ability.coef_ot_mod,
                                          spell_name_to_id["Arcane Missiles"], pts * 0.314685314/3, 0.0);
                end
            },
            -- mind mastery
            [125] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.sp_from_stat_mod[stat.int] = effects.by_attribute.sp_from_stat_mod[stat.int]+ pts * 0.03;
                end
            },
            -- netherwind presence
            [128] = {
                apply = function(loadout, effects, pts)
                    effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * (1.0 + pts*0.02) - 1.0;
                end
            },
            [129] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_crit_mod[magic_school.frost] = 
                        effects.by_school.spell_crit_mod[magic_school.frost] + 0.5*pts*0.25;
                    effects.by_school.spell_crit_mod[magic_school.fire] = 
                        effects.by_school.spell_crit_mod[magic_school.fire] + 0.5*pts*0.25;
                    effects.by_school.spell_crit_mod[magic_school.arcane] = 
                        effects.by_school.spell_crit_mod[magic_school.arcane] + 0.5*pts*0.25;
                end
            },
            [202] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Fire Blast", "Scorch", "Arcane Blast", "Cone of Cold"})) do
                        ensure_exists_and_add(effects.ability.crit, v, pts * 0.02, 0.0);
                    end
                end
            },
            [203] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Fireball"], pts * 0.1, 0.0);
                end
            },
            [206] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Flamestrike", "Pyroblast", "Blast Wave", "Dragon's Breath", "Living Bomb", "Blizzard", "Arcane Explosion"})) do
                        ensure_exists_and_add(effects.ability.crit, v, pts * 0.02, 0.0);
                    end
                end
            },
            [211] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Fireball", "Scorch", "Frostfire Bolt"})) do
                        ensure_exists_and_add(effects.ability.crit, v, pts * 0.01, 0.0);
                    end
                end
            },
            [214] = {
                apply = function(loadout, effects, pts)
                    --effects.by_school.spell_dmg_mod[magic_school.fire] = 
                    --    (1.0 + effects.by_school.spell_dmg_mod[magic_school.fire])*(1.0 +  0.01 * pts) - 1.0;
                    --effects.by_school.spell_dmg_mod[magic_school.arcane] = 
                    --    (1.0 + effects.by_school.spell_dmg_mod[magic_school.arcane])*(1.0 +  0.01 * pts) - 1.0;
                    --effects.by_school.spell_dmg_mod[magic_school.frost] = 
                    --    (1.0 + effects.by_school.spell_dmg_mod[magic_school.frost])*(1.0 +  0.01 * pts) - 1.0;
                    effects.raw.spell_dmg_mod_mul = 
                        (1.0 + effects.raw.spell_dmg_mod_mul)*(1.0 +  0.01 * pts) - 1.0;
                end
            },
            [215] = {
                apply = function(loadout, effects, pts, missing_pts)
                    effects.by_school.spell_crit[magic_school.fire] =
                        effects.by_school.spell_crit[magic_school.fire] + 0.02 * missing_pts;
                end
            },
            [218] = {
                apply = function(loadout, effects, pts)
                    --effects.by_school.spell_dmg_mod[magic_school.fire] = 
                    --    (1.0 + effects.by_school.spell_dmg_mod[magic_school.fire])*(1.0 +  0.02 * pts) - 1.0;
                    effects.by_school.spell_dmg_mod[magic_school.fire] = 
                        effects.by_school.spell_dmg_mod[magic_school.fire] + 0.02 * pts;
                end
            },
            [219] = {
                apply = function(loadout, effects, pts, missing_pts)

                    effects.raw.regen_while_casting = effects.raw.regen_while_casting + pts*0.5/3;

                    for i = 2,7 do
                        effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.01 * missing_pts;
                    end
                end
            },
            [223] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Fireball"], pts * 0.05, 0);
                    ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Frostfire Bolt"], pts * 0.05, 0);
                    ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Pyroblast"], pts * 0.05, 0);
                    ensure_exists_and_add(effects.ability.coef_ot_mod, spell_name_to_id["Pyroblast"], pts, 0);
                    -- TODO: refund on ignite, tricky and assumptions must be made
                end
            },
            [227] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_crit_mod[magic_school.frost] = 
                        effects.by_school.spell_crit_mod[magic_school.frost] + 0.05*pts;
                    effects.by_school.spell_crit_mod[magic_school.fire] = 
                        effects.by_school.spell_crit_mod[magic_school.fire] + 0.05*pts;
                    effects.by_school.spell_crit_mod[magic_school.arcane] = 
                        effects.by_school.spell_crit_mod[magic_school.arcane] + 0.05*pts;
                end
            },
            [302] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Frostbolt"], pts * 0.1, 0.0);
                end
            },
            [304] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_crit_mod[magic_school.frost] = 
                        effects.by_school.spell_crit_mod[magic_school.frost] + pts*0.5/3;
                end
            },
            [306] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_hit[magic_school.frost] = 
                        effects.by_school.spell_dmg_hit[magic_school.frost] + pts * 0.01;
                    effects.by_school.spell_dmg_hit[magic_school.arcane] = 
                        effects.by_school.spell_dmg_hit[magic_school.arcane] + pts * 0.01;
                    effects.by_school.spell_dmg_hit[magic_school.fire] = 
                        effects.by_school.spell_dmg_hit[magic_school.fire] + pts * 0.01;
                    effects.raw.cost_mod = effects.raw.cost_mod + pts* 0.01;
                end
            },
            [308] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_mod[magic_school.frost] = 
                        effects.by_school.spell_dmg_mod[magic_school.frost] + 0.02 * pts;
                end
            },
            [312] = {
                apply = function(loadout, effects, pts)
                    if pts ~= 0 then
                        local by_pts = {0.04, 0.07, 0.1};
                        effects.raw.cost_mod = effects.raw.cost_mod + by_pts[pts];
                    end
                end
            },
            [315] = {
                apply = function(loadout, effects, pts)
                    if pts ~= 0 then
                        local by_pts = {0.15, 0.25, 0.35};
                        ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Cone of Cold"], by_pts[pts], 0.0);
                    end
                end
            },
            [318] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Frostbolt"], pts * 0.01, 0.0);
                end
            },
            [321] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_mod[magic_school.frost] = 
                        (1.0 + effects.by_school.spell_dmg_mod[magic_school.frost])*(1.0 + 0.01 * pts) - 1.0;
                end
            },
            [322] = {
                apply = function(loadout, effects, pts)
                    local fb = spell_name_to_id["Frostbolt"];
                    ensure_exists_and_add(effects.ability.cast_mod, fb, pts * 0.1, 0.0);
                    ensure_exists_and_add(effects.ability.coef_mod, fb, pts * 0.05, 0.0);
                end
            },
            [327] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Frostbolt", "Frostfire Bolt", "Ice Lance"})) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.01, 0.0);
                    end
                end
            },
        };

    elseif class == "WARLOCK" then
        return {
            [101] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Curse of Agony"], pts * 0.05, 0.0); 
                end
            },
            [102] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_hit[magic_school.shadow] = 
                        effects.by_school.spell_dmg_hit[magic_school.shadow] + pts * 0.01;
                    effects.by_school.spell_dmg_hit[magic_school.fire] = 
                        effects.by_school.spell_dmg_hit[magic_school.fire] + pts * 0.01;

                    local affl_abilities = spell_names_to_id({"Corruption", "Curse of Agony", "Death Coil", "Drain Life", "Drain Soul", "Curse of Doom", "Unstable Affliction", "Haunt", "Seed of Corruption"});
                    for k, v in pairs(affl_abilities) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.02, 0.0); 
                    end
                end
            },
            [103] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Corruption"], pts * 0.02, 0.0); 
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Seed of Corruption"], pts * 0.01, 0.0); 
                end
            },
            [107] = {
                apply = function(loadout, effects, pts)
                    --TODO: need to track affliction debuffs on target
                end
            },
            [110] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Curse of Agony", "Curse of Doom"})) do
                        ensure_exists_and_add(effects.ability.cast_mod, v, pts*0.5, 0.0); 
                    end
                end
            },
            [113] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.coef_ot_mod, spell_name_to_id["Corruption"], pts*0.1, 0.0); 
                end
            },
            [115] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Seed of Corruption", "Corruption", "Unstable Affliction"})) do
                        ensure_exists_and_add(effects.ability.effect_ot_mod, v, pts*0.05, 0.0); 
                    end
                end
            },
            [118] = {
                apply = function(loadout, effects, pts)
                    -- TODO: multiplicative or additive?
                    effects.by_school.spell_dmg_mod_add[magic_school.shadow] = 
                        effects.by_school.spell_dmg_mod_add[magic_school.shadow] + pts * 0.03;
                end
            },
            [120] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Curse of Agony", "Seed of Corruption", "Corruption"})) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts*0.01, 0.0); 
                    end
                end
            },
            [123] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                        effects.by_school.spell_dmg_mod[magic_school.shadow] + 0.01 * pts;
                    effects.by_school.spell_dmg_mod[magic_school.fire] = 
                        effects.by_school.spell_dmg_mod[magic_school.fire] + 0.01 * pts;
                    for k, v in pairs(spell_names_to_id({"Corruption", "Unstable Affliction"})) do
                        ensure_exists_and_add(effects.ability.crit_ot, v, pts*0.03, 0.0); 
                    end
                end
            },
            [126] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Corruption", "Unstable Affliction", "Haunt"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.crit_mod, v, pts*0.5, 0);
                    end
                end
            },
            [127] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.coef_ot_mod, spell_name_to_id["Unstable Affliction"], pts*0.05, 0.0); 
                    ensure_exists_and_add(effects.ability.coef_ot_mod, spell_name_to_id["Corruption"], pts*0.05, 0.0); 
                end
            },
            [217] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.extra_ticks, spell_name_to_id["Immolate"], pts, 0.0); 
                    -- rest is done in buffs
                end
            },
            [226] = {
                apply = function(loadout, effects, pts)
                    effects.raw.spell_dmg_mod_mul = 
                        (1.0 + effects.raw.spell_dmg_mod_mul) * (1.0 + pts * 0.02) - 1.0;
                end
            },
            [301] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Shadow Bolt"], pts*0.02, 0.0); 
                end
            },
            [302] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Shadow Bolt"], pts*0.1, 0.0); 
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Chaos Bolt"], pts*0.1, 0.0); 
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Immolate"], pts*0.1, 0.0); 
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Soul Fire"], pts*0.4, 0.0); 
                end
            },
            [303] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_ot_mod, spell_name_to_id["Immolate"], pts*0.03, 0.0); 
                end
            },
            [305] = {
                apply = function(loadout, effects, pts)
                    if pts ~= 0 then
                        local destr = spell_names_to_id({"Rain of Fire", "Hellfire", "Shadow Bolt", "Chaos Bolt", "Immolate", "Soul Fire", "Shadowburn", "Shadowfury", "Searing Pain", "Incinerate", "Shadowflame", "Conflagrate"});
                        local by_pts = {0.04, 0.07, 0.1};
                        for k, v in pairs(destr) do
                            ensure_exists_and_add(effects.ability.cost_mod, v, by_pts[pts], 0.0); 
                        end
                    end
                end
            },
            [308] = {
                apply = function(loadout, effects, pts)
                    local destr = spell_names_to_id({"Rain of Fire", "Hellfire", "Shadow Bolt", "Chaos Bolt", "Immolate", "Soul Fire", "Shadowburn", "Shadowfury", "Searing Pain", "Incinerate", "Shadowflame", "Conflagrate"});
                    for k, v in pairs(destr) do
                        ensure_exists_and_add(effects.ability.crit_mod, v, pts * 0.1, 0.0); 
                    end
                end
            },
            [311] = {
                apply = function(loadout, effects, pts)
                    if pts ~= 0 then
                        local by_pts = {0.04, 0.07, 0.1};
                        ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Searing Pain"], by_pts[pts], 0.0); 
                    end
                end
            },
            [312] = {
                apply = function(loadout, effects, pts, missing_pts)
                    for i = 2,7 do
                        effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.01 * missing_pts;
                    end
                end
            },
            [313] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Immolate"], pts*0.1, 0.0); 
                end
            },
            [314] = {
                apply = function(loadout, effects, pts)
                    local destr = spell_names_to_id({"Rain of Fire", "Hellfire", "Shadow Bolt", "Chaos Bolt", "Immolate", "Soul Fire", "Shadowburn", "Shadowfury", "Searing Pain", "Incinerate", "Shadowflame", "Conflagrate"});
                    for k, v in pairs(destr) do
                        ensure_exists_and_add(effects.ability.crit, v, pts*0.05, 0.0); 
                    end
                end
            },
            [316] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Incinerate"], pts * 0.05, 0.0); 
                    effects.by_school.spell_dmg_mod_add[magic_school.fire] = 
                        effects.by_school.spell_dmg_mod_add[magic_school.fire] + 0.03 * pts;
                end
            },
            [320] = {
                apply = function(loadout, effects, pts)
                    -- Note: This mod is multiplied, not added for some reason... Inconsistenty keeps on giving
                    for k, v in pairs(spell_names_to_id({"Shadow Bolt", "Shadowburn", "Chaos Bolt", "Incinerate"})) do
                        --ensure_exists_and_add(effects.ability.coef_mod, v, pts * 0.04, 0.0); 
                        ensure_exists_and_add(effects.ability.coef_mod, v, pts*spells[v].coef*0.04, 0.0); 
                    end
                end
            },
            [325] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Conflagrate"], pts * 0.05, 0.0); 
                end
            },
        };
    else
        return {};
    end
end

local talents = create_talents();

local glyphs = create_glyphs();
local wowhead_glyph_code_to_id = {};
-- reverse mapping from wowhead 3 char code to glyph spell id
for k, v in pairs(glyphs) do
    wowhead_glyph_code_to_id[v.wowhead_id] = k; 
end

local function wowhead_talent_link(code)
    local lowercase_class = string.lower(class);
    return "https://classic.wowhead.com/wotlk/talent-calc/"..lowercase_class.."/"..code;
end

local function wowhead_talent_code_from_url(link)

    local last_slash_index = 1;
    local i = 1;

    while link:sub(i, i) ~= "" do
        if link:sub(i, i) == "/" then
            last_slash_index = i;
        end
        i = i + 1;
    end
    return link:sub(last_slash_index + 1, i);
end

local function wowhead_talent_code()

    local talent_code = {};

    
    local sub_codes = {"", "", ""};
    for i = 1, 3 do

        local talent_table = {};
        for row = 1, 11 do
            talent_table[row] = {}
        end
        -- NOTE: GetNumTalents(i) will return 0 on early calls after logging in,
        --       but works fine after reload
        for j = 1, GetNumTalents(i) do
            -- talent indices are not in left-right, top-to-bottom order
            -- but rather seemingly random...


            local _, _, row, column, pts, _, _, _ = GetTalentInfo(i, j);
            talent_table[row][column] = pts;
        end

        local found_max = false;
        for r = 1, 11 do
            row = 11 - r + 1
            for c = 1, 4 do
                column = 4 - c + 1;

                local pts = talent_table[row][column];
                if pts then
                    if pts ~= 0 then
                        found_max = true;
                    end
                    if found_max then
                        
                        sub_codes[i] = tostring(pts)..sub_codes[i];
                    end
                end
            end
        end
    end
    if sub_codes[2] == "" and sub_codes[3] == "" then
        talent_code =  sub_codes[1];
    elseif sub_codes[2] == "" then
        talent_code =  sub_codes[1].."--"..sub_codes[3];
    elseif sub_codes[3] == "" then
        talent_code =  sub_codes[1].."-"..sub_codes[2];
    else
        talent_code = sub_codes[1].."-"..sub_codes[2].."-"..sub_codes[3];
    end

    local glyphs_code = "";

    local primary_glyph_prefixes = {"001", "11", "21"};
    local special_prefixes = {"002", "12", "22"};
    local j = 1;
    for i = 1, GetNumGlyphSockets() do
        local _, quality, id, _ = GetGlyphSocketInfo(i);
        if id and glyphs[id] then
            if glyphs[id].special then
                glyphs_code = glyphs_code..special_prefixes[j]..glyphs[id].wowhead_id;
            else
                glyphs_code = glyphs_code..primary_glyph_prefixes[j]..glyphs[id].wowhead_id;
            end
            j = j + 1;
        end
    end

    return talent_code.."_"..glyphs_code;
end

local function talent_glyphs_table(wowhead_code)

    local talents = {{}, {}, {}};

    local i = 1;
    local tree_index = 1;
    local talent_index = 1;

    while wowhead_code:sub(i, i) ~= ""  and wowhead_code:sub(i, i) ~= "_" do
        if wowhead_code:sub(i, i) == "-" then
            tree_index = tree_index + 1;
            talent_index = 1;
        elseif tonumber(wowhead_code:sub(i, i)) then
            talents[tree_index][talent_index] = tonumber(wowhead_code:sub(i, i));
            talent_index = talent_index + 1;
        end
        i = i + 1;
    end

    talents.pts = function(this, tree_index, talent_index)
        if this[tree_index][talent_index] then
            return this[tree_index][talent_index];
        else
            return 0;
        end
    end;

    local glyphs_table = {};
    while wowhead_code:sub(i, i) ~= "" do

        if string.match(wowhead_code:sub(i, i), "[3-9a-z]") ~= nil then
            local glyph_code = wowhead_code:sub(i, i + 2);
            local glyph_id = wowhead_glyph_code_to_id[glyph_code];
            if glyph_id then
                glyphs_table[glyph_id] = glyphs[glyph_id];
            end
            i = i + 3;
        else
            i = i + 1;
        end
    end

    return talents, glyphs_table;
end

local function apply_talents_glyphs(loadout, effects)

    local dynamic_talents, dynamic_glyphs = talent_glyphs_table(loadout.talents_code);
    local custom_talents, custom_glyphs = nil, nil;

    if bit.band(loadout.flags, addonTable.loadout_flags.is_dynamic_loadout) ~= 0 then
        loadout.talents_table = dynamic_talents;
        loadout.glyphs = dynamic_glyphs;
    else
        custom_talents, custom_glyphs = talent_glyphs_table(loadout.custom_talents_code);
        loadout.talents_table = custom_talents;
        loadout.glyphs = custom_glyphs;
    end

    for k, v in pairs(loadout.glyphs) do
        if v.apply then
            v.apply(loadout, effects);
        end
    end

    if bit.band(loadout.flags, addonTable.loadout_flags.is_dynamic_loadout) ~= 0 then
        for i = 1, 3 do
            for j = 1, 29 do
                local id = i*100 + j;
                if talents[id] then
                    talents[id].apply(loadout, effects, loadout.talents_table:pts(i, j), 0);
                end

            end
        end
    else
        for i = 1, 3 do
            for j = 1, 29 do
                local id = i*100 + j;
                if talents[id] then
                    local custom_pts = custom_talents:pts(i, j);
                    local active_pts = dynamic_talents:pts(i, j);
                    talents[id].apply(loadout, effects, custom_pts, custom_pts - active_pts);
                end
            end
        end
    end
end

addonTable.glyphs = glyphs;
addonTable.wowhead_talent_link = wowhead_talent_link
addonTable.wowhead_talent_code_from_url = wowhead_talent_code_from_url;
addonTable.wowhead_talent_code = wowhead_talent_code;
addonTable.talent_glyphs_table = talent_glyphs_table;
addonTable.apply_talents_glyphs = apply_talents_glyphs;

