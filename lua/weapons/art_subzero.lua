SWEP.PrintName = "Subzero Standard"
SWEP.Author			= "ArtiBakingTrays" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu
SWEP.Contact 		= "ArtificialBakingTrays"
SWEP.Instructions	= "Standard Issue technology, Fires in a Tricorn Spread. Every 3rd Shot will be an icy micro missile,. "
SWEP.Category 		= "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/compacted_generi.png"

SWEP.ViewModel	= "models/weapons/c_smg1.mdl"
SWEP.WorldModel	= "models/weapons/w_smg1.mdl"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = true
SWEP.DrawHUD = false
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 3

SWEP.Primary.ClipSize = 36
SWEP.Primary.DefaultClip = 36
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "Battery"

local offsetSpread = 0.02
local offsetLUT = {
	[1] = Vector(-offsetSpread, offsetSpread ),
	[2] = Vector( offsetSpread, offsetSpread ),
	[3] = Vector( 0			  , 0			 ),
	[4] = Vector( 0			  , -offsetSpread),
}

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end
	self:TakePrimaryAmmo( 1 )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetNextPrimaryFire( CurTime() + 0.145 )

	self:SetClip2( self:Clip2() + 1 )

	local owner = self:GetOwner()

	owner:LagCompensation( true )
		if self:Clip2() <= 3 then
			self:EmitSound( "sparkbound/shoot.mp3", 100, math.random( 105, 115 ), 100, 6 ) --PLEASE CHANGE THESE SOUNDS
			self:EmitSound( "artiwepsv2/blast1concept.mp3", 100, math.random( 95, 105 ), 100, 6 )

			local aimDir = self:GetOwner():GetAimVector()
			local aimDirAng = aimDir:Angle()
			local aimRight = aimDirAng:Right()
			local aimUp = aimDirAng:Up()
			local realShootDir = Vector()

			for i = 1, #offsetLUT do
				local entry = offsetLUT[i] * 1
				realShootDir:Set(aimDir)

				local offX = entry[1]
				local offY = entry[2]

				realShootDir = realShootDir + (aimRight * offX) + (aimUp * offY)
				realShootDir:Normalize()

				owner:FireBullets({ 
					Src = owner:GetShootPos(),
					Dir = realShootDir,
					Damage = 6,
	--				Num = 1,
					Spread = Vector(0.0, 0.0),
					Attacker = owner,
					Inflictor = self,
					Force = 0
				 })
			end
		end
		
		if self:Clip2() == 4 then
			self:SetClip2( 0 )
			self:EmitSound( "artiwepsv2/secondaryfire01.mp3", 100, math.random( 105, 115 ), 100, 6 ) --PLEASE CHANGE THESE SOUNDS
			self:EmitSound( "sparkbound/crystal_proc.mp3", 100, math.random( 95, 105 ), 100, 6 )

			--SpawnProjectile( Entstring, Owner, Position, Angles, AimVec, VelBool )
			self:SpawnProjectile( "icerock_proj", self:GetOwner(), owner:GetShootPos(), owner:EyeAngles() + Angle( 90, 0, 0 ), owner:GetAimVector(), 1, False )
		end

	owner:LagCompensation( false )
end

function SWEP:SecondaryAttack()
	if self:Clip2() < 3 then return end
	self:SetClip2( 0 )
	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )

	
end

function SWEP:Reload()
	if self:GetDTFloat( 0 ) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() == self.Primary.ClipSize then return end

	self:SetDTFloat( 0, CurTime() + 1.2 )
	self:SendWeaponAnim(ACT_VM_RELOAD)
end

function SWEP:Think()
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end

	if time > CurTime() then return end

	self:SetClip2( 0 )
	self:SetClip1( 36 )
	self:SetDTFloat( 0, 0 )
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end

function SWEP:SpawnProjectile( Entstring, Owner, Position, Angles, AimVec, VelBool, Gravity)
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
		local Speed = 3000

		AimVec:Mul( Speed * entphys:GetMass() )
		entphys:ApplyForceCenter( AimVec )
	end
end

function SWEP:DrawHUD()
	local h = ScrH()
	local w = ScrW()
	local RectSize = 100
	local RectSizeHalf = RectSize / 2
	local Speed = 100


	draw.SimpleText("Ammo1: " .. self:Clip1(), "HudDefault", w * .555, h * .45, Color(255, 255, 255) )
	draw.SimpleText("Ammo2: " .. self:Clip2(), "HudDefault", w * .555, h * .425, Color(255, 255, 255) )

	local dist = LocalPlayer():GetEyeTrace().Fraction * 32768
	draw.SimpleText("Distance: " .. math.floor(dist), "HudDefault", w * .555, h * .475, Color(255, 255, 255) )

end

SWEP.UseHands = false

function SWEP:DrawWorldModel( flags )
	render.SetColorModulation( 0.43, 0.48, 1 )
		render.SuppressEngineLighting( true )
			self:DrawModel( flags )
		render.SuppressEngineLighting( false )
	render.SetColorModulation( 1, 1, 1 )
end

function SWEP:PreDrawViewModel( vm )
	render.SetColorModulation( 0.43, 0.48, 1  ) -- the glow
	render.SuppressEngineLighting( true ) -- disable lighting
end

function SWEP:PostDrawViewModel( _, _, ply )
	render.SuppressEngineLighting( false ) -- re enable lighting
	render.SetColorModulation( 1, 1, 1 ) -- reset the glow

	if IsValid( ply ) then ply:GetHands():DrawModel() end
end