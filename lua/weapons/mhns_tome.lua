SWEP.PrintName = "BookWyrm's Tome of the Risen"
SWEP.Author			= "ArtiBakingTrays" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu
SWEP.Contact 		= "ArtificialBakingTrays"
SWEP.Instructions	= "A book that raises the Sunless,"
SWEP.Category 		= "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/tome_generi.png"

util.PrecacheSound( "tray_sounds/tombfire_2.mp3" )
util.PrecacheSound( "tray_sounds/slingfire2.mp3" ) --While I wouldnt reccomend using these as they can cause a slight jitter / lag spike
util.PrecacheSound( "tray_sounds/tombfoley2.mp3" ) --Its just to preload the sound before they are used, if you use alot i imagine it can be bad -Trays

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.ViewModel = "models/weapons/c_medkit.mdl"
SWEP.WorldModel	= "models/weapons/w_medkit.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "slam"
SWEP.Slot = 3

SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 15
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:PrimaryAttack()
	--Seeking rounds
	if self:Clip1() <= 0 then return end
	self:TakePrimaryAmmo( 3 )

	self:SetNextPrimaryFire( CurTime() + 0.5 )
	self:EmitSound( "tray_sounds/slingfire2.mp3", 100, math.random( 135, 165 ), 100, 6 )
	self:EmitSound( "tray_sounds/tombfire_2.mp3", 100, math.random( 95, 105 ), 100, 6 )

end

function SWEP:SecondaryAttack()
	--Will summon Sunless Fool
end

function SWEP:Reload()
	if self:GetDTFloat(0) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() == self.Primary.ClipSize then return end

	self:SetDTFloat( 0, CurTime() + 1 )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:EmitSound( "tray_sounds/tombfoley2.mp3", 100, math.random( 95, 105 ), 100, 6 )
end

function SWEP:Think() --This like fuckass prediction for timers is so like cooked- how the fuck did zynx figure this out?
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end

	if time > CurTime() then return end

	self:SetClip1( 15 )
	self:SetDTFloat( 0, 0 )
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end

--[[
Transmission: From BookWyrm

Our religion is a lie, the 'truth' is a lie.
We need to forsake our god of suffering if we must persist on with our existance.
Please Madware, for our sake; We need to abandon the god before we are made redundant.
We both know he has found greater apprentices than us, it is only a matter of time.

This message remains unread by its Recipient.
]]--