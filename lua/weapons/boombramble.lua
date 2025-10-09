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

SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
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
	if self:Clip1() <= 0 then return end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )

	self:SetNextPrimaryFire( CurTime() + 0.65 )

	self:EmitSound( "tray_sounds/parasite_energy.mp3", 55, math.random(130, 140), 1, 1 )
	self:EmitSound( "weapons/ar2/ar2_altfire.wav", 90, math.random(130, 135), 1, 6 )

	local owner = self:GetOwner()

end