local spr_palette = load_sprite("ElitePaletteGuardian", "Elites/sElitePaletteGuardian.png")
local spr_icon = load_sprite("EliteIconGuardian", "Elites/")

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