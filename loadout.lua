local _, sc = ...;

local attr                              = sc.attr;
local classes                           = sc.classes;
local powers                            = sc.powers;
local class                             = sc.class;
local deep_table_copy                   = sc.utils.deep_table_copy;

local category_idx                      = sc.aura_idx_category;
local effect_idx                        = sc.aura_idx_effect;
local value_idx                         = sc.aura_idx_value;
local subject_idx                       = sc.aura_idx_subject;
local flags_idx                         = sc.aura_idx_flags;
local iid_idx                           = sc.aura_idx_iid; -- internal index within this spell id

local mana_per_int                      = sc.scaling.mana_per_int;
local int_to_spell_crit                 = sc.scaling.int_to_spell_crit;
local agi_to_physical_crit              = sc.scaling.agi_to_physical_crit;
local ap_per_str                        = sc.scaling.ap_per_str;
local ap_per_agi                        = sc.scaling.ap_per_agi;
local rap_per_agi                       = sc.scaling.rap_per_agi;

local config                            = sc.config;

--------------------------------------------------------------------------------
local loadout = {};

local loadout_flags = {
    has_target                          = bit.lshift(1, 1),
    target_friendly                     = bit.lshift(1, 2),
    target_pvp                          = bit.lshift(1, 3),
    --target_snared                       = bit.lshift(1, 2),
    --target_frozen                       = bit.lshift(1, 3),
};


-- Loadout and Effects split into sections by types to make comparing, iterating, merging
-- not need a slower general purpose recursive implementation
local loadout_numbers = {
    "armor",
    "player_hp_perc",
    "enemy_hp_perc",
    "flags",
    "lvl",
    "target_lvl",
    "haste_rating",
    "crit_rating",
    "hit_rating",
    "phys_hit",
    "spell_dmg",
    "healing_power",
    "spell_power",
    "attack_power",
    "extra_mana",
    "base_mana",
    "ap",
    "rap",
    "ranged_skill",
    "m1_skill",
    "m2_skill",
    "melee_crit",
    "ranged_crit",
    "block_value",
    "r_speed",
    "r_min",
    "r_max",
    "r_pos",
    "r_neg",
    "r_mod",
    "m1_min",
    "m1_max",
    "m2_min",
    "m2_max",
    "m_pos",
    "m_neg",
    "m_mod",
    "m1_speed",
    "m2_speed",
    "shapeshift",
    "shapeshift_no_weapon",
    "target_defense",
    "target_creature_mask",
};

local loadout_tables = {
    stats = {0, 0, 0, 0, 0},
    resources = {
        [sc.powers.mana] = 0,
        [sc.powers.rage] = 0,
        [sc.powers.energy] = 0,
        [sc.powers.combopoints] = 0,
    },
    resources_max = {
        [sc.powers.mana] = 0,
        [sc.powers.rage] = 0,
        [sc.powers.energy] = 0,
        [sc.powers.combopoints] = 0,
    },
    spell_dmg_by_school     = {0, 0, 0, 0, 0, 0, 0},
    spell_dmg_hit_by_school = {0, 0, 0, 0, 0, 0, 0},
    spell_crit_by_school    = {0, 0, 0, 0, 0, 0, 0},
};

local loadout_strs = {
    "player_name",
    "target_name",
    "hostile_towards",
    "friendly_towards",
    "target_creature_type",
};

local loadout_units = {
    "player", "target", "mouseover"
};


local function loadout_zero()
    local empty = {};

    for _, v in ipairs(loadout_numbers) do
        empty[v] = 0;
    end
    for _, v in ipairs(loadout_strs) do
        empty[v] = "";
    end
    for k, v in pairs(loadout_tables) do
        empty[k] = {};
        for kk, vv in pairs(v) do
            empty[k][kk] = vv;
        end
    end
    empty.dynamic_buffs = {};
    for _, v in ipairs(loadout_units) do
        empty.dynamic_buffs[v] = {};
    end

    return empty;
end

