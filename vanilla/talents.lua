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

local ensure_exists_and_add         = swc.utils.ensure_exists_and_add;
local ensure_exists_and_mul         = swc.utils.ensure_exists_and_mul;
local class                         = swc.utils.class;
local race                          = swc.utils.race;
local stat                          = swc.utils.stat;

local magic_school                  = swc.abilities.magic_school;
local spell_name_to_id              = swc.abilities.spell_name_to_id;
local spell_names_to_id             = swc.abilities.spell_names_to_id;
local spells                        = swc.abilities.spells;
-------------------------------------------------------------------------------
local talents_export = {};

local rune_ids = {
    --priest
    serendipity                     = 6932,
    strength_of_soul                = 6936,
    twisted_faith                   = 7024,
    void_plague                     = 7025,
    circle_of_healing               = 6750,
    mind_sear                       = 6934,
    penance                         = 6752,
    shadow_word_death               = 6741,
    homunculi                       = 6744,
    power_word_barrier              = 7023,
    prayer_of_mending               = 6740,
    shared_pain                     = 6746,
    --druid
    fury_of_the_stormrage           = 6872,
    living_seed                     = 6975,
    survival_of_the_fittest         = 6972,
    wild_strikes                    = 6858,
    lacerate                        = 6973,
    mangle                          = 6868,
    sunfire                         = 6976,
    wild_growth                     = 6860,
    lifebloom                       = 6865,
    savage_roar                     = 6863,
    skull_bash                      = 6971,
    starsurge                       = 7011,
    --paladin
    aegis                           = 7041,
    divine_storm                    = 6850,
    horn_of_lordaeron               = 7040,
    seal_of_martyrdom               = 6851,
    beacon_of_light                 = 6843,
    crusader_strike                 = 6845,
    hand_of_reckoning               = 6844,
    avengers_shield                 = 6854,
    divine_sacrifice                = 6856,
    exorcist                        = 6965,
    inspiration_exemplar            = 6857,
    rebuke                          = 7042,
    --shaman
    dual_wield_specialization       = 6874,
    healing_rain                    = 6984,
    overload                        = 6878,
    shield_mastery                  = 6876,
    lava_burst                      = 6883,
    lava_lash                       = 6884,
    molten_blast                    = 7031,
    water_shield                    = 6875,
    ancestral_guidance              = 6877,
    earth_shield                    = 6880,
    shamanistic_rage                = 7030,
    way_of_earth                    = 6886,
    --mage
    burnout                         = 6729,
    enlightment                     = 6922,
    fingers_of_frost                = 6735,
    regeneration                    = 6736,
    arcane_blast                    = 6728,
    ice_lance                       = 6730,
    living_bomb                     = 6923,
    rewind_time                     = 6731,
    arcane_surge                    = 7021,
    icy_veins                       = 7020,
    living_flame                    = 6737,
    mass_regeneration               = 6927,
    --warlock
    demonic_tactics                 = 6952,
    lake_of_fire                    = 6815,
    master_channeler                = 6811,
    soul_siphon                     = 6808,
    chaos_bolt                      = 6805,
    haunt                           = 6803,
    metamorphosis                   = 6816,
    shadow_bolt_volley              = 6814,
    demonic_grace                   = 7039,
    demonic_pact                    = 7038,
    everlasting_affliction          = 6950,
    incinerate                      = 6955,
};    

