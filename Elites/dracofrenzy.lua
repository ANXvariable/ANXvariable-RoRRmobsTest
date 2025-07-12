local path_string = "Elites/Dracofrenzy/"

local spr_palette = load_sprite("ElitePaletteDracofrenzy", path_string.."sElitePaletteDracofrenzy.png")
local spr_icon = load_sprite("EliteIconDracofrenzy", path_string.."sEliteIconDracofrenzy.png", 1, 14, 9)
local spr_frenzymeter = load_sprite("sEfFrenzyMeter", path_string.."sEfFrenzyMeter.png", 1, 30, 4)
local sFrenzyVirusIncubate = load_sprite("sFrenzyVirusIncubate", path_string.."sFrenzyVirusIncubate.png", 1, 6, -6)
local sFrenzyVirusDisease = load_sprite("sFrenzyVirusDisease", path_string.."sFrenzyVirusDisease.png", 1, 6, -6)
local sFrenzyVirusCure = load_sprite("sFrenzyVirusCure", path_string.."sFrenzyVirusCure.png", 1, 6, -6)

local eliteDracofrenzy = Elite.new(NAMESPACE, "dracofrenzy")
eliteDracofrenzy.healthbar_icon = spr_icon
eliteDracofrenzy.palette = spr_palette
eliteDracofrenzy.blend_col = Color.PURPLE
GM.elite_generate_palettes()

local itemEliteOrbDracofrenzy = Item.new(NAMESPACE, "eliteOrbDracofrenzy", true)
itemEliteOrbDracofrenzy.is_hidden = true

local frenzyVirusIncubate = Buff.new(NAMESPACE, "frenzyVirusIncubate")
local frenzyVirusDisease  = Buff.new(NAMESPACE, "frenzyVirusDisease")
local frenzyVirusCure     = Buff.new(NAMESPACE, "frenzyVirusCure")
frenzyVirusIncubate.icon_sprite = sFrenzyVirusIncubate
frenzyVirusDisease.icon_sprite = sFrenzyVirusDisease
frenzyVirusCure.icon_sprite = sFrenzyVirusCure
frenzyVirusIncubate.is_debuff = true
frenzyVirusDisease.is_debuff = true
frenzyVirusCure.is_debuff = false

local obj_frenzyMeter = Object.new(NAMESPACE, "FrenzyMeter")
obj_frenzyMeter.obj_depth = -400

local frenzyParticle = Particle.new(NAMESPACE, "frenzyParticle")
frenzyParticle:set_shape(Particle.SHAPE.disk)
frenzyParticle:set_scale(0.2, 0.2)
frenzyParticle:set_color1(0)
frenzyParticle:set_alpha2(1, 0)
frenzyParticle:set_life(30, 60)
frenzyParticle:set_gravity(0.03125, 90)
frenzyParticle:set_direction(0, 360, 0, 0)
frenzyParticle:set_speed(0.5, 1.5, 0, 0)

eliteDracofrenzy:clear_callbacks()
eliteDracofrenzy:onApply(function(actor)
	actor:item_give(itemEliteOrbDracofrenzy)
	actor.hp = actor.maxhp / 2.8
end)

itemEliteOrbDracofrenzy:clear_callbacks()
itemEliteOrbDracofrenzy:onPostStep(function(actor, stack)
	if gm._mod_net_isClient() then return end
	local data = actor:get_data()
	local width = actor.bbox_right - actor.bbox_left
	if Global._current_frame % 6 == 0 then
		frenzyParticle:create(actor.x + (width * (0.5 - math.random())), actor.bbox_bottom - 16 * math.random(), 2 + math.ceil(width / 4), Particle.SYSTEM.above)
	end
end)

itemEliteOrbDracofrenzy:onStatRecalc(function(actor, stack)
	actor.maxhp = actor.maxhp / 2.8
	if actor.hp > actor.maxhp then
		actor.hp = actor.maxhp
	end
	actor.attack_speed = actor.attack_speed * 1.1
	actor.pHmax = actor.pHmax * 1.1
end)

