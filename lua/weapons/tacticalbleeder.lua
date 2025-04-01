SWEP.PrintName = "Tactical Bleeder"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "2 hits cause a powerful shot, Standard Semi Automatic Weapon"
SWEP.IconOverride = "vgui/weaponvgui/tactical_generi.png"
--this coco amazing very nice

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel	= "models/weapons/c_smg1.mdl"
SWEP.WorldModel	= "models/weapons/w_smg1.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 2
SWEP.Category = "Artificial Weaponry"

SWEP.Primary.ClipSize = 24
SWEP.Primary.DefaultClip = 24
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Force = 80

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:Reload()
    if ( not self:HasAmmo() ) or ( CurTime() < self:GetNextPrimaryFire() ) then return end
        if self:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 then
            self:DefaultReload( ACT_VM_RELOAD )
    end
end

function SWEP:PrimaryAttack()
    if self:Clip1() <= 0 then return end -- No Shoot
    if self:Clip1() <= 30 then self.Dmg = 16 end

    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self:TakePrimaryAmmo( 1 )

    self:SetNextPrimaryFire( CurTime() + 0.34 )

    local pitch = math.random( 90, 110 )
    self:EmitSound( "npc/manhack/mh_blade_snick1.wav", 75, pitch, 0.7, 1 )
    self:EmitSound( "npc/roller/blade_cut.wav", 75, pitch, 0.7, 6 )

    local owner = self:GetOwner()
    owner:LagCompensation( true )

    owner:FireBullets {
        Src = owner:GetShootPos(),
        Dir = owner:GetAimVector(),

        Damage = 15,
        Attacker = owner,

        Callback = function( attacker, tr )
            if SERVER and tr.Entity:IsValid() and ( tr.Entity:IsPlayer() or tr.Entity:IsNPC() ) then
                self:SetClip2( self:Clip2() + 1 )
                if self:Clip2() >= 2 then
                    local dmg = DamageInfo()
                    dmg:SetDamage( 50 )
                    dmg:SetAttacker( attacker )
                    dmg:SetInflictor( self )
                    dmg:SetDamageType( DMG_DISSOLVE )
                    tr.Entity:TakeDamageInfo( dmg )
                    self:SetClip2( 0 )
                    tr.Entity:EmitSound("ambient/levels/canals/toxic_slime_sizzle3.wav", 75, pitch)
                end
            else
                self:SetClip2( 0 )
            end
        end,
    }

    owner:LagCompensation( false )
end

local function drawCircleLine(x, y, sx, sy, itr)
    for i = 0, (itr - 1) do
        local delta = (i / itr) * (math.pi * 2)
        local deltaPrev = ((i - 1) / itr) * (math.pi * 2)
        local x1 = x + math.cos(delta) * sx
        local y1 = y + math.sin(delta) * sy
        local x2 = x + math.cos(deltaPrev) * sx
        local y2 = y + math.sin(deltaPrev) * sy
        surface.DrawLine(x1, y1, x2, y2)
    end
end

function SWEP:DrawHUD()
    surface.SetDrawColor(255, 255, 255, 125)
    render.SetColorMaterialIgnoreZ()

    drawCircleLine(ScrW() * .5, ScrH() * .5, 2, 2,  24)

    draw.SimpleText("iDELTA; " .. tostring(invDelta), "BudgetLabel", 0, 0, c_White)
end
