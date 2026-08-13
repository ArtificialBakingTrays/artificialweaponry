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
SWEP.Slot = 2
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

function SWEP:DrawBeam()
    if not self.BeamEndTime then return end
    if CurTime() > self.BeamEndTime then return end

    if not self.BeamStart or not self.BeamEnd then return end
    local timeLeft = self.BeamEndTime - CurTime()

    local alpha = math.Clamp(timeLeft / 0.1, 0, 1)

    render.SetMaterial(Material("sprites/physgbeamb"))

    render.DrawBeam( self.BeamStart, self.BeamEnd, 4 * alpha, 0, 1, Color(225, 255, 128, 255 * alpha) )
end

function SWEP:PrimaryAttack()
    if self.IsReloading then return end
    if self:Clip1() <= 0 then 
        self:EmitSound( "weapons/ar2/ar2_empty.wav", 100, 100, nil, CHAN_STATIC )
        self:EmitSound( "artiwepsv2/primebop.mp3", 100, 170, nil, CHAN_STATIC )
        self:SetNextPrimaryFire( CurTime() + 0.235 )
        return 
    end

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )
    self:SetNextPrimaryFire( CurTime() + 0.235 )

    local owner = self:GetOwner()

    if CLIENT then
        self:EmitSound( "tray_sounds/slingfire2.mp3", 100, 100, nil, CHAN_STATIC )
        self:EmitSound( "artiwepsv2/nucleoshoot.mp3", 100, 100, nil, CHAN_STATIC )

        local startPos = owner:GetShootPos()

        local vm = owner:GetViewModel()

        if IsValid(vm) then
            local attachment = vm:GetAttachment(1)
            if attachment then startPos = attachment.Pos end
        end

        local endPos = startPos + owner:GetAimVector() * 32768
        local boxSize = 12

        local tr = util.TraceHull({
            start = startPos,
            endpos = endPos,
            mins = Vector(-boxSize, -boxSize, -boxSize),
            maxs = Vector(boxSize, boxSize, boxSize),
            filter = owner
        })

        self.BeamStart = startPos
        self.BeamEnd = tr.HitPos

        self.BeamEndTime = CurTime() + 0.1

        return
    end

    self:GetOwner():LagCompensation( true )

        local startPos = owner:GetShootPos()
        local endPos = startPos + owner:GetAimVector() * 32768
    	local boxSize = 6
        local boxMins = Vector(-boxSize, -boxSize, -boxSize)
        local boxMaxs = Vector(boxSize , boxSize , boxSize )

        local tr = util.TraceHull({
            start = startPos,
            endpos = endPos,
            mins = boxMins,
            maxs = boxMaxs,
            filter = owner
        })

        debugoverlay.Box(tr.HitPos, boxMins, boxMaxs, 3, Color(0, 0, 255, 128))

        self:ProjectileHit(startPos, endPos)

        if IsValid(tr.Entity) and tr.Entity:IsPlayer() or tr.Entity:IsNPC() then 
            tr.Entity:TakeDamage(23, owner, self)

            local FxData = EffectData()
			FxData:SetOrigin( tr.Entity:GetPos() + Vector(0, 0, 40) )
			util.Effect("BloodImpact", FxData, true, true)
            
        	DEBUG_BOX_COLOUR = Color(0, 255, 30, 10)
        else
            DEBUG_BOX_COLOUR = Color(255, 0, 0, 10 )
            if tr.HitWorld then
                util.Decal( "BulletProof", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
            end
        end

    self:GetOwner():LagCompensation( false )
end

function SWEP:ProjectileHit(startPos, endPos)
    local closest
    local bestDist = 12

    for _, ent in ipairs(ents.FindByClass("sh_bulkball")) do
        local pos = ent:GetPos()
        local nearest = util.DistanceToLine(startPos, endPos, pos)

        debugoverlay.Box(pos, -Vector(6, 6, 6), Vector(6, 6, 6), 5, Color(0, 255, 0, 128))

        if nearest < bestDist then
            closest = ent
            bestDist = nearest
        end
    end
    if IsValid( closest ) then
        closest:TakeDamage( 1, self:GetOwner(), self )
        self:SetClip1( self:Clip1() + 5 )
        self:EmitSound("sparkbound/gun_unsheathe.mp3", 100, math.random(90, 110), 1, nil, CHAN_STATIC )
    end
end

function SWEP:Reload()
	if self:GetDTFloat( 0 ) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() >= self.Primary.ClipSize then return end
    self:EmitSound( "tray_sounds/sling_reload.mp3", 100, 100, 1, nil )

    self.IsReloading = true

    self:SetNextPrimaryFire( 1.6 )
    self:SetNextSecondaryFire( 1.4 )

	self:SetDTFloat( 0, CurTime() + 1.2 )
	self:SendWeaponAnim(ACT_VM_RELOAD)
end

function SWEP:Think() --This like fuckass prediction for timers is so like cooked- how the fuck did zynx figure this out?
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end

	if time > CurTime() then return end

	self:SetClip1( self:GetMaxClip1() )
	self:SetDTFloat( 0, 0 )
    self.IsReloading = false 
end


--================================ALT FIRE Section================================--
function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire( CurTime() + 1.45 )
    self:SetNextPrimaryFire( CurTime() + 0.95 )
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

    self:EmitSound( "weapons/ar2/ar2_empty.wav", 100, 110 + math.floor(math.random(0, 15)), nil, CHAN_STATIC )
    self:EmitSound( "artiwepsv2/nukecharge.mp3", 100, 150 + math.random(0, 10), nil, CHAN_STATIC )

    timer.Simple( 0.6, function()
        self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
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

if CLIENT then
    hook.Add("PostDrawTranslucentRenderables", "SWEPBeam", function()
        if not IsValid(LocalPlayer()) then return end
        local wep = LocalPlayer():GetActiveWeapon()
        if not IsValid(wep) then return end
        if wep:GetClass() ~= "art_nucleonic" then return end
        wep:DrawBeam()
    end)
end