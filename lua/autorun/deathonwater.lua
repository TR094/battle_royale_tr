if engine.ActiveGamemode() == "battle_royale_trhomo" then
    concommand.Add("touchwatermeansdeath_true", function(activator, caller)
        if activator:IsAdmin() then
            timer.Create("ilikecreeperswateroff", 0.50, 0, function()
                for k, v in pairs(player.GetAll()) do
                    if v:WaterLevel() ~= 0 then
                        local dam = DamageInfo()
                        dam:SetDamage(99999999)
                        dam:SetAttacker(v)
                        dam:SetDamageType(DMG_GENERIC)
                        v:TakeDamageInfo(dam)
                    end
                end
            end)
        else
            print(tostring(activator), "is attempting to change the touchwatermeansdeath state without permission")
        end
    end)

    concommand.Add("touchwatermeansdeath_false", function(activator, caller)
        if activator:IsAdmin() then
            timer.Stop("ilikecreeperswateroff")
        else
            print(tostring(activator), "is attempting to change the touchwatermeansdeath state without permission")
        end
    end)

    concommand.Add("npctouchwatermeansdeath_true", function(activator, caller)
        if activator:IsAdmin() then
            timer.Create("ilikecreeperswateroffnpcbase", 0.50, 0, function()
                for k, v in pairs(ents.GetAll()) do
                    if v:WaterLevel() ~= 0 then
                        if v:IsNPC() == true or v:IsNextBot() == true then
                            if v:Health() >= 1 then
                                local dam = DamageInfo()
                                dam:SetDamage(99999999)
                                dam:SetAttacker(v)
                                dam:SetDamageType(DMG_GENERIC)
                                v:TakeDamageInfo(dam)
                            end
                        end
                    end
                end
            end)
        else
            print(tostring(activator), "is attempting to change the touchwatermeansdeath state without permission")
        end
    end)

    concommand.Add("npctouchwatermeansdeath_false", function(activator, caller)
        if activator:IsAdmin() then
            timer.Stop("ilikecreeperswateroffnpcbase")
        else
            print(tostring(activator), "is attempting to change the touchwatermeansdeath state without permission")
        end
    end)
end