local function loadout_eql(lhs, rhs)

    for _, v in ipairs(loadout_numbers) do
        if lhs[v] ~= rhs[v] then
            return false;
        end
    end
    for _, v in ipairs(loadout_strs) do
        if lhs[v] ~= rhs[v] then
            return false;
        end
    end

    for k, v in pairs(loadout_tables) do
        for kk, vv in pairs(v) do
            if lhs[k][kk] ~= rhs[k][kk] then
                return false;
            end
        end
    end

    for _, v in ipairs(loadout_units) do
        for id, _ in pairs(lhs.dynamic_buffs[v]) do
            if not rhs.dynamic_buffs[v][id] then
                return false;
            end
        end
        for id, buff_data in pairs(rhs.dynamic_buffs[v]) do
            if not lhs.dynamic_buffs[v][id] then
                return false;
            else
                for kk, vv in pairs(buff_data) do
                    if lhs.dynamic_buffs[v][id][kk] ~= vv then
                        return false;
                    end
                end
            end
        end
    end
    return true;
end


local effect_categories = {
    "by_school",
    "by_attr",
    "raw",
    "ability",
    "aura_pts",
    "aura_pts_flat",
    "wpn_subclass",
    "creature",
};

local effects_additive = {
    by_school = {
        "spell_hit",
        "crit_mod",
        "sp_dmg_flat",
        "crit",
        "target_res",
        "target_res_flat",
        "threat",
        "cost_mod",
    },
    by_attr = {
        "stats",
        "stat_mod",
        "sp_from_stat_mod",
        "hp_from_stat_mod",
        "crit_from_stat_mod",
    },
    ability = {
        "threat",
        "threat_flat",
        "crit",
        "ignore_cant_crit",
        "effect_mod",
        "effect_mod_flat",
        "effect_mod_ot",
        "effect_mod_ot_flat",
        "base_mod",
        "base_mod_flat",
        "base_mod_ot",
        "base_mod_ot_flat",
        "cast_mod_flat",
        "cast_mod",
        "extra_dur_flat",
        "extra_dur",
        "extra_tick_time_flat",
        "cost_mod",
        "cost_mod_flat",
        "crit_mod",
        "hit",
        "sp_flat",
        "flat_add",
        "flat_add_ot",
        "refund",
        "coef_mod",
        "coef_mod_flat",
        "effect_mod_only_heal",
        "jumps_flat",
        "jump_amp",
        "gcd_flat",
    },
    -- effects that affects the base value (points) of other subauras
    -- indexed by the aura internal idx
    aura_pts = {
        -1, 0, 1, 2, 3, 4
    },
    aura_pts_flat = {
        -1, 0, 1, 2, 3, 4
    },
    wpn_subclass = {
        "phys_crit",
        "phys_crit_forced",
        "phys_hit",
        "phys_hit",
        "phys_dmg",
        "phys_dmg_flat",
    },
    creature = {
        "crit_mod"
    },
    raw = {
        "mana_mod",
        "mana_mod_active",
        "mana",
        "mp5_from_int_mod",
        "mp5",
        "perc_max_mana_as_mp5",
        "regen_while_casting",
        "spell_power",
        "spell_dmg",
        "healing_power_flat",
        "phys_dmg_flat",
        "ap_flat",
        "rap_flat",
        "cast_haste",
        "cost_mod",
        "phys_hit",
        "phys_crit",
        "phys_crit_forced",
        "offhand_mod",
        "extra_hits_flat",
        "haste_rating",
        "crit_rating",
        "hit_rating",
        "skill",
        "class_misc",
    },
};

local effects_multiplicative = {
    by_school = {
        "vuln_mod",
        "dmg_mod",
    },
    ability = {
        "vuln_mod",
    },
    wpn_subclass = {
        "phys_mod",
        "spell_mod", -- Wand mods apply this
    },
    creature = {
        "dmg_mod",
    },
    raw = {
        "phys_mod",
        "heal_mod",
        "vuln_heal",
        "vuln_phys",
        "melee_haste",
        "melee_haste_forced",
        "ranged_haste",
        "ranged_haste_forced",
        "cast_haste",
    },
};

