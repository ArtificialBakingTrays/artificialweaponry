SWEP.PrintName = "Meatgrinder"
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

local bannedLUT = {
	["CHudHealth"]    = true,
	["CHudAmmo"]      = true,
	["CHudCrosshair"] = true,
	["CHudBattery"]	  = true,
}

function SWEP:HUDShouldDraw(element)
	if bannedLUT[element] then
		return false
	end
	return true
end

function SWEP:PrimaryAttack()
	if self:GetOwner():WaterLevel() > 0 then return end

	--Chainsaw attack, will not need ammo
	self:SetNextPrimaryFire( CurTime() + 1.685 )
	self:EmitSound( "artiwepsv2/chainsawrev.mp3", 100, 100, 100, 6 )

	self:GetOwner():LagCompensation( true )

	local Num = 0.05
	Num = 0.05
	for i = 1, 12 do
		Num = Num + 0.05
		timer.Simple( Num, function()
			self:DoTrace()
		end)
	end

	self:GetOwner():LagCompensation( false )
end

local DEBUG_BOX_COLOUR = Color(255, 0, 0, 10) -- transparent!
function SWEP:DoTrace()
	if CLIENT then return end
	local boxSize = 24
	local boxMins = Vector(-boxSize, -boxSize, -boxSize)
	local boxMaxs = Vector(boxSize , boxSize , boxSize )
	local ownerthing = self:GetOwner()

	local tr = util.TraceHull({
	  start = ownerthing:GetShootPos() + ( ownerthing:GetAimVector() * 10 ),
	  endpos = ownerthing:GetShootPos() + ( ownerthing:GetAimVector() * 70 ),
	  mins = boxMins,
	  maxs = boxMaxs,
	  filter = self:GetOwner(), IsTraysProjectile -- assuming you're doing this in a swep hook, make sure the owner can't hit itself
	})

	if tr.Entity:IsValid() and tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
		local trEnt = tr.Entity
		DEBUG_BOX_COLOUR = Color(0, 255, 30, 10)

		trEnt:TakeDamage( 6, self:GetOwner(), self )
		StatusBleed( 3, self:GetOwner(), trEnt )
	else
		DEBUG_BOX_COLOUR = Color(255, 0, 0, 10 )
	end

	local lifetime = 8 -- debug boxes last 8s
	debugoverlay.Box( tr.HitPos, boxMins, boxMaxs, lifetime, DEBUG_BOX_COLOUR )
end

local offsetSpread = 0.1
local offsetLUT = {
	[1] = Vector(-offsetSpread, 0), -- left
	[2] = Vector(            0, 0), -- center
	[3] = Vector( offsetSpread, 0), -- right
}

function SWEP:SecondaryAttack()
	--Distraction/Projectile attack
	self:SetNextSecondaryFire( CurTime() + 1.2 )

	self:EmitSound( "artiwepsv2/usesfx.wav", 75, math.random(85, 95), 0.3, 1 )

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

	local ent = ents.Create( "gibbler" )

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

function SWEP:Reload()
	--charge up attack
	if self:GetOwner():IsSprinting() then return end
	self.DoChargeUp = true
end

function SWEP:Deploy() --Features Lokacode cus 3 line if statements
	self:EmitSound( "artiwepsv2/chainstartup.mp3", 100, math.random( 95, 105 ), 0.4, 1 )
	self:SetClip1(0)
	self.AmmoLoseTime = CurTime()
	self.isEquipped = true


	timer.Simple(1, function()
		if not self.isEquipped then
			return
		end

		self:EmitSound( "artiwepsv2/chainstartup.mp3", 100, math.random( 105, 115 ), 0.4, 6 )
	end)

	timer.Simple(2, function()
		if not self.isEquipped then
			return
		end

		self.proccySound = CreateSound(self, "artiwepsv2/chainsawbrr-longfix-loop.wav")
		self.proccySound:PlayEx(0.3, 100)
	end)
end

function SWEP:Holster()
	if CLIENT then
		return
	end
	self.isEquipped = false

	if self.proccySound then
		self.proccySound:Stop()
		self.proccySound = nil
	end

	return true
end

