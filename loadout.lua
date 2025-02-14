local _, sc = ...;

local attr                              = sc.attr;
local classes                           = sc.classes;
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
local loadout_export = {};

local loadout_flags = {
    has_target                          = bit.lshift(1, 1),
    target_snared                       = bit.lshift(1, 2),
    target_frozen                       = bit.lshift(1, 3),
    target_friendly                     = bit.lshift(1, 4),
    target_pvp                          = bit.lshift(1, 5),
};

local function empty_loadout()

    return {
        flags = 0,

        lvl = 0,
        target_lvl = 0,
        talents_table = "",

        mana = 0,
        stats = {0, 0, 0, 0, 0},

        haste_rating = 0.0,
        crit_rating = 0.0,
        hit_rating = 0.0,
        target_creature_type = "",

        spell_dmg_by_school = {0, 0, 0, 0, 0, 0, 0},
        spell_dmg_hit_by_school = {0, 0, 0, 0, 0, 0, 0},
        spell_crit_by_school = {0, 0, 0, 0, 0, 0, 0},
        phys_hit = 0.0,
        spell_dmg = 0,
        healing_power = 0,
        spell_power = 0,
        attack_power = 0,

        wpn_skills = {},
        num_set_pieces = {},
        enchants = {},
        dynamic_buffs = {},
    };
end

