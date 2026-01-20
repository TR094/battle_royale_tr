if engine.ActiveGamemode() == "battle_royale_trhomo" then
    local function DoDropWeapon( victim, inflictor, attacker )
        for i=1 , table.Count( victim:GetWeapons() ) do
            if IsValid( victim:GetWeapons()[i]) then
                local ent = ents.Create( victim:GetWeapons()[i]:GetClass() )
                ent:SetPos( victim:GetPos() )
                ent:SetParent( victim.Entity )
                ent:Spawn()
            end
        end
    end
    hook.Add("PlayerDeath","DROPWEAPON",DoDropWeapon)
end

