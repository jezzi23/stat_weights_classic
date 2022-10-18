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

local sw_addon_name = "Stat Weights Classic";
local version =  "3.0.0";

local sw_addon_loaded = false;

local libstub_data_broker = LibStub("LibDataBroker-1.1", true)
local libstub_icon = libstub_data_broker and LibStub("LibDBIcon-1.0", true)

local font = "GameFontHighlightSmall";
local icon_overlay_font = "Interface\\AddOns\\stat_weights_classic\\fonts\\Oswald-Bold.ttf";

local action_bar_addon_name = nil;
local spell_book_addon_name = nil;

sw_snapshot_loadout_update_freq = 1;
sw_num_icon_overlay_fields_active = 0;
local addon_running_time = 0;
local snapshot_time_since_last_update = 0;
local beacon_snapshot_time = -1000;

local _, class = UnitClass("player");
local _, race = UnitRace("player");
local faction, _ = UnitFactionGroup("player");

local function class_supported()
    -- wotlk ready classes
    return class == "PRIEST" or class == "DRUID" or class == "PALADIN";
    
    --return class == "MAGE" or class == "PRIEST" or class == "WARLOCK" or
    --   class == "SHAMAN" or class == "DRUID" or class == "PALADIN";
end

local stat = {
    str = 1,
    agi = 2,
    stam = 3,
    int = 4,
    spirit = 5
};

local stat_ids_in_ui = {
    int = 1,
    spirit = 2,
    mana = 3,
    mp5 = 4,
    sp = 5,
    spell_crit = 6,
    spell_hit = 7,
    spell_haste = 8,
    target_spell_res_decrease = 9
};

local icon_stat_display = {
    normal              = bit.lshift(1,1),
    crit                = bit.lshift(1,2),
    expected            = bit.lshift(1,3),
    effect_per_sec      = bit.lshift(1,4),
    effect_per_cost     = bit.lshift(1,5),
    avg_cost            = bit.lshift(1,6),
    avg_cast            = bit.lshift(1,7),
    hit                 = bit.lshift(1,8),
    crit_chance         = bit.lshift(1,9),
    casts_until_oom     = bit.lshift(1,10),
    effect_until_oom    = bit.lshift(1,11),
    time_until_oom      = bit.lshift(1,12),

    show_heal_variant = bit.lshift(1,20)
};

local tooltip_stat_display = {
    normal              = bit.lshift(1,1),
    crit                = bit.lshift(1,2),
    ot                  = bit.lshift(1,3),
    ot_crit             = bit.lshift(1,4),
    expected            = bit.lshift(1,5),
    effect_per_sec      = bit.lshift(1,6),
    effect_per_cost     = bit.lshift(1,7),
    cost_per_sec        = bit.lshift(1,8),
    stat_weights        = bit.lshift(1,9),
    coef                = bit.lshift(1,10),
    avg_cost            = bit.lshift(1,11),
    avg_cast            = bit.lshift(1,12),
    cast_until_oom      = bit.lshift(1,13),
    cast_and_tap        = bit.lshift(1,14)
};

local simulation_type = {
    spam_cast           = 1,
    cast_until_oom      = 2
};

local set_tiers = {
    pve_t7_1         = 1,
    pve_t7_2         = 2,
    pve_t7_3         = 3,
};

local class_is_supported = class_supported();

local addonName, addonTable = ...;
local spells = addonTable.spells;
local spell_name_to_id = addonTable.spell_name_to_id;
local magic_school = addonTable.magic_school;
local spell_flags = addonTable.spell_flags;

local function localized_spell_name(english_name)
    local name, _, _, _, _, _, _ = GetSpellInfo(spell_name_to_id[english_name]);
    return name;
end

local function localize_spell_name_array(english_names)
    local names = {};
    for k, v in pairs(english_names) do
        names[k] = localized_spell_name(v);
    end
    return names;
end

local function ensure_exists_and_add(table, key, add, default_if_not_exists)
    if not table[key] then
        table[key] = default_if_not_exists + add;
    else
        table[key] = table[key] + add;
    end
end

local function ensure_exists_and_mul(table, key, mul, default_if_not_exists)
    if not table[key] then
        table[key] = default_if_not_exists * mul;
    else
        table[key] = table[key] * mul;
    end
end

local buff_filters = {
    caster      = bit.lshift(1,1),
    --
    priest      = bit.lshift(1,2),
    mage        = bit.lshift(1,3),
    warlock     = bit.lshift(1,4),
    druid       = bit.lshift(1,5),
    shaman      = bit.lshift(1,6),
    paladin     = bit.lshift(1,7),
    --
    troll       = bit.lshift(1,8),
    belf        = bit.lshift(1,9),

    -- for buffs/debuffs that affect healing taken or dmg taken
    friendly    = bit.lshift(1,11),
    hostile     = bit.lshift(1,12),
};

local filter_flags_active = 0;
filter_flags_active = bit.bor(filter_flags_active, buff_filters.caster);
if class == "PRIEST" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.priest);
elseif class == "DRUID" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.druid);
elseif class == "SHAMAN" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.shaman);
elseif class == "MAGE" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.mage);
elseif class == "WARLOCK" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.warlock);
elseif class == "PALADIN" then
    filter_flags_active = bit.bor(filter_flags_active, buff_filters.paladin);
end

--TODO: 
--    warlock healing taken
--    pala blessing of healing thing
--    boomkin aura
--    tree of life
local buffs = {
    -- power infusion
    [10060] = {
        apply = function(loadout, buff)
            loadout.haste_mod = loadout.haste_mod * 1.2;
            loadout.cost_mod = loadout.cost_mod * 0.2;
        end,
        filter = buff_filters.caster,
    },
    -- shadow weaving
    [15258] = {
        apply = function(loadout, buff)
            local c = 0;
            if buff.count then
                c = buff.count
            else
                c = 5;
            end

            loadout.spell_dmg_mod_by_school[magic_school.shadow] = 
                (1.0 + loadout.spell_dmg_mod_by_school[magic_school.shadow]) * (1.0 + c * 0.02) - 1.0;
        end,
        filter = buff_filters.priest,
    },
    --shadow form
    [15473] = {
        apply = function(loadout, buff)
            loadout.spell_dmg_mod_by_school[magic_school.shadow] = 
                (1.0 + loadout.spell_dmg_mod_by_school[magic_school.shadow]) * 1.15 - 1.0;
        end,
        filter = buff_filters.priest,
    },
    --misery
    [33198] = {
        apply = function(loadout, buff)
            local hit = 0.03;
            if buff.id then
                if buff.id == 33196 then
                    hit = 0.01;
                elseif buff.id == 33197 then
                    hit = 0.02;
                end
            end
            
            loadout.spell_dmg_hit_by_school[magic_school.shadow] = 
                loadout.spell_dmg_hit_by_school[magic_school.shadow] + hit;
        end,
        filter = buff_filters.priest,
    },
    --serendipity
    [63734] = {
        apply = function(loadout, buff)
            local effect = 0.12;
            local c = 0;
            if buff.count then
                c = buff.count;
                if buff.id == 63731 then
                    effect = 0.04;
                elseif buff.id == 63735 then 
                    effect = 0.08;
                end
            else
                c = 3;
            end
            local abilities = localize_spell_name_array({"Greater Heal", "Prayer of Heal"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(loadout.ability_cast_mod, v, c * effect, 0);
            end
        
        end,
        filter = buff_filters.priest,
    },
    --moonkin aura
    [24907] = {
        apply = function(loadout, buff)
            local haste = 0.03;
            if buff.src == "player" then
                haste = 0.01 * loadout.talents_table:pts(1, 19); -- improved boomkin
            end
            loadout.haste_mod = loadout.haste_mod * (1.0 + haste);

            -- TODO: static loadout for crit?
            --for i = 2, 7 do
            --    loadout.spell_crit_by_school[i] = loadout.spell_crit_by_school[i] + 0.05;
            --end
        end,
        filter = buff_filters.caster,
    },
    --moonkin form
    [24858] = {
        apply = function(loadout, buff)
            -- mana refund done in later stage
            -- master shapeshifter
            local pts = loadout.talents_table:pts(3, 9);
            loadout.target_spell_dmg_taken[magic_school.arcane] =
                loadout.target_spell_dmg_taken[magic_school.arcane] + pts * 0.02;
            loadout.target_spell_dmg_taken[magic_school.nature] =
                loadout.target_spell_dmg_taken[magic_school.nature] + pts * 0.02;
        end,
        filter = buff_filters.druid,
    },
    --tree of life form
    [33891] = {
        apply = function(loadout, buff)
            -- mana refund done in later stage
            -- master shapeshifter
            local pts = loadout.talents_table:pts(3, 9);
            loadout.spell_heal_mod = loadout.spell_heal_mod + pts * 0.02;
        end,
        filter = buff_filters.druid,
    },
};
    --arcane_power                = { flag = bit.lshift(1,11), id = 12042, name = "Arcane Power"},-- ok
    --int                         = { flag = bit.lshift(1,12), id = 10157, name = "Arcane Intellect"}, --ok
    --int_aoe                     = { flag = bit.lshift(1,12), id = 23028, name = "Arcane Brilliance"}, --ok
    --motw                        = { flag = bit.lshift(1,13), id = 24752, name = "Mark of the Wild"}, --ok
    --motw_aoe                    = { flag = bit.lshift(1,13), id = 21850, name = "Gift of the Wild"}, --ok
    --spirit                      = { flag = bit.lshift(1,14), id = 27841, name = "Divine Spirit"}, --ok
    --spirit_aoe                  = { flag = bit.lshift(1,14), id = 27681, name = "Prayer Spirit"}, --ok
    --mind_quickening_gem         = { flag = bit.lshift(1,15), id = 23723, name = "Mind Quickening Gem"},-- ok
    --hazzrahs_charm_of_magic     = { flag = bit.lshift(1,20), id = 24544, name = "Hazza'rah'Charm"},-- ok
    --hazzrahs_charm_of_destr     = { flag = bit.lshift(1,21), id = 24544, name = "Hazza'rah'Charm"},-- ok
    --amplify_curse               = { flag = bit.lshift(1,22), id = 18288, name = "Amplify Curse"},-- ok
    --demonic_sacrifice           = { flag = bit.lshift(1,23), id = 18791, name = "Demonic Sacrifice (Succ)"},-- ok
    --hazzrahs_charm_of_healing   = { flag = bit.lshift(1,24), id = 24546, name = "Hazza'rah'Charm Healing"},-- ok
    --wushoolays_charm_of_spirits = { flag = bit.lshift(1,26), id = 24499, name = "Wushoolay's Charm"},-- ok
    --wushoolays_charm_of_nature  = { flag = bit.lshift(1,27), id = 24542, name = "Wushoolay's Charm"},-- ok
    ---- TODO: spell ids for rogue/warr ambigious on wowhead, the following 2 are wrong
    --berserking_rogue            = { flag = bit.lshift(1,28), id = 26297, name = "Berserking (Troll)"},
    --berserking_warrior          = { flag = bit.lshift(1,29), id = 26296, name = "Berserking (Troll)"},
    --berserking                  = { flag = bit.lshift(1,30), id = 26635, name = "Berserking (Troll)"}, -- ok casters
    --toep                        = { flag = bit.lshift(1,31), id = 23271, name = "TOEP trinket"} -- ok casters
    --grileks_charm_of_valor      = { flag = bit.lshift(1,32), id = 24498, name = "Gri'lek's Charm of Valor"} -- ok casters

--local buffs2 = {
    --zandalarian_hero_charm      = { flag = bit.lshift(1,1),  id = 24658, name = "Zandalarian Hero Charm", icon_id = GetItemIcon(19950)}, --ok casters
    --bok                         = { flag = bit.lshift(1,2),  id = 20217, name = "Blessing of Kings"}, --ok
    --vengeance                   = { flag = bit.lshift(1,3),  id = 20059, name = "Vengeance"}, --ok
    --natural_alignment_crystal   = { flag = bit.lshift(1,4),  id = 23734, name = "Natural Alignment Crystal"}, --ok
    --blessed_prayer_beads        = { flag = bit.lshift(1,5),  id = 24354, name = "Blessed Prayer Beads"}, --ok
    --troll_vs_beast              = { flag = bit.lshift(1,6),  id = 20557, name = "Beast Slaying (Trolls)"}, --ok
    --flask_of_supreme_power      = { flag = bit.lshift(1,7),  id = 17628, name = "Flask of Supreme Power"}, --ok
    --nightfin                    = { flag = bit.lshift(1,8),  id = 18194, name = "Nightfin Soup"}, --ok
    --mage_armor                  = { flag = bit.lshift(1,9),  id = 22783, name = "Mage Armor"}, --ok
    --flask_of_distilled_wisdom   = { flag = bit.lshift(1,10), id = 17627, name = "Flask of Distilled Wisdom"}, --ok
    --bow                         = { flag = bit.lshift(1,11), id = 25290, name = "Blessing of Wisdom"}, --ok
    --boomkin                     = { flag = bit.lshift(1,12), id = 24907, name = "Moonkin Aura"}, -- ok
    --manaspring_totem            = { flag = bit.lshift(1,13), id = 10497, name = "Mana Spring Totem"}, --ok
    --mageblood                   = { flag = bit.lshift(1,14), id = 24363, name = "Mageblood Potion"}, --ok
    --spirit_of_zanza             = { flag = bit.lshift(1,15), id = 24382, name = "Spirit of Zanza"}, --ok
    --kreegs_stout_beatdown       = { flag = bit.lshift(1,16), id = 22790, name = "Kreeg's Stout Beatdown"},--ok
    --brilliant_wizard_oil        = { flag = bit.lshift(1,17), id = 25122, name = "Brilliant Wizard Oil", icon_id = GetItemIcon(20749)}, --ok
    --brilliant_mana_oil          = { flag = bit.lshift(1,18), id = 25123, name = "Brilliant Mana Oil", icon_id = GetItemIcon(20748)}, --ok
    --demonic_sacrifice_imp       = { flag = bit.lshift(1,19), id = 18789, name = "Demonic Sacrifice (Imp)"},-- ok
    --lightning_shield            = { flag = bit.lshift(1,20), id = 10432, name = "MP5 (only if T3 active)"},-- 
    --epiphany                    = { flag = bit.lshift(1,21), id = 28804, name = "T3 8set bonus buff"}--
--};

local target_buffs = {
    -- grace
    [47930] = {
        apply = function(loadout, buff)
            --TODO: this is probably multiplied last after % healing
            local c = 3;
            if buff.count then
                c = buff.count
            end
            loadout.target_healing_taken = loadout.target_healing_taken + c * 0.03; 
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.friendly),
    },
    -- focused will
    [45242] = {
        apply = function(loadout, buff)
            --TODO: this is probably multiplied last after % healing
            local heal_effect = 0.05;
            local c = 3;
            if buff.count then
                c = buff.count
                if buff.id == 45237 then
                    heal_effect = 0.03;
                elseif buff.id == 45241 then 
                    heal_effect = 0.04;
                end
            end
            loadout.spell_heal_mod = loadout.spell_heal_mod + c * heal_effect; 
            
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.friendly),
    },
    -- weakened soul (renewed hope talent effect)
    [6788] = {
        apply = function(loadout, buff)
            local pts = loadout.talents_table:pts(1, 21);
            if pts ~= 0 and loadout.target_friendly then
                    
                    local abilities = localize_spell_name_array({"Flash Heal", "Greater heal", "Penance"});
                    for k, v in pairs(abilities) do
                        ensure_exists_and_add(loadout.ability_crit, v, pts * 0.02, 0);
                    end
                end
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.friendly),
        name = "Renewed Hope",
        icon_id = GetSpellTexture(63944),
    },
    --shadow word: pain (twisted faith)
    [589] = {
        apply = function(loadout, buff)

            -- TODO: should probably be last mulitply
            local pts = loadout.talents_table:pts(3, 26);
            if pts ~= 0 then
                local abilities = localize_spell_name_array({"Mind Flay", "Mind Blast"});
                for k, v in pair(abilities) do
                    ensure_exists_and_mul(loadout.ability_effect_mod, v, 1 + pts * 0.02, 1.0);
                end
                 
            end
        end,
        filter = bit.bor(buff_filters.priest, buff_filters.hostile),
        name = "Twisted Faith",
        icon_id = GetSpellTexture(51167),
    },
    --beacon of light
    [53563] = {
        -- just used for toggle and icon in buffs, applied later
        apply = function(loadout, buff)
        end,
        filter = bit.bor(buff_filters.paladin, buff_filters.friendly),
    },
    --tree of life
    [34123] = {
        apply = function(loadout, buff)
            loadout.target_healing_taken = loadout.target_healing_taken + 0.06;
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.friendly),
    },
    --moonfire (improved insect swarm talent)
    [8921] = {
        apply = function(loadout, buff)
            local pts = loadout.talents_table:pts(1, 14);
            ensure_exists_and_add(loadout.ability_crit, localized_spell_name("Starfire"), pts * 0.01, 0);
        end,
        filter = bit.bor(buff_filters.druid, buff_filters.hostile),
        name = "Improved Insect Swarm",
    },
    --insect swarm (improved insect swarm talent)
    [5570] = {
        apply = function(loadout, buff)
            -- done in later stage
        end,
        name = "Improved Insect Swarm",
        filter = bit.bor(buff_filters.druid, buff_filters.hostile),
    },
    --earth and moon
    [60431] = {
        apply = function(loadout, buff)
            local dmg_taken = 0.04;
            if buff.id == 60433 then
                dmg_taken = 0.13;
            elseif buff.id == 60432 then
                dmg_taken = 0.09;
            end

            for i = 2, 7 do
                loadout.target_spell_dmg_taken[i] = loadout.target_spell_dmg_taken[i] + dmg_taken;
            end
        end,
        filter = bit.bor(buff_filters.caster, buff_filters.hostile),
    },
};
    --amplify_magic               = { flag = bit.lshift(1,1), id = 10170, name = "Amplify Magic"}, --ok
    --dampen_magic                = { flag = bit.lshift(1,2), id = 10174, name = "Dampen Magic"}, --ok
    --blessing_of_light           = { flag = bit.lshift(1,3), id = 19979, name = "Blessing of Light"}, --ok
    --healing_way                 = { flag = bit.lshift(1,4), id = 29203, name = "Healing Way"} --ok
    
    --curse_of_the_elements       = { flag = bit.lshift(1,1), id = 11722, name = "Curse of the Elements"}, -- ok casters
    --wc                          = { flag = bit.lshift(1,2), id = 12579, name = "Winter's Chill"}, -- ok casters
    --improved_scorch             = { flag = bit.lshift(1,4), id = 22959, name = "Improved Scorch"}, -- ok casters
    --improved_shadow_bolt        = { flag = bit.lshift(1,5), id = 17800, name = "Improved Shadow Bolt"}, -- ok casters
    --shadow_weaving              = { flag = bit.lshift(1,6), id = 15258, name = "Shadow Weaving"}, -- ok casters
    --stormstrike                 = { flag = bit.lshift(1,7), id = 17364, name = "Stormstrike"}, -- ok casters
    --curse_of_shadow             = { flag = bit.lshift(1,8), id = 17937, name = "Curse of Shadow"} -- ok casters

local function get_spell(spell_id)

    return spells[spell_id];
end

local function create_glyphs()
    if class == "PRIEST" then
        return {
            -- glyph of circle of healing
            [55675] = {
                apply = function(loadout)
                    --TODO
                end,
                wowhead_id = "pbv"
            },
            -- glyph of shadow
            [55689] = {
                apply = function(loadout)
                    --TODO: trackable buff?
                end,
                wowhead_id = "pc9"
            },
            -- glyph of shadow word pain
            [55681] = {
                apply = function(loadout)
                    --TODO
                end,
                wowhead_id = "pc1"
            },
            -- glyph of mind flay
            [55687] = {
                apply = function(loadout)
                    -- TODO
                end,
                wowhead_id = "pc7"
            },
            -- glyph of power word shield
            [55672] = {
                wowhead_id = "pbr"
            },
            -- glyph of flash heal
            [55679] = {
                apply = function(loadout)
                    local fl = localized_spell_name("Flash Heal");
                    ensure_exists_and_add(loadout.ability_cost_mod, fl, 0.1, 0);
                end,
                wowhead_id = "pbz"
            },
            -- glyph of holy nova
            [55683] = {
                apply = function(loadout)
                    local hn = localized_spell_name("Holy Nova");
                    ensure_exists_and_mul(loadout.ability_effect_mod, hn, 1.20, 1.0);
                end,
                wowhead_id = "pc3"
            },
            -- glyph of prayer of healing
            [57195] = {
                apply = function(loadout)
                    local ph = localized_spell_name("Prayer of Healing");
                    --TODO
                end,
                wowhead_id = "pc0"
            },
            -- glyph of smite
            [55692] = {
                apply = function(loadout)
                    -- add to gmod?
                    --TODO
                end,
                wowhead_id = "pcc"
            },
            -- glyph of shadow word death
            [55682] = {
                apply = function(loadout)
                    --TODO
                end,
                wowhead_id = "pc2"
            },
            -- glyph of renew
            [55674] = {
                apply = function(loadout)
                    local renew = localized_spell_name("Renew");

                    ensure_exists_and_add(loadout.ability_extra_ticks, renew, -1, 0);
                    -- heal increase applied later calculation
                end,
                wowhead_id = "pbt"
            },
            -- glyph of lightwell
            [55673] = {
                apply = function(loadout)
                    local lw = localized_spell_name("Lightwell");
                    ensure_exists_and_mul(loadout.ability_effect_mod, lw, 1.20, 1.0);
                end,
                wowhead_id = "pbs"
            }
        };
    elseif class == "DRUID" then
        return {};
    elseif class == "PALADIN" then
        return {};
    else
        return {};
    end
end

local glyphs = create_glyphs();
local wowhead_glyph_code_to_id = {};
-- reverse mapping from wowhead 3 char code to glyph spell id
for k, v in pairs(glyphs) do
    wowhead_glyph_code_to_id[v.wowhead_id] = k; 
end

local function wowhead_talent_link(code)
    local lowercase_class = string.lower(class);
    return "https://classic.wowhead.com/wotlk/talent-calc/"..lowercase_class.."/"..code;
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

    local talent_code = {};

    local sub_codes = {"", "", ""};
    for i = 1, 3 do

        local talent_table = {};
        for row = 1, 11 do
            talent_table[row] = {}
        end
        for j = 1, GetNumTalents(i) do
            -- talent indices are not in left-right, top-to-bottom order
            -- but rather seemingly random...


            local _, _, row, column, pts, _, _, _ = GetTalentInfo(i, j);
            talent_table[row][column] = pts;
        end

        local found_max = false;
        for r = 1, 11 do
            row = 11 - r + 1
            for c = 1, 4 do
                column = 4 - c + 1;

                local pts = talent_table[row][column];
                if pts then
                    if pts ~= 0 then
                        found_max = true;
                    end
                    if found_max then
                        
                        sub_codes[i] = tostring(pts)..sub_codes[i];
                    end
                end
            end
        end
    end
    if sub_codes[2] == "" and sub_codes[3] == "" then
        talent_code =  sub_codes[1];
    elseif sub_codes[2] == "" then
        talent_code =  sub_codes[1].."--"..sub_codes[3];
    elseif sub_codes[3] == "" then
        talent_code =  sub_codes[1].."-"..sub_codes[2];
    else
        talent_code = sub_codes[1].."-"..sub_codes[2].."-"..sub_codes[3];
    end

    local glyphs_code = "";

    local primary_glyph_prefixes = {"001", "11", "21"};
    local j = 1;
    for i = 1, GetNumGlyphSockets() do
        local _, quality, id, _ = GetGlyphSocketInfo(i);
        if id and glyphs[id] then
            glyphs_code = glyphs_code..primary_glyph_prefixes[j]..glyphs[id].wowhead_id;
            j = j + 1;
        end
    end

    return talent_code.."_"..glyphs_code;
end

local function talent_glyphs_table(wowhead_code)

    local talents = {{}, {}, {}};

    local i = 1;
    local tree_index = 1;
    local talent_index = 1;

    while wowhead_code:sub(i, i) ~= ""  and wowhead_code:sub(i, i) ~= "_" do
        if wowhead_code:sub(i, i) == "-" then
            tree_index = tree_index + 1;
            talent_index = 1;
        elseif tonumber(wowhead_code:sub(i, i)) then
            talents[tree_index][talent_index] = tonumber(wowhead_code:sub(i, i));
            talent_index = talent_index + 1;
        end
        i = i + 1;
    end

    talents.pts = function(this, tree_index, talent_index)
        if this[tree_index][talent_index] then
            return this[tree_index][talent_index];
        else
            return 0;
        end
    end;

    local glyphs_table = {};
    while wowhead_code:sub(i, i) ~= "" do

        if string.match(wowhead_code:sub(i, i), "[a-z]") ~= nil then
            local glyph_code = wowhead_code:sub(i, i + 2);
            local glyph_id = wowhead_glyph_code_to_id[glyph_code];
            if glyph_id then
                glyphs_table[glyph_id] = glyphs[glyph_id];
            end
            i = i + 3;
        else
            i = i + 1;
        end
    end

    return talents, glyphs_table;
end

local function get_combat_rating_effect(rating_id, level)
    -- src: https://wowwiki-archive.fandom.com/wiki/Combat_rating_system#Combat_Ratings_formula
    -- base off level 60
    local rating_id_to_base = {
        [CR_HASTE_SPELL] = 10,
        [CR_CRIT_SPELL] = 14,
        [CR_HIT_SPELL] = 8
    };
    local rating_per_percentage = 0.0;
    if level >= 70 then
        rating_per_percentage = rating_id_to_base[rating_id] * (41/26) * math.pow(131/63, (level-70)/10);
    elseif level >= 60 then
        rating_per_percentage = rating_id_to_base[rating_id] * (82/(262 - 3*level));
    elseif level >= 10 then
        rating_per_percentage = rating_id_to_base[rating_id] * (level - 8)/52;
    elseif level >= 1 then
        rating_per_percentage = rating_id_to_base[rating_id] / 26;
    end

    return rating_per_percentage;
end

local function empty_loadout()

    return {
        name = "Empty";
        is_dynamic_loadout = true,
        talents_code = "",
        talents_table = {},
        always_assume_buffs = true,
        lvl = 0,
        target_lvl = 0,
        use_dynamic_target_lvl = true,
        has_target = false; 

        stats = {0, 0, 0, 0, 0},
        mana = 0,
        max_mana = 0,
        extra_mana = 0,
        mp5 = 0,
        regen_while_casting = 0,
        mana_mod = 0,

        spell_dmg_by_school = {0, 0, 0, 0, 0, 0, 0},
        spell_power = 0,

        spell_crit_by_school = {0, 0, 0, 0, 0, 0, 0},

        spell_dmg_hit_by_school = {0, 0, 0, 0, 0, 0, 0},
        spell_dmg_mod_by_school = {0, 0, 0, 0, 0, 0, 0},
        spell_crit_mod_by_school = {0, 0, 0, 0, 0, 0, 0},
        target_spell_dmg_taken = {0, 0, 0, 0, 0, 0, 0},

        spell_heal_mod = 0,
        target_healing_taken = 0,
        gmod = 1.0,

        dmg_mod = 0,
        ot_mod = 0,
        target_res_by_school = {0, 0, 0, 0, 0, 0, 0},
        target_mod_res_by_school = {0, 0, 0, 0, 0, 0, 0},

        haste_rating = 0.0,
        crit_rating = 0.0,
        hit_rating = 0.0,

        haste_mod = 1.0,
        cost_mod = 0,

        stat_mod = {0, 0, 0, 0, 0},

        ignite = 0,
        spiritual_guidance = 0,
        lunar_guidance = 0,
        master_of_elements  = 0,
        improved_immolate = 0,
        improved_shadowbolt = 0,

        num_set_pieces = {},
        
        -- indexable by ability name
        ability_crit = {},
        ability_effect_mod = {},
        ability_cast_mod = {},
        ability_extra_ticks = {},
        ability_cost_mod = {},
        ability_crit_mod = {},
        ability_hit = {},
        ability_sp = {},
        ability_flat_add = {},
        ability_refund = {},
        ability_coef_mod = {},
        ability_coef_ot_mod = {},

        target_friendly = false,
        target_type = "",

        dynamic_buffs = {},
        buffs = {},
        target_buffs = {},
    };
end

--TODO: should clean this up before wotlk
--
-- add things to loadout that a loadout is assumed to have but don't due to an older version of a loadout
local function satisfy_loadout(loadout)

    --if not loadout.mp5 then
    --    loadout.mp5 = 0;
    --end
    --if not loadout.regen_while_casting then
    --    loadout.regen_while_casting = 0;
    --end
    --if not loadout.mana then
    --    loadout.mana = 0;
    --end
    --if not loadout.extra_mana then
    --    loadout.extra_mana = 0;
    --end
    --if not loadout.mana_mod then
    --    loadout.mana_mod = 0;
    --end
    --if not loadout.ability_flat_add then
    --    loadout.ability_flat_add = {};
    --end
    --if not loadout.ability_refund then
    --    loadout.ability_refund = {};
    --end
    --if not loadout.talents_code then
    --    loadout.talents_code = wowhead_talent_code();
    --end
    --if not loadout.glyphs then
    --    loadout.glyphs = {};
    --end
    --if not loadout.target_mod_res_by_school then
    --    loadout.target_mod_res_by_school = {0, 0, 0, 0, 0, 0, 0};
    --end
    --if not loadout.target_res_by_school then
    --    loadout.target_res_by_school = {0, 0, 0, 0, 0, 0, 0};
    --end

end

local function negate_loadout(loadout)

    local negated = loadout;

    for i = 1, 5 do
        negated.stats[i] = -loadout.negated.stats[i];
    end
    negated.mp5 = -loadout.negated.mp5;
    negated.mana = -loadout.negated.mana;

    for i = 1, 7 do
        negated.spell_dmg_by_school[i] = -loadout.spell_dmg_by_school[i];
    end
    negated.spell_power = -loadout.spell_power;

    for i = 1, 7 do
        negated.spell_crit_by_school[i] = -loadout.spell_crit_by_school[i];
    end

    for i = 1, 7 do
        negated.spell_dmg_hit_by_school[i] = -loadout.spell_dmg_hit_by_school[i];
    end

    for i = 1, 7 do
        negated.spell_dmg_mod_by_school[i] = -loadout.spell_dmg_mod_by_school[i];
    end

    for i = 1, 7 do
        negated.spell_crit_mod_by_school[i] = -loadout.spell_crit_mod_by_school[i];
    end

    for i = 1, 7 do
        negated.target_spell_dmg_taken[i] = -loadout.target_spell_dmg_taken[i];
    end

    for i = 1, 7 do
        negated.target_mod_res_by_school[i] = -loadout.target_mod_res_by_school[i];
    end
    for i = 1, 7 do
        negated.target_res_by_school[i] = -loadout.target_res_by_school[i];
    end

    negated.spell_heal_mod = -negated.spell_heal_mod;
    negated.target_healing_taken = -negated.target_healing_taken;

    negated.dmg_mod = -negated.dmg_mod;

    negated.haste_rating = -negated.haste_rating;
    negated.crit_rating = -negated.crit_rating;
    negated.hit_rating = -negated.hit_rating;

    negated.cost_mod = -negated.cost_mod;

    return negated;
end

local function deep_table_copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[deep_table_copy(k, s)] = deep_table_copy(v, s) end
  return res
end

-- deep copy to avoid reference entanglement
local function loadout_copy(loadout)
    return deep_table_copy(loadout);
end

local function loadout_add(primary, diff)

    local added = loadout_copy(primary);

    for i = 1, 5 do
        added.stats[i] = primary.stats[i] + diff.stats[i] * (1 + primary.stat_mod[i]);
    end
    -- TODO: outdated stuff here, mana and int crit formula need figuring out

    added.mp5 = primary.mp5 + diff.mp5;
    added.mana = primary.mana + 
                 (diff.mana * (1 + primary.mana_mod)) + 
                 (15*diff.stats[stat.int]*(1 + primary.stat_mod[stat.int]*primary.mana_mod));

    local sp_gained_from_spirit = diff.stats[stat.spirit] * (1 + primary.stat_mod[stat.spirit]) * primary.spiritual_guidance * 0.01;
    local sp_gained_from_int = diff.stats[stat.int] * (1 + primary.stat_mod[stat.int]) * primary.lunar_guidance * 0.01;
    sp_gained_from_stat = sp_gained_from_spirit + sp_gained_from_int;
    for i = 1, 7 do
        added.spell_dmg_by_school[i] = primary.spell_dmg_by_school[i] + diff.spell_dmg_by_school[i] + sp_gained_from_stat;
    end
    added.spell_power = primary.spell_power + diff.spell_power + sp_gained_from_stat;

    -- introduce crit by intellect here
    crit_diff_normalized_to_primary = diff.stats[stat.int] * ((1 + primary.stat_mod[stat.int])/60)/100; -- assume diff has no stat mod
    for i = 1, 7 do
        added.spell_crit_by_school[i] = primary.spell_crit_by_school[i] + diff.spell_crit_by_school[i] + 
            crit_diff_normalized_to_primary;
    end

    for i = 1, 7 do
        added.spell_dmg_hit_by_school[i] = primary.spell_dmg_hit_by_school[i] + diff.spell_dmg_hit_by_school[i];
    end

    for i = 1, 7 do
        added.spell_dmg_mod_by_school[i] = primary.spell_dmg_mod_by_school[i] + diff.spell_dmg_mod_by_school[i];
    end

    for i = 1, 7 do
        added.spell_crit_mod_by_school[i] = primary.spell_crit_mod_by_school[i] + diff.spell_crit_mod_by_school[i];
    end
    for i = 1, 7 do
        added.target_spell_dmg_taken[i] = primary.target_spell_dmg_taken[i] + diff.target_spell_dmg_taken[i];
    end
    for i = 1, 7 do
        added.target_mod_res_by_school[i] = primary.target_mod_res_by_school[i] + diff.target_mod_res_by_school[i];
    end
    for i = 1, 7 do
        added.target_res_by_school[i] = primary.target_res_by_school[i] + diff.target_res_by_school[i];
    end

    added.spell_heal_mod = primary.spell_heal_mod + diff.spell_heal_mod;

    added.target_healing_taken = primary.target_healing_taken + diff.target_healing_taken;

    added.dmg_mod = primary.dmg_mod + diff.dmg_mod;

    added.haste_rating = primary.haste_rating + diff.haste_rating;
    added.crit_rating = primary.crit_rating + diff.crit_rating;
    added.hit_rating = primary.hit_rating + diff.hit_rating;

    added.cost_mod = primary.cost_mod + diff.cost_mod;

    return added;
end

local active_loadout_base = nil;