local function empty_effects(effects)

    effects.mul = {};
    for _, v in ipairs(effect_categories) do
        effects[v] = {};
        effects.mul[v] = {};
    end

    for _, v in pairs(effects_additive.by_school) do
        effects.by_school[v] = {0, 0, 0, 0, 0, 0, 0};
    end
    for _, v in pairs(effects_additive.by_attr) do
        effects.by_attr[v] = {0, 0, 0, 0, 0};
    end
    for _, v in pairs(effects_additive.ability) do
        effects.ability[v] = {};
    end
    for _, v in pairs(effects_additive.aura_pts) do
        effects.aura_pts[v] = {};
    end
    for _, v in pairs(effects_additive.aura_pts_flat) do
        effects.aura_pts_flat[v] = {};
    end
    for _, v in pairs(effects_additive.wpn_subclass) do
        effects.wpn_subclass[v] = {};
    end
    for _, v in pairs(effects_additive.creature) do
        effects.creature[v] = {};
    end
    for _, v in pairs(effects_additive.raw) do
        effects.raw[v] = 0;
    end

    for _, v in pairs(effects_multiplicative.by_school) do
        effects.mul.by_school[v] = {1, 1, 1, 1, 1, 1, 1};
    end
    for _, v in pairs(effects_multiplicative.ability) do
        effects.mul.ability[v] = {};
    end
    for _, v in pairs(effects_multiplicative.wpn_subclass) do
        effects.mul.wpn_subclass[v] = {};
    end
    for _, v in pairs(effects_multiplicative.creature) do
        effects.mul.creature[v] = {};
    end
    for _, v in pairs(effects_multiplicative.raw) do
        effects.mul.raw[v] = 1;
    end
end

local function cpy_effects(dst, src)

    for _, cat in ipairs(effect_categories) do
        local dst_cat = dst[cat];
        local src_cat = src[cat];
        for i, src_e in pairs(src_cat) do
            if type(src_e) == "table" then
                local dst_e = dst_cat[i];
                for j, _ in pairs(dst_e) do
                    if not src_e[j] then
                        -- prevent values in src that are not in dst
                        dst_e[j] = 0.0;
                    end
                end

                for j, _ in pairs(src_e) do
                    dst_e[j] = src_e[j];
                end
            else
                dst_cat[i] = src_cat[i];
            end
        end
    end

    for _, cat in ipairs(effect_categories) do
        local dst_cat = dst.mul[cat];
        local src_cat = src.mul[cat];
        for i, src_e in pairs(src_cat) do
            if type(src_e) == "table" then
                local dst_e = dst_cat[i];
                for j, _ in pairs(dst_e) do
                    if not src_e[j] then
                        -- prevent values in src that are not in dst
                        dst_e[j] = 1.0;
                    end
                end

                for j, _ in pairs(src_e) do
                    dst_e[j] = src_e[j];
                end
            else
                dst_cat[i] = src_cat[i];
            end
        end
    end
end

local function zero_effects(effects)

    for _, cat in ipairs(effect_categories) do
        local effect_cat = effects[cat];
        for i, e in pairs(effect_cat) do
            if type(e) == "table" then
                for j, _ in pairs(e) do
                    e[j] = 0.0;
                end
            else
                effect_cat[i] = 0.0;
            end
        end
    end

    for _, cat in ipairs(effect_categories) do
        local effect_cat = effects.mul[cat]
        for i, e in pairs(effect_cat) do
            if type(e) == "table" then
                for j, _ in pairs(e) do
                    e[j] = 1.0;
                end
            else
                effect_cat[i] = 1.0;
            end
        end
    end
end

local function effects_add(dst, src)


    for _, cat in ipairs(effect_categories) do
        local dst_cat = dst[cat];
        local src_cat = src[cat];
        for i, src_e in pairs(src_cat) do
            if type(src_e) == "table" then
                local dst_e = dst_cat[i];
                for j, v in pairs(src_e) do
                    dst_e[j] = (dst_e[j] or 0.0) + v;
                end
            else
                dst_cat[i] = dst_cat[i] + src_cat[i];
            end
        end
    end
    for _, cat in ipairs(effect_categories) do
        local dst_cat = dst.mul[cat];
        local src_cat = src.mul[cat];
        for i, src_e in pairs(src_cat) do
            if type(src_e) == "table" then
                local dst_e = dst_cat[i];
                for j, v in pairs(src_e) do
                    dst_e[j] = (dst_e[j] or 1.0) * v;
                end
            else
                dst_cat[i] = dst_cat[i] * src_cat[i];
            end
        end
    end

