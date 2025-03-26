SWEP.PrintName = "Compacted Ice Chucker"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Projectile Based Shotgun, Benefits from GLACIER_ORBS"
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/compacted_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.DrawCrosshair = false
SWEP.ViewModel	= "models/weapons/c_shotgun.mdl"
SWEP.WorldModel	= "models/weapons/w_shotgun.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "shotgun"
SWEP.Slot = 1
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 25
SWEP.Primary.DefaultClip = 25
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = 500

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

local pitch = 95

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end -- No Shoot
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 5 )

--    local owner = self:GetOwner()
--    local Ownerpos = owner:GetShootPos()
--    local Forwar = owner:GetAimVector()

	self:SetNextPrimaryFire( CurTime() + .33 )

	self:EmitSound("tray_sounds/glacialchuck.mp3", 100, math.random( pitch - 10, pitch ), 15, 1 )
	self:EmitSound("npc/antlion/foot2.wav", 100, math.random( pitch + 10, pitch + 20), 7, 6 )
end

function SWEP:Reload()
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() < self.Primary.ClipSize then
		self:EmitSound("tray_sounds/reload_1.mp3", 100, 150 )
		local time = 0.7
		timer.Simple(time, function()
			self:SetClip1( 25 )
		end)
	end
end