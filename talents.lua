local _, sc                = ...;

local spell_mod_add = sc.utils.spell_mod_add;
local class                 = sc.utils.class;
local stat                  = sc.utils.stat;

local config                = sc.config;

local magic_school          = sc.abilities.magic_school;
local spids                 = sc.abilities.spids;
-------------------------------------------------------------------------------
local talents_export        = {};

--local rune_ids              = {
--    --priest p1
--    serendipity                    = 6932,
--    strength_of_soul               = 6936,
--    twisted_faith                  = 7024,
--    void_plague                    = 7025,
--    circle_of_healing              = 6750,
--    mind_sear                      = 6934,
--    penance                        = 6752,
--    shadow_word_death              = 6741,
--    homunculi                      = 6744,
--    power_word_barrier             = 7589,
--    prayer_of_mending              = 6740,
--    shared_pain                    = 6746,
--    -- p2
--    empowered_renew                = 7026,
--    mind_spike                     = 7110,
--    renewed_hope                   = 7027,
--    dispersion                     = 7029,
--    pain_suppression               = 6747,
--    rolling_with_the_punches       = 6714,
--    spirit_of_the_redeemer         = 7028,
--    shadowfiend                    = 6751,
--    -- p3
--    divine_aegis                   = 7109,
--    eye_of_the_void                = 6754,
--    pain_and_suffering             = 6933,
--    despair                        = 7112,
--    surge_of_light                 = 7111,
--    void_zone                      = 7113,
--    -- p4
--    vampiric_touch                 = 6749,
--    soul_warding                   = 6742,
--    binding_heal                   = 6745,
--    --druid p1
--    fury_of_the_stormrage          = 6872,
--    living_seed                    = 6975,
--    survival_of_the_fittest        = 6972,
--    wild_strikes                   = 6858,
--    lacerate                       = 7492,
--    mangle                         = 6868,
--    sunfire                        = 6976,
--    wild_growth                    = 6860,
--    lifebloom                      = 6865,
--    savage_roar                    = 6863,
--    skull_bash                     = 7491,
--    starsurge                      = 7011,
--    -- p2
--    berserk                        = 7012,
--    eclipse                        = 7106,
--    nourish                        = 6870,
--    dreamstate                     = 6871,
--    king_of_the_jungle             = 7013,
--    survival_instincts             = 6859,
--    -- p3
--    efflorescence                  = 7105,
--    elunes_fires                   = 6977,
--    gale_winds                     = 7104,
--    gore                           = 7102,
--    -- p4
--    starfall                       = 7259,
--    tree_of_life                   = 7258,
--    improved_swipe                 = 7257,
--    -- px
--    improved_frenzied_regeneration = 6861,
--    improved_barkskin              = 7103,
--    --paladin p1
--    aegis                          = 7041,
--    divine_storm                   = 6850,
--    horn_of_lordaeron              = 7040,
--    seal_of_martyrdom              = 6851,
--    beacon_of_light                = 6843,
--    crusader_strike                = 6845,
--    hand_of_reckoning              = 6844,
--    avengers_shield                = 6854,
--    divine_sacrifice               = 6856,
--    exorcist                       = 6965,
--    inspiration_exemplar           = 6857,
--    rebuke                         = 7042,
--    -- p2
--    enlightened_judgements         = 7049,
--    infusion_of_light              = 7051,
--    sheath_of_light                = 7050,
--    guarded_by_the_light           = 6963,
--    sacred_shield                  = 6960,
--    the_art_of_war                 = 6966,
--    -- p3
--    fanaticism                     = 7088,
--    improved_sanctuary             = 7092,
--    lights_grace                   = 7499,
--    wrath                          = 7089,
--    hammer_of_the_righteous        = 6849,
--    improved_hammer_of_wrath       = 7091,
--    purifying_power                = 7090,
--    -- p4
--    righteous_vengeance            = 7271,
--    shock_and_awe                  = 7270,
--    shield_of_rigtheousness        = 7269,
--    divine_light                   = 7562,
--    --shaman p1
--    dual_wield_specialization      = 6874,
--    healing_rain                   = 6984,
--    overload                       = 6878,
--    shield_mastery                 = 6876,
--    lava_burst                     = 6883,
--    lava_lash                      = 6884,
--    molten_blast                   = 7031,
--    water_shield                   = 6875,
--    ancestral_guidance             = 6877,
--    earth_shield                   = 6880,
--    shamanistic_rage               = 7030,
--    way_of_earth                   = 6886,
--    -- p2
--    fire_nova                      = 6873,
--    maelstrom_weapon               = 6879,
--    power_surge                    = 6980,
--    ancestral_awakening            = 7048,
--    decoy_totem                    = 7047,
--    spirit_of_the_alpha            = 6882,
--    two_handed_mastery             = 7224,
--    --p3
--    overcharged                    = 7128,
--    riptide                        = 6885,
--    rolling_thunder                = 7126,
--    static_shock                   = 7127,
--    burn                           = 6987,
--    mental_dexterity               = 6982,
--    tidal_waves                    = 7125,
--    --p4
--    storm_earth_and_fire           = 7268,
--    feral_spirit                   = 7267,
--    coherence                      = 7000,
--    --mage p1
--    burnout                        = 6729,
--    enlightment                    = 6922,
--    fingers_of_frost               = 6735,
--    regeneration                   = 6736,
--    arcane_blast                   = 6728,
--    ice_lance                      = 6730,
--    living_bomb                    = 6923,
--    rewind_time                    = 7561,
--    arcane_surge                   = 7021,
--    icy_veins                      = 7020,
--    living_flame                   = 6737,
--    mass_regeneration              = 6927,
--    -- p2
--    frostfire_bolt                 = 6732,
--    hot_streak                     = 7560,
--    missile_barrage                = 6733,
--    spellfrost_bolt                = 6930,
--    brain_freeze                   = 6725,
--    chronostatic_preservation      = 7022,
--    spell_power                    = 6921,
--    -- p3
--    balefire_bolt                  = 7097,
--    deep_freeze                    = 7093,
--    temporal_anomaly               = 7094,
--    advanced_warding               = 6726,
--    displacement                   = 7096,
--    molten_armor                   = 7095,
--    -- p4
--    frozen_orb                     = 7272,
--    arcane_barrage                 = 6723,
--    overheat                       = 6734,
--    --warlock p1
--    demonic_tactics                = 6952,
--    lake_of_fire                   = 6815,
--    master_channeler               = 6811,
--    chaos_bolt                     = 6805,
--    haunt                          = 6803,
--    metamorphosis                  = 6816,
--    shadow_bolt_volley             = 6814,
--    demonic_grace                  = 7039,
--    demonic_pact                   = 7038,
--    everlasting_affliction         = 6950,
--    incinerate                     = 7591,
--    -- p2
--    grimoire_of_synergy            = 7054,
--    invocation                     = 7053,
--    shadow_and_flame               = 7056,
--    dance_of_the_wicked            = 6957,
--    demonic_knowledge              = 6953,
--    shadowflame                    = 7057,
--    -- p3
--    backdraft                      = 7115,
--    pandemic                       = 7114,
--    vengeance                      = 7058,
--    immolation_aura                = 7118,
--    summon_felguard                = 7117,
--    unstable_affliction            = 7116,
--    -- p4
--    decimation                     = 7273,
--    infernal_armor                 = 7275,
--    soul_siphon                    = 7590,
--    mark_of_chaos                  = 7592,
--    --rings p4
--    arcane_specialization          = 7514,
--    fire_specialization            = 7515,
--    frost_specialization           = 7516,
--    holy_specialization            = 7519,
--    shadow_specialization          = 7518,
--    nature_specialization          = 7517,
--
--    meditation_specialization      = 7639,
--    healing_specialization         = 7638,
--};

