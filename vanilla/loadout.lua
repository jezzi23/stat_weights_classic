
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

local stat                              = addonTable.stat;
local deep_table_copy                   = addonTable.deep_table_copy;
local loadout_flags                     = addonTable.loadout_flags;
local stat_ids_in_ui                    = addonTable.stat_ids_in_ui;

local best_rank_by_lvl_update           = addonTable.best_rank_by_lvl_update;

local apply_buffs                       = addonTable.apply_buffs;
local detect_buffs                      = addonTable.detect_buffs;
local apply_equipment                   = addonTable.apply_equipment;
local apply_talents                     = addonTable.apply_talents;
local wowhead_talent_code               = addonTable.wowhead_talent_code;
local wowhead_talent_link               = addonTable.wowhead_talent_link;

local effects_from_ui_diff              = addonTable.effects_from_ui_diff;

local function empty_loadout()

    return {
        flags = loadout_flags.is_dynamic_loadout;
        name = "Empty";
        talents_code = "",
        custom_talents_code = "",
        --talents_table = talent_glyphs_table(""),
        talents_table = {},
        lvl = 1,
        target_lvl = 0,
        default_target_lvl_diff = 3,
        target_hp_perc_default = 1.0,

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
        spell_crit_by_school = {0, 0, 0, 0, 0, 0, 0},
        hit = 0.0,
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
    effects.raw.regen_while_casting = 0;
    effects.raw.spell_power = 0;
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

-- deep copy to avoid reference entanglement
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
        hit_rating = 0,
        haste_rating = 0,
        crit_rating = 0,
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


    diff.stats[stat.int] = stats[stat_ids_in_ui.int].editbox_val;
    diff.stats[stat.spirit] = stats[stat_ids_in_ui.spirit].editbox_val;
    diff.mp5 = stats[stat_ids_in_ui.mp5].editbox_val;

    diff.crit_rating = stats[stat_ids_in_ui.spell_crit].editbox_val;
    diff.hit_rating = stats[stat_ids_in_ui.spell_hit].editbox_val;
    diff.haste_rating = stats[stat_ids_in_ui.spell_haste].editbox_val;

    diff.sp = stats[stat_ids_in_ui.sp].editbox_val;

    frame.is_valid = true;

    return diff;
end

local function int_to_crit_rating(int, lvl)
    return 60;
end

local function effects_diff(loadout, effects, diff)
    -- TODO: mp5 from int scaling too

    --for i = 1, 5 do
    --    effects.stats[i] = loadout.stats[i] + diff.stats[i] * (1 + effects.by_attribute.stat_mod[i]);
    --end
    -- TODO: outdated stuff here, mana and int crit formula need figuring out

    --loadout.mana = loadout.mana + 
    --             (15*diff.stats[stat.int]*(1 + effects.by_attribute.stat_mod[stat.int]*effects.raw.mana_mod));

    local sp_gained_from_spirit = diff.stats[stat.spirit] * (1 + effects.by_attribute.stat_mod[stat.spirit]) * effects.by_attribute.sp_from_stat_mod[stat.spirit];
    local sp_gained_from_int = diff.stats[stat.int] * (1 + effects.by_attribute.stat_mod[stat.int]) * effects.by_attribute.sp_from_stat_mod[stat.int];
    local sp_gained_from_stat = sp_gained_from_spirit + sp_gained_from_int;

    local hp_gained_from_spirit = diff.stats[stat.spirit] * (1 + effects.by_attribute.stat_mod[stat.spirit]) * effects.by_attribute.hp_from_stat_mod[stat.spirit];
    local hp_gained_from_int = diff.stats[stat.int] * (1 + effects.by_attribute.stat_mod[stat.int]) * effects.by_attribute.hp_from_stat_mod[stat.int];
    local hp_gained_from_stat = hp_gained_from_spirit + hp_gained_from_int;

    effects.raw.spell_power = effects.raw.spell_power + diff.sp + sp_gained_from_stat;
    effects.raw.healing_power = effects.raw.healing_power + hp_gained_from_stat;


    effects.raw.mp5 = effects.raw.mp5 + diff.mp5;
    effects.raw.mp5 = effects.raw.mp5 + diff.stats[stat.int] * (1 + effects.by_attribute.stat_mod[stat.int]) * effects.raw.mp5_from_int_mod;

    -- TODO: crit and mana yields from intellect
    --       Missing formulas, seems to depend on lvl and class/race?
    --       It looks like in many cases 166.67 int is needed per 1% crit at many lvl 80 caster classes
    --
    --       Only contribute mana and crit IF we are level 80 since the generalized case is unknown atm
    local crit_rating_from_int = int_to_crit_rating(diff.stats[stat.int]*(1.0 + effects.by_attribute.stat_mod[stat.int]), loadout.lvl);

    effects.raw.mana = effects.raw.mana + (diff.stats[stat.int]*(1.0 + effects.by_attribute.stat_mod[stat.int]) * 15)*(1.0 + effects.raw.mana_mod);

    effects.raw.haste_rating = effects.raw.haste_rating + diff.haste_rating;
    effects.raw.crit_rating = effects.raw.crit_rating + diff.crit_rating + diff.stats[stat.spirit]*effects.by_attribute.crit_from_stat_mod[stat.spirit] + crit_rating_from_int;
    effects.raw.hit_rating = effects.raw.hit_rating + diff.hit_rating;

    for i = 1, 5 do
        effects.by_attribute.stats[i] = effects.by_attribute.stats[i] + diff.stats[i];
    end
end

local active_loadout_base = nil;

local function print_loadout(loadout, effects)

    print("Stat Weights Classic - Version: "..addonTable.version);
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

    local level = UnitLevel("player");
    if loadout.lvl ~= level then
        best_rank_by_lvl_update();
    end
    loadout.lvl = level;

    for i = 1, 5 do
        local _, stat, _, _ = UnitStat("player", i);

        loadout.stats[i] = stat;
    end

    loadout.max_mana = UnitPowerMax("player", 0);
    loadout.mana = loadout.max_mana;

    if bit.band(loadout.flags, loadout_flags.always_max_mana) == 0 then
        loadout.mana = UnitPower("player", 0);
    end

    -- in wotlk, healing power will equate to spell power
    loadout.spell_power = GetSpellBonusHealing();
    for i = 1, 7 do
        loadout.spell_dmg_by_school[i] = GetSpellBonusDamage(i) - loadout.spell_power;
    end
    for i = 1, 7 do
        loadout.spell_crit_by_school[i] = GetSpellCritChance(i)*0.01;
    end
    local ap_src1, ap_src2, ap_src3 = UnitAttackPower("player");
    loadout.attack_power = ap_src1 + ap_src2 + ap_src3;

    -- crit and hit is already gathered indirectly from rating, but not haste
    -- TODO VANILLA:
    loadout.haste_rating = 0;
    loadout.hit_rating = 0;

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

    if UnitExists("target") then

        loadout.flags = bit.bor(loadout.flags, loadout_flags.has_target);
        loadout.hostile_towards = "target";
        loadout.friendly_towards = "target";

        if UnitIsFriend("player", "target") then
            loadout.flags = bit.bor(loadout.flags, loadout_flags.target_friendly);
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
        
    if addonTable.equipment_update_needed then
        zero_effects(loadout_entry.equipped);
        local equipment_api_worked = apply_equipment(loadout_entry.loadout, loadout_entry.equipped);
        -- need eq update again next because api failed
        addonTable.equipment_update_needed = not equipment_api_worked;
        addonTable.talents_update_needed = true;
    end

    if addonTable.talents_update_needed
        or loadout_entry.loadout.talents_code == "_" -- workaround around edge case when the talents query won't work shortly after logging in
        then

        loadout_entry.loadout.talents_code = wowhead_talent_code();

        zero_effects(loadout_entry.talented);
        effects_add(loadout_entry.talented, loadout_entry.equipped);
        apply_talents(loadout_entry.loadout, loadout_entry.talented);

        addonTable.talents_update_needed = false;
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
    effects_diff(loadout, effects_diffed, diff);

    return loadout, effects, effects_diffed;
end

addonTable.print_loadout                                = print_loadout;
addonTable.empty_loadout                                = empty_loadout;
addonTable.empty_effects                                = empty_effects;
addonTable.effects_add                                  = effects_add;
addonTable.effects_diff                                 = effects_diff;
addonTable.effects_zero_diff                            = effects_zero_diff;
addonTable.default_loadout                              = default_loadout;
addonTable.active_loadout                               = active_loadout;
addonTable.active_loadout_entry                         = active_loadout_entry;
addonTable.active_loadout_and_effects                   = active_loadout_and_effects;
addonTable.active_loadout_and_effects_diffed_from_ui    = active_loadout_and_effects_diffed_from_ui;
addonTable.static_loadout_from_dynamic                  = static_loadout_from_dynamic;
addonTable.int_to_crit_rating                           = int_to_crit_rating;

