-- THIS FILE IS GENERATED
local _, sc = ...;
if sc.class ~= sc.classes.fake then return; end
local powers = sc.powers
local schools = sc.schools
local spell_flags = sc.spell_flags
local comp_flags = sc.comp_flags
sc.spells = {
};
sc.spids = {
};
sc.rank_seqs = {
};
sc.spells_lvl_ordered = {
};
sc.talent_order = {
};
sc.talent_effects = {
};
sc.talent_ranks = {
};
sc.class_buffs = {
};
local class_hostile_buffs = {
};
for k, v in pairs(class_hostile_buffs) do sc.hostile_buffs[k] = v; end
local class_friendly_buffs = {
};
for k, v in pairs(class_friendly_buffs) do sc.friendly_buffs[k] = v; end
local set_items = {
	[21395] = 506,
	[21396] = 506,
	[233413] = 1837,
	[19685] = 441,
	[230925] = 1798,
	[233443] = 1866,
	[18202] = 261,
	[13218] = 65,
	[22302] = 520,
	[15054] = 141,
	[21345] = 503,
	[13183] = 65,
	[228573] = 1783,
	[22311] = 520,
	[220589] = 1651,
	[21343] = 503,
	[18205] = 261,
	[16808] = 203,
	[19695] = 444,
	[16809] = 203,
	[14620] = 124,
	[19693] = 444,
	[14622] = 124,
	[21407] = 494,
	[228006] = 1786,
	[21401] = 510,
	[230943] = 1799,
	[227999] = 1786,
	[21347] = 503,
	[228146] = 1779,
	[21409] = 494,
	[16803] = 203,
	[18204] = 261,
	[230934] = 1798,
	[16810] = 203,
	[233441] = 1866,
	[233414] = 1837,
	[15055] = 141,
	[233412] = 1837,
	[21402] = 510,
	[233440] = 1865,
	[21403] = 510,
	[233416] = 1837,
	[22313] = 520,
	[231281] = 1830,
	[231341] = 1830,
	[233438] = 1865,
	[22303] = 520,
	[228145] = 1779,
	[21397] = 506,
	[18203] = 261,
	[16805] = 203,
	[233442] = 1866,
	[22305] = 520,
	[22301] = 520,
	[227867] = 1789,
	[19910] = 463,
	[233439] = 1865,
	[230999] = 1799,
	[19686] = 441,
	[21355] = 493,
	[22304] = 520,
	[228002] = 1786,
	[17064] = 241,
	[17082] = 241,
	[227868] = 1789,
	[14621] = 124,
	[231340] = 1830,
	[220588] = 1651,
	[227866] = 1789,
	[19694] = 444,
	[233419] = 1858,
	[16804] = 203,
	[21346] = 503,
	[19912] = 464,
	[19873] = 464,
	[233418] = 1858,
	[21353] = 493,
	[16807] = 203,
	[19687] = 441,
	[228000] = 1786,
	[15053] = 141,
	[14623] = 124,
	[231343] = 1830,
	[233415] = 1837,
	[21408] = 494,
	[21357] = 493,
	[16806] = 203,
	[14624] = 124,
	[21344] = 503,
	[19896] = 463,
	[22306] = 520,
	[233417] = 1858,
	[228147] = 1779,
	[228008] = 1786,
	[228592] = 1783,
	[21356] = 493,
	[21354] = 493,
	[231342] = 1830,
};
for k, v in pairs(set_items) do sc.set_items[k] = v; end
local set_bonuses = {
};
for k, v in pairs(set_bonuses) do sc.set_bonuses[k] = v; end
local items = {
};
for k, v in pairs(items) do sc.items[k] = v; end
local item_effects = {
};
for k, v in pairs(item_effects) do sc.item_effects[k] = v; end
local set_effects = {
};
for k, v in pairs(set_effects) do sc.set_effects[k] = v; end
local enchant_effects = {
};
for k, v in pairs(enchant_effects) do sc.enchant_effects[k] = v; end
local enchants = {
};
for k, v in pairs(enchants) do sc.enchants[k] = v; end
local passives = {
};
for k, v in pairs(passives) do sc.passives[k] = v; end
sc.shapeshift_passives = {
};