local function remove_dynamic_stats_from_talents(loadout)

    local talents, _ = talent_glyphs_table(loadout.talents_code);

    if class == "PALADIN" then

        -- TODO: 
        local pts = talents:pts(1, 16);
        if pts ~= 0 then
            loadout.spell_crit_by_school[magic_school.holy] = 
                loadout.spell_crit_by_school[magic_school.holy] - pts * 0.01;
        end

    elseif class == "PRIEST" then
        -- holy specialization
        local pts = talents:pts(2, 3);
        if pts ~= 0 then
            loadout.spell_crit_by_school[magic_school.holy] = 
                loadout.spell_crit_by_school[magic_school.holy] - pts * 0.01;
        end
    end

    return loadout;
end

local function static_rescale_from_talents_diff(new_loadout, old_loadout)

    local old_int = old_loadout.stats[stat.int];
    local old_max_mana = old_loadout.mana;

    local int_mod = (1 + new_loadout.stat_mod[stat.int])/(1 + old_loadout.stat_mod[stat.int]);
    local mana_mod = (1 + new_loadout.mana_mod)/(1 + old_loadout.mana_mod);
    local new_int = int_mod * old_int
    local mana_gained_from_int =  (new_int - old_int)*15
    local crit_from_int_diff = (new_int - old_int)/6000;
    local new_max_mana = mana_mod * (old_max_mana + mana_gained_from_int);

    local loadout = active_loadout_base();
    loadout.mana = new_max_mana;
    loadout.max_mana = new_max_mana;
    loadout.stats[stat.int] = new_int;
    for i = 2, 7 do
        loadout.spell_crit_by_school[i] = loadout.spell_crit_by_school[i] + crit_from_int_diff;
    end
end


