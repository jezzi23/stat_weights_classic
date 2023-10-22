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
--
local addon_name, swc = ...;

local ensure_exists_and_add             = swc.utils.ensure_exists_and_add;
local ensure_exists_and_mul             = swc.utils.ensure_exists_and_mul;
local class                             = swc.utils.class;
local stat                              = swc.utils.stat;

local magic_school                      = swc.abilities.magic_school;
local spell_name_to_id                  = swc.abilities.spell_name_to_id;
local spell_names_to_id                 = swc.abilities.spell_names_to_id;

-------------------------------------------------------------------------------
local equipment = {};

local set_tiers = {
    pve_t7_1         = 1,
    pve_t7_2         = 2,
    pve_t7_3         = 3,
    pve_t8_1         = 4,
    pve_t8_2         = 5,
    pve_t8_3         = 6,
    pve_t9_1         = 7,
    pve_t9_2         = 8,
    pve_t9_3         = 9,
};

local function create_sets()

    local set_tier_ids = {};

    if class == "PRIEST" then

        -- t7 healing 
        for i = 39514, 39519 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        for i = 40445, 40450 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        -- t7 shadow
        set_tier_ids[39521] = set_tiers.pve_t7_3;
        set_tier_ids[39523] = set_tiers.pve_t7_3;
        for i = 39528, 39530 do
            set_tier_ids[i] = set_tiers.pve_t7_3;
        end
        set_tier_ids[40454] = set_tiers.pve_t7_3;
        for i = 40456, 40459 do
            set_tier_ids[i] = set_tiers.pve_t7_3;
        end

        -- t8 healing 
        for i = 45386, 45390 do
            set_tier_ids[i] = set_tiers.pve_t8_1;
        end
        set_tier_ids[46188] = set_tiers.pve_t8_1;
        set_tier_ids[46190] = set_tiers.pve_t8_1;
        set_tier_ids[46193] = set_tiers.pve_t8_1;
        set_tier_ids[46195] = set_tiers.pve_t8_1;
        set_tier_ids[46197] = set_tiers.pve_t8_1;

        -- t8 shadow
        set_tier_ids[46163] = set_tiers.pve_t8_3;
        set_tier_ids[46165] = set_tiers.pve_t8_3;
        set_tier_ids[46168] = set_tiers.pve_t8_3;
        set_tier_ids[46170] = set_tiers.pve_t8_3;
        set_tier_ids[46172] = set_tiers.pve_t8_3;

        for i = 45391, 45395 do
            set_tier_ids[i] = set_tiers.pve_t8_3;
        end

        -- t9 healing
        for i = 48062, 48066 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 48067, 48071 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 48750, 48754 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 48057, 48061 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        -- t9 shadow
        for i = 48087, 48091 do
            set_tier_ids[i] = set_tiers.pve_t9_3;
        end
        for i = 48760, 48764 do
            set_tier_ids[i] = set_tiers.pve_t9_3;
        end
        for i = 48097, 48101 do
            set_tier_ids[i] = set_tiers.pve_t9_3;
        end
        for i = 48092, 48096 do
            set_tier_ids[i] = set_tiers.pve_t9_3;
        end

    elseif class == "DRUID" then
        -- t7 balance
        for i = 39544, 39548 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        for i = 40466, 40470 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        -- t7 resto
        for i = 40460, 40463 do
            set_tier_ids[i] = set_tiers.pve_t7_3;
        end
        set_tier_ids[40465] = set_tiers.pve_t7_3;

        set_tier_ids[39531] = set_tiers.pve_t7_3;
        set_tier_ids[39538] = set_tiers.pve_t7_3;
        set_tier_ids[39539] = set_tiers.pve_t7_3;
        set_tier_ids[39542] = set_tiers.pve_t7_3;
        set_tier_ids[39543] = set_tiers.pve_t7_3;

        -- t8 balance
        set_tier_ids[46313] = set_tiers.pve_t8_1;
        for i = 45351, 45354 do
            set_tier_ids[i] = set_tiers.pve_t8_1;
        end

        set_tier_ids[46189] = set_tiers.pve_t8_1;
        set_tier_ids[46191] = set_tiers.pve_t8_1;
        set_tier_ids[46192] = set_tiers.pve_t8_1;
        set_tier_ids[46194] = set_tiers.pve_t8_1;
        set_tier_ids[46196] = set_tiers.pve_t8_1;

        -- t8 resto
        for i = 45345, 45349 do
            set_tier_ids[i] = set_tiers.pve_t8_3;
        end
        for i = 46183, 46187 do
            set_tier_ids[i] = set_tiers.pve_t8_3;
        end

        -- t9 balance
        for i = 48781, 48785 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 48178, 48182 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 48183, 48187 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 48173, 48177 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end

        -- t9 resto
        for i = 48148, 48152 do
            set_tier_ids[i] = set_tiers.pve_t9_3;
        end
        for i = 48769, 48773 do
            set_tier_ids[i] = set_tiers.pve_t9_3;
        end
        for i = 48153, 48157 do
            set_tier_ids[i] = set_tiers.pve_t9_3;
        end
        for i = 48143, 48147 do
            set_tier_ids[i] = set_tiers.pve_t9_3;
        end


    elseif class == "SHAMAN" then
        -- t7 elemental
        for i = 39592, 39596 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        for i = 40514, 40518 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        -- t7 enhancement
        set_tier_ids[39597] = set_tiers.pve_t7_2;
        for i = 39601, 39604 do
            set_tier_ids[i] = set_tiers.pve_t7_2;
        end
        for i = 40520, 40524 do
            set_tier_ids[i] = set_tiers.pve_t7_2;
        end

        -- t7 restoration
        for i = 40508, 40513 do
            set_tier_ids[i] = set_tiers.pve_t7_3;
        end
        for i = 40520, 40524 do
            set_tier_ids[i] = set_tiers.pve_t7_3;
        end

        set_tier_ids[39583] = set_tiers.pve_t7_3;
        set_tier_ids[39588] = set_tiers.pve_t7_3;
        for i = 39589, 39591 do
            set_tier_ids[i] = set_tiers.pve_t7_3;
        end

        -- t8 elemental
        set_tier_ids[46206] = set_tiers.pve_t8_1;
        set_tier_ids[46207] = set_tiers.pve_t8_1;
        set_tier_ids[46209] = set_tiers.pve_t8_1;
        set_tier_ids[46210] = set_tiers.pve_t8_1;
        set_tier_ids[46211] = set_tiers.pve_t8_1;

        for i = 45406, 45411 do
            set_tier_ids[i] = set_tiers.pve_t8_1;
        end

        -- t8 resto
        set_tier_ids[46198] = set_tiers.pve_t8_3;
        set_tier_ids[46199] = set_tiers.pve_t8_3;
        set_tier_ids[46201] = set_tiers.pve_t8_3;
        set_tier_ids[46202] = set_tiers.pve_t8_3;
        set_tier_ids[46204] = set_tiers.pve_t8_3;

        for i = 45401, 45405 do
            set_tier_ids[i] = set_tiers.pve_t8_3;
        end

        -- t9 resto
        for i = 48295, 48299 do
            set_tier_ids[i] = set_tiers.pve_t9_3;
        end
        for i = 48829, 48833 do
            set_tier_ids[i] = set_tiers.pve_t9_3;
        end
        for i = 48305, 48309 do
            set_tier_ids[i] = set_tiers.pve_t9_3;
        end
        for i = 48300, 48304 do
            set_tier_ids[i] = set_tiers.pve_t9_3;
        end

        --t9 enhance
        for i = 48366, 48370 do
            set_tier_ids[i] = set_tiers.pve_t9_2;
        end
        for i = 48851, 48855 do
            set_tier_ids[i] = set_tiers.pve_t9_2;
        end
        for i = 48361, 48365 do
            set_tier_ids[i] = set_tiers.pve_t9_2;
        end
        for i = 48356, 48360 do
            set_tier_ids[i] = set_tiers.pve_t9_2;
        end

        --t9 elemental
        for i = 48841, 48845 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 48836, 48840 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 48331, 48335 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 48326, 48330 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end

    elseif class == "WARLOCK" then
        -- t8
        for i = 46242, 46246 do
            set_tier_ids[i] = set_tiers.pve_t8_1;
        end
        for i = 46135, 46140 do
            set_tier_ids[i] = set_tiers.pve_t8_1;
        end
        -- t9
        for i = 47798, 47802 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 48735, 48739 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 47803, 47807 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 47793, 47797 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end

    elseif class == "MAGE" then
        -- t7
        for i = 39491, 39495 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        for i = 40415, 40419 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        -- t9
        for i = 47773, 47777 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 48730, 48734 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 47768, 47772 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 47763, 47767 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end


    elseif class == "PALADIN" then
        -- t7 holy
        for i = 39628, 39632 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        for i = 40569, 40573 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        -- t8 holy
        for i = 46178, 46182 do
            set_tier_ids[i] = set_tiers.pve_t8_1;
        end
        for i = 45370, 45374 do
            set_tier_ids[i] = set_tiers.pve_t8_1;
        end

        --t9 holy
        for i = 48595, 48599 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 48905, 48909 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
        for i = 48585, 48589 do
            set_tier_ids[i] = set_tiers.pve_t9_1;
        end
    end

    return set_tier_ids;