local function empty_effects(effects)

    effects.mul = {};

    effects.by_school = {};
    effects.by_school.spell_hit = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.crit_mod = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.sp_dmg_flat = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.crit = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.target_res = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.target_res_flat = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.threat = {0, 0, 0, 0, 0, 0, 0};
    effects.mul.by_school = {};
    effects.mul.by_school.vuln_mod = {1, 1, 1, 1, 1, 1, 1};
    effects.mul.by_school.dmg_mod = {1, 1, 1, 1, 1, 1, 1};

    effects.by_attr =  {};
    effects.by_attr.stats = {0, 0, 0, 0, 0};
    effects.by_attr.stat_mod = {0, 0, 0, 0, 0};
    effects.by_attr.sp_from_stat_mod = {0, 0, 0, 0, 0};
    effects.by_attr.hp_from_stat_mod = {0, 0, 0, 0, 0};
    effects.by_attr.crit_from_stat_mod = {0, 0, 0, 0, 0};

    effects.raw = {};
    --effects.raw.heal_mod = 0;
    effects.raw.mana_mod = 0;
    effects.raw.mana_mod_active = 0;
    effects.raw.mana = 0;
    effects.raw.mp5_from_int_mod = 0;
    effects.raw.mp5 = 0;
    effects.raw.perc_max_mana_as_mp5 = 0;
    effects.raw.regen_while_casting = 0;
    effects.raw.spell_power = 0;
    effects.raw.spell_dmg = 0;
    effects.raw.healing_power_flat = 0;

    effects.raw.phys_dmg_flat = 0;

    effects.raw.ap_flat = 0;
    effects.raw.rap_flat = 0;

    effects.raw.cast_haste = 0;

    effects.mul.raw = {};
    effects.mul.raw.phys_mod = 1.0;
    effects.mul.raw.heal_mod = 1.0;
    effects.mul.raw.vuln_heal = 1.0;
    effects.mul.raw.vuln_phys = 1.0;

    effects.mul.raw.melee_haste = 1;
    effects.mul.raw.melee_haste_forced = 1;
    effects.mul.raw.ranged_haste = 1;
    effects.mul.raw.ranged_haste_forced = 1;
    effects.mul.raw.cast_haste = 1;

    effects.raw.haste_mod = 0.0;
    effects.raw.cost_mod = 0;
    effects.raw.resource_refund = 0;

    effects.raw.phys_hit = 0;
    effects.raw.phys_crit = 0;
    effects.raw.offhand_mod = 0;
    effects.raw.extra_hits_flat = 0; -- windfury like effects

    effects.raw.haste_rating = 0;
    effects.raw.crit_rating = 0;
    effects.raw.hit_rating = 0;
    effects.raw.skill = 0;

    effects.raw.non_stackable_effect_flags = 0;

    effects.raw.target_num_afflictions = 0;
    effects.raw.target_num_shadow_afflictions = 0;

    -- indexable by ability base id
    effects.ability = {};
    effects.ability.threat = {};
    effects.ability.threat_flat = {};
    effects.ability.crit = {};
    effects.ability.ignore_cant_crit = {};
    effects.ability.effect_mod = {};
    effects.ability.effect_mod_flat = {};
    effects.ability.effect_mod_ot = {};
    effects.ability.effect_mod_ot_flat = {};
    effects.ability.base_mod = {};
    effects.ability.base_mod_flat = {};
    effects.ability.base_mod_ot = {};
    effects.ability.base_mod_ot_flat = {};
    effects.ability.cast_mod_flat = {};
    effects.ability.cast_mod = {};
    effects.ability.extra_dur_flat = {};
    effects.ability.extra_dur = {};
    effects.ability.extra_tick_time_flat = {};
    effects.ability.cost_mod = {};
    effects.ability.cost_mod_flat = {};
    effects.ability.crit_mod = {};
    effects.ability.hit = {};
    effects.ability.sp = {};
    effects.ability.sp_ot = {};
    effects.ability.flat_add = {}; -- custom
    effects.ability.flat_add_ot = {}; -- custom
    effects.ability.refund = {};
    effects.ability.coef_mod = {};
    effects.ability.coef_mod_flat = {};
    effects.ability.effect_mod_only_heal = {};
    effects.ability.jumps_flat = {};
    effects.ability.jump_amp = {};
    effects.mul.ability = {};
    effects.mul.ability.vuln_mod = {};

    -- effects that affects the base value (points) of other subauras
    -- indexed by the aura id
    effects.aura_pts = { [-1] = {}, [0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {},};
    effects.aura_pts_flat = { [-1] = {}, [0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {},};

    effects.wpn_subclass = {};
    effects.wpn_subclass.phys_crit = {};
    effects.wpn_subclass.phys_hit = {};
    effects.wpn_subclass.phys_hit = {};
    effects.wpn_subclass.phys_dmg = {};
    effects.wpn_subclass.phys_dmg_flat = {};
    effects.mul.wpn_subclass = {};
    effects.mul.wpn_subclass.phys_mod = {};

    effects.creature = {};
    effects.creature.crit_mod = {};
    effects.mul.creature = {};
    effects.mul.creature.dmg_mod = {};


    -- OBSOLETE
    effects.by_school.cost_mod = {0, 0, 0, 0, 0, 0, 0};
end

local function zero_effects(effects)
    -- addable effects
    for k, _ in pairs(effects.raw) do
        effects.raw[k] = 0.0;
    end

    for _, e in pairs(effects.ability) do
        for k, _ in pairs(e) do
            e[k] = 0.0;
        end
    end
    for _, e in pairs(effects.by_school) do
        for i = 1,7 do
            e[i] = 0.0;
        end
    end
    for _, e in pairs(effects.by_attr) do
        for i = 1,5 do
            e[i] = 0.0;
        end
    end

    for _, e in pairs(effects.by_school) do
        for i = 1,7 do
            e[i] = 0.0;
        end
    end
    for _, e in pairs(effects.aura_pts) do
        for k, _ in pairs(e) do
            e[k] = 0.0;
        end
    end
    for _, e in pairs(effects.aura_pts_flat) do
        for k, _ in pairs(e) do
            e[k] = 0.0;
        end
    end
    for _, e in pairs(effects.wpn_subclass) do
        for k, _ in pairs(e) do
            e[k] = 0.0;
        end
    end
    for _, e in pairs(effects.creature) do
        for k, _ in pairs(e) do
            e[k] = 0.0;
        end
    end
    -- multiplicative effects
    for k, _ in pairs(effects.mul.raw) do
        effects.mul.raw[k] = 1.0;
    end

    for _, e in pairs(effects.mul.by_school) do
        for i = 1,7 do
            e[i] = 1.0;
        end
    end
    for _, e in pairs(effects.mul.ability) do
        for k, _ in pairs(e) do
            e[k] = 1.0;
        end
    end
    for _, e in pairs(effects.mul.wpn_subclass) do
        for k, _ in pairs(e) do
            e[k] = 1.0;
        end
    end
    for _, e in pairs(effects.mul.creature) do
        for k, _ in pairs(e) do
            e[k] = 1.0;
        end
    end
end

local function effects_add(dst, src)
    for k, v in pairs(src.raw) do
        if dst.raw[k] then
            dst.raw[k] = dst.raw[k] + v;
        end
    end
    for k, v in pairs(src.ability) do
        if dst.ability[k] then
            for kk, vv in pairs(v) do
                dst.ability[k][kk] = (dst.ability[k][kk] or 0.0) + vv;
            end
        end
    end
    for k, v in pairs(src.by_school) do
        if dst.by_school[k] then
            for i = 1,7 do
                dst.by_school[k][i] = dst.by_school[k][i] + v[i];
            end
        end
    end
    for k, v in pairs(src.by_attr) do
        if dst.by_attr[k] then
            for i = 1,5 do
                dst.by_attr[k][i] = dst.by_attr[k][i] + v[i];
            end
        end
    end
    for k, v in pairs(src.aura_pts) do
        if dst.aura_pts[k] then
            for kk, vv in pairs(v) do
                dst.aura_pts[k][kk] = (dst.aura_pts[k][kk] or 0.0) + vv;
            end
        end
    end
    for k, v in pairs(src.aura_pts_flat) do
        if dst.aura_pts_flat[k] then
            for kk, vv in pairs(v) do
                dst.aura_pts_flat[k][kk] = (dst.aura_pts_flat[k][kk] or 0.0) + vv;
            end
        end
    end
    for k, v in pairs(src.wpn_subclass) do
        if dst.wpn_subclass[k] then
            for kk, vv in pairs(v) do
                dst.wpn_subclass[k][kk] = (dst.wpn_subclass[k][kk] or 0.0) + vv;
            end
        end
    end
    for k, v in pairs(src.creature) do
        if dst.creature[k] then
            for kk, vv in pairs(v) do
                dst.creature[k][kk] = (dst.creature[k][kk] or 0.0) + vv;
            end
        end
    end
    -- multiplicative
    for k, v in pairs(src.mul.raw) do
        if dst.mul.raw[k] then
            dst.mul.raw[k] = dst.mul.raw[k] * v;
        end
    end
    for k, v in pairs(src.mul.by_school) do
        if dst.mul.by_school[k] then
            for i = 1,7 do
                dst.mul.by_school[k][i] = dst.mul.by_school[k][i] * v[i];
            end
        end
    end
    for k, v in pairs(src.mul.ability) do
        if dst.mul.ability[k] then
            for kk, vv in pairs(v) do
                dst.mul.ability[k][kk] = (dst.mul.ability[k][kk] or 1.0) * vv;
            end
        end
    end
    for k, v in pairs(src.mul.wpn_subclass) do
        if dst.mul.wpn_subclass[k] then
            for kk, vv in pairs(v) do
                dst.mul.wpn_subclass[k][kk] = (dst.mul.wpn_subclass[k][kk] or 1.0) * vv;
            end
        end
    end
    for k, v in pairs(src.mul.creature) do
        if dst.mul.creature[k] then
            for kk, vv in pairs(v) do
                dst.mul.creature[k][kk] = (dst.mul.creature[k][kk] or 1.0) * vv;
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
    for k, v in pairs(stats) do


        local expr_str = v.editbox:GetText();

        local is_whitespace_expr = expr_str and string.match(expr_str, "%S") == nil;
        --local is_whitespace_expr = string.format(expr_str, "[^ \t\n]") == nil;
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
    diff.mp5 = stats.mp5.editbox_val;

    diff.crit_rating = stats.spell_crit.editbox_val;
    diff.hit_rating = stats.spell_hit.editbox_val;
    diff.haste_rating = stats.spell_haste.editbox_val;

    diff.sp = stats.sp.editbox_val;

    if sc.expansion == sc.expansions.vanilla then
        diff.sd = stats.sd.editbox_val;
        diff.hp = stats.hp.editbox_val;
        diff.spell_pen = stats.spell_pen.editbox_val;
    end

    frame.is_valid = true;

    return diff;
end

local diff_stats_gained = {};
local function effects_diff(loadout, effects, diff)

    --for i = 1, 5 do
    --    effects.stats[i] = loadout.stats[i] + diff.stats[i] * (1 + effects.by_attr.stat_mod[i]);
    --end

    --loadout.mana = loadout.mana + 
    --             (mana_per_int*diff.stats[attr.intellect]*(1 + effects.by_attr.stat_mod[attr.intellect]*effects.raw.mana_mod));

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
        effects.by_school.target_res[i] = effects.by_school.target_res[i] + diff.spell_pen;
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
    local added_rap = diff.ap + diff_stats_gained[attr.agility] * rap_per_agi[class];
    effects.raw.phys_crit = effects.raw.phys_crit +
        agi_to_physical_crit(diff_stats_gained[attr.agility], loadout.lvl);

    effects.raw.ap_flat = effects.raw.ap_flat + added_ap;
    effects.raw.rap_flat = effects.raw.rap_flat + added_rap;


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

    loadout.max_mana = UnitPowerMax("player", 0);
    loadout.mana = loadout.max_mana;
    loadout.rage = UnitPowerMax("player", 1);
    loadout.energy = UnitPowerMax("player", 3);
    loadout.cpts = 5;

    if not config.loadout.always_max_resource then
        loadout.mana = UnitPower("player", 0);
        loadout.rage = UnitPower("player", 1);
        loadout.energy = UnitPower("player", 3);
        loadout.cpts = UnitPower("player", 4);
        loadout.cpts = math.max(1, GetComboPoints("player", "target"));
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
        for i = 3, 7 do
            loadout.spell_dmg_by_school[i] = math.min(loadout.spell_dmg_by_school[1],
                                                      loadout.spell_dmg_by_school[i]);
        end

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
    loadout.shapeshift_no_weapon = sc.class == "DRUID" and shapeshift ~= 5;

    loadout.player_name = UnitName("player");
    loadout.target_name = UnitName("target");
    loadout.mouseover_name = UnitName("mouseover");

    loadout.hostile_towards = nil;
    loadout.friendly_towards = "player";

    loadout.flags =
        bit.band(loadout.flags, bit.band(bit.bnot(loadout_flags.has_target),
                                         bit.bnot(loadout_flags.target_snared),
                                         bit.bnot(loadout_flags.target_frozen),
                                         bit.bnot(loadout_flags.target_friendly),
                                         bit.bnot(loadout_flags.target_pvp)));
    loadout.enemy_hp_perc = config.loadout.default_target_hp_perc*0.01;
    loadout.friendly_hp_perc = config.loadout.default_target_hp_perc*0.01;

    loadout.target_creature_mask = 0;

    loadout.target_lvl = config.loadout.default_target_lvl_diff + loadout.lvl;

    if UnitExists("target") then

        loadout.flags = bit.bor(loadout.flags, loadout_flags.has_target);
        loadout.hostile_towards = "target";
        loadout.friendly_towards = "target";

        if UnitIsFriend("player", "target") then
            loadout.flags = bit.bor(loadout.flags, loadout_flags.target_friendly);
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
        loadout.friendly_hp_perc = UnitHealth(loadout.friendly_towards)/UnitHealthMax(loadout.friendly_towards);
    end

    if UnitExists("mouseover") and UnitIsFriend("player", "mouseover") then
        loadout.friendly_towards = "mouseover";
        loadout.friendly_hp_perc = UnitHealth(loadout.friendly_towards)/UnitHealthMax(loadout.friendly_towards);
    end
    loadout.player_hp_perc = UnitHealth("player")/math.max(UnitHealthMax("player"), 1);
    if loadout.hostile_towards == "target" and bit.band(loadout.flags, loadout_flags.target_friendly) == 0 then
        loadout.enemy_hp_perc = UnitHealth("target")/math.max(UnitHealthMax("target"), 1);
    end

    loadout.target_defense = 5*loadout.target_lvl;

    loadout.armor = config.loadout.target_armor;
    if config.loadout.target_automatic_armor then
        if sc.npc_armor_by_lvl[loadout.target_lvl] then
            loadout.armor = sc.npc_armor_by_lvl[loadout.target_lvl] * config.loadout.target_automatic_armor_pct * 0.01;
        end
    end

    sc.buffs.detect_buffs(loadout);
end

local function apply_effect(loadout, effects, spid, auras, forced, stacks, undo)
    if not auras then
        print("Missing aura", spid);
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
                apply_effect(loadout, effects, k, sc[aura[effect_idx]][k], forced, stacks, undo);
            end
            return;
        end
        local add = add_all;
        local mul = mul_all;
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

local base_loadout = empty_loadout();
local equipped = {};
local talented = {};
local final_effects = {};
empty_effects(equipped);
empty_effects(talented);
empty_effects(final_effects);

local function active_loadout()
    return base_loadout;
end


local function update_loadout_and_effects()

    dynamic_loadout(base_loadout);

    if sc.core.equipment_update_needed then
        zero_effects(equipped);
        local equipment_api_worked = sc.equipment.apply_equipment(base_loadout, equipped);
        -- need eq update again next because api failed
        sc.core.equipment_update_needed = not equipment_api_worked;
        sc.core.talents_update_needed = true;
    end

    if sc.core.talents_update_needed or
        (config.loadout.talents_code == "_" and UnitLevel("player") >= 10) -- workaround around edge case when the talents query won't work shortly after logging in
        then

        config.loadout.talents_code = sc.talents.wowhead_talent_code();

        zero_effects(talented);
        effects_add(talented, equipped);
        -- load special passives along with talents
        for k, v in pairs(sc.special_passives) do
            if IsPlayerSpell(k) then
                local lname = GetSpellInfo(k);
                apply_effect(base_loadout, talented, k, v, false, 1);
            end
        end

        sc.talents.apply_talents(base_loadout, talented);

        sc.core.talents_update_needed = false;
    end

    -- equipment and talents updates above are rare

    zero_effects(final_effects);
    effects_add(final_effects, talented);
    sc.buffs.apply_buffs(base_loadout, final_effects);

    return base_loadout, final_effects;
end


local function update_loadout_and_effects_diffed_from_ui()

    local loadout, effects = update_loadout_and_effects();

    local diff = effects_from_ui_diff(__sc_frame.calculator_frame);

    local effects_diffed = deep_table_copy(effects);
    effects_diff(loadout, effects_diffed, diff);

    return loadout, effects, effects_diffed;
end

loadout_export.equipped                                     = equipped;
loadout_export.talented                                     = talented;
loadout_export.final_effects                                = final_effects;
loadout_export.empty_loadout                                = empty_loadout;
loadout_export.empty_effects                                = empty_effects;
loadout_export.effects_add                                  = effects_add;
loadout_export.effects_diff                                 = effects_diff;
loadout_export.effects_zero_diff                            = effects_zero_diff;
loadout_export.active_loadout                               = active_loadout;
loadout_export.update_loadout_and_effects                   = update_loadout_and_effects;
loadout_export.update_loadout_and_effects_diffed_from_ui    = update_loadout_and_effects_diffed_from_ui;
loadout_export.loadout_flags                                = loadout_flags;
loadout_export.apply_effect                                 = apply_effect;

sc.loadout = loadout_export;