local function apply_talents_glyphs(loadout)

    local new_loadout = loadout;

    local talents, glyphs_table = talent_glyphs_table(loadout.talents_code);
    new_loadout.talents_table = talents;
    new_loadout.glyphs = glyphs_table;

    for k, v in pairs(new_loadout.glyphs) do
        if v.apply then
            v.apply(new_loadout);
        end
    end
    
    if class == "MAGE" then

        -- arcane subtlety
        local pts = talents:pts(1, 1);
        if pts ~= 0 then
            for i = 2, 7 do
                new_loadout.target_res_by_school[i] = new_loadout.target_res_by_school[i] - pts * 5;
            end
        end
        -- arcane focus
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            new_loadout.spell_dmg_hit_by_school[magic_school.arcane] = 
                new_loadout.spell_dmg_hit_by_school[magic_school.arcane] + pts * 0.02;
        end
        --  improved arcane explosion
        local pts = talents:pts(1, 8);
        if pts ~= 0 then
            local ae = localized_spell_name("Arcane Explosion");
            if not new_loadout.ability_crit[ae] then
                new_loadout.ability_crit[ae] = 0;
            end
            new_loadout.ability_crit[ae] = new_loadout.ability_crit[ae] + pts * 0.02;
        end
        --  arcane mediation
        local pts = talents:pts(1, 12);
        if pts ~= 0 then
            new_loadout.regen_while_casting = new_loadout.regen_while_casting + pts * 0.05;
        end
        --  arcane mind
        local pts = talents:pts(1, 14);
        if pts ~= 0 then
            new_loadout.mana_mod = new_loadout.mana_mod + pts * 0.02;
        end
        -- arcane instability
        local pts = talents:pts(1, 15);
        if pts ~= 0 then
            for i = 1, 7 do
                new_loadout.spell_dmg_mod_by_school[i] = new_loadout.spell_dmg_mod_by_school[i] + pts * 0.01;
                new_loadout.spell_crit_by_school[i] = new_loadout.spell_crit_by_school[i] + pts * 0.01;
            end
        end
        -- improved fireball
        local pts = talents:pts(2, 1);
        if pts ~= 0 then
            local fb = localized_spell_name("Fireball");
            if not new_loadout.ability_cast_mod[fb] then
                new_loadout.ability_cast_mod[fb] = 0;
            end
            new_loadout.ability_cast_mod[fb] = new_loadout.ability_cast_mod[fb] + pts * 0.1;
        end
        -- ignite
        local pts = talents:pts(2, 3);
        if pts ~= 0 then
           new_loadout.ignite = pts; 
        end
        -- incinerate
        local pts = talents:pts(2, 6);
        if pts ~= 0 then
            local scorch = localized_spell_name("Scorch");
            local fb = localized_spell_name("Fire Blast");
            if not new_loadout.ability_crit[scorch] then
                new_loadout.ability_crit[scorch] = 0;
            end
            if not new_loadout.ability_crit[fb] then
                new_loadout.ability_crit[fb] = 0;
            end
            new_loadout.ability_crit[scorch] = new_loadout.ability_crit[scorch] + pts * 0.02;
            new_loadout.ability_crit[fb] = new_loadout.ability_crit[fb] + pts * 0.02;
        end
        -- improved flamestrike
        local pts = talents:pts(2, 7);
        if pts ~= 0 then
            local fs = localized_spell_name("Flamestrike");
            if not new_loadout.ability_crit[fs] then
                new_loadout.ability_crit[fs] = 0;
            end
            new_loadout.ability_crit[fs] = new_loadout.ability_crit[fs] + pts * 0.05;
        end
        -- master of elements
        local pts = talents:pts(2, 12);
        if pts ~= 0 then
            new_loadout.master_of_elements = pts;
        end
        -- critical mass
        local pts = talents:pts(2, 13);
        if pts ~= 0 then
            new_loadout.spell_crit_by_school[magic_school.fire] =
                new_loadout.spell_crit_by_school[magic_school.fire] + pts * 0.02;
        end
        -- fire power
        local pts = talents:pts(2, 15);
        if pts ~= 0 then
            new_loadout.spell_dmg_mod_by_school[magic_school.fire] =
                new_loadout.spell_dmg_mod_by_school[magic_school.fire] + pts * 0.02;
        end
        -- improved frostbolt
        local pts = talents:pts(3, 2);
        if pts ~= 0 then
            local fb = localized_spell_name("Frostbolt");
            if not new_loadout.ability_cast_mod[fb] then
                new_loadout.ability_cast_mod[fb] = 0;
            end
            new_loadout.ability_cast_mod[fb] = new_loadout.ability_cast_mod[fb] + pts * 0.1;
        end
        -- elemental precision
        local pts = talents:pts(3, 3);
        if pts ~= 0 then
            new_loadout.spell_dmg_hit_by_school[magic_school.fire] = 
                new_loadout.spell_dmg_hit_by_school[magic_school.fire] + pts * 0.02;
            new_loadout.spell_dmg_hit_by_school[magic_school.frost] = 
                new_loadout.spell_dmg_hit_by_school[magic_school.frost] + pts * 0.02;
        end
        -- ice shards
        local pts = talents:pts(3, 4);
        if pts ~= 0 then
            new_loadout.spell_crit_mod_by_school[magic_school.frost] = 
                1 + (new_loadout.spell_crit_mod_by_school[magic_school.frost] - 1) * (1 + pts * 0.2);
        end
        -- piercing ice
        local pts = talents:pts(3, 8);
        if pts ~= 0 then
            new_loadout.spell_dmg_mod_by_school[5] = new_loadout.spell_dmg_mod_by_school[5] + pts * 0.02;
        end
        -- frost channeling
        local pts = talents:pts(3, 12);
        if pts ~= 0 then

            local cold_spells = {"Frostbolt", "Blizzard", "Cone of Cold", "Frost Nova"};
            for k, v in pairs(cold_spells) do
                cold_spells[k] = localized_spell_name(v);
            end

            for k, v in pairs(cold_spells) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(cold_spells) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.05;
            end
        end
        -- improved cone of cold
        local pts = talents:pts(3, 15);
        if pts ~= 0 then
            local coc = localized_spell_name("Cone of Cold");
        end
    elseif class == "DRUID" then

        -- starlight wrath
        local pts = talents:pts(1, 1);
        if pts ~= 0 then

            local abilities = localize_spell_name_array({"Wrath", "Starfire"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_cast_mod, v, pts * 0.1, 0);
            end
        end


        -- genesis
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            new_loadout.ot_mod = new_loadout.ot_mod + 0.01 * pts;
        end

        -- moonglow
        local pts = talents:pts(1, 3);
        if pts ~= 0 then

            local abilities = localize_spell_name_array({"Moonfire", "Starfire", "Wrath", "Healing Touch", "Nourish", "Regrowth", "Rejuvenation"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_cost_mod, v, pts * 0.03, 0);
            end
        end

        -- nature's majesty
        local pts = talents:pts(1, 4);
        if pts ~= 0 then
            local abilities = localize_spell_name_array({"Wrath", "Starfire", "Starfall", "Nourish", "Healing Touch"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_crit, v, pts * 0.02, 0);
            end
        end

        -- improved moonfire
        local pts = talents:pts(1, 5);
        if pts ~= 0 then
            local mf = localized_spell_name("Moonfire");
            ensure_exists_and_add(new_loadout.ability_crit, mf, pts * 0.05, 0);
            ensure_exists_and_add(new_loadout.ability_effect_mod, mf, pts * 0.05, 1.0);
        end
        -- brambles
        local pts = talents:pts(1, 6);
        if pts ~= 0 then
            local abilities = localize_spell_name_array({"Thorns", "Entangling Roots"});
            for k, v in pairs(abilities) do
                ensure_exists_and_mul(new_loadout.ability_effect_mod, v, 1.0 + pts * 0.25, 1.0);
            end
        end

        -- nature's grace

        -- nature's splendor
        local pts = talents:pts(1, 8);
        if pts ~= 0 then
            local one_ticks = localize_spell_name_array({"Moonfire", "Rejuvenation", "Insect Swarm"});
            local two_ticks = localize_spell_name_array({"Regrowth", "Lifebloom"});
            for k, v in pairs(one_ticks) do
                ensure_exists_and_add(new_loadout.ability_extra_ticks, v, 1, 0);
            end
            for k, v in pairs(two_ticks) do
                ensure_exists_and_add(new_loadout.ability_extra_ticks, v, 2, 0);
            end
        end

        -- vengeance
        local pts = talents:pts(1, 10);
        if pts ~= 0 then

            local abilities = localize_spell_name_array({"Starfire", "Starfall", "Moonfire", "Wrath"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_crit_mod, v, pts * 0.1, 0);
            end
        end

        -- celestial focus
        local pts = talents:pts(1, 11);
        if pts ~= 0 then
            new_loadout.haste_mod = new_loadout.haste_mod * (1.0 + pts * 0.01);
        end

        -- lunar guidance
        local pts = talents:pts(1, 12);
        if pts ~= 0 then
           new_loadout.lunar_guidance = pts * 0.04; 
        end

        -- improved insect swarm
        local pts = talents:pts(1, 14);
        if pts ~= 0 then
            -- TODO: track moonfire and insect swarm
        end

        -- dreamstate
        local pts = talents:pts(1, 15);
        if pts ~= 0 then
            -- TODO: mana regen based on int
        end

        -- moonfury
        local pts = talents:pts(1, 16);
        if pts ~= 0 then
            local abilities = localize_spell_name_array({"Starfire", "Moonfire", "Wrath"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_effect_mod, v, pts * 0.03, 1.0);
            end
        end
        -- balance of power
        local pts = talents:pts(1, 17);
        if pts ~= 0 then

            new_loadout.spell_dmg_hit_by_school[magic_school.nature] = 
                new_loadout.spell_dmg_hit_by_school[magic_school.nature] + pts * 0.02;
            new_loadout.spell_dmg_hit_by_school[magic_school.arcane] = 
                new_loadout.spell_dmg_hit_by_school[magic_school.arcane] + pts * 0.02;
        end

        -- moonkin form
        local pts = talents:pts(1, 18);
        if pts ~= 0 then

            -- TODO: boomkin tracking for self and party
        end
        -- improved moonkin form
        local pts = talents:pts(1, 19);
        if pts ~= 0 then

            -- TODO: boomkin tracking for self and party
        end

        -- improved faerie fire
        local pts = talents:pts(1, 20);
        if pts ~= 0 then

            -- TODO: faerie fire tracking
        end

        -- owlkin frenzy
        local pts = talents:pts(1, 21);
        if pts ~= 0 then

            -- TODO: owlkin frenzy tracking
        end

        -- wrath of cenarius
        local pts = talents:pts(1, 22);
        if pts ~= 0 then

            local sf = localized_spell_name("Starfire");
            local w = localized_spell_name("Wrath");
            ensure_exists_and_add(new_loadout.ability_coef_mod, sf, pts * 0.04, 0);
            ensure_exists_and_add(new_loadout.ability_coef_mod, w, pts * 0.02, 0);
        end

        -- eclipse
        local pts = talents:pts(1, 23);
        if pts ~= 0 then

            -- TODO: eclipse tracking
        end

        -- gale winds
        local pts = talents:pts(1, 26);
        if pts ~= 0 then
            local abilities = localize_spell_name_array({"Hurricane", "Typhoon"});
            for k, v in pairs(abilities) do
                ensure_exists_and_mul(new_loadout.ability_effect_mod, v, 1.0 + pts * 0.15, 1.0);
            end
        end

        --  earth and moon
        local pts = talents:pts(1, 27);
        if pts ~= 0 then
            new_loadout.spell_dmg_mod_by_school[magic_school.arcane] = 
                new_loadout.spell_dmg_mod_by_school[magic_school.arcane] + 0.02 * pts;
            new_loadout.spell_dmg_mod_by_school[magic_school.nature] = 
                new_loadout.spell_dmg_mod_by_school[magic_school.nature] + 0.02 * pts;
        end

        --  starfall
        --  TODO: awkward to display tooltip for

        -- TODO: feral
        -- heart of the wild
        --local pts = talents:pts(2, 15);
        --if pts ~= 0 then
        --    new_loadout.stat_mod[stat.int] = new_loadout.stat_mod[stat.int] + pts * 0.04;
        --end


        -- TODO: furor talent (3,3) intellect in boomkin form
        -- naturalist
        local pts = talents:pts(3, 4);
        if pts ~= 0 then
            local ht = localized_spell_name("Healing Touch");
            ensure_exists_and_add(new_loadout.ability_cast_mod, ht, pts * 0.1, 0);
        end
        -- intensity
        local pts = talents:pts(3, 7);
        if pts ~= 0 then
            local effects = {0.17, 0.33, 0.5};
            new_loadout.regen_while_casting = new_loadout.regen_while_casting + effects[pts];
        end

        
        -- tranquil spirit
        local pts = talents:pts(3, 10);
        if pts ~= 0 then
            local abilities = localize_spell_name_array({"Healing Touch", "Tranquility", "Nourish"});
            
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_cost_mod, v, pts * 0.02, 0);
            end
        end

        -- improved rejuvenation
        local pts = talents:pts(3, 11);
        if pts ~= 0 then
            local rejuv = localized_spell_name("Rejuvenation");
            ensure_exists_and_mul(new_loadout.ability_effect_mod, rejuv, 1.0 + pts * 0.05, 1.0);
        end

        -- gift of nature
        local pts = talents:pts(3, 13);
        if pts ~= 0 then
            new_loadout.spell_heal_mod = new_loadout.spell_heal_mod + pts * 0.02;
        end

        -- empowered touch
        local pts = talents:pts(3, 15);
        if pts ~= 0 then

            local ht = localized_spell_name("Healing Touch");
            local no = localized_spell_name("Nourish");
            ensure_exists_and_add(new_loadout.ability_coef_mod, ht, pts * 0.2, 0);
            ensure_exists_and_add(new_loadout.ability_coef_mod, no, pts * 0.1, 0);
        end

        -- nature's bounty
        local pts = talents:pts(3, 16);
        if pts ~= 0 then
            local abilities = localize_spell_name_array({"Regrowth", "Nourish"});
            
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_crit, v, pts * 0.05, 0);
            end
        end

        -- living spirit
        local pts = talents:pts(3, 17);
        if pts ~= 0 then
            new_loadout.stat_mod[stat.spirit] = new_loadout.stat_mod[stat.spirit] + pts * 0.05;
        end

        -- natural perfection
        local pts = talents:pts(3, 19);
        if pts ~= 0 then

            new_loadout.spell_crit_by_school[magic_school.nature] = 
                new_loadout.spell_crit_by_school[magic_school.nature] + 0.01 * pts;
            new_loadout.spell_crit_by_school[magic_school.arcane] = 
                new_loadout.spell_crit_by_school[magic_school.arcane] + 0.01 * pts;
        end

        -- empowered rejuvenation
        local pts = talents:pts(3, 20);
        if pts ~= 0 then
            local hots = localize_spell_name_array({"Lifebloom", "Regrowth",  "Wild Growth", "Rejuvenation"});
            for k, v in pairs(hots) do
                ensure_exists_and_add(new_loadout.ability_coef_ot_mod, v, pts * 0.04, 0);
            end
        end

        -- living seed
        --local pts = talents:pts(3, 21);
        --if pts ~= 0 then
        --end
        --
        -- TODO: lifebloom half mana cost

        -- revitalize
        local pts = talents:pts(3, 22);
        if pts ~= 0 then
            -- TODO: mana refund on rejuv and wild growth
        end

        -- tree of life
        local pts = talents:pts(3, 23);
        if pts ~= 0 then
            -- TODO: tree tracking aura and self
            local abilities = localize_spell_name_array({"Regrowth", "Rejuvenation", "Lifebloom", "Wild Growth"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_cost_mod, v, 0.2, 0);
            end
        end

        -- improved tree of life
        local pts = talents:pts(3, 23);
        if pts ~= 0 then
            -- TODO: spiritual guidance
        end

        -- gift of the earthmother
        local pts = talents:pts(3, 25);
        if pts ~= 0 then
            new_loadout.haste_mod = new_loadout.haste_mod * (1.0 + pts * 0.02);
        end

    elseif class == "PRIEST" then

        local instants = localize_spell_name_array({"Renew", "Holy Nova", "Circle of Healing", "Prayer of Mending", "Devouring Plague", "Shadow Word: Pain", "Shadow Word: Death", "Power Word: Shield", "Mind Flay", "Mind Sear", "Desperate Prayer"});

        -- twin disciplines
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            for k, v in pairs(instants) do
                ensure_exists_and_add(new_loadout.ability_effect_mod, v, pts * 0.01, 1.0);
            end
        end

        -- meditation
        local pts = talents:pts(1, 7);
        if pts ~= 0 then
            local effects = {0.17, 0.33, 0.5};
            new_loadout.regen_while_casting = new_loadout.regen_while_casting + effects[pts];
        end

        -- improved power word: shield
        local pts = talents:pts(1, 9);
        if pts ~= 0 then
            local shield = localized_spell_name("Power Word: Shield");
            ensure_exists_and_mul(new_loadout.ability_effect_mod, shield, 1.0 + pts * 0.05, 1.0);
        end

        -- mental agility 
        local pts = talents:pts(1, 11);
        if pts ~= 0 then

            local effects = {0.04, 0.07, 0.1};
            for k, v in pairs(instants) do
                ensure_exists_and_add(new_loadout.ability_cost_mod, v, effects[pts], 0);
            end
            local shield = localized_spell_name("Power Word: Shield");
            ensure_exists_and_add(new_loadout.ability_cost_mod, shield, effects[pts], 0);
        end

        -- mental strength
        local pts = talents:pts(1, 14);
        if pts ~= 0 then
            new_loadout.stat_mod[stat.int] = new_loadout.stat_mod[stat.int] + pts * 0.03;
        end

        -- focused power
        local pts = talents:pts(1, 16);
        if pts ~= 0 then
            -- TODO: unclear how this spell % dmg is added, before or with other % ?
            --new_loadout.dmg_mod = new_loadout.dmg_mod + pts * 0.02;
            --new_loadout.spell_heal_mod = new_loadout.spell_heal_mod + pts * 0.02;
            new_loadout.gmod = new_loadout.gmod * (1 + pts*0.02);
        end

        -- enlightenment
        local pts = talents:pts(1, 17);
        if pts ~= 0 then
            new_loadout.stat_mod[stat.spirit] = new_loadout.stat_mod[stat.spirit] + pts * 0.02;
            new_loadout.haste_mod = new_loadout.haste_mod * (1.0 + pts * 0.02);
        end

        -- focused will
        local pts = talents:pts(1, 18);
        if pts ~= 0 then

            new_loadout.spell_crit_by_school[magic_school.holy] = 
                new_loadout.spell_crit_by_school[magic_school.holy] + 0.01 * pts;
            new_loadout.spell_crit_by_school[magic_school.shadow] = 
                new_loadout.spell_crit_by_school[magic_school.shadow] + 0.01 * pts;
        end

        -- TODO: increased crit dynamically on low hp target
        -- improved flash heal
        local pts = talents:pts(1, 20);
        if pts ~= 0 then
            local flash_heal = localized_spell_name("Flash Heal");
            ensure_exists_and_add(new_loadout.ability_cost_mod, flash_heal, pts * 0.05, 0);
        end
        -- borrowed time
        local pts = talents:pts(1, 27);
        if pts ~= 0 then

            local shield = localized_spell_name("Power Word: Shield");
            ensure_exists_and_add(new_loadout.ability_coef_mod, shield, pts * 0.08, 0); 
        end

        -- improved renew
        local pts = talents:pts(2, 2);
        if pts ~= 0 then
            local renew = localized_spell_name("Renew");
            ensure_exists_and_add(new_loadout.ability_effect_mod, renew, pts * 0.05, 1.0); 
        end
        -- holy specialization
        local pts = talents:pts(2, 3);
        if pts ~= 0 then
            new_loadout.spell_crit_by_school[magic_school.holy] = 
                new_loadout.spell_crit_by_school[magic_school.holy] + pts * 0.01;
        end
        -- divine fury
        local pts = talents:pts(2, 5);
        if pts ~= 0 then
            local abilities = localize_spell_name_array({"Smite", "Holy Fire", "Heal", "Greater Heal"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_cast_mod, v, pts * 0.1, 0);
            end
        end
        -- improved healing
        local pts = talents:pts(2, 10);
        if pts ~= 0 then
            local abilities =
                localize_spell_name_array({"Lesser Heal", "Heal", "Greater Heal", "Divine Hymn", "Penance"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_cost_mod, v, pts * 0.05, 0);
            end
        end
        -- searing light
        local pts = talents:pts(2, 11);
        if pts ~= 0 then
            local abilities = localize_spell_name_array({"Smite", "Holy Fire", "Holy Nova", "Penance"});
            for k, v in pairs(abilities) do
                ensure_exists_and_mul(new_loadout.ability_effect_mod, v, 1.0 + pts * 0.05, 1.0);
            end
        end
        -- healing prayers
        local pts = talents:pts(2, 12);
        if pts ~= 0 then
            local abilities = localize_spell_name_array({"Prayer of Healing", "Prayer of Mending"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_cost_mod, v, pts * 0.1, 0);
            end
        end
        -- spiritual redemption 
        local pts = talents:pts(2, 13);
        if pts ~= 0 then
            new_loadout.stat_mod[stat.spirit] = new_loadout.stat_mod[stat.spirit] + pts * 0.05;
        end
        -- spiritual guidance 
        local pts = talents:pts(2, 14);
        if pts ~= 0 then
           new_loadout.spiritual_guidance = pts * 0.05; 
        end
        -- surge of light
        -- TODO: refund flash heal mana cost off crit chance, similarly as with holy palas in vanilla?
 
        -- spiritual healing
        local pts = talents:pts(2, 16);
        if pts ~= 0 then
            new_loadout.spell_heal_mod = new_loadout.spell_heal_mod + pts * 0.02;
        end

        -- holy concentration
        -- TODO: need an expectation of this extra mana regen uptime based on spell cast time & crit
 
        -- blessed resilience
        local pts = talents:pts(2, 19);
        if pts ~= 0 then
            new_loadout.spell_heal_mod = new_loadout.spell_heal_mod + pts * 0.01;
        end

        -- empowered healing
        local pts = talents:pts(2, 21);
        if pts ~= 0 then
            local gh = localized_spell_name("Greater Heal");
            local fh = localized_spell_name("Flash Heal");
            local bh = localized_spell_name("Binding Heal");

            ensure_exists_and_add(new_loadout.ability_coef_mod, gh, pts * 0.08, 0);
            ensure_exists_and_add(new_loadout.ability_coef_mod, fh, pts * 0.04, 0);
            ensure_exists_and_add(new_loadout.ability_coef_mod, bh, pts * 0.04, 0);
        end

        -- empowered renew 
        local pts = talents:pts(2, 23);
        if pts ~= 0 then
            local renew = localized_spell_name("Renew");
            ensure_exists_and_add(new_loadout.ability_coef_ot_mod, renew, pts * 0.05, 0);
        end

        -- divine providence
        local pts = talents:pts(2, 26);
        if pts ~= 0 then
            local abilities = localize_spell_name_array({"Circle of Healing", "Binding Heal", "Holy Nova", "Prayer of Healing", "Divine Hymn", "Prayer of Mending"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_effect_mod, v, pts * 0.02, 1.0);
            end
        end

        -- darkness 
        local pts = talents:pts(3, 3);
        if pts ~= 0 then

            local abilities = localize_spell_name_array(
                {"Devouring Plague", "Mind Blast", "Shadow Word: Pain", "Mind Flay", "Vampiric Touch", "Shadow Word: Death", "Mind Sear"}
            );
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_effect_mod, v, pts * 0.02, 1.0);
            end
        end

        -- improved shadow word: pain
        local pts = talents:pts(3, 5);
        if pts ~= 0 then
            local swp = localized_spell_name("Shadow Word: Pain");                
            ensure_exists_and_add(new_loadout.ability_effect_mod, swp, pts * 0.03, 1.0);
        end
        -- shadow focus
        local pts = talents:pts(3, 6);
        if pts ~= 0 then
            new_loadout.spell_dmg_hit_by_school[magic_school.shadow] = 
                new_loadout.spell_dmg_hit_by_school[magic_school.shadow] + pts * 0.01;

            local abilities = localize_spell_name_array(
                {"Devouring Plague", "Mind Blast", "Shadow Word: Pain", "Mind Flay", "Vampiric Touch", "Shadow Word: Death", "Mind Sear"}
            );
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_cost_mod, v, pts * 0.02, 0);
            end
        end

        -- focused mind
        local pts = talents:pts(3, 16);
        if pts ~= 0 then
            new_loadout.spell_dmg_hit_by_school[magic_school.shadow] = 
                new_loadout.spell_dmg_hit_by_school[magic_school.shadow] + pts * 0.01;

            local abilities = localize_spell_name_array({"Mind Blast", "Mind Flay", "Mind Sear"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_cost_mod, v, pts * 0.05, 0);
            end
        end
        -- mind melt
        local pts = talents:pts(3, 17);
        if pts ~= 0 then

            local mind = localize_spell_name_array({"Mind Blast", "Mind Flay", "Mind Sear"});
            for k, v in pairs(mind) do
                ensure_exists_and_add(new_loadout.ability_crit, v, pts * 0.02, 0);
            end
            local dots = localize_spell_name_array({"Vampiric Touch", "Shadow Word: Pain", "Devouring Plague"});
            for k, v in pairs(dots) do
                ensure_exists_and_add(new_loadout.ability_crit, v, pts * 0.03, 0);
            end
        end
        -- improved devouring plague
        local pts = talents:pts(3, 18);
        if pts ~= 0 then

            local dp = localized_spell_name("Devouring Plague");
            ensure_exists_and_add(new_loadout.ability_effect_mod, dp, pts * 0.05, 1.0);
            -- TODO: instant dmg 10%, as with renew
        end

        -- shadow power
        local pts = talents:pts(3, 20);
        if pts ~= 0 then
            local abilities = localize_spell_name_array({"Mind Blast", "Mind Flay", "Shadow Word: Death"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_crit_mod, v, pts * 0.1, 0);
            end
        end

        -- misery
        local pts = talents:pts(3, 22);
        if pts ~= 0 then

            local mind_flay = localized_spell_name("Mind Flay");
            --ensure_exists_and_add(new_loadout.ability_coef_ot_mod, mind_flay,  pts * 0.05/(0.2570*3), 0);
            ensure_exists_and_add(new_loadout.ability_coef_ot_mod, mind_flay,  pts * 0.05, 0);
            local mind_sear = localized_spell_name("Mind Sear");
            --ensure_exists_and_add(new_loadout.ability_coef_ot_mod, mind_sear, pts * 0.05, 0);
            local mind_blast = localized_spell_name("Mind Blast");
            --ensure_exists_and_add(new_loadout.ability_coef_mod, mind_blast, pts * 0.175/3, 0);
            ensure_exists_and_add(new_loadout.ability_coef_mod, mind_blast, pts * 0.05 * 0.4286, 0);

        end
        -- twisted faith
        -- TODO: shadow word: pain tracking
        local pts = talents:pts(3, 26);
        if pts ~= 0 then
             
           new_loadout.spiritual_guidance = pts * 0.04; 
        end
        
    elseif class == "SHAMAN" then

        -- convection
        local pts = talents:pts(1, 1);
        if pts ~= 0 then
            local abilities = {"Earth Shock", "Frost Shock", "Flame Shock", "Lightning Bolt", "Chain Lightning"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end

            for k, v in pairs(abilities) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.02;
            end
        end

        -- concussion
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            local abilities = {"Earth Shock", "Frost Shock", "Flame Shock", "Lightning Bolt", "Chain Lightning"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end

        end

        -- call of flame
        local pts = talents:pts(1, 5);
        if pts ~= 0 then
        end

        -- call of thunder
        local pts = talents:pts(1, 8);
        if pts ~= 0 then
            local abilities = {"Lightning Bolt", "Chain Lightning"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end

            for k, v in pairs(abilities) do
                if not new_loadout.ability_crit[v] then
                    new_loadout.ability_crit[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                if pts == 5 then
                    new_loadout.ability_crit[v] = new_loadout.ability_crit[v] + 0.06;
                else
                    new_loadout.ability_crit[v] = new_loadout.ability_crit[v] + pts * 0.01;
                end
            end
        end

        -- elemental fury
        local pts = talents:pts(1, 13);
        if pts ~= 0 then
            new_loadout.spell_crit_mod_by_school[magic_school.frost] = 
                1 + (new_loadout.spell_crit_mod_by_school[magic_school.frost] - 1) * 2;
            new_loadout.spell_crit_mod_by_school[magic_school.fire] = 
                1 + (new_loadout.spell_crit_mod_by_school[magic_school.fire] - 1) * 2;
            new_loadout.spell_crit_mod_by_school[magic_school.nature] = 
                1 + (new_loadout.spell_crit_mod_by_school[magic_school.nature] - 1) * 2;
        end

        -- lightning mastery
        local pts = talents:pts(1, 14);
        if pts ~= 0 then

            local abilities = {"Lightning Bolt", "Chain Lightning"};
            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end

            for k, v in pairs(abilities) do
                if not new_loadout.ability_cast_mod[v] then
                    new_loadout.ability_cast_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_cast_mod[v] = new_loadout.ability_cast_mod[v] + pts * 0.2;
            end
        end

        -- improved lightning shield
        local pts = talents:pts(2, 6);
        if pts ~= 0 then
            local ls = localized_spell_name("Lightning Shield");
        end

        -- improved healing wave
        local pts = talents:pts(3, 1);
        if pts ~= 0 then
            local hw = localized_spell_name("Healing Wave");
            if not new_loadout.ability_cast_mod[hw] then
                new_loadout.ability_cast_mod[hw] = 0;
            end
            new_loadout.ability_cast_mod[hw] = new_loadout.ability_cast_mod[hw] + pts * 0.1;
        end

        -- tidal focus
        local pts = talents:pts(3, 2);
        if pts ~= 0 then

            local abilities = {"Lesser Healing Wave", "Healing Wave", "Chain Heal", "Healing Stream Totem"};

            for k, v in pairs(abilities) do
                abilities[k] = localized_spell_name(v);
            end
            for k, v in pairs(abilities) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.01;
            end
        end

        -- totemic focus
        local pts = talents:pts(3, 5);
        if pts ~= 0 then

            local totems = {"Healing Stream Totem", "Magma Totem", "Searing Totem", "Fire Nova Totem"};

            for k, v in pairs(totems) do
                totems[k] = localized_spell_name(v);
            end

            for k, v in pairs(totems) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(totems) do
                new_loadout.ability_cost_mod[v] = new_loadout.ability_cost_mod[v] + pts * 0.05;
            end
        end

        local pts = talents:pts(3, 10);
        if pts ~= 0 then

            local totems = {"Healing Stream Totem"};
            for k, v in pairs(totems) do
                totems[k] = localized_spell_name(v);
            end

        end

        -- tidal mastery
        local pts = talents:pts(3, 11);
        if pts ~= 0 then


            local lightning_spells = {"Lightning Bolt", "Chain Lightning", "Lightning Shield"};

            for k, v in pairs(lightning_spells) do
                lightning_spells[k] = localized_spell_name(v);
            end

            for k, v in pairs(lightning_spells) do
                if not new_loadout.ability_crit[v] then
                    new_loadout.ability_crit[v] = 0;
                end
            end
            for k, v in pairs(lightning_spells) do
                new_loadout.ability_crit[v] = new_loadout.ability_crit[v] + pts * 0.01;
            end
        end

        -- purification
        local pts = talents:pts(3, 14);
        if pts ~= 0 then


        end

    elseif class == "PALADIN" then

        -- healing light
        local pts = talents:pts(1, 3);
        if pts ~= 0 then
            local abilities = localize_spell_name_array({"Holy Light", "Flash of Light", "Holy Shock"});

            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_effect_mod, v, pts * 0.04, 1.0);
            end
        end

        -- divine intellect
        local pts = talents:pts(1, 4);
        if pts ~= 0 then
            new_loadout.stat_mod[stat.int] = new_loadout.stat_mod[stat.int] + pts * 0.02;
        end

        -- TODO: bow?
        
        -- sanctified light
        local pts = talents:pts(1, 14);
        if pts ~= 0 then
            local abilities = localize_spell_name_array({"Holy Light", "Holy Shock"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(new_loadout.ability_crit, v, pts * 0.02, 0);
            end
            
        end

        -- holy power
        local pts = talents:pts(1, 16);
        if pts ~= 0 then
            new_loadout.spell_crit_by_school[magic_school.holy] = 
                new_loadout.spell_crit_by_school[magic_school.holy] + pts * 0.01;
        end

        -- lights grace
        local pts = talents:pts(1, 17);
        if pts ~= 0 then

            local hl = localized_spell_name("Holy Light");
            ensure_exists_and_add(new_loadout.ability_cast_mod, hl, pts * 0.5 / 3.0, 0);
        end

        -- holy guidance
        local pts = talents:pts(1, 21);
        if pts ~= 0 then

            -- TODO: sp based on int
        end
        -- divine illumination
        local pts = talents:pts(1, 23);
        if pts ~= 0 then

            -- TODO: tracking
        end
        -- judgement of pure
        local pts = talents:pts(1, 23);
        if pts ~= 0 then

            -- TODO: haste buff tracking
        end
        -- infusion of light
        local pts = talents:pts(1, 23);
        if pts ~= 0 then

            -- TODO: buff tracking, flash of light increase
        end

        -- divinity
        local pts = talents:pts(2, 1);
        if pts ~= 0 then
            new_loadout.spell_heal_mod = new_loadout.spell_heal_mod + pts * 0.02;
            new_loadout.target_healing_taken = new_loadout.target_healing_taken + pts * 0.02;
        end
        -- benediction
        local pts = talents:pts(3, 2);
        if pts ~= 0 then
            local hs = localized_spell_name("Holy Shock");
            ensure_exists_and_add(new_loadout.ability_cost_mod, hs, pts * 0.02, 0.0); 
        end

    elseif class == "WARLOCK" then
        local affl = {"Corruption", "Siphon Life", "Curse of Agony", "Death Coil", "Drain Life", "Drain Soul"};
        for k, v in pairs(affl) do
            affl[k] = localized_spell_name(v);
        end
        local destr = {"Shadow Bolt", "Searing Pain", "Soul Fire", "Hellfire", "Rain of Fire", "Immolate", "Shadowburn", "Conflagrate"};
        for k, v in pairs(destr) do
            destr[k] = localized_spell_name(v);
        end


        -- suppression
        local pts = talents:pts(1, 1);
        if pts ~= 0 then

            for k, v in pairs(affl) do
                if not new_loadout.ability_hit[v] then
                    new_loadout.ability_hit[v] = 0;
                end
            end
            for k, v in pairs(affl) do
                new_loadout.ability_hit[v] = 
                    new_loadout.ability_hit[v] + pts * 0.02;
            end
        end
        -- improved corruption
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            local corruption = localized_spell_name("Corruption");

            if not new_loadout.ability_cast_mod[corruption] then
                new_loadout.ability_cast_mod[corruption] = 0;
            end

            new_loadout.ability_cast_mod[corruption] = 
                new_loadout.ability_cast_mod[corruption] + pts * 0.4;
        end

        -- improved curse of agony
        local pts = talents:pts(1, 7);
        if pts ~= 0 then
            local coa = localized_spell_name("Curse of Agony");

        end
        -- shadow mastery
        local pts = talents:pts(1, 16);
        if pts ~= 0 then

            new_loadout.spell_dmg_mod_by_school[magic_school.shadow] = 
                new_loadout.spell_dmg_mod_by_school[magic_school.shadow] + pts * 0.02;
        end

        -- improved shadow bolt
        local pts = talents:pts(3, 1);
        if pts ~= 0 then
           new_loadout.improved_shadowbolt = pts; 
        end

        -- cataclysm
        local pts = talents:pts(3, 2);
        if pts ~= 0 then

            for k, v in pairs(destr) do
                if not new_loadout.ability_cost_mod[v] then
                    new_loadout.ability_cost_mod[v] = 0;
                end
            end
            for k, v in pairs(destr) do
                new_loadout.ability_cost_mod[v] = 
                    new_loadout.ability_cost_mod[v] + pts * 0.01;
            end
        end
        -- bane
        local pts = talents:pts(3, 3);
        if pts ~= 0 then
            local imm = localized_spell_name("Immolate");
            local sb = localized_spell_name("Shadow Bolt");
            local sf = localized_spell_name("Soul Fire");

            if not new_loadout.ability_cast_mod[imm] then
                new_loadout.ability_cast_mod[imm] = 0;
            end
            if not new_loadout.ability_cast_mod[sb] then
                new_loadout.ability_cast_mod[sb] = 0;
            end
            if not new_loadout.ability_cast_mod[sf] then
                new_loadout.ability_cast_mod[sf] = 0;
            end

            new_loadout.ability_cast_mod[imm] = new_loadout.ability_cast_mod[imm] + pts * 0.1;
            new_loadout.ability_cast_mod[sb] = new_loadout.ability_cast_mod[sb] + pts * 0.1;
            new_loadout.ability_cast_mod[sf] = new_loadout.ability_cast_mod[sf] + pts * 0.4;
        end
        -- devastation
        local pts = talents:pts(3, 7);
        if pts ~= 0 then

            for k, v in pairs(destr) do
                if not new_loadout.ability_crit[v] then
                    new_loadout.ability_crit[v] = 0;
                end
            end
            for k, v in pairs(destr) do
                new_loadout.ability_crit[v] = 
                    new_loadout.ability_crit[v] + pts * 0.01;
            end
        end
        -- improved searing pain
        local pts = talents:pts(3, 11);
        if pts ~= 0 then
            local sp = localized_spell_name("Searing Pain");
            if not new_loadout.ability_crit[sp] then
                new_loadout.ability_crit[sp] = 0;
            end
            new_loadout.ability_crit[sp] = new_loadout.ability_crit[sp] + pts * 0.02;
        end

        -- improved immolate
        local pts = talents:pts(3, 13);
        new_loadout.improved_immolate = pts;

        -- ruin 
        local pts = talents:pts(3, 14);
        if pts ~= 0 then

            for k, v in pairs(destr) do
                if not new_loadout.ability_crit_mod[v] then
                    new_loadout.ability_crit_mod[v] = 0;
                end
            end
            for k, v in pairs(destr) do
                new_loadout.ability_crit_mod[v] = 
                    new_loadout.ability_crit_mod[v] + 0.5;
            end
        end
        --emberstorm
        local pts = talents:pts(3, 15);
        if pts ~= 0 then
            new_loadout.spell_dmg_mod_by_school[magic_school.fire] =
                new_loadout.spell_dmg_mod_by_school[magic_school.fire] + pts * 0.02;
        end
    end

    return new_loadout;
end

local function create_sets()

    local set_tier_ids = {};

    if class == "PRIEST" then
        -- of prophecy
        for i = 16811, 16819 do
            set_tier_ids[i] = set_tiers.pve_1;
        end
        for i = 16919, 16926 do
            set_tier_ids[i] = set_tiers.pve_2;
        end
        -- aq20
        for i = 21410, 21412 do
            set_tier_ids[i] = set_tiers.aq20;
        end

        -- aq40
        for i = 21348, 21352 do
            set_tier_ids[i] = set_tiers.aq40;
        end

        --naxx
        for i = 22512, 22519 do
            set_tier_ids[i] = set_tiers.pve_3;
        end
        set_tier_ids[23061] = set_tiers.pve_3;

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

    elseif class == "SHAMAN" then

    elseif class == "WARLOCK" then

    elseif class == "MAGE" then


    elseif class == "PALADIN" then
        -- t7 holy
        for i = 39628, 39632 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
        for i = 40569, 40573 do
            set_tier_ids[i] = set_tiers.pve_t7_1;
        end
    end

    return set_tier_ids;
end

local function create_set_effects() 

    if class == "PRIEST" then
        return {
            [set_tiers.pve_t7_1] = function(num_pieces, loadout)
                if num_pieces >= 2 then
                    -- TODO: POM calculation done in later stage
                end
                if num_pieces >= 4 then
                    local gh = localized_spell_name("Greater Heal");
                    ensure_exists_and_add(loadout.ability_cost_mod, gh, 0.05, 0.0);
                end
            end,
            [set_tiers.pve_t7_3] = function(num_pieces, loadout)
                if num_pieces >= 2 then
                    local mb = localized_spell_name("Mind Blast");
                    ensure_exists_and_add(loadout.ability_cost_mod, mb, 0.1, 0.0);
                end
                if num_pieces >= 4 then
                    local swd = localized_spell_name("Shadow Word: Death");
                    ensure_exists_and_add(loadout.ability_crit, swd, 0.1, 0.0);
                end
            end,
        };

    elseif class == "DRUID" then
        return {
            [set_tiers.pve_t7_1] = function(num_pieces, loadout)
                if num_pieces >= 2 then
                    local is = localized_spell_name("Insect Swarm");
                    ensure_exists_and_add(loadout.ability_effect_mod, is, 0.1, 1.0);
                    
                end
                if num_pieces >= 4 then
                    local abilities = localize_spell_name_array({"Wrath", "Starfire"});
                    for k, v in pair(abilities) do
                        ensure_exists_and_add(loadout.ability_crit, v, 0.05, 0.0);
                    end
                end
            end,
            [set_tiers.pve_t7_3] = function(num_pieces, loadout)
                if num_pieces >= 2 then
                    local lb = localized_spell_name("Lifebloom");
                    ensure_exists_and_add(loadout.ability_cost_mod, lb, 0.05, 0.0);
                end
                if num_pieces >= 4 then
                    -- TODO: awkward to implement, could track hots on target and estimate
                end
            end,
        };

    elseif class == "SHAMAN" then

    elseif class == "WARLOCK" then

    elseif class == "MAGE" then

    elseif class == "PALADIN" then
        return {
            [set_tiers.pve_t7_1] = function(num_pieces, loadout)
                if num_pieces >= 2 then
                    local hs = localized_spell_name("Holy Shock");
                    ensure_exists_and_add(loadout.ability_crit, hs, 0.1, 0.0);

                end
                if num_pieces >= 4 then
                    local hl = localized_spell_name("Holy Light");
                    ensure_exists_and_add(loadout.ability_cost_mod, hl, 0.05, 0.0);
                end
            end,
        };
    end
end 

local set_items = create_sets();
local set_bonus_effects = create_set_effects();

local function apply_set_bonuses(loadout)

    local new_loadout = loadout;

    -- go through equipment to find set pieces

    for item = 1, 18 do
        local id = GetInventoryItemID("player", item);
        if set_items[id] then
            -- incr counter
            if not new_loadout.num_set_pieces[set_items[id]] then
                new_loadout.num_set_pieces[set_items[id]] = 0;
            end
            new_loadout.num_set_pieces[set_items[id]] = new_loadout.num_set_pieces[set_items[id]] + 1;
        end
        local item_link = GetInventoryItemLink("player", item);
        if item_link then
            local item_stats = GetItemStats(item_link);
            if item_stats then

                if item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] then
                    new_loadout.mp5 = new_loadout.mp5 + item_stats["ITEM_MOD_POWER_REGEN0_SHORT"] + 1;
                end

                if item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] then
                    for i = 2,7 do
                        new_loadout.target_res_by_school[i] = 
                            new_loadout.target_res_by_school[i] - (item_stats["ITEM_MOD_SPELL_PENETRATION_SHORT"] - 1);
                    end
                end
            end
        end
    end

    if class == "PRIEST" then
        for k, v in pairs(loadout.num_set_pieces) do
            set_bonus_effects[k](v, new_loadout);
        end
    end

    return new_loadout;
end

local function detect_buffs(loadout)

    local new_loadout = loadout;

    new_loadout.dynamic_buffs = {["player"] = {}, ["target"] = {}, ["mouseover"] = {}};
    if loadout.player_name == loadout.target_name then
        new_loadout.dynamic_buffs["target"] = new_loadout.dynamic_buffs["player"]
    end
    if loadout.player_name == loadout.mouseover_name then
        new_loadout.dynamic_buffs["mouseover"] = new_loadout.dynamic_buffs["player"]
    end
    if loadout.target_name == loadout.mouseover_name then
        new_loadout.dynamic_buffs["mouseover"] = new_loadout.dynamic_buffs["target"]
    end

    for k, v in pairs(new_loadout.dynamic_buffs) do
        local i = 1;
        while true do
              local name, icon_tex, count, _, _, _, src, _, _, spell_id = UnitBuff(k, i);
              if not name then
                  break;
              end
              v[name] = {count = count, id = spell_id, src = src,};
              i = i + 1;
        end
        local i = 1;
        while true do
              local name, _, count, _, _, _, src, _, _, spell_id = UnitDebuff(k, i);
              if not name then
                  break;
              end
              v[name] = {count = count, id = spell_id, src = src};
              i = i + 1;
        end
    end

    return new_loadout;
end

local function apply_buffs(loadout)

    local stats_diff_loadout = empty_loadout();

    if loadout.always_assume_buffs then
        for k, v in pairs(loadout.buffs) do
            -- if dynamically present, some type of buffs must be removed
            -- as they were already counted for, things like sp, crit
            if loadout.dynamic_buffs["player"][k] then
                if v.remove then
                    v.remove(loadout, loadout.dynamic_buffs["player"][k]);
                end
            else
                v.apply(loadout, v);
            end
        end
        for k, v in pairs(loadout.target_buffs) do
            v.apply(loadout, v);
        end
        if class == "PALADIN" and loadout.talents_table:pts(1, 26) ~= 0 and loadout.target_buffs[localized_spell_name("Beacon of Light")] then
            loadout.beacon = true;
        else
            loadout.beacon = nil
        end
    else
        for k, v in pairs(loadout.dynamic_buffs["player"]) do
            if loadout.buffs[k] then
                loadout.buffs[k].apply(loadout, loadout.dynamic_buffs["player"][k]); 
            end
        end
        for k, v in pairs(loadout.dynamic_buffs[loadout.friendly_towards]) do
            if loadout.target_buffs[k] and bit.band(buff_filters.friendly, loadout.target_buffs[k].filter) ~= 0 then
                loadout.target_buffs[k].apply(loadout, v); 
            end
        end
        if loadout.hostile_towards then
            for k, v in pairs(loadout.dynamic_buffs[loadout.hostile_towards]) do
                if loadout.target_buffs[k] and bit.band(buff_filters.hostile, loadout.target_buffs[k].filter) ~= 0 then
                    loadout.target_buffs[k].apply(loadout, v); 
                end
            end
        end

        if class == "PALADIN" and loadout.talents_table:pts(1, 26) and loadout.target_buffs[localized_spell_name("Beacon of Light")] and beacon_snapshot_time + 60 >= addon_running_time then
            loadout.beacon = true;
        else
            loadout.beacon = nil
        end
    end

    loadout = loadout_add(loadout, stats_diff_loadout);

    return loadout;
end

local function default_loadout()

   local loadout = empty_loadout();

   loadout.name = "Default";

   loadout.lvl = UnitLevel("player");
   loadout.target_lvl = loadout.lvl + 3;
   loadout.is_dynamic_loadout = true;
   loadout.talents_code = wowhead_talent_code();
   loadout.always_assume_buffs = false;
   loadout.use_dynamic_target_lvl = true;
   loadout.has_target = false;

   loadout.stats = {};
   for i = 1, 5 do
       local _, stat, _, _ = UnitStat("player", i);

       loadout.stats[i] =  stat;
   end
   loadout.mana = 0;
   loadout.max_mana = 0;
   loadout.extra_mana = 0;

   -- in wotlk, healing power will equate to spell power
   loadout.spell_power = GetSpellBonusHealing();
   for i = 1, 7 do
       loadout.spell_dmg_by_school[i] = GetSpellBonusDamage(i) - loadout.spell_power;
   end
   for i = 1, 7 do
       print(loadout.spell_crit_by_school[i]);
       loadout.spell_crit_by_school[i] = GetSpellCritChance(i)*0.01;
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

   loadout.spell_crit_mod_by_school = {1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5};

    -- assume all buffs are checked and dynamically checked for
    for k, v in pairs(buffs) do
        if bit.band(filter_flags_active, v.filter) ~= 0 then
            local buff_lname, _, _, _, _, _, _ = GetSpellInfo(k);
            loadout.buffs[buff_lname] = v;
        end
    end
    for k, v in pairs(target_buffs) do
        if bit.band(filter_flags_active, v.filter) ~= 0 then
            local buff_lname, _, _, _, _, _, _ = GetSpellInfo(k);
            loadout.target_buffs[buff_lname] = v;
        end
    end

   --loadout = apply_talents_glyphs(loadout);

   --loadout = apply_glyphs(loadout);

   --loadout = apply_set_bonuses(loadout);

   --loadout = detect_buffs(loadout);

   return loadout;
end

--TODO: almost duplicate code here and in  static_loadout_from_dynamic
--      forgotten reasoning -- figure out why and unify
local function dynamic_loadout(base_loadout)

   base_loadout.talents_code = wowhead_talent_code();

   local loadout = loadout_copy(base_loadout);

   loadout.lvl = UnitLevel("player");

   loadout.stats = {};
   for i = 1, 5 do
       local _, stat, _, _ = UnitStat("player", i);

       loadout.stats[i] =  stat;
   end

   loadout.mana = UnitPower("player", 0);
   loadout.max_mana = UnitPowerMax("player", 0);

   -- in wotlk, healing power will equate to spell power
   loadout.spell_power = GetSpellBonusHealing();
   for i = 1, 7 do
       loadout.spell_dmg_by_school[i] = GetSpellBonusDamage(i) - loadout.spell_power;
   end
   for i = 1, 7 do
       loadout.spell_crit_by_school[i] = GetSpellCritChance(i)*0.01;
   end

   -- crit and hit is already gathered indirectly from rating, but not haste
   loadout.haste_rating = GetCombatRating(CR_HASTE_SPELL);

   -- right after load GetSpellHitModifier seems to sometimes returns a nil.... so check first I guess
   local spell_hit = 0;
   local real_hit = GetSpellHitModifier();
   if real_hit then
       spell_hit = 0.01*real_hit;
   end
   for i = 1, 7 do
       loadout.spell_dmg_hit_by_school[i] = spell_hit;
   end

   loadout.berserking_snapshot = sw_berserking_snapshot;

   loadout.spell_crit_mod_by_school = {1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5};

   -- CARE: duplicate old code for forgotten reason
   loadout.player_name = UnitName("player"); 
   loadout.target_name = UnitName("target"); 
   loadout.mouseover_name = UnitName("mouseover"); 

   loadout.hostile_towards = nil; 
   loadout.friendly_towards = "player";

   loadout.has_target = false; 
   if UnitExists("target") then
       loadout.has_target = true; 
       loadout.hostile_towards = "target";
       loadout.friendly_towards = "target";

       loadout.target_friendly = UnitIsFriend("player", "target");
       -- TODO: returns localized name.. so won't work for non-english clients....
       loadout.target_type = UnitCreatureType("target");

       if loadout.use_dynamic_target_lvl and not loadout.target_friendly then
           local target_lvl = UnitLevel("target");
           if target_lvl == -1 then
               loadout.target_lvl = loadout.lvl + 3;
           else
               loadout.target_lvl = target_lvl;
           end
       end
   end

   if UnitExists("mouseover") and UnitName("mouseover") ~= UnitName("target") then
       loadout.friendly_towards = "mouseover";
   end
   loadout.friendly_hp_perc = UnitHealth(loadout.friendly_towards)/UnitHealthMax(loadout.friendly_towards);

   -- talents may not be applied here as they are parameterized
   --loadout = apply_talents_glyphs(loadout);

   loadout = remove_dynamic_stats_from_talents(loadout);

   loadout = apply_set_bonuses(loadout);

   loadout = detect_buffs(loadout);

   return loadout;
end

local function static_loadout_from_dynamic(base_loadout)
    
   local loadout = loadout_copy(base_loadout);

   loadout.lvl = UnitLevel("player");

   loadout.stats = {};
   for i = 1, 5 do
       local _, stat, _, _ = UnitStat("player", i);

       loadout.stats[i] =  stat;
   end

   loadout.mana = UnitPowerMax("player", 0);
   loadout.talents_code = wowhead_talent_code();
   loadout.extra_mana = base_loadout.extra_mana;

   -- in wotlk, healing power will equate to spell power
   loadout.spell_power = GetSpellBonusHealing();
   for i = 1, 7 do
       loadout.spell_dmg_by_school[i] = GetSpellBonusDamage(i) - loadout.spell_power;
   end
   for i = 1, 7 do
       loadout.spell_crit_by_school[i] = GetSpellCritChance(i)*0.01;
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

   loadout.berserking_snapshot = sw_berserking_snapshot;

   loadout.spell_crit_mod_by_school = {1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5};

   loadout.player_name = UnitName("player"); 
   loadout.target_name = UnitName("target"); 
   loadout.mouseover_name = UnitName("mouseover"); 

   loadout.hostile_towards = nil; 
   loadout.friendly_towards = "player";

   loadout.has_target = false; 
   if UnitExists("target") and UnitName("target") ~= UnitName("player") then
       loadout.has_target = true; 
       loadout.hostile_towards = "target";
       loadout.friendly_towards = "target";

       loadout.target_friendly = UnitIsFriend("player", "target");
       -- TODO: returns localized name.. so won't work for non-english clients....
       loadout.target_type = UnitCreatureType("target");

       if loadout.use_dynamic_target_lvl and not loadout.target_friendly then
           local target_lvl = UnitLevel("target");
           if target_lvl == -1 then
               loadout.target_lvl = loadout.lvl + 3;
           else
               loadout.target_lvl = target_lvl;
           end
       end
   end

   -- talents may not be applied here as they are parameterized
   --loadout = apply_talents_glyphs(loadout);
   loadout = remove_dynamic_stats_from_talents(loadout);

   loadout = apply_set_bonuses(loadout);

   loadout = detect_buffs(loadout);

   return loadout;
end

local function empty_loadout_with_buffs(loadout_with_buffs)

    -- snapshot loadout
    local loadout = empty_loadout();

    loadout.name = loadout_with_buffs.name;
    loadout.lvl = loadout_with_buffs.lvl;
    loadout.target_lvl = loadout_with_buffs.target_lvl;

    -- setting mana as max mana, is this fine?

    loadout.always_assume_buffs = loadout_with_buffs.always_assume_buffs;
    loadout.is_dynamic_loadout = loadout_with_buffs.is_dynamic_loadout;
    loadout.use_dynamic_target_lvl = loadout_with_buffs.use_dynamic_target_lvl;
    loadout.has_target = loadout_with_buffs.has_target;

    for k, v in pairs(loadout_with_buffs.buffs) do
        loadout.buffs[k] = v;
    end
    for k, v in pairs(loadout_with_buffs.target_buffs) do
        loadout.target_buffs[k] = v;
    end

    --for k, v in pairs(loadout_with_buffs.dynamic_buffs) do
    --    loadout.dynamic_buffs[k] = v;
    --end
    --for k, v in pairs(loadout_with_buffs.dynamic_target_buffs) do
    --    loadout.dynamic_target_buffs[k] = v;
    --end
    --for k, v in pairs(loadout_with_buffs.dynamic_mouseover_buffs) do
    --    loadout.dynamic_mouseover_buffs[k] = v;
    --end

    loadout.target_friendly = loadout_with_buffs.target_friendly;
    loadout.target_type = loadout_with_buffs.target_type;

    loadout.berserking_snapshot = loadout_with_buffs.berserking_snapshot;

    return loadout;
end

local function begin_tooltip_section(tooltip)
    tooltip:AddLine(" ");
    --tooltip:AddLine("Stat Weights", 1.0, 153.0/255, 102.0/255);
end
local function end_tooltip_section(tooltip)
    tooltip:Show();
end

local function print_loadout(loadout)

    print("Stat Weights Classic - Version: "..version);
    print("Loadout: "..loadout.name);
    print(string.format("level:%d, target_level: %d", loadout.lvl, loadout.target_lvl));
    print("dynamic: ", loadout.is_dynamic_loadout);
    print("always_apply_buffs: ", loadout.always_assume_buffs);
    print("talents: ", wowhead_talent_link(loadout.talents_code));

    print(string.format("str: %d, agi: %d, stam: %d, int: %d, spirit: %d",
          loadout.stats[1],
          loadout.stats[2],
          loadout.stats[3],
          loadout.stats[4],
          loadout.stats[5]));
    print("mana", loadout.mana);
    print("extra mana gained from consumes (pots, runes)", loadout.extra_mana);
    print("mana regen while casting ratio:", loadout.regen_while_casting);
    print("mp5 from gear/buffs", loadout.mp5);
    print("sp: "..loadout.spell_power);
    print(string.format("spell power schools: holy %d, fire %d, nature %d, frost %d, shadow %d, arcane %d",
          loadout.spell_dmg_by_school[2],
          loadout.spell_dmg_by_school[3],
          loadout.spell_dmg_by_school[4],
          loadout.spell_dmg_by_school[5],
          loadout.spell_dmg_by_school[6],
          loadout.spell_dmg_by_school[7]));
    print("spell heal mod: ", loadout.spell_heal_mod);
    print(string.format("spell crit schools: holy %.3f, fire %.3f, nature %.3f, frost %.3f,shadow  %.3f, arcane %.3f", 
                        loadout.spell_crit_by_school[2],
                        loadout.spell_crit_by_school[3],
                        loadout.spell_crit_by_school[4],
                        loadout.spell_crit_by_school[5],
                        loadout.spell_crit_by_school[6],
                        loadout.spell_crit_by_school[7]));
    print(string.format("spell crit dmg mod schools: holy %.3f, fire %.3f, nature %.3f, frost %.3f, shadow %.3f arcane %.3f", 
                        loadout.spell_crit_mod_by_school[2],
                        loadout.spell_crit_mod_by_school[3],
                        loadout.spell_crit_mod_by_school[4],
                        loadout.spell_crit_mod_by_school[5],
                        loadout.spell_crit_mod_by_school[6],
                        loadout.spell_crit_mod_by_school[7]));
    print(string.format("spell hit schools: holy %.3f, fire %.3f, nature %.3f, frost %.3f, shadow %.3f, arcane %.3f", 
                        loadout.spell_dmg_hit_by_school[2],
                        loadout.spell_dmg_hit_by_school[3],
                        loadout.spell_dmg_hit_by_school[4],
                        loadout.spell_dmg_hit_by_school[5],
                        loadout.spell_dmg_hit_by_school[6],
                        loadout.spell_dmg_hit_by_school[7]));
    print(string.format("spell mod schools: holy %.3f, fire %.3f, nature %.3f, frost %.3f, shadow %.3f, arcane %.3f", 
                        loadout.spell_dmg_mod_by_school[2],
                        loadout.spell_dmg_mod_by_school[3],
                        loadout.spell_dmg_mod_by_school[4],
                        loadout.spell_dmg_mod_by_school[5],
                        loadout.spell_dmg_mod_by_school[6],
                        loadout.spell_dmg_mod_by_school[7]));

    print(string.format("target spell dmg taken mod schools: holy %.3f, fire %.3f, nature %.3f, frost %.3f, shadow %.3f, arcane %.3f", 
                        loadout.target_spell_dmg_taken[2],
                        loadout.target_spell_dmg_taken[3],
                        loadout.target_spell_dmg_taken[4],
                        loadout.target_spell_dmg_taken[5],
                        loadout.target_spell_dmg_taken[6],
                        loadout.target_spell_dmg_taken[7]));
    print(string.format("target resistance schools: holy %.1f, fire %.1f, nature %.1f, frost %.1f, shadow %.1f, arcane %.1f", 
                        loadout.target_res_by_school[2],
                        loadout.target_res_by_school[3],
                        loadout.target_res_by_school[4],
                        loadout.target_res_by_school[5],
                        loadout.target_res_by_school[6],
                        loadout.target_res_by_school[7]));
    print(string.format("target resistance schools mod: holy %.1f, fire %.1f, nature %.1f, frost %.1f, shadow %.1f, arcane %.1f", 
                        loadout.target_mod_res_by_school[2],
                        loadout.target_mod_res_by_school[3],
                        loadout.target_mod_res_by_school[4],
                        loadout.target_mod_res_by_school[5],
                        loadout.target_mod_res_by_school[6],
                        loadout.target_mod_res_by_school[7]));

    print(string.format("spell haste mod: %.3f", loadout.haste_mod));
    print(string.format("spell cost mod: %.3f", loadout.cost_mod));
    print(string.format("spell dmg mod : %.3f", loadout.dmg_mod));
    print(string.format("stat mods : %.3f, %.3f, %.3f, %.3f, %.3f",
                        loadout.stat_mod[1],
                        loadout.stat_mod[2],
                        loadout.stat_mod[3],
                        loadout.stat_mod[4],
                        loadout.stat_mod[5]));
    print(string.format("max mana mod : %.3f", loadout.mana_mod));


    print("num set pieces: ");
    for k, v in pairs(loadout.num_set_pieces) do
        print("set id:", k, " num pieces:", v);
    end
    for k, v in pairs(loadout.ability_effect_mod) do
        print("effect mod: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_crit) do
        print("crit: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_cast_mod) do
        print("cast mod: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_extra_ticks) do
        print("extra ticks: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_cost_mod) do
        print("cost mod: ", k, string.format("%.3f", v));
    end

    for k, v in pairs(loadout.ability_crit_mod) do
        print("crit mod: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_hit) do
        print("hit: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_sp) do
        print("ability extra sp: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_flat_add) do
        print("ability flat extra effect: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.ability_refund) do
        print("ability refund: ", k, string.format("%.3f", v));
    end
    for k, v in pairs(loadout.buffs) do
        print("Buffs: ", k);
    end
    --for k, v in pairs(loadout.target_buffs) do
    --    print("Target buffs: ", k);
    --end
    --for k, v in pairs(loadout.target_debuffs) do
    --    print("Target debuffs: ", k);
    --end
end

-- TODO: this is probably still in use along with more scaling punishments
local function level_scaling(lvl)
    return math.min(1, 1 - (20 - lvl)* 0.0375);
end

local function spell_hit(lvl, lvl_target, hit)

    base_hit = 0;

    if lvl_target - lvl > 2 then
        base_hit =  0.94 - 0.11 * (lvl_target - lvl - 2);
    else
        base_hit = 0.96 - 0.01 * (lvl_target - lvl);
    end
    
    return math.max(0.01, math.min(0.99, base_hit + hit));
end

local function  target_avg_magical_res(self_lvl, target_res)
    return math.min(0.75, 0.75 * (target_res/(self_lvl * 5)))
end

local function base_mana_pool()

    local intellect = UnitStat("player", 4);
    local base_mana = UnitPowerMax("player", 0) - (min(20, intellect) + 15*(intellect - min(20, intellect)));

    return base_mana;
end

local function mana_regen_per_5(int, spirit, level)
    local lvl_to_base_regen = {
        [1 ] = 0.034965,
        [2 ] = 0.034191,
        [3 ] = 0.033465,
        [4 ] = 0.032526,
        [5 ] = 0.031661,
        [6 ] = 0.031076,
        [7 ] = 0.030523,
        [8 ] = 0.029994,
        [9 ] = 0.029307,
        [10] = 0.028661,
        [11] = 0.027584,
        [12] = 0.026215,
        [13] = 0.025381,
        [14] = 0.024300,
        [15] = 0.023345,
        [16] = 0.022748,
        [17] = 0.021958,
        [18] = 0.021386,
        [19] = 0.020790,
        [20] = 0.020121,
        [21] = 0.019733,
        [22] = 0.019155,
        [23] = 0.018819,
        [24] = 0.018316,
        [25] = 0.017936,
        [26] = 0.017576,
        [27] = 0.017201,
        [28] = 0.016919,
        [29] = 0.016581,
        [30] = 0.016233,
        [31] = 0.015994,
        [32] = 0.015707,
        [33] = 0.015464,
        [34] = 0.015204,
        [35] = 0.014956,
        [36] = 0.014744,
        [37] = 0.014495,
        [38] = 0.014302,
        [39] = 0.014094,
        [40] = 0.013895,
        [41] = 0.013724,
        [42] = 0.013522,
        [43] = 0.013363,
        [44] = 0.013175,
        [45] = 0.012996,
        [46] = 0.012853,
        [47] = 0.012687,
        [48] = 0.012539,
        [49] = 0.012384,
        [50] = 0.012233,
        [51] = 0.012113,
        [52] = 0.011973,
        [53] = 0.011859,
        [54] = 0.011714,
        [55] = 0.011575,
        [56] = 0.011473,
        [57] = 0.011342,
        [58] = 0.011245,
        [59] = 0.011110,
        [60] = 0.010999,
        [61] = 0.010700,
        [62] = 0.010522,
        [63] = 0.010290,
        [64] = 0.010119,
        [65] = 0.009968,
        [66] = 0.009808,
        [67] = 0.009651,
        [68] = 0.009553,
        [69] = 0.009445,
        [70] = 0.009327,
        [71] = 0.008859,
        [72] = 0.008415,
        [73] = 0.007993,
        [74] = 0.007592,
        [75] = 0.007211,
        [76] = 0.006849,
        [77] = 0.006506,
        [78] = 0.006179,
        [79] = 0.005869,
        [80] = 0.005575,
    };

    local base_regen = lvl_to_base_regen[level];
    if not base_regen then
        base_regen = lvl_to_base_regen[80];
    end
    local mana_regen = math.ceil(5 * (0.001 * math.sqrt(int) * spirit * lvl_to_base_regen[level]) * 0.6);
    return mana_regen;
end

local function spell_info(spell, ot_extra_ticks,
                          cast_time, sp, flat_direct_addition,
                          crit, ot_crit, crit_mod, hit, target_resi,
                          target_vuln_mod, global_mod, mod, ot_mod,
                          direct_coef, ot_coef, cost,
                          spell_name, loadout)
            
    local spell_data = spell;

    local base_min = spell_data.base_min;
    local base_max = spell_data.base_max;
    local base_ot = spell_data.over_time;
    local ot_freq = spell_data.over_time_tick_freq;
    local ot_dur = spell_data.over_time_duration;

    local ot = 0;
    local ot_if_crit = 0;
    local ot_ticks = 0;

    if spell_data.cast_time == spell_data.over_time_duration then
        ot_freq = spell_data.over_time_tick_freq*(cast_time/ot_dur);
        ot_dur = cast_time;
    end

    -- certain ticks may tick faster
    local shadow_form, _, _, _, _, _, _ = GetSpellInfo(15473);
    if (loadout.buffs[shadow_form] and
        (loadout.always_assume_buffs or loadout.dynamic_buffs["player"][shadow_form])) then -- warlock stuff
        if spell_name == localized_spell_name("Devouring Plague") or spell_name == localized_spell_name("Vampiric Touch") then
            -- but locks?
            ot_freq  = spell_data.over_time_tick_freq/loadout.haste_mod;
            ot_dur = ot_dur/loadout.haste_mod;
        end
    end
    if class == "PRIEST" and bit.band(spell_flags.heal, spell_data.flags) ~= 0 and min ~= 0 then
        -- divine aegis
        local pts = loadout.talents_table:pts(1, 24);
        crit_mod = crit_mod * (1 + 0.1 * pts);
    elseif class == "DRUID" and bit.band(spell_flags.heal, spell_data.flags) ~= 0 and min ~= 0 then
        -- living seed
        local pts = loadout.talents_table:pts(3, 21);
        crit_mod = crit_mod * (1 + 0.1 * pts);
    end

    local target_vuln_mod_direct = target_vuln_mod;


    local min_noncrit_if_hit = 
        (base_min + sp * direct_coef + flat_direct_addition) * mod * target_vuln_mod * global_mod;
    local max_noncrit_if_hit = 
        (base_max + sp * direct_coef + flat_direct_addition) * mod * target_vuln_mod * global_mod;

    local min_crit_if_hit = min_noncrit_if_hit * crit_mod;
    local max_crit_if_hit = max_noncrit_if_hit * crit_mod;

    -- TODO: Looks like min is ceiled and max is floored
    --       do this until we know any better!

    --min_noncrit_if_hit = math.ceil(min_noncrit_if_hit);
    --max_noncrit_if_hit = math.ceil(max_noncrit_if_hit);

    --min_crit_if_hit = math.ceil(min_crit_if_hit);
    --max_crit_if_hit = math.ceil(max_crit_if_hit);
    
    local direct_crit = crit;
    if bit.band(spell_flags.absorb, spell_data.flags) ~= 0 then
        direct_crit = 0.0;
    end

    local min = hit * ((1 - direct_crit) * min_noncrit_if_hit + (direct_crit * min_crit_if_hit));
    local max = hit * ((1 - direct_crit) * max_noncrit_if_hit + (direct_crit * max_crit_if_hit));

    local absorb = 0.0;

    if spell_name == localized_spell_name("Fireball") then
        -- dont include dot for calcs
        base_ot = 0.0;
        base_dur = 0.0;
    end

    if base_ot > 0 then

        local base_ot_num_ticks = (ot_dur / ot_freq);
        local ot_coef_per_tick = ot_coef
        local base_ot_tick = base_ot / base_ot_num_ticks;

        ot_ticks = base_ot_num_ticks + ot_extra_ticks;

        ot = (base_ot_tick + ot_coef_per_tick * sp) * ot_ticks * ot_mod * target_vuln_mod * global_mod;

        if ot_crit > 0 then
            ot_if_crit = ot * crit_mod;
        else
            ot_if_crit = 0;
        end
    end

    local expectation_ot_if_hit = (1 - ot_crit) * ot + ot_crit * ot_if_crit;
    local expected_ot = hit * expectation_ot_if_hit;
    -- soul drain, life drain, mind flay are all directed casts that can only miss on the channel itself
    -- 1.5 sec gcd is always implied which is the only penalty for misses
    if spell_name == localized_spell_name("Drain Soul") or 
       spell_name == localized_spell_name("Drain Life") or
       spell_name == localized_spell_name("Mind Flay") or 
       spell_name == localized_spell_name("Starshards") then 

        local channel_ratio_time_lost_to_miss = 1 - (ot_dur - 1.5)/ot_dur;
        expected_ot = expectation_ot_if_hit - (1 - hit) * channel_ratio_time_lost_to_miss * expectation_ot_if_hit;
    end

    if class == "PRIEST" then
        local pts = 0;
        if spell_name == localized_spell_name("Renew") then
            pts = loadout.talents_table:pts(2, 23);
        elseif spell_name == localized_spell_name("Devouring Plague") then
            pts = 2 * loadout.talents_table:pts(3, 18);
        end

        if pts ~= 0 then
            local direct = pts * 0.05 * ot

            min_noncrit_if_hit = direct;
            max_noncrit_if_hit = direct;

            -- crit mod on direct devouring plague effect is always 1.5 even if specced into 2.0
            min_crit_if_hit = direct * 1.5;
            max_crit_if_hit = direct * 1.5;

            min = hit * ((1 - crit) * min_noncrit_if_hit + (crit * min_crit_if_hit));
            max = hit * ((1 - crit) * max_noncrit_if_hit + (crit * max_crit_if_hit));
        end
    end

    local expectation_direct = (min + max) / 2;

    if spell_name == localized_spell_name("Searing Totem") then
        expectation_direct = expectation_direct * ot_dur/ot_freq;
    end
      
    local expectation = expectation_direct + expected_ot;

    if loadout.ignite and loadout.ignite ~= 0 and spell_data.school == magic_school.fire then
        -- dont include dot for calcs
         local ignite_min = loadout.ignite * 0.08 * min_crit_if_hit;
         local ignite_max = loadout.ignite * 0.08 * max_crit_if_hit;
         expectation = expectation + hit * crit * (ignite_min + ignite_max)/2;
     end

    --if class == "MAGE" and base_min > 0 and loadout.num_set_pieces[set_tiers.pve_2] >= 8 then
    --    cast_time = cast_time - math.max(0, (cast_time - 1.5)) * 0.1;
    --end

    if loadout.improved_shadowbolt ~= 0 and spell_name == localized_spell_name("Shadow Bolt") then
        -- a reasonably good, generous estimate, 
        -- assumes all other warlocks in raid/party have same crit chance/improved shadowbolt talent
        -- and just spam shadow bolt allt fight, other abilities like shadowburn/mind blast will skew this estimate
        local sb_dmg_bonus = loadout.improved_shadowbolt * 0.04;
        local improved_sb_uptime = 1 - math.pow(1-crit, 4);
        local sb_dmg_taken_mod = sb_dmg_bonus * improved_sb_uptime;
        local new_vuln_mod = (target_vuln_mod + sb_dmg_taken_mod)/target_vuln_mod;

        expectation = expectation * new_vuln_mod;
    end

    local target_avg_resi = target_avg_magical_res(loadout.lvl, target_resi);
    expectation = expectation * (1 - target_avg_resi);

    local expectation_st = expectation;

    local special_abilities = {
        [localized_spell_name("Chain Heal")] = function()
            --if loadout.num_set_pieces[set_tiers.pve_2] >= 3 then
            --    expectation = (1 + 1.3*0.5 + 1.3*1.3*0.5*0.5) * expectation_st;
            --else
            expectation = (1 + 0.5 + 0.5*0.5) * expectation_st;
            --end
        end,
        [localized_spell_name("Healing Wave")] = function()
            --if loadout.num_set_pieces[set_tiers.pve_1] >= 8 then
            --    expectation = (1 + 0.2 + 0.2*0.2) * expectation_st;
            --end
        end,
        [localized_spell_name("Lightning Shield")] = function()
            expectation = 3 * expectation_st;
        end,
        [localized_spell_name("Prayer of Healing")] = function()

            if loadout.glyphs[57195] then
                expectation_st = expectation_st * 1.2;
                -- hot displayed specialized in tooltip section
            end
            expectation = 5 * expectation_st;
        end,
        [localized_spell_name("Circle of Healing")] = function()

            if loadout.glyphs[55675] then
                expectation = 6 * expectation_st;
            else
                expectation = 5 * expectation_st;
            end
        end,
        [localized_spell_name("Prayer of Mending")] = function()
            if loadout.num_set_pieces[set_tiers.pve_t7_1] and
                loadout.num_set_pieces[set_tiers.pve_t7_1] >= 2 then
                expectation = 6 * expectation_st;
            else
                expectation = 5 * expectation_st;
            end
        end,
        [localized_spell_name("Power Word: Shield")] = function()

           absorb = min_noncrit_if_hit;

            if loadout.glyphs[55672] then
                min_noncrit_if_hit = 0.2 * min_noncrit_if_hit;
                max_noncrit_if_hit = 0.2 * max_noncrit_if_hit;

                min_crit_if_hit = 0.2 * min_crit_if_hit;
                max_crit_if_hit = 0.2 * max_crit_if_hit;
                expectation_st = expectation_st * 1.2;
                expectation = expectation_st;
            else

                min_noncrit_if_hit = 0.0;
                max_noncrit_if_hit = 0.0;

                min_crit_if_hit = 0.0;
                max_crit_if_hit = 0.0;
            end
        end,
        [localized_spell_name("Holy Nova")] = function()
            if bit.band(spell_data.flags, spell_flags.heal) ~= 0 then
                expectation = 5 * expectation_st;
            end
        end,
        [localized_spell_name("Binding Heal")] = function()
            expectation = 2 * expectation_st;
        end,
        [localized_spell_name("Penance")] = function()
            expectation = 3 * expectation_st;
        end,
        [localized_spell_name("Lightwell")] = function()
            expectation = 10 * expectation_st;
        end,
        [localized_spell_name("Wild Growth")] = function()
            expectation = 5 * expectation_st;
        end,
        [localized_spell_name("Tranquility")] = function()
            expectation = 5 * expectation_st;
        end,
        [localized_spell_name("Chain Lightning")] = function()
            --if loadout.num_set_pieces[set_tiers.aq20] >= 3 then
            --    expectation = (1 + 0.75 + 0.75 * 0.75) * expectation_st;
            --else
            expectation = (1 + 0.7 + 0.7 * 0.7) * expectation_st;
            --end
        end,
    };

    if special_abilities[spell_name] then
        special_abilities[spell_name]();
    end

    if loadout.beacon then
        expectation = expectation * 2;
    end

    local effect_per_sec = expectation/cast_time;

    -- TODO: delete this?
    -- improved shadow bolt invuln mod has been ignored before for shadow bolt only
    -- and inserted now if relevant to show accurate dmg numbers
    -- expected dmg, dps, and stat weights still assume uptime based on crit instead of 100% uptime
    --if bit.band(target_debuffs1.improved_shadow_bolt.flag, loadout.target_debuffs1) ~= 0 and 
    --    (loadout.always_assume_buffs or 
    --    (loadout.target_debuffs[target_debuffs1.improved_shadow_bolt.id] and not loadout.target_friendly and loadout.has_target)) and 
    --    spell_name == localized_spell_name("Shadow Bolt") then

    --    local shadowbolt_vuln_mod = (target_vuln_mod + 0.2)/target_vuln_mod;

    --    min_noncrit_if_hit = min_noncrit_if_hit * shadowbolt_vuln_mod;
    --    max_noncrit_if_hit = max_noncrit_if_hit * shadowbolt_vuln_mod;

    --    min_crit_if_hit = min_crit_if_hit * shadowbolt_vuln_mod;
    --    max_crit_if_hit = max_crit_if_hit * shadowbolt_vuln_mod;
    --end
    --

    return {
        min_noncrit = min_noncrit_if_hit,
        max_noncrit = max_noncrit_if_hit,

        min_crit = min_crit_if_hit,
        max_crit = max_crit_if_hit,

        absorb = absorb,

        --including crit/hit
        expectation_direct = expectation_direct,

        ot_num_ticks = ot_ticks,
        ot_duration = ot_dur + ot_extra_ticks * ot_freq,
        ot_if_hit = ot,
        ot_crit_if_hit = ot_if_crit,
        ot = expected_ot,

        expectation = expectation,
        expectation_st = expectation_st,
        effect_per_sec = effect_per_sec,
        target_avg_resi = target_avg_resi,

        effect_per_cost = expectation/cost,
        cost_per_sec = cost / cast_time,

        cast_time = cast_time,

        cost = cost
    };
end

local function loadout_stats_for_spell(spell_data, spell_name, loadout)

    local crit = 0;
    local ot_crit = 0;
    local crit_delta_1 = 0;
    local ot_crit_delta_1 = 0;

    crit = loadout.spell_crit_by_school[spell_data.school];
    if not loadout.ability_crit[spell_name] then
        loadout.ability_crit[spell_name] = 0;
    end
    -- rating may come from diffed loadout
    local crit_rating_per_perc = get_combat_rating_effect(CR_CRIT_SPELL, loadout.lvl);
    local crit_from_rating = 0.01 * loadout.crit_rating/crit_rating_per_perc;
    crit = math.max(0.0, crit + loadout.ability_crit[spell_name] + crit_from_rating);
    crit_delta_1 = math.min(crit + 0.01/crit_rating_per_perc, 1.0);

    if bit.band(spell_data.flags, spell_flags.over_time_crit) ~= 0 then
        ot_crit = crit;
        ot_crit_delta_1 = crit_delta_1;
    end

    local spell_crit_mod = loadout.spell_crit_mod_by_school[spell_data.school];
    if not loadout.ability_crit_mod[spell_name] then
        loadout.ability_crit_mod[spell_name] = 0;
    end
    spell_crit_mod = spell_crit_mod + loadout.ability_crit_mod[spell_name];

    local target_vuln_mod = 1;
    local global_mod = loadout.gmod; 
    local spell_mod = 1;
    local spell_ot_mod = 1;
    local flat_addition = 0;
    local resource_refund = 0;

    if not loadout.ability_effect_mod[spell_name] then
        loadout.ability_effect_mod[spell_name] = 1.0;
    end

    -- regarding blessing of light effect
    if loadout.ability_flat_add[spell_name] and class == "PALADIN" then

        local scaling_coef_by_lvl = 1;
        if spell_data.lvl_req == 1 then -- rank 1 holy light
            scaling_coef_by_lvl = 0.2;
        elseif spell_data.lvl_req == 6 then -- rank 2 holy light
            scaling_coef_by_lvl = 0.4;
        elseif spell_data.lvl_req == 14 then -- rank 3 holy light
            scaling_coef_by_lvl = 0.7;
        end
        
        flat_addition = 
            flat_addition + loadout.ability_flat_add[spell_name] * scaling_coef_by_lvl;
    end

    local gcd = 1.0;

    if class == "DRUID" then
        local pts = loadout.talents_table:pts(3, 25);
        if pts ~= 0 then
            gcd = gcd - pts * 0.02;
        end

    end

    if class == "PRIEST" then
        if spell_name == localized_spell_name("Flash Heal") and loadout.friendly_hp_perc and loadout.friendly_hp_perc < 0.5  then
            local pts = loadout.talents_table:pts(1, 20);
            crit = crit + pts * 0.04;
        end
        -- test of faith
        if loadout.friendly_hp_perc and loadout.friendly_hp_perc < 0.5 then
            loadout.spell_heal_mod = loadout.spell_heal_mod + 0.04 * loadout.talents_table:pts(2, 25);
        end
        --shadow form
        local shadow_form, _, _, _, _, _, _ = GetSpellInfo(15473);
        if loadout.buffs[shadow_form] and
            (loadout.always_assume_buffs or loadout.dynamic_buffs["player"][shadow_form]) then
            if spell_data.base_min == 0.0 and ot_crit == 0.0  and bit.band(spell_data.flags, spell_flags.heal) == 0 then
                -- must be shadow word pain, devouring plague or vampiric touch
                ot_crit = crit;
                ot_crit_delta_1 = crit_delta_1;
                spell_crit_mod = 2.0;
            end
        end
        -- glyph of renew
        if spell_name == localized_spell_name("Renew") and loadout.glyphs[55674] then
            global_mod = global_mod * 1.25;
        end
    elseif  class == "DRUID" then

        --moonkin form
        local moonkin_form, _, _, _, _, _, _ = GetSpellInfo(24858);
        if loadout.buffs[moonkin_form] and
            (loadout.always_assume_buffs or loadout.dynamic_buffs["player"][moonkin_form]) then
            resource_refund = crit * 0.02 * loadout.max_mana;

        -- never mind ...this tick resource refund is only on target,... could apply if targeting self?
        --local pts = loadout.talents_table:pts(3, 22);
        --if (spell_name == localized_spell_name("Wild Growth") or spell_name == localized_spell_name("Rejuvenation"))
        --    and pts ~= 0 and bit.band(spell_data.flags, spell_flags.heal) ~= 0 then

        --    local refund_amount = 0.15 * loadout.max_mana * 0.01 * ot_ticks;
        --    if spell_name == localized_spell_name("Wild Growth") then
        --        refund_amount = refund_amount * 5;
        --    end
        --    cost = cost - refund_amount;
        --end
        --
        --improved insect swarm talent
        local insect_swarm = localized_spell_name("Insect Swarm");
        if loadout.target_buffs[insect_swarm] and
            (loadout.always_assume_buffs or loadout.dynamic_buffs["target"][insect_swarm]) then
            if spell_name == localized_spell_name("Wrath") then
                global_mod = global_mod + 0.01 * loadout.talents_table:pts(1, 14);
                --target_vuln_mod = target_vuln_mod * (1.0 + 0.01 * loadout.talents_table:pts(1, 14));
                --796
            end
        end
        
    elseif class == "PALADIN" and bit.band(spell_data.flags, spell_flags.heal) ~= 0 then
        -- illumination
        local pts = loadout.talents_table:pts(1, 7);

            local mana_refund = 0.3 * spell_data.cost_base_percent * base_mana_pool();
            resource_refund = crit * pts*0.2 * mana_refund;
        end
    end

    --if spell_name == localized_spell_name("Healing Touch") and loadout.num_set_pieces[set_tiers.pve_3] >= 8 then

    --    cost = cost - cost * crit * 0.3;
    --end


    --if loadout.master_of_elements ~= 0 and spell_data.base_min > 0 and
    --   (spell_data.school == magic_school.fire or spell_data.school == magic_school.frost) then

    --    cost = cost - cost * crit * (loadout.master_of_elements * 0.1);
    --end


    --TODO: wotlk haste, cast speed calculation is different
    -- so far it seems like gcd cap is 1.0 instead of 1.5?
    local cast_speed = spell_data.cast_time;
    if not loadout.ability_cast_mod[spell_name] then
        loadout.ability_cast_mod[spell_name] = 0;
    end
    cast_speed = cast_speed - loadout.ability_cast_mod[spell_name];

    -- nature's grace
    local pts = loadout.talents_table:pts(1, 7);
    if pts ~= 0 and class == "DRUID" and spell_data.base_min ~= 0 then
        cast_speed = cast_speed/(1.0 + pts * 0.2*crit/3);
    end

    --if loadout.natures_grace and loadout.natures_grace ~= 0  and cast_time > 1.5 and 
    --    spell_name ~= localized_spell_name("Tranquility") and spell_name ~= localized_spell_name("Hurricane") then
    --    local cast_reduction = 0.5;
    --    if cast_time - 1.5 < 0.5 then
    --        --cast_time is between ]1.5:2]
    --        -- partially account for natures grace as the cast is lower than 2 and natures grace doesnt ignore gcd
    --        cast_reduction = cast_time - 1.5; -- i.e. between [0:0.5]
    --    end
    --    cast_time = cast_time - cast_reduction * crit;
    --end

    -- apply global haste which has been multiplied at each step
    local haste_rating_per_perc = get_combat_rating_effect(CR_HASTE_SPELL, loadout.lvl);
    local haste_from_rating = 0.01 * max(0.0, loadout.haste_rating) / haste_rating_per_perc;

    local haste_mod_delta_1 = loadout.haste_mod * (1.0 + haste_from_rating + 0.01/haste_rating_per_perc);
    local haste_mod = loadout.haste_mod * (1.0 + haste_from_rating);

    cast_speed_haste_delta_1 = math.max(cast_speed/haste_mod_delta_1, gcd);
    cast_speed = math.max(cast_speed/haste_mod, gcd);


    -- delete this?
    --if spell_name == localized_spell_name("Shadow Bolt") and 
    --    bit.band(target_debuffs1.improved_shadow_bolt.flag, loadout.target_debuffs1) ~= 0 and 
    --    ((not loadout.target_friendly and loadout.has_target and loadout.target_debuffs[target_debuffs1.improved_shadow_bolt.id]) or 
    --    loadout.always_assume_buffs) then


    --    -- undo for shadow bolt in order to get real average stat weights for crit, which increases buff uptime
    --    loadout.target_spell_dmg_taken[magic_school.shadow] = 
    --        loadout.target_spell_dmg_taken[magic_school.shadow] - 0.2;
    --end
    -- multiplicitive vs additive can become an error here 
    if bit.band(spell_data.flags, spell_flags.heal) ~= 0 then

        target_vuln_mod = target_vuln_mod * (1.0 + loadout.target_healing_taken);
        spell_ot_mod =
            spell_mod
            *
            (loadout.ability_effect_mod[spell_name] + loadout.spell_heal_mod + loadout.ot_mod);
        spell_mod =
            spell_mod
            *
            (loadout.ability_effect_mod[spell_name] + loadout.spell_heal_mod);

    elseif bit.band(spell_data.flags, spell_flags.absorb) ~= 0 then

        -- TODO: looks like healing % from talents is added with twin disciples talent
        -- then multiplied by effect mod...
        --spell_mod = 1 + loadout.spell_heal_mod;
        spell_mod =
            spell_mod
            * 
            loadout.ability_effect_mod[spell_name]
            *
            (1.0 + loadout.spell_heal_mod);
    else 
        target_vuln_mod = target_vuln_mod * (1.0 + loadout.target_spell_dmg_taken[spell_data.school]);
        spell_ot_mod =
            spell_mod
            *
            (1 + loadout.spell_dmg_mod_by_school[spell_data.school])
            *
            (loadout.ability_effect_mod[spell_name] + loadout.dmg_mod + loadout.ot_mod);
        spell_mod = 
            spell_mod
            *
            (1 + loadout.spell_dmg_mod_by_school[spell_data.school])
            *
            (loadout.ability_effect_mod[spell_name] + loadout.dmg_mod);
    end


    local extra_hit = 0;
    if loadout.ability_hit[spell_name] then
        extra_hit = loadout.spell_dmg_hit_by_school[spell_data.school] + loadout.ability_hit[spell_name];
    else
        extra_hit = loadout.spell_dmg_hit_by_school[spell_data.school];
    end

    local hit_rating_per_perc = get_combat_rating_effect(CR_HIT_SPELL, loadout.lvl);
    local hit_from_rating = 0.01 * loadout.hit_rating/hit_rating_per_perc
    extra_hit = extra_hit + loadout.ability_crit[spell_name] + hit_from_rating;

    local hit = spell_hit(loadout.lvl, loadout.target_lvl, extra_hit);
    local hit_delta_1 = hit + 0.01/hit_rating_per_perc;
    if bit.band(spell_data.flags, spell_flags.heal) ~= 0 or bit.band(spell_data.flags, spell_flags.absorb) ~= 0 then
        hit = 1.0;
        hit_delta_1 = 1.0;
    else
        hit = math.min(0.99, hit);
        hit_delta_1 = math.min(0.99, hit_delta_1);
    end

    -- 
    local extra_ticks = loadout.ability_extra_ticks[spell_name];
    if not extra_ticks then
        extra_ticks = 0;
    end

    local spell_power = 0;
    if bit.band(spell_data.flags, spell_flags.heal) ~= 0 or bit.band(spell_data.flags, spell_flags.absorb) ~= 0 then
        spell_power = loadout.spell_power;
    else
        spell_power = loadout.spell_power + loadout.spell_dmg_by_school[spell_data.school];
    end

    if loadout.ability_sp[spell_name] then
        spell_power = spell_power + loadout.ability_sp[spell_name];
    end

    local target_resi = 0;
    if bit.band(spell_data.flags, spell_flags.heal) == 0 then
        -- mod res by school currently used to snapshot equipment and set bonuses
        target_resi = loadout.target_res_by_school[spell_data.school] + loadout.target_mod_res_by_school[spell_data.school];
    end

    local cost = spell_data.cost_base_percent * base_mana_pool();
    local cost_mod = 1 - loadout.cost_mod;

    if loadout.ability_cost_mod[spell_name] then
        cost_mod = cost_mod - loadout.ability_cost_mod[spell_name]
    end

    cost = cost * cost_mod;
    cost = cost - resource_refund;

    if loadout.ability_refund[spell_name] and loadout.ability_refund[spell_name] ~= 0 then

        local refund = loadout.ability_refund[spell_name];
        local max_rank = spell_data.rank;
        if spell_name == localized_spell_name("Lesser Healing Wave") then
            max_rank = 6;
        elseif spell_name == localized_spell_name("Healing Touch") then
            max_rank = 11;
        end

        coef_estimate = spell_data.rank/max_rank;

        cost = cost - refund*coef_estimate;
    end

    -- the game seems to round cost up/down to the nearest
    cost = tonumber(string.format("%.0f", cost));

    local lvl_scaling = level_scaling(loadout.lvl);
    local direct_coef = spell_data.coef * lvl_scaling;
    local over_time_coef = spell_data.over_time_coef *lvl_scaling;

    if loadout.ability_coef_mod[spell_name] then
        direct_coef = direct_coef + loadout.ability_coef_mod[spell_name];
    end
    if loadout.ability_coef_ot_mod[spell_name] then
        over_time_coef = over_time_coef * (1 + loadout.ability_coef_ot_mod[spell_name]);
    end


    return {
        extra_ticks = extra_ticks,
        cast_speed = cast_speed,
        cast_speed_haste_delta_1 = cast_speed_haste_delta_1,
        spell_power = spell_power,
        flat_direct_addition = flat_addition,
        crit = crit,
        crit_delta_1 = crit_delta_1,
        ot_crit = ot_crit,
        ot_crit_delta_1 = ot_crit_delta_1,
        spell_crit_mod = spell_crit_mod,
        hit = hit,
        hit_delta_1 = hit_delta_1,
        target_vuln_mod = target_vuln_mod,
        global_mod = global_mod,
        spell_mod = spell_mod,
        spell_ot_mod = spell_ot_mod,
        direct_coef = direct_coef,
        over_time_coef = over_time_coef,
        cost = cost,
        target_resi = target_resi
    };
end

local function spell_info_from_loadout_stats(spell_data, spell_name, loadout)

    local stats = loadout_stats_for_spell(spell_data, spell_name, loadout);

    return spell_info(
       spell_data, 
       stats.extra_ticks,
       stats.cast_speed,
       stats.spell_power,
       stats.flat_direct_addition,
       math.max(0, min(1, stats.crit)),
       math.max(0, min(1, stats.ot_crit)),
       stats.spell_crit_mod,
       stats.hit,
       math.max(0, stats.target_resi),
       stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_ot_mod,
       stats.direct_coef, stats.over_time_coef,
       stats.cost,
       spell_name, loadout
    );
end

local function evaluate_spell(stats, spell_data, spell_name, loadout)

    local spell_effect = spell_info(
       spell_data,
       stats.extra_ticks,
       stats.cast_speed,
       stats.spell_power,
       stats.flat_direct_addition,
       max(0, min(1, stats.crit)),
       max(0, min(1, stats.ot_crit)),
       stats.spell_crit_mod,
       stats.hit,
       math.max(0, stats.target_resi),
       stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_ot_mod,
       stats.direct_coef, stats.over_time_coef,
       stats.cost,
       spell_name, loadout
    );

    local spell_effect_extra_1sp = spell_info(
        spell_data,
        stats.extra_ticks,
        stats.cast_speed,
        stats.spell_power + 1,
        stats.flat_direct_addition,
        max(0, min(1, stats.crit)),
        max(0, min(1, stats.ot_crit)),
        stats.spell_crit_mod,
        stats.hit,
        math.max(0, stats.target_resi),
       stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_ot_mod,
        stats.direct_coef, stats.over_time_coef,
        stats.cost,
        spell_name, loadout
    );
    local spell_effect_extra_1crit = spell_info(
        spell_data,
        stats.extra_ticks,
        stats.cast_speed,
        stats.spell_power,
        stats.flat_direct_addition,
        max(0, min(1, stats.crit_delta_1)),
        max(0, min(1, stats.ot_crit_delta_1)),
        stats.spell_crit_mod,
        stats.hit,
        math.max(0, stats.target_resi),
       stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_ot_mod,
        stats.direct_coef, stats.over_time_coef,
        stats.cost,
        spell_name, loadout
    );
    local spell_effect_extra_1hit = spell_info(
        spell_data, 
        stats.extra_ticks,
        stats.cast_speed,
        stats.spell_power,
        stats.flat_direct_addition,
        max(0, min(1, stats.crit)),
        max(0, min(1, stats.ot_crit)),
        stats.spell_crit_mod,
        stats.hit_delta_1,
        math.max(0, stats.target_resi),
       stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_ot_mod,
        stats.direct_coef, stats.over_time_coef,
        stats.cost,
        spell_name, loadout
    );
    local spell_effect_extra_1haste = spell_info(
        spell_data, 
        stats.extra_ticks,
        stats.cast_speed_haste_delta_1,
        stats.spell_power,
        stats.flat_direct_addition,
        max(0, min(1, stats.crit)),
        max(0, min(1, stats.ot_crit)),
        stats.spell_crit_mod,
        stats.hit,
        math.max(0, stats.target_resi),
       stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_ot_mod,
        stats.direct_coef, stats.over_time_coef,
        stats.cost,
        spell_name, loadout
    );

    local spell_effect_extra_1_target_resi = spell_info(
        spell_data, 
        stats.extra_ticks,
        stats.cast_speed,
        stats.spell_power,
        stats.flat_direct_addition,
        max(0, min(1, stats.crit)),
        max(0, min(1, stats.ot_crit)),
        stats.spell_crit_mod,
        stats.hit,
        math.max(0, stats.target_resi - 1),
       stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_ot_mod,
        stats.direct_coef, stats.over_time_coef,
        stats.cost,
        spell_name, loadout
    );

    local spell_effect_per_sec_1sp_delta = spell_effect_extra_1sp.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1crit_delta = spell_effect_extra_1crit.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1hit_delta = spell_effect_extra_1hit.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1haste_delta = spell_effect_extra_1haste.effect_per_sec - spell_effect.effect_per_sec;
    local spell_effect_per_sec_1target_resi_delta = spell_effect_extra_1_target_resi.effect_per_sec - spell_effect.effect_per_sec;

    local sp_per_crit = spell_effect_per_sec_1crit_delta/(spell_effect_per_sec_1sp_delta);
    local sp_per_hit = spell_effect_per_sec_1hit_delta/(spell_effect_per_sec_1sp_delta);
    local sp_per_haste = spell_effect_per_sec_1haste_delta/(spell_effect_per_sec_1sp_delta);
    local sp_per_target_resi = spell_effect_per_sec_1target_resi_delta/(spell_effect_per_sec_1sp_delta);

    return {
        effect_per_sec_per_sp = spell_effect_per_sec_1sp_delta,
        sp_per_crit = sp_per_crit,
        sp_per_hit = sp_per_hit,
        sp_per_haste = sp_per_haste,
        sp_per_target_resi = sp_per_target_resi,

        spell_data = spell_effect,
        spell_data_1_sp = spell_effect_extra_1sp,
        spell_data_1_crit = spell_effect_extra_1crit,
        spell_data_1_hit = spell_effect_extra_1hit,
        spell_data_1_haste = spell_effect_extra_1haste,
        spell_data_1_target_resi = spell_effect_extra_1_target_resi
    };
end

local function cast_until_oom_sim(spell_effect, mp5, spirit, int, mana, loadout)

    local num_casts = 0;
    local effect = 0;

    -- src: https://wowwiki-archive.fandom.com/wiki/Spirit
    local mp1_not_casting = 0.2 * mana_regen_per_5(int, spirit, loadout.lvl);
    local mp1_casting = 0.2 * (0.05 * base_mana_pool() + mp5) + mp1_not_casting * loadout.regen_while_casting;

    local resource_loss_per_sec = spell_effect.cost/spell_effect.cast_time - mp1_casting;

    if resource_loss_per_sec <= 0 then
        -- divide by 0 party!
        return {
            num_casts = 1/0,
            effect = 1/0,
            time_until_oom = 1/0,
            mp1 = mp1_casting

        };
    end

    local time_until_oom = mana/resource_loss_per_sec; 
    local num_casts = time_until_oom/spell_effect.cast_time;
    local effect_until_oom = num_casts * spell_effect.expectation;
    
    return {
        num_casts = num_casts,
        effect = effect_until_oom,
        time_until_oom = time_until_oom,
        mp1 = mp1_casting
    };
end

local function cast_until_oom_sim_default(spell_effect, loadout)

    return cast_until_oom_sim(
        spell_effect, loadout.mp5, loadout.stats[stat.spirit], loadout.stats[stat.int],
        loadout.mana + loadout.extra_mana, loadout
    );
end

local function cast_until_oom_stat_weights(
        stats, spell_data, spell_name, 
        spell_effect_normal, spell_effect_1_sp, spell_effect_1_crit, spell_effect_1_hit, spell_effect_1_haste, spell_effect_1_target_resi, loadout)

    local until_oom_normal = 
        cast_until_oom_sim(spell_effect_normal, loadout.mp5, loadout.stats[stat.spirit], loadout.stats[stat.int], loadout.mana + loadout.extra_mana, loadout);
    local until_oom_1_sp = 
        cast_until_oom_sim(spell_effect_1_sp, loadout.mp5, loadout.stats[stat.spirit], loadout.stats[stat.int], loadout.mana + loadout.extra_mana, loadout);
    local until_oom_1_crit = 
        cast_until_oom_sim(spell_effect_1_crit, loadout.mp5, loadout.stats[stat.spirit], loadout.stats[stat.int], loadout.mana + loadout.extra_mana, loadout);
    local until_oom_1_hit = 
        cast_until_oom_sim(spell_effect_1_hit, loadout.mp5, loadout.stats[stat.spirit], loadout.stats[stat.int], loadout.mana + loadout.extra_mana, loadout);
    local until_oom_1_haste = 
        cast_until_oom_sim(spell_effect_1_haste, loadout.mp5, loadout.stats[stat.spirit], loadout.stats[stat.int], loadout.mana + loadout.extra_mana, loadout);
    local until_oom_1_target_resi = 
        cast_until_oom_sim(spell_effect_1_target_resi, loadout.mp5, loadout.stats[stat.spirit], loadout.stats[stat.int], loadout.mana + loadout.extra_mana, loadout);
    local until_oom_1_mp5 = 
        cast_until_oom_sim(spell_effect_normal, loadout.mp5 + 1, loadout.stats[stat.spirit], loadout.stats[stat.int], loadout.mana + loadout.extra_mana, loadout);

    local loadout_1_spirit = empty_loadout();
    loadout_1_spirit.stats[stat.spirit] = 1;
    local loadout_added_1_spirit = loadout_add(loadout, loadout_1_spirit);
    local stats_1_spirit_added = loadout_stats_for_spell(spell_data, spell_name, loadout_added_1_spirit);
    local added_1_spirit_effect = spell_info(
       spell_data,
       stats.extra_ticks,
       stats_1_spirit_added.cast_speed,
       stats_1_spirit_added.spell_power,
       stats_1_spirit_added.flat_direct_addition,
       max(0, min(1, stats_1_spirit_added.crit)),
       max(0, min(1, stats_1_spirit_added.ot_crit)),
       stats_1_spirit_added.spell_crit_mod,
       stats_1_spirit_added.hit,
       max(0, stats_1_spirit_added.target_resi),
       stats_1_spirit_added.target_vuln_mod, 
       stats_1_spirit_added.global_mod, 
       stats_1_spirit_added.spell_mod, 
       stats_1_spirit_added.spell_ot_mod, 
       stats_1_spirit_added.direct_coef, 
       stats_1_spirit_added.over_time_coef,
       stats_1_spirit_added.cost,
       spell_name, loadout_added_1_spirit
    );

    local until_oom_1_spirit = cast_until_oom_sim(
        added_1_spirit_effect, 
        loadout_added_1_spirit.mp5, 
        loadout_added_1_spirit.stats[stat.spirit], 
        loadout_added_1_spirit.stats[stat.int], 
        loadout_added_1_spirit.mana + loadout.extra_mana, 
        loadout_added_1_spirit);

    local loadout_1_int = empty_loadout();
    loadout_1_int.stats[stat.int] = 1;

    local loadout_added_1_int = loadout_add(loadout, loadout_1_int);
    local stats_1_int_added = loadout_stats_for_spell(spell_data, spell_name, loadout_added_1_int);
    local added_1_int_effect = spell_info(
       spell_data,
       stats.extra_ticks,
       stats_1_int_added.cast_speed,
       stats_1_int_added.spell_power,
       stats_1_int_added.flat_direct_addition,
       max(0, min(1, stats_1_int_added.crit)),
       max(0, min(1, stats_1_int_added.ot_crit)),
       stats_1_int_added.spell_crit_mod,
       stats_1_int_added.hit,
       max(0, stats_1_int_added.target_resi),
       stats_1_int_added.target_vuln_mod, 
       stats_1_int_added.global_mod, 
       stats_1_int_added.spell_mod, 
       stats_1_spirit_added.spell_ot_mod, 
       stats_1_int_added.direct_coef, 
       stats_1_int_added.over_time_coef,
       stats_1_int_added.cost,
       spell_name, loadout_added_1_int
    );

    local until_oom_1_int = cast_until_oom_sim(
        added_1_int_effect, 
        loadout_added_1_int.mp5, 
        loadout_added_1_int.stats[stat.spirit], 
        loadout_added_1_int.stats[stat.int], 
        loadout_added_1_int.mana + loadout.extra_mana,
        loadout_added_1_int);

    local diff_1_sp = until_oom_1_sp.effect - until_oom_normal.effect;
    local diff_1_crit = until_oom_1_crit.effect - until_oom_normal.effect;
    local diff_1_hit = until_oom_1_hit.effect - until_oom_normal.effect;
    local diff_1_haste = until_oom_1_haste.effect - until_oom_normal.effect;
    local diff_1_target_resi = until_oom_1_target_resi.effect - until_oom_normal.effect;
    local diff_1_mp5 = until_oom_1_mp5.effect - until_oom_normal.effect;
    local diff_1_spirit = until_oom_1_spirit.effect - until_oom_normal.effect;
    local diff_1_int = until_oom_1_int.effect - until_oom_normal.effect;

    local sp_per_crit = diff_1_crit/diff_1_sp;
    local sp_per_hit = diff_1_hit/diff_1_sp;
    local sp_per_haste = diff_1_haste/diff_1_sp;
    local sp_per_target_resi = diff_1_target_resi/diff_1_sp;
    local sp_per_mp5 = diff_1_mp5/diff_1_sp;
    local sp_per_spirit = diff_1_spirit/diff_1_sp;
    local sp_per_int = diff_1_int/diff_1_sp;

    return {
        effect_per_1_sp = diff_1_sp,

        sp_per_crit = sp_per_crit,
        sp_per_hit = sp_per_hit,
        sp_per_haste = sp_per_haste,
        sp_per_target_resi = sp_per_target_resi,
        sp_per_mp5 = sp_per_mp5,
        sp_per_spirit = sp_per_spirit,
        sp_per_int = sp_per_int,

        normal = until_oom_normal,
    };
end


local function tooltip_spell_info(tooltip, spell, spell_name, loadout)

    if spell then

        if sw_frame.settings_frame.tooltip_num_checked == 0 or 
            (sw_frame.settings_frame.show_tooltip_only_when_shift and not IsShiftKeyDown()) then
            return;
        end

        local stats = loadout_stats_for_spell(spell, spell_name, loadout); 
        local eval = evaluate_spell(stats, spell, spell_name, loadout);

        local cast_til_oom = cast_until_oom_stat_weights(
          stats, spell, spell_name, 
          eval.spell_data, eval.spell_data_1_sp, eval.spell_data_1_crit, eval.spell_data_1_hit, eval.spell_data_1_haste, eval.spell_data_1_target_resi, 
          loadout
        );

        local effect = "";
        local effect_per_sec = "";
        local effect_per_cost = "";
        local effect_per_sec_per_sp = "";
        local sp_name = "";

        -- TODO: might want to separate dps and dmg per execution time for clarity
        if bit.band(spell.flags, spell_flags.heal) ~= 0 or bit.band(spell.flags, spell_flags.absorb) ~= 0 then
            effect = "Heal";
            effect_per_sec = "HPS (by execution time)";
            effect_per_cost = "Heal per Mana";
            cost_per_sec = "Mana per sec";
            effect_per_sec_per_sp = "HPS per spell power";
            sp_name = "Spell power";
        else
            effect = "Damage";
            effect_per_sec = "DPS (by execution time)";
            effect_per_cost = "Damage per Mana";
            cost_per_sec = "Mana per sec";
            effect_per_sec_per_sp = "DPS per spell power";
            sp_name = "Spell power";
        end

        begin_tooltip_section(tooltip);

        tooltip:AddLine("Stat Weights Classic", 1, 1, 1);

        if loadout.lvl > spell.lvl_max and not __sw__debug__ then
            tooltip:AddLine("Ability downranking is not optimal in WOTLK! At your level a new rank is available. ", 252.0/255, 69.0/255, 3.0/255);
            end_tooltip_section(tooltip);
            return;
        end 

        local loadout_type = "";
        if loadout.is_dynamic_loadout then
            loadout_type = "dynamic";
        else
            loadout_type = "static";
        end
        if bit.band(spell.flags, spell_flags.heal) ~= 0 or bit.band(spell.flags, spell_flags.absorb) ~= 0 then
            tooltip:AddLine(string.format("Active Loadout (%s): %s", loadout_type, loadout.name), 1, 1,1);
        else
            tooltip:AddLine(string.format("Active Loadout (%s): %s - Target lvl %d", loadout_type, loadout.name, loadout.target_lvl), 1, 1, 1);
        end
        if eval.spell_data.min_noncrit + eval.spell_data.absorb ~= 0 then
            if sw_frame.settings_frame.tooltip_normal_effect:GetChecked() then
                if eval.spell_data.min_noncrit ~= eval.spell_data.max_noncrit then
                    -- dmg spells with real direct range
                    if stats.hit ~= 1 then
                        if spell_name == localized_spell_name("Searing Totem") then
                            local num_ticks = spell.over_time_duration/spell.over_time_tick_freq;
                            tooltip:AddLine(
                                string.format("Normal %s (%.1f%% hit): %d over %d sec (%d-%d per tick for %d ticks)", 
                                              effect, 
                                              stats.hit*100,
                                              (eval.spell_data.min_noncrit + eval.spell_data.max_noncrit)*num_ticks/2,
                                              spell.over_time_duration,
                                              math.floor(eval.spell_data.min_noncrit), 
                                              math.ceil(eval.spell_data.max_noncrit),
                                              num_ticks),
                                232.0/255, 225.0/255, 32.0/255);
                        else
                            tooltip:AddLine(string.format("Normal %s (%.1f%% hit): %d-%d", 
                                                           effect, 
                                                           stats.hit*100,
                                                           math.floor(eval.spell_data.min_noncrit), 
                                                           math.ceil(eval.spell_data.max_noncrit)),
                                             232.0/255, 225.0/255, 32.0/255);
                        end
                    -- heal spells with real direct range
                    else
                        tooltip:AddLine(string.format("Normal %s: %d-%d", 
                                                      effect, 
                                                      math.floor(eval.spell_data.min_noncrit), 
                                                      math.ceil(eval.spell_data.max_noncrit)),
                                        232.0/255, 225.0/255, 32.0/255);

                        if spell_name == localized_spell_name("Prayer of Healing") and loadout.glyphs[57195] then
                            tooltip:AddLine(string.format("        and %d-%d over %d sec (%d-%d per tick for %d ticks)", 
                                                          math.floor(0.2*eval.spell_data.min_noncrit),
                                                          math.ceil(0.2*eval.spell_data.max_noncrit),
                                                          6,
                                                          math.floor(0.2*eval.spell_data.min_noncrit/6),
                                                          math.ceil(0.2*eval.spell_data.max_noncrit/6),
                                                          6),
                                            232.0/255, 225.0/255, 32.0/255);
                        end
                    end
                else
                    if stats.hit ~= 1 then
                        tooltip:AddLine(string.format("Normal %s (%.1f%% hit): %d", 
                                                      effect,
                                                      stats.hit*100,
                                                      math.floor(eval.spell_data.min_noncrit)),
                                                      --string.format("%.0f", eval.spell_data.min_noncrit)),
                                        232.0/255, 225.0/255, 32.0/255);
                    else
                        if eval.spell_data.absorb ~= 0 then
                            tooltip:AddLine(string.format("Absorb: %d", 
                                                          math.floor(eval.spell_data.absorb)),
                                            232.0/255, 225.0/255, 32.0/255);
                        end
                        if eval.spell_data.min_noncrit ~= 0 then
                            tooltip:AddLine(string.format("Normal %s: %d", 
                                                          effect,
                                                          math.floor(eval.spell_data.min_noncrit)),
                                                          --string.format("%.0f", eval.spell_data.min_noncrit)),
                                            232.0/255, 225.0/255, 32.0/255);
                        end
                    end

                end
            end
            if sw_frame.settings_frame.tooltip_crit_effect:GetChecked() then
                if stats.crit ~= 0 then
                    if loadout.ignite ~= 0 and eval.spell_data.ignite_min > 0 then
                        local ignite_min = loadout.ignite * 0.08 * eval.spell_data.min_crit;
                        local ignite_max = loadout.ignite * 0.08 * eval.spell_data.max_crit;
                        tooltip:AddLine(string.format("Critical %s (%.2f%% crit): %d-%d (ignites for %d-%d)", 
                                                      effect, 
                                                      stats.crit*100, 
                                                      math.floor(eval.spell_data.min_crit), 
                                                      math.ceil(eval.spell_data.max_crit),
                                                      math.floor(ignite_min), 
                                                      math.ceil(ignite_max)),
                                       252.0/255, 69.0/255, 3.0/255);


                    -- divine aegis
                    elseif class == "PRIEST" and bit.band(spell_flags.heal, spell.flags) ~= 0 and eval.spell_data.min_crit ~= 0 and loadout.talents_table:pts(1, 24) ~= 0 then
                        local pts = loadout.talents_table:pts(1, 24)
                        local min_crit = eval.spell_data.min_crit/(1 + pts * 0.1);
                        local max_crit = eval.spell_data.max_crit/(1 + pts * 0.1);
                        local absorb_min = pts * 0.1 * min_crit;
                        local absorb_max = pts * 0.1 * max_crit;
                        tooltip:AddLine(string.format("Critical %s (%.2f%% crit): %d-%d (absorbs %d-%d)", 
                                                      effect, 
                                                      stats.crit*100, 
                                                      math.floor(min_crit), 
                                                      math.ceil(max_crit),
                                                      math.floor(absorb_min), 
                                                      math.ceil(absorb_max)),
                                       252.0/255, 69.0/255, 3.0/255);

                        if spell_name == localized_spell_name("Prayer of Healing") and loadout.glyphs[57195] then
                            tooltip:AddLine(string.format("        and %d-%d over %d sec (%d-%d per tick for %d ticks)", 
                                                          math.floor(0.2*min_crit), 
                                                          math.ceil(0.2*max_crit),
                                                          6,
                                                          math.floor(0.2*min_crit/6), 
                                                          math.ceil(0.2*max_crit/6),
                                                          6),
                                           252.0/255, 69.0/255, 3.0/255);
                        end
                    -- living seeds
                    elseif class == "DRUID" and bit.band(spell_flags.heal, spell.flags) ~= 0 and eval.spell_data.min_crit ~= 0 and loadout.talents_table:pts(3, 21) ~= 0 then
                        local pts = loadout.talents_table:pts(3, 21)
                        local min_crit = eval.spell_data.min_crit/(1 + pts * 0.1);
                        local max_crit = eval.spell_data.max_crit/(1 + pts * 0.1);
                        local seed_min = pts * 0.1 * min_crit;
                        local seed_max = pts * 0.1 * max_crit;
                        tooltip:AddLine(string.format("Critical %s (%.2f%% crit): %d-%d (seeds %d-%d)", 
                                                      effect, 
                                                      stats.crit*100, 
                                                      math.floor(min_crit), 
                                                      math.ceil(max_crit),
                                                      math.floor(seed_min), 
                                                      math.ceil(seed_max)),
                                       252.0/255, 69.0/255, 3.0/255);

                    elseif spell_name == localized_spell_name("Searing Totem") then
                        local num_ticks = spell.over_time_duration/spell.over_time_tick_freq;
                        tooltip:AddLine(
                            string.format("Critical %s (%.2f%% crit): %d over %d sec (%d-%d per tick for %d ticks)", 
                                          effect, 
                                          stats.crit*100, 
                                          (eval.spell_data.min_crit + eval.spell_data.max_crit)*num_ticks/2,
                                          spell.over_time_duration,
                                          math.floor(eval.spell_data.min_crit), 
                                          math.ceil(eval.spell_data.max_crit),
                                          num_ticks),
                            252.0/255, 69.0/255, 3.0/255);
                    elseif eval.spell_data.min_crit ~= 0 then
                        tooltip:AddLine(string.format("Critical %s (%.2f%% crit): %d-%d", 
                                                      effect, 
                                                      stats.crit*100, 
                                                      math.floor(eval.spell_data.min_crit), 
                                                      math.ceil(eval.spell_data.max_crit)),
                                       252.0/255, 69.0/255, 3.0/255);
                    end

                end
            end
        end


        if eval.spell_data.ot_if_hit ~= 0 and sw_frame.settings_frame.tooltip_normal_ot:GetChecked() then

            -- round over time num for niceyness
            local ot = tonumber(string.format("%.0f", eval.spell_data.ot_if_hit));

            if stats.hit ~= 1 then
                if spell_name == localized_spell_name("Curse of Agony") then
                    tooltip:AddLine(string.format("%s (%.1f%% hit): %d over %.1f sec (%.0f-%.0f-%.0f per tick for %d ticks)",
                                                  effect,
                                                  stats.hit * 100,
                                                  eval.spell_data.ot_if_hit, 
                                                  eval.spell_data.ot_duration, 
                                                  eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks * 0.6,
                                                  eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks,
                                                  eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks * 1.4,
                                                  eval.spell_data.ot_num_ticks), 
                                    232.0/255, 225.0/255, 32.0/255);
                else
                    tooltip:AddLine(string.format("%s (%.1f%% hit): %d over %.1f sec (%d-%d per tick for %d ticks)",
                                                  effect,
                                                  stats.hit * 100,
                                                  eval.spell_data.ot_if_hit, 
                                                  eval.spell_data.ot_duration, 
                                                  math.floor(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks),
                                                  math.ceil(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks),
                                                  eval.spell_data.ot_num_ticks), 
                                    232.0/255, 225.0/255, 32.0/255);
                end
                

            else
                -- wild growth
                if spell_name == localized_spell_name("Wild Growth") then
                    tooltip:AddLine(string.format("%s: %d over %d sec (%d, %d, %d, %d, %d, %d, %d ticks)",
                                                  effect,
                                                  eval.spell_data.ot_if_hit, 
                                                  eval.spell_data.ot_duration, 
                                                  math.floor(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks * (1.0 + 0.09245475363 *  3) + 0.5),
                                                  math.floor(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks * (1.0 + 0.09245475363 *  2) + 0.5),
                                                  math.floor(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks * (1.0 + 0.09245475363 *  1) + 0.5),
                                                  math.floor(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks * (1.0 + 0.09245475363 *  0) + 0.5),
                                                  math.floor(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks * (1.0 + 0.09245475363 * -1) + 0.5),
                                                  math.floor(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks * (1.0 + 0.09245475363 * -2) + 0.5),
                                                  math.floor(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks * (1.0 + 0.09245475363 * -3) + 0.5)
                                                  ), 
                                    232.0/255, 225.0/255, 32.0/255);
                else
                     tooltip:AddLine(string.format("%s: %d over %.1f sec (%d-%d per tick for %d ticks)",
                                                   effect,
                                                   eval.spell_data.ot_if_hit, 
                                                   eval.spell_data.ot_duration, 
                                                   math.floor(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks),
                                                   math.ceil(eval.spell_data.ot_if_hit/eval.spell_data.ot_num_ticks),
                                                   eval.spell_data.ot_num_ticks), 
                                    232.0/255, 225.0/255, 32.0/255);
                end
            end

            if eval.spell_data.ot_crit_if_hit ~= 0.0 and 
               sw_frame.settings_frame.tooltip_crit_ot:GetChecked() then
                -- over time can crit (e.g. arcane missiles)
                tooltip:AddLine(string.format("Critical %s (%.2f%% crit): %d over %d sec (%d-%d per tick for %d ticks)",
                                              effect,
                                              stats.crit*100, 
                                              eval.spell_data.ot_crit_if_hit, 
                                              eval.spell_data.ot_duration, 
                                              math.floor(eval.spell_data.ot_crit_if_hit/eval.spell_data.ot_num_ticks),
                                              math.ceil(eval.spell_data.ot_crit_if_hit/eval.spell_data.ot_num_ticks),
                                              eval.spell_data.ot_num_ticks), 
                           252.0/255, 69.0/255, 3.0/255);
                    
            end
        end


        
      if sw_frame.settings_frame.tooltip_expected_effect:GetChecked() then

        -- show avg target magical resi if present
        if stats.target_resi > 0 then
            tooltip:AddLine(string.format("Target resi: %d with average %.2f%% resists",
                                          stats.target_resi,
                                          eval.spell_data.target_avg_resi * 100
                                          ), 
                          232.0/255, 225.0/255, 32.0/255);
        end

        local effect_extra_str = "";
        if loadout.ignite ~= 0 then
            if spell_name == localized_spell_name("Fireball") then
                effect_extra_str = " (ignite)";
            elseif spell_name == localized_spell_name("Pyroblast") then
                effect_extra_str = " (ignite & pyro dot)";
            else
                effect_extra_str = " (ignite)";
            end
        else
            if spell_name == localized_spell_name("Fireball") then
                effect_extra_str = " (excl: fireball dot)";
            elseif spell_name == localized_spell_name("Pyroblast") then
                effect_extra_str = " (pyro dot)";
            end
        end
        if loadout.improved_shadowbolt ~= 0 and spell_name == localized_spell_name("Shadow Bolt") then
            effect_extra_str = string.format(" (incl: %.1f%% improved shadow bolt uptime)", 
                                             100*(1 - math.pow(1-stats.crit, 4)));
        end
        if loadout.natures_grace and loadout.natures_grace ~= 0 and eval.spell_data.cast_time > 1.5 then
            effect_extra_str = " (nature's grace)";
        end

        if spell_name == localized_spell_name("Prayer of Healing") or 
           spell_name == localized_spell_name("Chain Heal") or 
           spell_name == localized_spell_name("Chain Heal") or 
           spell_name == localized_spell_name("Tranquility") then

            effect_extra_str = "";
        elseif bit.band(spell.flags, spell_flags.aoe) ~= 0 and 
                eval.spell_data.expectation == eval.spell_data.expectation_st then
            effect_extra_str = "(single effect)";
        end


        tooltip:AddLine("Expected "..effect..string.format(": %.1f ",eval.spell_data.expectation)..effect_extra_str,
                        255.0/256, 128.0/256, 0);

        if eval.spell_data.base_min ~= 0.0 and eval.spell_data.expectation ~=  eval.spell_data.expectation_st then

          tooltip:AddLine("Expected "..effect..string.format(": %.1f",eval.spell_data.expectation_st).." (incl: single effect)",
                          255.0/256, 128.0/256, 0);
        end
      end

      tooltip:AddLine("Scenario: Repeated casts", 1, 1, 1);
      if sw_frame.settings_frame.tooltip_effect_per_sec:GetChecked() then
        tooltip:AddLine(string.format("%s: %.1f", 
                                      effect_per_sec,
                                      eval.spell_data.effect_per_sec),
                        255.0/256, 128.0/256, 0);
      end
      if sw_frame.settings_frame.tooltip_effect_per_cost:GetChecked() then
        tooltip:AddLine(effect_per_cost..": "..string.format("%.1f",eval.spell_data.effect_per_cost), 0.0, 1.0, 1.0);
      end
      if sw_frame.settings_frame.tooltip_cost_per_sec:GetChecked() then
        tooltip:AddLine(cost_per_sec.." burn: "..string.format("%.1f",eval.spell_data.cost_per_sec), 0.0, 1.0, 1.0);
        tooltip:AddLine(cost_per_sec.." gain: "..string.format("%.1f",cast_til_oom.normal.mp1), 0.0, 1.0, 1.0);
      end

      if sw_frame.settings_frame.tooltip_stat_weights:GetChecked() then
        tooltip:AddLine(effect_per_sec_per_sp..": "..string.format("%.3f",eval.effect_per_sec_per_sp), 0.0, 1.0, 0.0);
        tooltip:AddLine(sp_name.." per Critical rating: "..string.format("%.3f",eval.sp_per_crit), 0.0, 1.0, 0.0);
        tooltip:AddLine(sp_name.." per Haste rating: "..string.format("%.3f",eval.sp_per_haste), 0.0, 1.0, 0.0);

        if (bit.band(spell.flags, spell_flags.heal) == 0 and bit.band(spell.flags, spell_flags.absorb) == 0) then
            tooltip:AddLine(sp_name.." per Hit rating: "..string.format("%.3f",eval.sp_per_hit), 0.0, 1.0, 0.0);
        end
      end

      if sw_frame.settings_frame.tooltip_cast_until_oom:GetChecked() and
          bit.band(spell.flags, spell_flags.cd) == 0 then
        tooltip:AddLine("Scenario: Cast until OOM", 1, 1, 1);

        tooltip:AddLine("Time until OOM "..string.format("%.1f sec",cast_til_oom.normal.time_until_oom));
        tooltip:AddLine(effect.." until OOM: "..string.format("%.1f",cast_til_oom.normal.effect));
        tooltip:AddLine("Casts until OOM: "..string.format("%.1f",cast_til_oom.normal.num_casts));
        --tooltip:AddLine("Effect per 1 sp: "..string.format("%.3f",cast_til_oom.effect_per_1_sp), 0.0, 1.0, 0.0);
        --tooltip:AddLine("Spell power per 1% crit: "..string.format("%.2f",cast_til_oom.sp_per_crit), 0.0, 1.0, 0.0);
        --if cast_til_oom.sp_per_hit ~= 0 then
        --    tooltip:AddLine("Spell power per 1% hit: "..string.format("%.2f",cast_til_oom.sp_per_hit), 0.0, 1.0, 0.0);
        --end
        tooltip:AddLine(sp_name.." per MP5: "..string.format("%.3f",cast_til_oom.sp_per_mp5), 0.0, 1.0, 0.0);
        tooltip:AddLine(sp_name.." per Spirit: "..string.format("%.3f",cast_til_oom.sp_per_spirit), 0.0, 1.0, 0.0);
        tooltip:AddLine(sp_name.." per Intellect: "..string.format("%.3f",cast_til_oom.sp_per_int), 0.0, 1.0, 0.0);
        tooltip:AddLine(sp_name.." per Critical rating: "..string.format("%.3f",cast_til_oom.sp_per_crit), 0.0, 1.0, 0.0);
        tooltip:AddLine(sp_name.." per Haste rating: "..string.format("%.3f",cast_til_oom.sp_per_haste), 0.0, 1.0, 0.0);
        if (bit.band(spell.flags, spell_flags.heal) == 0 and bit.band(spell.flags, spell_flags.absorb) == 0) then
            tooltip:AddLine(sp_name.." per Hit rating: "..string.format("%.3f",cast_til_oom.sp_per_hit), 0.0, 1.0, 0.0);
        end
      end

      if sw_frame.settings_frame.tooltip_coef:GetChecked() then
          tooltip:AddLine(string.format("Coefficient direct: %.3f", stats.direct_coef), 232.0/255, 225.0/255, 32.0/255);
          tooltip:AddLine(string.format("Coefficient over time: %.3f", stats.over_time_coef), 232.0/255, 225.0/255, 32.0/255);
      end
      if sw_frame.settings_frame.tooltip_avg_cast:GetChecked() then

          tooltip:AddLine(string.format("Average cast time: %.3f sec", eval.spell_data.cast_time), 232.0/255, 225.0/255, 32.0/255);
      end
      if sw_frame.settings_frame.tooltip_avg_cost:GetChecked() then
          tooltip:AddLine(string.format("Average cost: %.1f",eval.spell_data.cost), 232.0/255, 225.0/255, 32.0/255);
      end

      -- debug tooltip stuff
      if __sw__debug__ then
          tooltip:AddLine("Base "..effect..": "..spell.base_min.."-"..spell.base_max);
          tooltip:AddLine("Base "..effect..": "..spell.over_time);
          tooltip:AddLine(
            string.format("Stats: sp %d, crit %.4f, crit_mod %.4f, hit %.4f, vuln_mod %.4f, gmod %.4f, mod %.4f, ot_mod %.4f, flat add %.4f, cost %f, cast %f, coef %f, %f",
                          stats.spell_power,
                          stats.crit,
                          stats.spell_crit_mod,
                          stats.hit,
                          stats.target_vuln_mod,
                          stats.global_mod,
                          stats.spell_mod,
                          stats.spell_ot_mod,
                          stats.flat_direct_addition,
                          eval.spell_data.cost,
                          eval.spell_data.cast_time,
                          stats.direct_coef,
                          stats.over_time_coef

            
          ));
      end


      end_tooltip_section(tooltip);

      if spell.healing_version then
          -- used for holy nova
          tooltip_spell_info(tooltip, spell.healing_version, spell_name, loadout);
      end
    end
end

local function print_spell(spell, spell_name, loadout)

    if spell then

        local stats = loadout_stats_for_spell(spell, spell_name, loadout); 
        local eval = evaluate_spell(stats, spell, spell_name, loadout);
        
        print(string.format("Base spell: min %d, max %d, ot %d, ot_freq %d, ot_dur %d, cast %.3f, rank %d, lvl_req %d, flags %d, school %d, direct coef %.3f, ot coef %.3f, cost: %d", 
                            spell.base_min,
                            spell.base_max,
                            spell.over_time,
                            spell.over_time_tick_freq,
                            spell.over_time_duration,
                            spell.cast_time,
                            spell.rank,
                            spell.lvl_req,
                            spell.flags,
                            spell.school,
                            spell.coef,
                            spell.over_time_coef,
                            spell.cost_base_percent
                            ));

        print(string.format("Spell noncrit: min %d, max %d", eval.spell_data.min_noncrit, eval.spell_data.max_noncrit));
        print(string.format("Spell crit: min %d, max %d", eval.spell_data.min_crit, eval.spell_data.max_crit));
                            

        print("Spell evaluation");
        print(string.format("ot if hit: %.3f", eval.spell_data.ot_if_hit));
        print(string.format("including hit/miss - expectation: %.3f, effect_per_sec: %.3f, effect per cost:%.3f, effect_per_sec_per_sp : %.3f, sp_per_crit: %.3f, sp_per_hit: %.3f", 
                            eval.spell_data.expectation, 
                            eval.spell_data.effect_per_sec, 
                            eval.spell_data.effect_per_cost, 
                            eval.effect_per_sec_per_sp, 
                            eval.sp_per_crit, 
                            eval.sp_per_hit
                            ));
        print("---------------------------------------------------");
    end
end

--local function diff_spell(spell_data, spell_name, loadout1, loadout2)
--

--    lhs = evaluate_spell(spell_data, spell_name, loadout1);
--    rhs = evaluate_spell(spell_data, spell_name, loadout2);
--    return {
--        expectation = rhs.spell_data.expectation - lhs.spell_data.expectation,
--        effect_per_sec = rhs.spell_data.effect_per_sec - lhs.spell_data.effect_per_sec
--    };
--end

-- UI code
local function ui_y_offset_incr(y) 
    return y - 17;
end

local sw_frame = {};

local function create_loadout_from_ui_diff(frame) 

    local stats = frame.stats;

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
                return empty_loadout();
            end
        end
    end

    local loadout = empty_loadout();

    loadout.stats[stat.int] = stats[stat_ids_in_ui.int].editbox_val;
    loadout.stats[stat.spirit] = stats[stat_ids_in_ui.spirit].editbox_val;
    loadout.mana = stats[stat_ids_in_ui.mana].editbox_val;
    loadout.mp5 = stats[stat_ids_in_ui.mp5].editbox_val;

    loadout.crit_rating = stats[stat_ids_in_ui.spell_crit].editbox_val;
    loadout.hit_rating = stats[stat_ids_in_ui.spell_hit].editbox_val;
    loadout.haste_rating = stats[stat_ids_in_ui.spell_haste].editbox_val;

    local loadout_sp = stats[stat_ids_in_ui.sp].editbox_val;
    loadout.spell_power = loadout.spell_power + loadout_sp;

    local loadout_decrease_target_res = stats[stat_ids_in_ui.target_spell_res_decrease].editbox_val;
    for i = 2, 7 do
        loadout.target_mod_res_by_school[i] = loadout.target_mod_res_by_school[i] - loadout_decrease_target_res;
    end

    frame.is_valid = true;

    return loadout;
end

local function spell_diff(spell_data, spell_name, loadout, diff, sim_type)

    local loadout_diffed = loadout_add(loadout, diff);

    local expectation_loadout = spell_info_from_loadout_stats(spell_data, spell_name, loadout);
    local expectation_loadout_diffed = spell_info_from_loadout_stats(spell_data, spell_name, loadout_diffed);

    if sim_type == simulation_type.spam_cast then
        return {
            diff_ratio = 100 * 
                (expectation_loadout_diffed.effect_per_sec/expectation_loadout.effect_per_sec - 1),
            expectation = expectation_loadout_diffed.expectation - 
                expectation_loadout.expectation,
            effect_per_sec = expectation_loadout_diffed.effect_per_sec - 
                expectation_loadout.effect_per_sec
        };
    elseif sim_type == simulation_type.cast_until_oom then
        
        local race_for_loadout = cast_until_oom_sim_default(expectation_loadout, loadout);
        local race_for_loadout_diffed = cast_until_oom_sim_default(expectation_loadout_diffed, loadout_diffed);
        -- Misleading! effect_per_sec used here to use previous code but doesnt mean efect_per_sec here
        return {
            diff_ratio = 100 * 
                (race_for_loadout_diffed.effect/race_for_loadout.effect - 1),
            expectation = race_for_loadout_diffed.effect - 
                race_for_loadout.effect,
            effect_per_sec = race_for_loadout_diffed.time_until_oom - 
                race_for_loadout.time_until_oom
        };
    end
end

function active_loadout_base()
    if sw_frame.loadouts_frame.lhs_list.loadouts and sw_frame.loadouts_frame.lhs_list.active_loadout then
        return sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout;
    else
        return default_loadout();
    end
end

local function active_loadout_copy()

    local loadout = active_loadout_base();
    if loadout.is_dynamic_loadout then
        loadout_modified = dynamic_loadout(loadout);
    else
        loadout_modified = loadout_copy(loadout);
    end

    return loadout_modified;
end

local function active_loadout_talented_copy()

    return apply_talents_glyphs(active_loadout_copy());
end

local function active_loadout_buffed_talented_copy()

    return apply_buffs(apply_talents_glyphs(active_loadout_copy()));
end


-- non local functions intended to be usable by other addons
function __sw__spell_info_from_loadout(spell_id, loadout)

    local spell_data = spells[spell_id];

    if not spell_data or not loadout then
        return nil;
    end

    local spell_name = GetSpellInfo(spell_id);

    local stats = loadout_stats_for_spell(spell_data, spell_name, loadout);

    local info = spell_info(
       spell_data, 
       stats.extra_ticks,
       stats.cast_speed,
       stats.spell_power,
       stats.flat_direct_addition,
       math.max(0, min(1, stats.crit)),
       math.max(0, min(1, stats.ot_crit)),
       stats.spell_crit_mod,
       stats.hit,
       math.max(0, stats.target_resi),
       stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_ot_mod,
       stats.direct_coef, stats.over_time_coef,
       stats.cost,
       spell_name, loadout
    );
    return {
        stats = stats,
        info = info
    };
end

function __sw__spell_info(spell_id)
    return __sw__spell_info_from_loadout(spell_id, active_loadout_buffed_talented_copy());
end

function __sw__spell_evaluation_from_loadout(spell_id, loadout)

    local spell_data = spells[spell_id];

    if not spell_data or not loadout then
        return nil;
    end

    local spell_name = GetSpellInfo(spell_id);

    local stats = loadout_stats_for_spell(spell_data, spell_name, loadout);

    local eval = evaluate_spell(stats, spell_data, spell_name, loadout);
    return {
        stats = stats,
        eval = eval
    };
end

function __sw__spell_evaluation(spell_id)
    return __sw__spell_evaluation_from_loadout(spell_id, active_loadout_buffed_talented_copy());
end

function __sw__spell_cast_til_oom_evaluation_from_loadout(spell_id, loadout)

    local spell_data = spells[spell_id];

    if not spell_data or not loadout then
        return nil;
    end

    local spell_name = GetSpellInfo(spell_id);

    local stats = loadout_stats_for_spell(spell_data, spell_name, loadout);

    local eval = evaluate_spell(stats, spell_data, spell_name, loadout);

    local rtb = cast_until_oom_stat_weights(
        stats,
        spell_data,
        spell_name,
        eval.spell_data, 
        eval.spell_data_1_sp,
        eval.spell_data_1_crit,
        eval.spell_data_1_hit,
        eval.spell_data_1_haste,
        eval.spell_data_1_target_resi, 
        loadout
    );

    return {
        stats = stats,
        eval = rtb
    };
end

function __sw__spell_cast_til_oom_evaluation(spell_id)
    return __sw__spell_cast_til_oom_evaluation_from_loadout(spell_id, active_loadout_buffed_talented_copy());
end

local update_and_display_spell_diffs = nil;

local function display_spell_diff(spell_id, spell_data, spell_diff_line, loadout, loadout_diff, frame, is_duality_spell, sim_type)

    local diff = spell_diff(spell_data, spell_diff_line.name, loadout, loadout_diff, sim_type);

    local v = nil;
    if is_duality_spell then
        if not spell_diff_line.duality then
            spell_diff_line.duality = {};
        end
        spell_diff_line.duality.name = spell_diff_line.name;
        v = spell_diff_line.duality;
    else
        v = spell_diff_line;
    end
    
    frame.line_y_offset = ui_y_offset_incr(frame.line_y_offset);
    
    if not v.name_str then
        v.name_str = frame:CreateFontString(nil, "OVERLAY");
        v.name_str:SetFontObject(font);
    
        v.change = frame:CreateFontString(nil, "OVERLAY");
        v.change:SetFontObject(font);
    
        v.expectation = frame:CreateFontString(nil, "OVERLAY");
        v.expectation:SetFontObject(font);
    
        v.effect_per_sec = frame:CreateFontString(nil, "OVERLAY");
        v.effect_per_sec:SetFontObject(font);
    

        if not spell_data.healing_version then
            v.cancel_button = CreateFrame("Button", "button", frame, "UIPanelButtonTemplate"); 
        end
    end
    
    v.name_str:SetPoint("TOPLEFT", 15, frame.line_y_offset);
    if is_duality_spell and 
        bit.band(spell_data.flags, spell_flags.heal) ~= 0 then

        v.name_str:SetText(v.name.." H (Rank "..spell_data.rank..")");
    elseif v.name == localized_spell_name("Holy Nova") or v.name == localized_spell_name("Holy Shock") then

        v.name_str:SetText(v.name.." D (Rank "..spell_data.rank..")");
    else
        v.name_str:SetText(v.name.." (Rank "..spell_data.rank..")");
    end

    v.name_str:SetTextColor(222/255, 192/255, 40/255);
    
    if not frame.is_valid then
    
        v.change:SetPoint("TOPRIGHT", -180, frame.line_y_offset);
        v.change:SetText("NAN");
    
        v.expectation:SetPoint("TOPRIGHT", -115, frame.line_y_offset);
        v.expectation:SetText("NAN");
    
        v.effect_per_sec:SetPoint("TOPRIGHT", -45, frame.line_y_offset);
        v.effect_per_sec:SetText("NAN");
        
    else
    
        v.change:SetPoint("TOPRIGHT", -180, frame.line_y_offset);
        v.expectation:SetPoint("TOPRIGHT", -115, frame.line_y_offset);
        v.effect_per_sec:SetPoint("TOPRIGHT", -45, frame.line_y_offset);
    
        if diff.expectation < 0 then
    
            v.change:SetText(string.format("%.2f", diff.diff_ratio).."%");
            v.change:SetTextColor(195/255, 44/255, 11/255);
    
            v.expectation:SetText(string.format("%.2f", diff.expectation));
            v.expectation:SetTextColor(195/255, 44/255, 11/255);
    
        elseif diff.expectation > 0 then
    
            v.change:SetText(string.format("+%.2f", diff.diff_ratio).."%");
            v.change:SetTextColor(33/255, 185/255, 21/255);
    
            v.expectation:SetText(string.format("+%.2f", diff.expectation));
            v.expectation:SetTextColor(33/255, 185/255, 21/255);
    
        else
    
            v.change:SetText("0 %");
            v.change:SetTextColor(1, 1, 1);
    
            v.expectation:SetText("0");
            v.expectation:SetTextColor(1, 1, 1);
        end

        if diff.effect_per_sec < 0 then
            v.effect_per_sec:SetText(string.format("%.2f", diff.effect_per_sec));
            v.effect_per_sec:SetTextColor(195/255, 44/255, 11/255);
        elseif diff.effect_per_sec > 0 then
            v.effect_per_sec:SetText(string.format("+%.2f", diff.effect_per_sec));
            v.effect_per_sec:SetTextColor(33/255, 185/255, 21/255);
        else
            v.effect_per_sec:SetText("0");
            v.effect_per_sec:SetTextColor(1, 1, 1);
        end
            

        if not spell_data.healing_version then
            v.cancel_button:SetScript("OnClick", function()
    
                v.change:Hide();
                v.name_str:Hide();
                v.expectation:Hide();
                v.effect_per_sec:Hide();
                v.cancel_button:Hide();

                -- in case this was the duality spell, i.e. healing counterpart 
                frame.spells[spell_id].change:Hide();
                frame.spells[spell_id].name_str:Hide();
                frame.spells[spell_id].expectation:Hide();
                frame.spells[spell_id].effect_per_sec:Hide();

                frame.spells[spell_id] = nil;
                update_and_display_spell_diffs(frame);
    
            end);
    
            v.cancel_button:SetPoint("TOPRIGHT", -10, frame.line_y_offset + 3);
            v.cancel_button:SetHeight(20);
            v.cancel_button:SetWidth(25);
            v.cancel_button:SetText("X");
        end
    end
end

function update_and_display_spell_diffs(frame)

    frame.line_y_offset = frame.line_y_offset_before_dynamic_spells;

    local loadout = active_loadout_buffed_talented_copy();

    local loadout_diff = create_loadout_from_ui_diff(frame);

    for k, v in pairs(frame.spells) do
        display_spell_diff(k, spells[k], v, loadout, loadout_diff, frame, false, sw_frame.stat_comparison_frame.sim_type);

        -- for spells with both heal and dmg
        if spells[k].healing_version then
            display_spell_diff(k, spells[k].healing_version, v, loadout, loadout_diff, frame, true, sw_frame.stat_comparison_frame.sim_type);
        end
    end

    -- footer
    frame.line_y_offset = ui_y_offset_incr(frame.line_y_offset);
    frame.line_y_offset = ui_y_offset_incr(frame.line_y_offset);

    if not frame.footer then
        frame.footer = frame:CreateFontString(nil, "OVERLAY");
    end
    frame.footer:SetFontObject(font);
    frame.footer:SetPoint("TOPLEFT", 15, frame.line_y_offset);
    frame.footer:SetText("Add abilities by holding SHIFT and HOVERING over them!");
end

local function loadout_name_already_exists(name)

    local already_exists = false;    
    for i = 1, sw_frame.loadouts_frame.lhs_list.num_loadouts do
    
        if name == sw_frame.loadouts_frame.lhs_list.loadouts[i].loadout.name then
            already_exists = true;
        end
    end
    return already_exists;
end

local function update_loadouts_rhs()

    local loadout = active_loadout_base();

    if sw_frame.loadouts_frame.lhs_list.num_loadouts == 1 then

        sw_frame.loadouts_frame.rhs_list.delete_button:Hide();
    else
        sw_frame.loadouts_frame.rhs_list.delete_button:Show();
    end

    sw_frame.stat_comparison_frame.loadout_name_label:SetText(
        loadout.name
    );

    sw_frame.loadouts_frame.rhs_list.name_editbox:SetText(
        loadout.name
    );

    sw_frame.loadouts_frame.rhs_list.level_editbox:SetText(
        loadout.target_lvl
    );

    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetText(
        loadout.extra_mana
    );

    if loadout.use_dynamic_target_lvl then
        sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton:SetChecked(true);
    else
        sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton:SetChecked(false);
    end
    if loadout.is_dynamic_loadout then

        sw_frame.loadouts_frame.rhs_list.talent_editbox:SetText(
            wowhead_talent_link(wowhead_talent_code())
        );

        sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(true);
        sw_frame.loadouts_frame.rhs_list.static_button:SetChecked(false);

    else

        sw_frame.loadouts_frame.rhs_list.talent_editbox:SetText(
            wowhead_talent_link(loadout.talents_code)
        );

        sw_frame.loadouts_frame.rhs_list.static_button:SetChecked(true);
        sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(false);
    end

    if loadout.always_assume_buffs then

        sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetChecked(true);
        sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetChecked(false);
    else
        sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetChecked(true);
        sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetChecked(false);
    end

    for i = 2, 7 do
        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetText(loadout.target_res_by_school[i]);
    end

    local num_checked_buffs = 0;
    local num_checked_target_buffs = 0;
    for k = 1, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs do

        local v = sw_frame.loadouts_frame.rhs_list.buffs[k];
        if v.checkbutton.buff_type == "self" then
            
            if loadout.buffs[v.checkbutton.buff_lname] then
                v.checkbutton:SetChecked(true);
                num_checked_buffs = num_checked_buffs + 1;
            else
                v.checkbutton:SetChecked(false);
            end
        end
        v.checkbutton:Hide();
        v.icon:Hide();
    end
    for k = 1, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs do

        local v = sw_frame.loadouts_frame.rhs_list.target_buffs[k];

        if loadout.target_buffs[v.checkbutton.buff_lname] then
            v.checkbutton:SetChecked(true);
            num_checked_target_buffs = num_checked_target_buffs + 1;
        else
            v.checkbutton:SetChecked(false);
        end
        v.checkbutton:Hide();
        v.icon:Hide();
    end
    -- all checkbuttons have been hidden, now unhide and set positions depending on slider
    local y_offset = 0;
    local buffs_show_max = 0;
    local num_buffs = 0;
    local num_skips = 0;
    local self_buffs_tab = sw_frame.loadouts_frame.rhs_list.self_buffs_frame:IsShown();

    if self_buffs_tab then
        y_offset = sw_frame.loadouts_frame.rhs_list.self_buffs_y_offset_start;
        buffs_show_max = sw_frame.loadouts_frame.rhs_list.buffs.num_buffs_can_fit;
        num_buffs = sw_frame.loadouts_frame.rhs_list.buffs.num_buffs;
        num_skips = math.floor(sw_frame.loadouts_frame.self_buffs_slider:GetValue()) + 1;
    else
        y_offset = sw_frame.loadouts_frame.rhs_list.target_buffs_y_offset_start;
        buffs_show_max = sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs_can_fit;
        num_buffs = sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs;
        num_skips = math.floor(sw_frame.loadouts_frame.target_buffs_slider:GetValue()) + 1;
    end

    local icon_offset = -4;

    if self_buffs_tab then
        for i = num_skips, math.min(num_skips + buffs_show_max - 1, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs) do
            sw_frame.loadouts_frame.rhs_list.buffs[i].checkbutton:SetPoint("TOPLEFT", 20, y_offset);
            sw_frame.loadouts_frame.rhs_list.buffs[i].checkbutton:Show();
            sw_frame.loadouts_frame.rhs_list.buffs[i].icon:SetPoint("TOPLEFT", 5, y_offset + icon_offset);
            sw_frame.loadouts_frame.rhs_list.buffs[i].icon:Show();
            y_offset = y_offset - 20;
        end
    else
        
        local target_buffs_iters = 
            math.max(0, math.min(buffs_show_max - num_skips, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs - num_skips) + 1);
        if buffs_show_max < num_skips and num_skips <= sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs then
            target_buffs_iters = buffs_show_max;
        end
        if target_buffs_iters > 0 then
            for i = num_skips, num_skips + target_buffs_iters - 1 do
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].checkbutton:SetPoint("TOPLEFT", 20, y_offset);
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].checkbutton:Show();
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].icon:SetPoint("TOPLEFT", 5, y_offset + icon_offset);
                sw_frame.loadouts_frame.rhs_list.target_buffs[i].icon:Show();
                y_offset = y_offset - 20;
            end
        end

        num_skips = num_skips + target_buffs_iters - sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs;
    end

    sw_frame.loadouts_frame.rhs_list.num_checked_buffs = num_checked_buffs;
    sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs = num_checked_target_buffs;

    if sw_frame.loadouts_frame.rhs_list.num_checked_buffs == 0 then
        sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(false);
    else
        sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(true);
    end

    if sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs == 0 then

        sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(false);
    else
        sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(true);
    end

end

local loadout_checkbutton_id_counter = 1;

-- TODO: localize
function update_loadouts_lhs()

    local y_offset = -13;
    local max_slider_val = math.max(0, sw_frame.loadouts_frame.lhs_list.num_loadouts - sw_frame.loadouts_frame.lhs_list.num_loadouts_can_fit);

    sw_frame.loadouts_frame.loadouts_slider:SetMinMaxValues(0, max_slider_val);
    if sw_frame.loadouts_frame.loadouts_slider:GetValue() > max_slider_val then
        sw_frame.loadouts_frame.loadouts_slider:SetValue(max_slider_val);
    end

    local num_skips = math.floor(sw_frame.loadouts_frame.loadouts_slider:GetValue()) + 1;


    -- precheck to create if needed and hide by default
    for k, v in pairs(sw_frame.loadouts_frame.lhs_list.loadouts) do

        local checkbutton_name = "sw_frame_loadouts_lhs_list"..k;
        v.check_button = getglobal(checkbutton_name);

        if not v.check_button then


            v.check_button = 
                CreateFrame("CheckButton", checkbutton_name, sw_frame.loadouts_frame.lhs_list, "ChatConfigCheckButtonTemplate");

            v.check_button.target_index = k;

            v.check_button:SetScript("OnClick", function(self)
                
                for i = 1, sw_frame.loadouts_frame.lhs_list.num_loadouts  do

                    sw_frame.loadouts_frame.lhs_list.loadouts[i].check_button:SetChecked(false);
                    
                end
                self:SetChecked(true);

                sw_frame.loadouts_frame.lhs_list.active_loadout = self.target_index;

                update_loadouts_rhs();
            end);
        end

        v.check_button:Hide();
    end

    -- show the ones in frames according to scroll slider
    for k = num_skips, math.min(num_skips + sw_frame.loadouts_frame.lhs_list.num_loadouts_can_fit - 1, 
                                sw_frame.loadouts_frame.lhs_list.num_loadouts) do

        local v = sw_frame.loadouts_frame.lhs_list.loadouts[k];

        getglobal(v.check_button:GetName() .. 'Text'):SetText(v.loadout.name);
        v.check_button:SetPoint("TOPLEFT", 10, y_offset);
        v.check_button:Show();

        if k == sw_frame.loadouts_frame.lhs_list.active_loadout then
            v.check_button:SetChecked(true);
        else
            v.check_button:SetChecked(false);
        end

        y_offset = y_offset - 20;
    end

    update_loadouts_rhs();
end

local function create_new_loadout_as_copy(loadout, name)

    local cpy = loadout_copy(loadout);

    sw_frame.loadouts_frame.lhs_list.loadouts[
        sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(false);

    sw_frame.loadouts_frame.lhs_list.num_loadouts = sw_frame.loadouts_frame.lhs_list.num_loadouts + 1;
    sw_frame.loadouts_frame.lhs_list.active_loadout = sw_frame.loadouts_frame.lhs_list.num_loadouts;

    sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.num_loadouts] = {};
    sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.num_loadouts].loadout = cpy;

    sw_frame.loadouts_frame.lhs_list.loadouts[
        sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.name = name.." (Copy)";

    update_loadouts_lhs();

    sw_frame.loadouts_frame.lhs_list.loadouts[
        sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(true);
end

local function sw_activate_tab(tab_index)

    sw_frame.active_tab = tab_index;

    sw_frame:Show();

    sw_frame.settings_frame:Hide();
    sw_frame.loadouts_frame:Hide();
    sw_frame.stat_comparison_frame:Hide();

    sw_frame.tab1:UnlockHighlight();
    sw_frame.tab1:SetButtonState("NORMAL");
    sw_frame.tab2:UnlockHighlight();
    sw_frame.tab2:SetButtonState("NORMAL");
    sw_frame.tab3:UnlockHighlight();
    sw_frame.tab3:SetButtonState("NORMAL");

    if tab_index == 1 then
        sw_frame.settings_frame:Show();
        sw_frame.tab1:LockHighlight();
        sw_frame.tab1:SetButtonState("PUSHED");
    elseif tab_index == 2 then
        sw_frame.loadouts_frame:Show();
        sw_frame.tab2:LockHighlight();
        sw_frame.tab2:SetButtonState("PUSHED");
    elseif tab_index == 3 then

        update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
        sw_frame.stat_comparison_frame:Show();
        sw_frame.tab3:LockHighlight();
        sw_frame.tab3:SetButtonState("PUSHED");
    end
end

local function default_sw_settings()
    local settings = {};
    settings.ability_icon_overlay = 
        bit.bor(icon_stat_display.normal, 
                icon_stat_display.crit, 
                icon_stat_display.effect_per_sec,
                icon_stat_display.show_heal_variant);

    settings.ability_tooltip = 
        bit.bor(tooltip_stat_display.normal, 
                tooltip_stat_display.crit, 
                tooltip_stat_display.ot,
                tooltip_stat_display.ot_crit,
                tooltip_stat_display.expected,
                tooltip_stat_display.effect_per_sec,
                tooltip_stat_display.effect_per_cost,
                tooltip_stat_display.cost_per_sec,
                tooltip_stat_display.stat_weights,
                tooltip_stat_display.cast_until_oom);

    settings.icon_overlay_update_freq = 10;
    settings.icon_overlay_font_size = 8;
    settings.show_tooltip_only_when_shift = false;
    settings.libstub_minimap_icon = { hide = false };

    return settings;
end

local function save_sw_settings()

    local icon_overlay_settings = 0;
    local tooltip_settings = 0;

    if sw_frame.settings_frame.icon_normal_effect:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.normal);
    end
    if sw_frame.settings_frame.icon_crit_effect:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.crit);
    end
    if sw_frame.settings_frame.icon_expected_effect:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.expected);
    end
    if sw_frame.settings_frame.icon_effect_per_sec:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.effect_per_sec);
    end
    if sw_frame.settings_frame.icon_effect_per_cost:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.effect_per_cost);
    end
    if sw_frame.settings_frame.icon_avg_cost:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.avg_cost);
    end
    if sw_frame.settings_frame.icon_avg_cast:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.avg_cast);
    end
    if sw_frame.settings_frame.icon_hit:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.hit);
    end
    if sw_frame.settings_frame.icon_crit:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.crit_chance);
    end
    if sw_frame.settings_frame.icon_casts_until_oom:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.casts_until_oom);
    end
    if sw_frame.settings_frame.icon_effect_until_oom:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.effect_until_oom);
    end
    if sw_frame.settings_frame.icon_time_until_oom:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.time_until_oom);
    end
    if sw_frame.settings_frame.icon_heal_variant:GetChecked() then
        icon_overlay_settings = bit.bor(icon_overlay_settings, icon_stat_display.show_heal_variant);
    end

    if sw_frame.settings_frame.tooltip_normal_effect:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.normal);
    end
    if sw_frame.settings_frame.tooltip_crit_effect:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.crit);
    end
    if sw_frame.settings_frame.tooltip_normal_ot:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.ot);
    end
    if sw_frame.settings_frame.tooltip_crit_ot:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.ot_crit);
    end
    if sw_frame.settings_frame.tooltip_expected_effect:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.expected);
    end
    if sw_frame.settings_frame.tooltip_effect_per_sec:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.effect_per_sec);
    end
    if sw_frame.settings_frame.tooltip_effect_per_cost:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.effect_per_cost);
    end
    if sw_frame.settings_frame.tooltip_cost_per_sec:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.cost_per_sec);
    end
    if sw_frame.settings_frame.tooltip_stat_weights:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.stat_weights);
    end
    if sw_frame.settings_frame.tooltip_coef:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.coef);
    end
    if sw_frame.settings_frame.tooltip_avg_cost:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.avg_cost);
    end
    if sw_frame.settings_frame.tooltip_avg_cast:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.avg_cast);
    end
    if sw_frame.settings_frame.tooltip_cast_until_oom:GetChecked() then
        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.cast_until_oom);
    end
    --if class == "WARLOCK" then
    --    if sw_frame.settings_frame.tooltip_cast_and_tap:GetChecked() then
    --        tooltip_settings = bit.bor(tooltip_settings, tooltip_stat_display.cast_and_tap);
    --    end
    --end

    __sw__persistent_data_per_char.settings.ability_icon_overlay = icon_overlay_settings;
    __sw__persistent_data_per_char.settings.ability_tooltip = tooltip_settings;
    __sw__persistent_data_per_char.settings.show_tooltip_only_when_shift = sw_frame.settings_frame.show_tooltip_only_when_shift;
    __sw__persistent_data_per_char.settings.icon_overlay_update_freq = sw_snapshot_loadout_update_freq;
    __sw__persistent_data_per_char.settings.icon_overlay_font_size = sw_frame.settings_frame.icon_overlay_font_size;
