SWEP.PrintName = "Parasitical Arm-Implants"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = ""
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/placehold_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = false
SWEP.ViewModel	= "models/weapons/c_crossbow.mdl"
SWEP.WorldModel	= "models/weapons/w_crossbow.mdl"
SWEP.DrawAmmo = true
SWEP.AccurateCrosshair = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 3
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = 160

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end
	if self:Clip1() <= 30 then self.Dmg = 16 end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )

	self:SetNextPrimaryFire( CurTime() + 0.65 )

	self:EmitSound( "tray_sounds/parasite_energy.mp3", 55, math.random(130, 140), 1, 1 )
	self:EmitSound( "weapons/ar2/ar2_altfire.wav", 90, math.random(130, 135), 1, 6 )
end

function SWEP:SecondaryAttack() end --will be used for scoping like Slabshot

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end

function SWEP:Reload()
	if CurTime() < self:GetNextPrimaryFire() then return end

	local owner = self:GetOwner()
	if owner:Armor() < 15 then return end
	if self:Clip1() >= 10 then return end

	local time = self:GetDTFloat( 0 )
	if time ~= 0 then return end

	self:SetDTFloat( 0, CurTime() + 0.2 )
	self:SetNextPrimaryFire( CurTime() + 0.2 )
end

function SWEP:Think()
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end
	if time > CurTime() then return end

	local owner = self:GetOwner()
	if 15 > owner:Armor() then
		self:SetDTFloat( 0, 0 )
		return
	end

	local clip1 = self:Clip1() + 2
	if clip1 > self.Primary.ClipSize then return end

	if SERVER then
		owner:SetArmor( owner:Armor() - 15 )
	end

	self:SetClip1( clip1 )
	self:SetDTFloat( 0, 0 )

	self:EmitSound( "weapons/bugbait/bugbait_squeeze3.wav", 75, math.random(140, 150), 1, 6 )
	self:EmitSound( "weapons/ar2/ar2_reload_rotate.wav", 75, 100, 1, 6 )
end