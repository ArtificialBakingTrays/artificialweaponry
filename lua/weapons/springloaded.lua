SWEP.PrintName = "SpringLoaded ScatterSearch"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = ""
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/placehold_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.DrawCrosshair = true
SWEP.ViewModel	= "models/weapons/c_shotgun.mdl"
SWEP.WorldModel	= "models/weapons/w_shotgun.mdl"
SWEP.DrawAmmo = true
SWEP.AccurateCrosshair = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 3
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = -1

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

--The code I understand the least :D -Trays

local offsetSpread = 0.025
local offsetLUT = {
	-- Top row
	[1] = Vector(-offsetSpread, offsetSpread ),
	[2] = Vector( 0			  , offsetSpread ),
	[3] = Vector( offsetSpread, offsetSpread ),

	-- Center row
	[4] = Vector(-offsetSpread, 0			 ),
	[5] = Vector( 0			  , 0			 ),
	[6] = Vector( offsetSpread, 0			 ),

	[7] = Vector(-offsetSpread, -offsetSpread),
	[8] = Vector( 0			  , -offsetSpread),
	[9] = Vector( offsetSpread, -offsetSpread),
}

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )
	self:SetNextPrimaryFire( CurTime() + 0.75 )
	local owner = self:GetOwner()

	self:EmitSound( "tray_sounds/basicfire.mp3", 75, math.random(130, 140), 1, 1 )
	self:EmitSound( "tray_sounds/parasite_fire.mp3", 75, math.random(105, 110), 1, 6 )

	owner:LagCompensation( true )

	self._fireAmount = (self._fireAmount or 0) + 1

	local aimDir = owner:GetAimVector()
	local aimDirAng = aimDir:Angle()
	local aimRight = aimDirAng:Right()
	local aimUp = aimDirAng:Up()

	local realShootDir = Vector()
	for i = 1, #offsetLUT do
		local entry = offsetLUT[i] * 1
		realShootDir:Set(aimDir)

		entry:Rotate(Angle(0, self._fireAmount * 15, 0))

		local offX = entry[1]
		local offY = entry[2]

		realShootDir = realShootDir + (aimRight * offX) + (aimUp * offY)
		realShootDir:Normalize()

		owner:FireBullets({
			Src = owner:GetShootPos(),
			Dir = realShootDir,
			Damage = 7,
			Num = 1,
			Spread = Vector(0.0, 0.0),
			Attacker = owner,
			Inflictor = self,
			Force = 0,
		})
	end

	owner:LagCompensation( false )
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end

function SWEP:Reload()
	if self:GetDTFloat( 0 ) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() == self.Primary.ClipSize then return end

	self:SetDTFloat(0, CurTime() + .7 )
	self:SendWeaponAnim( ACT_VM_RELOAD )

end

function SWEP:Think()
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end
	if time > CurTime() then return end

	self:SetClip1( 8 )
	self:SetDTFloat( 0, 0 )
end
