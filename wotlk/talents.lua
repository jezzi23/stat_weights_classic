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
local ensure_exists_and_add         = addonTable.ensure_exists_and_add;
local ensure_exists_and_mul         = addonTable.ensure_exists_and_mul;
local class                         = addonTable.class;
local race                          = addonTable.race;

local magic_school                  = addonTable.magic_school;
local spell_name_to_id              = addonTable.spell_name_to_id;
local spell_names_to_id             = addonTable.spell_names_to_id;

local stat                          = addonTable.stat;

local function create_glyphs()
    if class == "PRIEST" then
        return {
            -- glyph of circle of healing
            [55675] = {
                apply = function(loadout, effects)
                    --TODO
                end,
                wowhead_id = "pbv"
            },
            -- glyph of shadow
            [55689] = {
                apply = function(loadout, effects)
                    --TODO: trackable buff?
                end,
                wowhead_id = "pc9"
            },
            -- glyph of word pain
            [55681] = {
                apply = function(loadout, effects)
                    --TODO
                end,
                wowhead_id = "pc1"
            },
            -- glyph of mind flay
            [55687] = {
                apply = function(loadout, effects)
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
                apply = function(loadout, effects)
                    local fl = spell_name_to_id["Flash Heal"];
                    ensure_exists_and_add(effects.ability.cost_mod, fl, 0.1, 0);
                end,
                wowhead_id = "pbz"
            },
            -- glyph of holy nova
            [55683] = {
                apply = function(loadout, effects)
                    local hn = spell_name_to_id["Holy Nova"];
                    ensure_exists_and_mul(effects.ability.effect_mod, hn, 1.20, 1.0);
                end,
                wowhead_id = "pc3"
            },
            -- glyph of prayer of healing
            [57195] = {
                apply = function(loadout, effects)
                    local ph = spell_name_to_id["Prayer of Healing"];
                    --TODO
                end,
                wowhead_id = "pc0"
            },
            -- glyph of smite
            [55692] = {
                apply = function(loadout, effects)
                    --TODO
                end,
                wowhead_id = "pcc"
            },
            -- glyph of shadow word death
            [55682] = {
                apply = function(loadout, effects)
                    --TODO
                end,
                wowhead_id = "pc2"
            },
            -- glyph of renew
            [55674] = {
                apply = function(loadout, effects)
                    local renew = spell_name_to_id["Renew"];

                    ensure_exists_and_add(effects.ability.extra_ticks, renew, -1, 0);
                    -- heal increase applied later calculation
                end,
                wowhead_id = "pbt"
            },
            -- glyph of lightwell
            [55673] = {
                apply = function(loadout, effects)
                    local lw = spell_name_to_id["Lightwell"];
                    ensure_exists_and_mul(effects.ability.effect_mod, lw, 1.20, 1.0);
                end,
                wowhead_id = "pbs"
            }
        };
    elseif class == "DRUID" then
        return {
            -- glyph of focus
            [62080] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Starfall"], 0.1, 0.0);
                end,
                wowhead_id = "wm0"
            },
            -- glyph of healing touch
            [54825] = {
                apply = function(loadout, effects)
                    local ht = spell_name_to_id["Healing Touch"];
                    ensure_exists_and_add(effects.ability.effect_mod, ht, -0.5, 0.0);
                    ensure_exists_and_add(effects.ability.cost_mod, ht, 0.25, 0.0);
                    ensure_exists_and_add(effects.ability.cast_mod, ht, 1.5, 0.0);
                end,
                wowhead_id = "nh9"
            },
            -- glyph of insect swarm
            [54830] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Insect Swarm"], 0.3, 0.0);
                end,
                wowhead_id = "nhe"
            },
            -- glyph of lifebloom
            [54826] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.extra_ticks, spell_name_to_id["Lifebloom"], 1, 0.0);
                end,
                wowhead_id = "nha"
            },
            -- glyph of moonfire
            [54829] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Moonfire"], -0.9 , 0.0);
                    ensure_exists_and_add(effects.ability.effect_ot_mod, spell_name_to_id["Moonfire"], 0.9 + 0.75, 0.0);
                end,
                wowhead_id = "nhd"
            },
            -- glyph of nourish
            [62971] = {
                apply = function(loadout, effects)
                    -- TODO: need to track  some druid hots and
                    --       swiftmend could be implemented in the process
                end,
                wowhead_id = "xfv"
            },
            -- glyph of rapid rejuvenation
            -- TODO: wowhead id begins with _002 intead of _001???
            [71013] = {
                apply = function(loadout, effects)
                    -- implementeed in later stage
                end,
                wowhead_id = "5b5",
                special = true
            },
            -- glyph of regrowth
            [54743] = {
                apply = function(loadout, effects)
                    -- TODO: regrowth tracking
                end,
                wowhead_id = "neq"
            },
            -- glyph of rejuvenatioin
            [54754] = {
                apply = function(loadout, effects)
                end,
                wowhead_id = "nf2"
            },
            -- glyph of wild growth
            [62970] = {
                apply = function(loadout, effects)
                    -- implemented in later stage
                end,
                wowhead_id = "xft"
            },
            -- glyph of innervate
            [54832] = {
                apply = function(loadout, effects)
                    -- implemented in later stage
                end,
                wowhead_id = "nhg"
            },
        };
    elseif class == "PALADIN" then
        return {
            -- glyph of beacon of light
            [63218] = {
                apply = function(loadout, effects)
                    -- TODO: 60 to 90
                end,
                wowhead_id = "xqj"
            },
            -- glyph of flash of light
            [54936] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Flash of Light"], 0.05, 0.0);
                end,
                wowhead_id = "nmr"
            },
            -- glyph of holy light
            [54937] = {
                apply = function(loadout, effects)
                    -- Implemented in later stage
                end,
                wowhead_id = "nms"
            },
            -- glyph of seal of light
            [54943] = {
                apply = function(loadout, effects)
                    -- Implemented in buffs
                end,
                wowhead_id = "nmz"
            },
            -- glyph of seal of wisdom
            [54940] = {
                apply = function(loadout, effects)
                    -- Implemented in buffs
                end,
                wowhead_id = "nmw"
            },
        };
    elseif class == "SHAMAN" then
        return {
            -- glyph of chain heal
            [55437] = {
                apply = function(loadout, effects)
                    -- Impemented in later stage
                end,
                wowhead_id = "p4d"
            },
            -- glyph of chain lightning
            [55449] = {
                apply = function(loadout, effects)
                    -- Impemented in later stage
                end,
                wowhead_id = "p4s"
            },
            -- glyph of earth shield
            [63279] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Earth Shield"], 0.2, 0.0);
                end,
                wowhead_id = "xsf"
            },
            -- glyph of earthliving weapon
            [55439] = {
                apply = function(loadout, effects)
                    -- TODO
                end,
                wowhead_id = "p4f"
            },
            -- glyph of flametongue weapon
            [55451] = {
                apply = function(loadout, effects)
                    -- TODO
                end,
                wowhead_id = "p4v"
            },
            -- glyph of flame shock
            [55447] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.crit_mod, spell_name_to_id["Flame Shock"], 0.3, 0.0);
                end,
                wowhead_id = "p4q"
            },
            -- glyph of healing stream totem
            [55456] = {
                apply = function(loadout, effects)
                    -- wording is interesting, could be a multiplier
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Healing Stream Totem"], 0.2, 0.0);
                end,
                wowhead_id = "p50"
            },
            -- glyph of lava
            [55454] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Lava Burst"], 0.1, 0.0);
                end,
                wowhead_id = "p4y"
            },
            -- glyph of lightning bolt
            [55453] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Lightning Bolt"], 0.04, 0.0);
                end,
                wowhead_id = "p4x"
            },
            -- glyph of lightning shield
            [55448] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Lightning Shield"], 0.2, 0.0);
                end,
                wowhead_id = "p4r"
            },
            -- glyph of shocking
            [55442] = {
                apply = function(loadout, effects)
                    local shocks = spell_names_to_id({"Flame Shock", "Earth Shock", "Frost Shock"});
                    for _, v in pairs(shocks) do
                        ensure_exists_and_add(effects.ability.cast_mod, v, 0.5, 0.0);
                    end
                end,
                wowhead_id = "p4j"
            },
            -- glyph of totem of wrath
            [63280] = {
                apply = function(loadout, effects)
                    -- TODO: see if this is a separate buff or baked into the main one
                end,
                wowhead_id = "xsg"
            },
            -- glyph of water mastery
            [55436] = {
                apply = function(loadout, effects)
                    -- TODO: 
                end,
                wowhead_id = "p4c"
            },

        };
    elseif class == "MAGE" then
        return {
            -- glyph of arcane barrage
            [63092] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Arcane Barrage"], 0.2, 0.0);
                end,
                wowhead_id = "xkm"
            },
            -- glyph of arcane blast
            [62210] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Arcane Blast"], 0.03, 0.0);
                end,
                wowhead_id = "wr2"
            },
            -- glyph of arcane exposion
            [56360] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Arcane Explosion"], 0.1, 0.0);
                end,
                wowhead_id = "q18"
            },
            -- glyph of arcane missiles
            [56363] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.crit_mod, spell_name_to_id["Arcane Missiles"], 0.125, 0.0);
                end,
                wowhead_id = "q1b"
            },
            -- glyph of frostbolt
            [56370] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Frostbolt"], 0.05, 0.0);
                end,
                wowhead_id = "q1j"
            },
            -- glyph of frostfire
            [61205] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Frostfire Bolt"], 0.02, 0.0);
                    ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Frostfire Bolt"], 0.02, 0.0);
                end,
                wowhead_id = "vrn"
            },
            -- glyph of ice barrier
            [63095] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Ice Barrier"], 0.3, 0.0);
                end,
                wowhead_id = "xkq"
            },
            -- glyph of ice lance
            [56377] = {
                apply = function(loadout, effects)
                    -- Implemented in a later stage
                end,
                wowhead_id = "q1s"
            },
            -- glyph of mage armor
            [56383] = {
                apply = function(loadout, effects)
                    effects.raw.regen_while_casting = effects.raw.regen_while_casting + 0.2;
                end,
                wowhead_id = "q1z"
            },
            -- glyph of molten armor
            [56382] = {
                apply = function(loadout, effects)
                    -- TODO:
                end,
                wowhead_id = "q1y"
            },
            -- glyph of scorch
            [56371] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Scorch"], 0.2, 0.0);
                end,
                wowhead_id = "q1k"
            },
            -- glyph of fireball
            [56368] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Fireball"], 0.15, 0.0);
                end,
                wowhead_id = "q1g"
            },
            -- glyph of living bomb
            [63091] = {
                apply = function(loadout, effects)
                    -- implemented in later stage
                end,
                wowhead_id = "xkk"
            }
        };

    elseif class == "WARLOCK" then
        return {
            -- glyph of haunt
            [63302] = {
                apply = function(loadout, effects)
                    -- Implemented in buffs
                end,
                wowhead_id = "xt6"
            },
            -- glyph of immolate
            [56228] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_ot_mod, spell_name_to_id["Immolate"], 0.1, 0.0);
                end,
                wowhead_id = "px4"
            },
            -- glyph of incinerate
            [56242] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Incinerate"], 0.05, 0.0);
                end,
                wowhead_id = "pxj"
            },
            -- glyph of life tap
            [63320] = {
                apply = function(loadout, effects)
                    -- TODO: to be implemented in buffs
                end,
                wowhead_id = "xtr"
            },
            -- glyph of quick decay
            [70947] = {
                apply = function(loadout, effects)
                    -- Implemented in later stage
                end,
                -- TODO: _002 prefix instead of _001, won't work atm via import
                wowhead_id = "593",
                special = true
            },
            -- glyph of searing pain
            [56226] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.crit_mod, spell_name_to_id["Searing Pain"], 0.1, 0.0);
                end,
                wowhead_id = "px2"
            },
            -- glyph of shadow bolt
            [56240] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.cost_mod, spell_name_to_id["Shadow Bolt"], 0.1, 0.0);
                end,
                wowhead_id = "pxg"
            },
            -- glyph of shadow burn
            [56229] = {
                apply = function(loadout, effects)
                    -- Implemented in later stage
                end,
                wowhead_id = "px5"
            },
            -- glyph of unstable affliction
            [56233] = {
                apply = function(loadout, effects)
                    ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Unstable Affliction"], 0.2, 0.0);
                end,
                wowhead_id = "px9"
            },
        };
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
        -- NOTE: GetNumTalents(i) will return 0 on early calls after logging in,
        --       but works fine after reload
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
    local special_prefixes = {"002", "12", "22"};
    local j = 1;
    for i = 1, GetNumGlyphSockets() do
        local _, quality, id, _ = GetGlyphSocketInfo(i);
        if id and glyphs[id] then
            if glyphs[id].special then
                glyphs_code = glyphs_code..special_prefixes[j]..glyphs[id].wowhead_id;
            else
                glyphs_code = glyphs_code..primary_glyph_prefixes[j]..glyphs[id].wowhead_id;
            end
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

        if string.match(wowhead_code:sub(i, i), "[3-9a-z]") ~= nil then
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

