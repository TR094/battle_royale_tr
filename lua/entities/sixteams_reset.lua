AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Reset Scores"
ENT.Category = "Six Teams"

ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:Initialize()
	self:SetModel("models/props_phx/construct/glass/glass_plate4x4.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
	end
	self:PhysWake()
	self:DrawShadow(false)
end
