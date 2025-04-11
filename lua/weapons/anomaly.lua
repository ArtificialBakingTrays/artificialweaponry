--You were not supposed to find this.
SWEP.PrintName = "A.D.T" --Anomaly Detector Tool
SWEP.Instructions = "Anomaly Detecting Tool"
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
	--self:EmitSound( "other/online.mp3", 100, math.random(90, 110), 100, 6 )
	--self:EmitSound( "other/use.mp3", 100, math.random(90, 110), 100, 6 )
end

function SWEP:Deploy()
	local random = math.random(1, 2)

	if random == 1 then
		self:EmitSound( "other/notify2.mp3", 100, math.random(95, 105), 100, 6 )
	elseif random == 2 then
		self:EmitSound( "other/notify.mp3", 100, math.random(95, 105), 100, 6 )
	end
end

--[[
DIFFERENT TEXT OPTIONS FOR ANOMALY SCANS:
	Nothing: YOU FOUND, NOTHING. :(

	Player: YES, THAT IS (NAME). NOTHING ODD HERE.

	Chair: I REALLY WISH I COULD SIT.

	Computer: I HAD A FRIEND WHO WAS ONE OF THESE.

	Sword: Felwinter, IS THAT YOU?

]]--