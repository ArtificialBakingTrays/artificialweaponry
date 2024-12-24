SWEP.PrintName = "Directed Animosity"
SWEP.Author	= "ArtificialBakingTrays" -- Shows up while hovering
SWEP.Instructions = "Slow fire rate, Increases Rate of Fire as you hold the trigger. Returns rounds on kills."
SWEP.Category = "Artificial Weaponry"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel	= "models/weapons/c_smg1.mdl"
SWEP.WorldModel	= "models/weapons/w_smg1.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 2

SWEP.Primary.ClipSize = 45
SWEP.Primary.DefaultClip = 45
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Force = 80

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:Initialize()
    self.ROF = 0.1
    self.Pitch = 60
    self.Spred = 0.025
    self.Dmg = 12
end

function SWEP:Reload()
    if ( not self:HasAmmo() ) or ( CurTime() < self:GetNextPrimaryFire() ) then return end
        if self:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 then
            self:DefaultReload( ACT_VM_RELOAD )
             self:EmitSound("npc/manhack/gib.wav", 100 )

        self.ROF = 0.1
        self.Pitch = 60
        self.Spred = 0.025
        self.Dmg = 12
    end
end

function SWEP:SecondaryAttack() end

function SWEP:PrimaryAttack()
    if self:Clip1() <= 0 then return end -- No Shoot
    if self:Clip1() <= 20 then self.Dmg = 16 end

    if IsFirstTimePredicted() then
        self.Pitch = self.Pitch + 1
        self.ROF = math.max( self.ROF - .0004, .001 )
        self.Spred = math.max( self.Spred + 0.0001, 0.01 )
    end

    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self:TakePrimaryAmmo( 1 )

    local owner = self:GetOwner()
    local Ownerpos = owner:GetShootPos()
    local Forwar = owner:GetAimVector()

    self:SetNextPrimaryFire( CurTime() + self.ROF )

    local pitch = self.Pitch
    self:EmitSound( "weapons/ar2/npc_ar2_altfire.wav", 100, math.random( pitch - 10, pitch ), 0.7, 1 )

    owner:LagCompensation( true )

    self:FireBullets({
        ["Src"] = Ownerpos,
        ["Dir"] = Forwar,
        ["Spread"] = Vector( self.Spred, self.Spred, self.Spred ),
        ["TracerName"] = Trcr, -- https://wiki.facepunch.com/gmod/Default_Effects
        ["Num"] = 1,
        ["Damage"] = self.Dmg,
        ["Attacker"] = owner,
    })

    owner:LagCompensation( false )
end

hook.Add( "OnNPCKilled", "direchatred", function( npc, attacker, inflictor )
    if inflictor:IsValid() and inflictor:GetClass() == "direchatred" then
        inflictor:SetClip1( math.min( inflictor:Clip1() + 20, inflictor:GetMaxClip1() ) )
    end
end )

hook.Add( "PlayerDeath", "direchatred", function( victim, inflictor )
    if inflictor:IsValid() and inflictor:GetClass() == "direchatred" then
        inflictor:SetClip1( math.min( inflictor:Clip1() + 20, inflictor:GetMaxClip1() ) )
    end
end )

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

local c_White = Color(255, 255, 255)
function SWEP:DrawHUD()
    --render stuff here with surface or any drawing method, its a 2d context
    local delta = self:Clip1() / self:GetMaxClip1()

    -- set red colour
    surface.SetDrawColor(255, delta * 255, delta * 255, 128)
    render.SetColorMaterialIgnoreZ()

    local spread = self.Spred * 20

    -- draws the line circle
    drawCircleLine(ScrW() * .5, ScrH() * .5, 28 * spread, 28 * spread,  24)

    draw.SimpleText("iDELTA; " .. tostring(invDelta), "BudgetLabel", 0, 0, c_White)
end
