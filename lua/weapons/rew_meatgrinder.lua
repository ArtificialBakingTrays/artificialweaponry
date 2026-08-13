SWEP.PrintName = "(Rewritten) Meatgrinder"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Groovy"
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/meatgrind_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.DrawCrosshair = false
SWEP.ViewModel	= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel	= "models/weapons/w_crowbar.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 1
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = 500

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"
--They say my hungers a problem.

function SWEP:Deploy() --Features Lokacode cus 3 line if statements
	self:EmitSound( "artiwepsv2/chainstartup.mp3", 100, math.random( 105, 115 ), 0.4, 1 )
	self:SetClip1(0)
	self.AmmoLoseTime = CurTime()
	self.isEquipped = true


	timer.Simple(0.6, function()
		if not self.isEquipped then
			return
		end

		self:EmitSound( "artiwepsv2/chainstartup.mp3", 100, math.random( 115, 120 ), 0.4, 6 )
	end)

	timer.Simple(1.3, function()
		if not self.isEquipped then
			return
		end

		self.proccySound = CreateSound(self, "artiwepsv2/chainsawbrr-longfix-loop.wav")
		self.proccySound:PlayEx(0.3, 100)
	end)
end

function SWEP:Holster()
	if CLIENT then return end
	self.isEquipped = false

	if self.proccySound then
		self.proccySound:Stop()
		self.proccySound = nil
	end
	return true
end

local sndLUT = {
	[1] = {
		snd = "artiwepsv2/meatgrind1.mp3",
		pitchMin = 100,
		pitchMax = 115
	},
	[2] = {
		snd = "artiwepsv2/meatgrind2.mp3",
		pitchMin = 100,
		pitchMax = 115
	},
	[3] = {
		snd = "artiwepsv2/meatgrind3.mp3",
		pitchMin = 100,
		pitchMax = 115
	},
}

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + 0.45 )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	local random = math.random(math.random( 1, 3 ))

	local sndEntry = sndLUT[random]
	local sndFile = sndEntry.snd
	self:EmitSound( sndFile, 100, math.random( sndEntry.pitchMin, sndEntry.pitchMax ), 0.3, CHAN_STATIC )
end


--==================SECONDARY FIRE STUFF==================--


local offsetSpread = 0.1
local offsetLUT = {
	[1] = Vector(-offsetSpread, 0), -- left
	[2] = Vector(            0, 0), -- center
	[3] = Vector( offsetSpread, 0), -- right
}

function SWEP:SecondaryAttack()
	--Distraction/Projectile attack
	self:SetNextSecondaryFire( CurTime() + 1.7 )

	self:EmitSound( "artiwepsv2/usesfx.wav", 100, math.random(85, 95), 1, 1 )
	self:EmitSound( "artiwepsv2/splathit1.mp3", 100, math.random(85, 95), 1, 6 )
	--artiwepsv2/splathit1.mp3

	self:GetOwner():LagCompensation( true )

	local aimDir = self:GetOwner():GetAimVector()
	local aimDirAng = aimDir:Angle()
	local aimRight = aimDirAng:Right()
	local aimUp = aimDirAng:Up()

	local realShootDir = Vector()
	for i = 1, #offsetLUT do
		local shootDir = offsetLUT[i]
		realShootDir:Set(aimDir)

		local offX = shootDir[1]
		local offY = shootDir[2]

		realShootDir = realShootDir + (aimRight * offX) + (aimUp * offY)
		realShootDir:Normalize()

		--Hehe idk what im doing
		self:SpawnGibblers(realShootDir)
	end

	self:GetOwner():LagCompensation( false )
end

function SWEP:SpawnGibblers(targetDir)
	if CLIENT then return end

	local ent = ents.Create( "gibbler_proj" )

	if ( not ent:IsValid() ) then return end

	--yknow its bad when we have the CUBE OF VARIABLES
	local ownerpos = self:GetOwner():GetShootPos()
	local ownereyes = self:GetOwner():EyeAngles()

	ent:SetOwner( self:GetOwner() )
	ent:SetPos( ownerpos + Vector(0, 0, -5) )
	ent:SetAngles( ownereyes + Angle(90,0,0) )
	ent:Spawn()


	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	local Speed = 950
	targetDir:Mul( Speed * entphys:GetMass() )
	entphys:ApplyForceCenter( targetDir )
end