-- maps rune engraving enchant id to effect and wowhead's encoding
local function create_runes()
    if class == "PRIEST" then
        return {
            [rune_ids.serendipity       ] = { wowhead_id = "56rm"},
            [rune_ids.strength_of_soul  ] = { wowhead_id = "56rr"},
            [rune_ids.twisted_faith     ] = { wowhead_id = "56vg"},
            [rune_ids.void_plague       ] = { wowhead_id = "56vh"},
            [rune_ids.circle_of_healing ] = { wowhead_id = "a6jy"},
            [rune_ids.mind_sear         ] = { wowhead_id = "a6rp"},
            [rune_ids.penance           ] = { wowhead_id = "a6k0"},
            [rune_ids.shadow_word_death ] = { wowhead_id = "a6jn"},
            [rune_ids.homunculi         ] = { wowhead_id = "76jr"},
            [rune_ids.power_word_barrier] = { wowhead_id = "76vf"},
            [rune_ids.prayer_of_mending ] = { wowhead_id = "76jm"},
            [rune_ids.shared_pain       ] = { wowhead_id = "76jt"},
        };
    elseif class == "DRUID" then
        return {
            [rune_ids.fury_of_the_stormrage  ] = { wowhead_id = "56pr"},
            [rune_ids.living_seed            ] = { wowhead_id = "56sz"},
            [rune_ids.survival_of_the_fittest] = { wowhead_id = "56sw"},
            [rune_ids.wild_strikes           ] = { wowhead_id = "56pa"},
            [rune_ids.lacerate               ] = { wowhead_id = "a6sx"},
            [rune_ids.mangle                 ] = { wowhead_id = "a6pm"},
            [rune_ids.sunfire                ] = { wowhead_id = "a6t0"},
            [rune_ids.wild_growth            ] = { wowhead_id = "a6pc"},
            [rune_ids.lifebloom] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Rejuvenation"], 0.5, 0.0);
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Lifebloom"], 0.5, 0.0);
                end,
                wowhead_id = "76ph"
            },
            [rune_ids.savage_roar            ] = { wowhead_id = "76pf"},
            [rune_ids.skull_bash             ] = { wowhead_id = "76sv"},
            [rune_ids.starsurge              ] = { wowhead_id = "76v3"},

        };
    elseif class == "PALADIN" then
        return {

            [rune_ids.aegis               ] = { wowhead_id = "56w1"},
            [rune_ids.divine_storm        ] = { wowhead_id = "56p2"},
            [rune_ids.horn_of_lordaeron   ] = { wowhead_id = "56w0"},
            [rune_ids.seal_of_martyrdom   ] = { wowhead_id = "56p3"},
            [rune_ids.beacon_of_light     ] = { wowhead_id = "a6nv"},
            [rune_ids.crusader_strike     ] = { wowhead_id = "a6nx"},
            [rune_ids.hand_of_reckoning   ] = { wowhead_id = "a6nw"},
            [rune_ids.avengers_shield     ] = { wowhead_id = "76p6"},
            [rune_ids.rebuke              ] = { wowhead_id = "76p8"},
            [rune_ids.exorcist            ] = { wowhead_id = "76sn"},
            [rune_ids.inspiration_exemplar] = { wowhead_id = "76p9"},
            [rune_ids.divine_sacrifice    ] = { wowhead_id = "76w2"},
        };
    elseif class == "SHAMAN" then
        return {
            [rune_ids.dual_wield_specialization] = { wowhead_id = "56pt"},
            [rune_ids.healing_rain             ] = { wowhead_id = "56t8"},
            [rune_ids.overload                 ] = { wowhead_id = "56py"},
            [rune_ids.shield_mastery           ] = { wowhead_id = "56pw"},
            [rune_ids.lava_burst               ] = { wowhead_id = "a6q3"},
            [rune_ids.lava_lash                ] = { wowhead_id = "a6q4"},
            [rune_ids.molten_blast             ] = { wowhead_id = "a6vq"},
            [rune_ids.water_shield             ] = { wowhead_id = "a6pv"},
            [rune_ids.ancestral_guidance       ] = { wowhead_id = "76px"},
            [rune_ids.earth_shield             ] = { wowhead_id = "76q0"},
            [rune_ids.shamanistic_rage         ] = { wowhead_id = "76vp"},
            [rune_ids.way_of_earth             ] = { wowhead_id = "76q6"},
        };
    elseif class == "MAGE" then
        return {
            [rune_ids.burnout] = {
                apply = function(loadout, effects, inactive)
                    -- 15% spell crit but 1% more base mana cost on crit
                    if inactive then
                        for i = 2, 7 do
                            effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.15;
                        end
                    end
                end,
                wowhead_id = "56j9"
            },
            [rune_ids.enlightment      ] = { wowhead_id = "56ra"},
            [rune_ids.fingers_of_frost ] = { wowhead_id = "56jf"},
            [rune_ids.regeneration     ] = { wowhead_id = "56jg"},
            [rune_ids.arcane_blast     ] = { wowhead_id = "a6j8"},
            [rune_ids.ice_lance        ] = { wowhead_id = "a6ja"},
            [rune_ids.living_bomb      ] = { wowhead_id = "a6rb"},
            [rune_ids.rewind_time      ] = { wowhead_id = "a6jb"},
            [rune_ids.arcane_surge     ] = { wowhead_id = "76vd"},
            [rune_ids.icy_veins        ] = { wowhead_id = "76vc"},
            [rune_ids.living_flame     ] = { wowhead_id = "76jh"},
            [rune_ids.mass_regeneration] = { wowhead_id = "76rf"},
        };

    elseif class == "WARLOCK" then
        return {
            [rune_ids.demonic_tactics       ] = {
                apply = function(loadout, effects, inactive)
                    if inactive then
                        for i = 2, 7 do
                            effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.1;
                        end
                    end
                end,
                wowhead_id = "56s8",
            },
            [rune_ids.lake_of_fire          ] = { wowhead_id = "56mz"},
            [rune_ids.master_channeler      ] = { wowhead_id = "56mv"},
            [rune_ids.soul_siphon           ] = { wowhead_id = "56mr"},
            [rune_ids.chaos_bolt            ] = { wowhead_id = "a6mn"},
            [rune_ids.haunt                 ] = { wowhead_id = "a6mk"},
            [rune_ids.metamorphosis         ] = { wowhead_id = "a6n0"},
            [rune_ids.shadow_bolt_volley    ] = { wowhead_id = "a6my"},
            [rune_ids.demonic_grace         ] = { wowhead_id = "76vz"},
            [rune_ids.demonic_pact          ] = { wowhead_id = "76vy"},
            [rune_ids.everlasting_affliction] = { wowhead_id = "76s6"},
            [rune_ids.incinerate            ] = { wowhead_id = "76sb"},
        };
    else
        return {};
    end
