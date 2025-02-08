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

local _, swc = ...;

--------------------------------------------------------------------------------
local equipment = {};

local set_tiers = {
    pve_0                   = 1,
    pve_0_5                 = 2,
    pve_1                   = 3,
    pve_2                   = 4,
    pve_2_5_0               = 6, -- zg
    pve_2_5_1               = 7, -- aq20
    pve_2_5_2               = 8, -- aq40
    pve_3                   = 9,
    pvp_1                   = 10,
    pvp_2                   = 11,
    sod_p2_anyclass         = 12,
    sod_p2_class            = 13,
    sod_p3_t1               = 14,
    sod_p3_t1_dmg           = 15,
    sod_final_pve_0_5       = 16,
    sod_final_pve_0_5_heal  = 17,
    sod_final_pve_1         = 18,
    sod_final_pve_1_heal    = 19,
    sod_final_pve_2         = 20,
    sod_final_pve_2_heal    = 21,
    sod_final_pve_zg        = 22,
};

--local function create_sets()
--
--    local set_tier_ids = {};
--
--    if class == "PRIEST" then
--
--        -- t1
--        for i = 16811, 16819 do
--            set_tier_ids[i] = set_tiers.pve_1;
--        end
--        -- t2
--        for i = 16919, 16926 do
--            set_tier_ids[i] = set_tiers.pve_2;
--        end
--        -- aq20
--        for i = 21410, 21412 do
--            set_tier_ids[i] = set_tiers.pve_2_5_1;
--        end
--
--        -- aq40
--        for i = 21348, 21352 do
--            set_tier_ids[i] = set_tiers.pve_2_5_2;
--        end
--
--        --naxx
--        for i = 22512, 22519 do
--            set_tier_ids[i] = set_tiers.pve_3;
--        end
--        set_tier_ids[23061] = set_tiers.pve_3;
--
--        --sod 
--        for i = 220683, 220685 do
--            set_tier_ids[i] = set_tiers.sod_p3_t1;
--        end
--
--        for i = 226571, 226578 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_1_heal;
--        end
--
--        for i = 231165, 231172 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_2;
--        end
--        for i = 231155, 231162 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_2_heal;
--        end
--
--        set_tier_ids[231283] = set_tiers.sod_final_pve_zg;
--        for i = 231332, 231335 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_zg;
--        end
--
--    elseif class == "DRUID" then
--
--        -- t1
--        for i = 16828, 16836 do
--            set_tier_ids[i] = set_tiers.pve_1;
--        end
--
--        -- t2
--        for i = 16897, 16904 do
--            set_tier_ids[i] = set_tiers.pve_2;
--        end
--
--        -- zg
--        set_tier_ids[19955] = set_tiers.pve_2_5_0;
--        set_tier_ids[19613] = set_tiers.pve_2_5_0;
--        set_tier_ids[19840] = set_tiers.pve_2_5_0;
--        set_tier_ids[19839] = set_tiers.pve_2_5_0;
--        set_tier_ids[19838] = set_tiers.pve_2_5_0;
--
--        --naxx
--        for i = 22488, 22495 do
--            set_tier_ids[i] = set_tiers.pve_3;
--        end
--        set_tier_ids[23064] = set_tiers.pve_3;
--
--        set_tier_ids[213312] = set_tiers.sod_p2_class;
--        set_tier_ids[213331] = set_tiers.sod_p2_class;
--        set_tier_ids[213342] = set_tiers.sod_p2_class;
--
--        --sod
--        for i = 220669, 220670 do
--            set_tier_ids[i] = set_tiers.sod_p3_t1;
--        end
--        for i = 220672, 220675 do
--            set_tier_ids[i] = set_tiers.sod_p3_t1_dmg;
--        end
--        --sod pve t1
--        for i = 226651, 226658 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_1;
--        end
--        for i = 226644, 226650 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_1_heal;
--        end
--        set_tier_ids[221785] = set_tiers.sod_final_pve_1_heal;
--        --sod pve t2
--        for i = 231246, 231253 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_2;
--        end
--        for i = 231230, 231237  do
--            set_tier_ids[i] = set_tiers.sod_final_pve_2_heal;
--        end
--        set_tier_ids[231280] = set_tiers.sod_final_pve_zg;
--        for i = 231316, 231319 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_zg;
--        end
--
--    elseif class == "SHAMAN" then
--        -- t1
--        for i = 16837, 16844 do
--            set_tier_ids[i] = set_tiers.pve_1;
--        end
--        -- t2
--        for i = 16943, 16950 do
--            set_tier_ids[i] = set_tiers.pve_2;
--        end
--        set_tier_ids[22857] = set_tiers.pvp_1;
--        set_tier_ids[22867] = set_tiers.pvp_1;
--        set_tier_ids[22876] = set_tiers.pvp_1;
--        set_tier_ids[22887] = set_tiers.pvp_1;
--        set_tier_ids[23259] = set_tiers.pvp_1;
--        set_tier_ids[23260] = set_tiers.pvp_1;
--
--        set_tier_ids[16577] = set_tiers.pvp_2;
--        set_tier_ids[16578] = set_tiers.pvp_2;
--        set_tier_ids[16580] = set_tiers.pvp_2;
--        set_tier_ids[16573] = set_tiers.pvp_2;
--        set_tier_ids[16574] = set_tiers.pvp_2;
--        set_tier_ids[16579] = set_tiers.pvp_2;
--
--        --zg
--        set_tier_ids[19609] = set_tiers.pve_2_5_0;
--        set_tier_ids[19956] = set_tiers.pve_2_5_0;
--        set_tier_ids[19830] = set_tiers.pve_2_5_0;
--        set_tier_ids[19829] = set_tiers.pve_2_5_0;
--        set_tier_ids[19828] = set_tiers.pve_2_5_0;
--
--        -- aq20
--        for i = 21398, 21400 do
--            set_tier_ids[i] = set_tiers.pve_2_5_1;
--        end
--
--        -- aq40
--        for i = 21372, 21376 do
--            set_tier_ids[i] = set_tiers.pve_2_5_2;
--        end
--
--        --naxx
--        for i = 22464, 22471 do
--            set_tier_ids[i] = set_tiers.pve_3;
--        end
--        set_tier_ids[23065] = set_tiers.pve_3;
--
--        set_tier_ids[213315] = set_tiers.sod_p2_class;
--        set_tier_ids[213334] = set_tiers.sod_p2_class;
--        set_tier_ids[213338] = set_tiers.sod_p2_class;
--
--        --sod
--        for i = 220663, 220665 do
--            set_tier_ids[i] = set_tiers.sod_p3_t1;
--        end
--
--        for i = 226611, 226618 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_1_heal;
--        end
--
--        for i = 231214, 231221 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_2;
--        end
--        for i = 231198, 231204 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_2_heal;
--        end
--
--    elseif class == "WARLOCK" then
--        for i = 16803, 16810 do
--            set_tier_ids[i] = set_tiers.pve_1;
--        end
--
--        -- ally
--        set_tier_ids[23296] = set_tiers.pvp_1;
--        set_tier_ids[23297] = set_tiers.pvp_1;
--        set_tier_ids[23283] = set_tiers.pvp_1;
--        set_tier_ids[23311] = set_tiers.pvp_1;
--        set_tier_ids[23282] = set_tiers.pvp_1;
--        set_tier_ids[23310] = set_tiers.pvp_1;
--
--        set_tier_ids[17581] = set_tiers.pvp_2;
--        set_tier_ids[17580] = set_tiers.pvp_2;
--        set_tier_ids[17583] = set_tiers.pvp_2;
--        set_tier_ids[17584] = set_tiers.pvp_2;
--        set_tier_ids[17579] = set_tiers.pvp_2;
--        set_tier_ids[17578] = set_tiers.pvp_2;
--        -- horde
--        set_tier_ids[22865] = set_tiers.pvp_1;
--        set_tier_ids[22855] = set_tiers.pvp_1;
--        set_tier_ids[23255] = set_tiers.pvp_1;
--        set_tier_ids[23256] = set_tiers.pvp_1;
--        set_tier_ids[22881] = set_tiers.pvp_1;
--        set_tier_ids[22884] = set_tiers.pvp_1;
--
--        set_tier_ids[17586] = set_tiers.pvp_2;
--        set_tier_ids[17588] = set_tiers.pvp_2;
--        set_tier_ids[17593] = set_tiers.pvp_2;
--        set_tier_ids[17591] = set_tiers.pvp_2;
--        set_tier_ids[17590] = set_tiers.pvp_2;
--        set_tier_ids[17592] = set_tiers.pvp_2;
--
--        -- zg
--        set_tier_ids[19957] = set_tiers.pve_2_5_0;
--        set_tier_ids[19605] = set_tiers.pve_2_5_0;
--        set_tier_ids[19848] = set_tiers.pve_2_5_0;
--        set_tier_ids[19849] = set_tiers.pve_2_5_0;
--        set_tier_ids[20033] = set_tiers.pve_2_5_0;
--
--        -- aq40      
--        for i = 21334, 21338 do
--            set_tier_ids[i] = set_tiers.pve_2_5_2;
--        end
--
--        --naxx
--        for i = 22504, 22511 do
--            set_tier_ids[i] = set_tiers.pve_3;
--        end
--        set_tier_ids[23063] = set_tiers.pve_3;
--
--        -- sod
--        for i = 226547, 226554 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_1;
--        end
--
--        for i = 231072, 231079 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_2;
--        end
--        set_tier_ids[231284] = set_tiers.sod_final_pve_zg;
--        for i = 231346, 231349 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_zg;
--        end
--
--    elseif class == "MAGE" then
--        -- zg
--        set_tier_ids[19601] = set_tiers.pve_2_5_0;
--        set_tier_ids[19959] = set_tiers.pve_2_5_0;
--        set_tier_ids[19846] = set_tiers.pve_2_5_0;
--        set_tier_ids[20034] = set_tiers.pve_2_5_0;
--        set_tier_ids[19845] = set_tiers.pve_2_5_0;
--
--        -- aq20
--        for i = 21413, 21415 do
--            set_tier_ids[i] = set_tiers.pve_2_5_1;
--        end
--
--        -- t1
--        for i = 16795, 16802 do
--            set_tier_ids[i] = set_tiers.pve_1;
--        end
--
--        -- t2
--        set_tier_ids[16818] = set_tiers.pve_2;
--        set_tier_ids[16912] = set_tiers.pve_2;
--        set_tier_ids[16913] = set_tiers.pve_2;
--        set_tier_ids[16914] = set_tiers.pve_2;
--        set_tier_ids[16915] = set_tiers.pve_2;
--        set_tier_ids[16916] = set_tiers.pve_2;
--        set_tier_ids[16917] = set_tiers.pve_2;
--        set_tier_ids[16918] = set_tiers.pve_2;
--
--        --sod pve t2
--        for i = 231100, 231107 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_2;
--        end
--        for i = 231108, 231115  do
--            set_tier_ids[i] = set_tiers.sod_final_pve_2_heal;
--        end
--        set_tier_ids[231282] = set_tiers.sod_final_pve_zg;
--        for i = 231324, 231327 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_zg;
--        end
--
--    elseif class == "PALADIN" then
--        -- zg
--        set_tier_ids[19588] = set_tiers.pve_2_5_0;
--        set_tier_ids[19952] = set_tiers.pve_2_5_0;
--        set_tier_ids[19827] = set_tiers.pve_2_5_0;
--        set_tier_ids[19826] = set_tiers.pve_2_5_0;
--        set_tier_ids[19825] = set_tiers.pve_2_5_0;
--
--        set_tier_ids[216486] = set_tiers.sod_p2_class;
--        set_tier_ids[216485] = set_tiers.sod_p2_class;
--        set_tier_ids[216484] = set_tiers.sod_p2_class;
--
--        --sod pve t2
--        for i = 231190, 231197  do
--            set_tier_ids[i] = set_tiers.sod_final_pve_2_heal;
--        end
--        set_tier_ids[231285] = set_tiers.sod_final_pve_zg;
--        for i = 231328, 231331 do
--            set_tier_ids[i] = set_tiers.sod_final_pve_zg;
--        end
--    end
--
--    set_tier_ids[213310] = set_tiers.sod_p2_anyclass;
--    set_tier_ids[213337] = set_tiers.sod_p2_anyclass;
--    set_tier_ids[213328] = set_tiers.sod_p2_anyclass;
--
--    return set_tier_ids;
--end
--
--local function create_set_effects() 
--
--    local set_effects = {};
--
--    if class == "PRIEST" then
--        set_effects = {
--            [set_tiers.pve_1] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.flash_heal, 0.1, 0.0);
--                end
--                if num_pieces >= 8 then
--                    spell_mod_add(effects.ability.crit, spids.prayer_of_healing, 0.25, 0.0);
--                end
--            end,
--            [set_tiers.pve_2] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    effects.raw.regen_while_casting = effects.raw.regen_while_casting + 0.15;
--                end
--            end,
--            [set_tiers.pve_2_5_1] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.effect_mod, spids.shadow_word_pain, 0.05, 0.0);
--                end
--            end,
--            [set_tiers.pve_2_5_2] = function(num_pieces, loadout, effects)
--                if num_pieces >= 5 then
--                    spell_mod_add(effects.ability.extra_ticks, spids.renew, 1, 0.0);
--                end
--            end,
--            [set_tiers.pve_3] = function(num_pieces, loadout, effects)
--                if num_pieces >= 2 then
--                    spell_mod_add(effects.ability.cost_mod, spids.renew, 0.12, 0.0);
--                end
--            end,
--            [set_tiers.sod_p3_t1] = function(num_pieces, loadout, effects)
--                if num_pieces >= 2 then
--                    effects.raw.mp5 = effects.raw.mp5 + 4;
--                end
--            end,
--            [set_tiers.sod_final_pve_1_heal] = function(num_pieces, loadout, effects)
--                if num_pieces >= 2 then
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.flash_heal, 0.1, 0.0);
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.greater_heal, 0.1, 0.0);
--                end
--                if num_pieces >= 6 then
--                    spell_mod_add(effects.ability.crit, spids.prayer_of_healing, 0.25, 0.0);
--                    spell_mod_add(effects.ability.crit, spids.circle_of_healing, 0.25, 0.0);
--                end
--            end,
--            [set_tiers.sod_final_pve_2_heal] = function(num_pieces, loadout, effects)
--                if num_pieces >= 2 then
--                    effects.raw.regen_while_casting = effects.raw.regen_while_casting + 0.15;
--                end
--            end,
--            [set_tiers.sod_final_pve_zg] = function(num_pieces, loadout, effects)
--                if num_pieces >= 5 then
--                    spell_mod_add(effects.ability.effect_mod, spids.power_word_shield, 0.1, 0.0);
--                end
--            end,
--        };
--
--    elseif class == "DRUID" then
--        set_effects = {
--            [set_tiers.pve_1] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.flat_add, spids.thorns, 4, 0.0);
--                end
--            end,
--            [set_tiers.pve_2] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    effects.raw.regen_while_casting = effects.raw.regen_while_casting + 0.15;
--                end
--                if num_pieces >= 5 then
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.regrowth, 0.2, 0.0);
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.nourish, 0.2, 0.0);
--                end
--                if num_pieces >= 8 then
--                    spell_mod_add(effects.ability.extra_ticks, spids.rejuvenation, 1, 0.0);
--                end
--            end,
--            [set_tiers.pve_2_5_0] = function(num_pieces, loadout, effects)
--                if num_pieces >= 5 then
--                    spell_mod_add(effects.ability.crit, spids.starfire, 0.03, 0.0);
--                end
--            end,
--            [set_tiers.pve_3] = function(num_pieces, loadout, effects)
--                if num_pieces >= 4 then
--                    local spells = {spids.healing_touch, spids.regrowth, spids.rejuvenation, spids.tranquility, spids.nourish};
--                    for k, v in pairs(spells) do
--                        spell_mod_add(effects.ability.cost_mod, v, 0.03, 0.0);
--                    end
--                end
--            end,
--            [set_tiers.sod_p2_class] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.crit, spids.wrath, 0.02, 0.0);
--                    spell_mod_add(effects.ability.crit, spids.starfire, 0.02, 0.0);
--                end
--            end,
--            [set_tiers.sod_p3_t1] = function(num_pieces, loadout, effects)
--                if num_pieces >= 2 then
--                    effects.raw.mp5 = effects.raw.mp5 + 4;
--                end
--            end,
--            [set_tiers.sod_p3_t1_dmg] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.crit, spids.wrath, 0.03, 0.0);
--                    spell_mod_add(effects.ability.crit, spids.starfire, 0.03, 0.0);
--                end
--            end,
--            [set_tiers.sod_final_pve_1] = function(num_pieces, loadout, effects)
--                if num_pieces >= 2 then
--                    spell_mod_add(effects.ability.effect_mod, spids.thorns, 1.0, 0.0);
--                end
--            end,
--            [set_tiers.sod_final_pve_1_heal] = function(num_pieces, loadout, effects)
--                if num_pieces >= 6 then
--                    spell_mod_add(effects.ability.effect_mod, spids.tranquility, 1.0, 0.0);
--                end
--            end,
--            [set_tiers.sod_final_pve_2] = function(num_pieces, loadout, effects)
--                if num_pieces >= 2 then
--                    spell_mod_add(effects.ability.effect_mod, spids.hurricane, 0.25, 0.0);
--                    spell_mod_add(effects.ability.effect_mod, spids.starfall, 0.25, 0.0);
--                end
--            end,
--            [set_tiers.sod_final_pve_2_heal] = function(num_pieces, loadout, effects)
--                if num_pieces >= 6 then
--                    spell_mod_add(effects.ability.effect_mod, spids.wild_growth, 0.1, 0.0);
--                end
--            end,
--            [set_tiers.sod_final_pve_zg] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.starfire, 0.5, 0.0);
--                end
--                if num_pieces >= 5 then
--                    spell_mod_add(effects.ability.crit, spids.wrath, 0.1, 0.0);
--                end
--            end,
--        };
--
--    elseif class == "SHAMAN" then
--        set_effects =  {
--            [set_tiers.pve_2_5_0] = function(num_pieces, loadout, effects)
--                if num_pieces >= 2 then
--                    effects.raw.mp5 = effects.raw.mp5 + 4;
--                end
--            end,
--            [set_tiers.pve_2_5_2] = function(num_pieces, loadout, effects)
--                if num_pieces >= 5 then
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.chain_heal, 0.4, 0.0);
--                end
--            end,
--            [set_tiers.pve_3] = function(num_pieces, loadout, effects)
--                if num_pieces >= 2 then
--                    local spells = {spids.healing_stream_totem, spids.magma_totem, spids.searing_totem, spids.mana_tide, spids.fire_nova_totem};
--                    for k, v in pairs(spells) do
--                        spell_mod_add(effects.ability.cost_mod, v, 0.03, 0.0);
--                    end
--                end
--            end,
--            [set_tiers.pvp_1] = function(num_pieces, loadout, effects)
--                if num_pieces >= 4 then
--                    local shocks = {spids.earth_shock, spids.flame_shock, spids.frost_shock};
--                    for k, v in pairs(shocks) do
--                        spell_mod_add(effects.ability.crit, v, 0.02, 0.0);
--                    end
--                end
--            end,
--            [set_tiers.pvp_2] = function(num_pieces, loadout, effects)
--                if num_pieces >= 4 then
--                    local shocks = {spids.earth_shock, spids.flame_shock, spids.frost_shock};
--                    for k, v in pairs(shocks) do
--                        spell_mod_add(effects.ability.crit, v, 0.02, 0.0);
--                    end
--                end
--            end,
--            [set_tiers.sod_p2_class] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.lightning_bolt, 0.2, 0.0);
--                end
--            end,
--            [set_tiers.sod_p3_t1] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.cast_mod, spids.healing_rain, 1.0, 0);
--                end
--            end,
--            [set_tiers.sod_final_pve_2_heal] = function(num_pieces, loadout, effects)
--                if num_pieces >= 6 then
--                    spell_mod_add(effects.ability.effect_mod, spids.chain_heal, 0.2, 0);
--                    spell_mod_add(effects.ability.effect_mod, spids.chain_lightning, 0.2, 0);
--                end
--            end,
--        };
--
--    elseif class == "WARLOCK" then
--        set_effects = {
--            [set_tiers.pve_1] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.effect_mod, spids.drain_life, 0.15, 0.0);
--                end
--                if num_pieces >= 8 then
--                    local shadow = {spids.curse_of_doom, spids.death_coil, spids.curse_of_agony, spids.drain_life, spids.corruption, spids.shadow_ward, spids.drain_soul};
--                    for k, v in pairs(shadow) do
--                        spell_mod_add(effects.ability.cost_mod, v, 0.15, 0.0);
--                    end
--                end
--            end,
--            [set_tiers.pve_2_5_0] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.effect_mod, spids.corruption, 0.02, 0.0);
--                end
--            end,
--            [set_tiers.pve_2_5_2] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.effect_mod_base, spids.immolate, 0.05, 0.0);
--                end
--                if num_pieces >= 5 then
--                    spell_mod_add(effects.ability.cost_mod, spids.shadow_bolt, 0.15, 0.0);
--                end
--            end,
--            [set_tiers.pve_3] = function(num_pieces, loadout, effects)
--                if num_pieces >= 4 then
--                    spell_mod_add(effects.ability.effect_mod, spids.corruption, 0.12, 0.0);
--                end
--            end,
--            [set_tiers.pvp_1] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.immolate, 0.2, 0.0);
--                end
--            end,
--            [set_tiers.pvp_2] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.immolate, 0.2, 0.0);
--                end
--            end,
--            [set_tiers.sod_final_pve_1] = function(num_pieces, loadout, effects)
--                if num_pieces >= 2 then
--                    spell_mod_add(effects.ability.effect_mod, spids.life_tap, 0.5, 0.0);
--                end
--            end,
--            [set_tiers.sod_final_pve_2] = function(num_pieces, loadout, effects)
--                if num_pieces >= 2 then
--                    spell_mod_add(effects.ability.effect_mod, spids.corruption, 0.1, 0.0);
--                    spell_mod_add(effects.ability.effect_mod, spids.immolate, 0.1, 0.0);
--                    spell_mod_add(effects.ability.effect_mod, spids.drain_life, 0.1, 0.0);
--                    spell_mod_add(effects.ability.effect_mod, spids.curse_of_agony, 0.1, 0.0);
--                    spell_mod_add(effects.ability.effect_ot_mod, spids.immolate, 0.1, 0.0);
--                    spell_mod_add(effects.ability.effect_mod, spids.rain_of_fire, 0.1, 0.0);
--                    spell_mod_add(effects.ability.effect_mod, spids.drain_soul, 0.1, 0.0);
--                    spell_mod_add(effects.ability.effect_mod, spids.siphon_life, 0.1, 0.0);
--                    spell_mod_add(effects.ability.effect_ot_mod, spids.shadowflame, 0.1, 0.0);
--                end
--            end,
--        };
--
--
--    elseif class == "MAGE" then
--        set_effects = {
--            [set_tiers.pve_1] = function(num_pieces, loadout, effects)
--                if num_pieces >= 5 then
--                    for i = 2,7 do
--                        effects.by_school.target_res[i] = 
--                            effects.by_school.target_res[i] - 10;
--                    end
--                end
--            end,
--            [set_tiers.pve_2_5_0] = function(num_pieces, loadout, effects)
--                if num_pieces >= 5 then
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.flamestrike, 0.5, 0.0);
--                end
--            end,
--            [set_tiers.pve_2_5_1] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.effect_mod, spids.mana_shield, 0.15, 0.0);
--                end
--            end,
--            [set_tiers.sod_final_pve_zg] = function(num_pieces, loadout, effects)
--                if num_pieces >= 5 then
--                    spell_mod_add(effects.ability.effect_mod, spids.frostbolt, 0.65, 0.0);
--                    spell_mod_add(effects.ability.effect_mod, spids.spellfrost_bolt, 0.65, 0.0);
--                end
--            end,
--        };
--
--    elseif class == "PALADIN" then
--        -- TODO VANILLA: Tier3 holy power buff tracking
--        set_effects = {
--            [set_tiers.pve_2_5_0] = function(num_pieces, loadout, effects)
--                if num_pieces >= 2 then
--                    effects.raw.mp5 = effects.raw.mp5 + 4;
--                end
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.cast_mod_flat, spids.holy_light, 0.1, 0.0);
--                end
--            end,
--            [set_tiers.sod_p2_class] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.crit, spids.holy_shock, 0.02, 0.0);
--                end
--            end,
--            [set_tiers.sod_final_pve_2_heal] = function(num_pieces, loadout, effects)
--                if num_pieces >= 2 then
--                    spell_mod_add(effects.ability.crit, spids.holy_shock, 0.05, 0.0);
--                end
--                if num_pieces >= 4 then
--                    spell_mod_add(effects.ability.effect_mod, spids.consecration, 0.5, 0.0);
--                end
--            end,
--            [set_tiers.sod_final_pve_zg] = function(num_pieces, loadout, effects)
--                if num_pieces >= 3 then
--                    spell_mod_add(effects.ability.effect_mod, spids.holy_shock, 0.5, 0.0);
--                    spell_mod_add(effects.ability.effect_mod_only_heal, spids.holy_shock, -0.5, 0.0);
--                end
--                if num_pieces >= 5 then
--                    spell_mod_add(effects.ability.effect_mod, spids.exorcism, 0.5, 0.0);
--                end
--            end,
--        };
--    end
--    set_effects[set_tiers.sod_p2_anyclass] = function(num_pieces, loadout, effects)
--        if num_pieces >= 3 then
--            effects.raw.mp5 = effects.raw.mp5 + 7;
--        end
--    end;
--
--    return set_effects;
--end 
--
--
--local function create_relics()
--    if class == "PALADIN" then
--        return {
--            [23201] = function(effects)
--                spell_mod_add(effects.ability.sp, spids.flash_of_light, 53, 0.0);
--            end,
--            [23202] = function(effects)
--                spell_mod_add(effects.ability.sp, spids.flash_of_light, 53, 0.0);
--            end,
--            [23006] = function(effects)
--                spell_mod_add(effects.ability.sp, spids.flash_of_light, 83, 0.0);
--            end,
--        };
--    elseif class == "SHAMAN" then
--        return {
--            [22395] = function(effects)
--                spell_mod_add(effects.ability.sp, spids.earth_shock, 30, 0.0);
--                spell_mod_add(effects.ability.sp, spids.flame_shock, 30, 0.0);
--                spell_mod_add(effects.ability.sp, spids.frost_shock, 30, 0.0);
--            end,
--            [23200] = function(effects)
--                spell_mod_add(effects.ability.sp, spids.lesser_healing_wave, 53, 0.0);
--            end,
--            [22396] = function(effects)
--                spell_mod_add(effects.ability.sp, spids.lesser_healing_wave, 80, 0.0);
--            end,
--            [23199] = function(effects)
--                spell_mod_add(effects.ability.sp, spids.chain_lightning, 33, 0.0);
--                spell_mod_add(effects.ability.sp, spids.lightning_bolt, 33, 0.0);
--            end,
--            [23005] = function(effects)
--                spell_mod_add(effects.ability.refund, spids.lesser_healing_wave, 10, 0.0);
--            end,
--            [215436] = function(effects)
--                spell_mod_add(effects.ability.cost_mod_flat, spids.flame_shock, 10, 0.0);
--            end,
--            [228179] = function(effects)
--                spell_mod_add(effects.ability.cast_mod, spids.healing_rain, 1.0, 0.0);
--            end,
--            [228176] = function(effects)
--                spell_mod_add(effects.ability.cast_mod_flat, spids.lightning_bolt, 0.1, 0.0);
--            end,
--        };
--    elseif class == "DRUID" then
--        return {
--            [22398] = function(effects)
--                spell_mod_add(effects.ability.sp, spids.rejuvenation, 50, 0.0);
--            end,
--            [23197] = function(effects)
--                spell_mod_add(effects.ability.effect_mod, spids.moonfire, 0.17, 0.0);
--                spell_mod_add(effects.ability.effect_mod, spids.sunfire, 0.17, 0.0);
--                spell_mod_add(effects.ability.effect_mod, spids.starfall, 0.17, 0.0);
--            end,
--            [22399] = function(effects)
--                spell_mod_add(effects.ability.cast_mod_flat, spids.healing_touch, 0.15, 0.0);
--                spell_mod_add(effects.ability.cast_mod_flat, spids.nourish, 0.15, 0.0);
--            end,
--            [23004] = function(effects)
--                spell_mod_add(effects.ability.refund, spids.healing_touch, 25, 0.0);
--                spell_mod_add(effects.ability.refund, spids.nourish, 25, 0.0);
--            end,
--            [216490] = function(effects)
--                spell_mod_add(effects.ability.effect_mod, spids.wrath, 0.02, 0.0);
--            end,
--            [228183] = function(effects)
--                spell_mod_add(effects.ability.refund, spids.regrowth, 25, 0.0);
--                spell_mod_add(effects.ability.refund, spids.nourish, 25, 0.0);
--            end,
--            [228180] = function(effects)
--                spell_mod_add(effects.ability.extra_ticks, spids.insect_swarm, 6, 0.0);
--            end,
--        };
--    else 
--        return {};
--    end
--    
--end 
--
--local set_items = create_sets();
--
--local set_bonus_effects = create_set_effects();
--
--local relics = create_relics();
--
--local function create_items()
--    if class == "PRIEST" then
--        return {
--            [19594] = function(effects)
--                spell_mod_add(effects.ability.flat_add, spids.power_word_shield, 35, 0.0);
--            end,
--            [231332] = function(effects)
--                spell_mod_add(effects.ability.flat_add, spids.power_word_shield, 25, 0.0);
--            end,
--        };
--    elseif class == "DRUID" then
--        return {
--            [231316] = function(effects)
--                spell_mod_add(effects.ability.crit, spids.wrath, 0.02, 0.0);
--                spell_mod_add(effects.ability.crit, spids.starfire, 0.02, 0.0);
--            end,
--        };
--    elseif class == "PALADIN" then
--        return {
--            [231328] = function(effects)
--                spell_mod_add(effects.ability.crit, spids.holy_shock, 0.02, 0.0);
--            end,
--        };
--    else
--        return {};
--    end
--end
--
--local items = create_items();