-- maps rune engraving enchant id to effect and wowhead's encoding
--local function create_runes()
--    if class == "PRIEST" then
--        return {
--            -- p1
--            [rune_ids.serendipity] = { wowhead_id = "56rm" },
--            [rune_ids.strength_of_soul] = { wowhead_id = "56rr" },
--            [rune_ids.twisted_faith] = { wowhead_id = "56vg" },
--            [rune_ids.void_plague] = { wowhead_id = "56vh" },
--            [rune_ids.circle_of_healing] = { wowhead_id = "a6jy" },
--            [rune_ids.mind_sear] = { wowhead_id = "a6rp" },
--            [rune_ids.penance] = { wowhead_id = "a6k0" },
--            [rune_ids.shadow_word_death] = { wowhead_id = "a6jn" },
--            [rune_ids.homunculi] = { wowhead_id = "76jr" },
--            [rune_ids.power_word_barrier] = { wowhead_id = "97d5" },
--            [rune_ids.prayer_of_mending] = { wowhead_id = "76jm" },
--            [rune_ids.shared_pain] = { wowhead_id = "76jt" },
--            -- p2
--            [rune_ids.empowered_renew] = {
--                apply = function(loadout, effects)
--                    spell_mod_add(effects.ability.coef_ot_mod, spids.renew, 0.15, 0.0);
--                end,
--                wowhead_id = "66vj"
--            },
--            [rune_ids.mind_spike] = { wowhead_id = "66y6" },
--            [rune_ids.renewed_hope] = { wowhead_id = "66vk" },
--            [rune_ids.dispersion] = { wowhead_id = "86vn" },
--            [rune_ids.pain_suppression] = { wowhead_id = "86jv" },
--            [rune_ids.spirit_of_the_redeemer] = { wowhead_id = "86vm" },
--            [rune_ids.shadowfiend] = { wowhead_id = "76jz" },
--            -- p3
--            [rune_ids.divine_aegis] = { wowhead_id = "16y5" },
--            [rune_ids.eye_of_the_void] = { wowhead_id = "16k2" },
--            [rune_ids.pain_and_suffering] = { wowhead_id = "16rn" },
--            [rune_ids.despair] = {
--                apply = function(loadout, effects)
--                    for i = 1, 7 do
--                        effects.by_school.spell_crit_mod[i] =
--                            effects.by_school.spell_crit_mod[i] + 0.5;
--                    end
--                end,
--                wowhead_id = "96y8"
--            },
--            [rune_ids.surge_of_light] = { wowhead_id = "96y7" },
--            [rune_ids.void_zone] = { wowhead_id = "96y9" },
--            -- p4
--            [rune_ids.vampiric_touch] = { wowhead_id = "f6jx" },
--            [rune_ids.soul_warding] = {
--                apply = function(loadout, effects)
--                    spell_mod_add(effects.ability.effect_mod_base, spids.power_word_shield, 0.15,
--                        0.0);
--                    spell_mod_add(effects.ability.coef_mod, spids.power_word_shield, 0.5, 0.0);
--                    spell_mod_add(effects.ability.cost_mod, spids.power_word_shield, 0.15, 0.0);
--                end,
--                wowhead_id = "f6jp"
--            },
--            [rune_ids.binding_heal] = { wowhead_id = "f6js" },
--        };
--    elseif class == "DRUID" then
--        return {
--            -- p1
--            [rune_ids.fury_of_the_stormrage] = {
--                apply = function(loadout, effects)
--                    spell_mod_add(effects.ability.cost_mod, spids.wrath, 1.0, 0.0);
--                end,
--                wowhead_id = "56pr"
--            },
--            [rune_ids.living_seed] = { wowhead_id = "56sz" },
--            [rune_ids.survival_of_the_fittest] = { wowhead_id = "56sw" },
--            [rune_ids.wild_strikes] = { wowhead_id = "56pa" },
--            [rune_ids.skull_bash] = { wowhead_id = "a7a3" },
--            [rune_ids.mangle] = { wowhead_id = "a6pm" },
--            [rune_ids.sunfire] = { wowhead_id = "a6t0" },
--            [rune_ids.wild_growth] = { wowhead_id = "a6pc" },
--            [rune_ids.lifebloom] = {
--                apply = function(loadout, effects)
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.rejuvenation, 0.5, 0.0);
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.lifebloom, 0.5, 0.0);
--                end,
--                wowhead_id = "76ph"
--            },
--            [rune_ids.savage_roar] = { wowhead_id = "76pf" },
--            [rune_ids.starsurge] = { wowhead_id = "76v3" },
--            [rune_ids.lacerate] = { wowhead_id = "77a4" },
--            -- p2
--            [rune_ids.berserk] = { wowhead_id = "66v4" },
--            [rune_ids.eclipse] = { wowhead_id = "66y2" },
--            [rune_ids.nourish] = { wowhead_id = "66pp" },
--            [rune_ids.dreamstate] = { wowhead_id = "86pq" },
--            [rune_ids.king_of_the_jungle] = { wowhead_id = "86v5" },
--            [rune_ids.survival_instincts] = { wowhead_id = "86pb" },
--            -- p3
--            [rune_ids.gale_winds] = {
--                apply = function(loadout, effects)
--                    spell_mod_add(effects.ability.effect_mod, spids.hurricane, 1.0, 0.0);
--                    spell_mod_add(effects.ability.cost_mod, spids.hurricane, 0.6, 0.0);
--                end,
--                wowhead_id = "16y0"
--            },
--            [rune_ids.gore] = { wowhead_id = "16xy" },
--            [rune_ids.improved_barkskin] = { wowhead_id = "16xz" },
--            [rune_ids.efflorescence] = { wowhead_id = "96y1" },
--            [rune_ids.improved_frenzied_regeneration] = { wowhead_id = "96pd" },
--            [rune_ids.elunes_fires] = { wowhead_id = "96t1" },
--            -- p4
--            [rune_ids.starfall] = { wowhead_id = "f72v" },
--            [rune_ids.tree_of_life] = { wowhead_id = "f72t" },
--            [rune_ids.improved_swipe] = { wowhead_id = "f72s" },
--        };
--    elseif class == "PALADIN" then
--        return {
--            -- p1
--            [rune_ids.aegis] = { wowhead_id = "56w1" },
--            [rune_ids.divine_storm] = { wowhead_id = "56p2" },
--            [rune_ids.horn_of_lordaeron] = { wowhead_id = "56w0" },
--            [rune_ids.seal_of_martyrdom] = { wowhead_id = "56p3" },
--            [rune_ids.beacon_of_light] = { wowhead_id = "a6nv" },
--            [rune_ids.crusader_strike] = { wowhead_id = "a6nx" },
--            [rune_ids.hand_of_reckoning] = { wowhead_id = "a6nw" },
--            [rune_ids.avengers_shield] = { wowhead_id = "76p6" },
--            [rune_ids.rebuke] = { wowhead_id = "76p8" },
--            [rune_ids.exorcist] = { wowhead_id = "76sn" },
--            [rune_ids.inspiration_exemplar] = { wowhead_id = "76p9" },
--            [rune_ids.divine_sacrifice] = { wowhead_id = "76w2" },
--            -- p2
--            [rune_ids.enlightened_judgements] = {
--                apply = function(loadout, effects, inactive)
--                    -- unclear if this appears in GetSpellHitModifier ingame
--                    if inactive then
--                        for i = 1, 7 do
--                            effects.by_school.spell_dmg_hit[i] = effects.by_school.spell_dmg_hit[i] + 0.17;
--                        end
--                    end
--                end,
--                wowhead_id = "66w9"
--            },
--            [rune_ids.infusion_of_light] = {
--                apply = function(loadout, effects)
--                    spell_mod_add(effects.ability.effect_mod, spids.holy_shock, 0.5, 0.0);
--                end,
--                wowhead_id = "66wb"
--            },
--            [rune_ids.sheath_of_light] = { wowhead_id = "66wa" },
--            [rune_ids.guarded_by_the_light] = { wowhead_id = "86sk" },
--            [rune_ids.sacred_shield] = { wowhead_id = "86sg" },
--            [rune_ids.the_art_of_war] = { wowhead_id = "86sp" },
--            -- p3
--            [rune_ids.fanaticism] = { wowhead_id = "16xg" },
--            [rune_ids.improved_sanctuary] = { wowhead_id = "16xm" },
--            [rune_ids.wrath] = { wowhead_id = "16xh" },
--            [rune_ids.improved_hammer_of_wrath] = { wowhead_id = "96xk" },
--            [rune_ids.purifying_power] = { wowhead_id = "96xj" },
--            [rune_ids.hammer_of_the_righteous] = { wowhead_id = "96p1" },
--            [rune_ids.lights_grace] = {
--                apply = function(loadout, effects)
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.holy_light, 0.5, 0.0);
--                end,
--                wowhead_id = "97ab"
--            },
--            -- p4
--            [rune_ids.righteous_vengeance] = { wowhead_id = "f737" },
--            [rune_ids.shock_and_awe] = { wowhead_id = "f736" },
--            [rune_ids.shield_of_rigtheousness] = { wowhead_id = "f735" },
--            [rune_ids.divine_light] = { wowhead_id = "f7ca" },
--        };
--    elseif class == "SHAMAN" then
--        return {
--            -- p1
--            [rune_ids.dual_wield_specialization] = { wowhead_id = "56pt" },
--            [rune_ids.healing_rain] = { wowhead_id = "56t8" },
--            [rune_ids.overload] = { wowhead_id = "56py" },
--            [rune_ids.shield_mastery] = { wowhead_id = "56pw" },
--            [rune_ids.lava_burst] = { wowhead_id = "a6q3" },
--            [rune_ids.lava_lash] = { wowhead_id = "a6q4" },
--            [rune_ids.molten_blast] = { wowhead_id = "a6vq" },
--            [rune_ids.water_shield] = { wowhead_id = "a6pv" },
--            [rune_ids.ancestral_guidance] = { wowhead_id = "76px" },
--            [rune_ids.earth_shield] = { wowhead_id = "76q0" },
--            [rune_ids.shamanistic_rage] = { wowhead_id = "76vp" },
--            [rune_ids.way_of_earth] = { wowhead_id = "76q6" },
--            -- p2
--            [rune_ids.two_handed_mastery] = { wowhead_id = "571r" },
--            [rune_ids.fire_nova] = { wowhead_id = "66ps" },
--            [rune_ids.maelstrom_weapon] = { wowhead_id = "66pz" },
--            [rune_ids.power_surge] = {
--                apply = function(loadout, effects)
--                    effects.raw.mp5_from_int_mod = effects.raw.mp5_from_int_mod + 0.15;
--                end,
--                wowhead_id = "66t4"
--            },
--            [rune_ids.ancestral_awakening] = { wowhead_id = "86w8" },
--            [rune_ids.decoy_totem] = { wowhead_id = "86w7" },
--            [rune_ids.spirit_of_the_alpha] = { wowhead_id = "86q2" },
--            -- p3
--            [rune_ids.burn] = {
--                apply = function(loadout, effects)
--                    spell_mod_add(effects.ability.effect_mod, spids.flame_shock, 1.0, 0.0);
--                    spell_mod_add(effects.ability.extra_ticks, spids.flame_shock, 2, 0.0);
--                end,
--                wowhead_id = "16tb"
--            },
--
--            [rune_ids.mental_dexterity] = { wowhead_id = "16t6" },
--            [rune_ids.tidal_waves] = { wowhead_id = "16yn" },
--            [rune_ids.overcharged] = { wowhead_id = "96yr" },
--            [rune_ids.riptide] = { wowhead_id = "96q5" },
--            [rune_ids.rolling_thunder] = { wowhead_id = "96yp" },
--            [rune_ids.static_shock] = { wowhead_id = "96yq" },
--            --p4
--            [rune_ids.storm_earth_and_fire] = {
--                apply = function(loadout, effects)
--                    spell_mod_add(effects.ability.effect_ot_mod, spids.flame_shock, 0.6, 0.0);
--                end,
--                wowhead_id = "f734"
--            },
--            [rune_ids.feral_spirit] = { wowhead_id = "f733" },
--            [rune_ids.coherence] = { wowhead_id = "f6tr" },
--        };
--    elseif class == "MAGE" then
--        return {
--            -- p1
--            [rune_ids.regeneration] = { wowhead_id = "56jg" },
--            [rune_ids.fingers_of_frost] = { wowhead_id = "56jf" },
--            [rune_ids.enlightment] = { wowhead_id = "56ra" },
--            [rune_ids.burnout] = {
--                apply = function(loadout, effects, inactive)
--                    -- 15% spell crit but 1% more base mana cost on crit
--                    add_all_spell_crit(effects, 0.15, inactive);
--                end,
--                wowhead_id = "56j9"
--            },
--            [rune_ids.rewind_time] = { wowhead_id = "97c9" },
--            [rune_ids.living_bomb] = { wowhead_id = "a6rb" },
--            [rune_ids.ice_lance] = { wowhead_id = "a6ja" },
--            [rune_ids.arcane_blast] = { wowhead_id = "a6j8" },
--            [rune_ids.mass_regeneration] = { wowhead_id = "76rf" },
--            [rune_ids.living_flame] = { wowhead_id = "76jh" },
--            [rune_ids.icy_veins] = { wowhead_id = "76vc" },
--            [rune_ids.arcane_surge] = { wowhead_id = "76vd" },
--            -- p2
--            [rune_ids.frostfire_bolt] = { wowhead_id = "66jc" },
--            [rune_ids.hot_streak] = { wowhead_id = "17c8" },
--            [rune_ids.missile_barrage] = { wowhead_id = "66jd" },
--            [rune_ids.spellfrost_bolt] = { wowhead_id = "66rj" },
--            [rune_ids.brain_freeze] = { wowhead_id = "86j5" },
--            [rune_ids.chronostatic_preservation] = { wowhead_id = "86ve" },
--            [rune_ids.spell_power] = {
--                apply = function(loadout, effects)
--                    for i = 1, 7 do
--                        effects.by_school.spell_crit_mod[i] =
--                            effects.by_school.spell_crit_mod[i] + 0.25;
--                    end
--                end,
--                wowhead_id = "86r9"
--            },
--            -- p3
--            [rune_ids.advanced_warding] = {
--                apply = function(loadout, effects)
--                    spell_mod_add(effects.ability.effect_mod, spids.mana_shield, 1.0, 0.0);
--                    --spell_mod_add(effects.ability.effect_mod, spids.fire_ward, 1.0, 0.0);
--                    --spell_mod_add(effects.ability.effect_mod, spids.frost_ward_, 1.0, 0.0);
--                end,
--                wowhead_id = "16j6"
--            },
--            [rune_ids.deep_freeze] = { wowhead_id = "16xn" },
--            [rune_ids.temporal_anomaly] = { wowhead_id = "16xp" },
--            [rune_ids.balefire_bolt] = { wowhead_id = "96xs" },
--            [rune_ids.displacement] = { wowhead_id = "96xr" },
--            [rune_ids.molten_armor] = { wowhead_id = "96xq" },
--            -- p4
--            [rune_ids.frozen_orb] = { wowhead_id = "f738" },
--            [rune_ids.arcane_barrage] = { wowhead_id = "f6j3" },
--            [rune_ids.overheat] = {
--                apply = function(loadout, effects)
--                    spell_mod_add(effects.ability.crit, spids.fire_blast, 1.0, 0.0);
--                end,
--                wowhead_id = "f6je"
--            },
--        };
--    elseif class == "WARLOCK" then
--        return {
--            -- p1
--            [rune_ids.lake_of_fire] = { wowhead_id = "56mz" },
--            [rune_ids.demonic_tactics] = {
--                apply = function(loadout, effects, inactive)
--                    add_all_spell_crit(effects, 0.1, inactive);
--                end,
--                wowhead_id = "56s8",
--            },
--            [rune_ids.chaos_bolt] = { wowhead_id = "56mn" },
--            [rune_ids.master_channeler] = { wowhead_id = "56mv" },
--            [rune_ids.shadow_bolt_volley] = {
--                apply = function(loadout, effects)
--                    spell_mod_add(effects.ability.effect_mod, spids.shadow_bolt, -0.05, 0.0);
--                end,
--                wowhead_id = "a6my"
--            },
--            [rune_ids.metamorphosis] = { wowhead_id = "a6n0" },
--            [rune_ids.haunt] = { wowhead_id = "a6mk" },
--            [rune_ids.incinerate] = { wowhead_id = "97d7" },
--            [rune_ids.everlasting_affliction] = { wowhead_id = "76s6" },
--            [rune_ids.demonic_pact] = { wowhead_id = "76vy" },
--            [rune_ids.demonic_grace] = { wowhead_id = "76vz" },
--            -- p2
--            [rune_ids.grimoire_of_synergy] = { wowhead_id = "66we" },
--            [rune_ids.invocation] = { wowhead_id = "66wd" },
--            [rune_ids.shadow_and_flame] = { wowhead_id = "66wg" },
--            [rune_ids.dance_of_the_wicked] = { wowhead_id = "86sd" },
--            [rune_ids.demonic_knowledge] = { wowhead_id = "86s9" },
--            [rune_ids.shadowflame] = { wowhead_id = "86wh" },
--            -- p3
--            -- px
--            [rune_ids.backdraft] = { wowhead_id = "16yb" },
--            [rune_ids.pandemic] = { wowhead_id = "16ya" },
--            [rune_ids.vengeance] = { wowhead_id = "16wj" },
--            [rune_ids.immolation_aura] = { wowhead_id = "96ye" },
--            [rune_ids.summon_felguard] = { wowhead_id = "96yd" },
--            [rune_ids.unstable_affliction] = { wowhead_id = "96yc" },
--            --p4
--            [rune_ids.decimation] = { wowhead_id = "f739" },
--            [rune_ids.infernal_armor] = { wowhead_id = "f73b" },
--            [rune_ids.soul_siphon] = {
--                apply = function(loadout, effects)
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.drain_soul, 10, 0);
--                end,
--                wowhead_id = "f7d6"
--            },
--            [rune_ids.mark_of_chaos] = { wowhead_id = "87d8" },
--        };
--    else
--        return {};
--    end
--end

