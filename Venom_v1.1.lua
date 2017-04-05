--Author: reloadz0r
local venomHelper= {}
 
venomHelper.optionEnable = Menu.AddOption({ "Hero Specific",".Venomancer"}, "Enable", "Venom Poison Nova")
venomHelper.optionKey = Menu.AddKeyOption({ "Hero Specific",".Venomancer"}, "Key",Enum.ButtonCode.KEY_P)
 
venomHelper.ultiRadius = {venonamcer_poison_nova = 830}
venomHelper.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
venomHelper.cache = {}
 
venomHelper.castQueue ={}
venomHelper.nextTick = 0
 
 
function venomHelper.OnUpdate()
    if not Menu.IsEnabled(venomHelper.optionEnable) then return true end
    local myHero = Heroes.GetLocal()
 
    if os.clock() < venomHelper.nextTick then return end
    venomHelper.processCastQueue(myHero)
    if #venomHelper.castQueue ~= 0 then return end
 
    if not Menu.IsKeyDown(venomHelper.optionKey) then return end
    if myHero == nill then return end
    local ultimate = NPC.GetAbilityByIndex(myHero, 3)
    if ultimate == nill or not Ability.IsReady(ultimate) then return end
 
    local maxCount,finalPos = venomHelper.findBestPostiont(myHero)
 
    if finalPos == nill or maxCount < 3 then return end
    --venomHelper.renderHelper(finalPos, "CT")
    --venomHelper.renderHelper(ccs, "CC")
    --venomHelper.renderHelper(mid, "MD")
    if not venomHelper.useItem(myHero, finalPos) then return end
    venomHelper.castUltimate(myHero, finalPos)
end
 
 
function venomHelper.processCastQueue(myHero)
    for i = 1, #venomHelper.castQueue do
        local element = venomHelper.castQueue[1]
        table.remove(venomHelper.castQueue, 1)
        local ability = element[2]
        local position = element[3]
        local onlyUseIfChanneling = element[4]
        if type(ability) == "string" then
            ability = NPC.GetItem(myHero, ability, true)
        end
        local myMana = NPC.GetMana(myHero)
        if ability and Ability.IsCastable(ability,myMana) and Ability.IsReady(ability) then
            if onlyUseIfChanneling and not NPC.IsChannellingAbility(myHero) then return end
            if position == null then
                Ability.CastNoTarget(ability)
            else
                Ability.CastPosition(ability, position)
            end
            local totalLatency = (NetChannel.GetAvgLatency(Enum.Flow.FLOW_INCOMING) + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING)) * 2
            venomHelper.nextTick = os.clock() + element[1] + totalLatency
            --Log.Write(venomHelper.nextTick)
            return
        end
    end
end
 
function venomHelper.findBestPostiont(myHero)
    local enemies = NPC.GetHeroesInRadius(myHero, 1500, Enum.TeamType.TEAM_ENEMY)
    local count = 0;
    local point = {}
    for i, enemy in ipairs(enemies) do
        count = count + 1;
        point[i] = NPC.GetAbsOrigin(enemy)
        --Log.Write(NPC.GetUnitName(enemy)..":  "..point[i]:GetX()..","..point[i]:GetY())
    end
    if count<3 then return end
 
    local maxCount = 0;
    local finalPos = nill
    for i = 1, count do
        for j = i+1, count do
            for k = j+1, count do
                --Log.Write(point[i]:GetX().."  "..i)
                --Log.Write(point[j]:GetX().."  "..j)
                --Log.Write(point[k]:GetX().."  "..k)
                venomHelper.processHeroes(myHero,point[i],point[j],point[k])
                local tempPos = venomHelper.cache["pos"]
                local tempCount = venomHelper.cache["count"]
                if tempCount> maxCount then
                    maxCount = tempCount
                    finalPos = tempPos
                end
            end
        end
    end
    return maxCount, finalPos
end
 
function venomHelper.useItem(myHero, finalPos)
    local myMana = NPC.GetMana(myHero)
    local dagger = NPC.GetItem(myHero, "item_blink", true)
    if dagger == nill or Ability.GetCooldownTimeLeft(dagger)>0 then
        return false
    end
 
    local bkb = NPC.GetItem(myHero, "item_black_king_bar", true)
    if bkb ~= nill then
        table.insert(venomHelper.castQueue,{0, bkb,})
    end
    local veil = NPC.GetItem(myHero, "item_veil_of_discord", true)
    if veil ~= nill and Ability.IsCastable(veil, myMana)then
        table.insert(venomHelper.castQueue,{0, veil, finalPos})
    end
    local shivas = NPC.GetItem(myHero, "item_shivas_guard", true)
    if shivas ~= nill and Ability.IsCastable(shivas, myMana)then
        table.insert(venomHelper.castQueue,{0, shivas})
    end
    local ultimate = NPC.GetAbilityByIndex(myHero, 3)
    if dagger ~= nill and ultimate~= nill and Ability.IsCastable(ultimate, myMana) and Ability.IsReady(dagger) and Ability.IsReady(ultimate) then
        --Log.Write("venomHelper ready")
        if NPC.IsPositionInRange(myHero, finalPos, 1200, 0) then
            table.insert(venomHelper.castQueue,{0, dagger, finalPos})
        else
            local dir = finalPos - NPC.GetAbsOrigin(myHero)
            dir:SetZ(0)
            dir:Normalize()
            dir:Scale(1199)
            local destination = NPC.GetAbsOrigin(myHero) + dir
 
            table.insert(venomHelper.castQueue,{0, dagger, destination})
        end
    end
    return true
 
end
 