end

local function effects_zero_diff()
    return {
        stats = {0, 0, 0, 0, 0},
        mp5 = 0,
        sp = 0,
        sd = 0,
        hp = 0,
        ap = 0,
        rap = 0,
        hit_rating = 0,
        haste_rating = 0,
        crit_rating = 0,
        spell_pen = 0,

        weapon_skill = 0,
    };
end

local function effects_from_ui_diff(frame)

    local stats = frame.stats;
    local diff = effects_zero_diff();

    -- verify validity and run input expr 
    for _, v in pairs(stats) do

        local expr_str = v.editbox:GetText();

        local is_whitespace_expr = expr_str and string.match(expr_str, "%S") == nil;
        local is_valid_expr = string.match(expr_str, "[^-+0123456789. ()]") == nil

        local expr = nil;
        if is_valid_expr then
            expr = loadstring("return "..expr_str..";");
            if expr then
                v.editbox_val = expr();
                frame.is_valid = true;
            end
        end
        if is_whitespace_expr or not is_valid_expr or not expr then

            v.editbox_val = 0;
            if not is_whitespace_expr then
                frame.is_valid = false;
                return diff;
            end
        end
    end

    diff.stats[attr.intellect] = stats.int.editbox_val;
    diff.stats[attr.spirit] = stats.spirit.editbox_val;
    diff.stats[attr.strength] = stats.str.editbox_val;
    diff.stats[attr.agility] = stats.agi.editbox_val;
    diff.mp5 = stats.mp5.editbox_val;

    diff.crit_rating = stats.crit_rating.editbox_val;
    diff.hit_rating = stats.hit_rating.editbox_val;
    diff.haste_rating = stats.haste_rating.editbox_val;

    diff.sp = stats.sp.editbox_val;
    diff.sd = stats.sd.editbox_val;
    diff.hp = stats.hp.editbox_val;
    diff.ap = stats.ap.editbox_val;
    diff.rap = stats.rap.editbox_val;
    diff.weapon_skill = stats.wep.editbox_val;
    diff.spell_pen = stats.spell_pen.editbox_val;

    frame.is_valid = true;

    return diff;
end

local diff_stats_gained = {};
local function effects_diff(loadout, effects, diff)

    for i = 1, 5 do
        diff_stats_gained[i] = diff.stats[i] * (1 + effects.by_attr.stat_mod[attr.spirit]);
    end
    local sp_gained_from_spirit = diff_stats_gained[attr.spirit] * effects.by_attr.sp_from_stat_mod[attr.spirit];
    local sp_gained_from_int = diff_stats_gained[attr.intellect] * effects.by_attr.sp_from_stat_mod[attr.intellect];
    local sp_gained_from_stat = sp_gained_from_spirit + sp_gained_from_int;

    local hp_gained_from_spirit = diff_stats_gained[attr.spirit] * effects.by_attr.hp_from_stat_mod[attr.spirit];
    local hp_gained_from_int = diff_stats_gained[attr.intellect] * effects.by_attr.hp_from_stat_mod[attr.intellect];
    local hp_gained_from_stat = hp_gained_from_spirit + hp_gained_from_int;

    effects.raw.spell_power = effects.raw.spell_power + diff.sp;
    effects.raw.spell_dmg = effects.raw.spell_dmg + diff.sd + sp_gained_from_stat;
    effects.raw.healing_power_flat = effects.raw.healing_power_flat + diff.hp + hp_gained_from_stat;

    effects.raw.mp5 = effects.raw.mp5 + diff.mp5;
    effects.raw.mp5 = effects.raw.mp5 + diff_stats_gained[attr.intellect] * effects.raw.mp5_from_int_mod;

    local crit_from_int = int_to_spell_crit(diff_stats_gained[attr.intellect], loadout.lvl);
    local crit_from_spirit = diff_stats_gained[attr.spirit]*effects.by_attr.crit_from_stat_mod[attr.spirit];
    local spell_crit = crit_from_spirit + crit_from_int;
    for i = 1, 7 do
        effects.by_school.crit[i] = effects.by_school.crit[i] + spell_crit;
    end

    effects.raw.mana = effects.raw.mana + (diff_stats_gained[attr.intellect] * mana_per_int)*(1.0 + effects.raw.mana_mod);

    effects.raw.haste_rating = effects.raw.haste_rating + diff.haste_rating;
    effects.raw.crit_rating = effects.raw.crit_rating + diff.crit_rating;
    effects.raw.hit_rating = effects.raw.hit_rating + diff.hit_rating;

    for i = 1, 5 do
        effects.by_attr.stats[i] = effects.by_attr.stats[i] + diff.stats[i];
    end
    for i = 2, 7 do
        effects.by_school.target_res_flat[i] = effects.by_school.target_res_flat[i] - diff.spell_pen;
    end

    -- physical stuff

    local agi_ap_class = class;
    if class == classes.druid and loadout.shapeshift == 3 then
        -- cat form
        agi_ap_class = classes.rogue;
    end

    local added_ap = diff.ap +
        diff_stats_gained[attr.strength] * ap_per_str[class] +
        diff_stats_gained[attr.agility] * ap_per_agi[agi_ap_class];
    effects.raw.ap_flat = effects.raw.ap_flat + added_ap;

    local added_rap = diff.rap + diff_stats_gained[attr.agility] * rap_per_agi[class];
    effects.raw.rap_flat = effects.raw.rap_flat + added_rap;

    effects.raw.phys_crit = effects.raw.phys_crit +
        agi_to_physical_crit(diff_stats_gained[attr.agility], loadout.lvl);

    effects.raw.skill = effects.raw.skill + diff.weapon_skill;