end

local function create_talents()
    if class == "PRIEST" then
        return {
            -- improved power word shield
            [105] = {
                apply = function(loadout, effects, pts)

                    ensure_exists_and_add(effects.ability.effect_mod_base, spell_name_to_id["Power Word: Shield"], pts * 0.05, 0.0);
                end
            },
            [108] = {
                apply = function(loadout, effects, pts)
                    effects.raw.regen_while_casting = effects.raw.regen_while_casting + pts * 0.05;
                end
            },
            [110] = {
                apply = function(loadout, effects, pts)
                    -- TODO VANILLA there's more racial priest spells
                    local instants = spell_names_to_id({"Renew", "Holy Nova", "Devouring Plague", "Shadow Word: Pain", "Mind Flay", "Desperate Prayer", "Touch of Weakness", "Circle of Healing", "Prayer of Mending", "Shadow Word: Death", "Void Plague", "Shadowguard", "Power Word: Shield"});
                    for k, v in pairs(instants) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.02, 0.0);
                    end
                end
            },
            [111] = {
                apply = function(loadout, effects, pts)
                    
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Mana Burn"], pts * 0.25, 0.0);
                end
            },
            [112] = {
                apply = function(loadout, effects, pts)
                    
                    effects.raw.mana_mod = effects.raw.mana_mod + pts * 0.02;
                end
            },
            [114] = {
                apply = function(loadout, effects, pts)
                    
                    -- TODO VANILLA: mana burn
                    -- TODO VANILLA: make separate spell dmg mod for hybrids like holy nova
                    local offensives = spell_names_to_id({"Smite", "Mind Blast", "Holy Fire", "Holy Nova", "Shadow Word: Pain", "Mind Flay", "Starshards"});
                    for k, v in pairs(offensives) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.01, 0.0);
                        ensure_exists_and_add(effects.ability.crit, v, pts * 0.01, 0.0);
                    end
                end
            },
            [116] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_mod_add[magic_school.holy] =
                        effects.by_school.spell_dmg_mod_add[magic_school.holy] + pts * 0.01;
                    effects.by_school.spell_dmg_mod_add[magic_school.shadow] =
                        effects.by_school.spell_dmg_mod_add[magic_school.shadow] + pts * 0.01;
                    effects.by_school.spell_dmg_mod_add[magic_school.arcane] =
                        effects.by_school.spell_dmg_mod_add[magic_school.arcane] + pts * 0.01;
                    -- TODO VANILLA: %crit per point, unclear if on ability bases or on holy and shadow spells
                end
            },
            [202] = {
                apply = function(loadout, effects, pts)
                    local renew = spell_name_to_id["Renew"];
                    ensure_exists_and_add(effects.ability.effect_mod_base, renew, pts * 0.05, 0.0); 
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
                        spell_names_to_id({"Lesser Heal", "Heal", "Greater Heal"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.05, 0);
                    end
                end
            },
            [211] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Smite", "Holy Fire"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.effect_mod_base, v, pts * 0.05, 0.0);
                    end
                end
            },
            [212] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Prayer of Healing"], pts * 0.1, 0);
                end
            },
            [214] = {
                apply = function(loadout, effects, pts)
                    effects.by_attribute.sp_from_stat_mod[stat.spirit] = effects.by_attribute.sp_from_stat_mod[stat.spirit] + pts * 0.05;
                    effects.by_attribute.hp_from_stat_mod[stat.spirit] = effects.by_attribute.hp_from_stat_mod[stat.spirit] + pts * 0.05;
                end
            },
            [215] = {
                apply = function(loadout, effects, pts)
                    effects.raw.spell_heal_mod_base = effects.raw.spell_heal_mod_base + pts * 0.02;
                end
            },
            [304] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.extra_ticks, spell_name_to_id["Shadow Word: Pain"], pts, 0.0);
                end
            },
            [305] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_hit[magic_school.shadow] = 
                        effects.by_school.spell_dmg_hit[magic_school.shadow] + pts * 0.02;

                end
            },
            [315] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_mod_add[magic_school.shadow] = 
                        effects.by_school.spell_dmg_mod_add[magic_school.shadow] + 0.02 * pts;
                end
            },
        };
    elseif class == "DRUID" then
        return {
            [101] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Wrath"], pts * 0.1, 0);
                end
            },
            [105] = {
                apply = function(loadout, effects, pts)
                    local mf = spell_name_to_id["Moonfire"];
                    ensure_exists_and_add(effects.ability.crit, mf, pts * 0.02, 0);
                    ensure_exists_and_add(effects.ability.effect_mod_base, mf, pts * 0.02, 0.0);
                    local sf = spell_name_to_id["Sunfire"];
                    ensure_exists_and_add(effects.ability.crit, sf, pts * 0.02, 0);
                    ensure_exists_and_add(effects.ability.effect_mod_base, sf, pts * 0.02, 0.0);
                end
            },
            [111] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Starfire", "Moonfire", "Wrath", "Starsurge", "Sunfire"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.crit_mod, v, pts * 0.1, 0);
                    end
                end
            },
            [112] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Starfire"], pts * 0.1, 0);
                end
            },
            [114] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Moonfire", "Starfire", "Wrath", "Healing Touch", "Regrowth", "Rejuvenation", "Starsurge"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.03, 0);
                    end
                end
            },
            [115] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Starfire", "Moonfire", "Wrath", "Starsurge", "Sunfire"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.effect_mod_base, v, pts * 0.02, 0.0);
                    end
                end
            },
            [215] = {
                apply = function(loadout, effects, pts)
                    -- dynamic fix
                    effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + pts * 0.04;
                end
            },
            [303] = {
                apply = function(loadout, effects, pts)
                    local ht = spell_name_to_id["Healing Touch"];
                    ensure_exists_and_add(effects.ability.cast_mod, ht, pts * 0.1, 0);
                end
            },
            [306] = {
                apply = function(loadout, effects, pts)
                    if pts ~= 0 then
                        effects.raw.regen_while_casting = effects.raw.regen_while_casting + pts * 0.05;
                    end
                end
            },
            [309] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Healing Touch", "Tranquility"});
                    
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.02, 0);
                    end
                end
            },
            [310] = {
                apply = function(loadout, effects, pts)
                    local rejuv = spell_name_to_id["Rejuvenation"];
                    ensure_exists_and_add(effects.ability.effect_mod_base, rejuv, pts * 0.05, 0.0);
                end
            },
            [312] = {
                apply = function(loadout, effects, pts)
                    effects.raw.spell_heal_mod_base = effects.raw.spell_heal_mod_base + pts * 0.02;
                end
            },
            [314] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Regrowth"], pts * 0.1, 0);
                end
            },
        };
    elseif class == "PALADIN" then
        return {
            [102] = {
                apply = function(loadout, effects, pts)
                    effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + pts * 0.02;
                end
            },
            [105] = {
                apply = function(loadout, effects, pts)
                    local abilities = spell_names_to_id({"Holy Light", "Flash of Light"});

                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.effect_mod_base, v, pts * 0.04, 0.0);
                    end
                end
            },
            -- TODO VANILLA: Pom improvement in buffs
            [113] = {
                apply = function(loadout, effects, pts, missing_pts)
                    effects.by_school.spell_crit[magic_school.holy] = 
                        effects.by_school.spell_crit[magic_school.holy] + missing_pts * 0.01;
                end
            },
        };
    elseif class == "SHAMAN" then
        return {
            [101] = {
                apply = function(loadout, effects, pts)
                    local ele_abilities = spell_names_to_id({"Earth Shock", "Frost Shock", "Flame Shock", "Lightning Bolt", "Chain Lightning"});
                    for k, v in pairs(ele_abilities) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.02, 0.0);
                    end
                end
            },
            [102] = {
                apply = function(loadout, effects, pts)
                    local ele_abilities = spell_names_to_id({"Earth Shock", "Frost Shock", "Flame Shock", "Lightning Bolt", "Chain Lightning"});
                    for k, v in pairs(ele_abilities) do
                        ensure_exists_and_add(effects.ability.effect_mod_base, v, pts * 0.01, 0.0);
                    end
                end
            },
            [105] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Magma Totem", "Searing Totem", "Fire Nova Totem"})) do
                        ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.05, 0.0);
                    end
                end
            },
            [108] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Lightning Bolt", "Chain Lightning"})) do
                        ensure_exists_and_add(effects.ability.crit, v, 0.01*pts, 0.0);
                    end
                end
            },
            [113] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_crit_mod[magic_school.frost] = 
                        effects.by_school.spell_crit_mod[magic_school.frost] + pts*0.5;
                    effects.by_school.spell_crit_mod[magic_school.fire] = 
                        effects.by_school.spell_crit_mod[magic_school.fire] + pts*0.5;
                    effects.by_school.spell_crit_mod[magic_school.nature] = 
                        effects.by_school.spell_crit_mod[magic_school.nature] + pts*0.5;
                end
            },
            [114] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Lightning Bolt", "Chain Lightning"})) do
                        ensure_exists_and_add(effects.ability.cast_mod, v, pts * 0.2, 0.0);
                    end
                end
            },
            [201] = {
                apply = function(loadout, effects, pts)
                    effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + pts * 0.01;
                end
            },
            [206] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod_base, spell_name_to_id["Lightning Shield"], pts * 0.05, 0.0);
                end
            },
            [301] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Healing Wave"], pts * 0.1, 0.0);
                end
            },
            [302] = {
                apply = function(loadout, effects, pts)

                    -- TODO VANILLA: is healing stream totem here??
                    local healing_spells = spell_names_to_id({"Chain Heal", "Lesser Healing Wave", "Healing Wave", "Healing Rain"});
                    for k, v in pairs(healing_spells) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.01, 0.0);
                    end
                end
            },
            [305] = {
                apply = function(loadout, effects, pts)
                    -- TODO VANILLA : is fire nova a totem?
                    for k, v in pairs(spell_names_to_id({"Healing Stream Totem", "Magma Totem", "Searing Totem"})) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.05, 0.0);
                    end
                end
            },
            [306] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_hit[magic_school.frost] = 
                        effects.by_school.spell_dmg_hit[magic_school.frost] + pts * 0.01;
                    effects.by_school.spell_dmg_hit[magic_school.fire] = 
                        effects.by_school.spell_dmg_hit[magic_school.fire] + pts * 0.01;
                    effects.by_school.spell_dmg_hit[magic_school.nature] = 
                        effects.by_school.spell_dmg_hit[magic_school.nature] + pts * 0.01;
                end
            },
            [310] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod_base, spell_name_to_id["Healing Stream Totem"], pts * 0.05, 0.0);
                end
            },
            [311] = {
                apply = function(loadout, effects, pts, missing_pts)
                    for i = 2,7 do
                        effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + missing_pts * 0.02;
                    end
                end
            },
            -- TODO VANILLA: healing way talent 
            [314] = {
                apply = function(loadout, effects, pts)
                    effects.raw.spell_heal_mod_base = effects.raw.spell_heal_mod_base + pts * 0.02;
                end
            },
        };
    elseif class == "MAGE" then
        return {
            [101] = {
                apply = function(loadout, effects, pts)

                    for i = 2, 7 do
                        effects.by_school.target_res[i] = 
                            effects.by_school.target_res[i] + pts * 5;
                    end
                end
            },
            [102] = {
                apply = function(loadout, effects, pts)

                    effects.by_school.spell_dmg_hit[magic_school.arcane] = 
                        effects.by_school.spell_dmg_hit[magic_school.arcane] + pts * 0.02;
                end
            },
            [108] = {
                apply = function(loadout, effects, pts)

                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Arcane Explosion"], pts * 0.02, 0);
                end
            },
            [112] = {
                apply = function(loadout, effects, pts)
                    effects.raw.regen_while_casting = effects.raw.regen_while_casting + pts * 0.05;
                end
            },
            [114] = {
                apply = function(loadout, effects, pts)
                    effects.raw.mana_mod = 
                        effects.raw.mana_mod + pts*0.02;
                end
            },
            [115] = {
                apply = function(loadout, effects, pts, missing_pts)

                    effects.by_school.spell_dmg_mod_add[magic_school.fire] = 
                        effects.by_school.spell_dmg_mod_add[magic_school.fire] + pts*0.01;
                    effects.by_school.spell_dmg_mod_add[magic_school.arcane] = 
                        effects.by_school.spell_dmg_mod_add[magic_school.arcane] + pts*0.01;
                    effects.by_school.spell_dmg_mod_add[magic_school.frost] = 
                        effects.by_school.spell_dmg_mod_add[magic_school.frost] + pts*0.01;

                    for i = 2,7 do
                        effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.01 * missing_pts;
                    end
                end
            },
            [201] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Fireball"], pts * 0.1, 0.0);
                end
            },
            [206] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs(spell_names_to_id({"Fire Blast", "Scorch"})) do
                        ensure_exists_and_add(effects.ability.crit, v, pts * 0.02, 0.0);
                    end
                end
            },
            [207] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Flamestrike"], pts * 0.05, 0.0);
                end
            },
            [213] = {
                apply = function(loadout, effects, pts, missing_pts)
                    effects.by_school.spell_crit[magic_school.fire] =
                        effects.by_school.spell_crit[magic_school.fire] + 0.02 * missing_pts;
                end
            },
            [215] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_mod_add[magic_school.fire] = 
                        effects.by_school.spell_dmg_mod_add[magic_school.fire] + 0.02 * pts;
                end
            },
            [302] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Frostbolt"], pts * 0.1, 0.0);
                end
            },
            [303] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_hit[magic_school.frost] = 
                        effects.by_school.spell_dmg_hit[magic_school.frost] + pts * 0.02;
                    effects.by_school.spell_dmg_hit[magic_school.fire] = 
                        effects.by_school.spell_dmg_hit[magic_school.fire] + pts * 0.02;
                end
            },
            [304] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_crit_mod[magic_school.frost] = 
                        effects.by_school.spell_crit_mod[magic_school.frost] + pts*0.5/3;
                end
            },
            [308] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_mod_add[magic_school.frost] = 
                        effects.by_school.spell_dmg_mod_add[magic_school.frost] + 0.02 * pts;
                end
            },
            [312] = {
                apply = function(loadout, effects, pts)
                    local frost_spells = spell_names_to_id({"Frostbolt", "Frost Nova", "Blizzard", "Cone of Cold", "Ice Barrier", "Ice Ward", "Ice Lance"});
                    for k, v in pairs(frost_spells) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.05, 0.0);
                    end
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Frostbolt"], pts * 0.01, 0.0);
                end
            },
            [313] = {
                apply = function(loadout, effects, pts)
                    --TODO VANILLA
                end
            },
            [315] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod_base, spell_name_to_id["Cone of Cold"], pts * 0.15, 0.0);
                end
            },
        };

    elseif class == "WARLOCK" then
        return {
            [101] = {
                apply = function(loadout, effects, pts)

                    local affl_abilities = spell_names_to_id({"Corruption", "Curse of Agony", "Death Coil", "Drain Life", "Drain Soul", "Curse of Doom", "Siphon Life", "Haunt"});
                    for k, v in pairs(affl_abilities) do
                        ensure_exists_and_add(effects.ability.hit, v, pts * 0.02, 0.0); 
                    end
                end
            },
            [102] = {
                apply = function(loadout, effects, pts)
                    -- TODO VANILLA: is this capped at 1.0 or 1.5 effectively?
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Corruption"], pts * 0.4, 0.0); 
                end
            },
            [105] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Life Tap"], pts * 0.1, 0.0); 
                end
            },
            [106] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod_base, spell_name_to_id["Drain Life"], pts * 0.02, 0.0); 
                end
            },
            [107] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod_base, spell_name_to_id["Curse of Agony"], pts*0.02, 0.0); 
                end
            },
            [116] = {
                -- TODO: some spells treated differently than others
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_mod_add[magic_school.shadow] = 
                        effects.by_school.spell_dmg_mod_add[magic_school.shadow] + 0.02 * pts;
                end
            },
            [203] = {
                apply = function(loadout, effects, pts)
                    effects.by_attribute.stat_mod[stat.spirit] = effects.by_attribute.stat_mod[stat.spirit] - pts * 0.01;
                end
            },
            [204] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod_base, spell_name_to_id["Health Funnel"], pts*0.1, 0.0); 
                end
            },
            -- TODO VANILLA: demo pet stuff demonic sacrifice talent and master demonologist
            -- TODO VANILLA: improved shadow bolt estimate thingy
            [302] = {
                apply = function(loadout, effects, pts)
                    local destr = spell_names_to_id({"Rain of Fire", "Hellfire", "Shadow Bolt", "Immolate", "Soul Fire", "Shadowburn", "Searing Pain", "Conflagrate", "Shadow Cleave", "Chaos Bolt", "Incinerate"});
                    for k, v in pairs(destr) do
                        ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.01, 0.0); 
                    end
                end
            },
            [303] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Shadow Bolt"], pts*0.1, 0.0); 
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Immolate"], pts*0.1, 0.0); 
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Soul Fire"], pts*0.4, 0.0); 
                end
            },
            [307] = {
                apply = function(loadout, effects, pts)
                    local destr = spell_names_to_id({"Shadow Bolt", "Immolate", "Soul Fire", "Shadowburn", "Searing Pain", "Conflagrate", "Shadow Cleave", "Chaos Bolt", "Incinerate"});
                    for k, v in pairs(destr) do
                        ensure_exists_and_add(effects.ability.crit, v, pts * 0.01, 0.0); 
                    end
                end
            },
            [311] = {
                apply = function(loadout, effects, pts)
                    if pts ~= 0 then
                        ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Searing Pain"], pts * 0.02, 0.0); 
                    end
                end
            },
            [313] = {
                apply = function(loadout, effects, pts)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Immolate"], pts*0.05, 0.0); 
                    ensure_exists_and_add(effects.ability.effect_ot_mod, spell_name_to_id["Immolate"], -pts*0.05, 0.0); 
                end
            },
            [314] = {
                apply = function(loadout, effects, pts)
                    local destr = spell_names_to_id({"Shadow Bolt", "Immolate", "Soul Fire", "Shadowburn", "Searing Pain", "Conflagrate", "Shadow Cleave", "Chaos Bolt", "Incinerate"});
                    for k, v in pairs(destr) do
                        ensure_exists_and_add(effects.ability.crit_mod, v, pts*0.5, 0.0); 
                    end
                end
            },
            [315] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_mod_add[magic_school.fire] = 
                        effects.by_school.spell_dmg_mod_add[magic_school.fire] + 0.02 * pts;
                end
            },
        };
    else
        return {};
    end
