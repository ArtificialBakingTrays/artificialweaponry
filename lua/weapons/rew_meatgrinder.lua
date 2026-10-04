SWEP.PrintName = "(Rewritten) Meatgrinder"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Groovy"
SWEP.Category = GetWeaponPack()
SWEP.IconOverride = "vgui/weaponvgui/meatgrind_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = false
SWEP.ViewModel	= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel	= "models/weapons/w_crowbar.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 1
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
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

	return true
end

function SWEP:Holster()
	if CLIENT then return true end
	self.isEquipped = false

	self:GetOwner():SetRunSpeed( 400 )

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
	local Pitch
	local Dmg
	local Speed

	if self:CheckEnabled() then
		Pitch = 20
		Dmg = 17
		Speed = -0.15
	else
		Pitch = 0
		Dmg = 13
		Speed = 0
	end

	self:SetNextPrimaryFire( CurTime() + 0.45 + Speed)
	self:SendWeaponAnim( ACT_VM_HITCENTER )

	local random = math.random(math.random( 1, 3 ))

	local sndEntry = sndLUT[random]
	local sndFile = sndEntry.snd
	self:EmitSound( sndFile, 100, math.random( sndEntry.pitchMin + Pitch, sndEntry.pitchMax ), 0.3, CHAN_STATIC )
	self:DoTrace( Dmg )
end

local DEBUG_BOX_COLOUR = Color(255, 0, 0, 10) -- transparent!
function SWEP:DoTrace( damage )
	if CLIENT then return end
	local boxSize = 24
	local boxMins = Vector(-boxSize, -boxSize, -boxSize)
	local boxMaxs = Vector(boxSize , boxSize , boxSize )
	local ownerthing = self:GetOwner()

	ownerthing:LagCompensation( true )

	local tr = util.TraceHull({
	  start = ownerthing:GetShootPos() + ( ownerthing:GetAimVector() * 10 ),
	  endpos = ownerthing:GetShootPos() + ( ownerthing:GetAimVector() * 70 ),
	  mins = boxMins,
	  maxs = boxMaxs,
	  filter = self:GetOwner(), ent.IsTraysProjectile, game.GetWorld() -- assuming you're doing this in a swep hook, make sure the owner can't hit itself
	})

	ownerthing:LagCompensation( false )

	if tr.Entity:IsValid() and tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
		local trEnt = tr.Entity
		DEBUG_BOX_COLOUR = Color(0, 255, 30, 10)

		trEnt:TakeDamage( damage + math.random(15, 30), self:GetOwner(), self )
		if self:CheckEnabled() == true then trEnt:Ignite(2, 0) end
		StatusBleed( 3, self:GetOwner(), trEnt )

		if self:Clip1() >= self:GetMaxClip1() then self:SetClip1( 3 )
		else self:SetClip1( self:Clip1() + 1 ) end

		util.ScreenShake(
			self:GetPos(),
			15,    -- Intensity
			10,   -- Frequency
			0.2,  -- Duration
			200   -- Radius
		)
	else
		DEBUG_BOX_COLOUR = Color(255, 0, 0, 10 )
	end

	local lifetime = 3 -- debug boxes last 8s
	debugoverlay.Box( tr.HitPos, boxMins, boxMaxs, lifetime, DEBUG_BOX_COLOUR )
end

--==================SECONDARY FIRE STUFF==================--

local offsetSpread = 0.1
local offsetLUT = {
	[1] = Vector(-offsetSpread, 0), -- left
	[2] = Vector(            0, 0), -- center
	[3] = Vector( offsetSpread, 0), -- right
}

function SWEP:SecondaryAttack()
	if self:Clip1() == 0 then return end
	self:TakePrimaryAmmo( 1 )

	self:EmitSound( "artiwepsv2/usesfx.wav", 100, math.random(85, 95), 0.5, 1 )
	self:EmitSound( "artiwepsv2/splathit1.mp3", 100, math.random(85, 95), 0.5, 6 )

	self:GetOwner():LagCompensation( true )

	local aimDir = self:GetOwner():GetAimVector()
	local aimDirAng = aimDir:Angle()
	local aimRight = aimDirAng:Right()
	local aimUp = aimDirAng:Up()

	local own = self:GetOwner()

	local realShootDir = Vector()
	for i = 1, #offsetLUT do
		local shootDir = offsetLUT[i]
		realShootDir:Set(aimDir)

		local offX = shootDir[1]
		local offY = shootDir[2]

		realShootDir = realShootDir + (aimRight * offX) + (aimUp * offY)
		realShootDir:Normalize()

		ArtiwepsProjectile("sh_gibbler", own, own:GetShootPos(), own:EyeAngles(), realShootDir, 950, true)
	end

	self:GetOwner():LagCompensation( false )
end

--zynx color modulation code
function SWEP:DrawWorldModel( flags )
	render.SetColorModulation( 10, 0, 2)
		render.SuppressEngineLighting( true )
			self:DrawModel( flags )
		render.SuppressEngineLighting( false )
	render.SetColorModulation( 1, 1, 1 )
end

function SWEP:PreDrawViewModel( vm )
	render.SetColorModulation( 10, 0, 2) -- the glow
	render.SuppressEngineLighting( true ) -- disable lighting
end

function SWEP:PostDrawViewModel( _, _, ply )
	render.SuppressEngineLighting( false ) -- re enable lighting
	render.SetColorModulation( 1, 1, 1 ) -- reset the glow

	if IsValid( ply ) then ply:GetHands():DrawModel() end
end


--==================RELOAD MECHANIC STUFF==================--

function SWEP:Reload()
	if self:Clip1() == 3 then
		if self:CheckEnabled() == true then return end
		self:SetClip1( 0 )
		self.ModeActive = true
		self:EmitSound("tray_sounds/chargebegin.mp3", 100, 100, 1, CHAN_AUTO)

		self:GetOwner():SetRunSpeed( 520 )

		timer.Simple(5, function()
			self.ModeActive = false
		end)
	end
end

function SWEP:CheckEnabled()
	if not IsValid(self) then return end
	return self.ModeActive
end