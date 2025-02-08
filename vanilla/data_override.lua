-- All manual overrides and additions or removal to generated data that
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

-- Class data modification
if sc.class == sc.classes.mage then
    for _, v in pairs(rank_seqs[spids.ice_lance]) do
        spells[v].direct.coef = spell_coef_lvl_adjusted(0.42899999022, spells[v].lvl_req);
    end
elseif sc.class == sc.classes.druid then
    -- Disable some janky spells
    spells[spids.swiftmend].flags = bit.band(spells[spids.swiftmend].flags, bit.bnot(spell_flags.eval));
    for _, v in pairs(rank_seqs[spids.frenzied_regeneration]) do
        spells[v].flags = bit.band(spells[v].flags, bit.bnot(spell_flags.eval));
    end

    for _, v in pairs(rank_seqs[spids.lifebloom]) do
        spells[v].periodic.coef = spell_coef_lvl_adjusted(0.051, spells[v].lvl_req);
    end
    -- cat has a few spells wth AP coef not found in game client
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
elseif sc.class == sc.classes.priest then
    for _, v in pairs(rank_seqs[spids.power_word_shield]) do
        spells[v].direct.coef = spell_coef_lvl_adjusted(0.1, spells[v].lvl_req);
    end
elseif sc.class == sc.classes.shaman then
    for _, v in pairs(rank_seqs[spids.earth_shield]) do
        spells[v].direct.coef = spell_coef_lvl_adjusted(0.27099999785, spells[v].lvl_req);
    end

elseif sc.class == sc.classes.rogue then
    -- rogue has a few spells wth AP coef not found in game client
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

elseif sc.class == sc.classes.warrior then
    for _, v in pairs(rank_seqs[spids.bloodthirst]) do
        spells[v].direct.coef_ap = 0.01*spells[v].direct.min;
        spells[v].direct.min = 0;
        spells[v].direct.max = 0;
    end
end

