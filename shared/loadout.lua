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

local stat                              = swc.utils.stat;
local deep_table_copy                   = swc.utils.deep_table_copy;
local loadout_flags                     = swc.utils.loadout_flags;

local apply_buffs                       = swc.buffs.apply_buffs;
local detect_buffs                      = swc.buffs.detect_buffs;

local apply_equipment                   = swc.equipment.apply_equipment;

local apply_talents                     = swc.talents.apply_talents;
local wowhead_talent_code               = swc.talents.wowhead_talent_code;
local wowhead_talent_link               = swc.talents.wowhead_talent_link;

--------------------------------------------------------------------------------
local loadout_export = {};

local function empty_loadout()

    return {
        flags = loadout_flags.is_dynamic_loadout;
        name = "Empty";
        talents_code = "",
        custom_talents_code = "",
        talents_table = {},
        lvl = 1,
        target_lvl = 0,
        default_target_lvl_diff = 3,
        target_hp_perc_default = 1.0,
        target_res = 0,
        target_creature_type = "",
        unbounded_aoe_targets = 1,

        buffs = {},
        target_buffs = {},

        stats = {0, 0, 0, 0, 0},
        mana = 0,
        max_mana = 0,
        extra_mana = 0,

        haste_rating = 0.0,
        crit_rating = 0.0,
        hit_rating = 0.0,

        spell_dmg_by_school = {0, 0, 0, 0, 0, 0, 0},
        spell_dmg_hit_by_school = {0, 0, 0, 0, 0, 0, 0},
        spell_crit_by_school = {0, 0, 0, 0, 0, 0, 0},
        hit = 0.0,
        spell_dmg = 0,
        healing_power = 0,
        spell_power = 0,

        num_set_pieces = {},
        dynamic_buffs = {},
    };
end

local function empty_effects(effects) 

    effects.by_school = {};
    effects.by_school.spell_dmg_hit = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.spell_dmg_mod = {0, 0, 0, 0, 0, 0, 0}; -- mul
    effects.by_school.spell_dmg_mod_add = {0, 0, 0, 0, 0, 0, 0}; --add
    effects.by_school.spell_crit = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.spell_crit_mod = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.target_spell_dmg_taken = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.target_res = {0, 0, 0, 0, 0, 0, 0};
    effects.by_school.target_mod_res= {0, 0, 0, 0, 0, 0, 0};

    effects.by_attribute =  {};
    effects.by_attribute.stats = {0, 0, 0, 0, 0};
    effects.by_attribute.stat_mod = {0, 0, 0, 0, 0};
    effects.by_attribute.sp_from_stat_mod = {0, 0, 0, 0, 0};
    effects.by_attribute.hp_from_stat_mod = {0, 0, 0, 0, 0};
    effects.by_attribute.crit_from_stat_mod = {0, 0, 0, 0, 0};

    effects.raw = {};

    effects.raw.spell_heal_mod = 0;
    effects.raw.spell_heal_mod_mul = 0;
    effects.raw.spell_heal_mod_base = 0;
    effects.raw.spell_dmg_mod = 0;
    effects.raw.spell_dmg_mod_mul = 0;
    effects.raw.target_healing_taken = 0;
    effects.raw.mana_mod = 0;
    effects.raw.mana = 0;
    effects.raw.mp5_from_int_mod = 0;
    effects.raw.mp5 = 0;
    effects.raw.perc_max_mana_as_mp5 = 0;
    effects.raw.regen_while_casting = 0;
    effects.raw.spell_power = 0;
    effects.raw.spell_dmg = 0;
    effects.raw.healing_power = 0;

    effects.raw.ot_mod = 0;

    effects.raw.haste_mod = 0.0;
    effects.raw.cost_mod = 0;
    effects.raw.cost_mod_base = 0;
    effects.raw.cost_flat = 0;
    effects.raw.resource_refund = 0;

    effects.raw.haste_rating = 0;
    effects.raw.crit_rating = 0;
    effects.raw.hit_rating = 0;

    effects.raw.special_crit_mod = 0;
    effects.raw.special_crit_heal_mod = 0;
    effects.raw.non_stackable_effect_flags = 0;

    -- indexable by ability base id
    effects.ability = {};
    effects.ability.crit = {};
    effects.ability.crit_ot = {};
    effects.ability.effect_mod = {};
    effects.ability.effect_mod_base = {};
    effects.ability.cast_mod = {}; -- flat before mul
    effects.ability.cast_mod_mul = {}; -- after flat
     -- works like wow classic cast time reductiond, also may reduce gcd (used for backdraft)
    effects.ability.cast_mod_reduce = {};
    effects.ability.extra_ticks = {};
    effects.ability.cost_mod = {}; -- last, multiplied
    effects.ability.cost_flat = {}; -- second, additive
    effects.ability.cost_mod_base = {}; -- first, multiplied
    effects.ability.crit_mod = {};
    effects.ability.hit = {};
    effects.ability.sp = {};
    effects.ability.sp_ot = {};
    effects.ability.flat_add = {};
    effects.ability.flat_add_ot = {};
    effects.ability.refund = {};
    effects.ability.coef_mod = {};
    effects.ability.coef_ot_mod = {};
    effects.ability.effect_ot_mod = {};
    effects.ability.vuln_mod = {};
    effects.ability.vuln_ot_mod = {};

