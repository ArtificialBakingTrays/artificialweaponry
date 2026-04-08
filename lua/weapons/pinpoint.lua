SWEP.PrintName = "PinPoint Detonator"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "A Heldheld Mortar, one far past its prime."
SWEP.IconOverride = "vgui/weaponvgui/pinpoint_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel	= "models/weapons/c_357.mdl"
SWEP.WorldModel	= "models/weapons/w_357.mdl"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 3
SWEP.BobScale = 1.15
SWEP.Category = "Artificial Weaponry"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "Battery"

local bannedLUT = {
	["CHudAmmo"]      = true,
	["CHudBattery"]	  = true,
}

function SWEP:HUDShouldDraw(element)
	if bannedLUT[element] then
		return false
	end
	return true
end

function SWEP:Reload() return end

function SWEP:DrawWorldModel( flags )
	render.SetColorModulation( 1, 0.267, 0)
		render.SuppressEngineLighting( true )
			self:DrawModel( flags )
		render.SuppressEngineLighting( false )
	render.SetColorModulation( 1, 1, 1 )
end

function SWEP:PreDrawViewModel( vm )
	render.SetColorModulation( 1, 0.267, 0) -- the glow
	render.SuppressEngineLighting( true ) -- disable lighting
end

function SWEP:PostDrawViewModel( _, _, ply )
	render.SuppressEngineLighting( false ) -- re enable lighting
	render.SetColorModulation( 1, 1, 1 ) -- reset the glow

	if IsValid( ply ) then ply:GetHands():DrawModel() end
end


function SWEP:PrimaryAttack()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetNextPrimaryFire( CurTime() + 0.325 )

	self:EmitSound( "weapons/mortar/mortar_fire1.wav", 75, math.random( 160, 170 ), 1, 1 )
	self:EmitSound( "artiwepsv2/rockblast.mp3", 75, math.random( 100, 110 ), 1, 6 )

	self:GetOwner():LagCompensation( true )

--striderbuster_explode_core
	self:SpawnPrimaryRock()

	self:GetOwner():LagCompensation( false )

end

function SWEP:SpawnPrimaryRock()
	if CLIENT then return end
	local ent = ents.Create( "lavarock_proj" )
	if ( not ent:IsValid() ) then return end

	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local ownereyes = owner:EyeAngles()
	local aimvec = owner:GetAimVector()

	ent:SetOwner( owner )
	ent:SetPos( ownerpos )
	ent:SetAngles( ownereyes + Angle( 90, 0, 0 ) )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	local Speed = 2000

	aimvec:Mul( Speed * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )
end

function SWEP:SpawnMortar()
	if CLIENT then return end
	local ent = ents.Create( "lavamortar_proj" )
	if ( not ent:IsValid() ) then return end

	local owner = self:GetOwner()
	local ownertr = owner:GetEyeTrace()
	local targetpos = ownertr.HitPos + Vector(0, 0, 600)

	ent:SetOwner( owner )
	ent:SetPos( targetpos )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end
end

function SWEP:SecondaryAttack()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetNextSecondaryFire( CurTime() + 2.5 )

	self:EmitSound( "artiwepsv2/splathit1.mp3", 75, math.random( 160, 170 ), 1, 1 )
	self:EmitSound( "weapons/mortar/mortar_fire1.wav", 75, math.random( 100, 110 ), 0.4, 6 )

	self:GetOwner():LagCompensation( true )

--striderbuster_explode_core
	self:SpawnMortar()

	self:GetOwner():LagCompensation( false )

end