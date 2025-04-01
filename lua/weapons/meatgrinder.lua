SWEP.PrintName = "Meatgrinder"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Groovy"
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/placehold_generi.png"

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
    --Chainsaw attack, will not need ammo
    self:SetNextPrimaryFire( CurTime() + 0.5 )
    self:EmitSound( "", 100, math.random( 135, 165 ), 100, 6 )
end

function SWEP:SecondaryAttack()
    --Distraction/Projectile attack

end
