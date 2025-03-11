local utils = {};

local _, sc = ...;

local spells                        = sc.spells;
local spell_flags                   = sc.spell_flags;
local rank_seqs                     = sc.rank_seqs;
---------------------------------------------------------------------------------------------------

local function deep_table_copy(obj, seen)
  if type(obj) ~= 'table' then
      return obj;
  end
  if seen and seen[obj] then
      return seen[obj];
  end
  local s = seen or {};
  local res = setmetatable({}, getmetatable(obj));
  s[obj] = res;
  for k, v in pairs(obj) do
      res[deep_table_copy(k, s)] = deep_table_copy(v, s);
  end
  return res;
end

local function spell_cost(spell_id)

    local costs = GetSpellPowerCost(spell_id);
    if costs then
        local cost_table = costs[1];
        if cost_table then
            if cost_table.cost then
                return cost_table.cost, cost_table.name;
            else
                return nil;
            end
        end
    end
end

local function spell_cast_time(spell_id)

    local cast_time = select(4, GetSpellInfo(spell_id));
    if cast_time  then
        cast_time = cast_time/1000;
    end
    if spells[spell_id] then
        cast_time = cast_time or 0.0;
        cast_time = math.max(spells[spell_id].gcd, cast_time);
    end

    return cast_time;
end

local function best_rank_by_lvl(spell, lvl)
    local n = #sc.rank_seqs[spell.base_id];
    local i = n;
    while i ~= 0 do
        if spells[sc.rank_seqs[spell.base_id][i]].lvl_req <= lvl then
            return spells[sc.rank_seqs[spell.base_id][i]];
        end
        i = i - 1;
    end
    return nil;
end

local function highest_learned_rank(base_id)
    local n = #sc.rank_seqs[base_id];
    local i = n;
    while i ~= 0 do
        if IsSpellKnownOrOverridesKnown(sc.rank_seqs[base_id][i]) or
            IsSpellKnownOrOverridesKnown(sc.rank_seqs[base_id][i], true) then
            return sc.rank_seqs[base_id][i];
        end
        i = i - 1;
    end
    return nil;
end

local function next_rank(spell_data)
    return spells[sc.rank_seqs[spell_data.base_id][spell_data.rank + 1]];
end


local effect_colors = {
    hit_chance              = { 232 / 255, 225 / 255,  32 / 255 },
    target_info             = {  70 / 255, 130 / 255, 180 / 255 },
    avoidance_info          = {  70 / 255, 130 / 255, 180 / 255 },
    normal                  = { 232 / 255, 225 / 255,  32 / 255 },
    crit                    = { 252 / 255,  69 / 255,   3 / 255 },
    expectation             = { 255 / 255, 128 / 255,   0 / 255 },
    effect_per_sec          = { 255 / 255, 128 / 255,   0 / 255 },
    avg_cast                = { 149 / 255,  53 / 255,  83 / 255 },
    avg_cost                = {   0 / 255, 255 / 255, 255 / 255 },
    effect_per_cost         = {   0 / 255, 255 / 255, 255 / 255 },
    cost_per_sec            = {   0 / 255, 255 / 255, 255 / 255 },
    effect_until_oom        = { 255 / 255, 128 / 255,   0 / 255 },
    casts_until_oom         = {   0 / 255, 255 / 255,   0 / 255 },
    time_until_oom          = {   0 / 255, 255 / 255,   0 / 255 },
    sp_effect               = { 138 / 255, 134 / 255, 125 / 255 },
    stat_weights            = {   0 / 255, 255 / 255,   0 / 255 },
    spell_rank              = { 138 / 255, 134 / 255, 125 / 255 },
    threat                  = { 150 / 255, 105 / 255,  25 / 255 },
};

local function effect_color(effect)
    return effect_colors[effect][1], effect_colors[effect][2], effect_colors[effect][3];
end

local function color_by_lvl_diff(clvl, other_lvl)
    if other_lvl + 6 <= clvl then
        return "|cFFA9A9A9";
    elseif other_lvl + 3 <= clvl then
        return "|cFF00FF00";
    elseif other_lvl - 2 <= clvl then
        return "|cFFFFFF00";
    elseif other_lvl - 3 <= clvl then
        return "|cFFFF4500";
    else
        return "|cFFFF0000";
    end
end

local function format_number(val, max_accuracy_digits)

    if not val then
        return "";
    end
    local abs_val = math.abs(val);
    if val ~= val then
        return "∞";
    elseif (abs_val < 100.0 and max_accuracy_digits >= 2) then
        return string.format("%.2f", val);
    elseif (abs_val < 1000.0 and max_accuracy_digits >= 1) then
        return string.format("%.1f", val);
    elseif (abs_val < 10000.0) then
        return string.format("%d", 0.5+math.floor(val));
    elseif (abs_val < 1000000.0) then
        return string.format("%.1fk", val/1000);
    elseif (abs_val < 10000000000.0) then
        return string.format("%.1fm", val/1000000);
    else
        return "∞";
    end
end
local function format_number_signed_colored(val, max_accuracy_digits)

    local normal_format = format_number(val, max_accuracy_digits);

    if normal_format == "∞" then
        return normal_format;
    elseif val < 0 then
        return "|cFFFF0000"..normal_format.."|r";
    elseif val > 0 then
        return "|cFF00FF00"..normal_format.."|r";
    else
        return normal_format;
    end
end

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
            local anycomp = spell.direct or spell.periodic;
            if bit.band(spell.flags, spell_flags.eval) ~= 0 then
                anycomp.threat_mod_flat = (anycomp.threat_mod_flat or 0.0) + threat;
            else
                -- spell is without any components
                spell.periodic = nil;
                if not spell.direct then
                    spell.direct = {};
                    spell.direct.flags = 0;
                end
                spell.direct.threat_mod_flat = (spell.direct.threat_mod_flat or 0.0) + threat;
                -- spells with no eval will have anyschool defined
                spell.direct.school1 = spell.anyschool;
                spell.flags = bit.bor(spell.flags, spell_flags.only_threat);
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
            if spell.periodic then
                spell.periodic.threat_mod = threat_mod;
            end
        end
    end
end

utils.deep_table_copy               = deep_table_copy;
utils.spell_cost                    = spell_cost;
utils.spell_cast_time               = spell_cast_time;
utils.format_number                 = format_number;
utils.color_by_lvl_diff             = color_by_lvl_diff;
utils.format_number_signed_colored  = format_number_signed_colored;
utils.best_rank_by_lvl              = best_rank_by_lvl;
utils.highest_learned_rank          = highest_learned_rank
utils.next_rank                     = next_rank;
utils.effect_color                  = effect_color;
utils.effect_colors                 = effect_colors;
utils.spell_coef_lvl_adjusted       = spell_coef_lvl_adjusted;
utils.add_threat_flat_by_rank       = add_threat_flat_by_rank;
utils.add_threat_mod_all_ranks      = add_threat_mod_all_ranks;


sc.utils = utils;
sc.ext = {};

