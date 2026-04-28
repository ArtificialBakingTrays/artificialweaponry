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
	["CHudCrosshair"]	= true,
}
--Removing certain Hud Elements
function SWEP:HUDShouldDraw(element)
	if bannedLUT[element] then
		return false
	end
	return true
end

function SWEP:Reload() return end

--zynx color modulation code
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


--==============Divider==============--


function SWEP:PrimaryAttack()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetNextPrimaryFire( CurTime() + 0.325 )

	self:EmitSound( "weapons/mortar/mortar_fire1.wav", 75, math.random( 160, 170 ), 1, 1 )
	self:EmitSound( "artiwepsv2/rockblast.mp3", 75, math.random( 100, 110 ), 1, 6 )

	self:GetOwner():LagCompensation( true )

	local ownerpos = self:GetOwner():GetShootPos()
	local ownereyes = self:GetOwner():EyeAngles()
	local ownaimvec = self:GetOwner():GetAimVector()
	self:SpawnProjectile( "lavarock_proj", self:GetOwner(), ownerpos, ownereyes + Angle( 90, 0, 0 ), ownaimvec, 1 )

	self:GetOwner():LagCompensation( false )

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
		local Speed = 2000

		AimVec:Mul( Speed * entphys:GetMass() )
		entphys:ApplyForceCenter( AimVec )
	end
end


function SWEP:SecondaryAttack()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetNextSecondaryFire( CurTime() + 2.5 )

	Alpha = 0

	timer.Simple( self:GetNextSecondaryFire(), function()
		Alpha = 255
	end)

	self:EmitSound( "artiwepsv2/splathit1.mp3", 75, math.random( 160, 170 ), 1, 1 )
	self:EmitSound( "weapons/mortar/mortar_fire1.wav", 75, math.random( 100, 110 ), 0.4, 6 )

	self:GetOwner():LagCompensation( true )

	local ownertr = self:GetOwner():GetEyeTrace()
	local targetpos = ownertr.HitPos + Vector(0, 0, 600)
	self:SpawnProjectile( "lavamortar_proj", self:GetOwner(), targetpos, Angle(0,0,0), _, 0 )

	self:GetOwner():LagCompensation( false )

end


--==============Divider==============--


function SWEP:DrawHUD()
	if CLIENT then
		render.SetColorMaterialIgnoreZ()
		surface.SetMaterial( Material( "vgui/hud/lavamortar.png", "noclamp smooth" ) )
		surface.SetDrawColor( Color( 255, 143, 109) )
		local w = ScrW() / 2
		local h = ScrH() / 2
		local scale = 256
		local length = scale / 1.5
		surface.DrawTexturedRect( w - length / 2, h - scale / 2 + 50, length, scale * .5 )

		surface.SetMaterial( Material( "vgui/hud/lavamortar2.png", "noclamp smooth" ) )
		surface.SetDrawColor( Color( 255, 192, 90 ) )
		surface.DrawTexturedRect( w - length / 2, h - scale / 2 + 50, length, scale * .5 )
	end
end

function SWEP:DoDrawCrosshair() return false end