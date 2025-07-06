SWEP.PrintName = "Undeclared Reanimation"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Right click to charge up a bomb attack. Primary Fire to unleash the blast."
SWEP.IconOverride = "vgui/weaponvgui/unique_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.ViewModel	= "models/weapons/c_smg1.mdl"
SWEP.WorldModel	= "models/weapons/w_smg1.mdl"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 2
SWEP.BobScale = 1.15
SWEP.Category = "Artificial Weaponry"

SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "Battery"

local bannedLUT = {
	["CHudAmmo"]      = true,
}

function SWEP:HUDShouldDraw(element)
	if bannedLUT[element] then
		return false
	end
	return true
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	if self:Clip2() == 0 then return end
	self:SetNextPrimaryFire( CurTime() + 1 )

	local ExplDMG = self:Clip2() * 1.25
	local ExplRad = 60 + (self:Clip2() * 1.25)

	local ExplPos = owner:GetShootPos() + ( owner:GetAimVector() * 10 ),

	owner:LagCompensation( true )

		util.BlastDamage( self, owner, ExplPos, ExplRad, ExplDMG )
		util.ScreenShake( ExplPos, ExplDMG, 40, 1, ExplRad, true )

		self:EmitSound( "weapons/mortar/mortar_explode2.wav", 100, math.random(80, 90) - (self:Clip2() * 0.1), 1, 6 )
		self:EmitSound( "tray_sounds/parsite_multihit.mp3", 100, math.random(80, 90) - (self:Clip2() * 0.1), 0.3, 6 )

	owner:LagCompensation( false )

	self:SetClip1( 0 )
	self:SetClip2( 0 )
end


function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + 0.7 )
	if self:Clip1() == 0 then self:SetClip1( 1 ) end

	self:SetClip2( self:Clip2() + 50 )

	local MaxPit = math.random(100 + self:Clip2(), 105 + self:Clip2())

	self:EmitSound( "artiwepsv3/ding.mp3", 100, math.Clamp(MaxPit, 100, 170), 1.5, 6 )

end

function SWEP:SpecialParticles()
local tr =  LocalPlayer():GetEyeTrace()
local pos = tr.HitPos + tr.HitNormal * 100 -- The origin position of the effect

local emitter = ParticleEmitter( pos ) -- Particle emitter in this position

for i = 1, 100 do -- Do 100 particles
	local part = emitter:Add( "effects/spark", pos ) -- Create a new particle at pos
		if ( part ) then
			part:SetDieTime( 1 ) -- How long the particle should "live"

			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime

			part:SetStartSize( 5 ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed

			part:SetGravity( Vector( 0, 0, -250 ) ) -- Gravity of the particle
			part:SetVelocity( VectorRand() * 50 ) -- Initial velocity of the particle
		end
	end

	emitter:Finish()
end


if CLIENT then
	surface.CreateFont( "FunnyAhFont", {
		font = "CloseCaption_Bold",
		extended = false,
		size = 35,
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

	function SWEP:DrawHUD()
	local w = ScrW() / 2
	local h = ScrH() / 2
		draw.SimpleText( "Ammo: " .. self:Clip1(), "FunnyAhFont", w * 1.1, h * 1.05, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( "Charge: " .. self:Clip2(), "FunnyAhFont", w * 1.1025, h * 1.015, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
	end
end