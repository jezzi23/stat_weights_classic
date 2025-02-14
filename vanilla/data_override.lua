-- All manual overrides, additions or removals to generated data goes in here
-- Things that:
-- 1) is not available in parsed client data
-- 2) fixes problematic generated data
-- 3) removes unwanted behaviour 
local _, sc = ...;

local spells                        = sc.spells;
local spids                         = sc.spids;
local spell_flags                   = sc.spell_flags;
local rank_seqs                     = sc.rank_seqs;

-- Helper functions
local function spell_coef_lvl_adjusted(coef, lvl_req)
    local coef_mod = 1.0;
    if (lvl_req ~= 0) then
        coef_mod = math.min(1, 1 - (20 - lvl_req) * 0.0375);
    end
    return coef * coef_mod;
end
local function add_threat_flat_by_rank(list)
    for _, v in ipairs(list) do
        local spell_base_id = v[1];
        local threat_by_rank = v[2];
        for rank, threat in ipairs(threat_by_rank) do
            local spell = spells[rank_seqs[spell_base_id][rank]];
            if spell.direct then
                spell.direct.threat_mod_flat = threat;
            end
        end
    end
end
local function add_threat_mod_all_ranks(list)
    for _, v in ipairs(list) do
        local spell_base_id = v[1];
        local threat_mod = v[2];
        for _, spid in ipairs(rank_seqs[spell_base_id]) do
            local spell = spells[spid];
            if spell.direct then
                spell.direct.threat_mod = threat_mod;
            end
        end
    end
end
---------------------------------------------------------------------------------------------------
-- NOTE:
--  THREAT: Client data does not contain special threat information
--          added to many spells like Sunder armor, Heroic Strike, Mind Blast etc
--          For what it's worth, some threat info is added in this file according to
--          https://www.wowhead.com/classic/guide/threat-overview-classic-wow

-- Class data modification
if sc.class == sc.classes.mage then
    for _, v in pairs(rank_seqs[spids.ice_lance]) do
        spells[v].direct.coef = spell_coef_lvl_adjusted(0.42899999022, spells[v].lvl_req);
    end

    -- THREAT
    add_threat_flat_by_rank({
        { spids.counterspell, {300} },
        { spids.remove_lesser_curse, {14} },
    });
elseif sc.class == sc.classes.druid then
    -- DISABLE JUNK
    spells[spids.swiftmend].flags = bit.band(spells[spids.swiftmend].flags, bit.bnot(spell_flags.eval));
    for _, v in pairs(rank_seqs[spids.frenzied_regeneration]) do
        spells[v].flags = bit.band(spells[v].flags, bit.bnot(spell_flags.eval));
    end

    -- COEF ADJUSTMENTS
    for _, v in pairs(rank_seqs[spids.lifebloom]) do
        spells[v].periodic.coef = spell_coef_lvl_adjusted(0.051, spells[v].lvl_req);
    end
    -- cat has a few spells with AP coef not found in game client
    for _, v in pairs(rank_seqs[spids.ferocious_bite]) do
        spells[v].direct.per_cp_coef_ap = 0.03;
    end
    for _, v in pairs(rank_seqs[spids.rake]) do
        --TODO: Did SOD turbo charge some of these ap scalings?
        spells[v].periodic.coef_ap = 0.02;
        --spells[v].periodic.coef_ap = 0.11215;
    end
    for _, v in pairs(rank_seqs[spids.rip]) do
        spells[v].periodic.coef_ap = 0.04;
    end
    if bit.band(sc.game_mode, sc.game_modes.season_of_discovery) == 0 then
        -- new moonkin passive id in SOD, no way to detect if this is active or not at runtime
        sc.shapeshift_passives[443359] = nil;
    end

    -- THREAT
    add_threat_flat_by_rank({
        { spids.demoralizing_roar, {9, 15, 20, 30, 39} },
        { spids.faerie_fire_feral, {108, 108, 108, 108} },
        { spids.faerie_fire, {108, 108, 108, 108} },
    });
    add_threat_mod_all_ranks({
        {spids.maul, 0.75},
        {spids.swipe, 0.75},
    });
    -- "Dire Bear Form" has a problem with applying "Bear Form" threat passive so add it
    local bear_threat_passive = 21178;
    for _, v in pairs(sc.class_buffs[spids.dire_bear_form]) do
        if v[sc.aura_idx_category] == "applies_aura" and v[sc.aura_idx_effect] == "shapeshift_passives" then
            table.insert(v[sc.aura_idx_subject], bear_threat_passive);
            break;
        end
    end