function venomHelper.processHeroes(myHero, hero1Pos, hero2Pos, hero3Pos)
 
    -- get circumcenter of the 3 points
    local centroid = venomHelper.centroid(hero1Pos, hero2Pos, hero3Pos)
    local ccs = venomHelper.circumCenter(hero1Pos, hero2Pos, hero3Pos)
    local mid = venomHelper.furthestMidPoint(hero1Pos, hero2Pos, hero3Pos)
 
    local centroidHeroCount = venomHelper.validateCenter(centroid,myHero)
    local ccsHeroCount = venomHelper.validateCenter(ccs,myHero)
    local midCount = venomHelper.validateCenter(mid,myHero)
 
    --Log.Write(centroidHeroCount)
    --Log.Write(ccsHeroCount)
    --Log.Write(midCount)
 
 
    if centroidHeroCount < 3 and ccsHeroCount < 3 and midCount < 3 then
       --Log.Write(centroidHeroCount)
        venomHelper.cache["pos"] = nill
        venomHelper.cache["count"] = 0
        --Logs.Write(result["count"])
        return r
    end
    if centroidHeroCount >= ccsHeroCount and centroidHeroCount >= midCount then
        --Log.Write(centroidHeroCount)
        venomHelper.cache["pos"] = centroid
        --Logs.Write(centroidHeroCount)
        venomHelper.cache["count"] = centroidHeroCount
        return
    end
    if ccsHeroCount >= centroidHeroCount and ccsHeroCount >= midCount then
        --Log.Write(centroidHeroCount)
        venomHelper.cache["pos"] = ccs
        venomHelper.cache["count"] = ccsHeroCount
        --Logs.Write(result["count"])
        return
    end
    venomHelper.cache["pos"] = mid
    venomHelper.cache["count"] = midCount
    return result
    --venomHelper.castUltimate(myHero, ccs)
end
 
function venomHelper.furthestMidPoint(a, b, c)
    local distanceAB = a:Distance(b)
    local distanceAC = a:Distance(c)
    local distanceBC = b:Distance(c)
 
    distanceAB = distanceAB:Length()
    distanceAC = distanceAC:Length()
    distanceBC = distanceBC:Length()
 
    if distanceAB >= distanceAC and distanceAB>= distanceBC then
        local result = a + b
        result:SetX(result:GetX()/2)
        result:SetY(result:GetY()/2)  
        result:SetZ(0)
        return result
    end
 
    if distanceAC >= distanceAB and distanceAC>= distanceBC then
        local result = a + c
        result:SetX(result:GetX()/2)
        result:SetY(result:GetY()/2)  
        result:SetZ(0)
        return result
    end
 
    local result = b + c
    result:SetX(result:GetX()/2)
    result:SetY(result:GetY()/2)  
    result:SetZ(0)
    return result
end
 
function venomHelper.circumCenter(a, b, c)
    a:SetZ(0)
    b:SetZ(0)
    c:SetZ(0)
   
    local xa = a:GetX()
    local ya = a:GetY()
    local xb = b:GetX()
    local yb = b:GetY()
    local xc = c:GetX()
    local yc = c:GetY()
 
    local delta = 2*(xa-xb)*(yc-yb) - 2*(ya-yb)*(xc-xb)
    local deltaX = (yc-yb)*(xa*xa + ya*ya - xb*xb - yb*yb) - (ya-yb)*(xc*xc + yc*yc - xb*xb - yb*yb)
    local deltaY = (xa-xb)*(xc*xc + yc*yc - xb*xb - yb*yb) - (xc-xb)*(xa*xa + ya*ya - xb*xb - yb*yb)
 
    local resultX = deltaX/delta
    local resultY = deltaY/delta
    return Vector(resultX, resultY, 0)
end
 
function venomHelper.castUltimate(myHero, finalpos)
    local myMana = NPC.GetMana(myHero)
    local ulti = NPC.GetAbilityByIndex(myHero, 3)
 
    if ulti ~= nil and Ability.IsCastable(ulti, myMana) then
        local name =Ability.GetName(ulti)
        --Log.Write(Ability.GetName(ulti))
        if name == "venomancer_poison_nova" then
            table.insert(venomHelper.castQueue,{0, ulti})
        end
    end
 
    myMana = NPC.GetMana(myHero)
    local refresher = NPC.GetItem(myHero, "item_refresher")
    if refresher == nill then return end
 
    if myMana >=  Ability.GetManaCost(ulti) + Ability.GetManaCost(refresher) then
        table.insert(venomHelper.castQueue,{0.1, refresher, nill, true})
        return
    end  
end
 
function venomHelper.centroid(a, b, c )
    local result = a + b + c
    result:SetX(result:GetX()/3)
    result:SetY(result:GetY()/3)
    result:SetZ(0)
    return result
end
 
function venomHelper.renderHelper(pos, text)
    local x, y, visible = Renderer.WorldToScreen(pos)
    if visible then
        Renderer.SetDrawColor(255, 255, 0, 255)
        Renderer.DrawTextCentered(venomHelper.font, x, y, text, 1)
    end
end
 
function venomHelper.validateCenter(center, myHero)
    local numOfEnemyInRadius = 0
    local myTeam = Entity.GetTeamNum( myHero )
 
    for i = 1, Heroes.Count() do
        local hero = Heroes.Get(i)
        if not NPC.IsIllusion(hero) then
            local sameTeam = Entity.GetTeamNum(hero) == myTeam
            if not sameTeam then
                if NPC.IsPositionInRange(hero, center, 420, 0) then
                    numOfEnemyInRadius = numOfEnemyInRadius + 1
                end
            end
        end
    end
   
    return numOfEnemyInRadius
end
 
return venomHelper