end

local function zero_effects(effects)
    for k, v in pairs(effects.raw) do
        effects.raw[k] = 0.0;
    end
    for _, e in pairs(effects.ability) do
        for k, v in pairs(e) do
            if v == 0.0 then
                e[k] = nil;
            else
                e[k] = 0.0;
            end
        end
    end
    for _, e in pairs(effects.by_school) do
        for i = 1,7 do
            e[i] = 0.0;
        end
    end
    for _, e in pairs(effects.by_attribute) do
        for i = 1,5 do
            e[i] = 0.0;
        end
    end
end

local function loadout_copy(loadout)
    return deep_table_copy(loadout);
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
                if not dst.ability[k][kk] then
                   dst.ability[k][kk] = 0.0;
                end
                dst.ability[k][kk] = dst.ability[k][kk] + vv;
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
    for k, v in pairs(src.by_attribute) do

        if dst.by_attribute[k] then
            for i = 1,5 do
                dst.by_attribute[k][i] = dst.by_attribute[k][i] + v[i];
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
        hit_rating = 0,
        haste_rating = 0,
        crit_rating = 0,
        spell_pen = 0,
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

    diff.stats[stat.int] = stats.int.editbox_val;
    diff.stats[stat.spirit] = stats.spirit.editbox_val;
    diff.mp5 = stats.mp5.editbox_val;

    diff.crit_rating = stats.spell_crit.editbox_val;
    diff.hit_rating = stats.spell_hit.editbox_val;
    diff.haste_rating = stats.spell_haste.editbox_val;

    diff.sp = stats.sp.editbox_val;

    if swc.core.expansion_loaded == swc.core.expansions.vanilla then
        diff.sd = stats.sd.editbox_val;
        diff.hp = stats.hp.editbox_val;
        diff.spell_pen = stats.spell_pen.editbox_val;
    end

    frame.is_valid = true;

    return diff;
end

local active_loadout_base = nil;

local function print_loadout(loadout, effects)

    print("Stat Weights Classic - Version: "..swc.core.version);
    for k, v in pairs(loadout) do
        print(k, v);
    end
    for k, v in pairs(effects.raw) do
        print(k, v);
    end
    local str = "spell_dmg_school : {";
    for i = 2,7 do
        str = str .. loadout.spell_dmg_by_school[i] .. ", "
    end
    str = str.."}";
    print(str);
    str = "spell_crit_school : {";
    for i = 2,7 do
        str = str .. loadout.spell_crit_by_school[i] .. ", "
    end
    str = str.."}";
    str = "spell_hit_school : {";
    for i = 2,7 do
        str = str .. loadout.spell_crit_by_school[i] .. ", "
    end
    str = str.."}";
    print(str);
    for w, e in pairs(effects.ability) do
        local str = w.. ": {";
        for k, v in pairs(e) do
            str = str..k..": "..v.." ";
        end
        str = str .."}";
        print(str);
    end
    for k, e in pairs(effects.by_school) do
        local str = k..": {";
        for i = 1,7 do
            str = str .. e[i].. ", ";
        end
        str = str .."}";
        print(str);
    end
    local str = "";
    for i = 1,5 do
        str = str .. effects.by_attribute.stat_mod[i] .. ", "
    end
    print(str);
end

local function default_loadout(loadout)

    loadout.name = "Default";
    loadout.flags = bit.bor(loadout.flags, loadout_flags.is_dynamic_loadout);
end