itemEliteOrbDracofrenzy:onAttackHit(function(actor, victim, stack, hit_info)
	if victim:buff_stack_count(frenzyVirusIncubate) == 0 and victim:buff_stack_count(frenzyVirusDisease) == 0 and victim:buff_stack_count(frenzyVirusCure) == 0 then
		victim:buff_apply(frenzyVirusIncubate, 1801)
	end
end)

frenzyVirusIncubate:clear_callbacks()
frenzyVirusIncubate:onApply(function(actor, stack)
	local data = actor:get_data()
	data.frenzyCureProgress = 0
	data.frenzyCureFailure = false
end)

frenzyVirusIncubate:onPostStep(function(actor, stack)
	local data = actor:get_data()
	local bufftime = GM.get_buff_time(actor, frenzyVirusIncubate)
	local width = actor.bbox_right - actor.bbox_left
	if not Instance.exists(data.frenzyMeter) then
		data.frenzyMeter = obj_frenzyMeter:create()
		data.frenzyMeter.parent = actor
	end
	if Global._current_frame % 6 == 0 then
		frenzyParticle:create(actor.x + (width * (0.5 - math.random())), actor.bbox_bottom - 16 * math.random(), 2, Particle.SYSTEM.above)
	end
	if bufftime <= 1 then
		data.frenzyCureFailure = true
	end
	if data.frenzyCureProgress >= 100 then
		data.frenzyCureFailure = false
		actor:buff_remove(frenzyVirusIncubate)
	end
end)

frenzyVirusIncubate:onHitProc(function(actor, victim, stack, hit_info)
	local data = actor:get_data()
	local baseDamage = actor.damage_base + (actor.damage_level * (actor.level - 1))
	data.frenzyCureProgress = data.frenzyCureProgress + (hit_info.damage * 2.8) / baseDamage
	--log.info(data.frenzyCureProgress)
end)

frenzyVirusIncubate:onRemove(function(actor, stack)
	local data = actor:get_data()
	if data.frenzyCureFailure == true then
		actor:buff_apply(frenzyVirusDisease, 3600)
	else
		actor:buff_apply(frenzyVirusCure, 1800)
	end
	if data.frenzyMeter:exists() then data.frenzyMeter:destroy() end
end)

frenzyVirusDisease:clear_callbacks()
frenzyVirusDisease:onPostStatRecalc(function(actor, stack)
	actor.hp_regen = 0
end)

frenzyVirusCure:clear_callbacks()
frenzyVirusCure:onStatRecalc(function(actor, stack)
	actor.critical_chance = actor.critical_chance + 15
end)

obj_frenzyMeter:clear_callbacks()
obj_frenzyMeter:onCreate(function(instance)
	instance.parent = -4
	instance.persistent = true
end)

obj_frenzyMeter:onStep(function(instance)
	if not GM.actor_is_alive(instance.parent) then
		instance:destroy()
	end
end)

obj_frenzyMeter:onDraw(function(instance)
	local actor = instance.parent
	local data = actor:get_data()
	local bufftime = GM.get_buff_time(actor, frenzyVirusIncubate)

	if not Instance.exists(actor) then return end
	if not GM.bool(actor.visible) then return end

	local x, y = math.floor(actor.ghost_x+0.5), math.floor(actor.ghost_y+0.5)

	local x = x + 1
	local y = y - 22

	local meter_left		= x - 23
	local meter_right		= x + 23
	local meter_width		= meter_right - meter_left
	local meter_top		= y - 2
	local meter_bottom	= y + 2

	local fraction = (1800 - bufftime) / 1800 or 0

	gm.draw_set_color(Color(0x161010))
	gm.draw_rectangle(meter_left, meter_top, meter_left + meter_width, meter_bottom, false)
	gm.draw_set_color(Color(0x8773e9))
	gm.draw_rectangle(meter_left, meter_top, meter_left + meter_width * fraction, meter_bottom, false)
	gm.draw_sprite(spr_frenzymeter, 0, x, y)
end)

local blacklist = {
	["magmaWorm"] = true,
	["spider"] = true,
}

for i, card in ipairs(Monster_Card.find_all()) do
	if not blacklist[card.identifier] then
		local elite_list = List.wrap(card.elite_list)
		if not elite_list:contains(eliteDracofrenzy) then
			elite_list:add(eliteDracofrenzy)
		end
	end
end