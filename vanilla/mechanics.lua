local _, sc = ...;

local attr                                          = sc.attr;
local spells                                        = sc.spells;
local spids                                         = sc.spids;
local schools                                       = sc.schools;
local class                                         = sc.class;
local classes                                       = sc.classes;
local powers                                        = sc.powers;
local spell_flags                                   = sc.spell_flags;
local comp_flags                                    = sc.comp_flags;
---------------------------------------------------------------------------------------------------
local mechanics = {};
-- Vanilla specific behaviour uncompatible with other version

local class_stats_spell = (function()
    if class == classes.warrior then
        return function(anycomp, bid, stats, spell, loadout, effects)
        end
    elseif class == classes.paladin then
        return function(anycomp, bid, stats, spell, loadout, effects)
        end
    elseif class == classes.hunter then
        return function(anycomp, bid, stats, spell, loadout, effects)
        end
    elseif class == classes.rogue then
        return function(stats, spell, loadout, effects)
        end
    elseif class == classes.priest then
        return function(anycomp, bid, stats, spell, loadout, effects)
        end
    elseif class == classes.shaman then
        return function(anycomp, bid, stats, spell, loadout, effects)
        end
    elseif class == classes.mage then
        return function(anycomp, bid, stats, spell, loadout, effects)
            if bid == spids.arcane_surge then
                stats.spell_dmg_mod_mul = stats.spell_dmg_mod_mul *
                    (1.0 + 100*spell.direct.per_resource * loadout.resources[powers.mana] / loadout.resources_max[powers.mana]);
            end
        end
    elseif class == classes.warlock then
        return function(anycomp, bid, stats, spell, loadout, effects)
        end
    elseif class == classes.druid then
        return function(anycomp, bid, stats, spell, loadout, effects)
        end
    end
end)();


mechanics.client_class_stats_spell = class_stats_spell;

sc.mechanics = mechanics;