end

local function dynamic_loadout(loadout)
    if not config.loadout.use_custom_lvl then
        loadout.lvl = UnitLevel("player");
    else
        loadout.lvl = config.loadout.lvl;
    end

    for i = 1, 5 do
        local _, s, _, _ = UnitStat("player", i);
        loadout.stats[i] = s;
    end

    for pwr, _ in pairs(loadout.resources_max) do
        loadout.resources_max[pwr] = math.max(1, UnitPowerMax("player", pwr));
    end
    if config.loadout.always_max_resource then
        for pwr, _ in pairs(loadout.resources) do
            loadout.resources[pwr] = loadout.resources_max[pwr];
        end
    else
        for pwr, _ in pairs(loadout.resources) do
            loadout.resources[pwr] = UnitPower("player", pwr);
        end
    end
    loadout.extra_mana = config.loadout.extra_mana;
    -- always put at least 1 combo point to at least resemble spell descriptions
    loadout.resources[powers.combopoints] = math.max(1, loadout.resources[powers.combopoints]);

    loadout.base_mana = 0;
    if sc.base_mana_by_lvl then
        loadout.base_mana = sc.base_mana_by_lvl[loadout.lvl];
    end


    loadout.haste_rating = 0;
    loadout.hit_rating = 0;
    loadout.phys_hit = 0;
    local phys_hit = GetSpellHitModifier();
    if phys_hit then
        loadout.phys_hit = 0.01*phys_hit;
    end

    if sc.expansion == sc.expansions.vanilla then
        loadout.healing_power = GetSpellBonusHealing();
        for i = 1, 7 do
            loadout.spell_dmg_by_school[i] = GetSpellBonusDamage(i);
        end
        loadout.spell_dmg_by_school[1] = loadout.spell_dmg_by_school[2];
        -- use holy as +all schools baseline, write to physical so singular sp by schools can be 
        -- detected for multischool spells
        --for i = 3, 7 do
        --    loadout.spell_dmg_by_school[i] = math.min(loadout.spell_dmg_by_school[1],
        --                                              loadout.spell_dmg_by_school[i]);
        --end

        -- right after load GetSpellHitModifier seems to sometimes returns a nil.... so check first I guess
       local spell_hit = 0;
       local api_hit = GetSpellHitModifier();
       if api_hit then
           spell_hit = 0.01*api_hit;
       end
       for i = 1, 7 do
           loadout.spell_dmg_hit_by_school[i] = spell_hit;
       end
    else
        -- in wotlk, healing power will equate to spell power
        loadout.spell_power = GetSpellBonusHealing();
        for i = 1, 7 do
            loadout.spell_dmg_by_school[i] = GetSpellBonusDamage(i) - loadout.spell_power;
        end

        -- crit and hit is already gathered indirectly from rating, but not haste
        loadout.haste_rating = GetCombatRating(CR_HASTE_SPELL);
        loadout.hit_rating = GetCombatRating(CR_HIT_SPELL);
    end

    for i = 1, 7 do
        loadout.spell_crit_by_school[i] = GetSpellCritChance(i)*0.01;
    end
    local ap_src1, ap_src2, ap_src3 = UnitAttackPower("player");
    loadout.ap = ap_src1 + ap_src2 + ap_src3;
    local rap_src1, rap_src2, rap_src3 = UnitRangedAttackPower("player");
    loadout.rap = rap_src1 + rap_src2 + rap_src3;

    local r_skill_base, r_skill_mod = UnitRangedAttack("player");
    loadout.ranged_skill = r_skill_base + r_skill_mod;
    local m1_skill_base, m1_skill_mod, m2_skill_base, m2_skill_mod = UnitAttackBothHands("player");
    loadout.m1_skill = m1_skill_base + m1_skill_mod;
    loadout.m2_skill = m2_skill_base + m2_skill_mod;

    loadout.melee_crit = GetCritChance()*0.01;
    loadout.ranged_crit = GetRangedCritChance()*0.01;
    loadout.block_value = GetShieldBlock();

    loadout.r_speed, loadout.r_min, loadout.r_max, loadout.r_pos, loadout.r_neg, loadout.r_mod = UnitRangedDamage("player");

    loadout.m1_min, loadout.m1_max, loadout.m2_min, loadout.m2_max, loadout.m_pos, loadout.m_neg, loadout.m_mod = UnitDamage("player");

    loadout.m1_speed, loadout.m2_speed = UnitAttackSpeed("player");

    loadout.shapeshift = GetShapeshiftForm();
    if sc.class == sc.classes and shapeshift ~= 5 then
        loadout.shapeshift_no_weapon = 1;
    else
        loadout.shapeshift_no_weapon = 0;
    end

    loadout.player_name = UnitName("player");
    loadout.target_name = UnitName("target");
    loadout.mouseover_name = UnitName("mouseover");

    loadout.hostile_towards = "";
    loadout.friendly_towards = "player";

    loadout.flags =
        bit.band(loadout.flags, bit.band(bit.bnot(loadout_flags.has_target),
                                         --bit.bnot(loadout_flags.target_snared),
                                         --bit.bnot(loadout_flags.target_frozen),
                                         bit.bnot(loadout_flags.target_friendly),
                                         bit.bnot(loadout_flags.target_pvp)));

    loadout.player_hp_perc = UnitHealth("player")/math.max(UnitHealthMax("player"), 1);

    loadout.enemy_hp_perc = config.loadout.default_target_hp_perc*0.01;

    loadout.target_creature_mask = 0;

    loadout.target_lvl = config.loadout.default_target_lvl_diff + loadout.lvl;

    if UnitExists("target") then

        loadout.flags = bit.bor(loadout.flags, loadout_flags.has_target);
        loadout.hostile_towards = "target";

        if UnitIsFriend("player", "target") then
            loadout.flags = bit.bor(loadout.flags, loadout_flags.target_friendly);
            loadout.friendly_towards = "target";
        elseif UnitIsPlayer("target") then
            loadout.flags = bit.bor(loadout.flags, loadout_flags.target_pvp);
        end

        local creature = UnitCreatureType("target");
        if creature then
            local creature_id = sc.creature_lname_to_id[creature];
            if creature_id then
                loadout.target_creature_mask = bit.lshift(1, creature_id-1);
            end
        end

        if bit.band(loadout.flags, loadout_flags.target_friendly) == 0 then
            local target_lvl = UnitLevel("target");
            if target_lvl == -1 then
                loadout.target_lvl = loadout.lvl + 3;
            else
                loadout.target_lvl = target_lvl;
            end
        end
    end

    if UnitExists("mouseover") and UnitIsFriend("player", "mouseover") then
        loadout.friendly_towards = "mouseover";
    end
    if loadout.hostile_towards == "target" and bit.band(loadout.flags, loadout_flags.target_friendly) == 0 then
        loadout.enemy_hp_perc = UnitHealth("target")/math.max(UnitHealthMax("target"), 1);
    end

    loadout.friendly_hp_max = math.max(UnitHealthMax(loadout.friendly_towards), 1);
    loadout.friendly_hp_perc = UnitHealth(loadout.friendly_towards)/loadout.friendly_hp_max;

    loadout.target_defense = 5*loadout.target_lvl;

    loadout.armor = config.loadout.target_armor;
    if config.loadout.target_automatic_armor then
        if sc.npc_armor_by_lvl[loadout.target_lvl] then
            loadout.armor = sc.npc_armor_by_lvl[loadout.target_lvl] * config.loadout.target_automatic_armor_pct * 0.01;
        end
    end

    sc.buffs.detect_buffs(loadout);
