SWEP.PrintName = "BoomBramble"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "An artifact of the past, now embued with poisonous berries. M1 to blast an array of Berries, M2 to release a damaging Bramble."
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/legendari_generi.png"

SWEP.ViewModel	= "models/weapons/c_shotgun.mdl"
SWEP.WorldModel	= "models/weapons/w_shotgun.mdl"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = true
SWEP.DrawHUD = false
SWEP.DrawAmmo = true
SWEP.UseHands = false
SWEP.HoldType = "ar2"
SWEP.Slot = 3

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = 75

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "Battery"

function SWEP:Deploy()
	self:EmitSound( "boombramble/shakebush.mp3", 75, math.random(105, 125), 1, 1 )
	self:EmitSound( "sparkbound/gun_unsheathe.mp3", 75, math.random(50, 65), 1, 6 )
end

local bannedLUT = {
	["CHudAmmo"] = true,
}

function SWEP:HUDShouldDraw(element)
	if bannedLUT[element] then
		return false
	end
	return true
end

function SWEP:PrimaryAttack()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	local owner = self:GetOwner()
	--local ownerpos = owner:GetShootPos()
	--local forward = owner:GetAimVector()

	self:SetNextPrimaryFire( CurTime() + 0.45 )

	self:EmitSound( "boombramble/terrariapult.mp3", 100, math.random(90, 110), 0.7, 1 )
	--Weapon Sounds
	self:EmitSound( "boombramble/aureusshootcrystal.mp3", 100, math.random(90, 110) - 30, 0.7, 6 )

	owner:LagCompensation( true )

		self:EntLaunch()

	owner:LagCompensation( false )
end

function SWEP:EntLaunch()
	if CLIENT then return end

	local ent = ents.Create( "berry_proj" )

	if ( not ent:IsValid() ) then return end

	--yknow its bad when we have the CUBE OF VARIABLES
	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local ownereyes = owner:EyeAngles()
	local aimvec = owner:GetAimVector()

	ent:SetPos( ownerpos + Vector(0, 0, -5) )
	ent:SetAngles( ownereyes + Angle(90,0,0) + Angle(math.random(0, 1), math.random(0, 1), math.random(0, 1)))
	ent:SetOwner( owner )
	ent:SetGravity( 1 )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	aimvec:Mul( 1500 * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )

end