local function dynamic_loadout(loadout)

    if bit.band(loadout.flags, loadout_flags.custom_lvl) == 0 then
        loadout.lvl = UnitLevel("player");
    end

    for i = 1, 5 do
        local _, stat, _, _ = UnitStat("player", i);

        loadout.stats[i] = stat;
    end

    loadout.max_mana = UnitPowerMax("player", 0);
    loadout.mana = loadout.max_mana;

    if bit.band(loadout.flags, loadout_flags.always_max_mana) == 0 then
        loadout.mana = UnitPower("player", 0);
    end

    loadout.haste_rating = 0;
    loadout.hit_rating = 0;

    if swc.core.expansion_loaded == swc.core.expansions.vanilla then
        loadout.healing_power = GetSpellBonusHealing();
        loadout.spell_dmg = math.huge;
        for i = 2, 7 do
            loadout.spell_dmg = math.min(loadout.spell_dmg, GetSpellBonusDamage(i));
        end
        for i = 2, 7 do
            loadout.spell_dmg_by_school[i] = GetSpellBonusDamage(i) - loadout.spell_dmg;
        end
        -- right after load GetSpellHitModifier seems to sometimes returns a nil.... so check first I guess
       local spell_hit = 0;
       local real_hit = GetSpellHitModifier();
       if real_hit then
           spell_hit = real_hit/100;
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

    for i = 2, 7 do
        loadout.spell_crit_by_school[i] = GetSpellCritChance(i)*0.01;
    end
    local ap_src1, ap_src2, ap_src3 = UnitAttackPower("player");
    loadout.attack_power = ap_src1 + ap_src2 + ap_src3;


    loadout.player_name = UnitName("player"); 
    loadout.target_name = UnitName("target"); 
    loadout.mouseover_name = UnitName("mouseover"); 

    loadout.hostile_towards = nil; 
    loadout.friendly_towards = "player";

    loadout.flags =
        bit.band(loadout.flags, bit.band(bit.bnot(loadout_flags.has_target),
                                         bit.bnot(loadout_flags.target_snared),
                                         bit.bnot(loadout_flags.target_frozen),
                                         bit.bnot(loadout_flags.target_friendly)));
    loadout.enemy_hp_perc = loadout.target_hp_perc_default;
    loadout.friendly_hp_perc = loadout.target_hp_perc_default;

    loadout.target_lvl = loadout.default_target_lvl_diff + loadout.lvl;

    loadout.target_creature_type = "";

    if UnitExists("target") then

        loadout.flags = bit.bor(loadout.flags, loadout_flags.has_target);
        loadout.hostile_towards = "target";
        loadout.friendly_towards = "target";

        if UnitIsFriend("player", "target") then
            loadout.flags = bit.bor(loadout.flags, loadout_flags.target_friendly);
        end

        loadout.target_creature_type = UnitCreatureType("target");
        
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

    if UnitExists("mouseover") and UnitName("mouseover") ~= UnitName("target") then
        loadout.friendly_towards = "mouseover";
        loadout.friendly_hp_perc = UnitHealth(loadout.friendly_towards)/UnitHealthMax(loadout.friendly_towards);
    end
    loadout.player_hp_perc = UnitHealth("player")/math.max(UnitHealthMax("player"), 1);
    if loadout.hostile_towards == "target" and bit.band(loadout.flags, loadout_flags.target_friendly) == 0 then
        loadout.enemy_hp_perc = UnitHealth("target")/math.max(UnitHealthMax("target"), 1);
    end

    detect_buffs(loadout);
end

local function active_loadout_entry()
    
    return sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout];
end

local function active_loadout()
    
    return active_loadout_entry().loadout;
end

function __sw_active_loadout()
    return active_loadout();
end


local function active_loadout_and_effects()

    local loadout_entry = active_loadout_entry();
    dynamic_loadout(loadout_entry.loadout);
        
    if swc.core.equipment_update_needed then
        zero_effects(loadout_entry.equipped);
        local equipment_api_worked = apply_equipment(loadout_entry.loadout, loadout_entry.equipped);
        -- need eq update again next because api failed
        swc.core.equipment_update_needed = not equipment_api_worked;
        swc.core.talents_update_needed = true;
    end

    if swc.core.talents_update_needed or
        (loadout_entry.loadout.talents_code == "_" and UnitLevel("player") >= 10) -- workaround around edge case when the talents query won't work shortly after logging in
        then

        loadout_entry.loadout.talents_code = wowhead_talent_code();

        zero_effects(loadout_entry.talented);
        effects_add(loadout_entry.talented, loadout_entry.equipped);
        apply_talents(loadout_entry.loadout, loadout_entry.talented);

        swc.core.talents_update_needed = false;
    end

    -- equipment and talents updates above are rare

    zero_effects(loadout_entry.final_effects);
    effects_add(loadout_entry.final_effects, loadout_entry.talented);
    apply_buffs(loadout_entry.loadout, loadout_entry.final_effects);

    return loadout_entry.loadout, loadout_entry.final_effects;
end


local function active_loadout_and_effects_diffed_from_ui()

    local loadout, effects = active_loadout_and_effects();

    local diff = effects_from_ui_diff(sw_frame.stat_comparison_frame);

    local effects_diffed = deep_table_copy(effects);
    swc.loadout.effects_diff(loadout, effects_diffed, diff);

    return loadout, effects, effects_diffed;
end

loadout_export.print_loadout                                = print_loadout;
loadout_export.empty_loadout                                = empty_loadout;
loadout_export.empty_effects                                = empty_effects;
loadout_export.effects_add                                  = effects_add;
loadout_export.effects_zero_diff                            = effects_zero_diff;
loadout_export.default_loadout                              = default_loadout;
loadout_export.active_loadout                               = active_loadout;
loadout_export.active_loadout_entry                         = active_loadout_entry;
loadout_export.active_loadout_and_effects                   = active_loadout_and_effects;
loadout_export.active_loadout_and_effects_diffed_from_ui    = active_loadout_and_effects_diffed_from_ui;
loadout_export.static_loadout_from_dynamic                  = static_loadout_from_dynamic;

swc.loadout = loadout_export;

