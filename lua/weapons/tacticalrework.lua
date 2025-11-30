SWEP.PrintName = "Tactical Chemistry"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Brew up their demise."
SWEP.IconOverride = "vgui/weaponvgui/tactical_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel	= "models/weapons/c_smg1.mdl"
SWEP.WorldModel	= "models/weapons/w_smg1.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 2
SWEP.Category = "Artificial Weaponry"

SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"

SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "Battery"

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	if self:Clip1() <= 0 then return end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )
	self:SetNextPrimaryFire( CurTime() + 0.115 + ((self:Clip2() / 10) / 2))

	self:EmitSound( "other/splathit1.mp3", 100, math.random( 95,105 ) + (self:Clip2() * 10 * 2), 75, 1 )

	owner:LagCompensation( true )

	self:SpawnProj()

	owner:LagCompensation( false )
end

function SWEP:SpawnProj()
	if CLIENT then return end

	local ent = ents.Create( "potion" )

	if ( not ent:IsValid() ) then return end

	--yknow its bad when we have the CUBE OF VARIABLES
	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local ownereyes = owner:EyeAngles()
	local aimvec = owner:GetAimVector()

	ent:SetPos( ownerpos + Vector( 0, 0, -5 ))
	ent:SetAngles( ownereyes + Angle( 90, 0, 0 ))
	ent:SetOwner( owner )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	aimvec:Mul( 3500 * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )

end


function SWEP:SecondaryAttack()
	--Each number up to 4 is different brews that can be called on by right clicking.
	self:SetNextPrimaryFire( CurTime() + 0.35 )
	self:SetClip2( self:Clip2() + 1 )

	self:EmitSound( "other/chemfire1.mp3", 100, math.random( 95,105 ) + (self:Clip2() * 10), 75, 1 )

	if self:Clip2() <= 4 then
		self:SetClip2( 1 )
	end
end

function SWEP:Reload()
	if self:GetDTFloat( 0 ) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() == self.Primary.ClipSize then return end

	self:SetDTFloat( 0, CurTime() + .6 )
	self:SendWeaponAnim(ACT_VM_RELOAD)

	self:EmitSound( "other/potregenreload.mp3", 75, 110, .7, 1 )
end

function SWEP:Think() --Help from zynx
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end

	if time > CurTime() then return end

	self:SetClip1( 6 )
	self:SetDTFloat( 0, 0 )
end