local function create_talents()
    if class == "PRIEST" then
        return {
            [102] = {
                apply = function(loadout, effects, pts, missing_pts)
                    spell_mod_add(effects.ability.effect_mod, spids.shoot, (pts - missing_pts) *
                        0.05, 0);
                end
            },
            -- improved power word shield
            [105] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.effect_mod_base, spids.power_word_shield,
                        pts * 0.05, 0.0);
                end
            },
            [108] = {
                apply = function(loadout, effects, pts)
                    effects.raw.regen_while_casting = effects.raw.regen_while_casting + pts * 0.05;
                end
            },
            [111] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.cast_mod_flat, spids.mana_burn, pts * 0.25, 0.0);
                end
            },
            [112] = {
                apply = function(loadout, effects, pts, missing_pts)
                    sc.loadout.add_mana_mod(loadout, effects, missing_pts * 0.02, pts * 0.02);
                end
            },
            [114] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_mod[magic_school.shadow] =
                        effects.by_school.spell_dmg_mod[magic_school.shadow] + 0.01 * pts;
                    effects.by_school.spell_dmg_mod[magic_school.holy] =
                        effects.by_school.spell_dmg_mod[magic_school.holy] + 0.01 * pts;
                end
            },
            [202] = {
                apply = function(loadout, effects, pts)
                    local renew = spids.renew;
                    spell_mod_add(effects.ability.effect_mod_base, renew, pts * 0.05, 0.0);
                end
            },
            [203] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_crit[magic_school.holy] =
                        effects.by_school.spell_crit[magic_school.holy] + 0.01 * pts;
                end
            },
            [205] = {
                apply = function(loadout, effects, pts)
                    local abilities = { spids.smite, spids.holy_fire, spids.heal, spids.greater_heal };
                    for k, v in pairs(abilities) do
                        spell_mod_add(effects.ability.cast_mod_flat, v, pts * 0.1, 0);
                    end
                end
            },
            [210] = {
                apply = function(loadout, effects, pts)
                    local abilities =
                        { spids.lesser_heal, spids.heal, spids.greater_heal };
                    for k, v in pairs(abilities) do
                        spell_mod_add(effects.ability.cost_mod, v, pts * 0.05, 0);
                    end
                end
            },
            [211] = {
                apply = function(loadout, effects, pts)
                    local abilities = { spids.smite, spids.holy_fire };
                    for k, v in pairs(abilities) do
                        spell_mod_add(effects.ability.effect_mod_base, v, pts * 0.05, 0.0);
                    end
                end
            },
            [212] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.cost_mod, spids.prayer_of_healing, pts * 0.1, 0);
                end
            },
            [214] = {
                apply = function(loadout, effects, pts, missing_pts)
                    effects.by_attribute.sp_from_stat_mod[stat.spirit] = effects.by_attribute.sp_from_stat_mod
                        [stat.spirit] + pts * 0.05;
                    effects.by_attribute.hp_from_stat_mod[stat.spirit] = effects.by_attribute.hp_from_stat_mod
                        [stat.spirit] + pts * 0.05;

                    effects.raw.spell_dmg = effects.raw.spell_dmg + 0.05 * missing_pts * loadout.stats[stat.spirit];
                    effects.raw.healing_power = effects.raw.healing_power + 0.05 * missing_pts *
                        loadout.stats[stat.spirit];
                end
            },
            [215] = {
                apply = function(loadout, effects, pts)
                    effects.raw.spell_heal_mod_base = effects.raw.spell_heal_mod_base + pts * 0.02;
                end
            },
            [304] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.extra_ticks, spids.shadow_word_pain, pts, 0.0);
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
                    effects.by_school.spell_dmg_mod[magic_school.shadow] =
                        effects.by_school.spell_dmg_mod[magic_school.shadow] + 0.02 * pts;
                end
            },
        };
    elseif class == "DRUID" then
        return {
            [101] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.cast_mod_flat, spids.wrath, pts * 0.1, 0);
                end
            },
            [105] = {
                apply = function(loadout, effects, pts)
                    local mf = spids.moonfire;
                    spell_mod_add(effects.ability.crit, mf, pts * 0.02, 0);
                    spell_mod_add(effects.ability.effect_mod_base, mf, pts * 0.02, 0.0);
                    local sf = spids.sunfire;
                    spell_mod_add(effects.ability.crit, sf, pts * 0.02, 0);
                    spell_mod_add(effects.ability.effect_mod_base, sf, pts * 0.02, 0.0);
                    local starfall = spids.starfall;
                    spell_mod_add(effects.ability.crit, starfall, pts * 0.02, 0);
                    spell_mod_add(effects.ability.effect_mod_base, starfall, pts * 0.02, 0.0);
                end
            },
            [106] = {
                apply = function(loadout, effects, pts)
                    if bit.band(sc.core.client_deviation, sc.core.client_deviation_flags.sod) ~= 0 then
                        effects.mul.by_school.spell_dmg_mod[magic_school.nature] =
                            effects.mul.by_school.spell_dmg_mod[magic_school.nature] * (1.0 + 0.02 * pts);
                        effects.mul.by_school.spell_dmg_mod[magic_school.arcane] =
                            effects.mul.by_school.spell_dmg_mod[magic_school.arcane] * (1.0 + 0.02 * pts);
                    end
                end
            },
            [111] = {
                apply = function(loadout, effects, pts)
                    local abilities = { spids.starfire, spids.moonfire, spids.wrath, spids.starsurge, spids.sunfire,
                        spids.starfall };
                    for k, v in pairs(abilities) do
                        spell_mod_add(effects.ability.crit_mod, v, pts * 0.1, 0);
                    end
                end
            },
            [112] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.cast_mod_flat, spids.starfire, pts * 0.1, 0);
                end
            },
            [114] = {
                apply = function(loadout, effects, pts)
                    local abilities = {spids.moonfire, spids.starfire, spids.wrath, spids.healing_touch, spids.regrowth,
                        spids.rejuvenation, spids.nourish, spids.starfall };
                    for k, v in pairs(abilities) do
                        spell_mod_add(effects.ability.cost_mod, v, pts * 0.03, 0);
                    end
                end
            },
            [115] = {
                apply = function(loadout, effects, pts)
                    local abilities = { spids.starfire, spids.moonfire, spids.wrath, spids.starsurge, spids.sunfire,
                        spids.starfall };
                    for k, v in pairs(abilities) do
                        spell_mod_add(effects.ability.effect_mod_base, v, pts * 0.02, 0.0);
                    end
                end
            },
            [215] = {
                apply = function(loadout, effects, pts, missing_pts)
                    sc.loadout.add_int_mod(loadout, effects, 0.04 * missing_pts, 0.04 * pts);
                end
            },
            [303] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.cast_mod_flat, spids.healing_touch, pts * 0.1, 0);
                    spell_mod_add(effects.ability.cast_mod_flat, spids.nourish, pts * 0.1, 0);
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
                    local abilities = { spids.healing_touch, spids.tranquility, spids.nourish };

                    for k, v in pairs(abilities) do
                        spell_mod_add(effects.ability.cost_mod, v, pts * 0.02, 0);
                    end
                end
            },
            [310] = {
                apply = function(loadout, effects, pts)
                    local rejuv = spids.rejuvenation;
                    spell_mod_add(effects.ability.effect_mod_base, rejuv, pts * 0.05, 0.0);
                end
            },
            [312] = {
                apply = function(loadout, effects, pts)
                    effects.raw.spell_heal_mod_base = effects.raw.spell_heal_mod_base + pts * 0.02;
                end
            },
            [314] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.crit, spids.regrowth, pts * 0.1, 0);
                    spell_mod_add(effects.ability.crit, spids.nourish, pts * 0.1, 0);
                end
            },
        };
    elseif class == "PALADIN" then
        return {
            [102] = {
                apply = function(loadout, effects, pts, missing_pts)
                    sc.loadout.add_int_mod(loadout, effects, missing_pts * 0.02, pts * 0.02);
                end
            },
            [105] = {
                apply = function(loadout, effects, pts)
                    local abilities = { spids.holy_light, spids.flash_of_light };

                    for k, v in pairs(abilities) do
                        spell_mod_add(effects.ability.effect_mod_base, v, pts * 0.04, 0.0);
                    end
                end
            },
            -- TODO VANILLA: Pom improvement in buffs
            [113] = {
                apply = function(loadout, effects, pts, missing_pts)
                    -- TODO: verify is this is added as all school crit
                    effects.by_school.spell_crit[magic_school.holy] =
                        effects.by_school.spell_crit[magic_school.holy] + missing_pts * 0.01;
                end
            },
        };
    elseif class == "SHAMAN" then
        return {
            [101] = {
                apply = function(loadout, effects, pts)
                    local ele_abilities = { spids.earth_shock, spids.frost_shock, spids.flame_shock,
                        spids.lightning_bolt, spids.chain_lightning };
                    for k, v in pairs(ele_abilities) do
                        spell_mod_add(effects.ability.cost_mod, v, pts * 0.02, 0.0);
                    end
                end
            },
            [102] = {
                apply = function(loadout, effects, pts)
                    local ele_abilities = { spids.earth_shock, spids.frost_shock, spids.flame_shock,
                        spids.lightning_bolt, spids.chain_lightning };
                    for k, v in pairs(ele_abilities) do
                        spell_mod_add(effects.ability.effect_mod, v, pts * 0.01, 0.0);
                    end
                end
            },
            [105] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs({ spids.magma_totem, spids.searing_totem, spids.fire_nova_totem }) do
                        spell_mod_add(effects.ability.effect_mod, v, pts * 0.05, 0.0);
                    end
                end
            },
            [108] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs({ spids.lightning_bolt, spids.chain_lightning }) do
                        if pts == 5 then
                            pts = 6;
                        end
                        spell_mod_add(effects.ability.crit, v, 0.01 * pts, 0.0);
                    end
                end
            },
            [113] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_crit_mod[magic_school.frost] =
                        effects.by_school.spell_crit_mod[magic_school.frost] + pts * 0.5;
                    effects.by_school.spell_crit_mod[magic_school.fire] =
                        effects.by_school.spell_crit_mod[magic_school.fire] + pts * 0.5;
                    effects.by_school.spell_crit_mod[magic_school.nature] =
                        effects.by_school.spell_crit_mod[magic_school.nature] + pts * 0.5;
                end
            },
            [114] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs({ spids.lightning_bolt, spids.chain_lightning }) do
                        spell_mod_add(effects.ability.cast_mod_flat, v, pts * 0.2, 0.0);
                    end
                end
            },
            [201] = {
                apply = function(loadout, effects, pts, missing_pts)
                    sc.loadout.add_mana_mod(loadout, effects, missing_pts * 0.01, pts * 0.01);
                end
            },
            [206] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.effect_mod_base, spids.lightning_shield,
                        pts * 0.05, 0.0);
                end
            },
            [213] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.effect_mod_base, spids.flametongue_weapon,
                        pts * 0.05, 0.0);
                    spell_mod_add(effects.ability.effect_mod_base, spids.frostbrand_weapon,
                        pts * 0.05, 0.0);
                end
            },
            [301] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.cast_mod_flat, spids.healing_wave, pts * 0.1, 0.0);
                end
            },
            [302] = {
                apply = function(loadout, effects, pts)
                    local healing_spells = { spids.chain_heal, spids.lesser_healing_wave, spids.healing_wave,
                        spids.healing_rain, spids.riptide, spids.earth_shield };
                    for k, v in pairs(healing_spells) do
                        spell_mod_add(effects.ability.cost_mod, v, pts * 0.01, 0.0);
                    end
                end
            },
            [305] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs({ spids.healing_stream_totem, spids.magma_totem, spids.searing_totem, spids.fire_nova_totem }) do
                        spell_mod_add(effects.ability.cost_mod, v, pts * 0.05, 0.0);
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
                    spell_mod_add(effects.ability.effect_mod_base, spids.healing_stream_totem,
                        pts * 0.05, 0.0);
                end
            },
            [311] = {
                apply = function(loadout, effects, pts, missing_pts)
                    for k, v in pairs({ spids.lightning_shield, spids.healing_wave, spids.lightning_bolt, spids.chain_lightning, spids.lesser_healing_wave, spids.chain_heal, spids.earth_shield, spids.riptide, spids.healing_rain }) do
                        spell_mod_add(effects.ability.crit, v, pts * 0.01, 0.0);
                    end
                end
            },
            [314] = {
                apply = function(loadout, effects, pts)
                    effects.raw.spell_heal_mod_base = effects.raw.spell_heal_mod_base + pts * 0.02;
                    spell_mod_add(effects.ability.effect_mod_base, spids.earth_shield, -pts * 0.02,
                        0.0);
                    spell_mod_add(effects.ability.effect_mod_base, spids.healing_stream_totem,
                        -pts * 0.02, 0.0);
                end
            },
        };
    elseif class == "MAGE" then
        return {
            [101] = {
                apply = function(loadout, effects, pts)
                    for i = 1, 7 do
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
            [104] = {
                apply = function(loadout, effects, pts, missing_pts)
                    spell_mod_add(effects.ability.effect_mod, spids.shoot,
                        (pts - missing_pts) * 0.125, 0);
                end
            },
            [108] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.crit, spids.arcane_explosion, pts * 0.02, 0);
                end
            },
            [112] = {
                apply = function(loadout, effects, pts)
                    effects.raw.regen_while_casting = effects.raw.regen_while_casting + pts * 0.05;
                end
            },
            [114] = {
                apply = function(loadout, effects, pts, missing_pts)
                    sc.loadout.add_mana_mod(loadout, effects, missing_pts * 0.02, pts * 0.02);
                end
            },
            [115] = {
                apply = function(loadout, effects, pts, missing_pts)
                    effects.by_school.spell_dmg_mod[magic_school.fire] =
                        effects.by_school.spell_dmg_mod[magic_school.fire] + pts * 0.01;
                    effects.by_school.spell_dmg_mod[magic_school.arcane] =
                        effects.by_school.spell_dmg_mod[magic_school.arcane] + pts * 0.01;
                    effects.by_school.spell_dmg_mod[magic_school.frost] =
                        effects.by_school.spell_dmg_mod[magic_school.frost] + pts * 0.01;

                    for i = 2, 7 do
                        effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.01 * missing_pts;
                    end
                    effects.raw.added_physical_spell_crit = effects.raw.added_physical_spell_crit +
                        (pts - missing_pts) * 0.01;
                end
            },
            [201] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.cast_mod_flat, spids.fireball, pts * 0.1, 0.0);
                end
            },
            [206] = {
                apply = function(loadout, effects, pts)
                    for k, v in pairs({ spids.fire_blast, spids.scorch }) do
                        spell_mod_add(effects.ability.crit, v, pts * 0.02, 0.0);
                    end
                end
            },
            [207] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.crit, spids.flamestrike, pts * 0.05, 0.0);
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
                    effects.by_school.spell_dmg_mod[magic_school.fire] =
                        effects.by_school.spell_dmg_mod[magic_school.fire] + 0.02 * pts;
                end
            },
            [302] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.cast_mod_flat, spids.frostbolt, pts * 0.1, 0.0);
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
                        effects.by_school.spell_crit_mod[magic_school.frost] + pts * 0.1;
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
                    effects.by_school.cost_mod[magic_school.frost] =
                        effects.by_school.cost_mod[magic_school.frost] + 0.05 * pts;
                end
            },
            [313] = {
                apply = function(loadout, effects, pts)
                    --TODO VANILLA
                end
            },
            [315] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.effect_mod_base, spids.cone_of_cold, pts * 0.15,
                        0.0);
                end
            },
        };
    elseif class == "WARLOCK" then
        return {
            [102] = {
                apply = function(loadout, effects, pts)
                    -- TODO VANILLA: is this capped at 1.0 or 1.5 effectively?
                    spell_mod_add(effects.ability.cast_mod_flat, spids.corruption, pts * 0.4, 0.0);
                end
            },
            [105] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.effect_mod, spids.life_tap, pts * 0.1, 0.0);
                end
            },
            [106] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.effect_mod_base, spids.drain_life, pts * 0.02,
                        0.0);
                end
            },
            [107] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.effect_mod_base, spids.curse_of_agony, pts * 0.02,
                        0.0);
                end
            },
            [116] = {
                -- TODO: some spells treated differently than others
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_mod[magic_school.shadow] =
                        effects.by_school.spell_dmg_mod[magic_school.shadow] + 0.02 * pts;
                end
            },
            [203] = {
                apply = function(loadout, effects, pts)
                    effects.by_attribute.stat_mod[stat.spirit] = effects.by_attribute.stat_mod[stat.spirit] - pts * 0.01;
                    -- TODO: dynamic mod
                end
            },
            [204] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.effect_mod_base, spids.health_funnel, pts * 0.1,
                        0.0);
                end
            },
            [303] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.cast_mod_flat, spids.shadow_bolt, pts * 0.1, 0.0);
                    spell_mod_add(effects.ability.cast_mod_flat, spids.immolate, pts * 0.1, 0.0);
                    spell_mod_add(effects.ability.cast_mod_flat, spids.soul_fire, pts * 0.4, 0.0);
                end
            },
            [311] = {
                apply = function(loadout, effects, pts)
                    if pts ~= 0 then
                        spell_mod_add(effects.ability.crit, spids.searing_pain, pts * 0.02, 0.0);
                    end
                end
            },
            [313] = {
                apply = function(loadout, effects, pts)
                    spell_mod_add(effects.ability.effect_mod, spids.immolate, pts * 0.05, 0.0);
                    spell_mod_add(effects.ability.effect_ot_mod, spids.immolate, -pts * 0.05, 0.0);
                end
            },
            [315] = {
                apply = function(loadout, effects, pts)
                    effects.by_school.spell_dmg_mod[magic_school.fire] =
                        effects.by_school.spell_dmg_mod[magic_school.fire] + 0.02 * pts;
                end
            },
        };
    else
        return {};
    end
