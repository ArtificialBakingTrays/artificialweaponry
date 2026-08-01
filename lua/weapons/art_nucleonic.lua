SWEP.PrintName = "Nucleonic"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "We are become death, the destroyer of worlds."
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/nucleonic_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = true
SWEP.ViewModel	= "models/weapons/c_irifle.mdl"
SWEP.WorldModel	= "models/weapons/w_irifle.mdl"
SWEP.DrawAmmo = true
SWEP.AccurateCrosshair = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 3
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 17
SWEP.Primary.DefaultClip = 17
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = 160

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"



function SWEP:PrimaryAttack()
    if self:Clip1() <= 0 then return end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )
    self:SetNextPrimaryFire( CurTime() + 0.235 )

    local owner = self:GetOwner()

    if CLIENT then
        self:EmitSound( "tray_sounds/slingfire2.mp3", 100, 100, nil, CHAN_STATIC )
        self:EmitSound( "artiwepsv2/nucleoshoot.mp3", 100, 100, nil, CHAN_STATIC )
        return
    end

    self:GetOwner():LagCompensation( true )

        local startPos = owner:GetShootPos()
        local endPos = startPos + owner:GetAimVector() * 32768

        local tr = util.TraceLine({
            start = startPos,
            endpos = endPos,
            filter = owner
        })

        self:HandleProjectileHit(startPos, endPos)

        if IsValid(tr.Entity) then tr.Entity:TakeDamage(23, owner, self) end

    self:GetOwner():LagCompensation( false )
end

function SWEP:HandleProjectileHit(startPos, endPos)

    local closest
    local bestDist = math.huge

    for _, ent in ipairs(ents.FindByClass("bulkball_projectile")) do

        local pos = ent:GetPos()

        local nearest = util.DistanceToLine(startPos, endPos, pos)

        if nearest < 12 and nearest < bestDist then
            closest = ent
            bestDist = nearest
        end
    end

    if IsValid(closest) then
        closest:Explode(self:GetOwner())
    end
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

	self:SetClip1( self:GetMaxClip1() )
	self:SetDTFloat( 0, 0 )
end


--================================ALT FIRE Section================================--
function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire( CurTime() + 1.45 )

    self:EmitSound( "artiwepsv2/nukecharge.mp3", 100, 150 + math.random(0, 10), nil, CHAN_STATIC )

    timer.Simple( 0.6, function()
        self:EmitSound( "artiwepsv2/nucleouse.mp3", 100, 110 + math.floor(math.random(0, 15)), nil, CHAN_STATIC )
        self:EmitSound( "artiwepsv2/nucleoshoot.mp3", 100, math.random(90, 110), nil, CHAN_STATIC )
        self:SpawnProjectile("sh_bulkball", self:GetOwner(), self:GetOwner():GetShootPos(), self:GetOwner():EyeAngles(), self:GetOwner():GetAimVector(), 1 )
    end)
end

--Custom Projectile Spawning Func
--Now updated to work for MANY projectiles at once.
function SWEP:SpawnProjectile( Entstring, Owner, Position, Angles, AimVec, VelBool )
	if CLIENT then return end
	local ent = ents.Create( Entstring )
	if ( not ent:IsValid() ) then return end

	ent:SetOwner( Owner )
	ent:SetPos( Position )
	ent:SetAngles( Angles )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	if VelBool == 1 then
		local Speed = 1000

		AimVec:Mul( Speed * entphys:GetMass() )
		entphys:ApplyForceCenter( AimVec )
	end
end