end

local function create_sw_checkbox(name, parent, line_pos_index, y_offset, text, check_func)

    local checkbox_frame = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate"); 

    local x_spacing = 180;
    local x_pad = 10;
    checkbox_frame:SetPoint("TOPLEFT", x_pad + (line_pos_index - 1) * x_spacing, y_offset);
    getglobal(checkbox_frame:GetName() .. 'Text'):SetText(text);
    checkbox_frame:SetScript("OnClick", check_func);

    return checkbox_frame;
end

local function create_sw_gui_settings_frame()

    sw_frame.settings_frame:SetWidth(370);
    sw_frame.settings_frame:SetHeight(600);
    sw_frame.settings_frame:SetPoint("TOP", sw_frame, 0, -20);

    if not __sw__persistent_data_per_char then
        __sw__persistent_data_per_char = {};
    end

    if not __sw__persistent_data_per_char.settings then
        __sw__persistent_data_per_char.settings = default_sw_settings();
    end

    -- content frame for settings
    sw_frame.settings_frame.y_offset = -35;

    sw_frame.settings_frame.icon_settings_label = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.icon_settings_label:SetFontObject(font);
    sw_frame.settings_frame.icon_settings_label:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_settings_label:SetText("Ability Icon Overlay Display Options (max 3)");
    sw_frame.settings_frame.icon_settings_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    -- TODO: this needs to be checked based on saved vars
    sw_frame.settings_frame.icons_num_checked = 0;

    local icon_checkbox_func = function(self)
        if self:GetChecked() then
            if sw_frame.settings_frame.icons_num_checked >= 3 then
                self:SetChecked(false);
            else
                sw_frame.settings_frame.icons_num_checked = sw_frame.settings_frame.icons_num_checked + 1;
            end
        else
            sw_frame.settings_frame.icons_num_checked = sw_frame.settings_frame.icons_num_checked - 1;
        end
        update_icon_overlay_settings();
    end;

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_normal_effect = 
        create_sw_checkbox("sw_icon_normal_effect", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Normal effect", icon_checkbox_func);
    sw_frame.settings_frame.icon_crit_effect = 
        create_sw_checkbox("sw_icon_crit_effect", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Critical effect", icon_checkbox_func); 
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_expected_effect = 
        create_sw_checkbox("sw_icon_expected_effect", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Expected effect", icon_checkbox_func);  
    getglobal(sw_frame.settings_frame.icon_expected_effect:GetName()).tooltip = 
        "Expected effect is the DMG or Heal dealt on average for a single cast considering miss chance, crit chance, spell power etc. This equates to your DPS or HPS number multiplied with the ability's cast time"

    sw_frame.settings_frame.icon_effect_per_sec = 
        create_sw_checkbox("sw_icon_effect_per_sec", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Effect per sec", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_effect_per_cost = 
        create_sw_checkbox("sw_icon_effect_per_costs", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Effect per cost", icon_checkbox_func);  
    sw_frame.settings_frame.icon_avg_cost = 
        create_sw_checkbox("sw_icon_avg_cost", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Average cost", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_avg_cast = 
        create_sw_checkbox("sw_icon_avg_cast", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Average cast time", icon_checkbox_func);
    sw_frame.settings_frame.icon_hit = 
        create_sw_checkbox("sw_icon_hit", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Hit Chance", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_crit = 
        create_sw_checkbox("sw_icon_crit_chance", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Critical Chance", icon_checkbox_func);  
    sw_frame.settings_frame.icon_casts_until_oom = 
        create_sw_checkbox("sw_icon_casts_until_oom", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Casts until OOM", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    sw_frame.settings_frame.icon_effect_until_oom = 
        create_sw_checkbox("sw_icon_effect_until_oom", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Effect until OOM", icon_checkbox_func);  
    sw_frame.settings_frame.icon_time_until_oom = 
        create_sw_checkbox("sw_icon_time_until_oom", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "Time until OOM", icon_checkbox_func);  
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 30;

    sw_frame.settings_frame.icon_settings_label = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.icon_settings_label:SetFontObject(font);
    sw_frame.settings_frame.icon_settings_label:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_settings_label:SetText("Ability Icon Overlay Configuration");
    sw_frame.settings_frame.icon_settings_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.icon_heal_variant = 
        CreateFrame("CheckButton", "sw_icon_heal_variant", sw_frame.settings_frame, "ChatConfigCheckButtonTemplate"); 
    sw_frame.settings_frame.icon_heal_variant:SetPoint("TOPLEFT", 10, sw_frame.settings_frame.y_offset);   
    getglobal(sw_frame.settings_frame.icon_heal_variant:GetName() .. 'Text'):SetText("Show healing for hybrid spells");
    --sw_frame.settings_frame.icon_heal_variant:SetScript("OnClick", function(self)
    --end);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 30;
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetFontObject(font);
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetText("Update frequency");

    sw_frame.settings_frame.icon_settings_update_freq_label_lhs = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetFontObject(font);
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetPoint("TOPLEFT", 170, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_settings_update_freq_label_lhs:SetText("Hz (less means better performance");

    sw_frame.settings_frame.icon_settings_update_freq_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.settings_frame, "InputBoxTemplate");
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetPoint("TOPLEFT", 120, sw_frame.settings_frame.y_offset + 3);
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetText("");
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetSize(40, 15);
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetAutoFocus(false);

    local hz_editbox = function(self)

        
        local txt = self:GetText();
        
        local hz = tonumber(txt);
        if hz and hz >= 0.01 and hz <= 300 then

            sw_snapshot_loadout_update_freq = tonumber(hz);
            
        else
            self:SetText("10"); 
            sw_snapshot_loadout_update_freq = 10;
        end

    	self:ClearFocus();
    end

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 30;

    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetScript("OnEnterPressed", hz_editbox);
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetScript("OnEscapePressed", hz_editbox);

    sw_frame.settings_frame.icon_overlay_font_size_slider =
        CreateFrame("Slider", "icon_overlay_font_size", sw_frame.settings_frame, "OptionsSliderTemplate");
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetMinMaxValues(2, 24)
    getglobal(sw_frame.settings_frame.icon_overlay_font_size_slider:GetName()..'Text'):SetText("Icon overlay font size");
    getglobal(sw_frame.settings_frame.icon_overlay_font_size_slider:GetName()..'Low'):SetText("");
    getglobal(sw_frame.settings_frame.icon_overlay_font_size_slider:GetName()..'High'):SetText("");
    sw_frame.settings_frame.icon_overlay_font_size = __sw__persistent_data_per_char.settings.icon_overlay_font_size;
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetValue(sw_frame.settings_frame.icon_overlay_font_size);
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetValueStep(1)
    sw_frame.settings_frame.icon_overlay_font_size_slider:SetScript("OnValueChanged", function(self, val)
        sw_frame.settings_frame.icon_overlay_font_size = val;
    end);


    local num_icon_overlay_checks = 0;
    -- set checkboxes for _icon options as  according to persistent data per char
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.normal) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_normal_effect:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.crit) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_crit_effect:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.expected) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_expected_effect:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.effect_per_sec) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_effect_per_sec:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.effect_per_cost) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_effect_per_cost:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.avg_cost) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_avg_cost:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.avg_cast) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_avg_cast:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.hit) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_hit:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.crit_chance) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_crit:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.casts_until_oom) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_casts_until_oom:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.effect_until_oom) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_effect_until_oom:SetChecked(true);
        end
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.time_until_oom) ~= 0 then
        if num_icon_overlay_checks < 3 then
            num_icon_overlay_checks = num_icon_overlay_checks + 1;
            sw_frame.settings_frame.icon_time_until_oom:SetChecked(true);
        end
    end
    sw_frame.settings_frame.icons_num_checked = num_icon_overlay_checks;
    if bit.band(__sw__persistent_data_per_char.settings.ability_icon_overlay, icon_stat_display.show_heal_variant) ~= 0 then
        sw_frame.settings_frame.icon_heal_variant:SetChecked(true);
    end

    sw_snapshot_loadout_update_freq = __sw__persistent_data_per_char.settings.icon_overlay_update_freq;
    sw_frame.settings_frame.icon_settings_update_freq_editbox:SetText(""..sw_snapshot_loadout_update_freq);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 30;

    sw_frame.settings_frame.tooltip_settings_label = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.tooltip_settings_label:SetFontObject(font);
    sw_frame.settings_frame.tooltip_settings_label:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.tooltip_settings_label:SetText("Ability Tooltip Display Options");
    sw_frame.settings_frame.tooltip_settings_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;

    -- tooltip options
    sw_frame.settings_frame.tooltip_num_checked = 0;
    local tooltip_checkbox_func = function(self)
        if self:GetChecked() then
            sw_frame.settings_frame.tooltip_num_checked = sw_frame.settings_frame.tooltip_num_checked + 1;
        else
            sw_frame.settings_frame.tooltip_num_checked = sw_frame.settings_frame.tooltip_num_checked - 1;
        end
    end;

    sw_frame.settings_frame.tooltip_normal_effect = 
        create_sw_checkbox("sw_tooltip_normal_effect", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Normal effect", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_crit_effect = 
        create_sw_checkbox("sw_tooltip_crit_effect", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Critical effect", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_normal_ot = 
        create_sw_checkbox("sw_tooltip_normal_ot", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Normal over time effect", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_crit_ot = 
        create_sw_checkbox("sw_tooltip_crit_ot", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Critical over time effect", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_expected_effect = 
        create_sw_checkbox("sw_tooltip_expected_effect", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Expected effect", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_effect_per_sec = 
        create_sw_checkbox("sw_tooltip_effect_per_sec", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Effect per sec", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_effect_per_cost = 
        create_sw_checkbox("sw_tooltip_effect_per_cost", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Effect per cost", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_cost_per_sec = 
        create_sw_checkbox("sw_tooltip_cost_per_sec", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Cost per sec", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_stat_weights = 
        create_sw_checkbox("sw_tooltip_stat_weights", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Stat Weights", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_coef = 
        create_sw_checkbox("sw_tooltip_coef", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Ability coefficient", tooltip_checkbox_func);
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_avg_cost = 
        create_sw_checkbox("sw_tooltip_avg_cost", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Average cost", tooltip_checkbox_func);
    sw_frame.settings_frame.tooltip_avg_cast = 
        create_sw_checkbox("sw_tooltip_avg_cast", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                            "Average cast time", tooltip_checkbox_func);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.tooltip_cast_until_oom = 
        create_sw_checkbox("sw_tooltip_cast_until_oom", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                            "Cast until OOM", tooltip_checkbox_func);
    getglobal(sw_frame.settings_frame.tooltip_cast_until_oom:GetName()).tooltip = 
        "Assumes you cast a particular ability until you are OOM with no cooldowns.";
    --if class == "WARLOCK" then    
    --    sw_frame.settings_frame.tooltip_cast_and_tap = 
    --        create_sw_checkbox("sw_tooltip_cast_and_tap", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
    --                            "Cast and Lifetap", tooltip_checkbox_func);
    --end

    -- set tooltip options as according to saved persistent data
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.normal) ~= 0 then
        sw_frame.settings_frame.tooltip_normal_effect:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.crit) ~= 0 then
        sw_frame.settings_frame.tooltip_crit_effect:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.ot) ~= 0 then
        sw_frame.settings_frame.tooltip_normal_ot:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.ot_crit) ~= 0 then
        sw_frame.settings_frame.tooltip_crit_ot:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.expected) ~= 0 then
        sw_frame.settings_frame.tooltip_expected_effect:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.effect_per_sec) ~= 0 then
        sw_frame.settings_frame.tooltip_effect_per_sec:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.effect_per_cost) ~= 0 then
        sw_frame.settings_frame.tooltip_effect_per_cost:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.cost_per_sec) ~= 0 then
        sw_frame.settings_frame.tooltip_cost_per_sec:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.stat_weights) ~= 0 then
        sw_frame.settings_frame.tooltip_stat_weights:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.coef) ~= 0 then
        sw_frame.settings_frame.tooltip_coef:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.avg_cost) ~= 0 then
        sw_frame.settings_frame.tooltip_avg_cost:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.avg_cast) ~= 0 then
        sw_frame.settings_frame.tooltip_avg_cast:SetChecked(true);
    end
    if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.cast_until_oom) ~= 0 then
        sw_frame.settings_frame.tooltip_cast_until_oom:SetChecked(true);
    end
    --if class == "WARLOCK" then
        --if bit.band(__sw__persistent_data_per_char.settings.ability_tooltip, tooltip_stat_display.cast_and_tap) ~= 0 then
        --    sw_frame.settings_frame.tooltip_cast_and_tap:SetChecked(true);
        --end
    --end

    for i = 1, 32 do
        if bit.band(bit.lshift(1, i), __sw__persistent_data_per_char.settings.ability_tooltip) ~= 0 then
            sw_frame.settings_frame.tooltip_num_checked = sw_frame.settings_frame.tooltip_num_checked + 1;
        end
    end;
    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 30;
    
    sw_frame.settings_frame.tooltip_settings_label_misc = sw_frame.settings_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.settings_frame.tooltip_settings_label_misc:SetFontObject(font);
    sw_frame.settings_frame.tooltip_settings_label_misc:SetPoint("TOPLEFT", 15, sw_frame.settings_frame.y_offset);
    sw_frame.settings_frame.tooltip_settings_label_misc:SetText("Miscellaneous Settings");
    sw_frame.settings_frame.tooltip_settings_label_misc:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.settings_frame.y_offset = sw_frame.settings_frame.y_offset - 20;
    sw_frame.settings_frame.libstub_icon_checkbox = 
        create_sw_checkbox("sw_settings_show_minimap_button", sw_frame.settings_frame, 1, sw_frame.settings_frame.y_offset, 
                           "Minimap Icon", function(self) 

        __sw__persistent_data_per_char.settings.libstub_minimap_icon.hide = not self:GetChecked();
        if __sw__persistent_data_per_char.settings.libstub_minimap_icon.hide then
            libstub_icon:Hide(sw_addon_name);

        else
            libstub_icon:Show(sw_addon_name);
        end
    end);

    sw_frame.settings_frame.show_tooltip_only_when_shift_button = 
        create_sw_checkbox("sw_settings_show_tooltip_only_when_shift_button", sw_frame.settings_frame, 2, sw_frame.settings_frame.y_offset, 
                           "SHIFT to show tooltip", function(self)
        sw_frame.settings_frame.show_tooltip_only_when_shift = self:GetChecked();
    end);
    sw_frame.settings_frame.show_tooltip_only_when_shift = 
        __sw__persistent_data_per_char.settings.show_tooltip_only_when_shift;
    sw_frame.settings_frame.show_tooltip_only_when_shift_button:SetChecked(
        sw_frame.settings_frame.show_tooltip_only_when_shift
    );
