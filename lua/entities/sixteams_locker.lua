AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Teapot Base Entity"
ENT.Category = "Other"
ENT.Spawnable = false
ENT.Model = "models/weapons/w_bugbait.mdl"

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:PhysWake()
	end
else
	surface.CreateFont("TeapotEntity.Label", {
		font = "Arial",
		size = 40
	})

	ENT.LabelHeight = 12
	ENT.ChosenLabelColor = false
	local labelColor = Color(255, 255, 255)
	local labelOutline = Color(25, 25, 25)
	local labelColorContra = Color(207, 95, 81)
	function ENT:GetLabel() return self.PrintName end
	function ENT:Draw()
		self:DrawModel()

		local ply = LocalPlayer()
		local pos = self:GetPos()

		local dist = pos:DistToSqr(ply:EyePos())
		if dist < 90000 then
			local cls = self.ClassName
			if not self.ChosenLabelColor then
				self.ChosenLabelColor = (CONTRA_POCKET[cls] or CONTRA_OTHER[cls]) and labelColorContra:Copy() or labelColor:Copy()
			end
			local a = 255 - ((dist - 66000) * 0.010625)
			self.ChosenLabelColor.a = a
			labelOutline.a = a
			pos.z = pos.z + self.LabelHeight
			cam.Start3D2D(pos, Angle(0, ply:EyeAngles().y - 90, 90), 0.125)
				draw.SimpleTextOutlined(self:GetLabel(), "Trebuchet48", 0, -100, self.ChosenLabelColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, labelOutline)
			cam.End3D2D()
		end
	end
end
