AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Team Spawn"
ENT.Category = "Six Teams"

ENT.Spawnable = true
ENT.PhysgunDisabled = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", "Team")
end

function ENT:Initialize()
	self:SetModel("models/props_phx/ball.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetSolidFlags(FSOLID_TRIGGER + FSOLID_NOT_SOLID)
	self:DrawShadow(false)
end

if CLIENT then
	function ENT:Draw()
		local t = self:GetTeam()
		if t < 1 or not SIXTEAMS_FLAGMATS[t] then return end
		render.ModelMaterialOverride(SIXTEAMS_FLAGMATS[t])
		local ang = self:GetAngles()
		--ang.p = 90
		render.Model({
			model = "models/xqm/button3.mdl",
			pos = self:GetPos(),
			angle = ang,
		})
		render.ModelMaterialOverride(nil)
	end
end