end

local function apply_effect(effects, spid, auras, forced, stacks, undo, player_owned)
    if not auras then
        --print("Missing aura", spid);
        return;
    end
    local add_all = 0.0;
    local mul_all = 1.0;
    -- affects all internal ids
    if effects.aura_pts_flat[-1][spid] then
        add_all = add_all + effects.aura_pts_flat[-1][spid];
    end
    if effects.aura_pts[-1][spid] then
        mul_all = mul_all + effects.aura_pts[-1][spid];
    end

    for _, aura in pairs(auras) do

        if bit.band(aura[flags_idx], sc.aura_flags.apply_aura) ~= 0 then
            for _, k in pairs(aura[subject_idx]) do
                apply_effect(effects, k, sc[aura[effect_idx]][k], forced, stacks, undo);
            end
        elseif bit.band(aura[flags_idx], sc.aura_flags.requires_ownership) ~= 0 and not player_owned then
            -- skip
        else
            local add;
            local mul;
            if aura[iid_idx] == -1 then
                -- iid_idx == -1 on effect aura means it is a "fake aura", not from client generator
                add = 0;
                mul = 1.0;
            else
                add = add_all;
                mul = mul_all;
            end
            -- affects specific iids
            if effects.aura_pts_flat[aura[iid_idx]] and effects.aura_pts_flat[aura[iid_idx]][spid] then
                add = add + effects.aura_pts_flat[aura[iid_idx]][spid];
            end
            if effects.aura_pts[aura[iid_idx]] and effects.aura_pts[aura[iid_idx]][spid] then
                mul = mul + effects.aura_pts[aura[iid_idx]][spid];
            end
            local val;
            if stacks > 1 then
                val = (aura[value_idx] + add) * mul * stacks;
            else
                val = (aura[value_idx] + add) * mul;
            end

            if bit.band(aura[flags_idx], sc.aura_flags.inactive_forced) == 0 or forced then
                local aura_effect = aura[effect_idx];
                if forced and bit.band(aura[flags_idx], sc.aura_flags.forced_separated) ~= 0 then
                    aura_effect = aura_effect.."_forced";
                end
                if bit.band(aura[flags_idx], sc.aura_flags.mul) ~= 0 then
                    if not effects["mul"][aura[category_idx]][aura_effect] then
                        print("Missing effects.mul."..aura[category_idx].."."..aura_effect);
                    end
                    if undo then
                        val = 1/val;
                    end
                    if aura[category_idx] == "raw" then
                        effects["mul"][aura[category_idx]][aura_effect] = effects["mul"][aura[category_idx]][aura_effect] * (1.0 + val);
                    else
                        for _, i in pairs(aura[subject_idx]) do
                            effects["mul"][aura[category_idx]][aura_effect][i] = (effects["mul"][aura[category_idx]][aura_effect][i] or 1.0) * (1.0 + val);
                        end
                    end
                else
                    if not effects[aura[category_idx]] then
                        print("Missing effects."..aura[category_idx]);
                    end
                    if not effects[aura[category_idx]][aura_effect] then
                        print("Missing effects."..aura[category_idx].."."..aura_effect);
                    end
                    if undo then
                        val = -val;
                    end
                    if aura[category_idx] == "raw" then
                        effects[aura[category_idx]][aura_effect] = effects[aura[category_idx]][aura_effect] + val;
                    else
                        for _, i in pairs(aura[subject_idx]) do
                            effects[aura[category_idx]][aura_effect][i] = (effects[aura[category_idx]][aura_effect][i] or 0.0) + val;
                        end
                    end
                end
            end
        end
    end
