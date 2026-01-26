
list.Set("ContentCategoryIcons", "Six Teams", "sixteams/hud/flag1.png")

sound.Add({
	name = "SixTeams.Whoops",
	channel = CHAN_VOICE,
	volume = 1,
	level = 70,
	pitch = 100,
	sound = "vo/npc/male01/whoops01.wav"
})

sound.Add({
	name = "SixTeams.WhoopsF",
	channel = CHAN_VOICE,
	volume = 1,
	level = 70,
	pitch = 100,
	sound = "vo/npc/female01/whoops01.wav"
})

SixTeamsBaseID = 419

function GetPlayerSixTeam(ply) return 
	ply:Team() - SixTeamsBaseID 

end

function IsSixTeamsTeam(i) return 
	i > SixTeamsBaseID and i - SixTeamsBaseID < 7 
end

function IsSixTeamsPlayer(ply) return 
	IsSixTeamsTeam(ply:Team()) 
end

function GetFlagCarriedBy(ply)
	for _, flag in ipairs(ents.FindByClass("sixteams_flag")) do
		if flag:GetCarrier() == ply then
			return flag
		end
	end
	return NULL
end

SIXTEAMS = {
	{
		name = "RED",
		color = Color(220, 20, 60),
		model = "models/player/leet.mdl",
	}, {
		name = "GREEN",
		color = Color(50, 205, 50),
		model = "models/player/phoenix.mdl",
	}, {
		name = "ORANGE",
		color = Color(255, 140, 0),
		model = "models/player/Group01/male_04.mdl",
	}, {
		name = "BLUE",
		color = Color(30, 144, 255),
		model = "models/player/odessa.mdl",
	}, {
		name = "GOLD",
		color = Color(255, 215, 0),
		model = "models/player/gman_high.mdl",
	}, {
		name = "PINK",
		color = Color(255, 0, 255),
		model = "models/player/alyx.mdl",
	}, {
		name = "NO TEAM",
		color = Color(45, 45, 45),
	}
}

SIXTEAMS_FLAG_STEAL = 1
SIXTEAMS_FLAG_RETURN = 2
SIXTEAMS_FLAG_CAPTURE = 3
SIXTEAMS_FLAG_DROP = 4

SIXTEAMS_FLAGVERB = {"stole", "returned", "captured", "dropped"}

SIXTEAMS_FLAGMATS = {}
SIXTEAMS_HUDFLAGS = {}

for i = 1, 6 do
	local clr = SIXTEAMS[i].color
	SIXTEAMS[i].colorVec = Vector(clr.r / 255, clr.g / 255, clr.b / 255)
	sound.Add({
		name = "SixTeams.SelectTeam" .. i,
		channel = CHAN_VOICE,
		volume = 1,
		level = 70,
		pitch = 100,
		sound = SIXTEAMS[i].selectSnd
	})
	util.PrecacheModel(SIXTEAMS[i].model)
	if CLIENT then
		SIXTEAMS_FLAGMATS[i] = CreateMaterial("SixTeams_Flag" .. i, "UnlitGeneric", {
			["$basetexture"] = "color/white",
			["$color2"] = "{" .. clr.r .. " " .. clr.g .. " " .. clr.b .. "}",
			["$model"] = 1,
		})
		SIXTEAMS_HUDFLAGS[i] = Material("sixteams/hud/flag" .. i .. ".png")
	end
end

hook.Add("CreateTeams", "SixTeams", function()
	for i = 1, 6 do
		team.SetUp(SixTeamsBaseID + i, SIXTEAMS[i].name, SIXTEAMS[i].color)
	end
end)

hook.Add("ShouldCollide", "SixTeams.NoPlayerCollision", function(ent1, ent2)
	if ent1:IsPlayer() and ent2:IsPlayer() then return false end
end)

