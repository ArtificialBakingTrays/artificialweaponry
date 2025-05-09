SWEP.PrintName = "Parasitical Arm-Implants"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Hold R to consume Armour to gain 2 rounds, Damage enemies to gain Armour, while at full armor, gain health for hits."
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/parasite_generi.png"

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
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )

	self:SetNextPrimaryFire( CurTime() + 0.65 )

	self:EmitSound( "tray_sounds/parasite_energy.mp3", 55, math.random(130, 140), 1, 1 )
	self:EmitSound( "weapons/ar2/ar2_altfire.wav", 90, math.random(130, 135), 1, 6 )

	local owner = self:GetOwner()
	owner:LagCompensation( true )

	owner:FireBullets {
		Src = owner:GetShootPos(),
		Dir = owner:GetAimVector(),
		Damage = 55,
		Attacker = owner,
		Callback = function( attacker, tr, dmg )
			if tr.Entity:IsValid() and ( tr.Entity:IsPlayer() or tr.Entity:IsNPC() ) then
				if SERVER then
					StatusNullify( owner, 10, 15 )
					util.BlastDamage( dmg:GetInflictor(), owner, tr.HitPos, 95, dmg:GetDamage() / 4)
					tr.Entity:EmitSound( "tray_sounds/parsite_multihit.mp3", 100, math.random(100, 115), 1, 6 )
				end
				local effectdata = EffectData()
				effectdata:SetOrigin( tr.HitPos )
				util.Effect("HelicopterMegaBomb", effectdata, true)
			end
		end,
	}

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

function SWEP:SetScoped( bool ) self:SetDTBool( 0, bool ) end
function SWEP:GetScoped() return self:GetDTBool( 0 ) end
function SWEP:SecondaryAttack() self:SetScoped( not self:GetScoped() ) end

function SWEP:TranslateFOV( fov )
	self.LastFOV = fov
	if self:GetScoped() then
		return 25
	end
end

function SWEP:AdjustMouseSensitivity()
	if self:GetScoped() then
		return 25 / self.LastFOV
	end
end