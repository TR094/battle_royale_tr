AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Scoreboard"
ENT.Category = "Six Teams"

ENT.Spawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", "Team")
end

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

if CLIENT then
	surface.CreateFont("SixTeams.Score", {
		font = "Roboto Black",
		size = 220,
	})

	surface.CreateFont("SixTeams.ScoreLarge", {
		font = "Roboto Black",
		size = 300,
	})

	local function sortByScore(a, b) return a[2] > b[2] end

	function ENT:Draw()
		self:DrawModel()
		local pos = self:GetPos() + self:GetForward() * -115.5 + self:GetRight() * 20.5 + self:GetUp() * 3
		local ang = self:GetAngles()
		local showKills = math.sin(CurTime()) > 0
		ang:RotateAroundAxis(ang:Up(), 90)
		cam.Start3D2D(pos, ang, 0.1)
			-- back
			surface.SetDrawColor(60, 60, 60, 240)
			surface.DrawRect(0, 0, 1360, 1360)

			-- title
			surface.SetTextColor(255, 255, 255)
			surface.SetFont("SixTeams.ScoreLarge")
			local titleTxt = showKills and "Team Frags" or "Captures"
			surface.SetTextPos(680 - surface.GetTextSize(titleTxt) * 0.5, 12)
			surface.DrawText(titleTxt)

			-- gather scores
			surface.SetFont("SixTeams.Score")
			local teams = {}
			for i = 1, 6 do
				local score = GetGlobalInt("SixTeams." .. (showKills and "Frags" or "Score") .. i)
				if score > 0 then
					table.insert(teams, {i, score})
				end
			end

			-- display scores
			if #teams > 0 then
				table.sort(teams, sortByScore)
				for i, info in ipairs(teams) do
					local team = SIXTEAMS[info[1]]
					local y = 80 + 170 * i
					surface.SetTextColor(team.color)
					surface.SetTextPos(80, y)
					surface.DrawText(team.name)
					local num = string.Comma(info[2])
					surface.SetTextPos(1280 - surface.GetTextSize(num), y)
					surface.DrawText(num)
				end
			else
				surface.SetTextColor(180, 180, 180)
				local txt = showKills and "No frags" or "No captures"
				surface.SetTextPos(680 - surface.GetTextSize(txt) * 0.5, 260)
				surface.DrawText(txt)
			end
		cam.End3D2D()
	end
end
