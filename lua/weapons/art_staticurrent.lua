SWEP.PrintName = "Staticurrent"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Chain Reaction M1 Projectile, Alt Fire to become a Staticurrent Orb"
SWEP.Category = GetWeaponPack()
SWEP.IconOverride = "vgui/weaponvgui/staticurrent_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = true
SWEP.ViewModel	= "models/weapons/c_357.mdl"
SWEP.WorldModel	= "models/weapons/w_357.mdl"
SWEP.DrawAmmo = true
SWEP.AccurateCrosshair = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 2
SWEP.BobScale = 1.15

local maxClip = 9

SWEP.Primary.ClipSize = maxClip
SWEP.Primary.DefaultClip = maxClip
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = nil

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

-- this is neccessary so that the hands dont glow aswell
SWEP.UseHands = false

function SWEP:DrawWorldModel( flags )
	render.SetColorModulation( 10, 10, 0 )
		render.SuppressEngineLighting( true )
			self:DrawModel( flags )
		render.SuppressEngineLighting( false )
	render.SetColorModulation( 10, 10, 0 )
end

function SWEP:PreDrawViewModel( vm )
	render.SetColorModulation( 10, 10, 0 ) -- the glow
	render.SuppressEngineLighting( true ) -- disable lighting
end

function SWEP:PostDrawViewModel( _, _, ply )
	render.SuppressEngineLighting( false ) -- re enable lighting
	render.SetColorModulation( 1, 1, 1 ) -- reset the glow
	if IsValid( ply ) then ply:GetHands():DrawModel() end
end


--======================================Actual Gun Code Here======================================--


function SWEP:PrimaryAttack()
	if self:Clip1() == 0 then return end
	self:SetNextPrimaryFire( CurTime() + 0.125 )
	self:TakePrimaryAmmo( 1 )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	ArtiwepsProjectile( "sh_electroball", self:GetOwner(), self:GetOwner():GetShootPos(), self:GetOwner():EyeAngles() + Angle( 90, 0, 0 ), self:GetOwner():GetAimVector(), 4000, 0, false )

	self:EmitSound( "artiwepsv3/staticfire2.mp3", 100, math.random( 95, 105 ) + (self:Clip1() * 10), 0.4, 1 )
	self:EmitSound( "artiwepsv3/staticfire.mp3", 100, math.random( 105, 115 ) + (self:Clip1() * 10), 0.4, 6 )
end


function SWEP:Reload()
	if self:GetDTFloat( 0 ) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() >= self:GetMaxClip1() then return end
	self.isReloading = true
	self:SetNextPrimaryFire( CurTime() + 1.56 )

	self:EmitSound( "tray_sounds/reload_1.mp3", 100, 105, 1, nil )
	self:EmitSound( "artiwepsv2/usesfx.wav", 100, 105, 1, 6 )

	self:SetDTFloat(0, CurTime() + .7 )
	self:SendWeaponAnim( ACT_VM_RELOAD )

	timer.Simple( 0.7, function()
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end)
end

function SWEP:Think()
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end
	if time > CurTime() then return end

	self:SetClip1( self:GetMaxClip1() )
	self:SetDTFloat( 0, 0 )
	self.isReloading = false
end