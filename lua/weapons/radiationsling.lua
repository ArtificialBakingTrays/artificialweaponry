SWEP.PrintName = "Lethal Dose of Radiation"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Slingshot, but Pebbles of Uranium. Will bounce off of enemies, when it hits the floor: it will release mini pebbles that also do damage"
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/radsling_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel	= "models/weapons/c_pistol.mdl"
SWEP.WorldModel	= "models/weapons/w_pistol.mdl"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 1
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Force = 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:SetScoped( bool ) self:SetDTBool( 0, bool ) end
function SWEP:GetScoped() return self:GetDTBool( 0 ) end

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

	self:SetDTFloat( 0, CurTime() + 1.3 )
	self:SendWeaponAnim(ACT_VM_RELOAD)

	self:EmitSound( "tray_sounds/sling_reload.mp3", 75, 110, .7, 1 )
end

function SWEP:Think() --Help from zynx
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end

	if time > CurTime() then return end

	self:SetClip1( 8 )
	self:SetDTFloat( 0, 0 )
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	if self:Clip1() <= 0 then return end -- No Shoot
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )

	self:SetNextPrimaryFire( CurTime() + 0.45 )

	self:EmitSound( "tray_sounds/slingfire.mp3", 100, math.random( 100, 105 ), 1, 1 )
	--self:EmitSound( "tray_sounds/slingfire2.mp3", 100, math.random( 105, 110 ), 1, 6 )

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


function SWEP:SecondaryAttack()
	self:SetScoped( not self:GetScoped() )
	self:EmitSound("weapons/sniper/sniper_zoomin.wav", 75, math.random(95, 105), 100, 6 )
end


local slingreticle = Material( "vgui/hud/sling_reticle.png", "noclamp smooth" )
local color = Color(226, 255, 121, 255)
--Note to self. wait for fucking loka next time before trying rendering bullshit
function SWEP:DrawHUD()
	if self:GetScoped() then
	render.SetColorMaterialIgnoreZ()
	surface.SetMaterial( slingreticle )
	surface.SetDrawColor( color )
	local w = ScrW() / 2
	local h = ScrH() / 2

	local scale = 256
	local length = scale / 1.5

	surface.DrawTexturedRect(w - length / 2 + 5, h - scale / 2 + 30, length, scale)
	end
end
--Small crashout on my part- it wasnt even that hard in the end-

function SWEP:DoDrawCrosshair()
	return self:GetScoped() --Im so marvelous at coding
end