if SERVER then
	resource.AddFile("materials/sixteams/icon64.png")
	resource.AddFile("materials/sixteams/hud/flag1.png")
	resource.AddFile("materials/sixteams/hud/flag2.png")
	resource.AddFile("materials/sixteams/hud/flag3.png")
	resource.AddFile("materials/sixteams/hud/flag4.png")
	resource.AddFile("materials/sixteams/hud/flag5.png")
	resource.AddFile("materials/sixteams/hud/flag6.png")
	util.AddNetworkString("sixteams")
	util.AddNetworkString("sixteams_flag")

	function DropFlagIfCarrying(ply)
		local flag = GetFlagCarriedBy(ply)
		if IsValid(flag) then
			flag:SetPos(ply:GetPos())
			flag:DropToFloor()
			flag:SetCarrier(NULL)
			net.Start("sixteams_flag")
			net.WriteEntity(ply)
			net.WriteInt(SIXTEAMS_FLAG_DROP, 4)
			net.WriteInt(flag:GetTeam(), 5)
			net.Broadcast()
		end
	end

	concommand.Add("sixteams_resetscores", function(ply, cmd, args)
		if not ply:IsAdmin() then return end
		PrintMessage(HUD_PRINTTALK, ply:Nick() .. " reset team scores")
		for i = 1, 6 do
			SetGlobalInt("SixTeams.Score" .. i, 0)
			SetGlobalInt("SixTeams.Frags" .. i, 0)
		end
	end)

	local function setupPlayerModel(ply, i)
		ply:SetModel(SIXTEAMS[i].model)
		ply:SetPlayerColor(SIXTEAMS[i].colorVec)
		ply:SetupHands()
	end

	net.Receive("sixteams", function(len, ply)
		local i = net.ReadUInt(5)
		if i == 7 then
			ply:SetTeam(TEAM_UNASSIGNED)

			if ply:Alive() then
				-- reset model how sandbox does it
				ply:SetModel(player_manager.TranslatePlayerModel(ply:GetInfo("cl_playermodel")))
				ply:SetSkin(ply:GetInfoNum("cl_playerskin", 0))
				local bodygroups = ply:GetInfo("cl_playerbodygroups")
				if bodygroups == nil then bodygroups = "" end
				local groups = string.Explode(" ", bodygroups)
				for k = 0, ply:GetNumBodyGroups() - 1 do
					ply:SetBodygroup(k, tonumber(groups[k + 1]) or 0)
				end
				ply:SetPlayerColor(Vector(ply:GetInfo("cl_playercolor")))
			end
		else
			ply:SetTeam(SixTeamsBaseID + i)
			if ply:Alive() then
				setupPlayerModel(ply, i)
			end
		end

		if ply:Alive() then
			local epos = ply:GetShootPos()
			epos[3] = epos[3] + 50
			local ef = EffectData()
			ef:SetEntity(ply)
			ef:SetStart(epos)
			ef:SetOrigin(epos)
			ef:SetScale(1)
			util.Effect("entity_remove", ef, true, true)
		end

		-- let everybody know
		net.Start("sixteams")
		net.WriteEntity(ply)
		net.WriteUInt(i, 5)
		net.Broadcast()
	end)

	hook.Add("PlayerSpawn", "SixTeams", function(ply)
		local t = ply:Team()
		if IsSixTeamsTeam(t) then
			timer.Simple(0, function()
				if not IsValid(ply) or not ply:Alive() then return end
				setupPlayerModel(ply, t - SixTeamsBaseID)
			end)
		end
	end)

	hook.Add("PlayerShouldTakeDamage", "SixTeams", function(ply, atk)
		if IsValid(ply) and ply:IsPlayer() and IsValid(atk) and atk:IsPlayer() then
			local plyTeam, atkTeam = ply:Team(), atk:Team()
			if IsSixTeamsTeam(plyTeam) and IsSixTeamsTeam(atkTeam) then
				if plyTeam == atkTeam and ply ~= atk then
					atk:EmitSound(atkTeam - SixTeamsBaseID == 6 and "SixTeams.WhoopsF" or "SixTeams.Whoops")
					if not atk.LastFF then atk.LastFF = -99 end
					if CurTime() - atk.LastFF > 3 then
						PrintMessage(HUD_PRINTTALK, atk:Nick() .. " attacked a teammate")
						atk.LastFF = CurTime()
					end
					return false
				end
				return true
			else
				return cvars.Bool("sbox_playershurtplayers", true)
			end
		end
	end)

	local needTeam = {
		sixteams_flag = true,
		sixteams_spawn = true,
	}

	hook.Add("PlayerSpawnSENT", "SixTeams", function(ply, cls)
		if needTeam[cls] and not IsSixTeamsTeam(ply:Team()) then
			ply:ChatPrint("Join a team to spawn team entities!")
			return false
		end

		if cls == "sixteams_reset" then
			if ply:IsAdmin() then
				ply:SendLua("SixTeams_OpenResetPrompt()")
			end
			return false
		end
	end)

	hook.Add("PlayerSpawnedSENT", "SixTeams", function(ply, ent)
		if needTeam[ent:GetClass()] then
			ent:SetTeam(ply:Team() - SixTeamsBaseID)
			if ent:GetClass() == "sixteams_spawn" then
				ent:SetPos(ply:GetPos() + Vector(0, 0, 1))
				ent:SetAngles(Angle(0, ply:EyeAngles().y, 0))
			end
		end
	end)