end


-- double buffered loadout
local loadout_base1 = loadout_zero();
local loadout_base2 = loadout_zero();
local loadout_front = loadout_base1;

-- singular tables shared in both loadout buffers, not to be compared 
local loadout_shared = {
    "wpn_skills",
    "wpn_subclasses",
    "num_set_pieces",
    "enchants",
    "talents",
};
for _, v in ipairs(loadout_shared) do
    loadout_base1[v] = {};
    loadout_base2[v] = loadout_base1[v];
end
loadout_base1.talents.code = "";
loadout_base1.talents.pts = {};

local equipped = {};
local talented = {};
local final_effects = {};
empty_effects(equipped);
empty_effects(talented);
empty_effects(final_effects);


local function active_loadout()
    return loadout_front;
end

loadout.force_update = true;

local function update_loadout_and_effects()

    local other;
    if loadout_front == loadout_base1 then
        other = loadout_base2;
    else
        other = loadout_base1;
    end
    dynamic_loadout(other);

    if not SpellBookFrame:IsShown() and
        not loadout.force_update and
        not sc.core.equipment_update_needed and
        not sc.core.talents_update_needed and
            loadout_eql(loadout_front, other) then

        loadout_front = other;

        -- No interesting change, early exit here and Overlay
        -- will benefit from not having to update icons
        return loadout_front, final_effects, false;
    end
    loadout.force_update = false;
    loadout_front = other;

    if sc.core.equipment_update_needed then
        zero_effects(equipped);
        local equipment_api_worked = sc.equipment.apply_equipment(loadout_front, equipped);
        -- need eq update again next because api failed
        sc.core.equipment_update_needed = not equipment_api_worked;
        sc.core.talents_update_needed = true;
    end

    if sc.core.talents_update_needed or
        (loadout_front.talents.code == "_" and UnitLevel("player") >= 10) -- workaround around edge case when the talents query won't work shortly after logging in
        then

        loadout_front.talents.code = sc.talents.wowhead_talent_code();

        zero_effects(talented);
        effects_add(talented, equipped);
        -- NOTE: these special passives may change aura_pts of other effects, thus applied first
        for k, v in pairs(sc.passives) do
            if IsPlayerSpell(k) then
                apply_effect(talented, k, v, false, 1);
            end
        end

        sc.talents.apply_talents(loadout_front, talented);

        sc.core.talents_update_needed = false;
    end

    -- equipment and talents updates above are rare

    zero_effects(final_effects);
    effects_add(final_effects, talented);

    sc.buffs.apply_buffs(loadout_front, final_effects);

    return loadout_front, final_effects, true;
end


local function update_loadout_and_effects_diffed_from_ui()

    local loadout_, effects = update_loadout_and_effects();

    local diff = effects_from_ui_diff(__sc_frame.calculator_frame);

    local effects_diffed = deep_table_copy(effects);
    effects_diff(loadout_, effects_diffed, diff);

    return loadout_, effects, effects_diffed;
end

loadout.equipped                                     = equipped;
loadout.talented                                     = talented;
loadout.final_effects                                = final_effects;
loadout.empty_effects                                = empty_effects;
loadout.effects_add                                  = effects_add;
loadout.effects_diff                                 = effects_diff;
loadout.cpy_effects                                  = cpy_effects;
loadout.effects_zero_diff                            = effects_zero_diff;
loadout.active_loadout                               = active_loadout;
loadout.update_loadout_and_effects                   = update_loadout_and_effects;
loadout.update_loadout_and_effects_diffed_from_ui    = update_loadout_and_effects_diffed_from_ui;
loadout.loadout_flags                                = loadout_flags;
loadout.apply_effect                                 = apply_effect;

sc.loadout = loadout;

