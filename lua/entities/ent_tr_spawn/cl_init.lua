include("shared.lua")

function ENT:Initialize()
end

CreateClientConVar("tr_spawners_draw", "0", true, false)
function ENT:Draw()
	if GetConVarNumber("tr_spawners_draw") == 1 and LocalPlayer():IsAdmin() then
		self:DrawModel()
	end
end

hook.Add("HUDPaint", "Spawner_ESP", function()
    if GetConVarNumber("tr_spawners_draw") == 1 and LocalPlayer():IsAdmin() then
		for k,v in pairs(ents.FindByClass("ent_tr_spawn")) do
			pos = v:GetPos() + Vector(0,0,20)
			pos = pos:ToScreen()
			draw.SimpleText("Spawnpoint", "Default", pos.x-(6/2), pos.y-(6/2), Color(255,255,150,100), TEXT_ALIGN_CENTER)
		end
    end
end)