end

local talents = create_talents();
--local runes = create_runes();
--
--runes[rune_ids.arcane_specialization] = {
--    apply = function(loadout, effects)
--        effects.by_school.spell_dmg_hit[magic_school.arcane] =
--            effects.by_school.spell_dmg_hit[magic_school.arcane] + 0.06;
--    end,
--    wowhead_id = "b7at"
--};
--runes[rune_ids.fire_specialization] = {
--    apply = function(loadout, effects)
--        effects.by_school.spell_dmg_hit[magic_school.fire] =
--            effects.by_school.spell_dmg_hit[magic_school.fire] + 0.06;
--    end,
--    wowhead_id = "b7av"
--};
--runes[rune_ids.frost_specialization] = {
--    apply = function(loadout, effects)
--        effects.by_school.spell_dmg_hit[magic_school.frost] =
--            effects.by_school.spell_dmg_hit[magic_school.frost] + 0.06;
--    end,
--    wowhead_id = "b7aw"
--};
--runes[rune_ids.holy_specialization] = {
--    apply = function(loadout, effects)
--        effects.by_school.spell_dmg_hit[magic_school.holy] =
--            effects.by_school.spell_dmg_hit[magic_school.holy] + 0.06;
--    end,
--    wowhead_id = "b7az"
--};
--runes[rune_ids.shadow_specialization] = {
--    apply = function(loadout, effects)
--        effects.by_school.spell_dmg_hit[magic_school.shadow] =
--            effects.by_school.spell_dmg_hit[magic_school.shadow] + 0.06;
--    end,
--    wowhead_id = "b7ay"
--};
--runes[rune_ids.nature_specialization] = {
--    apply = function(loadout, effects)
--        effects.by_school.spell_dmg_hit[magic_school.nature] =
--            effects.by_school.spell_dmg_hit[magic_school.nature] + 0.06;
--    end,
--    wowhead_id = "b7ax"
--};
--runes[rune_ids.meditation_specialization] = {
--    apply = function(loadout, effects)
--        effects.raw.mp5 = effects.raw.mp5 + 5;
--    end,
--    wowhead_id = "b7eq"
--};
--runes[rune_ids.healing_specialization] = { wowhead_id = "b7ep" };

