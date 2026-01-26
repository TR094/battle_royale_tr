AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Team Flag"
ENT.Category = "Six Teams"

ENT.Spawnable = true
ENT.PhysgunDisabled = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", "Team")
	self:NetworkVar("Entity", "Carrier")
	self:NetworkVar("Vector", "Home")
end

local renderBounds = {Vector(-999999, -999999, -999999), Vector(999999, 999999, 999999)}

function ENT:Initialize()
	self:SetModel("models/props_phx/ball.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetSolidFlags(FSOLID_TRIGGER + FSOLID_NOT_SOLID)
	self:DrawShadow(false)
	if CLIENT then
		self:SetRenderBounds(renderBounds[1], renderBounds[2])
	end
	self:SetHome(self:GetPos())
	self:SetCarrier(NULL)
	timer.Simple(0, function() if IsValid(self) then self:SetPos(self:GetHome()) end end)
end

function ENT:GetIconPos()
	local pos = self:GetPos()
	local ply = self:GetCarrier()
	if IsValid(ply) then
		pos:Set(ply:GetPos())
	end
	pos[3] = pos[3] + 6
	return pos
end

if SERVER then
	/*function ENT:StartTouch(ply)
		if IsValid(ply) and ply:Alive() and IsSixTeamsPlayer(ply) then
			local plyTeam = GetPlayerSixTeam(ply)
			if plyTeam == self:GetTeam() then
				if self:GetPos() == self:GetHome() then
					local flag = GetFlagCarriedBy(ply)
					if IsValid(flag) then
						SetGlobalInt("SixTeams.Score" .. plyTeam, GetGlobalInt("SixTeams.Score" .. plyTeam) + 1)
						net.Start("sixteams_flag")
						net.WriteEntity(ply)
						net.WriteInt(SIXTEAMS_FLAG_CAPTURE, 4)
						net.WriteInt(flag:GetTeam(), 5)
						net.Broadcast()
						flag:Return(NULL)
					end
				else
					self:Return(ply)
				end
			else
				if IsValid(GetFlagCarriedBy(ply)) then return end
				self:Steal(ply)
			end
		end
	end

	function ENT:Return(ply)
		self:SetPos(self:GetHome())
		self:SetCarrier(NULL)
		if IsValid(ply) then
			net.Start("sixteams_flag")
			net.WriteEntity(ply)
			net.WriteInt(SIXTEAMS_FLAG_RETURN, 4)
			net.WriteInt(self:GetTeam(), 5)
			net.Broadcast()
		end
	end

	function ENT:Steal(ply)
		if IsValid(self:GetCarrier()) then return end
		self:SetCarrier(ply)
		net.Start("sixteams_flag")
		net.WriteEntity(ply)
		net.WriteInt(SIXTEAMS_FLAG_STEAL, 4)
		net.WriteInt(self:GetTeam(), 5)
		net.Broadcast()
	end*/

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end
else
	local poleOffset = Vector(0, 0, -16)
	local flagOffset = Vector(0, 12, 79)
	local poleAng = Angle(0, 0, 0)
	local flagAng = Angle(90, 180, 0)
	local flagCarryOffset = Vector(0, 0, 24)

	local missingMat = CreateMaterial("SixTeams_FlagMissing3", "UnlitGeneric", {
		["$basetexture"] = "color/white",
		["$color2"] = "{60 60 60}",
		["$model"] = 1,
	})

	function ENT:Draw()
		local pos = self:GetPos()
		local ang = self:GetAngles()
		local ply = self:GetCarrier()
		local home = self:GetHome()
		if IsValid(ply) or pos ~= home then
			render.ModelMaterialOverride(missingMat)
			render.Model({
				model = "models/props_c17/signpole001.mdl",
				pos = home + poleOffset,
				angle = poleAng,
			})
			render.Model({
				model = "models/xqm/wingtip1.mdl",
				pos = home + flagOffset,
				angle = flagAng,
			})
			render.ModelMaterialOverride(nil)
		end
		if IsValid(ply) then
			local plyAng = Angle(0, ply:EyeAngles().y, 0)
			pos:Set(ply:GetPos() - plyAng:Forward() * 10 + flagCarryOffset)
		end
		render.Model({
			model = "models/props_c17/signpole001.mdl",
			pos = pos + poleOffset,
			angle = poleAng,
		})
		local t = self:GetTeam()
		if t < 1 or not SIXTEAMS_FLAGMATS[t] then return end
		render.ModelMaterialOverride(SIXTEAMS_FLAGMATS[t])
		render.Model({
			model = "models/xqm/wingtip1.mdl",
			pos = pos + flagOffset,
			angle = flagAng,
		})
		render.ModelMaterialOverride(nil)
	end
end
