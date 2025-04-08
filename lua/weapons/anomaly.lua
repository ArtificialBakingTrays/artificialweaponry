--You were not supposed to find this.
SWEP.PrintName = "ANOMALY"
SWEP.Author	= "ArtiBakingTrays"

SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel	= "models/weapons/w_stunbaton.mdl"
SWEP.DrawAmmo = false
SWEP.UseHands = false
SWEP.HoldType = "rpg"
SWEP.Slot = 0
--There are things that you must find, that you cannot see. Use me to seek them out.

util.PrecacheSound("other/use.mp3")
util.PrecacheSound("other/notify2.mp3")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"
--There is but one other creation that can see us.

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + 0.5 )
	self:EmitSound( "other/use.mp3", 100, math.random(95, 105), 100, 6 )
end

function SWEP:Deploy()
	self:EmitSound( "other/notify2.mp3", 100, math.random(95, 105), 100, 6 )
end