--local wowhead_rune_code_to_id = {};
---- reverse mapping from wowhead 3 char code to rune spell id
--for k, v in pairs(runes) do
--    wowhead_rune_code_to_id[v.wowhead_id] = k;
--end
--
--local function engraving_runes_id()
--    local ids = {};
--    if C_Engraving.IsEngravingEnabled then
--        -- NOTE: order might be important here for wowhead export
--        for k = 1, 16 do
--            local rune_slot = C_Engraving.GetRuneForEquipmentSlot(k);
--            if rune_slot then
--                if runes[rune_slot.itemEnchantmentID] then
--                    ids[k] = rune_slot.itemEnchantmentID;
--                end
--            end
--        end
--    end
--    return ids
--end

local function wowhead_talent_link(code)
    local lowercase_class = string.lower(class);
    return "https://classic.wowhead.com/talent-calc/" .. lowercase_class .. "/" .. code;
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
    local talent_code = "";

    local sub_codes = { "", "", "" };
    for i = 1, 3 do
        -- NOTE: GetNumTalents(i) will return 0 on early calls after logging in,
        --       but works fine after reload
        for _, v in pairs(sc.talent_order[i]) do
            local _, _, _, _, pts, _, _, _ = GetTalentInfo(i, v);
            sub_codes[i] = sub_codes[i]..tostring(pts);
        end
        local num_redundant = 0;
        local n = #sub_codes[i];
        for k = 1, n do
            if string.sub(sub_codes[i], n-k+1, n-k+1) == "0" then
                num_redundant = num_redundant + 1;
            else
                break;
            end
        end
        sub_codes[i] = string.sub(sub_codes[i], 1, n-num_redundant);
    end
    if sub_codes[2] == "" and sub_codes[3] == "" then
        talent_code = sub_codes[1];
    elseif sub_codes[2] == "" then
        talent_code = sub_codes[1] .. "--" .. sub_codes[3];
    elseif sub_codes[3] == "" then
        talent_code = sub_codes[1] .. "-" .. sub_codes[2];
    else
        talent_code = sub_codes[1] .. "-" .. sub_codes[2] .. "-" .. sub_codes[3];
    end

    --local runes_code = "";

    --local item_rune_ids = engraving_runes_id();

    --if next(item_rune_ids) then
    --    runes_code = "1";
    --end
    --for k, v in pairs(item_rune_ids) do
    --    runes_code = runes_code .. runes[v].wowhead_id;
    --end

    --return talent_code .. "_" .. runes_code;
    return talent_code .. "_";
