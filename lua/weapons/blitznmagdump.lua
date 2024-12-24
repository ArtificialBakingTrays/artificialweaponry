util.PrecacheSound("npc/antlion_guard/near_foot_light2.wav")
util.PrecacheSound("npc/antlion_guard/foot_light1.wav")
util.PrecacheSound("tray_sounds/reloadonce.mp3")

SWEP.PrintName = "Blitz & MagDump"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = ""
SWEP.Category = "Artificial Weaponry"

SWEP.ViewModel	= "models/weapons/c_smg1.mdl"
SWEP.WorldModel	= "models/weapons/w_smg1.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.DrawCrosshair = true
SWEP.DrawHUD = false
SWEP.DrawAmmo = true

SWEP.UseHands = false
SWEP.HoldType = "ar2"
SWEP.Slot = 3


SWEP.Primary.ClipSize = 45
SWEP.Primary.DefaultClip = 45
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Force = 75

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"

local FirRat = 0.095

local FirTracr = "AR2Tracer"

function SWEP:PrimaryAttack()
    if self:Clip1() <= 0 then return end

    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self:TakePrimaryAmmo( 1 )

    local owner = self:GetOwner()
    local ownerpos = owner:GetShootPos()
    local forward = owner:GetAimVector()

    self:SetNextPrimaryFire( CurTime() + FirRat )

    self:EmitSound( "npc/antlion_guard/near_foot_light2.wav", 100, 145, 0.7, 1 )

    owner:LagCompensation( true )

        self:FireBullets({
            ["Src"] = ownerpos + Vector(0,0,0),
            ["Dir"] = forward,
            ["Spread"] = Vector( 0.035, .035),
            ["TracerName"] = FirTracr,
            ["Num"] = 1,
            ["Damage"] = 15,
            ["Attacker"] = owner,
        })

    owner:LagCompensation( false )

end

function SWEP:SecondaryAttack()
    if self:Clip1() <= 0 then return end

    self:TakePrimaryAmmo( 1 )

    local owner = self:GetOwner()

    local SFireRate = FirRat - 0.045

    self:SetNextSecondaryFire( CurTime() + SFireRate )

    self:EmitSound( "npc/antlion_guard/foot_light1.wav", 100, 165, 0.7, 1 )

    owner:LagCompensation( true )

        self:FireBullets({
            ["Src"] = owner:GetShootPos(),
            ["Dir"] = owner:GetAimVector(),
            ["Spread"] = Vector( 0.055, .055),
            ["TracerName"] = FirTracr,
            ["Num"] = 1,
            ["Damage"] = 15,
            ["Attacker"] = owner,
        })

    owner:LagCompensation( false )

end

function SWEP:Reload()
    if ( not self:HasAmmo() ) or ( CurTime() < self:GetNextPrimaryFire() ) then return end

    if self:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 then
        self:DefaultReload( ACT_VM_RELOAD )
        self:EmitSound("tray_sounds/reloadonce.mp3", 100, 150 )
    end
end