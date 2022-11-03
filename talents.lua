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
                    -- add to gmod?
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

        -- arcane subtlety
        local pts = talents:pts(1, 1);
        if pts ~= 0 then
            for i = 2, 7 do
                effects.target_res_by_school[i] = effects.target_res_by_school[i] - pts * 5;
            end
        end
        -- arcane focus
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            effects.spell_dmg_hit_by_school[magic_school.arcane] = 
                effects.spell_dmg_hit_by_school[magic_school.arcane] + pts * 0.02;
        end
        --  improved arcane explosion
        local pts = talents:pts(1, 8);
        if pts ~= 0 then
            local ae = spell_name_to_id["Arcane Explosion"];
            if not effects.ability.crit[ae] then
                effects.ability.crit[ae] = 0;
            end
            effects.ability.crit[ae] = effects.ability.crit[ae] + pts * 0.02;
        end
        --  arcane mediation
        local pts = talents:pts(1, 12);
        if pts ~= 0 then
            effects.regen_while_casting = effects.regen_while_casting + pts * 0.05;
        end
        --  arcane mind
        local pts = talents:pts(1, 14);
        if pts ~= 0 then
            effects.mana_mod = effects.mana_mod + pts * 0.02;
        end
        -- arcane instability
        local pts = talents:pts(1, 15);
        if pts ~= 0 then
            for i = 1, 7 do
                effects.spell_dmg_mod_by_school[i] = effects.spell_dmg_mod_by_school[i] + pts * 0.01;
                effects.spell_crit_by_school[i] = effects.spell_crit_by_school[i] + pts * 0.01;
            end
        end
        -- improved fireball
        local pts = talents:pts(2, 1);
        if pts ~= 0 then
            local fb = spell_name_to_id["Fireball"];
            if not effects.ability.cast_mod[fb] then
                effects.ability.cast_mod[fb] = 0;
            end
            effects.ability.cast_mod[fb] = effects.ability.cast_mod[fb] + pts * 0.1;
        end
        -- ignite
        local pts = talents:pts(2, 3);
        if pts ~= 0 then
           effects.ignite = pts; 
        end
        -- incinerate
        local pts = talents:pts(2, 6);
        if pts ~= 0 then
            local scorch = spell_name_to_id["Scorch"];
            local fb = spell_name_to_id["Fire Blast"];
            if not effects.ability.crit[scorch] then
                effects.ability.crit[scorch] = 0;
            end
            if not effects.ability.crit[fb] then
                effects.ability.crit[fb] = 0;
            end
            effects.ability.crit[scorch] = effects.ability.crit[scorch] + pts * 0.02;
            effects.ability.crit[fb] = effects.ability.crit[fb] + pts * 0.02;
        end
        -- improved flamestrike
        local pts = talents:pts(2, 7);
        if pts ~= 0 then
            local fs = spell_name_to_id["Flamestrike"];
            if not effects.ability.crit[fs] then
                effects.ability.crit[fs] = 0;
            end
            effects.ability.crit[fs] = effects.ability.crit[fs] + pts * 0.05;
        end
        -- master of elements
        local pts = talents:pts(2, 12);
        if pts ~= 0 then
            effects.master_of_elements = pts;
        end
        -- critical mass
        local pts = talents:pts(2, 13);
        if pts ~= 0 then
            loadout.spell_crit_by_school[magic_school.fire] =
                loadout.spell_crit_by_school[magic_school.fire] + pts * 0.02;
        end
        -- fire power
        local pts = talents:pts(2, 15);
        if pts ~= 0 then
            effects.by_school.spell_dmg_mod[magic_school.fire] =
                effects.by_school.spell_dmg_mod[magic_school.fire] + pts * 0.02;
        end
        -- improved frostbolt
        local pts = talents:pts(3, 2);
        if pts ~= 0 then
            local fb = spell_name_to_id["Frostbolt"];
            if not effects.ability.cast_mod[fb] then
                effects.ability.cast_mod[fb] = 0;
            end
            effects.ability.cast_mod[fb] = effects.ability.cast_mod[fb] + pts * 0.1;
        end
        -- elemental precision
        local pts = talents:pts(3, 3);
        if pts ~= 0 then
            effects.by_school.spell_dmg_hit[magic_school.fire] = 
                effects.by_school.spell_dmg_hit[magic_school.fire] + pts * 0.02;
            effects.by_school.spell_dmg_hit[magic_school.frost] = 
                effects.by_school.spell_dmg_hit[magic_school.frost] + pts * 0.02;
        end
        -- ice shards
        local pts = talents:pts(3, 4);
        if pts ~= 0 then
            effects.by_school.spell_crit_mod[magic_school.frost] = 
                1 + (effects.by_school.spell_crit_mod[magic_school.frost] - 1) * (1 + pts * 0.2);
        end
        -- piercing ice
        local pts = talents:pts(3, 8);
        if pts ~= 0 then
            effects.by_school.spell_dmg_mod[5] = effects.by_school.spell_dmg_mod[5] + pts * 0.02;
        end
        -- frost channeling
        local pts = talents:pts(3, 12);
        if pts ~= 0 then

            local cold_spells = {"Frostbolt", "Blizzard", "Cone of Cold", "Frost Nova"};
            for k, v in pairs(cold_spells) do
                cold_spells[k] = spell_name_to_id[v];
            end

            for k, v in pairs(cold_spells) do
                if not effects.ability.cost_mod[v] then
                    effects.ability.cost_mod[v] = 0;
                end
            end
            for k, v in pairs(cold_spells) do
                effects.ability.cost_mod[v] = effects.ability.cost_mod[v] + pts * 0.05;
            end
        end
        -- improved cone of cold
        local pts = talents:pts(3, 15);
        if pts ~= 0 then
            local coc = spell_name_to_id["Cone of Cold"];
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
            effects.ot_mod = effects.ot_mod + 0.01 * pts;
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
           effects.raw.lunar_guidance = pts * 0.04; 
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
            local abilities = spell_names_to_id({"Starfire", "Moonfire", "Wrath"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.effect_mod, v, pts * 0.03, 0.0);
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

            local sf = spell_name_to_id["Starfire"];
            local w = spell_name_to_id["Wrath"];
            ensure_exists_and_add(effects.ability.coef_mod, sf, pts * 0.04, 0);
            ensure_exists_and_add(effects.ability.coef_mod, w, pts * 0.02, 0);
        end

        -- eclipse
        local pts = talents:pts(1, 23);
        if pts ~= 0 then

            -- TODO: eclipse tracking
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
            effects.regen_while_casting = effects.regen_while_casting + regen[pts];
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

            effects.spell_crit_by_school[magic_school.nature] = 
                effects.spell_crit_by_school[magic_school.nature] + 0.01 * pts;
            effects.spell_crit_by_school[magic_school.arcane] = 
                effects.spell_crit_by_school[magic_school.arcane] + 0.01 * pts;
        end

        -- empowered rejuvenation
        local pts = talents:pts(3, 20);
        if pts ~= 0 then
            local hots = spell_names_to_id({"Lifebloom", "Regrowth",  "Wild Growth", "Rejuvenation"});
            for k, v in pairs(hots) do
                ensure_exists_and_add(effects.ability.coef_ot_mod, v, pts * 0.04, 0);
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
            local abilities = spell_names_to_id({"Regrowth", "Rejuvenation", "Lifebloom", "Wild Growth"});
            for k, v in pairs(abilities) do
                ensure_exists_and_add(effects.ability.cost_mod, v, 0.2, 0);
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
            effects.haste_mod = (1.0 + effects.haste_mod) * (1.0 + pts * 0.02) - 1.0;
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
            -- TODO: unclear how this spell % dmg is added, before or with other % ?
            --effects.dmg_mod = effects.dmg_mod + pts * 0.02;
            --effects.spell_heal_mod = effects.spell_heal_mod + pts * 0.02;
            effects.raw.gmod = (1.0 + effects.raw.gmod) * (1 + pts*0.02) - 1.0;
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
            effects.by_school.spell_crit[magic_school.holy] = 
                effects.by_school.spell_crit[magic_school.holy] + pts * 0.01;
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
           effects.raw.spiritual_guidance = pts * 0.05; 
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
            effects.by_school.spell_dmg_hit[magic_school.shadow] = 
                effects.by_school.spell_dmg_hit[magic_school.shadow] + pts * 0.01;

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
             
           effects.raw.spiritual_guidance = pts * 0.04; 
        end
        
    elseif class == "SHAMAN" then

        -- convection
        local pts = talents:pts(1, 1);
        if pts ~= 0 then
            local abilities = {"Earth Shock", "Frost Shock", "Flame Shock", "Lightning Bolt", "Chain Lightning"};
            for k, v in pairs(abilities) do
                abilities[k] = spell_name_to_id[v];
            end

            for k, v in pairs(abilities) do
                if not effects.ability.cost_mod[v] then
                    effects.ability.cost_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                effects.ability.cost_mod[v] = effects.ability.cost_mod[v] + pts * 0.02;
            end
        end

        -- concussion
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            local abilities = {"Earth Shock", "Frost Shock", "Flame Shock", "Lightning Bolt", "Chain Lightning"};
            for k, v in pairs(abilities) do
                abilities[k] = spell_name_to_id[v];
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
                abilities[k] = spell_name_to_id[v];
            end

            for k, v in pairs(abilities) do
                if not effects.ability.crit[v] then
                    effects.ability.crit[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                if pts == 5 then
                    effects.ability.crit[v] = effects.ability.crit[v] + 0.06;
                else
                    effects.ability.crit[v] = effects.ability.crit[v] + pts * 0.01;
                end
            end
        end

        -- elemental fury
        local pts = talents:pts(1, 13);
        if pts ~= 0 then
            effects.by_school.spell_crit_mod[magic_school.frost] = 
                1 + (effects.by_school.spell_crit_mod[magic_school.frost] - 1) * 2;
            effects.by_school.spell_crit_mod[magic_school.fire] = 
                1 + (effects.by_school.spell_crit_mod[magic_school.fire] - 1) * 2;
            effects.by_school.spell_crit_mod[magic_school.nature] = 
                1 + (effects.by_school.spell_crit_mod[magic_school.nature] - 1) * 2;
        end

        -- lightning mastery
        local pts = talents:pts(1, 14);
        if pts ~= 0 then

            local abilities = {"Lightning Bolt", "Chain Lightning"};
            for k, v in pairs(abilities) do
                abilities[k] = spell_name_to_id[v];
            end

            for k, v in pairs(abilities) do
                if not effects.ability.cast_mod[v] then
                    effects.ability.cast_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                effects.ability.cast_mod[v] = effects.ability.cast_mod[v] + pts * 0.2;
            end
        end

        -- improved lightning shield
        local pts = talents:pts(2, 6);
        if pts ~= 0 then
            local ls = spell_name_to_id["Lightning Shield"];
        end

        -- improved healing wave
        local pts = talents:pts(3, 1);
        if pts ~= 0 then
            local hw = spell_name_to_id["Healing Wave"];
            if not effects.ability.cast_mod[hw] then
                effects.ability.cast_mod[hw] = 0;
            end
            effects.ability.cast_mod[hw] = effects.ability.cast_mod[hw] + pts * 0.1;
        end

        -- tidal focus
        local pts = talents:pts(3, 2);
        if pts ~= 0 then

            local abilities = {"Lesser Healing Wave", "Healing Wave", "Chain Heal", "Healing Stream Totem"};

            for k, v in pairs(abilities) do
                abilities[k] = spell_name_to_id[v];
            end
            for k, v in pairs(abilities) do
                if not effects.ability.cost_mod[v] then
                    effects.ability.cost_mod[v] = 0;
                end
            end
            for k, v in pairs(abilities) do
                effects.ability.cost_mod[v] = effects.ability.cost_mod[v] + pts * 0.01;
            end
        end

        -- totemic focus
        local pts = talents:pts(3, 5);
        if pts ~= 0 then

            local totems = {"Healing Stream Totem", "Magma Totem", "Searing Totem", "Fire Nova Totem"};

            for k, v in pairs(totems) do
                totems[k] = spell_name_to_id[v];
            end

            for k, v in pairs(totems) do
                if not effects.ability.cost_mod[v] then
                    effects.ability.cost_mod[v] = 0;
                end
            end
            for k, v in pairs(totems) do
                effects.ability.cost_mod[v] = effects.ability.cost_mod[v] + pts * 0.05;
            end
        end

        local pts = talents:pts(3, 10);
        if pts ~= 0 then

            local totems = {"Healing Stream Totem"};
            for k, v in pairs(totems) do
                totems[k] = spell_name_to_id[v];
            end

        end

        -- tidal mastery
        local pts = talents:pts(3, 11);
        if pts ~= 0 then


            local lightning_spells = {"Lightning Bolt", "Chain Lightning", "Lightning Shield"};

            for k, v in pairs(lightning_spells) do
                lightning_spells[k] = spell_name_to_id[v];
            end

            for k, v in pairs(lightning_spells) do
                if not effects.ability.crit[v] then
                    effects.ability.crit[v] = 0;
                end
            end
            for k, v in pairs(lightning_spells) do
                effects.ability.crit[v] = effects.ability.crit[v] + pts * 0.01;
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
            effects.by_school.spell_crit[magic_school.holy] = 
                effects.by_school.spell_crit[magic_school.holy] + pts * 0.01;
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
            effects.raw.spell_heal_mod = effects.raw.spell_heal_mod + pts * 0.02;
            effects.raw.target_healing_taken = effects.raw.target_healing_taken + pts * 0.02;
        end
        -- benediction
        local pts = talents:pts(3, 2);
        if pts ~= 0 then
            local hs = spell_name_to_id["Holy Shock"];
            ensure_exists_and_add(effects.ability.cost_mod, hs, pts * 0.02, 0.0); 
        end

    elseif class == "WARLOCK" then
        local affl = {"Corruption", "Siphon Life", "Curse of Agony", "Death Coil", "Drain Life", "Drain Soul"};
        for k, v in pairs(affl) do
            affl[k] = spell_name_to_id[v];
        end
        local destr = {"Shadow Bolt", "Searing Pain", "Soul Fire", "Hellfire", "Rain of Fire", "Immolate", "Shadowburn", "Conflagrate"};
        for k, v in pairs(destr) do
            destr[k] = spell_name_to_id[v];
        end


        -- suppression
        local pts = talents:pts(1, 1);
        if pts ~= 0 then

            for k, v in pairs(affl) do
                if not effects.ability.hit[v] then
                    effects.ability.hit[v] = 0;
                end
            end
            for k, v in pairs(affl) do
                effects.ability.hit[v] = 
                    effects.ability.hit[v] + pts * 0.02;
            end
        end
        -- improved corruption
        local pts = talents:pts(1, 2);
        if pts ~= 0 then
            local corruption = spell_name_to_id["Corruption"];

            if not effects.ability.cast_mod[corruption] then
                effects.ability.cast_mod[corruption] = 0;
            end

            effects.ability.cast_mod[corruption] = 
                effects.ability.cast_mod[corruption] + pts * 0.4;
        end

        -- improved curse of agony
        local pts = talents:pts(1, 7);
        if pts ~= 0 then
            local coa = spell_name_to_id["Curse of Agony"];

        end
        -- shadow mastery
        local pts = talents:pts(1, 16);
        if pts ~= 0 then

            effects.by_school.spell_dmg_mod[magic_school.shadow] = 
                effects.by_school.spell_dmg_mod[magic_school.shadow] + pts * 0.02;
        end

        -- improved shadow bolt
        local pts = talents:pts(3, 1);
        if pts ~= 0 then
           effects.improved_shadowbolt = pts; 
        end

        -- cataclysm
        local pts = talents:pts(3, 2);
        if pts ~= 0 then

            for k, v in pairs(destr) do
                if not effects.ability.cost_mod[v] then
                    effects.ability.cost_mod[v] = 0;
                end
            end
            for k, v in pairs(destr) do
                effects.ability.cost_mod[v] = 
                    effects.ability.cost_mod[v] + pts * 0.01;
            end
        end
        -- bane
        local pts = talents:pts(3, 3);
        if pts ~= 0 then
            local imm = spell_name_to_id["Immolate"];
            local sb = spell_name_to_id["Shadow Bolt"];
            local sf = spell_name_to_id["Soul Fire"];

            if not effects.ability.cast_mod[imm] then
                effects.ability.cast_mod[imm] = 0;
            end
            if not effects.ability.cast_mod[sb] then
                effects.ability.cast_mod[sb] = 0;
            end
            if not effects.ability.cast_mod[sf] then
                effects.ability.cast_mod[sf] = 0;
            end

            effects.ability.cast_mod[imm] = effects.ability.cast_mod[imm] + pts * 0.1;
            effects.ability.cast_mod[sb] = effects.ability.cast_mod[sb] + pts * 0.1;
            effects.ability.cast_mod[sf] = effects.ability.cast_mod[sf] + pts * 0.4;
        end
        -- devastation
        local pts = talents:pts(3, 7);
        if pts ~= 0 then

            for k, v in pairs(destr) do
                if not effects.ability.crit[v] then
                    effects.ability.crit[v] = 0;
                end
            end
            for k, v in pairs(destr) do
                effects.ability.crit[v] = 
                    effects.ability.crit[v] + pts * 0.01;
            end
        end
        -- improved searing pain
        local pts = talents:pts(3, 11);
        if pts ~= 0 then
            local sp = spell_name_to_id["Searing Pain"];
            if not effects.ability.crit[sp] then
                effects.ability.crit[sp] = 0;
            end
            effects.ability.crit[sp] = effects.ability.crit[sp] + pts * 0.02;
        end

        -- improved immolate
        local pts = talents:pts(3, 13);
        effects.improved_immolate = pts;

        -- ruin 
        local pts = talents:pts(3, 14);
        if pts ~= 0 then

            for k, v in pairs(destr) do
                if not effects.ability.crit_mod[v] then
                    effects.ability.crit_mod[v] = 0;
                end
            end
            for k, v in pairs(destr) do
                effects.ability.crit_mod[v] = 
                    effects.ability.crit_mod[v] + 0.5;
            end
        end
        --emberstorm
        local pts = talents:pts(3, 15);
        if pts ~= 0 then
            effects.by_school.spell_dmg_mod[magic_school.fire] =
                effects.by_school.spell_dmg_mod[magic_school.fire] + pts * 0.02;
        end
    end
end

addonTable.glyphs = glyphs;
addonTable.wowhead_talent_link = wowhead_talent_link
addonTable.wowhead_talent_code_from_url = wowhead_talent_code_from_url;
addonTable.wowhead_talent_code = wowhead_talent_code;
addonTable.talent_glyphs_table = talent_glyphs_table;
addonTable.apply_talents_glyphs = apply_talents_glyphs;

