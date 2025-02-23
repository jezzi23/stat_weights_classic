local _, sc                = ...;

local class                 = sc.class;
local config                = sc.config;
local apply_effect          = sc.loadout.apply_effect;
---------------------------------------------------------------------------------------------------
local talents_export        = {};

local function wowhead_talent_link(code)
    local lowercase_class = string.lower(class);
    return "https://classic.wowhead.com/talent-calc/" .. lowercase_class .. "/" .. code;
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
    local talent_code = "";

    local sub_codes = { "", "", "" };
    for i = 1, 3 do
        -- NOTE: GetNumTalents(i) will return 0 on early calls after logging in,
        --       but works fine after reload
        for _, v in pairs(sc.talent_order[i]) do
            local _, _, _, _, pts, _, _, _ = GetTalentInfo(i, v);
            sub_codes[i] = sub_codes[i]..tostring(pts);
        end
        local num_redundant = 0;
        local n = #sub_codes[i];
        for k = 1, n do
            if string.sub(sub_codes[i], n-k+1, n-k+1) == "0" then
                num_redundant = num_redundant + 1;
            else
                break;
            end
        end
        sub_codes[i] = string.sub(sub_codes[i], 1, n-num_redundant);
    end
    if sub_codes[2] == "" and sub_codes[3] == "" then
        talent_code = sub_codes[1];
    elseif sub_codes[2] == "" then
        talent_code = sub_codes[1] .. "--" .. sub_codes[3];
    elseif sub_codes[3] == "" then
        talent_code = sub_codes[1] .. "-" .. sub_codes[2];
    else
        talent_code = sub_codes[1] .. "-" .. sub_codes[2] .. "-" .. sub_codes[3];
    end

    return talent_code .. "_";
end

local function talent_table(wowhead_code)
    local talents_t = {};

    for k, v in pairs(sc.talent_order) do
        for i, _ in pairs(v) do
            talents_t[k*100+i] = 0;
        end
    end

    local i = 1;
    local tree_index = 1;
    local talent_index = 1;

    while wowhead_code:sub(i, i) ~= "" and wowhead_code:sub(i, i) ~= "_" do
        if wowhead_code:sub(i, i) == "-" then
            tree_index = tree_index + 1;
            talent_index = 1;
        elseif tonumber(wowhead_code:sub(i, i)) then
            talents_t[tree_index*100 + talent_index] = tonumber(wowhead_code:sub(i, i));
            talent_index = talent_index + 1;
        end
        i = i + 1;
    end

    return talents_t;
end

local function apply_talents(loadout, effects)

    -- weapon skills 
    for i = 1, GetNumSkillLines() do
        local skill_lname, _, _, skill = GetSkillLineInfo(i);
        local wep_subclass = sc.wpn_skill_lname_to_subclass[skill_lname];
        if wep_subclass then
            loadout.wpn_skills[wep_subclass] = skill;
        end
    end

    local dynamic_talents, _ = talent_table(loadout.talents.code);

    local custom_talents, _ = nil, nil;

    if not config.loadout.use_custom_talents then
        loadout.talents.pts = dynamic_talents;
    else
        custom_talents, _ = talent_table(config.loadout.custom_talents_code);
        loadout.talents.pts = custom_talents;
    end
    for id, pts in pairs(loadout.talents.pts) do
        if pts > 0 and sc.talent_ranks[id] then
            local effect_id = sc.talent_ranks[id][pts];
            if effect_id then
                apply_effect(effects,
                             effect_id,
                             sc.talent_effects[effect_id],
                             config.loadout.use_custom_talents,
                             1,
                             false);
            end
        end
    end
    --if config.loadout.use_custom_talents then
    --    -- undo dynamic talents
    --    for id, pts in pairs(dynamic_talents) do
    --        if pts > 0 and sc.talent_ranks[id] then
    --            local effect_id = sc.talent_ranks[id][pts];
    --            if effect_id then
    --                apply_effect(effects,
    --                             effect_id,
    --                             sc.talent_effects[effect_id],
    --                             false,
    --                             1,
    --                             true);
    --            end
    --        end
    --    end
    --end

    if sc.core.__sw__test_all_codepaths then
        --for k, v in pairs(runes) do
        --    loadout.runes[k] = v;
        --    if v.apply then
        --        v.apply(loadout, effects, true);
        --    end
        --end
        --for k, v in pairs(talents) do
        --    for i = 1, 3 do
        --        for j = 1, 29 do
        --            local id = i*100 + j;
        --            if custom_talents then
        --                custom_talents[id] = 5;
        --            end
        --            if dynamic_talents then
        --                dynamic_talents[id] = 5;
        --            end
        --        end
        --    end
        --    if v.apply then
        --        v.apply(loadout, effects, 3, 3);
        --    end
        --end
        -- Testing all special passives
        local passives_applied = 0;
        for id, e in pairs(sc.passives) do
            apply_effect( effects, id, e, true, 1);
            passives_applied = passives_applied + 1;
        end

        print(passives_applied, "gen passives applied");

        -- Testing all talents
        local applied = 0;
        for _, v in pairs(sc.talent_ranks) do
            for _, i in pairs(v) do
                apply_effect(effects, i, sc.talent_effects[i], true, 1);
                applied = applied + 1;
            end
        end
        print(applied, "gen talents applied");

    end
end

talents_export.wowhead_talent_link = wowhead_talent_link
talents_export.wowhead_talent_code_from_url = wowhead_talent_code_from_url;
talents_export.wowhead_talent_code = wowhead_talent_code;
talents_export.talent_table = talent_table;
talents_export.apply_talents = apply_talents;
talents_export.rune_ids = rune_ids;

sc.talents = talents_export;