local function detect_sets(loadout)

    -- TMP
    for k, v in pairs(set_tiers) do
        loadout.num_set_pieces[v] = 0;
    end
    -- Real ting
    for k, _ in pairs(swc.set_bonuses) do
        loadout.num_set_pieces[k] = 0;
    end

    for item = 1, 18 do
        local id = GetInventoryItemID("player", item);
        if swc.set_items[id] then
            local set_id = swc.set_items[id];
            if not loadout.num_set_pieces[set_id] then
                loadout.num_set_pieces[set_id] = 0;
            end
            loadout.num_set_pieces[set_id] = loadout.num_set_pieces[set_id] + 1;
        end
    end
end

local wpn_strs = { [16] = "mh", [17] = "oh", [18] = "ranged"};

local function apply_equipment(loadout, effects)

    detect_sets(loadout);

    local found_anything = false;

    for set_id, num in pairs(loadout.num_set_pieces) do
        if num < 2 then

            if swc.set_bonuses[set_id] then -- remove this check when old sets handling is gone
                for threshold, effect_id in pairs(swc.set_bonuses[set_id]) do
                    if num < threshold then
                        break;
                    end
                    swc.loadout.apply_effect(loadout, effects, effect_id, swc.set_effects[effect_id], false, 1.0);
                end
            end
        end
    end

    -- NOTE: shortly after logging in, the equipment querying API won't work
    --       (but does for /reload). Track if we get nothing so we can signal
    --       that equipment scanning needs to be done again on next update
    loadout.crit_rating = 0;

    for item = 1, 18 do
        local item_link = GetInventoryItemLink("player", item);
        if item_link then
            local id = GetInventoryItemID("player", i);
            if id and swc.items[id] then
                swc.loadout.apply_effect(loadout, effects, id, swc.item_effects[id], false, 1.0);
            end
            found_anything = true;
            local item_stats = GetItemStats(item_link);
            if item_stats then

                if item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] then
                    effects.raw.mp5 = effects.raw.mp5 + item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] + 1;
                end

                if item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] then
                    for i = 2,7 do
                        effects.by_school.target_res_flat[i] = 
                            effects.by_school.target_res_flat[i] + (item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] - 1);
                    end
                end
            end
        end
        if wpn_strs[item] then
            if item_link then
                local subclass_id = select(13, GetItemInfo(item_link));
                loadout[wpn_strs[item].."_subclass"] = subclass_id;
            else
                loadout[wpn_strs[item].."_subclass"] = -1;
            end
        end
    end

    loadout.enchant_effects_applied = {};
    -- just do weapon enchants for now, are others even needed?
    local _, _, _, enchant_id = GetWeaponEnchantInfo();
    if swc.enchants[enchant_id] then
        for _, spid in pairs(swc.enchants[enchant_id]) do
            swc.loadout.apply_effect(loadout, effects, spid, swc.enchant_effects[spid], false, 1.0, false);
            loadout.enchant_effects_applied[spid] = 1;
        end
    end

    if C_Engraving and C_Engraving.IsEngravingEnabled then
        for i = 1, 18 do
            local rune_slot = C_Engraving.GetRuneForEquipmentSlot(i);
            if rune_slot then
                if rune_slot.itemEnchantmentID then
                    if swc.enchants[rune_slot.itemEnchantmentID] then
                        for _, spid in pairs(swc.enchants[rune_slot.itemEnchantmentID]) do
                            swc.loadout.apply_effect(loadout, effects, spid, swc.enchant_effects[spid], false, 1.0, false);
                            loadout.enchant_effects_applied[spid] = 1;
                        end
                    end

                end
            end
        end
    end

    for ench_id, _ in pairs(loadout.enchants) do

    end

    if swc.core.__sw__test_all_codepaths then
        --for k, v in pairs(items) do
        --    if v then
        --        v(effects);
        --    end
        --end
        --for _, v in pairs(relics) do
        --    if v then
        --        v(effects);
        --    end
        --end
        --for k, v in pairs(loadout.num_set_pieces) do
        --    loadout.num_set_pieces[k] = 10;
        --end
        --for k, v in pairs(loadout.num_set_pieces) do
        --    if set_bonus_effects[k] then
        --        set_bonus_effects[k](v, loadout, effects);
        --    end
        --end

        -- Testing all items
        local items_applied = 0;
        for _, v in pairs(swc.items) do
            for _, id in pairs(v) do
                swc.loadout.apply_effect(loadout, effects, id, swc.item_effects[id], true, 1.0);
                items_applied = items_applied + 1;
            end
        end
        print(items_applied, "gen items applied");
        local sets_applied = 0;
        for _, v in pairs(swc.set_bonuses) do
            for _, bonus in pairs(v) do
                local id = bonus[2];

                swc.loadout.apply_effect(loadout, effects, id, swc.set_effects[id], true, 1.0);
                sets_applied = sets_applied + 1;
            end
        end
        print(sets_applied, "gen sets applied");

        local enchants_applied = 0;
        for _, v in pairs(swc.enchants) do
            for _, id in pairs(v) do

                swc.loadout.apply_effect(loadout, effects, id, swc.enchant_effects[id], true, 1.0);
                enchants_applied = enchants_applied + 1;
            end
        end
        print(enchants_applied, "gen enchants applied");
    end

    return found_anything;
end

equipment.set_tiers = set_tiers;
equipment.apply_equipment = apply_equipment;

swc.equipment = equipment;