--[[
function GM:IsSpawnpointSuitable( pl, spawnpointent, bMakeSuitable )

	local Pos = spawnpointent:GetPos()

	-- Note that we're searching the default hull size here for a player in the way of our spawning.
	-- This seems pretty rough, seeing as our player's hull could be different.. but it should do the job
	-- (HL2DM kills everything within a 128 unit radius)
	if ( pl:Team() == TEAM_SPECTATOR ) then return true end

	

	if ( bMakeSuitable ) then return true end
	if ( Blockers > 0 ) then return false end
	return true

end
]]

	local spawnpointmin = Vector( -16, -16, 0 )
	local spawnpointmax = Vector( 16, 16, 64 )

	hook.Add("PlayerSelectSpawn", "SixTeams", function(ply)
		local team = ply:Team()
		if IsSixTeamsTeam(team) then
			local spawns = {}
			for _, spawn in ipairs(ents.FindByClass("sixteams_spawn")) do
				if spawn:GetTeam() == team - SixTeamsBaseID then
					table.insert(spawns, spawn)
				end
			end
			team = team - SixTeamsBaseID
			if #spawns > 0 then
				local spawn = spawns[math.random(#spawns)]
				local pos = spawn:GetPos()
				for _, blocker in ipairs(ents.FindInBox(pos + spawnpointmin, pos + spawnpointmax)) do
					if IsValid(blocker) && blocker ~= ply && blocker:IsPlayer() and blocker:Alive() then
						blocker:Kill()
					end
				end
				return spawn
			end
		end
	end)

	hook.Add("PostPlayerDeath", "SixTeams.DropFlag", function(ply)
		DropFlagIfCarrying(ply)
	end)

	hook.Add("DoPlayerDeath", "SixTeams.AddFrag", function(ply, atk, dmg)
		if IsValid(ply) and IsValid(atk) and atk:IsPlayer() and IsSixTeamsPlayer(ply) and IsSixTeamsPlayer(atk) then
			local atkTeam = GetPlayerSixTeam(atk)
			if atkTeam == GetPlayerSixTeam(ply) then return end
			local glbl = "SixTeams.Frags" .. atkTeam
			SetGlobalInt(glbl, GetGlobalInt(glbl, 0) + 1)
		end
	end)
else
	local offWhite = Color(248, 248, 248)
	net.Receive("sixteams", function(len)
		local ply = net.ReadEntity()
		local i = net.ReadUInt(5)
		chat.AddText(SIXTEAMS[i].color, ply:Nick(), offWhite, " joined ", SIXTEAMS[i].color, SIXTEAMS[i].name)
	end)

	net.Receive("sixteams_flag", function(len)
		local ply = net.ReadEntity()
		local verb = net.ReadUInt(4)
		local i = net.ReadUInt(5)
		chat.AddText(SIXTEAMS[GetPlayerSixTeam(ply)].color, ply:Nick(), offWhite, " ", SIXTEAMS_FLAGVERB[verb], " ", SIXTEAMS[i].color, SIXTEAMS[i].name, offWhite, " flag")
	end)

	local btnClrHovered = Color(220, 220, 220)
	local btnClrPressed = Color(120, 120, 120)
	list.Set("DesktopWindows", "SixTeams", {
		title = "Six Teams",
		icon = "sixteams/icon64.png",
		width = 600,
		height = 400,
		onewindow = true,
		init = function(icon, teamlist)
			teamlist:SetTitle("Choose Team")
			teamlist:Center()
			local teamPanel = vgui.Create("DPanel", teamlist)
			teamPanel:Dock(FILL)
			teamPanel:InvalidateParent(true)
			function teamPanel:Paint(x, y, w, h) end
			local pw, ph = teamPanel:GetSize()
			local bw, bh = pw / 3, ph * 0.4
			for i = 1, 7 do
				local teamBtn = vgui.Create("DButton", teamPanel)
				local bx, by = (i - 1) % 3, math.floor((i - 1) / 3)
				teamBtn:SetPos(bx * bw, by * bh)
				if i == 7 then
					bx, by = 0, ph * 0.8
					bw, bh = pw, ph * 0.2
					teamBtn:SetPos(bx * bw, by)
				end
				teamBtn:SetSize(bw, bh)
				teamBtn:SetText("")
				function teamBtn:Paint(w, h)
					draw.RoundedBox(2, 0, 0, w, h, SIXTEAMS[i].color)
					local textClr = self:IsHovered() and color_white or btnClrHovered
					if self:IsDown() then
						textClr = btnClrPressed
					end
					draw.SimpleTextOutlined(SIXTEAMS[i].name, "CloseCaption_Bold", w * 0.5, h * 0.5, textClr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
				end
				teamBtn.DoClick = function()
					surface.PlaySound("weapons/357/357_spin1.wav")
					net.Start("sixteams")
					net.WriteUInt(i, 5)
					net.SendToServer()
				end
			end
		end
	})

	hook.Add("HUDPaint", "SixTeams", function()
		local ply = LocalPlayer()
		surface.SetDrawColor(255, 255, 255, 255)
		local flagW = ScrW() * 0.02
		for _, flag in ipairs(ents.FindByClass("sixteams_flag")) do
			local t = flag:GetTeam()
			if t > 0 then
				local pos = flag:GetIconPos():ToScreen()
				if pos.visible then
					surface.SetMaterial(SIXTEAMS_HUDFLAGS[t])
					surface.DrawTexturedRect(pos.x - flagW * 0.5, pos.y - flagW * 0.5, flagW, flagW)
				end
			end
		end
	end)

	function SixTeams_OpenResetPrompt()
		if IsValid(SixTeams_ResetPanel) then
			SixTeams_ResetPanel:Remove()
		end
		SixTeams_ResetPanel = Derma_Query(
			"Reset all team captures and frags to zero?",
			"Reset Scores",
			"Yes",
			function() LocalPlayer():ConCommand("sixteams_resetscores") end,
			"Cancel",
		function() end)
	end
end
