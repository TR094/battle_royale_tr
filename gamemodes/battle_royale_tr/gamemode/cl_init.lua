include("shared.lua")



local function DisallowSpawnMenu( )
	if LocalPlayer():IsUserGroup("user") then
		return false
	else
		return true
	end
end
	
hook.Add( "SpawnMenuOpen", "DisallowSpawnMenu", DisallowSpawnMenu)


-- In cl_init.lua or a clientside file
hook.Add("OnContextMenuOpen", "RestrictContextMenu", function()
    if not LocalPlayer():IsAdmin() then
        return false
    end
end)
