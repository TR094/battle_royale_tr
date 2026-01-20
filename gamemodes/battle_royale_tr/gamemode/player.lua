-- from what I understand, makes the local variable Player the "address" to the Player class functions, etc.
local ply = FindMetaTable("Player")



-- Function to set player as Catcher
function ply:Battle()
	self:SetHealth( 100 )
	self:SetMaxHealth( 10000 )
	self:SetArmor( 50 )
	self:SetMaxArmor( 10000 )
	self:SetModel("models/player/kleiner.mdl")
	self:StripWeapons()
	self:StripAmmo()
end
