AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("player.lua")


function GM:PlayerInitialSpawn( ply )
	print("Player " .. ply:Name() .. " spawned.")
	ply:Battle()

end

function GM:PlayerSpawn( ply )
	print("Player " .. ply:Name() .. " respawned.")
	ply:Battle()
end

hook.Add( "GetFallDamage", "RealisticDamage", function( ply, speed )
    return ( speed / 8 )
end )


--[[---------------------------------------------------------
	If false is returned then the context menu is never created.
	This saves load times if your mod doesn't actually use the
	context menu for any reason.
-----------------------------------------------------------]]
function GM:ContextMenuEnabled()
	return true
end

--[[---------------------------------------------------------
	Called when context menu is trying to be opened.
	Return false to dissallow it.
-----------------------------------------------------------]]
function GM:ContextMenuOpen()
	return true
end

function GM:ContextMenuOpened()
	self:SuppressHint( "OpeningContext" )
	self:AddHint( "ContextClick", 20 )
end



hook.Add("PlayerNoClip", "FeelFreeToTurnItOff", function(ply, desiredState)
    if desiredState == true then
		if (ply:IsSuperAdmin() )then
			return true     
		else
			return false
		end
    end
end)

local speed_slowwalk = 20
local speed_walk = 100
local speed_run = 250
local speed_crouchwalk = 0.1

local RMSEnabled = CreateConVar( "sv_rms_enable", 1, FCVAR_NONE, "Toggles Realistic Movement Speed mod", 0, 1 )

cvars.AddChangeCallback( "sv_rms_enable", function()
    print("Respawn for changes to take effect.")
end)

hook.Add("PlayerSpawn", "RMSHook", function(player)
    if RMSEnabled:GetInt() == 1 then 
        timer.Simple(0.1, function()
            player:SetWalkSpeed(speed_walk)
            player:SetRunSpeed(speed_run)
            player:SetSlowWalkSpeed(speed_slowwalk)
            player:SetCrouchedWalkSpeed(speed_crouchwalk)
        end)
    end
end)