end

local function create_set_effects() 

    if class == "PRIEST" then
        return {
            [set_tiers.pve_t7_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    -- TODO: POM calculation done in later stage
                end
                if num_pieces >= 4 then
                    local gh = spell_name_to_id["Greater Heal"];
                    ensure_exists_and_add(effects.ability.cost_mod, gh, 0.05, 0.0);
                end
            end,
            [set_tiers.pve_t7_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    local mb = spell_name_to_id["Mind Blast"];
                    ensure_exists_and_add(effects.ability.cost_mod, mb, 0.1, 0.0);
                end
                if num_pieces >= 4 then
                    local swd = spell_name_to_id["Shadow Word: Death"];
                    ensure_exists_and_add(effects.ability.crit, swd, 0.1, 0.0);
                end
            end,
            [set_tiers.pve_t8_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Prayer of Healing"], 0.1, 0.0);
                end
            end,
            [set_tiers.pve_t8_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Devouring Plague"], 0.15, 0.0);
                end
            end,
            [set_tiers.pve_t9_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Prayer of Mending"], 0.2, 0.0);
                end
            end,
            [set_tiers.pve_t9_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    ensure_exists_and_add(effects.ability.extra_ticks, spell_name_to_id["Vampiric Touch"], 2, 0.0);
                end
                if num_pieces >= 4 then
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Mind Flay"], 0.05, 0.0);
                end
            end,
        };

    elseif class == "DRUID" then
        return {
            [set_tiers.pve_t7_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    local is = spell_name_to_id["Insect Swarm"];
                    ensure_exists_and_add(effects.ability.effect_mod, is, 0.1, 0.0);
                    
                end
                if num_pieces >= 4 then
                    local abilities = spell_names_to_id({"Wrath", "Starfire"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(effects.ability.crit, v, 0.05, 0.0);
                    end
                end
            end,
            [set_tiers.pve_t7_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    local lb = spell_name_to_id["Lifebloom"];
                    ensure_exists_and_add(effects.ability.cost_mod, lb, 0.05, 0.0);
                end
                if num_pieces >= 4 then
                    -- TODO: awkward to implement, could track hots on target and estimate
                end
            end,
            [set_tiers.pve_t8_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    -- done in later stage
                end
            end,
            [set_tiers.pve_t8_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Swiftmend"], 0.1, 0.0);
                end
                if num_pieces >= 4 then
                    -- done in later stage
                end
            end,
            [set_tiers.pve_t9_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 4 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Starfire"], 0.04, 0.0);
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Wrath"], 0.04, 0.0);
                end
            end,
            [set_tiers.pve_t9_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Nourish"], 0.05, 0.0);
                end
            end,
        };

    elseif class == "SHAMAN" then
        return {
            [set_tiers.pve_t7_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Lightning Bolt"], 0.05, 0.0);
                end
                if num_pieces >= 4 then
                    ensure_exists_and_add(effects.ability.crit_mod, spell_name_to_id["Lava Burst"], 0.05, 0.0);
                end
            end,
            [set_tiers.pve_t7_2] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Lightning Bolt"], 0.1, 0.0);
                end
            end,
            [set_tiers.pve_t7_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    -- TODO: water shield
                end
                if num_pieces >= 4 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Chain Heal"], 0.05, 0.0);
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Healing Wave"], 0.05, 0.0);
                end
            end,
            [set_tiers.pve_t8_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    ensure_exists_and_add(effects.ability.effect_ot_mod, spell_name_to_id["Flame Shock"], 0.2, 0.0);
                end
                if num_pieces >= 4 then
                    -- Done in later stage
                end
            end,
            [set_tiers.pve_t8_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 4 then
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Chain Heal"], 0.2, 0.0);
                end
            end,
            [set_tiers.pve_t9_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    ensure_exists_and_add(effects.ability.extra_ticks, spell_name_to_id["Flame Shock"], 3, 0.0);
                end
                -- 4 set done in later stage
            end,
            [set_tiers.pve_t9_2] = function(num_pieces, loadout, effects)
                if num_pieces >= 4 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Flame Shock"], 0.25, 0.0);
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Earth Shock"], 0.25, 0.0);
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Frost Shock"], 0.25, 0.0);
                end
            end,
            [set_tiers.pve_t9_3] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Riptide"], 0.2, 0.0);
                end
                if num_pieces >= 4 then
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Chain Heal"], 0.05, 0.0);
                end
            end,
        };

    elseif class == "WARLOCK" then
        return {
            [set_tiers.pve_t7_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Unstable Affliction"], 0.2, 0.0);
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Immolate"], 0.1, 0.0);
                end
                if num_pieces >= 4 then
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Shadow Bolt"], 0.05, 0.0);
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Incinerate"], 0.05, 0.0);
                end
            end,
            [set_tiers.pve_t9_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 4 then
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Immolate"], 0.1, 0.0);
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Corruption"], 0.1, 0.0);
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Unstable Affliction"], 0.1, 0.0);
                end
            end,
        };


    elseif class == "MAGE" then
        return {
            [set_tiers.pve_t7_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 4 then
                    effects.by_school.spell_crit_mod[magic_school.fire] = 
                        effects.by_school.spell_crit_mod[magic_school.fire] + 0.025;
                    effects.by_school.spell_crit_mod[magic_school.arcane] = 
                        effects.by_school.spell_crit_mod[magic_school.arcane] + 0.025;
                    effects.by_school.spell_crit_mod[magic_school.frost] = 
                        effects.by_school.spell_crit_mod[magic_school.frost] + 0.025;
                end
            end,
            [set_tiers.pve_t9_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 4 then
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Fireball"], 0.05, 0.0);
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Frostbolt"], 0.05, 0.0);
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Frostfire Bolt"], 0.05, 0.0);
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Arcane Blast"], 0.05, 0.0);
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Arcane Missiles"], 0.05, 0.0);
                end
            end,
        };

    elseif class == "PALADIN" then
        return {
            [set_tiers.pve_t7_1] = function(num_pieces, loadout, effects)
                if num_pieces >= 2 then
                    local hs = spell_name_to_id["Holy Shock"];
                    ensure_exists_and_add(effects.ability.crit, hs, 0.1, 0.0);

                end
                if num_pieces >= 4 then
                    local hl = spell_name_to_id["Holy Light"];
                    ensure_exists_and_add(effects.ability.cost_mod, hl, 0.05, 0.0);
                end
            end,
        };
    end
end 


local function create_relics()
    if class == "PALADIN" then
        return {
            [40705] = function(effects)
                ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Holy Light"], 113, 0.0);
            end,
            [40268] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Holy Light"], 141, 0.0);
            end,
            [42614] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 331, 0.0);
            end,
            [42612] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 204, 0.0);
            end,
            [42613] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 293, 0.0);
            end,
            [45436] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Holy Light"], 169, 0.0);
            end,
            [28592] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 89, 0.0);
            end,
            [42615] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 375, 0.0);
            end,
            [38364] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Holy Shock"], 69, 0.0);
            end,
            [23006] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 43, 0.0);
            end,
            [23201] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 28, 0.0);
            end,
            [199635] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 47, 0.0);
            end,
            [30063] = function(effects)
                ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Holy Light"], 34, 0.0);
            end,
            [25644] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 79, 0.0);
            end,
            [28296] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Holy Light"], 47, 0.0);
            end,
            [51472] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 510, 0.0);
            end,
            [186065] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Flash of Light"], 10, 0.0);
            end,
            [42616] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flash of Light"], 436, 0.0);
            end,

        };
    elseif class == "SHAMAN" then
        return {
            [40267] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Chain Lightning"], 165, 0.0);
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lightning Bolt"], 165, 0.0);
            end,
            [45114] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Chain Heal"], 257, 0.0);
            end,
            [40709] = function(effects)
                ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Chain Heal"], 78, 0.0);
            end,
            [45255] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Lava Burst"], 227, 0.0);
            end,
            [38368] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Chain Heal"], 102, 0.0);
            end,
            [39728] = function(effects)
                ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Healing Wave"], 79, 0.0);
            end,
            [38361] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Lava Burst"], 121, 0.0);
            end,
            [42597] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lesser Healing Wave"], 267, 0.0);
            end,
            [25645] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lesser Healing Wave"], 79, 0.0);
            end,
            [42596] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lesser Healing Wave"], 236, 0.0);
            end,
            [23199] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Chain Lightning"], 33, 0.0);
            end,
            [27544] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Healing Wave"], 88, 0.0);
            end,
            [32330] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Chain Lightning"], 85, 0.0);
            end,
            [22395] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Earth Shock"], 30, 0.0);
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flame Shock"], 30, 0.0);
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Frost Shock"], 30, 0.0);
            end,
            [33505] = function(effects)
                ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Chain Heal"], 20, 0.0);
            end,
            [186072] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lesser Healing Wave"], 10, 0.0);
            end,
            [28066] = function(effects)
                ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Lightning Bolt"], 15, 0.0);
            end,
            [27947] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Earth Shock"], 46, 0.0);
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flame Shock"], 46, 0.0);
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Frost Shock"], 46, 0.0);
            end,
            [28248] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Chain Lightning"], 55, 0.0);
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lightning Bolt"], 55, 0.0);
            end,
            [42595] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lesser Healing Wave"], 204, 0.0);
            end,
            [22396] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lesser Healing Wave"], 80, 0.0);
            end,
            [23200] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lesser Healing Wave"], 53, 0.0);
            end,
            [27984] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Earth Shock"], 46, 0.0);
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Flame Shock"], 46, 0.0);
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Frost Shock"], 46, 0.0);
            end,
            [28523] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Chain Heal"], 87, 0.0);
            end,
            [51501] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lesser Healing Wave"], 459, 0.0);
            end,
            [199643] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lesser Healing Wave"], 88, 0.0);
            end,
            [42598] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lesser Healing Wave"], 338, 0.0);
            end,
            [23005] = function(effects)
                ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Lesser Healing Wave"], 10, 0.0);
            end,
            [29389] = function(effects)
                ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Lightning Bolt"], 27, 0.0);
            end,
            [30023] = function(effects)
                ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Healing Wave"], 24, 0.0);
            end,
            [42599] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lesser Healing Wave"], 404, 0.0);
            end,
            [199642] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Chain Lightning"], 55, 0.0);
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lightning Bolt"], 55, 0.0);
            end,
            [186071] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Chain Lightning"], 10, 0.0);
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lightning Bolt"], 10, 0.0);
            end,
        };
    elseif class == "DRUID" then
        return {
            [40321] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Starfire"], 165, 0.0);
            end,
            [40342] = function(effects)
                ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Rejuvenation"], 106, 0.0);
            end,
            [33508] = function(effects)
                ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Rejuvenation"], 36, 0.0);
            end,
            [40712] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Wrath"], 70, 0.0);
            end,
            [40711] = function(effects)
                ensure_exists_and_add(effects.ability.sp_ot, spell_name_to_id["Lifebloom"], 125, 0.0);
            end,
            [38366] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add_ot, spell_name_to_id["Rejuvenation"], 33, 0.0);
            end,
            [45270] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Insect Swarm"], 396, 0.0);
            end,
            [25643] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Rejuvenation"], 86, 0.0);
            end,
            [46138] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Nourish"], 198, 0.0);
            end,
            [42578] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lifebloom"], 246, 0.0);
                ensure_exists_and_add(effects.ability.sp_ot, spell_name_to_id["Lifebloom"], -246, 0.0);
            end,
            [23197] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Moonfire"], 33, 0.0);
            end,
            [42577] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lifebloom"], 217, 0.0);
                ensure_exists_and_add(effects.ability.sp_ot, spell_name_to_id["Lifebloom"], -217, 0.0);
            end,
            [22398] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Rejuvenation"], 50, 0.0);
            end,
            [31025] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Wrath"], 25, 0.0);
            end,
            [42576] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lifebloom"], 188, 0.0);
                ensure_exists_and_add(effects.ability.sp_ot, spell_name_to_id["Lifebloom"], -188, 0.0);
            end,
            [27518] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Starfire"], 55, 0.0);
            end,
            [35021] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lifebloom"], 131, 0.0);
                ensure_exists_and_add(effects.ability.sp_ot, spell_name_to_id["Lifebloom"], -131, 0.0);
            end,
            [186054] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Rejuvenation"], 15, 0.0);
            end,
            [199640] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Rejuvenation"], 90, 0.0);
            end,
            [33076] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lifebloom"], 105, 0.0);
                ensure_exists_and_add(effects.ability.sp_ot, spell_name_to_id["Lifebloom"], -105, 0.0);
            end,
            [199638] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Moonfire"], 55, 0.0);
            end,
            [27886] = function(effects)
                ensure_exists_and_add(effects.ability.sp_ot, spell_name_to_id["Lifebloom"], 47, 0.0);
            end,
            [23004] = function(effects)
                ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Healing Touch"], 25, 0.0);
            end,
            [51423] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lifebloom"], 448, 0.0);
                ensure_exists_and_add(effects.ability.sp_ot, spell_name_to_id["Lifebloom"], -448, 0.0);
            end,
            [42579] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lifebloom"], 311, 0.0);
                ensure_exists_and_add(effects.ability.sp_ot, spell_name_to_id["Lifebloom"], -311, 0.0);
            end,
            [28568] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Healing Touch"], 136, 0.0);
            end,
            [30051] = function(effects)
                ensure_exists_and_add(effects.ability.cost_flat, spell_name_to_id["Regrowth"], 65, 0.0);
            end,
            [28355] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lifebloom"], 87, 0.0);
                ensure_exists_and_add(effects.ability.sp_ot, spell_name_to_id["Lifebloom"], -87, 0.0);
            end,
            [33841] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lifebloom"], 116, 0.0);
                ensure_exists_and_add(effects.ability.sp_ot, spell_name_to_id["Lifebloom"], -116, 0.0);
            end,
            [186052] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Moonfire"], 10, 0.0);
            end,
            [22399] = function(effects)
                ensure_exists_and_add(effects.ability.flat_add, spell_name_to_id["Healing Touch"], 100, 0.0);
            end,
            [42580] = function(effects)
                ensure_exists_and_add(effects.ability.sp, spell_name_to_id["Lifebloom"], 376, 0.0);
                ensure_exists_and_add(effects.ability.sp_ot, spell_name_to_id["Lifebloom"], -376, 0.0);
            end,
        };
    else 
        return {};
    end
    
end 

local set_items = create_sets();

local set_bonus_effects = create_set_effects();

local relics = create_relics();

local items = {
    [45703] = function(effects)
        effects.raw.cost_flat = effects.raw.cost_flat + 44;
    end,
};

local function detect_sets(loadout)
    -- go through equipment to find set pieces
    for k, v in pairs(set_tiers) do
        loadout.num_set_pieces[v] = 0;
    end

    for item = 1, 18 do
        local id = GetInventoryItemID("player", item);
        if set_items[id] then
            set_id = set_items[id];
            if not loadout.num_set_pieces[set_id] then
                loadout.num_set_pieces[set_id] = 0;
            end
            loadout.num_set_pieces[set_id] = loadout.num_set_pieces[set_id] + 1;
        end
    end
end

local function apply_equipment(loadout, effects)

    detect_sets(loadout);

    local found_anything = false;
    -- head slot gems
    for _, v in pairs({GetInventoryItemGems(1)}) do
        if v == 41285 or v == 34220 then
            effects.raw.special_crit_mod = effects.raw.special_crit_mod + 0.03;
        elseif v == 41333 then
            effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + 0.02;
        elseif v == 41389 then
            effects.raw.mana_mod = effects.raw.mana_mod + 0.02;
        elseif v == 41376 then
            effects.raw.special_crit_heal_mod = effects.raw.special_crit_heal_mod + 0.03;
            effects.raw.mp5 = effects.raw.mp5 + 11;
        elseif v == 41401 then
            effects.raw.resource_refund = effects.raw.resource_refund + 0.05 * 600;
        end
    end

    local relic_id = GetInventoryItemID("player", 18);
    if relic_id and relics[relic_id] then
        relics[relic_id](effects);
    end

    local trinket1 = GetInventoryItemID("player", 13);
    local trinket2 = GetInventoryItemID("player", 14);
    if trinket1 and items[trinket1] then
        items[trinket1](effects);
    end
    if trinket2 and items[trinket2] then
        items[trinket2](effects);
    end
    
    for k, v in pairs(loadout.num_set_pieces) do
        if v >= 2 then
            if set_bonus_effects[k] then
                set_bonus_effects[k](v, loadout, effects);
            end
        end
    end

    -- NOTE: shortly after logging in, the equipment querying API won't work
    --       (but does for /reload). Track if we get nothing so we can signal
    --       that equipment scanning needs to be done again on next update
    for item = 1, 18 do
        local item_link = GetInventoryItemLink("player", item);
        if item_link then
            found_anything = true;
            local item_stats = GetItemStats(item_link);
            if item_stats then

                if item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] then
                    effects.raw.mp5 = effects.raw.mp5 + item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] + 1;
                end

                --if item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] then
                --    for i = 2,7 do
                --        loadout.target_res_by_school[i] = 
                --            loadout.target_res_by_school[i] - (item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] - 1);
                --    end
                --end
            end
        end
    end

    return found_anything;
end

equipment.set_tiers = set_tiers;
equipment.apply_equipment = apply_equipment;

swc.equipment = equipment;
