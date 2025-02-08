-- THIS FILE IS GENERATED
local _, sc = ...;
sc.client_name_src = "wow_classic_era";
sc.client_version_src = "1.15.6.58912";
_, sc.class = UnitClass("player");
_, _, sc.race = UnitRace("player");
sc.classes = {
	warrior = "WARRIOR",
	paladin = "PALADIN",
	hunter = "HUNTER",
	rogue = "ROGUE",
	priest = "PRIEST",
	shaman = "SHAMAN",
	mage = "MAGE",
	warlock = "WARLOCK",
	druid = "DRUID",
	fake = "FAKE",
};
sc.races = {
	human = 1,
	orc = 2,
	dwarf = 3,
	nightelf = 4,
	scourge = 5,
	tauren = 6,
	gnome = 7,
	troll = 8,
	goblin = 9,
};
sc.schools = {
	physical = 1,
	holy = 2,
	fire = 3,
	nature = 4,
	frost = 5,
	shadow = 6,
	arcane = 7,
};
sc.stats = {
	strength = 1,
	agility = 2,
	stamina = 3,
	intellect = 4,
	spirit = 5,
};
sc.powers = {
	mana = 0,
	rage = 1,
	focus = 2,
	energy = 3,
	combopoints = 4,
	happiness = 27,
};
sc.spell_flags = {
	heal = bit.lshift(1, 0),
	absorb = bit.lshift(1, 1),
	channel = bit.lshift(1, 2),
	cd = bit.lshift(1, 3),
	base_mana_cost = bit.lshift(1, 4),
	instant = bit.lshift(1, 5),
	binary = bit.lshift(1, 6),
	eval = bit.lshift(1, 7),
	resource_regen = bit.lshift(1, 8),
	regen_pct = bit.lshift(1, 9),
	regen_max_pct = bit.lshift(1, 10),
	entire_channel_missable = bit.lshift(1, 11),
	weapon_enchant = bit.lshift(1, 12),
	resi_pen = bit.lshift(1, 13),
	alias = bit.lshift(1, 14),
	on_next_attack = bit.lshift(1, 15),
	uses_attack_speed = bit.lshift(1, 16),
	finishing_move_dmg = bit.lshift(1, 17),
	finishing_move_dur = bit.lshift(1, 18),
	pet = bit.lshift(1, 19),
	refund_on_miss = bit.lshift(1, 20),
};
sc.comp_flags = {
	cant_crit = bit.lshift(1, 0),
	always_hit = bit.lshift(1, 1),
	periodic = bit.lshift(1, 2),
	unbounded_aoe = bit.lshift(1, 3),
	resi_pen = bit.lshift(1, 4),
	applies_mh = bit.lshift(1, 5),
	applies_oh = bit.lshift(1, 6),
	applies_ranged = bit.lshift(1, 7),
	bleed = bit.lshift(1, 8),
	white = bit.lshift(1, 9),
};
sc.aura_flags = {
	mul = bit.lshift(1, 0),
	inactive_forced = bit.lshift(1, 1),
	player_owned = bit.lshift(1, 2),
	weapon_subclass = bit.lshift(1, 3),
};