end

local function create_sw_gui_stat_comparison_frame()

    sw_frame.stat_comparison_frame:SetWidth(400);
    sw_frame.stat_comparison_frame:SetHeight(600);
    sw_frame.stat_comparison_frame:SetPoint("TOP", sw_frame, 0, -20);

    sw_frame.stat_comparison_frame.line_y_offset = -20;

    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.instructions_label = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.instructions_label:SetFontObject(font);
    sw_frame.stat_comparison_frame.instructions_label:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.instructions_label:SetText("See project page for an example use case of this tool:");


    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.instructions_label1 = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.instructions_label1:SetFontObject(font);
    sw_frame.stat_comparison_frame.instructions_label1:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.instructions_label1:SetText("https://www.curseforge.com/wow/addons/stat-weights-classic");

    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

    sw_frame.stat_comparison_frame.loadout_label = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.loadout_label:SetFontObject(font);
    sw_frame.stat_comparison_frame.loadout_label:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.loadout_label:SetText("Active Loadout: ");
    sw_frame.stat_comparison_frame.loadout_label:SetTextColor(222/255, 192/255, 40/255);

    sw_frame.stat_comparison_frame.loadout_name_label = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.loadout_name_label:SetFontObject(font);
    sw_frame.stat_comparison_frame.loadout_name_label:SetPoint("TOPLEFT", 110, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.loadout_name_label:SetText("Missing loadout!");
    sw_frame.stat_comparison_frame.loadout_name_label:SetTextColor(222/255, 192/255, 40/255);


    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

    sw_frame.stat_comparison_frame.stat_diff_header_left = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.stat_diff_header_left:SetFontObject(font);
    sw_frame.stat_comparison_frame.stat_diff_header_left:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.stat_diff_header_left:SetText("Stat");

    sw_frame.stat_comparison_frame.stat_diff_header_center = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.stat_diff_header_center:SetFontObject(font);
    sw_frame.stat_comparison_frame.stat_diff_header_center:SetPoint("TOPRIGHT", -80, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.stat_diff_header_center:SetText("Difference");

    sw_frame.stat_comparison_frame.stats = {
        [1] = {
            label_str = "Intellect"
        },
        [2] = {
            label_str = "Spirit"
        },
        [3] = {
            label_str = "Mana"
        },
        [4] = {
            label_str = "MP5"
        },
        [5] = {
            label_str = "Spell power"
        },
        [6] = {
            label_str = "Critical rating"
        },
        [7] = {
            label_str = "Hit rating"
        },
        [8] = {
            label_str = "Haste rating"
        },
        [9] = {
            label_str = "Reduced resistance (target)"
        }
    };

    local num_stats = 0;
    for _ in pairs(sw_frame.stat_comparison_frame.stats) do
        num_stats = num_stats + 1;
    end

    sw_frame.stat_comparison_frame.clear_button = CreateFrame("Button", "button", sw_frame.stat_comparison_frame, "UIPanelButtonTemplate"); 
    sw_frame.stat_comparison_frame.clear_button:SetScript("OnClick", function()

        for i = 1, num_stats do

            sw_frame.stat_comparison_frame.stats[i].editbox:SetText("");
        end

        update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
    end);

    sw_frame.stat_comparison_frame.clear_button:SetPoint("TOPRIGHT", -30, sw_frame.stat_comparison_frame.line_y_offset + 3);
    sw_frame.stat_comparison_frame.clear_button:SetHeight(15);
    sw_frame.stat_comparison_frame.clear_button:SetWidth(50);
    sw_frame.stat_comparison_frame.clear_button:SetText("Clear");

    --sw_frame.stat_comparison_frame.line_y_offset = sw_frame.stat_comparison_frame.line_y_offset - 10;


    for i = 1 , num_stats do

        v = sw_frame.stat_comparison_frame.stats[i];

        sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

        v.label = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");

        v.label:SetFontObject(font);
        v.label:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
        v.label:SetText(v.label_str);
        v.label:SetTextColor(222/255, 192/255, 40/255);

        v.editbox = CreateFrame("EditBox", v.label_str.."editbox"..i, sw_frame.stat_comparison_frame, "InputBoxTemplate");
        v.editbox:SetPoint("TOPRIGHT", -30, sw_frame.stat_comparison_frame.line_y_offset);
        v.editbox:SetText("");
        v.editbox:SetAutoFocus(false);
        v.editbox:SetSize(100, 10);
        v.editbox:SetScript("OnTextChanged", function(self)

            if string.match(self:GetText(), "[^-+0123456789. ()]") ~= nil then
                self:ClearFocus();
                self:SetText("");
                self:SetFocus();
            else 
                update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
            end
        end);

        v.editbox:SetScript("OnEnterPressed", function(self)

        	self:ClearFocus()
        end);
        
        v.editbox:SetScript("OnEscapePressed", function(self)
        	self:ClearFocus()
        end);

        v.editbox:SetScript("OnTabPressed", function(self)

            local next_index = 0;
            if IsShiftKeyDown() then
                next_index = 1 + ((i-2) %num_stats);
            else
                next_index = 1 + (i %num_stats);

            end
        	self:ClearFocus()
            sw_frame.stat_comparison_frame.stats[next_index].editbox:SetFocus();
        end);
    end

    sw_frame.stat_comparison_frame.stats[stat_ids_in_ui.sp].editbox:SetText("1");

    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

    -- sim type button
    sw_frame.stat_comparison_frame.sim_type_button = 
        CreateFrame("Button", "sw_sim_type_button", sw_frame.stat_comparison_frame, "UIDropDownMenuTemplate"); 
    sw_frame.stat_comparison_frame.sim_type_button:SetPoint("TOPLEFT", -5, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.sim_type_button.init_func = function()
        UIDropDownMenu_Initialize(sw_frame.stat_comparison_frame.sim_type_button, function()
            
            if sw_frame.stat_comparison_frame.sim_type == simulation_type.spam_cast then 
                UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Repeated casts");
            elseif sw_frame.stat_comparison_frame.sim_type == simulation_type.cast_until_oom then 
                UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Cast until OOM");
            end
            UIDropDownMenu_SetWidth(sw_frame.stat_comparison_frame.sim_type_button, 130);

            UIDropDownMenu_AddButton(
                {
                    text = "Repeated cast",
                    func = function()

                        sw_frame.stat_comparison_frame.sim_type = simulation_type.spam_cast;
                        UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Repeated casts");
                        sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Show();
                        sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:Hide();
                        update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
                    end
                }
            );
            UIDropDownMenu_AddButton(
                {
                    text = "Cast until OOM",
                    func = function()

                        sw_frame.stat_comparison_frame.sim_type = simulation_type.cast_until_oom;
                        UIDropDownMenu_SetText(sw_frame.stat_comparison_frame.sim_type_button, "Cast until OOM");
                        sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Hide();
                        sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:Show();
                        update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
                    end
                }
            );
        end);
    end;

    sw_frame.stat_comparison_frame.sim_type_button:SetText("Simulation type");

    -- header for spells
    sw_frame.stat_comparison_frame.export_button = CreateFrame("Button", "button", sw_frame.stat_comparison_frame, "UIPanelButtonTemplate"); 
    sw_frame.stat_comparison_frame.export_button:SetScript("OnClick", function()

        local loadout = active_loadout_copy();

        local loadout_diff = create_loadout_from_ui_diff(sw_frame.stat_comparison_frame);

        local new_loadout = loadout_add(loadout, loadout_diff);

        new_loadout.is_dynamic_loadout = false;

        create_new_loadout_as_copy(new_loadout, active_loadout_base().name.." (modified)");

        sw_activate_tab(2);
    end);


    sw_frame.stat_comparison_frame.export_button:SetPoint("TOPRIGHT", -10, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.export_button:SetHeight(25);
    sw_frame.stat_comparison_frame.export_button:SetWidth(180);
    sw_frame.stat_comparison_frame.export_button:SetText("New loadout with difference");

    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.line_y_offset = ui_y_offset_incr(sw_frame.stat_comparison_frame.line_y_offset);

    sw_frame.stat_comparison_frame.line_y_offset_before_dynamic_spells = sw_frame.stat_comparison_frame.line_y_offset;

    sw_frame.stat_comparison_frame.spell_diff_header_spell = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_spell:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_spell:SetPoint("TOPLEFT", 15, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_spell:SetText("Spell");

    sw_frame.stat_comparison_frame.spell_diff_header_left = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_left:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_left:SetPoint("TOPRIGHT", -180, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_left:SetText("Change");

    sw_frame.stat_comparison_frame.spell_diff_header_center = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_center:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_center:SetPoint("TOPRIGHT", -105, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_center:SetText("DMG/HEAL");

    sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:SetPoint("TOPRIGHT", -45, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:SetText("DPS/HPS");

    sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom = sw_frame.stat_comparison_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:SetFontObject(font);
    sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:SetPoint("TOPRIGHT", -20, sw_frame.stat_comparison_frame.line_y_offset);
    sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:SetText("DURATION (s)");

    -- always have at least one
    sw_frame.stat_comparison_frame.spells = {};
    sw_frame.stat_comparison_frame.sim_type = simulation_type.spam_cast;

    -- TODO: wotlk stuff
    if UnitLevel("player") == 60 then

        if class == "MAGE" then
            sw_frame.stat_comparison_frame.spells[25304] = {
                name = localized_spell_name("Frostbolt")
            };
            sw_frame.stat_comparison_frame.spells[25306] = {
                name = localized_spell_name("Fireball")
            };
        elseif class == "DRUID" then

            sw_frame.stat_comparison_frame.spells[25297] = {
                name = localized_spell_name("Healing Touch")
            };
            sw_frame.stat_comparison_frame.spells[25298] = {
                name = localized_spell_name("Starfire")
            };

        elseif class == "PALADIN" then

            sw_frame.stat_comparison_frame.spells[19943] = {
                name = localized_spell_name("Flash of Light")
            };
            sw_frame.stat_comparison_frame.spells[25292] = {
                name = localized_spell_name("Holy Light")
            };
        elseif class == "SHAMAN" then

            sw_frame.stat_comparison_frame.spells[25357] = {
                name = localized_spell_name("Healing Wave")
            };
            sw_frame.stat_comparison_frame.spells[15208] = {
                name = localized_spell_name("Lightning Bolt")
            };
        elseif class == "PRIEST" then

            sw_frame.stat_comparison_frame.spells[25314] = {
                name = localized_spell_name("Greater Heal")
            };
            sw_frame.stat_comparison_frame.spells[25315] = {
                name = localized_spell_name("Renew")
            };
        elseif class == "WARLOCK" then

            sw_frame.stat_comparison_frame.spells[25307] = {
                name = localized_spell_name("Shadow Bolt")
            };
            sw_frame.stat_comparison_frame.spells[25311] = {
                name = localized_spell_name("Corruption")
            };
            sw_frame.stat_comparison_frame.spells[11713] = {
                name = localized_spell_name("Curse of Agony")
            };
        end
    end

end

local function create_loadout_buff_checkbutton(buffs_table, buff_id, buff_info, buff_type, parent_frame, func)

    local index = buffs_table.num_buffs + 1;

    buffs_table[index] = {};
    buffs_table[index].checkbutton = CreateFrame("CheckButton", "loadout_apply_buffs_"..buff_id, parent_frame, "ChatConfigCheckButtonTemplate");
    buffs_table[index].checkbutton.buff_info = buff_info;
    local buff_lname, _, _, _, _, _, _ = GetSpellInfo(buff_id);
    buffs_table[index].checkbutton.buff_lname = buff_lname;
    buffs_table[index].checkbutton.buff_type = buff_type;
    if buff_info.name then
        -- overwrite name if its bad for display
        getglobal(buffs_table[index].checkbutton:GetName() .. 'Text'):SetText(buff_info.name);
    else
        getglobal(buffs_table[index].checkbutton:GetName() .. 'Text'):SetText(buff_lname);
    end
    buffs_table[index].checkbutton:SetScript("OnClick", func);

    buffs_table[index].icon = CreateFrame("Frame", "loadout_apply_buffs_icon_"..buff_id, parent_frame);
    buffs_table[index].icon:SetSize(15, 15);
    local tex = buffs_table[index].icon:CreateTexture(nil);
    tex:SetAllPoints(buffs_table[index].icon);
    if buff_info.icon_id then
        tex:SetTexture(buff_info.icon_id);
    else
        tex:SetTexture(GetSpellTexture(buff_id));
    end

    buffs_table.num_buffs = index;

    return buffs_table[index].checkbutton;
end

local function create_sw_gui_loadout_frame()

    sw_frame.loadouts_frame:SetWidth(400);
    sw_frame.loadouts_frame:SetHeight(600);
    sw_frame.loadouts_frame:SetPoint("TOP", sw_frame, 0, -20);

    sw_frame.loadouts_frame.lhs_list = CreateFrame("ScrollFrame", "sw_loadout_frame_lhs", sw_frame.loadouts_frame);
    sw_frame.loadouts_frame.lhs_list:SetWidth(180);
    sw_frame.loadouts_frame.lhs_list:SetHeight(600-30-200-10-25-10-20-20);
    sw_frame.loadouts_frame.lhs_list:SetPoint("TOPLEFT", sw_frame, 0, -50);

    sw_frame.loadouts_frame.lhs_list:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.loadouts_frame.loadouts_slider:GetMinMaxValues();
        local val = sw_frame.loadouts_frame.loadouts_slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.loadouts_frame.loadouts_slider:SetValue(val - dir);
            update_loadouts_lhs();
        end
    end);

    sw_frame.loadouts_frame.rhs_list = CreateFrame("ScrollFrame", "sw_loadout_frame_rhs", sw_frame.loadouts_frame);
    sw_frame.loadouts_frame.rhs_list:SetWidth(400-180);
    sw_frame.loadouts_frame.rhs_list:SetHeight(600-30-30);
    sw_frame.loadouts_frame.rhs_list:SetPoint("TOPLEFT", sw_frame, 180, -50);

    sw_frame.loadouts_frame.loadouts_select_label = sw_frame.loadouts_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.loadouts_select_label:SetFontObject(font);
    sw_frame.loadouts_frame.loadouts_select_label:SetPoint("TOPLEFT", sw_frame.loadouts_frame.lhs_list, 15, -2);
    sw_frame.loadouts_frame.loadouts_select_label:SetText("Select Active Loadout");
    sw_frame.loadouts_frame.loadouts_select_label:SetTextColor(232.0/255, 225.0/255, 32.0/255);

    sw_frame.loadouts_frame.loadouts_slider =
        CreateFrame("Slider", "sw_loadouts_slider", sw_frame.loadouts_frame.lhs_list, "OptionsSliderTemplate");
    sw_frame.loadouts_frame.loadouts_slider:SetOrientation('VERTICAL');
    sw_frame.loadouts_frame.loadouts_slider:SetPoint("TOPRIGHT", 0, -14);
    sw_frame.loadouts_frame.loadouts_slider:SetSize(15, 248);
    sw_frame.loadouts_frame.lhs_list.num_loadouts_can_fit =
        math.floor(sw_frame.loadouts_frame.loadouts_slider:GetHeight()/20);
    getglobal(sw_frame.loadouts_frame.loadouts_slider:GetName()..'Text'):SetText("");
    getglobal(sw_frame.loadouts_frame.loadouts_slider:GetName()..'Low'):SetText("");
    getglobal(sw_frame.loadouts_frame.loadouts_slider:GetName()..'High'):SetText("");
    sw_frame.loadouts_frame.loadouts_slider:SetMinMaxValues(0, 0);
    sw_frame.loadouts_frame.loadouts_slider:SetValue(0);
    sw_frame.loadouts_frame.loadouts_slider:SetValueStep(1);
    sw_frame.loadouts_frame.loadouts_slider:SetScript("OnValueChanged", function(self, val)
        update_loadouts_lhs();
    end);

    sw_frame.loadouts_frame.rhs_list.self_buffs_frame = 
        CreateFrame("ScrollFrame", "sw_loadout_frame_rhs_self_buffs", sw_frame.loadouts_frame.rhs_list);
    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetWidth(400-180);
    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetHeight(600-30-30);
    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetPoint("TOPLEFT", sw_frame.loadouts_frame.rhs_list, 0, 0);

    sw_frame.loadouts_frame.rhs_list.target_buffs_frame = 
        CreateFrame("ScrollFrame", "sw_loadout_frame_rhs_target_buffs", sw_frame.loadouts_frame.rhs_list);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetWidth(400-180);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetHeight(600-30-30);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetPoint("TOPLEFT", sw_frame.loadouts_frame.rhs_list, 0, 0);
    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:Hide();

    sw_frame.loadouts_frame.rhs_list.num_buffs_checked = 0;
    sw_frame.loadouts_frame.rhs_list.num_target_buffs_checked = 0;

    local y_offset_lhs = 0;
    
    sw_frame.loadouts_frame.rhs_list.delete_button =
        CreateFrame("Button", "sw_loadouts_delete_button", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.delete_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.delete_button:SetText("Delete Loadout");
    sw_frame.loadouts_frame.rhs_list.delete_button:SetSize(170, 25);
    sw_frame.loadouts_frame.rhs_list.delete_button:SetScript("OnClick", function(self)
        
        if sw_frame.loadouts_frame.lhs_list.num_loadouts == 1 then
            return;
        end

        sw_frame.loadouts_frame.lhs_list.loadouts[
            sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(false);
        
        for i = sw_frame.loadouts_frame.lhs_list.num_loadouts - 1, sw_frame.loadouts_frame.lhs_list.active_loadout, -1  do
            sw_frame.loadouts_frame.lhs_list.loadouts[i].loadout = sw_frame.loadouts_frame.lhs_list.loadouts[i+1].loadout;
        end

        sw_frame.loadouts_frame.lhs_list.loadouts[
            sw_frame.loadouts_frame.lhs_list.num_loadouts].check_button:Hide();

        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.num_loadouts] = nil;

        sw_frame.loadouts_frame.lhs_list.num_loadouts = sw_frame.loadouts_frame.lhs_list.num_loadouts - 1;

        sw_frame.loadouts_frame.lhs_list.active_loadout = sw_frame.loadouts_frame.lhs_list.num_loadouts;

        update_loadouts_lhs();
    end);

    y_offset_lhs = y_offset_lhs - 30;

    sw_frame.loadouts_frame.rhs_list.export_button =
        CreateFrame("Button", "sw_loadouts_export_button", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.export_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.export_button:SetText("Create Loadout as a Copy");
    sw_frame.loadouts_frame.rhs_list.export_button:SetSize(170, 25);
    sw_frame.loadouts_frame.rhs_list.export_button:SetScript("OnClick", function(self)

        local loadout = active_loadout_base();
        create_new_loadout_as_copy(loadout, loadout.name);
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.loadout_talent_label = sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_talent_label:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_talent_label:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_talent_label:SetText("Custom talents (Wowhead link)");

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.talent_editbox = 
        CreateFrame("EditBox", "sw_loadout_talent_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 20, y_offset_lhs - 2);
    --sw_frame.loadouts_frame.rhs_list.talent_editbox:SetText("");
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetSize(150, 15);
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetAutoFocus(false);
    local talent_editbox = function(self)

        local txt = self:GetText();
        local loadout = active_loadout_base();

        if txt == wowhead_talent_link(loadout.talents_code) then
            return;
        end

        if loadout.is_dynamic_loadout then
            sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout = 
                static_loadout_from_dynamic(loadout);
            sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.is_dynamic_loadout 
                = false;
        end

        local loadout_before = active_loadout_talented_copy();

        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.talents_code = wowhead_talent_code_from_url(txt);

        local loadout_after = active_loadout_talented_copy();

        sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(false);

        static_rescale_from_talents_diff(loadout_after, loadout_before);

        update_loadouts_lhs();
    end

    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetScript("OnEnterPressed", function(self) 
        talent_editbox(self);
        self:ClearFocus();
    end);
    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetScript("OnEscapePressed", function(self) 
        talent_editbox(self);
        self:ClearFocus();
    end);

    sw_frame.loadouts_frame.rhs_list.talent_editbox:SetScript("OnTextChanged", function(self) 
        talent_editbox(self);
        self:ClearFocus();
    end);


    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.loadout_rename_label = 
        sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_rename_label:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_rename_label:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_rename_label:SetText("Rename");

    sw_frame.loadouts_frame.rhs_list.name_editbox = 
        CreateFrame("EditBox", "sw_loadout_name_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 65, y_offset_lhs - 2);
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetText("");
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetSize(110, 15);
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetAutoFocus(false);
    local editbox_save = function(self)

        local txt = self:GetText();
        sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.name = txt;

        update_loadouts_lhs();
    end

    sw_frame.loadouts_frame.rhs_list.name_editbox:SetScript("OnEnterPressed", function(self) 
        editbox_save(self);
        self:ClearFocus();
    end);
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetScript("OnEscapePressed", function(self) 
        editbox_save(self);
        self:ClearFocus();
    end);
    sw_frame.loadouts_frame.rhs_list.name_editbox:SetScript("OnTextChanged", editbox_save);

    y_offset_lhs = y_offset_lhs - 20;


    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana = 
        sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana:SetText("Extra mana (pots)");

    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 120, y_offset_lhs - 2);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetSize(50, 15);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetAutoFocus(false);

    local mana_editbox = function(self)

        local txt = self:GetText();
        
        local mana = tonumber(txt);
        if mana then
            active_loadout_base().extra_mana = mana;
            
        else
            self:SetText("0");
            active_loadout_base().extra_mana = 0;
        end

    	self:ClearFocus();
    end

    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetScript("OnEnterPressed", mana_editbox);
    sw_frame.loadouts_frame.rhs_list.loadout_extra_mana_editbox:SetScript("OnEscapePressed", mana_editbox);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.loadout_level_label = 
        sw_frame.loadouts_frame.rhs_list:CreateFontString(nil, "OVERLAY");
    sw_frame.loadouts_frame.rhs_list.loadout_level_label:SetFontObject(font);
    sw_frame.loadouts_frame.rhs_list.loadout_level_label:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 15, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_level_label:SetText("Default target level");

    sw_frame.loadouts_frame.rhs_list.level_editbox = CreateFrame("EditBox", "sw_loadout_lvl_editbox", sw_frame.loadouts_frame.rhs_list, "InputBoxTemplate");
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 130, y_offset_lhs - 2);
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetText("");
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetSize(40, 15);
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetAutoFocus(false);

    local editbox_lvl = function(self)

        local txt = self:GetText();
        
        local lvl = tonumber(txt);
        if lvl and lvl == math.floor(lvl) and lvl >= 1 and lvl <= 63 then

            active_loadout_base().target_lvl = lvl;
            
        else
            self:SetText(""..active_loadout_base().target_lvl); 
        end

    	self:ClearFocus();
    end

    sw_frame.loadouts_frame.rhs_list.level_editbox:SetScript("OnEnterPressed", editbox_lvl);
    sw_frame.loadouts_frame.rhs_list.level_editbox:SetScript("OnEscapePressed", editbox_lvl);

    y_offset_lhs = y_offset_lhs - 25;

    sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_dynamic_target_level", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton:GetName()..'Text'):SetText("Use target's level");
    getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton:GetName()).tooltip = 
        "Only works with dynamic loadouts. If level is unknown '?' 3 levels above yourself is assumed";

    sw_frame.loadouts_frame.rhs_list.dynamic_target_lvl_checkbutton :SetScript("OnClick", function(self)
        active_loadout_base().use_dynamic_target_lvl = self:GetChecked();
    end)

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.dynamic_button = 
        CreateFrame("CheckButton", "sw_loadout_dynamic_check", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.dynamic_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_button:GetName()..'Text'):SetText("Dynamic loadout");
    getglobal(sw_frame.loadouts_frame.rhs_list.dynamic_button:GetName()).tooltip = 
        "Dynamic loadouts use your current equipment, set bonuses, talents. In addition, self buffs and target's buffs/debuffs may be applied if so chosen";

    sw_frame.loadouts_frame.rhs_list.dynamic_button:SetScript("OnClick", function(self)
        
        if self:GetChecked() then

            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.is_dynamic_loadout = true;

            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout = empty_loadout_with_buffs(active_loadout_base());

            
            sw_frame.loadouts_frame.rhs_list.static_button:SetChecked(false);
        else

            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.is_dynamic_loadout = false;

            sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout = 
                static_loadout_from_dynamic(active_loadout_base());

            sw_frame.loadouts_frame.rhs_list.static_button:SetChecked(true);
        end
        update_loadouts_rhs();
    end);

    y_offset_lhs = y_offset_lhs - 20;
    sw_frame.loadouts_frame.rhs_list.static_button = 
        CreateFrame("CheckButton", "sw_loadout_static_check_button", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.static_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    getglobal(sw_frame.loadouts_frame.rhs_list.static_button:GetName()..'Text'):SetText("Static loadout");
    getglobal(sw_frame.loadouts_frame.rhs_list.static_button:GetName()).tooltip =
        "Static loadouts never change and can be used to create custom setups. When checked, a static loadout is a snapshot of a dynamic loadout or can be created with modified stats through the stat comparison tool. Max mana is always assumed before Cast until OOM type of fight starts."
    sw_frame.loadouts_frame.rhs_list.static_button:SetScript("OnClick", function(self)

        if self:GetChecked() then
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.is_dynamic_loadout = false;

            sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout = 
                static_loadout_from_dynamic(active_loadout_base());

            sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(false);
        else
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.is_dynamic_loadout = true;

            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout = empty_loadout_with_buffs(active_loadout_base());

            sw_frame.loadouts_frame.rhs_list.dynamic_button:SetChecked(true);
        end
        update_loadouts_rhs();
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button = 
        CreateFrame("CheckButton", "sw_loadout_always_apply_buffs_button", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.apply_buffs_button = 
        CreateFrame("CheckButton", "sw_loadout_apply_buffs_button", sw_frame.loadouts_frame.rhs_list, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    getglobal(sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:GetName() .. 'Text'):SetText("Apply buffs ALWAYS");
    getglobal(sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:GetName()).tooltip = 
        "The selected buffs always be applied, but only if not already active";
    sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetScript("OnClick", function(self)

        if self:GetChecked() then
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.always_assume_buffs = true;
            sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetChecked(false);
        else
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.always_assume_buffs = false;
            sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetChecked(true);
        end
            
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    getglobal(sw_frame.loadouts_frame.rhs_list.apply_buffs_button:GetName() .. 'Text'):SetText("Apply buffs IF ACTIVE");
    getglobal(sw_frame.loadouts_frame.rhs_list.apply_buffs_button:GetName()).tooltip =
        "The selected buffs will be applied only if already active";
    sw_frame.loadouts_frame.rhs_list.apply_buffs_button:SetScript("OnClick", function(self)

        if self:GetChecked() then
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.always_assume_buffs = false;
            sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetChecked(false);
        else
            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.always_assume_buffs = true;
            sw_frame.loadouts_frame.rhs_list.always_apply_buffs_button:SetChecked(true);
        end
            
    end);

    y_offset_lhs = y_offset_lhs - 20;

    sw_frame.loadouts_frame.rhs_list.loadout_dump =
        CreateFrame("Button", "sw_loadouts_loadout_dump", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.loadout_dump:SetPoint("BOTTOMLEFT", sw_frame.loadouts_frame.lhs_list, 10, y_offset_lhs);
    sw_frame.loadouts_frame.rhs_list.loadout_dump:SetText("Debug print Loadout");
    sw_frame.loadouts_frame.rhs_list.loadout_dump:SetSize(170, 20);
    sw_frame.loadouts_frame.rhs_list.loadout_dump:SetScript("OnClick", function(self)

        print_loadout(active_loadout_buffed_talented_copy());
    end);

    local y_offset_rhs = 0;

    sw_frame.loadouts_frame.rhs_list.buffs_button =
        CreateFrame("Button", "sw_frame_buffs_button", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetScript("OnClick", function(self)

        sw_frame.loadouts_frame.rhs_list.self_buffs_frame:Show();

        sw_frame.loadouts_frame.rhs_list.buffs_button:LockHighlight();
        sw_frame.loadouts_frame.rhs_list.buffs_button:SetButtonState("PUSHED");

        sw_frame.loadouts_frame.rhs_list.target_buffs_frame:Hide();

        sw_frame.loadouts_frame.rhs_list.target_buffs_button:UnlockHighlight();
        sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetButtonState("NORMAL");

        update_loadouts_rhs();

    end);
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetPoint("TOPLEFT", 20, y_offset_rhs);
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetText("SELF");
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetWidth(93);
    sw_frame.loadouts_frame.rhs_list.buffs_button:LockHighlight();
    sw_frame.loadouts_frame.rhs_list.buffs_button:SetButtonState("PUSHED");

    sw_frame.loadouts_frame.rhs_list.target_buffs_button =
        CreateFrame("Button", "sw_frame_target_buffs_button", sw_frame.loadouts_frame.rhs_list, "UIPanelButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetScript("OnClick", function(self)

        sw_frame.loadouts_frame.rhs_list.target_buffs_frame:Show();

        sw_frame.loadouts_frame.rhs_list.target_buffs_button:LockHighlight();
        sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetButtonState("PUSHED");

        sw_frame.loadouts_frame.rhs_list.self_buffs_frame:Hide();

        sw_frame.loadouts_frame.rhs_list.buffs_button:UnlockHighlight();
        sw_frame.loadouts_frame.rhs_list.buffs_button:SetButtonState("NORMAL");

        update_loadouts_rhs();

    end);
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetPoint("TOPLEFT", 93 + 20, y_offset_rhs);
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetText("TARGET");
    sw_frame.loadouts_frame.rhs_list.target_buffs_button:SetWidth(93);

    y_offset_rhs = y_offset_rhs - 20;

    sw_frame.loadouts_frame.rhs_list.buffs = {};
    sw_frame.loadouts_frame.rhs_list.buffs.num_buffs = 0;

    sw_frame.loadouts_frame.rhs_list.target_buffs = {};
    sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs = 0;

    local check_button_buff_func = function(self)

        local loadout = sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout;
        if self:GetChecked() then
            if self.buff_type == "self" then
                loadout.buffs[self.buff_lname] = self.buff_info;
                sw_frame.loadouts_frame.rhs_list.num_checked_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_buffs + 1;
            elseif self.buff_type == "target_buffs" then
                loadout.target_buffs[self.buff_lname] = self.buff_info;
                sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs + 1;
            end

        else    
            if self.buff_type == "self" then
                loadout.buffs[self.buff_lname] = nil;
                sw_frame.loadouts_frame.rhs_list.num_checked_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_buffs - 1;
            elseif self.buff_type == "target_buffs" then
                loadout.target_buffs[self.buff_lname] = nil;
                sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs = sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs - 1;
            end
        end

        if sw_frame.loadouts_frame.rhs_list.num_checked_buffs == 0 then
            sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetChecked(true);
        end

        if sw_frame.loadouts_frame.rhs_list.num_checked_target_buffs == 0 then
            sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(false);
        else
            sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetChecked(true);
        end
    end

    local y_offset_rhs_buffs = y_offset_rhs - 3;
    local y_offset_rhs_target_buffs = y_offset_rhs - 3;

    -- add select all optoin for both buffs and debuffs

    sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_select_all_buffs", sw_frame.loadouts_frame.rhs_list.self_buffs_frame, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetPoint("TOPLEFT", 20, y_offset_rhs_buffs);
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:GetName() .. 'Text'):SetText("SELECT ALL/NONE");
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:GetName() .. 'Text'):SetTextColor(1, 0, 0);

    sw_frame.loadouts_frame.rhs_list.select_all_buffs_checkbutton:SetScript("OnClick", function(self) 
        if self:GetChecked() then

            active_loadout_base().buffs = {};

            for i = 1, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs do
                active_loadout_base().buffs[sw_frame.loadouts_frame.rhs_list.buffs[i].checkbutton.buff_lname] =
                    sw_frame.loadouts_frame.rhs_list.buffs[i].checkbutton.buff_info;
            end
        else
            active_loadout_base().buffs = {};
        end

        update_loadouts_rhs();
    end);


    sw_frame.loadouts_frame.rhs_list.target_resi_editbox = {};

    local num_target_resi_labels = 6;
    local target_resi_labels = {
        [2] = {
            label = "Holy",
            color = {255/255, 255/255, 153/255}
        },
        [3] = {
            label = "Fire",
            color = {255/255, 0, 0}
        },
        [4] = {
            label = "Nature",
            color = {0, 153/255, 51/255}
        },
        [5] = {
            label = "Frost",
            color = {51/255, 102/255, 255/255}
        },
        [6] = {
            label = "Shadow",
            color = {102/255, 0, 102/255}
        },
        [7] = {
            label = "Arcane",
            color = {102/255, 0, 204/255}
        }
    };

    local target_resi_label = sw_frame.loadouts_frame.rhs_list.target_buffs_frame:CreateFontString(nil, "OVERLAY");

    target_resi_label:SetFontObject(font);
    target_resi_label:SetPoint("TOPLEFT", 22, y_offset_rhs_target_buffs);
    target_resi_label:SetText("Presumed enemy resistances");

    y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 15;

    for i = 2, 7 do

        local resi_school_label = sw_frame.loadouts_frame.rhs_list.target_buffs_frame:CreateFontString(nil, "OVERLAY");

        resi_school_label:SetFontObject(font);
        resi_school_label:SetPoint("TOPLEFT", 22, y_offset_rhs_target_buffs);
        resi_school_label:SetText(target_resi_labels[i].label);
        resi_school_label:SetTextColor(
            target_resi_labels[i].color[1], target_resi_labels[i].color[2], target_resi_labels[i].color[3]
        );


        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i] = 
            CreateFrame("EditBox", "sw_"..target_resi_labels[i].label.."editbox", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, "InputBoxTemplate");

        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i].school_type = i;
        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetPoint("TOPLEFT", 130, y_offset_rhs_target_buffs);
        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetAutoFocus(false);
        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetSize(60, 10);
        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetScript("OnTextChanged", function(self)

            if self:GetText() == "" then
                sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_res_by_school[self.school_type] = 0;

            elseif not string.match(self:GetText(), "[^0123456789]") then
                sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_res_by_school[self.school_type] = tonumber(self:GetText());
            else 
                self:ClearFocus();
                self:SetText(tostring(sw_frame.loadouts_frame.lhs_list.loadouts[sw_frame.loadouts_frame.lhs_list.active_loadout].loadout.target_res_by_school[self.school_type]));
            end
        end);

        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetScript("OnEnterPressed", function(self)
        	self:ClearFocus()
        end);
        
        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetScript("OnEscapePressed", function(self)
        	self:ClearFocus()
        end);

        sw_frame.loadouts_frame.rhs_list.target_resi_editbox[i]:SetScript("OnTabPressed", function(self)

            local next_index = 0;
            if IsShiftKeyDown() then
                next_index = 1 + ((i-3) %num_target_resi_labels);
            else
                next_index = 1 + ((i-1) %num_target_resi_labels);

            end
        	self:ClearFocus()
            sw_frame.loadouts_frame.rhs_list.target_resi_editbox[next_index + 1]:SetFocus();
        end);


        y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 15;
    end

    sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton = 
        CreateFrame("CheckButton", "sw_loadout_select_all_target_buffs", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, "ChatConfigCheckButtonTemplate");
    sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetPoint("TOPLEFT", 20, y_offset_rhs_target_buffs);
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:GetName() .. 'Text'):SetText("SELECT ALL/NONE");
    getglobal(sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:GetName() .. 'Text'):SetTextColor(1, 0, 0);
    sw_frame.loadouts_frame.rhs_list.select_all_target_buffs_checkbutton:SetScript("OnClick", function(self)
        if self:GetChecked() then

            
            for  i = 1, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs  do
                active_loadout_base().target_buffs[sw_frame.loadouts_frame.rhs_list.target_buffs[i].checkbutton.buff_lname] =
                    sw_frame.loadouts_frame.rhs_list.target_buffs[i].checkbutton.buff_info;
            end
        else
            active_loadout_base().target_buffs = {};
        end
        update_loadouts_rhs();
    end);


    y_offset_rhs_buffs = y_offset_rhs_buffs - 20;
    y_offset_rhs_target_buffs = y_offset_rhs_target_buffs - 20;

    sw_frame.loadouts_frame.rhs_list.self_buffs_y_offset_start = y_offset_rhs_buffs;
    sw_frame.loadouts_frame.rhs_list.target_buffs_y_offset_start = y_offset_rhs_target_buffs;

    for k, v in pairs(buffs) do
        if bit.band(filter_flags_active, v.filter) ~= 0 then
            create_loadout_buff_checkbutton(
                sw_frame.loadouts_frame.rhs_list.buffs, k, v, "self", 
                sw_frame.loadouts_frame.rhs_list.self_buffs_frame, check_button_buff_func
            );
        end
    end
    for k, v in pairs(target_buffs) do
        if bit.band(filter_flags_active, v.filter) ~= 0 then
            create_loadout_buff_checkbutton(
                sw_frame.loadouts_frame.rhs_list.target_buffs, k, v, "target_buffs", 
                sw_frame.loadouts_frame.rhs_list.target_buffs_frame, check_button_buff_func
            );
        end
    end

    sw_frame.loadouts_frame.self_buffs_slider =
        CreateFrame("Slider", "sw_self_buffs_slider", sw_frame.loadouts_frame.rhs_list.self_buffs_frame, "OptionsSliderTemplate");
    sw_frame.loadouts_frame.self_buffs_slider:SetOrientation('VERTICAL');
    sw_frame.loadouts_frame.self_buffs_slider:SetPoint("TOPRIGHT", -10, -42);
    sw_frame.loadouts_frame.self_buffs_slider:SetSize(15, 505);
    sw_frame.loadouts_frame.rhs_list.buffs.num_buffs_can_fit =
        math.floor(sw_frame.loadouts_frame.self_buffs_slider:GetHeight()/20);
    sw_frame.loadouts_frame.self_buffs_slider:SetMinMaxValues(
        0, 
        max(0, sw_frame.loadouts_frame.rhs_list.buffs.num_buffs - sw_frame.loadouts_frame.rhs_list.buffs.num_buffs_can_fit)
    );
    getglobal(sw_frame.loadouts_frame.self_buffs_slider:GetName()..'Text'):SetText("");
    getglobal(sw_frame.loadouts_frame.self_buffs_slider:GetName()..'Low'):SetText("");
    getglobal(sw_frame.loadouts_frame.self_buffs_slider:GetName()..'High'):SetText("");
    sw_frame.loadouts_frame.self_buffs_slider:SetValue(0);
    sw_frame.loadouts_frame.self_buffs_slider:SetValueStep(1);
    sw_frame.loadouts_frame.self_buffs_slider:SetScript("OnValueChanged", function(self, val)

        update_loadouts_rhs();
    end);

    sw_frame.loadouts_frame.rhs_list.self_buffs_frame:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.loadouts_frame.self_buffs_slider:GetMinMaxValues();
        local val = sw_frame.loadouts_frame.self_buffs_slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.loadouts_frame.self_buffs_slider:SetValue(val - dir);
            update_loadouts_rhs();
        end
    end);

    sw_frame.loadouts_frame.target_buffs_slider =
        CreateFrame("Slider", "sw_target_buffs_slider", sw_frame.loadouts_frame.rhs_list.target_buffs_frame, "OptionsSliderTemplate");
    sw_frame.loadouts_frame.target_buffs_slider:SetOrientation('VERTICAL');
    sw_frame.loadouts_frame.target_buffs_slider:SetPoint("TOPRIGHT", -10, -147);
    sw_frame.loadouts_frame.target_buffs_slider:SetSize(15, 400);
    sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs_can_fit = 
        math.floor(sw_frame.loadouts_frame.target_buffs_slider:GetHeight()/20);
    sw_frame.loadouts_frame.target_buffs_slider:SetMinMaxValues(
        0, 
        max(0, sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs - sw_frame.loadouts_frame.rhs_list.target_buffs.num_buffs_can_fit)
    );
    getglobal(sw_frame.loadouts_frame.target_buffs_slider:GetName()..'Text'):SetText("");
    getglobal(sw_frame.loadouts_frame.target_buffs_slider:GetName()..'Low'):SetText("");
    getglobal(sw_frame.loadouts_frame.target_buffs_slider:GetName()..'High'):SetText("");
    sw_frame.loadouts_frame.target_buffs_slider:SetValue(0);
    sw_frame.loadouts_frame.target_buffs_slider:SetValueStep(1);
    sw_frame.loadouts_frame.target_buffs_slider:SetScript("OnValueChanged", function(self, val)
        update_loadouts_rhs();
    end);

    sw_frame.loadouts_frame.rhs_list.target_buffs_frame:SetScript("OnMouseWheel", function(self, dir)
        local min_val, max_val = sw_frame.loadouts_frame.target_buffs_slider:GetMinMaxValues();
        local val = sw_frame.loadouts_frame.target_buffs_slider:GetValue();
        if val - dir >= min_val and val - dir <= max_val then
            sw_frame.loadouts_frame.target_buffs_slider:SetValue(val - dir);
            update_loadouts_rhs();
        end
    end);


end

local function action_id_of_button(button)

    if action_bar_addon_name == "Default" then
        return button.action;
    else
        -- Dominos seems to set GetAttribute function for the 1-6 default blizz bars
        return button:GetAttribute("action");
    end
end

local function gather_spell_icons()


    local action_bar_frame_names = {};
    local spell_book_frames = {};

    local index = 1;
    -- gather spell book icons
    if false then -- check for some common addons if they overrite spellbook frames

    else -- default spellbook frames
        for i = 1, 16 do

            spell_book_frames[i] = { 
                frame = getfenv()["SpellButton"..i];
            };
        end
    end
    for i = 1, 16 do

        spell_book_frames[i].overlay_frames = {nil, nil, nil};
    end

    -- danni er faggi

    -- gather action bar icons
    index = 1;
    if IsAddOnLoaded("Bartender4") then -- check for some common addons if they overrite spellbook frames

        for i = 1, 120 do
            action_bar_frame_names[i] = "BT4Button"..i;
        end
        action_bar_addon_name = "Bartender4";

    elseif IsAddOnLoaded("ElvUI") then -- check for some common addons if they overrite spellbook frames

        local elvi_bar_order_to_match_action_ids = {1, 6, 5, 4, 2, 3, 7, 8, 9, 10};
        for i = 1, 10 do
            for j = 1, 12 do
                action_bar_frame_names[index] = 
                    "ElvUI_Bar"..elvi_bar_order_to_match_action_ids[i].."Button"..j;

                index = index + 1;
            end
        end
        action_bar_addon_name = "ElvUI";

    elseif IsAddOnLoaded("Dominos") then -- check for some common addons if they overrite spellbook frames

        local bars = {
            "ActionButton", "DominosActionButton", "MultiBarRightButton",
            "MultiBarLeftButton", "MultiBarBottomRightButton", "MultiBarBottomLeftButton"
        };
        index = 1;
        for k, v in pairs(bars) do
            for j = 1, 12 do
                action_bar_frame_names[index] = v..j;

                index = index + 1;
            end
        end

        local dominos_button_index = 13;
        for i = index, 120 do
            action_bar_frame_names[i] = "DominosActionButton"..dominos_button_index;

            dominos_button_index = dominos_button_index + 1;
        end
        action_bar_addon_name = "Dominos";

    else -- default action bars
        
        local bars = {
            "ActionButton", "BonusActionButton", "MultiBarRightButton",
            "MultiBarLeftButton", "MultiBarBottomRightButton", "MultiBarBottomLeftButton"
        };
        index = 1;
        for k, v in pairs(bars) do
            for j = 1, 12 do
                action_bar_frame_names[index] = v..j;

                index = index + 1;
            end
        end
        action_bar_addon_name = "Default";
    end

    local action_bar_frames_of_interest = {};

    for k, v in pairs(action_bar_frame_names) do

        local frame = getfenv()[v];
        if frame then

            local action_id = action_id_of_button(frame);
            if action_id then
                local spell_id = 0;
                local action_type, id, _ = GetActionInfo(action_id);
                if action_type == "macro" then
                     spell_id, _ = GetMacroSpell(id);
                elseif action_type == "spell" then
                     spell_id = id;
                else
                    spell_id = 0;
                end
                if not spells[spell_id] then
                    spell_id = 0;
                end

                if spell_id ~= 0 then

                    action_bar_frames_of_interest[action_id] = {};
                    action_bar_frames_of_interest[action_id].spell_id = spell_id;
                    action_bar_frames_of_interest[action_id].frame = frame; 
                    action_bar_frames_of_interest[action_id].overlay_frames = {nil, nil, nil}
                end
            end
                
        end
    end
    

    return {
        bar_names = action_bar_frame_names,
        bars = action_bar_frames_of_interest,
        book = spell_book_frames
    };
end

local function on_special_action_bar_changed()

    for i = 1, 12 do
    
        local frame = getfenv()[__sw__icon_frames.bar_names[i]];
        if frame then
    
            local action_id = action_id_of_button(frame);
                
            local spell_id = 0;
            local action_type, id, _ = GetActionInfo(action_id);
            if action_type == "macro" then
                 spell_id, _ = GetMacroSpell(id);
            elseif action_type == "spell" then
                 spell_id = id;
            else
                spell_id = 0;
            end
            if not spells[spell_id] then
                spell_id = 0;
            end
    
            if spell_id ~= 0 then
    
                if __sw__icon_frames.bars[i] then
                    for j = 1, 3 do
                        if __sw__icon_frames.bars[i].overlay_frames[j] then
                            __sw__icon_frames.bars[i].overlay_frames[j]:SetText("");
                            __sw__icon_frames.bars[i].overlay_frames[j]:Hide();
                        end
                    end
                end
    
                __sw__icon_frames.bars[i] = {};
                __sw__icon_frames.bars[i].spell_id = spell_id;
                __sw__icon_frames.bars[i].frame = frame; 
                __sw__icon_frames.bars[i].overlay_frames = {nil, nil, nil}
            else
                if __sw__icon_frames.bars[i] then
                    for j = 1, 3 do
                        if __sw__icon_frames.bars[i].overlay_frames[j] then
                            __sw__icon_frames.bars[i].overlay_frames[j]:SetText("");
                            __sw__icon_frames.bars[i].overlay_frames[j]:Hide();
                        end
                    end
                end
                __sw__icon_frames.bars[i] = nil; 
            end
        end
    end
end


local function create_sw_base_gui()

    sw_frame = CreateFrame("Frame", "sw_frame", UIParent, "BasicFrameTemplate, BasicFrameTemplateWithInset");

    sw_frame:SetMovable(true)
    sw_frame:EnableMouse(true)
    sw_frame:RegisterForDrag("LeftButton")
    sw_frame:SetScript("OnDragStart", sw_frame.StartMoving)
    sw_frame:SetScript("OnDragStop", sw_frame.StopMovingOrSizing)

    sw_frame.settings_frame = CreateFrame("ScrollFrame", "sw_settings_frame", sw_frame);
    sw_frame.loadouts_frame = CreateFrame("ScrollFrame", "sw_loadout_frame ", sw_frame);
    sw_frame.stat_comparison_frame = CreateFrame("ScrollFrame", "sw_stat_comparison_frame", sw_frame);

    -- TODO: Reorganize this into a table switch
    sw_frame:RegisterEvent("ADDON_LOADED");
    sw_frame:RegisterEvent("PLAYER_LOGIN");
    sw_frame:RegisterEvent("PLAYER_LOGOUT");
    sw_frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
    --sw_frame:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
    --sw_frame:RegisterEvent("ACTIONBAR_UPDATE_STATE");
    sw_frame:RegisterEvent("UPDATE_STEALTH");
    sw_frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
    if class == "PALADIN" then
        sw_frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
    end
    sw_frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM");

    sw_frame:SetWidth(400);
    sw_frame:SetHeight(600);
    sw_frame:SetPoint("TOPLEFT", 400, -30);

    sw_frame.title = sw_frame:CreateFontString(nil, "OVERLAY");
    sw_frame.title:SetFontObject(font)
    sw_frame.title:SetText("Stat Weights Classic");
    sw_frame.title:SetPoint("CENTER", sw_frame.TitleBg, "CENTER", 11, 0);

    sw_frame:SetScript("OnEvent", function(self, event, msg, msg2, msg3)

        if event == "UNIT_SPELLCAST_SUCCEEDED" and msg3 == 53563 then -- beacon
             beacon_snapshot_time = addon_running_time;

        elseif event == "ADDON_LOADED" and msg == "stat_weights_classic" then

            if not class_is_supported then
                return;
            end
            create_sw_gui_stat_comparison_frame();

            if not __sw__persistent_data_per_char then
                __sw__persistent_data_per_char = {};
            end
            if __sw__use_defaults__ then
                __sw__persistent_data_per_char.settings = nil;
                __sw__persistent_data_per_char.loadouts = nil;
            end

            if not __sw__persistent_data_per_char.settings then
                __sw__persistent_data_per_char.settings = default_sw_settings();
            end

            create_sw_gui_settings_frame();

            if libstub_data_broker then
                local sw_launcher = libstub_data_broker:NewDataObject(sw_addon_name, {
                    type = "launcher",
                    icon = "Interface\\Icons\\spell_fire_elementaldevastation",
                    OnClick = function(self, button)
                        if button == "LeftButton" or button == "RightButton" then 
                            if sw_frame:IsShown() then 
                                 sw_frame:Hide() 
                            else 
                                 sw_frame:Show() 
                            end
                        end
                    end,
                    OnTooltipShow = function(tooltip)
                        tooltip:AddLine(sw_addon_name..": Version "..version);
                        tooltip:AddLine("Left/Right click: Toggle addon frame");
                        tooltip:AddLine("This icon can be removed in the addon's settings tab");
                        tooltip:AddLine("If this addon confuses you, instructions and pointers at");
                        tooltip:AddLine("https://www.curseforge.com/wow/addons/stat-weights-classic");
                    end,
                });
                if libstub_icon then
                    libstub_icon:Register(sw_addon_name, sw_launcher, __sw__persistent_data_per_char.settings.libstub_minimap_icon);
                end
            end

            if __sw__persistent_data_per_char.settings.libstub_minimap_icon.hide then
                libstub_icon:Hide(sw_addon_name);
            else
                libstub_icon:Show(sw_addon_name);
                sw_frame.settings_frame.libstub_icon_checkbox:SetChecked(true);
            end

            create_sw_gui_loadout_frame();

            if not __sw__persistent_data_per_char.sim_type or __sw__use_defaults__ then
                sw_frame.stat_comparison_frame.sim_type = simulation_type.spam_cast;
            else
                sw_frame.stat_comparison_frame.sim_type = __sw__persistent_data_per_char.sim_type;
            end
            if sw_frame.stat_comparison_frame.sim_type  == simulation_type.spam_cast then
                sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Show();
                sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:Hide();
            elseif sw_frame.stat_comparison_frame.sim_type  == simulation_type.cast_until_oom then
                sw_frame.stat_comparison_frame.spell_diff_header_right_spam_cast:Hide();
                sw_frame.stat_comparison_frame.spell_diff_header_right_cast_until_oom:Show();
            end
            sw_frame.stat_comparison_frame.sim_type_button.init_func();

            if __sw__persistent_data_per_char.stat_comparison_spells and not __sw__use_defaults__ then

                sw_frame.stat_comparison_frame.spells = __sw__persistent_data_per_char.stat_comparison_spells;

                update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
            end

            if not __sw__persistent_data_per_char.loadouts then
                -- load defaults
                __sw__persistent_data_per_char.loadouts = {};
                __sw__persistent_data_per_char.loadouts.loadouts_list = {};
                __sw__persistent_data_per_char.loadouts.loadouts_list[1] = default_loadout();
                __sw__persistent_data_per_char.loadouts.active_loadout = 1;
                __sw__persistent_data_per_char.loadouts.num_loadouts = 1;
            end

            sw_frame.loadouts_frame.lhs_list.loadouts = {};
            for k, v in pairs(__sw__persistent_data_per_char.loadouts.loadouts_list) do
                sw_frame.loadouts_frame.lhs_list.loadouts[k] = {};
                sw_frame.loadouts_frame.lhs_list.loadouts[k].loadout = v;
                satisfy_loadout(sw_frame.loadouts_frame.lhs_list.loadouts[k].loadout);
                
            end

            sw_frame.loadouts_frame.lhs_list.active_loadout = __sw__persistent_data_per_char.loadouts.active_loadout;
            sw_frame.loadouts_frame.lhs_list.num_loadouts = __sw__persistent_data_per_char.loadouts.num_loadouts;

            update_loadouts_lhs();

            sw_frame.loadouts_frame.lhs_list.loadouts[
                sw_frame.loadouts_frame.lhs_list.active_loadout].check_button:SetChecked(true);

            sw_activate_tab(3);
            sw_frame:Hide();

        elseif event ==  "PLAYER_LOGOUT"  then

            if not class_is_supported then
                return;
            end

            -- clear previous ui elements from spells table
            __sw__persistent_data_per_char.stat_comparison_spells = {};
            for k, v in pairs(self.stat_comparison_frame.spells) do
                __sw__persistent_data_per_char.stat_comparison_spells[k] = {};
                __sw__persistent_data_per_char.stat_comparison_spells[k].name = v.name;
            end
            __sw__persistent_data_per_char.sim_type = self.stat_comparison_frame.sim_type;

            __sw__persistent_data_per_char.loadouts = {};
            __sw__persistent_data_per_char.loadouts.loadouts_list = {};
            for k, v in pairs(self.loadouts_frame.lhs_list.loadouts) do
                __sw__persistent_data_per_char.loadouts.loadouts_list[k] = v.loadout;
            end
            __sw__persistent_data_per_char.loadouts.active_loadout = self.loadouts_frame.lhs_list.active_loadout;
            __sw__persistent_data_per_char.loadouts.num_loadouts = self.loadouts_frame.lhs_list.num_loadouts;

            -- save settings from ui
            save_sw_settings();

        elseif event ==  "PLAYER_LOGIN"  then
            if not class_is_supported then
                return;
            end
            __sw__icon_frames = gather_spell_icons();
            update_icon_overlay_settings();

            sw_addon_loaded = true;

        elseif event ==  "ACTIONBAR_SLOT_CHANGED"  then

            if not sw_addon_loaded then
                return;
            end

            local action_id = msg;

            local spell_id = 0;
            local action_type, id, _ = GetActionInfo(action_id);
            if action_type == "macro" then
                spell_id, _ = GetMacroSpell(id);
            elseif action_type == "spell" then
                 spell_id = id;
            else
                spell_id = 0;
            end
            if not spells[spell_id] then
                spell_id = 0;
            end

            if spell_id ~= 0 then
                if __sw__icon_frames.bars[action_id] then
                    for i = 1, 3 do
                        if __sw__icon_frames.bars[action_id].overlay_frames[i] then
                            __sw__icon_frames.bars[action_id].overlay_frames[i]:Hide();
                        end
                    end
                end

                __sw__icon_frames.bars[action_id] = {};
                __sw__icon_frames.bars[action_id].spell_id = spell_id;
                __sw__icon_frames.bars[action_id].frame = getfenv()[__sw__icon_frames.bar_names[action_id]]; 
                __sw__icon_frames.bars[action_id].overlay_frames = {nil, nil, nil}
            else
                if __sw__icon_frames.bars[action_id] then
                    for i = 1, 3 do
                        if __sw__icon_frames.bars[action_id].overlay_frames[i] then
                            __sw__icon_frames.bars[action_id].overlay_frames[i]:SetText("");
                            __sw__icon_frames.bars[action_id].overlay_frames[i]:Hide();
                        end
                        __sw__icon_frames.bars[action_id].overlay_frames[i] = nil;
                    end
                end
                __sw__icon_frames.bars[action_id] = nil; 
            end

            if IsStealthed() or GetShapeshiftForm() ~= 0 then
                on_special_action_bar_changed();
            end
        elseif event ==  "UPDATE_STEALTH" or event == "UPDATE_SHAPESHIFT_FORM" then

            if not sw_addon_loaded then
                return;
            end
            on_special_action_bar_changed();
        end
    end
    );

    
    sw_frame.tab1 = CreateFrame("Button", "__sw_settings_button", sw_frame, "UIPanelButtonTemplate"); 

    sw_frame.tab1:SetPoint("TOPLEFT", 10, -25);
    sw_frame.tab1:SetWidth(116);
    sw_frame.tab1:SetHeight(25);
    sw_frame.tab1:SetText("Settings");
    sw_frame.tab1:SetScript("OnClick", function()
        sw_activate_tab(1);
    end);


    sw_frame.tab2 = CreateFrame("Button", "__sw_loadouts_button", sw_frame, "UIPanelButtonTemplate"); 
    sw_frame.tab2:SetPoint("TOPLEFT", 124, -25);
    sw_frame.tab2:SetWidth(116);
    sw_frame.tab2:SetHeight(25);
    sw_frame.tab2:SetText("Loadouts");

    sw_frame.tab2:SetScript("OnClick", function()
        sw_activate_tab(2);
    end);

    sw_frame.tab3 = CreateFrame("Button", "__sw_stat_comparison_button", sw_frame, "UIPanelButtonTemplate"); 
    sw_frame.tab3:SetPoint("TOPLEFT", 238, -25);
    sw_frame.tab3:SetWidth(150);
    sw_frame.tab3:SetHeight(25);
    sw_frame.tab3:SetText("Stat Comparison");
    sw_frame.tab3:SetScript("OnClick", function()
        sw_activate_tab(3);
    end);
end

local function command(msg, editbox)
    if class_is_supported then
        if msg == "print" then
            print_loadout(active_loadout_buffed_talented_copy());
        elseif msg == "loadout" or msg == "loadouts" then
            sw_activate_tab(2);
        elseif msg == "settings" or msg == "opt" or msg == "options" or msg == "conf" or msg == "configure" then
            sw_activate_tab(1);
        elseif msg == "compare" or msg == "sc" or msg == "stat compare"  or msg == "stat" then
            sw_activate_tab(3);
        else
            sw_activate_tab(3);
        end
    end
end

if class_is_supported then
    GameTooltip:HookScript("OnTooltipSetSpell", function(tooltip, ...)
        local spell_name, spell_id = tooltip:GetSpell();
    
        local spell = get_spell(spell_id);

        local loadout = active_loadout_buffed_talented_copy();
    
        tooltip_spell_info(GameTooltip, spell, spell_name, loadout);
    
        if spell and IsShiftKeyDown() and sw_frame.stat_comparison_frame:IsShown() and 
                not sw_frame.stat_comparison_frame.spells[spell_id]then
            sw_frame.stat_comparison_frame.spells[spell_id] = {
                name = spell_name
            };
    
            update_and_display_spell_diffs(sw_frame.stat_comparison_frame);
        end
        
    end)
end

function update_icon_overlay_settings()

    sw_frame.settings_frame.icon_overlay = {};
    
    local index = 1; 

    if sw_frame.settings_frame.icon_normal_effect:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.normal,
            color = {232.0/255, 225.0/255, 32.0/255}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_crit_effect:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.crit,
            color = {252.0/255, 69.0/255, 3.0/255}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_expected_effect:GetChecked() then 
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.expected,
            color = {255.0/256, 128/256, 0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_effect_per_sec:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.effect_per_sec,
            color = {255.0/256, 128/256, 0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_effect_per_cost:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.effect_per_cost,
            color = {0.0, 1.0, 1.0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_avg_cost:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.avg_cost,
            color = {0.0, 1.0, 1.0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_avg_cast:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.avg_cast,
            color = {0.0, 1.0, 0.0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_hit:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.hit,
            color = {232.0/255, 225.0/255, 32.0/255}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_crit:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.crit_chance,
            color = {252.0/255, 69.0/255, 3.0/255}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_effect_until_oom:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.effect_until_oom,
            color = {255.0/256, 128/256, 0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_casts_until_oom:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.casts_until_oom,
            color = {0.0, 1.0, 0.0}
        };
        index = index + 1;
    end
    if sw_frame.settings_frame.icon_time_until_oom:GetChecked() then
        sw_frame.settings_frame.icon_overlay[index] = {
            label_type = icon_stat_display.time_until_oom,
            color = {0.0, 1.0, 0.0}
        };
        index = index + 1;
    end

    -- if 1, do bottom
    if not sw_frame.settings_frame.icon_overlay[2] then
        sw_frame.settings_frame.icon_overlay[3] = sw_frame.settings_frame.icon_overlay[1];
        sw_frame.settings_frame.icon_overlay[1] = nil;
    -- if 2, do top and bottom
    elseif not sw_frame.settings_frame.icon_overlay[3] then
        sw_frame.settings_frame.icon_overlay[3] = sw_frame.settings_frame.icon_overlay[2];
        sw_frame.settings_frame.icon_overlay[2] = nil;
    end

    sw_num_icon_overlay_fields_active = index - 1;

    -- hide existing overlay frames that should no longer exist
    for i = 1, 3 do

        if not sw_frame.settings_frame.icon_overlay[i] then
            for k, v in pairs(__sw__icon_frames.book) do
                if v.overlay_frames[i] then
                    v.overlay_frames[i]:Hide();
                end
            end
            for k, v in pairs(__sw__icon_frames.bars) do
                if v.overlay_frames[i] then
                    v.overlay_frames[i]:Hide();
                end
            end
        end
    end
end

local function update_spell_icon_frame(frame_info, spell_data, spell_name, loadout)

    if not spell_data.lvl_max then
        print(spell_name, spell_data.rank);
    end
    if loadout.lvl > spell_data.lvl_max and not __sw__debug__ then
        -- low spell rank

        for i = 1, 3 do
            if not frame_info.overlay_frames[i] then
                frame_info.overlay_frames[i] = frame_info.frame:CreateFontString(nil, "OVERLAY");
            end
            frame_info.overlay_frames[i]:SetFont(
                icon_overlay_font, sw_frame.settings_frame.icon_overlay_font_size, "THICKOUTLINE");
        end

        frame_info.overlay_frames[1]:SetPoint("TOP", 1, -3);
        frame_info.overlay_frames[2]:SetPoint("CENTER", 1, -1.5);
        frame_info.overlay_frames[3]:SetPoint("BOTTOM", 1, 0);

        frame_info.overlay_frames[1]:SetText("OLD");
        frame_info.overlay_frames[2]:SetText("RANK");
        frame_info.overlay_frames[3]:SetText("!!!");

        for i = 1, 3 do
            frame_info.overlay_frames[i]:SetTextColor(252.0/255, 69.0/255, 3.0/255); 
            frame_info.overlay_frames[i]:Show();
        end
        
        return;
    end

    local stats = loadout_stats_for_spell(spell_data, spell_name, loadout); 

    local spell_effect = spell_info(
       spell_data,
       stats.extra_ticks,
       stats.cast_speed,
       stats.spell_power,
       stats.flat_direct_addition,
       max(0, min(1, stats.crit)),
       max(0, min(1, stats.ot_crit)),
       stats.spell_crit_mod,
       stats.hit,
       max(0, stats.target_resi),
       stats.target_vuln_mod, stats.global_mod, stats.spell_mod, stats.spell_ot_mod,
       stats.direct_coef, stats.over_time_coef,
       stats.cost,
       spell_name, loadout
    );

    local cast_until_oom = cast_until_oom_sim(
        spell_effect, loadout.mp5, loadout.stats[stat.spirit], loadout.stats[stat.int], loadout.mana + loadout.extra_mana, loadout
    );

    for i = 1, 3 do
        
        if sw_frame.settings_frame.icon_overlay[i] then
            if not frame_info.overlay_frames[i] then
                frame_info.overlay_frames[i] = frame_info.frame:CreateFontString(nil, "OVERLAY");
            end
            frame_info.overlay_frames[i]:SetFont(
                icon_overlay_font, sw_frame.settings_frame.icon_overlay_font_size, "THICKOUTLINE");

            if i == 1 then
                frame_info.overlay_frames[i]:SetPoint("TOP", 1, -3);
            elseif i == 2 then
                frame_info.overlay_frames[i]:SetPoint("CENTER", 1, -1.5);
            elseif i == 3 then 
                frame_info.overlay_frames[i]:SetPoint("BOTTOM", 1, 0);
            end
            if sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.normal then
                frame_info.overlay_frames[i]:SetText(string.format("%d",
                    (spell_effect.min_noncrit + spell_effect.max_noncrit)/2 + spell_effect.ot_if_hit + spell_effect.absorb));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.crit  then
                if spell_effect.ot_crit_if_hit > 0  then
                    frame_info.overlay_frames[i]:SetText(string.format("%d",
                        (spell_effect.min_crit + spell_effect.max_crit)/2 + spell_effect.ot_crit_if_hit + spell_effect.absorb));
                elseif spell_effect.min_crit ~= 0.0 then
                    frame_info.overlay_frames[i]:SetText(string.format("%d", 
                        (spell_effect.min_crit + spell_effect.max_crit)/2 + spell_effect.ot_if_hit + spell_effect.absorb));
                else
                    frame_info.overlay_frames[i]:SetText("");
                end
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.expected then
                frame_info.overlay_frames[i]:SetText(string.format("%d", spell_effect.expectation));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.effect_per_sec then
                frame_info.overlay_frames[i]:SetText(string.format("%d", spell_effect.effect_per_sec));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.effect_per_cost then
                frame_info.overlay_frames[i]:SetText(string.format("%.2f", spell_effect.effect_per_cost));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.avg_cost then
                frame_info.overlay_frames[i]:SetText(string.format("%d", spell_effect.cost));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.avg_cast then
                frame_info.overlay_frames[i]:SetText(string.format("%.2f", spell_effect.cast_time));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.hit and 
                    stats.hit < 1 then

                frame_info.overlay_frames[i]:SetText(string.format("%d%%", 100*stats.hit));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.crit_chance and
                    stats.crit ~= 0 then

                frame_info.overlay_frames[i]:SetText(string.format("%.1f%%", 100*max(0, min(1, stats.crit))));
                ---
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.casts_until_oom then
                frame_info.overlay_frames[i]:SetText(string.format("%.1f", cast_until_oom.num_casts));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.effect_until_oom then
                frame_info.overlay_frames[i]:SetText(string.format("%.0f", cast_until_oom.effect));
            elseif sw_frame.settings_frame.icon_overlay[i].label_type == icon_stat_display.time_until_oom then
                frame_info.overlay_frames[i]:SetText(string.format("%.1fs", cast_until_oom.time_until_oom));
            end
            frame_info.overlay_frames[i]:SetTextColor(sw_frame.settings_frame.icon_overlay[i].color[1], 
                                                      sw_frame.settings_frame.icon_overlay[i].color[2], 
                                                      sw_frame.settings_frame.icon_overlay[i].color[3]);

            frame_info.overlay_frames[i]:Show();
        end
    end
end

__sw__icon_frames = {};

local function update_spell_icons(loadout)

    -- update spell book icons
    if SpellBookFrame:IsShown() then
        for k, v in pairs(__sw__icon_frames.book) do
            if v.frame then
                spell_name = v.frame.SpellName:GetText();
                spell_rank_name = v.frame.SpellSubName:GetText();

                local _, _, _, _, _, _, id = GetSpellInfo(spell_name, spell_rank_name);
                if v.frame and v.frame:IsShown() then
                    if spells[id] then
                        local spell_name = GetSpellInfo(id);
                        -- TODO: icon overlay not working for healing version checkbox
                        if spells[id].healing_version and sw_frame.settings_frame.icon_heal_variant:GetChecked() then
                            update_spell_icon_frame(v, spells[id].healing_version, spell_name, loadout);
                        else
                            update_spell_icon_frame(v, spells[id], spell_name, loadout);
                        end
                    else
                        for i = 1, 3 do
                            if v.overlay_frames[i] then
                                v.overlay_frames[i]:Hide();
                            end
                        end
                    end
                elseif v.frame and not v.frame:IsShown() then
                    for i = 1, 3 do
                        if v.overlay_frames[i] then
                            v.overlay_frames[i]:Hide();
                        end
                    end
                end
            end
        end
    end

    -- update action bar icons
    for k, v in pairs(__sw__icon_frames.bars) do

        if v.frame and v.frame:IsShown() then

            local id = v.spell_id;
            local spell_name = GetSpellInfo(id);

            if spells[id].healing_version and sw_frame.settings_frame.icon_heal_variant:GetChecked() then
                update_spell_icon_frame(v, spells[id].healing_version, spell_name, loadout);
            else
                update_spell_icon_frame(v, spells[id], spell_name, loadout);
            end

        else
            for i = 1, 3 do
                if v.overlay_frames[i] then
                    v.overlay_frames[i]:Hide();
                end
            end
        end
    end
end

if class_is_supported then
    create_sw_base_gui();

    UIParent:HookScript("OnUpdate", function(self, elapsed)
    
        addon_running_time = addon_running_time + snapshot_time_since_last_update;
        snapshot_time_since_last_update = snapshot_time_since_last_update + elapsed;
        
        if snapshot_time_since_last_update > 1/sw_snapshot_loadout_update_freq and 
                sw_num_icon_overlay_fields_active > 0 then

            update_spell_icons(active_loadout_buffed_talented_copy());

            snapshot_time_since_last_update = 0;
        end

    end)
else
    print("Stat Weights Classic currently does not support your class :(");
end

-- add addon to Addons list under Interface
if InterfaceOptions_AddCategory then

    local addon_interface_panel = CreateFrame("FRAME");
    addon_interface_panel.name = "Stat Weights Classic";
    InterfaceOptions_AddCategory(addon_interface_panel);


    local y_offset = -20;
    local x_offset = 20;

    local str = "";
    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Stats Weights Classic - Version"..version);

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Project Page: https://www.curseforge.com/wow/addons/stat-weights-classic");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Author: jezzi23");

    y_offset = y_offset - 30;

    addon_interface_panel.open_sw_frame_button = 
        CreateFrame("Button", "sw_addon_interface_open_frame_button", addon_interface_panel, "UIPanelButtonTemplate"); 

    addon_interface_panel.open_sw_frame_button:SetPoint("TOPLEFT", x_offset, y_offset);
    addon_interface_panel.open_sw_frame_button:SetWidth(150);
    addon_interface_panel.open_sw_frame_button:SetHeight(25);
    addon_interface_panel.open_sw_frame_button:SetText("Open Addon Frame");
    addon_interface_panel.open_sw_frame_button:SetScript("OnClick", function()
        sw_activate_tab(1);
    end);

    y_offset = y_offset - 30;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("Or type any of the following:");

    y_offset = y_offset - 15;
    x_offset = x_offset + 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sw");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sw conf");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sw loadouts");

    y_offset = y_offset - 15;

    str = addon_interface_panel:CreateFontString(nil, "OVERLAY");
    str:SetFontObject(font);
    str:SetPoint("TOPLEFT", x_offset, y_offset);
    str:SetText("/sw stat");
    
end

SLASH_STAT_WEIGHTS1 = "/sw"
SLASH_STAT_WEIGHTS2 = "/stat-weights"
SLASH_STAT_WEIGHTS3 = "/stat-weights-classic"
SLASH_STAT_WEIGHTS4 = "/swc"
SlashCmdList["STAT_WEIGHTS"] = command

__sw__debug__ = 1;
__sw__use_defaults__ = 1;
