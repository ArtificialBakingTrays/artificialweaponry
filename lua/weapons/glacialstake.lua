SWEP.PrintName = "Glacial Stake"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "An ice based grenade launcher, will cause you and enemies to bounce around the area of explosion, CAUTION: user may get ice splinters."
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/compacted_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.DrawCrosshair = false
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel	= "models/weapons/w_rocket_launcher.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "shotgun"
SWEP.Slot = 1
SWEP.BobScale = 1.15

local Ammo = 1

SWEP.Primary.ClipSize = Ammo
SWEP.Primary.DefaultClip = Ammo
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = 500

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

--Incase you havent realised at this point:
--the purpose of me doing this is to allow myself to use custom ammo.
--Allowing me to then make custom reload mechanics.
function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}
	self.AmmoDisplay.Draw = true
	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end
--To put it simply, its better than having to rely on the base gmod reload mechanics as I cant manipulate reload time that way.
--Easier for balancing.

function SWEP:Reload() --This reload mechanic is simply just a timer that does the funny animation, then after X amount of time: It sets the magasine size back to the maximum.
	if self:GetDTFloat( 0 ) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() == self.Primary.ClipSize then return end

	self:SetDTFloat(0, CurTime() + .7 )
	self:SendWeaponAnim( ACT_VM_RELOAD )

	self:EmitSound( "weapons/smg1/smg1_reload.wav", 75, 120, 70, 1 )
	self:EmitSound( "tray_sounds/reload_1.mp3", 75, 150, 70, 6 )
	--Its... quite easy actually (Especially when you have lovely GLUA coders helping you learn-)
end

function SWEP:Think() --Help from zynx
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end
	if time > CurTime() then return end

	self:SetClip1( 1 )
	self:SetDTFloat( 0, 0 )
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	--Not sure why ive been explaining how this code functions
	--Wouldve been more useful to do it on an earlier release weapon.
	if self:Clip1() <= 0 then return end -- No Shoot
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )
	--Probably will be entertaining for the code readers
	self:SetNextPrimaryFire( CurTime() + .2 )

	self:EmitSound( "weapons/alyx_gun/alyx_gun_fire3.wav", 100, math.random( 70, 85 ), 1, 1 )
	self:EmitSound( "tray_sounds/glacialchuck.mp3", 100, math.random( 70, 85 ), 1, 6 )

	owner:LagCompensation( true )
	self:SpawnProj()
	owner:LagCompensation( false )
--I will stop adding these nonsense comments now-
end

function SWEP:SpawnProj()
	if CLIENT then return end

	local ent = ents.Create( "stake_proj" )

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

	local Speed = 1000 * 1000

	aimvec:Mul( Speed * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )
end

local reticle = Material( "vgui/hud/stake_reticle.png", "noclamp smooth" )
local color = Color(255, 255, 255, 255)

function SWEP:DrawHUD()
	render.SetColorMaterialIgnoreZ()
	surface.SetMaterial( reticle )
	surface.SetDrawColor( color )
	local w = ScrW() / 2
	local h = ScrH() / 2

	local scale = 256
	local length = scale / 1.5

	surface.DrawTexturedRect(w - length / 2 + 5, h - scale / 2 + 70, length, scale / 2)
end