function SWEP:TakeAmmoThink()
	if self.DoChargeUp then
		self.AmmoLoseTime = CurTime()
		return
	end

	local pTime = self.AmmoLoseTime or CurTime()
	local cTime = CurTime()

	local secWaitToLoseOneAmmo = 0.05
	if (cTime - pTime) < secWaitToLoseOneAmmo then
		return
	end
	self.AmmoLoseTime = CurTime()

	-- take away ammo
	self:SetClip1( math.max(self:Clip1() - 1, 0) )
end

function SWEP:ChargeUpThink()
	if not self.DoChargeUp then
		return
	end

	local keyReload = self:GetOwner():KeyDown(IN_RELOAD)
	if not keyReload then
		self.DoChargeUp = false
	end

	if (self.NextAmmoGive or 0) > CurTime() then
		return
	end
	self.NextAmmoGive = CurTime() + .05
	self:EmitSound( "other/use.mp3", 75, 100 + self:Clip1(), 0.3, 1 )

	self:GetOwner():LagCompensation(true)
	self:SetClip1( math.min( self:Clip1() + 2, 100) )
	self:GetOwner():LagCompensation(false)
end

function SWEP:Think()
	if CLIENT then return end
	self:TakeAmmoThink()
	self:ChargeUpThink()
	self:GetOwner():SetRunSpeed( 400 + ( self:Clip1() * 3 ))
end

function SWEP:Holster()
	self:GetOwner():SetRunSpeed( 400 )
end

--[artificialweaponry] addons/artificialweaponry/lua/weapons/meatgrinder.lua:189: attempt to index global 'surface' (a nil value)
--1. unknown - addons/artificialweaponry/lua/weapons/meatgrinder.lua:189 (x5)

if CLIENT then
	surface.CreateFont( "CadaverYummy", {
		font = "CloseCaption_Bold",
		extended = false,
		size = 150,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})

	surface.CreateFont("CadaverYummy2", {
		font = "CloseCaption_Bold",
		extended = false,
		size = 40,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})
end

local reticle = Material( "vgui/hud/hudbloodleft.png", "noclamp smooth" )
local color = Color(186, 186, 186)


local matGibblerSkull = Material("vgui/hud/gibblerskull.png")
local skullW, skullH = matGibblerSkull:Width(), matGibblerSkull:Height()


local saw1 = Material("vgui/hud/chainsaw1.png")
local saw2 = Material("vgui/hud/chainsaw2.png")
function SWEP:DrawHUD()
	render.SetColorMaterialIgnoreZ()
	surface.SetMaterial( reticle )
	surface.SetDrawColor( color )
	local w = ScrW() / 2
	local h = ScrH() / 2

	local realH = ScrH()

	local scale = 256
	local length = scale / 1.5

	surface.DrawTexturedRect(w - length / 2 - 360 * 4, h - scale / 2 + 90,  length * 8, scale * 3)

	local healthStr = tostring(self:GetOwner():Health())
	local armourStr = tostring(self:GetOwner():Armor())

	draw.SimpleText(healthStr, "CadaverYummy", 256 + 64 + 32, h * 1.75, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	draw.SimpleText("|", "CadaverYummy", 256 + 64 + 32 + 64, h * 1.75, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	draw.SimpleText(armourStr, "CadaverYummy", 256 + 64 + 32 + 64 + 16, h * 1.75, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	for i = 1, 3 do
		local deltaMove = (i - 1) / 2

		--Rendering the Skull
		surface.SetMaterial( matGibblerSkull )
		surface.SetDrawColor( Color(255, 255, 255) )

		local offX = deltaMove * (196 - 32)
		surface.DrawTexturedRect(150 + offX, realH - 256 - 16,  skullW * .15, skullH * .15)

		draw.SimpleText( "Kills: " .. self:GetOwner():Frags(), "CadaverYummy2", 150, realH - 160, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	end

--Rendering the Chainsaw
	local waitPerChange = .025

	local doDrawThing = math.floor((CurTime() * (1 / waitPerChange)) % 2) == 0
	local sawTarget = saw1
	if doDrawThing then
		sawTarget = saw2
	end

	surface.SetMaterial( sawTarget )
	surface.SetDrawColor( Color(255, 255, 255 ) )
	surface.DrawTexturedRect(w - length / 2 - 360 * 3.7, h - scale / 2 + 90 * 5,  length * 2, scale * 2)

--Rendering Fuel
	draw.SimpleText( "Fuel: " .. self:Clip1(), "CadaverYummy", 256 * 9, h * 1.95, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
end