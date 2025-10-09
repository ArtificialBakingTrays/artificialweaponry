SWEP.PrintName = "SparkBound Compass"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "They say it will lead you in the direction of a raging storm"
SWEP.Category = "Artificial Legendaries"
SWEP.IconOverride = ""

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = true
SWEP.ViewModel	= "models/weapons/c_crossbow.mdl"
SWEP.WorldModel	= "models/weapons/w_crossbow.mdl"
SWEP.DrawAmmo = true
SWEP.AccurateCrosshair = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 3
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = 160

SWEP.Secondary.ClipSize	= 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

function SWEP:Deploy()
	self:EmitSound( "sparkbound/surge.mp3", 75, math.random(105, 125), 1, 1 )
	self.UsingSurge = false
	self.ThunderActive = false
	self.ComboTrue = false
	self:SetClip1( 0 )
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

function SWEP:SpawnProj( EntName, Speed )
	if CLIENT then return end
	local ent = ents.Create( EntName )
	if ( not ent:IsValid() ) then return end

	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local ownereyes = owner:EyeAngles()
	local aimvec = owner:GetAimVector()

	ent:SetOwner( owner )
	ent:SetPos( ownerpos + Vector( 0, 0, -5 ) )
	ent:SetAngles( ownereyes + Angle( 90, 0, 0 ) )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	aimvec:Mul( Speed * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )

end

function SWEP:PrimaryAttack()
	if self.HasFired then return end
	self.HasFired = true

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetClip1( self:Clip1() + 1 )

	local Delay = 0.65

	self:EmitSound( "sparkbound/shoot.mp3", 75, math.random( 90, 100 ) + ( self:Clip1() * 10 ), 1.2, 6 )

	if self.HasFired then
		timer.Simple( Delay - ( self:Clip1() * 0.1 ), function()
			if not self:IsValid() then return end
			self:EmitSound( "sparkbound/gun_unsheathe.mp3", 75, math.random( 90, 100 ), 1.2, 6 )
			self.HasFired = false
		end)
	end

	local owner = self:GetOwner()
	owner:LagCompensation( true )

	if self:Clip1() <= 4 then
		self:SpawnProj( "thunderbolt", 5000 * 1000 )
		self:EmitSound( "sparkbound/cloudstrikefire.mp3", 75, math.random( 120, 130 ) + ( self:Clip1() * 10 ), 1, 1 )
	else
		self:SpawnProj( "sharpshot", 7500 * 2000 )
		self:EmitSound( "sparkbound/surgeblast.mp3", 75, math.random( 120, 130 ) + ( self:Clip1() * 10 ), 1, 1 )
	end

	owner:LagCompensation( false )
end

function SWEP:Think()
	if self:Clip1() == 5 then self:SetClip1( 0 ) end
end

--====================On-Kill Functionality====================--
--Will cause a radius based explosion, dealing an okay amount of damage


--====================Secondary Attack Functionality====================--
--Sparklers / Scatter Rounds, throw out 3 bolts that detonate after a moment, have no gravity. do not track either
	--Meant for extra dps or distraction rounds

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + 1 )
	self:EmitSound("sparkbound/cast.mp3", 75, math.random( 90, 110 ), 1.2, 6)

	for I = 1, 3 do self:SpawnSparks() continue end
end

function SWEP:SpawnSparks()
	if CLIENT then return end
	local ent = ents.Create( "sparkler" )
	if ( not ent:IsValid() ) then return end

	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local ownereyes = owner:EyeAngles()
	local aimvec = owner:GetAimVector()

	ent:SetOwner( owner )
	ent:SetPos( ownerpos + Vector( 0, 0, -5 ) )
	ent:SetAngles( ownereyes + Angle( 90, 0, 0 ) )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	local Speed = 850

	aimvec:Mul( Speed * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )
end