elseif sc.class == sc.classes.priest then
    for _, v in pairs(rank_seqs[spids.power_word_shield]) do
        spells[v].direct.coef = spell_coef_lvl_adjusted(0.1, spells[v].lvl_req);
    end

    -- THREAT
    add_threat_mod_all_ranks({
        {spids.mind_blast, 1.0}
    });
    for _, v in pairs(rank_seqs[spids.holy_nova]) do
        spells[v].flags = bit.bor(spells[v].flags, spell_flags.no_threat);
        spells[v].healing_version.flags = bit.bor(spells[v].healing_version.flags, spell_flags.no_threat);
    end

elseif sc.class == sc.classes.shaman then
    for _, v in pairs(rank_seqs[spids.earth_shield]) do
        spells[v].direct.coef = spell_coef_lvl_adjusted(0.27099999785, spells[v].lvl_req);
    end

    -- THREAT
    add_threat_mod_all_ranks({
        {spids.earth_shock, 1.0}
    });

elseif sc.class == sc.classes.warlock then

    -- THREAT
    add_threat_mod_all_ranks({
        {spids.searing_pain, 1.0}
    });
elseif sc.class == sc.classes.rogue then
    -- rogue has a few spells with AP coef not found in game client
    for _, v in pairs(rank_seqs[spids.rupture]) do
        spells[v].periodic.per_cp_dur = 2;
        spells[v].periodic.coef_ap_by_cp = {0.01, 0.02, 0.03, 0.03, 0.03}; -- scuffed scaling
    end
    for _, v in pairs(rank_seqs[spids.eviscerate]) do
        spells[v].direct.per_cp_coef_ap = 0.03;
    end
    for _, v in pairs(rank_seqs[spids.garrote]) do
        spells[v].periodic.coef_ap = 0.03;
    end
elseif sc.class == sc.classes.paladin then
    sc.friendly_buffs[407613] = {}; -- beacon of light, dummy value - handled manually

    add_threat_flat_by_rank({
        { spids.holy_shield, {20, 30, 40} },
        { spids.cleanse, {40} },
    });

elseif sc.class == sc.classes.warrior then

    sc.shapeshift_id_to_effects = {
        [1] = {21156}, -- battle
        [2] = {7376}, -- defensive
        [3] = {7381}, -- berserker
        [4] = {413479}, -- gladiator
    }
    for _, v in pairs(rank_seqs[spids.bloodthirst]) do
        spells[v].direct.coef_ap = 0.01*spells[v].direct.min;
        spells[v].direct.min = 0;
        spells[v].direct.max = 0;
    end
    -- THREAT
    add_threat_mod_all_ranks({
        {spids.execute, 0.25}
    });

    add_threat_flat_by_rank({
        { spids.revenge, {155, 195, 235, 275, 315, 355} },
        { spids.shield_slam, {160, 190, 220, 250} },
        { spids.sunder_armor, {100, 140, 180, 220, 260} },
        { spids.shield_bash, {180, 180, 180} },
        { spids.thunder_clap, {17, 40, 64, 96, 143, 180} },
        { spids.battle_shout, {5, 11, 17, 26, 39, 55, 70} },
        { spids.cleave, {10, 40, 60, 70, 100} },
        { spids.demoralizing_shout, {11, 17, 21, 32, 43} },
        { spids.heroic_strike, {20, 39, 59, 78, 98, 118, 137, 145, 175} },
        { spids.hamstring, {61, 101, 141} },
    });
end

-- Remove eval from wands while broken
if spells[5019] then
    spells[5019].flags = bit.band(spells[5019].flags, bit.bnot(spell_flags.eval));
end

