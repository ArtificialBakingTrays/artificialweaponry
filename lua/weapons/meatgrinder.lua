SWEP.PrintName = "Meatgrinder"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Groovy"
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/meatgrind_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.DrawCrosshair = false
SWEP.ViewModel	= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel	= "models/weapons/w_crowbar.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 1
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = 500

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"
--They say my hungers a problem.

function SWEP:PrimaryAttack()
	if self:GetOwner():WaterLevel() > 0 then return end

	--Chainsaw attack, will not need ammo
	self:SetNextPrimaryFire( CurTime() + 0.685 )
	self:EmitSound( "artiwepsv2/chainsawrev.mp3", 100, 100, 100, 6 )
end

function SWEP:SecondaryAttack()
	--Distraction/Projectile attack
	self:SetNextSecondaryFire( CurTime() + 1.6 )

	self:GetOwner():LagCompensation( true )
		self:SpawnGibblers()
	self:GetOwner():LagCompensation( false )
end

function SWEP:SpawnGibblers()
	if CLIENT then return end

	local ent = ents.Create( "gibbler" )

	if ( not ent:IsValid() ) then return end

	--yknow its bad when we have the CUBE OF VARIABLES
	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local ownereyes = owner:EyeAngles()
	local aimvec = owner:GetAimVector()

	ent:SetOwner( owner )
	ent:SetPos( ownerpos + Vector(0, 0, -5) )
	ent:SetAngles( ownereyes + Angle(90,0,0) )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	local Speed = 1250
	aimvec:Mul( Speed * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )
end

function SWEP:Reload()
	--charge up attack
end

function SWEP:Deploy()
	self:EmitSound( "artiwepsv2/chainstartup.mp3", 100, math.random( 95, 105 ), 0.4, 1 )
	self:SetClip1(0)

	local time = 1
	timer.Simple(time, function()
		self:EmitSound( "artiwepsv2/chainstartup.mp3", 100, math.random( 105, 115 ), 0.4, 6 )
	end)

end