end

local talents = create_talents();
local runes = create_runes();
local wowhead_rune_code_to_id = {};
-- reverse mapping from wowhead 3 char code to rune spell id
for k, v in pairs(runes) do
    wowhead_rune_code_to_id[v.wowhead_id] = k; 
end

local function engraving_runes_id()
    local ids = {};
    -- NOTE: order might be important here
    local item_slots = {5, 10, 7};
    for k, v in pairs(item_slots) do
        local link = GetInventoryItemLink("player", v);
        --local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name 
        if link then
            -- Unclear how rune engraving will appear in SoD since other enchants also exist on these slots
            --local _, _, _, _, _, enchant_id, _, _, _, _, _, _, _, _ = string.find(link,
            --    "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
            --ids[k] = enchant_id;
            --ids[k] = nil;

            local _, itr = string.find(link, "item");
            local itr_end, _ = string.find(link:sub(itr), "|");
            itr_end = itr_end + itr;

            --print(link:sub(itr, itr_end));
            while itr <= itr_end do
                -- try to match any number id's in item part of item string against rune enchant ids
                local id_start, id_end = string.find(link:sub(itr, itr_end), "%d+");
                if id_start then 
                    local id = tonumber(link:sub(itr+id_start-1, itr+id_end-1));
                    if runes[id] then
                        ids[k] = id;
                        break;
                    end
                    --print(v..": "..id);
                    itr = itr + id_end + 1;
                    
                else
                    break;
                end
            end
        end
    end
    return ids
end

local function wowhead_talent_link(code)
    local lowercase_class = string.lower(class);
    return "https://classic.wowhead.com/talent-calc/"..lowercase_class.."/"..code;
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

    local runes_code = "";

    local item_rune_ids = engraving_runes_id();

    local first_prefix = "";
    local num_runes = #item_rune_ids;
    if num_runes > 0 then
        runes_code = "1";
    end
    for k, v in pairs(item_rune_ids) do
        runes_code = runes_code..runes[v].wowhead_id;
    end

    return talent_code.."_"..runes_code;
end

local function talent_table(wowhead_code)

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

    local runes_table = {};
    if wowhead_code:sub(i, i) == "_" then
        i = i + 2;
        for k = 1, 3 do
            -- runes start with 5 for chest, 7 for legs, "a" (10) for gloves
            -- followed by 3 id characters
            local rune_code = wowhead_code:sub(i, i + 3);
            if rune_code ~= "" then
                local rune_id = wowhead_rune_code_to_id[rune_code];
                if rune_id then
                    runes_table[rune_id] = runes[rune_id];
                end
                i = i + 4;
            else
                break;
            end

        end
    end

    return talents, runes_table;
end

local function apply_talents(loadout, effects)

    local dynamic_talents, dynamic_runes = talent_table(loadout.talents_code);
    local custom_talents, custom_runes = nil, nil;

    if bit.band(loadout.flags, swc.utils.loadout_flags.is_dynamic_loadout) ~= 0 then
        loadout.talents_table = dynamic_talents;
        loadout.runes = dynamic_runes;
    else
        custom_talents, custom_runes = talent_table(loadout.custom_talents_code);
        loadout.talents_table = custom_talents;
        loadout.runes = custom_runes;
    end

    for k, v in pairs(loadout.runes) do
        if v.apply then
            if dynamic_runes[k] then
                v.apply(loadout, effects);
            else
                -- not dynamically active
                v.apply(loadout, effects, true);
            end
        end
    end
    if bit.band(loadout.flags, swc.utils.loadout_flags.is_dynamic_loadout) ~= 0 then
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

    if swc.core.__sw__test_all_codepaths then
        for k, v in pairs(runes) do
            loadout.runes[k] = v;
            if v.apply then
                v.apply(loadout, effects, true);
            end
        end
        for k, v in pairs(talents) do
            for i = 1, 3 do
                for j = 1, 29 do
                    if custom_talents then
                        custom_talents[i][j] = 5;
                    end
                    if dynamic_talents then
                        dynamic_talents[i][j] = 5;
                    end
                end
            end
            if v.apply then
                v.apply(loadout, effects, 3, 3);
            end
        end
    end
end

talents_export.wowhead_talent_link = wowhead_talent_link
talents_export.wowhead_talent_code_from_url = wowhead_talent_code_from_url;
talents_export.wowhead_talent_code = wowhead_talent_code;
talents_export.talent_table = talent_table;
talents_export.apply_talents = apply_talents;
talents_export.rune_ids = rune_ids;

swc.talents = talents_export;

