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

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:Reload() return end
function SWEP:PrimaryAttack() return end
function SWEP:SecondaryAttack() return end