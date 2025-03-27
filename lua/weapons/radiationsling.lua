SWEP.PrintName = "Lethal Dose of Radiation"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Slingshot, but Pebbles of Uranium"
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/radsling_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = false
SWEP.ViewModel	= "models/weapons/c_pistol.mdl"
SWEP.WorldModel	= "models/weapons/c_pistol.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 1
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Force = 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end

function SWEP:Reload()
	if self:GetDTFloat( 0 ) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() == self.Primary.ClipSize then return end

	self:SetDTFloat( 0, CurTime() + 1.2 )
	self:SendWeaponAnim(ACT_VM_RELOAD)

	self:EmitSound( "tray_sounds/sling_reload.mp3", 75, 110, .7, 1 )
end

function SWEP:Think() --Help from zynx
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end

	if time > CurTime() then return end

	self:SetClip1( 6 )
	self:SetDTFloat( 0, 0 )
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	if self:Clip1() <= 0 then return end -- No Shoot
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )

	local delay = 0.45
	self:SetNextPrimaryFire( CurTime() + delay )

	self:EmitSound( "tray_sounds/slingfire.mp3", 100, math.random( 100, 105 ), 1, 1 )
	self:EmitSound( "tray_sounds/slingfire2.mp3", 100, math.random( 105, 110 ), 1, 6 )

	owner:LagCompensation( true )

	self:SpawnProj()

	owner:LagCompensation( false )
end

function SWEP:SpawnProj()
	if CLIENT then return end

	local ent = ents.Create( "rad_proj" )

	if ( not ent:IsValid() ) then return end

	--yknow its bad when we have the CUBE OF VARIABLES
	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local ownereyes = owner:EyeAngles()
	local aimvec = owner:GetAimVector()

	ent:SetPos( ownerpos + Vector(0, 0, -5) )
	ent:SetAngles( ownereyes + Angle(90,0,0) )
	ent:SetOwner( owner )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	aimvec:Mul( 3500 * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )

end

local slingreticle = Material( "vgui/hud/sling_reticle.png", "noclamp smooth" )
local color = Color(226, 255, 121, 114)
--Note to self. wait for fucking loka next time before trying rendering bullshit
function SWEP:DrawHUD()
	render.SetColorMaterialIgnoreZ()
	surface.SetMaterial( slingreticle )
	surface.SetDrawColor( color )
	local w = ScrW() / 2
	local h = ScrH() / 2

	local scale = 256
	local length = scale / 1.5

	surface.DrawTexturedRectRotated(w + 5, h + 30, length, scale, 0)
end
--Small crashout on my part- it wasnt even that hard in the end-