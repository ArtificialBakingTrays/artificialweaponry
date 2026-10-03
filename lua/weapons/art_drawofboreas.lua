SWEP.PrintName = "Draw of Boreas"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "The bone-chilling tension of the string against my hands."
SWEP.Category = GetWeaponPack()
SWEP.IconOverride = "vgui/weaponvgui/draw_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.DrawCrosshair = true
SWEP.ViewModel	= "models/weapons/c_crossbow.mdl"
SWEP.WorldModel	= "models/weapons/w_crossbow.mdl"
SWEP.DrawAmmo = true
SWEP.HoldType = "ar2"
SWEP.Slot = 1
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = 500

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:SecondaryAttack()
	local ownertr = self:GetOwner():GetEyeTrace()
	local targetpos = ownertr.HitPos + Vector(0, 0, 600)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetNextPrimaryFire( CurTime() + 0.4 )
	self:SetNextSecondaryFire( CurTime() + 12.5 )

	self:EmitSound("artiwepsv3/harpoonshot.mp3", 100, math.random(120, 125), 0.7, CHAN_AUTO)
	timer.Simple(0.2, function()
		self:EmitSound("artiwepsv3/boreasmagic.mp3", 100, math.random(130, 145), 0.3, CHAN_AUTO)
		ArtiwepsProjectile( "sh_borealrain", self:GetOwner(), targetpos, Angle(0,0,0), _, 0, false)
	end)
end

function SWEP:SetChargeStart( time ) self:SetDTFloat( 0, time ) end
function SWEP:GetChargeStart() return self:GetDTFloat( 0 ) end

local singleplayer = game.SinglePlayer()
function SWEP:Think()
	if CLIENT and singleplayer then return end
	local start = self:GetChargeStart()
	if start == 0 then return end

	if not self:GetOwner():KeyDown( IN_ATTACK ) then
		self:SetChargeStart( 0 )
		self:ChargeAttack( CurTime() - start )
	end

	if start == 1 then
		self:EmitSound( "npc/roller/blade_cut.wav", 75, pitch, 0.7, 6 )
	end
end

function SWEP:PrimaryAttack()
	if self:GetChargeStart() ~= 0 then return end

	self:EmitSound( "artiwepsv3/bowtension.mp3", 75, 105 )
	self:SetChargeStart( CurTime() )
end


function SWEP:ChargeAttack( charge )
	if charge > 1 then charge = 1 end

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:SetNextPrimaryFire( CurTime() + 0.65 )

	self:EmitSound( "npc/roller/blade_cut.wav", 75, math.random(100.5, 105.5), 0.7, 1 )

	local owner = self:GetOwner()
	local ownvec = owner:GetAimVector()
	local ownshopos = owner:GetShootPos()
	--local ownangles = owner:EyeAngles()

	owner:LagCompensation( true )

	if charge == 1 then
		self:PerfectFire( charge )
		self:EmitSound( "artiwepsv3/staticfire.mp3", 75, math.random(105.5, 110), 0.7, 6 )
	else
		ArtiwepsProjectile( "sh_boreasarrow", self:GetOwner(), ownshopos, self:GetOwner():EyeAngles(), ownvec, 4000 * charge, true )
		self:EmitSound( "artiwepsv2/smack1.mp3", 75, math.random(105.5, 110), 0.7, 6 )
	end

	owner:LagCompensation( false )
end

local offsetSpread = 0.025
local OffsetExtra = offsetSpread + 0.010
local offsetLUT = {
	[1] = Vector(-offsetSpread, 0 ),
	[2] = Vector( 0			  , 0 ),
	[3] = Vector( offsetSpread, 0 ),
	[4] = Vector( OffsetExtra, 0  ),
	[5] = Vector( -OffsetExtra, 0 )
}

function SWEP:PerfectFire( ChargeAm )
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

		ArtiwepsProjectile( "sh_boreasarrow", self:GetOwner(), self:GetOwner():GetShootPos(), self:GetOwner():EyeAngles(), realShootDir, 4000 * ChargeAm, true )
	end
end

--============================[ Fancy Rendering Shit ]============================--

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

local reticle = Material( "particle/Particle_Glow_05", "noclamp smooth" )
function SWEP:DrawHUD()
	if CLIENT then
		local h = ScrH()
		local w = ScrW()

		local delta = self:GetChargeStart()
		if delta ~= 0 then
			delta = CurTime() - delta
			if delta > 1 then delta = 1 end
		end

		surface.SetMaterial(reticle)
		surface.SetDrawColor(Color(81,151,255, 125 * delta))
		surface.DrawTexturedRectRotated( w / 2, h / 2, (w / 2) / 6, (w / 2) / 6, 0 )

		--[[
		local text

		if delta == 1 then text = "Ready!"
		else text = string.format("%.2f", delta) end --ty tiddymso for this format thing

		draw.SimpleText("Arrow: " .. text, "HudDefault", w * .53, h * .48, Color(81,151,255) )
		]]--

		surface.SetMaterial(Material("materials/pngtexts/icearrow.png"))
		surface.SetDrawColor(Color(198,221,255, 255 * delta ))
		surface.DrawTexturedRectRotated( w / 2, (h / 2) - 150, (w / 2) / 6, (w / 2) / 6, 0 )

		surface.SetMaterial(Material("effects/bloodcircle"))
		surface.SetDrawColor(Color(85,153,255, 255 * delta ))
		surface.DrawTexturedRectRotated( w / 2, h / 2, (w / .5) / delta, (w / .5) / delta, 0 )
	end
end

local bannedLUT = {
	--["CHudHealth"]    = true,
	["CHudAmmo"]      = true,
	--["CHudCrosshair"] = true,
	--["CHudBattery"]	  = true,
}

function SWEP:HUDShouldDraw(element)
	if bannedLUT[element] then return false end
	return true
end