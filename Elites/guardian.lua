local spr_palette = load_sprite("ElitePaletteGuardian", "Elites/sElitePaletteGuardian.png")
local spr_icon = load_sprite("EliteIconGuardian", "Elites/sEliteIconGuardian.png", 1, 14, 9)

local eliteGuardian = Elite.new(NAMESPACE, "guardian")
eliteGuardian.healthbar_icon = spr_icon
eliteGuardian.palette = spr_palette
eliteGuardian.blend_col = 12632256.0
GM.elite_generate_palettes()

local itemEliteOrbGuardian = Item.new(NAMESPACE, "eliteOrbGuardian", true)
itemEliteOrbGuardian.is_hidden = true

eliteGuardian:clear_callbacks()
eliteGuardian:onApply(function(actor)
	actor:item_give(itemEliteOrbGuardian)
end)

itemEliteOrbGuardian:clear_callbacks()
itemEliteOrbGuardian:onPostStep(function(actor, stack)
	if gm._mod_net_isClient() then return end
    local grounded = not actor.free
	local data = actor:get_data()
	if not data.guardian_timer then
		data.guardian_timer = 60
	end

	data.guardian_timer = data.guardian_timer - 1
	if data.guardian_timer < 0 then
		data.guardian_timer = 600 + math.random(240)

		if grounded and actor.hp > actor.maxhp / 10 then
			local crystal = Instance.wrap(GM.instance_create(actor.x, actor.bbox_bottom - 24, gm.constants.oArtiSnap))
			crystal.parent = actor
            crystal.maxhp = actor.maxhp / 2.8
			crystal.team = actor.team
            crystal.is_targettable = false
            crystal.is_character_enemy_targettable = false
            crystal:__actor_update_target_marker()
		end
	end
end)

Callback.add("preStep", "destroyGuardianCrystals", function()
    local crystals = Instance.find_all(Object.find("ror-artiSnap"))
    for _, found_crystal in ipairs(crystals) do
        if found_crystal.team ~= 1 then
            if found_crystal.parent.hp <= 0 then
                found_crystal:destroy()
            end
        end
    end
end)

local blacklist = {
	["magmaWorm"] = true,
}

for i, card in ipairs(Monster_Card.find_all()) do
	if not blacklist[card.identifier] then
		local elite_list = List.wrap(card.elite_list)
		if not elite_list:contains(eliteGuardian) then
			elite_list:add(eliteGuardian)
		end
	end
end