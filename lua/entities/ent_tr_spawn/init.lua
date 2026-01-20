--Some of the loading stuff here is from maurits (old gmod wiki) (http://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/indexa7b4.html)
function tr_Spawners_Spawn()
if not file.Exists("tr_spawners/"..game.GetMap()..".txt","DATA") then print("[tr-SPAWNERS]: No spawner file is found for this map! Cannot spawn any spawners!") return end

for k,v in pairs(ents.FindByClass("ent_tr_spawn")) do
	v:Remove()
end

local textdata = nil
local lines = nil
local data = nil

textdata = file.Read("tr_spawners/"..game.GetMap()..".txt")

lines = string.Explode("\n", textdata)

for i, line in ipairs(lines) do

data = string.Explode(";", line)

if line == nil or line == "" then return end

local spawner = ents.Create("ent_tr_spawn")
spawner:SetPos(Vector(data[1],data[2],data[3]))
spawner:Spawn()

end

end
hook.Add("InitPostEntity","tr_Spawners_LoadMap",tr_Spawners_Spawn)

function tr_Spawners_Spawn_Ply(ply)
if ply and ply != nil and ply:IsValid() and ply:IsPlayer() then
	if not ply:IsSuperAdmin() then
		ply:PrintMessage(HUD_PRINTCONSOLE,"You have insufficient permissions to use this!")
		return
	end
	ply:SendLua("surface.PlaySound('hl1/fvox/blip.wav')")
	ply:PrintMessage(HUD_PRINTCONSOLE,"[tr-SPAWNERS]: Respawned all saved spawnpoints!")
	print("[tr-SPAWNERS]: "..ply:GetName().." respawned all saved spawnpoints!")
end
if not file.Exists("tr_spawners/"..game.GetMap()..".txt","DATA") then ply:PrintMessage(HUD_PRINTCONSOLE,"[tr-SPAWNERS]: No spawner file is found for this map! Cannot spawn any spawners!") print("[tr-SPAWNERS]: No spawner file is found for this map! Cannot spawn any spawners!") return end

for k,v in pairs(ents.FindByClass("ent_tr_spawn")) do
	v:Remove()
end

local textdata = nil
local lines = nil
local data = nil

textdata = file.Read("tr_spawners/"..game.GetMap()..".txt")

lines = string.Explode("\n", textdata)

for i, line in ipairs(lines) do

data = string.Explode(";", line)

if line == nil or line == "" then return end

local spawner = ents.Create("ent_tr_spawn")
spawner:SetPos(Vector(data[1],data[2],data[3]))
spawner:Spawn()

end

end
concommand.Add("tr_spawners_spawn",tr_Spawners_Spawn_Ply)

concommand.Add("tr_spawners_save",function(ply)
	if not ply:IsSuperAdmin() then PrintMessage(HUD_PRINTCONSOLE,"You have insufficient permissions to use this!") return end
	
	if not file.IsDir("tr_spawners","DATA") then
		file.CreateDir("tr_spawners","DATA")
	end
	
	if file.Exists("tr_spawners/"..game.GetMap()..".txt","DATA") then
		file.Delete("tr_spawners/"..game.GetMap()..".txt")
		ply:PrintMessage(HUD_PRINTCONSOLE,"[tr-SPAWNERS]: Deleted the map's spawner file")
		print("[tr-SPAWNERS]: Deleted the map's spawner file")
	end

	ply:PrintMessage(HUD_PRINTCONSOLE,"[tr-SPAWNERS]: Saving spawners!")
	print("[tr-SPAWNERS]: "..ply:GetName().." began saving spawners!")
	
	if #ents.FindByClass("ent_tr_spawn") < 1 then ply:PrintMessage(HUD_PRINTCONSOLE,"[tr-SPAWNERS]: Not a single bloody spawner was found! Aborting...") ply:SendLua("surface.PlaySound('hl1/fvox/fuzz.wav')") print("[tr-SPAWNERS]: Not a single bloody spawner was found! Aborting...") return end
	for k,v in pairs(ents.FindByClass("ent_tr_spawn")) do
		local SpawnerPos = string.Explode(" ", tostring(v:GetPos()))

		file.Append("tr_spawners/"..game.GetMap()..".txt",SpawnerPos[1]..";"..SpawnerPos[2]..";"..SpawnerPos[3].." \n")
		ply:PrintMessage(HUD_PRINTCONSOLE,"[tr-SPAWNERS]: Saved a spawner! ("..v:EntIndex()..")")
		print("[tr-SPAWNERS]: Saved a spawner! ("..v:EntIndex()..")")
	end
	ply:PrintMessage(HUD_PRINTCONSOLE,"[tr-SPAWNERS]: Save complete")
	print("[tr-SPAWNERS]: Save complete")
	ply:SendLua("surface.PlaySound('hl1/fvox/bell.wav')")
end)

--Probably some dumb parts here... Bah... Whatever
concommand.Add("tr_spawners_clear",function(ply)
	if not ply:IsSuperAdmin() then PrintMessage(HUD_PRINTCONSOLE,"You have insufficient permissions to use this!") return end
	
	if not file.IsDir("tr_spawners","DATA") then
		file.CreateDir("tr_spawners","DATA")
	end
	
	ply:PrintMessage(HUD_PRINTCONSOLE,"[tr-SPAWNERS]: Cleansing the map of spawners!")
	print("[tr-SPAWNERS]: "..ply:GetName().." cleansed the map's spawners")
	
	if file.Exists("tr_spawners/"..game.GetMap()..".txt","DATA") then
		file.Delete("tr_spawners/"..game.GetMap()..".txt")
		ply:PrintMessage(HUD_PRINTCONSOLE,"[tr-SPAWNERS]: Deleted the map's spawner file")
		print("[tr-SPAWNERS]: Deleted the map's spawner file")
	end
	
	for k,v in pairs(ents.FindByClass("ent_tr_spawn")) do
		ply:PrintMessage(HUD_PRINTCONSOLE,"[tr-SPAWNERS]: Removed a spawner ("..v:EntIndex()..")")
		print("[tr-SPAWNERS]: Removed a spawner ("..v:EntIndex()..")")
		v:Remove()
	end
	
	ply:PrintMessage(HUD_PRINTCONSOLE,"[tr-SPAWNERS]: All spawners are now gone and the map's spawner file has been deleted")
	print("[tr-SPAWNERS]: All spawners are now gone and the map's spawner file has been deleted")
	
	ply:SendLua("surface.PlaySound('hl1/fvox/deactivated.wav')")
end)

hook.Add("PlayerSpawnedSENT","tr_Spawners_SpawnMessage",function(ply,ent)
	if ent:GetClass() == "ent_tr_spawn" then
		ply:ChatPrint("Spawners will by default stay invisible")
		ply:ChatPrint("You can make them appear by using 'tr_spawners_draw 1' in console")
		ply:ChatPrint("Save the spawner using tr_spawners_save and tr_spawners_respawn to spawn them")
		ply:ChatPrint("Spawners will NOT activate unless the gamemode is Sandbox!")
	end
end)

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel("models/props_combine/combine_mine01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:DrawShadow(false)
	
	self:SetKeyValue("renderfx",16) 
	
	self:SetColor(Color(255,255,255,20))
end

hook.Add("PlayerSpawn","tr_Spawners_SetPlyPos",function(ply)
	if GAMEMODE.Name == "Sandbox" then
		if #ents.FindByClass("ent_tr_spawn") > 0 then
			local spawner = table.Random(ents.FindByClass("ent_tr_spawn"))
			if spawner:IsValid() then
				ply:SetPos(spawner:GetPos())
				for k,v in pairs(player.GetAll()) do
					v:SendLua("if GetConVarNumber('tr_spawners_draw') == 1 and Entity("..spawner:EntIndex().."):IsValid() then Entity("..spawner:EntIndex().."):EmitSound('ambient/energy/whiteflash.wav',75,200) end")
				end
			end
		end
	end
end)