end

local function talent_table(wowhead_code)
    local talents_t = {};

    for k, v in pairs(sc.talent_order) do
        for i, _ in pairs(v) do
            talents_t[k*100+i] = 0;
        end
    end

    local i = 1;
    local tree_index = 1;
    local talent_index = 1;

    while wowhead_code:sub(i, i) ~= "" and wowhead_code:sub(i, i) ~= "_" do
        if wowhead_code:sub(i, i) == "-" then
            tree_index = tree_index + 1;
            talent_index = 1;
        elseif tonumber(wowhead_code:sub(i, i)) then
            talents_t[tree_index*100 + talent_index] = tonumber(wowhead_code:sub(i, i));
            talent_index = talent_index + 1;
        end
        i = i + 1;
    end

    --local runes_table = {};
    --if wowhead_code:sub(i, i) == "_" then
    --    i = i + 2;
    --    while wowhead_code:sub(i, i + 3) ~= "" do
    --        local rune_code = wowhead_code:sub(i, i + 3);
    --        if rune_code ~= "" then
    --            local rune_id = wowhead_rune_code_to_id[rune_code];
    --            if rune_id then
    --                runes_table[rune_id] = runes[rune_id];
    --            end
    --            i = i + 4;
    --        else
    --            break;
    --        end
    --    end
    --end

    --return talents_t, runes_table;
    return talents_t;