local function apply_talents_glyphs(loadout, effects)

    local talents, glyphs_table = talent_glyphs_table(loadout.talents_code);
    loadout.talents_table = talents;
    loadout.glyphs = glyphs_table;

    for k, v in pairs(loadout.glyphs) do
        if v.apply then
            v.apply(loadout, effects);
        end
    end
    
    if class == "MAGE" then

        -- arcane focus
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            effects.by_school.spell_dmg_hit[magic_school.arcane] = 
                effects.by_school.spell_dmg_hit[magic_school.arcane] + pts * 0.01;

            for k, v in pairs(spell_names_to_id({"Arcane Blast", "Arcane Missiles", "Arcane Explosion", "Arcane Barrage"})) do
                ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.01, 0);
            end

        end

        --  clearclast
        --  done in later stage
        
        --  spell impact
        local pts = talents:pts(1, 8);
        if pts ~= 0 then
            for k, v in pairs(spell_names_to_id({"Arcane Explosion", "Arcane Blast", "Blast Wave", "Fire Blast", "Scorch", "Fireball", "Ice Lance", "Cone of Cold"})) do
                ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.02, 0.0);
            end
        end
        local pts = talents:pts(1, 9);
        if pts ~= 0 then
            local val_by_pts = {0.04, 0.07, 0.1};
            effects.by_attribute.stat_mod[stat.spirit] = 
                effects.by_attribute.stat_mod[stat.spirit] + val_by_pts[pts];
        end
        --  arcane mediation
        local pts = talents:pts(1, 13);
        if pts ~= 0 then
            effects.raw.regen_while_casting = effects.raw.regen_while_casting + pts * 0.5/3;
        end
        --  torment of the weak
        local pts = talents:pts(1, 14);
        if pts ~= 0 then
            --effects.mana_mod = effects.mana_mod + pts * 0.02;
            -- TODO: more dmg to snared
        end
        -- arcane mind
        local pts = talents:pts(1, 17);
        if pts ~= 0 then
            effects.by_attribute.stat_mod[stat.int] = 
                effects.by_attribute.stat_mod[stat.int] + pts*0.03;
        end
        -- arcane instability
        local pts = talents:pts(1, 19);
        if pts ~= 0 then
            --TODO: dynamic crit
            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.fire]) * (1.0 + 0.01 * pts) - 1.0;
            effects.by_school.spell_dmg_mod[magic_school.frost] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.frost]) * (1.0 + 0.01 * pts) - 1.0;
            effects.by_school.spell_dmg_mod[magic_school.arcane] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.arcane]) * (1.0 + 0.01 * pts) - 1.0;


        end
        -- arcane potency
        local pts = talents:pts(1, 20);
        if pts ~= 0 then
            -- NOTE: add crit as is expected by clearcast proc chance
            local expected_extra_crit = loadout.talents_table:pts(1, 6)*0.02*0.15*pts;
            effects.by_school.spell_crit[magic_school.fire] = 
                effects.by_school.spell_crit[magic_school.fire] + expected_extra_crit;
            effects.by_school.spell_crit[magic_school.frost] = 
                effects.by_school.spell_crit[magic_school.frost] + expected_extra_crit;
            effects.by_school.spell_crit[magic_school.arcane] = 
                effects.by_school.spell_crit[magic_school.arcane] + expected_extra_crit;
        end
        -- arcane empowerment
        local pts = talents:pts(1, 21);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.coef_mod,
                                  spell_name_to_id["Arcane Blast"], pts * 0.03, 0.0);
            ensure_exists_and_add(effects.ability.coef_ot_mod,
                                  spell_name_to_id["Arcane Missiles"], pts * 0.314685314/3, 0.0);
        end
        -- mind mastery
        local pts = talents:pts(1, 25);
        if pts ~= 0 then
            -- TODO: spell power based on int
        end
        -- netherwind presence
        local pts = talents:pts(1, 28);
        if pts ~= 0 then
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * (1.0 + pts*0.02) - 1.0;
        end

        -- spell power
        local pts = talents:pts(1, 29);
        if pts ~= 0 then
            effects.by_school.spell_crit_mod[magic_school.frost] = 
                effects.by_school.spell_crit_mod[magic_school.frost] + 0.5*pts*0.25;
            effects.by_school.spell_crit_mod[magic_school.fire] = 
                effects.by_school.spell_crit_mod[magic_school.fire] + 0.5*pts*0.25;
            effects.by_school.spell_crit_mod[magic_school.arcane] = 
                effects.by_school.spell_crit_mod[magic_school.arcane] + 0.5*pts*0.25;
            
        end

        -- incineration
        local pts = talents:pts(2, 2);
        if pts ~= 0 then
            for k, v in pairs(spell_names_to_id({"Fire Blast", "Scorch", "Arcane Blast", "Cone of Cold"})) do
                ensure_exists_and_add(effects.ability.crit, v, pts * 0.02, 0.0);
            end
        end

        -- improved fireball
        local pts = talents:pts(2, 3);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Fireball"], pts * 0.1, 0.0);
        end
        -- ignite
        local pts = talents:pts(2, 4);
        if pts ~= 0 then
           -- done in later stage
        end
        -- world in flames
        local pts = talents:pts(2, 6);
        if pts ~= 0 then
            for k, v in pairs(spell_names_to_id({"Flamestrike", "Pyroblast", "Blast Wave", "Dragon's Breath", "Living Bomb", "Blizzard", "Arcane Explosion"})) do
                ensure_exists_and_add(effects.ability.crit, v, pts * 0.02, 0.0);
            end
        end
        -- improved scorch
        local pts = talents:pts(2, 11);
        if pts ~= 0 then
            for k, v in pairs(spell_names_to_id({"Fireball", "Scorch", "Frostfire Bolt"})) do
                ensure_exists_and_add(effects.ability.crit, v, pts * 0.01, 0.0);
            end
        end
        -- master of elements
        -- done in later stage

        -- playing with fire
        local pts = talents:pts(2, 14);
        if pts ~= 0 then

            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.fire])*(1.0 +  0.01 * pts) - 1.0;
            effects.by_school.spell_dmg_mod[magic_school.arcane] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.arcane])*(1.0 +  0.01 * pts) - 1.0;
            effects.by_school.spell_dmg_mod[magic_school.frost] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.frost])*(1.0 +  0.01 * pts) - 1.0;
        end
        -- critical mass
        local pts = talents:pts(2, 15);
        if pts ~= 0 then
            -- TODO: dynamic crit
        end
        -- fire power
        local pts = talents:pts(2, 18);
        if pts ~= 0 then
            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.fire])*(1.0 +  0.02 * pts) - 1.0;
        end
        --pyromaniac
        local pts = talents:pts(2, 19);
        if pts ~= 0 then
            -- TODO: dynamic crit
            effects.raw.regen_while_casting = effects.raw.regen_while_casting + pts*0.5/3;
        end
        --molten fury
        local pts = talents:pts(2, 21);
        if pts ~= 0 then
            -- done in later stage
        end

        --empowered fire
        local pts = talents:pts(2, 23);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Fireball"], pts * 0.05, 0);
            ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Frostfire Bolt"], pts * 0.05, 0);
            ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Pyroblast"], pts * 0.05, 0);
            ensure_exists_and_add(effects.ability.coef_ot_mod, spell_name_to_id["Pyroblast"], pts, 0);
            -- TODO: refund on ignite, tricky and assumptions must be made
        end

        --burnout
        local pts = talents:pts(2, 27);
        if pts ~= 0 then
            effects.by_school.spell_crit_mod[magic_school.frost] = 
                effects.by_school.spell_crit_mod[magic_school.frost] + 0.05*pts;
            effects.by_school.spell_crit_mod[magic_school.fire] = 
                effects.by_school.spell_crit_mod[magic_school.fire] + 0.05*pts;
            effects.by_school.spell_crit_mod[magic_school.arcane] = 
                effects.by_school.spell_crit_mod[magic_school.arcane] + 0.05*pts;
        end

        -- improved frostbolt
        local pts = talents:pts(3, 2);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Frostbolt"], pts * 0.1, 0.0);
        end
        -- ice shards
        local pts = talents:pts(3, 4);
        if pts ~= 0 then
            effects.by_school.spell_crit_mod[magic_school.frost] = 
                effects.by_school.spell_crit_mod[magic_school.frost] + pts*0.5/3;
        end
        -- precision
        local pts = talents:pts(3, 6);
        if pts ~= 0 then
            effects.by_school.spell_dmg_hit[magic_school.frost] = 
                effects.by_school.spell_dmg_hit[magic_school.frost] + pts * 0.01;
            effects.by_school.spell_dmg_hit[magic_school.arcane] = 
                effects.by_school.spell_dmg_hit[magic_school.arcane] + pts * 0.01;
            effects.by_school.spell_dmg_hit[magic_school.fire] = 
                effects.by_school.spell_dmg_hit[magic_school.fire] + pts * 0.01;
            effects.raw.cost_mod = effects.raw.cost_mod + pts* 0.01;
        
        end
        -- piercing ice
        local pts = talents:pts(3, 8);
        if pts ~= 0 then
            effects.by_school.spell_dmg_mod[magic_school.frost] = 
                effects.by_school.spell_dmg_mod[magic_school.frost] + 0.02 * pts;
        end
        -- frost channeling
        local pts = talents:pts(3, 12);
        if pts ~= 0 then
            local by_pts = {0.04, 0.07, 0.1};
            effects.raw.cost_mod = effects.raw.cost_mod + by_pts[pts];

        end
        -- improved cone of cold
        local pts = talents:pts(3, 15);
        if pts ~= 0 then
            local by_pts = {0.15, 0.25, 0.35};
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Cone of Cold"], by_pts[pts], 0.0);
        end

        -- winters chill
        local pts = talents:pts(3, 18);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Frostbolt"], pts * 0.01, 0.0);
        end

        -- arctic winds
        local pts = talents:pts(3, 21);
        if pts ~= 0 then
            effects.by_school.spell_dmg_mod[magic_school.frost] = 
                (1.0 + effects.by_school.spell_dmg_mod[magic_school.frost])*(1.0 + 0.01 * pts) - 1.0;

        end

        -- empowered frostbolt
        local pts = talents:pts(3, 22);
        if pts ~= 0 then
            local fb = spell_name_to_id["Frostbolt"];
            ensure_exists_and_add(effects.ability.cast_mod, fb, pts * 0.1, 0.0);
            ensure_exists_and_add(effects.ability.coef_mod, fb, pts * 0.05, 0.0);
        end

        -- chilled to the bone
        local pts = talents:pts(3, 27);
        if pts ~= 0 then
            for k, v in pairs(spell_names_to_id({"Frostbolt", "Frostfire Bolt", "Ice Lance"})) do
                ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.01, 0.0);
            end
        end

    elseif class == "DRUID" then

        -- starlight wrath
        local pts = talents:pts(1, 1);
        if pts ~= 0 then

            local abilities = spell_names_to_id({"Wrath", "Starfire"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.cast_mod, v, pts * 0.1, 0);
            end
        end

        -- genesis
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            effects.raw.ot_mod = effects.raw.ot_mod + 0.01 * pts;
        end

        -- moonglow
        local pts = talents:pts(1, 3);
        if pts ~= 0 then

            local abilities = spell_names_to_id({"Moonfire", "Starfire", "Wrath", "Healing Touch", "Nourish", "Regrowth", "Rejuvenation"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.03, 0);
            end
        end

        -- nature's majesty
        local pts = talents:pts(1, 4);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Wrath", "Starfire", "Starfall", "Nourish", "Healing Touch"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.crit, v, pts * 0.02, 0.0);
            end
        end

        -- improved moonfire
        local pts = talents:pts(1, 5);
        if pts ~= 0 then
            local mf = spell_name_to_id["Moonfire"];
            ensure_exists_and_add(effects.ability.crit, mf, pts * 0.05, 0);
            ensure_exists_and_add(effects.ability.effect_mod, mf, pts * 0.05, 0.0);
        end
        -- brambles
        local pts = talents:pts(1, 6);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Thorns", "Entangling Roots"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.25, 0.0);
            end
        end

        -- nature's grace

        -- nature's splendor
        local pts = talents:pts(1, 8);
        if pts ~= 0 then
            local one_ticks = spell_names_to_id({"Moonfire", "Rejuvenation", "Insect Swarm"});
            local two_ticks = spell_names_to_id({"Regrowth", "Lifebloom"});
            for k, v in pairs(one_ticks) do
                ensure_exists_and_add(effects.ability.extra_ticks, v, 1, 0);
            end
            for k, v in pairs(two_ticks) do
                ensure_exists_and_add(effects.ability.extra_ticks, v, 2, 0);
            end
        end

        -- vengeance
        local pts = talents:pts(1, 10);
        if pts ~= 0 then

            local abilities = spell_names_to_id({"Starfire", "Starfall", "Moonfire", "Wrath"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.crit_mod, v, pts * 0.1, 0);
            end
        end

        -- celestial focus
        local pts = talents:pts(1, 11);
        if pts ~= 0 then
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * (1.0 + pts * 0.01) - 1.0;
        end

        -- lunar guidance
        local pts = talents:pts(1, 12);
        if pts ~= 0 then
            effects.by_attribute.sp_from_stat_mod[stat.int] = effects.by_attribute.sp_from_stat_mod[stat.int]+ pts * 0.04;
        end

        -- improved insect swarm
        local pts = talents:pts(1, 14);
        if pts ~= 0 then
            -- TODO: track moonfire and insect swarm
        end

        -- dreamstate
        local pts = talents:pts(1, 15);
        if pts ~= 0 then
            effects.raw.mp5_from_int_mod = effects.raw.mp5_from_int_mod + 0.04 * pts;
        end

        -- moonfury
        local pts = talents:pts(1, 16);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Starfire", "Moonfire", "Wrath"});
            local dmg_mod_by_pts = {0.03, 0.06, 0.1};
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.effect_mod, v, dmg_mod_by_pts[pts], 0.0);
            end
        end
        -- balance of power
        local pts = talents:pts(1, 17);
        if pts ~= 0 then

            effects.by_school.spell_dmg_hit[magic_school.nature] = 
                effects.by_school.spell_dmg_hit[magic_school.nature] + pts * 0.02;
            effects.by_school.spell_dmg_hit[magic_school.arcane] = 
                effects.by_school.spell_dmg_hit[magic_school.arcane] + pts * 0.02;
        end

        -- moonkin form
        local pts = talents:pts(1, 18);
        if pts ~= 0 then
        end
        -- improved moonkin form
        local pts = talents:pts(1, 19);
        if pts ~= 0 then
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

            local sf = spell_name_to_id["Starfire"];
            local w = spell_name_to_id["Wrath"];
            ensure_exists_and_add(effects.ability.coef_mod, sf, pts * 0.04, 0);
            ensure_exists_and_add(effects.ability.coef_mod, w, pts * 0.02, 0);
        end

        -- eclipse
        local pts = talents:pts(1, 23);
        if pts ~= 0 then
        end

        -- gale winds
        local pts = talents:pts(1, 26);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Hurricane", "Typhoon"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.15, 0.0);
            end
        end

        --  earth and moon
        local pts = talents:pts(1, 27);
        if pts ~= 0 then
            effects.by_school.spell_dmg_mod[magic_school.arcane] = 
                effects.by_school.spell_dmg_mod[magic_school.arcane] + 0.02 * pts;
            effects.by_school.spell_dmg_mod[magic_school.nature] = 
                effects.by_school.spell_dmg_mod[magic_school.nature] + 0.02 * pts;
        end

        --  starfall
        --  TODO: awkward to display tooltip for

        -- TODO: feral
        -- heart of the wild
        --local pts = talents:pts(2, 15);
        --if pts ~= 0 then
        --    effects.stat_mod[stat.int] = effects.stat_mod[stat.int] + pts * 0.04;
        --end


        -- TODO: furor talent (3,3) intellect in boomkin form
        -- naturalist
        local pts = talents:pts(3, 4);
        if pts ~= 0 then
            local ht = spell_name_to_id["Healing Touch"];
            ensure_exists_and_add(effects.ability.cast_mod, ht, pts * 0.1, 0);
        end
        -- intensity
        local pts = talents:pts(3, 7);
        if pts ~= 0 then
            local regen = {0.17, 0.33, 0.5};
            effects.raw.regen_while_casting = effects.raw.regen_while_casting + regen[pts];
        end

        
        -- tranquil spirit
        local pts = talents:pts(3, 10);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Healing Touch", "Tranquility", "Nourish"});
            
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.02, 0);
            end
        end

        -- improved rejuvenation
        local pts = talents:pts(3, 11);
        if pts ~= 0 then
            local rejuv = spell_name_to_id["Rejuvenation"];
            ensure_exists_and_add(effects.ability.effect_mod, rejuv, pts * 0.05, 0.0);
        end

        -- gift of nature
        local pts = talents:pts(3, 13);
        if pts ~= 0 then
            effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + pts * 0.02;
        end

        -- empowered touch
        local pts = talents:pts(3, 15);
        if pts ~= 0 then

            local ht = spell_name_to_id["Healing Touch"];
            local no = spell_name_to_id["Nourish"];
            ensure_exists_and_add(effects.ability.coef_mod, ht, pts * 0.2, 0);
            ensure_exists_and_add(effects.ability.coef_mod, no, pts * 0.1, 0);
        end

        -- nature's bounty
        local pts = talents:pts(3, 16);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Regrowth", "Nourish"});
            
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.crit, v, pts * 0.05, 0);
            end
        end

        -- living spirit
        local pts = talents:pts(3, 17);
        if pts ~= 0 then
            effects.by_attribute.stat_mod[stat.spirit] = effects.by_attribute.stat_mod[stat.spirit] + pts * 0.05;
        end

        -- natural perfection
        local pts = talents:pts(3, 19);
        if pts ~= 0 then

            -- TODO: dynamic crit
            --effects.by_school.spell_crit[magic_school.nature] = 
            --    effects.by_school.spell_crit[magic_school.nature] + 0.01 * pts;
            --effects.by_school.spell_crit[magic_school.arcane] = 
            --    effects.by_school.spell_crit[magic_school.arcane] + 0.01 * pts;
        end

        -- empowered rejuvenation
        local pts = talents:pts(3, 20);
        if pts ~= 0 then
            local hots = spell_names_to_id({"Lifebloom", "Regrowth",  "Wild Growth", "Rejuvenation", "Tranquility"});
            for k, v in pairs(hots) do
                ensure_exists_and_add(effects.ability.coef_ot_mod, v, pts * 0.04, 0);
            end

            ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Lifebloom"], pts*0.02064, 0);
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
            local abilities = spell_names_to_id({"Regrowth", "Rejuvenation", "Lifebloom", "Wild Growth"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.cost_mod, v, 0.2, 0);
            end
        end

        -- improved tree of life
        local pts = talents:pts(3, 24);
        if pts ~= 0 then
            -- TODO: spiritual guidance
        end

        -- gift of the earthmother
        local pts = talents:pts(3, 26);
        if pts ~= 0 then
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * (1.0 + pts * 0.02) - 1.0;
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Lifebloom"], pts * 0.02, 0.0);
        end

    elseif class == "PRIEST" then

        local instants = spell_names_to_id({"Renew", "Holy Nova", "Circle of Healing", "Prayer of Mending", "Devouring Plague", "Shadow Word: Pain", "Shadow Word: Death", "Power Word: Shield", "Mind Flay", "Mind Sear", "Desperate Prayer"});

        -- twin disciplines
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            for k, v in pairs(instants) do
                ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.01, 0.0);
            end
        end

        -- meditation
        local pts = talents:pts(1, 7);
        if pts ~= 0 then
            local regen = {0.17, 0.33, 0.5};
            effects.raw.regen_while_casting = effects.raw.regen_while_casting + regen[pts];
        end

        -- improved power word: shield
        local pts = talents:pts(1, 9);
        if pts ~= 0 then
            local shield = spell_name_to_id["Power Word: Shield"];
            ensure_exists_and_mul(effects.ability.effect_mod, shield, 1.0 + pts * 0.05, 0.0);
            if not effects.ability.effect_mod then
                effects.ability.effect_mod[shield] = 0.0;
            end
            effects.ability.effect_mod[shield] =
                (1.0 + effects.ability.effect_mod[shield]) * (1.0 + pts * 0.05) - 1.0;
        end

        -- mental agility 
        local pts = talents:pts(1, 11);
        if pts ~= 0 then

            local mod = {0.04, 0.07, 0.1};
            for k, v in pairs(instants) do
                ensure_exists_and_add(effects.ability.cost_mod, v, mod[pts], 0);
            end
            local shield = spell_name_to_id["Power Word: Shield"];
            ensure_exists_and_add(effects.ability.cost_mod, shield, mod[pts], 0);
        end

        -- mental strength
        local pts = talents:pts(1, 14);
        if pts ~= 0 then
            effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + pts * 0.03;
        end

        -- focused power
        local pts = talents:pts(1, 16);
        if pts ~= 0 then
            effects.raw.spell_heal_mod_mul = effects.raw.spell_heal_mod_mul + pts * 0.02;
            effects.by_school.spell_dmg_mod[magic_school.holy] =
                effects.by_school.spell_dmg_mod[magic_school.holy] + pts * 0.02;
            effects.by_school.spell_dmg_mod[magic_school.shadow] =
                effects.by_school.spell_dmg_mod[magic_school.shadow] + pts * 0.02;
        end

        -- enlightenment
        local pts = talents:pts(1, 17);
        if pts ~= 0 then
            effects.by_attribute.stat_mod[stat.spirit] = effects.by_attribute.stat_mod[stat.spirit] + pts * 0.02;
            effects.raw.haste_mod = (1.0 + effects.raw.haste_mod) * (1.0 + pts * 0.02) - 1.0;
        end

        -- focused will
        local pts = talents:pts(1, 18);
        if pts ~= 0 then

            effects.by_school.spell_crit[magic_school.holy] = 
                effects.by_school.spell_crit[magic_school.holy] + 0.01 * pts;
            effects.by_school.spell_crit[magic_school.shadow] = 
                effects.by_school.spell_crit[magic_school.shadow] + 0.01 * pts;
        end

        -- TODO: increased crit dynamically on low hp target
        -- improved flash heal
        local pts = talents:pts(1, 20);
        if pts ~= 0 then
            local flash_heal = spell_name_to_id["Flash Heal"];
            ensure_exists_and_add(effects.ability.cost_mod, flash_heal, pts * 0.05, 0);
        end
        -- borrowed time
        local pts = talents:pts(1, 27);
        if pts ~= 0 then

            local shield = spell_name_to_id["Power Word: Shield"];
            ensure_exists_and_add(effects.ability.coef_mod, shield, pts * 0.08, 0); 
        end

        -- improved renew
        local pts = talents:pts(2, 2);
        if pts ~= 0 then
            local renew = spell_name_to_id["Renew"];
            ensure_exists_and_add(effects.ability.effect_mod, renew, pts * 0.05, 0.0); 
        end
        -- holy specialization
        local pts = talents:pts(2, 3);
        if pts ~= 0 then
            -- TODO: dynamic crit
            --effects.by_school.spell_crit[magic_school.holy] = 
            --    effects.by_school.spell_crit[magic_school.holy] + pts * 0.01;
        end
        -- divine fury
        local pts = talents:pts(2, 5);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Smite", "Holy Fire", "Heal", "Greater Heal"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.cast_mod, v, pts * 0.1, 0);
            end
        end
        -- improved healing
        local pts = talents:pts(2, 10);
        if pts ~= 0 then
            local abilities =
                spell_names_to_id({"Lesser Heal", "Heal", "Greater Heal", "Divine Hymn", "Penance"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.05, 0);
            end
        end
        -- searing light
        local pts = talents:pts(2, 11);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Smite", "Holy Fire", "Holy Nova", "Penance"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.05, 0.0);
            end
        end
        -- healing prayers
        local pts = talents:pts(2, 12);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Prayer of Healing", "Prayer of Mending"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.1, 0);
            end
        end
        -- spiritual redemption 
        local pts = talents:pts(2, 13);
        if pts ~= 0 then
            effects.by_attribute.stat_mod[stat.spirit] = effects.by_attribute.stat_mod[stat.spirit] + pts * 0.05;
        end
        -- spiritual guidance 
        local pts = talents:pts(2, 14);
        if pts ~= 0 then
            effects.by_attribute.sp_from_stat_mod[stat.spirit] = effects.by_attribute.sp_from_stat_mod[stat.spirit] + pts * 0.05;

        end
        -- surge of light
        -- TODO: refund flash heal mana cost off crit chance, similarly as with holy palas in vanilla?
 
        -- spiritual healing
        local pts = talents:pts(2, 16);
        if pts ~= 0 then
            effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + pts * 0.02;
        end

        -- holy concentration
        -- TODO: need an expectation of this extra mana regen uptime based on spell cast time & crit
 
        -- blessed resilience
        local pts = talents:pts(2, 19);
        if pts ~= 0 then
            effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + pts * 0.01;
        end

        -- empowered healing
        local pts = talents:pts(2, 21);
        if pts ~= 0 then
            local gh = spell_name_to_id["Greater Heal"];
            local fh = spell_name_to_id["Flash Heal"];
            local bh = spell_name_to_id["Binding Heal"];

            ensure_exists_and_add(effects.ability.coef_mod, gh, pts * 0.08, 0);
            ensure_exists_and_add(effects.ability.coef_mod, fh, pts * 0.04, 0);
            ensure_exists_and_add(effects.ability.coef_mod, bh, pts * 0.04, 0);
        end

        -- empowered renew 
        local pts = talents:pts(2, 23);
        if pts ~= 0 then
            local renew = spell_name_to_id["Renew"];
            ensure_exists_and_add(effects.ability.coef_ot_mod, renew, pts * 0.05, 0);
        end

        -- divine providence
        local pts = talents:pts(2, 26);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Circle of Healing", "Binding Heal", "Holy Nova", "Prayer of Healing", "Divine Hymn", "Prayer of Mending"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.02, 0.0);
            end
        end

        -- darkness 
        local pts = talents:pts(3, 3);
        if pts ~= 0 then

            local abilities = spell_names_to_id(
                {"Devouring Plague", "Mind Blast", "Shadow Word: Pain", "Mind Flay", "Vampiric Touch", "Shadow Word: Death", "Mind Sear"}
            );
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.02, 0.0);
            end
        end

        -- improved shadow word: pain
        local pts = talents:pts(3, 5);
        if pts ~= 0 then
            local swp = spell_name_to_id["Shadow Word: Pain"];                
            ensure_exists_and_add(effects.ability.effect_mod, swp, pts * 0.03, 0.0);
        end
        -- shadow focus
        local pts = talents:pts(3, 6);
        if pts ~= 0 then
            effects.by_school.spell_dmg_hit[magic_school.shadow] = 
                effects.by_school.spell_dmg_hit[magic_school.shadow] + pts * 0.01;

            local abilities = spell_names_to_id(
                {"Devouring Plague", "Mind Blast", "Shadow Word: Pain", "Mind Flay", "Vampiric Touch", "Shadow Word: Death", "Mind Sear"}
            );
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.02, 0);
            end
        end

        -- focused mind
        local pts = talents:pts(3, 16);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Mind Blast", "Mind Flay", "Mind Sear"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.05, 0);
            end
        end
        -- mind melt
        local pts = talents:pts(3, 17);
        if pts ~= 0 then

            local mind = spell_names_to_id({"Mind Blast", "Mind Flay", "Mind Sear"});
            for k, v in pairs(mind) do
                ensure_exists_and_add(effects.ability.crit, v, pts * 0.02, 0);
            end
            local dots = spell_names_to_id({"Vampiric Touch", "Shadow Word: Pain", "Devouring Plague"});
            for k, v in pairs(dots) do
                ensure_exists_and_add(effects.ability.crit, v, pts * 0.03, 0);
            end
        end
        -- improved devouring plague
        local pts = talents:pts(3, 18);
        if pts ~= 0 then

            local dp = spell_name_to_id["Devouring Plague"];
            ensure_exists_and_add(effects.ability.effect_mod, dp, pts * 0.05, 0.0);
            -- TODO: instant dmg 10%, as with renew
        end

        -- shadow power
        local pts = talents:pts(3, 20);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Mind Blast", "Mind Flay", "Shadow Word: Death"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.crit_mod, v, pts * 0.1, 0);
            end
        end

        -- misery
        local pts = talents:pts(3, 22);
        if pts ~= 0 then

            local mind_flay = spell_name_to_id["Mind Flay"];
            ensure_exists_and_add(effects.ability.coef_ot_mod, mind_flay,  pts * 0.05, 0);
            local mind_sear = spell_name_to_id["Mind Sear"];
            ensure_exists_and_add(effects.ability.coef_ot_mod, mind_sear, pts * 0.05, 0);
            local mind_blast = spell_name_to_id["Mind Blast"];
            ensure_exists_and_add(effects.ability.coef_mod, mind_blast, pts * 0.05 * 0.4286, 0);

        end
        -- twisted faith
        -- TODO: shadow word: pain tracking
        local pts = talents:pts(3, 26);
        if pts ~= 0 then
             
            effects.by_attribute.sp_from_stat_mod[stat.spirit] = effects.by_attribute.sp_from_stat_mod[stat.spirit] + pts * 0.04;
        end
        
    elseif class == "SHAMAN" then

        local ele_abilities = spell_names_to_id({"Earth Shock", "Frost Shock", "Flame Shock", "Lightning Bolt", "Chain Lightning", "Lava Burst", "Thunderstorm"});

        ---- convection
        local pts = talents:pts(1, 1);
        if pts ~= 0 then
            for k, v in pairs(ele_abilities) do
                ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.02, 0.0);
            end
        end
        -- concussion
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            for k, v in pairs(ele_abilities) do
                ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.01, 0.0);
            end
        end
        -- call of flame
        local pts = talents:pts(1, 3);
        if pts ~= 0 then
            for k, v in pairs(spell_names_to_id({"Magma Totem", "Searing Totem", "Fire Nova"})) do
                ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.05, 0.0);
            end
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Lava Burst"], pts * 0.02, 0.0);
        end
        -- elemental focus implemented in later stage
        
        -- elemental fury
        local pts = talents:pts(1, 8);
        if pts ~= 0 then
            effects.by_school.spell_crit_mod[magic_school.frost] = 
                effects.by_school.spell_crit_mod[magic_school.frost] + pts * 0.1;
            effects.by_school.spell_crit_mod[magic_school.fire] = 
                effects.by_school.spell_crit_mod[magic_school.fire] + pts * 0.1;
            effects.by_school.spell_crit_mod[magic_school.nature] = 
                effects.by_school.spell_crit_mod[magic_school.nature] + pts * 0.1;
        end

        -- improved fire nova
        local pts = talents:pts(1, 9);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Fire Nova"], pts * 0.1, 0.0);
        end

        -- call of thunder
        local pts = talents:pts(1, 12);
        if pts ~= 0 then
            for k, v in pairs(spell_names_to_id({"Lightning Bolt", "Chain Lightning", "Thunderstorm"})) do
                ensure_exists_and_add(effects.ability.crit, v, 0.05, 0.0);
            end
        end

        -- unrlenting storm
        -- TODO: mana regen off % intellect, same as boomies
        local pts = talents:pts(1, 13);
        if pts ~= 0 then
            effects.raw.mp5_from_int_mod = effects.raw.mp5_from_int_mod + 0.04 * pts;
        end
        -- elemental precision
        local pts = talents:pts(1, 14);
        if pts ~= 0 then
            effects.by_school.spell_dmg_hit[magic_school.frost] = 
                effects.by_school.spell_dmg_hit[magic_school.frost] + pts * 0.01;
            effects.by_school.spell_dmg_hit[magic_school.fire] = 
                effects.by_school.spell_dmg_hit[magic_school.fire] + pts * 0.01;
            effects.by_school.spell_dmg_hit[magic_school.nature] = 
                effects.by_school.spell_dmg_hit[magic_school.nature] + pts * 0.01;
        end

        -- lightning mastery
        local pts = talents:pts(1, 15);
        if pts ~= 0 then
            for k, v in pairs(spell_names_to_id({"Lightning Bolt", "Chain Lightning", "Lava Burst"})) do
                ensure_exists_and_add(effects.ability.cast_mod, v, pts * 0.1, 0.0);
            end
        end

        -- storm, earth and fire
        local pts = talents:pts(1, 17);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.effect_ot_mod, spell_name_to_id["Flame Shock"], pts * 0.2, 0.0);
        end

        -- booming echoes
        -- TODO: the wording is interesting, could be a multiplier instead of add?
        local pts = talents:pts(1, 18);
        if pts ~= 0 then
            local flame_shock = spell_name_to_id["Flame Shock"];
            ensure_exists_and_add(effects.ability.effect_mod, flame_shock, pts * 0.1, 0.0);
            ensure_exists_and_add(effects.ability.effect_ot_mod, flame_shock, -pts * 0.1, 0.0);
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Frost Shock"], pts * 0.1, 0.0);
        end

        -- TODO: figure out crit mod calculation
        -- lava flows
        local pts = talents:pts(1, 23);
        if pts ~= 0 then
            local crit_mod = 0.03*bit.lshift(1, pts);
            -- 0.06, 0.12 or 0.24
            ensure_exists_and_add(effects.ability.crit_mod, spell_name_to_id["Lava Burst"], 0.5*crit_mod, 0.0);
        end

        -- shamanism
        local pts = talents:pts(1, 24);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Lightning Bolt"], pts * 0.04, 0);
            ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Chain Lightning"], pts * 0.04, 0);
            ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Lava Burst"], pts * 0.05, 0);
        end

        -- ancestral knowledge
        local pts = talents:pts(2, 3);
        if pts ~= 0 then
            effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + pts * 0.02;
        end

        -- thundering strikes
        local pts = talents:pts(2, 5);
        if pts ~= 0 then
            for i = 2,7 do
                effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + 0.01 * pts;
            end
        end

        -- improved shields
        local pts = talents:pts(2, 7);
        if pts ~= 0 then

            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Lightning Shield"], pts * 0.05, 0.0);
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Earth Shield"], pts * 0.05, 0.0);
        end

        -- shamanistic focus
        local pts = talents:pts(2, 9);
        if pts ~= 0 then
            for k, v in pairs(spell_names_to_id({"Earth Shock", "Flame Shock", "Frost Shock"})) do
                ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.45, 0.0);
            end
        end

        -- improved healing wave
        local pts = talents:pts(3, 1);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Healing Wave"], pts * 0.1, 0.0);
        end
        
        -- totemic focus
        local pts = talents:pts(3, 2);
        if pts ~= 0 then
            -- TODO: is fire nova not a totem?
            for k, v in pairs(spell_names_to_id({"Healing Stream Totem", "Magma Totem", "Searing Totem"})) do
                ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.05, 0.0);
            end
        end

        -- tidal focus
        local pts = talents:pts(3, 5);
        if pts ~= 0 then
            -- TODO: healing totem included?
            local healing_spells = spell_names_to_id({"Chain Heal", "Lesser Healing Wave", "Healing Wave", "Riptide", "Earth Shield"});
            for k, v in pairs(healing_spells) do
                ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.01, 0.0);
            end
        end

        -- tidal force
        -- Could track this but should then also do inner focus
        --
        -- restorative totems
        local pts = talents:pts(3, 10);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Healing Stream Totem"], pts * 0.15, 0.0);
        end

        -- tidal mastery
        local pts = talents:pts(3, 11);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Lightning Bolt", "Chain Lightning", "Thunderstorm",  "Lesser Healing Wave", "Healing Wave", "Riptide", "Earth Shield", "Chain Heal"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.crit, v, pts * 0.01, 0.0);
            end
        end

        -- restorative totems
        local pts = talents:pts(3, 12);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Healing Wave"], pts * 0.25/3, 0.0);
        end

        -- purification
        local pts = talents:pts(3, 15);
        if pts ~= 0 then
            effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + pts * 0.02;
        end

        -- blessing of the eternals
        -- TODO: wtf is earthliving heal??
        local pts = talents:pts(3, 19);
        if pts ~= 0 then
            for i = 2,7 do
                effects.by_school.spell_crit[i] = effects.by_school.spell_crit[i] + pts * 0.02;
            end
        end

        -- improved chain heal
        local pts = talents:pts(3, 20);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Chain Heal"], pts * 0.1, 0.0);
        end

        -- nature's blessing
        local pts = talents:pts(3, 21);
        if pts ~= 0 then
            effects.by_attribute.hp_from_stat_mod[stat.int] = effects.by_attribute.hp_from_stat_mod[stat.int] + pts * 0.05;
        end

        -- ancestral awakening
        -- done in later stage

        -- 
        local pts = talents:pts(3, 24);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Earth Shield"], pts * 0.05, 0.0);
        end

        -- tidal waves
        local pts = talents:pts(3, 25);
        if pts ~= 0 then

            local sf = spell_name_to_id["Starfire"];
            local w = spell_name_to_id["Wrath"];
            ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Healing Wave"], pts * 0.04, 0);
            ensure_exists_and_add(effects.ability.coef_mod, spell_name_to_id["Lesser Healing Wave"], pts * 0.02, 0);
        end

    elseif class == "PALADIN" then

        -- healing light
        local pts = talents:pts(1, 3);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Holy Light", "Flash of Light", "Holy Shock"});

            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.04, 0.0);
            end
        end

        -- divine intellect
        local pts = talents:pts(1, 4);
        if pts ~= 0 then
            effects.by_attribute.stat_mod[stat.int] = effects.by_attribute.stat_mod[stat.int] + pts * 0.02;
        end

        -- TODO: bow?
        
        -- sanctified light
        local pts = talents:pts(1, 14);
        if pts ~= 0 then
            local abilities = spell_names_to_id({"Holy Light", "Holy Shock"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.crit, v, pts * 0.02, 0);
            end
            
        end

        -- holy power
        local pts = talents:pts(1, 16);
        if pts ~= 0 then
            -- TODO: dynamic crit
            --effects.by_school.spell_crit[magic_school.holy] = 
            --    effects.by_school.spell_crit[magic_school.holy] + pts * 0.01;
        end

        -- lights grace
        local pts = talents:pts(1, 17);
        if pts ~= 0 then

            local hl = spell_name_to_id["Holy Light"];
            ensure_exists_and_add(effects.ability.cast_mod, hl, pts * 0.5 / 3.0, 0);
        end

        -- holy guidance
        local pts = talents:pts(1, 21);
        if pts ~= 0 then

            effects.by_attribute.sp_from_stat_mod[stat.int] = effects.by_attribute.sp_from_stat_mod[stat.int]+ pts * 0.04;
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
            effects.raw.spell_heal_mod_mul = effects.raw.spell_heal_mod_mul + pts * 0.01;
        end
        -- benediction
        local pts = talents:pts(3, 2);
        if pts ~= 0 then
            local hs = spell_name_to_id["Holy Shock"];
            ensure_exists_and_add(effects.ability.cost_mod, hs, pts * 0.02, 0.0); 
        end

    elseif class == "WARLOCK" then
        -- improved curse of agony
        local pts = talents:pts(1, 1);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Curse of Agony"], pts * 0.05, 0.0); 
        end

        -- suppression
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            effects.by_school.spell_dmg_hit[magic_school.shadow] = 
                effects.by_school.spell_dmg_hit[magic_school.shadow] + pts * 0.01;
            effects.by_school.spell_dmg_hit[magic_school.fire] = 
                effects.by_school.spell_dmg_hit[magic_school.fire] + pts * 0.01;

            local affl_abilities = spell_names_to_id({"Corruption", "Curse of Agony", "Death Coil", "Drain Life", "Drain Soul", "Curse of Doom", "Unstable Affliction", "Haunt", "Seed of Corruption"});
            for k, v in pairs(affl_abilities) do
                ensure_exists_and_add(effects.ability.cost_mod, v, pts * 0.02, 0.0); 
            end
        end

        -- improved corruption
        local pts = talents:pts(1, 3);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Corruption"], pts * 0.02, 0.0); 
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Seed of Corruption"], pts * 0.01, 0.0); 
        end

        -- soul siphon
        local pts = talents:pts(1, 7);
        if pts ~= 0 then
            --TODO: need to track affliction debuffs on target
        end

        -- amplify curse
        local pts = talents:pts(1, 10);
        if pts ~= 0 then
            for k, v in pairs(spell_names_to_id({"Curse of Agony", "Curse of Doom"})) do
                ensure_exists_and_add(effects.ability.cast_mod, v, 0.5, 0.0); 
            end
        end

        -- empowered corruption
        local pts = talents:pts(1, 13);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.coef_ot_mod, spell_name_to_id["Corruption"], pts*0.1, 0.0); 
        end

        -- shadow embrace
        -- implemented in buffs
        
        -- siphon life
        local pts = talents:pts(1, 15);
        if pts ~= 0 then
            for k, v in pairs(spell_names_to_id({"Seed of Corruption", "Corruption", "Unstable Affliction"})) do
                ensure_exists_and_add(effects.ability.effect_ot_mod, v, pts*0.05, 0.0); 
            end
        end

        -- shadow mastery
        local pts = talents:pts(1, 18);
        if pts ~= 0 then
            -- TODO: multiplicative or additive?
            effects.by_school.spell_dmg_mod_add[magic_school.shadow] = 
                effects.by_school.spell_dmg_mod_add[magic_school.shadow] + pts * 0.03;
        end

        -- eradication
        -- implemented in buffs

        -- contagion
        local pts = talents:pts(1, 20);
        if pts ~= 0 then
            for k, v in pairs(spell_names_to_id({"Curse of Agony", "Seed of Corruption", "Corruption"})) do
                ensure_exists_and_add(effects.ability.effect_mod, v, pts*0.01, 0.0); 
            end
        end

        -- malediction
        local pts = talents:pts(1, 23);
        if pts ~= 0 then
            effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                effects.by_school.spell_dmg_mod[magic_school.shadow] + 0.01 * pts;
            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                effects.by_school.spell_dmg_mod[magic_school.fire] + 0.01 * pts;
            for k, v in pairs(spell_names_to_id({"Corruption", "Unstable Affliction"})) do
                ensure_exists_and_add(effects.ability.crit_ot, v, pts*0.03, 0.0); 
            end
        end

        -- death's embrace
        -- implemented in later stage
        

        -- pandemic
        local pts = talents:pts(1, 26);
        if pts ~= 0 then

            local abilities = spell_names_to_id({"Corruption", "Unstable Affliction", "Haunt"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.crit_mod, v, 0.5, 0);
            end
        end

        -- everlasting affliction
        local pts = talents:pts(1, 27);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.coef_ot_mod, spell_name_to_id["Unstable Affliction"], pts*0.05, 0.0); 
            ensure_exists_and_add(effects.ability.coef_ot_mod, spell_name_to_id["Corruption"], pts*0.05, 0.0); 
        end

        -- master demonoligist
        -- TODO: buff tracking
        --
        -- demonic aegis
        -- TODO: buff tracking
        -- spirit from SP 
        
        --
        local pts = talents:pts(2, 16);

        -- molten core
        local pts = talents:pts(2, 17);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.extra_ticks, spell_name_to_id["Immolate"], pts, 0.0); 
            -- rest is done in buffs
        end

        -- decimation done in later stage
        
        -- demonic pact
        local pts = talents:pts(2, 26);
        if pts ~= 0 then
            effects.by_school.spell_dmg_mod[magic_school.fire] = 
                effects.by_school.spell_dmg_mod[magic_school.fire] + 0.02 * pts;
            effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                effects.by_school.spell_dmg_mod[magic_school.shadow] + 0.02 * pts;
        end

        -- improved shadow bolt
        local pts = talents:pts(3, 1);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Shadow Bolt"], pts*0.02, 0.0); 
        end

        -- bane
        local pts = talents:pts(3, 2);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Shadow Bolt"], pts*0.1, 0.0); 
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Chaos Bolt"], pts*0.1, 0.0); 
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Immolate"], pts*0.1, 0.0); 
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Soul Fire"], pts*0.4, 0.0); 
        end

        -- aftermath
        local pts = talents:pts(3, 3);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.effect_ot_mod, spell_name_to_id["Immolate"], pts*0.03, 0.0); 
        end

        -- TODO: are these all the destr spells? conflagrate doesnt have an id atm
        local destr = spell_names_to_id({"Rain of Fire", "Hellfire", "Shadow Bolt", "Chaos Bolt", "Immolate", "Soul Fire", "Shadowburn", "Shadowfury", "Searing Pain", "Incinerate"});

        -- cataclysm
        local pts = talents:pts(3, 5);
        if pts ~= 0 then
            local by_pts = {0.04, 0.07, 0.1};
            for k, v in pairs(destr) do
                ensure_exists_and_add(effects.ability.cost_mod, v, by_pts[pts], 0.0); 
            end
        end
        -- ruin
        local pts = talents:pts(3, 8);
        if pts ~= 0 then
            for k, v in pairs(destr) do
                ensure_exists_and_add(effects.ability.crit_mod, v, pts * 0.1, 0.0); 
            end
        end

        -- improved searing pain
        local pts = talents:pts(3, 11);
        if pts ~= 0 then
            local by_pts = {0.04, 0.07, 0.1};
            ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Searing Pain"], by_pts[pts], 0.0); 
        end

        -- backlash
        local pts = talents:pts(3, 12);
        if pts ~= 0 then
            -- TODO: dynamic crit
        end

        -- improved immolate
        local pts = talents:pts(3, 13);
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.effect_mod, spell_name_to_id["Immolate"], pts*0.1, 0.0); 
        end

        -- devastation
        local pts = talents:pts(3, 14);
        -- TODO: make sure this isn't being dynamically added ingame
        if pts ~= 0 then
            for k, v in pairs(destr) do
                ensure_exists_and_add(effects.ability.crit, v, 0.05, 0.0); 
            end
        end

        -- emberstorm
        local pts = talents:pts(3, 16);
        -- TODO: make sure this isn't being dynamically added ingame
        if pts ~= 0 then
            ensure_exists_and_add(effects.ability.cast_mod, spell_name_to_id["Incinerate"], pts * 0.05, 0.0); 
            effects.by_school.spell_dmg_mod_add[magic_school.fire] = 
                effects.by_school.spell_dmg_mod_add[magic_school.fire] + 0.03 * pts;
        end

        -- pyroclasm
        -- done in buffs
        
        -- shadow and flame
        local pts = talents:pts(3, 20);
        if pts ~= 0 then
            for k, v in pairs(spell_names_to_id({"Shadow Bolt", "Shadowburn", "Chaos Bolt", "Incinerate"})) do
                ensure_exists_and_add(effects.ability.coef_mod, v, pts * 0.04, 0.0); 
            end
        end

        -- fire and brimstone
        local pts = talents:pts(3, 25);
        if pts ~= 0 then
            -- TODO: when conflagrate is implemented uncomment this
            --ensure_exists_and_add(effects.ability.crit, spell_name_to_id["Conflagrate"], pts * 0.05, 0.0); 
        end



    end
end

addonTable.glyphs = glyphs;
addonTable.wowhead_talent_link = wowhead_talent_link
addonTable.wowhead_talent_code_from_url = wowhead_talent_code_from_url;
addonTable.wowhead_talent_code = wowhead_talent_code;
addonTable.talent_glyphs_table = talent_glyphs_table;
addonTable.apply_talents_glyphs = apply_talents_glyphs;

