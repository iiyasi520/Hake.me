--Author: reloadz0r v_2.0
local Lion = {}

Lion.optionEnable = Menu.AddOption({ "Hero Specific", ".Lion"}, "Enabled", "")
Lion.optionHex = Menu.AddOption({ "Hero Specific", ".Lion"}, "Auto Hex", "")
Lion.optionFoD= Menu.AddOption({ "Hero Specific", ".Lion"}, "Auto Finger of Death", "")
Lion.optionStun = Menu.AddOption({ "Hero Specific", ".Lion"}, "Auto Earth Spike", "")
Lion.optionVeil = Menu.AddOption({ "Hero Specific", ".Lion"}, "Auto Veil of Discord", "")
Lion.optionEblade = Menu.AddOption({ "Hero Specific", ".Lion"}, "Auto Ethereal Blade", "")
Lion.optionDagon = Menu.AddOption({ "Hero Specific", ".Lion"}, "Auto Dagon", "")
Lion.optionBlink = Menu.AddOption({ "Hero Specific", ".Lion"}, "Auto Blink", "")
Lion.optionKey = Menu.AddKeyOption({ "Hero Specific", ".Lion"}, "Key", Enum.ButtonCode.KEY_F)

Lion.font = Renderer.LoadFont("Tahoma", 20, Enum.FontWeight.EXTRABOLD)

-- More options to be added later when suggested

function Lion.OnUpdate()
	if not Menu.IsEnabled(Lion.optionEnable) then return end
		if Menu.IsKeyDown(Lion.optionKey) then
			Lion.Combo()
	end
end

function Lion.Combo()

	local myHero = Heroes.GetLocal()

	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_lion" then return end

	local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)

	local heroPos = Entity.GetAbsOrigin(hero)
	local hex = NPC.GetAbilityByIndex(myHero, 1)
	local finger = NPC.GetAbilityByIndex(myHero, 3)
	local stun = NPC.GetAbilityByIndex(myHero, 0)
	local veil = NPC.GetItem(myHero, "item_veil_of_discord", true)
	local eblade = NPC.GetItem(myHero, "item_ethereal_blade", true)
	local blink = NPC.GetItem(myHero, "item_blink", true) 

	local myMana = NPC.GetMana(myHero)
	local mousePos = Input.GetWorldCursorPos()

	--Blink
	if blink and Ability.IsCastable(blink, myMana) and hero ~= nil and not NPC.IsPositionInRange(myHero, NPC.GetAbsOrigin(hero),600,0) then Ability.CastPosition(blink,mousePos)  end
	
	--Hex
	if hex and Ability.IsCastable(hex, myMana) and Menu.IsEnabled(Lion.optionHex) and NPC.IsEntityInRange(hero, myHero, Ability.GetCastRange(hex)) and Menu.IsKeyDown(Lion.optionKey) then Ability.CastTarget(hex, hero) return end
	
	--Veil of Discord
	if veil and Ability.IsCastable(veil, myMana) and Menu.IsEnabled(Lion.optionVeil) and NPC.IsEntityInRange(hero, myHero, Ability.GetCastRange(veil)) and Menu.IsKeyDown(Lion.optionKey) then Ability.CastPosition(veil, NPC.GetAbsOrigin(hero)) return end

	--Ethereal Blade
	if eblade and Ability.IsCastable(eblade, myMana) and Menu.IsEnabled(Lion.optionEblade) and not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and hero and NPC.IsEntityInRange(hero, myHero, Ability.GetCastRange(eblade)) and Menu.IsKeyDown(Lion.optionKey) then Ability.CastTarget(eblade, hero) return end
	
	--Earth Spike
	if Ability.IsCastable(stun, myMana) and Menu.IsEnabled(Lion.optionStun) and not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and hero and NPC.IsEntityInRange(hero, myHero, Ability.GetCastRange(stun)) and Menu.IsKeyDown(Lion.optionKey) then Ability.CastTarget(stun, hero) return end

	--Dagon
	for i = 0, 5 do
        local dagon = NPC.GetItem(myHero, "item_dagon_" .. i, true)
		if i == 0 then dagon = NPC.GetItem(myHero, "item_dagon", true) end
	if dagon and Ability.IsCastable(dagon, myMana) and Menu.IsEnabled(Lion.optionDagon) and not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and hero and NPC.IsEntityInRange(hero, myHero, Ability.GetCastRange(dagon)) and Menu.IsKeyDown(Lion.optionKey) then Ability.CastTarget(dagon, hero) return end
	end
	
	--Finger of Death
	if Ability.IsCastable(finger, myMana) and Menu.IsEnabled(Lion.optionFoD) and not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and hero and NPC.IsEntityInRange(hero, myHero, Ability.GetCastRange(finger)) and Menu.IsKeyDown(Lion.optionKey) then Ability.CastTarget(finger, hero) return end
	
end

return Lion