end
local weapon_skill_collapsed_one_time_warned = false;
local function apply_talents(loadout, effects)

    -- weapon skills 
    for i = 1, GetNumSkillLines() do
        local skill_lname, _, _, skill = GetSkillLineInfo(i);
        local wep_subclass = sc.wpn_skill_lname_to_subclass[skill_lname];
        if wep_subclass then
            loadout.wpn_skills[wep_subclass] = skill;
        end
    end
    --if not found_any and not weapon_skill_collapsed_one_time_warned then
    --    print("SpellCoda: Could not read weapon skill. Assuming max. Make sure \"Weapon Skills\" in \"Skills\" tab is not collapsed.");
    --    weapon_skill_collapsed_one_time_warned = true;
    --end

    local dynamic_talents, _ = talent_table(config.loadout.talents_code);
    local custom_talents, _ = nil, nil;

    if not config.loadout.use_custom_talents then
        loadout.talents_table = dynamic_talents;
    else
        custom_talents, _ = talent_table(config.loadout.custom_talents_code);
        loadout.talents_table = custom_talents;
    end

    for id, pts in pairs(loadout.talents_table) do
        if pts > 0 and sc.talent_ranks[id] then
            local effect_id = sc.talent_ranks[id][pts];
            if effect_id then
                sc.loadout.apply_effect(loadout,
                                         effects,
                                         effect_id,
                                         sc.talent_effects[effect_id],
                                         config.loadout.use_custom_talents,
                                         1,
                                         false);
            end
        end
    end
    --if config.loadout.use_custom_talents then
    --    -- undo dynamic talents
    --    for id, pts in pairs(dynamic_talents) do
    --        if pts > 0 and sc.talent_ranks[id] then
    --            local effect_id = sc.talent_ranks[id][pts];
    --            if effect_id then
    --                sc.loadout.apply_effect(loadout,
    --                                         effects,
    --                                         effect_id,
    --                                         sc.talent_effects[effect_id],
    --                                         false,
    --                                         1,
    --                                         true);
    --            end
    --        end
    --    end
    --end

    if sc.core.__sw__test_all_codepaths then
        --for k, v in pairs(runes) do
        --    loadout.runes[k] = v;
        --    if v.apply then
        --        v.apply(loadout, effects, true);
        --    end
        --end
        --for k, v in pairs(talents) do
        --    for i = 1, 3 do
        --        for j = 1, 29 do
        --            local id = i*100 + j;
        --            if custom_talents then
        --                custom_talents[id] = 5;
        --            end
        --            if dynamic_talents then
        --                dynamic_talents[id] = 5;
        --            end
        --        end
        --    end
        --    if v.apply then
        --        v.apply(loadout, effects, 3, 3);
        --    end
        --end
        -- Testing all special passives
        local passives_applied = 0;
        for id, e in pairs(sc.special_passives) do
            sc.loadout.apply_effect(loadout, effects, id, e, true, 1);
            passives_applied = passives_applied + 1;
        end

        print(passives_applied, "gen special passives applied");

        -- Testing all talents
        local applied = 0;
        for _, v in pairs(sc.talent_ranks) do
            for _, i in pairs(v) do
                sc.loadout.apply_effect(loadout, effects, i, sc.talent_effects[i], true, 1);
                applied = applied + 1;
            end
        end
        print(applied, "gen talents applied");

    end
end

talents_export.wowhead_talent_link = wowhead_talent_link
talents_export.wowhead_talent_code_from_url = wowhead_talent_code_from_url;
talents_export.wowhead_talent_code = wowhead_talent_code;
talents_export.talent_table = talent_table;
talents_export.apply_talents = apply_talents;
talents_export.rune_ids = rune_ids;

sc.talents = talents_export;
