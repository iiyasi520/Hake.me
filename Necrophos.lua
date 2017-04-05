--Author: reloadz0r v1.0
local Necrophos = {} 

Necrophos.optionEnable = Menu.AddOption({ "Hero Specific", ".Necrophos"}, "Enabled", "")
Necrophos.optionDeathP = Menu.AddOption({ "Hero Specific", ".Necrophos"}, "Auto Death Pulse", "")
Necrophos.optionulti = Menu.AddOption({ "Hero Specific", ".Necrophos"}, "Use Ulti on Combo", "Disable Hake.me Default for better results")
Necrophos.optionVeil = Menu.AddOption({ "Hero Specific", ".Necrophos"}, "Auto Veil of Discord", "")
Necrophos.optionEblade = Menu.AddOption({ "Hero Specific", ".Necrophos"}, "Auto Ethereal Blade", "")
Necrophos.optionDagon = Menu.AddOption({ "Hero Specific", ".Necrophos"}, "Auto Dagon", "")
Necrophos.optionKey = Menu.AddKeyOption({ "Hero Specific", ".Necrophos"}, "Key", Enum.ButtonCode.KEY_F)
--Menu Ghost Shroud Helper
Necrophos.optionAuto = Menu.AddOption({ "Hero Specific", ".Necrophos", "Ghost Shroud Helper"}, "Enabled", "While in Ghost Shroud it will use the items you choose if enemies are in range")
Necrophos.optionPipe = Menu.AddOption({ "Hero Specific", ".Necrophos", "Ghost Shroud Helper"}, "Auto Pipe", "")
Necrophos.optionBladeMail = Menu.AddOption({ "Hero Specific", ".Necrophos", "Ghost Shroud Helper"}, "Auto Blade Mail" , "")
Necrophos.optionLotus = Menu.AddOption({ "Hero Specific", ".Necrophos", "Ghost Shroud Helper"}, "Auto Lotus Orb", "")
Necrophos.option2 = Menu.AddOption({"Hero Specific", ".Necrophos", "Ghost Shroud Helper"}, "Radius", "If there's enemies in this radius it will use this items while in Ghost Shroud",  600, 1650, 100)

Necrophos.font = Renderer.LoadFont("Tahoma", 20, Enum.FontWeight.EXTRABOLD)
	


	

function Necrophos.OnUpdate()
	if not Menu.IsEnabled(Necrophos.optionEnable) then return end
		if Menu.IsKeyDown(Necrophos.optionKey) then
			Necrophos.Combo()
	end
	if Menu.IsEnabled(Necrophos.optionAuto) then
		Necrophos.Helper()
	end
	
return Necrophos
end

function Necrophos.Combo()

	local myHero = Heroes.GetLocal()

	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_necrolyte" then return end


	local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)

	local heroPos = Entity.GetAbsOrigin(hero)
	local DeathP = NPC.GetAbilityByIndex(myHero, 0)
	local GhostS = NPC.GetAbilityByIndex(myHero, 1)
	local ulti = NPC.GetAbilityByIndex(myHero, 3)
	local veil = NPC.GetItem(myHero, "item_veil_of_discord", true)
	local eblade = NPC.GetItem(myHero, "item_ethereal_blade", true)
	local blink = NPC.GetItem(myHero, "item_blink", true)

	

	local myMana = NPC.GetMana(myHero)
	local mousePos = Input.GetWorldCursorPos()
	
    --Blink
	if blink and Ability.IsCastable(blink, myMana) and hero ~= nil and not NPC.IsPositionInRange(myHero, NPC.GetAbsOrigin(hero), 600,0) then Ability.CastPosition(blink,mousePos)  end
	
	--DeathPulse
	if DeathP and Ability.IsCastable(DeathP, myMana) and Menu.IsEnabled(Necrophos.optionDeathP) and NPC.IsPositionInRange(myHero,NPC.GetAbsOrigin(hero), 0 , 475) and Menu.IsKeyDown(Necrophos.optionKey) then Ability.CastNoTarget(DeathP, 0) return end
	
	--Veil of Discord
	if veil and Ability.IsCastable(veil, myMana) and Menu.IsEnabled(Necrophos.optionVeil) and NPC.IsEntityInRange(hero, myHero, Ability.GetCastRange(veil)) and Menu.IsKeyDown(Necrophos.optionKey) then Ability.CastPosition(veil, NPC.GetAbsOrigin(hero)) return end

	--Ethereal Blade
	if eblade and Ability.IsCastable(eblade, myMana) and Menu.IsEnabled(Necrophos.optionEblade) and not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and hero and NPC.IsEntityInRange(hero, myHero, Ability.GetCastRange(eblade)) and Menu.IsKeyDown(Necrophos.optionKey) then Ability.CastTarget(eblade, hero) return end
		
	--ulti
	if Ability.IsCastable(ulti, myMana) and Menu.IsEnabled(Necrophos.optionulti) and not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and hero and NPC.IsEntityInRange(hero, myHero, Ability.GetCastRange(ulti)) and Menu.IsKeyDown(Necrophos.optionKey) then Ability.CastTarget(ulti, hero) return end
	
	--Dagon
	for i = 0, 5 do
        local dagon = NPC.GetItem(myHero, "item_dagon_" .. i, true)
		if i == 0 then dagon = NPC.GetItem(myHero, "item_dagon", true) end
	if dagon and Ability.IsCastable(dagon, myMana) and Menu.IsEnabled(Necrophos.optionDagon) and not NPC.HasState(hero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and hero and NPC.IsEntityInRange(hero, myHero, Ability.GetCastRange(dagon)) and Menu.IsKeyDown(Necrophos.optionKey) then Ability.CastTarget(dagon, hero) return end
	end
	
end

function Necrophos.Helper()
---- Ghost Shroud Helper
	local myChamp = Heroes.GetLocal()
	if NPC.GetUnitName(myChamp) ~= "npc_dota_hero_necrolyte" then return end
	
	local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myChamp), Enum.TeamType.TEAM_ENEMY)
	local myMana2 = NPC.GetMana(myChamp)
	local lotus = NPC.GetItem(myChamp,"item_lotus_orb", true)
	local bm = NPC.GetItem(myChamp, "item_blade_mail", true)
	local pipe = NPC.GetItem(myChamp, "item_pipe", true)
	
	if pipe and NPC.HasModifier(myChamp, "modifier_necrolyte_sadist_active") and NPC.IsPositionInRange(myChamp, NPC.GetAbsOrigin(enemy ),0,Menu.GetValue(Necrophos.option2)) and Ability.IsCastable(pipe,myMana2) then Ability.CastNoTarget(pipe) return end
	if lotus and NPC.HasModifier(myChamp, "modifier_necrolyte_sadist_active") and NPC.IsPositionInRange(myChamp, NPC.GetAbsOrigin(enemy ),0,Menu.GetValue(Necrophos.option2)) and Ability.IsCastable(lotus,myMana2) then Ability.CastTarget(lotus,myChamp, true) return end
	if bm and NPC.HasModifier(myChamp, "modifier_necrolyte_sadist_active")and NPC.IsPositionInRange(myChamp, NPC.GetAbsOrigin(enemy ),0,Menu.GetValue(Necrophos.option2)) and Ability.IsCastable(bm,myMana2) then Ability.CastNoTarget(bm) return end
end
return Necrophos
