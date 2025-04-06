SWEP.PrintName = "Subzero Standard"
SWEP.Author			= "ArtiBakingTrays" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu
SWEP.Contact 		= "ArtificialBakingTrays"
SWEP.Instructions	= "Standard Issue technology, fires Ice Bolts that slows targets. If you have GLACIAL BONUS: Weapon has increased Reload Speed and a Slight ROF speed bump. "
SWEP.Category 		= "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/compacted_generi.png"

util.PrecacheSound( "tray_sounds/subzero_fire.mp3" )

SWEP.ViewModel	= "models/weapons/c_smg1.mdl"
SWEP.WorldModel	= "models/weapons/w_smg1.mdl"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = true
SWEP.DrawHUD = false
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 3

SWEP.Primary.ClipSize = 36
SWEP.Primary.DefaultClip = 36
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:PrimaryAttack()
    if self:Clip1() <= 0 then return end
    self:TakePrimaryAmmo( 1 )
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self:SetNextPrimaryFire( CurTime() + 0.06 )

    self:EmitSound( "tray_sounds/subzero_standard.mp3", 100, math.random( 105, 115 ), 100, 6 )
    self:EmitSound( "tray_sounds/tomefire.mp3", 100, math.random( 95, 105 ), 100, 6 )

    local owner = self:GetOwner()

owner:LagCompensation( true )

    owner:FireBullets {
    Src = owner:GetShootPos(),
    Dir = owner:GetAimVector(),
    Damage = 7,
    Attacker = owner,
    Callback = function( attacker, tr )
        if SERVER and tr.Entity:IsValid() and tr.Entity:IsPlayer() then
            if not IsValid( tr.Entity ) then return end
            if tr.Entity.IsSlowed == true then return end
            if tr.Entity.IsSlowed == false then
                tr.Entity.IsSlowed = true
                Ply = tr.Entity
                Ply:SetRunSpeed( Ply:GetRunSpeed() - 40 )
                Ply:SetWalkSpeed( Ply:GetWalkSpeed() - 40 )
            end

            if tr.Entity.IsSlowed == true then
                local Time = 2
                timer.Simple( Time, function()
                    Ply:SetRunSpeed( Ply:GetRunSpeed() + 40 )
                    Ply:SetWalkSpeed( Ply:GetWalkSpeed() + 40 )
                    tr.Entity.IsSlowed = false
                end)
            end
        end
    end,}
owner:LagCompensation( false )
end

function SWEP:Reload()
    if self:GetDTFloat(0) ~= 0 then return end
    if CurTime() < self:GetNextPrimaryFire() then return end
    if self:Clip1() == self.Primary.ClipSize then return end

    self:SetDTFloat( 0, CurTime() + 1.2 )
    self:SendWeaponAnim(ACT_VM_RELOAD)
end

function SWEP:Think() --This like fuckass prediction for timers is so like cooked- how the fuck did zynx figure this out?
    local time = self:GetDTFloat( 0 )
    if time == 0 then return end

    if time > CurTime() then return end

    self:SetClip1( 36 )
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