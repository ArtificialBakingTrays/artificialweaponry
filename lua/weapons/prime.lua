SWEP.PrintName = "ITHINKTHEREFOREIAM"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "COGITOERGOSUM."
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/primed_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = true
SWEP.ViewModel	= "models/weapons/c_crossbow.mdl"
SWEP.WorldModel	= "models/weapons/w_crossbow.mdl"
SWEP.DrawAmmo = true
SWEP.AccurateCrosshair = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 3
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = 160

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.UseHands = false

function SWEP:DrawWorldModel( flags )
	render.SetColorModulation( 30, 0, 1)
		render.SuppressEngineLighting( true )
			self:DrawModel( flags )
		render.SuppressEngineLighting( false )
	render.SetColorModulation( 1, 1, 1 )
end

function SWEP:PreDrawViewModel( vm )
	render.SetColorModulation( 30, 0, 1 ) -- the glow
	render.SuppressEngineLighting( true ) -- disable lighting
end

function SWEP:PostDrawViewModel( _, _, ply )
	render.SuppressEngineLighting( false ) -- re enable lighting
	render.SetColorModulation( 1, 1, 1 ) -- reset the glow

	if IsValid( ply ) then ply:GetHands():DrawModel() end
end

--Custom Projectile Spawning Func
--Now updated to work for MANY projectiles at once.
function SWEP:SpawnProjectile( Entstring, Owner, Position, Angles, AimVec, VelBool, Gravity )
	if CLIENT then return end
	local ent = ents.Create( Entstring )
	if ( not ent:IsValid() ) then return end

	ent:SetOwner( Owner )
	ent:SetPos( Position )
	ent:SetAngles( Angles )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

    entphys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
	entphys:EnableGravity( Gravity )

	if ( not entphys:IsValid() ) then ent:Remove() return end

	if VelBool == 1 then
		local Speed = 2000

		AimVec:Mul( Speed * entphys:GetMass() )
		entphys:ApplyForceCenter( AimVec )
	end
end

function SWEP:Reload()
	if self:GetDTFloat(0) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() == self.Primary.ClipSize then return end
    self:EmitSound( "artiwepsv2/cooling.mp3", 100, math.random(105, 115), 0.7, 1 )

	self:SetDTFloat( 0, CurTime() + 1.2 )
	self:SendWeaponAnim(ACT_VM_RELOAD)
end

function SWEP:Think() --This like fuckass prediction for timers is so like cooked- how the fuck did zynx figure this out?
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end

	if time > CurTime() then return end

	self:SetClip1( 50 )
	self:SetDTFloat( 0, 0 )
	self:SetClip2( 0 )
end

function SWEP:PrimaryAttack()
    if self:Clip1() == 0 then return end
    self:TakePrimaryAmmo( 1 )
    self:SetNextPrimaryFire( CurTime() + 0.055)
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

    --SpawnProjectile( Entstring, Owner, Position, Angles, AimVec, VelBool )
	self:SpawnProjectile( "primepellete", self:GetOwner(), self:GetOwner():GetShootPos(), self:GetOwner():EyeAngles() + Angle( 90, 0, 0 ), self:GetOwner():GetAimVector(), 1, True )

    self:EmitSound( "artiwepsv2/primebop.mp3", 100, 110, 0.7, 1 )
	self:EmitSound( "artiwepsv2/primebop2.mp3", 100, 110, 0.7, 6 )
end