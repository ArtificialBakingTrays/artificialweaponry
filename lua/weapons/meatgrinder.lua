SWEP.PrintName = "Meatgrinder"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Groovy"
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/meatgrind_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
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

local offsetSpread = 0.1
local offsetLUT = {
	[1] = Vector(-offsetSpread, 0), -- left
	[2] = Vector(            0, 0), -- center
	[3] = Vector( offsetSpread, 0), -- right
}

function SWEP:SecondaryAttack()
	--Distraction/Projectile attack
	self:SetNextSecondaryFire( CurTime() + 3.2 )

	self:EmitSound( "artiwepsv2/usesfx.wav", 75, math.random(85, 95), 1, 1 )

	self:GetOwner():LagCompensation( true )

	local owner = self:GetOwner()
	local aimDir = owner:GetAimVector()
	local aimDirAng = aimDir:Angle()
	local aimRight = aimDirAng:Right()
	local aimUp = aimDirAng:Up()

	local realShootDir = Vector()
	for i = 1, #offsetLUT do
		local shootDir = offsetLUT[i]
		realShootDir:Set(aimDir)

		local offX = shootDir[1]
		local offY = shootDir[2]

		realShootDir = realShootDir + (aimRight * offX) + (aimUp * offY)
		realShootDir:Normalize()

		--Hehe idk what im doing
		self:SpawnGibblers(realShootDir)
	end

	self:GetOwner():LagCompensation( false )
end

function SWEP:SpawnGibblers(targetDir)
	if CLIENT then return end

	local ent = ents.Create( "gibbler" )

	if ( not ent:IsValid() ) then return end

	--yknow its bad when we have the CUBE OF VARIABLES
	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local ownereyes = owner:EyeAngles()

	ent:SetOwner( owner )
	ent:SetPos( ownerpos + Vector(0, 0, -5) )
	ent:SetAngles( ownereyes + Angle(90,0,0) )
	ent:Spawn()


	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	local Speed = 650
	targetDir:Mul( Speed * entphys:GetMass() )
	entphys:ApplyForceCenter( targetDir )
end

function SWEP:Reload()
	--charge up attack
	self.DoChargeUp = true
end

function SWEP:Deploy()
	self:EmitSound( "artiwepsv2/chainstartup.mp3", 100, math.random( 95, 105 ), 0.4, 1 )
	self:SetClip1(0)

	self.AmmoLoseTime = CurTime()

	local time = 1
	timer.Simple(time, function()
		self:EmitSound( "artiwepsv2/chainstartup.mp3", 100, math.random( 105, 115 ), 0.4, 6 )
	end)
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end

function SWEP:TakeAmmoThink()
	if self.DoChargeUp then
		self.AmmoLoseTime = CurTime()
		return
	end

	local pTime = self.AmmoLoseTime or CurTime()
	local cTime = CurTime()

	local secWaitToLoseOneAmmo = 0.05
	if (cTime - pTime) < secWaitToLoseOneAmmo then
		return
	end
	self.AmmoLoseTime = CurTime()

	-- take away ammo
	self:SetClip1( math.max(self:Clip1() - 1, 0) )
end

function SWEP:ChargeUpThink()
	if not self.DoChargeUp then
		return
	end

	local keyReload = self:GetOwner():KeyDown(IN_RELOAD)
	if not keyReload then
		self.DoChargeUp = false
	end

	if (self.NextAmmoGive or 0) > CurTime() then
		return
	end
	self.NextAmmoGive = CurTime() + .05

	self:SetClip1( math.min( self:Clip1() + 1, 100) )
end

function SWEP:Think()
	if CLIENT then return end
	self:TakeAmmoThink()
	self:ChargeUpThink()
end